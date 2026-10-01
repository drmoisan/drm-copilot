# 2026-09-29-orchestrator-remediation-loop-control (Spec)

- **Issue:** #484
- **Parent (optional):** Epic #771 (`orchestrator-state-contract-correctness`; manifest `docs/features/epics/orchestrator-state-contract-correctness/epic.md`)
- **Owner:** drmoisan
- **Last Updated:** 2026-09-29T18-30
- **Status:** Draft
- **Version:** 0.1

## Context
The orchestration state machine treats every non-PASS review as actionable remediation, including external runtime incompatibilities and unavailable coverage metrics. This causes unnecessary remediation plans, commits, re-reviews, inconsistent cycle numbering, and cycle consumption when no corrective candidate was applied.

Environment:
- OS/version: Windows 11 / PowerShell workspace
- Python version: 3.13.12 through Poetry
- Node/npm version: Node 24.14.0 / npm 11.9.0
- Command/flags used: Codex `orchestrate` workflow with authoritative MCP orchestration validation
- Data source or fixture: issue #467 checkpoint, review artifacts, published `@danmoisan/drm-copilot-mcp@1.0.24`, and repository-local validators

Impact / Severity:
- [x] Blocker
- [ ] High
- [ ] Medium
- [ ] Low

Research basis: `research/2026-09-29T17-50-remediation-loop-verdict-research.md` (cited below as "research section N"). The research was performed without a shell; line numbers and line counts were obtained by file reads against this worktree before #464, #509, and #523 merged. The executor re-measures every figure (`wc -l` or equivalent) and locates edit sites by identifier and heading, not by line number.

Epic position: wave 2, depends on #523, which depends on #464. #509 (wave 1) merges into `epic/orchestrator-state-contract-correctness-integration` before #484 executes. This spec assumes:
- the #464 layout: remediation-loop constants and validators live in `scripts/dev_tools/_orchestrator_state_remediation_loop.py`, which `scripts/dev_tools/validate_orchestrator_state.py` imports (`REMEDIATION_LOOP_KEY`, `_validate_remediation_loop`) (#464 plan P3-T1, P3-T2);
- the #523 halt representation (snapshot of `origin/bug/blocked-reason-premise-falsified-halt-523` at `576b91c8`; see Upstream Halt Representation below);
- the #509 optional top-level `issue_adoption` checkpoint object.

## Repro & Evidence
Steps to Reproduce:
1. Run a feature review that returns a blocker which cannot be changed by repository remediation, such as an immutable MCP runtime mismatch or unavailable source-attributable coverage metric.
2. Observe that the reviewer can return only `PASS` or `REMEDIATION_REQUIRED` and that the orchestrator unconditionally enters R1-R5 for `REMEDIATION_REQUIRED`.
3. Let remediation execution return an external/runtime failure with no candidate applied and the checkpoint restored byte-for-byte.
4. Observe that the outer workflow still stages evidence, commits, re-reviews, increments the pass counter, and consumes a remediation cycle.
5. Compare repository-local and published MCP routing inventories when a new Codex agent family was added after the package version was published.

Expected:
The reviewer classifies whether a blocking condition is autonomously remediable. External runtime mismatches, policy decisions, awaiting-CI states, and human-decision requirements halt or wait without creating a remediation plan or consuming a remediation cycle. Cycle accounting counts completed remediation attempts consistently, and runtime capability/version incompatibility is detected before execution.

Actual:
The binary review contract forced every blocker into remediation. The pass counter alternated between current and completed semantics, an unexecuted pass occupied a number, and pass 7 was consumed after `PRE_R5_STATUS: ACTIVE_RUNTIME_INCOMPATIBILITY` with `candidate_applied: false`. The published MCP 1.0.24 validator rejected valid repository `commit-steward` routing receipts, while an unrelated legacy routing gate also generated missing-receipt diagnostics.

Logs / Screenshots:
- [x] Attached minimal logs or screenshot
- Snippet: issue #467 records seven audit rounds, six completed remediation re-reviews, eight execution/resume delegations, one unexecuted numbered pass, and no pass 8. The final candidate passed the repository validator but could not change the immutable published MCP resolver.

Note: `PRE_R5_STATUS`, `ACTIVE_RUNTIME_INCOMPATIBILITY`, and the #467 `candidate_applied` key were ad hoc fields written during that run and are not part of any current contract (research section 0). This spec defines `candidate_applied` formally under `remediation_loop.cycles[]`.

## Scope & Non-Goals
- In scope:
  - A four-value review verdict and a per-finding remediability class, defined in the reviewer and orchestrator documents of the `.agents/`, `.claude/`, and `.codex/` surfaces and recorded in the checkpoint.
  - Halt and wait outcomes recorded through #523's `blocked_reason` members, without a remediation plan and without a remediation cycle.
  - One cycle-accounting rule (completed attempts only) for the local, CI-failure, merge-conflict, and parallel-drift loop variants.
  - Additive, presence-gated checkpoint fields under `remediation_loop` and validator invariants R5-R11 in Python (authoritative), PowerShell (repository and bundled copies), and TypeScript, with a shared parity corpus and a back-compat corpus.
  - A minimal, contract-documentation edit to `.claude/rules/orchestrator-state.md` and its mirrors (see Policy-Document Edit).
- Out of scope / non-goals:
  - Any change to the `blocked_reason` vocabulary, partition, or classification helpers. These are owned by #523; #484 consumes them unchanged.
  - Any validator cross-field rule between `remediation_loop.review_outcomes[].verdict`, `blocked_reason`, and `human_interaction.requirements[]` (research section 4.3; consistent with #523 scope).
  - Any change to the completion gate, PR-creation-readiness gate, SubagentStop hook, or PR-author preflight.
  - A new `remediation-inputs` artifact validator type or any MCP tool-schema change.
  - Any change to `validate_orchestrator_state.py`, `orchestrator-state-core.ts`, `OrchestratorStateUnconditional.psm1`, or `OrchestratorState.psm1`.
  - Runtime capability or version incompatibility detection (issue AC-6); written up as a follow-up under Out-of-Scope Follow-up: Published-MCP Contract Lag.
  - The Copilot `.github/` surface (`.github/agents/orchestrator.agent.md`, `.github/agents/feature-review.agent.md`, `.github/skills/feature-review-workflow/SKILL.md`, `.github/prompts/review-feature.prompt.md`, and their mirrors). It keeps the binary verdict, which remains valid under the new contract. Recorded as a follow-up.
  - Any edit under `.github/instructions/`.
- Explicitly excluded systems, integrations, or datasets:
  - Issue #769 files: `.claude/hooks/enforce-powershell-batch-budget.ps1` and its related files and tests.
  - All enforcement hooks under `.claude/hooks/` and `.codex/hooks/`. No hook is edited and no hook gains a Python leg.
  - `scripts/dev_tools/validate_orchestration_review_artifacts.py` and `extensions/drm-copilot/src/lib/validate/review-artifacts.ts` (not edited; research section 7).
  - PR-context readiness parsers (`scripts/dev_tools/pr_context/feature_docs.py`, `extensions/drm-copilot/src/lib/pr-context/feature-docs-parsers.ts`). The `feature-audit` readiness line is unchanged.

## Root Cause Analysis
The review contract in `.agents/skills/` and `.claude/skills/orchestrate/SKILL.md` (`## Post-Review Outcome Evaluation`, `## Remediation Loop (R1–R5)`) defines only a binary outcome and increments `remediation_pass` unconditionally at R5.

Additional findings (research sections 1.1-1.2):
- Codex surfaces define the exact terminal line `REVIEW_STATUS: PASS` or `REVIEW_STATUS: REMEDIATION_REQUIRED` in four `.agents` documents (research Numeric Derivation Evidence N2). The Claude surface has no verdict token; the orchestrator counts lines containing `BLOCKING` or `Severity: Blocking` in the newest `remediation-inputs.<timestamp>.md` and enters R1-R5 on a count of one or more.
- Reviewer-side rules convert non-remediable conditions into remediation triggers: an absent coverage artifact is `FAIL`; `modified-workflow-needs-green-run` emits a Blocking finding until a green run exists; the S9 poll timeout writes `step9_status: "failed_remediation_required"`; the Codex reviewer creates the remediation plan target and delegates to `atomic-planner` inside the review delegation.
- Counters: `remediation_pass` ("starts at 1 and increments at R5") uses current-pass semantics in both orchestrate skills; `remediation-pass` in `.agents/skills/orchestrator-workflow/SKILL.md` increments after a completed re-review with no initial value and no cap; `remediation_loop.current_cycle` and `remediation.cycle_N` are separate indices. No validator reads any of them. No rule ties a number to an executed attempt.
- Remediation cycles are validated by three invariants in four production files (research N1): the Python module (post-#464 `scripts/dev_tools/_orchestrator_state_remediation_loop.py`), `.claude/lib/orchestrator-state/OrchestratorStateReceipts.psm1` and its bundled copy, and `extensions/drm-copilot/src/lib/validate/orchestrator-state-remediation.ts`.

## Proposed Fix

### Design summary (what changes where):

**Decision 1: extend the verdict and classify each blocking finding (research option A).** Options B (orchestrator-side classification) and C (binary verdict plus a `non_remediable` flag) are rejected per research section 2.1: B fails issue AC-2 on the Codex path, where the reviewer creates the plan; C cannot separate halt from wait with one field.

**Review verdict literals (exact, case-sensitive):**

| Verdict | Condition over the classes of all blocking findings | Orchestrator action |
|---|---|---|
| `PASS` | No blocking findings. | Advance to the PR creation gate (unchanged). |
| `REMEDIATION_REQUIRED` | At least one `autonomous` finding. | Enter R1 with a plan scoped to the `autonomous` findings only; carry the non-remediable findings forward unchanged. |
| `HALT_NON_REMEDIABLE` | No `autonomous` finding, and at least one `external_dependency`, `policy_hold`, or `human_decision_required` finding. | Halt. No remediation plan, no cycle. |
| `AWAITING_CI` | At least one finding, and every finding is `awaiting_ci`. | Wait. No remediation plan, no cycle. |

**Per-finding classification field and values (exact, case-sensitive):**

- Field name: `Remediability` in `remediation-inputs.<timestamp>.md`; `remediability` in the checkpoint (`remediation_loop.review_outcomes[].findings[].remediability`).
- Values: `autonomous`, `external_dependency`, `policy_hold`, `awaiting_ci`, `human_decision_required`.

| Class | Issue AC-1 wording | Meaning | `blocked_reason` member (#523) |
|---|---|---|---|
| `autonomous` | autonomously remediable | Repository remediation can resolve the finding without a human decision. Default when the `Remediability` line is absent from a `remediation-inputs` finding block. | none (remediation loop) |
| `external_dependency` | external runtime incompatibility | A system, service, runtime, or published artifact outside the repository is unavailable or mismatched (for example a published MCP validator older than the repository contract, or a coverage metric the toolchain cannot attribute to source). | `external_dependency` |
| `policy_hold` | policy decision | Proceeding requires a policy decision, exception, or authorization the orchestrator may not grant. | `policy_hold` |
| `awaiting_ci` | awaiting-CI state | The finding resolves when a CI result that has not completed becomes available (for example `modified-workflow-needs-green-run` before a green run exists, or an S9 poll timeout). | `awaiting_ci` |
| `human_decision_required` | human-decision requirement | A human must choose between alternatives or approve a direction. | `human_decision_required` |

The four non-remediable class literals are identical to #523's four predefined non-mechanical `blocked_reason` members, so no translation table exists between a finding class and a halt reason. `premise_falsified` is not a #484 finding class.

Verdict derivation is a pure function of the class multiset, evaluated in this order: empty → `PASS`; any `autonomous` → `REMEDIATION_REQUIRED`; any of `external_dependency`, `policy_hold`, `human_decision_required` → `HALT_NON_REMEDIABLE`; otherwise → `AWAITING_CI`. Mixed-case rationale (research section 3.1): issue AC-2 constrains only reviews whose blockers are all non-remediable; remediating the `autonomous` findings keeps the run autonomous, and the next re-audit returns `HALT_NON_REMEDIABLE` or `AWAITING_CI`.

**Decision 2: nest checkpoint fields under the existing `remediation_loop` key (research section 2.2).** The remediation-loop family is already key-gated in every runtime, so no dispatcher, required-key list, or core module changes. A new top-level key is rejected because it would edit the optional-key dispatch in `validate_orchestrator_state.py` and `orchestrator-state-core.ts`.

**Decision 3: derive the attempt count from a per-cycle boolean (research section 2.3).** A stored per-cycle `attempt_number` is rejected because it duplicates derivable state and is the kind of stored number that was misassigned in issue #467.

**Decision 4: add the new PowerShell checks in a new module.** Adding them to `OrchestratorStateReceipts.psm1` (410 lines) would take it to about 510 lines (research section 5.3), over the cap. The checks go into `.claude/lib/orchestrator-state/OrchestratorStateRemediationAccounting.psm1`.

**Deviation from research (recorded):** the research places the documentation drift tests in the Python unit test file. This spec places them in a separate file, `tests/scripts/dev_tools/test_orchestrator_state_remediation_docs.py`, because the unit file carries the exhaustive 32-combination verdict-derivation test plus R5-R11 positive and negative cases, and keeping the drift tests separate removes the risk of that file approaching the 500-line cap. No other research recommendation is changed.

### Upstream Halt Representation (#523) Consumed by #484

#484 records every halt and wait through #523's representation and introduces no parallel representation. The names below are those #523's spec and plan introduce (#523 spec `## Extension Point for #484`; #523 plan P3-T1..P5-T3):

| Runtime | Module | Names #484 consumes |
|---|---|---|
| Python | `scripts/dev_tools/_orchestrator_state_blocked_reason.py` | `MECHANICAL_BLOCKED_REASONS: frozenset[str]`, `NON_MECHANICAL_BLOCKED_REASONS: frozenset[str]` (`premise_falsified`, `external_dependency`, `policy_hold`, `awaiting_ci`, `human_decision_required`), `VALID_BLOCKED_REASONS`, `BlockedReasonClass`, `classify_blocked_reason(value: object) -> BlockedReasonClass` (raises `ValueError`). `scripts/dev_tools/validate_orchestrator_state.py` imports `VALID_BLOCKED_REASONS` from it. |
| TypeScript | `extensions/drm-copilot/src/lib/validate/orchestrator-state-blocked-reason.ts` | `MECHANICAL_BLOCKED_REASONS`, `NON_MECHANICAL_BLOCKED_REASONS`, `VALID_BLOCKED_REASONS` (`ReadonlySet<string>`), `type BlockedReasonClass`, `classifyBlockedReason(value: unknown)` (throws `RangeError`). `orchestrator-state-core.ts` re-exports `VALID_BLOCKED_REASONS`. |
| PowerShell | `.claude/lib/orchestrator-state/OrchestratorState.psm1` and bundle copy | Script-scoped arrays `$script:MECHANICAL_BLOCKED_REASONS`, `$script:NON_MECHANICAL_BLOCKED_REASONS`, `$script:VALID_BLOCKED_REASONS`; no classify function. |
| Fixtures | `tests/fixtures/orchestrator_state_blocked_reason_partition.json` | Partition oracle (read-only for #484). |
| Documents | `.claude/rules/orchestrator-state.md` `## Blocked-Reason Vocabulary` (line beginning `Extension point for #484:`); `.agents/skills/orchestrator-workflow/SKILL.md` enumeration under ``- `blocked_reason` MUST be one of:`` | Not edited by #484. |

Rules:
- A `HALT_NON_REMEDIABLE` verdict sets `blocked_reason` to the highest-precedence class present: `human_decision_required` > `policy_hold` > `external_dependency`. Precedence rationale: a human decision can supersede the direction a policy or external fix would serve; an external dependency is the narrowest halt.
- An `AWAITING_CI` verdict sets `blocked_reason: "awaiting_ci"`.
- Every existing gate already treats these four members as not complete (#523 spec, Design summary), so halt and wait states block DONE and PR creation with no gate edit.
- #484 adds a drift-guard test in each runtime asserting that `NON_REMEDIABLE_CLASSES` (below) is a subset of `NON_MECHANICAL_BLOCKED_REASONS` (Python and TypeScript import the #523 constant in the test; Pester reads `$script:NON_MECHANICAL_BLOCKED_REASONS` from `OrchestratorState.psm1` through `InModuleScope`).
- #484 does not rename, remove, or re-partition any #523 member, and edits no #523 file.

### Relationship to `human_interaction.requirements[].response == "halt"`

- `halt` is a member of the response enum (`scripts/dev_tools/_orchestrator_state_human_interaction.py`; `.claude/lib/orchestrator-state/OrchestratorStateReceipts.psm1`), and `Test-HumanInteractionShape` in `.claude/hooks/validate-orchestrator-output.ps1` blocks DONE while any `halt` requirement is present. A halt is lifted by resolving the requirement.
- Producer rule (documentation only): on `HALT_NON_REMEDIABLE`, append one `human_interaction.requirements[]` entry with `response: "halt"` for each class present among `external_dependency`, `policy_hold`, and `human_decision_required`, describing the human action needed (for example "publish an MCP release containing the repository contract").
- On `AWAITING_CI`, record no `halt` requirement: the condition resolves without a human, and a `halt` requirement would require manual lifting.
- No validator rule ties the verdict, `blocked_reason`, and `human_interaction` together. A cross-field rule would invalidate the checkpoint in the window between clearing `blocked_reason` on resume and appending the next review outcome, and it would contradict #523's no-cross-field decision. The parity corpus includes a case proving that a `HALT_NON_REMEDIABLE` outcome with `blocked_reason: "none"` and no `human_interaction` block produces no remediation-family error.

### Halt, Wait, and Resume Behavior (documents)

1. Post-review evaluation (Claude and Codex):
   - No `remediation-inputs` file, or blocking count 0: `PASS` (unchanged).
   - Blocking count at least 1 and no `Review-Verdict:` line: `REMEDIATION_REQUIRED` (unchanged; every finding is treated as `autonomous`).
   - `Review-Verdict:` present: the orchestrator recomputes the verdict from the `Remediability:` lines (a blocking finding block without a `Remediability:` line counts as `autonomous`). A mismatch between declared and recomputed verdicts is a reviewer contract error: record it under `artifact_errors`, re-request the review once, and halt with `blocked_reason: "delegate_contract_incomplete"` if it persists.
   - Append a `remediation_loop.review_outcomes[]` entry for every review, including `PASS`.
2. Halt (`HALT_NON_REMEDIABLE`): set `blocked_reason` per precedence; append the `halt` requirements; leave `completed_attempts` unchanged; write no cycle; create no remediation plan; stop.
3. Wait (`AWAITING_CI`): set `blocked_reason: "awaiting_ci"` and `next_step` to the step that re-checks (`S7_feature_review` for a review-time wait, `S9_ci_green` for an S9 poll timeout). Poll within the existing bounded S9 interval and timeout; when the bound is exhausted, persist and stop. On resume, set `blocked_reason: "none"` and re-run the named step. For S9, the awaited run is already identified by `ci_gate.head_sha` and `ci_gate.pr_pipeline_run_id` with `conclusion: "pending"`; for a review-time wait, the awaited workflow is named in the finding's `Remediability-Evidence:` line. No additional checkpoint field is added.
4. S9 change: a poll timeout writes its synthetic finding with `Remediability: awaiting_ci` and follows the wait path; a failed required check stays `autonomous` and enters the loop as today.
5. Codex reviewer: `REVIEW_STATUS:` accepts the two new values; `REMEDIATION_PLAN: NONE` is required for `HALT_NON_REMEDIABLE` and `AWAITING_CI`; the reviewer creates no remediation plan target and does not delegate to `atomic-planner` for those verdicts.

### Cycle Accounting Rule (one rule for every loop variant)

- A remediation attempt is complete when R3 execution finished (`execution_status: "complete"`) and the pre-R4 commit recorded a non-empty change set. Only then does the producer set `candidate_applied: true` on that cycle.
- `remediation_loop.completed_attempts` equals the number of cycles whose `candidate_applied` is `true`. It replaces `remediation_pass` in both orchestrate skills and in the epic and parallel orchestrate skills. For Codex, `remediation-pass` remains a persisted top-level key (so existing checkpoints keep their key set) and is redefined as equal to `remediation_loop.completed_attempts`.
- The active cycle's number is `completed_attempts + 1`; `remediation.cycle_N` in `next_step` uses that number. `remediation_loop.current_cycle` stays the zero-based index into `cycles[]` and is documented as a record position, not a count.
- A cycle that ends without a candidate (execution not started, execution failed, or an empty staged change set) records `candidate_applied: false` and consumes no number. It is followed by at most one re-plan under the same number when the executor output identifies an autonomous plan defect; otherwise the orchestrator reclassifies the blocker (typically `external_dependency`) and halts. Two consecutive no-candidate cycles halt with `step6_status: "blocked_remediation_loop_limit"`; the existing loop-limit halt behavior otherwise applies unchanged. (This bound is a design decision to prevent an unbounded loop of unnumbered cycles.)
- Termination guard: halt when `completed_attempts == 3` and the latest verdict is not `PASS` (three completed attempts). This replaces the ambiguous "reaches 3 without resolution" wording. The step-status literal per loop variant is unchanged (`blocked_remediation_loop_limit`, `blocked_ci_loop_limit`, `blocked_conflict_loop_limit`). Local, CI-failure, merge-conflict, and parallel-drift cycles share the one count.
- A halt or wait verdict never creates a cycle, so it cannot consume a number.
- Every cycle a producer opens from a review records `opened_by_review`, the zero-based index of the `review_outcomes[]` entry that opened it.

### Boundaries and invariants to preserve:
- Existing remediation-cycle error messages, their order, and their zero-based `#{index}` numbering are unchanged in every runtime:
  - `Checkpoint remediation cycle #{index} plan_path must be a non-empty string.`
  - `Checkpoint remediation cycle #{index} execution_status is {execution_status} but preflight.final_status is not 'clear'.`
  - `Checkpoint remediation cycle #{index} exit_condition_met is true but blocking_count is not 0.`
  - `Checkpoint remediation cycle #{index} must be an object.`
- A non-object `remediation_loop` still yields no remediation-family error.
- New checks run only when their key is present and append after all existing remediation-cycle errors.
- `blocked_reason` handling, the completion gate, and the PR-readiness gate are #523's and are not edited.
- A `remediation-inputs` file without a `Review-Verdict:` line is evaluated exactly as today, and the new text lines never change the blocking-line count (see Inputs/outputs).
- Repository and bundled copies of every edited `.claude/**`, `.agents/**`, and `.codex/**` file are byte-identical.

### Dependencies or blocked work:
- Depends on #523 (merged into the integration branch first) for the four `blocked_reason` members and the `NON_MECHANICAL_BLOCKED_REASONS` constant in each runtime. The executor confirms `scripts/dev_tools/_orchestrator_state_blocked_reason.py` and `extensions/drm-copilot/src/lib/validate/orchestrator-state-blocked-reason.ts` exist before starting.
- Depends on #464 for `scripts/dev_tools/_orchestrator_state_remediation_loop.py`. The executor confirms it exists and that `validate_orchestrator_state.py` imports `REMEDIATION_LOOP_KEY` and `_validate_remediation_loop` from it.
- Follows #509 (wave 1). #509 edits `pack-manifests/core.json`, `OrchestratorState.Manifest.Tests.ps1`, both `pester.runsettings.psd1` files, `jest.config.cjs`, the rules document `## Enforcement`, and `.agents/skills/orchestrator-workflow/SKILL.md` near its `issue_adoption` text. #484 adds separate list entries and edits disjoint hunks.
- Blocks nothing in the epic.

### Implementation strategy (what changes, not sequencing):
The remediation-loop validator in each runtime is restructured so that new checks also run for a loop with `review_outcomes` but no `cycles` list; the existing per-cycle loop is unchanged and still runs only when `cycles` is a list. A pure verdict-derivation helper and R5-R11 are added. Documents in the `.agents`, `.claude`, and `.codex` surfaces adopt the four-way verdict, the remediability class, the halt and wait branches, and the accounting rule. Back-compat outputs are captured from the unmodified validators before any production edit.

#### Files/modules to change:

Production (line counts from research section 5.3; re-measure):

| File | Lines now | Change | Estimated after |
|---|---|---|---|
| `scripts/dev_tools/_orchestrator_state_remediation_loop.py` | about 100 (created by #464) | Restructure `_validate_remediation_loop`; add constants, `derive_review_verdict`, R5-R11; extend `__all__`. | about 230 |
| `.claude/lib/orchestrator-state/OrchestratorStateReceipts.psm1` + bundle copy | 410 | `Import-Module` the new module; restructure the early return in `Get-OrchestratorStateRemediationLoopError`; one call to the new entry point. | about 416 |
| New `.claude/lib/orchestrator-state/OrchestratorStateRemediationAccounting.psm1` + bundle copy | absent | R5-R11 and the verdict helper; imports `OrchestratorStateCheckpointValue.psm1`. | about 180 |
| `extensions/drm-copilot/resources/claude-customizations/pack-manifests/core.json` | 198 | Register the new module next to the Receipts entry. | +1 |
| `scripts/powershell/PoshQC/settings/pester.runsettings.psd1` and `extensions/drm-copilot/resources/powershell/PoshQC/settings/pester.runsettings.psd1` | 335 each | Add the new module to `CodeCoverage.Path` next to Receipts. | +1 each |
| `extensions/drm-copilot/src/lib/validate/orchestrator-state-remediation.ts` | 136 | Restructure `validateRemediationLoop`; add constants, `deriveReviewVerdict`, R5-R11; update the header comment. | about 280 |
| `extensions/drm-copilot/jest.config.cjs` | 325 | Add a per-file `coverageThreshold` entry for `./src/lib/validate/orchestrator-state-remediation.ts` (`lines: 85`, `branches: 75`). The file has no entry today. | +4 |

Module-split rule: if `orchestrator-state-remediation.ts` or `_orchestrator_state_remediation_loop.py` measures above 450 lines after formatting, move the review-outcome checks (R8-R10) and the verdict helper into a sibling module (`orchestrator-state-remediation-accounting.ts` or `_orchestrator_state_remediation_accounting.py`) and record the split in the evidence. The research estimates do not require the split.

Not edited (line counts for the record): `scripts/dev_tools/validate_orchestrator_state.py` (492 pre-#464, about 433 after), `extensions/drm-copilot/src/lib/validate/orchestrator-state-core.ts` (467), `.claude/lib/orchestrator-state/OrchestratorStateUnconditional.psm1` (168), `.claude/lib/orchestrator-state/OrchestratorState.psm1` (499), `tests/scripts/dev_tools/test_validate_orchestrator_state_remediation_loop.py` (326), `tests/scripts/claude-lib/orchestrator-state/OrchestratorStateReceipts.Tests.ps1` (298), `extensions/drm-copilot/test/lib/validate/orchestrator-state-remediation.test.ts` (168).

Test registration: `tests/scripts/claude-lib/orchestrator-state/OrchestratorState.Manifest.Tests.ps1` (105 lines) adds the new module path to `$script:ExpectedPaths`.

Documents: see Documents Inventory.

New tests and fixtures: see Test Strategy.

#### Functions/classes/CLI commands impacted:
- Python (`_orchestrator_state_remediation_loop.py`): `_validate_remediation_loop` (restructured); `_validate_remediation_cycle` (unchanged); new `derive_review_verdict(remediabilities: Sequence[str]) -> ReviewVerdict` where `ReviewVerdict = Literal["PASS", "REMEDIATION_REQUIRED", "HALT_NON_REMEDIABLE", "AWAITING_CI"]`; new private helpers for review outcomes and accounting (names at executor discretion, prefixed `_validate_`). New constants: `REVIEW_OUTCOMES_KEY = "review_outcomes"`, `COMPLETED_ATTEMPTS_KEY = "completed_attempts"`, `CANDIDATE_APPLIED_KEY = "candidate_applied"`, `OPENED_BY_REVIEW_KEY = "opened_by_review"`, `REVIEW_VERDICTS` (tuple of the four verdicts in table order), `REMEDIABILITY_CLASSES` (tuple of the five classes in table order), `NON_REMEDIABLE_CLASSES` (frozenset of the four non-`autonomous` classes), `HALT_CLASSES` (frozenset of `external_dependency`, `policy_hold`, `human_decision_required`). No CLI flag change.
- TypeScript (`orchestrator-state-remediation.ts`): `validateRemediationLoop` (restructured); `validateRemediationCycle` (unchanged); new exported `deriveReviewVerdict(remediabilities: readonly string[]): ReviewVerdict`, `type ReviewVerdict`, and constants `REVIEW_OUTCOMES_KEY`, `COMPLETED_ATTEMPTS_KEY`, `CANDIDATE_APPLIED_KEY`, `OPENED_BY_REVIEW_KEY`, `REVIEW_VERDICTS`, `REMEDIABILITY_CLASSES`, `NON_REMEDIABLE_CLASSES`, `HALT_CLASSES` with the same members.
- PowerShell: `Get-OrchestratorStateRemediationLoopError` (restructured early return; calls the new entry point); `Get-RemediationCycleError` (unchanged). New module exports `Get-OrchestratorStateRemediationAccountingError` (entry point returning R5-R11 errors for a loop object) and keeps `Get-RemediationReviewVerdict` private; script-scoped arrays `$script:REVIEW_VERDICTS`, `$script:REMEDIABILITY_CLASSES`, `$script:NON_REMEDIABLE_CLASSES`, `$script:HALT_CLASSES`. All comparisons are case-sensitive (`-ccontains`, `-cnotcontains`, `-ceq`), matching #523's correction.

#### Data flow and validation changes:

New checkpoint fields (all optional, additive, presence-gated, under `remediation_loop`):

| Path | Type | Meaning |
|---|---|---|
| `remediation_loop.review_outcomes` | list of objects | One entry per review, appended in order. |
| `remediation_loop.review_outcomes[].verdict` | string, one of the four verdicts | The review verdict. |
| `remediation_loop.review_outcomes[].findings` | list of objects | The review's blocking findings only (empty for `PASS`). |
| `remediation_loop.review_outcomes[].findings[].remediability` | string, one of the five classes | Required on every finding object in the checkpoint (the `autonomous` default applies only to `remediation-inputs` text). Other finding keys are permitted and not validated. |
| `remediation_loop.review_outcomes[].inputs_path` | string | Optional; path of the `remediation-inputs` file. Not validated. |
| `remediation_loop.cycles[].candidate_applied` | boolean | True only for a completed attempt. |
| `remediation_loop.cycles[].opened_by_review` | integer | Zero-based index into `review_outcomes`. |
| `remediation_loop.completed_attempts` | non-negative integer | Must equal the number of cycles with `candidate_applied: true`. |

Validator invariants (Python authoritative; mirrored exactly). Indices `{i}`, `{j}`, `{m}` are zero-based. `{v}` renders the value as the existing human-interaction message does (Python f-string `{value}`, TypeScript `pythonRepr`, PowerShell `ConvertTo-PythonDisplayText`). "Integer" means a JSON integer that is not a boolean.

| ID | Rule | Literal message (identical in all three runtimes) |
|---|---|---|
| R5 | `candidate_applied`, when present on an object cycle, is a boolean. | `Checkpoint remediation cycle #{i} candidate_applied must be a boolean.` |
| R6 | `candidate_applied: true` requires `execution_status == "complete"`. | `Checkpoint remediation cycle #{i} candidate_applied is true but execution_status is not 'complete'.` |
| R7a | `completed_attempts`, when present, is a non-negative integer. | `Checkpoint remediation_loop completed_attempts must be a non-negative integer.` |
| R7b | A valid `completed_attempts` equals `k`, the number of object cycles whose `candidate_applied` is `true` (`k = 0` when `cycles` is absent or not a list). | `Checkpoint remediation_loop completed_attempts is {n} but {k} cycles have candidate_applied true.` |
| R8a | `review_outcomes`, when present, is a list. | `Checkpoint remediation_loop review_outcomes must be a list.` |
| R8b | Each outcome is an object. | `Checkpoint remediation review outcome #{j} must be an object.` |
| R9a | Each outcome's `verdict` is a string in `REVIEW_VERDICTS`. | `Checkpoint remediation review outcome #{j} verdict must be one of PASS, REMEDIATION_REQUIRED, HALT_NON_REMEDIABLE, AWAITING_CI; got: {v}` |
| R9b | Each outcome's `findings` is a list (a missing key is not a list). | `Checkpoint remediation review outcome #{j} findings must be a list.` |
| R9c | Each finding is an object. | `Checkpoint remediation review outcome #{j} finding #{m} must be an object.` |
| R9d | Each finding's `remediability` is a string in `REMEDIABILITY_CLASSES` (string check before set membership). | `Checkpoint remediation review outcome #{j} finding #{m} remediability must be one of autonomous, external_dependency, policy_hold, awaiting_ci, human_decision_required; got: {v}` |
| R10 | When R9a-R9d produced no error for the outcome, its verdict equals `derive_review_verdict` over its findings' classes. | `Checkpoint remediation review outcome #{j} verdict {v} does not match its findings (expected {e}).` |
| R11 | `opened_by_review`, when present on an object cycle, is an integer that indexes an object entry of a list `review_outcomes` whose `verdict` is `REMEDIATION_REQUIRED`. | `Checkpoint remediation cycle #{i} opened_by_review must reference a review outcome whose verdict is REMEDIATION_REQUIRED.` |

R11 encodes issue AC-2 structurally: no cycle can be attributed to a halt or wait review. Every new message contains the substring `remediation`, which corpus readers use to filter the family.

Error order (identical in all runtimes):
1. Existing per-cycle errors, unchanged, when `cycles` is a list.
2. Review-outcome errors: R8a; otherwise, for each outcome `j` in order: R8b (and skip the outcome), R9a, R9b, then for each finding `m` in order R9c or R9d, then R10.
3. For each object cycle `i` in order: R5, R6, R11.
4. R7a, otherwise R7b.

Structural change common to all runtimes: `_validate_remediation_loop` (Python), `validateRemediationLoop` (TypeScript), and `Get-OrchestratorStateRemediationLoopError` (PowerShell) currently return early when `cycles` is not a list. They keep the per-cycle loop under that condition and then call the new checks with the cycle list or `None`/`null`/`$null`. With no new keys present, the new checks return nothing.

#### Error handling and logging updates:
- New validator messages only as listed above. No change to existing messages.
- `derive_review_verdict` / `deriveReviewVerdict` / `Get-RemediationReviewVerdict` raise `ValueError` / throw `RangeError` / throw a terminating error for an input member outside `REMEDIABILITY_CLASSES`, with a message beginning `invalid remediability: `. The validators call them only after R9d passes.
- No logging changes.

#### Rollback/feature-flag considerations (if applicable):
No feature flag. Rollback is a revert of the change set. After a revert, checkpoints carrying the new keys validate with no remediation-family error for those keys (the reverted validators ignore unknown keys inside `remediation_loop`), so a revert does not invalidate recorded checkpoints.

### Technical specifications (interfaces/contracts):

#### Inputs/outputs and formats:
- `remediation-inputs.<timestamp>.md` (flat form in the feature folder; the reviewer writes it for every review with at least one blocking finding, including halt and wait verdicts):
  - One line `Review-Verdict: <VERDICT>`.
  - Inside each blocking finding block: one line `Remediability: <class>` and one line `Remediability-Evidence: <text>`.
  - Compatibility constraint: none of these lines may contain the substring `BLOCKING` or `Severity: Blocking`, including within the evidence text, so the blocking-line count used by `.claude/skills/orchestrate/SKILL.md` `## Post-Review Outcome Evaluation` is unchanged by their presence.
- Codex review final report: `REVIEW_STATUS: <VERDICT>` with the four values; `REMEDIATION_PLAN: NONE` for `HALT_NON_REMEDIABLE` and `AWAITING_CI`.
- Claude review final report (`.claude/agents/feature-review.md`): optional token `review-status: <VERDICT>` beside the existing path tokens; the orchestrator treats `remediation-inputs` as authoritative and the token as a cross-check. The token scanner in `.claude/hooks/validate-feature-review-coverage.ps1` ignores unknown tokens (research section 7), so no hook edit is needed.
- `code-review`, `feature-audit`, `policy-audit` artifacts: no required change. The `feature-audit` readiness line keeps `PASS`, `NEEDS REVISION`, `BLOCKED`; new verdict values are not written on it.
- Checkpoint fields: see Data flow and validation changes.
- Parity corpus case file `tests/fixtures/orchestrator_state_remediation_loop/<name>.json`: `{name, notes, checkpoint, expected_errors}` where `name` equals the file stem and `expected_errors` is the ordered list of plain-validation errors containing `remediation`. Non-string values in the corpus are limited to integers, `null`, booleans in `candidate_applied` only, and key absence; floats and booleans in other positions are excluded (rendering divergence; research section 5.2). `blocking_count: false` is excluded (pre-existing TypeScript divergence; research section 5.1).
- Back-compat corpus: `tests/fixtures/orchestrator_state_remediation_loop_backcompat/<name>.json` (checkpoints) and `tests/fixtures/orchestrator_state_remediation_loop_backcompat_expected.json` (`{<name>: {<runtime>: {<mode>: [full, unfiltered error list]}}}`), captured from the unmodified validators before any production edit.

#### Required configuration keys and defaults:
None. All new checkpoint fields are optional. A `remediation-inputs` finding block without a `Remediability:` line defaults to `autonomous`.

#### Backward-compatibility expectations:
- A checkpoint without `review_outcomes`, `completed_attempts`, `candidate_applied`, and `opened_by_review` produces the same full error list, byte for byte, in every mode each runtime supports: plain, `require_complete`, PR-creation readiness (Python and PowerShell), and `require_model_routing`. None of those modes reads the new keys, and the remediation family appends nothing for them.
- A `remediation-inputs` file without `Review-Verdict:` is evaluated exactly as today. The review-artifact validators are not edited, so review artifacts validate byte-identically.
- How this is tested: the back-compat corpus is captured from the unmodified validators first and replayed after the change by one reader per runtime (Test Strategy); the existing remediation, review-artifact, and orchestrator-state suites run unchanged and stay green; `git diff --name-only` shows no edit to the review-artifact validators or the excluded core modules.
- Forward compatibility: older published TypeScript validators ignore unknown keys inside `remediation_loop` and accept the new fields without enforcing them. They reject #523's new `blocked_reason` members until a release containing #523 is published (see Out-of-Scope Follow-up).

#### Performance constraints (latency/throughput/memory):
None. The checks are linear in the number of cycles, outcomes, and findings.

## Documents Inventory

Mirror parity tests (research section 6):
- M-C: every `.claude/**` file except `settings.local.json` and `agent-memory/**` equals its copy under `extensions/drm-copilot/resources/claude-customizations/.claude/` (`tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py`); orchestrator-state modules also by `OrchestratorState.Manifest.Tests.ps1`.
- M-A: every `.agents/**` and `.codex/**` file equals its copy under `extensions/drm-copilot/resources/codex-and-agents-customizations/` (`tests/scripts/dev_tools/test_push_down_codex_and_agents_resource_contracts.py`); `orchestrator-workflow` also by `tests/scripts/dev_tools/test_orchestration_guardrail_contracts.py`.
- Fragment guards (existing sentences must remain; additions permitted): `tests/scripts/dev_tools/test_codex_handoff_contract_parity.py` (`.agents/skills/feature-review/SKILL.md` hand-off sentences), `tests/scripts/dev_tools/test_codex_agent_wrapper_contracts.py` (`.codex/agents/feature-reviewer.toml`), `tests/scripts/dev_tools/test_orchestration_guardrail_contracts.py` (``blocked_reason` MUST be one of:``).
- Generated Codex variants: `.codex/agents/feature-reviewer.toml` is the source for `feature-reviewer-{c1,c2,c3,c3-elevated,c4}.toml` (`scripts/dev_tools/generate_codex_agent_variants.py`), checked in CI (`.github/workflows/_quality-checks.yml`) and by `tests/scripts/dev_tools/test_generate_codex_agent_variants.py`. The variants are regenerated with the generator, not edited by hand (twelve files including bundle copies).
- Skill bundle contract (#762): no `python -m scripts.dev_tools...` or `scripts/...` invocation form is added to any `.claude/skills/*/SKILL.md` (`tests/scripts/dev_tools/test_skill_bundle_contract_repo.py`).

`.agents/skills/` (primary verdict surface):

| File | Change | Mirror |
|---|---|---|
| `.agents/skills/feature-review/SKILL.md` | Four verdicts; `Remediability` contract; "remediation is required" only when at least one blocking finding is `autonomous`; `REMEDIATION_PLAN: NONE` and no planner hand-off for halt and wait. Guarded hand-off sentences remain. | M-A |
| `.agents/skills/feature-review-workflow/SKILL.md` | Classification step before the remediation trigger; new `REVIEW_STATUS` values. | M-A |
| `.agents/skills/orchestrate/SKILL.md` | Four-way outcome evaluation; `completed_attempts` rule and guard; PR gate unchanged (requires `PASS`). Hunks not adjacent to #523's inserted bullet. | M-A |
| `.agents/skills/orchestrator-workflow/SKILL.md` | Verdict list; redefine `remediation-pass`; add the three-attempt cap; record `candidate_applied`; halt and wait branches. The `no_staged_changes` sentence is left as is and a separate sentence adds the `candidate_applied: false` recording. #523's enum block and #509's `issue_adoption` text are not touched. | M-A + guardrail test |
| `.agents/skills/orchestrator-state/SKILL.md` | Same text as the rules-document edit (see Policy-Document Edit). | M-A |
| `.agents/skills/remediation-handoff-atomic-planner/SKILL.md` | Trigger only on `autonomous` blocking findings. | M-A |
| `.agents/skills/epic-orchestrate/SKILL.md` | "three completed attempts" for the shared count. | M-A |

Codex agent:

| File | Change | Mirror |
|---|---|---|
| `.codex/agents/feature-reviewer.toml` | One added sentence exempting non-remediable blockers from the planner hand-off and naming the new verdicts; regenerate the five variants. | M-A + generator check |

`.claude/` surface:

| File | Change | Mirror |
|---|---|---|
| `.claude/skills/orchestrate/SKILL.md` | `## Post-Review Outcome Evaluation`: four-way evaluation; `## Remediation Loop (R1–R5)`: accounting rule and guard; S9 timeout as `awaiting_ci`; CI-failure sharing via `completed_attempts`. | M-C |
| `.claude/agents/orchestrator.md` | Document `review_outcomes`, `completed_attempts`, `candidate_applied`, `opened_by_review`; malformed-cycle rules R5-R11; `cycle_N` numbering rule; exit gate counts only `autonomous` blockers. | M-C |
| `.claude/agents/feature-review.md` | `Review-Verdict:`, `Remediability:`, `Remediability-Evidence:` lines in `remediation-inputs`; optional `review-status:` token. | M-C |
| `.claude/skills/feature-review-workflow/SKILL.md` | `modified-workflow-needs-green-run` findings are `awaiting_ci`; classification before the trigger. | M-C |
| `.claude/skills/remediation-handoff-atomic-planner/SKILL.md` | Trigger on `autonomous` only; exit gate; `candidate_applied` recording. | M-C |
| `.claude/skills/epic-orchestrate/SKILL.md` | Shared count is `completed_attempts`. | M-C |
| `.claude/skills/parallel-orchestrate/SKILL.md` | Shared count is `completed_attempts`. The existing statement that that earlier feature did not modify `.claude/skills/orchestrate/SKILL.md` remains. | M-C |
| `.claude/rules/orchestrator-state.md` | See Policy-Document Edit. | M-C |

## Policy-Document Edit: `.claude/rules/orchestrator-state.md`

Why the edit is unavoidable:
- `.claude/rules/orchestrator-state.md` is the documented contract for checkpoint invariants. Its introduction states that it "documents three invariants that must hold for each remediation cycle", and `extensions/drm-copilot/src/lib/validate/orchestrator-state-remediation.ts` (header comment) names that section as its source. After #484 the validators enforce R5-R11 in addition to the three invariants. Without the edit, the documented contract and the enforced contract diverge, and the `.agents` copy (`.agents/skills/orchestrator-state/SKILL.md`) diverges in the same way.
- Its `## Scope and Backward Compatibility` section states that the invariants apply "only when the checkpoint contains a top-level `remediation_loop` with a `cycles` array". The review-outcome invariants also apply to a loop with `review_outcomes` and no `cycles` (a halt at the first review), so that sentence becomes inaccurate.
- The edit is needed for documentation accuracy; enforcement does not depend on it. `.claude/rules/orchestrator-state.md` is not a mirror of a `.github/instructions/` file, and no `.github/instructions/` file is edited.

Minimal text change:
1. Introduction: replace "three invariants that must hold for each remediation cycle" with "the invariants that must hold for each remediation cycle and for the remediation-loop review outcomes and attempt count".
2. `## Scope and Backward Compatibility`: replace "with a `cycles` array" with "; the per-cycle invariants apply when it has a `cycles` array, and the review-outcome and attempt-count invariants apply when their keys are present". The remaining sentences are unchanged.
3. `## Invariants (per remediation cycle)`: append items 4-7 for R5, R6, R11, and R7 (one sentence each, same style as items 1-3).
4. New section `## Invariants (remediation_loop.review_outcomes)` directly after `## Invariants (per remediation cycle)` and before `## Human-Interaction Scope and Backward Compatibility`: the four verdicts, the five classes and their mapping to #523's `blocked_reason` members, the derivation order, and R8-R10.

Not edited: `## Enforcement` (edited by #509), `## Blocked-Reason Vocabulary` (added by #523), and #464's `## Bare-Module CLI Contract`. The #484 hunks sit above #523's anchor and are not adjacent to #464's or #509's hunks.

Mirrors (same commit, byte-identical): `extensions/drm-copilot/resources/claude-customizations/.claude/rules/orchestrator-state.md` (M-C); `.agents/skills/orchestrator-state/SKILL.md` receives the same text changes in its corresponding sections, and its bundle `extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/orchestrator-state/SKILL.md` is byte-identical to it (M-A).

The orchestrator records a decision authorizing the edit in the checkpoint (as #523 recorded OD-523-2), identifier `OD-484-1`.

## Promotion Note

Issue #484 pre-existed on GitHub. `potential_to_issue` was not called for it, and no receipt was fabricated. Following the epic's shared design, the orchestrator records the substitution under `human_interaction.requirements[]` in the checkpoint, citing #509 as the defect that otherwise makes the receipt unavoidable. #509 introduces the optional top-level `issue_adoption` checkpoint object; once #509 has merged into `epic/orchestrator-state-contract-correctness-integration`, execution-time checkpoints for #484 should record the pre-existing issue with `issue_adoption` instead of the `human_interaction` substitution.

## Assumptions, Constraints, Dependencies
- Assumptions (environment, data, access):
  - #464, #509, and #523 have merged into the integration branch before execution; the executor confirms the modules named under Dependencies exist.
  - Research line numbers and counts were not measured with a shell; the executor re-measures every file named in this spec before and after editing.
- Constraints (budget, performance, compatibility):
  - No edit to issue #769 files (`.claude/hooks/enforce-powershell-batch-budget.ps1` and related files and tests). Batch-budget hook state may be reset only at the reset points the approved plan schedules, by deleting the per-session `.claude/state/<kind>-batch-budget.*.json` state file with evidence recorded (orchestrator decision OD-484-2); the hook files themselves are not modified. At most three test files per delegation batch.
  - No file under `.claude/hooks/` or `.codex/hooks/` is edited, and no enforcement hook gains a Python leg.
  - No production or test file exceeds 500 lines. Current and estimated counts are in Files/modules to change; `OrchestratorStateReceipts.psm1` (410) stays below the cap by placing the new checks in `OrchestratorStateRemediationAccounting.psm1`; `OrchestratorState.psm1` (499) and `orchestrator-state-core.ts` (467) are not edited; existing remediation test files are not extended. `extensions/drm-copilot/test/lib/validate/orchestration-artifacts.test.ts` (pre-existing overage) is not modified.
  - Tests create no temporary files. Corpus files are committed and read in place; Pester unit tests use in-memory JSON (`ConvertFrom-Json -NoEnumerate`).
  - Python coverage commands use the dotted form with `--cov-report=term-missing` (for example `--cov=scripts.dev_tools._orchestrator_state_remediation_loop`). A `--cov=<path>.py` form measures nothing.
  - Line coverage >= 85% and branch coverage >= 75% where the tooling measures branch coverage (Pester measures line coverage only).
  - No edit under `.github/instructions/`.
  - `hypothesis` and `fast-check` are not dependencies; `derive_review_verdict` is covered exhaustively over the 32 subsets of the five classes instead of by property tests.
- External dependencies (services, libraries, releases):
  - None for this change. Codex producers cannot validate #523's members through the pinned MCP until a release containing #523 is published; that release is outside #484 (see Out-of-Scope Follow-up).

## Data / API / Config Impact
- User-facing or API changes:
  - Review verdict vocabulary gains `HALT_NON_REMEDIABLE` and `AWAITING_CI`; findings gain a `Remediability` class.
  - Checkpoint `remediation_loop` gains four optional fields; validators gain R5-R11.
  - New exported constants and verdict helpers in Python and TypeScript; a new PowerShell module exporting `Get-OrchestratorStateRemediationAccountingError`.
- Data or migration considerations:
  - None. Existing checkpoints are unaffected. Codex `remediation-pass` remains a persisted key with a redefined meaning.
- Logging/telemetry updates (if any):
  - None.
- Compatibility notes (CLI flags, config schemas, versioning):
  - No CLI flag, MCP tool schema, or schema-version change. The contract change is additive.

## Test Strategy
Seeded from issue:

- [ ] Unit coverage areas: verdict-class validation and cycle-accounting invariants in all three validator runtimes, with shared parity fixtures.
- [ ] Integration scenario to retest: a checkpoint recording a non-remediable halt validates without a remediation cycle entry.
- [ ] Manual verification notes: none.

Order: capture back-compat outputs against the unmodified validators first; then add failing tests for R5-R11; then implement Python, TypeScript, and PowerShell in that order.

- Regression tests to add or update:
  - Existing suites run unchanged before and after and stay green: `tests/scripts/dev_tools/test_validate_orchestrator_state_remediation_loop.py`, `tests/scripts/dev_tools/test_validate_orchestrator_state.py`, `tests/scripts/dev_tools/test_validate_orchestration_artifacts.py`; Jest `extensions/drm-copilot/test/lib/validate/orchestrator-state-remediation.test.ts`, `orchestrator-state-core.test.ts`, `review-artifacts.test.ts`; Pester `OrchestratorStateReceipts.Tests.ps1`, `OrchestratorStateUnconditional.Tests.ps1`, `OrchestratorState.Manifest.Tests.ps1`.
  - Back-compat readers (new), one per runtime, replaying `tests/fixtures/orchestrator_state_remediation_loop_backcompat/` against `..._backcompat_expected.json` with full, unfiltered error lists in every mode the runtime supports: `tests/scripts/dev_tools/test_validate_orchestrator_state_remediation_backcompat.py`, `extensions/drm-copilot/test/lib/validate/orchestrator-state-remediation-backcompat.test.ts`, `tests/scripts/claude-lib/orchestrator-state/OrchestratorStateRemediationLoop.Backcompat.Tests.ps1`. Required cases: no `remediation_loop`; non-object `remediation_loop`; a valid legacy cycle; each of the three existing violations; `cycles` as a string and as an object; a non-object cycle; a legacy `current_cycle` value; a checkpoint with a Codex `remediation-pass` key. The expected file is written from the unmodified validators and committed before any production edit; the before and after run outputs are recorded under `docs/features/active/2026-09-29-orchestrator-remediation-loop-control-484/evidence/regression-testing/`.
- Unit tests for the fixed behavior and boundaries:
  - Python `tests/scripts/dev_tools/test_orchestrator_state_remediation_accounting.py`: `derive_review_verdict` over all 32 subsets of `REMEDIABILITY_CLASSES` (with duplicates for at least the mixed cases) and the `ValueError` for a non-member; each R5-R11 violation and its passing counterpart; halt at first review (`review_outcomes` present, no `cycles`); a `candidate_applied: false` cycle not counted; mismatched `completed_attempts`; `completed_attempts` present with no `cycles`; each precedence-relevant verdict case; case variants of every verdict and class literal rejected; `opened_by_review` out of range, negative, boolean, and pointing at `HALT_NON_REMEDIABLE` and `AWAITING_CI` outcomes; drift guard `NON_REMEDIABLE_CLASSES <= NON_MECHANICAL_BLOCKED_REASONS` importing #523's constant; integration test `test_halt_checkpoint_without_cycles_validates_clean` asserting that `validate_orchestrator_state_text` returns an empty list for a checkpoint with a `HALT_NON_REMEDIABLE` outcome, no `cycles`, and `blocked_reason: "external_dependency"`.
  - Jest `extensions/drm-copilot/test/lib/validate/orchestrator-state-remediation-accounting.test.ts`: the same cases through `deriveReviewVerdict` and `validateOrchestratorStateText`, including the drift guard against `NON_MECHANICAL_BLOCKED_REASONS` from `orchestrator-state-blocked-reason.ts` and the halt-without-cycles integration case.
  - Pester `tests/scripts/claude-lib/orchestrator-state/OrchestratorStateRemediationAccounting.Tests.ps1`: the same cases through `Get-OrchestratorStateRemediationAccountingError` and, via `InModuleScope`, `Get-RemediationReviewVerdict`; the drift guard reads `$script:NON_MECHANICAL_BLOCKED_REASONS` from `OrchestratorState.psm1` via `InModuleScope`; case-variant rejection proves case-sensitive comparison.
  - Documentation drift tests `tests/scripts/dev_tools/test_orchestrator_state_remediation_docs.py` (functions prefixed `test_docs_`, files read in place): every verdict and class literal appears in `.agents/skills/feature-review/SKILL.md`, `.claude/agents/orchestrator.md`, and the rules-document `## Invariants (remediation_loop.review_outcomes)` section; the `.claude/rules/orchestrator-state.md` introduction no longer contains "three invariants that must hold for each remediation cycle"; the literal line prefixes `Review-Verdict:`, `Remediability:`, and `Remediability-Evidence:` contain neither `BLOCKING` nor `Severity: Blocking`, and `.claude/agents/feature-review.md` states the evidence-text constraint.
- Parity corpus `tests/fixtures/orchestrator_state_remediation_loop/*.json`, with readers:
  - Python `tests/scripts/dev_tools/test_orchestrator_state_remediation_loop_parity.py` via `validate_orchestrator_state_text`.
  - Jest `extensions/drm-copilot/test/lib/validate/orchestrator-state-remediation-loop-parity.test.ts` via `validateOrchestratorStateText`.
  - Pester `tests/scripts/claude-lib/orchestrator-state/OrchestratorStateRemediationLoop.Parity.Tests.ps1` via `Get-OrchestratorStateUnconditionalError` on `ConvertFrom-Json` output, resolving the corpus relative to `$PSScriptRoot` as `BlastRadius.Parity.Tests.ps1` does.
  - Each reader filters errors to those containing `remediation`, compares ordered lists for equality, asserts `name` equals the file stem, and asserts a minimum case count so an empty or unreadable directory fails.
  - Required cases: every R5-R11 message at least once; each verdict valid; halt at first review with no `cycles`; `HALT_NON_REMEDIABLE` outcome with `blocked_reason: "none"` and no `human_interaction` (no remediation-family error; no cross-field rule); `AWAITING_CI` outcome; mixed `autonomous` plus `human_decision_required` findings yielding `REMEDIATION_REQUIRED`; `candidate_applied: false` not counted; case variants `Pass`, `halt_non_remediable`, `Autonomous`, `AWAITING_CI` as a class rejected; integer and `null` verdict and remediability values; combined legacy and new errors showing the order rule.
- Edge cases and negative scenarios: missing `findings`; empty `findings` with a non-`PASS` verdict; non-object findings; `completed_attempts` negative, boolean, and string; `opened_by_review` when `review_outcomes` is absent or not a list.
- Error handling and logging verification: helper exception types and the `invalid remediability: ` prefix; unchanged existing messages.
- Coverage impact and targets for changed lines/modules:
  - Python: `poetry run pytest tests/scripts/dev_tools/test_orchestrator_state_remediation_accounting.py tests/scripts/dev_tools/test_orchestrator_state_remediation_loop_parity.py tests/scripts/dev_tools/test_validate_orchestrator_state_remediation_backcompat.py tests/scripts/dev_tools/test_validate_orchestrator_state_remediation_loop.py --cov=scripts.dev_tools._orchestrator_state_remediation_loop --cov-branch --cov-report=term-missing` (add `--cov=scripts.dev_tools._orchestrator_state_remediation_accounting` if the split rule applies).
  - Jest: new per-file threshold for `orchestrator-state-remediation.ts` (85 lines, 75 branches). Confirm before relying on the threshold that the pre-change code in that file meets it, because the entry newly gates existing code.
  - Pester: line coverage >= 85% for `OrchestratorStateRemediationAccounting.psm1` and `OrchestratorStateReceipts.psm1`, with no reduction on changed lines; the new module is added to both run-settings files before measuring.
  - Coverage outputs recorded under `docs/features/active/2026-09-29-orchestrator-remediation-loop-control-484/evidence/qa-gates/`.
- Toolchain commands to run (format → lint → type-check → test):
  - The seven-stage loop per `.claude/rules/general-code-change.md` for each language touched (Python: Black, Ruff, Pyright, pytest; TypeScript: Prettier, ESLint, TSC, dependency-cruiser, Jest; PowerShell: Invoke-Formatter, PSScriptAnalyzer, Pester), restarting on any failure or auto-fix. Also run `tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py`, `tests/scripts/dev_tools/test_push_down_codex_and_agents_resource_contracts.py`, `tests/scripts/dev_tools/test_orchestration_guardrail_contracts.py`, `tests/scripts/dev_tools/test_codex_handoff_contract_parity.py`, `tests/scripts/dev_tools/test_codex_agent_wrapper_contracts.py`, `tests/scripts/dev_tools/test_generate_codex_agent_variants.py`, `tests/scripts/dev_tools/test_skill_bundle_contract_repo.py`, the Codex variant generator in check mode, and `OrchestratorState.Manifest.Tests.ps1`.
- Manual validation steps (if required):
  - Measure and record line counts for every production and test file created or edited, after formatting.

## Acceptance Criteria

- [x] AC-1: The review verdict classifies every blocking finding as `autonomous` or as one of `external_dependency`, `policy_hold`, `awaiting_ci`, `human_decision_required`: the verdict and class literals in this spec's tables are defined as `REVIEW_VERDICTS` and `REMEDIABILITY_CLASSES` in `scripts/dev_tools/_orchestrator_state_remediation_loop.py`, `extensions/drm-copilot/src/lib/validate/orchestrator-state-remediation.ts`, and `.claude/lib/orchestrator-state/OrchestratorStateRemediationAccounting.psm1`; R9 rejects any other value (proven by the three unit test files); and `tests/scripts/dev_tools/test_orchestrator_state_remediation_docs.py` proves every literal appears in `.agents/skills/feature-review/SKILL.md`, `.claude/agents/orchestrator.md`, and the rules document.
- [ ] AC-2: A review whose blocking findings are all non-remediable halts or waits without a remediation plan or cycle: the `.agents` and `.claude` orchestrate and feature-review documents define the halt and wait branches (no plan, no cycle, `REMEDIATION_PLAN: NONE` for Codex); R11 rejects a cycle whose `opened_by_review` references a `HALT_NON_REMEDIABLE` or `AWAITING_CI` outcome; and the corpus case for a halt at the first review with no `cycles` validates with no remediation-family error in all three parity readers.
- [ ] AC-3: Cycle accounting counts completed attempts only: R5, R6, and R7 are enforced; a `candidate_applied: false` cycle is not counted and a mismatched `completed_attempts` is rejected (corpus cases pass in all three readers); and the orchestrate, epic-orchestrate, parallel-orchestrate, and orchestrator-workflow documents state the `completed_attempts + 1` numbering rule, the three-completed-attempts guard, and that `remediation_pass` / `remediation-pass` equal `completed_attempts`.
- [ ] AC-4: The Python, PowerShell, and TypeScript validators enforce R5-R11 identically: `tests/scripts/dev_tools/test_orchestrator_state_remediation_loop_parity.py`, `extensions/drm-copilot/test/lib/validate/orchestrator-state-remediation-loop-parity.test.ts`, and `tests/scripts/claude-lib/orchestrator-state/OrchestratorStateRemediationLoop.Parity.Tests.ps1` pass over `tests/fixtures/orchestrator_state_remediation_loop/*.json`, read in place, with the name-equals-stem and minimum-count guards, and the corpus contains every literal message listed in this spec's R5-R11 table.
- [ ] AC-5: Checkpoints and review artifacts that do not use the new fields validate byte-identically: the back-compat expected file captured before any production edit is matched after the change by `tests/scripts/dev_tools/test_validate_orchestrator_state_remediation_backcompat.py`, `extensions/drm-copilot/test/lib/validate/orchestrator-state-remediation-backcompat.test.ts`, and `tests/scripts/claude-lib/orchestrator-state/OrchestratorStateRemediationLoop.Backcompat.Tests.ps1` in every mode each runtime supports; before and after outputs are recorded under `evidence/regression-testing/`; the existing suites listed in Test Strategy pass unchanged; and `git diff --name-only` shows no change to `scripts/dev_tools/validate_orchestration_review_artifacts.py` or `extensions/drm-copilot/src/lib/validate/review-artifacts.ts`.
- [ ] AC-6: Runtime capability or version incompatibility is recorded as a scoped follow-up: this spec's `## Out-of-Scope Follow-up: Published-MCP Contract Lag` section contains a title, summary, scope, and rationale, and the documents classify a detected mismatch as `external_dependency`.
- [x] AC-7: `derive_review_verdict`, `deriveReviewVerdict`, and `Get-RemediationReviewVerdict` return the verdict defined by the derivation order for every subset of `REMEDIABILITY_CLASSES` and raise or throw with the prefix `invalid remediability: ` for a non-member, proven by the three unit test files.
- [ ] AC-8: `NON_REMEDIABLE_CLASSES` is asserted to be a subset of #523's `NON_MECHANICAL_BLOCKED_REASONS` in the Python, Jest, and Pester unit tests, and no #523 file (`_orchestrator_state_blocked_reason.py`, `orchestrator-state-blocked-reason.ts`, `OrchestratorState.psm1` and its bundle copy, the partition oracle, or the `blocked_reason` corpus) is modified.
- [ ] AC-9: `.claude/lib/orchestrator-state/OrchestratorStateRemediationAccounting.psm1` exists with a byte-identical bundle copy committed in the same commit; it is registered in `pack-manifests/core.json`, in `$script:ExpectedPaths` of `OrchestratorState.Manifest.Tests.ps1`, and in `CodeCoverage.Path` of both `pester.runsettings.psd1` files; `OrchestratorStateReceipts.psm1` and its bundle copy import it; `OrchestratorState.Manifest.Tests.ps1` passes.
- [ ] AC-10: The halt and wait producer rules are documented in `.claude/skills/orchestrate/SKILL.md` and `.agents/skills/orchestrate/SKILL.md`: `blocked_reason` precedence `human_decision_required` > `policy_hold` > `external_dependency`; `awaiting_ci` for a wait; one `human_interaction.requirements[]` entry with `response: "halt"` per halt class present and none for `AWAITING_CI`; S9 poll timeout classified `awaiting_ci`; and the corpus case with a `HALT_NON_REMEDIABLE` outcome, `blocked_reason: "none"`, and no `human_interaction` passes in all three readers, proving no cross-field rule.
- [ ] AC-11: `.claude/rules/orchestrator-state.md` and its bundle copy contain exactly the minimal changes listed under Policy-Document Edit, `.agents/skills/orchestrator-state/SKILL.md` and its bundle copy carry the same text, `## Enforcement` and `## Blocked-Reason Vocabulary` are not changed (verified by diff), `OD-484-1` is recorded in the checkpoint, and no file under `.github/instructions/` is modified.
- [ ] AC-12: Every document in the Documents Inventory is edited with its mirror in the same commit; the generated `feature-reviewer-*.toml` variants and their bundle copies are regenerated by `scripts/dev_tools/generate_codex_agent_variants.py`; and the mirror, fragment-guard, generator, and skill-bundle suites listed under Toolchain commands pass.
- [x] AC-13: The `Review-Verdict:`, `Remediability:`, and `Remediability-Evidence:` line formats and the evidence-text constraint are documented in `.claude/agents/feature-review.md` and `.agents/skills/feature-review/SKILL.md`, and `test_orchestrator_state_remediation_docs.py` proves the prefixes contain neither `BLOCKING` nor `Severity: Blocking`.
- [ ] AC-14: `extensions/drm-copilot/jest.config.cjs` has a per-file `coverageThreshold` entry for `./src/lib/validate/orchestrator-state-remediation.ts` (`lines: 85`, `branches: 75`) and Jest passes with it.
- [ ] AC-15: Measured line counts, recorded in the evidence, show every created or edited production and test file at or below 500 lines, and `validate_orchestrator_state.py`, `orchestrator-state-core.ts`, `OrchestratorStateUnconditional.psm1`, `OrchestratorState.psm1`, and the three existing remediation test files are not modified.
- [ ] AC-16: Line coverage >= 85% and branch coverage >= 75% for `scripts.dev_tools._orchestrator_state_remediation_loop` (dotted `--cov=` form with `--cov-report=term-missing`) and `orchestrator-state-remediation.ts`; line coverage >= 85% for `OrchestratorStateRemediationAccounting.psm1` and `OrchestratorStateReceipts.psm1`; no reduction on changed lines; outputs recorded under `evidence/qa-gates/`.
- [ ] AC-17: No file under `.claude/hooks/` or `.codex/hooks/` is modified, no enforcement hook gains a Python leg, no issue #769 file is modified, and no test creates a temporary file (verified by diff and by review of the new test files).
- [ ] AC-18: The checkpoint records the `potential_to_issue` substitution for pre-existing issue #484 under `human_interaction.requirements[]` citing #509, or, if #509 has merged into the integration branch before execution, records it with the `issue_adoption` object; no `potential_to_issue` receipt is fabricated.
- [ ] AC-19: The follow-ups listed under Rollout & Follow-up are recorded as potential entries or orchestration follow-ups, including the AC-6 write-up.
- [ ] AC-20: Full toolchain pass completed (format → lint → type-check → architecture → test → contract → integration) for Python, TypeScript, and PowerShell with no failing stage in a single pass.

## Risks & Mitigations
- Technical or operational risks:
  - #484 edits documents after #509 and #523 have edited them (`.agents/skills/orchestrator-workflow/SKILL.md`, both orchestrate skills, the rules document).
  - One sentence in `feature-reviewer.toml` changes twelve generated files.
  - The new Jest threshold gates pre-existing code in `orchestrator-state-remediation.ts`.
  - Registration files (`core.json`, the manifest test, both run-settings files, `jest.config.cjs`) are also edited by #509 and #523.
  - Codex producers cannot validate #523's members through the pinned MCP until a release is published.
  - Research figures were not measured with a shell and predate #464, #509, and #523.
  - Producers may omit the new fields, in which case R11 and R7 do not apply; the presence gate is deliberate for back-compat.
- Mitigations and rollbacks:
  - Locate hunks by heading and content; keep hunks away from #509 and #523 anchors.
  - Run the generator; do not edit variants by hand.
  - Measure the pre-change coverage of `orchestrator-state-remediation.ts` before adding the threshold; add tests if it falls below 85/75.
  - Add separate list entries; resolve adjacent-line conflicts by keeping all entries.
  - Sequence the epic release before relying on Codex halts; see the follow-up.
  - Re-measure every figure during execution and record it in the evidence.
  - Document the new fields as required for producers in `.claude/agents/orchestrator.md` and `.agents/skills/orchestrator-workflow/SKILL.md`.
  - Rollback is a revert of the change set.

## Out-of-Scope Follow-up: Published-MCP Contract Lag

Issue AC-6 is recorded as a scoped follow-up for a potential entry.

- Title: Detect published-MCP contract lag before orchestration.
- Summary: The Codex MCP transport is pinned to the repository's package version (`.codex/config.toml`, equal to `packages/mcp-server/package.json` `version` by test), but the package published under that version can predate repository validator and routing changes. Orchestration then fails validation for reasons no repository remediation can fix (issue #467: a Codex agent family added after `@danmoisan/drm-copilot-mcp@1.0.24` was published). The server reports its version only in the MCP `serverInfo` handshake, and no check compares the published contract with the repository contract. Detect the lag at startup and halt with `blocked_reason: "external_dependency"`.
- Scope: (1) a deterministic contract fingerprint over `VALID_BLOCKED_REASONS`, `GENERATED_AGENT_FAMILIES`, the routing matrix, and the remediation-loop vocabularies (`REVIEW_VERDICTS`, `REMEDIABILITY_CLASSES`), computed identically by a Python helper and by the TypeScript server; (2) an MCP tool returning the fingerprint and package version, with `.codex/config.toml` `enabled_tools`, its bundle copy, and the `EXPECTED_DRM_COPILOT_TOOLS` test list updated; (3) an orchestrator S0 preflight in both orchestrate skills that compares the two and records a mismatch as an `external_dependency` halt with a `human_interaction` `halt` requirement naming the release action; (4) tests for fingerprint parity and mismatch handling. Non-goals: automatic publishing; changing the pin policy. Constraint: no enforcement hook gains a Python leg (the preflight is an orchestrator step, not a hook).
- Rationale: the detection is independent of the verdict and accounting contract; it adds an MCP tool surface that takes effect only after a publish, which is an irreversible release step outside #484; the research estimates it at C3 (about 6-9 production files and 4-6 test files across TypeScript, Python, and configuration), while #484 is already a C4 change across three runtimes and about sixteen documents. Within #484, a detected mismatch is classified `external_dependency`, so it halts instead of consuming remediation cycles.

## Rollout & Follow-up
- Release/rollout steps:
  - Merge to `epic/orchestrator-state-contract-correctness-integration` (epic #771). No version bump or publish step is specific to this fix. Codex producers that write #523's members require an MCP release containing #523 and #484 before the pinned validator accepts them.
- Post-fix monitoring or clean-up tasks (follow-ups, not part of #484):
  1. Detect published-MCP contract lag before orchestration (Out-of-Scope Follow-up above; issue AC-6).
  2. Reconcile the flat `remediation-inputs.<timestamp>.md` form with the `remediation/<entry-ts>/remediation-inputs.md` form prescribed by the remediation-handoff skills (research section 1.3).
  3. TypeScript `blocking_count: false` divergence from Python and PowerShell (research section 5.1).
  4. Apply the verdict and accounting contract to the Copilot `.github/` surface and its mirrors (research section 6).
  5. `no_staged_changes` in `.agents/skills/orchestrator-workflow/SKILL.md` is a validator-rejected literal on the no-candidate path; covered by #523 follow-up 1, which should account for the `candidate_applied` recording.
  6. Python `response not in HUMAN_INTERACTION_RESPONSE_ENUM` in `_orchestrator_state_human_interaction.py` likely raises `TypeError` for list or dict values (inference; not executed).
  7. TypeScript cannot distinguish JSON `2.0` from `2`, so integer checks (R7a, R11) accept a float-formatted integer that Python rejects; the corpus excludes floats. Record for the cross-runtime rendering follow-up.
- Links: issue #484; epic #771 (`docs/features/epics/orchestrator-state-contract-correctness/epic.md`); upstream #523 (spec and plan at `576b91c8`), #464 (`docs/features/active/2026-09-29-validate-orchestrator-state-cli-entry-point-464/plan.2026-09-29T14-20.md`), #509 (`docs/features/active/2026-08-22-promotion-gate-lacks-preexisting-issue-branch-509/plan.2026-09-29T15-26.md`); out-of-scope #769; research `research/2026-09-29T17-50-remediation-loop-verdict-research.md`.
