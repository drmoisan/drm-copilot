# Feature Audit: SubagentStop Hooks Resolve the Item Worktree (#1105)

**Audit Date:** 2026-11-07
**Feature Folder:** `docs/features/active/2026-11-07-hooks-read-main-checkout-not-item-worktree-1105`
**Base Branch:** `main`
**Head Branch:** `bug/hooks-read-main-checkout-1105`
**Work Mode:** `full-bug`
**Audit Type:** Re-audit after remediation cycle 2 (light path)

---

## Scope and Baseline

- **Base branch:** `main` (merge base `bad886e304990d26af56d6bcabc9d543518492e9`, the merge base of `origin/main` and `HEAD` after a fetch)
- **Head branch/commit:** `bug/hooks-read-main-checkout-1105` (commit `8b1103ea0527187f121d5090db8819b1c573f49e`)
- **Merge base:** `bad886e304990d26af56d6bcabc9d543518492e9`
- **Evidence sources:**
  - Primary: `artifacts/pr_context.summary.txt` in the item worktree, generated 2026-11-07 17:29:41 UTC for this head
  - Secondary baseline diff: `artifacts/pr_context.appendix.txt`
  - Feature evidence: `evidence/baseline/`, `evidence/qa-gates/` (cycle 2: `pester-parallel.2026-11-07T17-28.md`; cycle 1: `pytest-parallel.2026-11-07T16-50.md`, `baseline-comparison.2026-11-07T17-01.md`), `evidence/regression-testing/`
  - Additional evidence: `artifacts/pester/powershell-coverage.xml` in the item worktree; the reviewer's Pester, PSScriptAnalyzer, and formatter runs at this head; the reviewer's F4 mutation probe under two hosts
- **Feature folder used:** `docs/features/active/2026-11-07-hooks-read-main-checkout-not-item-worktree-1105`
- **Requirements source:** `spec.md` only
- **Work mode resolution note:** `issue.md` states `- Work Mode: full-bug`, so `spec.md` `## Acceptance Criteria` is the only AC source.
- **Scope note:** the audit covers the full branch diff, 102 files over 45 commits. Since the 17-13 review, only the coverage target test file and Markdown under the feature folder changed.

---

## Acceptance Criteria Inventory

**Authoritative AC source file for this run:**
- `docs/features/active/2026-11-07-hooks-read-main-checkout-not-item-worktree-1105/spec.md` — `## Acceptance Criteria`, 16 checkbox items

### Acceptance criteria

1. The helper suite verifies `Resolve-SubagentStopTargetWorktree` sources `FilePath`, `DelegationPrompt`, and `SessionRoot` with injected seams.
2. The helper suite verifies `Resolve-SubagentStopArtifactPath` for session root, `$null` root, relative join, absolute-inside conversion, and absolute-outside pass-through.
3. The researcher suite verifies item-only (with the three deeper checks), main-only, both, and not-derivable and ambiguous cases for `research-path`.
4. The `prd-feature` suite verifies the same cases for `spec-path` and `research-path`, including the numeric-criterion check.
5. The required-artifact suite verifies the same cases and the absolute-inside conversion against `^docs/features/active/.+/spec\.md$`.
6. The planner suite verifies the same cases, including plan-structure, Pre-Mortem, and planner-internal-review checks.
7. The executor suite verifies the same cases for `plan-path` and `preflight-fix-record`, including the item-only fix record (#1034).
8. The coverage suite verifies the same cases for the four review artifact tokens (#1031) and item-root-only reads of the summary and `CLAUDE.md`.
9. The freshness suite verifies absent report, absent summary, stale report, fresh report, and the three git failure modes.
10. The coverage suite verifies the not-derivable and ambiguous blocks read no report from the session root, and a stale main-checkout report is never read.
11. Session-root behavior is unchanged: pre-existing suites pass without `ParameterFilter` edits, and no freshness probe runs for the session root.
12. The three guard suites pass with the new files loaded under the guarded pattern and without Python.
13. The four push-down contract modules pass, confirming byte-identical mirrors and `core.json` entries.
14. Every brief copy states the item-worktree resolution in `## Hook Execution Context`, byte-identical, verified by the contract tests.
15. Restored baseline: no new Pester or pytest failures, no changed-line coverage drop, and both new files at or above 85% line coverage.
16. CI-dependent: the CI Required Gate is green on the PR head SHA.

---

## Acceptance Criteria Evaluation

| # | Criterion (short) | Status | Evidence |
|---|---|---|---|
| 1 | Helper resolution sources | PASS | `subagentstop-target-worktree.Tests.ps1` 40 of 40 in the reviewer run and the cycle 2 gate. Production code unchanged since the 17-13 review's probes. |
| 2 | Helper path conversion | PASS | Same suite; unchanged since the 17-13 review. |
| 3 | Researcher cases | PASS | `validate-task-researcher-output.TargetWorktree.Tests.ps1` passes in the cycle 2 gate (0 failures in 15759). |
| 4 | `prd-feature` cases | PASS | `validate-prd-feature-output.TargetWorktree.Tests.ps1` passes in the cycle 2 gate. |
| 5 | Required-artifact cases | PASS | `validate-required-artifact-output.TargetWorktree.Tests.ps1` passes in the cycle 2 gate. |
| 6 | Planner cases | PASS | `validate-planner-output.TargetWorktree.Tests.ps1` passes in the cycle 2 gate, including the second-`branch:` case. |
| 7 | Executor cases (#1034) | PASS | `validate-executor-output.TargetWorktree.Tests.ps1` passes in the cycle 2 gate. |
| 8 | Coverage hook artifacts (#1031) and item-root reads | PASS | `validate-feature-review-coverage.TargetWorktree.Tests.ps1` 21 of 21 (reviewer run and cycle 2 gate). F4 resolved: the `-Times 0` assertion now reads `$PesterBoundParameters['Root']` and fails a mutant that adds an unrooted summary read under both plain `Invoke-Pester` and a host with an outer `$Root`; the original hook passes in both. Control: the pre-fix file passes the mutant in the rooted host. |
| 9 | Freshness rules | PASS | `validate-feature-review-coverage-freshness.Tests.ps1` 18 of 18 (reviewer run and cycle 2 gate). |
| 10 | Unresolved target and stale main report | PASS | Coverage suite cases assert zero artifact and report reads with unfiltered `-Times 0`; 21 of 21 pass. |
| 11 | Session-root behavior unchanged | PASS | Cycle 2 edited only the new target suite, not a pre-existing suite; the pre-existing suites still carry no `ParameterFilter` edits. |
| 12 | Guard suites | PASS | Cycle 2 gate: `hook-dependency-guard-completeness.Tests.ps1` 671 of 671, `hook-dependency-failure.Claude.Tests.ps1` 191 of 191, `enforcement-hooks-no-python-invocation.Tests.ps1` 33 of 33. |
| 13 | Mirrors and manifest | PASS | `cmp` of the ten hook pairs at this head: identical. The contract modules passed in the cycle 1 gate and the 17-13 reviewer run; no mirrored file changed since. |
| 14 | Brief copies | PASS | The brief copies did not change since the 17-13 review, which verified one MD5 across all six. |
| 15 | Restored baseline and coverage | PASS | Cycle 2 gate: Pester 0 failed of 15759; reviewer parse of the item worktree report: helper 100.00% (92 of 92), freshness 97.96% (48 of 49), repo-wide 94.06% (baseline 94.01%). Pytest unchanged at 16179 passed, 0 failed (no Python change). |
| 16 | CI Required Gate green on the PR head | PENDING-CI | No pull request exists yet. The orchestrator checks this off at S9. Not counted as a blocking finding. |

**Prior findings.** F1, F2, and F3 were resolved in cycle 1 (17-13 review). F4 is resolved in cycle 2. F5 is a non-blocking Nit outside the diff.

---

## Summary

- **Total criteria:** 16
- **PASS:** 15
- **PARTIAL:** 0
- **FAIL:** 0
- **PENDING-CI:** 1 (criterion 16)
- **Blocking review finding:** none; verdict `PASS`

---

## Acceptance Criteria Check-off

The remediation executor re-checked criterion 8 in `spec.md` in `8b1103ea0` after the F4 fix passed the gate, with the text unchanged. This review evaluates criterion 8 as PASS, so the check-off stands. Criteria 1 to 7 and 9 to 15 are evaluated PASS and their check-offs stand. Criterion 16 stays unchecked, pending CI. This review made no change to `spec.md`.

### AC Status Summary

- Source: `docs/features/active/2026-11-07-hooks-read-main-checkout-not-item-worktree-1105/spec.md`
- Total AC items: 16
- Checked off (delivered): 15
- Remaining (unchecked): 1
- Items remaining: criterion 16, "CI-dependent: the CI Required Gate is green on the PR head SHA." (pending CI; owned by the orchestrator at S9)

---

**Audit completed by:** feature-review agent
