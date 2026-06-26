import { describe, expect, it } from "@jest/globals";

import { validateHumanInteraction } from "../../../src/lib/validate/orchestrator-state-human-interaction";

describe("validateHumanInteraction", () => {
  it("rejects a non-object human_interaction value", () => {
    // Arrange / Act
    const errors = validateHumanInteraction("not-an-object");

    // Assert
    expect(errors).toContain(
      "Checkpoint human_interaction must be an object when present.",
    );
  });

  it("rejects a human_interaction without a requirements list", () => {
    // Arrange / Act
    const errors = validateHumanInteraction({ note: "no requirements here" });

    // Assert
    expect(errors).toContain(
      "Checkpoint human_interaction.requirements must be a list.",
    );
  });

  it("rejects a requirements value that is not a list", () => {
    // Arrange / Act
    const errors = validateHumanInteraction({ requirements: "nope" });

    // Assert
    expect(errors).toContain(
      "Checkpoint human_interaction.requirements must be a list.",
    );
  });

  it("rejects a non-object requirement entry with the indexed error", () => {
    // Arrange / Act
    const errors = validateHumanInteraction({
      requirements: ["not-a-requirement"],
    });

    // Assert
    expect(errors).toContain(
      "Checkpoint human_interaction.requirements #0 must be an object.",
    );
  });

  it("rejects a response outside the permitted enum", () => {
    // Arrange / Act
    const errors = validateHumanInteraction({
      requirements: [{ response: "maybe" }],
    });

    // Assert
    expect(errors).toContain(
      "Checkpoint human_interaction.requirements #0 response " +
        "must be one of scope_change, exception, halt; got: maybe",
    );
  });

  it("renders a missing response as None for parity", () => {
    // Arrange / Act
    const errors = validateHumanInteraction({ requirements: [{}] });

    // Assert
    expect(errors).toContain(
      "Checkpoint human_interaction.requirements #0 response " +
        "must be one of scope_change, exception, halt; got: None",
    );
  });

  it("accepts a valid halt response", () => {
    // Arrange / Act
    const errors = validateHumanInteraction({
      requirements: [{ response: "halt" }],
    });

    // Assert
    expect(errors).toEqual([]);
  });

  it("accepts a valid scope_change response", () => {
    // Arrange / Act
    const errors = validateHumanInteraction({
      requirements: [{ response: "scope_change" }],
    });

    // Assert
    expect(errors).toEqual([]);
  });

  it("accepts an exception with a valid runbook_path", () => {
    // Arrange / Act
    const errors = validateHumanInteraction({
      requirements: [
        {
          response: "exception",
          runbook_path: "docs/runbooks/admin-consent.runbook.md",
        },
      ],
    });

    // Assert
    expect(errors).toEqual([]);
  });

  it("rejects an exception with a missing runbook_path", () => {
    // Arrange / Act
    const errors = validateHumanInteraction({
      requirements: [{ response: "exception" }],
    });

    // Assert
    expect(errors).toContain(
      "Checkpoint human_interaction.requirements #0 " +
        "response is exception but runbook_path is missing or empty.",
    );
  });

  it("rejects an exception with a whitespace-only runbook_path", () => {
    // Arrange / Act
    const errors = validateHumanInteraction({
      requirements: [{ response: "exception", runbook_path: "   " }],
    });

    // Assert
    expect(errors).toContain(
      "Checkpoint human_interaction.requirements #0 " +
        "response is exception but runbook_path is missing or empty.",
    );
  });

  it("validates multiple requirements independently", () => {
    // Arrange / Act
    const errors = validateHumanInteraction({
      requirements: [{ response: "scope_change" }, { response: "exception" }],
    });

    // Assert: only the second requirement is malformed.
    expect(errors).toEqual([
      "Checkpoint human_interaction.requirements #1 " +
        "response is exception but runbook_path is missing or empty.",
    ]);
  });
});
