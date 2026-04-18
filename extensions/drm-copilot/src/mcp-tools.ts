import { getStderrExcerpt } from "./command-runtime";
import {
  REPO_AUTOMATION_TOOL_DEFINITIONS,
  type ToolDefinition,
} from "./mcp-repo-automation-tool-definitions";
import {
  type RepoAutomationExecutionResult,
  type RepoAutomationService,
} from "./repo-automation-service";
import {
  REPO_AUTOMATION_TOOLS,
  type RepoAutomationToolName,
} from "./repo-automation-tool-names";
import {
  resolveCollectCommitContextToolInput,
  resolveCollectPrContextToolInput,
  resolveNewActiveFeatureFolderToolInput,
  resolveNewPotentialBugEntryToolInput,
  resolveNewPotentialEntryToolInput,
  resolvePolicyAuditTemplateAssetToolInput,
  resolvePotentialToIssueToolInput,
  resolvePushDownCodexAndAgentsCustomizationsToolInput,
  resolvePushDownCopilotCustomizationsToolInput,
  resolveRunPoshQCSuiteToolInput,
  resolveResolveAtomicPlanPromptToolInput,
  resolveResolveExecuteHardLockPromptToolInput,
  resolveValidateOrchestrationArtifactsToolInput,
} from "./mcp-tool-inputs";
import { normalizeWorkspaceRoot } from "./workflow-command-arguments";

export interface RepoAutomationMcpToolResult extends Record<string, unknown> {
  readonly ok: boolean;
  readonly tool: RepoAutomationToolName;
  readonly workspace_root: string;
  readonly artifacts?: ReadonlyArray<string>;
  readonly asset_id?: string;
  readonly bundled_source_path?: string;
  readonly destination_path?: string;
  readonly summary: string;
  readonly stderr_excerpt?: string;
}

function inferWorkspaceRoot(rawInput: unknown): string {
  if (
    typeof rawInput !== "object" ||
    rawInput === null ||
    Array.isArray(rawInput)
  ) {
    return process.cwd();
  }

  const workspaceRoot = (rawInput as Readonly<Record<string, unknown>>)[
    "workspace_root"
  ];
  return normalizeWorkspaceRoot(workspaceRoot, process.cwd());
}

function toMcpToolResult(
  result: RepoAutomationExecutionResult,
): RepoAutomationMcpToolResult {
  return {
    ok: true,
    tool: result.tool,
    workspace_root: result.workspaceRoot,
    summary: result.summary,
    ...(result.artifacts === undefined ? {} : { artifacts: result.artifacts }),
    ...(result.assetId === undefined ? {} : { asset_id: result.assetId }),
    ...(result.bundledSourcePath === undefined
      ? {}
      : { bundled_source_path: result.bundledSourcePath }),
    ...(result.destinationPath === undefined
      ? {}
      : { destination_path: result.destinationPath }),
  };
}

function toFailureToolResult(
  tool: RepoAutomationToolName,
  workspaceRoot: string,
  error: unknown,
): RepoAutomationMcpToolResult {
  const stderrExcerpt = getStderrExcerpt(error);
  return {
    ok: false,
    tool,
    workspace_root: workspaceRoot,
    summary: error instanceof Error ? error.message : String(error),
    ...(stderrExcerpt === undefined ? {} : { stderr_excerpt: stderrExcerpt }),
  };
}

/**
 * Lists the semantic repo-automation tools exposed through the MCP bridge.
 *
 * @returns Stable tool definitions advertised to MCP clients.
 */
export function listRepoAutomationTools(): ReadonlyArray<ToolDefinition> {
  return REPO_AUTOMATION_TOOL_DEFINITIONS;
}

/**
 * Dispatches a semantic repo-automation tool call through the shared service layer.
 *
 * @param toolName The semantic snake_case tool name.
 * @param rawInput The raw MCP tool arguments.
 * @param service The shared repo-automation service.
 * @returns A structured result that can be surfaced to Codex.
 */
export async function dispatchRepoAutomationTool(
  toolName: RepoAutomationToolName,
  rawInput: unknown,
  service: RepoAutomationService,
): Promise<RepoAutomationMcpToolResult> {
  const workspaceRoot = inferWorkspaceRoot(rawInput);

  try {
    switch (toolName) {
      case "collect_commit_context": {
        const input = resolveCollectCommitContextToolInput(rawInput);
        return toMcpToolResult(await service.collectCommitContext(input));
      }

      case "collect_pr_context": {
        const input = resolveCollectPrContextToolInput(rawInput);
        return toMcpToolResult(await service.collectPrContext(input));
      }

      case "push_down_copilot_customizations": {
        const input = resolvePushDownCopilotCustomizationsToolInput(rawInput);
        return toMcpToolResult(
          await service.pushDownCopilotCustomizations(input),
        );
      }

      case "push_down_codex_and_agents_customizations": {
        const input =
          resolvePushDownCodexAndAgentsCustomizationsToolInput(rawInput);
        return toMcpToolResult(
          await service.pushDownCodexAndAgentsCustomizations(input),
        );
      }

      case "new_potential_bug_entry": {
        const input = resolveNewPotentialBugEntryToolInput(rawInput);
        return toMcpToolResult(await service.newPotentialBugEntry(input));
      }

      case "new_potential_entry": {
        const input = resolveNewPotentialEntryToolInput(rawInput);
        return toMcpToolResult(await service.newPotentialEntry(input));
      }

      case "potential_to_issue": {
        const input = resolvePotentialToIssueToolInput(rawInput);
        return toMcpToolResult(await service.potentialToIssue(input));
      }

      case "new_active_feature_folder": {
        const input = resolveNewActiveFeatureFolderToolInput(rawInput);
        return toMcpToolResult(await service.newActiveFeatureFolder(input));
      }

      case "run_poshqc_format": {
        const input = resolveRunPoshQCSuiteToolInput(rawInput);
        return toMcpToolResult(await service.runPoshQCFormat(input));
      }

      case "run_poshqc_analyze": {
        const input = resolveRunPoshQCSuiteToolInput(rawInput);
        return toMcpToolResult(await service.runPoshQCAnalyze(input));
      }

      case "run_poshqc_test": {
        const input = resolveRunPoshQCSuiteToolInput(rawInput);
        return toMcpToolResult(await service.runPoshQCTest(input));
      }

      case "run_poshqc_analyze_autofix": {
        const input = resolveRunPoshQCSuiteToolInput(rawInput);
        return toMcpToolResult(await service.runPoshQCAnalyzeAutofix(input));
      }

      case "run_poshqc_suite": {
        const input = resolveRunPoshQCSuiteToolInput(rawInput);
        return toMcpToolResult(await service.runPoshQCSuite(input));
      }

      case "resolve_policy_audit_template_asset": {
        const input = resolvePolicyAuditTemplateAssetToolInput(rawInput);
        return toMcpToolResult(
          await service.resolvePolicyAuditTemplateAsset(input),
        );
      }

      case "resolve_execute_hard_lock_prompt": {
        const input = resolveResolveExecuteHardLockPromptToolInput(rawInput);
        return toMcpToolResult(
          await service.resolveExecuteHardLockPrompt(input),
        );
      }

      case "resolve_atomic_plan_prompt": {
        const input = resolveResolveAtomicPlanPromptToolInput(rawInput);
        return toMcpToolResult(await service.resolveAtomicPlanPrompt(input));
      }

      case "validate_orchestration_artifacts": {
        const input = resolveValidateOrchestrationArtifactsToolInput(rawInput);
        return toMcpToolResult(
          await service.validateOrchestrationArtifacts(input),
        );
      }
    }
  } catch (error: unknown) {
    return toFailureToolResult(toolName, workspaceRoot, error);
  }
}

/**
 * Checks whether a tool name is one of the semantic repo-automation MCP tools.
 *
 * @param name The tool name to inspect.
 * @returns True when the supplied name is a supported semantic tool.
 */
export function isRepoAutomationToolName(
  name: string,
): name is RepoAutomationToolName {
  return REPO_AUTOMATION_TOOLS.includes(name as RepoAutomationToolName);
}
