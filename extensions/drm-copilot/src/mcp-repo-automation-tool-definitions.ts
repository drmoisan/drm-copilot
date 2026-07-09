import { type RepoAutomationToolName } from "./repo-automation-tool-names";
import {
  claudePushDownSelectionProperties,
  codexPushDownSelectionProperties,
  copilotPushDownSelectionProperties,
  workspaceRootProperty,
} from "./mcp-push-down-schema-properties";
import { POLICY_AUDIT_TEMPLATE_ASSET_SELECTORS } from "./workflow-command-arguments";
export interface ToolDefinition {
  readonly name: RepoAutomationToolName;
  readonly description: string;
  readonly inputSchema: {
    readonly type: "object";
    readonly properties: Readonly<Record<string, object>>;
    readonly required?: ReadonlyArray<string>;
    readonly additionalProperties: false;
  };
}

export const REPO_AUTOMATION_TOOL_DEFINITIONS: ReadonlyArray<ToolDefinition> = [
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
    name: "run_codex_native_converter",
    description:
      "Run the bundled Codex-native converter in review or apply mode using the extension resources.",
    inputSchema: {
      type: "object",
      properties: {
        workspace_root: workspaceRootProperty,
        mode: {
          type: "string",
          description: "Converter mode to execute.",
        },
        source_ecosystem: {
          type: "string",
          description: "Supported source ecosystem for the conversion run.",
        },
        source_root: {
          type: "string",
          description: "Workspace-relative or absolute source runtime root.",
        },
        selected_paths: {
          type: "array",
          description:
            "Optional workspace-relative or absolute source paths beneath source_root.",
          items: {
            type: "string",
          },
        },
        destination_root: {
          type: "string",
          description:
            "Workspace-relative or absolute destination root required for apply mode.",
        },
        artifact_root: {
          type: "string",
          description:
            "Optional workspace-relative or absolute artifact output root.",
        },
        enable_repo_prompts: {
          type: "boolean",
          description:
            "When true, allow repository-convention .codex/prompts outputs.",
        },
      },
      required: ["mode", "source_ecosystem", "source_root"],
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
        ...copilotPushDownSelectionProperties,
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
        ...codexPushDownSelectionProperties,
      },
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
        workspace_root: workspaceRootProperty,
        ...claudePushDownSelectionProperties,
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
    name: "link_parent_child",
    description:
      "Link a child GitHub issue to a parent GitHub issue in the target workspace using the bundled PowerShell workflow.",
    inputSchema: {
      type: "object",
      properties: {
        workspace_root: workspaceRootProperty,
        parent_issue_number: {
          type: "string",
          description: "Numeric issue number of the parent issue.",
        },
        child_issue_number: {
          type: "string",
          description: "Numeric issue number of the child issue.",
        },
      },
      required: ["parent_issue_number", "child_issue_number"],
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
    name: "resolve_policy_audit_template_asset",
    description:
      "Resolve a bundled policy-audit template asset from the published extension package, optionally copying it into the target workspace.",
    inputSchema: {
      type: "object",
      properties: {
        workspace_root: workspaceRootProperty,
        asset: {
          type: "string",
          enum: [...POLICY_AUDIT_TEMPLATE_ASSET_SELECTORS],
          description:
            "Bundled policy-audit asset selector: 'template' for policy-audit.yyyy-MM-ddTHH-mm.md, 'code-review-template' for code-review.yyyy-MM-ddTHH-mm.md, 'feature-audit-template' for feature-audit.yyyy-MM-ddTHH-mm.md, or 'agents' for AGENTS.md.",
        },
        target_path: {
          type: "string",
          description:
            "Optional workspace-relative or absolute destination path for a copied asset.",
        },
      },
      required: ["asset"],
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
    name: "resolve_atomic_plan_prompt",
    description:
      "Resolve the atomic-plan prompt for a target plan path using bundled extension resources.",
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
        require_model_routing: {
          type: "boolean",
          description:
            "When true and artifact_type is 'orchestrator-state', require a model_routing_receipts entry per delegated agent once a delegation is recorded. The TypeScript side performs the existence check only; the Python validator is authoritative for full per-receipt correctness.",
        },
      },
      required: ["artifact_type", "artifact_path"],
      additionalProperties: false,
    },
  },
  {
    name: "render_subagent_tree",
    description:
      "Render the subagent call tree for a root session id. The session id is a transcript filename stem; the transcript is resolved under the user-global Claude projects directory, searching the encoded workspace directory plus its '-wt-' worktree siblings (case-insensitive) and returning the first match deterministically.",
    inputSchema: {
      type: "object",
      properties: {
        workspace_root: workspaceRootProperty,
        session_id: {
          type: "string",
          description:
            "Root session identifier (transcript filename stem under ~/.claude/projects/<encoded-workspace>/, e.g. a UUIDv4).",
        },
      },
      required: ["session_id"],
      additionalProperties: false,
    },
  },
];
