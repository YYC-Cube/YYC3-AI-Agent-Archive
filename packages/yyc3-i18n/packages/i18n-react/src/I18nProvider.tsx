/**
 * @file I18nProvider.tsx
 * @description React Context Provider for @yyc3/i18n-core
 */

import { I18nEngine, type Locale } from '@yyc3/i18n-core';
import {
  createContext,
  useContext,
  useEffect,
  useMemo,
  useState,
  type ReactNode,
} from 'react';

export interface I18nContextValue {
  engine: I18nEngine;
  locale: Locale;
  setLocale: (locale: Locale) => Promise<void>;
  t: (key: string, params?: Record<string, string>) => string;
  ready: boolean;
}

const I18nContext = createContext<I18nContextValue | null>(null);

export interface I18nProviderProps {
  engine: I18nEngine;
  children: ReactNode;
}

export function I18nProvider({ engine, children }: I18nProviderProps) {
  const [locale, setLocaleState] = useState<Locale>(engine.getLocale());
  const [ready, setReady] = useState(false);

  useEffect(() => {
    let mounted = true;
    // Engine is ready after construction, sync initial locale
    setReady(true);
    setLocaleState(engine.getLocale());

    // Subscribe to locale changes from the engine
    const unsubscribe = engine.subscribe((newLocale) => {
      if (mounted) setLocaleState(newLocale);
    });

    return () => {
      mounted = false;
      unsubscribe();
    };
  }, [engine]);

  const value = useMemo<I18nContextValue>(
    () => ({
      engine,
      locale,
      ready,
      setLocale: async (newLocale: Locale) => {
        await engine.setLocale(newLocale);
        setLocaleState(newLocale);
      },
      t: (key: string, params?: Record<string, string>) =>
        engine.t(key, params),
    }),
    [engine, locale, ready],
  );

  return <I18nContext.Provider value={value}>{children}</I18nContext.Provider>;
}

export function useI18nContext(): I18nContextValue {
  const ctx = useContext(I18nContext);
  if (!ctx) {
    throw new Error(
      'useTranslation must be used within an <I18nProvider>. ' +
      'Wrap your component tree with <I18nProvider engine={engine}>.',
    );
  }
  return ctx;
}
