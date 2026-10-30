/**
 * Discovery entries of the repo-automation tool definitions.
 *
 * The discovery definitions close the union, appear on both definition
 * surfaces identically, and advertise the v2 input shapes.
 */

import { describe, expect, it } from "@jest/globals";

import { toolDefinitions } from "../src/mcp-tool-definitions";
import { REPO_AUTOMATION_TOOL_DEFINITIONS } from "../src/mcp-repo-automation-tool-definitions";
import { REPO_AUTOMATION_TOOLS } from "../src/repo-automation-tool-names";
import {
  DISCOVERY_ARTIFACT_TYPES,
  DISCOVERY_REPORT_TYPES,
} from "../src/mcp-tool-inputs-discovery";

const DISCOVERY_TOOL_NAMES = [
  "validate_discovery_artifacts",
  "run_discovery_init",
  "run_discovery_repo_inventory",
  "run_discovery_dotnet_analyzer",
  "run_discovery_vsto_analyzer",
  "run_discovery_scenario_generation",
  "run_discovery_report",
  "create_discovery_artifact",
  "update_discovery_artifact",
  "link_discovery_evidence",
  "configure_discovery_workspace",
  "transfer_discovery_snapshot",
  "import_discovery_inventory",
  "migrate_discovery_artifacts",
  "run_discovery_doctor",
  "read_discovery_source",
  "prepare_discovery_agent",
  "finalize_discovery_agent",
  "discovery_capability_sentinel",
] as const;

function findRepoDefinition(name: string) {
  return REPO_AUTOMATION_TOOL_DEFINITIONS.find(
    (definition) => definition.name === name,
  );
}

function findBaseDefinition(name: string) {
  return toolDefinitions.find((definition) => definition.name === name);
}

describe("discovery MCP tool definitions", () => {
  it("keeps the definition list aligned with the widened union order", () => {
    const definitionNames = REPO_AUTOMATION_TOOL_DEFINITIONS.map(
      (definition) => definition.name,
    );

    expect(definitionNames).toEqual([...REPO_AUTOMATION_TOOLS]);
    expect(definitionNames.slice(-19)).toEqual([...DISCOVERY_TOOL_NAMES]);
  });

  it.each(DISCOVERY_TOOL_NAMES)(
    "defines %s in both definition files with additionalProperties:false and workspace_root",
    (toolName) => {
      for (const definition of [
        findRepoDefinition(toolName),
        findBaseDefinition(toolName),
      ]) {
        expect(definition).toBeDefined();
        expect(definition?.inputSchema.additionalProperties).toBe(false);
        expect(definition?.inputSchema.properties).toHaveProperty(
          "workspace_root",
        );
      }
    },
  );

  it("requires artifact_type and artifact_path for validate_discovery_artifacts and matches the resolver enum", () => {
    const definition = findRepoDefinition("validate_discovery_artifacts");
    expect(definition?.inputSchema.required).toEqual([
      "workspace_root",
      "artifact_type",
      "artifact_path",
    ]);
    const properties = definition?.inputSchema.properties as Record<
      string,
      { enum?: string[] }
    >;
    expect(properties["artifact_type"]?.enum).toEqual([
      ...DISCOVERY_ARTIFACT_TYPES,
    ]);
  });

  it("requires workspace_root and the explicit system identity for run_discovery_init", () => {
    expect(
      findRepoDefinition("run_discovery_init")?.inputSchema.required,
    ).toEqual([
      "workspace_root",
      "system_id",
      "system_name",
      "system_role",
      "repository_id",
    ]);
    expect(
      findRepoDefinition("run_discovery_init")?.inputSchema.properties,
    ).not.toHaveProperty("target_dir");
  });

  it.each([
    "run_discovery_repo_inventory",
    "run_discovery_dotnet_analyzer",
    "run_discovery_vsto_analyzer",
  ])("requires only workspace_root for %s", (toolName) => {
    expect(findRepoDefinition(toolName)?.inputSchema.required).toEqual([
      "workspace_root",
    ]);
  });

  it("requires workspace_root and acceptance_kind for scenario generation", () => {
    const definition = findRepoDefinition("run_discovery_scenario_generation");
    expect(definition?.inputSchema.required).toEqual([
      "workspace_root",
      "acceptance_kind",
    ]);
    expect(definition?.inputSchema.properties).not.toHaveProperty(
      "feature_contract",
    );
  });

  it("requires workspace_root and report_type for run_discovery_report and matches the resolver report enum", () => {
    const definition = findRepoDefinition("run_discovery_report");
    expect(definition?.inputSchema.required).toEqual([
      "workspace_root",
      "report_type",
    ]);
    const properties = definition?.inputSchema.properties as Record<
      string,
      { enum?: string[] }
    >;
    expect(properties["report_type"]?.enum).toEqual([
      ...DISCOVERY_REPORT_TYPES,
    ]);
    expect(properties["report_type"]?.enum).toEqual([
      "coverage",
      "parity",
      "completion",
    ]);
    // Reports derive from the validated workspace; the retired input paths are gone.
    expect(definition?.inputSchema.properties).toHaveProperty("mode");
    expect(definition?.inputSchema.properties).toHaveProperty("format");
    expect(definition?.inputSchema.properties).not.toHaveProperty("input_path");
    expect(definition?.inputSchema.properties).not.toHaveProperty(
      "coverage_input",
    );
  });

  it.each(DISCOVERY_TOOL_NAMES)(
    "keeps the base and repo-automation definitions aligned for %s",
    (toolName) => {
      expect(findBaseDefinition(toolName)).toEqual(
        findRepoDefinition(toolName),
      );
    },
  );
});
