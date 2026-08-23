/** Validate legacy and schema-versioned remediation-loop state. */

import { createHash } from "node:crypto";
import { posix as posixPath } from "node:path";

import { validateExceptionBindings } from "./orchestrator-state-remediation-exceptions";
import {
  REMEDIATION_COUNT_ERROR,
  REMEDIATION_CYCLES_KEY,
  REMEDIATION_SEQUENCE_ERROR,
  REMEDIATION_TRANSITION_ERROR,
  codedError,
  isNonEmptyString,
  isNonNegativeInteger,
  isObject,
  isPositiveInteger,
  isVersionedRemediationLoop,
  schemaError,
  validateVersionedSchema,
} from "./orchestrator-state-remediation-schema";
import {
  validateLoopTransition,
  validateReviewTransitions,
  validateStagnation,
} from "./orchestrator-state-remediation-transitions";

export {
  REMEDIATION_CYCLES_KEY,
  isVersionedRemediationLoop,
} from "./orchestrator-state-remediation-schema";

export const REMEDIATION_LOOP_KEY = "remediation_loop";

export interface ValidateRemediationLoopOptions {
  readonly issueNumber?: unknown;
  readonly remediationPass?: unknown;
  readonly routingPolicySha256?: unknown;
  readonly strict?: boolean;
}

export interface CanonicalBlockingFinding {
  readonly audit_kind: string;
  readonly message: string;
  readonly path: string;
  readonly rule_id: string;
}

const PREFLIGHT_CLEARED_STATUS = "clear";
const EXECUTION_STATUSES_REQUIRING_CLEAR_PREFLIGHT = new Set([
  "in_progress",
  "complete",
  "failed",
]);
const FALSE_CANDIDATE_EXECUTION_BY_DISPOSITION: Readonly<
  Record<string, string>
> = {
  no_candidate: "complete",
  external_runtime: "blocked",
  awaiting_ci: "awaiting_ci",
  human_decision: "blocked",
  execution_failed: "failed",
};

function transitionError(subject: string, requirement: string): string {
  return codedError(REMEDIATION_TRANSITION_ERROR, subject, requirement);
}

function formatIntegerList(values: readonly unknown[]): string {
  return `[${values.join(", ")}]`;
}

function normalizeFindingText(
  value: unknown,
  field: string,
  index: number,
): string {
  if (typeof value !== "string" || value.trim() === "") {
    throw new Error(
      `Blocking finding #${index} ${field} must be a non-empty string.`,
    );
  }
  return value.trim().split(/\s+/u).join(" ");
}

function normalizeFindingPath(
  value: unknown,
  workspaceRoot: string | undefined,
  index: number,
): string {
  let normalized = posixPath.normalize(
    normalizeFindingText(value, "path", index).replaceAll("\\", "/"),
  );
  if (workspaceRoot !== undefined) {
    const root = posixPath
      .normalize(workspaceRoot.trim().replaceAll("\\", "/"))
      .replace(/\/+$/u, "");
    const prefix = `${root}/`;
    if (normalized.toLowerCase().startsWith(prefix.toLowerCase())) {
      normalized = normalized.slice(prefix.length);
    }
  }
  while (normalized.startsWith("./")) normalized = normalized.slice(2);
  return normalized;
}

/** Normalize and sort all stable blocker fields for canonical JSON encoding. */
export function normalizeBlockingFindings(
  findings: unknown,
  workspaceRoot?: string,
): CanonicalBlockingFinding[] {
  if (!Array.isArray(findings)) {
    throw new Error("Blocking findings must be an array.");
  }
  const canonical = findings.map((value, index) => {
    if (!isObject(value)) {
      throw new Error(`Blocking finding #${index} must be an object.`);
    }
    return {
      audit_kind: normalizeFindingText(
        value["audit_kind"],
        "audit_kind",
        index,
      ),
      message: normalizeFindingText(value["message"], "message", index),
      path: normalizeFindingPath(value["path"], workspaceRoot, index),
      rule_id: normalizeFindingText(value["rule_id"], "rule_id", index),
    };
  });
  canonical.sort((left, right) => {
    const fields = ["audit_kind", "rule_id", "path", "message"] as const;
    for (const field of fields) {
      if (left[field] !== right[field]) {
        return left[field] < right[field] ? -1 : 1;
      }
    }
    return 0;
  });
  return canonical;
}

/** Return the lowercase SHA-256 digest of canonical stable blocker JSON. */
export function canonicalBlockerFingerprint(
  findings: unknown,
  workspaceRoot?: string,
): string {
  const payload = JSON.stringify(
    normalizeBlockingFindings(findings, workspaceRoot),
  );
  return `sha256:${createHash("sha256").update(payload, "utf8").digest("hex")}`;
}

function validateAttemptSequence(loop: Record<string, unknown>): string[] {
  const attempts = loop["attempts"];
  if (!Array.isArray(attempts)) return [];
  const errors: string[] = [];
  const attemptCount = loop["attempt_count"];
  if (isNonNegativeInteger(attemptCount) && attemptCount !== attempts.length) {
    errors.push(
      codedError(
        REMEDIATION_COUNT_ERROR,
        "remediation_loop.attempt_count",
        `must equal attempts length ${attempts.length}`,
      ),
    );
  }
  const attemptIds = attempts
    .filter(isObject)
    .map((attempt) => attempt["attempt_id"]);
  if (
    attemptIds.length === attempts.length &&
    attemptIds.every(isPositiveInteger)
  ) {
    const expected = attempts.map((_value, index) => index + 1);
    if (attemptIds.some((attemptId, index) => attemptId !== expected[index])) {
      errors.push(
        codedError(
          REMEDIATION_SEQUENCE_ERROR,
          "remediation_loop attempt_id sequence",
          `must be ${formatIntegerList(expected)}; received ${formatIntegerList(attemptIds)}`,
        ),
      );
    }
  }
  return errors;
}

function validateCycleSequence(loop: Record<string, unknown>): string[] {
  const cycles = loop[REMEDIATION_CYCLES_KEY];
  const attempts = loop["attempts"];
  if (!Array.isArray(cycles) || !Array.isArray(attempts)) return [];
  const errors: string[] = [];
  const completedCount = loop["completed_cycle_count"];
  if (
    isNonNegativeInteger(completedCount) &&
    completedCount !== cycles.length
  ) {
    errors.push(
      codedError(
        REMEDIATION_COUNT_ERROR,
        "remediation_loop.completed_cycle_count",
        `must equal cycles length ${cycles.length}`,
      ),
    );
  }
  const cycleIds = cycles.filter(isObject).map((cycle) => cycle["cycle_id"]);
  if (cycleIds.length === cycles.length && cycleIds.every(isPositiveInteger)) {
    const expected = cycles.map((_value, index) => index + 1);
    if (cycleIds.some((cycleId, index) => cycleId !== expected[index])) {
      errors.push(
        codedError(
          REMEDIATION_SEQUENCE_ERROR,
          "remediation_loop cycle_id sequence",
          `must be ${formatIntegerList(expected)}; received ${formatIntegerList(cycleIds)}`,
        ),
      );
    }
  }
  const attemptById = new Map<unknown, Record<string, unknown>>();
  attempts.filter(isObject).forEach((attempt) => {
    if (isPositiveInteger(attempt["attempt_id"])) {
      attemptById.set(attempt["attempt_id"], attempt);
    }
  });
  const references = cycles.flatMap((cycle, index) =>
    isObject(cycle) && isPositiveInteger(cycle["attempt_id"])
      ? [[index, cycle["attempt_id"]] as const]
      : [],
  );
  const referenceIds = references.map(([, attemptId]) => attemptId);
  if (new Set(referenceIds).size !== referenceIds.length) {
    errors.push(
      codedError(
        REMEDIATION_SEQUENCE_ERROR,
        "remediation_loop cycle attempt references",
        "must be unique",
      ),
    );
  }
  references.forEach(([cycleIndex, attemptId]) => {
    const attempt = attemptById.get(attemptId);
    const subject = `remediation_loop.cycles[${cycleIndex}].attempt_id`;
    if (attempt === undefined) {
      errors.push(
        transitionError(subject, `references missing attempt ${attemptId}`),
      );
      return;
    }
    const preflight = attempt["preflight"];
    const eligibility: readonly (readonly [boolean, string])[] = [
      [
        isObject(preflight) && preflight["final_status"] === "clear",
        "preflight must be clear",
      ],
      [
        attempt["execution_status"] === "complete",
        "execution_status must be complete",
      ],
      [attempt["candidate_applied"] === true, "candidate_applied must be true"],
    ];
    eligibility.forEach(([valid, requirement]) => {
      if (!valid) errors.push(transitionError(subject, requirement));
    });
  });
  return errors;
}

function validateExitConditions(loop: Record<string, unknown>): string[] {
  const cycles = loop[REMEDIATION_CYCLES_KEY];
  if (!Array.isArray(cycles)) return [];
  const errors: string[] = [];
  cycles.forEach((value, index) => {
    if (!isObject(value) || typeof value["exit_condition_met"] !== "boolean") {
      return;
    }
    const expected =
      value["review_verdict"] === "PASS" &&
      value["remediation_action"] === "NONE" &&
      value["blocking_count"] === 0;
    if (value["exit_condition_met"] !== expected) {
      errors.push(
        transitionError(
          `remediation_loop.cycles[${index}].exit_condition_met`,
          "must be true exactly for PASS/NONE with blocking_count 0",
        ),
      );
    }
  });
  return errors;
}

function validateRemediationPass(
  loop: Record<string, unknown>,
  options: ValidateRemediationLoopOptions,
): string[] {
  if (!Object.hasOwn(options, "remediationPass")) return [];
  const completedCount = loop["completed_cycle_count"];
  if (
    isNonNegativeInteger(options.remediationPass) &&
    options.remediationPass === completedCount
  ) {
    return [];
  }
  return [
    codedError(
      REMEDIATION_COUNT_ERROR,
      "remediation-pass",
      `must equal remediation_loop.completed_cycle_count ${String(completedCount)}`,
    ),
  ];
}

function validateCandidateTransitions(loop: Record<string, unknown>): string[] {
  const attempts = loop["attempts"];
  if (!Array.isArray(attempts)) return [];
  const errors: string[] = [];
  attempts.forEach((value, index) => {
    if (!isObject(value)) return;
    const subject = `remediation_loop.attempts[${index}]`;
    const candidateApplied = value["candidate_applied"];
    const executionStatus = value["execution_status"];
    const disposition = value["terminal_disposition"];
    if (candidateApplied === true) {
      if (
        executionStatus !== "complete" ||
        disposition !== "candidate_applied"
      ) {
        errors.push(
          transitionError(
            subject,
            "an applied candidate requires complete/candidate_applied",
          ),
        );
      }
    } else if (candidateApplied === false && typeof disposition === "string") {
      const expectedExecution =
        FALSE_CANDIDATE_EXECUTION_BY_DISPOSITION[disposition];
      if (
        expectedExecution === undefined ||
        executionStatus !== expectedExecution
      ) {
        errors.push(
          transitionError(
            subject,
            "a false candidate requires its matching terminal execution",
          ),
        );
      }
      if (index !== attempts.length - 1) {
        errors.push(
          transitionError(
            subject,
            "a false candidate cannot precede another attempt",
          ),
        );
      }
    }
    if (typeof candidateApplied === "boolean" && value["finished_at"] == null) {
      errors.push(
        transitionError(subject, "a terminal candidate requires finished_at"),
      );
    }
  });
  return errors;
}

function validateLegacyCycle(
  index: number,
  cycle: Record<string, unknown>,
): string[] {
  const errors: string[] = [];
  if (!isNonEmptyString(cycle["plan_path"])) {
    errors.push(
      `Checkpoint remediation cycle #${index} plan_path must be a non-empty string.`,
    );
  }
  const executionStatus = cycle["execution_status"];
  if (
    typeof executionStatus === "string" &&
    EXECUTION_STATUSES_REQUIRING_CLEAR_PREFLIGHT.has(executionStatus)
  ) {
    const preflight = cycle["preflight"];
    if (
      !isObject(preflight) ||
      preflight["final_status"] !== PREFLIGHT_CLEARED_STATUS
    ) {
      errors.push(
        `Checkpoint remediation cycle #${index} execution_status is ` +
          `${executionStatus} but preflight.final_status is not 'clear'.`,
      );
    }
  }
  if (cycle["exit_condition_met"] === true && cycle["blocking_count"] !== 0) {
    errors.push(
      `Checkpoint remediation cycle #${index} exit_condition_met is true ` +
        "but blocking_count is not 0.",
    );
  }
  return errors;
}

/** Validate a legacy or schema-versioned remediation loop. */
export function validateRemediationLoop(
  remediationLoop: unknown,
  options: ValidateRemediationLoopOptions = {},
): string[] {
  if (!isObject(remediationLoop)) {
    return options.strict
      ? [
          schemaError(
            "legacy remediation_loop",
            "requires evidence-backed schema version 2 migration before strict validation",
          ),
        ]
      : [];
  }
  if (isVersionedRemediationLoop(remediationLoop)) {
    const errors = validateVersionedSchema(remediationLoop);
    errors.push(...validateAttemptSequence(remediationLoop));
    errors.push(...validateCycleSequence(remediationLoop));
    errors.push(...validateRemediationPass(remediationLoop, options));
    errors.push(...validateReviewTransitions(remediationLoop));
    errors.push(...validateExitConditions(remediationLoop));
    const [bindingErrors, authorizedCycles] = validateExceptionBindings(
      remediationLoop,
      options,
    );
    errors.push(...bindingErrors);
    errors.push(...validateStagnation(remediationLoop, authorizedCycles));
    errors.push(...validateCandidateTransitions(remediationLoop));
    errors.push(...validateLoopTransition(remediationLoop));
    return errors;
  }
  const cycles = remediationLoop[REMEDIATION_CYCLES_KEY];
  const errors: string[] = [];
  if (Array.isArray(cycles)) {
    cycles.forEach((cycle, index) => {
      if (!isObject(cycle)) {
        errors.push(
          `Checkpoint remediation cycle #${index} must be an object.`,
        );
      } else {
        errors.push(...validateLegacyCycle(index, cycle));
      }
    });
  }
  if (options.strict) {
    errors.push(
      schemaError(
        "legacy remediation_loop",
        "requires evidence-backed schema version 2 migration before strict validation",
      ),
    );
  }
  return errors;
}
