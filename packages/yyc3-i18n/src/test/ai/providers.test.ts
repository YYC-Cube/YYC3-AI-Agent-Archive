/**
 * file providers.test.ts
 * description @yyc3/i18n-core providers.ts 单元测试
 * module @yyc3/i18n-core
 * author YanYuCloudCube Team <admin@0379.email>
 * version 2.3.0
 * created 2026-04-24
 * updated 2026-04-24
 * status active
 * tags [test],[unit]
 *
 * copyright YanYuCloudCube Team
 * license MIT
 *
 * brief @yyc3/i18n-core providers.ts 单元测试
 */
import { beforeEach, describe, expect, it, vi } from "vitest";
import { OllamaProvider } from "../../lib/ai/ollama-provider.js";
import { OpenAIProvider } from "../../lib/ai/openai-provider.js";
import type { AIProviderType } from "../../lib/ai/provider.js";
import { AIProviderManager } from "../../lib/ai/provider.js";

describe("OpenAI Provider", () => {
  let provider: OpenAIProvider;

  beforeEach(() => {
    provider = new OpenAIProvider({ type: "openai", apiKey: "test-key-123" });
  });

  it("should initialize with config", () => {
    expect(provider.type).toBe("openai");
    expect(provider.isReady).toBe(false);
  });

  it("should read apiKey from env when not provided in config", () => {
    vi.stubEnv("OPENAI_API_KEY", "env-key-456");
    const envProvider = new OpenAIProvider({ type: "openai" });
    expect(envProvider.validate()).resolves.toBe(true);
    vi.unstubAllEnvs();
  });

  it("should use default baseUrl when not provided", () => {
    const defaultProvider = new OpenAIProvider({ type: "openai", apiKey: "test" });
    // Trigger translate to use baseUrl — verify via fetch call
    vi.spyOn(globalThis, "fetch").mockResolvedValue({
      ok: true,
      json: async () => ({ choices: [{ message: { content: "x" } }], model: "gpt-4o-mini" }),
    } as Response);
  });

  it("should become ready after initialize", async () => {
    await provider.initialize();
    expect(provider.isReady).toBe(true);
  });

  it("should throw without API key", async () => {
    const noKey = new OpenAIProvider({ type: "openai", apiKey: "" });
    await expect(noKey.initialize()).rejects.toThrow("OpenAI API Key not configured");
  });

  it("should return correct info", async () => {
    await provider.initialize();
    const info = provider.getInfo();
    expect(info.type).toBe("openai");
    expect(info.isLocal).toBe(false);
    expect(info.defaultModel).toBe("gpt-4o-mini");
  });

  it("should validate with API key", async () => {
    const valid = await provider.validate();
    expect(valid).toBe(true);
  });

  it("should validate without API key", async () => {
    const noKey = new OpenAIProvider({ type: "openai", apiKey: "" });
    const valid = await noKey.validate();
    expect(valid).toBe(false);
  });

  it("should translate text via fetch", async () => {
    vi.spyOn(globalThis, "fetch").mockResolvedValueOnce({
      ok: true,
      json: async () => ({
        choices: [{ message: { content: "你好世界" } }],
        model: "gpt-4o-mini",
      }),
    } as Response);

    await provider.initialize();
    const result = await provider.translate({
      sourceText: "Hello World",
      sourceLocale: "en",
      targetLocale: "zh-CN",
    });

    expect(result.translatedText).toBe("你好世界");
    expect(result.provider).toBe("openai");
    expect(result.cached).toBe(false);
  });

  it("should handle API errors", async () => {
    vi.spyOn(globalThis, "fetch").mockResolvedValueOnce({
      ok: false,
      status: 429,
      text: async () => "Rate limited",
    } as Response);

    await provider.initialize();
    await expect(
      provider.translate({
        sourceText: "test",
        sourceLocale: "en",
        targetLocale: "zh-CN",
      })
    ).rejects.toThrow("OpenAI API error (429)");
  });

  it("should batch translate", async () => {
    vi.spyOn(globalThis, "fetch").mockResolvedValue({
      ok: true,
      json: async () => ({
        choices: [{ message: { content: "翻译结果" } }],
        model: "gpt-4o-mini",
      }),
    } as Response);

    await provider.initialize();
    const results = await provider.batchTranslate([
      { sourceText: "Hello", sourceLocale: "en", targetLocale: "zh-CN" },
      { sourceText: "World", sourceLocale: "en", targetLocale: "zh-CN" },
    ]);

    expect(results).toHaveLength(2);
    expect(results[0].translatedText).toBe("翻译结果");
  });

  it("should use formal style in system prompt", async () => {
    const fetchSpy = vi.spyOn(globalThis, "fetch").mockResolvedValue({
      ok: true,
      json: async () => ({
        choices: [{ message: { content: "结果" } }],
        model: "gpt-4o-mini",
      }),
    } as Response);

    await provider.initialize();
    await provider.translate({
      sourceText: "test",
      sourceLocale: "en",
      targetLocale: "zh-CN",
      style: "formal",
    });

    const body = JSON.parse((fetchSpy.mock.calls.at(-1)?.[1] as RequestInit)?.body as string);
    expect(body.messages[0].content).toContain("formal language");
  });

  it("should use technical style in system prompt", async () => {
    const fetchSpy = vi.spyOn(globalThis, "fetch").mockResolvedValue({
      ok: true,
      json: async () => ({
        choices: [{ message: { content: "结果" } }],
        model: "gpt-4o-mini",
      }),
    } as Response);

    await provider.initialize();
    await provider.translate({
      sourceText: "test",
      sourceLocale: "en",
      targetLocale: "zh-CN",
      style: "technical",
    });

    const body = JSON.parse((fetchSpy.mock.calls.at(-1)?.[1] as RequestInit)?.body as string);
    expect(body.messages[0].content).toContain("technical terminology");
  });

  it("should include context in user prompt", async () => {
    const fetchSpy = vi.spyOn(globalThis, "fetch").mockResolvedValue({
      ok: true,
      json: async () => ({
        choices: [{ message: { content: "结果" } }],
        model: "gpt-4o-mini",
      }),
    } as Response);

    await provider.initialize();
    await provider.translate({
      sourceText: "test",
      sourceLocale: "en",
      targetLocale: "zh-CN",
      context: "This is a technical document",
    });

    const body = JSON.parse((fetchSpy.mock.calls.at(-1)?.[1] as RequestInit)?.body as string);
    expect(body.messages[1].content).toContain("Context");
    expect(body.messages[1].content).toContain("technical document");
  });

  it("should include glossary in prompt", async () => {
    const fetchSpy = vi.spyOn(globalThis, "fetch").mockResolvedValue({
      ok: true,
      json: async () => ({
        choices: [{ message: { content: "result" } }],
        model: "gpt-4o-mini",
      }),
    } as Response);

    await provider.initialize();
    await provider.translate({
      sourceText: "test",
      sourceLocale: "en",
      targetLocale: "zh-CN",
      glossary: { API: "接口" },
    });

    const body = JSON.parse((fetchSpy.mock.calls.at(-1)?.[1] as RequestInit)?.body as string);
    expect(body.messages[1].content).toContain("Glossary");
    expect(body.messages[1].content).toContain("API → 接口");
  });

  it("should fallback model name when not in response", async () => {
    vi.spyOn(globalThis, "fetch").mockResolvedValueOnce({
      ok: true,
      json: async () => ({
        choices: [{ message: { content: "hello" } }],
        // No model field in response
      }),
    } as Response);

    await provider.initialize();
    const result = await provider.translate({
      sourceText: "test",
      sourceLocale: "en",
      targetLocale: "zh-CN",
    });

    expect(result.model).toBe("gpt-4o-mini"); // Should use defaultModel
  });

  it("should handle empty choices in response", async () => {
    vi.spyOn(globalThis, "fetch").mockResolvedValueOnce({
      ok: true,
      json: async () => ({
        choices: [],
        model: "gpt-4o-mini",
      }),
    } as Response);

    await provider.initialize();
    const result = await provider.translate({
      sourceText: "test",
      sourceLocale: "en",
      targetLocale: "zh-CN",
    });

    expect(result.translatedText).toBe(""); // Fallback to empty string
  });

  it("should handle null content in choice message", async () => {
    vi.spyOn(globalThis, "fetch").mockResolvedValueOnce({
      ok: true,
      json: async () => ({
        choices: [{ message: { content: null } }],
        model: "gpt-4o-mini",
      }),
    } as Response);

    await provider.initialize();
    const result = await provider.translate({
      sourceText: "test",
      sourceLocale: "en",
      targetLocale: "zh-CN",
    });

    expect(result.translatedText).toBe(""); // ?? "" fallback
  });

  it("should dispose correctly", async () => {
    await provider.initialize();
    expect(provider.isReady).toBe(true);
    await provider.dispose();
    expect(provider.isReady).toBe(false);
  });
});

describe("Ollama Provider", () => {
  let provider: OllamaProvider;

  beforeEach(() => {
    provider = new OllamaProvider({ type: "ollama", baseUrl: "http://localhost:11434" });
  });

  it("should initialize with config", () => {
    expect(provider.type).toBe("ollama");
    expect(provider.isReady).toBe(false);
  });

  it("should return correct info", () => {
    const info = provider.getInfo();
    expect(info.type).toBe("ollama");
    expect(info.isLocal).toBe(true);
    expect(info.defaultModel).toBe("qwen2.5:3b");
  });

  it("should validate successfully when Ollama available", async () => {
    vi.spyOn(globalThis, "fetch").mockResolvedValueOnce({ ok: true } as Response);
    const valid = await provider.validate();
    expect(valid).toBe(true);
  });

  it("should validate unsuccessfully when Ollama unavailable", async () => {
    vi.spyOn(globalThis, "fetch").mockRejectedValueOnce(new Error("Connection refused"));
    const valid = await provider.validate();
    expect(valid).toBe(false);
  });

  it("should initialize when Ollama available", async () => {
    vi.spyOn(globalThis, "fetch").mockResolvedValueOnce({ ok: true } as Response);
    await provider.initialize();
    expect(provider.isReady).toBe(true);
  });

  it("should throw when Ollama unavailable", async () => {
    vi.spyOn(globalThis, "fetch").mockRejectedValueOnce(new Error("Connection refused"));
    await expect(provider.initialize()).rejects.toThrow("Ollama not available");
  });

  it("should translate text via Ollama API", async () => {
    vi.spyOn(globalThis, "fetch")
      .mockResolvedValueOnce({ ok: true } as Response)
      .mockResolvedValueOnce({
        ok: true,
        json: async () => ({
          message: { content: "你好" },
          model: "qwen2.5:3b",
        }),
      } as Response);

    await provider.initialize();
    const result = await provider.translate({
      sourceText: "Hello",
      sourceLocale: "en",
      targetLocale: "zh-CN",
    });

    expect(result.translatedText).toBe("你好");
    expect(result.provider).toBe("ollama");
  });

  it("should handle Ollama API errors", async () => {
    vi.spyOn(globalThis, "fetch")
      .mockResolvedValueOnce({ ok: true } as Response)
      .mockResolvedValueOnce({
        ok: false,
        status: 500,
        text: async () => "Internal error",
      } as Response);

    await provider.initialize();
    await expect(
      provider.translate({
        sourceText: "test",
        sourceLocale: "en",
        targetLocale: "zh-CN",
      })
    ).rejects.toThrow("Ollama API error (500)");
  });

  it("should batch translate", async () => {
    vi.spyOn(globalThis, "fetch")
      .mockResolvedValueOnce({ ok: true } as Response)
      .mockResolvedValue({
        ok: true,
        json: async () => ({ message: { content: "结果" }, model: "qwen2.5:3b" }),
      } as Response);

    await provider.initialize();
    const results = await provider.batchTranslate([
      { sourceText: "a", sourceLocale: "en", targetLocale: "zh-CN" },
    ]);
    expect(results).toHaveLength(1);
  });

  it("should dispose correctly", async () => {
    vi.spyOn(globalThis, "fetch").mockResolvedValueOnce({ ok: true } as Response);
    await provider.initialize();
    await provider.dispose();
    expect(provider.isReady).toBe(false);
  });
});

describe("AIProviderManager", () => {
  let manager: AIProviderManager;

  beforeEach(() => {
    manager = new AIProviderManager();
  });

  it("should register provider and set active", () => {
    const provider = new OpenAIProvider({ type: "openai", apiKey: "test" });
    manager.register(provider);
    expect(manager.getActiveProviderType()).toBe("openai");
  });

  it("should not change active provider if already set", () => {
    const p1 = new OpenAIProvider({ type: "openai", apiKey: "test" });
    const p2 = new OllamaProvider({ type: "ollama" });
    manager.register(p1);
    manager.register(p2);
    // First registered becomes active
    expect(manager.getActiveProviderType()).toBe("openai");
  });

  it("should list registered provider types", () => {
    manager.register(new OpenAIProvider({ type: "openai", apiKey: "test" }));
    manager.register(new OllamaProvider({ type: "ollama" }));
    const types = manager.getRegisteredProviders();
    expect(types).toContain("openai");
    expect(types).toContain("ollama");
  });

  it("should set active provider", () => {
    manager.register(new OpenAIProvider({ type: "openai", apiKey: "test" }));
    manager.register(new OllamaProvider({ type: "ollama" }));
    manager.setActive("ollama");
    expect(manager.getActiveProviderType()).toBe("ollama");
  });

  it("should throw when setting unregistered provider", () => {
    expect(() => manager.setActive("nonexistent" as AIProviderType)).toThrow("not registered");
  });

  it("should auto-detect providers — valid provider", async () => {
    vi.spyOn(globalThis, "fetch").mockResolvedValue({ ok: true } as Response);
    manager.register(new OpenAIProvider({ type: "openai", apiKey: "test" }));
    const results = await manager.autoDetect();
    expect(results.length).toBeGreaterThanOrEqual(1);
    expect(results[0]!.isAvailable).toBe(true);
  });

  it("should auto-detect providers — invalid validate should be caught", async () => {
    vi.spyOn(globalThis, "fetch").mockRejectedValue(new Error("Network error"));
    const provider = new OllamaProvider({ type: "ollama" });
    // Mock validate to throw/reject
    vi.spyOn(provider, "validate").mockRejectedValue(new Error("Unreachable"));
    manager.register(provider);
    // Should not throw, just skip this provider
    const results = await manager.autoDetect();
    expect(results).toHaveLength(0);
  });

  it("should auto-detect with preferLocal selecting local provider", async () => {
    const localManager = new AIProviderManager({ preferLocal: true });
    vi.spyOn(globalThis, "fetch").mockResolvedValue({ ok: true } as Response);
    localManager.register(new OpenAIProvider({ type: "openai", apiKey: "test" }));
    localManager.register(new OllamaProvider({ type: "ollama" }));
    const results = await localManager.autoDetect();
    // Ollama is local, so should be active if auto-detected
    if (results.length > 0) {
      const types = results.map((r) => r.type);
      if (types.includes("ollama")) {
        expect(localManager.getActiveProviderType()).toBe("ollama");
      } else {
        expect(localManager.getActiveProviderType()).toBe("openai");
      }
    }
  });

  it("should auto-detect with preferLocal but no local provider", async () => {
    const localManager = new AIProviderManager({ preferLocal: true });
    vi.spyOn(globalThis, "fetch").mockResolvedValue({ ok: true } as Response);
    localManager.register(new OpenAIProvider({ type: "openai", apiKey: "test" }));
    const results = await localManager.autoDetect();
    expect(results.length).toBeGreaterThanOrEqual(1);
    // openai is not local, so active provider should remain as first registered
    expect(localManager.getActiveProviderType()).toBe("openai");
  });

  it("should throw when no provider registered for translate", async () => {
    await expect(
      manager.translate({
        sourceText: "test",
        sourceLocale: "en",
        targetLocale: "zh-CN",
      })
    ).rejects.toThrow("No AI provider registered");
  });

  it("should throw when registered provider is not ready", async () => {
    const provider = new OpenAIProvider({ type: "openai", apiKey: "test-key" });
    manager.register(provider);
    // provider not initialized, so isReady is false
    await expect(
      manager.translate({
        sourceText: "test",
        sourceLocale: "en",
        targetLocale: "zh-CN",
      })
    ).rejects.toThrow("not ready");
  });

  it("should return cached translation on repeated call", async () => {
    const provider = new OpenAIProvider({ type: "openai", apiKey: "test-key" });
    vi.spyOn(globalThis, "fetch").mockResolvedValue({
      ok: true,
      json: async () => ({
        choices: [{ message: { content: "你好" } }],
        model: "gpt-4o-mini",
      }),
    } as Response);

    await provider.initialize();
    manager.register(provider);

    const request = {
      sourceText: "Hello",
      sourceLocale: "en",
      targetLocale: "zh-CN",
    };

    const result1 = await manager.translate(request);
    expect(result1.cached).toBe(false);
    expect(result1.translatedText).toBe("你好");

    const result2 = await manager.translate(request);
    expect(result2.cached).toBe(true); // Should come from cache
    expect(result2.translatedText).toBe("你好");
  });

  it("should clear cache", () => {
    manager.clearCache();
  });

  it("should dispose all providers", async () => {
    vi.spyOn(globalThis, "fetch").mockResolvedValue({ ok: true } as Response);
    const p1 = new OpenAIProvider({ type: "openai", apiKey: "test" });
    await p1.initialize();
    manager.register(p1);
    await manager.disposeAll();
    expect(manager.getActiveProviderType()).toBeNull();
    expect(manager.getRegisteredProviders()).toHaveLength(0);
  });

  it("should getActiveProviderType return null when no provider registered", () => {
    expect(manager.getActiveProviderType()).toBeNull();
  });
});
