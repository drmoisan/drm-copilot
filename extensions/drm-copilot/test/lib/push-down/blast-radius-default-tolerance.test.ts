import { describe, expect, it } from "@jest/globals";
import * as fs from "node:fs";
import * as path from "node:path";

import { deriveDestinationModuleMap } from "../../../src/lib/push-down/claude-blast-radius-derive-core";
import {
  BLAST_RADIUS_OVERLAY_RELATIVE_PATH,
  composeBlastRadiusOverlay,
} from "../../../src/lib/push-down/claude-blast-radius-overlay";

/**
 * Default scheduling tolerance delivered by an overlay-free push (issue #1013).
 *
 * Purpose:
 *     Pin spec D-1 and AC-01: a destination with no blast-radius overlay
 *     receives the published `conflict_tolerance` defaults, `tolerance_percent`
 *     100 and `combination_threshold_percent` 400. The scenario derives the
 *     destination document from an empty destination scan over the committed
 *     bundled truth table and composes it with a null overlay, the path taken
 *     when the overlay file is absent. The Python twin is
 *     `tests/scripts/dev_tools/test_push_down_claude_blast_radius_default_tolerance.py`.
 *
 * Side effects:
 *     Read-only access to the committed bundled truth table; no temporary file.
 */

/** The committed bundled truth table, five levels above this file. */
const BUNDLED_TABLE = path.join(
  __dirname,
  "..",
  "..",
  "..",
  "..",
  "..",
  "extensions",
  "drm-copilot",
  "resources",
  "claude-customizations",
  "config",
  "blast-radius.json",
);

/**
 * Derive and compose the destination document with no overlay.
 * @returns The destination `conflict_tolerance` member.
 */
function destinationConflictTolerance(): Record<string, unknown> {
  const sourceText = fs.readFileSync(BUNDLED_TABLE, "utf8");
  const derived = deriveDestinationModuleMap([], sourceText);
  const composed = composeBlastRadiusOverlay(
    derived,
    null,
    BLAST_RADIUS_OVERLAY_RELATIVE_PATH,
  );
  const document = JSON.parse(composed) as Record<string, unknown>;
  return document["conflict_tolerance"] as Record<string, unknown>;
}

describe("issue #1013: default tolerance after an overlay-free push", () => {
  it("delivers tolerance_percent 100", () => {
    // Act
    const member = destinationConflictTolerance();

    // Assert
    expect(member["tolerance_percent"]).toBe(100);
  });

  it("delivers combination_threshold_percent 400", () => {
    // Act
    const member = destinationConflictTolerance();

    // Assert
    expect(member["combination_threshold_percent"]).toBe(400);
  });
});
