# Feature Audit: Stage Timing, Stage B (#1097)

**Audit Date:** 2026-11-07
**Feature Folder:** `docs/features/active/reduce-feature-cycle-time-with-revertible-ledger-1097`
**Base Branch:** `main`
**Head Branch:** `feature/reduce-feature-cycle-time`
**Work Mode:** `full-feature`
**Audit Type:** First review of PR B (stage A merged as PR #1100)

---

## Scope and Baseline

- **Base branch:** `main` (commit `51d3886485956df68a68a38e920c7c3687ec4462`, equal to `origin/main`)
- **Head branch/commit:** `feature/reduce-feature-cycle-time` (commit `d854f13c3da7d3d97873cb4b8adab47e3a8fa7dc`)
- **Merge base:** `51d3886485956df68a68a38e920c7c3687ec4462`
- **Evidence sources:**
  - Primary: `artifacts/pr_context.summary.txt`, generated 2026-11-07 05:55:05 UTC for this head
  - Secondary baseline diff: `artifacts/pr_context.appendix.txt`
  - Feature evidence: `docs/features/active/reduce-feature-cycle-time-with-revertible-ledger-1097/evidence/`
  - Additional evidence: `artifacts/pester/pester-junit.xml`, `artifacts/pester/powershell-coverage.xml`, `artifacts/python/lcov.info`, and reviewer probes of the report script and module
- **Feature folder used:** `docs/features/active/reduce-feature-cycle-time-with-revertible-ledger-1097`
- **Requirements source:** `spec.md` and `user-story.md`
- **Work mode resolution note:** `issue.md` states `- Work Mode: full-feature`.
- **Scope note:** the audit covers the full branch diff. `spec.md` `## Delivery Stages` states that a PR owes criteria tagged with its stage and earlier ones, so this PR owes the six `[A]` and the two `[B]` criteria. Criteria tagged `[C]` to `[I]` are delivered by later PRs and are listed as UNVERIFIED with that reason. They are not gaps in this PR. Full suites were not re-run, under `spec.md` `## Testing Rule`.

---

## Acceptance Criteria Inventory

**Authoritative AC source files for this run:**
- `docs/features/active/reduce-feature-cycle-time-with-revertible-ledger-1097/spec.md` — primary
- `docs/features/active/reduce-feature-cycle-time-with-revertible-ledger-1097/user-story.md` — secondary; its 40 criteria are identical to `spec.md`, including checkbox state

### Acceptance criteria

1. [A] `docs/engineering/process-reductions/` exists with a `README.md` index, and a test fails when the index and the entries disagree.
2. [A] A test fails if a ledger entry lacks a required section, covering a complete entry, a missing section, an empty section, and missing prior text, and it also iterates the real entries read-only.
3. [A] The structure test accepts a pending merge commit only in the exact form `Merge commit: pending (PR #N)`.
4. [A] `Invoke-ProcessReductionRevert` restores `Prior` text in memory, normalizes line endings before comparing, and throws when `Current` is absent.
5. [A] The review skill and all its mirrored copies state the standing rule, conditional on the ledger folder existing, and state that one-off waivers are not entries.
6. [A] `Invoke-PoshQCParallelTest` and `pytest -n auto` pass with zero failures, under the Testing Rule, at each stage.
7. [B] Stage timing is recorded in the checkpoint and in committed evidence, and is reported per stage by `Get-StageTimingReport.ps1`, which labels figures as wall-clock and states that the merge stage is not captured.
8. [B] A test proves that `stage_timing` passes each validator and survives portable handoff.
9. [C] The merge guard commit precedes the readiness relaxation commit on the branch.
10. [C] Under `review_mode: "concurrent"`, merge is denied with review passed and CI pending, and with CI green and review pending, on each guarded path. On the authorization path, which reads no CI result, the required `CI Required Gate` context is the control, and the spec limit in D10 applies.
11. [C] The guard denies a stale head after a code change, including a merge of `origin/main`; a git failure; an unresolved head; and a bare command under the key. It allows a predecessor head whose later changes are only feature-folder paths.
12. [C] The Claude guard and its Codex twin behave the same on these cases.
13. [C] A test proves that a checkpoint without the key makes no `gh` call, receives no new denial, and receives no readiness relaxation.
14. [C] `step7_status: pending` stops blocking PR readiness only under the key, and `require_complete` under the key requires the same `PASS` record in the Python, TypeScript, and PowerShell validators.
15. [C] The orchestrate skill defaults new runs to concurrent and requires a `CI full run` at the join, the parallel merge-on-green step does not record `ci_green` while the child's review is unresolved, and the concurrent reduction lands as its own commit with its entry.
16. [D] A light remediation cycle validates truthfully in the Python, TypeScript, and PowerShell validators with byte-identical strings, and all three land in one commit.
17. [D] A cycle with a design-level finding or no `scope` fails on the light path and still requires the full chain, and a full-path cycle with no preflight fails invariant 2.
18. [D] Invariant 8 also rejects a light cycle with findings above the threshold, a consecutive light cycle, and a light cycle carrying a `preflight` object.
19. [D] The reviewer's `Remediation-Path` choice can be moved only heavier, the skills state the threshold and the Python CLI route of D9, and the light reduction lands as its own commit with its entry.
20. [E] An entry for #1094, the parallel-only test gates, exists with the prior text from its pre-merge state.
21. [E] The planning skill and all its mirrored copies state the standing rule.
22. [E] The smaller-plans text states the design-level target of 15 to 20 tasks and lands as its own commit with its entry.
23. [E] The policy-read task, its artifact requirement, and the hook's policy-read check are removed in one commit with its entry; a plan that keeps the task stays valid; and every baseline requirement string named in research section 3 is present before and after.
24. [E] Applying one entry's revert steps to a test copy restores the prior behavior for at least one sample reduction: in memory, the reverted `Get-PlanStructureValidationReport` returns the policy-read error and the live function does not.
25. [E] Wording deferred from stages A to D has landed, with each affected ledger entry updated in the same commit.
26. [F] G13 reports at the new guideline of 20 tasks and 250 physical lines in both validators, with parity, at the guideline and one above it, with and without a justification.
27. [F] Parity tests run both sides of `PLAN_GUIDELINE_CUTOFF` and the no-path case, cover each stamp shape in K4, and prove that a plan with absent repository wiring keeps its stamp result.
28. [F] The finding message states the guideline that applied, the rule file's scope section describes the cutoff, and G13 lands as its own commit with its entry.
29. [G] The evidence requirements marked Reduce in research section 4 are removed from the skills and templates, and those marked Keep remain.
30. [G] The reviewer writes `## CI Cross-check`, and a mismatch at the join becomes a synthetic Blocking finding that blocks merge, as in K7.
31. [G] The less-evidence reduction lands as its own commit with its entry.
32. [H] The named design-check pass is in single-pass preflight, adds no delegation, and is pinned by a contract test.
33. [H] All 6 copies of the atomic-plan-contract skill describe the new rules, and contract tests pin them.
34. [I] Layer 1 and layer 2 honor `early_start` only for the named dependency; a dependent at `pr_open` or later requires the dependency merged and a string `synced_at`; and without the key both layers are unchanged.
35. [I] Frozen hashes are re-baselined in the same commit, and the reduction lands as its own commit with its entry.
36. [I] The ledger holds an entry for every reduction made, including #1094; every entry carries the prior text or a patch, revert steps, and revert signals; and the reviewer confirms from the branch log that each reduction is a separate commit.
37. [I] The planning, execution, and review skills, and all mirrored copies, describe the new rules, and contract tests pin them.
38. [I] No baseline task, evidence, or comparison requirement is removed.
39. [I] Older checkpoints and plans still validate: existing fixtures pass unchanged, and no Epic #1019 feature folder or admitted plan is edited.
40. [I] Merge is still impossible without a passing review and green CI, within the limit stated in D10.


---

## Acceptance Criteria Evaluation

| # | Criterion | Status | Evidence | Verification command(s) | Notes |
|---|-----------|--------|----------|--------------------------|-------|
| 1 | [A] `docs/engineering/process-reductions/` exists with a `README.md` index, and a test fails when the index and the entries disagree. | PASS | Merged in PR #1100; the folder and `ProcessReductionLedger.Index.Tests.ps1` are on the merge base. | `artifacts/pester/pester-junit.xml`: 0 failures | Still holds: 14582 Pester tests, 0 failures. |
| 2 | [A] A test fails if a ledger entry lacks a required section, covering a complete entry, a missing section, an empty section, and missing prior text, and it also iterates the real entries read-only. | PASS | Merged in PR #1100; its `PRL-*` cases pass in `pester-junit.xml`. | `artifacts/pester/pester-junit.xml` | Still holds. |
| 3 | [A] The structure test accepts a pending merge commit only in the exact form `Merge commit: pending (PR #N)`. | PASS | `PRL-ENTRY-MERGE-*` cases pass. | `artifacts/pester/pester-junit.xml` | Still holds; the module is unchanged by this PR. |
| 4 | [A] `Invoke-ProcessReductionRevert` restores `Prior` text in memory, normalizes line endings before comparing, and throws when `Current` is absent. | PASS | `PRL-REVERT-*` cases pass. | `artifacts/pester/pester-junit.xml` | Still holds. |
| 5 | [A] The review skill and all its mirrored copies state the standing rule, conditional on the ledger folder existing, and state that one-off waivers are not entries. | PASS | `PRL-RULE-*` cases pass; this PR does not touch the review skill. | `artifacts/pester/pester-junit.xml` | Still holds. |
| 6 | [A] `Invoke-PoshQCParallelTest` and `pytest -n auto` pass with zero failures, under the Testing Rule, at each stage. | PASS | `stage-b-powershell-test.2026-11-07T05-48.md`: 14582 tests, 0 failures. `stage-b-python-test.2026-11-07T05-52.md`: 16115 passed, 0 failed. Junit and `lcov.info` agree. | XML parse of `pester-junit.xml`; evidence read | PASS for stage B. The criterion recurs at each later stage. The TypeScript full-suite gap is F1 in the policy audit and is not named by this criterion. |
| 7 | [B] Stage timing is recorded in the checkpoint and in committed evidence, and is reported per stage by `Get-StageTimingReport.ps1`, which labels figures as wall-clock and states that the merge stage is not captured. | PASS | The writer protocol is in the orchestrate skill (item 6 under `## Checkpoint Handling`), the orchestrator agent, and the orchestrator-state rule, in all eight copies, byte-identical to their sources and pinned by `STD-*` tests. `Get-StageTimingReport.ps1` prints both labels, per-stage medians, and per-issue totals. | `pwsh -File scripts/dev-tools/Get-StageTimingReport.ps1 -EvidenceRoot tests/fixtures/dev-tools/stage-timing`; `cmp` of mirror pairs | The recording is performed by orchestrator sessions at run time, so no real evidence file exists yet; the protocol, the format, and the report are delivered and tested on fixtures. The default root prints the labels and `No stage timing evidence was found.` |
| 8 | [B] A test proves that `stage_timing` passes each validator and survives portable handoff. | PASS | Python: `test_python_plain_validation_ignores_stage_timing`, `test_python_completion_and_pr_modes_ignore_stage_timing`, and three handoff tests. PowerShell: `OST-PLAIN-IGNORES-STAGE-TIMING`. TypeScript: three Jest cases. Each has a control that removes a required key. | Junit and `lcov.info` for the first two; the Jest subset record for the third | The TypeScript tests pass in a subset run. The full-suite and coverage gap is F1 in the policy audit, a toolchain finding that does not change this behavior verdict. |
| 9 | [C] The merge guard commit precedes the readiness relaxation commit on the branch. | UNVERIFIED | Not delivered in this PR | none | Owed by PR C under `spec.md` `## Delivery Stages`; not owed here. |
| 10 | [C] Under `review_mode: "concurrent"`, merge is denied with review passed and CI pending, and with CI green and review pending, on each guarded path. On the authorization path, which reads no CI result, the required `CI Required Gate` context is the control, and the spec limit in D10 applies. | UNVERIFIED | Not delivered in this PR | none | Owed by PR C under `spec.md` `## Delivery Stages`; not owed here. |
| 11 | [C] The guard denies a stale head after a code change, including a merge of `origin/main`; a git failure; an unresolved head; and a bare command under the key. It allows a predecessor head whose later changes are only feature-folder paths. | UNVERIFIED | Not delivered in this PR | none | Owed by PR C under `spec.md` `## Delivery Stages`; not owed here. |
| 12 | [C] The Claude guard and its Codex twin behave the same on these cases. | UNVERIFIED | Not delivered in this PR | none | Owed by PR C under `spec.md` `## Delivery Stages`; not owed here. |
| 13 | [C] A test proves that a checkpoint without the key makes no `gh` call, receives no new denial, and receives no readiness relaxation. | UNVERIFIED | Not delivered in this PR | none | Owed by PR C under `spec.md` `## Delivery Stages`; not owed here. |
| 14 | [C] `step7_status: pending` stops blocking PR readiness only under the key, and `require_complete` under the key requires the same `PASS` record in the Python, TypeScript, and PowerShell validators. | UNVERIFIED | Not delivered in this PR | none | Owed by PR C under `spec.md` `## Delivery Stages`; not owed here. |
| 15 | [C] The orchestrate skill defaults new runs to concurrent and requires a `CI full run` at the join, the parallel merge-on-green step does not record `ci_green` while the child's review is unresolved, and the concurrent reduction lands as its own commit with its entry. | UNVERIFIED | Not delivered in this PR | none | Owed by PR C under `spec.md` `## Delivery Stages`; not owed here. |
| 16 | [D] A light remediation cycle validates truthfully in the Python, TypeScript, and PowerShell validators with byte-identical strings, and all three land in one commit. | UNVERIFIED | Not delivered in this PR | none | Owed by PR D under `spec.md` `## Delivery Stages`; not owed here. |
| 17 | [D] A cycle with a design-level finding or no `scope` fails on the light path and still requires the full chain, and a full-path cycle with no preflight fails invariant 2. | UNVERIFIED | Not delivered in this PR | none | Owed by PR D under `spec.md` `## Delivery Stages`; not owed here. |
| 18 | [D] Invariant 8 also rejects a light cycle with findings above the threshold, a consecutive light cycle, and a light cycle carrying a `preflight` object. | UNVERIFIED | Not delivered in this PR | none | Owed by PR D under `spec.md` `## Delivery Stages`; not owed here. |
| 19 | [D] The reviewer's `Remediation-Path` choice can be moved only heavier, the skills state the threshold and the Python CLI route of D9, and the light reduction lands as its own commit with its entry. | UNVERIFIED | Not delivered in this PR | none | Owed by PR D under `spec.md` `## Delivery Stages`; not owed here. |
| 20 | [E] An entry for #1094, the parallel-only test gates, exists with the prior text from its pre-merge state. | UNVERIFIED | Not delivered in this PR | none | Owed by PR E under `spec.md` `## Delivery Stages`; not owed here. |
| 21 | [E] The planning skill and all its mirrored copies state the standing rule. | UNVERIFIED | Not delivered in this PR | none | Owed by PR E under `spec.md` `## Delivery Stages`; not owed here. |
| 22 | [E] The smaller-plans text states the design-level target of 15 to 20 tasks and lands as its own commit with its entry. | UNVERIFIED | Not delivered in this PR | none | Owed by PR E under `spec.md` `## Delivery Stages`; not owed here. |
| 23 | [E] The policy-read task, its artifact requirement, and the hook's policy-read check are removed in one commit with its entry; a plan that keeps the task stays valid; and every baseline requirement string named in research section 3 is present before and after. | UNVERIFIED | Not delivered in this PR | none | Owed by PR E under `spec.md` `## Delivery Stages`; not owed here. |
| 24 | [E] Applying one entry's revert steps to a test copy restores the prior behavior for at least one sample reduction: in memory, the reverted `Get-PlanStructureValidationReport` returns the policy-read error and the live function does not. | UNVERIFIED | Not delivered in this PR | none | Owed by PR E under `spec.md` `## Delivery Stages`; not owed here. |
| 25 | [E] Wording deferred from stages A to D has landed, with each affected ledger entry updated in the same commit. | UNVERIFIED | Not delivered in this PR | none | Owed by PR E under `spec.md` `## Delivery Stages`; not owed here. |
| 26 | [F] G13 reports at the new guideline of 20 tasks and 250 physical lines in both validators, with parity, at the guideline and one above it, with and without a justification. | UNVERIFIED | Not delivered in this PR | none | Owed by PR F under `spec.md` `## Delivery Stages`; not owed here. |
| 27 | [F] Parity tests run both sides of `PLAN_GUIDELINE_CUTOFF` and the no-path case, cover each stamp shape in K4, and prove that a plan with absent repository wiring keeps its stamp result. | UNVERIFIED | Not delivered in this PR | none | Owed by PR F under `spec.md` `## Delivery Stages`; not owed here. |
| 28 | [F] The finding message states the guideline that applied, the rule file's scope section describes the cutoff, and G13 lands as its own commit with its entry. | UNVERIFIED | Not delivered in this PR | none | Owed by PR F under `spec.md` `## Delivery Stages`; not owed here. |
| 29 | [G] The evidence requirements marked Reduce in research section 4 are removed from the skills and templates, and those marked Keep remain. | UNVERIFIED | Not delivered in this PR | none | Owed by PR G under `spec.md` `## Delivery Stages`; not owed here. |
| 30 | [G] The reviewer writes `## CI Cross-check`, and a mismatch at the join becomes a synthetic Blocking finding that blocks merge, as in K7. | UNVERIFIED | Not delivered in this PR | none | Owed by PR G under `spec.md` `## Delivery Stages`; not owed here. |
| 31 | [G] The less-evidence reduction lands as its own commit with its entry. | UNVERIFIED | Not delivered in this PR | none | Owed by PR G under `spec.md` `## Delivery Stages`; not owed here. |
| 32 | [H] The named design-check pass is in single-pass preflight, adds no delegation, and is pinned by a contract test. | UNVERIFIED | Not delivered in this PR | none | Owed by PR H under `spec.md` `## Delivery Stages`; not owed here. |
| 33 | [H] All 6 copies of the atomic-plan-contract skill describe the new rules, and contract tests pin them. | UNVERIFIED | Not delivered in this PR | none | Owed by PR H under `spec.md` `## Delivery Stages`; not owed here. |
| 34 | [I] Layer 1 and layer 2 honor `early_start` only for the named dependency; a dependent at `pr_open` or later requires the dependency merged and a string `synced_at`; and without the key both layers are unchanged. | UNVERIFIED | Not delivered in this PR | none | Owed by PR I under `spec.md` `## Delivery Stages`; not owed here. |
| 35 | [I] Frozen hashes are re-baselined in the same commit, and the reduction lands as its own commit with its entry. | UNVERIFIED | Not delivered in this PR | none | Owed by PR I under `spec.md` `## Delivery Stages`; not owed here. |
| 36 | [I] The ledger holds an entry for every reduction made, including #1094; every entry carries the prior text or a patch, revert steps, and revert signals; and the reviewer confirms from the branch log that each reduction is a separate commit. | UNVERIFIED | Not delivered in this PR | none | Owed by PR I under `spec.md` `## Delivery Stages`; not owed here. |
| 37 | [I] The planning, execution, and review skills, and all mirrored copies, describe the new rules, and contract tests pin them. | UNVERIFIED | Not delivered in this PR | none | Owed by PR I under `spec.md` `## Delivery Stages`; not owed here. |
| 38 | [I] No baseline task, evidence, or comparison requirement is removed. | UNVERIFIED | Not delivered in this PR | none | Owed by PR I under `spec.md` `## Delivery Stages`; not owed here. |
| 39 | [I] Older checkpoints and plans still validate: existing fixtures pass unchanged, and no Epic #1019 feature folder or admitted plan is edited. | UNVERIFIED | Not delivered in this PR | none | Owed by PR I under `spec.md` `## Delivery Stages`; not owed here. |
| 40 | [I] Merge is still impossible without a passing review and green CI, within the limit stated in D10. | UNVERIFIED | Not delivered in this PR | none | Owed by PR I under `spec.md` `## Delivery Stages`; not owed here. |

---

## Summary

**Overall Feature Readiness:** NOT READY for PR B until F1 is closed

All eight criteria owed by this PR evaluate PASS. The remaining gap is a toolchain item, not a criterion: the TypeScript change has no coverage artifact and no full Jest run (F1, `remediation-inputs.2026-11-07T06-05.md`).

**Criteria summary:**
- **PASS:** 8 criteria
- **PARTIAL:** 0 criteria
- **UNVERIFIED:** 32 criteria, all owed by later stages
- **FAIL:** 0 criteria

**Top gaps preventing PASS:**

1. F1: run the full Jest suite once with coverage and leave the lcov artifact in place.

**Recommended follow-up verification steps:**

1. CI on the PR head remains the authority for merge. No pull request exists yet for stage B.
2. `spec.md` `## Delivery Stages` states that the issue stays open until the last stage; the orchestrator owns the reopen after each non-final merge.

---

## Acceptance Criteria Check-off

Per the acceptance-criteria tracking rules:
- Criteria evaluated as **PASS** may be checked off in the authoritative source files.
- Criteria evaluated as **PARTIAL**, **FAIL**, or **UNVERIFIED** remain unchecked.

The six `[A]` criteria were checked in stage A and the two `[B]` criteria were checked by the executor at `57abf50f9`; all eight evaluate PASS at this head, so this review changed no source file. No pending-CI criterion exists for this PR.

### AC Status Summary

- Source: `spec.md`, `user-story.md`
- Total AC items: 40 per file
- Checked off (delivered): 8 per file
- Remaining (unchecked): 32 per file
- Items remaining: every criterion tagged `[C]` to `[I]`, items 9 to 40 above

| Source File | Total AC | Checked (PASS) | Unchecked | Notes |
|-------------|----------|----------------|-----------|-------|
| `spec.md` | 40 | 8 | 32 | Checkbox-backed |
| `user-story.md` | 40 | 8 | 32 | Checkbox-backed |
