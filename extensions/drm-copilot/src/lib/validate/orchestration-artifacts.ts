import type { FileSystem } from "../file-system";
import type { CommandRunner } from "../subprocess-runner";
import { validateEpicKickoffText } from "./epic-kickoff-artifact";
import {
  validateEpicOrchestratorStateText,
  type ValidateEpicOrchestratorStateOptions,
} from "./epic-orchestrator-state-core";
import {
  validateEpicPlannerStateText,
  type ValidateEpicPlannerStateOptions,
} from "./epic-planner-state-core";
import { CommandRunnerGitRepository } from "./epic-planner-git-integrity";
import {
  validateOrchestratorStateText,
  type ValidateOrchestratorStateOptions,
} from "./orchestrator-state-core";
import { validateParallelKickoffText } from "./parallel-kickoff-artifact";
import {
  CommandRunnerPlanGateRepository,
  evaluatePlanGates,
  type PlanGateContext,
} from "./plan-gate-discrimination";
import {
  validateParallelOrchestratorStateText,
  type ValidateParallelOrchestratorStateOptions,
} from "./parallel-orchestrator-state-core";
import {
  validateParallelPlannerStateText,
  type ValidateParallelPlannerStateOptions,
} from "./parallel-planner-state-core";
import { validatePolicyAuditText } from "./policy-audit-artifact";
import {
  validateCodeReviewText,
  validateFeatureAuditText,
} from "./review-artifacts";
import { validateHandoffEnvelopeText } from "./orchestration-handoff-contract";

/**
 * Orchestration-artifact dispatcher and canonical-plan validator.
 *
 * Purpose:
 *     Port `scripts/dev_tools/validate_orchestration_artifacts.py`. Provide the
 *     canonical atomic-plan structural validator and an in-process dispatcher
 *     that routes each supported artifact type to its validator.
 *
 * Responsibilities:
 *     - `validatePlanText`: enforce the phase/task structure of atomic plans.
 *     - `validateArtifact`: route `plan`, `policy-audit`, `code-review`,
 *       `feature-audit`, orchestration checkpoint, and epic-kickoff artifact
 *       types, with an unsupported-type fallback.
 *
 * Invariants / Constraints:
 *     - Phase/task regexes and error-message strings are identical to the Python
 *       source.
 *
 * Side Effects:
 *     None directly; the injected `FileSystem` performs reads when the
 *     orchestrator-state route loads the routing matrix.
 */

/** Canonical phase heading regex (em dash separator). */
export const PLAN_PHASE_RE = /^### Phase (?<phase>\d+) — (?<title>.+)$/;

/** Canonical task line regex. */
export const PLAN_TASK_RE =
  /^- \[(?<state>[ xX])\] \[P(?<phase>\d+)-T(?<task>\d+)\] (?<title>.+)$/;

/**
 * Validate canonical atomic-plan structure.
 *
 * Purpose:
 *     Mirror Python `validate_plan_text`. Enforce the required phase and task
 *     formatting for atomic execution plans, reporting structural violations
 *     against source line numbers.
 *
 * @param text Full plan document text.
 * @returns Validation errors describing structural contract violations.
 */
export function validatePlanText(text: string): string[] {
  const errors: string[] = [];
  let currentPhase: number | null = null;
  const seenPhases: number[] = [];
  const expectedTaskNum = new Map<number, number>();
  let foundTask = false;

  // Walk the document in source order so numbering and phase mismatches are
  // reported against the same line numbers a maintainer sees in the plan.
  const lines = text.split(/\r\n|\n|\r/);
  lines.forEach((line, lineIndex) => {
    const lineNumber = lineIndex + 1;

    // Phase headings reset the current-phase context and seed task numbering.
    if (line.startsWith("### Phase ")) {
      const match = PLAN_PHASE_RE.exec(line);
      if (match === null) {
        errors.push(
          `Line ${lineNumber}: phase heading must match ` +
            "`### Phase N — <Title>`.",
        );
        currentPhase = null;
        return;
      }
      currentPhase = Number(match.groups?.["phase"]);
      seenPhases.push(currentPhase);
      if (!expectedTaskNum.has(currentPhase)) {
        expectedTaskNum.set(currentPhase, 1);
      }
      return;
    }

    // Task lines carry a `[P#-T#]` token; validate numbering against the phase.
    if (line.startsWith("- [") && line.includes("[P") && line.includes("-T")) {
      foundTask = true;
      const match = PLAN_TASK_RE.exec(line);
      if (match === null) {
        errors.push(
          `Line ${lineNumber}: task line must match ` +
            "`- [ ] [P#-T#] <Title>`.",
        );
        return;
      }
      const taskPhase = Number(match.groups?.["phase"]);
      const taskNum = Number(match.groups?.["task"]);
      if (currentPhase === null) {
        errors.push(
          `Line ${lineNumber}: task appears before a canonical phase heading.`,
        );
        return;
      }
      if (taskPhase !== currentPhase) {
        errors.push(
          `Line ${lineNumber}: task phase P${taskPhase} does not match ` +
            `current phase ${currentPhase}.`,
        );
      }
      const expected = expectedTaskNum.get(taskPhase) ?? 1;
      if (!expectedTaskNum.has(taskPhase)) {
        expectedTaskNum.set(taskPhase, 1);
      }
      if (taskNum !== expected) {
        errors.push(
          `Line ${lineNumber}: expected task number T${expected} for phase ` +
            `${taskPhase}, found T${taskNum}.`,
        );
      }
      expectedTaskNum.set(taskPhase, Math.max(expected, taskNum) + 1);
    }
  });

  if (seenPhases.length === 0) {
    errors.push("Plan does not contain any canonical phase headings.");
  }
  if (!foundTask) {
    errors.push("Plan does not contain any canonical task lines.");
  }
  return errors;
}

/** Input for the orchestration-artifact dispatcher. */
export interface ValidateArtifactInput {
  /** Artifact type selecting the validator route. */
  readonly artifactType: string;
  /** Full artifact text to validate. */
  readonly text: string;
  /** Require completion-safe state (orchestrator-state route only). */
  readonly requireComplete?: boolean;
  /** Require model-routing receipts once delegated (orchestrator-state route). */
  readonly requireModelRouting?: boolean;
  /** Require canonical Codex deployment receipts for delegated agents. */
  readonly requireCodexModelRouting?: boolean;
  /** Require canonical Codex topology receipts for delegated agents. */
  readonly requireCodexTopology?: boolean;
  /** Require a fully prepared epic plan (epic-planner-state route only). */
  readonly requireReadyForExecution?: boolean;
  /** Artifact path used to bind repository-aware planner validation. */
  readonly artifactPath?: string;
  /** Injected Git command runner used by planner readiness validation. */
  readonly runner?: CommandRunner;
  /** Injected filesystem (orchestrator-state route routing-matrix load). */
  readonly fs?: FileSystem;
  /** Repository root (orchestrator-state route routing-matrix load). */
  readonly root?: string;
  /** Explicit routing matrix (orchestrator-state route). */
  readonly routingMatrix?: unknown;
}

/**
 * Build the plan-gate repository context from the dispatcher input.
 *
 * The plan route acquires its repository seam exactly the way the
 * epic-planner-state route does: every wiring field must be present, otherwise
 * the gate runs context-free and only the G1 and G4 rules apply.
 *
 * @param input Dispatcher input carrying the optional wiring fields.
 * @returns A context, or `undefined` when any wiring field is absent.
 */
function buildPlanGateContext(
  input: ValidateArtifactInput,
): PlanGateContext | undefined {
  if (
    input.fs === undefined ||
    input.root === undefined ||
    input.artifactPath === undefined ||
    input.runner === undefined
  ) {
    return undefined;
  }
  return {
    workspaceRoot: input.root,
    fileSystem: input.fs,
    git: new CommandRunnerPlanGateRepository(input.root, input.runner),
  };
}

/**
 * Dispatch the requested validator on both severity channels.
 *
 * Purpose:
 *     Mirror Python `validate_plan_text_with_warnings` and
 *     `_validate_from_args_with_warnings`. Give the service layer access to the
 *     Warning channel without widening `validateArtifact`, whose non-empty
 *     return is the failure signal every existing caller depends on.
 *
 * @param input Artifact type, text, and orchestrator-state wiring options.
 * @returns Validation errors and, for the `plan` route, gate Warnings. Only the
 *     `plan` route can populate the Warning channel today.
 */
export function validateArtifactWithWarnings(input: ValidateArtifactInput): {
  errors: string[];
  warnings: string[];
} {
  // The plan route is handled ahead of the type switch because it is the only
  // route that produces two channels and the only one that needs a repository
  // seam built from the dispatcher's wiring fields.
  if (input.artifactType === "plan") {
    const report = evaluatePlanGates(input.text, buildPlanGateContext(input));
    return {
      errors: [...validatePlanText(input.text), ...report.blocking],
      warnings: report.warnings,
    };
  }
  return { errors: dispatchValidatorErrors(input), warnings: [] };
}

/**
 * Dispatch the requested validator.
 *
 * Purpose:
 *     Mirror Python `_validate_from_args` routing while keeping the supported
 *     artifact-type names unchanged. The single-channel return shape and every
 *     existing call site are unchanged; the body delegates to
 *     {@link validateArtifactWithWarnings} and returns its error channel.
 *
 * @param input Artifact type, text, and orchestrator-state wiring options.
 * @returns Validation errors produced by the selected validator.
 */
export function validateArtifact(input: ValidateArtifactInput): string[] {
  return validateArtifactWithWarnings(input).errors;
}

/**
 * Route a non-plan artifact type to its dedicated validator.
 *
 * @param input Artifact type, text, and orchestrator-state wiring options.
 * @returns Validation errors produced by the selected validator.
 */
function dispatchValidatorErrors(input: ValidateArtifactInput): string[] {
  // Route each supported artifact type to its dedicated validator. The
  // orchestrator-state route additionally threads the completion flag and the
  // routing-matrix wiring. The `plan` route never reaches this switch; it is
  // handled by `validateArtifactWithWarnings` above.
  switch (input.artifactType) {
    case "policy-audit":
      return validatePolicyAuditText(input.text);
    case "code-review":
      return validateCodeReviewText(input.text);
    case "feature-audit":
      return validateFeatureAuditText(input.text);
    case "orchestrator-state": {
      const options: ValidateOrchestratorStateOptions = {
        ...(input.requireComplete === undefined
          ? {}
          : { requireComplete: input.requireComplete }),
        ...(input.requireModelRouting === undefined
          ? {}
          : { requireModelRouting: input.requireModelRouting }),
        ...(input.requireCodexModelRouting === undefined
          ? {}
          : { requireCodexModelRouting: input.requireCodexModelRouting }),
        ...(input.requireCodexTopology === undefined
          ? {}
          : { requireCodexTopology: input.requireCodexTopology }),
        ...(input.fs === undefined ? {} : { fs: input.fs }),
        ...(input.root === undefined ? {} : { root: input.root }),
        ...(input.routingMatrix === undefined
          ? {}
          : { routingMatrix: input.routingMatrix }),
      };
      return validateOrchestratorStateText(input.text, options);
    }
    case "epic-orchestrator-state": {
      const options: ValidateEpicOrchestratorStateOptions = {
        ...(input.requireComplete === undefined
          ? {}
          : { requireComplete: input.requireComplete }),
        ...(input.requireCodexModelRouting === undefined
          ? {}
          : { requireCodexModelRouting: input.requireCodexModelRouting }),
        ...(input.requireCodexTopology === undefined
          ? {}
          : { requireCodexTopology: input.requireCodexTopology }),
      };
      return validateEpicOrchestratorStateText(input.text, options);
    }
    case "epic-planner-state": {
      const options: ValidateEpicPlannerStateOptions = {
        ...(input.requireReadyForExecution === undefined
          ? {}
          : { requireReadyForExecution: input.requireReadyForExecution }),
        ...(input.fs === undefined ||
        input.root === undefined ||
        input.artifactPath === undefined ||
        input.runner === undefined
          ? {}
          : {
              readinessContext: {
                workspaceRoot: input.root,
                artifactPath: input.artifactPath,
                fileSystem: input.fs,
                git: new CommandRunnerGitRepository(input.root, input.runner),
              },
            }),
      };
      return validateEpicPlannerStateText(input.text, options);
    }
    case "epic-kickoff":
      return validateEpicKickoffText(input.text);
    case "parallel-orchestrator-state": {
      const options: ValidateParallelOrchestratorStateOptions = {
        ...(input.requireComplete === undefined
          ? {}
          : { requireComplete: input.requireComplete }),
      };
      return validateParallelOrchestratorStateText(input.text, options);
    }
    case "parallel-planner-state": {
      const options: ValidateParallelPlannerStateOptions = {
        ...(input.requireReadyForExecution === undefined
          ? {}
          : { requireReadyForExecution: input.requireReadyForExecution }),
      };
      return validateParallelPlannerStateText(input.text, options);
    }
    case "parallel-kickoff":
      return validateParallelKickoffText(input.text);
    case "portable-orchestration-handoff": {
      const failure = validateHandoffEnvelopeText(input.text);
      return failure === null ? [] : [failure];
    }
    default:
      return [`Unsupported artifact type: ${input.artifactType}`];
  }
}
