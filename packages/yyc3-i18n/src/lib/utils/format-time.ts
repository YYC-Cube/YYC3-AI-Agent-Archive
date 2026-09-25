/**
 * file format-time.ts
 * description 时间格式化工具
 * module @yyc3/i18n-core
 * author YanYuCloudCube Team <admin@0379.email>
 * version 2.3.0
 * created 2026-04-24
 * updated 2026-04-24
 * status active
 * tags [module]
 *
 * copyright YanYuCloudCube Team
 * license MIT
 *
 * brief 时间格式化工具
 */
export type FormatTimeAgoOptions = {
  suffix?: boolean;
  fallback?: string;
};

export function formatTimeAgo(
  durationMs: number | null | undefined,
  options?: FormatTimeAgoOptions,
): string {
  const suffix = options?.suffix !== false;
  const fallback = options?.fallback ?? "unknown";

  if (durationMs == null || !Number.isFinite(durationMs) || durationMs < 0) {
    return fallback;
  }

  const totalSeconds = Math.round(durationMs / 1000);
  const minutes = Math.round(totalSeconds / 60);

  if (minutes < 1) {
    return suffix ? "just now" : `${totalSeconds}s`;
  }
  if (minutes < 60) {
    return suffix ? `${minutes}m ago` : `${minutes}m`;
  }
  const hours = Math.round(minutes / 60);
  if (hours < 24) {
    return suffix ? `${hours}h ago` : `${hours}h`;
  }
  const days = Math.round(hours / 24);
  return suffix ? `${days}d ago` : `${days}d`;
}

export type FormatRelativeTimestampOptions = {
  dateFallback?: boolean;
  /**
   * 日期回退格式化使用的 BCP-47 locale（如 "en" / "zh-CN"）。
   * 显式传入以获得环境无关的稳定输出；缺省回退到框架默认 locale "en"，
   * 不跟随宿主 LANG（避免同一调用在不同机器区域设置下输出不一致）。
   */
  locale?: string;
  timezone?: string;
  fallback?: string;
};

export function formatRelativeTimestamp(
  timestampMs: number | null | undefined,
  options?: FormatRelativeTimestampOptions,
): string {
  const fallback = options?.fallback ?? "n/a";
  if (timestampMs == null || !Number.isFinite(timestampMs)) {
    return fallback;
  }

  const diff = Date.now() - timestampMs;
  const absDiff = Math.abs(diff);
  const isPast = diff >= 0;

  const sec = Math.round(absDiff / 1000);
  if (sec < 60) {
    return isPast ? "just now" : "in <1m";
  }

  const min = Math.round(sec / 60);
  if (min < 60) {
    return isPast ? `${min}m ago` : `in ${min}m`;
  }

  const hr = Math.round(min / 60);
  if (hr < 24) {
    return isPast ? `${hr}h ago` : `in ${hr}h`;
  }

  const day = Math.round(hr / 24);
  if (!options?.dateFallback || day <= 7) {
    return isPast ? `${day}d ago` : `in ${day}d`;
  }

  const date = new Date(timestampMs);
  // 注意：toLocaleDateString 第一个参数是 locales（此前误传 timezone，非法 BCP-47
  // 会抛 RangeError 并静默降级为无参调用，进而跟随宿主 LANG 输出如 "1月5日"）。
  const dateLocale = options?.locale ?? "en";
  try {
    return date.toLocaleDateString(dateLocale, {
      month: "short",
      day: "numeric",
      timeZone: options?.timezone,
    });
  } catch {
    // timeZone 非法（RangeError）时丢弃时区重试，保留月份/日选项与 locale，
    // 不退回到无参调用（无参形式既丢失格式又会跟随宿主 locale）。
    return date.toLocaleDateString(dateLocale, {
      month: "short",
      day: "numeric",
    });
  }
}
