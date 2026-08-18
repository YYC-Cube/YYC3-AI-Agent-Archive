# @yyc3/i18n-react

> React bindings for [@yyc3/i18n-core](https://github.com/YYC-Cube/YYC3-i18n-Core) — Zero-boilerplate i18n with AI translation + MCP protocol

## Install

```bash
npm install @yyc3/i18n-react @yyc3/i18n-core
```

## Quick Start

### 1. Wrap your app with I18nProvider

```tsx
import { I18nProvider } from '@yyc3/i18n-react';
import { I18nEngine } from '@yyc3/i18n-core';

const engine = new I18nEngine({ defaultLocale: 'en' });

function App() {
  return (
    <I18nProvider engine={engine}>
      <MyComponent />
    </I18nProvider>
  );
}
```

### 2. Use the hook

```tsx
import { useTranslation } from '@yyc3/i18n-react';

function MyComponent() {
  const { t, locale, setLocale } = useTranslation();

  return (
    <div>
      <h1>{t('welcome.message', { name: 'YYC³' })}</h1>
      <button onClick={() => setLocale('zh-CN')}>中文</button>
      <button onClick={() => setLocale('en')}>English</button>
    </div>
  );
}
```

### 3. Rich text with `<Trans>`

```tsx
import { Trans } from '@yyc3/i18n-react';

// ICU: "Read the <link>documentation</link> for v{version}"
function DocsLink() {
  return (
    <Trans
      id="docs.read"
      values={{ version: '2.0' }}
      components={{ link: <a href="/docs" /> }}
    />
  );
}
```

## Next.js App Router

### middleware.ts

```ts
import { createI18nMiddleware } from '@yyc3/i18n-react/next';

export const middleware = createI18nMiddleware({
  defaultLocale: 'en',
});

export const config = {
  matcher: ['/((?!api|_next|favicon).*)'],
};
```

### app/[locale]/layout.tsx (Server Component)

```tsx
import { createServerEngine } from '@yyc3/i18n-react/next';
import { I18nProvider } from '@yyc3/i18n-react';

export default async function Layout({ children, params }) {
  const engine = await createServerEngine(params.locale);
  return <I18nProvider engine={engine}>{children}</I18nProvider>;
}
```

## API

| Export | Description |
|--------|-------------|
| `I18nProvider` | Context Provider — wraps your app |
| `useTranslation()` | Hook — returns `{ t, locale, setLocale, ready, engine }` |
| `<Trans>` | Component — ICU translation with JSX interpolation |
| `createI18nMiddleware()` | Next.js middleware factory |
| `createServerEngine()` | Next.js Server Component engine factory |

## License

MIT © YYC³ Team
