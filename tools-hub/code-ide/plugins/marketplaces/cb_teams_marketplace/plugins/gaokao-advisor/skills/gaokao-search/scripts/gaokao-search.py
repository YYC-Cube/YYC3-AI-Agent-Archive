# -*- coding: utf-8 -*-
"""
Gaokao knowledge base retrieval client.

This script calls AgentTool ImaSearch as the only retrieval path. WorkBuddy
must provide a fresh token from connect_cloud_service for each invocation,
prefer tempToken when present, and fall back to token only when tempToken is
empty. The script only prints data returned by the upstream service and
intentionally avoids fallback generation or heuristic answer synthesis.
"""

import argparse
import contextlib
import hashlib
import io
import json
import mimetypes
import ntpath
import os
from pathlib import Path
import platform
import shutil
import socket
import subprocess
import sys
import time
import urllib.error
import urllib.parse
import urllib.request


DEFAULT_AGENTTOOL_ENDPOINT = "https://copilot.tencent.com/agenttool/v1/imasearch"


def configure_stdio():
    for stream_name in ("stdout", "stderr"):
        stream = getattr(sys, stream_name, None)
        if not stream:
            continue
        reconfigure = getattr(stream, "reconfigure", None)
        if reconfigure:
            try:
                reconfigure(encoding="utf-8", errors="replace")
            except (TypeError, ValueError):
                pass
            continue
        buffer = getattr(stream, "buffer", None)
        if buffer:
            setattr(sys, stream_name, io.TextIOWrapper(buffer, encoding="utf-8", errors="replace", line_buffering=True))


def error_out(error, message, **extra):
    payload = {
        "ok": False,
        "error": error,
        "message": message,
    }
    payload.update(extra)
    print(json.dumps(payload, ensure_ascii=False, indent=2))
    sys.exit(1)


def build_parser():
    parser = argparse.ArgumentParser(
        description="Search Gaokao knowledge base through AgentTool ImaSearch."
    )
    parser.add_argument("query", help="Search query. Use precise Gaokao-related terms.")
    parser.add_argument(
        "--limit",
        type=int,
        default=20,
        help="Number of documents to request from upstream, 1-20. Default: 20.",
    )
    parser.add_argument(
        "--endpoint",
        default=DEFAULT_AGENTTOOL_ENDPOINT,
        help="AgentTool ImaSearch endpoint. Default: https://copilot.tencent.com/agenttool/v1/imasearch.",
    )
    parser.add_argument(
        "--token",
        default="",
        help="Bearer token for this AgentTool request. Must be freshly obtained by connect_cloud_service and passed explicitly.",
    )
    parser.add_argument(
        "--resolve",
        default="",
        help="Optional DNS override in curl --resolve format, e.g. host:443:1.2.3.4.",
    )
    parser.add_argument(
        "--timeout",
        type=int,
        default=30,
        help="HTTP timeout in seconds. Default: 30.",
    )
    parser.add_argument(
        "--download",
        nargs="?",
        choices=["first", "all"],
        const="all",
        default="",
        help="Download matched source files instead of only returning search results. Use 'first' or 'all'.",
    )
    parser.add_argument(
        "--download-index",
        type=int,
        action="append",
        default=[],
        help="Download the 1-based result index. Can be provided multiple times.",
    )
    parser.add_argument(
        "--download-id",
        action="append",
        default=[],
        help="Download the stable download_id returned in chunks. Can be provided multiple times.",
    )
    parser.add_argument(
        "--download-dir",
        default="",
        help="Directory for downloaded files. Required when using --download, --download-id, or --download-index.",
    )
    parser.add_argument(
        "--download-timeout",
        type=int,
        default=60,
        help="File download timeout in seconds. Default: 60.",
    )
    return parser


def normalize_limit(limit):
    if limit < 1:
        return 1
    if limit > 20:
        return 20
    return limit


def build_agenttool_request(args):
    body = {
        "query": args.query,
        "scene": "gaokao",
        "limit": normalize_limit(args.limit),
    }
    headers = {
        "Content-Type": "application/json",
        "Authorization": f"Bearer {args.token}",
    }
    return body, headers, int(time.time())


@contextlib.contextmanager
def temporary_resolve(resolve_rule):
    if not resolve_rule:
        yield
        return

    parts = resolve_rule.rsplit(":", 2)
    if len(parts) != 3:
        error_out("INVALID_RESOLVE", "--resolve 必须使用 host:port:ip 格式。")

    resolve_host, resolve_port, resolve_ip = parts
    try:
        resolve_port = int(resolve_port)
    except ValueError:
        error_out("INVALID_RESOLVE", "--resolve 的端口必须是数字。")

    original_getaddrinfo = socket.getaddrinfo

    def patched_getaddrinfo(host, port, family=0, type=0, proto=0, flags=0):
        if host == resolve_host and int(port) == resolve_port:
            return original_getaddrinfo(resolve_ip, port, family, type, proto, flags)
        return original_getaddrinfo(host, port, family, type, proto, flags)

    socket.getaddrinfo = patched_getaddrinfo
    try:
        yield
    finally:
        socket.getaddrinfo = original_getaddrinfo


def post_json(endpoint, body, headers, timeout, resolve_rule=""):
    data = json.dumps(body, ensure_ascii=False).encode("utf-8")
    req = urllib.request.Request(endpoint, data=data, headers=headers, method="POST")
    try:
        with temporary_resolve(resolve_rule):
            with urllib.request.urlopen(req, timeout=timeout) as resp:
                raw = resp.read().decode("utf-8")
                return resp.status, json.loads(raw), raw
    except urllib.error.HTTPError as exc:
        raw = exc.read().decode("utf-8", errors="replace")
        try:
            parsed = json.loads(raw)
        except json.JSONDecodeError:
            parsed = {"raw": raw}
        return exc.code, parsed, raw
    except urllib.error.URLError as exc:
        error_out("CONNECTION_ERROR", "检索服务连接失败。", detail=str(exc.reason))
    except TimeoutError:
        error_out("TIMEOUT", "检索服务请求超时。")
    except json.JSONDecodeError:
        error_out("INVALID_RESPONSE", "检索服务返回了非 JSON 响应。")


def displayable_url(url):
    return ""


def make_chunk_payload(*, title, abstract, url, content, score, resource_id, chunk_id,
                       chunk_index, source, publish_time):
    payload = {
        "title": title or "",
        "abstract": abstract or "",
        "url": displayable_url(url),
        "content": content or "",
        "score": score,
        "resource_id": resource_id or "",
        "chunk_id": chunk_id or "",
        "chunk_index": chunk_index,
        "source": source,
        "publish_time": publish_time or "",
        "download_available": bool(url),
        "_download_url": url or "",
    }
    payload["download_id"] = make_download_id(payload)
    return payload


def make_download_id(chunk):
    parts = [
        chunk.get("resource_id") or "",
        chunk.get("chunk_id") or "",
        str(chunk.get("chunk_index") or ""),
        chunk.get("_download_url") or "",
        chunk.get("title") or "",
    ]
    digest = hashlib.sha256("\x1f".join(parts).encode("utf-8")).hexdigest()
    return f"dl_{digest[:16]}"


def format_agenttool_chunks(chunks):
    formatted = []
    for item in chunks:
        if not isinstance(item, dict):
            continue
        score = item.get("score", 0)
        try:
            score = float(score)
        except (TypeError, ValueError):
            score = 0.0
        formatted.append(make_chunk_payload(
            title=item.get("chunk_title") or item.get("title") or "",
            abstract=item.get("chunk_abstract") or item.get("abstract") or "",
            url=item.get("chunk_url") or item.get("url") or "",
            content=item.get("content") or "",
            score=score,
            resource_id=item.get("resource_id") or "",
            chunk_id=item.get("chunk_id") or "",
            chunk_index=item.get("chunk_index"),
            source=item.get("source"),
            publish_time=item.get("publish_time", ""),
        ))
    return sorted(formatted, key=lambda x: x["score"], reverse=True)


def sanitize_filename(name):
    cleaned = "".join("_" if ch in '<>:"/\\|?*\r\n\t' else ch for ch in name).strip(" .")
    if not cleaned:
        return "gaokao-document"
    reserved = {
        "CON", "PRN", "AUX", "NUL",
        "COM1", "COM2", "COM3", "COM4", "COM5", "COM6", "COM7", "COM8", "COM9",
        "LPT1", "LPT2", "LPT3", "LPT4", "LPT5", "LPT6", "LPT7", "LPT8", "LPT9",
    }
    if cleaned.upper() in reserved:
        cleaned = f"{cleaned}_file"
    return cleaned[:180]


def filename_from_url(url):
    parsed = urllib.parse.urlparse(url)
    name = Path(urllib.parse.unquote(parsed.path)).name
    return name or ""


def filename_from_headers(headers):
    disposition = headers.get("Content-Disposition", "")
    if not disposition:
        return ""
    params = {}
    for part in disposition.split(";")[1:]:
        if "=" not in part:
            continue
        key, value = part.split("=", 1)
        params[key.strip().lower()] = value.strip().strip('"')
    filename = params.get("filename*") or params.get("filename") or ""
    if filename and "''" in filename:
        filename = filename.split("''", 1)[1]
    return urllib.parse.unquote(filename or "")


def unique_path(path):
    if not path.exists():
        return path
    stem = path.stem
    suffix = path.suffix
    for i in range(2, 1000):
        candidate = path.with_name(f"{stem} ({i}){suffix}")
        if not candidate.exists():
            return candidate
    return path.with_name(f"{stem} ({int(time.time())}){suffix}")


def ensure_extension(path, content_type):
    if path.suffix:
        return path
    extension = ".pdf" if "application/pdf" in content_type else mimetypes.guess_extension(content_type.split(";", 1)[0].strip())
    if not extension:
        extension = ".bin"
    return path.with_suffix(extension)


def download_file(url, title, output_dir, timeout):
    req = urllib.request.Request(
        url,
        headers={"User-Agent": "WorkBuddy-GaokaoAdvisor/1.0"},
        method="GET",
    )
    with urllib.request.urlopen(req, timeout=timeout) as resp:
        content_type = resp.headers.get("Content-Type", "")
        header_name = filename_from_headers(resp.headers)
        preferred_name = title or header_name or filename_from_url(url) or "gaokao-document"
        output_path = Path(output_dir) / sanitize_filename(preferred_name)
        output_path = ensure_extension(output_path, content_type)
        output_path = unique_path(output_path)
        content = resp.read()
        if not content:
            raise ValueError("下载内容为空")
        with open(output_path, "wb") as file:
            file.write(content)
    return output_path, len(content)


def command_text(parts):
    return " ".join(f'"{part}"' if " " in str(part) else str(part) for part in parts)


def open_folder_command(system, folder):
    if system == "Darwin":
        return ["open", str(folder)], command_text(["open", str(folder)])
    opener = shutil.which("xdg-open")
    if not opener:
        return None, ""
    return [opener, str(folder)], command_text([opener, str(folder)])


def run_open_command(command, *, system, timeout=10):
    check = system != "Windows"
    completed = subprocess.run(command, check=check, timeout=timeout)
    return getattr(completed, "returncode", 0)


def fallback_open_folder(system, folder):
    result = {
        "ok": False,
        "platform": system or "Unknown",
        "folder": str(folder),
    }
    if system == "Windows":
        result["command"] = "os.startfile(<folder>)"
        startfile = getattr(os, "startfile", None)
        if not startfile:
            result.update({
                "error": "STARTFILE_NOT_AVAILABLE",
                "message": "当前 Python 环境不支持 os.startfile，无法打开文件夹。",
            })
            return result
        try:
            startfile(str(folder))
            result.update({
                "ok": True,
                "message": "已打开文件所在文件夹。",
            })
        except OSError as exc:
            result.update({
                "error": "OPEN_FOLDER_FAILED",
                "message": f"打开文件所在文件夹失败：{exc}。",
            })
        return result

    command, display_command = open_folder_command(system, folder)
    if not command:
        result.update({
            "error": "OPENER_NOT_FOUND",
            "message": "当前系统未找到可用的文件夹打开命令。",
        })
        return result
    result["command"] = display_command
    try:
        return_code = run_open_command(command, system=system, timeout=10)
        result.update({
            "ok": True,
            "return_code": return_code,
            "message": "已打开文件所在文件夹，但未定位到具体文件。",
        })
    except subprocess.TimeoutExpired:
        result.update({
            "error": "OPEN_FOLDER_TIMEOUT",
            "message": "打开文件所在文件夹超时。",
        })
    except (OSError, subprocess.CalledProcessError) as exc:
        result.update({
            "error": "OPEN_FOLDER_FAILED",
            "message": f"打开文件所在文件夹失败：{exc}。",
        })
    return result


def open_download_location(path):
    system = platform.system()
    target = Path(path).resolve()
    folder = target.parent
    if system == "Windows":
        target = str(path)
        folder = ntpath.dirname(target) or target
    result = {
        "ok": False,
        "platform": system or "Unknown",
        "path": str(target),
        "folder": str(folder),
    }

    try:
        if system == "Darwin":
            command = ["open", "-R", str(target)]
            result["command"] = command_text(command)
            return_code = run_open_command(command, system=system, timeout=10)
        elif system == "Windows":
            result["command"] = "os.startfile(<folder>)"
            startfile = getattr(os, "startfile", None)
            if not startfile:
                result.update({
                    "error": "STARTFILE_NOT_AVAILABLE",
                    "message": "当前 Python 环境不支持 os.startfile，无法打开文件夹。",
                })
                return result
            startfile(str(folder))
            return_code = 0
        else:
            opener = shutil.which("xdg-open")
            if not opener:
                result.update({
                    "error": "OPENER_NOT_FOUND",
                    "message": "当前系统未找到可用的文件夹打开命令。",
                })
                return result
            command = [opener, str(folder)]
            result["command"] = command_text(command)
            return_code = run_open_command(command, system=system, timeout=10)
        result.update({
            "ok": True,
            "return_code": return_code,
            "message": "已打开文件所在文件夹。",
        })
    except subprocess.TimeoutExpired:
        fallback = fallback_open_folder(system, folder)
        result.update({
            "error": "OPEN_LOCATION_TIMEOUT",
            "message": "定位文件超时。",
            "fallback_open_folder": fallback,
        })
        if fallback.get("ok"):
            result.update({
                "ok": True,
                "selected": False,
                "message": "定位文件超时，已打开文件所在文件夹。",
            })
    except (OSError, subprocess.CalledProcessError) as exc:
        fallback = fallback_open_folder(system, folder)
        result.update({
            "error": "OPEN_LOCATION_FAILED",
            "message": f"定位文件失败：{exc}。",
            "fallback_open_folder": fallback,
        })
        if fallback.get("ok"):
            result.update({
                "ok": True,
                "selected": False,
                "message": "未能定位到具体文件，已打开文件所在文件夹。",
            })
    return result


def selected_download_indexes(args, chunks):
    total = len(chunks)
    explicit = sorted({idx for idx in args.download_index if idx > 0})
    by_index = [idx for idx in explicit if idx <= total]
    wanted_ids = {download_id.strip() for download_id in args.download_id if download_id.strip()}
    by_id = [
        index
        for index, chunk in enumerate(chunks, start=1)
        if chunk.get("download_id") in wanted_ids
    ]
    combined = sorted(set(by_index + by_id))
    if combined:
        return combined
    if args.download == "first":
        return [1] if total else []
    if args.download == "all":
        return list(range(1, total + 1))
    return []


def download_selection_errors(args, chunks, selected_indexes):
    errors = []
    total = len(chunks)
    selected = set(selected_indexes)
    for index in sorted({idx for idx in args.download_index if idx > 0}):
        if index not in selected and index > total:
            errors.append({
                "ok": False,
                "download_index": index,
                "error": "DOWNLOAD_INDEX_NOT_FOUND",
                "message": f"当前检索结果中没有 download_index={index}。请使用当前结果里的 download_id，或重新确认目标资料。",
            })
    available_ids = {chunk.get("download_id") for chunk in chunks}
    for download_id in sorted({item.strip() for item in args.download_id if item.strip()}):
        if download_id not in available_ids:
            errors.append({
                "ok": False,
                "download_id": download_id,
                "error": "DOWNLOAD_ID_NOT_FOUND",
                "message": f"当前检索结果中没有 download_id={download_id}。请用当前结果返回的 download_id 下载，或先重新检索并确认目标资料。",
            })
    return errors


def has_download_intent(args):
    if args.download:
        return True
    return any(idx > 0 for idx in args.download_index) or any(download_id.strip() for download_id in args.download_id)


def download_chunks(chunks, args):
    indexes = selected_download_indexes(args, chunks)
    selection_errors = download_selection_errors(args, chunks, indexes)
    if not indexes:
        return selection_errors
    if not args.download_dir:
        error_out(
            "DOWNLOAD_DIR_REQUIRED",
            "下载资料时必须显式指定 --download-dir。Agent 应先判断合适的保存目录：有 /workspace 时下载到 /workspace；没有 /workspace 时可选择当前工作目录。",
        )
    output_dir = Path(args.download_dir).expanduser().resolve()
    output_dir.mkdir(parents=True, exist_ok=True)

    downloads = []
    downloads.extend(selection_errors)
    seen_urls = set()
    for index in indexes:
        chunk = chunks[index - 1]
        url = chunk.get("_download_url", "")
        result = {
            "index": index,
            "download_index": index,
            "download_id": chunk.get("download_id", ""),
            "title": chunk.get("title", ""),
            "ok": False,
        }
        if not url:
            result.update({"error": "NO_DOWNLOAD_URL", "message": "该结果没有可下载文件地址。"})
            downloads.append(result)
            continue
        if url in seen_urls:
            result.update({"error": "DUPLICATE_URL", "message": "该文件已在本次调用中下载过。"})
            downloads.append(result)
            continue
        seen_urls.add(url)
        try:
            path, bytes_downloaded = download_file(url, chunk.get("title", ""), output_dir, args.download_timeout)
            result.update({
                "ok": True,
                "file": str(path),
                "local_path": str(path),
                "bytes_downloaded": bytes_downloaded,
                "folder_opened": False,
                "open_location": None,
                "message": f"资料已下载，文件路径：{path}",
            })
        except urllib.error.HTTPError as exc:
            result.update({"error": "DOWNLOAD_HTTP_ERROR", "message": f"下载失败：HTTP {exc.code}。"})
        except urllib.error.URLError as exc:
            result.update({"error": "DOWNLOAD_CONNECTION_ERROR", "message": f"下载连接失败：{exc.reason}。"})
        except TimeoutError:
            result.update({"error": "DOWNLOAD_TIMEOUT", "message": "下载请求超时。"})
        except ValueError as exc:
            result.update({"error": "DOWNLOAD_EMPTY_FILE", "message": f"下载失败：{exc}。"})
        except OSError as exc:
            result.update({"error": "DOWNLOAD_FILE_ERROR", "message": f"写入文件失败：{exc}。"})
        downloads.append(result)
    return downloads


def has_downloaded_content(download):
    if not download.get("ok"):
        return False
    path = download.get("local_path") or download.get("file")
    if not path:
        return False
    try:
        local_file = Path(path)
        return local_file.is_file() and local_file.stat().st_size > 0 and download.get("bytes_downloaded", 0) > 0
    except OSError:
        return False


def attachment_paths(downloads):
    return [
        download.get("local_path") or download.get("file")
        for download in downloads
        if has_downloaded_content(download)
    ]


def public_chunk(chunk, index):
    payload = {key: value for key, value in chunk.items() if not key.startswith("_")}
    payload["download_index"] = index
    return payload


def main():
    parser = build_parser()
    args = parser.parse_args()

    query = args.query.strip()
    if not query:
        error_out("INVALID_QUERY", "检索 query 不能为空。")

    args.query = query
    if has_download_intent(args) and not args.download_dir:
        error_out(
            "DOWNLOAD_DIR_REQUIRED",
            "下载资料时必须显式指定 --download-dir。Agent 应先判断合适的保存目录：有 /workspace 时下载到 /workspace；没有 /workspace 时可选择当前工作目录。",
        )
    endpoint = args.endpoint
    if not args.token:
        error_out(
            "TOKEN_NOT_CONFIGURED",
            "gaokao-search 只支持 AgentTool 模式，需要本次调用新获取的 Bearer token。请先调用 connect_cloud_service，优先使用 tempToken；如果没有 tempToken，再使用 token，并通过 --token 传入。",
            endpoint=endpoint,
        )
    body, headers, timestamp = build_agenttool_request(args)

    status, data, _raw = post_json(endpoint, body, headers, args.timeout, args.resolve)

    if status != 200:
        message = str(data.get("msg") or data.get("message") or data.get("raw") or "")
        if status == 429 or "daily search limit exceeded" in message:
            error_out(
                "DAILY_LIMIT_EXCEEDED",
                "高考知识库检索今日配额已用尽。请先复用本轮已返回结果；如仍需补充证据，请明天再试或改查官方渠道。",
                upstream_status=status,
                upstream_response=data,
                endpoint=endpoint,
            )
        error_out(
            "SEARCH_FAILED",
            f"检索服务 HTTP {status}。",
            upstream_status=status,
            upstream_response=data,
            endpoint=endpoint,
        )

    code = data.get("code")
    message = str(data.get("msg") or data.get("message") or data.get("raw") or "")
    if code == 14003 or "daily search limit exceeded" in message:
        error_out(
            "DAILY_LIMIT_EXCEEDED",
            "高考知识库检索今日配额已用尽。请先复用本轮已返回结果；如仍需补充证据，请明天再试或改查官方渠道。",
            upstream_response=data,
            endpoint=endpoint,
        )

    if code not in (None, 0):
        error_out(
            "SEARCH_FAILED",
            f"检索服务返回 code={code}。",
            upstream_response=data,
            endpoint=endpoint,
        )

    chunks = format_agenttool_chunks(data.get("chunks") or [])
    upstream_format = "agenttool_chunks"

    downloads = download_chunks(chunks, args)
    attachments = attachment_paths(downloads)
    download_root = str(Path(args.download_dir).expanduser().resolve()) if args.download_dir else ""
    public_chunks = [public_chunk(chunk, index) for index, chunk in enumerate(chunks, start=1)]

    output = {
        "ok": True,
        "query": query,
        "total": len(chunks),
        "retrieval_status": "hit" if chunks else "empty",
        "chunks": public_chunks,
        "downloads": downloads,
        "attachment_paths": attachments,
        "download_root": download_root,
        "source_note": (
            "All chunks are extracted from the search API response. Empty result means no supported evidence was returned. "
            "Document URLs are intentionally hidden from display; use download_id with --download-id to download after user confirmation. "
            "Use download_index only within the same returned result set."
        ),
        "action_required": {
            "tool": "deliver_attachments",
            "tool_input_paths": attachments,
            "tool_call_scope": "Call the deliver_attachments tool with every path in tool_input_paths; one path means one attachment, multiple paths means all attachments.",
            "tool_call_strategy": "Pass all paths in one tool call if supported; otherwise call the tool once per path until every path is delivered.",
            "user_message": "After delivery, list the delivered local path(s). Ask whether the user wants the containing folder opened.",
            "open_folder": "Do not open automatically. Open only after the user confirms.",
        },
        "request": {
            "mode": "agenttool",
            "effective_mode": "agenttool",
            "endpoint": endpoint,
            "limit": body.get("limit"),
            "scene": body.get("scene"),
            "upstream_format": upstream_format,
            "timestamp": timestamp,
        },
    }
    print(json.dumps(output, ensure_ascii=False, indent=2))


if __name__ == "__main__":
    configure_stdio()
    main()
