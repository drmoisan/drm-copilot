import { describe, expect, it } from "@jest/globals";

import {
  classifyPrContextDiffState,
  type ClassifyPrContextDiffStateInput,
} from "../../../src/lib/pr-context/diff-emptiness";

/**
 * Table-driven tests for the pure diff-state classifier (spec.md #675,
 * "Empty diff fails loudly"). Covers all four mechanisms named in the
 * spec's Root Cause Analysis table: refs unresolved (state C); refs
 * resolved with merge base equal to head SHA (states A/B); refs resolved
 * and unequal with no changed file (state D); and refs resolved with at
 * least one changed file (the populated case).
 */

const BASE_INPUT: ClassifyPrContextDiffStateInput = {
  mergeBase: "merge-sha",
  headSha: "head-sha",
  resolvedHeadRef: "feature/explicit-target",
  resolvedBase: "origin/main",
  changedFileCount: 1,
  requestedBase: "main",
  attemptedHeadRef: "feature/explicit-target",
};

describe("classifyPrContextDiffState", () => {
  it("classifies refs-unresolved when the base did not resolve", () => {
    const result = classifyPrContextDiffState({
      ...BASE_INPUT,
      mergeBase: null,
      headSha: null,
      resolvedBase: null,
    });

    expect(result.kind).toBe("refs-unresolved");
    if (result.kind !== "refs-unresolved") {
      throw new Error("expected refs-unresolved");
    }
    expect(result.message).toContain("main");
    expect(result.message).toContain("feature/explicit-target");
  });

  it("classifies refs-unresolved when the head did not resolve, naming the session HEAD when target_ref is absent", () => {
    const result = classifyPrContextDiffState({
      ...BASE_INPUT,
      mergeBase: null,
      headSha: null,
      resolvedBase: "origin/main",
      attemptedHeadRef: null,
    });

    expect(result.kind).toBe("refs-unresolved");
    if (result.kind !== "refs-unresolved") {
      throw new Error("expected refs-unresolved");
    }
    expect(result.message).toContain("main");
    expect(result.message).toContain("session HEAD");
  });

  it("classifies refs-resolved-no-change when the merge base equals the head SHA", () => {
    const result = classifyPrContextDiffState({
      ...BASE_INPUT,
      mergeBase: "same-sha",
      headSha: "same-sha",
      changedFileCount: 0,
    });

    expect(result.kind).toBe("refs-resolved-no-change");
    if (result.kind !== "refs-resolved-no-change") {
      throw new Error("expected refs-resolved-no-change");
    }
    expect(result.message).toContain("feature/explicit-target");
    expect(result.message).toContain("same-sha");
  });

  it("classifies refs-resolved-no-change when refs are unequal but no file changed", () => {
    const result = classifyPrContextDiffState({
      ...BASE_INPUT,
      changedFileCount: 0,
    });

    expect(result.kind).toBe("refs-resolved-no-change");
    if (result.kind !== "refs-resolved-no-change") {
      throw new Error("expected refs-resolved-no-change");
    }
    expect(result.message).toContain("merge-sha");
    expect(result.message).toContain("origin/main");
  });

  it("classifies populated when refs are resolved and at least one file changed", () => {
    const result = classifyPrContextDiffState({
      ...BASE_INPUT,
      changedFileCount: 3,
    });

    expect(result).toEqual({ kind: "populated" });
  });

  it("renders distinct messages for the two failing states", () => {
    const unresolved = classifyPrContextDiffState({
      ...BASE_INPUT,
      mergeBase: null,
      headSha: null,
      resolvedBase: null,
    });
    const noChange = classifyPrContextDiffState({
      ...BASE_INPUT,
      changedFileCount: 0,
    });

    expect(unresolved.kind).not.toEqual(noChange.kind);
    if (
      unresolved.kind === "refs-unresolved" &&
      noChange.kind === "refs-resolved-no-change"
    ) {
      expect(unresolved.message).not.toEqual(noChange.message);
    } else {
      throw new Error(
        "expected one refs-unresolved and one refs-resolved-no-change result",
      );
    }
  });
});
