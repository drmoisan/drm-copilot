/**
 * Wrapper-compatibility tests for the three push-down MCP tools (issue #1029).
 *
 * A real service from `createRepoAutomationService` runs over a fresh
 * in-memory filesystem with seeded bundles and `shared.json`; no module is
 * mocked apart from the virtual `vscode` host module.
 */

import { describe, expect, it, jest } from "@jest/globals";

jest.mock("vscode", () => ({}), { virtual: true });

import { REPO_AUTOMATION_TOOL_DEFINITIONS } from "../src/mcp-repo-automation-tool-definitions";
import { toolDefinitions } from "../src/mcp-tool-definitions";
import { dispatchRepoAutomationTool } from "../src/mcp-tools";
import { createRepoAutomationService } from "../src/repo-automation-service";
import { type RepoAutomationToolName } from "../src/repo-automation-tool-names";
import { type InMemoryPushDownFileSystem } from "./lib/push-down/push-down.test-helpers";
import {
  SEED_EXTENSION_ROOT,
  seedThreeBundles,
  snapshotTree,
} from "./lib/push-down/push-down-pipeline.test-helpers";

const DEST = "/dest";

/** Seed the three bundles plus a one-file Copilot powershell pack. */
function seed(): InMemoryPushDownFileSystem {
  const fs = seedThreeBundles();
  const copilot = `${SEED_EXTENSION_ROOT}/resources/customizations`;
  fs.seedFile(`${copilot}/.github/agents/powershell-x.agent.md`, "ps\n");
  fs.seedFile(
    `${copilot}/pack-manifests/powershell.json`,
    JSON.stringify({
      name: "powershell",
      label: "PowerShell",
      paths: [".github/agents/powershell-x.agent.md"],
    }),
  );
  return fs;
}

/** Dispatch one push-down tool against a real service over `fs`. */
async function dispatch(
  fs: InMemoryPushDownFileSystem,
  tool: RepoAutomationToolName,
  args: Record<string, unknown>,
) {
  const service = createRepoAutomationService({
    extensionRoot: SEED_EXTENSION_ROOT,
    output: { appendLine: () => undefined },
    pushDownFileSystem: fs,
  });
  return dispatchRepoAutomationTool(
    tool,
    { workspace_root: DEST, ...args },
    service,
  );
}

/** Each tool with a payload path its own layer publishes. */
const TOOLS: ReadonlyArray<readonly [RepoAutomationToolName, string]> = [
  ["push_down_claude_customizations", ".claude/agents/a.md"],
  ["push_down_codex_and_agents_customizations", ".codex/agents/a.toml"],
  ["push_down_copilot_customizations", ".github/agents/a.agent.md"],
];

describe("push-down wrapper compatibility", () => {
  it.each(TOOLS)(
    "keeps the pre-change result keys for a workspace_root-only call (%s)",
    async (tool) => {
      const result = await dispatch(seed(), tool, {});

      expect(Object.keys(result).sort()).toEqual([
        "artifacts",
        "ok",
        "push_down_report",
        "summary",
        "tool",
        "workspace_root",
      ]);
      expect(result.ok).toBe(true);
      expect(result.tool).toBe(tool);
      expect(result.artifacts).toHaveLength(1);
      expect(result.summary.startsWith("Pushed bundled ")).toBe(true);
    },
  );

  it.each(TOOLS)(
    "returns no artifact path and mode dry-run for a dry_run call (%s)",
    async (tool) => {
      const fs = seed();
      const before = snapshotTree(fs, DEST);

      const result = await dispatch(fs, tool, { dry_run: true });

      expect(result.artifacts).toEqual([]);
      expect(result.push_down_report?.mode).toBe("dry-run");
      expect(snapshotTree(fs, DEST)).toEqual(before);
    },
  );

  it.each(TOOLS)(
    "forwards overwrite_unmanaged to the harness (%s)",
    async (tool, payloadPath) => {
      const declined = seed();
      declined.seedFile(`${DEST}/${payloadPath}`, "theirs\n");
      const opted = seed();
      opted.seedFile(`${DEST}/${payloadPath}`, "theirs\n");
      const payload = declined.readTextFile(
        `${SEED_EXTENSION_ROOT}/resources/${
          tool === "push_down_claude_customizations"
            ? "claude-customizations"
            : tool === "push_down_codex_and_agents_customizations"
              ? "codex-and-agents-customizations"
              : "customizations"
        }/${payloadPath}`,
      );

      const kept = await dispatch(declined, tool, {});
      await dispatch(opted, tool, { overwrite_unmanaged: true });

      expect(declined.readTextFile(`${DEST}/${payloadPath}`)).toBe("theirs\n");
      expect(
        kept.push_down_report?.files.find((file) => file.path === payloadPath)
          ?.action,
      ).toBe("unmanaged-conflict");
      expect(opted.readTextFile(`${DEST}/${payloadPath}`)).toBe(payload);
    },
  );

  it("forwards Copilot packs to the harness", async () => {
    const result = await dispatch(seed(), "push_down_copilot_customizations", {
      packs: ["python"],
    });

    expect(result.push_down_report?.ecosystems["copilot"]?.packs).toEqual([
      "core",
      "python",
    ]);
    expect(
      result.push_down_report?.files.some((file) =>
        file.path.includes("powershell-x"),
      ),
    ).toBe(false);
  });

  it("keeps tool names and existing schema properties", () => {
    const workspaceRoot = {
      type: "string",
      description:
        "Required absolute path to the root of the target checkout or worktree. The MCP server cannot infer the calling agent's checkout, so this value must be supplied explicitly.",
    };
    const selection = (
      memoryDescription: string,
      packsDescription: string,
      variantDescription: string,
    ) => ({
      packs: {
        type: "array",
        items: { type: "string" },
        description: packsDescription,
      },
      csharp_variant: {
        type: "string",
        enum: ["modern", "legacy"],
        description: variantDescription,
      },
      memory_mode: {
        type: "string",
        enum: ["overwrite", "merge", "skip"],
        description: memoryDescription,
      },
    });
    const frozen = [
      {
        name: "push_down_copilot_customizations",
        description:
          "Copy the bundled Copilot customization payload into the target workspace.",
        inputSchema: {
          type: "object",
          properties: { workspace_root: workspaceRoot },
          required: ["workspace_root"],
          additionalProperties: false,
        },
      },
      {
        name: "push_down_codex_and_agents_customizations",
        description:
          "Copy the bundled Codex and agents customization payload into the target workspace.",
        inputSchema: {
          type: "object",
          properties: {
            workspace_root: workspaceRoot,
            ...selection(
              "Optional inert Codex memory parity field: 'overwrite' (default), 'merge', or 'skip'.",
              "Optional Codex language pack names to publish. When omitted, the full tree is published. 'core' is always included.",
              "Optional Codex C# toolchain variant to source ('modern' default or 'legacy').",
            ),
          },
          required: ["workspace_root"],
          additionalProperties: false,
        },
      },
      {
        name: "push_down_claude_customizations",
        description:
          "Copy the bundled Claude Code customization payload into the target workspace.",
        inputSchema: {
          type: "object",
          properties: {
            workspace_root: workspaceRoot,
            ...selection(
              "Optional agent-memory handling mode: 'overwrite' (default), 'merge', or 'skip'.",
              "Optional language pack names to publish (for example 'core', 'typescript'). When omitted, the full tree is published. 'core' is always included.",
              "Optional C# toolchain variant to source ('modern' default or 'legacy').",
            ),
          },
          required: ["workspace_root"],
          additionalProperties: false,
        },
      },
    ];
    // Optional inputs added after the frozen schemas: #1029 run options and
    // the #1050 `ci_workflows` mode (rule K of the #1050 plan).
    const added = new Set(["dry_run", "overwrite_unmanaged", "ci_workflows"]);

    for (const definitions of [
      REPO_AUTOMATION_TOOL_DEFINITIONS,
      toolDefinitions,
    ]) {
      const current = definitions
        .filter((definition) => definition.name.startsWith("push_down_"))
        .map((definition) => {
          const properties = Object.fromEntries(
            Object.entries(definition.inputSchema.properties).filter(
              ([key]) =>
                !added.has(key) &&
                !(
                  definition.name === "push_down_copilot_customizations" &&
                  key === "packs"
                ),
            ),
          );
          return JSON.parse(
            JSON.stringify({
              ...definition,
              inputSchema: { ...definition.inputSchema, properties },
            }),
          ) as unknown;
        });

      expect(current).toEqual(frozen);
    }
  });
});
