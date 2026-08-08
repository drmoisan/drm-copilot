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
 * Dispatch the requested validator.
 *
 * Purpose:
 *     Mirror Python `_validate_from_args` routing while keeping the supported
 *     artifact-type names unchanged.
 *
 * @param input Artifact type, text, and orchestrator-state wiring options.
 * @returns Validation errors produced by the selected validator.
 */
export function validateArtifact(input: ValidateArtifactInput): string[] {
  // Route each supported artifact type to its dedicated validator. The
  // orchestrator-state route additionally threads the completion flag and the
  // routing-matrix wiring.
  switch (input.artifactType) {
    case "plan":
      return validatePlanText(input.text);
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
    default:
      return [`Unsupported artifact type: ${input.artifactType}`];
  }
}
