# Policy Compliance Audit: bug-burndown-2026-09-29 review nits (#846)

---

**Audit Date:** 2026-10-09 (host clock `2026-10-09T22-52` local, `2026-10-10T02-52` UTC; filename stamp `2026-10-10T03-00` assigned by the caller)
**Review pass:** 2 (final re-review, S9)
**Branch:** `bug/bug-burndown-2026-09-29-review-nits-846`; PR #873 (OPEN)
**HEAD at review time:** `b9e1f7558f19002d6413f576f5f779df434c4509`
**Base:** `main`; merge-base and current `origin/main` tip `816b5513a7e64b574a514ee320ccaef28fc7a597`. Diff anchor `git diff origin/main...HEAD`: 130 files, the same 32 paths outside the feature folder as in pass 1, plus the feature folder.
**Changes since pass 1 (HEAD `396f598b3`):** commit `d2732d523` (pass-1 review artifacts; host-path redaction in 7 evidence files) and merge commit `b9e1f7558` (main merged in). `git diff --name-only d2732d523 b9e1f7558` limited to this branch's directories lists only main-side files (codex-native-converter, pr-context, push-down, subagent-tree lib tests, and three Python test modules), none of which is in this branch's file list.
**Work mode:** `full-bug` (AC source: `spec.md` only)
**Code Under Test:** production Python `scripts/dev_tools/check_quality_tiers.py` (QT009 stderr detail, `GitRunResult.stderr`) and `scripts/dev_tools/potential_to_issue.py` (docstring and comment only); `pyproject.toml` (`partial_also`); Python tests (quality-tiers split, QT009 tests, completion-gate documentation pin); TypeScript test split (`extensions/drm-copilot/test/subagent-tree-command*.ts`); Pester test `tests/scripts/workflows/PublishMcpNpmWorkflow.Tests.ps1`; six acceptance-criteria-tracking `SKILL.md` copies; CHANGELOG; runbook; documentation and evidence corrections in the #338, #510, #543, #609, #623, #744, #764 feature folders.

**Coverage Metrics by Language:**

| Language | Files Changed | Tests | Test Result | Baseline Coverage | Post-Change Coverage | New Code Coverage |
|----------|--------------|-------|-------------|-------------------|---------------------|-------------------|
| Python | 2 production (`check_quality_tiers.py`, `potential_to_issue.py`), 5 test files (1 new support module, 1 new test module, 3 modified) | CI PR head: 6741 passed, 6 skipped (main tip: 6732 passed, 6 skipped) | PASS | 93.60% lines (16440/17565), 566 partial branches; CI main tip `816b5513a` run 38017407907 job 114110654867 | 93.61% lines (16449/17571), 511 partial branches; CI PR head run 38017787058 job 114111830945; `Enforce Python coverage thresholds` (85/75) success in all four matrix jobs. Local whole repository (pass 1): 93.70% lines, 87.97% branches | 100% of changed executable lines (5 of 5 in `check_quality_tiers.py`); `potential_to_issue.py` has no changed executable line |
| TypeScript | 3 test files (1 modified, 2 new); 0 production files | Local: 3925 tests in 258 suites; CI extension test jobs (ubuntu, windows) SUCCESS on the PR head | PASS | 97.16% lines, 91.70% branches (`evidence/baseline/ts-jest-coverage.2026-10-09T09-00.md`) | 97.16% lines (51037/52524), 91.71% branches (7524/8204) from `extensions/drm-copilot/coverage/lcov.info` (no TypeScript file changed since pass 1) | N/A (no production TypeScript file changed) |
| PowerShell | 1 test file (`PublishMcpNpmWorkflow.Tests.ps1`); 0 production files | CI PR head: 6743 passed, 0 failed, 10 skipped (main tip: 6742 passed) | PASS | 87.31% lines (command coverage, 22,010 commands in 178 files) on main tip `816b5513a`, CI run 38017407907 job 114110654807 | 87.31% lines (command coverage, 22,010 commands in 178 files) on PR head `b9e1f7558`, CI run 38017787058 job 114111830920 | N/A (no production PowerShell file changed) |
| C# | 0 files | N/A | N/A | N/A (no C# files changed) | N/A (no C# files changed) | N/A |
| Markdown | 118 files committed at HEAD (skills, CHANGELOG, runbook, feature documents, evidence, pass-1 review artifacts), plus the 4 files written by this pass | N/A | N/A | N/A (documentation) | N/A (documentation) | N/A |

### Coverage Evidence Checklist

- Python baseline coverage artifact: `docs/features/active/2026-10-08-bug-burndown-2026-09-29-review-nits-846/evidence/baseline/py-cov-whole-repo.2026-10-09T09-00.md` (93.68% lines, 87.1% branches) and the CI main-tip TOTAL row (93.60% lines) recorded in `evidence/qa-gates/ci-evidence-pr873.2026-10-10T03-00.md`
- Python post-change coverage artifact: `docs/features/active/2026-10-08-bug-burndown-2026-09-29-review-nits-846/evidence/qa-gates/ci-evidence-pr873.2026-10-10T03-00.md` (CI PR head 93.61% lines, threshold step success) and `evidence/qa-gates/py-cov-whole-repo.2026-10-09T09-00.md` (local 93.70% lines, 87.97% branches)
- TypeScript baseline coverage artifact: `docs/features/active/2026-10-08-bug-burndown-2026-09-29-review-nits-846/evidence/baseline/ts-jest-coverage.2026-10-09T09-00.md` (97.16% lines, 91.70% branches)
- TypeScript post-change coverage artifact: `docs/features/active/2026-10-08-bug-burndown-2026-09-29-review-nits-846/evidence/qa-gates/ts-jest-coverage.2026-10-09T09-00.md` (97.16% lines, 91.71% branches)
- PowerShell baseline coverage artifact: `docs/features/active/2026-10-08-bug-burndown-2026-09-29-review-nits-846/evidence/qa-gates/ci-evidence-pr873.2026-10-10T03-00.md`, section "Baseline: main tip 816b5513a" (87.31% lines over 22,010 commands)
- PowerShell post-change coverage artifact: `docs/features/active/2026-10-08-bug-burndown-2026-09-29-review-nits-846/evidence/qa-gates/ci-evidence-pr873.2026-10-10T03-00.md`, section "Job 1: poshqc / PowerShell QC" (87.31% lines over 22,010 commands)
- Per-language comparison summary: Section 1.2.1 of this document

**Non-negotiable verdict rule:** No policy audit may report PASS unless it includes numeric baseline and post-change coverage metrics for every language in scope, plus changed/new-code coverage when required.

**Fail-closed rule:** If any required baseline artifact, QA artifact, or coverage-comparison artifact is absent, the verdict must be BLOCKED or INCOMPLETE, never PASS.

**Evidence rule:** Do not synthesize or backfill audit evidence from memory or inference. If evidence is absent, stop and list the exact artifact paths.

---

## Executive Summary

The branch closes 26 accepted Minor/Nit findings from the `bug-burndown-2026-09-29` reviews plus one follow-up row. The only runtime behavior change is the QT009 message in `scripts/dev_tools/check_quality_tiers.py`. The remaining changes are test-file splits, new regression tests, a coverage reporting setting (`partial_also`), a Pester tightening, and documentation and evidence corrections. No code file changed between pass 1 and this pass.

Pass 1 left two Blocking findings classified `awaiting_ci` (PA-1 PowerShell coverage, PA-2 PowerShell toolchain). Both are resolved by CI run 38017787058 on PR head `b9e1f7558`. This reviewer read the job logs and the jobs API directly (not only the orchestrator's quotations). The `poshqc / PowerShell QC` job reports `head_sha` `b9e1f7558`, and its Format, Analyze, and Test steps each concluded `success`. The test file is `Already formatted`, PSScriptAnalyzer reports no findings, and Pester reports 6743 passed and 0 failed, with `PublishMcpNpmWorkflow.Tests.ps1` marked `[+]`. Repository-wide PowerShell coverage is 87.31%, identical to the main tip `816b5513a` (CI run 38017407907). The Python `Enforce Python coverage thresholds` step concluded `success` in all four `quality-checks7` matrix jobs.

PA-4 (host paths in evidence) was resolved in `d2732d523`. A search of the feature folder for user-profile path patterns returns no match.

Overall verdict: **PASS**. 0 Blocking; 2 Minor (PA-3, PA-5); 1 Nit (PA-6).

## Rejected Scope Narrowing

No scope narrowing was detected. The caller names `git diff origin/main...HEAD` as the diff anchor, which is the full branch diff against the resolved base. Asking the reviewer to re-evaluate four `awaiting_ci` findings sets a focus but does not exclude any file or language. This audit re-checked branch scope (130 files, unchanged code set), evidence locations, and host-path redaction, and it gives explicit coverage verdicts for Python, TypeScript, and PowerShell.

## Evidence Location Compliance

- `poetry run python scripts/dev_tools/validate_evidence_locations.py --root .` exited 0 in this pass (run after this pass's evidence file was written).
- The branch diff contains no path under `artifacts/baselines/`, `artifacts/qa/`, `artifacts/evidence/`, or `artifacts/coverage/`.
- The new CI evidence file is at `docs/features/active/2026-10-08-bug-burndown-2026-09-29-review-nits-846/evidence/qa-gates/ci-evidence-pr873.2026-10-10T03-00.md`.
- No `EVIDENCE_LOCATION_OVERRIDE_REJECTED` event occurred.
- Verdict: PASS.

## Findings

| ID | Severity | Remediability | Location | Rule | Evidence |
| --- | --- | --- | --- | --- | --- |
| PA-1 | Resolved (was Blocking, awaiting_ci) | n/a | PowerShell coverage at branch head | Coverage Verification (agent contract); `.claude/rules/quality-tiers.md` uniform line >= 85% | CI `poshqc / PowerShell QC` on head `b9e1f7558` reports `Covered 87.31% / 0%. 22,010 analyzed Commands in 178 Files.` (>= 85%; the `0%` figure is the branch metric Pester does not measure, which is exempt). Main tip `816b5513a` reports the same 87.31% over the same command count, so there is no regression. No production PowerShell file changed. Evidence: `evidence/qa-gates/ci-evidence-pr873.2026-10-10T03-00.md`. |
| PA-2 | Resolved (was Blocking, awaiting_ci) | n/a | `tests/scripts/workflows/PublishMcpNpmWorkflow.Tests.ps1` | Mandatory Toolchain Loop; PowerShell formatting, analysis, Pester | CI step conclusions: Format PowerShell, Analyze PowerShell, Test PowerShell all `success`. Log: `Already formatted: ...PublishMcpNpmWorkflow.Tests.ps1`, `PSScriptAnalyzer passed: no findings`, `[+] ...PublishMcpNpmWorkflow.Tests.ps1 103ms`, `Tests Passed: 6743, Failed: 0`. The file contains no `-Skip` or `Set-ItResult`. |
| PA-3 | Minor | n/a | 90 #846 evidence filenames | `.claude/skills/evidence-and-timestamp-conventions/SKILL.md` (timestamp format) | Carried forward from pass 1. Evidence files carry the plan-assigned stamp `2026-10-09T09-00`, while their recorded `Timestamp:` values range from `2026-10-09T20-56` to `2026-10-09T22-05`. This is documented as plan deviation D-9, and the `Timestamp:` field is authoritative. |
| PA-4 | Resolved (was Minor) | n/a | 6 PowerShell evidence files named in pass 1 | Repository practice of host-neutral artifacts | Resolved in `d2732d523`. Seven evidence files had the absolute worktree path replaced with `<worktree>`, and each carries a `Redaction:` line stating that no other content changed; no `Outcome:` or `EXIT_CODE:` line was altered. A case-insensitive search of the feature folder for Windows user-profile path prefixes returns no match in this pass. |
| PA-5 | Minor | n/a | Reviewer action (pass 1) | Review constraint: prefer no-mutation commands | Carried forward. The pass-1 targeted `pytest --cov` run rewrote the gitignored `artifacts/python/lcov.info`. No tracked file changed. This pass ran no coverage generation; it read CI logs only. |
| PA-6 | Nit | n/a | `evidence/baseline/phase0-instructions-read.md` | Evidence filename timestamp convention | Carried forward. The filename has no `yyyy-MM-ddTHH-mm` stamp; the file records `Timestamp: 2026-10-09T20-55`. |

---

## 1. General Unit Test Policy Compliance

### 1.1 Core Principles

| Principle | Status | Evidence |
| --- | --- | --- |
| Independence | PASS | Unchanged since pass 1: local fakes, in-memory YAML, `beforeEach` mock resets, `BeforeAll`-built Pester step blocks. |
| Isolation | PASS | Each new test targets one behavior. |
| Fast execution | PASS | `PublishMcpNpmWorkflow.Tests.ps1` ran in 103 ms in CI; 172 targeted Python tests in 0.98 s (pass 1). |
| Determinism | PASS | No clock, RNG, sleep, or network use in added test code. Green on all four Python matrix jobs and both extension-test operating systems. |
| Readability | PASS | Arrange/Act/Assert comments, descriptive docstrings, and a descriptive `It` title. |

### 1.2 Coverage and Scenarios

- Python whole repository, CI PR head: 93.61% lines; threshold step (line >= 85, branch >= 75) success. Local pass 1: 93.70% lines, 87.97% branches. Changed module `check_quality_tiers.py`: 100% lines, 92.86% branches.
- TypeScript whole extension: 97.16% lines, 91.71% branches. `src/subagent-tree-command.ts`: 100% lines, 95.65% branches.
- PowerShell repository-wide: 87.31% lines (command coverage) on the PR head and on the main tip.
- Scenario completeness: the code-review gap CR-1 (exact QT009 text when stderr is empty) is carried forward as Minor.

### 1.2.1 Per-Language Coverage Comparison

- Python: Baseline: 93.60% lines and 566 partial branches on CI main tip 816b5513a (local baseline 93.68% lines and 87.1% branches) -> Post-change: 93.61% lines and 511 partial branches on CI PR head b9e1f7558 (local 93.70% lines and 87.97% branches). Change: +0.01 percentage points lines on CI, 55 fewer partial branches, no regression. New/changed-code coverage: 100% of changed executable lines (5 of 5 in check_quality_tiers.py). Disposition: PASS. Evidence: `docs/features/active/2026-10-08-bug-burndown-2026-09-29-review-nits-846/evidence/qa-gates/ci-evidence-pr873.2026-10-10T03-00.md`, `docs/features/active/2026-10-08-bug-burndown-2026-09-29-review-nits-846/evidence/qa-gates/py-coverage-comparison.2026-10-09T09-00.md`.
- TypeScript: Baseline: 97.16% lines and 91.70% branches -> Post-change: 97.16% lines and 91.71% branches. Change: 0.00 percentage points lines, +0.01 percentage points branches, no regression; no production TypeScript file changed. Disposition: PASS. Evidence: `docs/features/active/2026-10-08-bug-burndown-2026-09-29-review-nits-846/evidence/qa-gates/ts-coverage-comparison.2026-10-09T09-00.md`.
- PowerShell: Baseline: 87.31% lines over 22,010 commands on CI main tip 816b5513a -> Post-change: 87.31% lines over 22,010 commands on CI PR head b9e1f7558. Change: 0.00 percentage points, no regression; no production PowerShell file changed; branch threshold not applicable (Pester measures no branch coverage). Disposition: PASS. Evidence: `docs/features/active/2026-10-08-bug-burndown-2026-09-29-review-nits-846/evidence/qa-gates/ci-evidence-pr873.2026-10-10T03-00.md`.
- C#: no C# files changed; Disposition: N/A.

### 1.3 Test Structure and Diagnostics

PASS. Unchanged since pass 1.

### 1.4 External Dependencies and Environment

PASS. No added test uses temporary files, subprocesses, sleeps, or network access.

### 1.5 Policy Audit Requirement

This document.

### 1.6 Coverage Exclusion Policy

PASS. `pyproject.toml` adds only the `partial_also` entry under `[tool.coverage.report]`. No `omit`, `exclude`, `exclude_lines`, or `exclude_also` entry is added. The CI statement total rises from 17565 (main tip) to 17571 (PR head), so no statement left the denominator; the increase is consistent with the statements added in `check_quality_tiers.py`. No `jest.config.cjs` or PoshQC coverage-configuration change exists on the branch.

---

## 2. General Code Change Policy Compliance

### 2.1 Before Making Changes

PASS. `evidence/baseline/phase0-instructions-read.md` and `evidence/baseline/*`.

### 2.2 Design Principles

PASS. Unchanged since pass 1.

### 2.3 Module and File Structure

PASS. The largest changed code file is 449 lines (`tests/scripts/dev_tools/test_check_quality_tiers.py`). No code file changed since pass 1. Tests live under `tests/` and `extensions/drm-copilot/test/`.

### 2.4 Naming, Docs, and Comments

PASS. Unchanged since pass 1.

### 2.5 After Making Changes - Toolchain Execution

- Python: PASS. Local single-pass loop (`evidence/qa-gates/py-loop-summary.2026-10-09T09-00.md`). CI Black, Ruff, Pyright, tier-classification, Pytest, and threshold steps all `success` on the PR head.
- TypeScript: PASS. Local loop (`evidence/qa-gates/ts-loop-summary.2026-10-09T09-00.md`). CI extension tests (ubuntu, windows) `SUCCESS`.
- PowerShell: PASS. CI Format, Analyze, and Test steps all `success` on the PR head (PA-2 resolved).
- Architecture-boundary, contract, and integration stages: not configured for these files (`evidence/qa-gates/py-stages-not-applicable`, `ts-stages-not-applicable`).

### 2.6 Summarize and Document

PASS. `evidence/other/closure-dispositions.2026-10-09T09-00.md` records 27 dispositions. The #338 A1 row now carries the appended CI run result (run 38017787058, threshold step success).

---

## 3. Language-Specific Code Change Policy Compliance

### Section 3A: Python Code Change Policy Compliance

PASS. Type annotations are present, pyright strict reports 0 errors (local and CI), and no suppressions were added.

### Section 3B: TypeScript Code Change Policy Compliance

PASS. The support module uses `import type` for mocked modules. No `any` was added.

### Section 3C: PowerShell Code Change Policy Compliance

PASS. CI Invoke-Formatter reports no change and PSScriptAnalyzer reports no findings across the repository. `Set-StrictMode -Version Latest` is retained.

---

## 4. Language-Specific Unit Test Policy Compliance

### Section 4A: Python Unit Test Policy Compliance

PASS. Fail-before evidence is recorded for the QT009 stderr test and the skill-sentence pin.

### Section 4B: TypeScript Unit Test Policy Compliance

PASS. 14 `it` blocks are preserved across the split.

### Section 4C: PowerShell Unit Test Policy Compliance

PASS. The new `It` block and the tightened assertions pass in CI. A fail-before run would require a workflow edit, which is out of scope; `evidence/regression-testing/fail-before-exception.2026-10-09T09-00.md` records this exception.

---

## 5. Test Coverage Detail

### `list_tracked_files` (`scripts/dev_tools/check_quality_tiers.py`) (2 added tests)

- `test_qt009_message_includes_git_stderr`, `test_qt009_message_collapses_multiline_git_stderr`. The empty-stderr arc is exercised by the existing nonzero-exit test.

### `parse_quality_tiers` (`scripts/dev_tools/quality_tiers_contract.py`) (1 added test, 3 added matrix rows)

- 100% lines and branches.

### Acceptance-criteria-tracking skill sentence (1 parametrized test, 3 ids)

- Passes locally and in CI.

### `publish-mcp-npm.yml` invariants (1 added `It`, 3 tightened assertion pairs)

- Passes in CI (`[+] ...PublishMcpNpmWorkflow.Tests.ps1`).

## 6. Test Execution Metrics

| Suite | Result | Source |
| --- | --- | --- |
| Python whole repository (CI 3.12, PR head) | 6741 passed, 6 skipped | CI job 114111830945 |
| Python whole repository (local) | 6731 passed, 6 skipped | `evidence/qa-gates/py-cov-whole-repo.2026-10-09T09-00.md` |
| Jest whole extension (local) | 3925 tests, 258 suites, exit 0 | `evidence/qa-gates/ts-jest-coverage.2026-10-09T09-00.md` |
| Extension tests (CI ubuntu, windows) | SUCCESS | PR #873 status check rollup |
| Pester repository-wide (CI, PR head) | 6743 passed, 0 failed, 10 skipped | CI job 114111830920 |

## 7. Code Quality Checks

| Check | Result | Source |
| --- | --- | --- |
| Black / Ruff / Pyright (CI, PR head) | success | CI job 114111830945 step conclusions |
| Prettier / ESLint (3 TS test files) | exit 0 | pass-1 reviewer re-run |
| npm run typecheck | exit 0 | `evidence/qa-gates/ts-typecheck.2026-10-09T09-00.md` |
| Invoke-Formatter (CI) | `Already formatted` for the test file | CI job 114111830920 |
| PSScriptAnalyzer (CI) | no findings | CI job 114111830920 |
| validate_evidence_locations.py | exit 0 | this pass |

## 8. Gaps and Exceptions

### Identified Gaps

- None blocking. PA-3, PA-5, PA-6 are non-blocking record-keeping items.

### Approved Exceptions

- Spec assumption A7: the CI `poshqc` job is authoritative when local Pester is blocked. Applied in this pass with the CI result in hand.

### Removed/Skipped Tests

- None. The 10 Pester skips are pre-existing and occur outside the changed test file.

## 9. Summary of Changes

### Files Modified

- Production Python (2): `scripts/dev_tools/check_quality_tiers.py`, `scripts/dev_tools/potential_to_issue.py`.
- Configuration (1): `pyproject.toml`.
- Python tests (5), TypeScript tests (3), PowerShell tests (1), as listed in pass 1.
- Markdown: six skill copies, CHANGELOG, runbook, corrections in seven other feature folders, and #846 feature documents, evidence, and review artifacts.
- This pass writes: `evidence/qa-gates/ci-evidence-pr873.2026-10-10T03-00.md`; the #338 A1 append in `evidence/other/closure-dispositions.2026-10-09T09-00.md`; four checkbox changes in `spec.md`; four task checkboxes and the Status line in `plan.2026-10-08T23-42.md`; and the three `.2026-10-10T03-00.md` review artifacts.
- Protected files untouched: `orchestration-handoff-authority-service.test.ts`, `.github/workflows/**`, `jest.config.cjs`, `tsconfig.jest.json`, `.gitignore`, `test_potential_to_issue_filesystem.py`. No deletions or renames.

## 10. Compliance Verdict

### Overall Status: PASS

### Policy-by-Policy Summary

| Policy | Verdict |
| --- | --- |
| General unit test | PASS (Python, TypeScript, PowerShell) |
| General code change | PASS (Python, TypeScript, PowerShell) |
| Python code change and unit test | PASS |
| TypeScript code change and unit test | PASS |
| PowerShell code change and unit test | PASS |
| Coverage Exclusion Policy | PASS |
| File size limit | PASS |
| Evidence location | PASS |
| Tonality | PASS |

### Metrics Summary

- Blocking: 0 (PA-1 and PA-2 resolved by CI run 38017787058).
- Minor: 2 (PA-3, PA-5). Nit: 1 (PA-6). Resolved: PA-1, PA-2, PA-4.

### Recommendation

No remediation is required before merge. PA-3, PA-5, and PA-6 are record-keeping observations that do not block merge.

## Appendix A: Test Inventory

- Added Python tests: `test_qt009_message_includes_git_stderr`, `test_qt009_message_collapses_multiline_git_stderr`, `test_parse_quality_tiers_non_scalar_key_reports_qt002`, `test_acceptance_criteria_tracking_skill_cross_references_ci_dependent_exception[claude|agents|github]`; QT003 params `version-bool`, `version-string`, `missing-projects`.
- Renamed Python test: `test_find_classification_errors_empty_project_set_reports_qt007_for_every_entry` -> `test_find_classification_errors_empty_projects_reports_qt007`.
- Moved Python tests: 10 into `test_quality_tiers_contract_classification.py`. Moved TypeScript tests: 4 into `subagent-tree-command.quick-pick.test.ts`.
- Added Pester `It`: "runs the registry poll step only after a successful publish step".

## Appendix B: Toolchain Commands Reference

- `gh pr view 873 --repo drmoisan/drm-copilot --json headRefOid,state,headRefName,statusCheckRollup`
- `gh run view 38017787058 --repo drmoisan/drm-copilot --job 114111830920 --log`
- `gh run view 38017787058 --repo drmoisan/drm-copilot --job 114111830945 --log`
- `gh api repos/drmoisan/drm-copilot/actions/jobs/114111830920` and `.../114111830945` (step conclusions, `head_sha`)
- `gh api "repos/drmoisan/drm-copilot/actions/runs/38017787058/jobs?per_page=100"` (threshold step across matrix jobs)
- `gh run view 38017407907 --repo drmoisan/drm-copilot --job 114110654807 --log` and `--job 114110654867 --log` (main-tip baseline)
- `git diff --name-only origin/main...HEAD`; `git diff --name-only d2732d523 b9e1f7558 -- <branch directories>`
- `git grep -n -F -e "Should -Match '(?m)^\s*exit 1\s*$'" -- tests/scripts/workflows/PublishMcpNpmWorkflow.Tests.ps1` (exit 1, no match)
- `poetry run python scripts/dev_tools/validate_evidence_locations.py --root .`
