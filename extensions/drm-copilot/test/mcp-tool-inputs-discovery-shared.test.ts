/**
 * Shared argument helpers used by every discovery input resolver.
 */

import { describe, expect, it } from "@jest/globals";

import {
  compact,
  normalizeOptionalInteger,
  normalizeOptionalStringList,
} from "../src/mcp-tool-inputs-discovery-shared";
describe("shared helpers", () => {
  it("validates positive integers and non-empty string lists and compacts undefined", () => {
    expect(normalizeOptionalInteger(undefined, "n")).toBeUndefined();
    expect(normalizeOptionalInteger(3, "n")).toBe(3);
    for (const bad of [0, 1.5, "3", -1]) {
      expect(() => normalizeOptionalInteger(bad, "n")).toThrow(
        /positive integer/,
      );
    }
    expect(normalizeOptionalStringList([" a ", "b"], "l")).toEqual(["a", "b"]);
    expect(() => normalizeOptionalStringList(["", "b"], "l")).toThrow(
      /non-empty/,
    );
    expect(compact({ a: 1, b: undefined, c: null })).toEqual({ a: 1, c: null });
  });
});
