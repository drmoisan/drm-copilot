import { describe, expect, it } from "@jest/globals";

import { DiscoveryOperationError } from "../src/discovery-result";
import {
  runDiscoveryDotnetAnalyzer,
  runDiscoveryInit,
  runDiscoveryRepoInventory,
  runDiscoveryReport,
  runDiscoveryScenarioGeneration,
  runDiscoveryVstoAnalyzer,
  runValidateDiscoveryArtifacts,
} from "../src/repo-automation-execute-discovery";
import {
  buildBlockingResult,
  buildServiceResult,
  FAKE_INTERPRETER,
  FakeLauncher,
  SHA_A,
  successOutcome,
} from "./discovery-test-helpers";

const WORKSPACE_ROOT = "C:/workspace";
const output = { appendLine: (): void => undefined };

/** Dependencies that record one launch and replay the given result. */
function deps(result = buildServiceResult()): {
  launcher: FakeLauncher;
  dependencies: Parameters<typeof runDiscoveryInit>[2];
} {
  const launcher = new FakeLauncher(successOutcome(result));
  return {
    launcher,
    dependencies: { launcher, detectInterpreter: () => FAKE_INTERPRETER },
  };
}

function expectGatewayArgv(launcher: FakeLauncher): void {
  const capture = launcher.single();
  expect(capture.args.slice(0, 3)).toEqual([
    "-I",
    "-m",
    "drm_copilot_discovery.gateway",
  ]);
  expect(capture.args).not.toContain("-c");
  expect(capture.cwd).toBe(WORKSPACE_ROOT);
}

describe("runValidateDiscoveryArtifacts", () => {
  it.each([
    ["profile", "validate-profile", "input_path"],
    ["feature-contract", "validate-feature-contract", "artifact_path"],
    ["coverage-ledger", "validate-coverage-ledger", "artifact_path"],
    ["runtime-scenario", "validate-runtime-scenario", "artifact_path"],
    ["parity-matrix", "validate-parity-matrix", "artifact_path"],
    ["unspecified-behavior", "validate-unspecified-behavior", "artifact_path"],
    ["product-decision", "validate-product-decision", "artifact_path"],
    ["evidence-reference", "validate-evidence-reference", "artifact_path"],
  ])(
    "maps %s to the %s request carrying %s",
    async (artifactType, operation, key) => {
      const { launcher, dependencies } = deps();

      const result = await runValidateDiscoveryArtifacts(
        output,
        {
          workspaceRoot: WORKSPACE_ROOT,
          artifactType,
          artifactPath: "d/a.yaml",
        },
        dependencies,
      );

      expectGatewayArgv(launcher);
      expect(launcher.request()).toMatchObject({
        operation,
        mode: "structural",
        dry_run: false,
        write: false,
        inputs: { [key]: "d/a.yaml" },
      });
      expect(result.tool).toBe("validate_discovery_artifacts");
      expect(result.discovery?.ok).toBe(true);
    },
  );

  it("maps all to a whole-workspace validate-all request in the selected mode", async () => {
    const { launcher, dependencies } = deps();

    await runValidateDiscoveryArtifacts(
      output,
      {
        workspaceRoot: WORKSPACE_ROOT,
        artifactType: "all",
        artifactPath: ".",
        mode: "discovery-complete",
        dryRun: true,
        profilePath: "discovery/profile.yaml",
        invocationId: "id-validate",
      },
      dependencies,
    );

    expect(launcher.request()).toMatchObject({
      operation: "validate-all",
      mode: "discovery-complete",
      dry_run: true,
      profile_path: "discovery/profile.yaml",
      inputs: {},
    });
  });

  it("rejects a non-workspace path for all and a completion mode for one kind", async () => {
    const { launcher, dependencies } = deps();

    await expect(
      runValidateDiscoveryArtifacts(
        output,
        {
          workspaceRoot: WORKSPACE_ROOT,
          artifactType: "all",
          artifactPath: "discovery/",
        },
        dependencies,
      ),
    ).rejects.toThrow("artifact_path must be '.'");
    await expect(
      runValidateDiscoveryArtifacts(
        output,
        {
          workspaceRoot: WORKSPACE_ROOT,
          artifactType: "profile",
          artifactPath: "p.yaml",
          mode: "planning",
        },
        dependencies,
      ),
    ).rejects.toThrow("Individual artifact validators are structural");
    await expect(
      runValidateDiscoveryArtifacts(
        output,
        {
          workspaceRoot: WORKSPACE_ROOT,
          artifactType: "unknown",
          artifactPath: "x",
        },
        dependencies,
      ),
    ).rejects.toThrow("Unsupported discovery artifact_type 'unknown'.");
    expect(launcher.captures).toHaveLength(0);
  });

  it("surfaces a blocking validation result as a typed operation error", async () => {
    const blocking = buildBlockingResult({ operation: "validate-all" });
    const launcher = new FakeLauncher({
      exitCode: 1,
      stdout: JSON.stringify(blocking),
      stderr: "",
    });

    await expect(
      runValidateDiscoveryArtifacts(
        output,
        {
          workspaceRoot: WORKSPACE_ROOT,
          artifactType: "all",
          artifactPath: ".",
        },
        { launcher, detectInterpreter: () => FAKE_INTERPRETER },
      ),
    ).rejects.toBeInstanceOf(DiscoveryOperationError);
  });
});

describe("runDiscoveryInit", () => {
  it("composes the init request from the system identity and roots", async () => {
    const { launcher, dependencies } = deps(
      buildServiceResult({
        operation: "init",
        artifacts: [
          {
            path: "discovery/profile.yaml",
            kind: "domain-profile",
            status: "created",
            sha256: SHA_A,
          },
        ],
      }),
    );

    const result = await runDiscoveryInit(
      output,
      {
        workspaceRoot: WORKSPACE_ROOT,
        systemId: "sample-system",
        systemName: "Sample System",
        systemRole: "legacy-source",
        repositoryId: "example/source",
        productionRoots: ["src"],
        testRoots: ["tests"],
        draft: true,
        dryRun: true,
      },
      dependencies,
    );

    expectGatewayArgv(launcher);
    expect(launcher.request()).toMatchObject({
      operation: "init",
      dry_run: true,
      inputs: {
        system_id: "sample-system",
        system_name: "Sample System",
        system_role: "legacy-source",
        repository_id: "example/source",
        production_roots: ["src"],
        test_roots: ["tests"],
        draft: true,
      },
    });
    expect(result.artifacts).toEqual(["discovery/profile.yaml"]);
  });

  it("rejects the retired target_dir, template_root and force inputs explicitly", async () => {
    const { launcher, dependencies } = deps();

    await expect(
      runDiscoveryInit(
        output,
        { workspaceRoot: WORKSPACE_ROOT, targetDir: "discovery", force: true },
        dependencies,
      ),
    ).rejects.toThrow("does not accept targetDir, force");
    expect(launcher.captures).toHaveLength(0);
  });

  it("requires the system identity fields", async () => {
    const { dependencies } = deps();

    await expect(
      runDiscoveryInit(
        output,
        { workspaceRoot: WORKSPACE_ROOT, systemId: "s" },
        dependencies,
      ),
    ).rejects.toThrow(
      "Discovery initialization requires systemName, systemRole, repositoryId.",
    );
  });
});

describe("inventory adapters", () => {
  it("runs the repository inventory with optional analyzer selection and write intent", async () => {
    const { launcher, dependencies } = deps(
      buildServiceResult({ operation: "inventory" }),
    );

    const result = await runDiscoveryRepoInventory(
      output,
      {
        workspaceRoot: WORKSPACE_ROOT,
        analyzerIds: ["repository", "dependencies"],
        write: true,
      },
      dependencies,
    );

    expect(launcher.request()).toMatchObject({
      operation: "inventory",
      write: true,
      dry_run: false,
      inputs: { analyzer_ids: ["repository", "dependencies"] },
    });
    expect(result.tool).toBe("run_discovery_repo_inventory");
  });

  it("omits analyzer_ids when none are selected", async () => {
    const { launcher, dependencies } = deps();

    await runDiscoveryRepoInventory(
      output,
      { workspaceRoot: WORKSPACE_ROOT },
      dependencies,
    );

    expect(launcher.request()["inputs"]).toEqual({});
  });

  it("selects the fixed dotnet and office-vsto analyzers for the stack tools", async () => {
    const dotnet = deps();
    const vsto = deps();

    await runDiscoveryDotnetAnalyzer(
      output,
      { workspaceRoot: WORKSPACE_ROOT, dryRun: true },
      dotnet.dependencies,
    );
    await runDiscoveryVstoAnalyzer(
      output,
      { workspaceRoot: WORKSPACE_ROOT },
      vsto.dependencies,
    );

    expect(dotnet.launcher.request()).toMatchObject({
      operation: "inventory",
      dry_run: true,
      inputs: { analyzer_ids: ["dotnet"] },
    });
    expect(vsto.launcher.request()).toMatchObject({
      inputs: { analyzer_ids: ["office-vsto"] },
    });
  });

  it("rejects the retired output_dir input", async () => {
    const { launcher, dependencies } = deps();

    await expect(
      runDiscoveryVstoAnalyzer(
        output,
        { workspaceRoot: WORKSPACE_ROOT, outputDir: "out" },
        dependencies,
      ),
    ).rejects.toThrow("does not accept outputDir");
    expect(launcher.captures).toHaveLength(0);
  });
});

describe("runDiscoveryScenarioGeneration", () => {
  it("composes the generate-acceptance request with kind, filters and format", async () => {
    const { launcher, dependencies } = deps(
      buildServiceResult({ operation: "generate-acceptance" }),
    );

    await runDiscoveryScenarioGeneration(
      output,
      {
        workspaceRoot: WORKSPACE_ROOT,
        acceptanceKind: "target-acceptance",
        featureIds: ["feature.alpha"],
        clientIds: ["web"],
        outputFormat: "both",
        write: true,
      },
      dependencies,
    );

    expect(launcher.request()).toMatchObject({
      operation: "generate-acceptance",
      write: true,
      dry_run: false,
      inputs: {
        acceptance_kind: "target-acceptance",
        feature_ids: ["feature.alpha"],
        client_ids: ["web"],
        output_format: "both",
      },
    });
  });

  it("rejects the retired three-input contract and requires the acceptance kind", async () => {
    const { launcher, dependencies } = deps();

    await expect(
      runDiscoveryScenarioGeneration(
        output,
        {
          workspaceRoot: WORKSPACE_ROOT,
          featureContract: "fc.yaml",
          parityMatrix: "pm.yaml",
          runtimeCharacterization: "rc.yaml",
        },
        dependencies,
      ),
    ).rejects.toThrow(
      "does not accept featureContract, parityMatrix, runtimeCharacterization",
    );
    await expect(
      runDiscoveryScenarioGeneration(
        output,
        { workspaceRoot: WORKSPACE_ROOT },
        dependencies,
      ),
    ).rejects.toThrow("requires acceptanceKind");
    expect(launcher.captures).toHaveLength(0);
  });
});

describe("runDiscoveryReport", () => {
  it.each([
    ["coverage", "coverage-report"],
    ["parity", "parity-report"],
    ["completion", "completion-report"],
  ])(
    "maps %s to the %s request with mode, format and write",
    async (reportType, operation) => {
      const { launcher, dependencies } = deps(
        buildServiceResult({ operation: operation as "coverage-report" }),
      );

      const result = await runDiscoveryReport(
        output,
        {
          workspaceRoot: WORKSPACE_ROOT,
          reportType,
          mode: "parity-complete",
          format: "both",
          write: true,
        },
        dependencies,
      );

      expectGatewayArgv(launcher);
      expect(launcher.request()).toMatchObject({
        operation,
        mode: "parity-complete",
        format: "both",
        write: true,
      });
      expect(result.summary).toBe("Validation passed.");
    },
  );

  it("defaults to the structural JSON report without writes", async () => {
    const { launcher, dependencies } = deps();

    await runDiscoveryReport(
      output,
      { workspaceRoot: WORKSPACE_ROOT, reportType: "coverage" },
      dependencies,
    );

    expect(launcher.request()).toMatchObject({
      mode: "structural",
      format: "json",
      write: false,
    });
  });

  it("rejects an unknown report type and the retired path inputs", async () => {
    const { launcher, dependencies } = deps();

    await expect(
      runDiscoveryReport(
        output,
        { workspaceRoot: WORKSPACE_ROOT, reportType: "summary" },
        dependencies,
      ),
    ).rejects.toThrow("Unsupported discovery report_type 'summary'.");
    await expect(
      runDiscoveryReport(
        output,
        {
          workspaceRoot: WORKSPACE_ROOT,
          reportType: "completion",
          coverageInput: "cov.json",
          parityInput: "par.yaml",
        },
        dependencies,
      ),
    ).rejects.toThrow("does not accept coverageInput, parityInput");
    expect(launcher.captures).toHaveLength(0);
  });

  it("passes the invocation id and trusted interpreter through to the runtime", async () => {
    const lines: string[] = [];
    const launcher = new FakeLauncher(successOutcome());

    await runDiscoveryReport(
      { appendLine: (line) => lines.push(line) },
      {
        workspaceRoot: WORKSPACE_ROOT,
        reportType: "parity",
        invocationId: "id-report",
        interpreter: "D:/venv/Scripts/python.exe",
      },
      { launcher },
    );

    expect(launcher.single().executable).toBe("D:/venv/Scripts/python.exe");
    expect(lines[0]).toBe(
      "[id-report] runtime probe success: D:/venv/Scripts/python.exe",
    );
  });
});
