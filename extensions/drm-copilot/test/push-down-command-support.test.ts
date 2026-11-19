/**
 * Unit tests for the host-neutral push-down command support (issue #1029).
 */

import { describe, expect, it } from "@jest/globals";

import {
  COPILOT_PUSH_DOWN_PACK_ITEMS,
  countExclusionConflictLines,
  countPushDownConflictLines,
  formatPushDownConflictMessage,
} from "../src/push-down-command-support";

const EXCLUSION_CONFLICT =
  "push-down exclusion conflict: destination file present, not overwritten: a.md (entry a.md, line 1)";
const EXCLUSION_SKIP = "push-down exclusion: skipped b.md (entry b.md, line 2)";
const PUSH_DOWN_CONFLICT =
  "push-down conflict: conflict c.md (layer shared, pack core): edited";
const PUSH_DOWN_DELETED =
  "push-down conflict: deleted-locally d.md (layer codex, pack core): gone";

describe("push-down command support", () => {
  it("offers the four Copilot packs without core", () => {
    expect(COPILOT_PUSH_DOWN_PACK_ITEMS.map((item) => item.pack)).toEqual([
      "python",
      "powershell",
      "typescript",
      "csharp",
    ]);
  });

  it("counts exclusion conflicts and push-down conflicts separately", () => {
    const warnings = [
      EXCLUSION_CONFLICT,
      EXCLUSION_SKIP,
      PUSH_DOWN_CONFLICT,
      PUSH_DOWN_DELETED,
    ];

    expect(countExclusionConflictLines(warnings)).toBe(1);
    expect(countPushDownConflictLines(warnings)).toBe(2);
  });

  it("counts zero when there are no warnings", () => {
    expect(countPushDownConflictLines(undefined)).toBe(0);
    expect(countExclusionConflictLines(undefined)).toBe(0);
  });

  it("formats the push-down conflict notification", () => {
    expect(formatPushDownConflictMessage(3)).toBe(
      "Push-down conflicts: 3. See the drm-copilot output channel for the affected paths.",
    );
  });
});
