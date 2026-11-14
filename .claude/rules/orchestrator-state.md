---
paths:
  - "artifacts/orchestration/*orchestrator-state.json"
  - "artifacts/orchestration/*planner-state.json"
  - "scripts/dev_tools/*orchestrator_state*"
  - "extensions/drm-copilot/src/lib/validate/orchestrator-state-*"
  - "scripts/dev_tools/compute_complexity_floor.py"
  - "scripts/dev_tools/resolve_delegation_model.py"
  - ".claude/hooks/validate-orchestrator-output.ps1"
  - ".claude/hooks/enforce-model-routing-receipt.ps1"
  - "config/orchestration-routing.json"
  - ".claude/agents/orchestrator.md"
  - ".claude/agents/epic-orchestrator.md"
  - ".claude/agents/parallel-orchestrator.md"
  - ".claude/agents/epic-planner.md"
  - ".claude/agents/parallel-planner.md"
  - ".claude/skills/orchestrate/SKILL.md"
  - ".claude/skills/epic-orchestrate/SKILL.md"
  - ".claude/skills/parallel-orchestrate/SKILL.md"
  - ".claude/skills/epic-plan/SKILL.md"
  - ".claude/skills/parallel-plan/SKILL.md"
description: Checkpoint invariants for the orchestration state artifact and the surfaces that write or validate it.
---

# Orchestrator-State Remediation-Cycle and Human-Interaction Invariants

This rule governs remediation-cycle records and the optional `human_interaction` block in the orchestrator-state checkpoint at `artifacts/orchestration/orchestrator-state.json`. It documents the invariants that must hold for each remediation cycle and for the remediation-loop review outcomes and attempt count, plus three invariants for the `human_interaction` block, so that resume and review workflows do not depend on a structurally invalid checkpoint.

## Foreign Schema Warning (do not copy verbatim)

A hardened snapshot from another repository contains a JSON Schema for the orchestrator-state artifact whose `$id` references a foreign origin (`drmoisan.github.io/mix-calculator/`). That schema MUST NOT be copied verbatim into this repository: its `$id`, its top-level required-field set, and its cycle-level `additionalProperties: false` do not match this repository's checkpoint contract. The invariants below are re-expressed here as prose and enforced by validator logic in `scripts/dev_tools/validate_orchestrator_state.py`, not by importing a foreign schema file.

This prohibition is specific to the disqualified foreign schema identified by the `drmoisan.github.io/mix-calculator/` `$id`. A schema whose `$id` is repo-local and whose required-field set and `additionalProperties` policy match this repository's checkpoint contract is not the disqualified foreign artifact; even so, the repository's enforcement mechanism remains the Python validator prose-and-logic above, not an imported schema file.

## Required Top-Level Keys

Plain validation requires every key below at the top level of the orchestrator-state checkpoint. The authority is `REQUIRED_STATE_KEYS` in `scripts/dev_tools/validate_orchestrator_state.py`. The TypeScript port in `extensions/drm-copilot/src/lib/validate/orchestrator-state-core.ts` and the PowerShell port in `.claude/lib/orchestrator-state/OrchestratorState.psm1` carry the same keys in the same order.

- `objective`
- `change_budget_estimate`
- `path_selected`
- `promotion-type`
- `short-name`
- `relativeFile`
- `long-name`
- `issue-num`
- `feature-folder`
- `work-mode`
- `plan-path`
- `completed_steps`
- `next_step`
- `last_updated`
- `step5_status`
- `step6_status`
- `step7_status`
- `step8_status`
- `step9_status`
- `step10_status`
- `delegation_receipts`
- `blocked_reason`

The check is unconditional: it runs with or without `--require-complete`, `--require-pr-creation-ready`, `--require-model-routing`, `--require-codex-model-routing`, and `--require-codex-topology`, and it is skipped only for a `portable_orchestration_handoff` envelope. The check is presence-only: a key whose value is any JSON value, including `null`, satisfies it. Each absent key produces one error line, `Checkpoint missing required key: <key>`. Some keys carry further validation when present, such as the step-status vocabulary for the `step*_status` keys and the Blocked-Reason Vocabulary below for `blocked_reason`.

`last_updated` records when the checkpoint was last written. Write it as an ISO-8601 UTC date-time string, for example `2026-10-08T17:28:00Z`. The value is rewritten on every checkpoint write: after every completed step and every state transition, including halts. The validators check presence only and do not parse the value, so a non-UTC, placeholder, or `null` value still passes the required-key check.

## Scope and Backward Compatibility

These invariants apply only when the checkpoint contains a top-level `remediation_loop`; the per-cycle invariants apply when it has a `cycles` array, and the review-outcome and attempt-count invariants apply when their keys are present. A checkpoint with no `remediation_loop` (the existing step-based checkpoint shape) is unaffected: it validates exactly as before and produces no new errors. The invariants are additive.

## Invariants (per remediation cycle)

1. **Non-empty `plan_path`.** Each cycle's `plan_path` must be a non-empty string. A missing value, a non-string value, or an empty/whitespace-only string is a malformed cycle.

2. **Execution requires cleared preflight.** A cycle's `execution_status` may be in `{in_progress, complete, failed}` only when that cycle's `preflight.final_status` is exactly `'clear'`. Any other preflight status with one of those execution statuses is a malformed cycle (execution was recorded before preflight cleared). The invariant does not apply to a cycle whose `remediation_path` is exactly the string `light`, compared ordinally, because a light cycle runs no preflight; invariant 8 governs that cycle.

3. **Exit gate requires zero blocking findings.** When a cycle's `exit_condition_met == true`, its `blocking_count` must be `0`. A non-zero `blocking_count` with `exit_condition_met == true` is a malformed cycle (the exit gate was marked satisfied while blocking findings remained).

4. **`candidate_applied` is a boolean (R5).** When a cycle object carries `candidate_applied`, its value must be a JSON boolean, and any other value is a malformed cycle.

5. **A completed attempt requires completed execution (R6).** A cycle whose `candidate_applied == true` must have `execution_status == "complete"`, and `candidate_applied == true` with any other execution status is a malformed cycle.

6. **`opened_by_review` references a remediation review (R11).** When a cycle object carries `opened_by_review`, its value must be a non-negative integer (not a boolean) that indexes an object entry of the `remediation_loop.review_outcomes` list whose `verdict` is `REMEDIATION_REQUIRED`, and a value that is not such an integer, is out of range, or references an outcome with any other verdict is a malformed cycle.

7. **`completed_attempts` counts completed attempts (R7).** When `remediation_loop.completed_attempts` is present, it must be a non-negative integer (not a boolean) equal to the number of object cycles whose `candidate_applied` is `true` (zero when `cycles` is absent or not a list), and any other value is a malformed loop.

8. **Light remediation (issue #1097).** When a cycle object carries `remediation_path`, the rules below run in the accounting stage, after the R7 checks, per cycle in order, with byte-identical messages in `scripts/dev_tools/_orchestrator_state_light_cycle.py`, `extensions/drm-copilot/src/lib/validate/orchestrator-state-light-cycle.ts`, and `Get-RemediationLightCycleError` in `.claude/lib/orchestrator-state/OrchestratorStateRemediationAccounting.psm1`, pinned by the corpus `tests/fixtures/orchestrator_state_remediation_loop/`. A cycle without the key reaches none of them, so every existing checkpoint validates as before. `scope` on a finding is read only by these rules.
   1. A value other than exactly `light` or `full`, null included: `Checkpoint remediation cycle #N remediation_path must be light or full.` Nothing further runs for the cycle, and nothing further runs for `full`.
   2. A `preflight` key, whatever its value: `Checkpoint remediation cycle #N remediation_path is light but the cycle carries preflight.`
   3. `opened_by_review` absent, or not naming a `REMEDIATION_REQUIRED` outcome by the R11 predicate: `Checkpoint remediation cycle #N remediation_path is light but opened_by_review does not name its opening review.` Rules 4 to 6 are then skipped.
   4. More than 3 findings in that outcome (a non-list `findings` value counts as empty): `Checkpoint remediation cycle #N remediation_path is light but its opening review has M findings; the limit is 3.`
   5. Per finding K whose `remediability` is not exactly `autonomous`, a non-object finding included: `Checkpoint remediation cycle #N remediation_path is light but finding #K is not autonomous.`
   6. Per finding K whose `scope` is not exactly `contained`, absent included: `Checkpoint remediation cycle #N remediation_path is light but finding #K scope is not contained.`
   7. The immediately prior list element is an object whose `remediation_path` is exactly `light`: `Checkpoint remediation cycle #N remediation_path is light but the prior cycle is light.`

   Route (D9): the installed MCP validator applies invariant 8 only after the extension release that carries it is installed. Until then, a Claude run validates a light checkpoint through the repository-local Python CLI, and on Codex, whose completion boundary is the installed MCP validator, the light path is unavailable.

## Invariants (remediation_loop.review_outcomes)

These invariants apply only when `remediation_loop` contains a `review_outcomes` key. The orchestrator appends one entry per review, including a `PASS` review, in the shape `{"verdict": <verdict>, "findings": [{"remediability": <class>}, ...]}`, where `findings` lists the review's blocking findings only. A halt or wait verdict records no remediation cycle.

Review verdicts (exact, case-sensitive):

| Verdict | Condition over the classes of the review's blocking findings |
|---|---|
| `PASS` | No blocking findings. |
| `REMEDIATION_REQUIRED` | At least one `autonomous` finding. |
| `HALT_NON_REMEDIABLE` | No `autonomous` finding, and at least one `external_dependency`, `policy_hold`, or `human_decision_required` finding. |
| `AWAITING_CI` | At least one finding, and every finding is `awaiting_ci`. |

Remediability classes (exact, case-sensitive) and the `blocked_reason` member (#523) that a halt or wait records for each class:

| Class | Meaning | `blocked_reason` member |
|---|---|---|
| `autonomous` | Repository remediation can resolve the finding without a human decision. | none (remediation loop) |
| `external_dependency` | A system, service, runtime, or published artifact outside the repository is unavailable or mismatched. | `external_dependency` |
| `policy_hold` | Proceeding requires a policy decision, exception, or authorization that the orchestrator may not grant. | `policy_hold` |
| `awaiting_ci` | The finding resolves when a CI result that has not completed becomes available. | `awaiting_ci` |
| `human_decision_required` | A human must choose between alternatives or approve a direction. | `human_decision_required` |

Derivation order. The verdict is a pure function of the findings' classes, evaluated in this order: no findings yields `PASS`; any `autonomous` finding yields `REMEDIATION_REQUIRED`; any `external_dependency`, `policy_hold`, or `human_decision_required` finding yields `HALT_NON_REMEDIABLE`; otherwise the verdict is `AWAITING_CI`.

1. **`review_outcomes` is a list of objects (R8).** `review_outcomes` must be a list, and each entry must be an object. A non-list value or a non-object entry is malformed.

2. **Verdict and class membership (R9).** Each outcome's `verdict` must be a string among the four verdicts, its `findings` must be a list (a missing key is not a list), and each finding must be an object whose `remediability` is a string among the five classes. Comparisons are case-sensitive, so a case variant such as `Pass` or `Autonomous` is malformed.

3. **Verdict matches its findings (R10).** When an outcome passes the membership checks, its `verdict` must equal the verdict that the derivation order yields for its findings' classes. A mismatch is a malformed outcome.

## Human-Interaction Scope and Backward Compatibility

These invariants apply only when the checkpoint contains a top-level `human_interaction` block. A checkpoint with no `human_interaction` key (the existing checkpoint shape) is unaffected: it validates exactly as before and produces no new errors. The invariants are additive and support the autonomous-execution mandate documented in `.claude/skills/orchestrate/SKILL.md`.

## Invariants (human_interaction block)

1. **Required `requirements` list.** When `human_interaction` is present, it must be an object containing a `requirements` list. A non-object `human_interaction`, or a `requirements` value that is not a list, is a malformed block.

2. **Per-requirement `response` enum membership.** Each requirement must be an object whose `response` value is one of `scope_change`, `exception`, or `halt`. A requirement that is not an object, or whose `response` is outside this enum, is a malformed requirement.

3. **Exception requires `runbook_path`.** A requirement whose `response == "exception"` must carry a non-empty `runbook_path` string. A missing, non-string, or empty/whitespace-only `runbook_path` on an `exception` requirement is a malformed requirement.

## Blocked-Reason Vocabulary

The checkpoint key `blocked_reason` accepts exactly the twelve members below. The authoritative definition is `scripts/dev_tools/_orchestrator_state_blocked_reason.py`; the TypeScript module `extensions/drm-copilot/src/lib/validate/orchestrator-state-blocked-reason.ts` and the grouped arrays in `.claude/lib/orchestrator-state/OrchestratorState.psm1` mirror it.

| Member | Partition | Definition |
|---|---|---|
| `none` | not blocked | The run is not blocked. JSON `null` is equivalent for classification. |
| `spawn_agent_unavailable` | mechanical | Existing member; meaning unchanged. |
| `delegation_launch_failed` | mechanical | Existing member; meaning unchanged. |
| `delegate_no_receipt` | mechanical | Existing member; meaning unchanged. |
| `delegate_contract_incomplete` | mechanical | Existing member; meaning unchanged. |
| `validator_failed` | mechanical | Existing member; meaning unchanged. |
| `user_requested_stop` | mechanical | Existing member; meaning unchanged. |
| `premise_falsified` | non-mechanical | Every delegation and validator succeeded, but evidence gathered during execution falsified the premise on which the plan was built, so continuing would implement an invalid plan. |
| `external_dependency` | non-mechanical | The run cannot proceed because a system, service, runtime, or artifact outside the repository's control is unavailable or mismatched, and no in-repository remediation can resolve it. |
| `policy_hold` | non-mechanical | The run is stopped because proceeding requires a policy decision, exception, or authorization that the orchestrator is not permitted to grant autonomously. |
| `awaiting_ci` | non-mechanical | The run is waiting for a CI result that has not yet completed, and no remediation is warranted until that result is available. |
| `human_decision_required` | non-mechanical | The run requires a human to choose between alternatives or approve a direction before it can continue. |

Partition definitions:

- **Not blocked:** `none`, JSON `null`, or key absent at a gate. Plain validation still reports an absent key through the required-key check.
- **Mechanical:** the orchestration process itself did not complete a step: a tool or delegation failed, a delegate returned no or an incomplete receipt, a validator failed, or the operator stopped execution. Membership is defined by the published constant, not by the wording.
- **Non-mechanical:** every process step could proceed, but the work cannot continue for a reason that no retry or remediation cycle of the process resolves.

The classification is recoverable from `blocked_reason` alone by looking the value up in the published partition (`classify_blocked_reason` in Python, `classifyBlockedReason` in TypeScript).

Enforcement parity: the Python, PowerShell, and TypeScript validators enforce this vocabulary identically, with case-sensitive comparison. A value outside the vocabulary, including a case variant of any member, is rejected with `Checkpoint has invalid blocked_reason: <value>`. Every non-`none` member, including the five non-mechanical members, blocks completion and PR-creation readiness with the existing messages.

Relationship to `human_interaction.requirements[].response == "halt"`: a human-decision halt may appear in both places. `blocked_reason: "human_decision_required"` classifies the run's halt, and a `human_interaction.requirements[]` entry with `response: "halt"` describes the specific requirement. There is no cross-field rule between them: either may appear without the other, and neither is validated against the other.

Producer guidance for `premise_falsified`: set it when every delegation and validator succeeded but evidence gathered during execution falsified the plan's premise. The evidence path is still recorded in free-form checkpoint keys; `blocked_reason` carries the classification only.

Extension point for #484: #484 consumes `external_dependency`, `policy_hold`, `awaiting_ci`, and `human_decision_required` without renaming, removing, or re-partitioning them; any further halt class is a separate contract change that appends the literal to the non-mechanical partition in all three runtimes, updates the partition oracle and corpus, and updates this section.

## Complexity-Assessment Scope and Backward Compatibility

These invariants apply only when the checkpoint contains a top-level `complexity_assessments` array. A checkpoint with no `complexity_assessments` key (the existing checkpoint shape) is unaffected: it validates exactly as before and produces no new errors. The invariants are additive and support the two-axis model-selection mechanism documented in `.claude/skills/orchestrate/SKILL.md` (`## Model Selection`). Enforcement is the Python validator, not an imported schema.

## Invariants (complexity_assessments array)

Each entry records one assessed phase with the shape `{ phase, band, floor, signals_present[], rationale, assessed_at }`.

1. **Band enum membership.** Each entry's `band` must be one of `C1`, `C2`, `C3`, `C4`. A missing or out-of-enum `band` is a malformed entry.

2. **Band at or above floor.** Each entry must satisfy `band >= floor` using the band ordering `C1 < C2 < C3 < C4`. The floor constrains the lower bound only; a `band` below its `floor` is a malformed entry.

3. **Floor equals the computed floor.** Each entry's `floor` must equal `compute_complexity_floor(signals_present)` (the reference implementation in `scripts/dev_tools/compute_complexity_floor.py`). A `floor` that does not equal the recomputed value is a malformed entry. C4 is never floor-forced; the floor never exceeds `C3`.

4. **Non-empty `rationale`.** Each entry's `rationale` must be a non-empty string. A missing, non-string, or empty/whitespace-only `rationale` is a malformed entry.

The validator never judges the merit of the assessed band; it checks shape, floor equality, and lower-bound ordering only.

## Model-Routing-Receipt Scope and Backward Compatibility

These invariants apply only when the checkpoint contains a top-level `model_routing_receipts` array. A checkpoint with no `model_routing_receipts` key (the existing checkpoint shape) is unaffected: it validates exactly as before and produces no new errors. The invariants are additive. Enforcement is the Python validator, not an imported schema.

## Invariants (model_routing_receipts array)

Each entry records one delegation with the shape `{ agent, phase, complexity_band, fable_policy, table_model, clamped_from | null, model }`.

1. **Model equals the resolved model.** Each entry's `model` must equal `resolve_delegation_model(agent, complexity_band, fable_policy)["model"]` (the reference implementation in `scripts/dev_tools/resolve_delegation_model.py`). A `complexity_band` outside `C1`..`C4` is a malformed entry. A `model` that does not equal the resolved model is a malformed entry.

2. **Disabled-mode clamp.** Under `fable_policy == "disabled"` no entry's `model` may equal `fable`; any entry whose `table_model == "fable"` must record `clamped_from == "fable"` and `model == "opus"`. A disabled-mode entry that resolves to `fable`, or a disabled-mode `fable` table cell that does not record the clamp, is a malformed entry.

## Model-Budget Contract

The session `model_budget.fable_policy` switch is a three-way enum `disabled | available | preferred` defined in `config/orchestration-routing.json`, defaulting to `disabled`. It governs only the delegation model tier and is not a route input. `disabled` removes `fable` from the consideration set and clamps `fable` cells to `opus`; `available` applies the base `complexity_to_model` table as-is; `preferred` applies the `preferred_overlay` (which redirects only the C3 cell to `fable` for the overlay agents `atomic-planner`, `prd-feature`, `feature-review`, `task-researcher`) and leaves `atomic-executor` and `pr-author` C3 cells at `opus`. `route` is never an input to model selection.

## Require-Model-Routing Mode Scope and Backward Compatibility

The complexity-assessment and model-routing-receipt invariants above are key-gated: they run only when their key is present, so a checkpoint that omits both arrays passes at every stage. The `require_model_routing` mode adds an existence gate that closes that gap without changing the default behavior. It is an opt-in keyword on `validate_orchestrator_state_text(..., require_model_routing=False)` (CLI flag `--require-model-routing`, accepted by the dispatcher `orchestrator-state` subcommand and by the bare-module CLI; MCP parameter `require_model_routing`), defaulting off. Plain, `require_complete`, and `require_pr_creation_ready` calls are unaffected and produce byte-identical results.

## Bare-Module CLI Contract

The validator module runs directly as `python -m scripts.dev_tools.validate_orchestrator_state <path> [--require-complete] [--require-model-routing] [--require-pr-creation-ready] [--require-codex-model-routing] [--require-codex-topology]`. The dispatcher stays available and accepts the same flags in two invocation forms: the module form `python -m scripts.dev_tools.validate_orchestration_artifacts orchestrator-state`, run from the repository root, and the file-path form `python scripts/dev_tools/validate_orchestration_artifacts.py orchestrator-state`. Both forms reach the same `main()`, so their flags, output lines, and exit codes are identical, and a relative artifact path resolves against the working directory in both. The file-path form derives the repository root from the script location and inserts it first in `sys.path` only when the script runs without a package context. The bare-module validator is supported in the module form only. Exit code 0 means the checkpoint passed and the success line `orchestrator-state validation passed: <path>` is written to stdout. Exit code 1 means validation errors, written one per stderr line. Exit code 2 means the path is missing, unreadable, or not UTF-8, with one stderr diagnostic and no traceback; argparse usage errors also exit 2.

## Invariants (require_model_routing mode)

These invariants apply only when a caller passes `require_model_routing=True` and the checkpoint records at least one delegation. A checkpoint with zero delegations (no well-formed `delegation_receipts[]` entry and a `next_step` that names no delegating agent) imposes no requirement, so genuinely old, delegation-free checkpoints stay valid.

1. **Required routing receipt once delegated.** Once the checkpoint records a delegation, the set of `model_routing_receipts[].agent` must be a superset of the delegated-agent set (each well-formed `delegation_receipts[].agent_name` plus a `next_step` that names a delegating agent). A delegated agent with no matching receipt is a violation. The delegating agent set excludes `orchestrator` (the caller, not a delegated subagent).

2. **Required complexity assessment per matched phase.** Each phase named by a routing receipt whose agent is in the delegated-agent set must have a `complexity_assessments[]` entry for that phase.

3. **Per-entry consistency reused, not reimplemented.** Present receipts and assessments must satisfy the model-routing-receipt and complexity-assessment invariants above; the gate reuses `_validate_model_routing_receipts` and `_validate_complexity_assessments` and never reimplements `compute_complexity_floor` or `resolve_delegation_model`. The gate logic lives in `scripts/dev_tools/_orchestrator_state_model_routing_gate.py`; enforcement is the Python validator, not an imported schema.

The completion hook (`.claude/hooks/validate-orchestrator-output.ps1`) passes `--require-model-routing` alongside `--require-complete` and surfaces a gate failure as the `MODEL_ROUTING_BLOCKED:` block reason. The PreToolUse deterrent (`.claude/hooks/enforce-model-routing-receipt.ps1`) performs presence-only gating before a delegation. The MCP TypeScript surface performs the existence check only (delegated-agent set ⊆ routing-receipt-agent set); the Python validator remains authoritative for per-receipt correctness.

## Epic Launch-Binding Activation Scope

This section governs when the epic child launch-binding gate runs. It exists because the gate admitted the generic `require_complete` flag into an otherwise Codex-specific activation set, which made Codex-only launch evidence a universal completion requirement (issue #524).

The evidence the gate demands — `launch_receipt_path`, `launch_status_path`, `delegation_receipt`, and `model_routing_receipt` on each feature — has exactly one production writer, `.codex/scripts/launch-epic-child-wave.ps1`, on the Codex runtime. No Claude-runtime producer writes it, so an epic executed on the Claude runtime could never satisfy an unconditional gate.

1. **Unconditional under the two Codex enforcement flags.** When a caller passes `require_codex_model_routing` or `require_codex_topology`, launch-binding validation runs for every feature exactly as before, including the existing `skip_not_started` filter. Behaviour under either Codex flag is unchanged.

2. **Key-gated per feature under `require_complete` alone.** When `require_complete` is the only flag passed, the gate validates a feature only when that feature carries `launch_receipt_path` or `launch_status_path`. A feature carrying neither key is skipped and contributes zero errors.

3. **The presence test is deliberately either-key, so a partial binding still fails.** Presence means key membership, not value truthiness: a key present with an empty or null value still arms the gate. A feature carrying one launch path key and not the other is therefore validated, and the absent key produces its error. The test is never "both keys"; that spelling would let a half-written binding pass unexamined, and the partial-binding failure is the property that distinguishes this scope rule from deleting the gate.

The rest of the completion gate is unchanged. An epic whose feature is not merged, or whose `epic_merge_pr.merge_commit_sha` is missing or empty, still fails under `require_complete`.

Enforcement is validator logic plus this prose, never an imported JSON Schema. The activation scope lives in `scripts/dev_tools/_epic_orchestrator_state_launch_binding.py`, and the TypeScript parity port at `extensions/drm-copilot/src/lib/validate/epic-orchestrator-state-launch-binding.ts` reproduces it with byte-identical error strings. No schema file is authored, imported, or read for it.

## Standalone-Merge-Authorization Scope and Backward Compatibility

These invariants apply only when a checkpoint contains a top-level `standalone_merge_authorizations` array. The key may appear in any of the three checkpoints the epic merge gate reads: `artifacts/orchestration/orchestrator-state.json`, `artifacts/orchestration/epic-orchestrator-state.json`, and `artifacts/orchestration/parallel-orchestrator-state.json`. A checkpoint with no such key (the existing checkpoint shape) is unaffected: it validates exactly as before and produces no new errors. The invariants are additive and key-gated. No JSON Schema file is authored, imported, or read for the block (see the Foreign Schema Warning above); the enforcing surface is the `PreToolUse` merge gate (issue #670).

Each entry records one authorized standalone merge with the shape `{ pr_number, pr_url, issue_num, branch_name, authorized_by, authorized_at, session_id, basis, run_slug? }`. The gate consults the array only for a `gh pr merge --merge` command that names an explicit pull request number, and only after its per-feature, epic, and parallel allow conditions have all declined. For a command that names an explicit pull request number, the gate reads the per-feature checkpoint `artifacts/orchestration/orchestrator-state.json` beneath the one live worktree whose checkpoint records that number in `pr_gate.pr_number` or in a `standalone_merge_authorizations` entry, and it reads no per-feature checkpoint when no live worktree or more than one records it; a bare command reads the checkpoint beneath the session worktree.

Honest disclosure: the standalone-merge authorization record is a policy-level, auditable declaration and is
not a cryptographic or security control.
`authorized_by` is a declaration that the gate does not verify, because the runtime exposes no attested agent identity at Bash `PreToolUse` time. The record is not tamper-proof: any actor able to write `artifacts/orchestration/*.json` inside the authorizing session can write one. The `session_id` cross-check binds a record to the session that wrote it, so a stale record from a previous run or a record copied between runs authorizes nothing; it does not stop same-session forgery. This is a documented accepted trade, not an unexamined gap.

## Invariants (standalone_merge_authorizations array)

1. **PR-specific block.** The value of `standalone_merge_authorizations` must be a non-empty array whose every entry is an object with a `pr_number` that is a JSON integer greater than zero. Any other shape (a boolean or other blanket flag, a string, an object, an empty array, a non-object entry, or a `pr_number` that is absent, `null`, zero, negative, fractional, a string, or an array) is rejected with `STANDALONE_MERGE_AUTHORIZATION_NOT_PR_SPECIFIC`.
2. **Binding by `pr_number`.** The gate selects the entry whose `pr_number` equals the pull request number extracted from the command. When records exist but none matches, the gate denies with `STANDALONE_MERGE_AUTHORIZATION_PR_MISMATCH`; when no checkpoint carries the key, it denies with `STANDALONE_MERGE_AUTHORIZATION_ABSENT`.
3. **`pr_url`.** Non-empty, and it must end with `/pull/` followed by the entry's own `pr_number` and nothing else.
4. **`issue_num`.** A JSON integer greater than zero.
5. **`branch_name`.** A non-empty string. It is never compared against the live branch or the working directory.
6. **`authorized_by`.** A non-empty string; presence only.
7. **`authorized_at`.** A date-time string that parses with the invariant culture, assuming and adjusting to UTC. No clock is read.
8. **`basis` and `run_slug`.** `basis` is at least 20 characters after trimming. `run_slug` is optional; when present it is a non-empty string.
9. **`session_id`.** A non-empty string equal, by ordinal comparison, to the `session_id` of the live hook envelope. An envelope without a `session_id` fails closed.

Field checks 3 through 9 run in the fixed order `pr_url`, `issue_num`, `branch_name`, `authorized_by`, `authorized_at`, `basis`, `run_slug`, `session_id`; the first failure wins and the gate denies with `STANDALONE_MERGE_AUTHORIZATION_MALFORMED` naming that field.

## Green-CI standalone merge (issue #997)

A standalone run (neither an epic child nor a parallel item) merges its own pull request at S9 step 7 of `.claude/skills/orchestrate/SKILL.md` without an authorization record. The merge gate evaluates this green-CI condition after its parallel condition and before the `standalone_merge_authorizations` condition, and allows the merge only when all of the following hold:

1. The command is a single structural `gh pr merge` naming an explicit pull request number, with no chain, wrapper, inline environment prefix, `-R` or `--repo`, `/pull/` URL selector, `--auto`, or `--admin`.
2. Exactly one live worktree's per-feature checkpoint records that number, and no epic or parallel checkpoint records the number or that worktree's path.
3. The per-feature checkpoint has `epic_mode` absent, `null`, or JSON `false`; carries no `parallel_mode: true` and no non-blank `parallel_slug`; records `step9_status` exactly `passed` and `ci_gate.conclusion` exactly `success`; records `pr_gate.pr_number` as a JSON integer equal to the command number (an authorization record does not substitute); records `ci_gate.head_sha` as a lowercase 40 or 64 character object id; and, when `pr_gate.head_sha` is present and not `null`, records it equal to `ci_gate.head_sha`.
4. The live pull-request head from one bounded `gh pr view` call equals `ci_gate.head_sha`, and a `--match-head-commit` value, when present, equals the live head.

`parallel_mode`, `parallel_slug`, `pr_merge`, and `stage_timing` are tolerated, unvalidated top-level checkpoint keys: no validator reads them. A parallel child records `parallel_mode: true` and `parallel_slug` at kickoff, and a standalone run records `pr_merge: { merge_commit_sha, target_branch, merged_at }` only after its merge is confirmed. The orchestrator main session writes `stage_timing`, a list of `{ stage, attempt, started_at, ended_at }` entries (issue 1097) of wall-clock times in which `ended_at` is null while a stage is open, and commits the same list as `FEATURE/evidence/other/stage-timing.<timestamp>.json` before the merge. The merge stage is not captured. The writer protocol is in the orchestrate skill.

Honest disclosure: the parallel exclusion is best-effort. The `Parallel mode: true` marker lives in the delegation prompt and is not present in a Bash `PreToolUse` payload, so a parallel child whose number and worktree path the parallel checkpoint has not yet recorded, and which omits the `parallel_mode` key, is not excluded by the hook. Like the authorization record above, the green-CI condition is a policy-level control, not a security control. A push after the live-head lookup can also change the head unless the command passes `--match-head-commit`, which the hook does not require.

## Epic-child CI verification (issue #1130)

An epic child (per-feature checkpoint with JSON `epic_mode` true and a ready `step9_status`) merges into its integration branch only when CI is verified on the live head of its pull request. Both merge gates dot-source the byte-identical helper `enforce-epic-merge-gate-child-ci.ps1` from `.claude/hooks/` and `.codex/hooks/`, and their child branch evaluates `Get-EpicMergeGateChildCiDecision` after the existing child predicates hold. The six stages run in order, and the first failure denies with `EPIC_MERGE_GATE_BLOCKED: EPIC_CHILD_CI_NOT_VERIFIED: <detail>` without falling through to a later allow branch:

1. PR number: the command's explicit number, else the JSON-integer `pr_gate.pr_number`; when both are present they must match, and when neither is present the merge is denied.
2. `ci_gate.conclusion` is exactly `success` and `ci_gate.head_sha` is a lowercase 40- or 64-character object id.
3. One bounded `gh pr view <PR> --json headRefOid`; the live head must equal `ci_gate.head_sha`.
4. One bounded `gh run list --commit <head> --limit 100`; the runs are filtered to `workflowName` exactly `CI` and `headSha` equal to the head, and the newest by `createdAt` is selected. No match denies.
5. The selected run's `event` is `pull_request` or `workflow_dispatch`, its `status` is `completed`, and its `conclusion` is `success`. A `push`-event run is not accepted.
6. For `workflow_dispatch`, the run's `databaseId` equals `ci_gate.dispatch_run_id`.

`ci_gate.dispatch_run_id` is a tolerated, optional positive JSON integer that the S9 dispatch fallback of `.claude/skills/orchestrate/SKILL.md` records; the checkpoint validators check the required `ci_gate` keys only and do not read it. A failed, timed-out, or unparseable `gh` result denies, and the helper invokes no Python. The required workflow name `CI` is a stated assumption.

Honest disclosure: like the green-CI branch, this is a policy-level control, not a security control. A push after the live-head lookup can change the head before the merge runs, the same residual race as issue #997, and a writer in the same session can edit the checkpoint.

## Issue-Adoption Scope and Backward Compatibility

These invariants apply only when a checkpoint contains a top-level `issue_adoption` key. The key records that the orchestration adopted a GitHub issue that already existed before orchestration started (transferred, filed by hand, or created by epic decomposition), so the issue was never created through `potential_to_issue`. The key is presence-gated: a checkpoint without it validates byte-identically to before and produces no new errors. It is evaluated only by the routing-contract completion check (`validate_routing_contract` and its TypeScript and PowerShell ports). It is not a member of `REQUIRED_STATE_KEYS`, it is not read by plain (non-completion) validation, and it is not read by the PR-creation-readiness gate. No JSON Schema file is authored, imported, or read for it.

Honest disclosure: the validators perform no network I/O. They cannot confirm that the issue exists, so `evidence` and `verified_via` are an auditable declaration of the read-only verification the orchestrator performed, not proof of it. This matches the `standalone_merge_authorizations` precedent above: the record is a policy-level declaration, not a security control.

The `feature_folder_record` is likewise declaration-only in every validator: the Python, TypeScript, and PowerShell validators perform no file-system or git access, so the validator checks, the MCP `validate_orchestration_artifacts` path, the Python CLI, and Codex gates cannot confirm that the folder exists or is committed. The folder is probed only under the Claude `SubagentStop` hook `.claude/hooks/validate-orchestrator-output.ps1`, through `.claude/hooks/validate-orchestrator-output-feature-folder.ps1`: when an `orchestrator-state` checkpoint waives `new_active_feature_folder` and passes the routing contract, the hook re-checks the checkpoint `feature-folder` against the path pattern and runs `git -C <worktree root> cat-file -t HEAD:<feature-folder>`. It allows only exit code 0 with the output `tree`; any other outcome blocks with `ROUTING_CONTRACT_BLOCKED: Checkpoint feature-folder is not committed in HEAD: <feature-folder>.`, which the subagent can repair. The probe proves only that `HEAD` of the run worktree holds a tree at that path at stop time; it does not prove which tool created the folder or that its contents are correct.

## Invariants (issue_adoption object)

The object has the shape `{ issue_num, issue_url, origin, verified_via, verified_at, evidence, waived_tools, potential_record?, feature_folder_record? }`.

| Field | Rule |
| --- | --- |
| `issue_num` | A string of decimal digits without a leading zero; equal to the checkpoint `issue-num` when that is a string. |
| `issue_url` | A string ending with `/issues/` followed by `issue_num`. |
| `origin` | One of `transferred`, `filed_before_orchestration`, `epic_decomposition`. |
| `verified_via` | One of `gh_issue_view`, `gh_api_get`, `github_mcp_issue_read`. |
| `verified_at` | Present, not `null`, and not a blank string. |
| `evidence` | A string with non-whitespace content. |
| `waived_tools` | A non-empty list of non-blank tool names that includes `potential_to_issue`. |
| `potential_record` | When waiving a promotion-entry tool: required when `origin` is `epic_decomposition`, optional when `origin` is `transferred` or `filed_before_orchestration`, and validated whenever it is present (a path under `docs/features/potential/` ending in `.md`). |
| `feature_folder_record` | Required when `waived_tools` includes `new_active_feature_folder`, and validated whenever it is an object: `{ path, verified_via, verified_at, evidence }`, where `path` is a folder under `docs/features/active/` equal to the checkpoint `feature-folder`, `verified_via` is `git_cat_file_head` or `git_ls_tree_head`, `verified_at` is present, and `evidence` is a non-empty string. |

The rules run in this order, and their errors accumulate:

1. A present value that is not an object (including `null`) yields `Checkpoint issue_adoption must be an object when present.` and evaluation stops.
2. `issue_num` must be a string of decimal digits without a leading zero (a JSON number is invalid). Only when it is valid and the checkpoint `issue-num` is a different string, `issue_num` must equal the checkpoint issue-num.
3. `issue_url` must end with `/issues/` followed by a valid `issue_num`.
4. `origin` must be one of the three origin values.
5. `verified_via` must be one of the three verification values.
6. `verified_at` must be present: absent, `null`, and blank strings are rejected; any other value passes.
7. `evidence` must be a non-empty string.
8. `waived_tools` must be a non-empty list of non-blank strings; otherwise no further rule-8 or rule-9 check runs. Each entry, in list order, receives the first applicable error of: listed more than once; not in the closed waivable set; not required by the selected route after promotion-type resolution; already holding a successful MCP receipt. The list must include `potential_to_issue`.
9. Only when the rule-8 shape check passed: each distinct waived promotion-entry tool (`new_potential_entry` or `new_potential_bug_entry`) requires a valid `potential_record`, except that rule 9 reports nothing when `origin` is `transferred` or `filed_before_orchestration` and the `potential_record` key is absent. A present `potential_record`, including `null`, is always validated.
10. Only when the rule-8 shape check passed: when `waived_tools` includes `new_active_feature_folder` and `feature_folder_record` is absent or not an object (including `null`), the error is `Checkpoint issue_adoption.feature_folder_record must be an object when waiving new_active_feature_folder.`
11. Only when the rule-8 shape check passed: whenever `feature_folder_record` is an object, waived or not, its fields are checked in this order, and the errors accumulate:
    - 11a. `path` must be a string that fully matches `^docs/features/active/[A-Za-z0-9][A-Za-z0-9._-]*(/[A-Za-z0-9][A-Za-z0-9._-]*)*$`, so dot segments, empty segments, a trailing slash, backslashes, drive letters, glob characters, and a leading `-` are rejected: `Checkpoint issue_adoption.feature_folder_record.path must be a folder path under docs/features/active/ without dot segments or a trailing slash.`
    - 11b. Only when `path` passed 11a: the checkpoint `feature-folder` must be the identical string; an absent, non-string, or different value yields `Checkpoint issue_adoption.feature_folder_record.path must equal the checkpoint feature-folder.`
    - 11c. `verified_via` must be `git_cat_file_head` or `git_ls_tree_head`: `Checkpoint issue_adoption.feature_folder_record.verified_via must be one of git_cat_file_head, git_ls_tree_head.`
    - 11d. `verified_at` must be present; absent, `null`, and blank strings are rejected: `Checkpoint issue_adoption.feature_folder_record.verified_at must be present.`
    - 11e. `evidence` must be a non-empty string: `Checkpoint issue_adoption.feature_folder_record.evidence must be a non-empty string.`

The closed waivable set is `potential_to_issue`, `new_potential_entry`, `new_potential_bug_entry`, and `new_active_feature_folder`; `new_active_feature_folder` is waived only together with a valid `feature_folder_record`. `collect_pr_context`, `validate_orchestration_artifacts`, and every other tool can never be waived. All comparisons are ordinal and case-sensitive.

A lifecycle record moved to `docs/features/potential/promoted/` satisfies the `potential_record` path rule, because the rule checks only the `docs/features/potential/` prefix and the `.md` suffix and does not check that the file exists.

Fail-closed behavior: any adoption error waives nothing, so each missing receipt is still reported as `Checkpoint missing successful MCP receipt: <tool>.`. Adoption errors are placed after the receipt-loop errors and before the `local_execution_overrides` errors. Rule 10 and rule 11 errors follow the rule 9 errors in the adoption error list, so a checkpoint that waives `new_active_feature_folder` without a valid record reports the missing-receipt line for each unreceipted required tool first, in `required_mcp_tools` order, and the rule 10 or rule 11 error after them. The waiver affects only receipt presence: the declared `required_mcp_tools` equality check with the routing matrix is unchanged, so a checkpoint must still declare every route tool it waives.

## Concurrent-Review Scope and Backward Compatibility

These rules apply only when a checkpoint contains the top-level key `review_mode` with the exact string `concurrent`, compared ordinally. An absent key, `null`, `sequential`, a case variant, a number, and every other value mean sequential, and a checkpoint without the key validates exactly as before: no `gh` call, no new denial, and no readiness relaxation. The key is tolerated and is not a member of `REQUIRED_STATE_KEYS`. `.claude/skills/orchestrate/SKILL.md` (`## Concurrent Review and CI (review_mode)`) defines the run sequence.

- **`head_sha`.** Each `remediation_loop.review_outcomes[]` entry of a concurrent run carries `head_sha`: the head the review ran against, a full lowercase object id of 40 or 64 characters. Plain validation does not read it.
- **Last-entry semantics.** Only the final `review_outcomes[]` element counts, so an earlier `PASS` never satisfies a rule.
- **Readiness.** Under the key, PR-creation readiness stops rejecting `step7_status` for the value `pending` only. `blocked`, and every other step, keep today's result. TypeScript has no readiness port.
- **Completion.** Under the key, `require_complete` appends exactly one of these strings after the existing completion checks, byte-identical in `scripts/dev_tools/_orchestrator_state_concurrent_review.py`, `extensions/drm-copilot/src/lib/validate/orchestrator-state-concurrent-review.ts`, and `Get-OrchestratorStateCompletionConcurrentReviewError` in `.claude/lib/orchestrator-state/OrchestratorStateCompletionChecks.psm1`, and pinned by the corpus `tests/fixtures/orchestrator_state_concurrent_review/`. The second is reported only when the first does not apply. Validators do no git work.
  - `Checkpoint completion validation failed: review_mode concurrent requires a last review_outcomes entry with verdict PASS.`
  - `Checkpoint completion validation failed: review_mode concurrent requires head_sha on the last review_outcomes entry.`
- **Merge guard.** `.claude/hooks/enforce-epic-merge-gate-review.ps1`, byte-identical at `.codex/hooks/`, runs before every allow branch of both merge gates. It denies with `REVIEW_GATE_NOT_PASSED`, `REVIEW_GATE_HEAD_STALE`, or `REVIEW_GATE_HEAD_UNRESOLVED`, each after the token `EPIC_MERGE_GATE_BLOCKED`. A later head is current only when the reviewed head is its ancestor and every path changed since then lies inside `feature-folder`, so a code change after the review, including a merge of `origin/main`, is stale. A merge must be one plain `gh pr merge` of one number as its own Bash call: under the key, text that could be a merge and cannot be bound to one pull request is denied with `REVIEW_GATE_HEAD_UNRESOLVED`, before any process and before the out-of-scope allow of both gates.
- **Validator route (D9).** The TypeScript rule reaches the MCP surface only after an extension release. Until then, installed MCP accepts a checkpoint that the PowerShell stop hook and the Python CLI reject, so a concurrent checkpoint is checked through the Python CLI.

Honest disclosure (D10): the guard is a policy-level control, not a security control. A writer in the same session can edit the checkpoint. A merge outside the Bash hook surface is not gated. A merge whose item target does not resolve (`NoTarget` or `Ambiguous`), or whose child checkpoint does not parse, sees no key, and the parallel skill step is then the only backstop. A push after the lookup can change the head unless the command passes `--match-head-commit`. The `CI full run` requirement of the join is skill-level, because a docs-only head passes `CI Required Gate`. The authorization path reads no CI result, so the required `CI Required Gate` context is the control there. A text scan cannot read every merge: a script file performing the merge cannot be read, and neither can encoded or run-time composed text, a `gh` alias or shell function from an earlier call, or an endpoint held in a variable. A merge through a tool other than Bash is not gated: the Claude PowerShell tool and `mcp__*` tools, because the gate is registered on the `Bash` matcher only, and the Codex `shell_command` tool, because the gate is registered under `^Bash$` and returns for any other tool name. An already-queued auto-merge fires with no command, and `gh pr merge <PR> --disable-auto` removes it. A direct push to the base branch is not a pull-request merge, and the gate does not read it. A number-less merge text sees only the session checkpoint, so a key in another worktree is not found. The extra checkpoint read of the shape rule is best-effort: a failed read sees no key and keeps the decision of a run without the key. The extra read covers at most the first 4 numbers of the text, so a key held only by an item named after them is not found. Under the key the rule is fail-closed, so prose containing `pr merge` is denied in any command, including `git commit -m` and `grep`. The trigger is wider than `pr merge`: prose such as `pr (#12)` or `pr $HOME` is denied the same way, and a plain merge followed by a line feed or `;` is denied, because a bound merge must be the whole text. This trade is accepted because only concurrent runs carry the key and a merge is issued in its own call.

## Owner-Directive Scope and Backward Compatibility

These rules apply only when a checkpoint contains the top-level key `owner_directives` or `owner_directive_records` (issue #1139), in any of `orchestrator-state`, `epic-orchestrator-state`, and `parallel-orchestrator-state`. Both keys are optional, key-gated, and tolerated: they are not members of `REQUIRED_STATE_KEYS` or of the key lists of `.claude/lib/orchestrator-state/OrchestratorStateUnconditional.psm1`, and a checkpoint without either key validates exactly as before. Key presence is decided by the top-level property names of the stop hook's own parse, compared ordinally and case-sensitively, so a checkpoint without either top-level key never reaches the check. The `owner-directives` skill defines the coordinator procedure, the relay block, the closed class set, and the recording duty; no JSON Schema file is authored, imported, or read for either key.

`owner_directives[]` entries carry `id`, `text`, `text_sha256`, `class`, `recorded_at`, `expires_at`, `scope` (`issue`, `branch`, `step`), and `issued_by_session`. `owner_directive_records[]` entries carry `directive_id`, `class`, `outcome`, `reason`, `decided_by`, and `decided_at`. Dates parse as ISO 8601 with the invariant culture, read as UTC when no offset is given; the B and R check reads no clock, and the pass-down coverage check below reads one clock value per hook run through a seam. Entry numbers `#N` are 1-based, and errors accumulate in entry order, block rules first, then record rules:

| Rule | Condition | Error string |
|---|---|---|
| B1 | `owner_directives` present, not a non-empty list of objects | `Checkpoint owner_directives must be a non-empty list of objects when present.` |
| B2 | Missing or blank `id`, `text`, `text_sha256`, `class`, `recorded_at`, `expires_at`, `issued_by_session` | `Checkpoint owner_directives entry #N field <name> must be a non-empty string.` |
| B3 | `id` not `^OD-[1-9][0-9]*$` | `Checkpoint owner_directives entry #N id must match OD-<positive integer>.` |
| B4 | Duplicate `id` | `Checkpoint owner_directives entry #N id <id> is duplicated.` |
| B5 | `text_sha256` is not the lowercase hex SHA-256 of the UTF-8 `text` | `Checkpoint owner_directives entry #N text_sha256 does not match text.` |
| B6 | `class` outside the closed set | `Checkpoint owner_directives entry #N class must be one of: scheduling, merge_timing, extra_planner_revision, scope_narrowing, accept_nonblocking_deviation, gate_bypass, force_push, tag_or_publish, policy_or_settings_edit, evidence_alteration, unclassified.` |
| B7 | Unparseable dates, or `expires_at` not later than `recorded_at` | `Checkpoint owner_directives entry #N expires_at must be a date-time later than recorded_at.` |
| B8 | `scope` not an object with a positive integer `issue` and non-empty `branch` and `step` | `Checkpoint owner_directives entry #N scope must be an object with issue, branch, and step.` |
| R1 | `owner_directive_records` present, not a list of objects | `Checkpoint owner_directive_records must be a list of objects when present.` |
| R2 | Missing or blank `directive_id`, `class`, `outcome`, `reason`, `decided_by`, `decided_at` | `Checkpoint owner_directive_records entry #N field <name> must be a non-empty string.` |
| R3 | `directive_id` not among the `owner_directives` ids, including when the block is absent | `Checkpoint owner_directive_records entry #N references directive <id> that is not in owner_directives.` |
| R4 | Record `class` differs from the directive's class | `Checkpoint owner_directive_records entry #N class does not match directive <id>.` |
| R5 | `outcome` not `honored` or `refused` | `Checkpoint owner_directive_records entry #N outcome must be honored or refused.` |
| R6 | `honored` for a refused or `unclassified` class | `Checkpoint owner_directive_records entry #N honors directive <id> of refused class <class>.` |
| R7 | More than one `honored` record for one `extra_planner_revision` directive | `Checkpoint owner_directive_records directive <id> grants more than one extra planner revision.` |
| R8 | `reason` shorter than 20 characters after trimming | `Checkpoint owner_directive_records entry #N reason must be at least 20 characters.` |
| R9 | `decided_at` unparseable | `Checkpoint owner_directive_records entry #N decided_at must be a date-time.` |
| R10 | `honored` with `decided_at` later than the directive's `expires_at` | `Checkpoint owner_directive_records entry #N honors directive <id> after its expires_at.` |

Enforcement point: `Get-OrchestratorStateOwnerDirectiveError` in `.claude/lib/orchestrator-state/OrchestratorStateOwnerDirectives.psm1` runs the rules, and `.claude/hooks/validate-orchestrator-output.ps1` calls it from `Get-OrchestratorOutputBlockDecision` for every artifact type, after the routing dispatch and before the type-specific branches, when the checkpoint carries either top-level key. Any error blocks with `OWNER_DIRECTIVE_BLOCKED: ` followed by the errors joined by `; `, repairable; text the module cannot evaluate blocks with `OWNER_DIRECTIVE_BLOCKED: OWNER_DIRECTIVE_UNEVALUABLE:`. The module import is guarded and fails closed like its sibling imports.

Coordinator ledger and pass-down (issue #1157): a coordinator may also record directives in the per-worktree ledger `artifacts/orchestration/owner-directives.jsonl`, one directive object per line in the `owner_directives` entry shape, appended only by the main session. The ledger is not a checkpoint key and no validator other than the Claude hooks reads it. The stop hook runs a second, key-gated pass-down coverage check through `.claude/hooks/validate-orchestrator-output-owner-pass-down.ps1` after the B and R check. It activates only when the checkpoint, or for a linked item checkpoint its resolved epic or parallel parent, carries `owner_directives` or a non-empty ledger at its root. It reads its clock once, only after at least one candidate entry exists, and blocks repairably with:

- `OWNER_DIRECTIVE_BLOCKED: OWNER_DIRECTIVE_RELAY_MISSING: <details>` when an epic or parallel parent has a running child (epic `merge_status` `worktree_created`, `pr_open`, `ci_green`, or `merge_conflict`; parallel `worktree_created`, `pr_open`, or `ci_green`) whose checkpoint neither holds an unexpired selected entry (same `id` and `text_sha256`) nor links back to the parent, when a parent and child entry share an `id` with different hashes, or when an item checkpoint lacks an entry selected for it from its own ledger or its parent's checkpoint or ledger;
- `OWNER_DIRECTIVE_BLOCKED: OWNER_DIRECTIVE_LEDGER_INVALID: <details>` when a ledger line fails B2-B8.

Rules B1-B8 and R1-R10 and their strings are unchanged. The optional record fields `agent_id` and `decision_source` are tolerated.

Refused-class enforcement: the classes `gate_bypass`, `force_push`, `tag_or_publish`, `policy_or_settings_edit`, `evidence_alteration`, and `unclassified` are refused by policy in every case. `force_push` is also enforced by the existing hook `.claude/hooks/validate-bash.ps1`, which stays authoritative and unchanged; the other refused classes are policy-only, and rule R6 is their mechanical backstop. No hook gains a directive-based allow path.

Known limitations:

- **Python and TypeScript parity gap.** `scripts/dev_tools/validate_orchestrator_state.py` and `extensions/drm-copilot/src/lib/validate/orchestrator-state-core.ts` ignore unknown top-level keys, so they neither validate nor reject the two keys. Precedents for PowerShell-only, key-gated checks are `standalone_merge_authorizations` and the feature-folder `HEAD` probe.
- **Codex enforcement gap.** Codex has no orchestrator stop hook equivalent to `validate-orchestrator-output.ps1`, so the check does not run for Codex runs, which follow the same documented policy.
- **Same-session forgery.** Any writer of the checkpoint can author a block with a matching hash. The check proves internal consistency (no record without a recorded directive, no honored refused class), not owner origin; origin rests on the coordinator procedure, as disclosed for `standalone_merge_authorizations`.
- **Policy-only conditions.** Autonomous mode for `merge_timing`, scope matching, and whether a deviation was recorded as non-blocking are not visible to the validator.

## Regeneration-Path Scope and Backward Compatibility

These rules apply only to a repository that holds the config file `config/orchestration-regeneration.json` at its worktree root (issue #1156). The file is repository-local and never bundled, so push-down never publishes it; each repository authors its own. `## Merge-Conflict Remediation` in `.claude/skills/orchestrate/SKILL.md` defines the run sequence.

Config rules, each violation one error naming its key path, errors accumulating: the text parses as a JSON object; version is the JSON integer 1; regeneration is an object or null; no key other than command, paths, idempotency_check, and unit_gate appears inside regeneration; command is a non-empty array of non-empty strings; paths is a non-empty array of path patterns; a paths entry with a backslash, a leading slash, a drive letter and colon, an empty, dot, or dot-dot segment, or a square bracket is rejected; idempotency_check is a non-empty array of non-empty strings; unit_gate is a non-empty array of argv arrays; any violation yields config_invalid.
An absent file, an absent regeneration key, or regeneration: null yields no_config and today's behavior.
At start, argv[0] resolves to an application through PATH (and PATHEXT on Windows), a resolved .cmd or .bat file runs through ComSpec /d /c, and a batch path holding a double quote or one of & | < > ^ %, or a batch argument holding whitespace, a double quote, or one of & | < > ^ % ( ), is refused before the start.

- **`regeneration_events[]`.** A tolerated top-level list of the per-feature checkpoint, one entry per regenerate attempt, with `at`, `trigger`, `feature_head_sha`, `merge_head_sha`, `merge_base_sha`, `classifier` (`decision`, `reason`, `unmatched_paths`), `command_exit_code`, `confined`, `idempotent`, `unit_gate`, `delta_check`, `head_sha`, `evidence_path`, and `outcome` (`regenerated` or `fell_back`).
- **Delta outcome.** A completed regenerate path appends one `remediation_loop.review_outcomes[]` entry `{verdict: "PASS", findings: [], head_sha, review_kind: "regeneration_delta", evidence_path}`. `review_kind` and `evidence_path` are tolerated extra keys.
- **`integration_regenerations[]`.** A tolerated top-level list of the epic checkpoint, one entry per integration-tip or main-sync regeneration, with `trigger` (`post_feature_merge` or `main_sync`), `after_feature_issue_num`, `merge_commit_sha`, `regeneration_commit_sha`, `command_exit_code`, `confined`, `idempotent`, `outcome` (`applied` or `not_applied`), `ci_run_id`, `ci_conclusion`, and `verified_at`.
- **Validators.** The new keys are tolerated and unvalidated by the Python, TypeScript, and PowerShell validators: there is no REQUIRED_STATE_KEYS change and no validator code change. The regenerate path writes no `remediation_loop.cycles[]` entry, so R7 holds by construction, and `remediation_path` keeps its two values.
- **Portable handoff.** The destination projection is a closed key set, so the portable handoff projection drops the new keys, as it drops `review_mode`.
- **Runtime scope.** The regenerate path runs in the Claude runtime only; Codex orchestrators keep today's behavior and the .agents skills are not edited.
- **Merge-gate check.** `enforce-epic-merge-gate-regeneration.ps1`, byte-identical in `.claude/hooks/` and `.codex/hooks/`, runs after the review guard of both merge gates. When the last `review_outcomes[]` entry carries `review_kind` exactly `regeneration_delta`, it requires a `regeneration_events[]` entry with the same `head_sha`, `outcome` `regenerated`, the JSON booleans `idempotent` and `confined` true, and `unit_gate` and `delta_check` `pass`; otherwise it denies with `REVIEW_GATE_REGENERATION_UNVERIFIED` after the token `EPIC_MERGE_GATE_BLOCKED`. It runs no process.
- **Preimplementation allowance.** `Get-EpicRegenerationAllowance` in `hook-epic-regeneration.ps1`, byte-identical in `.claude/hooks/` and `.codex/hooks/`, is called by the epic-scope gate only for the exact `merge-in-progress` readiness failure. It admits one `git add` or `git commit` of configured generated paths on the integration branch, and nothing when the config is absent or invalid.

Honest disclosure: the merge-gate check and the preimplementation allowance are policy-level controls, not security controls. A writer in the same session can author `regeneration_events[]` and a delta outcome; the controls prove internal consistency, not origin. The delta outcome is not a full review, and the review/verdict status names the last full review's audit file.

## Enforcement

- `scripts/dev_tools/validate_orchestrator_state.py` appends one error per violated invariant when a `remediation_loop` is present, using the existing validator message style (literal, checkpoint-context prefixed). The validator returns a list of error strings and does not mutate its input.
- `scripts/dev_tools/validate_orchestrator_state.py` likewise appends one error per violated `human_interaction` invariant when a `human_interaction` key is present, using the same literal, checkpoint-context-prefixed message style. The check does not import or read any schema file.
- `scripts/dev_tools/validate_orchestrator_state.py` appends one error per violated `complexity_assessments` invariant when a `complexity_assessments` key is present, delegating to `scripts/dev_tools/_orchestrator_state_complexity.py`, which recomputes the floor via `compute_complexity_floor`. The check does not import or read any schema file.
- `scripts/dev_tools/validate_orchestrator_state.py` appends one error per violated `model_routing_receipts` invariant when a `model_routing_receipts` key is present, delegating to `scripts/dev_tools/_orchestrator_state_model_routing.py`, which recomputes the resolved model via `resolve_delegation_model`. The check does not import or read any schema file.
- `scripts/dev_tools/validate_orchestrator_state.py` appends one error per violated `require_model_routing` invariant only when the caller passes `require_model_routing=True`, delegating to `scripts/dev_tools/_orchestrator_state_model_routing_gate.py`, which reuses the complexity and model-routing per-entry validators. When the flag is not passed the gate does not run, so existing calls are byte-identical.
- The validator is consumed by the MCP tool `validate_orchestration_artifacts`; backward compatibility for existing step-based checkpoints is preserved.
- The standalone-merge authorization invariants are enforced by the `PreToolUse` merge gate (`.claude/hooks/enforce-epic-merge-gate.ps1` with its dot-sourced helpers file, and `.codex/hooks/enforce-epic-merge-gate.ps1`) at merge time. The green-CI standalone merge conditions are enforced by the same Claude gate through its dot-sourced sibling `.claude/hooks/enforce-epic-merge-gate-green-ci.ps1`; the Codex gate has no green-CI branch. The epic-child CI verification stages (issue #1130) are enforced by both gates through the byte-identical dot-sourced helper `enforce-epic-merge-gate-child-ci.ps1` in `.claude/hooks/` and `.codex/hooks/`. The Python checkpoint validator
  does not currently validate standalone_merge_authorizations
  entries; adding that check is recorded as follow-up FU-3.
- The `issue_adoption` invariants are enforced at completion by the routing-contract check in all three runtimes: `scripts/dev_tools/_orchestrator_state_issue_adoption.py` (Python authority), `extensions/drm-copilot/src/lib/validate/orchestrator-state-issue-adoption.ts`, and `.claude/lib/orchestrator-state/OrchestratorStateIssueAdoption.psm1`, with byte-identical error strings pinned by the shared corpus under `tests/fixtures/orchestrator_state_issue_adoption/`. Rules 10 and 11 live in the record modules `scripts/dev_tools/_orchestrator_state_feature_folder_record.py`, `extensions/drm-copilot/src/lib/validate/orchestrator-state-feature-folder-record.ts`, and `.claude/lib/orchestrator-state/OrchestratorStateFeatureFolderRecord.psm1`. The `HEAD` probe for a waived `new_active_feature_folder` lives in the hook sibling `.claude/hooks/validate-orchestrator-output-feature-folder.ps1`, loaded by `.claude/hooks/validate-orchestrator-output.ps1`.
- The batch-budget hooks (`.claude/hooks/enforce-python-batch-budget.ps1`, `.claude/hooks/enforce-powershell-batch-budget.ps1`, and the Codex copies under `.codex/hooks/`) read the checkpoint of the target worktree that `Resolve-HookTargetWorktree` resolves for the edited file, so a coordinating session never needs a checkpoint at its own root for them.
- The owner-directive rules B1-B8 and R1-R10 are enforced only by the Claude stop hook `.claude/hooks/validate-orchestrator-output.ps1` through `Get-OrchestratorStateOwnerDirectiveError` in `.claude/lib/orchestrator-state/OrchestratorStateOwnerDirectives.psm1`, which blocks with `OWNER_DIRECTIVE_BLOCKED`; the Python and TypeScript validators and Codex do not evaluate them.
- Owner-directive pass-down (issue #1157) is enforced only on Claude Code: the PreToolUse hook `.claude/hooks/enforce-owner-directive-pass-down.ps1` denies with `OWNER_DIRECTIVE_PASS_DOWN_BLOCKED:` a worker or `orchestrator` delegation that lacks a selected directive (`OWNER_DIRECTIVE_RELAY_REQUIRED`), holds an acknowledgement-set worker until it writes a valid decision file per pending directive (`OWNER_DIRECTIVE_DECISION_REQUIRED`, `OWNER_DIRECTIVE_DECISION_INVALID`), and denies a ledger write that is not a main-session append of valid lines (`OWNER_DIRECTIVE_LEDGER_WRITE_DENIED`); with no ledger and no `owner_directives` in any source it emits nothing. The stop-hook coverage check reports `OWNER_DIRECTIVE_RELAY_MISSING` and `OWNER_DIRECTIVE_LEDGER_INVALID`. There is no Codex or Copilot twin.
- Restored-host note (#1163): after a worktree is restored or moved to a different host path, run `git worktree repair` so its registration names the current path. Until then the stale registration is `prunable`; `Resolve-AgentTargetWorktree` (`.claude/lib/worktree-resolution/AgentTargetWorktree.psm1`) excludes it, so a branch registered only at the prunable path resolves `TARGET_WORKTREE_NOT_DERIVABLE`, the SubagentStop artifact hooks block with that code and the `git worktree repair` remedy, and a removal-gate record whose absolute `worktree_path` names no live registration is matched through its `branch_name`. The hooks do not run the repair.
