/**
 * file cache.test.ts
 * description @yyc3/i18n-core cache.ts 单元测试
 * module @yyc3/i18n-core
 * author YanYuCloudCube Team <admin@0379.email>
 * version 2.4.0
 * created 2026-06-14
 * updated 2026-06-14
 * status active
 * tags [test],[unit]
 *
 * copyright YanYuCloudCube Team
 * license MIT
 *
 * brief @yyc3/i18n-core cache.ts 单元测试
 */
import { describe, expect, it, vi } from "vitest";
import { LRUCache } from "../lib/cache.js";

describe("LRUCache", () => {
  describe("basic operations", () => {
    it("should set and get values", () => {
      const cache = new LRUCache<string>();
      cache.set("key1", "value1");
      expect(cache.get("key1")).toBe("value1");
    });

    it("should return null for missing keys", () => {
      const cache = new LRUCache<string>();
      expect(cache.get("nonexistent")).toBeNull();
    });

    it("should delete entries", () => {
      const cache = new LRUCache<string>();
      cache.set("key1", "value1");
      expect(cache.delete("key1")).toBe(true);
      expect(cache.get("key1")).toBeNull();
      expect(cache.delete("key1")).toBe(false);
    });

    it("should check existence with has()", () => {
      const cache = new LRUCache<string>();
      cache.set("key1", "value1");
      expect(cache.has("key1")).toBe(true);
      expect(cache.has("key2")).toBe(false);
    });

    it("should clear all entries and reset stats", () => {
      const cache = new LRUCache<string>();
      cache.set("a", "1");
      cache.set("b", "2");
      cache.get("a"); // hit
      cache.get("x"); // miss

      cache.clear();
      // After clear, stats are reset
      const stats = cache.getStats();
      expect(stats.size).toBe(0);
      expect(stats.hits).toBe(0);
      expect(stats.misses).toBe(0);
      expect(stats.evictions).toBe(0);
      // Verify cache is actually empty
      expect(cache.has("a")).toBe(false);
    });
  });

  describe("keys() and values()", () => {
    it("should return all keys", () => {
      const cache = new LRUCache<string>();
      cache.set("a", "1");
      cache.set("b", "2");
      const keys = cache.keys();
      expect(keys).toHaveLength(2);
      expect(keys).toContain("a");
      expect(keys).toContain("b");
    });

    it("should return all values", () => {
      const cache = new LRUCache<string>();
      cache.set("a", "val1");
      cache.set("b", "val2");
      const values = cache.values();
      expect(values).toHaveLength(2);
      expect(values).toContain("val1");
      expect(values).toContain("val2");
    });

    it("should return empty arrays when cache is empty", () => {
      const cache = new LRUCache<string>();
      expect(cache.keys()).toEqual([]);
      expect(cache.values()).toEqual([]);
    });
  });

  describe("TTL expiration", () => {
    it("should return value within TTL", () => {
      const cache = new LRUCache<string>({ defaultTTL: 10000 });
      cache.set("key", "value");
      expect(cache.get("key")).toBe("value");
    });

    it("should expire entries after TTL", () => {
      vi.useFakeTimers();
      const cache = new LRUCache<string>({ defaultTTL: 100 });
      cache.set("key", "value");

      // Within TTL
      vi.advanceTimersByTime(50);
      expect(cache.get("key")).toBe("value");

      // After TTL
      vi.advanceTimersByTime(100);
      expect(cache.get("key")).toBeNull();
      vi.useRealTimers();
    });

    it("should support custom TTL per entry", () => {
      vi.useFakeTimers();
      const cache = new LRUCache<string>({ defaultTTL: 10000 });
      cache.set("short", "val", 50);
      cache.set("long", "val", 10000);

      vi.advanceTimersByTime(60);
      expect(cache.get("short")).toBeNull();
      expect(cache.get("long")).toBe("val");
      vi.useRealTimers();
    });
  });

  describe("LRU eviction", () => {
    it("should evict least recently used when at capacity", () => {
      const cache = new LRUCache<string>({ maxSize: 3 });
      cache.set("a", "1");
      cache.set("b", "2");
      cache.set("c", "3");

      // Access "a" to make it most recently used
      cache.get("a");

      // Insert "d" — should evict "b" (least recently used)
      cache.set("d", "4");

      expect(cache.has("a")).toBe(true); // recently used
      expect(cache.has("b")).toBe(false); // evicted
      expect(cache.has("c")).toBe(true);
      expect(cache.has("d")).toBe(true);

      const stats = cache.getStats();
      expect(stats.evictions).toBe(1);
    });

    it("should not evict when updating existing key", () => {
      const cache = new LRUCache<string>({ maxSize: 2 });
      cache.set("a", "1");
      cache.set("b", "2");
      cache.set("a", "updated"); // Update existing, no eviction

      expect(cache.get("a")).toBe("updated");
      expect(cache.get("b")).toBe("2");
      expect(cache.getStats().evictions).toBe(0);
    });
  });

  describe("disabled cache", () => {
    it("should not store values when disabled", () => {
      const cache = new LRUCache<string>({ enabled: false });
      cache.set("key", "value");
      expect(cache.get("key")).toBeNull();
      expect(cache.has("key")).toBe(false);
    });

    it("should return null for get when disabled", () => {
      const cache = new LRUCache<string>({ enabled: false });
      expect(cache.get("anything")).toBeNull();
    });
  });

  describe("getStats", () => {
    it("should track hits and misses", () => {
      const cache = new LRUCache<string>();
      cache.set("a", "1");

      cache.get("a"); // hit
      cache.get("a"); // hit
      cache.get("x"); // miss

      const stats = cache.getStats();
      expect(stats.hits).toBe(2);
      expect(stats.misses).toBe(1);
      expect(stats.hitRate).toBeCloseTo(66.67, 1);
    });

    it("should return 0 hitRate when no operations", () => {
      const cache = new LRUCache<string>();
      const stats = cache.getStats();
      expect(stats.hitRate).toBe(0);
      expect(stats.size).toBe(0);
      expect(stats.maxSize).toBe(1000);
    });

    it("should track evictions", () => {
      const cache = new LRUCache<number>({ maxSize: 2 });
      cache.set("a", 1);
      cache.set("b", 2);
      cache.set("c", 3); // evicts "a"

      const stats = cache.getStats();
      expect(stats.evictions).toBe(1);
      expect(stats.size).toBe(2);
      expect(stats.maxSize).toBe(2);
    });
  });

  describe("config defaults", () => {
    it("should use default config when none provided", () => {
      const cache = new LRUCache<string>();
      expect(cache.config.maxSize).toBe(1000);
      expect(cache.config.defaultTTL).toBe(5 * 60 * 1000);
      expect(cache.config.enabled).toBe(true);
    });

    it("should accept partial config", () => {
      const cache = new LRUCache<string>({ maxSize: 50 });
      expect(cache.config.maxSize).toBe(50);
      expect(cache.config.defaultTTL).toBe(5 * 60 * 1000);
    });
  });
});
