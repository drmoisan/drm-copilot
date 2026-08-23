import { describe, expect, it } from "@jest/globals";

import { toolDefinitions } from "../src/mcp-tool-definitions";
import { workspaceRootProperty } from "../src/mcp-push-down-schema-properties";
import {
  VALIDATOR_ARTIFACT_TYPE_PROPERTY,
  VALIDATOR_FLAG_SCHEMA_PROPERTIES,
} from "../src/mcp-validator-catalog";

describe("independent MCP tool definition schema", () => {
  it("defines the exact closed validator schema from the canonical catalog", () => {
    const definition = toolDefinitions.find(
      ({ name }) => name === "validate_orchestration_artifacts",
    );

    expect(definition?.inputSchema).toEqual({
      type: "object",
      properties: {
        workspace_root: workspaceRootProperty,
        artifact_type: VALIDATOR_ARTIFACT_TYPE_PROPERTY,
        artifact_path: {
          type: "string",
          description:
            "Workspace-relative or absolute path to the artifact file.",
        },
        ...VALIDATOR_FLAG_SCHEMA_PROPERTIES,
      },
      required: ["workspace_root", "artifact_type", "artifact_path"],
      additionalProperties: false,
    });
  });

  it("contains every readiness, completion, and routing flag exactly once", () => {
    const definition = toolDefinitions.find(
      ({ name }) => name === "validate_orchestration_artifacts",
    );
    const properties = definition?.inputSchema.properties ?? {};
    const flagNames = Object.keys(VALIDATOR_FLAG_SCHEMA_PROPERTIES);

    expect(
      Object.keys(properties).filter((name) => flagNames.includes(name)),
    ).toEqual(flagNames);
    for (const flagName of flagNames) {
      expect(properties[flagName]).toEqual(
        VALIDATOR_FLAG_SCHEMA_PROPERTIES[flagName],
      );
    }
  });
});
