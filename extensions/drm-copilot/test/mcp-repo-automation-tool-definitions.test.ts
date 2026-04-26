import { describe, expect, it } from "@jest/globals";

import { REPO_AUTOMATION_TOOL_DEFINITIONS } from "../src/mcp-repo-automation-tool-definitions";
import { REPO_AUTOMATION_TOOLS } from "../src/repo-automation-tool-names";

describe("repo automation MCP tool definitions", () => {
  it("defines one schema entry for every advertised repo automation tool", () => {
    const definitionNames = REPO_AUTOMATION_TOOL_DEFINITIONS.map(
      (definition) => definition.name,
    );

    expect(definitionNames).toEqual(REPO_AUTOMATION_TOOLS);
  });

  it("keeps the policy-audit asset selector schema aligned with the bundled asset tool", () => {
    const definition = REPO_AUTOMATION_TOOL_DEFINITIONS.find(
      ({ name }) => name === "resolve_policy_audit_template_asset",
    );

    expect(definition).toMatchObject({
      inputSchema: {
        required: ["asset"],
        properties: {
          asset: {
            type: "string",
          },
          target_path: {
            type: "string",
          },
        },
      },
    });
  });

  it("includes a push_down_claude_customizations definition with workspace_root and no additional properties", () => {
    const definition = REPO_AUTOMATION_TOOL_DEFINITIONS.find(
      ({ name }) => name === "push_down_claude_customizations",
    );

    expect(definition).toMatchObject({
      name: "push_down_claude_customizations",
      inputSchema: {
        properties: {
          workspace_root: expect.objectContaining({ type: "string" }),
        },
        additionalProperties: false,
      },
    });
  });
});
