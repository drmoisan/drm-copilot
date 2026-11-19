import { describe, expect, it, jest } from "@jest/globals";

import {
  pushDownClaudeCustomizationsServiceCall,
  pushDownCodexAndAgentsCustomizationsServiceCall,
  pushDownCopilotCustomizationsServiceCall,
} from "../../../src/lib/push-down/push-down-service-call";
import {
  buildInMemoryFileSystem as buildBaseFileSystem,
  fixedClock,
} from "./push-down.test-helpers";
import { hashPayloadText } from "../../../src/lib/push-down/push-down-destination-manifest";
import { seedSharedLayerManifest } from "./push-down-pipeline.test-helpers";

const CLOCK = fixedClock("2026-06-26T00:15:00.000Z");
const EXT = "/ext";
const WS = "/workspace";

/**
 * Build an in-memory filesystem and seed the shared-layer manifest.
 *
 * R3 (issue #1029): every service call reaches the push-down harness, which
 * loads `shared.json` on every run, so each case seeds it here.
 *
 * @param files Files to seed.
 * @param dirs Directories to seed.
 * @returns The seeded filesystem.
 */
function buildInMemoryFileSystem(
  files: Record<string, string>,
  dirs: ReadonlyArray<string>,
): ReturnType<typeof buildBaseFileSystem> {
  const fs = buildBaseFileSystem(files, dirs);
  seedSharedLayerManifest(
    fs,
    [],
    `${EXT}/resources/codex-and-agents-customizations`,
  );
  return fs;
}

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
      packs: ["csharp"],
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

describe("pushDownClaudeCustomizationsServiceCall exclusion reporting", () => {
  const bundle = `${EXT}/resources/claude-customizations`;

  /**
   * Seed a two-rule bundle plus optional destination files.
   *
   * @param destinationFiles Files to seed under the workspace.
   * @returns The seeded in-memory filesystem.
   */
  function seedBundle(
    destinationFiles: Record<string, string> = {},
  ): ReturnType<typeof buildInMemoryFileSystem> {
    return buildInMemoryFileSystem(
      {
        [`${bundle}/.claude/rules/quality-tiers.md`]: "tiers",
        [`${bundle}/.claude/rules/python.md`]: "python",
        ...destinationFiles,
      },
      [WS],
    );
  }

  it("carries warnings with the pinned line text and invokes log once per line when a manifest produces skips, conflicts, or unmatched entries", () => {
    // Arrange: plan-corpus case unmatched-stale-entry.
    const fs = seedBundle({
      [`${WS}/.push-down-exclusions`]:
        "# Coverage model kept local; see issue #178, PR #179.\n.claude/rules/quality-tiers.md\n# Agent memory is authored here, not pushed.\n.claude/agent-memory/**\n",
      [`${WS}/.claude/rules/quality-tiers.md`]: "local",
    });
    const log = jest.fn<(message: string) => void>();
    const expectedLines = [
      "push-down exclusion conflict: destination file present, not overwritten: .claude/rules/quality-tiers.md (entry .claude/rules/quality-tiers.md, line 2)",
      "push-down exclusion: entry matched no payload path: .claude/agent-memory/** (line 4)",
    ];

    // Act
    const result = pushDownClaudeCustomizationsServiceCall({
      fs,
      extensionRoot: EXT,
      workspaceRoot: WS,
      clock: CLOCK,
      log,
    });

    // Assert
    expect(result.warnings).toEqual(expectedLines);
    expect(log.mock.calls).toEqual(expectedLines.map((line) => [line]));
    expect(fs.readTextFile(`${WS}/.claude/rules/quality-tiers.md`)).toBe(
      "local",
    );
  });

  it("omits warnings and never invokes log when the manifest produces nothing to report", () => {
    // Arrange
    const fs = seedBundle({ [`${WS}/.push-down-exclusions`]: "# nothing\n" });
    const log = jest.fn<(message: string) => void>();

    // Act
    const result = pushDownClaudeCustomizationsServiceCall({
      fs,
      extensionRoot: EXT,
      workspaceRoot: WS,
      clock: CLOCK,
      log,
    });

    // Assert
    expect("warnings" in result).toBe(false);
    expect(log).not.toHaveBeenCalled();
  });

  it("omits warnings and never invokes log without a manifest", () => {
    // Arrange
    const fs = seedBundle();
    const log = jest.fn<(message: string) => void>();

    // Act
    const result = pushDownClaudeCustomizationsServiceCall({
      fs,
      extensionRoot: EXT,
      workspaceRoot: WS,
      clock: CLOCK,
      log,
    });

    // Assert
    expect("warnings" in result).toBe(false);
    expect(log).not.toHaveBeenCalled();
    expect(fs.isFile(`${WS}/.claude/rules/python.md`)).toBe(true);
  });
});

describe("push-down service calls over the unified harness (issue #1029)", () => {
  const codexBundle = `${EXT}/resources/codex-and-agents-customizations`;

  /** Seed one file per ecosystem plus a shared skill and AGENTS.md. */
  function seedAll(): ReturnType<typeof buildBaseFileSystem> {
    const fs = buildBaseFileSystem(
      {
        [`${codexBundle}/AGENTS.md`]: "agents\n",
        [`${codexBundle}/.agents/skills/shared/SKILL.md`]: "shared\n",
        [`${codexBundle}/.codex/agents/a.toml`]: "a\n",
        [`${EXT}/resources/claude-customizations/.claude/agents/a.md`]: "a\n",
        [`${EXT}/resources/customizations/.github/agents/a.agent.md`]: "a\n",
        [`${EXT}/resources/customizations/.github/agents/python-x.agent.md`]:
          "p\n",
        [`${EXT}/resources/customizations/pack-manifests/core.json`]:
          JSON.stringify({
            name: "core",
            label: "Core",
            paths: [".github/agents/a.agent.md"],
          }),
        [`${EXT}/resources/customizations/pack-manifests/python.json`]:
          JSON.stringify({
            name: "python",
            label: "Python",
            paths: [".github/agents/python-x.agent.md"],
          }),
      },
      [WS],
    );
    seedSharedLayerManifest(
      fs,
      ["AGENTS.md", ".agents/skills/shared/SKILL.md"],
      codexBundle,
    );
    return fs;
  }

  const calls = [
    ["copilot", pushDownCopilotCustomizationsServiceCall],
    ["codex", pushDownCodexAndAgentsCustomizationsServiceCall],
    ["claude", pushDownClaudeCustomizationsServiceCall],
  ] as const;

  it.each(calls)(
    "delegates to the harness with exactly its own ecosystem (%s)",
    (ecosystem, call) => {
      const result = call({
        fs: seedAll(),
        extensionRoot: EXT,
        workspaceRoot: WS,
        clock: CLOCK,
      });

      const report = result.pushDownReport;
      expect(Object.keys(report?.ecosystems ?? {})).toEqual([ecosystem]);
      expect(
        report?.files.every(
          (file) => file.layer === "shared" || file.layer === ecosystem,
        ),
      ).toBe(true);
      expect(report?.files.some((file) => file.layer === "shared")).toBe(true);
      expect(report?.mode).toBe("apply");
    },
  );

  it.each(calls)(
    "dry run returns mode dry-run and no artifact (%s)",
    (_ecosystem, call) => {
      const fs = seedAll();

      const result = call({
        fs,
        extensionRoot: EXT,
        workspaceRoot: WS,
        clock: CLOCK,
        dryRun: true,
      });

      expect(result.pushDownReport?.mode).toBe("dry-run");
      expect(result.artifacts).toEqual([]);
      expect(result.summary).toMatch(
        /^Dry run: planned bundled .+ customizations; no file was written\.$/,
      );
      expect(fs.writtenPaths).toEqual([]);
    },
  );

  it("passes the Copilot packs selection to the harness", () => {
    const fs = seedAll();

    const result = pushDownCopilotCustomizationsServiceCall({
      fs,
      extensionRoot: EXT,
      workspaceRoot: WS,
      clock: CLOCK,
      packs: ["python"],
    });

    expect(result.pushDownReport?.ecosystems["copilot"]).toEqual({
      packs: ["core", "python"],
    });
    expect(fs.isFile(`${WS}/.github/agents/python-x.agent.md`)).toBe(true);
  });

  it("routes conflict, unmanaged-conflict and deleted-locally lines to warnings and log", () => {
    // Arrange: AGENTS.md edited locally (conflict), the shared skill removed
    // locally (deleted-locally), and an unmanaged differing Codex agent.
    const fs = seedAll();
    fs.seedFile(`${WS}/AGENTS.md`, "local edit\n");
    fs.seedFile(`${WS}/.codex/agents/a.toml`, "theirs\n");
    fs.seedFile(
      `${WS}/.push-down-manifest.json`,
      JSON.stringify({
        schema_version: "1.0.0",
        payload_version: "1.0.0",
        selection: {},
        files: {
          "AGENTS.md": {
            layer: "shared",
            pack: "core",
            sha256: hashPayloadText("agents\n"),
          },
          ".agents/skills/shared/SKILL.md": {
            layer: "shared",
            pack: "core",
            sha256: hashPayloadText("shared\n"),
          },
        },
      }),
    );
    const log = jest.fn<(message: string) => void>();

    // Act
    const result = pushDownCodexAndAgentsCustomizationsServiceCall({
      fs,
      extensionRoot: EXT,
      workspaceRoot: WS,
      clock: CLOCK,
      log,
    });

    // Assert: one line per action, in path order, each also sent to the log.
    expect(
      (result.warnings ?? []).map((line) =>
        line.split(" ").slice(0, 4).join(" "),
      ),
    ).toEqual([
      "push-down conflict: deleted-locally .agents/skills/shared/SKILL.md",
      "push-down conflict: unmanaged-conflict .codex/agents/a.toml",
      "push-down conflict: conflict AGENTS.md",
    ]);
    expect(log.mock.calls.map(([line]) => line)).toEqual(result.warnings);
    expect(fs.readTextFile(`${WS}/AGENTS.md`)).toBe("local edit\n");
    expect(fs.readTextFile(`${WS}/.codex/agents/a.toml`)).toBe("theirs\n");
  });
});
