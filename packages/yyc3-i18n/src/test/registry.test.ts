/**
 * file registry.test.ts
 * description @yyc3/i18n-core registry.ts 单元测试 — 补充分支覆盖
 * module @yyc3/i18n-core
 * author YanYuCloudCube Team <admin@0379.email>
 * version 2.3.0
 * created 2026-06-14
 * updated 2026-06-14
 * status active
 * tags [test],[unit]
 *
 * copyright YanYuCloudCube Team
 * license MIT
 *
 * brief @yyc3/i18n-core registry.ts 单元测试
 */
import { afterEach, describe, expect, it, vi } from "vitest";
import {
  DEFAULT_LOCALE,
  SUPPORTED_LOCALES,
  isSupportedLocale,
  loadLazyLocaleTranslation,
  resolveNavigatorLocale,
} from "../lib/registry.js";
import type { Locale } from "../lib/types.js";

describe("registry", () => {
  describe("DEFAULT_LOCALE", () => {
    it("should be 'en'", () => {
      expect(DEFAULT_LOCALE).toBe("en");
    });
  });

  describe("SUPPORTED_LOCALES", () => {
    it("should include 10 locales", () => {
      expect(SUPPORTED_LOCALES).toHaveLength(10);
    });

    it("should include 'en' as first entry", () => {
      expect(SUPPORTED_LOCALES[0]).toBe("en");
    });

    it("should include all lazy locales", () => {
      expect(SUPPORTED_LOCALES).toContain("zh-CN");
      expect(SUPPORTED_LOCALES).toContain("ja");
      expect(SUPPORTED_LOCALES).toContain("ar");
    });
  });

  describe("isSupportedLocale", () => {
    it("should return true for 'en'", () => {
      expect(isSupportedLocale("en")).toBe(true);
    });

    it("should return true for 'zh-CN'", () => {
      expect(isSupportedLocale("zh-CN")).toBe(true);
    });

    it("should return false for unsupported locale", () => {
      expect(isSupportedLocale("en-US")).toBe(false);
    });

    it("should return false for completely unknown locale", () => {
      expect(isSupportedLocale("xx-XX")).toBe(false);
    });

    it("should return false for empty string", () => {
      expect(isSupportedLocale("")).toBe(false);
    });
  });

  describe("loadLazyLocaleTranslation", () => {
    it("should load zh-CN translation", async () => {
      const t = await loadLazyLocaleTranslation("zh-CN");
      expect(t).toBeDefined();
      expect(typeof t).toBe("object");
    });

    it("should load zh-TW translation", async () => {
      const t = await loadLazyLocaleTranslation("zh-TW");
      expect(t).toBeDefined();
    });

    it("should load pt-BR translation", async () => {
      const t = await loadLazyLocaleTranslation("pt-BR");
      expect(t).toBeDefined();
      expect(t).toHaveProperty("common");
    });

    it("should throw for unsupported locale", async () => {
      // loadLazyLocaleTranslation uses LazyLocale type which restricts to known locales
      // Cast to force an unsupported locale through
      await expect(
        loadLazyLocaleTranslation("unsupported" as unknown as Exclude<Locale, "en">)
      ).rejects.toThrow("Unsupported locale: unsupported");
    });

    it("should throw for random string", async () => {
      await expect(
        loadLazyLocaleTranslation("foobar" as unknown as Exclude<Locale, "en">)
      ).rejects.toThrow();
    });

    it("should throw for empty string", async () => {
      await expect(
        loadLazyLocaleTranslation("" as unknown as Exclude<Locale, "en">)
      ).rejects.toThrow("Unsupported locale: ");
    });
  });

  describe("resolveNavigatorLocale", () => {
    afterEach(() => {
      vi.unstubAllGlobals();
    });

    it("should return null when navigator is undefined", () => {
      vi.stubGlobal("navigator", undefined);
      const result = resolveNavigatorLocale();
      expect(result).toBeNull();
    });

    it("should detect locale from navigator.language", () => {
      vi.stubGlobal("navigator", { language: "en", languages: undefined });
      const result = resolveNavigatorLocale();
      expect(result).toBe("en");
    });

    it("should detect zh-CN from navigator.language with region", () => {
      vi.stubGlobal("navigator", { language: "zh-CN", languages: ["zh-CN"] });
      const result = resolveNavigatorLocale();
      expect(result).toBe("zh-CN");
    });

    it("should fallback to base language when full locale not supported", () => {
      // "zh-Hans-CN" is not directly in SUPPORTED_LOCALES, and baseLang "zh" is not either
      // so this should return null
      vi.stubGlobal("navigator", { language: "zh-Hans-CN", languages: ["zh-Hans-CN"] });
      const result = resolveNavigatorLocale();
      expect(result).toBeNull();
    });

    it("should return null when no locale matches", () => {
      vi.stubGlobal("navigator", { language: "xx-YY", languages: ["xx-YY"] });
      const result = resolveNavigatorLocale();
      expect(result).toBeNull();
    });

    it("should try navigator.languages first, then navigator.language", () => {
      vi.stubGlobal("navigator", {
        language: "en",
        languages: ["de", "en"],
      });
      // "de" is not supported (de IS in the list) wait...
      // SUPPORTED_LOCALES includes "de". So if "de" is in languages, it would be returned first.
      const result = resolveNavigatorLocale();
      expect(result).toBe("de");
    });

    it("should fallback to navigator.language when languages is undefined", () => {
      vi.stubGlobal("navigator", { language: "ja", languages: undefined });
      const result = resolveNavigatorLocale();
      expect(result).toBe("ja");
    });

    it("should handle locale with region code splitting correctly", () => {
      // "pt-BR" should match directly via isSupportedLocale
      vi.stubGlobal("navigator", { language: "pt-BR", languages: ["pt-BR"] });
      const result = resolveNavigatorLocale();
      expect(result).toBe("pt-BR");
    });

    it("should return null for non-browser environment after checking navigator", () => {
      // navigator exists but has no matching locale
      vi.stubGlobal("navigator", { language: "ru-RU", languages: ["ru-RU"] });
      const result = resolveNavigatorLocale();
      expect(result).toBeNull();
    });
  });
});
