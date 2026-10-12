import { describe, expect, it } from "@jest/globals";

import { replaceAllVariables } from "../../../src/lib/resolve/file-prompt-transforms";

describe("replaceAllVariables code-point ordering", () => {
  it("889-cp-order: reports missing variables in code-point order (U+FF5E before U+1F600)", () => {
    // Arrange: the supplementary-plane placeholder is referenced first.
    const template = "${\u{1F600}}${～}";

    // Act
    const act = (): unknown => replaceAllVariables(template, {});

    // Assert: exact message with the U+FF5E name first.
    expect(act).toThrow(
      new Error("Unresolved template variables: ～, \u{1F600}"),
    );
  });

  it("889-cp-order: substitutes keys in code-point order (U+FF5E before U+1F600)", () => {
    // Arrange: substituting U+FF5E first yields two U+1F600 placeholders that
    // the second pass resolves; the reverse order leaves a placeholder behind.
    const template = "${～}${\u{1F600}}";
    const variables = { "～": "${\u{1F600}}", "\u{1F600}": "done" };

    // Act
    const resolved = replaceAllVariables(template, variables);

    // Assert
    expect(resolved).toBe("donedone");
  });
});
