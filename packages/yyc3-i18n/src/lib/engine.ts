/**
 * file engine.ts
 * description i18n 核心引擎实现
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
 * brief i18n 核心引擎实现
 */
import { en } from "../locales/en.js";
import { LRUCache } from "./cache.js";
import { ICUCompiler } from "./icu/compiler.js";
import { ICUParser } from "./icu/parser.js";
import { logger } from "./infra/logger.js";
import { getSafeLocalStorage } from "./local-storage.js";
import { PluginManager } from "./plugins.js";
import {
  DEFAULT_LOCALE,
  SUPPORTED_LOCALES,
  isSupportedLocale,
  loadLazyLocaleTranslation,
  resolveNavigatorLocale,
} from "./registry.js";
import type { Locale, TranslationMap } from "./types.js";

type Subscriber = (locale: Locale) => void;

export interface I18nEngineConfig {
  locale?: Locale;
  fallbackLocale?: Locale;
  cache?: {
    enabled?: boolean;
    maxSize?: number;
    ttl?: number;
  };
  debug?: boolean;
  onError?: (error: Error, context: { key: string; locale: Locale }) => void;
  missingKeyHandler?: (key: string, locale: Locale) => string;
}

interface I18nEngineState {
  locale: Locale;
  translations: Partial<Record<Locale, TranslationMap>>;
}

export class I18nEngine {
  private state: I18nEngineState;
  private subscribers: Set<Subscriber> = new Set();

  // New v2.0 features
  public readonly cache: LRUCache<string>;
  public readonly plugins: PluginManager;

  /**
   * 初始 locale 就绪承诺：浏览器自动检测到非 en 时内含一次异步语言包懒加载。
   * 消费者在首次调用 t() 前 `await i18n.ready` 可消除"构造后立即翻译拿到 en"的竞态；
   * Node 环境不自动检测 navigator，通常构造即就绪。该承诺永不 reject（加载失败内部消化）。
   */
  public readonly ready: Promise<void>;

  private debugMode = false;
  private errorHandler?: I18nEngineConfig["onError"];
  private missingKeyHandler?: I18nEngineConfig["missingKeyHandler"];

  constructor(config: I18nEngineConfig = {}) {
    // Initialize state
    this.state = {
      locale: config.locale ?? DEFAULT_LOCALE,
      translations: { [DEFAULT_LOCALE]: en },
    };

    // Initialize cache
    this.cache = new LRUCache({
      enabled: config.cache?.enabled ?? true,
      maxSize: config.cache?.maxSize ?? 1000,
      defaultTTL: config.cache?.ttl ?? 5 * 60 * 1000, // 5 minutes
    });

    // Initialize plugin system
    this.plugins = new PluginManager();

    // Store handlers
    this.errorHandler = config.onError;
    this.missingKeyHandler = config.missingKeyHandler;
    this.debugMode = config.debug ?? false;

    // Load initial locale（浏览器可能触发异步懒加载，通过 ready 承诺对外暴露就绪状态）
    this.ready = this.loadInitialLocale();

    if (this.debugMode) {
      logger.info("🌐 I18n Engine v2.0 Initialized");
      logger.info(`   Locale: ${this.state.locale}`);
      logger.info(`   Cache: ${this.cache.config.enabled ? "✅ Enabled" : "❌ Disabled"}`);
      logger.info(`   Plugins: ${this.plugins.getRegisteredPlugins().length} registered`);
    }
  }

  private readStoredLocale(): string | null {
    const storage = getSafeLocalStorage();
    if (!storage) return null;

    try {
      return storage.getItem("yyc3.i18n.locale");
    } catch {
      return null;
    }
  }

  private persistLocale(locale: Locale): void {
    const storage = getSafeLocalStorage();
    if (!storage) return;

    try {
      storage.setItem("yyc3.i18n.locale", locale);
    } catch {
      // Ignore storage failures in private/blocked contexts
    }
  }

  private resolveInitialLocale(): Locale {
    const saved = this.readStoredLocale();
    if (saved && isSupportedLocale(saved)) {
      return saved;
    }

    // 自动检测仅在浏览器/DOM 环境采信 navigator：Node ≥21 内置的 undici navigator
    // 其 language 镜像宿主 LANG/LC_ALL（如中文机器返回 zh-CN），并非用户 UI 偏好，
    // 在 Node/SSR/CLI/测试进程中采信会让默认语言随机器区域设置漂移（确定性缺陷）。
    // Node 侧需要跟随系统语言时，请显式 setLocale() 或使用 detectSystemLocale()。
    const detected =
      typeof window !== "undefined" ? resolveNavigatorLocale() : null;

    return detected ?? DEFAULT_LOCALE;
  }

  private loadInitialLocale(): Promise<void> {
    const initialLocale = this.resolveInitialLocale();
    if (initialLocale === DEFAULT_LOCALE) {
      this.state.locale = DEFAULT_LOCALE;
      return Promise.resolve();
    }

    // setLocale 内部已消化语言包加载错误（不会 reject）；再兜一层，
    // 确保 ready 永不产生 unhandled rejection，消费者不 await 也安全。
    return this.setLocale(initialLocale).catch(() => { });
  }

  public getLocale(): Locale {
    return this.state.locale;
  }

  public async setLocale(locale: Locale): Promise<void> {
    const needsTranslationLoad =
      locale !== DEFAULT_LOCALE && !this.state.translations[locale];

    if (this.state.locale === locale && !needsTranslationLoad) {
      return;
    }

    const oldLocale = this.state.locale;

    if (needsTranslationLoad) {
      try {
        const translation = await loadLazyLocaleTranslation(locale as Exclude<Locale, "en">);
        if (!translation) {
          const error = new Error(`Failed to load translation for locale: ${locale}`);
          this.handleError(error, { key: "", locale });
          return;
        }
        // 懒加载等待期间可能已有 registerTranslation 增量注册（显式覆盖优先），
        // 直接赋值会抹掉它们——以语言包为基底做深合并，保住飞行中注册的键。
        const registeredWhileLoading = this.state.translations[locale];
        this.state.translations[locale] = registeredWhileLoading
          ? this.mergeTranslations(translation, registeredWhileLoading)
          : translation;
      } catch (e) {
        const error = e instanceof Error ? e : new Error(String(e));
        this.handleError(error, { key: "", locale });
        return;
      }
    }

    this.state.locale = locale;
    this.persistLocale(locale);

    // Invalidate cache on locale change
    this.cache.clear();

    // Notify plugins
    this.plugins.notifyLocaleChange(locale, oldLocale);

    // Notify subscribers
    this.notify();

    if (this.debugMode) {
      logger.debug(`🌍 Locale changed: ${oldLocale} → ${locale}`);
    }
  }

  /**
   * 增量注册翻译：与该 locale 已有语言包【深合并】，同名叶子键以传入值为准
   * （传入非对象值会整体覆盖同名对象节点）。
   *
   * 典型用途是增量补丁：注册单个 key（如 MCP `add_translation_key`）不再抹掉整包语言。
   * 如需"丢弃旧表、整包替换"的旧语义，请使用 {@link replaceTranslation}。
   */
  public registerTranslation(locale: Locale, map: TranslationMap): void {
    this.state.translations[locale] = this.mergeTranslations(
      this.state.translations[locale],
      map,
    );
    this.cache.clear();

    if (this.debugMode) {
      logger.debug(`📦 Translation merged for locale: ${locale}`);
    }
  }

  /**
   * 整表替换翻译：丢弃该 locale 已注册的全部键，以 `map` 作为新的语言包。
   * 这是 v3.0 之前 `registerTranslation` 的旧语义，作为逃生门保留。
   */
  public replaceTranslation(locale: Locale, map: TranslationMap): void {
    this.state.translations[locale] = map;
    this.cache.clear();

    if (this.debugMode) {
      logger.debug(`📦 Translation replaced for locale: ${locale}`);
    }
  }

  /**
   * 翻译表深合并：以 base 为基底、overrides 为显式覆盖；
   * 两侧同为普通对象时递归合并，否则 overrides 的值整体胜出
   * （字符串/数组/null 等叶子值覆盖对象节点，保证结构纠偏能力）。
   */
  private mergeTranslations(
    base: TranslationMap | undefined,
    overrides: TranslationMap,
  ): TranslationMap {
    return this.deepMergeTranslation(
      (base ?? {}) as Record<string, unknown>,
      overrides as Record<string, unknown>,
    ) as TranslationMap;
  }

  private isPlainRecord(value: unknown): value is Record<string, unknown> {
    return typeof value === "object" && value !== null && !Array.isArray(value);
  }

  private deepMergeTranslation(
    base: Record<string, unknown>,
    overrides: Record<string, unknown>,
  ): Record<string, unknown> {
    const output: Record<string, unknown> = { ...base };

    for (const key of Object.keys(overrides)) {
      const baseValue = output[key];
      const overrideValue = overrides[key];

      if (this.isPlainRecord(baseValue) && this.isPlainRecord(overrideValue)) {
        output[key] = this.deepMergeTranslation(baseValue, overrideValue);
      } else {
        output[key] = overrideValue;
      }
    }

    return output;
  }

  public subscribe(sub: Subscriber): () => void {
    this.subscribers.add(sub);
    return () => this.subscribers.delete(sub);
  }

  public getTranslations(locale: Locale): TranslationMap | undefined {
    return this.state.translations[locale];
  }

  private notify(): void {
    for (const sub of Array.from(this.subscribers)) {
      sub(this.state.locale);
    }
  }

  /**
   * Main translation method with caching and plugin support
   */
  public t(key: string, params?: Record<string, string>): string {
    try {
      // Check cache first (cache stores un-interpolated template)
      const cached = this.cache.get(`${this.state.locale}:${key}`);
      if (cached !== null) {
        return params ? this.interpolate(cached, params) : cached;
      }

      // Execute beforeTranslate plugins
      const { key: modifiedKey, params: modifiedParams } =
        this.plugins.executeBeforeTranslate(key, params);

      // Resolve translation value
      let value = this.resolveTranslation(modifiedKey);

      // Handle missing keys
      if (value === undefined || value === modifiedKey) {
        const fallback = this.plugins.handleMissingKey(modifiedKey, this.state.locale)
          ?? this.missingKeyHandler?.(modifiedKey, this.state.locale)
          ?? modifiedKey;

        if (this.debugMode && fallback === modifiedKey) {
          logger.warn(`Missing translation key: "${modifiedKey}"`);
        }

        value = fallback;
      }

      // Cache the raw template before interpolation
      this.cache.set(`${this.state.locale}:${key}`, value);

      // Execute afterTranslate plugins on raw value
      const afterPluginValue = this.plugins.executeAfterTranslate(value, modifiedKey, params);

      // Interpolate parameters
      if (params || modifiedParams) {
        const mergedParams = { ...params, ...modifiedParams };
        if (this.isICUMessage(afterPluginValue)) {
          return this.compileICU(afterPluginValue, mergedParams);
        }
        return this.interpolate(afterPluginValue, mergedParams);
      }

      return afterPluginValue;
    } catch (error) {
      const err = error instanceof Error ? error : new Error(String(error));
      this.handleError(err, { key, locale: this.state.locale });
      return key;
    }
  }

  private isICUMessage(value: string): boolean {
    return value.includes("{") && (value.includes(", plural") || value.includes(", select") || value.includes(", selectOrdinal"));
  }

  private compileICU(template: string, params: Record<string, string>): string {
    try {
      const parser = new ICUParser();
      const { nodes, errors } = parser.parse(template);
      if (errors.length > 0) {
        logger.warn(`ICU parse errors: ${JSON.stringify(errors)}`);
        return this.interpolate(template, params);
      }
      const compiler = new ICUCompiler();
      return compiler.compile(nodes, { locale: this.state.locale, params });
    } catch {
      return this.interpolate(template, params);
    }
  }

  /**
   * Batch translate multiple keys at once
   */
  public batchTranslate(
    keys: string[],
    params?: Record<string, Record<string, string>>
  ): Record<string, string> {
    const results: Record<string, string> = {};

    for (const key of keys) {
      results[key] = this.t(key, params?.[key]);
    }

    return results;
  }

  /**
   * Create a namespaced translator
   */
  public createNamespace(prefix: string): {
    t: (key: string, params?: Record<string, string>) => string;
    batchTranslate: (keys: string[]) => Record<string, string>;
    getLocale: () => Locale;
  } {
    return {
      t: (key, params) => this.t(`${prefix}.${key}`, params),
      batchTranslate: (keys) =>
        Object.fromEntries(keys.map((k) => [k, this.t(`${prefix}.${k}`)])),
      getLocale: () => this.getLocale(),
    };
  }

  private resolveTranslation(key: string): string | undefined {
    const keys = key.split(".");
    let value: unknown =
      this.state.translations[this.state.locale] ??
      this.state.translations[DEFAULT_LOCALE];

    for (const k of keys) {
      if (value && typeof value === "object") {
        value = (value as Record<string, unknown>)[k];
      } else {
        value = undefined;
        break;
      }
    }

    // Fallback to English if not found in current locale
    if (
      value === undefined &&
      this.state.locale !== DEFAULT_LOCALE
    ) {
      value = this.state.translations[DEFAULT_LOCALE];
      for (const k of keys) {
        if (value && typeof value === "object") {
          value = (value as Record<string, unknown>)[k];
        } else {
          value = undefined;
          break;
        }
      }
    }

    return typeof value === "string" ? value : undefined;
  }

  private interpolate(
    template: string,
    params: Record<string, string>
  ): string {
    return template.replace(/\{(\w+)\}/g, (_, k) => params[k] ?? `{${k}}`);
  }

  private handleError(
    error: Error,
    context: { key: string; locale: Locale }
  ): void {
    // Call custom error handler if provided
    this.errorHandler?.(error, context);

    // Notify plugins
    this.plugins.handleError(error, context);

    // Log in debug mode
    if (this.debugMode) {
      logger.error("Error:", error.message, context);
    }
  }

  /**
   * Enable/disable debug mode
   */
  public setDebug(enabled: boolean): void {
    this.debugMode = enabled;

    if (enabled) {
      logger.info("🔧 i18n Debug Mode ENABLED");

      // Attach debug utilities to window
      (globalThis as Record<string, unknown>).__i18n_debug__ = {
        engine: this,
        getStats: () => this.getStats(),
        clearCache: () => this.cache.clear(),
        getPlugins: () => this.plugins.getRegisteredPlugins(),
        testTranslation: (key: string) => this.t(key),
      };
    } else {
      delete (globalThis as Record<string, unknown>).__i18n_debug__;
    }
  }

  /**
   * Get comprehensive statistics
   */
  public getStats(): {
    locale: Locale;
    cache: ReturnType<LRUCache<string>["getStats"]>;
    plugins: string[];
    subscriberCount: number;
    loadedLocales: string[];
  } {
    return {
      locale: this.state.locale,
      cache: this.cache.getStats(),
      plugins: this.plugins.getRegisteredPlugins(),
      subscriberCount: this.subscribers.size,
      loadedLocales: Object.keys(this.state.translations),
    };
  }

  /**
   * Destroy the engine instance (cleanup)
   */
  public async destroy(): Promise<void> {
    await this.plugins.destroyAll();
    this.cache.clear();
    this.subscribers.clear();

    if (this.debugMode) {
      logger.debug("🗑️ I18n Engine destroyed");
    }
  }
}

// Singleton instance for backward compatibility
export const i18n = new I18nEngine();

// Convenience export
export const t = (key: string, params?: Record<string, string>) =>
  i18n.t(key, params);

export { SUPPORTED_LOCALES, isSupportedLocale };
