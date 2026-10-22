/**
 * Thin discovery operation adapters over the fixed installed runtime.
 *
 * Each adapter maps one host input shape onto a v2 `service-request`, hands it
 * to `invokeDiscoveryRuntime`, and converts the validated `service-result`
 * into the host execution result. No discovery semantics (schema, graph,
 * coverage, parity or approval rules) are computed here, no Python code string
 * is composed, and no stdout sentence is parsed. Inputs that belonged to the
 * retired positional CLI contract are rejected with an explicit message rather
 * than silently dropped.
 */

import type { CommandOutput } from "./command-runtime";
import { toExecutionResult } from "./discovery-result";
import {
  invokeDiscoveryRuntime,
  type DiscoveryRequestSpec,
  type DiscoveryRuntimeDependencies,
} from "./discovery-runtime";
import type {
  DiscoveryMode,
  DiscoveryOperation,
  DiscoveryOutputFormat,
  DiscoveryRequestInputs,
} from "./discovery-service-types";
import type { RepoAutomationExecutionResult } from "./repo-automation-service-contract";
import type { RepoAutomationToolName } from "./repo-automation-tool-names";

/** Shared fields carried by every discovery service input. */
export interface DiscoveryWorkspaceInput {
  readonly workspaceRoot: string;
  readonly invocationId?: string;
  /** Workspace-relative profile path; the activation/default rules apply when omitted. */
  readonly profilePath?: string;
  /** Trusted explicit interpreter chosen by host configuration, never by request data. */
  readonly interpreter?: string;
}

export interface ValidateDiscoveryArtifactsInput extends DiscoveryWorkspaceInput {
  readonly artifactType: string;
  readonly artifactPath: string;
  /** Validation mode for `all`; individual validators are structural. */
  readonly mode?: DiscoveryMode;
  readonly dryRun?: boolean;
}

export interface RunDiscoveryInitInput extends DiscoveryWorkspaceInput {
  readonly systemId?: string;
  readonly systemName?: string;
  readonly systemRole?: "legacy-source" | "modernization-target" | "combined";
  readonly repositoryId?: string;
  readonly productionRoots?: ReadonlyArray<string>;
  readonly testRoots?: ReadonlyArray<string>;
  readonly draft?: boolean;
  readonly dryRun?: boolean;
  /** Retired positional-CLI fields; present only until the input resolvers move. */
  readonly targetDir?: string;
  readonly templateRoot?: string;
  readonly force?: boolean;
}

export interface RunDiscoveryAnalyzerInput extends DiscoveryWorkspaceInput {
  readonly analyzerIds?: ReadonlyArray<string>;
  readonly write?: boolean;
  readonly dryRun?: boolean;
  /** Retired positional-CLI field; outputs follow the configured profile roots. */
  readonly outputDir?: string;
}

export interface RunDiscoveryScenarioGenerationInput extends DiscoveryWorkspaceInput {
  readonly acceptanceKind?: "legacy-characterization" | "target-acceptance";
  readonly featureIds?: ReadonlyArray<string>;
  readonly clientIds?: ReadonlyArray<string>;
  readonly modeIds?: ReadonlyArray<string>;
  readonly platformIds?: ReadonlyArray<string>;
  readonly outputFormat?: "markdown" | "gherkin" | "both";
  readonly write?: boolean;
  readonly dryRun?: boolean;
  /** Retired positional-CLI fields; the generator reads the validated workspace. */
  readonly featureContract?: string;
  readonly parityMatrix?: string;
  readonly runtimeCharacterization?: string;
  readonly outputPath?: string;
  readonly check?: boolean;
}

export interface RunDiscoveryReportInput extends DiscoveryWorkspaceInput {
  readonly reportType: string;
  readonly mode?: DiscoveryMode;
  readonly format?: DiscoveryOutputFormat;
  readonly write?: boolean;
  /** Retired positional-CLI fields; reports derive from the validated workspace. */
  readonly inputPath?: string;
  readonly coverageInput?: string;
  readonly parityInput?: string;
  readonly outputPath?: string;
}

/** Per-`artifact_type` operation and the request input that carries the path. */
const VALIDATE_OPERATION_BY_ARTIFACT_TYPE: Readonly<
  Record<
    string,
    { readonly operation: DiscoveryOperation; readonly key: string }
  >
> = {
  profile: { operation: "validate-profile", key: "input_path" },
  "feature-contract": {
    operation: "validate-feature-contract",
    key: "artifact_path",
  },
  "coverage-ledger": {
    operation: "validate-coverage-ledger",
    key: "artifact_path",
  },
  "runtime-scenario": {
    operation: "validate-runtime-scenario",
    key: "artifact_path",
  },
  "parity-matrix": {
    operation: "validate-parity-matrix",
    key: "artifact_path",
  },
  "unspecified-behavior": {
    operation: "validate-unspecified-behavior",
    key: "artifact_path",
  },
  "product-decision": {
    operation: "validate-product-decision",
    key: "artifact_path",
  },
  "evidence-reference": {
    operation: "validate-evidence-reference",
    key: "artifact_path",
  },
};

const REPORT_OPERATION_BY_REPORT_TYPE: Readonly<
  Record<string, DiscoveryOperation>
> = {
  coverage: "coverage-report",
  parity: "parity-report",
  completion: "completion-report",
};

/** Fixed analyzer selection per stack tool; the registry owns the identifiers. */
const DOTNET_ANALYZER_IDS: ReadonlyArray<string> = ["dotnet"];
const VSTO_ANALYZER_IDS: ReadonlyArray<string> = ["office-vsto"];

function rejectRetiredFields(
  input: object,
  fields: ReadonlyArray<string>,
  replacement: string,
): void {
  const present = fields.filter(
    (field) => (input as Record<string, unknown>)[field] !== undefined,
  );
  if (present.length > 0) {
    throw new Error(
      `The v2 discovery contract does not accept ${present.join(", ")}; ${replacement}`,
    );
  }
}

function optionalInputs(
  entries: ReadonlyArray<readonly [string, unknown]>,
): DiscoveryRequestInputs {
  const inputs: Record<
    string,
    string | number | boolean | ReadonlyArray<string>
  > = {};
  // Only supplied values become request inputs; the service applies defaults.
  for (const [key, value] of entries) {
    if (value !== undefined) {
      inputs[key] = value as string | number | boolean | ReadonlyArray<string>;
    }
  }
  return inputs;
}

async function run(
  output: CommandOutput,
  tool: RepoAutomationToolName,
  input: DiscoveryWorkspaceInput,
  request: Omit<DiscoveryRequestSpec, "workspaceRoot" | "profilePath">,
  dependencies: DiscoveryRuntimeDependencies,
): Promise<RepoAutomationExecutionResult> {
  const result = await invokeDiscoveryRuntime(
    output,
    {
      invocationId: input.invocationId ?? tool,
      request: {
        ...request,
        workspaceRoot: input.workspaceRoot,
        ...(input.profilePath === undefined
          ? {}
          : { profilePath: input.profilePath }),
      },
      ...(input.interpreter === undefined
        ? {}
        : { interpreter: input.interpreter }),
    },
    dependencies,
  );
  return toExecutionResult(result, tool, input.workspaceRoot);
}

export async function runValidateDiscoveryArtifacts(
  output: CommandOutput,
  input: ValidateDiscoveryArtifactsInput,
  dependencies: DiscoveryRuntimeDependencies = {},
): Promise<RepoAutomationExecutionResult> {
  // `all` validates the whole configured workspace in the selected mode; the
  // per-kind validators carry one artifact path and are always structural.
  if (input.artifactType === "all") {
    if (input.artifactPath !== ".") {
      throw new Error(
        "validate-all validates the whole configured workspace; artifact_path must be '.'.",
      );
    }
    return run(
      output,
      "validate_discovery_artifacts",
      input,
      {
        operation: "validate-all",
        mode: input.mode ?? "structural",
        dryRun: input.dryRun ?? false,
      },
      dependencies,
    );
  }
  const entry = VALIDATE_OPERATION_BY_ARTIFACT_TYPE[input.artifactType];
  if (entry === undefined) {
    throw new Error(
      `Unsupported discovery artifact_type '${input.artifactType}'.`,
    );
  }
  if (input.mode !== undefined && input.mode !== "structural") {
    throw new Error(
      "Individual artifact validators are structural; use artifact_type 'all' for a completion mode.",
    );
  }
  return run(
    output,
    "validate_discovery_artifacts",
    input,
    {
      operation: entry.operation,
      inputs: { [entry.key]: input.artifactPath },
    },
    dependencies,
  );
}

export async function runDiscoveryInit(
  output: CommandOutput,
  input: RunDiscoveryInitInput,
  dependencies: DiscoveryRuntimeDependencies = {},
): Promise<RepoAutomationExecutionResult> {
  rejectRetiredFields(
    input,
    ["targetDir", "templateRoot", "force"],
    "initialization never overwrites and takes system_id, system_name, system_role, repository_id, production_roots, test_roots, draft and dry_run.",
  );
  const missing = (
    ["systemId", "systemName", "systemRole", "repositoryId"] as const
  ).filter((field) => input[field] === undefined);
  if (missing.length > 0) {
    throw new Error(`Discovery initialization requires ${missing.join(", ")}.`);
  }
  return run(
    output,
    "run_discovery_init",
    input,
    {
      operation: "init",
      dryRun: input.dryRun ?? false,
      inputs: optionalInputs([
        ["system_id", input.systemId],
        ["system_name", input.systemName],
        ["system_role", input.systemRole],
        ["repository_id", input.repositoryId],
        ["production_roots", input.productionRoots],
        ["test_roots", input.testRoots],
        ["draft", input.draft],
      ]),
    },
    dependencies,
  );
}

async function runInventory(
  output: CommandOutput,
  tool: RepoAutomationToolName,
  input: RunDiscoveryAnalyzerInput,
  analyzerIds: ReadonlyArray<string> | undefined,
  dependencies: DiscoveryRuntimeDependencies,
): Promise<RepoAutomationExecutionResult> {
  rejectRetiredFields(
    input,
    ["outputDir"],
    "inventory outputs follow the configured profile roots; use write and dry_run.",
  );
  return run(
    output,
    tool,
    input,
    {
      operation: "inventory",
      write: input.write ?? false,
      dryRun: input.dryRun ?? false,
      inputs: optionalInputs([["analyzer_ids", analyzerIds]]),
    },
    dependencies,
  );
}

export function runDiscoveryRepoInventory(
  output: CommandOutput,
  input: RunDiscoveryAnalyzerInput,
  dependencies: DiscoveryRuntimeDependencies = {},
): Promise<RepoAutomationExecutionResult> {
  return runInventory(
    output,
    "run_discovery_repo_inventory",
    input,
    input.analyzerIds,
    dependencies,
  );
}

export function runDiscoveryDotnetAnalyzer(
  output: CommandOutput,
  input: RunDiscoveryAnalyzerInput,
  dependencies: DiscoveryRuntimeDependencies = {},
): Promise<RepoAutomationExecutionResult> {
  return runInventory(
    output,
    "run_discovery_dotnet_analyzer",
    input,
    DOTNET_ANALYZER_IDS,
    dependencies,
  );
}

export function runDiscoveryVstoAnalyzer(
  output: CommandOutput,
  input: RunDiscoveryAnalyzerInput,
  dependencies: DiscoveryRuntimeDependencies = {},
): Promise<RepoAutomationExecutionResult> {
  return runInventory(
    output,
    "run_discovery_vsto_analyzer",
    input,
    VSTO_ANALYZER_IDS,
    dependencies,
  );
}

export async function runDiscoveryScenarioGeneration(
  output: CommandOutput,
  input: RunDiscoveryScenarioGenerationInput,
  dependencies: DiscoveryRuntimeDependencies = {},
): Promise<RepoAutomationExecutionResult> {
  rejectRetiredFields(
    input,
    [
      "featureContract",
      "parityMatrix",
      "runtimeCharacterization",
      "outputPath",
      "check",
    ],
    "acceptance generation reads the validated workspace and takes acceptance_kind, feature/client/mode/platform filters, output_format, write and dry_run.",
  );
  if (input.acceptanceKind === undefined) {
    throw new Error(
      "Acceptance generation requires acceptanceKind: legacy-characterization or target-acceptance.",
    );
  }
  return run(
    output,
    "run_discovery_scenario_generation",
    input,
    {
      operation: "generate-acceptance",
      write: input.write ?? false,
      dryRun: input.dryRun ?? false,
      inputs: optionalInputs([
        ["acceptance_kind", input.acceptanceKind],
        ["feature_ids", input.featureIds],
        ["client_ids", input.clientIds],
        ["mode_ids", input.modeIds],
        ["platform_ids", input.platformIds],
        ["output_format", input.outputFormat],
      ]),
    },
    dependencies,
  );
}

export async function runDiscoveryReport(
  output: CommandOutput,
  input: RunDiscoveryReportInput,
  dependencies: DiscoveryRuntimeDependencies = {},
): Promise<RepoAutomationExecutionResult> {
  const operation = REPORT_OPERATION_BY_REPORT_TYPE[input.reportType];
  if (operation === undefined) {
    throw new Error(`Unsupported discovery report_type '${input.reportType}'.`);
  }
  rejectRetiredFields(
    input,
    ["inputPath", "coverageInput", "parityInput", "outputPath"],
    "reports derive from the validated workspace; use mode, format and write.",
  );
  return run(
    output,
    "run_discovery_report",
    input,
    {
      operation,
      mode: input.mode ?? "structural",
      format: input.format ?? "json",
      write: input.write ?? false,
    },
    dependencies,
  );
}
