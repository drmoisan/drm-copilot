import { type ToolDefinition } from "./mcp-repo-automation-tool-definitions";
import { workspaceRootProperty } from "./mcp-push-down-schema-properties";
import {
  DISCOVERY_ARTIFACT_TYPES,
  DISCOVERY_REPORT_TYPES,
} from "./mcp-tool-inputs-discovery";

/**
 * Tool definitions for the seven discovery MCP tools, in `REPO_AUTOMATION_TOOLS`
 * union order. Each reuses {@link workspaceRootProperty}, sets
 * `additionalProperties: false`, and draws its enum values from the Phase 4
 * resolver constants ({@link DISCOVERY_ARTIFACT_TYPES},
 * {@link DISCOVERY_REPORT_TYPES}) so the schema enums and the resolver enums
 * cannot drift. `run_discovery_report`'s per-`report_type` required inputs
 * cannot be expressed by a flat JSON-Schema `required` list, so they are
 * documented here and enforced by the input resolver before any spawn.
 */
export const DISCOVERY_TOOL_DEFINITIONS: ReadonlyArray<ToolDefinition> = [
  {
    name: "validate_discovery_artifacts",
    description:
      "Validate a discovery artifact against its declared schema by invoking the workspace discovery CLI. The artifact_type selects the per-kind validator entry.",
    inputSchema: {
      type: "object",
      properties: {
        workspace_root: workspaceRootProperty,
        artifact_type: {
          type: "string",
          enum: [...DISCOVERY_ARTIFACT_TYPES],
          description:
            "Discovery artifact kind to validate; 'all' validates every kind under the supplied path.",
        },
        artifact_path: {
          type: "string",
          description:
            "Workspace-relative or absolute path to the artifact (or directory for 'all').",
        },
      },
      required: ["workspace_root", "artifact_type", "artifact_path"],
      additionalProperties: false,
    },
  },
  {
    name: "run_discovery_init",
    description:
      "Scaffold a discovery workspace by invoking the workspace discovery init CLI at the target directory.",
    inputSchema: {
      type: "object",
      properties: {
        workspace_root: workspaceRootProperty,
        target_dir: {
          type: "string",
          description:
            "Workspace-relative or absolute directory to scaffold the discovery workspace into.",
        },
        template_root: {
          type: "string",
          description: "Optional template root overriding the CLI default.",
        },
        force: {
          type: "boolean",
          description: "When true, overwrite existing scaffold files.",
        },
      },
      required: ["workspace_root", "target_dir"],
      additionalProperties: false,
    },
  },
  {
    name: "run_discovery_repo_inventory",
    description:
      "Run the repository inventory analyzer via the workspace discovery CLI, returning the written artifact paths.",
    inputSchema: {
      type: "object",
      properties: {
        workspace_root: workspaceRootProperty,
        profile_path: {
          type: "string",
          description:
            "Optional domain-profile path; the CLI default filename applies when omitted.",
        },
        output_dir: {
          type: "string",
          description: "Optional output directory for the analysis artifacts.",
        },
      },
      required: ["workspace_root"],
      additionalProperties: false,
    },
  },
  {
    name: "run_discovery_dotnet_analyzer",
    description:
      "Run the .NET stack analyzer via the workspace discovery CLI, returning the written artifact paths.",
    inputSchema: {
      type: "object",
      properties: {
        workspace_root: workspaceRootProperty,
        profile_path: {
          type: "string",
          description:
            "Optional domain-profile path; the CLI default filename applies when omitted.",
        },
        output_dir: {
          type: "string",
          description: "Optional output directory for the analysis artifacts.",
        },
      },
      required: ["workspace_root"],
      additionalProperties: false,
    },
  },
  {
    name: "run_discovery_vsto_analyzer",
    description:
      "Run the VSTO stack analyzer via the workspace discovery CLI, returning the written artifact paths.",
    inputSchema: {
      type: "object",
      properties: {
        workspace_root: workspaceRootProperty,
        profile_path: {
          type: "string",
          description:
            "Optional domain-profile path; the CLI default filename applies when omitted.",
        },
        output_dir: {
          type: "string",
          description: "Optional output directory for the analysis artifacts.",
        },
      },
      required: ["workspace_root"],
      additionalProperties: false,
    },
  },
  {
    name: "run_discovery_scenario_generation",
    description:
      "Generate acceptance scenarios via the workspace discovery CLI from a feature contract, parity matrix, and runtime characterization.",
    inputSchema: {
      type: "object",
      properties: {
        workspace_root: workspaceRootProperty,
        feature_contract: {
          type: "string",
          description: "Workspace-relative or absolute feature-contract path.",
        },
        parity_matrix: {
          type: "string",
          description: "Workspace-relative or absolute parity-matrix path.",
        },
        runtime_characterization: {
          type: "string",
          description:
            "Workspace-relative or absolute runtime-characterization path.",
        },
        output_path: {
          type: "string",
          description:
            "Optional output path; when supplied the written artifact path is returned.",
        },
        check: {
          type: "boolean",
          description:
            "When true, run in check mode without writing generated scenarios.",
        },
      },
      required: [
        "workspace_root",
        "feature_contract",
        "parity_matrix",
        "runtime_characterization",
      ],
      additionalProperties: false,
    },
  },
  {
    name: "run_discovery_report",
    description:
      "Generate a discovery report via the workspace discovery CLI. report_type selects the report: 'coverage' and 'parity' require input_path; 'completion' requires both coverage_input and parity_input. The per-report_type required inputs are enforced by the tool before any invocation.",
    inputSchema: {
      type: "object",
      properties: {
        workspace_root: workspaceRootProperty,
        report_type: {
          type: "string",
          enum: [...DISCOVERY_REPORT_TYPES],
          description:
            "Report kind: 'coverage'/'parity' (single input) or 'completion' (coverage + parity inputs).",
        },
        input_path: {
          type: "string",
          description:
            "Required for 'coverage'/'parity': the ledger or matrix input path.",
        },
        coverage_input: {
          type: "string",
          description:
            "Required for 'completion': the coverage-ledger input path.",
        },
        parity_input: {
          type: "string",
          description:
            "Required for 'completion': the parity-matrix input path.",
        },
        output_path: {
          type: "string",
          description: "Optional output path for the generated report.",
        },
      },
      required: ["workspace_root", "report_type"],
      additionalProperties: false,
    },
  },
];
