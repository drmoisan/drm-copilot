import { type RepoAutomationToolName } from "./repo-automation-tool-names";
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

const workspaceRootProperty = {
  type: "string",
  description: "Target workspace root. Defaults to process.cwd() when omitted.",
};

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
      },
      required: ["artifact_type", "artifact_path"],
      additionalProperties: false,
    },
  },
];
