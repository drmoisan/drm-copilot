/**
 * Resolver contract for the workspace-level discovery tools (Set G).
 *
 * Every resolver normalizes the closed v2 input shape, refuses out-of-enum and
 * wrongly typed fields, omits optional fields that were not supplied, and
 * passes the retired positional-CLI fields through unchanged so the operation
 * adapter can reject them with its explicit message.
 */

import { describe, expect, it } from "@jest/globals";

import {
  ACCEPTANCE_KINDS,
  DISCOVERY_ARTIFACT_TYPES,
  DISCOVERY_MODES,
  DISCOVERY_REPORT_TYPES,
  resolveRunDiscoveryDotnetAnalyzerToolInput,
  resolveRunDiscoveryInitToolInput,
  resolveRunDiscoveryReportToolInput,
  resolveRunDiscoveryRepoInventoryToolInput,
  resolveRunDiscoveryScenarioGenerationToolInput,
  resolveRunDiscoveryVstoAnalyzerToolInput,
  resolveValidateDiscoveryArtifactsToolInput,
} from "../src/mcp-tool-inputs-discovery";

const WS = "C:/ws";
describe("resolveValidateDiscoveryArtifactsToolInput", () => {
  it("normalizes the v2 input with an explicit whole-workspace mode and dry run", () => {
    expect(
      resolveValidateDiscoveryArtifactsToolInput({
        workspace_root: WS,
        artifact_type: "all",
        artifact_path: ".",
        mode: "discovery-complete",
        dry_run: true,
        profile_path: "docs/profile.yaml",
      }),
    ).toEqual({
      workspaceRoot: WS,
      profilePath: "docs/profile.yaml",
      artifactType: "all",
      artifactPath: ".",
      mode: "discovery-complete",
      dryRun: true,
    });
  });

  it("omits optional fields and pins the nine artifact types and five modes", () => {
    expect(
      resolveValidateDiscoveryArtifactsToolInput({
        workspace_root: WS,
        artifact_type: "profile",
        artifact_path: "p.yaml",
      }),
    ).toEqual({
      workspaceRoot: WS,
      artifactType: "profile",
      artifactPath: "p.yaml",
    });
    expect(DISCOVERY_ARTIFACT_TYPES).toHaveLength(9);
    expect([...DISCOVERY_MODES]).toEqual([
      "structural",
      "agent-output",
      "discovery-complete",
      "parity-complete",
      "planning",
    ]);
  });

  it.each([
    ["missing artifact_path", { artifact_type: "profile" }, /artifact_path/],
    [
      "non-string artifact_path",
      { artifact_type: "profile", artifact_path: 5 },
      /artifact_path/,
    ],
    [
      "out-of-enum artifact_type",
      { artifact_type: "bogus", artifact_path: "p" },
      /artifact type/,
    ],
    [
      "out-of-enum mode",
      { artifact_type: "all", artifact_path: ".", mode: "complete" },
      /mode/,
    ],
    [
      "non-boolean dry_run",
      { artifact_type: "all", artifact_path: ".", dry_run: "yes" },
      /dry_run/,
    ],
  ])("rejects %s", (_label, args, pattern) => {
    expect(() =>
      resolveValidateDiscoveryArtifactsToolInput({
        workspace_root: WS,
        ...args,
      }),
    ).toThrow(pattern);
  });

  it("falls back to the provided workspace root", () => {
    expect(
      resolveValidateDiscoveryArtifactsToolInput(
        { artifact_type: "profile", artifact_path: "p.yaml" },
        "D:/fallback",
      ).workspaceRoot,
    ).toBe("D:/fallback");
  });
});

describe("resolveRunDiscoveryInitToolInput", () => {
  it("normalizes the explicit system identity, roots and flags", () => {
    expect(
      resolveRunDiscoveryInitToolInput({
        workspace_root: WS,
        system_id: "crm",
        system_name: "Legacy CRM",
        system_role: "legacy-source",
        repository_id: "legacy-crm",
        production_roots: ["src"],
        test_roots: ["tests"],
        draft: false,
        dry_run: true,
      }),
    ).toEqual({
      workspaceRoot: WS,
      systemId: "crm",
      systemName: "Legacy CRM",
      systemRole: "legacy-source",
      repositoryId: "legacy-crm",
      productionRoots: ["src"],
      testRoots: ["tests"],
      draft: false,
      dryRun: true,
    });
  });

  it.each([
    ["out-of-enum system_role", { system_role: "owner" }, /system role/],
    [
      "non-list production_roots",
      { production_roots: "src" },
      /production_roots/,
    ],
    ["blank root entry", { production_roots: [" "] }, /production_roots/],
    ["non-boolean draft", { draft: "no" }, /draft/],
  ])("rejects %s", (_label, args, pattern) => {
    expect(() =>
      resolveRunDiscoveryInitToolInput({ workspace_root: WS, ...args }),
    ).toThrow(pattern);
  });

  it("passes the retired positional fields through for the adapter to reject", () => {
    expect(
      resolveRunDiscoveryInitToolInput({
        workspace_root: WS,
        target_dir: "discovery",
        template_root: "t",
        force: true,
      }),
    ).toEqual({
      workspaceRoot: WS,
      targetDir: "discovery",
      templateRoot: "t",
      force: true,
    });
  });
});

describe("analyzer input resolvers", () => {
  it("accepts an explicit analyzer selection and publication flags for repo inventory", () => {
    expect(
      resolveRunDiscoveryRepoInventoryToolInput({
        workspace_root: WS,
        profile_path: "p.yaml",
        analyzer_ids: ["repository", "dotnet"],
        write: true,
        dry_run: false,
      }),
    ).toEqual({
      workspaceRoot: WS,
      profilePath: "p.yaml",
      analyzerIds: ["repository", "dotnet"],
      write: true,
      dryRun: false,
    });
  });

  it.each([
    ["dotnet", resolveRunDiscoveryDotnetAnalyzerToolInput],
    ["vsto", resolveRunDiscoveryVstoAnalyzerToolInput],
  ])("keeps the %s analyzer selection fixed", (_label, resolve) => {
    expect(resolve({ workspace_root: WS })).toEqual({ workspaceRoot: WS });
    expect(() =>
      resolve({ workspace_root: WS, analyzer_ids: ["dotnet"] }),
    ).toThrow(/analyzer_ids/);
    expect(() => resolve({ workspace_root: WS, profile_path: 7 })).toThrow(
      /profile_path/,
    );
  });

  it("passes the retired output_dir through for the adapter to reject", () => {
    expect(
      resolveRunDiscoveryRepoInventoryToolInput({
        workspace_root: WS,
        output_dir: "o",
      }),
    ).toEqual({ workspaceRoot: WS, outputDir: "o" });
  });
});

describe("resolveRunDiscoveryScenarioGenerationToolInput", () => {
  it("normalizes the acceptance kind, filters, format and flags", () => {
    expect(
      resolveRunDiscoveryScenarioGenerationToolInput({
        workspace_root: WS,
        acceptance_kind: "target-acceptance",
        feature_ids: ["orders"],
        client_ids: ["web"],
        mode_ids: ["online"],
        platform_ids: ["win"],
        output_format: "gherkin",
        write: true,
        dry_run: false,
      }),
    ).toEqual({
      workspaceRoot: WS,
      acceptanceKind: "target-acceptance",
      featureIds: ["orders"],
      clientIds: ["web"],
      modeIds: ["online"],
      platformIds: ["win"],
      outputFormat: "gherkin",
      write: true,
      dryRun: false,
    });
    expect([...ACCEPTANCE_KINDS]).toEqual([
      "legacy-characterization",
      "target-acceptance",
    ]);
  });

  it.each([
    [
      "out-of-enum acceptance_kind",
      { acceptance_kind: "smoke" },
      /acceptance kind/,
    ],
    ["out-of-enum output_format", { output_format: "xml" }, /output format/],
    ["non-list feature_ids", { feature_ids: "orders" }, /feature_ids/],
  ])("rejects %s", (_label, args, pattern) => {
    expect(() =>
      resolveRunDiscoveryScenarioGenerationToolInput({
        workspace_root: WS,
        ...args,
      }),
    ).toThrow(pattern);
  });

  it("passes the retired three-input contract through for the adapter to reject", () => {
    expect(
      resolveRunDiscoveryScenarioGenerationToolInput({
        workspace_root: WS,
        feature_contract: "fc",
        parity_matrix: "pm",
        runtime_characterization: "rc",
        output_path: "o",
        check: true,
      }),
    ).toEqual({
      workspaceRoot: WS,
      featureContract: "fc",
      parityMatrix: "pm",
      runtimeCharacterization: "rc",
      outputPath: "o",
      check: true,
    });
  });
});

describe("resolveRunDiscoveryReportToolInput", () => {
  it("normalizes the report kind, whole-workspace mode, format and write flag", () => {
    expect(
      resolveRunDiscoveryReportToolInput({
        workspace_root: WS,
        report_type: "completion",
        mode: "parity-complete",
        format: "both",
        write: true,
      }),
    ).toEqual({
      workspaceRoot: WS,
      reportType: "completion",
      mode: "parity-complete",
      format: "both",
      write: true,
    });
    expect([...DISCOVERY_REPORT_TYPES]).toEqual([
      "coverage",
      "parity",
      "completion",
    ]);
  });

  it.each([
    ["missing report_type", {}, /report_type/],
    ["out-of-enum report_type", { report_type: "bogus" }, /report type/],
    ["out-of-enum mode", { report_type: "coverage", mode: "fast" }, /mode/],
    [
      "out-of-enum format",
      { report_type: "coverage", format: "xml" },
      /format/,
    ],
  ])("rejects %s", (_label, args, pattern) => {
    expect(() =>
      resolveRunDiscoveryReportToolInput({ workspace_root: WS, ...args }),
    ).toThrow(pattern);
  });

  it("passes the retired input paths through for the adapter to reject", () => {
    expect(
      resolveRunDiscoveryReportToolInput({
        workspace_root: WS,
        report_type: "parity",
        input_path: "m.yaml",
        coverage_input: "c",
        parity_input: "p",
        output_path: "o",
      }),
    ).toEqual({
      workspaceRoot: WS,
      reportType: "parity",
      inputPath: "m.yaml",
      coverageInput: "c",
      parityInput: "p",
      outputPath: "o",
    });
  });
});
