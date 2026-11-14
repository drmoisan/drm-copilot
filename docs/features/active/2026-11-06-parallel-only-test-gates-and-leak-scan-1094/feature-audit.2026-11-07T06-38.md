# Feature Audit: parallel-only-test-gates-and-leak-scan (#1094)

---

**Audit Date:** 2026-11-07
**Feature Folder:** `docs/features/active/2026-11-06-parallel-only-test-gates-and-leak-scan-1094`
**Base Branch:** `origin/main`
**Head Branch:** `feature/parallel-only-test-gates-and-leak-scan-1094`
**Work Mode:** `full-feature`
**Audit Type:** Re-audit after the remediation of RF-6 and the process-reduction ledger addendum

---

## Scope and Baseline

- **Base branch:** `origin/main` (commit `51d3886485956df68a68a38e920c7c3687ec4462`)
- **Head branch/commit:** `feature/parallel-only-test-gates-and-leak-scan-1094` (commit `3c842ab7f9dce9aca98b47866e69b54047b734a7`)
- **Merge base:** `51d3886485956df68a68a38e920c7c3687ec4462`
- **Evidence sources:**
  - Primary: `artifacts/pr_context.summary.txt` (generated at head `3c842ab7f`, current)
  - Secondary baseline diff: `artifacts/pr_context.appendix.txt`
  - Feature evidence: `docs/features/active/2026-11-06-parallel-only-test-gates-and-leak-scan-1094/evidence/qa-gates/`
  - Additional evidence: `artifacts/pester/pester-junit.xml`, `artifacts/pester/powershell-coverage.xml`, `artifacts/python/lcov.info`, `coverage/lcov.info`, and reviewer probes at head
- **Feature folder used:** `docs/features/active/2026-11-06-parallel-only-test-gates-and-leak-scan-1094`
- **Requirements source:** `spec.md` and `user-story.md`
- **Work mode resolution note:** `issue.md` states `- Work Mode: full-feature`.
- **Scope note:** The audit scope is the full diff against the merge base. The owner directive applies: no single-process, shuffled, reversed-order, comparison, or pre-change run is required, and the absence of one is not a finding. Test results for the merged head come from CI on the PR head.

---

## Acceptance Criteria Inventory

**Authoritative AC source files for this run:**
- `docs/features/active/2026-11-06-parallel-only-test-gates-and-leak-scan-1094/spec.md` — primary
- `docs/features/active/2026-11-06-parallel-only-test-gates-and-leak-scan-1094/user-story.md` — secondary; the same 15 criteria, with section references that name `spec.md`

### Acceptance criteria

1. No skill, agent, or template text in the repository requires a serial, single-process, seeded-shuffle, reversed-order, comparison, or pre-change test-suite baseline run. Measured as stated in Decision 1: no skill, agent, or template text requires such a run or names a serial command as a validation gate, and the brief states that the parallel gates govern where a policy file names a toolchain test command. The residual limit in `## Constraints & Risks` applies: the deferred Python tools and VS Code aggregates still invoke a serial command until #1096.
2. The branch diff changes no file under `.claude/rules/` or `.github/instructions/`, no bundle copy of those files, and neither `.agents/skills/powershell` nor `.agents/skills/python`.
3. The branch diff changes no file under `.github/workflows/` or `scripts/powershell/PoshQC/`, and does not change `.vscode/tasks.json`, the Python tools named in `### 2. Out of scope`, or the policy-audit validators.
4. `## Test Isolation Checks` states the parallel gates, names no leak scan, and all mirrored copies match.
5. The `## Test Runtime`, `## CI-Only Failure Classes`, and `## PowerShell Route and PoshQC MCP Limits` passages of the brief carry the changes listed in `### 1. Parallel-only test gates`, in every mirrored copy, and `## CI-Only Failure Classes` names no scan.
6. The Pre-Mortem `Test isolation` bullet of `atomic-plan-contract` states the parallel gates, names no leak scan, and names no removed run, in every mirrored copy.
7. No plan-contract or review text requires a comparison run, and the brief states that a focused run of one test file is debugging only and is never a gate or evidence.
8. Static tool baselines remain required, and skill, agent, and template text reads coverage from the single gate run against the thresholds, in every mirrored copy.
9. The policy-audit template requires no pre-change run, its retained baseline fields record `N/A - no pre-change run`, and a contract test shows that an audit filled in that way passes the unchanged policy-audit validators.
10. Every editable surface in table A3 of the research, except `scripts/dev_tools/fix_all_branches.py`, no longer names a serial command as a validation gate, and tool-permission entries in those surfaces are unchanged.
11. The contract tests pass against the new wording and fail if the removed requirements are reintroduced, in any mirrored copy.
12. `test_execution_environment_fact_is_unchanged_across_copies` filters on the parts relative to `REPO_ROOT` and passes in a checkout under `.claude/worktrees/`.
13. `Invoke-PoshQCParallelTest` and `pytest -n auto` pass with zero failures.
14. The validation evidence for this item comes from the parallel gates, and cites no single-process, seeded-shuffle, reversed-order, comparison, or focused run.
15. CI-dependent: `CI Required Gate` reports success on the final PR head.

---

## Acceptance Criteria Evaluation

| # | Criterion | Status | Evidence | Verification command(s) | Notes |
|---|-----------|--------|----------|--------------------------|-------|
| 1 | No text requires a removed or comparison run | PASS | 0 hits for the 38 sweep tokens over 894 surface files at head. A separate search of the non-bundle surfaces for single-process, shuffle, and reversed-order phrasing returned no hit. `seeded` hits are cohort wording and the RNG rule; `pre-change` hits are the record itself; `Invoke-PoshQCTest` hits describe CI shards and the coverage source; `run_poshqc_test` hits are tool permissions, the adapter statement that it is not a validation gate, and a sample plan line. | Whole-text search with whitespace collapsed, each remaining hit read | Policy-file residuals and deferred tools are excluded per Decision 1. |
| 2 | No policy file changes | PASS | Path-limited diff is empty, including the bundle copies. | `git diff --name-only` from the merge base over the policy paths | |
| 3 | No CI, PoshQC, tasks, tool, or validator change | PASS | Path-limited diff is empty. The hook change is outside this criterion, and the spec records it. | `git diff --name-only` from the merge base over `.github/workflows`, `.github/actions`, `scripts/benchmarks`, `scripts/powershell/PoshQC`, `.vscode/tasks.json`, `scripts/dev_tools`, and `extensions/drm-copilot/src` | |
| 4 | Test Isolation Checks and mirror match | PASS | Six copies share blob `ccf978679`. The file is unchanged since the prior review. | `git ls-files -s` on the six copies | |
| 5 | Brief passages in every copy | PASS | One blob across six copies, unchanged since the prior review, which read each passage. | `git ls-files -s`; `git diff --name-only 6b8c3640a HEAD` | |
| 6 | Pre-Mortem bullet in every copy | PASS | Revert blocks of the ledger entry quote the bullet, and each `Current` matched its live file through `Get-ProcessReductionRevertBlock` and the ledger check. Each bundle copy equals its source. | Pair comparison; `ledger-check.2026-11-07T06-25.md` | |
| 7 | No plan-contract or review comparison; focused run is debugging only | PASS | The `feature-review-workflow` step 5 text states the single gate run and the debugging rule, read at head after the merge. The sweep finds no comparison token. | Read at head; sweep | |
| 8 | Static baselines stay; coverage from the single gate run | PASS | Unchanged surfaces since the prior review, plus the six `feature-review-workflow` copies, which read coverage from the single gate run. 112 source and bundle pairs equal. | Pair comparison after line-ending normalization | |
| 9 | Template and validators accept the record | PASS | Two Python tests and two Jest cases pin the record. The validators are unchanged. `policy-audit.2026-11-07T06-38.md` carries the record and passed the validator. The stop hooks now accept it as well. | Validator run on the policy audit; real hook runs on both surfaces | RF-6 closed. |
| 10 | A3 surfaces; permissions unchanged | PASS | No listed surface changed since the prior review. `scope-check.2026-11-07T06-03.md` reports 263 tool-entry lines in 154 agent files, 0 files differing from the merge base. | `git diff --name-only 6b8c3640a HEAD`; evidence read | |
| 11 | Contract tests pass and discriminate | PASS | Gates green. The tokens hit 0 at head, and earlier cycles replayed hits at the prior heads. The hook rule's discrimination was checked with 14 mutants: 12 changed a result, and the 2 survivors are guards outside this criterion's removed requirements. | Direct-call mutant probe; evidence read | No test run by this review. |
| 12 | Worktree filter fixed | PASS | Line 455 uses `path.relative_to(REPO_ROOT).parts`. The file now equals `origin/main`, which holds the same filter, so it left the branch diff. The pytest gate ran in the item worktree with 0 failures. | Test body read at head; `git diff` of the file from the merge base is empty | |
| 13 | Parallel gates zero failures | PASS | Pester: ExitCode 0, JUnit 14584 tests, 0 failures. Pytest: 16103 passed, 0 failures. Both ran after the last code commit `9c4049cb8`. | JUnit read of `artifacts/pester/pester-junit.xml`; `evidence/qa-gates/pytest-parallel.2026-11-07T06-02.md` | The runs predate merge `5483ba240`. By owner directive a merge is not a fix, and the merged-head result is criterion 15. |
| 14 | Evidence from the parallel gates | PASS | A search of `evidence/` for the removed-run words returns one file, `evidence/issue-updates/issue-1094.2026-11-07T02-09.md`, which restates the issue text and cites no run. | `grep` over `evidence/` | |
| 15 | CI Required Gate on final PR head | UNVERIFIED | Pending CI. No PR exists yet, so CI has not run on this head. | `gh pr list --head feature/parallel-only-test-gates-and-leak-scan-1094 --state all` returned no PR | Owned by the item's orchestrator at S9. Pending-CI, class of wait `awaiting_ci`, not a finding. |

---

## Summary

**Overall Feature Readiness:** READY

**Criteria summary:**
- **PASS:** 14 criteria
- **PARTIAL:** 0 criteria
- **UNVERIFIED:** 1 criteria
- **FAIL:** 0 criteria

**Top gaps preventing PASS:**

1. None for the locally verifiable criteria. Criterion 15 needs CI on the PR head.

The `user-story.md` scenario `Planning an item with no test-suite baseline` now holds end to end: the audit validators and both stop hooks accept the recorded audit.

**Recommended follow-up verification steps:**

1. Open the PR, and replace `PR #1101` in the ledger entry with this branch's number, because `#1101` is another branch's open PR.
2. Let S9 record `CI Required Gate` on the final head, which is the first test run on the merged tree.
3. Check off criterion 15 at S9.

---

## Acceptance Criteria Check-off

Criteria 1 to 14 were already checked in `spec.md` and `user-story.md`, and this audit confirms them as PASS. No checkbox changed in this review. Criterion 15 is pending CI and stays unchecked.

### Acceptance Criteria Status

- Source: `docs/features/active/2026-11-06-parallel-only-test-gates-and-leak-scan-1094/spec.md`, `docs/features/active/2026-11-06-parallel-only-test-gates-and-leak-scan-1094/user-story.md`
- Total AC items: 15 per file
- Checked off (delivered): 14 per file
- Remaining (unchecked): 1 per file
- Items remaining: criterion 15 (`CI Required Gate` on the final PR head)

| Source File | Total AC | Checked (PASS) | Unchecked | Notes |
|-------------|----------|----------------|-----------|-------|
| `spec.md` | 15 | 14 | 1 | Checkbox-backed |
| `user-story.md` | 15 | 14 | 1 | Checkbox-backed |
