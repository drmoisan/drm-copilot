import { describe, expect, it } from "@jest/globals";

import { describeHandoffFailureCause } from "../../../src/lib/validate/orchestration-handoff-materializer-request";

/**
 * Issue #645 (R18): blocked handoff results carry a redaction-safe
 * `<stage>: <token>` failure cause. These cases pin the token rule and prove
 * that no error message (and so no host path or environment value) can reach
 * the cause string.
 */

describe("describeHandoffFailureCause", () => {
  it.each([
    {
      label: "(a) an uppercase string code is the token",
      error: Object.assign(new Error("x"), { code: "EACCES" }),
      expected: "checkpoint-read: EACCES",
    },
    {
      label: "(b) a non-identifier string code falls back to the error name",
      error: Object.assign(new Error("x"), { code: "eacces-lower" }),
      expected: "checkpoint-read: Error",
    },
    {
      label: "(c) a numeric code falls back to the error name",
      error: Object.assign(new Error("x"), { code: 13 }),
      expected: "checkpoint-read: Error",
    },
    {
      label: "(d) an Error subclass without a code uses its name",
      error: new TypeError("x"),
      expected: "checkpoint-read: TypeError",
    },
    {
      label: "(e) a thrown string is a non-error value",
      error: "boom",
      expected: "checkpoint-read: non-error value",
    },
    {
      label: "(f) undefined is a non-error value",
      error: undefined,
      expected: "checkpoint-read: non-error value",
    },
    {
      label: "(g) a plain object with an uppercase code uses the code",
      error: { code: "ENOENT" },
      expected: "checkpoint-read: ENOENT",
    },
  ])("$label", ({ error, expected }) => {
    // Arrange
    const stage = "checkpoint-read";

    // Act
    const cause = describeHandoffFailureCause(stage, error);

    // Assert
    expect(cause).toBe(expected);
  });

  it("never copies an error message, path, or environment value into the cause", () => {
    // Arrange
    const messages = [
      "C:\\Users\\operator\\AppData\\secret.json",
      "/home/operator/.ssh/id_rsa",
      "HOME=/home/operator",
    ];
    const errors = messages.flatMap((message) => [
      { message, error: new Error(message) },
      {
        message,
        error: Object.assign(new Error(message), { code: "EACCES" }),
      },
    ]);

    // Act
    const causes = errors.map(({ message, error }) => ({
      message,
      cause: describeHandoffFailureCause("checkpoint-read", error),
    }));

    // Assert
    expect(causes).toHaveLength(6);
    for (const { message, cause } of causes) {
      expect(cause).not.toContain(message);
      expect(cause).not.toContain("/");
      expect(cause).not.toContain("\\");
      expect(cause).not.toContain("operator");
    }
  });
});
