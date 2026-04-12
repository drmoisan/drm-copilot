import { getStderrExcerpt } from "./command-runtime";
import {
  type RepoAutomationExecutionResult,
  type RepoAutomationService,
  REPO_AUTOMATION_TOOLS,
  type RepoAutomationToolName,
} from "./repo-automation-service";
import {
  resolveCollectCommitContextToolInput,
  resolveCollectPrContextToolInput,
  resolvePushDownCodexAndAgentsCustomizationsToolInput,
  resolveNewActiveFeatureFolderToolInput,
  resolveNewPotentialBugEntryToolInput,
  resolveNewPotentialEntryToolInput,
  resolvePotentialToIssueToolInput,
  resolvePushDownCopilotCustomizationsToolInput,
  resolveRunPoshQCSuiteToolInput,
  resolveResolveExecuteHardLockPromptToolInput,
  resolveValidateOrchestrationArtifactsToolInput,
} from "./mcp-tool-inputs";
import { normalizeWorkspaceRoot } from "./workflow-command-arguments";

interface ToolDefinition {
  readonly name: RepoAutomationToolName;
  readonly description: string;
  readonly inputSchema: {
    readonly type: "object";
    readonly properties: Readonly<Record<string, object>>;
    readonly required?: ReadonlyArray<string>;
    readonly additionalProperties: false;
  };
}

export interface RepoAutomationMcpToolResult extends Record<string, unknown> {
  readonly ok: boolean;
  readonly tool: RepoAutomationToolName;
  readonly workspace_root: string;
  readonly artifacts?: ReadonlyArray<string>;
  readonly summary: string;
  readonly stderr_excerpt?: string;
}

const workspaceRootProperty = {
  type: "string",
  description: "Target workspace root. Defaults to process.cwd() when omitted.",
};

const toolDefinitions: ReadonlyArray<ToolDefinition> = [
  {
    name: "collect_commit_context",
    description:
      "Collect commit context artifacts from the target workspace using bundled extension resources.",
    inputSchema: {
      type: "object",
      properties: {
        workspace_root: workspaceRootProperty,
      },
      additionalProperties: false,
    },
  },
  {
    name: "collect_pr_context",
    description:
      "Collect PR context artifacts for an explicit base branch using bundled extension resources.",
    inputSchema: {
      type: "object",
      properties: {
        workspace_root: workspaceRootProperty,
        base: {
          type: "string",
          description:
            "Explicit base branch or ref used for PR context collection.",
        },
      },
      required: ["base"],
      additionalProperties: false,
    },
  },
  {
    name: "push_down_copilot_customizations",
    description:
      "Copy the bundled Copilot customization payload into the target workspace.",
    inputSchema: {
      type: "object",
      properties: {
        workspace_root: workspaceRootProperty,
      },
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
        workspace_root: workspaceRootProperty,
      },
      additionalProperties: false,
    },
  },
  {
    name: "new_potential_bug_entry",
    description:
      "Create a new potential bug entry in the target workspace from bundled templates.",
    inputSchema: {
      type: "object",
      properties: {
        workspace_root: workspaceRootProperty,
        short_name: {
          type: "string",
          description: "Kebab-case short name for the potential bug entry.",
        },
      },
      required: ["short_name"],
      additionalProperties: false,
    },
  },
  {
    name: "new_potential_entry",
    description:
      "Create a new potential entry in the target workspace from bundled templates.",
    inputSchema: {
      type: "object",
      properties: {
        workspace_root: workspaceRootProperty,
        short_name: {
          type: "string",
          description: "Kebab-case short name for the potential entry.",
        },
      },
      required: ["short_name"],
      additionalProperties: false,
    },
  },
  {
    name: "potential_to_issue",
    description:
      "Promote a potential entry into an issue-oriented feature workflow in the target workspace.",
    inputSchema: {
      type: "object",
      properties: {
        workspace_root: workspaceRootProperty,
        potential_path: {
          type: "string",
          description:
            "Absolute or workspace-relative path to the potential Markdown file.",
        },
        promotion_type: {
          type: "string",
          enum: ["epic", "feature", "refactor", "bug"],
          description: "Promotion type to generate.",
        },
        work_mode: {
          type: "string",
          enum: ["minor-audit", "full-feature", "full-bug", "full"],
          description:
            "Work mode marker applied to the resulting issue workflow.",
        },
      },
      required: ["potential_path", "promotion_type", "work_mode"],
      additionalProperties: false,
    },
  },
  {
    name: "new_active_feature_folder",
    description:
      "Create a new active feature folder in the target workspace from bundled templates.",
    inputSchema: {
      type: "object",
      properties: {
        workspace_root: workspaceRootProperty,
        feature_name: {
          type: "string",
          description:
            "Feature folder name using kebab-case or underscore-case letters and numbers.",
        },
        type: {
          type: "string",
          enum: ["epic", "feature", "refactor", "bug"],
          description: "Feature folder type to create.",
        },
        issue_number: {
          type: "string",
          description:
            "Optional numeric issue number associated with the feature folder.",
        },
        work_mode: {
          type: "string",
          enum: ["minor-audit", "full-feature", "full-bug", "full"],
          description: "Work mode marker applied to the feature folder.",
        },
      },
      required: ["feature_name", "type", "work_mode"],
      additionalProperties: false,
    },
  },
  {
    name: "run_poshqc_format",
    description:
      "Run bundled PoshQC formatting against the target workspace using bundled extension resources.",
    inputSchema: {
      type: "object",
      properties: {
        workspace_root: workspaceRootProperty,
        scan_folders: {
          type: "array",
          items: {
            type: "string",
          },
          description:
            "Optional workspace-relative or workspace-contained folders to scan.",
        },
      },
      additionalProperties: false,
    },
  },
  {
    name: "run_poshqc_analyze",
    description:
      "Run bundled PoshQC analysis against the target workspace using bundled extension resources.",
    inputSchema: {
      type: "object",
      properties: {
        workspace_root: workspaceRootProperty,
        scan_folders: {
          type: "array",
          items: {
            type: "string",
          },
          description:
            "Optional workspace-relative or workspace-contained folders to scan.",
        },
      },
      additionalProperties: false,
    },
  },
  {
    name: "run_poshqc_test",
    description:
      "Run bundled PoshQC Pester checks against the target workspace using bundled extension resources.",
    inputSchema: {
      type: "object",
      properties: {
        workspace_root: workspaceRootProperty,
        scan_folders: {
          type: "array",
          items: {
            type: "string",
          },
          description:
            "Optional workspace-relative or workspace-contained folders to scan.",
        },
      },
      additionalProperties: false,
    },
  },
  {
    name: "run_poshqc_analyze_autofix",
    description:
      "Apply bundled PoshQC analyzer autofixes, then rerun analysis against the target workspace using bundled extension resources.",
    inputSchema: {
      type: "object",
      properties: {
        workspace_root: workspaceRootProperty,
        scan_folders: {
          type: "array",
          items: {
            type: "string",
          },
          description:
            "Optional workspace-relative or workspace-contained folders to scan.",
        },
      },
      additionalProperties: false,
    },
  },
  {
    name: "run_poshqc_suite",
    description:
      "Run the bundled PoshQC suite against the target workspace using bundled extension resources.",
    inputSchema: {
      type: "object",
      properties: {
        workspace_root: workspaceRootProperty,
        scan_folders: {
          type: "array",
          items: {
            type: "string",
          },
          description:
            "Optional workspace-relative or workspace-contained folders to scan.",
        },
      },
      additionalProperties: false,
    },
  },
  {
    name: "resolve_execute_hard_lock_prompt",
    description:
      "Resolve the execute hard-lock prompt for a target plan path using bundled extension resources.",
    inputSchema: {
      type: "object",
      properties: {
        workspace_root: workspaceRootProperty,
        target: {
          type: "string",
          description: "Target Markdown plan path to resolve.",
        },
      },
      required: ["target"],
      additionalProperties: false,
    },
  },
  {
    name: "validate_orchestration_artifacts",
    description:
      "Validate an orchestration artifact (plan, policy-audit, code-review, feature-audit, or orchestrator-state) against its structural schema.",
    inputSchema: {
      type: "object",
      properties: {
        workspace_root: workspaceRootProperty,
        artifact_type: {
          type: "string",
          enum: [
            "plan",
            "policy-audit",
            "code-review",
            "feature-audit",
            "orchestrator-state",
          ],
          description: "The type of orchestration artifact to validate.",
        },
        artifact_path: {
          type: "string",
          description:
            "Workspace-relative or absolute path to the artifact file.",
        },
        require_complete: {
          type: "boolean",
          description:
            "When true and artifact_type is 'orchestrator-state', require all phases to be complete.",
        },
      },
      required: ["artifact_type", "artifact_path"],
      additionalProperties: false,
    },
  },
];

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
  return toolDefinitions;
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

      case "resolve_execute_hard_lock_prompt": {
        const input = resolveResolveExecuteHardLockPromptToolInput(rawInput);
        return toMcpToolResult(
          await service.resolveExecuteHardLockPrompt(input),
        );
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
