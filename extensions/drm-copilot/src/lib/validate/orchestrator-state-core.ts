import type { FileSystem } from "../file-system";
import { validateCodexModelRoutingState } from "./orchestrator-state-codex-model-routing";
import { validateCodexTopologyState } from "./orchestrator-state-codex-topology";
import {
  PROMOTION_RECEIPT_KEYS,
  PROMOTION_RECEIPT_NAMESPACE_KEY,
  validateCompletionCiGate,
  validateCompletionPrGate,
} from "./orchestrator-state-completion";
import {
  HUMAN_INTERACTION_KEY,
  validateHumanInteraction,
} from "./orchestrator-state-human-interaction";
import {
  REMEDIATION_LOOP_KEY,
  validateRemediationLoop,
} from "./orchestrator-state-remediation";
import { validatePreparationTerminalContract } from "./orchestrator-state-preparation-terminal";
import { validateModelRoutingExistence } from "./orchestrator-state-model-routing-existence";
import {
  loadRoutingMatrix,
  routeRequiresCiGate,
  validatePhaseCompleteness,
  validateRoutingContract,
} from "./orchestrator-state-routing";

// Re-export the completion-gate constants the core ports historically carried so
// callers and tests can continue to import them from this module.
export { CI_GATE_KEYS, PR_GATE_KEYS } from "./orchestrator-state-completion";
export { PROMOTION_RECEIPT_KEYS, PROMOTION_RECEIPT_NAMESPACE_KEY };

/**
 * Core orchestrator-state checkpoint validator.
 *
 * Purpose:
 *     Port the core of `scripts/dev_tools/validate_orchestrator_state.py`. The
 *     remediation, human-interaction, and routing concerns are imported from
 *     their dedicated modules so this file stays within the 500-line limit.
 *
 * Responsibilities:
 *     - Parse the checkpoint JSON and validate required top-level keys, step
 *       statuses, blocked-reason, and delegation receipts (list or namespace).
 *     - Delegate the optional remediation and human-interaction blocks.
 *     - Under `requireComplete`, enforce completion-safe statuses, the PR/CI
 *       route-aware PR/CI gates, mandatory phases, the preparation terminal
 *       contract, and the routing contract.
 *
 * Invariants / Constraints:
 *     - Error-message strings are identical to the Python source.
 *     - The routing matrix is injected to keep the validator hermetic.
 *
 * Side Effects:
 *     None directly; the injected `FileSystem` performs reads when loading the
 *     routing matrix.
 */

/** Required top-level checkpoint keys. */
export const REQUIRED_STATE_KEYS = [
  "objective",
  "change_budget_estimate",
  "path_selected",
  "promotion-type",
  "short-name",
  "relativeFile",
  "long-name",
  "issue-num",
  "feature-folder",
  "work-mode",
  "plan-path",
  "completed_steps",
  "next_step",
  "last_updated",
  "step5_status",
  "step6_status",
  "step7_status",
  "step8_status",
  "step9_status",
  "step10_status",
  "delegation_receipts",
  "blocked_reason",
] as const;

/** Permitted step status values. */
export const VALID_STEP_STATUS: ReadonlySet<string> = new Set([
  "not-applicable",
  "pending",
  "delegated",
  "verified",
  "blocked",
  "not_started",
  "in_progress",
  "completed",
]);

/** Permitted blocked-reason values. */
export const VALID_BLOCKED_REASONS: ReadonlySet<string> = new Set([
  "none",
  "spawn_agent_unavailable",
  "delegation_launch_failed",
  "delegate_no_receipt",
  "delegate_contract_incomplete",
  "validator_failed",
  "user_requested_stop",
]);

/** Keys required on each legacy list delegation receipt. */
export const REQUIRED_RECEIPT_KEYS = [
  "step",
  "agent_name",
  "agent_id",
  "skill_source",
  "started_at",
  "completed_at",
  "result_signal",
  "artifact_paths",
] as const;

const STEP_STATUS_KEYS = [
  "step5_status",
  "step6_status",
  "step7_status",
  "step8_status",
  "step9_status",
  "step10_status",
] as const;

/** Options controlling orchestrator-state validation. */
export interface ValidateOrchestratorStateOptions {
  /** When true, enforce completion-safe lifecycle states and gates. */
  readonly requireComplete?: boolean;
  /**
   * When true, run the existence-only model-routing check: once the checkpoint
   * records a delegation, the routing-receipt-agent set must be a superset of
   * the delegated-agent set. The authoritative Python validator performs full
   * per-receipt correctness; this TS side performs the existence check only.
   */
  readonly requireModelRouting?: boolean;
  /** Require deterministic Codex deployment receipts once delegated. */
  readonly requireCodexModelRouting?: boolean;
  /** Require deterministic Codex topology receipts once delegated. */
  readonly requireCodexTopology?: boolean;
  /** Injected filesystem used to load the routing matrix when needed. */
  readonly fs?: FileSystem;
  /** Repository root used with `fs` to locate the routing matrix. */
  readonly root?: string;
  /** Explicit routing matrix; preferred over `fs`+`root` when supplied. */
  readonly routingMatrix?: unknown;
}

/**
 * Type guard for a plain object (non-null, non-array).
 *
 * @param value Candidate value.
 * @returns True when the value is a non-null, non-array object.
 */
function isObject(value: unknown): value is Record<string, unknown> {
  return typeof value === "object" && value !== null && !Array.isArray(value);
}

/**
 * Validate the legacy list-based delegation receipt payload.
 *
 * @param receipts Raw receipt list extracted from the checkpoint JSON.
 * @returns Validation errors for malformed receipt objects.
 */
function validateListDelegationReceipts(receipts: unknown[]): string[] {
  const errors: string[] = [];

  // Validate each legacy receipt independently so callers receive a complete
  // error list instead of stopping at the first malformed item.
  receipts.forEach((receipt, index) => {
    if (!isObject(receipt)) {
      errors.push(`Checkpoint delegation receipt #${index} must be an object.`);
      return;
    }
    for (const key of REQUIRED_RECEIPT_KEYS) {
      if (!(key in receipt)) {
        errors.push(
          `Checkpoint delegation receipt #${index} missing key: ${key}`,
        );
      }
    }
    const artifactPaths = receipt["artifact_paths"];
    if (
      artifactPaths !== undefined &&
      artifactPaths !== null &&
      !Array.isArray(artifactPaths)
    ) {
      errors.push(
        `Checkpoint delegation receipt #${index} artifact_paths must be a list.`,
      );
    }
  });

  return errors;
}

/**
 * Validate the additive object-namespace form of delegation receipts.
 *
 * @param receipts Object-form receipt payload from the checkpoint JSON.
 * @returns Validation errors for unsupported object-shape keys.
 */
function validateNamespacedDelegationReceipts(
  receipts: Record<string, unknown>,
): string[] {
  const errors: string[] = [];
  // Reject any top-level key other than the promotion namespace, sorted.
  const unsupportedKeys = Object.keys(receipts)
    .filter((key) => key !== PROMOTION_RECEIPT_NAMESPACE_KEY)
    .sort();
  for (const key of unsupportedKeys) {
    errors.push(
      `Checkpoint delegation_receipts object contains unsupported key: ${key}`,
    );
  }

  const promotionReceipts = receipts[PROMOTION_RECEIPT_NAMESPACE_KEY];
  if (promotionReceipts === undefined || promotionReceipts === null) {
    return errors;
  }
  if (!isObject(promotionReceipts)) {
    errors.push(
      "Checkpoint delegation_receipts.promotion must be an object namespace.",
    );
    return errors;
  }

  // Reject unknown nested keys while leaving raw receipt values untouched.
  const unsupportedPromotionKeys = Object.keys(promotionReceipts)
    .filter(
      (key) => !(PROMOTION_RECEIPT_KEYS as readonly string[]).includes(key),
    )
    .sort();
  for (const key of unsupportedPromotionKeys) {
    errors.push(
      "Checkpoint delegation_receipts.promotion contains unsupported key: " +
        key,
    );
  }

  return errors;
}

/**
 * Resolve the routing matrix for the completion routing-contract check.
 *
 * @param options Validation options carrying `routingMatrix` or `fs`+`root`.
 * @returns The resolved routing matrix, or undefined when none is available.
 */
function resolveRoutingMatrix(
  options: ValidateOrchestratorStateOptions,
): unknown {
  if (options.routingMatrix !== undefined) {
    return options.routingMatrix;
  }
  // Default to loading via the supplied FileSystem from production wiring.
  if (options.fs !== undefined && options.root !== undefined) {
    return loadRoutingMatrix(options.fs, options.root);
  }
  return undefined;
}

/**
 * Validate checkpoint schema and completion-state fields.
 *
 * Purpose:
 *     Mirror Python `validate_orchestrator_state_text`. Enforce the repository
 *     contract for orchestrator-state artifacts before resume or review
 *     workflows rely on the checkpoint contents.
 *
 * @param text Raw checkpoint JSON text.
 * @param options Validation options (completion gate and routing-matrix wiring).
 * @returns Validation errors for malformed or incomplete checkpoint state.
 */
export function validateOrchestratorStateText(
  text: string,
  options: ValidateOrchestratorStateOptions = {},
): string[] {
  const errors: string[] = [];
  let state: unknown;
  try {
    state = JSON.parse(text);
  } catch (exc) {
    return [
      `Checkpoint is not valid JSON: ${exc instanceof Error ? exc.message : String(exc)}`,
    ];
  }

  if (!isObject(state)) {
    return ["Checkpoint root must be a JSON object."];
  }
  const stateMap = state;

  // Require the canonical top-level fields before evaluating deeper invariants.
  for (const key of REQUIRED_STATE_KEYS) {
    if (!(key in stateMap)) {
      errors.push(`Checkpoint missing required key: ${key}`);
    }
  }

  // Validate each tracked step status against the permitted set.
  for (const key of STEP_STATUS_KEYS) {
    const value = stateMap[key];
    if (
      value !== undefined &&
      value !== null &&
      !(typeof value === "string" && VALID_STEP_STATUS.has(value))
    ) {
      errors.push(`Checkpoint has invalid ${key}: ${String(value)}`);
    }
  }

  const blockedReason = stateMap["blocked_reason"];
  if (
    blockedReason !== undefined &&
    blockedReason !== null &&
    !(
      typeof blockedReason === "string" &&
      VALID_BLOCKED_REASONS.has(blockedReason)
    )
  ) {
    errors.push(
      `Checkpoint has invalid blocked_reason: ${String(blockedReason)}`,
    );
  }

  const receipts = stateMap["delegation_receipts"];
  if (receipts !== undefined && receipts !== null) {
    if (Array.isArray(receipts)) {
      errors.push(...validateListDelegationReceipts(receipts));
    } else if (isObject(receipts)) {
      errors.push(...validateNamespacedDelegationReceipts(receipts));
    } else {
      errors.push(
        "Checkpoint delegation_receipts must be a list or object namespace.",
      );
    }
  }

  // Apply the additive remediation-cycle invariants only when present.
  if (REMEDIATION_LOOP_KEY in stateMap) {
    errors.push(...validateRemediationLoop(stateMap[REMEDIATION_LOOP_KEY]));
  }

  // Apply the additive human_interaction invariants only when present.
  if (HUMAN_INTERACTION_KEY in stateMap) {
    errors.push(...validateHumanInteraction(stateMap[HUMAN_INTERACTION_KEY]));
  }

  if (options.requireComplete === true) {
    // Enforce completion-safe lifecycle states only when the caller opts into
    // the stricter completion gate.
    for (const key of STEP_STATUS_KEYS) {
      const value = stateMap[key];
      if (value === "pending" || value === "blocked") {
        errors.push(
          `Checkpoint completion validation failed: ${key} is ${String(value)}.`,
        );
      }
    }
    const completionBlockedReason = stateMap["blocked_reason"];
    if (
      completionBlockedReason !== undefined &&
      completionBlockedReason !== null &&
      completionBlockedReason !== "none"
    ) {
      errors.push(
        "Checkpoint completion validation failed: blocked_reason is not `none`.",
      );
    }
    const routingMatrix = resolveRoutingMatrix(options);
    errors.push(...validateCompletionPrGate(stateMap, { routingMatrix }));
    if (routeRequiresCiGate(stateMap, { routingMatrix })) {
      errors.push(...validateCompletionCiGate(stateMap));
    }
    errors.push(...validatePhaseCompleteness(stateMap));
    errors.push(...validatePreparationTerminalContract(stateMap));
    errors.push(
      ...validateRoutingContract(stateMap, {
        routingMatrix,
      }),
    );
  }

  // Existence-only model-routing gate; independent of requireComplete and a
  // no-op for delegation-free checkpoints, preserving backward compatibility.
  if (options.requireModelRouting === true) {
    errors.push(...validateModelRoutingExistence(stateMap));
  }

  errors.push(
    ...validateCodexModelRoutingState(
      stateMap,
      options.requireCodexModelRouting === true,
    ),
  );
  errors.push(
    ...validateCodexTopologyState(
      stateMap,
      options.requireCodexTopology === true,
    ),
  );

  return errors;
}
