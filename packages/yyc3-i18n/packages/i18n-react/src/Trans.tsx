/**
 * @file Trans.tsx
 * @description <Trans> component — declarative ICU translation with JSX interpolation
 */

import { Fragment, type ReactNode, isValidElement } from 'react';
import { useTranslation } from './useTranslation';

export interface TransProps {
  /** Translation key (ICU MessageFormat supported) */
  id: string;
  /** ICU parameter values */
  values?: Record<string, string | number>;
  /** JSX components to interpolate into the translation */
  components?: Record<string, ReactNode>;
  /** Fallback text if key is missing */
  fallback?: string;
}

/**
 * Declarative translation component with JSX interpolation.
 *
 * @example
 * // ICU: "Read the <link>documentation</link> for {version}"
 * <Trans
 *   id="docs.read"
 *   values={{ version: '2.0' }}
 *   components={{ link: <a href="/docs" /> }}
 * />
 */
export function Trans({ id, values, components, fallback }: TransProps) {
  const { t } = useTranslation();

  // Convert all values to strings for ICU
  const stringValues: Record<string, string> = {};
  if (values) {
    for (const [k, v] of Object.entries(values)) {
      stringValues[k] = String(v);
    }
  }

  const text = t(id, stringValues);

  // If no components, just render the translated string
  if (!components) {
    return <>{text || fallback || id}</>;
  }

  // Interpolate JSX components into the translated text
  // Pattern: <0>text</0> or <tagName>text</tagName>
  return <>{interpolateJSX(text, components)}</>;
}

/**
 * Interpolate JSX components into translated text.
 * Supports both numeric (<0>, <1>) and named (<link>, <bold>) tags.
 */
function interpolateJSX(
  text: string,
  components: Record<string, ReactNode>,
): ReactNode[] {
  const parts: ReactNode[] = [];
  // Match <name>content</name> or <name/>
  const regex = /<(\w+)>(.*?)<\/\1>|<(\w+)\/>/g;
  let lastIndex = 0;
  let match: RegExpExecArray | null;
  let key = 0;

  while ((match = regex.exec(text)) !== null) {
    // Add preceding text
    if (match.index > lastIndex) {
      parts.push(text.slice(lastIndex, match.index));
    }

    const tagName = match[1] || match[3];
    const content = match[2] || '';
    const comp = components[tagName];

    if (comp !== undefined && isValidElement(comp)) {
      // Clone element with children if it has content
      if (content) {
        parts.push(
          <Fragment key={`trans-${key++}`}>
            {cloneWithChildren(comp, content)}
          </Fragment>,
        );
      } else {
        parts.push(<Fragment key={`trans-${key++}`}>{comp}</Fragment>);
      }
    } else {
      // No matching component, render as-is
      parts.push(match[0]);
    }

    lastIndex = regex.lastIndex;
  }

  // Add remaining text
  if (lastIndex < text.length) {
    parts.push(text.slice(lastIndex));
  }

  return parts;
}

function cloneWithChildren(element: ReactNode, children: ReactNode): ReactNode {
  if (isValidElement(element)) {
    const props = { ...element.props, children };
    return { ...element, props };
  }
  return element;
}
