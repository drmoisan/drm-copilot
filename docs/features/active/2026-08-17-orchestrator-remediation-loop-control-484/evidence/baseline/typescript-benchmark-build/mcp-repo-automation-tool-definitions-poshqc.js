"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.POSHQC_TOOL_DEFINITIONS = void 0;
const mcp_push_down_schema_properties_1 = require("./mcp-push-down-schema-properties");
/**
 * PoshQC MCP tool definitions extracted from
 * `mcp-repo-automation-tool-definitions.ts` (following the
 * `mcp-tool-inputs-push-down.ts` / `mcp-tool-inputs-potential-to-issue.ts`
 * extraction precedent) so the base module stays within the 500-line
 * production-file limit.
 *
 * The `ToolDefinition` type is imported type-only to avoid introducing a
 * runtime import cycle with the base module, which re-exports this constant and
 * splices it into `REPO_AUTOMATION_TOOL_DEFINITIONS` at the original array
 * position. This is a pure module split: schemas, tool names, descriptions,
 * properties, and `required` arrays (including `workspace_root`) are unchanged.
 */
exports.POSHQC_TOOL_DEFINITIONS = [
    {
        name: "run_poshqc_format",
        description: "Run bundled PoshQC formatting against the target workspace using bundled extension resources.",
        inputSchema: {
            type: "object",
            properties: {
                workspace_root: mcp_push_down_schema_properties_1.workspaceRootProperty,
                scan_folders: {
                    type: "array",
                    items: {
                        type: "string",
                    },
                    description: "Optional workspace-relative or workspace-contained folders to scan.",
                },
            },
            required: ["workspace_root"],
            additionalProperties: false,
        },
    },
    {
        name: "run_poshqc_analyze",
        description: "Run bundled PoshQC analysis against the target workspace using bundled extension resources.",
        inputSchema: {
            type: "object",
            properties: {
                workspace_root: mcp_push_down_schema_properties_1.workspaceRootProperty,
                scan_folders: {
                    type: "array",
                    items: {
                        type: "string",
                    },
                    description: "Optional workspace-relative or workspace-contained folders to scan.",
                },
            },
            required: ["workspace_root"],
            additionalProperties: false,
        },
    },
    {
        name: "run_poshqc_test",
        description: "Run bundled PoshQC Pester checks against the target workspace using bundled extension resources. When scan_folders is omitted, the scan set is resolved from config/poshqc-scan.json (test.scanFolders); an explicit scan_folders argument overrides the configuration.",
        inputSchema: {
            type: "object",
            properties: {
                workspace_root: mcp_push_down_schema_properties_1.workspaceRootProperty,
                scan_folders: {
                    type: "array",
                    items: {
                        type: "string",
                    },
                    description: "Optional workspace-relative or workspace-contained folders to scan.",
                },
            },
            required: ["workspace_root"],
            additionalProperties: false,
        },
    },
    {
        name: "run_poshqc_analyze_autofix",
        description: "Apply bundled PoshQC analyzer autofixes, then rerun analysis against the target workspace using bundled extension resources.",
        inputSchema: {
            type: "object",
            properties: {
                workspace_root: mcp_push_down_schema_properties_1.workspaceRootProperty,
                scan_folders: {
                    type: "array",
                    items: {
                        type: "string",
                    },
                    description: "Optional workspace-relative or workspace-contained folders to scan.",
                },
            },
            required: ["workspace_root"],
            additionalProperties: false,
        },
    },
    {
        name: "run_poshqc_suite",
        description: "Run the bundled PoshQC suite against the target workspace using bundled extension resources.",
        inputSchema: {
            type: "object",
            properties: {
                workspace_root: mcp_push_down_schema_properties_1.workspaceRootProperty,
                scan_folders: {
                    type: "array",
                    items: {
                        type: "string",
                    },
                    description: "Optional workspace-relative or workspace-contained folders to scan.",
                },
            },
            required: ["workspace_root"],
            additionalProperties: false,
        },
    },
];
