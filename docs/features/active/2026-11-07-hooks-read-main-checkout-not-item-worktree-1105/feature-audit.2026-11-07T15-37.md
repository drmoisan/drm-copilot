# Feature Audit: SubagentStop Hooks Resolve the Item Worktree (#1105)

**Audit Date:** 2026-11-07
**Feature Folder:** `docs/features/active/2026-11-07-hooks-read-main-checkout-not-item-worktree-1105`
**Base Branch:** `main`
**Head Branch:** `bug/hooks-read-main-checkout-1105`
**Work Mode:** `full-bug`
**Audit Type:** First review

---

## Scope and Baseline

- **Base branch:** `main` (commit `bad886e304990d26af56d6bcabc9d543518492e9`, equal to `origin/main` after a fetch)
- **Head branch/commit:** `bug/hooks-read-main-checkout-1105` (commit `98028900a19973e8467846b5962170488529c5b1`)
- **Merge base:** `bad886e304990d26af56d6bcabc9d543518492e9`
- **Evidence sources:**
  - Primary: `artifacts/pr_context.summary.txt` in the item worktree, generated 2026-11-07 15:28:03 UTC for this head
  - Secondary baseline diff: `artifacts/pr_context.appendix.txt`
  - Feature evidence: `evidence/baseline/`, `evidence/qa-gates/`, `evidence/regression-testing/`, `evidence/other/`
  - Additional evidence: `artifacts/pester/powershell-coverage.xml` in the item worktree; the reviewer's Pester, pytest, PSScriptAnalyzer, and formatter runs at this head; the reviewer's real-process probes of the helper and the coverage hook
- **Feature folder used:** `docs/features/active/2026-11-07-hooks-read-main-checkout-not-item-worktree-1105`
- **Requirements source:** `spec.md` only
- **Work mode resolution note:** `issue.md` states `- Work Mode: full-bug`, so `spec.md` `## Acceptance Criteria` is the only AC source.
- **Scope note:** the audit covers the full branch diff, 54 files over 27 commits.

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
| 1 | Helper resolution sources | PASS | `subagentstop-target-worktree.Tests.ps1` 28 of 28 in the reviewer run, with `ReadTranscriptHead` and `WorktreeListInvoker` injected. Reviewer probe: absolute inside item gave `FilePath`, branch label gave `DelegationPrompt`, no identity gave `SessionRoot`. |
| 2 | Helper path conversion | PASS | Same suite. Reviewer probe: a Windows absolute value inside the item root converted to `docs/features/active/f/spec.md`; an absolute value outside every worktree returned unchanged. |
| 3 | Researcher cases | PASS | `validate-task-researcher-output.TargetWorktree.Tests.ps1` 7 of 7. |
| 4 | `prd-feature` cases | PASS | `validate-prd-feature-output.TargetWorktree.Tests.ps1` 9 of 9; the inline `Test-Path` moved behind `Test-PrdFeatureArtifactFile`. |
| 5 | Required-artifact cases | PASS | `validate-required-artifact-output.TargetWorktree.Tests.ps1` 8 of 8. |
| 6 | Planner cases | PASS | `validate-planner-output.TargetWorktree.Tests.ps1` 7 of 7. |
| 7 | Executor cases (#1034) | PASS | `validate-executor-output.TargetWorktree.Tests.ps1` 14 of 14. |
| 8 | Coverage hook artifacts (#1031) and item-root reads | PASS | `validate-feature-review-coverage.TargetWorktree.Tests.ps1` 15 of 15; the summary and `CLAUDE.md` reads are asserted with `Root` equal to the item root and zero calls without it. |
| 9 | Freshness rules | PASS | `validate-feature-review-coverage-freshness.Tests.ps1` 18 of 18. Code inspection: absent summary and report are repairable; a git non-zero exit, empty output, non-integer output, or throw is non-repairable. |
| 10 | Unresolved target and stale main report | PASS | Coverage suite cases for `TARGET_WORKTREE_NOT_DERIVABLE` and `TARGET_WORKTREE_AMBIGUOUS` assert zero artifact and report reads. The stale main-report case asserts zero reads of the process-relative report. Reviewer probes confirmed the block text in a real process. See the note on F1 below. |
| 11 | Session-root behavior unchanged | PASS | The diff adds test files only (`--name-status` lists 8 `A` entries under `tests/`). The 21 pre-existing suites of the edited hook families passed in the reviewer run. The freshness suite covers source `SessionRoot` and a root equal to the session root. Reviewer probes: no identity, a branch label naming the session root's branch, and an absolute path inside the session root all returned the session root with the value unchanged. |
| 12 | Guard suites | PASS | Reviewer run: `hook-dependency-guard-completeness.Tests.ps1` 671 of 671, `hook-dependency-failure.Claude.Tests.ps1` 191 of 191, `enforcement-hooks-no-python-invocation.Tests.ps1` 33 of 33. |
| 13 | Mirrors and manifest | PASS | Reviewer pytest run of the four named modules plus two related modules: 126 passed. `cmp` of the ten hook pairs: identical. `core.json` adds both paths in sorted position. |
| 14 | Brief copies | PASS | All six copies share SHA-256 `2307aff2...`. The new bullet names `Resolve-SubagentStopTargetWorktree` and `Resolve-HookTargetWorktree`. `test_execution_environment_brief_contracts.py` and `test_push_down_claude_resource_contracts.py` passed in the reviewer run. |
| 15 | Restored baseline and coverage | PASS | Pester 0 failed of 15671 (baseline 0 of 15553); pytest 0 failed (16179 passed, unchanged). The reviewer parsed the item worktree report: helper 100.00% (73 of 73), freshness 97.96% (48 of 49), repo-wide 94.05% (baseline 94.01%). The comparison artifact records 0 changed executable lines uncovered. The report write time (15:20:34 UTC) follows the newest PowerShell commit (15:09:01 UTC). |
| 16 | CI Required Gate green on the PR head | PENDING-CI | No pull request exists yet. The orchestrator checks this off at S9, per `evidence/other/ci-gate-handoff.2026-11-07T15-24.md`. |

**Note on F1.** Criteria 10 and 11 hold as written. The spec defines the session-root case as resolver source `SessionRoot` or a root equal to the session root, and specifies a block for not-derivable and ambiguous results. The reviewer found that two prompt shapes the model-routing gate admits (an issue line with no `branch:` label, and a second `branch:` token after the item label) resolve as not-derivable or ambiguous here. A main-checkout review with either shape now blocks on every stop and cannot clear the block. This is a defect outside the criteria text, recorded as F1 in `code-review.2026-11-07T15-37.md`, and it blocks the merge.

---

## Summary

- **Total criteria:** 16
- **PASS:** 15
- **PARTIAL:** 0
- **FAIL:** 0
- **PENDING-CI:** 1 (criterion 16)
- **Blocking review finding outside the criteria:** F1 (`autonomous`); verdict `REMEDIATION_REQUIRED`

---

## Acceptance Criteria Check-off

No criterion was newly checked by this review. Criteria 1 to 15 were checked by the executor in `98028900a`. This review evaluated each of them PASS, so the check-offs stand. Criterion 16 stays unchecked, pending CI. No criterion text changed.

A remediation of F1 changes hook code, so the next review re-evaluates criteria 10 and 11 at the new head.

### AC Status Summary

- Source: `docs/features/active/2026-11-07-hooks-read-main-checkout-not-item-worktree-1105/spec.md`
- Total AC items: 16
- Checked off (delivered): 15
- Remaining (unchecked): 1
- Items remaining: "CI-dependent: the CI Required Gate is green on the PR head SHA." (pending CI; owned by the orchestrator at S9)

---

**Audit completed by:** feature-review agent
