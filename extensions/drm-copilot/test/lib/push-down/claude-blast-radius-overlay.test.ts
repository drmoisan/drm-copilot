import { describe, expect, it } from "@jest/globals";

import {
  layoutLister,
  OVERLAY_TEXT,
  publish,
  seedTree,
  SRC,
} from "./config-carriage.test-helpers";

/**
 * Destination blast-radius overlay (issue #508).
 *
 * Purpose:
 *     Cover the composition of the destination-owned overlay
 *     `config/blast-radius.local.json` onto the regenerated
 *     `config/blast-radius.json`, and the carriage rules that keep the overlay
 *     destination-owned: it is never published from the source and never
 *     written by a push.
 *
 * Scope note:
 *     Every case uses the hermetic in-memory adapter; no temporary files.
 */

describe("issue #508 AC11 overlay never shipped", () => {
  it("does not publish a source-side overlay file", () => {
    // Arrange: a source workspace that carries its own overlay file.
    const seeded = seedTree({
      [`${SRC}/config/blast-radius.local.json`]: OVERLAY_TEXT,
    });

    // Act
    publish(seeded, null, layoutLister({}));

    // Assert
    expect(seeded.isFile("/dest/config/blast-radius.local.json")).toBe(false);
  });
});
