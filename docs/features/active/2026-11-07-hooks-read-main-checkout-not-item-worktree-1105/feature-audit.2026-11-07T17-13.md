# Feature Audit: SubagentStop Hooks Resolve the Item Worktree (#1105)

**Audit Date:** 2026-11-07
**Feature Folder:** `docs/features/active/2026-11-07-hooks-read-main-checkout-not-item-worktree-1105`
**Base Branch:** `main`
**Head Branch:** `bug/hooks-read-main-checkout-1105`
**Work Mode:** `full-bug`
**Audit Type:** Re-audit after remediation cycle 1

---

## Scope and Baseline

- **Base branch:** `main` (merge base `bad886e304990d26af56d6bcabc9d543518492e9`, the merge base of `origin/main` and `HEAD` after a fetch)
- **Head branch/commit:** `bug/hooks-read-main-checkout-1105` (commit `5a866484f06e940196f7fe867dce98cc86e461de`)
- **Merge base:** `bad886e304990d26af56d6bcabc9d543518492e9`
- **Evidence sources:**
  - Primary: `artifacts/pr_context.summary.txt` in the item worktree, generated 2026-11-07 17:05:50 UTC for this head
  - Secondary baseline diff: `artifacts/pr_context.appendix.txt`
  - Feature evidence: `evidence/baseline/`, `evidence/qa-gates/` (cycle 1: `pester-parallel.2026-11-07T17-01.md`, `pytest-parallel.2026-11-07T16-50.md`, `baseline-comparison.2026-11-07T17-01.md`, `self-review.2026-11-07T17-02.md`), `evidence/other/census-derivation.2026-11-07T16-23.md`, `evidence/regression-testing/`
  - Additional evidence: `artifacts/pester/powershell-coverage.xml` in the item worktree; the reviewer's Pester, pytest, PSScriptAnalyzer, and formatter runs at this head; the reviewer's real-process and mutation probes
- **Feature folder used:** `docs/features/active/2026-11-07-hooks-read-main-checkout-not-item-worktree-1105`
- **Requirements source:** `spec.md` only
- **Work mode resolution note:** `issue.md` states `- Work Mode: full-bug`, so `spec.md` `## Acceptance Criteria` is the only AC source.
- **Scope note:** the audit covers the full branch diff, 97 files over 43 commits.

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
| 1 | Helper resolution sources | PASS | `subagentstop-target-worktree.Tests.ps1` 40 of 40 in the reviewer run, with `ReadTranscriptHead` and `WorktreeListInvoker` injected. Reviewer probes: absolute path gave `FilePath`, branch label gave `DelegationPrompt`, no identity gave `SessionRoot`. |
| 2 | Helper path conversion | PASS | Same suite. Reviewer probe: an absolute value inside the item root converted to `docs/features/active/x/spec.md`; an absolute value outside every worktree returned unchanged. |
| 3 | Researcher cases | PASS | `validate-task-researcher-output.TargetWorktree.Tests.ps1` 9 of 9. |
| 4 | `prd-feature` cases | PASS | `validate-prd-feature-output.TargetWorktree.Tests.ps1` 12 of 12. |
| 5 | Required-artifact cases | PASS | `validate-required-artifact-output.TargetWorktree.Tests.ps1` 10 of 10. |
| 6 | Planner cases | PASS | `validate-planner-output.TargetWorktree.Tests.ps1` 10 of 10, including the second-`branch:` case. |
| 7 | Executor cases (#1034) | PASS | `validate-executor-output.TargetWorktree.Tests.ps1` 19 of 19. Reviewer probe: one transcript read per invocation (F2). |
| 8 | Coverage hook artifacts (#1031) and item-root reads | PARTIAL | The four artifact tokens are verified (`validate-feature-review-coverage.TargetWorktree.Tests.ps1` 21 of 21), and the rooted summary and `CLAUDE.md` reads are asserted with `-Times 1`. The "only beneath the item root" clause rests on the line 218 `-Times 0` assertion, which cannot fail under the PoshQC gate host (F4, reviewer mutation). The production code reads both files only beneath the item root (code inspection of `validate-feature-review-coverage.ps1` line 200 and `validate-feature-review-coverage-metrics.ps1` line 64). |
| 9 | Freshness rules | PASS | `validate-feature-review-coverage-freshness.Tests.ps1` 18 of 18. |
| 10 | Unresolved target and stale main report | PASS | Coverage suite cases for `TARGET_WORKTREE_NOT_DERIVABLE` and `TARGET_WORKTREE_AMBIGUOUS` assert zero artifact and report reads with unfiltered `-Times 0`, which counts every call. Reviewer probes: a reader that finds no worktree gives `TARGET_WORKTREE_NOT_DERIVABLE`, and two different issue lines give `TARGET_WORKTREE_AMBIGUOUS`. |
| 11 | Session-root behavior unchanged | PASS | The pre-existing suites gained baseline-mock registration lines and probe cases but no `ParameterFilter` edits (reviewer search of the diff). Reviewer probes: no identity, `branch: main`, and an absolute path inside the session root returned the session root; `docs/../x.md` with the session root is not rejected. |
| 12 | Guard suites | PASS | Executor gate: `hook-dependency-guard-completeness.Tests.ps1` 671 of 671, `hook-dependency-failure.Claude.Tests.ps1` 191 of 191, `enforcement-hooks-no-python-invocation.Tests.ps1` 33 of 33. The two new guarded `Import-Module` lines follow the single-statement pattern. |
| 13 | Mirrors and manifest | PASS | Reviewer pytest run of the four named modules plus two related modules: 126 passed. `cmp` of the ten hook pairs: identical. |
| 14 | Brief copies | PASS | All six copies share MD5 `e238f35f...`; the brief did not change in cycle 1. The contract modules passed in the reviewer run. |
| 15 | Restored baseline and coverage | PASS | Pester 0 failed of 15759 (baseline 0 of 15553); pytest 0 failed (16179 passed, unchanged). The reviewer parsed the item worktree report: helper 100.00% (92 of 92), freshness 97.96% (48 of 49), repo-wide 94.06% (baseline 94.01%). The report (17:00:54 UTC) follows the newest code commit (16:50:31 UTC). |
| 16 | CI Required Gate green on the PR head | PENDING-CI | No pull request exists yet. The orchestrator checks this off at S9, per `evidence/other/ci-gate-handoff.2026-11-07T15-24.md`. Not counted as a blocking finding. |

**Prior findings.** F1, F2, and F3 from `remediation-inputs.2026-11-07T15-37.md` are resolved; the probes are listed in section 5 of `policy-audit.2026-11-07T17-13.md`.

---

## Summary

- **Total criteria:** 16
- **PASS:** 14
- **PARTIAL:** 1 (criterion 8, finding F4)
- **FAIL:** 0
- **PENDING-CI:** 1 (criterion 16)
- **Blocking review finding:** F4 (`autonomous`); verdict `REMEDIATION_REQUIRED`

---

## Acceptance Criteria Check-off

This review unchecked criterion 8 in `spec.md`, changing `- [x]` to `- [ ]` without changing its text, because its "only beneath the item root" clause is not enforced by the gate host (F4). The remediation executor re-checks it after the F4 fix passes the gate. Criteria 1 to 7 and 9 to 15 were checked by the executor and are evaluated PASS here, so those check-offs stand. Criterion 16 stays unchecked, pending CI.

### AC Status Summary

- Source: `docs/features/active/2026-11-07-hooks-read-main-checkout-not-item-worktree-1105/spec.md`
- Total AC items: 16
- Checked off (delivered): 14
- Remaining (unchecked): 2
- Items remaining: criterion 8, "`validate-feature-review-coverage.TargetWorktree.Tests.ps1` verifies the same cases for `policy-audit-path`, `code-review-path`, `feature-audit-path`, and `remediation-inputs-path` (#1031), and that the PR context summary and root `CLAUDE.md` are read only beneath the resolved item root." (F4); criterion 16, "CI-dependent: the CI Required Gate is green on the PR head SHA." (pending CI; owned by the orchestrator at S9)

---

**Audit completed by:** feature-review agent
