# Policy Compliance Audit: bug-burndown-2026-09-29 review nits (#846)

---

**Audit Date:** 2026-10-09 (host clock `2026-10-09T22-16` local; the filename stamp `2026-10-10T02-15` was assigned by the caller and corresponds to the same moment in UTC)
**Review pass:** 1
**Branch:** `bug/bug-burndown-2026-09-29-review-nits-846` (no PR exists yet; `gh pr list --head` returned `[]`)
**Local HEAD at review time:** `396f598b31e6f790b249c6cc4f2e0260ed7b407a` (working tree clean)
**Base:** `main`; merge-base and current `origin/main` tip `311dea0548cb2e2fe57259aec6e1e3a06a9bdd2a`. `main` was merged into the branch at `fe8de4c47`, so `git diff 311dea054..HEAD` shows only this branch's work (127 files, 4964 insertions, 406 deletions; statuses A and M only).
**Work mode:** `full-bug` (AC source: `spec.md` only)
**Code Under Test:** production Python `scripts/dev_tools/check_quality_tiers.py` (QT009 stderr detail, `GitRunResult.stderr`) and `scripts/dev_tools/potential_to_issue.py` (docstring and comment only); `pyproject.toml` (`partial_also`); Python tests (quality-tiers split, QT009 tests, completion-gate documentation pin); TypeScript test split (`extensions/drm-copilot/test/subagent-tree-command*.ts`); Pester test `tests/scripts/workflows/PublishMcpNpmWorkflow.Tests.ps1`; six acceptance-criteria-tracking `SKILL.md` copies; CHANGELOG; runbook; documentation and evidence corrections in the #338, #510, #543, #609, #623, #744, #764 feature folders.

**Coverage Metrics by Language:**

| Language | Files Changed | Tests | Test Result | Baseline Coverage | Post-Change Coverage | New Code Coverage |
|----------|--------------|-------|-------------|-------------------|---------------------|-------------------|
| Python | 2 production (`check_quality_tiers.py`, `potential_to_issue.py`), 5 test files (1 new support module, 1 new test module, 3 modified) | Whole repository 6731 passed, 6 skipped (baseline 6722 passed); reviewer re-run of 8 targeted files: 172 passed | PASS | 93.68% lines, 87.1% branches (whole repository, `evidence/baseline/py-cov-whole-repo.2026-10-09T09-00.md`) | 93.70% lines (16464/17571), 87.97% branches (5579/6342) from `artifacts/python/lcov.info`; threshold script exit 0 on `artifacts/python/coverage.json` | 100% of changed executable lines (5 of 5 in `check_quality_tiers.py`); `potential_to_issue.py` has no changed executable line |
| TypeScript | 3 test files (1 modified, 2 new); 0 production files | 3925 tests in 258 suites (baseline 3925 in 257); reviewer re-run `subagent-tree-command`: 2 suites, 14 passed | PASS | 97.16% lines, 91.70% branches (`evidence/baseline/ts-jest-coverage.2026-10-09T09-00.md`) | 97.16% lines (51037/52524), 91.71% branches (7524/8204) from `extensions/drm-copilot/coverage/lcov.info` | N/A (no production TypeScript file changed) |
| PowerShell | 1 test file (`PublishMcpNpmWorkflow.Tests.ps1`); 0 production files | 11 `It` blocks after the change (10 before); not executed locally | Not executed locally; CI `poshqc / PowerShell QC` pending | 96.1% lines (10592/11018) from the primary checkout's last full-repository Pester artifact, written 2026-09-29 20:39 (not a branch baseline) | 0.0% lines (0/11890) in the worktree `artifacts/pester/powershell-coverage.xml`, written 2026-10-09 22:00 by a PoshQC MCP run scoped to `tests/scripts/workflows`; not a repository-wide figure | N/A (no production PowerShell file changed) |
| C# | 0 files | N/A | N/A | N/A (no C# files changed) | N/A (no C# files changed) | N/A |
| Markdown | 115 files (skills, CHANGELOG, runbook, feature documents, evidence) | N/A | N/A | N/A (documentation) | N/A (documentation) | N/A |

### Coverage Evidence Checklist

- Python baseline coverage artifact: `docs/features/active/2026-10-08-bug-burndown-2026-09-29-review-nits-846/evidence/baseline/py-cov-whole-repo.2026-10-09T09-00.md` (93.68% lines, 87.1% branches)
- Python post-change coverage artifact: `artifacts/python/coverage.json` (written 21:55, threshold script exit 0 in this review) and `docs/features/active/2026-10-08-bug-burndown-2026-09-29-review-nits-846/evidence/qa-gates/py-cov-whole-repo.2026-10-09T09-00.md`
- TypeScript baseline coverage artifact: `docs/features/active/2026-10-08-bug-burndown-2026-09-29-review-nits-846/evidence/baseline/ts-jest-coverage.2026-10-09T09-00.md` (97.16% lines, 91.70% branches)
- TypeScript post-change coverage artifact: `extensions/drm-copilot/coverage/lcov.info` (written 21:58) and `docs/features/active/2026-10-08-bug-burndown-2026-09-29-review-nits-846/evidence/qa-gates/ts-jest-coverage.2026-10-09T09-00.md`
- PowerShell baseline coverage artifact: primary checkout `artifacts/pester/powershell-coverage.xml` written 2026-09-29 20:39, 96.1% lines (10592/11018); no branch-specific baseline was recorded because local Pester was unavailable (`evidence/baseline/ps-pester-workflow.2026-10-09T09-00.md`)
- PowerShell post-change coverage artifact: worktree `artifacts/pester/powershell-coverage.xml` written 2026-10-09 22:00 reports 0.0% lines (0/11890) because the run was scoped to `tests/scripts/workflows`; the CI `poshqc / PowerShell QC` artifact for the PR head is the authoritative post-change figure and does not exist yet
- Per-language comparison summary: Section 1.2.1 of this document

**Non-negotiable verdict rule:** No policy audit may report PASS unless it includes numeric baseline and post-change coverage metrics for every language in scope, plus changed/new-code coverage when required.

**Fail-closed rule:** If any required baseline artifact, QA artifact, or coverage-comparison artifact is absent, the verdict must be BLOCKED or INCOMPLETE, never PASS.

**Evidence rule:** Do not synthesize or backfill audit evidence from memory or inference. If evidence is absent, stop and list the exact artifact paths.

---

## Executive Summary

The branch closes 26 accepted Minor/Nit findings from the `bug-burndown-2026-09-29` reviews plus one follow-up row. The only runtime behavior change is the QT009 message in `scripts/dev_tools/check_quality_tiers.py`, which now appends whitespace-collapsed git stderr. The remaining changes are test-file splits (Python and TypeScript), new regression tests, a coverage reporting setting (`partial_also`), a Pester tightening, and documentation and evidence corrections.

Python and TypeScript policy compliance was verified by re-running checks in this review: black, ruff, and pyright on all changed Python files exit 0; 172 targeted Python tests pass with `check_quality_tiers.py` at 100% lines and `quality_tiers_contract.py` at 100% lines and branches; the Python threshold script exits 0 on the whole-repository report; the two split Jest suites pass 14 of 14; Prettier and ESLint on the three TypeScript test files exit 0. All changed code files are at most 449 lines.

The PowerShell test file was not formatted, analyzed, or executed locally, because the executor and this reviewer have no PowerShell tool and the operator forbids pwsh wrappers through Bash. PowerShell coverage at the branch head is therefore not established by a repository-wide artifact. Both items are Blocking with remediability `awaiting_ci`: they resolve on a green CI `poshqc / PowerShell QC` job for the PR head and require no code change from the evidence available. No Blocking finding is `autonomous`.

Overall verdict: **BLOCKED (awaiting_ci)**. 2 Blocking findings, both `awaiting_ci`; 3 Minor; 1 Nit.

## Rejected Scope Narrowing

No scope narrowing was detected in the caller prompt. The caller's scope list enumerates the same file set as `git diff 311dea054..HEAD --stat` and does not exclude any language from toolchain or coverage checks. The caller instruction to classify CI-dependent findings as `awaiting_ci` is a classification rule, not a scope reduction; PowerShell coverage and toolchain are still evaluated below with explicit PASS/FAIL verdicts.

## Evidence Location Compliance

- `poetry run python scripts/dev_tools/validate_evidence_locations.py --root .` exited 0 in this review.
- The branch diff contains no path under `artifacts/baselines/`, `artifacts/qa/`, `artifacts/evidence/`, or `artifacts/coverage/`.
- All #846 evidence is under `docs/features/active/2026-10-08-bug-burndown-2026-09-29-review-nits-846/evidence/{baseline,regression-testing,qa-gates,other}/`. The two superseding notes in the #609 and #764 folders are under those items' `evidence/other/`, as the spec allows.
- No `EVIDENCE_LOCATION_OVERRIDE_REJECTED` event occurred.
- Verdict: PASS.

## Findings

| ID | Severity | Remediability | Location | Rule | Evidence |
| --- | --- | --- | --- | --- | --- |
| PA-1 | Blocking | awaiting_ci | PowerShell coverage at branch head | Coverage Verification (agent contract); `.claude/rules/quality-tiers.md` uniform line >= 85% | Worktree Pester artifact is a scoped run (0/11890 lines); no repository-wide PowerShell artifact exists for HEAD `396f598b3`. No production PowerShell file changed, so changed-line no-regression holds vacuously; the last full artifact (primary checkout, 2026-09-29) reports 96.1%. Resolves on the CI `poshqc` coverage artifact for the PR head. |
| PA-2 | Blocking | awaiting_ci | `tests/scripts/workflows/PublishMcpNpmWorkflow.Tests.ps1` | Mandatory Toolchain Loop (`.claude/rules/general-code-change.md`); PowerShell formatting/analysis/Pester | `evidence/qa-gates/ps-formatter-check`, `ps-analyzer`, `ps-pester` (all `2026-10-09T09-00`) record `Outcome: LOCAL-PESTER-UNAVAILABLE`. Static reading in this review found the new assertions consistent with `.github/workflows/publish-mcp-npm.yml` lines 71-135. Resolves on a green CI `poshqc / PowerShell QC` job (Format, Analyze, Test steps). |
| PA-3 | Minor | n/a | 90 #846 evidence filenames | `.claude/skills/evidence-and-timestamp-conventions/SKILL.md` (timestamp format) | Every new evidence file carries the plan-assigned stamp `2026-10-09T09-00` while recorded `Timestamp:` values range from `2026-10-09T20-56` to `2026-10-09T22-05`. This is documented as plan deviation D-9 (`plan.2026-10-08T23-42.md` line 19) and the `Timestamp:` field is authoritative, so no rule is broken; it repeats the #764 filename-stamp pattern that this branch closes by a superseding note. |
| PA-4 | Minor | n/a | 6 evidence files: `evidence/baseline/ps-analyzer`, `evidence/baseline/ps-pester-workflow`, `evidence/qa-gates/ps-analyzer`, `evidence/qa-gates/ps-formatter-check`, `evidence/qa-gates/ps-pester`, `evidence/regression-testing/pester-workflow-after` | Repository practice of host-neutral artifacts | 12 occurrences of the absolute host path of the agent worktree (user profile directory) in recorded MCP commands and results. Host-dependent values make the records non-portable and disclose local account data. |
| PA-5 | Minor | n/a | Reviewer action | Review constraint: prefer no-mutation commands | The reviewer's targeted `pytest --cov` run rewrote the gitignored `artifacts/python/lcov.info` (pyproject emits LCOV by default). Whole-repository totals (93.70% / 87.97%) were read from that file before the run, and `artifacts/python/coverage.json` (21:55) was not changed. No tracked file changed. |
| PA-6 | Nit | n/a | `evidence/baseline/phase0-instructions-read.md` | Evidence filename timestamp convention | The filename has no `yyyy-MM-ddTHH-mm` stamp; the file records `Timestamp: 2026-10-09T20-55`. |

---

## 1. General Unit Test Policy Compliance

### 1.1 Core Principles

| Principle | Status | Evidence |
| --- | --- | --- |
| Independence | PASS | New Python tests build local fakes (`FakeRunResult`, in-memory YAML strings); Jest suites reset mocks in `beforeEach`; the Pester `It` reads `$script:` step blocks built once in `BeforeAll`. |
| Isolation | PASS | Each new test targets one behavior (QT009 single-line stderr, multi-line collapse, non-scalar key QT002, QT003 matrix rows, sentence pin per skill copy). |
| Fast execution | PASS | 172 targeted Python tests in 0.98 s in this review. |
| Determinism | PASS | No clock, RNG, sleep, or network use in added test code. The Pester file assembles the sleep cmdlet name from fragments only as a search token (pre-existing). |
| Readability | PASS | Arrange/Act/Assert comments and descriptive docstrings on all new Python tests; descriptive `It` title on the new Pester block. |

### 1.2 Coverage and Scenarios

- Python whole repository: 93.70% lines, 87.97% branches (>= 85 / 75). Changed modules: `check_quality_tiers.py` 100% lines, 92.86% branches (13/14; the one partial arc `157->160` is in `main` and pre-exists as `146->149`); `potential_to_issue.py` 99.26% lines, 97.37% branches (unchanged statement; docstring and comment only); `quality_tiers_contract.py` 100% / 100% (up from 98.43% / 96.15%).
- TypeScript whole extension: 97.16% lines, 91.71% branches. `src/subagent-tree-command.ts` 100% lines (211/211), 95.65% branches (22/23).
- PowerShell: see PA-1.
- Scenario completeness: QT009 covers empty (existing test), single-line, and multi-line stderr; QT003 matrix adds `version-bool`, `version-string`, `missing-projects`; QT002 adds the non-scalar key. Gap recorded in the code review (CR-1): no test asserts the exact unchanged message text when stderr is empty or whitespace-only.

### 1.2.1 Per-Language Coverage Comparison

- Python: Baseline: 93.68% lines and 87.1% branches -> Post-change: 93.70% lines and 87.97% branches. Change: +0.02 percentage points lines, +0.87 percentage points branches, no regression. New/changed-code coverage: 100% of changed executable lines (5 of 5 in check_quality_tiers.py lines 101-105). Disposition: PASS. Evidence: `docs/features/active/2026-10-08-bug-burndown-2026-09-29-review-nits-846/evidence/qa-gates/py-coverage-comparison.2026-10-09T09-00.md`, `artifacts/python/coverage.json`.
- TypeScript: Baseline: 97.16% lines and 91.70% branches -> Post-change: 97.16% lines and 91.71% branches. Change: 0.00 percentage points lines, +0.01 percentage points branches, no regression; no production TypeScript file changed. Disposition: PASS. Evidence: `docs/features/active/2026-10-08-bug-burndown-2026-09-29-review-nits-846/evidence/qa-gates/ts-coverage-comparison.2026-10-09T09-00.md`, `extensions/drm-copilot/coverage/lcov.info`.
- PowerShell: Baseline: 96.1% lines (primary checkout full-repository artifact, 2026-09-29) -> Post-change: 0.0% lines (worktree artifact from a run scoped to tests/scripts/workflows, not repository-wide). Change: not comparable because the post-change run measured no production population; no production PowerShell file changed. Disposition: FAIL (awaiting_ci; resolves on the CI poshqc coverage artifact for the PR head). Evidence: `artifacts/pester/powershell-coverage.xml`, `docs/features/active/2026-10-08-bug-burndown-2026-09-29-review-nits-846/evidence/qa-gates/ps-coverage-not-applicable.2026-10-09T09-00.md`.
- C#: no C# files changed; Disposition: N/A.

### 1.3 Test Structure and Diagnostics

PASS. New assertions include failure messages (`f"expected one QT009 line: {lines}"`, `_assert_section_contains` diagnostics). Pester assertions use `Should -Be 1` on match counts, which reports the observed count on failure.

### 1.4 External Dependencies and Environment

PASS. No added test uses `tempfile`, `tmp_path`, `subprocess`, `time.sleep`, network, or temporary files. The two committed-tree quality-tiers tests read `quality-tiers.yml` read-only (pre-existing, moved). The Pester suite reads the workflow file read-only (pre-existing).

### 1.5 Policy Audit Requirement

This document.

### 1.6 Coverage Exclusion Policy

PASS. `pyproject.toml` adds only `partial_also = ["^\\s*(async\\s+)?def\\s.*:\\s*\\.\\.\\.\\s*(#.*)?$"]` under `[tool.coverage.report]`. This setting changes how the def-to-exit arc of a one-line declaration-only `def ...: ...` is reported; it is not an `omit`, `exclude`, `exclude_lines`, or `exclude_also` entry, and no statement leaves the denominator (Stmts unchanged in `evidence/regression-testing/partial-also-after.2026-10-09T09-00.md`). No `jest.config.cjs` change exists on the branch.

---

## 2. General Code Change Policy Compliance

### 2.1 Before Making Changes

PASS. `evidence/baseline/phase0-instructions-read.md` records the policy reading order; baselines for every stage were captured before edits (`evidence/baseline/*`).

### 2.2 Design Principles

PASS. The QT009 change is a five-line edit inside the existing failure branch with a comment explaining why stderr is collapsed. The `GitRunResult` Protocol gains a read-only `stderr` property, which `subprocess.CompletedProcess` already provides. Test helpers were factored into support modules rather than duplicated.

### 2.3 Module and File Structure

PASS. Largest changed code file: `tests/scripts/dev_tools/test_check_quality_tiers.py` 449 lines. Others: `scripts/dev_tools/potential_to_issue.py` 443, `test_completion_gate_documentation_contracts.py` 423, `subagent-tree-command.test.ts` 335, `test_quality_tiers_contract.py` 322, `PublishMcpNpmWorkflow.Tests.ps1` 247, `subagent-tree-command.quick-pick.test.ts` 221, `check_quality_tiers.py` 204, `test_quality_tiers_contract_classification.py` 199, `subagent-tree-command-test-support.ts` 70, `quality_tiers_contract_test_support.py` 20 (counted with `wc -l` in this review). Tests live under `tests/` and `extensions/drm-copilot/test/`; no colocation.

### 2.4 Naming, Docs, and Comments

PASS. Public test helpers `qt_codes`, `make_manifest` have docstrings. `PromotionOutcome.exit_code` docstring now documents 0 / gh exit code / 1, matching `promotion.ts`.

### 2.5 After Making Changes - Toolchain Execution

- Python: PASS. Executor single-pass loop recorded in `evidence/qa-gates/py-loop-summary.2026-10-09T09-00.md`; this review re-ran black (7 files unchanged), ruff (all checks passed), pyright (0 errors) on the changed files.
- TypeScript: PASS. Executor loop in `evidence/qa-gates/ts-loop-summary.2026-10-09T09-00.md`; this review re-ran Prettier and ESLint on the three test files (exit 0) and the two Jest suites (14 passed).
- PowerShell: FAIL (awaiting_ci), PA-2.
- Architecture-boundary, contract, and integration stages: not configured for these files (`evidence/qa-gates/py-stages-not-applicable`, `ts-stages-not-applicable`).

### 2.6 Summarize and Document

PASS. `evidence/other/closure-dispositions.2026-10-09T09-00.md` records 27 dispositions; `evidence/qa-gates/closure-paths-exist.2026-10-09T09-00.md` shows all 36 cited paths exist.

---

## 3. Language-Specific Code Change Policy Compliance

### Section 3A: Python Code Change Policy Compliance

PASS. Type annotations on all new functions and tests (`-> None` on the renamed CR-1 test). pyright strict reports 0 errors. No suppressions added. Errors raised are specific (`OSError` with code and detail).

### Section 3B: TypeScript Code Change Policy Compliance

PASS. The support module uses `import type` for `TerminalWriter` and `FileTimes` and has no runtime import of `vscode`, `../src/command-runtime`, or `../src/terminal-writer`, so the per-file `jest.mock` registrations remain effective. No `any` added.

### Section 3C: PowerShell Code Change Policy Compliance

Static review only (PA-2). The added code uses `[regex]::Matches(...).Count`, `Should -Be`, `Should -Match`, `Should -Not -Match`, and `Should -BeGreaterThan`; `Set-StrictMode -Version Latest` remains at the top. No `Start-Sleep` literal, `New-TemporaryFile`, or `$env:TEMP` added.

---

## 4. Language-Specific Unit Test Policy Compliance

### Section 4A: Python Unit Test Policy Compliance

PASS. pytest with `pytest.param` ids for new matrix rows; `capsys` for stderr; fail-before evidence recorded for the QT009 stderr test (`evidence/regression-testing/qt009-fail-before.2026-10-09T09-00.md`) and the skill sentence pin (`ac-pin-fail-before`).

### Section 4B: TypeScript Unit Test Policy Compliance

PASS. Tests moved verbatim; `jest.mock` blocks remain per file as Jest requires. 14 `it` blocks preserved (10 kept, 4 moved).

### Section 4C: PowerShell Unit Test Policy Compliance

Static review only (PA-2). The new `It` block pins default `success()` gating of the poll step, absence of `continue-on-error` on the publish step, and step order. A fail-before run is not possible without a workflow edit, which is out of scope; `evidence/regression-testing/fail-before-exception.2026-10-09T09-00.md` records this.

---

## 5. Test Coverage Detail

### `list_tracked_files` (`scripts/dev_tools/check_quality_tiers.py`) (2 added tests)

- `test_qt009_message_includes_git_stderr`: single-line stderr appears on one `QT009: ` line.
- `test_qt009_message_collapses_multiline_git_stderr`: two-line stderr collapses to `fatal: first line hint: second line`.
- Existing `test_main_returns_one_with_qt009_when_git_exits_nonzero` exercises the empty-stderr arc via the `stderr: bytes = b""` default.

### `parse_quality_tiers` (`scripts/dev_tools/quality_tiers_contract.py`) (1 added test, 3 added matrix rows)

- `test_parse_quality_tiers_non_scalar_key_reports_qt002`; QT003 rows `version-bool`, `version-string`, `missing-projects`. Lines formerly at 124, 155, 199 are no longer reported as uncovered (100% / 100%).

### Acceptance-criteria-tracking skill sentence (1 parametrized test, 3 ids)

- `test_acceptance_criteria_tracking_skill_cross_references_ci_dependent_exception` over the `.claude`, `.agents`, `.github` source copies; mirror equality is covered by the existing `test_edited_surface_matches_bundled_mirror`.

### `publish-mcp-npm.yml` invariants (1 added `It`, 3 tightened assertion pairs)

- See PA-2 for execution status.

## 6. Test Execution Metrics

| Suite | Result | Source |
| --- | --- | --- |
| Python whole repository | 6731 passed, 6 skipped | `evidence/qa-gates/py-cov-whole-repo.2026-10-09T09-00.md` |
| Python targeted (8 files, this review) | 172 passed in 0.98 s | reviewer re-run |
| Jest whole extension | 3925 tests, 258 suites, exit 0 | `evidence/qa-gates/ts-jest-coverage.2026-10-09T09-00.md` |
| Jest `subagent-tree-command` (this review) | 2 suites, 14 passed | reviewer re-run |
| Pester `PublishMcpNpmWorkflow.Tests.ps1` | not executed locally | `evidence/qa-gates/ps-pester.2026-10-09T09-00.md` |

## 7. Code Quality Checks

| Check | Result | Source |
| --- | --- | --- |
| black --check (changed files) | 7 files unchanged | reviewer re-run |
| ruff check (changed files) | All checks passed | reviewer re-run |
| pyright (changed files) | 0 errors, 0 warnings | reviewer re-run |
| black / ruff / pyright (whole repository) | exit 0 | `evidence/qa-gates/py-black-check`, `py-ruff-check`, `py-pyright` |
| Prettier (3 TS test files) | all files use Prettier style | reviewer re-run |
| ESLint (3 TS test files) | exit 0 | reviewer re-run |
| npm run typecheck (includes `typecheck:test`) | exit 0 | `evidence/qa-gates/ts-typecheck.2026-10-09T09-00.md` |
| Invoke-Formatter / PSScriptAnalyzer | not executed locally | PA-2 |
| validate_evidence_locations.py | exit 0 | reviewer re-run |

## 8. Gaps and Exceptions

### Identified Gaps

- PA-1 and PA-2 (PowerShell coverage and toolchain): pending CI `poshqc / PowerShell QC` on the PR head.
- The PR does not exist yet, so no CI result exists for any CI-dependent criterion.

### Approved Exceptions

- Spec assumption A7 designates the CI `poshqc` job as authoritative when local Pester is blocked. This defers, but does not waive, the PowerShell gates.

### Removed/Skipped Tests

- None. 28 pre-split quality-tiers test names are all present after the split (one renamed per CR-1), plus one new test; verified name by name in this review.

## 9. Summary of Changes

### Files Modified

- Production Python (2): `scripts/dev_tools/check_quality_tiers.py`, `scripts/dev_tools/potential_to_issue.py`.
- Configuration (1): `pyproject.toml`.
- Python tests (5): `test_quality_tiers_contract.py`, `test_quality_tiers_contract_classification.py` (new), `quality_tiers_contract_test_support.py` (new), `test_check_quality_tiers.py`, `test_completion_gate_documentation_contracts.py`.
- TypeScript tests (3): `subagent-tree-command.test.ts`, `subagent-tree-command.quick-pick.test.ts` (new), `subagent-tree-command-test-support.ts` (new).
- PowerShell tests (1): `tests/scripts/workflows/PublishMcpNpmWorkflow.Tests.ps1`.
- Markdown (115): six skill copies, CHANGELOG, runbook, corrections in seven other feature folders, and #846 feature documents and evidence.
- Protected files untouched (verified with `git diff --name-status 311dea054..HEAD`): `orchestration-handoff-authority-service.test.ts`, `.github/workflows/**`, `jest.config.cjs`, `tsconfig.jest.json`, `.gitignore`, `test_potential_to_issue_filesystem.py`. No deletions or renames.

## 10. Compliance Verdict

### Overall Status: BLOCKED (awaiting_ci)

### Policy-by-Policy Summary

| Policy | Verdict |
| --- | --- |
| General unit test | PASS for Python and TypeScript; PowerShell coverage FAIL (awaiting_ci, PA-1) |
| General code change | PASS for Python and TypeScript; PowerShell toolchain FAIL (awaiting_ci, PA-2) |
| Python code change and unit test | PASS |
| TypeScript code change and unit test | PASS |
| PowerShell code change and unit test | FAIL (awaiting_ci, PA-2) |
| Coverage Exclusion Policy | PASS |
| File size limit | PASS |
| Evidence location | PASS |
| Tonality | PASS |

### Metrics Summary

- Blocking: 2 (PA-1, PA-2), both `awaiting_ci`; autonomous Blocking: 0.
- Minor: 3 (PA-3, PA-4, PA-5). Nit: 1 (PA-6).

### Recommendation

Open the PR and obtain a green `poshqc / PowerShell QC` job on the PR head. Confirm the uploaded `artifacts/pester/powershell-coverage.xml` reports repository-wide line coverage >= 85%, then treat PA-1 and PA-2 as resolved. No code remediation is indicated by the available evidence. PA-3 through PA-6 do not block merge.

## Appendix A: Test Inventory

- Added Python tests: `test_qt009_message_includes_git_stderr`, `test_qt009_message_collapses_multiline_git_stderr`, `test_parse_quality_tiers_non_scalar_key_reports_qt002`, `test_acceptance_criteria_tracking_skill_cross_references_ci_dependent_exception[claude|agents|github]`; QT003 params `version-bool`, `version-string`, `missing-projects`.
- Renamed Python test: `test_find_classification_errors_empty_project_set_reports_qt007_for_every_entry` -> `test_find_classification_errors_empty_projects_reports_qt007`.
- Moved Python tests: 10 classification and committed-tree tests into `test_quality_tiers_contract_classification.py`.
- Moved TypeScript tests: 4 quick-pick `it` blocks into `subagent-tree-command.quick-pick.test.ts`.
- Added Pester `It`: "runs the registry poll step only after a successful publish step".

## Appendix B: Toolchain Commands Reference

Changed Python files used below: `scripts/dev_tools/check_quality_tiers.py`, `scripts/dev_tools/potential_to_issue.py`, `tests/scripts/dev_tools/test_quality_tiers_contract.py`, `tests/scripts/dev_tools/test_quality_tiers_contract_classification.py`, `tests/scripts/dev_tools/quality_tiers_contract_test_support.py`, `tests/scripts/dev_tools/test_check_quality_tiers.py`, `tests/scripts/dev_tools/test_completion_gate_documentation_contracts.py`.

TypeScript test files used below: `extensions/drm-copilot/test/subagent-tree-command.test.ts`, `extensions/drm-copilot/test/subagent-tree-command.quick-pick.test.ts`, `extensions/drm-copilot/test/subagent-tree-command-test-support.ts`.

- `poetry run black --check` on the changed Python files
- `poetry run ruff check` on the changed Python files
- `poetry run pyright` on the changed Python files
- `poetry run pytest tests/scripts/dev_tools/test_quality_tiers_contract.py tests/scripts/dev_tools/test_quality_tiers_contract_classification.py tests/scripts/dev_tools/test_check_quality_tiers.py tests/scripts/dev_tools/test_completion_gate_documentation_contracts.py tests/scripts/dev_tools/test_minor_audit_acceptance_criteria_contracts.py tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py tests/scripts/dev_tools/test_workflow_npm_token_guard.py "tests/scripts/dev_tools/test_potential_to_issue_move_verification.py" --cov=scripts.dev_tools.quality_tiers_contract --cov=scripts.dev_tools.check_quality_tiers --cov-branch --cov-report=term-missing`
- `poetry run python -m scripts.dev_tools.check_python_coverage_thresholds --report artifacts/python/coverage.json --min-line 85 --min-branch 75`
- `npm --prefix extensions/drm-copilot run test:unit -- subagent-tree-command`
- `npx --prefix extensions/drm-copilot prettier --check` on the TypeScript test files
- `npx --prefix extensions/drm-copilot eslint --config extensions/drm-copilot/eslint.config.mjs` on the TypeScript test files
- `poetry run python scripts/dev_tools/validate_evidence_locations.py --root .`
- PowerShell (CI): `Invoke-PoshQCFormat`, `Invoke-PoshQCAnalyze`, `Invoke-PoshQCTest` in `.github/workflows/_poshqc.yml`.
