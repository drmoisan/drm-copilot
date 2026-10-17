# Research: Remediation-Loop Verdict Classification and Cycle Accounting (#484)

- Issue: #484 (epic #771 `orchestrator-state-contract-correctness`, wave 2, depends on #523)
- Branch: `bug/orchestrator-remediation-loop-control-484`
- Date: 2026-09-29
- Work mode: full-bug
- Inputs: `docs/features/active/2026-09-29-orchestrator-remediation-loop-control-484/issue.md` (AC-1..AC-6, authoritative), `spec.md` and `plan.2026-09-29T17-35.md` (both unfilled templates), `docs/features/epics/orchestrator-state-contract-correctness/epic.md`, the #464 plan `docs/features/active/2026-09-29-validate-orchestrator-state-cli-entry-point-464/plan.2026-09-29T14-20.md`, and the exported #523 spec, plan, and research (snapshot of `origin/bug/blocked-reason-premise-falsified-halt-523` at `576b91c8`).

## 0. Method and Limitations

- This session had file read, search, and write tools only. No shell was available, so no test, `wc -l`, `git`, or `npm` command was run.
- Line counts were obtained with a whole-file line-match count (`^`, one match per line), which equals `wc -l` for files that end in a newline. The executor must re-measure before relying on any headroom figure.
- Line citations are against this worktree (pre-#464, pre-#509, pre-#523). After #464 and #523 merge into the integration branch, Python line numbers in `validate_orchestrator_state.py` shift; the executor must locate sites by identifier.
- `PRE_R5_STATUS`, `ACTIVE_RUNTIME_INCOMPATIBILITY`, and `candidate_applied` appear only in this feature's `issue.md` and `spec.md` (repository-wide search, all file types). They were ad hoc fields written during the issue #467 run and are not part of any current contract.
- "Verified" below means read in the cited file. "Inference" marks conclusions drawn from the code or prose but not executed.

## 1. Current State

### 1.1 The review verdict contract, by surface (verified)

| Surface | Where the verdict is defined | Verdict form |
|---|---|---|
| Codex (`.agents/`) | `.agents/skills/feature-review/SKILL.md:41` and `:66-70`; `.agents/skills/feature-review-workflow/SKILL.md:148`; `.agents/skills/orchestrator-workflow/SKILL.md:228-236`; `.agents/skills/orchestrate/SKILL.md:407-410` | Exact terminal line `REVIEW_STATUS: PASS` or `REVIEW_STATUS: REMEDIATION_REQUIRED`, plus `REMEDIATION_INPUTS:` / `REMEDIATION_PLAN:` path-or-`NONE` lines. |
| Claude (`.claude/`) | `.claude/skills/orchestrate/SKILL.md:234-240` (`## Post-Review Outcome Evaluation`) | No verdict token. The orchestrator locates the newest `remediation-inputs.<timestamp>.md`; absent file means zero blockers; otherwise it counts lines matching `BLOCKING` or `Severity: Blocking` (case-sensitive) and enters R1-R5 on a count of 1 or more. |
| Copilot (`.github/`) | `.github/agents/orchestrator.agent.md:128,141,369,373-392`; `.github/skills/feature-review-workflow/SKILL.md:136`; `.github/prompts/review-feature.prompt.md:76,84` | Same two `REVIEW_STATUS` values as Codex. Not in the epic scope (epic.md lines 42-47, 54). |

Both forms are binary. Neither the reviewer nor the orchestrator has any vocabulary for a blocker that repository remediation cannot change.

Reviewer-side triggers that force non-remediable conditions into remediation (verified):

- Coverage: `.claude/agents/feature-review.md:93,131` and `.claude/skills/feature-review-workflow/SKILL.md:116,178` require an explicit `PASS` or `FAIL` per changed language and state that an absent coverage artifact is `FAIL`; the SubagentStop hooks `.claude/hooks/validate-feature-review-coverage.ps1` and `.codex/hooks/validate-feature-review-coverage.ps1:16-25` reject `UNVERIFIED` and `N/A`. An unavailable source-attributable coverage metric is therefore always a `FAIL`, and `FAIL` is always a remediation trigger (`.claude/skills/feature-review-workflow/SKILL.md:142-153`).
- Awaiting CI: the `modified-workflow-needs-green-run` rule emits a Blocking finding until a green run against the branch head exists and routes it "through the standard remediation handoff" (`.claude/skills/feature-review-workflow/SKILL.md:68-75`). The correct response is to wait for or dispatch a run, not to plan code changes.
- S9 poll timeout: `.claude/skills/orchestrate/SKILL.md:276` sets `step9_status: "failed_remediation_required"` on an exhausted poll timeout and enters the remediation loop, although a timeout means CI has not produced a result.
- Codex reviewer hand-off: `.agents/skills/feature-review/SKILL.md:66,72-82` and `.codex/agents/feature-reviewer.toml:47-54` make the reviewer itself create the remediation plan target file and delegate to `atomic-planner` whenever remediation is required. On the Codex path, "creating a remediation plan" (AC-2) happens inside the review delegation, not in the orchestrator.

### 1.2 Remediation-cycle counter inventory (verified)

| Counter | Defined at | Semantics as written | Validated by |
|---|---|---|---|
| `remediation_pass` | `.claude/skills/orchestrate/SKILL.md:244,251,253` | "starts at 1 and increments at R5 before returning to R1"; guard "reaches 3 without resolution" writes `step6_status: "blocked_remediation_loop_limit"`. | Nothing. No validator reads it (search of `*.py`, `*.ps1`, `*.psm1`, `*.ts`, `*.json` finds only prose comments in `_orchestrator_state_step_status.py:24`, a test docstring, and a Pester comment). |
| `remediation_pass` (CI sharing) | `.claude/skills/orchestrate/SKILL.md:326-328` | CI-failure passes share the counter; third CI-failure pass writes `step9_status: "blocked_ci_loop_limit"`. | Nothing (only the step-status literal is validated). |
| `remediation_pass` (merge conflict) | `.claude/skills/epic-orchestrate/SKILL.md:222-227`; `.agents/skills/epic-orchestrate/SKILL.md:114-116` | Shared with local and CI passes; "third conflict pass" writes `blocked_conflict_loop_limit`. | Nothing. |
| `remediation_pass` (parallel) | `.claude/skills/parallel-orchestrate/SKILL.md:418-419,1102` | Shared, cap 3. | Nothing. |
| `remediation_pass` (Codex orchestrate skill) | `.agents/skills/orchestrate/SKILL.md:414,421,423` | Same text as the Claude skill (starts at 1, increments at R5, cap 3). | Nothing. |
| `remediation-pass` (hyphenated) | `.agents/skills/orchestrator-workflow/SKILL.md:95,385,396` | Persisted top-level key; "increment `remediation-pass` and repeat" after a re-review that is still `REMEDIATION_REQUIRED`. No starting value and no cap in this document. | Nothing. |
| `remediation_loop.current_cycle` | `.claude/agents/orchestrator.md:99` | "integer index of the active cycle". | Nothing. |
| `remediation_loop.cycles[]` | `.claude/agents/orchestrator.md:100-114`; `.claude/rules/orchestrator-state.md:35-45` | Per-cycle `entry_timestamp`, `inputs_path`, `plan_path`, `preflight{iterations, final_status}`, `execution_status`, `audit_paths`, `blocking_count`, `exit_condition_met`. | Three invariants in all three runtimes (section 5.1). |
| `remediation.cycle_N.*` | `.claude/agents/orchestrator.md:116,120` | `next_step` form; `N` is "the cycle index"; a CI failure transitions to `cycle_N+1`. | Nothing. |

Findings on the accounting defect (inference from the prose above):

1. "Starts at 1, increments at R5" makes `remediation_pass` the number of the pass in progress (current semantics). `.agents/skills/orchestrator-workflow/SKILL.md:396` increments after a completed re-review (completed semantics) and gives no initial value. The two Codex documents therefore define different counters under near-identical names, which matches the issue's "alternated between current and completed semantics".
2. The guard text "reaches 3 without resolution" is ambiguous under current semantics: after the second failed re-audit the counter becomes 3 at R5, which reads as a halt after two attempts; the epic skill's "third conflict pass" reads as three attempts.
3. No rule ties a number to an executed attempt. A pass that is planned but never executed, or executed with no staged change, still receives the next number at R5 or at `cycle_N+1`.
4. `.agents/skills/orchestrator-workflow/SKILL.md:390` already halts a pass with empty staging (`blocked_reason: no_staged_changes`), but `no_staged_changes` is one of the six documentation-only members every validator rejects (#523 research section 2.2; #523 spec follow-up 1). The Claude loop has no equivalent halt.
5. `.agents/skills/orchestrator-workflow/SKILL.md:381-396` has no iteration cap; `.agents/skills/orchestrate/SKILL.md:423` does.

### 1.3 Layout inconsistency affecting the outcome evaluation (verified, pre-existing)

`.claude/skills/orchestrate/SKILL.md:238` locates a flat `remediation-inputs.<timestamp>.md` in the feature folder, and `.claude/agents/feature-review.md:35` writes that flat form. `.claude/skills/remediation-handoff-atomic-planner/SKILL.md:24,59,69` and `.agents/skills/remediation-handoff-atomic-planner/SKILL.md:25` prescribe `remediation/<entry-ts>/remediation-inputs.md`. The orchestrator's "highest timestamp" rule does not find the folder form. #484 keeps the flat form (the one the reviewer writes and the orchestrator and the parallel drift gate read, `.claude/hooks/enforce-parallel-drift-gate.ps1:75-76,147-168`) and records the divergence as a follow-up.

## 2. Candidate Approaches and Recommendation

### 2.1 Verdict representation

- **A (recommended). Extend the verdict with two values and classify each blocking finding.** Keep `PASS` and `REMEDIATION_REQUIRED` with their current meaning for remediable work; add `HALT_NON_REMEDIABLE` and `AWAITING_CI`. Each blocking finding carries a `Remediability` class. The verdict is a pure function of the class multiset (section 3.1), so the reviewer, the orchestrator, and the validators apply one rule. Existing reviewers that never emit the new values keep today's behavior.
- **B. Keep the binary verdict and let the orchestrator classify findings.** The orchestrator has no audit evidence of its own and would reclassify reviewer output; the Codex reviewer would still create the remediation plan before the orchestrator sees the result (section 1.1), so AC-2 fails on the Codex path. Rejected.
- **C. Binary verdict plus an orthogonal `non_remediable: true` flag.** Cannot distinguish halt from wait without a second field, and a reader that checks only `REVIEW_STATUS` still enters the loop. Rejected.

Class literals: reuse #523's four non-mechanical `blocked_reason` members directly as the non-remediable classes, plus `autonomous` for the remediable class. This removes any translation table between finding class and halt reason.

### 2.2 Checkpoint placement

- **Recommended: nest new fields under the existing `remediation_loop` key** (`remediation_loop.review_outcomes[]`, `remediation_loop.completed_attempts`, and per-cycle `candidate_applied` / `opened_by_review`). The remediation-loop family is already key-gated in every runtime (Python `validate_orchestrator_state.py:432-448`; PowerShell `OrchestratorStateUnconditional.psm1:65-72,139-145`; TypeScript `orchestrator-state-core.ts:402-405`), so no dispatcher, required-key list, or core module changes. `validate_orchestrator_state.py`, `orchestrator-state-core.ts`, and `OrchestratorStateUnconditional.psm1` are not edited.
- Rejected: a new top-level key (for example `review_verdicts[]`). It would add an entry to the optional-key dispatch in all three runtimes, touching `validate_orchestrator_state.py` (edited by #464 and #523) and `orchestrator-state-core.ts` (467 lines, edited by #405 and #523), with no behavioral gain.

### 2.3 Cycle accounting

- **Recommended: count derived from a per-cycle boolean.** Each cycle records `candidate_applied`; the attempt count is the number of cycles with `candidate_applied: true`; an optional stored `remediation_loop.completed_attempts` must equal that derived count. The number of the active cycle is `completed_attempts + 1`, so an unexecuted or no-candidate cycle leaves the next cycle with the same number.
- Rejected: a stored per-cycle `attempt_number`. It duplicates derivable state and is the kind of stored number that was misassigned in issue #467; validating sequential numbering across legacy and new cycles is also ambiguous.

## 3. Behavior Semantics (proposed)

### 3.1 Vocabulary

Per-finding class `Remediability` (exact literals; case-sensitive):

| Class | Meaning | Maps to `blocked_reason` (#523) |
|---|---|---|
| `autonomous` | Repository remediation can resolve the finding without a human decision. Default when the field is absent. | none (remediation loop) |
| `external_dependency` | External runtime incompatibility: a system, service, runtime, or published artifact outside the repository is unavailable or mismatched (for example a published MCP validator older than the repository contract, or a coverage metric the toolchain cannot attribute to source). | `external_dependency` |
| `policy_hold` | Proceeding requires a policy decision, exception, or authorization the orchestrator may not grant. | `policy_hold` |
| `awaiting_ci` | The finding resolves when a CI result that has not completed becomes available (for example `modified-workflow-needs-green-run` before a green run exists). | `awaiting_ci` |
| `human_decision_required` | A human must choose between alternatives or approve a direction. | `human_decision_required` |

Review verdict (exact literals), derived from the classes of all blocking findings:

| Verdict | Condition | Orchestrator action |
|---|---|---|
| `PASS` | No blocking findings. | Advance to the PR creation gate (unchanged). |
| `REMEDIATION_REQUIRED` | At least one `autonomous` blocking finding. | Enter R1 with a plan scoped to the `autonomous` findings only; carry non-remediable findings forward unchanged. |
| `HALT_NON_REMEDIABLE` | No `autonomous` finding, and at least one `external_dependency`, `policy_hold`, or `human_decision_required` finding. | Halt: no remediation plan, no cycle. Set `blocked_reason` to the highest-precedence class present: `human_decision_required` > `policy_hold` > `external_dependency`. |
| `AWAITING_CI` | Blocking findings exist and every one is `awaiting_ci`. | Wait: no remediation plan, no cycle; `blocked_reason: awaiting_ci`. |

Rationale for the mixed-case rule (design decision): AC-2 constrains only reviews whose blockers are all non-remediable; remediating the `autonomous` findings keeps the run autonomous, and the next re-audit then returns `HALT_NON_REMEDIABLE` or `AWAITING_CI`. Precedence rationale: a human decision can supersede the direction that a policy or external fix would serve; an external dependency is the narrowest halt.

### 3.2 Where the fields live

| Location | Addition | Authority |
|---|---|---|
| `remediation-inputs.<timestamp>.md` (flat, feature folder) | One line `Review-Verdict: <VERDICT>`; for each blocking finding one line `Remediability: <class>` and one line `Remediability-Evidence: <text>` inside that finding's block. | Primary carrier for both runtimes. The reviewer writes it for every review with at least one blocking finding, including halt and wait verdicts. |
| Codex review final report | `REVIEW_STATUS:` accepts the two new values; `REMEDIATION_PLAN: NONE` is required for `HALT_NON_REMEDIABLE` and `AWAITING_CI`. | `.agents/skills/feature-review/SKILL.md` |
| Claude review final report | Optional token `review-status: <VERDICT>` beside the existing path tokens (`.claude/agents/feature-review.md:41-46`). | The orchestrator treats `remediation-inputs` as authoritative and the token as a cross-check. |
| `code-review` / `feature-audit` / `policy-audit` | No required change. `code-review` may append a trailing `Remediability` column; the header check is a substring ending at `Evidence |` (`scripts/dev_tools/validate_orchestration_review_artifacts.py:74-79`; `extensions/drm-copilot/src/lib/validate/review-artifacts.ts:40`), so an appended column still passes. A column inserted mid-header would not. | Optional; not recommended as a requirement. |
| Checkpoint | `remediation_loop.review_outcomes[]`: `{verdict, findings: [{remediability, ...}], inputs_path?}` appended after every review once a producer adopts it; per-cycle `candidate_applied` (bool) and `opened_by_review` (index into `review_outcomes`); `remediation_loop.completed_attempts` (int). | Validated in all three runtimes (section 5). |

Compatibility constraint on the new text lines: they must not contain the substrings `BLOCKING` or `Severity: Blocking`, because `.claude/skills/orchestrate/SKILL.md:240` counts lines containing either. `Review-Verdict: HALT_NON_REMEDIABLE`, `Remediability: ...`, and `Remediability-Evidence: ...` satisfy this, so the blocking count of a new file equals the count of the same file without the new lines.

### 3.3 Post-review evaluation (Claude and Codex)

1. No `remediation-inputs` file, or blocking count 0: `PASS` (unchanged).
2. Blocking count at least 1 and no `Review-Verdict` line: `REMEDIATION_REQUIRED` (unchanged; every finding is treated as `autonomous`).
3. `Review-Verdict` present: the orchestrator recomputes the verdict from the `Remediability` lines (a blocking finding block without a `Remediability` line counts as `autonomous`). A mismatch between the declared and recomputed verdict is a reviewer contract error: record it under `artifact_errors`, re-request the review once, and halt with `blocked_reason: delegate_contract_incomplete` if it persists.
4. Append a `remediation_loop.review_outcomes[]` entry for the review.

### 3.4 Halt, wait, and resume

- Halt (`HALT_NON_REMEDIABLE`): set `blocked_reason` per the precedence rule; add one `human_interaction.requirements[]` entry with `response: "halt"` per non-remediable finding class present (section 4.3); leave `remediation_loop.completed_attempts` unchanged; do not write a cycle; stop.
- Wait (`AWAITING_CI`): set `blocked_reason: awaiting_ci` and set `next_step` to the step that re-checks (`S7_feature_review` for a review-time wait, `S9_ci_green` for an S9 poll timeout). Poll within the existing bounded S9 interval and timeout; when the bound is exhausted, persist and stop. On resume, set `blocked_reason: "none"` and re-run the named step. No `human_interaction` halt is recorded.
- S9 change: a poll timeout writes its synthetic finding with `Remediability: awaiting_ci` and follows the wait path; a failed required check stays `autonomous` and enters the loop as today (`.claude/skills/orchestrate/SKILL.md:276,320-328`).

### 3.5 Cycle accounting rule (one rule for every loop variant)

- A remediation attempt is complete when R3 execution finished (`execution_status: "complete"`) and the pre-R4 commit recorded a non-empty change set. Only then is `candidate_applied: true`.
- `completed_attempts` equals the number of cycles with `candidate_applied: true`. It replaces `remediation_pass` and `remediation-pass` in every document (for Codex, `remediation-pass` remains a persisted key and is redefined as equal to `remediation_loop.completed_attempts`, so existing checkpoints keep their key set).
- The active cycle's number is `completed_attempts + 1`; `remediation.cycle_N` in `next_step` uses that number, not the array index. `current_cycle` stays the zero-based index into `cycles[]` and is documented as a record position, not a count.
- A cycle that ends without a candidate (execution not started, execution failed, or an empty staged change set) records `candidate_applied: false`, consumes no number, and is followed by at most one re-plan under the same number when the executor output identifies an autonomous plan defect. Otherwise the orchestrator reclassifies the blocker (typically `external_dependency`) and halts. Two consecutive no-candidate cycles halt with `step6_status: "blocked_remediation_loop_limit"` (inference-based bound; prevents an unbounded loop of unnumbered cycles).
- Termination guard: halt when `completed_attempts == 3` and the latest verdict is not `PASS` (three completed attempts). The step-status literal is unchanged per loop variant (`blocked_remediation_loop_limit`, `blocked_ci_loop_limit`, `blocked_conflict_loop_limit`). Local, CI-failure, merge-conflict, and parallel-drift cycles share the one count.
- A halt or wait verdict never creates a cycle, so it cannot consume a number.

## 4. Upstream #523 Halt Representation

### 4.1 What #523 introduces (from the exported spec and plan)

| Runtime | Module | Names |
|---|---|---|
| Python | New `scripts/dev_tools/_orchestrator_state_blocked_reason.py` (spec lines 120-126; plan P3-T1) | `MECHANICAL_BLOCKED_REASONS: frozenset[str]` (six existing non-`none` members), `NON_MECHANICAL_BLOCKED_REASONS: frozenset[str]` (`premise_falsified`, `external_dependency`, `policy_hold`, `awaiting_ci`, `human_decision_required`), `VALID_BLOCKED_REASONS = frozenset({"none"}) | ...`, `BlockedReasonClass = Literal["not_blocked", "mechanical", "non_mechanical"]`, `classify_blocked_reason(value: object) -> BlockedReasonClass` (raises `ValueError("invalid blocked_reason: ...")`). `validate_orchestrator_state.py` imports `VALID_BLOCKED_REASONS` from it (plan P3-T2) and adds a `not isinstance(blocked_reason, str)` guard (P3-T3). |
| TypeScript | New `extensions/drm-copilot/src/lib/validate/orchestrator-state-blocked-reason.ts` (spec lines 139-144; plan P4-T1) | `MECHANICAL_BLOCKED_REASONS`, `NON_MECHANICAL_BLOCKED_REASONS`, `VALID_BLOCKED_REASONS` (`ReadonlySet<string>`), `type BlockedReasonClass`, `classifyBlockedReason(value: unknown)` (throws `RangeError`). `orchestrator-state-core.ts` imports and re-exports `VALID_BLOCKED_REASONS` (P4-T2); `jest.config.cjs` gains a per-file threshold (P4-T3). |
| PowerShell | `.claude/lib/orchestrator-state/OrchestratorState.psm1` and bundle copy (spec lines 146-153; plan P5-T1..P5-T3) | Script-scoped arrays `$script:MECHANICAL_BLOCKED_REASONS`, `$script:NON_MECHANICAL_BLOCKED_REASONS`, `$script:VALID_BLOCKED_REASONS = @('none') + ...`; no classify function; `-cnotcontains` in `Get-OrchestratorStateBasePresenceError` and `-cne 'none'` in `Get-OrchestratorStatePrCreationReadinessError`. |
| Fixtures | `tests/fixtures/orchestrator_state_blocked_reason_partition.json` (oracle), `tests/fixtures/orchestrator_state_blocked_reason/*.json` (20-case corpus, `MINIMUM_CORPUS_COUNT = 20`), `tests/fixtures/orchestrator_state_blocked_reason_backcompat/` plus `..._backcompat_expected.json` (plan P1-T1, P1-T2, P2-T1, P2-T2). |
| Documents | `.agents/skills/orchestrator-workflow/SKILL.md` enumeration plus a `Blocked-reason partition:` paragraph; `.claude/rules/orchestrator-state.md` new `## Blocked-Reason Vocabulary` section with a line starting `Extension point for #484:`; producer bullets in both orchestrate skills (plan P6-T3..P6-T6). |

The `## Extension Point for #484` section (spec lines 231-237) fixes the four literals, states that writing them requires no validator, gate, corpus, or partition change, and states that adding a fifth halt class is a separate contract change. #523 adds no cross-field rule between `blocked_reason` and `human_interaction.requirements[].response` (spec lines 57, 239-241).

### 4.2 Mapping and consequences for #484

| #484 non-remediable class (issue AC-1 wording) | #523 member |
|---|---|
| external runtime incompatibility | `external_dependency` |
| policy decision | `policy_hold` |
| awaiting-CI state | `awaiting_ci` |
| human-decision requirement | `human_decision_required` |

- #484 needs no `blocked_reason` vocabulary change and must not add one. `premise_falsified` is not a review finding class in #484.
- Every existing gate already treats the four members as "not complete" (#523 spec lines 86, 234), so halt and wait states block DONE and PR creation with no gate edit.
- "Wait" needs nothing beyond `blocked_reason: awaiting_ci` for the contract. Resume information already exists: `next_step` names the step to re-run, and for S9 the awaited run is in `ci_gate.head_sha` / `ci_gate.pr_pipeline_run_id` with `conclusion: "pending"` (`.claude/skills/orchestrate/SKILL.md:286-293`). For a review-time wait, the awaited workflow is named in the finding's `Remediability-Evidence` line. No additional checkpoint field is recommended.
- #484 should add a drift-guard unit test asserting that the non-remediable Remediability classes are a subset of `NON_MECHANICAL_BLOCKED_REASONS` (Python and TypeScript import the #523 constant in the test; Pester reads `$script:NON_MECHANICAL_BLOCKED_REASONS` through `InModuleScope`).

### 4.3 Interaction with `human_interaction.requirements[].response == "halt"`

- Verified: `halt` is in the response enum (`scripts/dev_tools/_orchestrator_state_human_interaction.py:48`; `.claude/lib/orchestrator-state/OrchestratorStateReceipts.psm1:69`); `Test-HumanInteractionShape` blocks DONE while any `halt` is present (`.claude/hooks/validate-orchestrator-output.ps1:68-132`); a halt is lifted by resolving the requirement (`.claude/skills/orchestrate/SKILL.md:108`).
- Producer rule (documentation only, consistent with #523's no-cross-field decision): for `HALT_NON_REMEDIABLE`, record one requirement with `response: "halt"` per class present among `external_dependency`, `policy_hold`, `human_decision_required`, describing the human action needed (for example "publish an MCP release containing the repository contract"). For `AWAITING_CI`, record no halt requirement, because the condition resolves without a human and a halt would require manual lifting.
- No validator rule ties `review_outcomes[].verdict`, `blocked_reason`, and `human_interaction` together. A cross-field rule would invalidate the checkpoint in the window between clearing `blocked_reason` on resume and appending the next review outcome (inference), and it would contradict #523's scope.

## 5. Validator Support in the Three Runtimes

### 5.1 Where remediation cycles are validated today (verified)

| Runtime | File (lines) | Functions / constants | Wiring |
|---|---|---|---|
| Python (pre-#464) | `scripts/dev_tools/validate_orchestrator_state.py` (492 lines): constants 110-117, `_validate_remediation_cycle` 120-152, `_validate_remediation_loop` 155-177 | `REMEDIATION_LOOP_KEY`, `REMEDIATION_CYCLES_KEY`, `EXECUTION_STATUSES_REQUIRING_CLEAR_PREFLIGHT`, `PREFLIGHT_CLEARED_STATUS` | Optional-key tuple at 432-448 (first entry, line 433). |
| Python (post-#464, assumed layout) | `scripts/dev_tools/_orchestrator_state_remediation_loop.py` (new; #464 plan P3-T1) | #464 moves verbatim the four constants above and `_validate_remediation_cycle`, `_validate_remediation_loop`, adds a module docstring, `from __future__ import annotations`, `from typing import Any, cast`, and an `__all__` block; `validate_orchestrator_state.py` imports `REMEDIATION_LOOP_KEY, _validate_remediation_loop` (P3-T2). Estimated about 100 lines (inference: 66 moved lines plus header). | Unchanged call site in the optional-key tuple. |
| PowerShell | `.claude/lib/orchestrator-state/OrchestratorStateReceipts.psm1` (410 lines): constants 60-64, `Get-RemediationCycleError` 231-288 (private), `Get-OrchestratorStateRemediationLoopError` 290-332 (exported, 407-410) | `$script:REMEDIATION_CYCLES_KEY`, `$script:EXECUTION_STATUSES_REQUIRING_CLEAR_PREFLIGHT`, `$script:PREFLIGHT_CLEARED_STATUS` | `OrchestratorStateUnconditional.psm1:65-72,143-145`. Bundle copy: `extensions/drm-copilot/resources/claude-customizations/.claude/lib/orchestrator-state/OrchestratorStateReceipts.psm1`. |
| TypeScript | `extensions/drm-copilot/src/lib/validate/orchestrator-state-remediation.ts` (136 lines): `validateRemediationCycle` 53-98, `validateRemediationLoop` 111-136 | `REMEDIATION_LOOP_KEY`, `REMEDIATION_CYCLES_KEY`, `EXECUTION_STATUSES_REQUIRING_CLEAR_PREFLIGHT`, `PREFLIGHT_CLEARED_STATUS` | `orchestrator-state-core.ts:16-17,402-405`. No per-file `coverageThreshold` entry in `extensions/drm-copilot/jest.config.cjs` (verified by search), so the file is currently ungated. |

Existing tests: Python `tests/scripts/dev_tools/test_validate_orchestrator_state_remediation_loop.py` (326 lines; #464 P3-T5 keeps it unedited); Pester `tests/scripts/claude-lib/orchestrator-state/OrchestratorStateReceipts.Tests.ps1` (298 lines; U6.R block 149-225, in-memory JSON via `ConvertFrom-Json -NoEnumerate`, lines 43-46); Jest `extensions/drm-copilot/test/lib/validate/orchestrator-state-remediation.test.ts` (168 lines). No shared remediation-loop fixture corpus exists. Repository corpus precedents: `tests/fixtures/parallel_cohort_barrier/`, `tests/fixtures/blast_radius/`, #509's `tests/fixtures/orchestrator_state_issue_adoption/`, and #523's `tests/fixtures/orchestrator_state_blocked_reason*/`.

Pre-existing cross-runtime divergence on an edited line (verified): Python `cycle.get("blocking_count") != 0` (`validate_orchestrator_state.py:146`) and PowerShell `Test-PythonZeroEquivalent` (`OrchestratorStateCheckpointValue.psm1:178-205`) treat `blocking_count: false` as zero; TypeScript `cycle["blocking_count"] !== 0` (`orchestrator-state-remediation.ts:90`) does not. The #484 corpus must exclude boolean `blocking_count`; the divergence is recorded as a follow-up so that TypeScript output for existing checkpoints stays byte-identical.

### 5.2 Proposed invariants (Python authoritative; mirrored exactly)

All run only when their key is present. They are evaluated after the existing per-cycle checks, so for a checkpoint without the new keys the error list is unchanged in content and order.

Structural change common to all runtimes: `_validate_remediation_loop` currently returns early when `cycles` is not a list. The new checks must also run for a loop that has `review_outcomes` but no `cycles` (a halt at the first review). The function keeps the per-cycle loop under the list condition and then calls the new checks with the cycle list or `None`. With no new keys present, the new checks return nothing, so existing outputs are unchanged.

| ID | Rule | Proposed message |
|---|---|---|
| R5 | `candidate_applied`, when present on a cycle, is a JSON boolean. | `Checkpoint remediation cycle #{i} candidate_applied must be a boolean.` |
| R6 | `candidate_applied: true` requires `execution_status == "complete"`. | `Checkpoint remediation cycle #{i} candidate_applied is true but execution_status is not 'complete'.` |
| R7 | `completed_attempts`, when present, is a non-negative integer (booleans excluded) equal to the number of cycles whose `candidate_applied` is `true`. | `Checkpoint remediation_loop completed_attempts must be a non-negative integer.` / `Checkpoint remediation_loop completed_attempts is {n} but {k} cycles have candidate_applied true.` |
| R8 | `review_outcomes`, when present, is a list of objects. | `Checkpoint remediation_loop review_outcomes must be a list.` / `Checkpoint remediation review outcome #{j} must be an object.` |
| R9 | Each outcome's `verdict` is one of the four literals; each `findings` is a list of objects whose `remediability` is one of the five classes (string check before set membership). | `Checkpoint remediation review outcome #{j} verdict must be one of PASS, REMEDIATION_REQUIRED, HALT_NON_REMEDIABLE, AWAITING_CI; got: {v}` / `Checkpoint remediation review outcome #{j} findings must be a list.` / `Checkpoint remediation review outcome #{j} finding #{m} remediability must be one of autonomous, external_dependency, policy_hold, awaiting_ci, human_decision_required; got: {v}` |
| R10 | A valid verdict equals the derivation of section 3.1 over its findings' classes. | `Checkpoint remediation review outcome #{j} verdict {v} does not match its findings (expected {e}).` |
| R11 | `opened_by_review`, when present on a cycle, is an integer index into `review_outcomes` whose entry has verdict `REMEDIATION_REQUIRED`. This encodes AC-2 structurally: no cycle can be attributed to a halt or wait review. | `Checkpoint remediation cycle #{i} opened_by_review must reference a review outcome whose verdict is REMEDIATION_REQUIRED.` |

Every new message contains the substring `remediation`, which lets corpus readers filter the family.

Pure helper (all three runtimes; Python name authoritative): `derive_review_verdict(remediabilities: Sequence[str]) -> ReviewVerdict` (TypeScript `deriveReviewVerdict`; PowerShell private `Get-RemediationReviewVerdict`), used by R10 and by tests. Constants: `REVIEW_OUTCOMES_KEY = "review_outcomes"`, `COMPLETED_ATTEMPTS_KEY`, `CANDIDATE_APPLIED_KEY`, `OPENED_BY_REVIEW_KEY`, `REVIEW_VERDICTS` (four), `REMEDIABILITY_CLASSES` (five), `HALT_CLASSES` (three). Rendering of `got:` values follows the existing human-interaction pattern (Python f-string, TypeScript `pythonRepr`, PowerShell `ConvertTo-PythonDisplayText`); the corpus limits non-string values to integers and `null` because boolean and float rendering diverge (#523 research section 1.3 item 3). PowerShell comparisons use `-ccontains` / `-cnotcontains`, matching #523's case-sensitivity correction.

### 5.3 Files to change and 500-line budget

| File | Lines now | Change | Estimated after (inference) |
|---|---|---|---|
| `scripts/dev_tools/_orchestrator_state_remediation_loop.py` | absent (created by #464, about 100) | Restructure `_validate_remediation_loop`; add R5-R11 and `derive_review_verdict`. | about 230 |
| `scripts/dev_tools/validate_orchestrator_state.py` | 492 (about 433 after #464) | Not edited. | unchanged |
| `.claude/lib/orchestrator-state/OrchestratorStateReceipts.psm1` + bundle | 410 | Import the new module; restructure the early return; one call to the new entry point. | about 416 |
| New `.claude/lib/orchestrator-state/OrchestratorStateRemediationAccounting.psm1` + bundle | absent | R5-R11 and the verdict helper, pure, importing `OrchestratorStateCheckpointValue.psm1`. Placing them in Receipts would take it to about 510 lines (inference: about 100 added lines with comment-based help), over the cap. | about 180 |
| `extensions/drm-copilot/resources/claude-customizations/pack-manifests/core.json` | 198 | Register the new module (line 135 lists Receipts). | +1 |
| `tests/scripts/claude-lib/orchestrator-state/OrchestratorState.Manifest.Tests.ps1` | 105 | Add the new path to `$script:ExpectedPaths` (28-40); the on-disk registration test at 78-88 fails otherwise. | +1 |
| `scripts/powershell/PoshQC/settings/pester.runsettings.psd1` and `extensions/drm-copilot/resources/powershell/PoshQC/settings/pester.runsettings.psd1` | 335 each | Add the new module to `CodeCoverage.Path` (Receipts is at line 103). | +1 each |
| `extensions/drm-copilot/src/lib/validate/orchestrator-state-remediation.ts` | 136 | Restructure; add R5-R11 and `deriveReviewVerdict`. | about 280 |
| `extensions/drm-copilot/jest.config.cjs` | 325 | Add a per-file entry for `orchestrator-state-remediation.ts` (`lines: 85`, `branches: 75`); #405, #509, and #523 add adjacent keys. | +4 |
| `orchestrator-state-core.ts`, `OrchestratorStateUnconditional.psm1`, `OrchestratorState.psm1` | 467 / 168 / 499 | Not edited. | unchanged |

`OrchestratorState.psm1` (499 lines) is avoided entirely; #523 already consumes its headroom. Registration files are shared with #509 (wave 1), which merges before #484 executes; the edits are separate list entries.

### 5.4 Tests and parity corpus

- New unit test files (one per runtime; the existing remediation test files are not extended, which keeps the Python file at 326 lines and avoids the batch-budget cost of editing more files): `tests/scripts/dev_tools/test_orchestrator_state_remediation_accounting.py`, `extensions/drm-copilot/test/lib/validate/orchestrator-state-remediation-accounting.test.ts`, `tests/scripts/claude-lib/orchestrator-state/OrchestratorStateRemediationAccounting.Tests.ps1`.
- Parity corpus `tests/fixtures/orchestrator_state_remediation_loop/*.json`, shape `{name, notes, checkpoint, expected_errors}` (the #509 and #523 shape), errors filtered to those containing `remediation`, name-equals-stem and minimum-count guards, read in place. Readers: `tests/scripts/dev_tools/test_orchestrator_state_remediation_loop_parity.py` (via `validate_orchestrator_state_text`), `extensions/drm-copilot/test/lib/validate/orchestrator-state-remediation-loop-parity.test.ts` (via `validateOrchestratorStateText`), `tests/scripts/claude-lib/orchestrator-state/OrchestratorStateRemediationLoop.Parity.Tests.ps1` (via `Get-OrchestratorStateUnconditionalError` on `ConvertFrom-Json` output, resolving the corpus from `$PSScriptRoot` as `BlastRadius.Parity.Tests.ps1` does).
- Back-compat cases in the same corpus, captured from the unmodified validators before any production edit (the #523 plan's Phase 1 technique): no `remediation_loop`; a valid legacy cycle; each of the three existing violations; `cycles` as a string and as an object; a non-object cycle; a legacy `current_cycle` value.
- New-field cases: each R5-R11 violation and its passing counterpart; halt at first review (`review_outcomes` present, no `cycles`); a `candidate_applied: false` cycle not counted; mixed verdict; each precedence case; case variants of every literal rejected.
- Documentation drift tests (prefix `test_docs_`, in the Python unit file): every verdict literal and class literal appears in `.agents/skills/feature-review/SKILL.md` and `.claude/agents/orchestrator.md`; the class set is a subset of #523's `NON_MECHANICAL_BLOCKED_REASONS` plus `autonomous`.
- No test creates a temporary file; Pester fixtures are in-memory JSON or committed corpus files.

## 6. Document Inventory

Mirror parity tests (verified):

- M-C: every `.claude/**` file except `settings.local.json` and `agent-memory/**` must equal its copy under `extensions/drm-copilot/resources/claude-customizations/.claude/` (`tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py:118-143`); orchestrator-state modules also by `OrchestratorState.Manifest.Tests.ps1:91-104`.
- M-A: every `.agents/**` and `.codex/**` file must equal its copy under `extensions/drm-copilot/resources/codex-and-agents-customizations/` (`tests/scripts/dev_tools/test_push_down_codex_and_agents_resource_contracts.py:215-228`); `orchestrator-workflow` also by `tests/scripts/dev_tools/test_orchestration_guardrail_contracts.py:116-126`.
- Fragment guards that constrain wording (existing sentences must remain; additions are permitted): `test_codex_handoff_contract_parity.py:134-162` (`.agents/skills/feature-review/SKILL.md` handoff sentences), `test_codex_agent_wrapper_contracts.py:123-147` (`.codex/agents/feature-reviewer.toml` lines 49-61), `test_orchestration_guardrail_contracts.py:132-134` (`blocked_reason` MUST be one of:).
- Generated Codex variants: `.codex/agents/feature-reviewer.toml` is the canonical source for `feature-reviewer-{c1,c2,c3,c3-elevated,c4}.toml` (`scripts/dev_tools/generate_codex_agent_variants.py:33-42,182-193`), checked in CI (`.github/workflows/_quality-checks.yml`) and by `tests/scripts/dev_tools/test_generate_codex_agent_variants.py`. An edit to the base requires regenerating five variants and their bundle copies (twelve files in total).

| File | Lines to change | Change | Mirror |
|---|---|---|---|
| `.agents/skills/feature-review/SKILL.md` | 29, 37-38, 41, 66-70, 72-82 | Add the two verdicts and the `Remediability` contract; "remediation is required" only when at least one blocking finding is `autonomous`; `REMEDIATION_PLAN: NONE` for halt and wait; no planner hand-off for halt and wait. Keep the guarded fragments. | M-A |
| `.agents/skills/feature-review-workflow/SKILL.md` | 131-142, 148 | Classification step before triggering remediation; new `REVIEW_STATUS` values. | M-A |
| `.agents/skills/orchestrate/SKILL.md` | 403-410, 412-423, 447-449 | Four-way outcome evaluation; `completed_attempts` rule and guard; PR gate unchanged (requires `PASS`). Coordinate with #523's inserted Preparation Mode bullet (not adjacent). | M-A |
| `.agents/skills/orchestrator-workflow/SKILL.md` | 92-95, 228-236, 323-325, 378-379, 383-396 | Verdict list; redefine `remediation-pass`; add the cap; record `candidate_applied`; halt and wait branches. Line 390 (`no_staged_changes`) is left to #523 follow-up 1; add the `candidate_applied: false` recording as a separate sentence. Do not touch #523's enum block (145-159) or #509's lines (about 200-201 and 407). | M-A + guardrail test |
| `.agents/skills/orchestrator-state/SKILL.md` | 12, 61-69, 85-89 | Mirror the new invariants (this is the `.agents` copy of the rules document). | M-A |
| `.agents/skills/remediation-handoff-atomic-planner/SKILL.md` | 16-21 | Trigger only on `autonomous` blocking findings. | M-A |
| `.agents/skills/epic-orchestrate/SKILL.md` | 114-116 | "three completed attempts". | M-A |
| `.codex/agents/feature-reviewer.toml` | 47-54, 59, 61 | One added sentence exempting non-remediable blockers from the hand-off and naming the new verdicts; regenerate the five variants. | M-A + generator check |
| `.claude/skills/orchestrate/SKILL.md` | 234-240, 242-253, 276, 320-328 | Four-way evaluation; accounting rule; S9 timeout as `awaiting_ci`; CI sharing via `completed_attempts`. No invocation form (skill bundle contract, #762). | M-C |
| `.claude/agents/orchestrator.md` | 95-116, 120, 150-152 | Add `review_outcomes`, `completed_attempts`, `candidate_applied`, `opened_by_review`; malformed-cycle rules R5-R11; `cycle_N` numbering rule; exit gate counts only `autonomous` blockers. | M-C |
| `.claude/agents/feature-review.md` | 35, 41-46 | `Remediability` lines and `Review-Verdict` in `remediation-inputs`; optional `review-status:` token. | M-C |
| `.claude/skills/feature-review-workflow/SKILL.md` | 68-75, 142-153 | Green-run rule findings are `awaiting_ci`; classification before the trigger. | M-C |
| `.claude/skills/remediation-handoff-atomic-planner/SKILL.md` | 12-18, 39-41, 48-55, 107, 123-125 | Trigger on `autonomous` only; exit gate; `candidate_applied` recording. | M-C |
| `.claude/skills/epic-orchestrate/SKILL.md` | 219-227 | Shared count is `completed_attempts`. | M-C |
| `.claude/skills/parallel-orchestrate/SKILL.md` | 415-419, 848, 1097-1103 | Same. Line 1102 states that `.claude/skills/orchestrate/SKILL.md` is not modified by that feature; that statement describes the earlier feature and stays true for it. | M-C |
| `.claude/rules/orchestrator-state.md` | 27, 35-45 | See section 9. | M-C |

Out of scope, recorded as follow-up: `.github/agents/orchestrator.agent.md`, `.github/agents/feature-review.agent.md`, `.github/skills/feature-review-workflow/SKILL.md`, `.github/prompts/review-feature.prompt.md` and their mirrors under `extensions/drm-copilot/resources/customizations/.github/` (mirror enforced for the orchestrator agents by `tests/scripts/dev_tools/test_orchestrator_direct_command_contracts.py:15-18,85`). The Copilot surface keeps the binary verdict, which remains valid under the new contract. `.codex/prompts/feature-review-remediate.md:7` ("If remediation is required") stays correct once the term is redefined.

## 7. Backward Compatibility and Consumers

| Consumer | What it reads | Effect of the new fields |
|---|---|---|
| Claude Post-Review Outcome Evaluation (`.claude/skills/orchestrate/SKILL.md:238-240`) | Newest `remediation-inputs`; count of lines containing `BLOCKING` / `Severity: Blocking` | New lines avoid both substrings; absent `Review-Verdict` keeps today's rule. |
| `.claude/hooks/validate-feature-review-coverage.ps1:12-18,370-417` | Output tokens `policy-audit-path`, `code-review-path`, `feature-audit-path`, optional `remediation-inputs-path`; file existence; policy-audit coverage rows | A new optional `review-status:` token is ignored by the token scanner; no hook edit. |
| `.codex/hooks/validate-feature-review-coverage.ps1:50-80` | Newest `policy-audit.*.md` coverage rows | Unaffected; coverage rows stay `PASS`/`FAIL`. |
| `.claude/hooks/enforce-parallel-drift-gate.ps1:75-76,99-170` | `remediation-inputs.` file names and embedded timestamps only (no content) | Unaffected. |
| PR-context readiness (`scripts/dev_tools/pr_context/feature_docs.py:143-195`; TypeScript `extensions/drm-copilot/src/lib/pr-context/feature-docs-parsers.ts:262-276`) | `Readiness:` / `Overall feature readiness:` in `feature-audit` with `PASS`, `NEEDS REVISION`, `BLOCKED` | Do not put new verdict values on the readiness line; an unknown value parses as `None`. The readiness line is unchanged. |
| Review-artifact validators (`scripts/dev_tools/validate_orchestration_review_artifacts.py:37-107`; `review-artifacts.ts`) | Headings; findings-table header substring | Unaffected; an appended code-review column still matches. |
| Orchestrator-state validators and gates (section 5.1; completion, PR-readiness, SubagentStop, PR-author preflight per #523 spec line 86) | `remediation_loop` family; `blocked_reason` | New checks are presence-gated and appended after existing errors; `blocked_reason` handling is #523's. |
| `.claude/hooks/enforce-checkpoint-monotonic.ps1:1-61` | `completed_steps` ordering | Unaffected. |

Byte-identity statement (design, to be proven by the back-compat corpus): a checkpoint without `review_outcomes`, `completed_attempts`, `candidate_applied`, and `opened_by_review` produces the same error list in plain, `require_complete`, PR-readiness, and `require_model_routing` modes, because none of those modes reads the new keys and the remediation family appends nothing for them. A `remediation-inputs` file without `Review-Verdict` is evaluated exactly as today.

Forward compatibility with older published validators (inference from code): the TypeScript validator ignores unknown keys inside `remediation_loop` (`orchestrator-state-remediation.ts:111-136`), so an older published MCP accepts the new fields without enforcing them. It does reject #523's new `blocked_reason` members until a release containing #523 is published (see section 8).

## 8. Runtime Capability and Version Incompatibility (AC-6)

What exists today (verified):

- The Codex MCP transport is pinned to `@danmoisan/drm-copilot-mcp@1.1.15` (`.codex/config.toml:5`, bundle copy identical), and a test requires the pin to equal `packages/mcp-server/package.json` `version` (`tests/scripts/dev_tools/test_push_down_codex_and_agents_resource_contracts.py:150-160`; package version 1.1.15). The Claude transport is unpinned (`.mcp.json:5`).
- The server reports its package version only in the MCP `serverInfo` handshake (`extensions/drm-copilot/src/mcp-server.ts:75-79`); no tool exposes a contract version or inventory.
- The Codex agent-family inventory has four copies kept equal by tests: Python `GENERATED_AGENT_FAMILIES` (`scripts/dev_tools/resolve_codex_deployment.py:32`), `config/orchestration-routing.json` `codex_model_policy.generated_agent_families` (`tests/scripts/dev_tools/test_codex_model_policy_config_parity.py:71,82`, which also pins `commit-steward`), PowerShell `CodexDeployment.psm1:66` (repo and two bundle copies), and TypeScript `orchestrator-state-codex-model-routing.ts:39`.
- Release reconciliation checks only that each `mcp-server-v*` tag has a published npm version, on schedule (`.github/workflows/verify-published-releases.yml:56-94`).
- No check compares the contract inside the published package with the repository contract, and no orchestration preflight runs one.

Consequence (inference): the repository can change the validator contract (a new Codex family, as in issue #467; or #523's `blocked_reason` members) without a version bump, so the pinned version resolves to a published package that predates the repository. After #523 and #484 merge, a Codex orchestrator that records `blocked_reason: external_dependency` would be rejected by the pinned MCP validator until a release is published.

Effort estimate for detection before execution: a contract fingerprint (hash of the validator vocabularies and routing inventories) computed from repository sources and exposed by a new MCP tool, a Python comparison script, orchestrator preflight text in the `.claude` and `.agents` orchestrate skills, `.codex/config.toml` `enabled_tools` plus its bundle and the `EXPECTED_DRM_COPILOT_TOOLS` test list, and a release before the check can pass. Estimate C3: about 6-9 production files and 4-6 test files across TypeScript, Python, and configuration. A cheaper interim form compares the pinned version's release tag with `HEAD` over the MCP-bundled source paths (`git diff --quiet mcp-server-v<version> HEAD -- <paths>`), but it still needs a path inventory of what the package bundles and its own tests.

Recommendation: record AC-6 as a scoped follow-up. It is independent of the verdict and accounting contract, it adds an MCP tool surface that only takes effect after a publish, and #484 is already a C4 change across three runtimes and about sixteen documents. #484 does classify a detected mismatch as `external_dependency` so that it halts instead of consuming cycles.

Draft follow-up (for a potential entry):

- Title: Detect published-MCP contract lag before orchestration.
- Summary: The Codex MCP transport is pinned to the repository's package version, but the package published under that version can predate repository validator and routing changes. Orchestration then fails validation for reasons no repository remediation can fix (issue #467: a Codex agent family added after `@danmoisan/drm-copilot-mcp@1.0.24` was published). Detect the lag at startup and halt with `blocked_reason: external_dependency`.
- Scope: (1) a deterministic contract fingerprint over `VALID_BLOCKED_REASONS`, `GENERATED_AGENT_FAMILIES`, the routing matrix, and the remediation-loop vocabularies, computed identically by a Python helper and by the TypeScript server; (2) an MCP tool returning the fingerprint and package version; (3) an orchestrator S0 preflight in both orchestrate skills that compares the two and records a mismatch as an `external_dependency` halt with a `human_interaction` halt requirement naming the release action; (4) tests for fingerprint parity and mismatch handling. Non-goals: automatic publishing; changing the pin policy. Constraint: no enforcement hook gains a Python leg (the preflight is an orchestrator step, not a hook).

## 9. Rules-Document Edit

`.claude/rules/orchestrator-state.md` states that it "documents three invariants that must hold for each remediation cycle" (line 27) and lists them at 35-45; `orchestrator-state-remediation.ts:5-8` cites that section as its source. If #484 adds validator invariants without updating it, the documented contract and the enforced contract diverge, and the `.agents` copy (`.agents/skills/orchestrator-state/SKILL.md:12,61-69`) diverges in the same way. The edit is therefore needed for accuracy, not for enforcement.

Minimal edit: in line 27 replace "three invariants that must hold for each remediation cycle" with wording that covers the added cycle and review-outcome invariants; append numbered items for R5-R7 and R11 to `## Invariants (per remediation cycle)`; add one short subsection `## Invariants (remediation_loop.review_outcomes)` directly after it for R8-R10. Do not edit `## Enforcement` (#509 edits it) or #523's `## Blocked-Reason Vocabulary` section; the #484 hunks sit above #523's anchor (after line 45) and are not adjacent to #464's (about line 95). Apply the same text to `.agents/skills/orchestrator-state/SKILL.md`. Record an orchestrator decision authorizing the edit, as #523 did (OD-523-2).

## Requirements Mapping

| Issue AC | Design element | Evidence to plan |
|---|---|---|
| AC-1 | `Remediability` classes (section 3.1) in `remediation-inputs`, the Codex report, and `review_outcomes[].findings[]`; R9 | Unit and corpus cases per class; documentation drift test |
| AC-2 | Halt and wait branches create no plan and no cycle (sections 3.3-3.4); Codex reviewer skips the planner hand-off; R11 forbids a cycle attributed to a halt or wait review | Corpus case: halt at first review with no cycles validates; R11 negative case |
| AC-3 | `candidate_applied`, derived `completed_attempts`, R5-R7, numbering rule (section 3.5) | Corpus cases: no-candidate cycle not counted; mismatched count rejected |
| AC-4 | R5-R11 in Python, PowerShell (new module), TypeScript; shared corpus | Three corpus readers with equal ordered outputs |
| AC-5 | Presence gating; appended ordering; unchanged `BLOCKING` count; unchanged readiness line | Back-compat corpus captured before edits; existing suites unchanged |
| AC-6 | Follow-up (section 8); mismatch classified `external_dependency` | Follow-up potential entry recorded |

## Testing Implications

- Order: capture back-compat corpus outputs against the unmodified validators first; then add failing tests for R5-R11; then implement Python, TypeScript, and PowerShell in that order.
- Python coverage must use dotted module names with `--cov-report=term-missing` (`--cov=scripts.dev_tools._orchestrator_state_remediation_loop`); a `--cov=<path>.py` form measures nothing.
- Jest: the new per-file threshold for `orchestrator-state-remediation.ts` gates both the old and new code in that file; confirm the pre-change coverage of the existing code meets 85/75 before relying on the threshold.
- Pester: line coverage only; add the new module to both run-settings files before measuring.
- Property tests: `hypothesis` and `fast-check` are not dependencies (#523 plan Scope Notes); `derive_review_verdict` can be covered exhaustively, because the input space is the power set of five classes (32 combinations).
- Run the mirror and fragment suites listed in section 6 and the Codex variant generator in check mode.
- Batch budget: at most three test files per delegation batch; do not reset hook state (issue #769 files are out of scope).

## Numeric Derivation Evidence

### N1: production implementations of remediation-cycle validation = 4

- Complete Family: every non-test file that emits a remediation-cycle validation error.
- Exhaustive Search Scope: the whole worktree excluding `docs/**`, `tests/**`, `extensions/drm-copilot/test/**`, and `node_modules`.
- Inclusion Rules: a file containing validation logic that produces a `remediation cycle #` message.
- Exclusion Rules: tests, documentation, fixtures.
- Primary Search Strategy or Query Expression: literal search for `remediation cycle #` with the exclusions above.
- Primary Member Set: `scripts/dev_tools/validate_orchestrator_state.py`; `.claude/lib/orchestrator-state/OrchestratorStateReceipts.psm1`; `extensions/drm-copilot/resources/claude-customizations/.claude/lib/orchestrator-state/OrchestratorStateReceipts.psm1`; `extensions/drm-copilot/src/lib/validate/orchestrator-state-remediation.ts`.
- Primary Count: 4.
- Cross-check Search Strategy or Query Expression: literal search for `exit_condition_met` in `*.py`, `*.ps1`, `*.psm1`, `*.ts`, `*.js`, `*.cjs`, then removing test files.
- Cross-check Member Set: the same four files (the search also returned four test files, excluded by rule: `test_validate_orchestrator_state_remediation_loop.py`, `orchestrator-state-remediation.test.ts`, `orchestration-artifacts.test.ts`, `OrchestratorStateReceipts.Tests.ps1`).
- Cross-check Count: 4.
- Member-set Comparison: identical. After #464 the Python member becomes `scripts/dev_tools/_orchestrator_state_remediation_loop.py`; the count is unchanged.

### N2: `.agents` documents that define the binary review verdict = 4

- Complete Family: files under `.agents/` that state the `REVIEW_STATUS` verdict values.
- Exhaustive Search Scope: `.agents/**` (bundle copies are separate files under `extensions/` and are excluded because they mirror these).
- Inclusion Rules: a file containing the verdict token and its values.
- Exclusion Rules: bundle mirrors, `.github/`, `docs/`.
- Primary Search Strategy or Query Expression: literal search for `REVIEW_STATUS`, restricted to `.agents/`.
- Primary Member Set: `.agents/skills/orchestrator-workflow/SKILL.md`, `.agents/skills/orchestrate/SKILL.md`, `.agents/skills/feature-review-workflow/SKILL.md`, `.agents/skills/feature-review/SKILL.md`.
- Primary Count: 4.
- Cross-check Search Strategy or Query Expression: literal search for `REMEDIATION_REQUIRED`, restricted to `.agents/`.
- Cross-check Member Set: the same four files.
- Cross-check Count: 4.
- Member-set Comparison: identical. (Outside `.agents/`, the two searches differ by `.github/agents/feature-review.agent.md` and its mirror, which mention `REVIEW_STATUS` in a description line without the values; that surface is out of scope.)

No other numeric claim is proposed for an acceptance criterion. The four verdict literals and five class literals are design definitions, not derived counts.

## Automation Feasibility

The work involves no third-party user interface and requires no human interaction to implement or verify: validator code in three runtimes, committed fixtures, Markdown and TOML edits with mirrors, generated Codex variants, and unattended Python, Jest, and Pester suites. Two items are not autonomous but are outside #484's execution: (1) the MCP publish that makes the pinned Codex validator accept #523's members, which is the release step and is irreversible once the tag is pushed; (2) the AC-6 follow-up, which only takes effect after a publish. The rules-document edit needs an orchestrator decision record, not a human. The epic's `potential_to_issue` substitution under `human_interaction.requirements[]` still applies (or #509's evidence form, if it has merged into the integration branch).

## Rejected Alternatives (summary)

- Binary verdict with orchestrator-side classification: fails AC-2 on the Codex path, where the reviewer creates the plan.
- Orthogonal `non_remediable` flag: cannot separate halt from wait with one field.
- New top-level checkpoint key for review outcomes: edits the dispatcher in three runtimes for no gain.
- Stored per-cycle `attempt_number`: duplicates derivable state and reintroduces misnumbering.
- Adding the new PowerShell checks to `OrchestratorStateReceipts.psm1`: exceeds the 500-line cap (estimate).
- Cross-field validator rule between the verdict, `blocked_reason`, and `human_interaction`: invalidates resumable intermediate states and contradicts #523's scope.
- A new `remediation-inputs` artifact validator type: requires MCP tool-schema changes and a publish; the checkpoint validators satisfy AC-4.

## Follow-ups (not part of #484)

1. AC-6: detect published-MCP contract lag before orchestration (draft in section 8).
2. Reconcile the flat `remediation-inputs.<timestamp>.md` form with the `remediation/<entry-ts>/remediation-inputs.md` form (section 1.3).
3. TypeScript `blocking_count: false` divergence from Python and PowerShell (section 5.1).
4. Apply the verdict and accounting contract to the Copilot `.github/` surface and its mirrors (section 6).
5. `no_staged_changes` at `.agents/skills/orchestrator-workflow/SKILL.md:390` is a validator-rejected literal on the no-candidate path; covered by #523 follow-up 1, which should take #484's `candidate_applied` recording into account.
6. Python `response not in HUMAN_INTERACTION_RESPONSE_ENUM` (`_orchestrator_state_human_interaction.py:111`) raises `TypeError` for list or dict values, the same class of defect #523 fixes for `blocked_reason` (inference from set semantics; not executed).

## Risks

- #484 edits `.agents/skills/orchestrator-workflow/SKILL.md`, both orchestrate skills, and the rules document after #509 and #523 have edited them; locate hunks by heading and content.
- Twelve generated Codex files change with one sentence in `feature-reviewer.toml`; run the generator, not manual edits.
- The Jest threshold entry newly gates pre-existing code in `orchestrator-state-remediation.ts`.
- Codex producers cannot validate #523's members through the pinned MCP until a release is published; sequence the epic release before relying on Codex halts.
- All line numbers and counts were measured without a shell and before #464, #509, and #523; re-measure during execution.
