/** Deterministic Codex deployment resolution and checkpoint receipt validation. */

export const CODEX_MODEL_ROUTING_RECEIPTS_KEY = "codex_model_routing_receipts";

export const BAND_ORDER = ["C1", "C2", "C3", "C4"] as const;

export type ComplexityBand = (typeof BAND_ORDER)[number];
export type ExecutionContext =
  "standalone" | "epic_preparation_child" | "epic_execution_child";
export type ModelReasoningEffort = "low" | "medium" | "high" | "max" | "ultra";

export interface CodexDeploymentReceipt {
  readonly logical_agent: string;
  readonly deployment_agent: string;
  readonly complexity_band: ComplexityBand;
  readonly execution_context: ExecutionContext;
  readonly orchestration_complexity_ceiling: ComplexityBand;
  readonly c3_overlay_applied: boolean;
  readonly c3_overlay_reason: string | null;
  readonly model: string;
  readonly model_reasoning_effort: ModelReasoningEffort;
}

interface DeploymentProfile {
  readonly suffix: string;
  readonly model: string;
  readonly model_reasoning_effort: ModelReasoningEffort;
}

const VALID_EXECUTION_CONTEXTS: ReadonlySet<string> = new Set([
  "standalone",
  "epic_preparation_child",
  "epic_execution_child",
]);
const EPIC_EXECUTION_CONTEXTS: ReadonlySet<string> = new Set([
  "epic_preparation_child",
  "epic_execution_child",
]);
const GENERATED_AGENT_FAMILIES: ReadonlySet<string> = new Set([
  "orchestrator",
  "atomic-planner",
  "atomic-executor",
  "feature-reviewer",
  "task-researcher",
  "prd-feature",
  "pr-author",
  "python-typed-engineer",
  "powershell-typed-engineer",
  "csharp-typed-engineer",
  "typescript-engineer",
]);
export const LOGICAL_AGENT_ALIASES: Readonly<Record<string, string>> = {
  "feature-review": "feature-reviewer",
};

const BASE_PROFILES: Readonly<Record<ComplexityBand, DeploymentProfile>> = {
  C1: {
    suffix: "c1",
    model: "gpt-5.6-luna",
    model_reasoning_effort: "low",
  },
  C2: {
    suffix: "c2",
    model: "gpt-5.6-terra",
    model_reasoning_effort: "medium",
  },
  C3: {
    suffix: "c3",
    model: "gpt-5.6-terra",
    model_reasoning_effort: "high",
  },
  C4: {
    suffix: "c4",
    model: "gpt-5.6-sol",
    model_reasoning_effort: "max",
  },
};
const C3_ELEVATED_PROFILE: DeploymentProfile = {
  suffix: "c3-elevated",
  model: "gpt-5.6-sol",
  model_reasoning_effort: "high",
};
const FORCED_PERSONA_PROFILES: Readonly<Record<string, DeploymentProfile>> = {
  "epic-planner": {
    suffix: "",
    model: "gpt-5.6-sol",
    model_reasoning_effort: "ultra",
  },
  "epic-orchestrator": {
    suffix: "",
    model: "gpt-5.6-sol",
    model_reasoning_effort: "ultra",
  },
};

const REQUIRED_KEYS = [
  "logical_agent",
  "deployment_agent",
  "phase",
  "complexity_band",
  "execution_context",
  "orchestration_complexity_ceiling",
  "c3_overlay_applied",
  "c3_overlay_reason",
  "model",
  "model_reasoning_effort",
] as const;
const RESOLVED_KEYS: ReadonlyArray<keyof CodexDeploymentReceipt> = [
  "logical_agent",
  "deployment_agent",
  "complexity_band",
  "execution_context",
  "orchestration_complexity_ceiling",
  "c3_overlay_applied",
  "c3_overlay_reason",
  "model",
  "model_reasoning_effort",
];

/** Error raised when the exact routed model is unavailable. */
export class ModelUnavailableError extends Error {
  public constructor(message: string) {
    super(message);
    this.name = "ModelUnavailableError";
  }
}

function isObject(value: unknown): value is Record<string, unknown> {
  return typeof value === "object" && value !== null && !Array.isArray(value);
}

/** Format JSON-compatible values like Python repr for parity errors. */
function pythonRepr(value: unknown): string {
  if (value === undefined || value === null) {
    return "None";
  }
  if (typeof value === "string") {
    const escaped = value
      .replaceAll("\\", "\\\\")
      .replaceAll("'", "\\'")
      .replaceAll("\n", "\\n")
      .replaceAll("\r", "\\r")
      .replaceAll("\t", "\\t");
    return `'${escaped}'`;
  }
  if (typeof value === "boolean") {
    return value ? "True" : "False";
  }
  if (typeof value === "number") {
    return String(value);
  }
  if (Array.isArray(value)) {
    return `[${value.map(pythonRepr).join(", ")}]`;
  }
  if (isObject(value)) {
    const entries = Object.entries(value).map(
      ([key, item]) => `${pythonRepr(key)}: ${pythonRepr(item)}`,
    );
    return `{${entries.join(", ")}}`;
  }
  return String(value);
}

function pythonStr(value: unknown): string {
  return typeof value === "string" ? value : pythonRepr(value);
}

function validateBand(value: string, fieldName: string): ComplexityBand {
  if (!(BAND_ORDER as ReadonlyArray<string>).includes(value)) {
    throw new Error(
      `${fieldName} must be one of ('C1', 'C2', 'C3', 'C4'), ` +
        `found ${pythonRepr(value)}.`,
    );
  }
  return value as ComplexityBand;
}

function validateContext(value: string): ExecutionContext {
  if (!VALID_EXECUTION_CONTEXTS.has(value)) {
    throw new Error(
      "execution_context must be one of " +
        "('epic_execution_child', 'epic_preparation_child', 'standalone'), " +
        `found ${pythonRepr(value)}.`,
    );
  }
  return value as ExecutionContext;
}

function selectC3OverlayReason(
  executionContext: ExecutionContext,
  orchestrationComplexityCeiling: ComplexityBand,
): string | null {
  const epicContext = EPIC_EXECUTION_CONTEXTS.has(executionContext);
  const c4Ceiling = orchestrationComplexityCeiling === "C4";
  if (epicContext && c4Ceiling) {
    return "epic_context_and_c4_ceiling";
  }
  if (epicContext) {
    return "epic_context";
  }
  if (c4Ceiling) {
    return "c4_orchestration_ceiling";
  }
  return null;
}

/** Resolve the exact Codex deployment profile for a logical agent delegation. */
export function resolveCodexDeployment(
  logicalAgent: string,
  complexityBand: string,
  executionContext: string,
  orchestrationComplexityCeiling: string,
  availableModels?: ReadonlySet<string>,
): CodexDeploymentReceipt {
  const band = validateBand(complexityBand, "complexity_band");
  const ceiling = validateBand(
    orchestrationComplexityCeiling,
    "orchestration_complexity_ceiling",
  );
  const context = validateContext(executionContext);
  if (BAND_ORDER.indexOf(band) > BAND_ORDER.indexOf(ceiling)) {
    throw new Error(
      "orchestration_complexity_ceiling must be greater than or equal to " +
        `complexity_band, found ${ceiling} below ${band}.`,
    );
  }

  const forcedProfile = FORCED_PERSONA_PROFILES[logicalAgent];
  let profile: DeploymentProfile;
  let deploymentAgent: string;
  let overlayReason: string | null;
  if (forcedProfile !== undefined) {
    profile = forcedProfile;
    deploymentAgent = logicalAgent;
    overlayReason = null;
  } else {
    const deploymentFamily =
      LOGICAL_AGENT_ALIASES[logicalAgent] ?? logicalAgent;
    if (!GENERATED_AGENT_FAMILIES.has(deploymentFamily)) {
      throw new Error(
        `Unsupported Codex logical agent: ${pythonRepr(logicalAgent)}.`,
      );
    }
    overlayReason =
      band === "C3" ? selectC3OverlayReason(context, ceiling) : null;
    profile =
      overlayReason === null ? BASE_PROFILES[band] : C3_ELEVATED_PROFILE;
    deploymentAgent = `${deploymentFamily}-${profile.suffix}`;
  }

  if (availableModels !== undefined && !availableModels.has(profile.model)) {
    throw new ModelUnavailableError(
      "model_unavailable: required Codex model " +
        `${pythonRepr(profile.model)} is unavailable; silent fallback is prohibited.`,
    );
  }
  return {
    logical_agent: logicalAgent,
    deployment_agent: deploymentAgent,
    complexity_band: band,
    execution_context: context,
    orchestration_complexity_ceiling: ceiling,
    c3_overlay_applied: overlayReason !== null,
    c3_overlay_reason: overlayReason,
    model: profile.model,
    model_reasoning_effort: profile.model_reasoning_effort,
  };
}

interface ReceiptValidationResult {
  readonly errors: string[];
  readonly resolvedCeiling?: ComplexityBand;
}

function validateReceipt(
  value: unknown,
  prefix: string,
  previousCeiling?: ComplexityBand,
): ReceiptValidationResult {
  if (!isObject(value)) {
    return { errors: [`${prefix} must be an object.`] };
  }
  const missing = REQUIRED_KEYS.filter((key) => !(key in value));
  if (missing.length > 0) {
    return {
      errors: [`${prefix} missing required keys: ${missing.join(", ")}.`],
    };
  }

  const errors: string[] = [];
  const phase = value["phase"];
  if (typeof phase !== "string" || phase.trim() === "") {
    errors.push(`${prefix}.phase must be a non-empty string.`);
  }

  let expected: CodexDeploymentReceipt;
  try {
    expected = resolveCodexDeployment(
      pythonStr(value["logical_agent"]),
      pythonStr(value["complexity_band"]),
      pythonStr(value["execution_context"]),
      pythonStr(value["orchestration_complexity_ceiling"]),
    );
  } catch (error) {
    const message = error instanceof Error ? error.message : String(error);
    errors.push(`${prefix} has invalid routing inputs: ${message}`);
    return { errors };
  }

  const currentCeiling = expected.orchestration_complexity_ceiling;
  if (
    previousCeiling !== undefined &&
    BAND_ORDER.indexOf(currentCeiling) < BAND_ORDER.indexOf(previousCeiling)
  ) {
    errors.push(
      `${prefix}.orchestration_complexity_ceiling must be monotonic; ` +
        `found ${currentCeiling} after ${previousCeiling}.`,
    );
  } else if (previousCeiling !== undefined) {
    const transition = value["ceiling_transition"];
    if (currentCeiling === previousCeiling) {
      if (transition !== undefined && transition !== null) {
        errors.push(
          `${prefix}.ceiling_transition must be absent unless the ceiling rises.`,
        );
      }
    } else if (!isObject(transition)) {
      errors.push(
        `${prefix}.ceiling_transition must record a ceiling increase.`,
      );
    } else {
      if (
        transition["from"] !== previousCeiling ||
        transition["to"] !== currentCeiling
      ) {
        errors.push(
          `${prefix}.ceiling_transition must record ${previousCeiling} to ${currentCeiling}.`,
        );
      }
      const affected = transition["affected_delegation_ids"];
      if (
        !Array.isArray(affected) ||
        affected.length === 0 ||
        affected.some(
          (item) => typeof item !== "string" || item.trim() === "",
        ) ||
        new Set(affected).size !== affected.length
      ) {
        errors.push(
          `${prefix}.ceiling_transition.affected_delegation_ids must be a ` +
            "non-empty unique string list.",
        );
      }
    }
  } else if (
    value["ceiling_transition"] !== undefined &&
    value["ceiling_transition"] !== null
  ) {
    errors.push(
      `${prefix}.ceiling_transition must be absent unless the ceiling rises.`,
    );
  }

  for (const key of RESOLVED_KEYS) {
    if (value[key] !== expected[key]) {
      errors.push(
        `${prefix}.${key} must be ${pythonRepr(expected[key])}, ` +
          `found ${pythonRepr(value[key])}.`,
      );
    }
  }
  return { errors, resolvedCeiling: currentCeiling };
}

/** Validate one Codex receipt against the canonical deployment resolver. */
export function validateCodexModelRoutingReceipt(
  value: unknown,
  prefix = `Checkpoint ${CODEX_MODEL_ROUTING_RECEIPTS_KEY}[0]`,
): string[] {
  return validateReceipt(value, prefix).errors;
}

/** Validate every present receipt in the checkpoint list. */
export function validateCodexModelRoutingReceipts(value: unknown): string[] {
  if (!Array.isArray(value)) {
    return [
      `Checkpoint ${CODEX_MODEL_ROUTING_RECEIPTS_KEY} must be a list when present.`,
    ];
  }
  const errors: string[] = [];
  let previousCeiling: ComplexityBand | undefined;
  value.forEach((item, index) => {
    const result = validateReceipt(
      item,
      `Checkpoint ${CODEX_MODEL_ROUTING_RECEIPTS_KEY}[${index}]`,
      previousCeiling,
    );
    errors.push(...result.errors);
    previousCeiling = result.resolvedCeiling ?? previousCeiling;
  });
  return errors;
}

function delegatedAgentNames(state: Record<string, unknown>): Set<string> {
  const result = new Set<string>();
  let receipts = state["delegation_receipts"];
  if (isObject(receipts)) {
    receipts = receipts["agents"];
  }
  if (!Array.isArray(receipts)) {
    return result;
  }
  for (const item of receipts) {
    if (!isObject(item)) {
      continue;
    }
    const agentName = item["agent_name"];
    if (typeof agentName === "string" && agentName.trim() !== "") {
      result.add(agentName);
    }
  }
  return result;
}

/** Require a valid logical or deployment receipt for every delegation. */
export function validateCodexModelRoutingGate(
  state: Record<string, unknown>,
): string[] {
  const delegated = delegatedAgentNames(state);
  if (delegated.size === 0) {
    return [];
  }

  const value = state[CODEX_MODEL_ROUTING_RECEIPTS_KEY];
  const errors = validateCodexModelRoutingReceipts(value);
  if (!Array.isArray(value)) {
    return errors;
  }

  const logicalAgents = new Set<string>();
  const deploymentAgents = new Set<string>();
  for (const item of value) {
    if (!isObject(item)) {
      continue;
    }
    const logical = item["logical_agent"];
    const deployment = item["deployment_agent"];
    if (typeof logical === "string") {
      logicalAgents.add(logical);
    }
    if (typeof deployment === "string") {
      deploymentAgents.add(deployment);
    }
  }

  for (const agent of [...delegated].sort()) {
    if (!logicalAgents.has(agent) && !deploymentAgents.has(agent)) {
      errors.push(
        `Checkpoint ${CODEX_MODEL_ROUTING_RECEIPTS_KEY} is missing a ` +
          `receipt for delegated agent: ${agent}.`,
      );
    }
  }
  return errors;
}

/** Apply always-on present-receipt validation and the optional delegation gate. */
export function validateCodexModelRoutingState(
  state: Record<string, unknown>,
  requireGate = false,
): string[] {
  const errors: string[] = [];
  if (CODEX_MODEL_ROUTING_RECEIPTS_KEY in state) {
    errors.push(
      ...validateCodexModelRoutingReceipts(
        state[CODEX_MODEL_ROUTING_RECEIPTS_KEY],
      ),
    );
  }
  if (requireGate) {
    errors.push(...validateCodexModelRoutingGate(state));
  }
  return errors;
}
