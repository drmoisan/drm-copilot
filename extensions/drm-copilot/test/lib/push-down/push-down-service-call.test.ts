import { describe, expect, it } from "@jest/globals";

import {
  pushDownClaudeCustomizationsServiceCall,
  pushDownCodexAndAgentsCustomizationsServiceCall,
  pushDownCopilotCustomizationsServiceCall,
} from "../../../src/lib/push-down/push-down-service-call";
import { buildInMemoryFileSystem, fixedClock } from "./push-down.test-helpers";

const CLOCK = fixedClock("2026-06-26T00:15:00.000Z");
const EXT = "/ext";
const WS = "/workspace";

describe("pushDownCopilotCustomizationsServiceCall", () => {
  it("returns the preserved tool, summary, and single normalized artifact path", () => {
    // Arrange: seed a copilot source tree under the bundled resources root.
    const fs = buildInMemoryFileSystem(
      {
        [`${EXT}/resources/customizations/.github/agents/a.md`]: "body",
      },
      [WS],
    );

    // Act
    const result = pushDownCopilotCustomizationsServiceCall({
      fs,
      extensionRoot: EXT,
      workspaceRoot: WS,
      clock: CLOCK,
    });

    // Assert
    expect(result.tool).toBe("push_down_copilot_customizations");
    expect(result.summary).toBe(
      "Pushed bundled Copilot customizations into the destination workspace.",
    );
    expect(result.artifacts).toEqual([
      "/workspace/artifacts/copilot-customizations/push-down-20260626T001500Z.json",
    ]);
  });

  it("resolves the copilot bundled source root and copies into the workspace", () => {
    // Arrange
    const fs = buildInMemoryFileSystem(
      {
        [`${EXT}/resources/customizations/.github/prompts/p.prompt.md`]:
          "plain",
      },
      [WS],
    );

    // Act
    pushDownCopilotCustomizationsServiceCall({
      fs,
      extensionRoot: EXT,
      workspaceRoot: WS,
      clock: CLOCK,
    });

    // Assert: the file landed at the workspace destination path.
    expect(fs.isFile(`${WS}/.github/prompts/p.prompt.md`)).toBe(true);
  });
});

describe("pushDownCodexAndAgentsCustomizationsServiceCall", () => {
  it("returns the preserved tool, summary, and artifact path", () => {
    // Arrange
    const fs = buildInMemoryFileSystem(
      {
        [`${EXT}/resources/codex-and-agents-customizations/.codex/config.md`]:
          "body",
      },
      [WS],
    );

    // Act
    const result = pushDownCodexAndAgentsCustomizationsServiceCall({
      fs,
      extensionRoot: EXT,
      workspaceRoot: WS,
      clock: CLOCK,
    });

    // Assert
    expect(result.tool).toBe("push_down_codex_and_agents_customizations");
    expect(result.summary).toBe(
      "Pushed bundled Codex and agents customizations into the destination workspace.",
    );
    expect(result.artifacts).toEqual([
      "/workspace/artifacts/codex-and-agents-customizations/push-down-20260626T001500Z.json",
    ]);
  });

  it("threads packs, csharpVariant, and memoryMode into the Codex port", () => {
    const bundle = `${EXT}/resources/codex-and-agents-customizations`;
    const fs = buildInMemoryFileSystem(
      {
        [`${bundle}/.codex/config.toml`]: "core",
        [`${bundle}/.agents/skills/csharp/SKILL.md`]: "modern",
        [`${bundle}/.agents-variants/csharp-legacy/skills/csharp/SKILL.md`]:
          "legacy",
        [`${bundle}/pack-manifests/core.json`]: JSON.stringify({
          name: "core",
          paths: [".codex/config.toml"],
        }),
        [`${bundle}/pack-manifests/csharp-legacy.json`]: JSON.stringify({
          name: "csharp-legacy",
          paths: [".agents/skills/csharp/SKILL.md"],
        }),
      },
      [WS],
    );

    pushDownCodexAndAgentsCustomizationsServiceCall({
      fs,
      extensionRoot: EXT,
      workspaceRoot: WS,
      packs: ["csharp-legacy"],
      csharpVariant: "legacy",
      memoryMode: "skip",
      clock: CLOCK,
    });

    expect(fs.readTextFile(`${WS}/.agents/skills/csharp/SKILL.md`)).toBe(
      "legacy",
    );
    expect(fs.isFile(`${WS}/.codex/config.toml`)).toBe(true);
  });
});

describe("pushDownClaudeCustomizationsServiceCall", () => {
  it("returns the preserved tool, summary, and artifact path with no selection", () => {
    // Arrange
    const fs = buildInMemoryFileSystem(
      {
        [`${EXT}/resources/claude-customizations/.claude/rules/python.md`]:
          "rule",
      },
      [WS],
    );

    // Act
    const result = pushDownClaudeCustomizationsServiceCall({
      fs,
      extensionRoot: EXT,
      workspaceRoot: WS,
      clock: CLOCK,
    });

    // Assert
    expect(result.tool).toBe("push_down_claude_customizations");
    expect(result.summary).toBe(
      "Pushed bundled Claude Code customizations into the destination workspace.",
    );
    expect(result.artifacts).toEqual([
      "/workspace/artifacts/claude-customizations/push-down-20260626T001500Z.json",
    ]);
  });

  it("threads packs, csharpVariant, and memoryMode into the in-process port", () => {
    // Arrange: seed manifests + a legacy variant; select csharp-legacy.
    const bundle = `${EXT}/resources/claude-customizations`;
    const fs = buildInMemoryFileSystem(
      {
        [`${bundle}/.claude/rules/csharp.md`]: "# Modern\n",
        [`${bundle}/.claude-variants/csharp-legacy/rules/csharp.md`]:
          "# Legacy\n",
        [`${bundle}/pack-manifests/core.json`]: JSON.stringify({
          name: "core",
          label: "Core",
          paths: [],
        }),
        [`${bundle}/pack-manifests/csharp-legacy.json`]: JSON.stringify({
          name: "csharp-legacy",
          label: "C# Legacy",
          paths: [".claude/rules/csharp.md"],
          source_prefix: ".claude-variants/csharp-legacy",
        }),
      },
      [WS],
    );

    // Act
    pushDownClaudeCustomizationsServiceCall({
      fs,
      extensionRoot: EXT,
      workspaceRoot: WS,
      packs: ["csharp-legacy"],
      csharpVariant: "legacy",
      memoryMode: "overwrite",
      clock: CLOCK,
    });

    // Assert: the canonical destination received legacy content (variant routed)
    // and only the selected pack path was published (pack filter threaded).
    expect(fs.readTextFile(`${WS}/.claude/rules/csharp.md`)).toBe("# Legacy\n");
  });
});
