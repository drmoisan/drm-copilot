import { describe, expect, it } from "@jest/globals";

import { toolDefinitions } from "../src/mcp-tool-definitions";
import { REPO_AUTOMATION_TOOL_DEFINITIONS } from "../src/mcp-repo-automation-tool-definitions";

/**
 * Alignment tests for the two MCP `validate_orchestration_artifacts` definition
 * surfaces.
 *
 * The extension surface (`toolDefinitions`) and the repo-automation surface
 * (`REPO_AUTOMATION_TOOL_DEFINITIONS`) must advertise the same
 * `artifact_type` enum; a value added to one and not the other produces a tool
 * that resolves in one host and is rejected in the other.
 */

interface ArtifactTypeProperty {
  readonly type?: string;
  readonly enum?: string[];
  readonly description?: string;
}

const PARALLEL_ARTIFACT_TYPES = [
  "parallel-orchestrator-state",
  "parallel-planner-state",
];

function schemaProperties(
  definitions: ReadonlyArray<{
    readonly name: string;
    readonly inputSchema: { readonly properties?: unknown };
  }>,
): Record<string, ArtifactTypeProperty> | undefined {
  const definition = definitions.find(
    ({ name }) => name === "validate_orchestration_artifacts",
  );
  return definition?.inputSchema.properties as
    Record<string, ArtifactTypeProperty> | undefined;
}

const extensionProperties = schemaProperties(toolDefinitions);
const repoAutomationProperties = schemaProperties(
  REPO_AUTOMATION_TOOL_DEFINITIONS,
);

describe("parallel validation MCP definitions", () => {
  it.each([
    ["extension", extensionProperties],
    ["repo automation", repoAutomationProperties],
  ])(
    "advertises both parallel artifact types on the %s surface",
    (_surface, properties) => {
      // Arrange / Act
      const artifactTypes = properties?.["artifact_type"]?.enum;

      // Assert
      expect(artifactTypes).toEqual(
        expect.arrayContaining(PARALLEL_ARTIFACT_TYPES),
      );
    },
  );

  it("keeps both definition surfaces byte-identical for artifact_type", () => {
    // Arrange / Act
    const extensionTypes = extensionProperties?.["artifact_type"]?.enum;
    const repoAutomationTypes =
      repoAutomationProperties?.["artifact_type"]?.enum;

    // Assert
    expect(extensionTypes).toEqual(repoAutomationTypes);
  });

  it.each([
    ["extension", extensionProperties],
    ["repo automation", repoAutomationProperties],
  ])(
    "names the parallel types in both gate descriptions on the %s surface",
    (_surface, properties) => {
      // Arrange / Act
      const requireComplete = properties?.["require_complete"];
      const requireReady = properties?.["require_ready_for_execution"];

      // Assert
      expect(requireComplete?.type).toBe("boolean");
      expect(requireComplete?.description).toContain(
        "parallel-orchestrator-state",
      );
      expect(requireReady?.type).toBe("boolean");
      expect(requireReady?.description).toContain("parallel-planner-state");
    },
  );

  it("keeps both gate descriptions aligned across surfaces", () => {
    // Arrange / Act / Assert
    expect(extensionProperties?.["require_complete"]?.description).toBe(
      repoAutomationProperties?.["require_complete"]?.description,
    );
    expect(
      extensionProperties?.["require_ready_for_execution"]?.description,
    ).toBe(
      repoAutomationProperties?.["require_ready_for_execution"]?.description,
    );
  });

  it("does not advertise an unplanned parallel kickoff artifact type", () => {
    // Arrange / Act / Assert
    expect(extensionProperties?.["artifact_type"]?.enum).not.toContain(
      "parallel-kickoff",
    );
    expect(repoAutomationProperties?.["artifact_type"]?.enum).not.toContain(
      "parallel-kickoff",
    );
  });
});
