"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.PLAN_TASK_RE = exports.PLAN_PHASE_RE = void 0;
exports.deduplicateSelectedRoutingDiagnostics = deduplicateSelectedRoutingDiagnostics;
exports.validatePlanText = validatePlanText;
exports.validateArtifactWithWarnings = validateArtifactWithWarnings;
exports.validateArtifact = validateArtifact;
const epic_kickoff_artifact_1 = require("./epic-kickoff-artifact");
const epic_orchestrator_state_core_1 = require("./epic-orchestrator-state-core");
const epic_planner_state_core_1 = require("./epic-planner-state-core");
const epic_planner_git_integrity_1 = require("./epic-planner-git-integrity");
const orchestrator_state_core_1 = require("./orchestrator-state-core");
const parallel_kickoff_artifact_1 = require("./parallel-kickoff-artifact");
const parallel_codex_readiness_filesystem_1 = require("./parallel-codex-readiness-filesystem");
const plan_gate_discrimination_1 = require("./plan-gate-discrimination");
const parallel_orchestrator_state_core_1 = require("./parallel-orchestrator-state-core");
const parallel_planner_state_core_1 = require("./parallel-planner-state-core");
const policy_audit_artifact_1 = require("./policy-audit-artifact");
const review_artifacts_1 = require("./review-artifacts");
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
exports.PLAN_PHASE_RE = /^### Phase (?<phase>\d+) — (?<title>.+)$/;
/** Canonical task line regex. */
exports.PLAN_TASK_RE = /^- \[(?<state>[ xX])\] \[P(?<phase>\d+)-T(?<task>\d+)\] (?<title>.+)$/;
const ROUTING_GATE_BY_CODE = new Map([
    ["ORCH_ROUTING_GATE_LEGACY", "legacy"],
    ["ORCH_ROUTING_GATE_CODEX_MODEL", "codex_model"],
    ["ORCH_ROUTING_GATE_CODEX_TOPOLOGY", "codex_topology"],
]);
const ROUTING_RECORD_RE = /(?:\[\d+\]|phase [^ .]+|delegated agent: [^.]+)/u;
function routingDiagnosticIdentity(error) {
    for (const [code, gate] of ROUTING_GATE_BY_CODE) {
        const prefix = `${code}: `;
        if (!error.startsWith(prefix)) {
            continue;
        }
        const subject = error.slice(prefix.length);
        const recordId = ROUTING_RECORD_RE.exec(subject)?.[0] ?? "checkpoint";
        return JSON.stringify([gate, recordId, code, subject]);
    }
    return undefined;
}
/** Preserve order while removing only identical selected-routing identities. */
function deduplicateSelectedRoutingDiagnostics(errors) {
    const result = [];
    const seen = new Set();
    for (const error of errors) {
        const identity = routingDiagnosticIdentity(error);
        if (identity !== undefined && seen.has(identity)) {
            continue;
        }
        if (identity !== undefined) {
            seen.add(identity);
        }
        result.push(error);
    }
    return result;
}
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
function validatePlanText(text) {
    const errors = [];
    let currentPhase = null;
    const seenPhases = [];
    const expectedTaskNum = new Map();
    let foundTask = false;
    // Walk the document in source order so numbering and phase mismatches are
    // reported against the same line numbers a maintainer sees in the plan.
    const lines = text.split(/\r\n|\n|\r/);
    lines.forEach((line, lineIndex) => {
        const lineNumber = lineIndex + 1;
        // Phase headings reset the current-phase context and seed task numbering.
        if (line.startsWith("### Phase ")) {
            const match = exports.PLAN_PHASE_RE.exec(line);
            if (match === null) {
                errors.push(`Line ${lineNumber}: phase heading must match ` +
                    "`### Phase N — <Title>`.");
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
            const match = exports.PLAN_TASK_RE.exec(line);
            if (match === null) {
                errors.push(`Line ${lineNumber}: task line must match ` +
                    "`- [ ] [P#-T#] <Title>`.");
                return;
            }
            const taskPhase = Number(match.groups?.["phase"]);
            const taskNum = Number(match.groups?.["task"]);
            if (currentPhase === null) {
                errors.push(`Line ${lineNumber}: task appears before a canonical phase heading.`);
                return;
            }
            if (taskPhase !== currentPhase) {
                errors.push(`Line ${lineNumber}: task phase P${taskPhase} does not match ` +
                    `current phase ${currentPhase}.`);
            }
            const expected = expectedTaskNum.get(taskPhase) ?? 1;
            if (!expectedTaskNum.has(taskPhase)) {
                expectedTaskNum.set(taskPhase, 1);
            }
            if (taskNum !== expected) {
                errors.push(`Line ${lineNumber}: expected task number T${expected} for phase ` +
                    `${taskPhase}, found T${taskNum}.`);
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
function buildParallelReadiness(input) {
    if (input.fs === undefined ||
        input.root === undefined ||
        input.artifactPath === undefined ||
        input.runner === undefined) {
        return {
            errors: [
                "Parallel Codex readiness evidence context requires filesystem, " +
                    "workspace root, artifact path, and Git runner.",
            ],
        };
    }
    return (0, parallel_codex_readiness_filesystem_1.buildParallelCodexReadinessEvidence)(input.text, {
        fileSystem: input.fs,
        workspaceRoot: input.root,
        artifactPath: input.artifactPath,
        runner: input.runner,
    });
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
function buildPlanGateContext(input) {
    if (input.fs === undefined ||
        input.root === undefined ||
        input.artifactPath === undefined ||
        input.runner === undefined) {
        return undefined;
    }
    return {
        workspaceRoot: input.root,
        fileSystem: input.fs,
        git: new plan_gate_discrimination_1.CommandRunnerPlanGateRepository(input.root, input.runner),
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
function validateArtifactWithWarnings(input) {
    // The plan route is handled ahead of the type switch because it is the only
    // route that produces two channels and the only one that needs a repository
    // seam built from the dispatcher's wiring fields.
    if (input.artifactType === "plan") {
        const report = (0, plan_gate_discrimination_1.evaluatePlanGates)(input.text, buildPlanGateContext(input));
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
function validateArtifact(input) {
    return validateArtifactWithWarnings(input).errors;
}
/**
 * Route a non-plan artifact type to its dedicated validator.
 *
 * @param input Artifact type, text, and orchestrator-state wiring options.
 * @returns Validation errors produced by the selected validator.
 */
function dispatchValidatorErrors(input) {
    // Route each supported artifact type to its dedicated validator. The
    // orchestrator-state route additionally threads the completion flag and the
    // routing-matrix wiring. The `plan` route never reaches this switch; it is
    // handled by `validateArtifactWithWarnings` above.
    switch (input.artifactType) {
        case "policy-audit":
            return (0, policy_audit_artifact_1.validatePolicyAuditText)(input.text);
        case "code-review":
            return (0, review_artifacts_1.validateCodeReviewText)(input.text);
        case "feature-audit":
            return (0, review_artifacts_1.validateFeatureAuditText)(input.text);
        case "orchestrator-state": {
            const options = {
                ...(input.requireComplete === undefined
                    ? {}
                    : { requireComplete: input.requireComplete }),
                ...(input.requirePrCreationReady === undefined
                    ? {}
                    : { requirePrCreationReady: input.requirePrCreationReady }),
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
            return deduplicateSelectedRoutingDiagnostics((0, orchestrator_state_core_1.validateOrchestratorStateText)(input.text, options));
        }
        case "epic-orchestrator-state": {
            const options = {
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
            return (0, epic_orchestrator_state_core_1.validateEpicOrchestratorStateText)(input.text, options);
        }
        case "epic-planner-state": {
            const options = {
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
                            git: new epic_planner_git_integrity_1.CommandRunnerGitRepository(input.root, input.runner),
                        },
                    }),
            };
            return (0, epic_planner_state_core_1.validateEpicPlannerStateText)(input.text, options);
        }
        case "epic-kickoff":
            return (0, epic_kickoff_artifact_1.validateEpicKickoffText)(input.text);
        case "parallel-orchestrator-state": {
            const readiness = input.requireComplete === true
                ? buildParallelReadiness(input)
                : { errors: [] };
            const options = {
                ...(input.requireComplete === undefined
                    ? {}
                    : { requireComplete: input.requireComplete }),
                ...(readiness.evidence === undefined
                    ? {}
                    : { readinessContext: readiness.evidence }),
            };
            return [
                ...readiness.errors,
                ...(0, parallel_orchestrator_state_core_1.validateParallelOrchestratorStateText)(input.text, options),
            ];
        }
        case "parallel-planner-state": {
            const readiness = input.requireReadyForExecution === true
                ? buildParallelReadiness(input)
                : { errors: [] };
            const options = {
                ...(input.requireReadyForExecution === undefined
                    ? {}
                    : { requireReadyForExecution: input.requireReadyForExecution }),
                ...(readiness.evidence === undefined
                    ? {}
                    : { readinessContext: readiness.evidence }),
            };
            return [
                ...readiness.errors,
                ...(0, parallel_planner_state_core_1.validateParallelPlannerStateText)(input.text, options),
            ];
        }
        case "parallel-kickoff": {
            const errors = (0, parallel_kickoff_artifact_1.validateParallelKickoffText)(input.text, {
                ...(input.requireReadyForExecution === undefined
                    ? {}
                    : { requireReadyForExecution: input.requireReadyForExecution }),
            });
            if (input.requireReadyForExecution !== true)
                return errors;
            if (input.fs === undefined ||
                input.root === undefined ||
                input.artifactPath === undefined ||
                input.runner === undefined) {
                return [
                    ...errors,
                    "Parallel committed kickoff evidence context requires filesystem, " +
                        "workspace root, artifact path, and Git runner.",
                ];
            }
            return [
                ...errors,
                ...(0, parallel_codex_readiness_filesystem_1.validateCommittedParallelKickoff)(input.text, {
                    fileSystem: input.fs,
                    workspaceRoot: input.root,
                    artifactPath: input.artifactPath,
                    runner: input.runner,
                }),
            ];
        }
        default:
            return [`Unsupported artifact type: ${input.artifactType}`];
    }
}
