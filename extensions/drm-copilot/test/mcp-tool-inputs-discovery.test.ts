import { describe, expect, it } from "@jest/globals";

import {
  DISCOVERY_ARTIFACT_TYPES,
  DISCOVERY_REPORT_TYPES,
  resolveRunDiscoveryDotnetAnalyzerToolInput,
  resolveRunDiscoveryInitToolInput,
  resolveRunDiscoveryReportToolInput,
  resolveRunDiscoveryRepoInventoryToolInput,
  resolveRunDiscoveryScenarioGenerationToolInput,
  resolveRunDiscoveryVstoAnalyzerToolInput,
  resolveValidateDiscoveryArtifactsToolInput,
} from "../src/mcp-tool-inputs-discovery";

describe("resolveValidateDiscoveryArtifactsToolInput", () => {
  it("normalizes a valid input", () => {
    const input = resolveValidateDiscoveryArtifactsToolInput({
      workspace_root: "C:/ws",
      artifact_type: "profile",
      artifact_path: "discovery/profile.yaml",
    });
    expect(input).toEqual({
      workspaceRoot: "C:/ws",
      artifactType: "profile",
      artifactPath: "discovery/profile.yaml",
    });
  });

  it("exposes exactly the nine landed artifact_type kinds", () => {
    expect([...DISCOVERY_ARTIFACT_TYPES]).toEqual([
      "profile",
      "feature-contract",
      "coverage-ledger",
      "runtime-scenario",
      "parity-matrix",
      "unspecified-behavior",
      "product-decision",
      "evidence-reference",
      "all",
    ]);
  });

  it("rejects a missing artifact_path", () => {
    expect(() =>
      resolveValidateDiscoveryArtifactsToolInput({ artifact_type: "profile" }),
    ).toThrow(/artifact_path/);
  });

  it("rejects a non-string artifact_path", () => {
    expect(() =>
      resolveValidateDiscoveryArtifactsToolInput({
        artifact_type: "profile",
        artifact_path: 5,
      }),
    ).toThrow(/artifact_path/);
  });

  it("rejects an out-of-enum artifact_type", () => {
    expect(() =>
      resolveValidateDiscoveryArtifactsToolInput({
        artifact_type: "not-a-kind",
        artifact_path: "p.yaml",
      }),
    ).toThrow(/artifact type/);
  });

  it("falls back to the provided workspace root", () => {
    const input = resolveValidateDiscoveryArtifactsToolInput(
      { artifact_type: "all", artifact_path: "discovery/" },
      "/fallback",
    );
    expect(input.workspaceRoot).toBe("/fallback");
  });
});

describe("resolveRunDiscoveryInitToolInput", () => {
  it("normalizes required target_dir and optional flags", () => {
    const input = resolveRunDiscoveryInitToolInput({
      workspace_root: "C:/ws",
      target_dir: "discovery",
      template_root: "templates",
      force: true,
    });
    expect(input).toEqual({
      workspaceRoot: "C:/ws",
      targetDir: "discovery",
      templateRoot: "templates",
      force: true,
    });
  });

  it("omits optional fields when not supplied", () => {
    const input = resolveRunDiscoveryInitToolInput({
      workspace_root: "C:/ws",
      target_dir: "discovery",
    });
    expect(input).toEqual({
      workspaceRoot: "C:/ws",
      targetDir: "discovery",
    });
  });

  it("rejects a missing target_dir", () => {
    expect(() => resolveRunDiscoveryInitToolInput({})).toThrow(/target_dir/);
  });

  it("rejects a non-boolean force", () => {
    expect(() =>
      resolveRunDiscoveryInitToolInput({
        target_dir: "discovery",
        force: "yes",
      }),
    ).toThrow(/force/);
  });
});

describe.each([
  ["repo inventory", resolveRunDiscoveryRepoInventoryToolInput],
  ["dotnet analyzer", resolveRunDiscoveryDotnetAnalyzerToolInput],
  ["vsto analyzer", resolveRunDiscoveryVstoAnalyzerToolInput],
])("resolve %s analyzer input", (_label, resolver) => {
  it("normalizes optional profile_path and output_dir", () => {
    const input = resolver({
      workspace_root: "C:/ws",
      profile_path: "profile.yaml",
      output_dir: "out",
    });
    expect(input).toEqual({
      workspaceRoot: "C:/ws",
      profilePath: "profile.yaml",
      outputDir: "out",
    });
  });

  it("omits optional fields when not supplied", () => {
    const input = resolver({ workspace_root: "C:/ws" });
    expect(input).toEqual({ workspaceRoot: "C:/ws" });
  });

  it("rejects a non-string profile_path", () => {
    expect(() => resolver({ profile_path: 42 })).toThrow(/profile_path/);
  });
});

describe("resolveRunDiscoveryScenarioGenerationToolInput", () => {
  it("normalizes the three required inputs and optional output/check", () => {
    const input = resolveRunDiscoveryScenarioGenerationToolInput({
      workspace_root: "C:/ws",
      feature_contract: "fc.yaml",
      parity_matrix: "pm.yaml",
      runtime_characterization: "rc.yaml",
      output_path: "out.md",
      check: true,
    });
    expect(input).toEqual({
      workspaceRoot: "C:/ws",
      featureContract: "fc.yaml",
      parityMatrix: "pm.yaml",
      runtimeCharacterization: "rc.yaml",
      outputPath: "out.md",
      check: true,
    });
  });

  it.each([
    [
      "feature_contract",
      { parity_matrix: "pm", runtime_characterization: "rc" },
    ],
    [
      "parity_matrix",
      { feature_contract: "fc", runtime_characterization: "rc" },
    ],
    [
      "runtime_characterization",
      { feature_contract: "fc", parity_matrix: "pm" },
    ],
  ])("rejects a missing %s", (missingField, args) => {
    expect(() => resolveRunDiscoveryScenarioGenerationToolInput(args)).toThrow(
      new RegExp(missingField),
    );
  });

  it("rejects a non-boolean check", () => {
    expect(() =>
      resolveRunDiscoveryScenarioGenerationToolInput({
        feature_contract: "fc",
        parity_matrix: "pm",
        runtime_characterization: "rc",
        check: 1,
      }),
    ).toThrow(/check/);
  });
});

describe("resolveRunDiscoveryReportToolInput", () => {
  it("exposes exactly the three landed report_type kinds", () => {
    expect([...DISCOVERY_REPORT_TYPES]).toEqual([
      "coverage",
      "parity",
      "completion",
    ]);
  });

  it("normalizes a coverage report requiring input_path", () => {
    const input = resolveRunDiscoveryReportToolInput({
      workspace_root: "C:/ws",
      report_type: "coverage",
      input_path: "ledger.json",
      output_path: "out.md",
    });
    expect(input).toEqual({
      workspaceRoot: "C:/ws",
      reportType: "coverage",
      inputPath: "ledger.json",
      outputPath: "out.md",
    });
  });

  it("normalizes a parity report requiring input_path", () => {
    const input = resolveRunDiscoveryReportToolInput({
      report_type: "parity",
      input_path: "matrix.yaml",
    });
    expect(input.reportType).toBe("parity");
    expect(input.inputPath).toBe("matrix.yaml");
  });

  it("normalizes a completion report requiring both pair inputs", () => {
    const input = resolveRunDiscoveryReportToolInput({
      report_type: "completion",
      coverage_input: "cov.json",
      parity_input: "par.yaml",
    });
    expect(input).toEqual({
      workspaceRoot: expect.any(String),
      reportType: "completion",
      coverageInput: "cov.json",
      parityInput: "par.yaml",
    });
  });

  it("rejects a coverage/parity report missing input_path", () => {
    expect(() =>
      resolveRunDiscoveryReportToolInput({ report_type: "coverage" }),
    ).toThrow(/input_path/);
  });

  it("rejects a completion report missing coverage_input", () => {
    expect(() =>
      resolveRunDiscoveryReportToolInput({
        report_type: "completion",
        parity_input: "par.yaml",
      }),
    ).toThrow(/coverage_input/);
  });

  it("rejects a completion report missing parity_input", () => {
    expect(() =>
      resolveRunDiscoveryReportToolInput({
        report_type: "completion",
        coverage_input: "cov.json",
      }),
    ).toThrow(/parity_input/);
  });

  it("rejects an out-of-enum report_type", () => {
    expect(() =>
      resolveRunDiscoveryReportToolInput({
        report_type: "unknown",
        input_path: "x",
      }),
    ).toThrow(/report type/);
  });
});
