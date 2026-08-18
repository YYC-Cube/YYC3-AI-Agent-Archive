/**
 * file plugins.test.ts
 * description @yyc3/i18n-core plugins.ts 单元测试
 * module @yyc3/i18n-core
 * author YanYuCloudCube Team <admin@0379.email>
 * version 2.3.0
 * created 2026-04-24
 * updated 2026-04-24
 * status active
 * tags [test],[plugin],[unit]
 *
 * copyright YanYuCloudCube Team
 * license MIT
 *
 * brief @yyc3/i18n-core plugins.ts 单元测试
 */
import { beforeEach, describe, expect, it, vi } from "vitest";
import type { I18nContext, I18nPlugin } from "../lib/plugins.js";
import { PluginManager } from "../lib/plugins.js";
import { createConsoleLogger, type ConsoleLoggerConfig } from "../lib/plugins/console-logger.js";
import { MissingKeyReporter } from "../lib/plugins/missing-key-reporter.js";
import type { Locale } from "../lib/types.js";

describe("Console Logger Plugin", () => {
  beforeEach(() => {
    vi.restoreAllMocks();
  });

  it("should create plugin with default config", () => {
    const plugin = createConsoleLogger();
    expect(plugin.name).toBe("console-logger");
    expect(plugin.version).toBe("1.0.0");
  });

  it("should create plugin with custom config", () => {
    const config: ConsoleLoggerConfig = {
      logTranslations: true,
      logMissingKeys: false,
      logLocaleChanges: false,
      logPerformance: false,
    };
    const plugin = createConsoleLogger(config);
    expect(plugin.name).toBe("console-logger");
  });

  it("should have beforeTranslate method", () => {
    const plugin = createConsoleLogger();
    expect(typeof plugin.beforeTranslate).toBe("function");
  });

  it("should have afterTranslate method", () => {
    const plugin = createConsoleLogger();
    expect(typeof plugin.afterTranslate).toBe("function");
  });

  it("should have onLocaleChange method", () => {
    const plugin = createConsoleLogger();
    expect(typeof plugin.onLocaleChange).toBe("function");
  });

  it("should have onMissingKey method", () => {
    const plugin = createConsoleLogger();
    expect(typeof plugin.onMissingKey).toBe("function");
  });

  it("should have onError method", () => {
    const plugin = createConsoleLogger();
    expect(typeof plugin.onError).toBe("function");
  });

  describe("beforeTranslate", () => {
    it("should log translation when enabled", () => {
      const spy = vi.spyOn(console, "log").mockImplementation(() => { });
      const plugin = createConsoleLogger({ logTranslations: true });
      plugin.beforeTranslate!('test.key');
      expect(spy).toHaveBeenCalledWith(
        expect.stringContaining('Translating: "test.key"'),
        expect.any(String)
      );
      spy.mockRestore();
    });

    it("should not log when disabled", () => {
      const spy = vi.spyOn(console, "log").mockImplementation(() => { });
      const plugin = createConsoleLogger({ logTranslations: false });
      plugin.beforeTranslate!('test.key');
      expect(spy).not.toHaveBeenCalledWith(
        expect.stringContaining("Translating")
      );
      spy.mockRestore();
    });
  });

  describe("afterTranslate", () => {
    it("should not log fast translations", () => {
      const spy = vi.spyOn(console, "log").mockImplementation(() => { });
      const plugin = createConsoleLogger({ logPerformance: true });
      plugin.beforeTranslate!("fast.key");
      plugin.afterTranslate!("result", "fast.key");
      expect(spy).not.toHaveBeenCalledWith(
        expect.stringContaining("Slow")
      );
      spy.mockRestore();
    });
  });

  describe("onLocaleChange", () => {
    it("should log locale change when enabled", () => {
      const spy = vi.spyOn(console, "log").mockImplementation(() => { });
      const plugin = createConsoleLogger({ logLocaleChanges: true });
      plugin.onLocaleChange!("zh-CN" as Locale, "en" as Locale);
      expect(spy).toHaveBeenCalledWith(
        expect.stringContaining("Locale changed"),
        expect.any(String)
      );
      spy.mockRestore();
    });

    it("should not log when disabled", () => {
      const spy = vi.spyOn(console, "log").mockImplementation(() => { });
      const plugin = createConsoleLogger({ logLocaleChanges: false });
      plugin.onLocaleChange!("zh-CN" as Locale, "en" as Locale);
      expect(spy).not.toHaveBeenCalledWith(
        expect.stringContaining("Locale changed")
      );
      spy.mockRestore();
    });
  });

  describe("onMissingKey", () => {
    it("should warn about missing keys when enabled", () => {
      const spy = vi.spyOn(console, "warn").mockImplementation(() => { });
      const plugin = createConsoleLogger({ logMissingKeys: true });
      const result = plugin.onMissingKey!("missing.key", "en" as Locale);
      expect(spy).toHaveBeenCalledWith(
        expect.stringContaining("Missing translation"),
        expect.any(String)
      );
      expect(result).toBeUndefined();
      spy.mockRestore();
    });

    it("should not warn when disabled", () => {
      const spy = vi.spyOn(console, "warn").mockImplementation(() => { });
      const plugin = createConsoleLogger({ logMissingKeys: false });
      plugin.onMissingKey!("missing.key", "en" as Locale);
      expect(spy).not.toHaveBeenCalled();
      spy.mockRestore();
    });
  });

  describe("onError", () => {
    it("should log errors with context", () => {
      const spy = vi.spyOn(console, "error").mockImplementation(() => { });
      const plugin = createConsoleLogger();
      plugin.onError!(new Error("test error"), { key: "test", locale: "en" as Locale });
      expect(spy).toHaveBeenCalledWith(
        expect.stringContaining("Translation error"),
        expect.any(String),
        expect.any(Object)
      );
      spy.mockRestore();
    });
  });
});

describe("Missing Key Reporter Plugin", () => {
  let reporter: MissingKeyReporter;

  beforeEach(() => {
    reporter = new MissingKeyReporter({
      maxEntries: 100,
      autoExport: false,
    });
  });

  it("should create instance with defaults", () => {
    const r = new MissingKeyReporter();
    expect(r).toBeInstanceOf(MissingKeyReporter);
  });

  it("should create plugin via createPlugin", () => {
    const plugin = reporter.createPlugin();
    expect(plugin.name).toBe("missing-key-reporter");
    expect(plugin.version).toBe("1.0.0");
  });

  it("should track missing keys", () => {
    const plugin = reporter.createPlugin();

    plugin.onMissingKey!("key1", "en" as Locale);
    plugin.onMissingKey!("key2", "zh-CN" as Locale);

    const report = reporter.getMissingKeys();
    expect(report.length).toBe(2);
  });

  it("should increment count for duplicate keys", () => {
    const plugin = reporter.createPlugin();

    plugin.onMissingKey!("duplicate.key", "en" as Locale);
    plugin.onMissingKey!("duplicate.key", "en" as Locale);
    plugin.onMissingKey!("duplicate.key", "en" as Locale);

    const report = reporter.getMissingKeys();
    const entry = report.find((e) => e.key === "duplicate.key");
    expect(entry?.count).toBe(3);
  });

  it("should enforce max entries limit", () => {
    const limitedReporter = new MissingKeyReporter({ maxEntries: 3 });
    const plugin = limitedReporter.createPlugin();

    for (let i = 0; i < 5; i++) {
      plugin.onMissingKey!(`key-${i}`, "en" as Locale);
    }

    const report = limitedReporter.getMissingKeys();
    expect(report.length).toBeLessThanOrEqual(3);
  });

  it("should clear entries", () => {
    const plugin = reporter.createPlugin();
    plugin.onMissingKey!("temp.key", "en" as Locale);

    reporter.clear();
    expect(reporter.getMissingKeys().length).toBe(0);
  });

  it("should export report as string", () => {
    const plugin = reporter.createPlugin();
    plugin.onMissingKey!("export.key", "en" as Locale);

    const exported = reporter.generateReport();
    expect(exported).toContain("MISSING TRANSLATION KEYS REPORT");
    expect(exported).toContain("export.key");
  });

  it("should provide utility methods", () => {
    const plugin = reporter.createPlugin();
    plugin.onMissingKey!("key1", "en" as Locale);
    plugin.onMissingKey!("key2", "en" as Locale);
    plugin.onMissingKey!("key3", "zh-CN" as Locale);

    expect(reporter.getUniqueMissingCount()).toBe(3);
    expect(reporter.getTotalMisses()).toBe(3);

    const enKeys = reporter.getByLocale("en" as Locale);
    expect(enKeys.length).toBe(2);
  });

  it("should export JSON format", () => {
    const plugin = reporter.createPlugin();
    plugin.onMissingKey!("json.key", "en" as Locale);

    const json = reporter.exportJSON();
    expect(() => JSON.parse(json)).not.toThrow();
    expect(json).toContain("json.key");
  });

  it("should handle destroy correctly", () => {
    const plugin = reporter.createPlugin();
    plugin.onMissingKey!("destroy.key", "en" as Locale);

    expect(reporter.getUniqueMissingCount()).toBe(1);

    reporter.destroy();
    expect(reporter.getUniqueMissingCount()).toBe(0);
  });

  it("should handle empty generateReport gracefully", () => {
    const emptyReporter = new MissingKeyReporter();
    const report = emptyReporter.generateReport();
    expect(report).toContain("No missing keys detected!");
  });

  it("should sort entries by count in getMissingKeys", () => {
    const plugin = reporter.createPlugin();
    plugin.onMissingKey!("rare.key", "en" as Locale);
    plugin.onMissingKey!("common.key", "en" as Locale);
    plugin.onMissingKey!("common.key", "en" as Locale);
    plugin.onMissingKey!("common.key", "en" as Locale);

    const sorted = reporter.getMissingKeys();
    expect(sorted[0].key).toBe("common.key");
    expect(sorted[0].count).toBe(3);
  });
});

// ============================================
// PluginManager Direct Tests
// ============================================
describe("PluginManager", () => {
  let manager: PluginManager;

  beforeEach(() => {
    manager = new PluginManager();
  });

  it("should register and get plugin", () => {
    const plugin: I18nPlugin = { name: "test-plugin" };
    manager.register(plugin);
    expect(manager.getPlugin("test-plugin")).toBe(plugin);
  });

  it("should return undefined for unregistered plugin", () => {
    expect(manager.getPlugin("nonexistent")).toBeUndefined();
  });

  it("should list registered plugins", () => {
    manager.register({ name: "p1" });
    manager.register({ name: "p2" });
    const list = manager.getRegisteredPlugins();
    expect(list).toContain("p1");
    expect(list).toContain("p2");
    expect(list).toHaveLength(2);
  });

  it("should unregister plugin", () => {
    const plugin: I18nPlugin = { name: "removable" };
    manager.register(plugin);
    expect(manager.getPlugin("removable")).toBeDefined();

    manager.unregister("removable");
    expect(manager.getPlugin("removable")).toBeUndefined();
  });

  it("should do nothing when unregistering unknown plugin", () => {
    manager.unregister("nonexistent");
    expect(manager.getRegisteredPlugins()).toHaveLength(0);
  });

  it("should call init on all plugins with init method", async () => {
    const initFn = vi.fn();
    const plugin: I18nPlugin = {
      name: "init-plugin",
      init: initFn,
    };
    manager.register(plugin);

    const ctx: I18nContext = { locale: "en" as Locale, key: "" };
    await manager.initAll(ctx);
    expect(initFn).toHaveBeenCalledWith(ctx);
  });

  it("should skip init for plugins without init method", async () => {
    const plugin: I18nPlugin = { name: "no-init" };
    manager.register(plugin);
    // Should not throw
    await manager.initAll({ locale: "en" as Locale, key: "" });
  });

  it("should call destroy on all plugins and clear", async () => {
    const destroyFn = vi.fn();
    const plugin: I18nPlugin = {
      name: "destroyable",
      destroy: destroyFn,
    };
    manager.register(plugin);

    await manager.destroyAll();
    expect(destroyFn).toHaveBeenCalled();
    expect(manager.getRegisteredPlugins()).toHaveLength(0);
  });

  it("should skip destroy for plugins without destroy method", async () => {
    manager.register({ name: "no-destroy" });
    await manager.destroyAll();
    expect(manager.getRegisteredPlugins()).toHaveLength(0);
  });

  it("should execute beforeTranslate hooks in order", () => {
    const order: string[] = [];
    manager.register({
      name: "first",
      beforeTranslate: () => {
        order.push("first");
        return undefined;
      },
    });
    manager.register({
      name: "second",
      beforeTranslate: () => {
        order.push("second");
        return undefined;
      },
    });

    manager.executeBeforeTranslate("key");
    expect(order).toEqual(["first", "second"]);
  });

  it("should modify key/params in beforeTranslate", () => {
    manager.register({
      name: "modifier",
      beforeTranslate: (key) => {
        return { key: `modified.${key}`, params: { x: "1" } };
      },
    });

    const result = manager.executeBeforeTranslate("original");
    expect(result.key).toBe("modified.original");
    expect(result.params).toEqual({ x: "1" });
  });

  it("should execute afterTranslate hooks", () => {
    manager.register({
      name: "after",
      afterTranslate: (value) => value.toUpperCase(),
    });

    const result = manager.executeAfterTranslate("hello", "key");
    expect(result).toBe("HELLO");
  });

  it("should handle afterTranslate returning undefined", () => {
    manager.register({
      name: "passthrough",
      afterTranslate: () => undefined,
    });

    const result = manager.executeAfterTranslate("original", "key");
    expect(result).toBe("original");
  });

  it("should call onLocaleChange hooks", () => {
    const changeFn = vi.fn();
    manager.register({
      name: "locale-watcher",
      onLocaleChange: changeFn,
    });

    manager.notifyLocaleChange("zh-CN" as Locale, "en" as Locale);
    expect(changeFn).toHaveBeenCalledWith("zh-CN", "en");
  });

  it("should call handleError on all plugins", () => {
    const errorFn = vi.fn();
    manager.register({
      name: "error-handler",
      onError: errorFn,
    });

    const error = new Error("test");
    manager.handleError(error, { key: "test", locale: "en" as Locale });
    expect(errorFn).toHaveBeenCalledWith(error, { key: "test", locale: "en" });
  });

  it("should call onMissingKey and return first non-undefined fallback", () => {
    manager.register({
      name: "fallback-provider",
      onMissingKey: (key) => `[${key}]`,
    });

    const result = manager.handleMissingKey("test.key", "en" as Locale);
    expect(result).toBe("[test.key]");
  });

  it("should return undefined when no plugin provides missing key fallback", () => {
    manager.register({ name: "no-fallback" });
    const result = manager.handleMissingKey("test.key", "en" as Locale);
    expect(result).toBeUndefined();
  });

  it("should warn when registering duplicate plugin name", () => {
    const warnSpy = vi.spyOn(console, "warn").mockImplementation(() => { });
    manager.register({ name: "dup" });
    manager.register({ name: "dup" }); // Should warn about overwrite
    // Verify both registered (overwritten)
    expect(manager.getPlugin("dup")).toBeDefined();
    warnSpy.mockRestore();
  });

  it("should call destroy when unregistering a plugin with destroy method", () => {
    const destroyFn = vi.fn();
    manager.register({
      name: "destroyable",
      destroy: destroyFn,
    });

    manager.unregister("destroyable");
    expect(destroyFn).toHaveBeenCalled();
  });

  it("should not add duplicate name to hookOrder on re-register", () => {
    manager.register({ name: "same" });
    manager.register({ name: "same" });
    const list = manager.getRegisteredPlugins();
    // hookOrder should not have duplicates
    expect(list.filter((n) => n === "same")).toHaveLength(1);
  });
});
