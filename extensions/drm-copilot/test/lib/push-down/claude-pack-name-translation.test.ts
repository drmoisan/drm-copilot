import { describe, expect, it } from "@jest/globals";

import { translateSelectedPackNames } from "../../../src/lib/push-down/claude-pack-name-translation";

/**
 * Unit tests for the pure pack-name translation used by the Push Down Claude
 * Customizations command. Covers AC1-AC4 of issue #256. The function under test
 * has no VS Code host dependency, so these tests exercise it directly.
 */
describe("translateSelectedPackNames", () => {
  it("AC1: replaces csharp with csharp-modern when the modern variant is chosen", () => {
    // Arrange
    const packs = ["csharp"];

    // Act
    const result = translateSelectedPackNames(packs, "modern");

    // Assert
    expect(result).toContain("csharp-modern");
    expect(result).not.toContain("csharp");
  });

  it("AC2: replaces csharp with csharp-legacy when the legacy variant is chosen", () => {
    // Arrange
    const packs = ["csharp"];

    // Act
    const result = translateSelectedPackNames(packs, "legacy");

    // Assert
    expect(result).toContain("csharp-legacy");
    expect(result).not.toContain("csharp");
  });

  it("AC3: returns non-C# packs unchanged and in original order", () => {
    // Arrange
    const packs = ["python", "powershell", "typescript"];

    // Act
    const result = translateSelectedPackNames(packs, undefined);

    // Assert
    expect(result).toEqual(["python", "powershell", "typescript"]);
  });

  it("AC1/AC3: preserves order and leaves non-C# packs untouched when csharp is translated", () => {
    // Arrange
    const packs = ["python", "powershell", "typescript", "csharp"];

    // Act
    const result = translateSelectedPackNames(packs, "modern");

    // Assert
    expect(result).toEqual([
      "python",
      "powershell",
      "typescript",
      "csharp-modern",
    ]);
  });

  it("AC4: throws when csharp is selected but the variant is unresolved", () => {
    // Arrange
    const packs = ["csharp"];

    // Act / Assert
    expect(() => translateSelectedPackNames(packs, undefined)).toThrow(
      /variant/i,
    );
  });

  it("does not mutate the input array", () => {
    // Arrange
    const packs = ["python", "csharp"];

    // Act
    translateSelectedPackNames(packs, "legacy");

    // Assert
    expect(packs).toEqual(["python", "csharp"]);
  });
});
