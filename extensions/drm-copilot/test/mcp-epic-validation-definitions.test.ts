import { describe, expect, it } from "@jest/globals";

import { toolDefinitions } from "../src/mcp-tool-definitions";
import { REPO_AUTOMATION_TOOL_DEFINITIONS } from "../src/mcp-repo-automation-tool-definitions";

describe("epic validation MCP definitions", () => {
  it("keeps both definition surfaces aligned for epic artifacts and gates", () => {
    const definitions = [
      toolDefinitions.find(
        ({ name }) => name === "validate_orchestration_artifacts",
      ),
      REPO_AUTOMATION_TOOL_DEFINITIONS.find(
        ({ name }) => name === "validate_orchestration_artifacts",
      ),
    ];

    for (const definition of definitions) {
      const properties = definition?.inputSchema.properties as
        Record<string, { type?: string; enum?: string[] }> | undefined;
      expect(properties?.["artifact_type"]?.enum).toEqual(
        expect.arrayContaining([
          "epic-orchestrator-state",
          "epic-planner-state",
          "epic-kickoff",
        ]),
      );
      expect(properties?.["require_codex_model_routing"]?.type).toBe("boolean");
      expect(properties?.["require_codex_topology"]?.type).toBe("boolean");
      expect(properties?.["require_ready_for_execution"]?.type).toBe("boolean");
    }
  });
});
