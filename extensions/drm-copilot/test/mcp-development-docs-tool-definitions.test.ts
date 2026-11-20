import { describe, expect, it } from "@jest/globals";

import { DEVELOPMENT_DOCS_TOOL_DEFINITIONS } from "../src/mcp-development-docs-tool-definitions";
import { REPO_AUTOMATION_TOOL_DEFINITIONS } from "../src/mcp-repo-automation-tool-definitions";
import { toolDefinitions } from "../src/mcp-tool-definitions";
import { REPO_AUTOMATION_TOOLS } from "../src/repo-automation-tool-names";

describe("DEVELOPMENT_DOCS_TOOL_DEFINITIONS", () => {
  const definition = DEVELOPMENT_DOCS_TOOL_DEFINITIONS[0];

  it("defines migrate_development_docs with the four input properties", () => {
    expect(DEVELOPMENT_DOCS_TOOL_DEFINITIONS).toHaveLength(1);
    expect(definition?.name).toBe("migrate_development_docs");
    expect(
      Object.keys(definition?.inputSchema.properties ?? {}).sort(),
    ).toEqual([
      "mode",
      "rename_decisions_path",
      "report_directory",
      "workspace_root",
    ]);
    expect(definition?.inputSchema.properties["mode"]).toMatchObject({
      enum: ["dry-run", "apply"],
    });
  });

  it("requires workspace_root and mode and forbids additional properties", () => {
    expect(definition?.inputSchema.required).toEqual([
      "workspace_root",
      "mode",
    ]);
    expect(definition?.inputSchema.additionalProperties).toBe(false);
  });

  it("spreads the same object into both definition lists directly before the docs tools", () => {
    for (const surface of [REPO_AUTOMATION_TOOL_DEFINITIONS, toolDefinitions]) {
      const index = surface.findIndex(
        (entry) => entry.name === "migrate_development_docs",
      );
      expect(surface[index]).toBe(definition);
      expect(surface[index + 1]?.name).toBe("run_docs_check");
    }
    expect(REPO_AUTOMATION_TOOLS.indexOf("migrate_development_docs") + 1).toBe(
      REPO_AUTOMATION_TOOLS.indexOf("run_docs_check"),
    );
  });
});
