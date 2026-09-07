import { describe, expect, it, jest } from "@jest/globals";

import { handlePortableHandoffTool } from "../../src/mcp-handlers/orchestration-handoff-handlers";
import {
  VIRTUAL_WORKSPACE_ROOT,
  createMockService,
  createPreparedTransitionCase,
} from "../mcp-server-test-service";

const INDEPENDENT_CONTEXT_ARGUMENTS = {
  expected_repository_id: "github.com/drmoisan/drm-copilot",
  expected_workspace_root: VIRTUAL_WORKSPACE_ROOT,
  expected_branch: "feature/portable-handoff-614",
  expected_source_head_sha: "0".repeat(40),
  allowed_head_relationship: "equal_or_descendant",
  expected_issue_number: 614,
  expected_feature_folder: "docs/features/active/portable-handoff-614",
  expected_work_mode: "full-feature",
  expected_plan_path: "docs/features/active/portable-handoff-614/plan.md",
  expected_plan_sha256: "c".repeat(64),
} as const;

const INDEPENDENT_CONTEXT_REQUEST = {
  expectedRepositoryId: INDEPENDENT_CONTEXT_ARGUMENTS.expected_repository_id,
  expectedWorkspaceRoot: INDEPENDENT_CONTEXT_ARGUMENTS.expected_workspace_root,
  expectedBranch: INDEPENDENT_CONTEXT_ARGUMENTS.expected_branch,
  expectedSourceHeadSha: INDEPENDENT_CONTEXT_ARGUMENTS.expected_source_head_sha,
  allowedHeadRelationship:
    INDEPENDENT_CONTEXT_ARGUMENTS.allowed_head_relationship,
  expectedIssueNumber: INDEPENDENT_CONTEXT_ARGUMENTS.expected_issue_number,
  expectedFeatureFolder: INDEPENDENT_CONTEXT_ARGUMENTS.expected_feature_folder,
  expectedWorkMode: INDEPENDENT_CONTEXT_ARGUMENTS.expected_work_mode,
  expectedPlanPath: INDEPENDENT_CONTEXT_ARGUMENTS.expected_plan_path,
  expectedPlanSha256: INDEPENDENT_CONTEXT_ARGUMENTS.expected_plan_sha256,
} as const;

function createCompleteTransitionCase() {
  const fixture = createPreparedTransitionCase();
  const request = { ...fixture.request, ...INDEPENDENT_CONTEXT_REQUEST };
  return {
    ...fixture,
    arguments: { ...fixture.arguments, ...INDEPENDENT_CONTEXT_ARGUMENTS },
    request,
    referenceRequest: {
      workspaceRoot: request.workspaceRoot,
      handoffEnvelopePath: request.handoffEnvelopePath,
      expectedHandoffEnvelopeSha256: request.expectedHandoffEnvelopeSha256,
      destinationProvider: request.destinationProvider,
      ...INDEPENDENT_CONTEXT_REQUEST,
    },
  };
}

function withOverride(key: string, value: unknown): Record<string, unknown> {
  return { ...createCompleteTransitionCase().arguments, [key]: value };
}

describe("portable orchestration handoff MCP handlers", () => {
  it.each([undefined, null, []])(
    "rejects non-object input %#",
    async (input) => {
      await expect(
        handlePortableHandoffTool(
          "transition_prepared_orchestration",
          input,
          createMockService(),
        ),
      ).rejects.toThrow("Portable handoff input must be an object.");
    },
  );

  it.each([
    ["workspace_root", 1, "workspace_root must be a non-empty string."],
    ["workspace_root", " ", "workspace_root must be a non-empty string."],
    ["workspace_root", "workspace", "workspace_root must be an absolute path."],
    [
      "destination_provider",
      "other",
      "destination_provider must be 'claude' or 'codex'.",
    ],
    [
      "handoff_envelope_path",
      "artifacts\\handoff.json",
      "handoff_envelope_path must be repository-relative POSIX syntax.",
    ],
    [
      "handoff_envelope_path",
      "/artifacts/handoff.json",
      "handoff_envelope_path must be repository-relative POSIX syntax.",
    ],
    [
      "handoff_envelope_path",
      "artifacts//handoff.json",
      "handoff_envelope_path must be repository-relative POSIX syntax.",
    ],
    [
      "handoff_envelope_path",
      "artifacts/./handoff.json",
      "handoff_envelope_path must be repository-relative POSIX syntax.",
    ],
    [
      "handoff_envelope_path",
      "artifacts/../handoff.json",
      "handoff_envelope_path must be repository-relative POSIX syntax.",
    ],
    [
      "expected_handoff_envelope_sha256",
      "invalid",
      "expected_handoff_envelope_sha256 must be a lowercase SHA-256 digest.",
    ],
    [
      "source_checkpoint_path",
      "artifacts\\source.json",
      "source_checkpoint_path must be repository-relative POSIX syntax.",
    ],
    [
      "expected_source_checkpoint_sha256",
      "INVALID",
      "expected_source_checkpoint_sha256 must be a lowercase SHA-256 digest.",
    ],
    [
      "expected_repository_id",
      " ",
      "expected_repository_id must be a non-empty string.",
    ],
    [
      "expected_workspace_root",
      "workspace",
      "expected_workspace_root must be an absolute path.",
    ],
    ["expected_branch", " ", "expected_branch must be a non-empty string."],
    [
      "expected_source_head_sha",
      "invalid",
      "expected_source_head_sha must be a lowercase 40-character Git SHA.",
    ],
    [
      "allowed_head_relationship",
      "ancestor",
      "allowed_head_relationship must be 'equal' or 'equal_or_descendant'.",
    ],
    [
      "expected_issue_number",
      0,
      "expected_issue_number must be a positive integer.",
    ],
    [
      "expected_feature_folder",
      "../feature",
      "expected_feature_folder must be repository-relative POSIX syntax.",
    ],
    [
      "expected_work_mode",
      "full",
      "expected_work_mode must be 'minor-audit', 'full-feature', or 'full-bug'.",
    ],
    [
      "expected_plan_path",
      "/plan.md",
      "expected_plan_path must be repository-relative POSIX syntax.",
    ],
    [
      "expected_plan_sha256",
      "invalid",
      "expected_plan_sha256 must be a lowercase SHA-256 digest.",
    ],
    ["mode", "apply", "mode must be 'dry_run' or 'materialize'."],
  ])("rejects invalid %s input %#", async (key, value, message) => {
    await expect(
      handlePortableHandoffTool(
        "transition_prepared_orchestration",
        withOverride(key, value),
        createMockService(),
      ),
    ).rejects.toThrow(message);
  });

  it.each([
    "resolve_orchestration_topology",
    "resolve_provider_routing",
    "transition_prepared_orchestration",
  ] as const)("rejects omitted independent context for %s", async (tool) => {
    for (const key of Object.keys(INDEPENDENT_CONTEXT_ARGUMENTS)) {
      const input: Record<string, unknown> = {
        ...createCompleteTransitionCase().arguments,
      };
      delete input[key];
      await expect(
        handlePortableHandoffTool(tool, input, createMockService()),
      ).rejects.toThrow(key);
    }
  });

  it("returns deterministic unavailable results for optional service seams", async () => {
    // Arrange
    const fixture = createCompleteTransitionCase();
    const service = createMockService();
    delete service.transitionPreparedOrchestration;

    // Act
    const topology = await handlePortableHandoffTool(
      "resolve_orchestration_topology",
      fixture.arguments,
      service,
    );
    const routing = await handlePortableHandoffTool(
      "resolve_provider_routing",
      { ...fixture.arguments, destination_provider: "claude" },
      service,
    );
    const transition = await handlePortableHandoffTool(
      "transition_prepared_orchestration",
      fixture.arguments,
      service,
    );

    // Assert
    expect(topology).toMatchObject({
      status: "blocked",
      primary_failure_code: "HANDOFF_TOPOLOGY_RESOLVER_UNAVAILABLE",
    });
    expect(routing).toMatchObject({
      status: "blocked",
      primary_failure_code: "HANDOFF_PROVIDER_ROUTING_UNAVAILABLE",
    });
    expect(transition).toMatchObject({
      status: "blocked",
      source_checkpoint_sha256:
        fixture.arguments.expected_source_checkpoint_sha256,
      primary_failure_code: "HANDOFF_VALIDATOR_UNAVAILABLE",
    });
  });

  it("dispatches available topology, routing, and transition service methods", async () => {
    // Arrange
    const fixture = createCompleteTransitionCase();
    const resolution = {
      status: "validated",
      handoffId: "handoff-614",
      handoffEnvelopeSha256: fixture.arguments.expected_handoff_envelope_sha256,
      primaryFailureCode: null,
      affectedPaths: [],
      unsupportedCapabilities: [],
      resolution: { provider: "codex" },
    } as const;
    const service = Object.assign(createMockService(), {
      resolveOrchestrationTopology: jest.fn(async () => resolution),
      resolveProviderRouting: jest.fn(async () => resolution),
      transitionPreparedOrchestration: jest.fn(async () => fixture.result),
    });

    // Act
    const topology = await handlePortableHandoffTool(
      "resolve_orchestration_topology",
      fixture.arguments,
      service,
    );
    const routing = await handlePortableHandoffTool(
      "resolve_provider_routing",
      fixture.arguments,
      service,
    );
    const transition = await handlePortableHandoffTool(
      "transition_prepared_orchestration",
      fixture.arguments,
      service,
    );

    // Assert
    expect(topology).toMatchObject({ status: "validated" });
    expect(routing).toMatchObject({ status: "validated" });
    expect(transition).toMatchObject({ status: "materialized" });
    expect(service.resolveOrchestrationTopology).toHaveBeenCalledTimes(1);
    expect(service.resolveProviderRouting).toHaveBeenCalledTimes(1);
    expect(service.transitionPreparedOrchestration).toHaveBeenCalledTimes(1);
    expect(service.resolveOrchestrationTopology).toHaveBeenCalledWith(
      fixture.referenceRequest,
    );
    expect(service.resolveProviderRouting).toHaveBeenCalledWith(
      fixture.referenceRequest,
    );
    expect(service.transitionPreparedOrchestration).toHaveBeenCalledWith(
      expect.objectContaining({
        ...fixture.request,
        expectedRepositoryId:
          INDEPENDENT_CONTEXT_ARGUMENTS.expected_repository_id,
        expectedWorkspaceRoot:
          INDEPENDENT_CONTEXT_ARGUMENTS.expected_workspace_root,
        expectedBranch: INDEPENDENT_CONTEXT_ARGUMENTS.expected_branch,
        expectedSourceHeadSha:
          INDEPENDENT_CONTEXT_ARGUMENTS.expected_source_head_sha,
        allowedHeadRelationship:
          INDEPENDENT_CONTEXT_ARGUMENTS.allowed_head_relationship,
        expectedIssueNumber:
          INDEPENDENT_CONTEXT_ARGUMENTS.expected_issue_number,
        expectedFeatureFolder:
          INDEPENDENT_CONTEXT_ARGUMENTS.expected_feature_folder,
        expectedWorkMode: INDEPENDENT_CONTEXT_ARGUMENTS.expected_work_mode,
        expectedPlanPath: INDEPENDENT_CONTEXT_ARGUMENTS.expected_plan_path,
        expectedPlanSha256: INDEPENDENT_CONTEXT_ARGUMENTS.expected_plan_sha256,
      }),
    );
  });
});
