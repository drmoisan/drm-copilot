"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.REPO_AUTOMATION_TOOL_DEFINITIONS = exports.POSHQC_TOOL_DEFINITIONS = void 0;
const mcp_push_down_schema_properties_1 = require("./mcp-push-down-schema-properties");
const workflow_command_arguments_1 = require("./workflow-command-arguments");
const mcp_discovery_tool_definitions_1 = require("./mcp-discovery-tool-definitions");
const mcp_validator_catalog_1 = require("./mcp-validator-catalog");
const mcp_repo_automation_tool_definitions_poshqc_1 = require("./mcp-repo-automation-tool-definitions-poshqc");
var mcp_repo_automation_tool_definitions_poshqc_2 = require("./mcp-repo-automation-tool-definitions-poshqc");
Object.defineProperty(exports, "POSHQC_TOOL_DEFINITIONS", { enumerable: true, get: function () { return mcp_repo_automation_tool_definitions_poshqc_2.POSHQC_TOOL_DEFINITIONS; } });
exports.REPO_AUTOMATION_TOOL_DEFINITIONS = [
    {
        name: "collect_commit_context",
        description: "Collect commit context artifacts from the target workspace using bundled extension resources.",
        inputSchema: {
            type: "object",
            properties: {
                workspace_root: mcp_push_down_schema_properties_1.workspaceRootProperty,
            },
            required: ["workspace_root"],
            additionalProperties: false,
        },
    },
    {
        name: "collect_pr_context",
        description: "Collect PR context artifacts for an explicit base branch using bundled extension resources.",
        inputSchema: {
            type: "object",
            properties: {
                workspace_root: mcp_push_down_schema_properties_1.workspaceRootProperty,
                base: {
                    type: "string",
                    description: "Explicit base branch or ref used for PR context collection.",
                },
            },
            required: ["workspace_root", "base"],
            additionalProperties: false,
        },
    },
    {
        name: "run_codex_native_converter",
        description: "Run the bundled Codex-native converter in review or apply mode using the extension resources.",
        inputSchema: {
            type: "object",
            properties: {
                workspace_root: mcp_push_down_schema_properties_1.workspaceRootProperty,
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
                    description: "Optional workspace-relative or absolute source paths beneath source_root.",
                    items: {
                        type: "string",
                    },
                },
                destination_root: {
                    type: "string",
                    description: "Workspace-relative or absolute destination root required for apply mode.",
                },
                artifact_root: {
                    type: "string",
                    description: "Optional workspace-relative or absolute artifact output root.",
                },
                enable_repo_prompts: {
                    type: "boolean",
                    description: "When true, allow repository-convention .codex/prompts outputs.",
                },
            },
            required: ["workspace_root", "mode", "source_ecosystem", "source_root"],
            additionalProperties: false,
        },
    },
    {
        name: "push_down_copilot_customizations",
        description: "Copy the bundled Copilot customization payload into the target workspace.",
        inputSchema: {
            type: "object",
            properties: {
                workspace_root: mcp_push_down_schema_properties_1.workspaceRootProperty,
                ...mcp_push_down_schema_properties_1.copilotPushDownSelectionProperties,
            },
            required: ["workspace_root"],
            additionalProperties: false,
        },
    },
    {
        name: "push_down_codex_and_agents_customizations",
        description: "Copy the bundled Codex and agents customization payload into the target workspace.",
        inputSchema: {
            type: "object",
            properties: {
                workspace_root: mcp_push_down_schema_properties_1.workspaceRootProperty,
                ...mcp_push_down_schema_properties_1.codexPushDownSelectionProperties,
            },
            required: ["workspace_root"],
            additionalProperties: false,
        },
    },
    {
        name: "push_down_claude_customizations",
        description: "Copy the bundled Claude Code customization payload into the target workspace.",
        inputSchema: {
            type: "object",
            properties: {
                workspace_root: mcp_push_down_schema_properties_1.workspaceRootProperty,
                ...mcp_push_down_schema_properties_1.claudePushDownSelectionProperties,
            },
            required: ["workspace_root"],
            additionalProperties: false,
        },
    },
    {
        name: "new_potential_bug_entry",
        description: "Create a new potential bug entry in the target workspace from bundled templates.",
        inputSchema: {
            type: "object",
            properties: {
                workspace_root: mcp_push_down_schema_properties_1.workspaceRootProperty,
                short_name: {
                    type: "string",
                    description: "Kebab-case short name for the potential bug entry.",
                },
            },
            required: ["workspace_root", "short_name"],
            additionalProperties: false,
        },
    },
    {
        name: "new_potential_entry",
        description: "Create a new potential entry in the target workspace from bundled templates.",
        inputSchema: {
            type: "object",
            properties: {
                workspace_root: mcp_push_down_schema_properties_1.workspaceRootProperty,
                short_name: {
                    type: "string",
                    description: "Kebab-case short name for the potential entry.",
                },
            },
            required: ["workspace_root", "short_name"],
            additionalProperties: false,
        },
    },
    {
        name: "link_parent_child",
        description: "Link a child GitHub issue to a parent GitHub issue in the target workspace using the bundled PowerShell workflow.",
        inputSchema: {
            type: "object",
            properties: {
                workspace_root: mcp_push_down_schema_properties_1.workspaceRootProperty,
                parent_issue_number: {
                    type: "string",
                    description: "Numeric issue number of the parent issue.",
                },
                child_issue_number: {
                    type: "string",
                    description: "Numeric issue number of the child issue.",
                },
            },
            required: ["workspace_root", "parent_issue_number", "child_issue_number"],
            additionalProperties: false,
        },
    },
    {
        name: "potential_to_issue",
        description: "Promote a potential entry into an issue-oriented feature workflow in the target workspace.",
        inputSchema: {
            type: "object",
            properties: {
                workspace_root: mcp_push_down_schema_properties_1.workspaceRootProperty,
                potential_path: {
                    type: "string",
                    description: "Absolute or workspace-relative path to the potential Markdown file.",
                },
                promotion_type: {
                    type: "string",
                    enum: ["epic", "feature", "refactor", "bug"],
                    description: "Promotion type to generate.",
                },
                work_mode: {
                    type: "string",
                    enum: ["minor-audit", "full-feature", "full-bug", "full"],
                    description: "Work mode marker applied to the resulting issue workflow.",
                },
            },
            required: [
                "workspace_root",
                "potential_path",
                "promotion_type",
                "work_mode",
            ],
            additionalProperties: false,
        },
    },
    {
        name: "new_active_feature_folder",
        description: "Create a new active feature folder in the target workspace from bundled templates.",
        inputSchema: {
            type: "object",
            properties: {
                workspace_root: mcp_push_down_schema_properties_1.workspaceRootProperty,
                feature_name: {
                    type: "string",
                    description: "Feature folder name using kebab-case or underscore-case letters and numbers.",
                },
                type: {
                    type: "string",
                    enum: ["epic", "feature", "refactor", "bug"],
                    description: "Feature folder type to create.",
                },
                issue_number: {
                    type: "string",
                    description: "Optional numeric issue number associated with the feature folder.",
                },
                work_mode: {
                    type: "string",
                    enum: ["minor-audit", "full-feature", "full-bug", "full"],
                    description: "Work mode marker applied to the feature folder.",
                },
            },
            required: ["workspace_root", "feature_name", "type", "work_mode"],
            additionalProperties: false,
        },
    },
    ...mcp_repo_automation_tool_definitions_poshqc_1.POSHQC_TOOL_DEFINITIONS,
    {
        name: "resolve_policy_audit_template_asset",
        description: "Resolve a bundled policy-audit template asset from the published extension package, optionally copying it into the target workspace.",
        inputSchema: {
            type: "object",
            properties: {
                workspace_root: mcp_push_down_schema_properties_1.workspaceRootProperty,
                asset: {
                    type: "string",
                    enum: [...workflow_command_arguments_1.POLICY_AUDIT_TEMPLATE_ASSET_SELECTORS],
                    description: "Bundled policy-audit asset selector: 'template' for policy-audit.yyyy-MM-ddTHH-mm.md, 'code-review-template' for code-review.yyyy-MM-ddTHH-mm.md, 'feature-audit-template' for feature-audit.yyyy-MM-ddTHH-mm.md, or 'agents' for AGENTS.md.",
                },
                target_path: {
                    type: "string",
                    description: "Optional workspace-relative or absolute destination path for a copied asset.",
                },
            },
            required: ["workspace_root", "asset"],
            additionalProperties: false,
        },
    },
    {
        name: "resolve_execute_hard_lock_prompt",
        description: "Resolve the execute hard-lock prompt for a target plan path using bundled extension resources.",
        inputSchema: {
            type: "object",
            properties: {
                workspace_root: mcp_push_down_schema_properties_1.workspaceRootProperty,
                target: {
                    type: "string",
                    description: "Target Markdown plan path to resolve.",
                },
            },
            required: ["workspace_root", "target"],
            additionalProperties: false,
        },
    },
    {
        name: "resolve_atomic_plan_prompt",
        description: "Resolve the atomic-plan prompt for a target plan path using bundled extension resources.",
        inputSchema: {
            type: "object",
            properties: {
                workspace_root: mcp_push_down_schema_properties_1.workspaceRootProperty,
                target: {
                    type: "string",
                    description: "Target Markdown plan path to resolve.",
                },
            },
            required: ["workspace_root", "target"],
            additionalProperties: false,
        },
    },
    {
        name: "validate_orchestration_artifacts",
        description: "Validate an orchestration artifact, including epic planner, kickoff, and execution checkpoints, against its structural and semantic invariants.",
        inputSchema: {
            type: "object",
            properties: {
                workspace_root: mcp_push_down_schema_properties_1.workspaceRootProperty,
                artifact_type: mcp_validator_catalog_1.VALIDATOR_ARTIFACT_TYPE_PROPERTY,
                artifact_path: {
                    type: "string",
                    description: "Workspace-relative or absolute path to the artifact file.",
                },
                ...mcp_validator_catalog_1.VALIDATOR_FLAG_SCHEMA_PROPERTIES,
            },
            required: ["workspace_root", "artifact_type", "artifact_path"],
            additionalProperties: false,
        },
    },
    {
        name: "render_subagent_tree",
        description: "Render the subagent call tree for a root session id. The session id is a transcript filename stem; the transcript is resolved under the user-global Claude projects directory, searching the encoded workspace directory plus its '-wt-' worktree siblings (case-insensitive) and returning the first match deterministically.",
        inputSchema: {
            type: "object",
            properties: {
                workspace_root: mcp_push_down_schema_properties_1.workspaceRootProperty,
                session_id: {
                    type: "string",
                    description: "Root session identifier (transcript filename stem under ~/.claude/projects/<encoded-workspace>/, e.g. a UUIDv4).",
                },
            },
            required: ["workspace_root", "session_id"],
            additionalProperties: false,
        },
    },
    ...mcp_discovery_tool_definitions_1.DISCOVERY_TOOL_DEFINITIONS,
];
