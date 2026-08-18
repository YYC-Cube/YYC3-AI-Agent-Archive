/**
 * @file next.ts
 * @description Next.js App Router integration — middleware + server helpers
 */

import type { Locale } from '@yyc3/i18n-core';

export const DEFAULT_LOCALES: Locale[] = [
  'en',
  'zh-CN',
  'zh-TW',
  'ja',
  'ko',
  'fr',
  'de',
  'es',
  'pt-BR',
  'ar',
];

export interface I18nMiddlewareConfig {
  locales?: Locale[];
  defaultLocale?: Locale;
  /** Path prefix strategy: '/en/about' or '/about' with cookie */
  strategy?: 'prefix' | 'cookie';
}

/**
 * Create Next.js middleware for automatic locale detection and routing.
 *
 * @example
 * // middleware.ts
 * import { createI18nMiddleware } from '@yyc3/i18n-react/next';
 * export const middleware = createI18nMiddleware({ defaultLocale: 'en' });
 */
export function createI18nMiddleware(config: I18nMiddlewareConfig = {}) {
  const locales = config.locales ?? DEFAULT_LOCALES;
  const defaultLocale = config.defaultLocale ?? 'en';

  return function i18nMiddleware(request: {
    nextUrl: { pathname: string };
    cookies: { get: (name: string) => { value: string } | undefined };
    headers: { get: (name: string) => string | null };
  }): { locale: Locale; shouldRedirect: boolean; redirectUrl?: string } {
    // 1. Check URL prefix
    const pathname = request.nextUrl.pathname;
    const segments = pathname.split('/').filter(Boolean);
    const firstSegment = segments[0];

    if (firstSegment && locales.includes(firstSegment as Locale)) {
      return { locale: firstSegment as Locale, shouldRedirect: false };
    }

    // 2. Check cookie
    const cookieLocale = request.cookies.get('yyc3-locale')?.value;
    if (cookieLocale && locales.includes(cookieLocale as Locale)) {
      return { locale: cookieLocale as Locale, shouldRedirect: false };
    }

    // 3. Check Accept-Language header
    const acceptLang = request.headers.get('accept-language');
    if (acceptLang) {
      const detected = detectLocaleFromHeader(acceptLang, locales);
      if (detected) {
        return { locale: detected, shouldRedirect: false };
      }
    }

    // 4. Fallback to default
    return { locale: defaultLocale, shouldRedirect: false };
  };
}

function detectLocaleFromHeader(
  header: string,
  supported: Locale[],
): Locale | null {
  const parsed = header
    .split(',')
    .map((part) => {
      const [lang, q = 'q=1'] = part.trim().split(';');
      const quality = parseFloat(q.split('=')[1] ?? '1');
      return { lang: lang.trim(), quality };
    })
    .sort((a, b) => b.quality - a.quality);

  for (const { lang } of parsed) {
    // Exact match (e.g., "zh-CN")
    if (supported.includes(lang as Locale)) {
      return lang as Locale;
    }
    // Base language match (e.g., "zh" → "zh-CN")
    const base = lang.split('-')[0];
    const match = supported.find((l) => l.startsWith(base));
    if (match) return match;
  }

  return null;
}

/**
 * Create a server-side I18nEngine for Next.js Server Components.
 *
 * @example
 * // app/[locale]/layout.tsx
 * import { createServerEngine } from '@yyc3/i18n-react/next';
 * const engine = await createServerEngine(params.locale);
 */
export async function createServerEngine(locale: Locale) {
  const { I18nEngine } = await import('@yyc3/i18n-core');
  const engine = new I18nEngine({ locale, fallbackLocale: 'en' });
  await engine.setLocale(locale);
  return engine;
}
