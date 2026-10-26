/**
 * Bind discovery invocations to the existing routing authority.
 *
 * A discovery skill is routed through the same resolvers that route every
 * other Codex delegation: `resolveCodexTopology` with the `discovery`
 * invocation kind (zero production and test writes, fixed specialist role)
 * and `resolveCodexDeployment` under the C1-C4 complexity ceiling. This module
 * adds nothing to those decisions; it validates the prepare inputs, derives
 * deterministic receipt references, checks expected outputs against the
 * skill's permissible artifact kinds and renders the deployment and
 * required-output-manifest shapes the protected invocation record carries.
 * It performs no I/O and grants no authority.
 */

import {
  type CodexDiscoveryTopologyReceipt,
  DISCOVERY_GENERATED_AGENT_FAMILIES,
  DISCOVERY_OPERATIONS,
} from "./lib/validate/codex-discovery-routing";
import { resolveCodexTopology } from "./lib/validate/codex-topology-resolver";
import {
  type CodexDeploymentReceipt,
  ModelUnavailableError,
  resolveCodexDeployment,
} from "./lib/validate/orchestrator-state-codex-model-routing";
import { sha256Hex } from "./discovery-authority-paths";
import { assertRelativePath } from "./discovery-authority-record";
import { canonicalJson } from "./discovery-authorization-record";
import type { ProtectedWorkspaceBinding } from "./discovery-authority";

export const REQUIRED_OUTPUT_MANIFEST_SCHEMA =
  "urn:drm-copilot:discovery:2.0.0:required-output-manifest";
export const DISCOVERY_SKILL_IDS: ReadonlyArray<string> =
  Object.keys(DISCOVERY_OPERATIONS);
export const DISCOVERY_ROLES: ReadonlyArray<string> =
  DISCOVERY_GENERATED_AGENT_FAMILIES;
export const EXECUTION_CONTEXTS: ReadonlyArray<string> = [
  "standalone",
  "epic_preparation_child",
  "epic_execution_child",
];
export const COMPLEXITY_BANDS: ReadonlyArray<string> = ["C1", "C2", "C3", "C4"];
export const OUTPUT_FORMATS: ReadonlyArray<string> = [
  "json",
  "yaml",
  "markdown",
  "gherkin",
  "binary",
];
/** `required-output-manifest#/$defs/output-kind`. */
export const OUTPUT_KINDS: ReadonlyArray<string> = [
  "domain-profile",
  "scope",
  "feature-contract",
  "coverage-ledger",
  "runtime-characterization-scenario",
  "parity-matrix",
  "unspecified-behavior",
  "product-decision",
  "evidence-reference",
  "inventory-snapshot",
  "acceptance-specification",
  "source-snapshot-manifest",
  "implementation-record",
  "unspecified-behavior-collection",
  "product-decision-collection",
  "extension-result-manifest",
  "coverage-report",
  "parity-report",
  "completion-report",
  "validation-report",
  "migration-report",
  "acceptance-view",
  "evidence-payload",
  "activation",
  "required-output-manifest",
];
/** The controlled operation each skill's invocation record is attributed to. */
export const SKILL_PRIMARY_OPERATIONS: Readonly<Record<string, string>> = {
  "inventory-legacy-system": "inventory",
  "extract-feature-contract": "new-contract",
  "characterize-runtime-behavior": "new-scenario",
  "reconcile-parity-matrix": "update-artifact",
  "review-discovery-coverage": "coverage-report",
  "adjudicate-unspecified-behavior": "update-artifact",
  "generate-acceptance-scenarios": "generate-acceptance",
  "initialize-discovery-workspace": "validate-all",
  "validate-discovery-artifacts": "validate-all",
};
const IDENTIFIER = /^[a-z][a-z0-9]*(?:[._-][a-z0-9]+)*$/u;
const SHA256 = /^[0-9a-f]{64}$/u;
const OUTPUT_KEYS = "artifact_kind,expected_sha256,format,id,path";

export type DiscoveryRoutingCode =
  | "ROUTING_SKILL_UNKNOWN"
  | "ROUTING_WRITE_COUNT"
  | "ROUTING_CONTEXT_INVALID"
  | "ROUTING_COMPLEXITY_INVALID"
  | "ROUTING_MODEL_UNAVAILABLE"
  | "ROUTING_SCOPE_INVALID"
  | "ROUTING_OUTPUT_INVALID"
  | "ROUTING_OUTPUT_KIND_FORBIDDEN";

/** Raised when a prepare request cannot be routed through the fixed contracts. */
export class DiscoveryRoutingError extends Error {
  readonly code: DiscoveryRoutingCode;

  constructor(code: DiscoveryRoutingCode, message: string) {
    super(message);
    this.name = "DiscoveryRoutingError";
    this.code = code;
  }
}

/** Untrusted routing inputs of a prepare request. */
export interface DiscoveryRoutingRequest {
  readonly skillId: unknown;
  readonly executionContext: unknown;
  readonly complexity: unknown;
  readonly orchestrationComplexityCeiling?: unknown;
  readonly productionWriteCount?: unknown;
  readonly testWriteCount?: unknown;
}

/** Routing outcome persisted as topology and model receipts. */
export interface DiscoveryRoutingDecision {
  readonly skillId: string;
  readonly role: string;
  readonly operation: string;
  readonly gateMode: string;
  readonly permissibleArtifactKinds: ReadonlyArray<string>;
  readonly topology: CodexDiscoveryTopologyReceipt;
  readonly deployment: CodexDeploymentReceipt;
  readonly topologyReceiptRef: string;
  readonly modelReceiptRef: string;
}

/** `required-output-manifest#/$defs/output`. */
export interface ExpectedOutput {
  readonly artifact_kind: string;
  readonly id: string;
  readonly path: string;
  readonly format: string;
  readonly expected_sha256: string | null;
}

export interface RequiredOutputManifest {
  readonly $schema: typeof REQUIRED_OUTPUT_MANIFEST_SCHEMA;
  readonly schema_version: "2.0.0";
  readonly artifact_kind: "required-output-manifest";
  readonly id: string;
  readonly invocation_id: string;
  readonly workspace: ProtectedWorkspaceBinding;
  readonly role: string;
  readonly outputs: ReadonlyArray<ExpectedOutput>;
  readonly manifest_sha256: string;
}

/** `discovery-invocation#/$defs/deployment`. */
export interface InvocationDeployment {
  readonly provider: string;
  readonly agent_name: string;
  readonly model: string;
  readonly reasoning_effort: string;
  readonly profile_path: string;
  readonly profile_sha256: string;
  readonly complexity: string;
  readonly execution_context: string;
}

export interface SelectedScope {
  readonly selectedIds: ReadonlyArray<string>;
  readonly paths: ReadonlyArray<string>;
}

function refuse(
  code: DiscoveryRoutingCode,
  message: string,
): DiscoveryRoutingError {
  return new DiscoveryRoutingError(code, message);
}

function isDiscoveryReceipt(
  receipt: ReturnType<typeof resolveCodexTopology>,
): receipt is CodexDiscoveryTopologyReceipt {
  return "invocation_kind" in receipt;
}

/**
 * Route a skill through the existing topology and deployment resolvers.
 *
 * Write counts default to zero and any other value is refused before the
 * resolvers run, so a discovery invocation can never carry code-write scope.
 * The ceiling defaults to the assessed complexity.
 */
export function resolveDiscoveryRouting(
  request: DiscoveryRoutingRequest,
  availableModels?: ReadonlySet<string>,
): DiscoveryRoutingDecision {
  const { skillId, executionContext, complexity } = request;
  if (typeof skillId !== "string" || !DISCOVERY_SKILL_IDS.includes(skillId)) {
    throw refuse(
      "ROUTING_SKILL_UNKNOWN",
      `skill_id must be one of the nine discovery skills: ${String(skillId)}`,
    );
  }
  const production = request.productionWriteCount ?? 0;
  const tests = request.testWriteCount ?? 0;
  if (production !== 0 || tests !== 0) {
    throw refuse(
      "ROUTING_WRITE_COUNT",
      "Discovery invocations carry zero production and test writes.",
    );
  }
  if (
    typeof executionContext !== "string" ||
    !EXECUTION_CONTEXTS.includes(executionContext)
  ) {
    throw refuse(
      "ROUTING_CONTEXT_INVALID",
      `execution_context must be one of ${EXECUTION_CONTEXTS.join(", ")}.`,
    );
  }
  const ceiling = request.orchestrationComplexityCeiling ?? complexity;
  if (
    typeof complexity !== "string" ||
    !COMPLEXITY_BANDS.includes(complexity) ||
    typeof ceiling !== "string" ||
    !COMPLEXITY_BANDS.includes(ceiling) ||
    COMPLEXITY_BANDS.indexOf(complexity) > COMPLEXITY_BANDS.indexOf(ceiling)
  ) {
    throw refuse(
      "ROUTING_COMPLEXITY_INVALID",
      "complexity and its ceiling must be C1-C4 with complexity at or below the ceiling.",
    );
  }
  const topology = resolveCodexTopology([], 0, 0, executionContext, {
    invocationKind: "discovery",
    skillId,
  });
  if (!isDiscoveryReceipt(topology)) {
    throw refuse(
      "ROUTING_SKILL_UNKNOWN",
      "The topology resolver did not select a discovery specialist.",
    );
  }
  let deployment: CodexDeploymentReceipt;
  try {
    deployment = resolveCodexDeployment(
      topology.logical_agent,
      complexity,
      executionContext,
      ceiling,
      availableModels,
    );
  } catch (error) {
    // The exact routed model is mandatory; silent fallback is prohibited.
    if (error instanceof ModelUnavailableError) {
      throw refuse("ROUTING_MODEL_UNAVAILABLE", error.message);
    }
    throw error;
  }
  return {
    skillId,
    role: topology.logical_agent,
    operation: SKILL_PRIMARY_OPERATIONS[skillId]!,
    gateMode: topology.gate_mode,
    permissibleArtifactKinds: topology.permissible_artifact_kinds,
    topology,
    deployment,
    topologyReceiptRef: `topology-${sha256Hex(canonicalJson(topology))}`,
    modelReceiptRef: `model-${sha256Hex(canonicalJson(deployment))}`,
  };
}

/** Validate selected identifiers and workspace paths; both must be unique. */
export function validateScope(
  selectedIds: unknown,
  paths: unknown,
): SelectedScope {
  if (!Array.isArray(selectedIds) || !Array.isArray(paths)) {
    throw refuse(
      "ROUTING_SCOPE_INVALID",
      "selected_ids and paths must be arrays.",
    );
  }
  const ids = selectedIds.map((value) => {
    if (typeof value !== "string" || !IDENTIFIER.test(value)) {
      throw refuse(
        "ROUTING_SCOPE_INVALID",
        `Invalid selected id: ${String(value)}`,
      );
    }
    return value;
  });
  const relative = paths.map((value) => {
    if (typeof value !== "string") {
      throw refuse("ROUTING_SCOPE_INVALID", "Selected paths must be strings.");
    }
    try {
      return assertRelativePath(value);
    } catch {
      throw refuse("ROUTING_SCOPE_INVALID", `Invalid selected path: ${value}`);
    }
  });
  if (
    new Set(ids).size !== ids.length ||
    new Set(relative).size !== relative.length
  ) {
    throw refuse(
      "ROUTING_SCOPE_INVALID",
      "Selected ids and paths must be unique.",
    );
  }
  return { selectedIds: ids, paths: relative };
}

/** Digest of the selected scope; equal selections have equal digests. */
export function scopeDigest(scope: SelectedScope): string {
  return sha256Hex(
    canonicalJson({ paths: scope.paths, selected_ids: scope.selectedIds }),
  );
}

/**
 * Validate expected outputs against the skill's permissible artifact kinds.
 *
 * A kind outside the skill's contract is refused even when it is a valid
 * output kind elsewhere: sharing a role never broadens a skill's outputs.
 */
export function validateExpectedOutputs(
  skillId: string,
  value: unknown,
): ExpectedOutput[] {
  const operation = DISCOVERY_OPERATIONS[skillId];
  if (operation === undefined) {
    throw refuse("ROUTING_SKILL_UNKNOWN", `Unknown skill: ${skillId}`);
  }
  if (!Array.isArray(value) || value.length === 0) {
    throw refuse(
      "ROUTING_OUTPUT_INVALID",
      "expected_outputs must be a non-empty array.",
    );
  }
  const outputs: ExpectedOutput[] = [];
  // Each row is checked structurally first, then against the skill contract.
  for (const entry of value as unknown[]) {
    const row = entry as Record<string, unknown> | null;
    if (
      row === null ||
      typeof row !== "object" ||
      Object.keys(row).sort().join(",") !== OUTPUT_KEYS
    ) {
      throw refuse(
        "ROUTING_OUTPUT_INVALID",
        "Each expected output has exactly five fields.",
      );
    }
    const {
      artifact_kind: kind,
      id,
      path,
      format,
      expected_sha256: expected,
    } = row;
    if (
      typeof kind !== "string" ||
      !OUTPUT_KINDS.includes(kind) ||
      typeof id !== "string" ||
      !IDENTIFIER.test(id) ||
      typeof path !== "string" ||
      typeof format !== "string" ||
      !OUTPUT_FORMATS.includes(format) ||
      (expected !== null &&
        (typeof expected !== "string" || !SHA256.test(expected)))
    ) {
      throw refuse(
        "ROUTING_OUTPUT_INVALID",
        `Expected output ${String(id)} is malformed.`,
      );
    }
    try {
      assertRelativePath(path);
    } catch {
      throw refuse(
        "ROUTING_OUTPUT_INVALID",
        `Expected output path is invalid: ${path}`,
      );
    }
    if (!operation.permissible_artifact_kinds.includes(kind)) {
      throw refuse(
        "ROUTING_OUTPUT_KIND_FORBIDDEN",
        `Skill ${skillId} may not produce ${kind}.`,
      );
    }
    outputs.push({
      artifact_kind: kind,
      id,
      path,
      format,
      expected_sha256: expected,
    });
  }
  if (
    new Set(outputs.map((output) => output.id)).size !== outputs.length ||
    new Set(outputs.map((output) => output.path)).size !== outputs.length
  ) {
    throw refuse(
      "ROUTING_OUTPUT_INVALID",
      "Expected output ids and paths must be unique.",
    );
  }
  return outputs;
}

/** Render the required-output-manifest with its self-digest. */
export function buildRequiredOutputManifest(options: {
  readonly invocationId: string;
  readonly workspace: ProtectedWorkspaceBinding;
  readonly role: string;
  readonly outputs: ReadonlyArray<ExpectedOutput>;
}): RequiredOutputManifest {
  const body = {
    $schema: REQUIRED_OUTPUT_MANIFEST_SCHEMA,
    schema_version: "2.0.0",
    artifact_kind: "required-output-manifest",
    id: `outputs-${sha256Hex(options.invocationId).slice(0, 24)}`,
    invocation_id: options.invocationId,
    workspace: { ...options.workspace },
    role: options.role,
    outputs: options.outputs.map((output) => ({ ...output })),
  } as const;
  return { ...body, manifest_sha256: sha256Hex(canonicalJson(body)) };
}

/**
 * Project the routing decision into the invocation deployment binding.
 *
 * `agent_name` is the profile the host actually launches and the native start
 * hook matches it exactly: Codex publishes one generated variant per complexity
 * band, so it receives the routed deployment agent; Claude Code and GitHub
 * Copilot publish one profile per role, so they receive the role itself.
 */
export function buildInvocationDeployment(
  decision: DiscoveryRoutingDecision,
  provider: string,
  workspace: ProtectedWorkspaceBinding,
): InvocationDeployment {
  return {
    provider,
    agent_name:
      provider === "codex"
        ? decision.deployment.deployment_agent
        : decision.role,
    model: decision.deployment.model,
    reasoning_effort: decision.deployment.model_reasoning_effort,
    profile_path: workspace.profile_path,
    profile_sha256: workspace.profile_sha256,
    complexity: decision.deployment.complexity_band,
    execution_context: decision.deployment.execution_context,
  };
}
