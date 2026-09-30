import { describe, expect, it } from "@jest/globals";

import { promotePotential } from "../../../src/lib/potential-to-issue/promotion";
import {
  buildFeatureContent,
  DroppingMovePotentialFileSystem,
  FakeGhClient,
  FakePotentialFileSystem,
  WORKSPACE,
} from "./promotion-test-support";

/**
 * Regression tests for #623: `promotePotential` must verify that the promoted
 * destination exists after the move before it reports success. The shared
 * hermetic fakes keep every case in memory (no real gh, filesystem, or temp
 * files).
 */

const POTENTIAL_PATH = "/workspace/docs/features/potential/sample.md";
const DEST_TS = "/workspace/docs/features/potential/promoted/sample.md";

/** Build the gh fake shared by both scenarios: a successful create and view. */
function makeGh(): FakeGhClient {
  return new FakeGhClient(
    { output: ["Created: https://example.com/issues/123"], exitCode: 0 },
    { output: [], exitCode: 0 },
  );
}

describe("promotePotential — post-move destination verification", () => {
  it("returns exit code 1 without a destination when the promoted file is missing after the move", () => {
    // Purpose: a move that drops the file must yield a non-zero outcome with no
    // destination, while still reporting the created issue URL.
    // Arrange
    const fs = new DroppingMovePotentialFileSystem();
    fs.files.set(POTENTIAL_PATH, buildFeatureContent("Feature Title"));
    const gh = makeGh();

    // Act
    const outcome = promotePotential({
      potentialPath: POTENTIAL_PATH,
      promotionType: "feature",
      fs,
      gh,
      workspace: WORKSPACE,
      emit: () => undefined,
    });

    // Assert
    expect(outcome.exitCode).toBe(1);
    expect(outcome.destination).toBeUndefined();
    expect(outcome.messages[outcome.messages.length - 1]).toBe(
      `Promoted file missing after move: ${DEST_TS}`,
    );
    expect(outcome.messages).toContain(
      "Created: https://example.com/issues/123",
    );
    expect(
      outcome.messages.some((m) =>
        m.startsWith("Moved potential file to promoted folder:"),
      ),
    ).toBe(false);
  });

  it("returns exit code 0 with the destination when the promoted file exists after the move", () => {
    // Purpose: a move that produces the destination keeps the success outcome
    // and the "Moved" line unchanged.
    // Arrange
    const fs = new FakePotentialFileSystem();
    fs.files.set(POTENTIAL_PATH, buildFeatureContent("Feature Title"));
    const gh = makeGh();

    // Act
    const outcome = promotePotential({
      potentialPath: POTENTIAL_PATH,
      promotionType: "feature",
      fs,
      gh,
      workspace: WORKSPACE,
      emit: () => undefined,
    });

    // Assert
    expect(outcome.exitCode).toBe(0);
    expect(outcome.destination).toBe(DEST_TS);
    expect(fs.exists(DEST_TS)).toBe(true);
    expect(outcome.messages[outcome.messages.length - 1]).toBe(
      `Moved potential file to promoted folder: ${DEST_TS}`,
    );
  });
});
