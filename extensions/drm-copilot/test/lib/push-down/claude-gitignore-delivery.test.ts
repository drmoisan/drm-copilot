import { describe, expect, it } from "@jest/globals";

import {
  CLAUDE_GITIGNORE_BEGIN_SENTINEL,
  CLAUDE_GITIGNORE_END_SENTINEL,
  CLAUDE_GITIGNORE_RELATIVE_PATH,
  CLAUDE_MANAGED_IGNORE_ENTRIES,
} from "../../../src/lib/push-down/claude-gitignore-merge";
import { DEST, publish, seedTree } from "./config-carriage.test-helpers";

/**
 * End-to-end delivery of the destination-side ignore configuration (issue #596).
 *
 * Purpose:
 *     `claude-gitignore-merge.test.ts` covers the merge function in isolation.
 *     This suite covers the call site: that a push-down actually delivers the
 *     managed block into the destination workspace, that it does so under a
 *     pack-scoped publish as well as an unscoped one, that a second publish is
 *     byte-stable and performs no write at all, and that the destination's own
 *     unrelated entries survive with their relative order intact.
 *
 * Scope note:
 *     Every case uses the hermetic in-memory adapter; no filesystem is touched.
 *     A new sibling suite is used rather than an extension of
 *     `claude-config-carriage.test.ts`, which is already near the 500-line cap.
 */

/** Absolute destination path of the file under delivery. */
const DEST_GITIGNORE = `${DEST}/${CLAUDE_GITIGNORE_RELATIVE_PATH}`;

/** The managed block exactly as the merge module emits it. */
const MANAGED_BLOCK = [
  CLAUDE_GITIGNORE_BEGIN_SENTINEL,
  ...CLAUDE_MANAGED_IGNORE_ENTRIES,
  CLAUDE_GITIGNORE_END_SENTINEL,
  "",
].join("\n");

/** Counts non-overlapping occurrences of a literal within a text. */
function countOccurrences(text: string, literal: string): number {
  return text.split(literal).length - 1;
}

describe("issue #596: the Claude push-down delivers destination-side ignore configuration", () => {
  it("delivers the managed ignore block to the destination on an unscoped publish", () => {
    // Arrange
    const seeded = seedTree();

    // Act
    publish(seeded);

    // Assert
    expect(seeded.isFile(DEST_GITIGNORE)).toBe(true);
    expect(seeded.readTextFile(DEST_GITIGNORE)).toBe(MANAGED_BLOCK);
  });

  it("delivers the managed ignore block to the destination on a pack-scoped publish", () => {
    // Arrange: a manifest-scoped run must not drop the ignore delivery.
    const seeded = seedTree();

    // Act
    publish(seeded, new Set(["core"]));

    // Assert
    expect(seeded.isFile(DEST_GITIGNORE)).toBe(true);
    expect(seeded.readTextFile(DEST_GITIGNORE)).toBe(MANAGED_BLOCK);
  });

  it("leaves the destination gitignore byte-identical and unwritten on a second publish", () => {
    // Arrange
    const seeded = seedTree();

    // Act
    publish(seeded);
    const afterFirst = seeded.readTextFile(DEST_GITIGNORE);
    // Snapshot the write log after the first publish so the assertion inspects
    // only the second publish's writes; asserting over the whole array would
    // always find the first publish's write and could never fail.
    const writesBeforeSecond = seeded.writtenPaths.length;
    publish(seeded);
    const afterSecond = seeded.readTextFile(DEST_GITIGNORE);
    const secondPublishWrites = seeded.writtenPaths.slice(writesBeforeSecond);

    // Assert
    expect(secondPublishWrites).not.toContain(DEST_GITIGNORE);
    expect(afterSecond).toBe(afterFirst);
    expect(countOccurrences(afterSecond, CLAUDE_GITIGNORE_BEGIN_SENTINEL)).toBe(
      1,
    );
    expect(countOccurrences(afterSecond, CLAUDE_GITIGNORE_END_SENTINEL)).toBe(
      1,
    );
  });

  it("preserves unrelated destination entries and their relative order", () => {
    // Arrange: three unrelated entries the destination workspace owns.
    const unrelated = ["node_modules/", "dist/", "*.log"];
    const seeded = seedTree({
      [DEST_GITIGNORE]: `${unrelated.join("\n")}\n`,
    });

    // Act
    publish(seeded);
    const merged = seeded.readTextFile(DEST_GITIGNORE);

    // Assert: every unrelated entry survives, and their relative order is the
    // order the destination authored them in.
    const positions = unrelated.map((entry) => merged.indexOf(`${entry}\n`));
    for (const position of positions) {
      expect(position).toBeGreaterThanOrEqual(0);
    }
    expect(positions).toEqual(
      [...positions].sort((left, right) => left - right),
    );
  });
});
