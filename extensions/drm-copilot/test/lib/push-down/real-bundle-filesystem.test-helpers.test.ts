/**
 * Unit tests for `registryHookPaths` (issue #1159).
 *
 * Each case reads in-memory registry text only; no file is read or created.
 */

import { describe, expect, it } from "@jest/globals";

import { registryHookPaths } from "./real-bundle-filesystem.test-helpers";

/** Build a registry hook entry whose command runs one script path. */
function hookEntry(scriptPath: string): Record<string, unknown> {
  return {
    type: "command",
    command: `pwsh -NoProfile -File "$(git rev-parse --show-toplevel)/${scriptPath}"`,
    timeout: 30,
  };
}

describe("registryHookPaths", () => {
  it("returns every PreToolUse hook path named by a registry command", () => {
    // Arrange
    const registryText = JSON.stringify({
      isolation: "in-process",
      hooks: {
        PreToolUse: [
          {
            matcher: "^Bash$",
            hooks: [
              hookEntry(".codex/hooks/validate-bash.ps1"),
              hookEntry(".codex/hooks/enforce-promotion-mcp-only.ps1"),
            ],
          },
          {
            matcher: "^apply_patch$",
            hooks: [
              hookEntry(".codex/hooks/enforce-file-size-limit.ps1"),
              hookEntry(".codex/hooks/validate-bash.ps1"),
            ],
          },
        ],
      },
    });

    // Act
    const paths = registryHookPaths(registryText);

    // Assert
    expect(paths).toEqual([
      ".codex/hooks/validate-bash.ps1",
      ".codex/hooks/enforce-promotion-mcp-only.ps1",
      ".codex/hooks/enforce-file-size-limit.ps1",
    ]);
  });

  it("skips a registry hook whose command names no .codex/hooks script", () => {
    // Arrange
    const registryText = JSON.stringify({
      hooks: {
        PreToolUse: [
          {
            matcher: "^Bash$",
            hooks: [
              hookEntry(".claude/hooks/validate-bash.ps1"),
              { type: "command", command: 42 },
              { type: "command" },
              "not an object",
              hookEntry(".codex/hooks/enforce-evidence-locations.ps1"),
            ],
          },
          { matcher: "^Write$", hooks: "not an array" },
        ],
      },
    });

    // Act
    const paths = registryHookPaths(registryText);

    // Assert
    expect(paths).toEqual([".codex/hooks/enforce-evidence-locations.ps1"]);
  });

  it("returns no path for a registry without PreToolUse groups", () => {
    // Arrange
    const registries = [
      JSON.stringify({ isolation: "per-process", hooks: {} }),
      JSON.stringify({ hooks: { PreToolUse: "not an array" } }),
      JSON.stringify({ notes: ["no hooks block"] }),
      JSON.stringify([]),
    ];

    // Act
    const results = registries.map((text) => registryHookPaths(text));

    // Assert
    expect(results).toEqual([[], [], [], []]);
  });
});
