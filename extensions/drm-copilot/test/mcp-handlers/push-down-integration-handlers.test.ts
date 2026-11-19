/**
 * Tests of the push-down integration handler and its registration (issue
 * #1051, S42, S45, S47). The service is a hand-built stub; no module is mocked.
 */

import { jest } from "@jest/globals";

jest.mock("vscode", () => ({}), { virtual: true });

import { toolDefinitions } from "../../src/mcp-tool-definitions";
import { REPO_AUTOMATION_TOOL_DEFINITIONS } from "../../src/mcp-repo-automation-tool-definitions";
import {
  handlePushDownIntegrationTool,
  PUSH_DOWN_INTEGRATION_UNAVAILABLE,
} from "../../src/mcp-handlers/push-down-integration-handlers";
import {
  dispatchRepoAutomationTool,
  isRepoAutomationToolName,
} from "../../src/mcp-tools";
import type { RepoAutomationService } from "../../src/repo-automation-service-contract";
import { REPO_AUTOMATION_TOOLS } from "../../src/repo-automation-tool-names";
import type { DetectIntegrationResult } from "../../src/lib/push-down-integration/integration-detect";
import {
  VALIDATE_NOT_CHECKED,
  type ValidateIntegrationResult,
} from "../../src/lib/push-down-integration/integration-validate";
import { createMockService } from "../mcp-server-test-service";

const NAMES = [
  "detect_push_down_integration",
  "validate_push_down_integration",
] as const;

const DETECT: DetectIntegrationResult = {
  ecosystems: { harness: [], packs: [] },
  workflows: [],
  conflicts: [],
  integration_needed: { present: false, item_count: null, parse: "absent" },
};

const FAILING: ValidateIntegrationResult = {
  verdict: "fail",
  rules: [
    {
      rule: "V5-manifest-hash",
      status: "fail",
      failures: [{ path: ".push-down-manifest.json", message: "absent" }],
      destination_owned: [],
    },
  ],
  not_checked: VALIDATE_NOT_CHECKED,
};

/** A service stub with both optional methods. */
function serviceWith(
  overrides: Partial<RepoAutomationService> = {},
): RepoAutomationService {
  return {
    ...createMockService(),
    detectPushDownIntegration: () => Promise.resolve(DETECT),
    validatePushDownIntegration: () => Promise.resolve(FAILING),
    ...overrides,
  };
}

/** Names of a definition list, restricted to the two tools. */
function relativeOrder(
  list: ReadonlyArray<{ readonly name: string }>,
): string[] {
  return list
    .map((entry) => entry.name)
    .filter((name) => (NAMES as ReadonlyArray<string>).includes(name));
}

describe("push-down integration handler and registration", () => {
  it("S45 positive: both names are registered after validate_docs_artifacts and defined on both surfaces in order", () => {
    const index = REPO_AUTOMATION_TOOLS.indexOf("validate_docs_artifacts");

    expect(REPO_AUTOMATION_TOOLS.slice(index + 1, index + 3)).toEqual([
      ...NAMES,
    ]);
    expect(relativeOrder(REPO_AUTOMATION_TOOL_DEFINITIONS)).toEqual([...NAMES]);
    expect(relativeOrder(toolDefinitions)).toEqual([...NAMES]);
    expect(NAMES.every((name) => isRepoAutomationToolName(name))).toBe(true);
  });

  it("S45 negative: a surface that lacks one tool or swaps their order is detected", () => {
    const missing = REPO_AUTOMATION_TOOL_DEFINITIONS.filter(
      (entry) => entry.name !== "validate_push_down_integration",
    );
    const swapped = [...relativeOrder(toolDefinitions)]
      .reverse()
      .map((name) => ({ name }));

    expect(relativeOrder(missing)).not.toEqual([...NAMES]);
    expect(relativeOrder(swapped)).not.toEqual([...NAMES]);
    expect(isRepoAutomationToolName("detect_push_down")).toBe(false);
  });

  it.each(NAMES)(
    "S47 positive: dispatches %s and returns the integration object",
    async (name) => {
      const result = await dispatchRepoAutomationTool(
        name,
        { workspace_root: "/dest" },
        serviceWith(),
      );

      expect(result).toMatchObject({
        ok: true,
        tool: name,
        workspace_root: "/dest",
      });
      expect(result["integration"]).toEqual(
        name === "detect_push_down_integration" ? DETECT : FAILING,
      );
      expect(result.summary).not.toBe("");
    },
  );

  it("S47 negative: no other tool result gains an integration field", async () => {
    const service = serviceWith({
      renderSubagentTree: () =>
        Promise.resolve({
          tool: "render_subagent_tree",
          workspaceRoot: "/dest",
          summary: "rendered",
        }),
    });

    const result = await dispatchRepoAutomationTool(
      "render_subagent_tree",
      { workspace_root: "/dest", session_id: "s" },
      service,
    );

    expect(Object.keys(result)).not.toContain("integration");
  });

  it("S42 positive: a validate run whose verdict is fail is ok: true", async () => {
    const result = await handlePushDownIntegrationTool(
      "validate_push_down_integration",
      { workspace_root: "/dest" },
      serviceWith(),
    );

    expect(result.ok).toBe(true);
    expect(result.summary).toBe("Validation verdict: fail (V5-manifest-hash).");
  });

  it("S42 positive: a passing validate run reports the verdict without rule ids", async () => {
    const service = serviceWith({
      validatePushDownIntegration: () =>
        Promise.resolve({ ...FAILING, verdict: "pass", rules: [] }),
    });

    const result = await handlePushDownIntegrationTool(
      "validate_push_down_integration",
      { workspace_root: "/dest" },
      service,
    );

    expect(result.summary).toBe("Validation verdict: pass.");
  });

  it.each(NAMES)(
    "S42 negative: %s returns ok false with a coded error when the host lacks the method",
    async (name) => {
      const service = createMockService();

      const result = await dispatchRepoAutomationTool(
        name,
        { workspace_root: "/dest" },
        service,
      );

      expect(result.ok).toBe(false);
      expect(result.summary).toBe(
        `${PUSH_DOWN_INTEGRATION_UNAVAILABLE}: this host does not provide ${name}.`,
      );
    },
  );

  it.each([
    ["an extra property", { workspace_root: "/dest", extra: 1 }],
    ["a missing workspace_root", {}],
  ])(
    "S42 negative: %s returns ok false before the service is called",
    async (_label, input) => {
      let calls = 0;
      const service = serviceWith({
        detectPushDownIntegration: () => {
          calls += 1;
          return Promise.resolve(DETECT);
        },
      });

      const result = await dispatchRepoAutomationTool(
        "detect_push_down_integration",
        input,
        service,
      );

      expect(result.ok).toBe(false);
      expect(calls).toBe(0);
    },
  );

  it("S42 negative: a host error from the service is ok false", async () => {
    const service = serviceWith({
      validatePushDownIntegration: () =>
        Promise.reject(
          new Error("workspace_root is not a directory: /missing"),
        ),
    });

    const result = await dispatchRepoAutomationTool(
      "validate_push_down_integration",
      { workspace_root: "/missing" },
      service,
    );

    expect(result).toMatchObject({
      ok: false,
      summary: "workspace_root is not a directory: /missing",
    });
  });
});
