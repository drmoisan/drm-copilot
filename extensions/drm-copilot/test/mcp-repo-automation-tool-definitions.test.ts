import { describe, expect, it } from "@jest/globals";

import { toolDefinitions } from "../src/mcp-tool-definitions";
import { REPO_AUTOMATION_TOOL_DEFINITIONS } from "../src/mcp-repo-automation-tool-definitions";
import type {
  PortableHandoffAuthorityResult,
  TransitionPreparedOrchestrationResult,
} from "../src/mcp-repo-automation-tool-definitions";
import { workspaceRootProperty } from "../src/mcp-push-down-schema-properties";
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
] as const;

function findRepoDefinition(name: string) {
  return REPO_AUTOMATION_TOOL_DEFINITIONS.find(
    (definition) => definition.name === name,
  );
}

function findBaseDefinition(name: string) {
  return toolDefinitions.find((definition) => definition.name === name);
}

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
          required: ["workspace_root", "asset"],
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
      expect(definition?.inputSchema.required).toEqual(["workspace_root"]);
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
        required: ["workspace_root", "mode", "source_ecosystem", "source_root"],
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
        required: ["workspace_root", "mode", "source_ecosystem", "source_root"],
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

  it("includes a render_subagent_tree definition with required session_id and workspace_root", () => {
    const definition = REPO_AUTOMATION_TOOL_DEFINITIONS.find(
      ({ name }) => name === "render_subagent_tree",
    );

    expect(definition).toMatchObject({
      name: "render_subagent_tree",
      inputSchema: {
        required: ["workspace_root", "session_id"],
        properties: {
          workspace_root: expect.objectContaining({ type: "string" }),
          session_id: expect.objectContaining({ type: "string" }),
        },
        additionalProperties: false,
      },
    });
  });

  it("includes epic-orchestrator-state in the validate_orchestration_artifacts artifact_type enum", () => {
    const definition = toolDefinitions.find(
      ({ name }) => name === "validate_orchestration_artifacts",
    );

    const properties = definition?.inputSchema.properties as
      Record<string, { enum?: string[] }> | undefined;

    expect(properties?.["artifact_type"]?.enum).toContain(
      "epic-orchestrator-state",
    );
  });
});

describe("workspace_root required contract (AC-5)", () => {
  it("lists workspace_root in inputSchema.required for every repo automation tool (all 28)", () => {
    // The authoritative runtime array must cover every advertised tool and each
    // must require workspace_root so an omitted value is rejected at the MCP
    // boundary rather than silently defaulting to the server process CWD.
    expect(REPO_AUTOMATION_TOOL_DEFINITIONS).toHaveLength(
      REPO_AUTOMATION_TOOLS.length,
    );
    for (const definition of REPO_AUTOMATION_TOOL_DEFINITIONS) {
      expect(definition.inputSchema.required ?? []).toContain("workspace_root");
    }
  });

  it("does not advertise a process.cwd() default in the workspace_root description", () => {
    expect(workspaceRootProperty.description).not.toContain("process.cwd()");
  });
});

describe("portable handoff MCP definitions", () => {
  const resolutionRequired = [
    "workspace_root",
    "handoff_envelope_path",
    "expected_handoff_envelope_sha256",
    "destination_provider",
  ];

  it.each(["resolve_orchestration_topology", "resolve_provider_routing"])(
    "defines the exact read-only request for %s",
    (toolName) => {
      const definition = findRepoDefinition(toolName);
      expect(definition?.inputSchema.required).toEqual(resolutionRequired);
      expect(Object.keys(definition?.inputSchema.properties ?? {})).toEqual(
        resolutionRequired,
      );
      expect(findBaseDefinition(toolName)).toEqual(definition);
    },
  );

  it("defines the exact transition request and constrained values", () => {
    const definition = findRepoDefinition("transition_prepared_orchestration");
    const required = [
      "workspace_root",
      "source_checkpoint_path",
      "expected_source_checkpoint_sha256",
      "handoff_envelope_path",
      "expected_handoff_envelope_sha256",
      "destination_provider",
      "mode",
    ];
    expect(definition?.inputSchema.required).toEqual(required);
    expect(Object.keys(definition?.inputSchema.properties ?? {})).toEqual([
      "workspace_root",
      "handoff_envelope_path",
      "expected_handoff_envelope_sha256",
      "destination_provider",
      "source_checkpoint_path",
      "expected_source_checkpoint_sha256",
      "mode",
    ]);
    const properties = definition?.inputSchema.properties as Record<
      string,
      { enum?: string[]; pattern?: string }
    >;
    expect(properties["destination_provider"]?.enum).toEqual([
      "claude",
      "codex",
    ]);
    expect(properties["mode"]?.enum).toEqual(["dry_run", "materialize"]);
    expect(properties["expected_source_checkpoint_sha256"]?.pattern).toBe(
      "^[a-f0-9]{64}$",
    );
    expect(findBaseDefinition("transition_prepared_orchestration")).toEqual(
      definition,
    );
  });

  it("types status, digests, primary code, and affected paths", () => {
    const authority: PortableHandoffAuthorityResult = {
      status: "blocked",
      handoffId: null,
      handoffEnvelopeSha256: "0".repeat(64),
      primaryFailureCode: "HANDOFF_TOPOLOGY_RESOLVER_UNAVAILABLE",
      affectedPaths: ["unrelated.csproj"],
      unsupportedCapabilities: ["workspace-explicit-routing"],
      resolution: null,
    };
    const transition: TransitionPreparedOrchestrationResult = {
      status: "materialized",
      handoffId: "handoff-614",
      sourceCheckpointSha256: "0".repeat(64),
      handoffEnvelopeSha256: "1".repeat(64),
      handoffHistorySha256: "2".repeat(64),
      requestedTransition: "atomic_execution",
      destinationCheckpointPath:
        "artifacts/orchestration/orchestrator-state.json",
      destinationCheckpointSha256: "3".repeat(64),
      primaryFailureCode: null,
      affectedPaths: [],
      unsupportedCapabilities: [],
    };
    expect(authority.primaryFailureCode).toBe(
      "HANDOFF_TOPOLOGY_RESOLVER_UNAVAILABLE",
    );
    expect(transition.status).toBe("materialized");
    expect(transition.destinationCheckpointSha256).toHaveLength(64);
  });
});

describe("discovery MCP tool definitions", () => {
  it("keeps the definition list aligned with the widened union order", () => {
    const definitionNames = REPO_AUTOMATION_TOOL_DEFINITIONS.map(
      (definition) => definition.name,
    );

    expect(definitionNames).toEqual([...REPO_AUTOMATION_TOOLS]);
    expect(definitionNames.slice(-7)).toEqual([...DISCOVERY_TOOL_NAMES]);
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

  it("requires workspace_root and target_dir for run_discovery_init", () => {
    expect(
      findRepoDefinition("run_discovery_init")?.inputSchema.required,
    ).toEqual(["workspace_root", "target_dir"]);
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

  it("requires the three scenario-generation inputs", () => {
    expect(
      findRepoDefinition("run_discovery_scenario_generation")?.inputSchema
        .required,
    ).toEqual([
      "workspace_root",
      "feature_contract",
      "parity_matrix",
      "runtime_characterization",
    ]);
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
    // The per-report_type conditional inputs are declared as properties.
    expect(definition?.inputSchema.properties).toHaveProperty("input_path");
    expect(definition?.inputSchema.properties).toHaveProperty("coverage_input");
    expect(definition?.inputSchema.properties).toHaveProperty("parity_input");
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
