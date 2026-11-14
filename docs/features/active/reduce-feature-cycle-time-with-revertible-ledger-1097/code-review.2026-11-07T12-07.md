# Code Review: Ledger Back-fill, Smaller Plans, Policy-Read Removal, and Deferred Wording, Stage E (#1097)

**Review Date:** 2026-11-07
**Reviewer:** feature-review agent
**Feature Folder:** `docs/features/active/reduce-feature-cycle-time-with-revertible-ledger-1097`
**Base Branch:** `main` (merge base `bad886e304990d26af56d6bcabc9d543518492e9`, equal to `origin/main` after a fetch)
**Head Branch:** `feature/reduce-feature-cycle-time` @ `b71c1d0649373d6083ff70f501383ff79b8f343f`
**Review Type:** First review of PR E (stages A to D merged; stage D as PR #1104, merge commit `bad886e30`)

---

## Executive Summary

Stage E adds two reductions to the ledger and completes two earlier ones.

- **`0004`, smaller plans.** A `**Task target.**` bullet (15 to 20 tasks) in all six `atomic-plan-contract` copies. The `**Size guideline.**` bullet and the validator limit are unchanged; stage F owns G13.
- **`0005`, policy-read removal.** One `if` is removed from `Get-PlanStructureValidationReport` in `validate-planner-output.ps1`, so a Phase 0 with only a baseline task passes. The contract states that Phase 0 carries no routine policy-read task and that a plan keeping one stays valid. Every producer and Copilot consumer drops the requirement, except the review prompt held under the coordinator baseline hold.
- **`0002` and `0003`.** The deferred brief wording, the light-remediation wording, and the third `Remediation-Mode` value land, each with its entry updated in the same commit. Stage D review item N1 is fixed by a new `Get-CheckpointObjectOrdinalMember` used for every key read of invariant 8 and the invariant 2 exemption.
- **Standing rule.** All six contract copies state the ledger rule for planners, in a commit without a reduction token.

The reviewer verified the main claims by execution:

- One parallel run per suite at this head: Pester 15653 tests, pytest 16183, Jest 5343, all with 0 failures.
- New and updated revert blocks of each `reduction:` commit replay to the text at that commit's parent. A full replay of entry `0003` restores both changed modules to their pre-stage-D text. All 129 `Current` fences occur exactly once at this head.
- `git grep` finds no remaining policy-read producer or consumer except the held review prompt.
- No changed file outside the feature folder and the ledger has fewer occurrences of `baseline`, `coverage`, or `no pre-change run` than at the merge base.

One Blocking item, F1, is the held surface. It is classified `human_decision_required`. One Minor and one Nit follow; neither stops the merge.

**What changed well:**
The hook change removes exactly one condition and leaves the baseline condition, the missing-Phase-0 message, and the final QA phase rule untouched. The inverted hook test keeps the same input and now asserts acceptance, and a new test pins that a kept policy-read task is not an error, which covers the "older plans stay valid" condition. `ProcessReductionLedger.Replay.Tests.ps1` reverts the entry's hook blocks in memory, extracts the two needed functions with the PowerShell parser, runs them in a child script block, and asserts that no function remains defined, so reverted and live definitions never meet. The ordinal accessor leaves `Get-CheckpointObjectMember` unchanged, so no other key changes behavior.

**Top 3 risks:**
1. F1: until the owner decides, a Copilot review of a plan without the read task can report `phase0-instructions-read.md` absent, because `.github/prompts/review-feature.prompt.md` still expects it.
2. N1: one ordinal read in invariant 8 can regress to a case-insensitive read with no failing row.
3. The `Merge commit: pending (PR #1097)` stand-ins of `0004` and `0005` are replaced after PR creation, outside the feature folder, so CI must be re-read at that head.

**PR readiness recommendation:** **Not ready without an owner decision.** No code change is required by the reviewer. Either the owner decides the baseline question and the held bullet is removed in a `reduction: 0005` commit that updates entry `0005`, or the owner accepts PR E with the `[E]` policy-read criterion left PARTIAL for a later stage. CI run 42370409304 on this head was `in_progress` when this review was written.

---

## Findings Table

| Severity | File | Location | Finding | Recommendation | Rationale | Evidence |
|---|---|---|---|---|---|---|
| Blocking | `.github/prompts/review-feature.prompt.md` and `extensions/drm-copilot/resources/customizations/.github/prompts/review-feature.prompt.md` | Line 52 | F1. The bullet `` `phase0-instructions-read.md` exists in the canonical baseline location with the required metadata fields. `` remains, so the `[E]` criterion "The policy-read task, its artifact requirement, and the hook's policy-read check are removed in one commit with its entry" is PARTIAL. All other parts hold: the hook check, the contract requirement, and every other surface are removed in `110f124f8` with entry `0005`; a kept task stays valid; baseline strings are unchanged. | After the owner decides, remove the bullet from both copies in a commit with `reduction: 0005` in its subject that adds a revert block and a `## Files Changed` line to entry `0005`, add a `PCW-SURFACE` row for the prompt, then re-review. | The bullet contains `canonical baseline location`, and the coordinator baseline hold forbids changing baseline text until the owner decides. The change itself is small, but it cannot be made autonomously while the hold stands. Remediability class: `human_decision_required`. | `git grep` for `instructions-read` over `.claude`, `.agents`, `.github`, `.codex`, `docs/features/templates`, and `scripts` returns only this line; entry `0005` `## Reason and Evidence` and `## Files Changed` disclose it. |
| Minor | `.claude/lib/orchestrator-state/OrchestratorStateRemediationAccounting.psm1` | `Get-RemediationLightCycleError`, line 316 (also the reads at lines 330, 334, 339, and 363) | N1. The two new corpus rows pin the invariant 2 exemption read (`OrchestratorStateReceipts.psm1` line 270) and the finding-key read (line 352), but not the invariant 8 path read at line 316. A library copy with only that read reverted to `Get-CheckpointObjectMember` reproduces the expected errors of both key-case rows. On a probe checkpoint with `Remediation_Path: "light"` and a `design` finding, head PowerShell and Python each report only the invariant 2 error, and the reverted copy adds `finding #0 scope is not contained.` The reads of `preflight`, `opened_by_review`, `findings`, and the prior cycle's path are likewise unpinned for case variants. | Add a corpus row `light_path_key_case_variant_design_scope` (mis-cased path key, `design` finding, expected: the invariant 2 error only), and optionally one with a mis-cased path key on the prior cycle, in the same commit as any other `0003` change. | Head behavior is correct and agrees across runtimes; the gap is that a regression of this read would pass every gate. The orchestrator writes exact keys, so no truthful checkpoint is affected. Remediability class if pursued: `autonomous`. | Reviewer probe through `Get-OrchestratorStateUnconditionalError` (head library and reverted-read copy in the scratchpad) and `validate_orchestrator_state_text`. |
| Nit | `docs/features/active/reduce-feature-cycle-time-with-revertible-ledger-1097/plan.2026-11-07T06-17.md` | Commits `110f124f8` and `664b0dba8` | N2. The `reduction: 0005` commit also added the stage F draft plan, because its staging list came from porcelain status. `664b0dba8` removed it from the index without rewriting history. The reduction commit is therefore not limited to the reduction, though the extra path is a feature-folder document that a revert does not need. | None. Build staging lists from the planned file list rather than from porcelain status. | Revertibility is unaffected, because entry `0005` names every reduction path and the replay of its 43 blocks matches the parent text. Remediability class: none; record only. | `git show --name-only 110f124f8`; `evidence/qa-gates/self-review.2026-11-07T11-55.md`, order rows. |

No covered file reaches the 700-line advisory tier, so no `Warning` row applies; the largest changed covered file is 451 logical lines. `config/file-size-baseline.json` is not in the branch diff.

### Prior findings (stage D review `code-review.2026-11-07T10-50.md`)

| Finding | Status | Evidence |
|---|---|---|
| N1 PowerShell key lookup ignores case | Closed for the light-path keys, with Minor N1 above on test pinning | `Get-CheckpointObjectOrdinalMember`; corpus rows `light_path_key_case_variant` and `light_scope_key_case_variant` pass in all three runtimes. |
| N2 Integral float | Unchanged; record only | No change owed. |
| N3 Guard size | Unchanged | The guard copies are not in this diff. |
| N4 Mode-line wording | Closed | `PCW-MODE-LIGHT-HANDOFF-CLAUDE`, `-AGENTS`, `-GITHUB`, and `-COPILOT-ORCH` rows; entry `0003` updated in `95a5254bb`. |

---

## PowerShell Review

**What changed well:** the hook edit is a three-line removal with the header comment updated to match. The accessor follows the existing return contract (`Present`, `Value`) and reports a non-object owner as absent. `-ceq` on the property name gives the ordinal comparison that Python and TypeScript key lookup use. A JSON object with two keys differing only in case cannot reach the accessor, because `ConvertFrom-Json` rejects it.

**API and safety:** the export list gains one name; no existing signature changes. Nothing writes, so `ShouldProcess` does not apply.

**Tests:** the four accessor rows cover exact name, case variant, present null, and non-object owner. The replay test is read-only and leaves no function defined.

## Python and TypeScript Review

Only the corpus floor changed, from 55 to 57, in both parity suites, matching the two new corpus files. Black, Ruff, Pyright, Prettier, ESLint, and `tsc` are clean. No typed-Python concern arises.

## Skill and Agent Text Review

- The six contract copies carry the standing rule, the task target, and the policy-read sentence; `PCW-` rows pin each copy.
- `execution-environment` is byte-identical across its three surfaces and its bundles.
- The 12 Codex planner profiles regenerate cleanly (`generate_codex_agent_variants --check` exit 0).
- Each Copilot agent edit removes only the policy-read clause; the baseline command-step bullets remain. The per-file occurrence count of `baseline`, `coverage`, and `no pre-change run` did not fall in any changed file.

## Test Quality

Each new rule has a row that fails without it: `PRR-REVERTED-RETURNS-POLICY-READ-ERROR` fails if the entry's hook blocks stop restoring the check; `accepts a plan that keeps the policy-read task` fails if the removal is replaced by a prohibition; the scope key-case row fails if the finding read reverts. The exception is N1.

## Security and Correctness

No command text is executed. The replay test compiles extracted function text into a child script block from a tracked file, which is acceptable in test code. No production behavior changes for a checkpoint with exact keys.

## Verdict

One Blocking item (F1, `human_decision_required`), one Minor, one Nit. Review verdict: `HALT_NON_REMEDIABLE`.
