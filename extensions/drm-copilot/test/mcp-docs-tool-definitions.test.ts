/**
 * Tests for the docs MCP tool definitions and annotations (issue #1036).
 */

import { describe, expect, it } from "@jest/globals";

import {
  DOCS_MUTATING_TOOLS,
  DOCS_TOOL_DEFINITIONS,
} from "../src/mcp-docs-tool-definitions";
import { REPO_AUTOMATION_TOOL_DEFINITIONS } from "../src/mcp-repo-automation-tool-definitions";
import { toolDefinitions } from "../src/mcp-tool-definitions";
import {
  DOCS_ACTOR_KINDS,
  DOCS_DIMENSION_STATES,
  DOCS_DIMENSIONS,
  DOCS_DISPOSITIONS,
  DOCS_LEDGER_OPERATIONS,
  DOCS_VALIDATE_MODES,
} from "../src/mcp-tool-inputs-docs";

const DOCS_TOOL_NAMES = [
  "run_docs_check",
  "run_docs_inventory",
  "run_docs_coverage",
  "update_docs_ledger",
  "generate_docs_reference",
  "validate_docs_artifacts",
];

function propertiesOf(name: string): Readonly<Record<string, unknown>> {
  const found = DOCS_TOOL_DEFINITIONS.find((entry) => entry.name === name);
  if (found === undefined) {
    throw new Error(`No definition for ${name}.`);
  }
  return found.inputSchema.properties;
}

describe("DOCS_TOOL_DEFINITIONS", () => {
  it("defines the six docs tools in union order", () => {
    // Act
    const names = DOCS_TOOL_DEFINITIONS.map((entry) => entry.name);

    // Assert
    expect(names).toEqual(DOCS_TOOL_NAMES);
  });

  it("closes every input schema and requires workspace_root", () => {
    for (const entry of DOCS_TOOL_DEFINITIONS) {
      // Assert
      expect(entry.inputSchema.type).toBe("object");
      expect(entry.inputSchema.additionalProperties).toBe(false);
      expect(entry.inputSchema.required?.[0]).toBe("workspace_root");
      expect(Object.keys(entry.inputSchema.properties)).toContain(
        "workspace_root",
      );
    }
    const required = Object.fromEntries(
      DOCS_TOOL_DEFINITIONS.map((entry) => [
        entry.name,
        entry.inputSchema.required,
      ]),
    );
    expect(required).toEqual({
      run_docs_check: ["workspace_root"],
      run_docs_inventory: ["workspace_root"],
      run_docs_coverage: ["workspace_root"],
      // Issue #1173: operation and operations are mutually exclusive, so neither is schema-required.
      update_docs_ledger: ["workspace_root", "actor_kind", "actor_id"],
      generate_docs_reference: ["workspace_root"],
      validate_docs_artifacts: ["workspace_root", "mode", "revision"],
    });
  });

  it("sets the read-only and destructive annotations", () => {
    for (const entry of DOCS_TOOL_DEFINITIONS) {
      // Arrange
      const expected =
        entry.name === "update_docs_ledger"
          ? { readOnlyHint: false, destructiveHint: true, openWorldHint: false }
          : { readOnlyHint: true, openWorldHint: false };

      // Assert
      expect({ name: entry.name, annotations: entry.annotations }).toEqual({
        name: entry.name,
        annotations: expected,
      });
    }
  });

  it("limits DOCS_MUTATING_TOOLS to update_docs_ledger and to definitions not marked read-only", () => {
    // Act
    const notReadOnly = DOCS_TOOL_DEFINITIONS.filter(
      (entry) => entry.annotations?.readOnlyHint !== true,
    ).map((entry) => entry.name);

    // Assert
    expect([...DOCS_MUTATING_TOOLS]).toEqual(["update_docs_ledger"]);
    expect(notReadOnly).toEqual([...DOCS_MUTATING_TOOLS]);
  });

  it("gives only update_docs_ledger a write field and no tool a write_receipt or output field", () => {
    for (const entry of DOCS_TOOL_DEFINITIONS) {
      // Arrange
      const keys = Object.keys(entry.inputSchema.properties);

      // Assert
      expect(keys.includes("write")).toBe(entry.name === "update_docs_ledger");
      expect(keys).not.toContain("write_receipt");
      expect(keys).not.toContain("output");
      expect(keys).not.toContain("output_file");
    }
  });

  it("advertises enums equal to the resolver constants", () => {
    // Arrange
    const ledger = propertiesOf("update_docs_ledger");
    const validate = propertiesOf("validate_docs_artifacts");
    const expected: ReadonlyArray<
      readonly [
        Readonly<Record<string, unknown>>,
        string,
        ReadonlyArray<string>,
      ]
    > = [
      [ledger, "operation", DOCS_LEDGER_OPERATIONS],
      [ledger, "disposition", DOCS_DISPOSITIONS],
      [ledger, "dimension", DOCS_DIMENSIONS],
      [ledger, "state", DOCS_DIMENSION_STATES],
      [ledger, "actor_kind", DOCS_ACTOR_KINDS],
      [validate, "mode", DOCS_VALIDATE_MODES],
    ];

    for (const [properties, field, values] of expected) {
      // Assert
      expect({ field, schema: properties[field] }).toEqual({
        field,
        schema: expect.objectContaining({ type: "string", enum: [...values] }),
      });
    }
    expect(ledger["pages"]).toEqual(
      expect.objectContaining({ type: "array", uniqueItems: true }),
    );
    expect(ledger["write"]).toEqual(
      expect.objectContaining({ type: "boolean", default: false }),
    );
    expect(propertiesOf("run_docs_check")["paths"]).not.toHaveProperty(
      "uniqueItems",
    );
  });

  it("spreads the same definition objects into both definition surfaces", () => {
    // Arrange
    const surfaces: ReadonlyArray<
      readonly [string, ReadonlyArray<{ readonly name: string }>]
    > = [
      ["REPO_AUTOMATION_TOOL_DEFINITIONS", REPO_AUTOMATION_TOOL_DEFINITIONS],
      ["toolDefinitions", toolDefinitions],
    ];

    for (const [label, surface] of surfaces) {
      // Act
      const start = surface.findIndex(
        (entry) => entry.name === "run_docs_check",
      );
      const slice = surface.slice(start, start + DOCS_TOOL_DEFINITIONS.length);

      // Assert
      expect({ label, start: start >= 0 }).toEqual({ label, start: true });
      expect({
        label,
        sameObjects: slice.every(
          (entry, index) => entry === DOCS_TOOL_DEFINITIONS[index],
        ),
      }).toEqual({ label, sameObjects: true });
      expect({
        label,
        next: surface[start + DOCS_TOOL_DEFINITIONS.length]?.name,
      }).toEqual({
        label,
        next: "validate_discovery_artifacts",
      });
    }
  });
});

describe("update_docs_ledger operations schema (issue #1173 B2.5)", () => {
  it("advertises operations as an array of objects with a description", () => {
    // Act
    const schema = propertiesOf("update_docs_ledger")["operations"] as {
      readonly type: string;
      readonly items: { readonly type: string };
      readonly minItems: number;
      readonly description: string;
    };

    // Assert
    expect(schema.type).toBe("array");
    expect(schema.items.type).toBe("object");
    expect(schema.minItems).toBe(1);
    expect(schema.description).toContain("sync-refs");
  });
});
