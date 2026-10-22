/**
 * Constrain direct discovery routing to the fixed operation contracts.
 *
 * Pure companion of `codex-topology-resolver`. The constants mirror
 * `discovery_operations` and the four discovery generated-agent families in
 * `config/orchestration-routing.json` and the Python `_codex_discovery_routing`
 * module. A discovery receipt names a specialist role and its permissible
 * output kinds; it grants no filesystem, configuration, approval, installation,
 * or native tool authority.
 */

export type InvocationKind = "ordinary" | "discovery";

export const DISCOVERY_ROUTE = "discovery";
export const DISCOVERY_TOPOLOGY = "discovery_specialist";
export const DISCOVERY_ROUTING_REASON = "fixed_discovery_operation";
export const DISCOVERY_OUTPUT_CONTRACT_VERSION = "2.0.0";
export const DISCOVERY_GATE_MODE = "agent-output";
export const DISCOVERY_GENERATED_AGENT_FAMILIES: ReadonlyArray<string> = [
  "legacy-parity-analyst",
  "runtime-characterization-analyst",
  "requirements-reconciler",
  "migration-coverage-reviewer",
];

/** Rejection messages shared with the Python and PowerShell resolvers. */
export const INVOCATION_KIND_MESSAGE =
  "invocation_kind must be ordinary or discovery.";
export const ORDINARY_SKILL_MESSAGE =
  "skill_id is only valid for discovery invocations.";
export const ROOT_PERSONA_MESSAGE =
  "Discovery invocations do not accept root_persona.";
export const PRODUCTION_COUNT_MESSAGE =
  "Discovery invocations require production_file_count=0.";
export const TEST_COUNT_MESSAGE =
  "Discovery invocations require test_file_count=0.";
export const LANGUAGES_MESSAGE =
  "Discovery invocations do not accept languages.";
export const CROSS_CUTTING_MESSAGE =
  "Discovery invocations do not accept cross_cutting.";
export const SKILL_ID_MESSAGE =
  "Discovery invocations require a supported skill_id.";

export interface DiscoveryOperation {
  readonly logical_agent: string;
  readonly output_contract_version: string;
  readonly permissible_artifact_kinds: ReadonlyArray<string>;
  readonly gate_mode: string;
}

/**
 * Deterministic discovery topology decision persisted before delegation.
 *
 * The twelve ordinary receipt keys are retained so a consumer reading the
 * ordinary shape still finds them; five discovery-only keys follow.
 */
export interface CodexDiscoveryTopologyReceipt {
  readonly execution_context: string;
  readonly languages: ReadonlyArray<string>;
  readonly production_file_count: 0;
  readonly test_file_count: 0;
  readonly cross_cutting: false;
  readonly root_persona: null;
  readonly route: typeof DISCOVERY_ROUTE;
  readonly topology: typeof DISCOVERY_TOPOLOGY;
  readonly logical_agent: string;
  readonly routing_reason: typeof DISCOVERY_ROUTING_REASON;
  readonly max_production_files: 0;
  readonly max_test_files: 0;
  readonly invocation_kind: "discovery";
  readonly skill_id: string;
  readonly output_contract_version: string;
  readonly permissible_artifact_kinds: ReadonlyArray<string>;
  readonly gate_mode: string;
}

/** Inputs the topology resolver has already validated and normalized. */
export interface DiscoveryRoutingInputs {
  readonly invocationKind: unknown;
  readonly skillId: unknown;
  readonly executionContext: string;
  readonly languages: ReadonlyArray<string>;
  readonly productionFileCount: number;
  readonly testFileCount: number;
  readonly crossCutting: boolean;
  readonly rootPersona: unknown;
}

function operation(
  logicalAgent: string,
  kinds: ReadonlyArray<string>,
): DiscoveryOperation {
  return {
    logical_agent: logicalAgent,
    output_contract_version: DISCOVERY_OUTPUT_CONTRACT_VERSION,
    permissible_artifact_kinds: kinds,
    gate_mode: DISCOVERY_GATE_MODE,
  };
}

/** Each exact skill keeps its own kinds: sharing a role never broadens them. */
export const DISCOVERY_OPERATIONS: Readonly<
  Record<string, DiscoveryOperation>
> = {
  "inventory-legacy-system": operation("legacy-parity-analyst", [
    "coverage-ledger",
    "evidence-reference",
    "inventory-snapshot",
    "required-output-manifest",
    "unspecified-behavior",
    "unspecified-behavior-collection",
  ]),
  "extract-feature-contract": operation("legacy-parity-analyst", [
    "coverage-ledger",
    "evidence-reference",
    "feature-contract",
    "required-output-manifest",
    "unspecified-behavior",
    "unspecified-behavior-collection",
  ]),
  "characterize-runtime-behavior": operation(
    "runtime-characterization-analyst",
    [
      "evidence-payload",
      "evidence-reference",
      "required-output-manifest",
      "runtime-characterization-scenario",
      "unspecified-behavior",
      "unspecified-behavior-collection",
    ],
  ),
  "reconcile-parity-matrix": operation("requirements-reconciler", [
    "parity-matrix",
    "required-output-manifest",
    "unspecified-behavior",
    "unspecified-behavior-collection",
  ]),
  "review-discovery-coverage": operation("migration-coverage-reviewer", [
    "completion-report",
    "coverage-report",
    "parity-report",
    "required-output-manifest",
    "validation-report",
  ]),
  "adjudicate-unspecified-behavior": operation("requirements-reconciler", [
    "acceptance-specification",
    "acceptance-view",
    "product-decision",
    "product-decision-collection",
    "required-output-manifest",
    "unspecified-behavior",
    "unspecified-behavior-collection",
  ]),
  "generate-acceptance-scenarios": operation("requirements-reconciler", [
    "acceptance-specification",
    "acceptance-view",
    "required-output-manifest",
  ]),
  "initialize-discovery-workspace": operation("migration-coverage-reviewer", [
    "coverage-report",
    "required-output-manifest",
    "validation-report",
  ]),
  "validate-discovery-artifacts": operation("migration-coverage-reviewer", [
    "coverage-report",
    "required-output-manifest",
    "validation-report",
  ]),
};

/**
 * Return the exact invocation kind or reject every other value.
 *
 * Only the exact lowercase strings are accepted; `undefined` is the caller's
 * omission default and is resolved before this function runs, so an explicit
 * `null`, a case variant, a blank, or a non-string is rejected here.
 */
export function validateInvocationKind(value: unknown): InvocationKind {
  if (value === "ordinary" || value === "discovery") {
    return value;
  }
  throw new Error(INVOCATION_KIND_MESSAGE);
}

/**
 * Select a fixed discovery role or allow the unchanged ordinary route.
 *
 * Guards run in the shared contract order so every language resolver reports
 * the same first failure for the same malformed request. Returns `null` when
 * the ordinary path must continue unchanged.
 */
export function resolveCodexDiscoveryTopology(
  inputs: DiscoveryRoutingInputs,
): CodexDiscoveryTopologyReceipt | null {
  const kind = validateInvocationKind(inputs.invocationKind);
  // An ordinary request must not carry a skill; the caller then continues
  // through the unchanged ordinary root, epic, and count dispatch.
  if (kind === "ordinary") {
    if (inputs.skillId !== undefined && inputs.skillId !== null) {
      throw new Error(ORDINARY_SKILL_MESSAGE);
    }
    return null;
  }

  // Discovery scope is rejected before the role lookup so the guard order
  // stays stable when several fields are malformed at once.
  if (inputs.rootPersona !== undefined && inputs.rootPersona !== null) {
    throw new Error(ROOT_PERSONA_MESSAGE);
  }
  if (inputs.productionFileCount !== 0) {
    throw new Error(PRODUCTION_COUNT_MESSAGE);
  }
  if (inputs.testFileCount !== 0) {
    throw new Error(TEST_COUNT_MESSAGE);
  }
  if (inputs.languages.length !== 0) {
    throw new Error(LANGUAGES_MESSAGE);
  }
  if (inputs.crossCutting) {
    throw new Error(CROSS_CUTTING_MESSAGE);
  }
  const skillId = inputs.skillId;
  if (
    typeof skillId !== "string" ||
    !Object.hasOwn(DISCOVERY_OPERATIONS, skillId)
  ) {
    throw new Error(SKILL_ID_MESSAGE);
  }
  const selected = DISCOVERY_OPERATIONS[skillId];
  if (selected === undefined) {
    throw new Error(SKILL_ID_MESSAGE);
  }

  return {
    execution_context: inputs.executionContext,
    languages: [],
    production_file_count: 0,
    test_file_count: 0,
    cross_cutting: false,
    root_persona: null,
    route: DISCOVERY_ROUTE,
    topology: DISCOVERY_TOPOLOGY,
    logical_agent: selected.logical_agent,
    routing_reason: DISCOVERY_ROUTING_REASON,
    max_production_files: 0,
    max_test_files: 0,
    invocation_kind: "discovery",
    skill_id: skillId,
    output_contract_version: selected.output_contract_version,
    permissible_artifact_kinds: [...selected.permissible_artifact_kinds],
    gate_mode: selected.gate_mode,
  };
}
