import { describe, expect, it } from "@jest/globals";

import {
  computeWaveNumbers,
  EpicWaveCycleError,
} from "../../../src/lib/validate/epic-wave-computation";

describe("computeWaveNumbers", () => {
  it("uses longest-path dependency layering for every feature", () => {
    const manifest = new Map<string, string[]>([
      ["a", []],
      ["b", ["a"]],
      ["c", ["a"]],
      ["d", ["b", "c"]],
    ]);

    expect([...computeWaveNumbers(manifest)]).toEqual([
      ["a", 0],
      ["b", 1],
      ["c", 1],
      ["d", 2],
    ]);
  });

  it("reports the feature that closes a dependency cycle", () => {
    const manifest = new Map<string, string[]>([
      ["feature'a", ["b"]],
      ["b", ["feature'a"]],
    ]);

    expect(() => computeWaveNumbers(manifest)).toThrow(EpicWaveCycleError);
    expect(() => computeWaveNumbers(manifest)).toThrow(
      "Epic dependency manifest contains a cycle at feature folder " +
        "'feature\\'a'; wave numbers cannot be computed for a cyclic " +
        "dependency graph.",
    );
  });
});
