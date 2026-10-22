import { type ToolDefinition } from "./mcp-repo-automation-tool-definitions";
import { workspaceRootProperty } from "./mcp-push-down-schema-properties";
import {
  CREATE_ARTIFACT_KINDS,
  DISCOVERY_ARTIFACT_KINDS,
  DISCOVERY_ARTIFACT_TYPES,
  DISCOVERY_MODES,
  DISCOVERY_OUTPUT_FORMATS,
  DISCOVERY_REPORT_TYPES,
  SYSTEM_ROLES,
  UPDATE_ACTIONS,
} from "./mcp-tool-inputs-discovery";
import { DISCOVERY_AUTHORITY_TOOL_DEFINITIONS } from "./mcp-discovery-authority-tool-definitions";

/**
 * Tool definitions for the discovery MCP tools, in `REPO_AUTOMATION_TOOLS`
 * union order. Each reuses {@link workspaceRootProperty}, sets
 * `additionalProperties: false`, and draws every enum from the resolver
 * constants so the advertised schema and the resolver cannot drift. Every tool
 * composes one closed v2 `service-request`; no tool accepts an output path, a
 * template root, a module, a command or a receipt destination.
 */

const profilePath = {
  type: "string",
  description:
    "Optional workspace-relative domain-profile path; the protected activation or default applies when omitted.",
};
const dryRun = {
  type: "boolean",
  description:
    "When true, plan the publication and report prospective effects without writing.",
};
const write = {
  type: "boolean",
  description: "When true, publish validated outputs; defaults to false.",
};
const invocationRef = {
  type: "string",
  description:
    "Protected invocation reference for an agent-output request; omitted for root operations.",
};
const authorizationRef = {
  type: "string",
  description:
    "One-use native tool authorization reference; omitted for root operations.",
};
const identifiers = (description: string) => ({
  type: "array",
  items: { type: "string" },
  description,
});

export const DISCOVERY_TOOL_DEFINITIONS: ReadonlyArray<ToolDefinition> = [
  {
    name: "validate_discovery_artifacts",
    description:
      "Validate one discovery artifact kind structurally, or validate the whole configured workspace ('all', artifact_path '.') in an explicit mode, through the installed discovery runtime.",
    inputSchema: {
      type: "object",
      properties: {
        workspace_root: workspaceRootProperty,
        artifact_type: {
          type: "string",
          enum: [...DISCOVERY_ARTIFACT_TYPES],
          description:
            "Artifact kind to validate; 'all' validates the configured workspace.",
        },
        artifact_path: {
          type: "string",
          description:
            "Workspace-relative artifact path, or '.' for artifact_type 'all'.",
        },
        profile_path: profilePath,
        mode: {
          type: "string",
          enum: [...DISCOVERY_MODES],
          description:
            "Whole-workspace validation mode for 'all'; individual kinds are structural.",
        },
        dry_run: dryRun,
      },
      required: ["workspace_root", "artifact_type", "artifact_path"],
      additionalProperties: false,
    },
  },
  {
    name: "run_discovery_init",
    description:
      "Initialize a v2 discovery workspace from explicit system identity and roots. Never overwrites; dry_run reports the plan.",
    inputSchema: {
      type: "object",
      properties: {
        workspace_root: workspaceRootProperty,
        system_id: { type: "string", description: "System identifier." },
        system_name: {
          type: "string",
          description: "Human-readable system name.",
        },
        system_role: {
          type: "string",
          enum: [...SYSTEM_ROLES],
          description: "Role of this repository in the migration.",
        },
        repository_id: {
          type: "string",
          description: "Repository identifier.",
        },
        production_roots: identifiers("Workspace-relative production roots."),
        test_roots: identifiers("Workspace-relative test roots."),
        draft: {
          type: "boolean",
          description: "When true, initialize a draft profile without roots.",
        },
        profile_path: profilePath,
        dry_run: dryRun,
      },
      required: [
        "workspace_root",
        "system_id",
        "system_name",
        "system_role",
        "repository_id",
      ],
      additionalProperties: false,
    },
  },
  {
    name: "run_discovery_repo_inventory",
    description:
      "Run the configured inventory analyzers (or an explicit analyzer selection) and publish inventory artifacts under the profile roots.",
    inputSchema: {
      type: "object",
      properties: {
        workspace_root: workspaceRootProperty,
        profile_path: profilePath,
        analyzer_ids: identifiers("Optional explicit analyzer identifiers."),
        write,
        dry_run: dryRun,
      },
      required: ["workspace_root"],
      additionalProperties: false,
    },
  },
  {
    name: "run_discovery_dotnet_analyzer",
    description:
      "Run the fixed .NET inventory analyzer through the installed discovery runtime.",
    inputSchema: {
      type: "object",
      properties: {
        workspace_root: workspaceRootProperty,
        profile_path: profilePath,
        write,
        dry_run: dryRun,
      },
      required: ["workspace_root"],
      additionalProperties: false,
    },
  },
  {
    name: "run_discovery_vsto_analyzer",
    description:
      "Run the fixed Office VSTO inventory analyzer through the installed discovery runtime.",
    inputSchema: {
      type: "object",
      properties: {
        workspace_root: workspaceRootProperty,
        profile_path: profilePath,
        write,
        dry_run: dryRun,
      },
      required: ["workspace_root"],
      additionalProperties: false,
    },
  },
  {
    name: "run_discovery_scenario_generation",
    description:
      "Generate acceptance scenarios from the validated workspace for an acceptance kind and optional feature/client/mode/platform filters.",
    inputSchema: {
      type: "object",
      properties: {
        workspace_root: workspaceRootProperty,
        acceptance_kind: {
          type: "string",
          enum: ["legacy-characterization", "target-acceptance"],
          description: "Acceptance specification kind to generate.",
        },
        feature_ids: identifiers("Optional feature identifiers."),
        client_ids: identifiers("Optional client identifiers."),
        mode_ids: identifiers("Optional mode identifiers."),
        platform_ids: identifiers("Optional platform identifiers."),
        output_format: {
          type: "string",
          enum: [...DISCOVERY_OUTPUT_FORMATS],
          description: "Rendering format for generated scenarios.",
        },
        profile_path: profilePath,
        write,
        dry_run: dryRun,
      },
      required: ["workspace_root", "acceptance_kind"],
      additionalProperties: false,
    },
  },
  {
    name: "run_discovery_report",
    description:
      "Produce a coverage, parity or completion report over the validated workspace in an explicit whole-workspace mode.",
    inputSchema: {
      type: "object",
      properties: {
        workspace_root: workspaceRootProperty,
        report_type: {
          type: "string",
          enum: [...DISCOVERY_REPORT_TYPES],
          description: "Report kind.",
        },
        mode: {
          type: "string",
          enum: [...DISCOVERY_MODES],
          description:
            "Whole-workspace evaluation mode; defaults to structural.",
        },
        format: {
          type: "string",
          enum: ["json", "markdown", "both"],
          description: "Report representation; defaults to json.",
        },
        profile_path: profilePath,
        write,
      },
      required: ["workspace_root", "report_type"],
      additionalProperties: false,
    },
  },
  {
    name: "create_discovery_artifact",
    description:
      "Draft a feature contract or runtime scenario through the discovery runtime. The draft is validated prospectively; no arbitrary text is written.",
    inputSchema: {
      type: "object",
      properties: {
        workspace_root: workspaceRootProperty,
        artifact_kind: {
          type: "string",
          enum: [...CREATE_ARTIFACT_KINDS],
          description: "Draft kind.",
        },
        feature_id: {
          type: "string",
          description: "Feature identifier (feature-contract).",
        },
        name: {
          type: "string",
          description: "Feature name (feature-contract).",
        },
        capability_group: {
          type: "string",
          description: "Optional capability group.",
        },
        scenario_id: {
          type: "string",
          description: "Scenario identifier (runtime-scenario).",
        },
        feature_ids: identifiers(
          "Covered feature identifiers (runtime-scenario).",
        ),
        input_path: {
          type: "string",
          description: "Optional workspace-relative proposal input path.",
        },
        profile_path: profilePath,
        invocation_ref: invocationRef,
        authorization_ref: authorizationRef,
        write,
        dry_run: dryRun,
      },
      required: ["workspace_root", "artifact_kind"],
      additionalProperties: false,
    },
  },
  {
    name: "update_discovery_artifact",
    description:
      "Replace one artifact by compare-and-swap after prospective validation, or approve a product decision with identity and evidence.",
    inputSchema: {
      type: "object",
      properties: {
        workspace_root: workspaceRootProperty,
        artifact_kind: {
          type: "string",
          enum: [...DISCOVERY_ARTIFACT_KINDS],
          description: "Artifact kind being updated.",
        },
        artifact_path: {
          type: "string",
          description: "Workspace-relative artifact path.",
        },
        input_path: {
          type: "string",
          description: "Workspace-relative proposal input path.",
        },
        expected_sha256: {
          type: ["string", "null"],
          description:
            "Digest of the current artifact, or null for exclusive creation.",
        },
        update_action: {
          type: "string",
          enum: [...UPDATE_ACTIONS],
          description: "replace or approve-decision.",
        },
        artifact_id: {
          type: "string",
          description: "Artifact identifier (approval).",
        },
        approval_owner: {
          type: "string",
          description: "Decision owner identifier (approval).",
        },
        approval_evidence_refs: identifiers(
          "Evidence reference identifiers (approval).",
        ),
        profile_path: profilePath,
        invocation_ref: invocationRef,
        authorization_ref: authorizationRef,
        write,
        dry_run: dryRun,
      },
      required: [
        "workspace_root",
        "artifact_kind",
        "artifact_path",
        "input_path",
        "expected_sha256",
        "update_action",
      ],
      additionalProperties: false,
    },
  },
  {
    name: "link_discovery_evidence",
    description:
      "Link captured evidence to one artifact identity after validating the evidence payload and the target digest.",
    inputSchema: {
      type: "object",
      properties: {
        workspace_root: workspaceRootProperty,
        artifact_kind: {
          type: "string",
          enum: [...DISCOVERY_ARTIFACT_KINDS],
          description: "Target artifact kind.",
        },
        artifact_id: {
          type: "string",
          description: "Target artifact identifier.",
        },
        evidence_path: {
          type: "string",
          description: "Workspace-relative evidence path.",
        },
        expected_sha256: {
          type: "string",
          description: "Digest of the current target artifact.",
        },
        profile_path: profilePath,
        invocation_ref: invocationRef,
        authorization_ref: authorizationRef,
        write,
        dry_run: dryRun,
      },
      required: [
        "workspace_root",
        "artifact_kind",
        "artifact_id",
        "evidence_path",
        "expected_sha256",
      ],
      additionalProperties: false,
    },
  },
  ...DISCOVERY_AUTHORITY_TOOL_DEFINITIONS,
];
