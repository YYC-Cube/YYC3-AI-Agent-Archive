/**
 * file parser-compiler.test.ts
 * description @yyc3/i18n-core parser-compiler.ts 单元测试
 * module @yyc3/i18n-core
 * author YanYuCloudCube Team <admin@0379.email>
 * version 2.3.0
 * created 2026-04-24
 * updated 2026-04-24
 * status active
 * tags [test],[i18n],[unit]
 *
 * copyright YanYuCloudCube Team
 * license MIT
 *
 * brief @yyc3/i18n-core parser-compiler.ts 单元测试
 */
import { describe, expect, it } from "vitest";
import { ICUCompiler } from "../../lib/icu/compiler.js";
import { ICUParser } from "../../lib/icu/parser.js";

function compile(input: string, params: Record<string, unknown>, locale = "en"): string {
  const parser = new ICUParser();
  const { nodes, errors } = parser.parse(input);
  expect(errors).toHaveLength(0);
  const compiler = new ICUCompiler();
  return compiler.compile(nodes, { locale, params });
}

describe("ICU Parser + Compiler", () => {
  describe("literal text", () => {
    it("should return literal text unchanged", () => {
      expect(compile("Hello World", {})).toBe("Hello World");
    });

    it("should handle empty string", () => {
      expect(compile("", {})).toBe("");
    });
  });

  describe("simple arguments", () => {
    it("should interpolate {name}", () => {
      expect(compile("Hello {name}", { name: "YYC³" })).toBe("Hello YYC³");
    });

    it("should interpolate multiple arguments", () => {
      expect(compile("{greeting} {name}!", { greeting: "Hi", name: "World" })).toBe("Hi World!");
    });

    it("should handle missing params gracefully", () => {
      expect(compile("Hello {name}", {})).toBe("Hello ");
    });
  });

  describe("plural", () => {
    it("should select 'one' for count 1", () => {
      const template = "{count, plural, one {# item} other {# items}}";
      expect(compile(template, { count: 1 })).toBe("1 item");
    });

    it("should select 'other' for count 5", () => {
      const template = "{count, plural, one {# item} other {# items}}";
      expect(compile(template, { count: 5 })).toBe("5 items");
    });

    it("should select 'zero' for count 0", () => {
      const template = "{count, plural, zero {no items} one {# item} other {# items}}";
      expect(compile(template, { count: 0 })).toBe("no items");
    });

    it("should handle exact match with =N", () => {
      const template = "{count, plural, =0 {nothing} =1 {one thing} other {# things}}";
      expect(compile(template, { count: 0 })).toBe("nothing");
      expect(compile(template, { count: 1 })).toBe("one thing");
      expect(compile(template, { count: 5 })).toBe("5 things");
    });
  });

  describe("select", () => {
    it("should select matching clause", () => {
      const template = "{gender, select, male {He said} female {She said} other {They said}}";
      expect(compile(template, { gender: "male" })).toBe("He said");
      expect(compile(template, { gender: "female" })).toBe("She said");
    });

    it("should fallback to 'other'", () => {
      const template = "{gender, select, male {He} other {They}}";
      expect(compile(template, { gender: "unknown" })).toBe("They");
    });
  });

  describe("selectOrdinal", () => {
    it("should work with ordinal patterns", () => {
      const template = "{rank, selectOrdinal, one {#st} two {#nd} few {#rd} other {#th}}";
      const result = compile(template, { rank: 4 }, "en");
      expect(result).toMatch(/4/);
    });
  });

  describe("number format", () => {
    it("should format numbers with Intl", () => {
      const result = compile("{value, number}", { value: 1234.5 }, "en");
      expect(result).toMatch(/1.*234.*5/);
    });
  });

  describe("date format", () => {
    it("should format dates", () => {
      const result = compile("{date, date, short}", { date: new Date(2026, 0, 15) }, "en");
      expect(result.length).toBeGreaterThan(0);
    });
  });

  describe("time format", () => {
    it("should format times", () => {
      const result = compile("{time, time, short}", { time: new Date(2026, 0, 15, 14, 30) }, "en");
      expect(result.length).toBeGreaterThan(0);
    });
  });

  describe("Chinese locale plural", () => {
    it("should always use 'other' for Chinese", () => {
      const template = "{count, plural, other {# 个项目}}";
      expect(compile(template, { count: 0 }, "zh-CN")).toBe("0 个项目");
      expect(compile(template, { count: 1 }, "zh-CN")).toBe("1 个项目");
      expect(compile(template, { count: 5 }, "zh-CN")).toBe("5 个项目");
    });
  });

  describe("Arabic locale plural (6 forms)", () => {
    it("should handle Arabic plural rules", () => {
      const template = "{count, plural, zero {صفر} one {واحد} two {اثنان} few {قليل} many {كثير} other {#}}";
      expect(compile(template, { count: 0 }, "ar")).toBe("صفر");
      expect(compile(template, { count: 1 }, "ar")).toBe("واحد");
      expect(compile(template, { count: 2 }, "ar")).toBe("اثنان");
      expect(compile(template, { count: 5 }, "ar")).toBe("قليل");
      expect(compile(template, { count: 50 }, "ar")).toBe("كثير");
      expect(compile(template, { count: 150 }, "ar")).toBe("150");
    });
  });

  describe("nested arguments in clauses", () => {
    it("should interpolate arguments inside plural clauses", () => {
      const template = "{count, plural, one {{name} has # item} other {{name} has # items}}";
      expect(compile(template, { count: 1, name: "Alice" })).toBe("Alice has 1 item");
      expect(compile(template, { count: 3, name: "Bob" })).toBe("Bob has 3 items");
    });
  });

  describe("escaped apostrophes", () => {
    it("should handle escaped text", () => {
      expect(compile("It's a test", {})).toBe("It's a test");
    });
  });

  describe("offset in plural", () => {
    it("should handle offset in plural rules", () => {
      const template = "{count, plural, offset:1 =0 {none} one {# item} other {# items}}";
      // With offset=1 and count=1, displayCount = 0, matches =0
      expect(compile(template, { count: 1 })).toBe("none");
      // With offset=1 and count=2, displayCount = 1, matches 'one'
      expect(compile(template, { count: 2 })).toBe("1 item");
      // With offset=1 and count=5, displayCount = 4, matches 'other'
      expect(compile(template, { count: 5 })).toBe("4 items");
    });

    it("should handle offset with no exact match", () => {
      // offset is parsed but no =N or category matches — should fallback to other
      const template = "{n, plural, offset:2 other {# left}}";
      expect(compile(template, { n: 5 })).toBe("3 left");
    });
  });

  describe("custom formatters", () => {
    it("should use custom formatNumber", () => {
      const parser = new ICUParser();
      const { nodes, errors } = parser.parse("{val, number, percent}");
      expect(errors).toHaveLength(0);
      const compiler = new ICUCompiler();
      const result = compiler.compile(nodes, {
        locale: "en",
        params: { val: 0.5 },
        formatNumber: (_locale, value, fmt) => `custom:${fmt}:${value}`,
      });
      expect(result).toBe("custom:percent:0.5");
    });

    it("should use custom formatDate", () => {
      const parser = new ICUParser();
      const { nodes, errors } = parser.parse("{d, date, long}");
      expect(errors).toHaveLength(0);
      const compiler = new ICUCompiler();
      const result = compiler.compile(nodes, {
        locale: "en",
        params: { d: new Date(2026, 0, 15) },
        formatDate: (_locale, _value, fmt) => `custom-date:${fmt}`,
      });
      expect(result).toBe("custom-date:long");
    });

    it("should use custom formatTime", () => {
      const parser = new ICUParser();
      const { nodes, errors } = parser.parse("{t, time, short}");
      expect(errors).toHaveLength(0);
      const compiler = new ICUCompiler();
      const result = compiler.compile(nodes, {
        locale: "en",
        params: { t: new Date(2026, 0, 15, 10, 30) },
        formatTime: (_locale, _value, fmt) => `custom-time:${fmt}`,
      });
      expect(result).toBe("custom-time:short");
    });
  });

  describe("number edge cases", () => {
    it("should handle non-numeric number argument", () => {
      const result = compile("{val, number}", { val: "abc" });
      expect(result).toBe("abc");
    });

    it("should handle undefined number argument", () => {
      const result = compile("{val, number}", {});
      expect(result).toBe("");
    });
  });

  describe("date edge cases", () => {
    it("should handle invalid date value", () => {
      const result = compile("{d, date, short}", { d: "not-a-date" });
      expect(result).toBe("not-a-date");
    });

    it("should handle Date object directly", () => {
      const date = new Date(2026, 0, 15);
      const result = compile("{d, date, short}", { d: date });
      expect(result.length).toBeGreaterThan(0);
    });
  });

  describe("time edge cases", () => {
    it("should handle invalid time value", () => {
      const result = compile("{t, time, short}", { t: "invalid" });
      expect(result).toBe("invalid");
    });

    it("should handle Date object for time", () => {
      const date = new Date(2026, 0, 15, 14, 30);
      const result = compile("{t, time, short}", { t: date });
      expect(result.length).toBeGreaterThan(0);
    });
  });

  describe("selectOrdinal fallback", () => {
    it("should fallback to other when no category matches", () => {
      const template = "{rank, selectOrdinal, one {#st} other {#th}}";
      // count=4 in English plural → "other" → "#th"
      const result = compile(template, { rank: 4 }, "en");
      expect(result).toBe("4th");
    });

    it("should match category before exact selector in selectOrdinal", () => {
      // In English, 1 → pluralRule "one" category matches first before =1
      const template = "{rank, selectOrdinal, =1 {first} one {#st} other {#th}}";
      const result = compile(template, { rank: 1 }, "en");
      // Category "one" is checked before exact match =1
      expect(result).toBe("1st");
    });
  });

  describe("select with no other clause", () => {
    it("should return the raw value when no match and no other", () => {
      const template = "{gender, select, male {He}}";
      const result = compile(template, { gender: "female" });
      expect(result).toBe("female");
    });
  });

  describe("plural with no other clause", () => {
    it("should return displayCount when no other clause", () => {
      const template = "{n, plural, one {# item}}";
      // count=5 in English → "other" category, no clause → returns displayCount
      const result = compile(template, { n: 5 }, "en");
      expect(result).toBe("5");
    });
  });

  describe("French plural rules", () => {
    it("should use one for 0 and 1 in French", () => {
      const template = "{n, plural, one {# élément} other {# éléments}}";
      expect(compile(template, { n: 0 }, "fr")).toBe("0 élément");
      expect(compile(template, { n: 1 }, "fr")).toBe("1 élément");
      expect(compile(template, { n: 5 }, "fr")).toBe("5 éléments");
    });
  });

  describe("German plural rules", () => {
    it("should use one for 1 in German", () => {
      const template = "{n, plural, one {# Tag} other {# Tage}}";
      expect(compile(template, { n: 1 }, "de")).toBe("1 Tag");
      expect(compile(template, { n: 5 }, "de")).toBe("5 Tage");
    });
  });

  describe("Portuguese plural rules", () => {
    it("should handle Portuguese plural categories", () => {
      const template = "{n, plural, one {# item} two {# itens-duplos} other {# itens}}";
      expect(compile(template, { n: 1 }, "pt")).toBe("1 item");
      expect(compile(template, { n: 2 }, "pt")).toBe("2 itens-duplos");
      expect(compile(template, { n: 5 }, "pt")).toBe("5 itens");
    });
  });

  describe("unknown locale plural fallback", () => {
    it("should fallback to English rules for unknown locale", () => {
      const template = "{n, plural, one {# x} other {# xs}}";
      const result = compile(template, { n: 1 }, "xx-YY");
      expect(result).toBe("1 x");
    });
  });

  describe("plural with non-numeric count", () => {
    it("should default count to 0 when param is non-numeric", () => {
      const template = "{n, plural, =0 {zero} one {# item} other {# items}}";
      const result = compile(template, { n: "abc" });
      // Number("abc") || 0 → 0, matches =0
      expect(result).toBe("zero");
    });

    it("should handle undefined count", () => {
      const template = "{n, plural, =0 {zero} other {# items}}";
      const result = compile(template, {});
      // Number(undefined) || 0 → 0
      expect(result).toBe("zero");
    });
  });
});
