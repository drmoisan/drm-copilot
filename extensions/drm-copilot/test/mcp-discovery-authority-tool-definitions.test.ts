/**
 * Advertised schema contract for every discovery MCP tool.
 *
 * The definitions must appear in union order, require workspace_root, close
 * their properties, carry no retired or open-ended input, draw every enum from
 * the resolver constants and declare exact required lists.
 */

import { describe, expect, it } from "@jest/globals";

import { DISCOVERY_SKILL_IDS } from "../src/discovery-routing";
import { DISCOVERY_TOOL_DEFINITIONS } from "../src/mcp-discovery-tool-definitions";
import type { ToolDefinition } from "../src/mcp-repo-automation-tool-definitions";
import {
  ACCEPTANCE_KINDS,
  CREATE_ARTIFACT_KINDS,
  DISCOVERY_ARTIFACT_KINDS,
  DISCOVERY_MODES,
  DISCOVERY_OUTPUT_FORMATS,
  REPORT_FORMATS,
  SYSTEM_ROLES,
  UPDATE_ACTIONS,
} from "../src/mcp-tool-inputs-discovery";
import {
  COMPLEXITY_BANDS,
  CONFIGURATION_ACTIONS,
  EXECUTION_CONTEXTS,
  READ_OPERATIONS,
  TRANSFER_DIRECTIONS,
} from "../src/mcp-tool-inputs-discovery-authority";
import { REPO_AUTOMATION_TOOLS } from "../src/repo-automation-tool-names";

const RETIRED_PROPERTIES = [
  "target_dir",
  "template_root",
  "force",
  "output_dir",
  "output_path",
  "coverage_input",
  "parity_input",
  "feature_contract",
  "parity_matrix",
  "runtime_characterization",
  "check",
  "command",
  "module",
  "receipt_path",
  "destination_path",
];

function definition(name: string) {
  const found = DISCOVERY_TOOL_DEFINITIONS.find((entry) => entry.name === name);
  if (found === undefined) {
    throw new Error(`missing definition ${name}`);
  }
  return found;
}

function enumOf(name: string, property: string): string[] | undefined {
  return (
    definition(name).inputSchema.properties as Record<
      string,
      { enum?: string[] }
    >
  )[property]?.enum;
}

describe("discovery tool definitions", () => {
  it("advertises all eighteen discovery tools in union order", () => {
    const start = REPO_AUTOMATION_TOOLS.indexOf("validate_discovery_artifacts");
    expect(DISCOVERY_TOOL_DEFINITIONS.map((entry) => entry.name)).toEqual(
      REPO_AUTOMATION_TOOLS.slice(start),
    );
    expect(DISCOVERY_TOOL_DEFINITIONS).toHaveLength(18);
    expect(REPO_AUTOMATION_TOOLS).toHaveLength(42);
  });

  it.each(
    DISCOVERY_TOOL_DEFINITIONS.map(
      (entry) => [entry.name, entry] as [string, ToolDefinition],
    ),
  )(
    "%s requires workspace_root, closes its properties and carries no retired input",
    (_name, entry) => {
      expect(entry.inputSchema.additionalProperties).toBe(false);
      expect(entry.inputSchema.required).toContain("workspace_root");
      for (const retired of RETIRED_PROPERTIES) {
        expect(entry.inputSchema.properties).not.toHaveProperty(retired);
      }
    },
  );

  it.each([
    [
      "configure_discovery_workspace",
      "configuration_action",
      CONFIGURATION_ACTIONS,
    ],
    ["transfer_discovery_snapshot", "direction", TRANSFER_DIRECTIONS],
    ["read_discovery_source", "read_operation", READ_OPERATIONS],
    ["prepare_discovery_agent", "skill_id", DISCOVERY_SKILL_IDS],
    ["prepare_discovery_agent", "execution_context", EXECUTION_CONTEXTS],
    ["prepare_discovery_agent", "complexity", COMPLEXITY_BANDS],
    [
      "prepare_discovery_agent",
      "orchestration_complexity_ceiling",
      COMPLEXITY_BANDS,
    ],
    ["update_discovery_artifact", "artifact_kind", DISCOVERY_ARTIFACT_KINDS],
    ["update_discovery_artifact", "update_action", UPDATE_ACTIONS],
    ["link_discovery_evidence", "artifact_kind", DISCOVERY_ARTIFACT_KINDS],
    ["create_discovery_artifact", "artifact_kind", CREATE_ARTIFACT_KINDS],
    ["run_discovery_init", "system_role", SYSTEM_ROLES],
    ["migrate_discovery_artifacts", "system_role", SYSTEM_ROLES],
    ["validate_discovery_artifacts", "mode", DISCOVERY_MODES],
    ["run_discovery_report", "mode", DISCOVERY_MODES],
    ["run_discovery_report", "format", REPORT_FORMATS],
    ["run_discovery_scenario_generation", "acceptance_kind", ACCEPTANCE_KINDS],
    [
      "run_discovery_scenario_generation",
      "output_format",
      DISCOVERY_OUTPUT_FORMATS,
    ],
  ] as const)(
    "%s.%s enum equals the resolver constant",
    (name, property, values) => {
      expect(enumOf(name, property)).toEqual([...values]);
    },
  );

  it.each([
    [
      "configure_discovery_workspace",
      ["workspace_root", "configuration_action"],
    ],
    ["create_discovery_artifact", ["workspace_root", "artifact_kind"]],
    [
      "update_discovery_artifact",
      [
        "workspace_root",
        "artifact_kind",
        "artifact_path",
        "input_path",
        "expected_sha256",
        "update_action",
      ],
    ],
    [
      "link_discovery_evidence",
      [
        "workspace_root",
        "artifact_kind",
        "artifact_id",
        "evidence_path",
        "expected_sha256",
      ],
    ],
    ["transfer_discovery_snapshot", ["workspace_root", "direction"]],
    ["import_discovery_inventory", ["workspace_root", "manifest_path"]],
    [
      "migrate_discovery_artifacts",
      [
        "workspace_root",
        "destination",
        "system_id",
        "system_name",
        "system_role",
        "repository_id",
      ],
    ],
    ["run_discovery_doctor", ["workspace_root"]],
    ["read_discovery_source", ["workspace_root", "read_operation", "paths"]],
    [
      "prepare_discovery_agent",
      [
        "workspace_root",
        "skill_id",
        "selected_ids",
        "paths",
        "expected_outputs",
        "execution_context",
        "complexity",
      ],
    ],
    // request_id is optional: a discovery agent omits it and the receipt
    // correlation comes from the host gate's consumed authorization reference.
    ["finalize_discovery_agent", ["workspace_root", "invocation_ref"]],
  ])("%s requires exactly %j", (name, required) => {
    expect(definition(name).inputSchema.required).toEqual(required);
  });

  it("finalize_discovery_agent still declares request_id as an optional string property", () => {
    const properties = definition("finalize_discovery_agent").inputSchema
      .properties as Record<string, { type?: string } | undefined>;
    expect(properties["request_id"]?.type).toBe("string");
  });
});
