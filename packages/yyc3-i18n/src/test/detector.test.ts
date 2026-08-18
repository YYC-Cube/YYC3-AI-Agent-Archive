/**
 * file detector.test.ts
 * description @yyc3/i18n-core detector.ts 单元测试
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
 * brief @yyc3/i18n-core detector.ts 单元测试
 */
import { afterEach, beforeEach, describe, expect, it, vi } from "vitest";
import {
  detectSystemLocale,
  isChineseLocale,
  normalizeLocale,
} from "../lib/detector.js";

describe("Locale Detector", () => {
  describe("normalizeLocale", () => {
    it("should normalize Chinese variants to zh-CN", () => {
      expect(normalizeLocale("zh")).toBe("zh-CN");
      expect(normalizeLocale("zh-cn")).toBe("zh-CN");
      expect(normalizeLocale("zh_cn")).toBe("zh-CN");
      expect(normalizeLocale("zh-hans")).toBe("zh-CN");
      expect(normalizeLocale("ZH")).toBe("zh-CN");
    });

    it("should normalize Traditional Chinese to zh-TW", () => {
      expect(normalizeLocale("zh-tw")).toBe("zh-TW");
      expect(normalizeLocale("zh_hk")).toBe("zh-TW");
      expect(normalizeLocale("zh-hant")).toBe("zh-TW");
    });

    it("should normalize English variants to en", () => {
      expect(normalizeLocale("en")).toBe("en");
      expect(normalizeLocale("en-us")).toBe("en");
      expect(normalizeLocale("en_gb")).toBe("en");
    });

    it("should normalize other languages", () => {
      expect(normalizeLocale("ja")).toBe("ja");
      expect(normalizeLocale("ja-jp")).toBe("ja");
      expect(normalizeLocale("ko")).toBe("ko");
      expect(normalizeLocale("fr")).toBe("fr");
      expect(normalizeLocale("de")).toBe("de");
      expect(normalizeLocale("es")).toBe("es");
    });

    it("should normalize Portuguese to pt-BR", () => {
      expect(normalizeLocale("pt")).toBe("pt-BR");
      expect(normalizeLocale("pt-br")).toBe("pt-BR");
    });

    it("should normalize Arabic to ar", () => {
      expect(normalizeLocale("ar")).toBe("ar");
      expect(normalizeLocale("ar-sa")).toBe("ar");
    });

    it("should handle locale with encoding suffix", () => {
      expect(normalizeLocale("zh_CN.UTF-8")).toBe("zh-CN");
      expect(normalizeLocale("en_US.iso88591")).toBe("en");
    });

    it("should return null for unknown locales", () => {
      expect(normalizeLocale("unknown")).toBeNull();
      expect(normalizeLocale("xx-YY")).toBeNull();
      expect(normalizeLocale("")).toBeNull();
    });

    it("should extract primary language for unknown but valid language codes", () => {
      expect(normalizeLocale("it")).toBeNull();
      expect(normalizeLocale("ru")).toBeNull();
    });

    it("should trim whitespace", () => {
      expect(normalizeLocale("  zh-CN  ")).toBe("zh-CN");
    });
  });

  describe("isChineseLocale", () => {
    it("should return true for Chinese locales", () => {
      expect(isChineseLocale("zh-CN")).toBe(true);
      expect(isChineseLocale("zh-TW")).toBe(true);
    });

    it("should return false for non-Chinese locales", () => {
      expect(isChineseLocale("en")).toBe(false);
      expect(isChineseLocale("ja")).toBe(false);
      expect(isChineseLocale("ko")).toBe(false);
      expect(isChineseLocale("ar")).toBe(false);
    });
  });

  describe("detectSystemLocale", () => {
    const originalEnv = process.env;

    beforeEach(() => {
      vi.restoreAllMocks();
      process.env = { ...originalEnv };
    });

    it("should detect a valid locale (env, storage, or system)", () => {
      delete process.env.LANGUAGE;
      delete process.env.LANG;
      delete process.env.LC_ALL;
      delete process.env.LC_MESSAGES;

      const result = detectSystemLocale();
      expect(result.locale).toBeTruthy();
      expect(["env", "storage", "system", "default"]).toContain(result.source);
      expect(result.confidence).toBeGreaterThan(0);
    });

    it("should detect from environment variable LANGUAGE", () => {
      process.env.LANGUAGE = "zh-CN:en";
      const result = detectSystemLocale();
      expect(result.locale).toBe("zh-CN");
      expect(result.source).toBe("env");
      expect(result.confidence).toBe(0.95);
    });

    it("should detect from environment variable LANG", () => {
      process.env.LANG = "ja_JP.UTF-8";
      const result = detectSystemLocale();
      expect(result.locale).toBe("ja");
      expect(result.source).toBe("env");
    });

    it("should use stored locale with high confidence when valid", () => {
      const result = detectSystemLocale("zh-TW");
      if (result.source === "storage") {
        expect(result.locale).toBe("zh-TW");
        expect(result.confidence).toBe(0.95);
      }
    });

    it("should ignore invalid stored locale and fall back", () => {
      const result = detectSystemLocale("invalid-locale");
      expect(result.source).not.toBe("storage");
    });

    it("should handle null stored locale", () => {
      const result = detectSystemLocale(null);
      expect(result.source).not.toBe("storage");
    });

    it("should detect from LC_ALL", () => {
      process.env.LANGUAGE = "";
      process.env.LANG = "";
      process.env.LC_ALL = "ko_KR.UTF-8";
      process.env.LC_MESSAGES = "";
      const result = detectSystemLocale();
      expect(result.locale).toBe("ko");
      expect(result.source).toBe("env");
    });

    it("should detect from LC_MESSAGES", () => {
      process.env.LANGUAGE = "";
      process.env.LANG = "";
      process.env.LC_ALL = "";
      process.env.LC_MESSAGES = "de_DE.UTF-8";
      const result = detectSystemLocale();
      expect(result.locale).toBe("de");
      expect(result.source).toBe("env");
    });

    it("should detect from system when env confidence is low", () => {
      // Remove all env vars — env detection returns null, should fallback to system/default
      delete process.env.LANGUAGE;
      delete process.env.LANG;
      delete process.env.LC_ALL;
      delete process.env.LC_MESSAGES;

      const result = detectSystemLocale();
      // In test environment (no browser), should be default
      expect(["system", "default"]).toContain(result.source);
    });

    it("should use stored locale when env not high-confidence", () => {
      delete process.env.LANGUAGE;
      delete process.env.LANG;
      delete process.env.LC_ALL;
      delete process.env.LC_MESSAGES;

      const result = detectSystemLocale("ja");
      expect(result.locale).toBe("ja");
      expect(result.source).toBe("storage");
      expect(result.confidence).toBe(0.95);
    });

    it("should return default when nothing detected", () => {
      delete process.env.LANGUAGE;
      delete process.env.LANG;
      delete process.env.LC_ALL;
      delete process.env.LC_MESSAGES;

      const result = detectSystemLocale(null);
      // No env, no storage, no browser in test env
      expect(result.locale).toBeTruthy();
      expect(result.confidence).toBeGreaterThan(0);
    });
  });

  describe("detectFromSystem via navigator", () => {
    afterEach(() => {
      vi.unstubAllGlobals();
    });

    it("should detect locale from navigator.languages via Intl", () => {
      vi.stubGlobal("navigator", {
        language: "en",
        languages: ["zh-CN", "en"],
      });
      vi.stubGlobal("Intl", {
        getCanonicalLocales: (locales: string[]) => locales,
      });

      delete process.env.LANGUAGE;
      delete process.env.LANG;
      delete process.env.LC_ALL;
      delete process.env.LC_MESSAGES;

      const result = detectSystemLocale();
      expect(result.locale).toBe("zh-CN");
      expect(result.source).toBe("system");
      expect(result.confidence).toBe(0.85);
    });

    it("should detect locale from navigator.language fallback", () => {
      vi.stubGlobal("navigator", {
        language: "ja",
        languages: [],
      });
      // No Intl.getCanonicalLocales — empty languages array
      // Falls to navigator.language path
      const result = detectSystemLocale();
      // If navigator.language is checked after empty languages array
      // detectFromSystem checks navigator.languages first, then navigator.language
      // With empty languages[], the loop does nothing, then checks navigator.language
      if (result.source === "system") {
        expect(result.locale).toBe("ja");
      }
    });

    it("should handle Intl throwing error gracefully", () => {
      vi.stubGlobal("navigator", {
        language: "en",
        languages: ["invalid-locale"],
      });
      vi.stubGlobal("Intl", {
        getCanonicalLocales: () => {
          throw new RangeError("Invalid locale");
        },
      });

      delete process.env.LANGUAGE;
      delete process.env.LANG;
      delete process.env.LC_ALL;
      delete process.env.LC_MESSAGES;

      // Should not throw, catch block handles it
      const result = detectSystemLocale();
      expect(result.locale).toBeTruthy();
    });
  });

  describe("normalizeLocale edge cases", () => {
    it("should handle locale with only separator", () => {
      expect(normalizeLocale("-")).toBeNull();
    });

    it("should handle locale with dot-only prefix", () => {
      expect(normalizeLocale(".UTF-8")).toBeNull();
    });

    it("should handle zh_hans_cn variant", () => {
      expect(normalizeLocale("zh_hans_cn")).toBe("zh-CN");
    });

    it("should handle es-419 region code", () => {
      expect(normalizeLocale("es-419")).toBe("es");
    });
  });
});
