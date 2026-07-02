import { describe, expect, it } from "@jest/globals";

import { toolDefinitions } from "../src/mcp-tool-definitions";
import { REPO_AUTOMATION_TOOL_DEFINITIONS } from "../src/mcp-repo-automation-tool-definitions";
import { REPO_AUTOMATION_TOOLS } from "../src/repo-automation-tool-names";

describe("repo automation MCP tool definitions", () => {
  it("exports resolve_policy_audit_template_asset as a repo automation tool", () => {
    expect(REPO_AUTOMATION_TOOLS).toContain(
      "resolve_policy_audit_template_asset",
    );
  });

  it("defines one schema entry for every advertised repo automation tool", () => {
    const definitionNames = REPO_AUTOMATION_TOOL_DEFINITIONS.map(
      (definition) => definition.name,
    );

    expect(definitionNames).toEqual(REPO_AUTOMATION_TOOLS);
  });

  it("keeps the policy-audit asset selector schema aligned with the bundled asset tool", () => {
    const repoAutomationDefinition = REPO_AUTOMATION_TOOL_DEFINITIONS.find(
      ({ name }) => name === "resolve_policy_audit_template_asset",
    );
    const baseDefinition = toolDefinitions.find(
      ({ name }) => name === "resolve_policy_audit_template_asset",
    );

    for (const definition of [repoAutomationDefinition, baseDefinition]) {
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
    }
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

  it("keeps Copilot push-down schemas workspace-root-only", () => {
    const repoDefinition = REPO_AUTOMATION_TOOL_DEFINITIONS.find(
      ({ name }) => name === "push_down_copilot_customizations",
    );
    const baseDefinition = toolDefinitions.find(
      ({ name }) => name === "push_down_copilot_customizations",
    );

    for (const definition of [repoDefinition, baseDefinition]) {
      expect(definition).toBeDefined();
      const properties = definition?.inputSchema.properties ?? {};
      expect(Object.keys(properties).sort()).toEqual(["workspace_root"]);
      expect(definition?.inputSchema.additionalProperties).toBe(false);
      expect(definition?.inputSchema.required).toBeUndefined();
    }
  });

  it("keeps both Codex MCP definition files aligned for optional selection fields", () => {
    const repoDefinition = REPO_AUTOMATION_TOOL_DEFINITIONS.find(
      ({ name }) => name === "push_down_codex_and_agents_customizations",
    );
    const baseDefinition = toolDefinitions.find(
      ({ name }) => name === "push_down_codex_and_agents_customizations",
    );

    for (const definition of [repoDefinition, baseDefinition]) {
      expect(definition).toMatchObject({
        inputSchema: {
          properties: {
            workspace_root: expect.objectContaining({ type: "string" }),
            packs: expect.objectContaining({ type: "array" }),
            csharp_variant: expect.objectContaining({
              type: "string",
              enum: ["modern", "legacy"],
            }),
            memory_mode: expect.objectContaining({
              type: "string",
              enum: ["overwrite", "merge", "skip"],
            }),
          },
          additionalProperties: false,
        },
      });
    }
  });

  it("includes a run_codex_native_converter definition with the required converter fields", () => {
    const definition = REPO_AUTOMATION_TOOL_DEFINITIONS.find(
      ({ name }) => name === "run_codex_native_converter",
    );

    expect(definition).toMatchObject({
      name: "run_codex_native_converter",
      inputSchema: {
        required: ["mode", "source_ecosystem", "source_root"],
        properties: {
          mode: expect.objectContaining({ type: "string" }),
          source_ecosystem: expect.objectContaining({ type: "string" }),
          source_root: expect.objectContaining({ type: "string" }),
          selected_paths: expect.objectContaining({ type: "array" }),
          destination_root: expect.objectContaining({ type: "string" }),
          artifact_root: expect.objectContaining({ type: "string" }),
          enable_repo_prompts: expect.objectContaining({ type: "boolean" }),
        },
        additionalProperties: false,
      },
    });
  });

  it("keeps the base toolDefinitions schema aligned for run_codex_native_converter", () => {
    const definition = toolDefinitions.find(
      ({ name }) => name === "run_codex_native_converter",
    );

    expect(definition).toMatchObject({
      name: "run_codex_native_converter",
      inputSchema: {
        required: ["mode", "source_ecosystem", "source_root"],
        properties: {
          mode: expect.objectContaining({ type: "string" }),
          source_ecosystem: expect.objectContaining({ type: "string" }),
          source_root: expect.objectContaining({ type: "string" }),
          selected_paths: expect.objectContaining({ type: "array" }),
          destination_root: expect.objectContaining({ type: "string" }),
          artifact_root: expect.objectContaining({ type: "string" }),
          enable_repo_prompts: expect.objectContaining({ type: "boolean" }),
        },
        additionalProperties: false,
      },
    });
  });
});
