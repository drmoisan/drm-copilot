/**
 * Tests for the push-down planning inputs added by issue #1029: `dry_run` and
 * `overwrite_unmanaged` on all three push-down tools, and Copilot `packs`.
 */

import { describe, expect, it } from "@jest/globals";

import { REPO_AUTOMATION_TOOL_DEFINITIONS } from "../src/mcp-repo-automation-tool-definitions";
import { toolDefinitions } from "../src/mcp-tool-definitions";
import {
  resolvePushDownClaudeCustomizationsToolInput,
  resolvePushDownCodexAndAgentsCustomizationsToolInput,
  resolvePushDownCopilotCustomizationsToolInput,
  resolveRunCodexNativeConverterToolInput,
} from "../src/mcp-tool-inputs";

const WS = "/workspace";

const resolvers = [
  [
    "push_down_claude_customizations",
    resolvePushDownClaudeCustomizationsToolInput,
  ],
  [
    "push_down_codex_and_agents_customizations",
    resolvePushDownCodexAndAgentsCustomizationsToolInput,
  ],
  [
    "push_down_copilot_customizations",
    resolvePushDownCopilotCustomizationsToolInput,
  ],
] as const;

describe("push-down planning inputs", () => {
  it.each(resolvers)(
    "parses dry_run and overwrite_unmanaged (%s)",
    (_tool, resolve) => {
      const input = resolve({
        workspace_root: WS,
        dry_run: true,
        overwrite_unmanaged: false,
      });

      expect(input).toMatchObject({ dryRun: true, overwriteUnmanaged: false });
    },
  );

  it.each(resolvers)(
    "omits both fields when they are absent (%s)",
    (_tool, resolve) => {
      const input = resolve({ workspace_root: WS });

      expect("dryRun" in input).toBe(false);
      expect("overwriteUnmanaged" in input).toBe(false);
    },
  );

  it.each(resolvers)("rejects a non-boolean dry_run (%s)", (_tool, resolve) => {
    expect(() => resolve({ workspace_root: WS, dry_run: "yes" })).toThrow(
      "Field 'dry_run' must be a boolean when provided.",
    );
  });

  it.each(resolvers)(
    "rejects a non-boolean overwrite_unmanaged (%s)",
    (_tool, resolve) => {
      expect(() =>
        resolve({ workspace_root: WS, overwrite_unmanaged: 1 }),
      ).toThrow("Field 'overwrite_unmanaged' must be a boolean when provided.");
    },
  );

  it("parses Copilot packs and omits them when absent", () => {
    expect(
      resolvePushDownCopilotCustomizationsToolInput({
        workspace_root: WS,
        packs: ["python", "csharp"],
      }),
    ).toEqual({ workspaceRoot: WS, packs: ["python", "csharp"] });
    expect(
      resolvePushDownCopilotCustomizationsToolInput({ workspace_root: WS }),
    ).toEqual({
      workspaceRoot: WS,
    });
  });

  it("rejects Copilot packs that are not an array", () => {
    expect(() =>
      resolvePushDownCopilotCustomizationsToolInput({
        workspace_root: WS,
        packs: "python",
      }),
    ).toThrow("Field 'packs' must be an array of strings when provided.");
  });

  // Issue #1029 moved the Copilot resolver (fully covered) out of
  // mcp-tool-inputs.ts; these two converter-input checks keep that file's
  // line coverage at or above its Phase 0 baseline.
  it("rejects a converter mode other than review or apply", () => {
    expect(() =>
      resolveRunCodexNativeConverterToolInput({
        workspace_root: WS,
        mode: "plan",
        source_ecosystem: "claude",
        source_root: WS,
      }),
    ).toThrow("Field 'mode' must be 'review' or 'apply'.");
  });

  it("rejects a converter source ecosystem other than github-copilot or claude", () => {
    expect(() =>
      resolveRunCodexNativeConverterToolInput({
        workspace_root: WS,
        mode: "review",
        source_ecosystem: "vim",
        source_root: WS,
      }),
    ).toThrow("Field 'source_ecosystem' must be 'github-copilot' or 'claude'.");
  });

  it("adds optional dry_run and overwrite_unmanaged to all three tool schemas", () => {
    for (const [tool] of resolvers) {
      for (const definitions of [
        REPO_AUTOMATION_TOOL_DEFINITIONS,
        toolDefinitions,
      ]) {
        const definition = definitions.find(({ name }) => name === tool);
        const properties = (definition?.inputSchema.properties ?? {}) as Record<
          string,
          { type?: string }
        >;
        expect(properties["dry_run"]?.type).toBe("boolean");
        expect(properties["overwrite_unmanaged"]?.type).toBe("boolean");
        expect(definition?.inputSchema.required).toEqual(["workspace_root"]);
      }
    }
  });
});
