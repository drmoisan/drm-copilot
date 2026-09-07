import {
  afterEach,
  beforeEach,
  describe,
  expect,
  it,
  jest,
} from "@jest/globals";
import { Client } from "@modelcontextprotocol/sdk/client/index.js";
import { InMemoryTransport } from "@modelcontextprotocol/sdk/inMemory.js";

// Spy on terminal creation so the MCP dispatch path can be asserted to never
// create a terminal (it uses the buffered in-memory sink). The `mock` prefix is
// required for jest.mock factory references.
const mockCreateTerminal = jest.fn();
jest.mock(
  "vscode",
  () => ({ window: { createTerminal: mockCreateTerminal } }),
  { virtual: true },
);

import { createRepoAutomationMcpServer } from "../src/mcp-server";
import { DEFAULT_HARD_LOCK_PROMPT_OUTPUT_PATH } from "../src/mcp-tools";
import type { RepoAutomationService } from "../src/repo-automation-service";
import {
  PUSH_DOWN_CODEX_ARTIFACT_PATH,
  VIRTUAL_WORKSPACE_ROOT,
  createMockService,
  createPreparedTransitionCase,
  workspacePath,
} from "./mcp-server-test-service";

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

describe("repo automation MCP server", () => {
  let client: Client;
  let service: jest.Mocked<RepoAutomationService>;
  let server: ReturnType<typeof createRepoAutomationMcpServer>;

  beforeEach(async () => {
    service = createMockService();
    server = createRepoAutomationMcpServer({
      createService: () => service,
    });
    client = new Client(
      {
        name: "test-client",
        version: "1.0.0",
      },
      {
        capabilities: {},
      },
    );
    const [clientTransport, serverTransport] =
      InMemoryTransport.createLinkedPair();
    await server.connect(serverTransport);
    await client.connect(clientTransport);
  });

  afterEach(async () => {
    await client.close();
    await server.close();
    jest.clearAllMocks();
  });

  it("registers the semantic repo automation tools", async () => {
    const result = await client.listTools();

    expect(result.tools.map((tool) => tool.name)).toEqual([
      "collect_commit_context",
      "collect_pr_context",
      "run_codex_native_converter",
      "push_down_copilot_customizations",
      "push_down_codex_and_agents_customizations",
      "push_down_claude_customizations",
      "new_potential_bug_entry",
      "new_potential_entry",
      "link_parent_child",
      "potential_to_issue",
      "new_active_feature_folder",
      "run_poshqc_format",
      "run_poshqc_analyze",
      "run_poshqc_test",
      "run_poshqc_analyze_autofix",
      "run_poshqc_suite",
      "resolve_policy_audit_template_asset",
      "resolve_execute_hard_lock_prompt",
      "resolve_atomic_plan_prompt",
      "validate_orchestration_artifacts",
      "resolve_orchestration_topology",
      "resolve_provider_routing",
      "transition_prepared_orchestration",
      "render_subagent_tree",
      "validate_discovery_artifacts",
      "run_discovery_init",
      "run_discovery_repo_inventory",
      "run_discovery_dotnet_analyzer",
      "run_discovery_vsto_analyzer",
      "run_discovery_scenario_generation",
      "run_discovery_report",
    ]);
  });

  it("dispatches collect_pr_context through the shared service with an explicit base", async () => {
    service.collectPrContext.mockResolvedValue({
      tool: "collect_pr_context",
      workspaceRoot: VIRTUAL_WORKSPACE_ROOT,
      artifacts: [
        workspacePath("artifacts/pr_context.summary.txt"),
        workspacePath("artifacts/pr_context.appendix.txt"),
      ],
      summary: "Collected PR context against base 'origin/main'.",
    });

    const result = await client.callTool({
      name: "collect_pr_context",
      arguments: {
        workspace_root: VIRTUAL_WORKSPACE_ROOT,
        base: "origin/main",
      },
    });

    expect(service.collectPrContext).toHaveBeenCalledWith({
      workspaceRoot: VIRTUAL_WORKSPACE_ROOT,
      base: "origin/main",
    });
    expect(result.isError).toBe(false);
    expect(result.structuredContent).toMatchObject({
      ok: true,
      tool: "collect_pr_context",
      workspace_root: VIRTUAL_WORKSPACE_ROOT,
      artifacts: [
        workspacePath("artifacts/pr_context.summary.txt"),
        workspacePath("artifacts/pr_context.appendix.txt"),
      ],
    });
  });

  it("returns validation failures without calling the shared service", async () => {
    const result = await client.callTool({
      name: "collect_pr_context",
      arguments: {
        workspace_root: VIRTUAL_WORKSPACE_ROOT,
      },
    });

    expect(service.collectPrContext).not.toHaveBeenCalled();
    expect(result.isError).toBe(true);
    expect(result.structuredContent).toMatchObject({
      ok: false,
      tool: "collect_pr_context",
      workspace_root: VIRTUAL_WORKSPACE_ROOT,
      summary: "Field 'base' must be a string.",
    });
  });

  it("fails closed with a structured error when workspace_root is omitted", async () => {
    const result = await client.callTool({
      name: "collect_commit_context",
      arguments: {},
    });

    // The service handler is never invoked because the resolver fails closed
    // rather than silently defaulting to the server's process.cwd().
    expect(service.collectCommitContext).not.toHaveBeenCalled();
    expect(result.isError).toBe(true);
    expect(result.structuredContent).toMatchObject({
      ok: false,
      tool: "collect_commit_context",
    });
    expect((result.structuredContent as { summary: string }).summary).toContain(
      "workspace_root is required",
    );
  });

  it("dispatches push_down_codex_and_agents_customizations through the shared service", async () => {
    service.pushDownCodexAndAgentsCustomizations.mockResolvedValue({
      tool: "push_down_codex_and_agents_customizations",
      workspaceRoot: VIRTUAL_WORKSPACE_ROOT,
      artifacts: [PUSH_DOWN_CODEX_ARTIFACT_PATH],
      summary:
        "Pushed bundled Codex and agents customizations into the destination workspace.",
    });

    const result = await client.callTool({
      name: "push_down_codex_and_agents_customizations",
      arguments: {
        workspace_root: VIRTUAL_WORKSPACE_ROOT,
      },
    });

    expect(service.pushDownCodexAndAgentsCustomizations).toHaveBeenCalledWith({
      workspaceRoot: VIRTUAL_WORKSPACE_ROOT,
    });
    expect(result.isError).toBe(false);
    expect(result.structuredContent).toMatchObject({
      ok: true,
      tool: "push_down_codex_and_agents_customizations",
      workspace_root: VIRTUAL_WORKSPACE_ROOT,
      artifacts: [PUSH_DOWN_CODEX_ARTIFACT_PATH],
    });
  });

  it("dispatches link_parent_child through the shared service with explicit issue numbers", async () => {
    service.linkParentChild.mockResolvedValue({
      tool: "link_parent_child",
      workspaceRoot: VIRTUAL_WORKSPACE_ROOT,
      summary:
        "Linked child issue #12 to parent issue #34 using the bundled workflow.",
    });

    const result = await client.callTool({
      name: "link_parent_child",
      arguments: {
        workspace_root: VIRTUAL_WORKSPACE_ROOT,
        child_issue_number: "12",
        parent_issue_number: "34",
      },
    });

    expect(service.linkParentChild).toHaveBeenCalledWith({
      workspaceRoot: VIRTUAL_WORKSPACE_ROOT,
      childIssueNumber: "12",
      parentIssueNumber: "34",
    });
    expect(result.isError).toBe(false);
    expect(result.structuredContent).toMatchObject({
      ok: true,
      tool: "link_parent_child",
      workspace_root: VIRTUAL_WORKSPACE_ROOT,
    });
  });

  it("dispatches run_poshqc_suite through resolveRunPoshQCSuiteToolInput and forwards repeated scan_folders values to the repo-automation service", async () => {
    service.runPoshQCSuite.mockResolvedValue({
      tool: "run_poshqc_suite",
      workspaceRoot: VIRTUAL_WORKSPACE_ROOT,
      summary: `Ran the bundled PoshQC suite against '${VIRTUAL_WORKSPACE_ROOT}' with 2 selected scan folder(s).`,
    });

    const result = await client.callTool({
      name: "run_poshqc_suite",
      arguments: {
        workspace_root: VIRTUAL_WORKSPACE_ROOT,
        scan_folders: [workspacePath("src"), workspacePath("tests/powershell")],
      },
    });

    expect(service.runPoshQCSuite).toHaveBeenCalledWith({
      workspaceRoot: VIRTUAL_WORKSPACE_ROOT,
      scanFolders: [workspacePath("src"), workspacePath("tests/powershell")],
    });
    expect(result.isError).toBe(false);
    expect(result.structuredContent).toMatchObject({
      ok: true,
      tool: "run_poshqc_suite",
      workspace_root: VIRTUAL_WORKSPACE_ROOT,
    });
  });

  it("dispatches run_poshqc_format through the shared service with scan folders", async () => {
    service.runPoshQCFormat.mockResolvedValue({
      tool: "run_poshqc_format",
      workspaceRoot: VIRTUAL_WORKSPACE_ROOT,
      summary: `Ran bundled PoshQC format against '${VIRTUAL_WORKSPACE_ROOT}' with 1 selected scan folder(s).`,
    });

    const result = await client.callTool({
      name: "run_poshqc_format",
      arguments: {
        workspace_root: VIRTUAL_WORKSPACE_ROOT,
        scan_folders: [workspacePath("src")],
      },
    });

    expect(service.runPoshQCFormat).toHaveBeenCalledWith({
      workspaceRoot: VIRTUAL_WORKSPACE_ROOT,
      scanFolders: [workspacePath("src")],
    });
    expect(result.isError).toBe(false);
    expect(result.structuredContent).toMatchObject({
      ok: true,
      tool: "run_poshqc_format",
      workspace_root: VIRTUAL_WORKSPACE_ROOT,
    });
  });

  it("dispatches run_poshqc_analyze through the shared service with scan folders", async () => {
    service.runPoshQCAnalyze.mockResolvedValue({
      tool: "run_poshqc_analyze",
      workspaceRoot: VIRTUAL_WORKSPACE_ROOT,
      summary: `Ran bundled PoshQC analyze against '${VIRTUAL_WORKSPACE_ROOT}' with 1 selected scan folder(s).`,
    });

    const result = await client.callTool({
      name: "run_poshqc_analyze",
      arguments: {
        workspace_root: VIRTUAL_WORKSPACE_ROOT,
        scan_folders: [workspacePath("src")],
      },
    });

    expect(service.runPoshQCAnalyze).toHaveBeenCalledWith({
      workspaceRoot: VIRTUAL_WORKSPACE_ROOT,
      scanFolders: [workspacePath("src")],
    });
    expect(result.isError).toBe(false);
    expect(result.structuredContent).toMatchObject({
      ok: true,
      tool: "run_poshqc_analyze",
      workspace_root: VIRTUAL_WORKSPACE_ROOT,
    });
  });

  it("dispatches run_poshqc_test through the shared service with scan folders", async () => {
    service.runPoshQCTest.mockResolvedValue({
      tool: "run_poshqc_test",
      workspaceRoot: VIRTUAL_WORKSPACE_ROOT,
      summary: `Ran bundled PoshQC test against '${VIRTUAL_WORKSPACE_ROOT}' with 1 selected scan folder(s).`,
    });

    const result = await client.callTool({
      name: "run_poshqc_test",
      arguments: {
        workspace_root: VIRTUAL_WORKSPACE_ROOT,
        scan_folders: [workspacePath("tests/powershell")],
      },
    });

    expect(service.runPoshQCTest).toHaveBeenCalledWith({
      workspaceRoot: VIRTUAL_WORKSPACE_ROOT,
      scanFolders: [workspacePath("tests/powershell")],
    });
    expect(result.isError).toBe(false);
    expect(result.structuredContent).toMatchObject({
      ok: true,
      tool: "run_poshqc_test",
      workspace_root: VIRTUAL_WORKSPACE_ROOT,
    });
  });

  it("creates no terminal on the MCP run_poshqc_test path (buffered sink only)", async () => {
    // Arrange
    service.runPoshQCTest.mockResolvedValue({
      tool: "run_poshqc_test",
      workspaceRoot: VIRTUAL_WORKSPACE_ROOT,
      summary: `Ran bundled PoshQC test against '${VIRTUAL_WORKSPACE_ROOT}'.`,
    });

    // Act
    await client.callTool({
      name: "run_poshqc_test",
      arguments: { workspace_root: VIRTUAL_WORKSPACE_ROOT },
    });

    // Assert: the MCP dispatch path never creates an integrated terminal.
    expect(mockCreateTerminal).not.toHaveBeenCalled();
    expect(service.runPoshQCTest).toHaveBeenCalledTimes(1);
  });

  it("dispatches run_poshqc_analyze_autofix through the shared service with scan folders", async () => {
    service.runPoshQCAnalyzeAutofix.mockResolvedValue({
      tool: "run_poshqc_analyze_autofix",
      workspaceRoot: VIRTUAL_WORKSPACE_ROOT,
      summary: `Ran bundled PoshQC analyze autofix against '${VIRTUAL_WORKSPACE_ROOT}' with 1 selected scan folder(s).`,
    });

    const result = await client.callTool({
      name: "run_poshqc_analyze_autofix",
      arguments: {
        workspace_root: VIRTUAL_WORKSPACE_ROOT,
        scan_folders: [workspacePath("src")],
      },
    });

    expect(service.runPoshQCAnalyzeAutofix).toHaveBeenCalledWith({
      workspaceRoot: VIRTUAL_WORKSPACE_ROOT,
      scanFolders: [workspacePath("src")],
    });
    expect(result.isError).toBe(false);
    expect(result.structuredContent).toMatchObject({
      ok: true,
      tool: "run_poshqc_analyze_autofix",
      workspace_root: VIRTUAL_WORKSPACE_ROOT,
    });
  });

  it("dispatches resolve_policy_audit_template_asset through the shared service with normalized inputs", async () => {
    service.resolvePolicyAuditTemplateAsset.mockResolvedValue({
      tool: "resolve_policy_audit_template_asset",
      workspaceRoot: VIRTUAL_WORKSPACE_ROOT,
      summary: "Resolved bundled policy-audit asset 'feature-audit-template'.",
      artifacts: [
        "C:/extension/resources/templates/policy_audit/feature-audit.yyyy-MM-ddTHH-mm.md",
      ],
      assetId: "policy_audit.feature_audit_template",
      bundledSourcePath:
        "C:/extension/resources/templates/policy_audit/feature-audit.yyyy-MM-ddTHH-mm.md",
    });

    const result = await client.callTool({
      name: "resolve_policy_audit_template_asset",
      arguments: {
        workspace_root: VIRTUAL_WORKSPACE_ROOT,
        asset: "feature-audit-template",
        target_path: "docs/policy-audit/feature-audit.md",
      },
    });

    expect(service.resolvePolicyAuditTemplateAsset).toHaveBeenCalledWith({
      workspaceRoot: VIRTUAL_WORKSPACE_ROOT,
      asset: "feature-audit-template",
      targetPath: workspacePath("docs/policy-audit/feature-audit.md"),
    });
    expect(result.isError).toBe(false);
    expect(result.structuredContent).toMatchObject({
      ok: true,
      tool: "resolve_policy_audit_template_asset",
      workspace_root: VIRTUAL_WORKSPACE_ROOT,
      asset_id: "policy_audit.feature_audit_template",
      bundled_source_path:
        "C:/extension/resources/templates/policy_audit/feature-audit.yyyy-MM-ddTHH-mm.md",
    });
  });

  it("dispatches a portable prepared-orchestration transition", async () => {
    const fixture = createPreparedTransitionCase();
    service.transitionPreparedOrchestration?.mockResolvedValue(fixture.result);

    const result = await client.callTool({
      name: "transition_prepared_orchestration",
      arguments: { ...fixture.arguments, ...INDEPENDENT_CONTEXT_ARGUMENTS },
    });

    expect(service.transitionPreparedOrchestration).toHaveBeenCalledWith(
      expect.objectContaining(fixture.request),
    );
    expect(result.isError).toBe(false);
    expect(result.structuredContent).toMatchObject(fixture.expectedMcpResult);
  });

  it("dispatches resolve_execute_hard_lock_prompt through the shared service with injected output and quiet defaults, and surfaces artifacts", async () => {
    service.resolveExecuteHardLockPrompt.mockResolvedValue({
      tool: "resolve_execute_hard_lock_prompt",
      workspaceRoot: VIRTUAL_WORKSPACE_ROOT,
      summary: `Resolved the execute hard-lock prompt for '${workspacePath("docs/features/active/feature-123/plan.md")}'.`,
      artifacts: [workspacePath("artifacts/hard_lock_prompt.txt")],
    });

    const result = await client.callTool({
      name: "resolve_execute_hard_lock_prompt",
      arguments: {
        workspace_root: VIRTUAL_WORKSPACE_ROOT,
        target: workspacePath("docs/features/active/feature-123/plan.md"),
      },
    });

    expect(service.resolveExecuteHardLockPrompt).toHaveBeenCalledWith({
      workspaceRoot: VIRTUAL_WORKSPACE_ROOT,
      target: workspacePath("docs/features/active/feature-123/plan.md"),
      output: DEFAULT_HARD_LOCK_PROMPT_OUTPUT_PATH,
      quiet: true,
    });
    expect(result.isError).toBe(false);
    expect(result.structuredContent).toMatchObject({
      ok: true,
      tool: "resolve_execute_hard_lock_prompt",
      workspace_root: VIRTUAL_WORKSPACE_ROOT,
      artifacts: [workspacePath("artifacts/hard_lock_prompt.txt")],
    });
  });
});
