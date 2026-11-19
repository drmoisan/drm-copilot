/**
 * Tests of the push-down integration tool definitions (issue #1051, S23, S32,
 * S34, S43).
 */

import {
  PUSH_DOWN_INTEGRATION_TOOL_DEFINITIONS,
  type PushDownIntegrationToolDefinition,
} from "../src/mcp-push-down-integration-tool-definitions";
import { workspaceRootProperty } from "../src/mcp-push-down-schema-properties";
import {
  REPO_AUTOMATION_TOOL_DEFINITIONS,
  type ToolDefinition,
} from "../src/mcp-repo-automation-tool-definitions";
import { toolDefinitions } from "../src/mcp-tool-definitions";

/** Return one tool's entry on a definition surface (issue #1051, S46). */
function surfaceEntry(
  surface: ReadonlyArray<ToolDefinition>,
  name: string,
): ToolDefinition {
  const found = surface.find((entry) => entry.name === name);
  if (found === undefined) {
    throw new Error(`missing surface entry ${name}`);
  }
  return found;
}

/** True when two surface entries have identical input schemas and annotations. */
function sameSurfaceShape(
  left: Pick<ToolDefinition, "inputSchema" | "annotations">,
  right: Pick<ToolDefinition, "inputSchema" | "annotations">,
): boolean {
  return (
    JSON.stringify(left.inputSchema) === JSON.stringify(right.inputSchema) &&
    JSON.stringify(left.annotations) === JSON.stringify(right.annotations)
  );
}

/** Return the definition of one tool. */
function definitionOf(name: string): PushDownIntegrationToolDefinition {
  const found = PUSH_DOWN_INTEGRATION_TOOL_DEFINITIONS.find(
    (entry) => entry.name === name,
  );
  if (found === undefined) {
    throw new Error(`missing definition ${name}`);
  }
  return found;
}

/** True when the input schema is exactly `{ workspace_root }`, required, closed. */
function isWorkspaceRootOnly(
  definition: Pick<PushDownIntegrationToolDefinition, "inputSchema">,
): boolean {
  const schema = definition.inputSchema;
  return (
    schema.type === "object" &&
    JSON.stringify(Object.keys(schema.properties)) === '["workspace_root"]' &&
    schema.properties["workspace_root"] === workspaceRootProperty &&
    JSON.stringify(schema.required) === '["workspace_root"]' &&
    schema.additionalProperties === false
  );
}

/** True when the annotations are read-only and closed-world. */
function isReadOnlyClosedWorld(
  definition: Pick<PushDownIntegrationToolDefinition, "annotations">,
): boolean {
  return (
    definition.annotations?.readOnlyHint === true &&
    definition.annotations.openWorldHint === false
  );
}

/** Copies of a definition that each break one schema condition. */
function schemaViolations(
  definition: PushDownIntegrationToolDefinition,
): Array<Pick<PushDownIntegrationToolDefinition, "inputSchema">> {
  const schema = definition.inputSchema;
  return [
    {
      inputSchema: {
        ...schema,
        properties: { ...schema.properties, extra: { type: "string" } },
      },
    },
    { inputSchema: { ...schema, required: [] } },
    {
      inputSchema: {
        ...schema,
        properties: { workspace_root: { type: "string" } },
      },
    },
  ];
}

/** Copies of a definition that each drop or flip one annotation hint. */
function annotationViolations(
  definition: PushDownIntegrationToolDefinition,
): Array<Pick<PushDownIntegrationToolDefinition, "annotations">> {
  return [
    { annotations: { openWorldHint: false } },
    { annotations: { readOnlyHint: true } },
    { annotations: { ...definition.annotations, readOnlyHint: false } },
    { annotations: { ...definition.annotations, openWorldHint: true } },
    {},
  ];
}

describe("push-down integration tool definitions", () => {
  it("defines detect then validate", () => {
    expect(
      PUSH_DOWN_INTEGRATION_TOOL_DEFINITIONS.map((entry) => entry.name),
    ).toEqual([
      "detect_push_down_integration",
      "validate_push_down_integration",
    ]);
  });

  it("S23 positive: detect takes only a required workspace_root and rejects other properties", () => {
    expect(
      isWorkspaceRootOnly(definitionOf("detect_push_down_integration")),
    ).toBe(true);
  });

  it("S23 negative: a detect schema copy with an extra property, no required list, or another property schema is detected", () => {
    for (const copy of schemaViolations(
      definitionOf("detect_push_down_integration"),
    )) {
      expect(isWorkspaceRootOnly(copy)).toBe(false);
    }
  });

  it("S34 positive: validate has the same input schema as detect", () => {
    const validate = definitionOf("validate_push_down_integration");

    expect(isWorkspaceRootOnly(validate)).toBe(true);
    expect(validate.inputSchema).toEqual(
      definitionOf("detect_push_down_integration").inputSchema,
    );
  });

  it("S34 negative: a validate schema copy that breaks one condition is detected", () => {
    for (const copy of schemaViolations(
      definitionOf("validate_push_down_integration"),
    )) {
      expect(isWorkspaceRootOnly(copy)).toBe(false);
    }
  });

  it("S32 positive: detect carries readOnlyHint true and openWorldHint false", () => {
    expect(
      isReadOnlyClosedWorld(definitionOf("detect_push_down_integration")),
    ).toBe(true);
  });

  it("S32 negative: a detect copy that drops or flips a hint is detected", () => {
    for (const copy of annotationViolations(
      definitionOf("detect_push_down_integration"),
    )) {
      expect(isReadOnlyClosedWorld(copy)).toBe(false);
    }
  });

  it("S43 positive: validate carries readOnlyHint true and openWorldHint false", () => {
    expect(
      isReadOnlyClosedWorld(definitionOf("validate_push_down_integration")),
    ).toBe(true);
  });

  it("S46 positive: both definition surfaces carry identical input schemas and annotations", () => {
    for (const definition of PUSH_DOWN_INTEGRATION_TOOL_DEFINITIONS) {
      const repo = surfaceEntry(
        REPO_AUTOMATION_TOOL_DEFINITIONS,
        definition.name,
      );
      const tools = surfaceEntry(toolDefinitions, definition.name);

      expect(sameSurfaceShape(repo, tools)).toBe(true);
    }
  });

  it("S46 negative: a surface copy with one altered property is detected", () => {
    const repo = surfaceEntry(
      REPO_AUTOMATION_TOOL_DEFINITIONS,
      "detect_push_down_integration",
    );
    const alteredSchema = {
      ...repo,
      inputSchema: {
        ...repo.inputSchema,
        properties: { workspace_root: { type: "string" } },
      },
    };
    const alteredHint = {
      ...repo,
      annotations: { ...repo.annotations, openWorldHint: true },
    };

    expect(sameSurfaceShape(repo, alteredSchema)).toBe(false);
    expect(sameSurfaceShape(repo, alteredHint)).toBe(false);
  });

  it("S43 negative: a validate copy that drops or flips a hint is detected", () => {
    for (const copy of annotationViolations(
      definitionOf("validate_push_down_integration"),
    )) {
      expect(isReadOnlyClosedWorld(copy)).toBe(false);
    }
  });
});
