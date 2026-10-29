import { type ToolDefinition } from "./mcp-repo-automation-tool-definitions";
import { workspaceRootProperty } from "./mcp-push-down-schema-properties";
import {
  COMPLEXITY_BANDS,
  CONFIGURATION_ACTIONS,
  EXECUTION_CONTEXTS,
  READ_OPERATIONS,
  SKILL_IDS,
  TRANSFER_DIRECTIONS,
} from "./mcp-tool-inputs-discovery-authority";
import { SYSTEM_ROLES } from "./mcp-tool-inputs-discovery";

/**
 * Tool definitions for the root-authority and agent-lifecycle discovery tools:
 * configure, transfer, import, migrate, doctor, read, prepare, finalize and the
 * capability sentinel. Prepare and every controlled root call consume the root
 * grant the native host gate issued; no tool accepts an identity, a capability
 * assertion, a receipt destination or a success claim. Enums are drawn from the
 * authority input resolver constants.
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
const stringList = (description: string) => ({
  type: "array",
  items: { type: "string" },
  description,
});

export const DISCOVERY_AUTHORITY_TOOL_DEFINITIONS: ReadonlyArray<ToolDefinition> =
  [
    {
      name: "configure_discovery_workspace",
      description:
        "Activate or deactivate discovery for the workspace through the root configuration operation. Root-only; the protected activation record is written outside the workspace.",
      inputSchema: {
        type: "object",
        properties: {
          workspace_root: workspaceRootProperty,
          configuration_action: {
            type: "string",
            enum: [...CONFIGURATION_ACTIONS],
            description: "activate or deactivate.",
          },
          input_path: {
            type: "string",
            description:
              "Workspace-relative profile to activate; not accepted for deactivate.",
          },
          profile_path: profilePath,
          dry_run: dryRun,
        },
        required: ["workspace_root", "configuration_action"],
        additionalProperties: false,
      },
    },
    {
      name: "transfer_discovery_snapshot",
      description:
        "Export selected discovery identities to a snapshot manifest, or import a snapshot manifest. Root-only; the direction enum is closed.",
      inputSchema: {
        type: "object",
        properties: {
          workspace_root: workspaceRootProperty,
          direction: {
            type: "string",
            enum: [...TRANSFER_DIRECTIONS],
            description: "export or import.",
          },
          selected_ids: stringList("Identities to export (export)."),
          paths: stringList(
            "Optional workspace-relative paths to export (export).",
          ),
          manifest_path: {
            type: "string",
            description: "Workspace-relative snapshot manifest path (import).",
          },
          profile_path: profilePath,
          write,
          dry_run: dryRun,
        },
        required: ["workspace_root", "direction"],
        additionalProperties: false,
      },
    },
    {
      name: "import_discovery_inventory",
      description:
        "Import an inventory snapshot manifest into the configured workspace. Root-only.",
      inputSchema: {
        type: "object",
        properties: {
          workspace_root: workspaceRootProperty,
          manifest_path: {
            type: "string",
            description: "Workspace-relative inventory manifest path.",
          },
          profile_path: profilePath,
          write,
          dry_run: dryRun,
        },
        required: ["workspace_root", "manifest_path"],
        additionalProperties: false,
      },
    },
    {
      name: "migrate_discovery_artifacts",
      description:
        "Migrate v1 discovery artifacts to v2 under an explicit destination and system identity. Root-only; exactly one of input_path or paths selects the source.",
      inputSchema: {
        type: "object",
        properties: {
          workspace_root: workspaceRootProperty,
          destination: {
            type: "string",
            description:
              "Workspace-relative destination root for v2 artifacts.",
          },
          system_id: { type: "string", description: "System identifier." },
          system_name: { type: "string", description: "System name." },
          system_role: {
            type: "string",
            enum: [...SYSTEM_ROLES],
            description: "Role of this repository in the migration.",
          },
          repository_id: {
            type: "string",
            description: "Repository identifier.",
          },
          input_path: {
            type: "string",
            description: "Workspace-relative v1 source file.",
          },
          paths: stringList("Workspace-relative v1 source paths."),
          production_roots: stringList("Workspace-relative production roots."),
          test_roots: stringList("Workspace-relative test roots."),
          draft: {
            type: "boolean",
            description: "When true, migrate into a draft profile.",
          },
          profile_path: profilePath,
          write,
          dry_run: dryRun,
        },
        required: [
          "workspace_root",
          "destination",
          "system_id",
          "system_name",
          "system_role",
          "repository_id",
        ],
        additionalProperties: false,
      },
    },
    {
      name: "run_discovery_doctor",
      description:
        "Report read-only runtime, activation and capability diagnostics for the workspace. Available to every caller; it grants nothing.",
      inputSchema: {
        type: "object",
        properties: {
          workspace_root: workspaceRootProperty,
          profile_path: profilePath,
        },
        required: ["workspace_root"],
        additionalProperties: false,
      },
    },
    {
      name: "read_discovery_source",
      description:
        "List, read or search bounded source under the configured roots. Returns normalized paths, digests, line ranges and bounded text; never resolves outside the workspace or writes.",
      inputSchema: {
        type: "object",
        properties: {
          workspace_root: workspaceRootProperty,
          read_operation: {
            type: "string",
            enum: [...READ_OPERATIONS],
            description: "list, read or search.",
          },
          paths: stringList("Workspace-relative paths to inspect."),
          query: {
            type: "string",
            description:
              "Search text (search only); literal unless regex is true.",
          },
          regex: {
            type: "boolean",
            description:
              "Interpret query as a bounded regular expression (search only).",
          },
          max_bytes: {
            type: "integer",
            description: "Maximum bytes to return.",
          },
          line_start: {
            type: "integer",
            description: "First line to return (read only).",
          },
          line_end: {
            type: "integer",
            description: "Last line to return (read only).",
          },
          profile_path: profilePath,
          invocation_ref: {
            type: "string",
            description:
              "Protected invocation reference when reading as a discovery agent.",
          },
          authorization_ref: {
            type: "string",
            description: "One-use native tool authorization reference.",
          },
        },
        required: ["workspace_root", "read_operation", "paths"],
        additionalProperties: false,
      },
    },
    {
      name: "prepare_discovery_agent",
      description:
        "Prepare a constrained discovery invocation for one skill: route through the existing topology/model authority, persist protected bindings and return the exact launchable deployment. Root-only.",
      inputSchema: {
        type: "object",
        properties: {
          workspace_root: workspaceRootProperty,
          skill_id: {
            type: "string",
            enum: [...SKILL_IDS],
            description: "One of the nine discovery skills.",
          },
          selected_ids: stringList("Selected artifact identities."),
          paths: stringList("Selected workspace-relative paths."),
          expected_outputs: {
            type: "array",
            items: { type: "object" },
            description:
              "Required output rows: artifact_kind, id, path, format, expected_sha256.",
          },
          execution_context: {
            type: "string",
            enum: [...EXECUTION_CONTEXTS],
            description: "Delegation context.",
          },
          complexity: {
            type: "string",
            enum: [...COMPLEXITY_BANDS],
            description: "Assessed complexity band.",
          },
          orchestration_complexity_ceiling: {
            type: "string",
            enum: [...COMPLEXITY_BANDS],
            description:
              "Optional ceiling; defaults to the assessed complexity.",
          },
          profile_path: profilePath,
        },
        required: [
          "workspace_root",
          "skill_id",
          "selected_ids",
          "paths",
          "expected_outputs",
          "execution_context",
          "complexity",
        ],
        additionalProperties: false,
      },
    },
    {
      name: "finalize_discovery_agent",
      description:
        "Finalize the calling discovery agent's output: validate the protected invocation's required outputs through the runtime, recompute inputs and mint the protected receipt.",
      inputSchema: {
        type: "object",
        properties: {
          workspace_root: workspaceRootProperty,
          invocation_ref: {
            type: "string",
            description: "Protected invocation reference being finalized.",
          },
          request_id: {
            type: "string",
            description:
              "Correlation identifier recorded on the receipt. A discovery agent omits it: the host gate's consumed authorization reference is used, and a caller-supplied identity field is refused.",
          },
          profile_path: profilePath,
        },
        required: ["workspace_root", "invocation_ref"],
        additionalProperties: false,
      },
    },
    {
      name: "discovery_capability_sentinel",
      description:
        "Consume the one-use sentinel observation the native host gate recorded for this call and report whether the host attributed it to the capability sentinel agent. Evidence only; it grants nothing and never fails a call.",
      inputSchema: {
        type: "object",
        properties: {
          workspace_root: workspaceRootProperty,
        },
        required: ["workspace_root"],
        additionalProperties: false,
      },
    },
  ];
