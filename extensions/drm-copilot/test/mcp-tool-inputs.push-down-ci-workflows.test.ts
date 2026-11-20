/**
 * Tests for the `ci_workflows` push-down input added by issue #1050: the MCP
 * schema property on both definition surfaces, the three resolvers, and the
 * forwarding of `ciWorkflows` through the service options to the harness.
 *
 * The forwarding case seeds a minimal in-memory CI bundle built in code; no
 * file is read from or written to disk.
 */

import { describe, expect, it } from "@jest/globals";

import { pushDownCopilotCustomizationsServiceCall } from "../src/lib/push-down/push-down-service-call";
import { REPO_AUTOMATION_TOOL_DEFINITIONS } from "../src/mcp-repo-automation-tool-definitions";
import { toolDefinitions } from "../src/mcp-tool-definitions";
import {
  resolvePushDownClaudeCustomizationsToolInput,
  resolvePushDownCodexAndAgentsCustomizationsToolInput,
  resolvePushDownCopilotCustomizationsToolInput,
} from "../src/mcp-tool-inputs";
import {
  buildPushDownClaudeCustomizationsOptions,
  buildPushDownCodexAndAgentsCustomizationsOptions,
  buildPushDownCopilotCustomizationsOptions,
} from "../src/repo-automation-service-push-down";
import {
  SEED_EXTENSION_ROOT,
  seedThreeBundles,
} from "./lib/push-down/push-down-pipeline.test-helpers";

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

/** Seed the three bundles plus a minimal CI bundle built in code. */
function seedWithCiBundle() {
  const fs = seedThreeBundles();
  const ci = `${SEED_EXTENSION_ROOT}/resources/ci-workflows`;
  fs.seedFile(
    `${ci}/caller/drm-copilot-ci.template.yml`,
    "name: CI\njobs:\n  __DRM_COPILOT_CI_JOBS__\n  ci-required-gate:\n    __DRM_COPILOT_CI_GATE_NEEDS__\n",
  );
  fs.seedFile(
    `${ci}/caller/jobs/python.yml`,
    "  python:\n    uses: __DRM_COPILOT_CI_USES__\n    __DRM_COPILOT_CI_WITH__\n",
  );
  fs.seedFile(`${ci}/ci-required-checks.json`, '{"workflow":"CI"}\n');
  fs.seedFile(`${ci}/Set-CiRequiredChecks.ps1`, "Write-Output 'x'\n");
  return fs;
}

describe("push-down ci_workflows input", () => {
  it("exposes an optional ci_workflows enum on both definition surfaces of every tool", () => {
    for (const [tool] of resolvers) {
      for (const definitions of [
        REPO_AUTOMATION_TOOL_DEFINITIONS,
        toolDefinitions,
      ]) {
        const definition = definitions.find(({ name }) => name === tool);
        const properties = (definition?.inputSchema.properties ?? {}) as Record<
          string,
          { type?: string; enum?: ReadonlyArray<string> }
        >;
        expect(properties["ci_workflows"]?.type).toBe("string");
        expect(properties["ci_workflows"]?.enum).toEqual([
          "off",
          "reference",
          "copy",
        ]);
        expect(definition?.inputSchema.required).toEqual(["workspace_root"]);
      }
    }
  });

  it.each(resolvers)(
    "accepts off, reference and copy (%s)",
    (_tool, resolve) => {
      for (const mode of ["off", "reference", "copy"] as const) {
        expect(resolve({ workspace_root: WS, ci_workflows: mode })).toEqual({
          workspaceRoot: WS,
          ciWorkflows: mode,
        });
      }
    },
  );

  it.each(resolvers)(
    "omits ciWorkflows when ci_workflows is absent (%s)",
    (_tool, resolve) => {
      const input = resolve({ workspace_root: WS });

      expect("ciWorkflows" in input).toBe(false);
    },
  );

  it.each(resolvers)(
    "rejects on with the value named (%s)",
    (_tool, resolve) => {
      expect(() => resolve({ workspace_root: WS, ci_workflows: "on" })).toThrow(
        "Field 'ci_workflows' must be one of off, reference, copy when provided; received 'on'.",
      );
    },
  );

  it("forwards ciWorkflows through the service options only when present", () => {
    for (const build of [
      buildPushDownClaudeCustomizationsOptions,
      buildPushDownCodexAndAgentsCustomizationsOptions,
      buildPushDownCopilotCustomizationsOptions,
    ]) {
      expect(build({ workspaceRoot: WS, ciWorkflows: "copy" })).toEqual({
        workspaceRoot: WS,
        ciWorkflows: "copy",
      });
      expect("ciWorkflows" in build({ workspaceRoot: WS })).toBe(false);
    }
  });

  it("forwards ciWorkflows from the service call to the harness", () => {
    const fs = seedWithCiBundle();

    const result = pushDownCopilotCustomizationsServiceCall({
      fs,
      extensionRoot: SEED_EXTENSION_ROOT,
      workspaceRoot: "/dest",
      packs: ["python"],
      dryRun: true,
      ciWorkflows: "reference",
    });
    const omitted = pushDownCopilotCustomizationsServiceCall({
      fs,
      extensionRoot: SEED_EXTENSION_ROOT,
      workspaceRoot: "/dest",
      packs: ["python"],
      dryRun: true,
    });

    const paths = (r: typeof result) =>
      (r.pushDownReport?.files ?? []).map((file) => file.path);
    expect(paths(result)).toContain(".github/workflows/drm-copilot-ci.yml");
    expect(paths(omitted)).not.toContain(
      ".github/workflows/drm-copilot-ci.yml",
    );
  });
});
