# Feature Audit: bug-burndown-2026-09-29 review nits (#846)

- Timestamp: 2026-10-09T22-16 (host clock, local; filename stamp `2026-10-10T02-15` assigned by the caller)
- Branch: `bug/bug-burndown-2026-09-29-review-nits-846`
- HEAD: `396f598b31e6f790b249c6cc4f2e0260ed7b407a`

## Scope and Baseline

- Base: `main`; merge-base and current `origin/main` tip `311dea0548cb2e2fe57259aec6e1e3a06a9bdd2a`. Diff anchor `git diff 311dea054..HEAD` (127 files; statuses A and M only; `--diff-filter=DRC` prints nothing).
- Work mode: `full-bug` (`issue.md` line 12). AC source: `docs/features/active/2026-10-08-bug-burndown-2026-09-29-review-nits-846/spec.md` only; no `user-story.md` applies.
- Plan: `plan.2026-10-08T23-42.md`. Open plan tasks: [P8-T10] (AC-30), [P8-T11] (AC-31), [P12-T5] (AC-38), [P13-T8] (AC-34).
- CI status: no PR exists for the branch (`gh pr list --head bug/bug-burndown-2026-09-29-review-nits-846 --state all` returned `[]`), so no CI result exists for any CI-dependent criterion.
- Spec verification commands written against `origin/main...HEAD` were evaluated against the merge-base `311dea054`, which equals current `origin/main`; this matches the executor's recorded merge-base substitution.
- Assumptions: (1) the executor's whole-repository runs at 21:55 (Python) and 21:58 (Jest) reflect HEAD, because no production or test code changed in the later Phase 12 and 13 commits (evidence-only); (2) CI-dependent criteria are checked off at S9 by the item's orchestrator per the CI-Dependent Criteria rule, so this review leaves them unchecked.

## Acceptance Criteria Inventory

- #734 quality-tiers contract: AC-1 through AC-7
- #744 completion-gate and tooling friction: AC-8 through AC-11
- #647 subagent-tree test split: AC-12 through AC-15
- #623 promotion receipt destination: AC-16 through AC-20
- #764 feature-review skill validator citation: AC-21 through AC-23
- #338 IDE launcher audit gaps: AC-24, AC-25
- #609, #543, #527, #510: AC-26 through AC-29
- #723 npm publish verify window: AC-30 through AC-33
- Closure, scope, and toolchain: AC-34 through AC-40
- Total: 40. Checked at review start: 36. Unchecked at review start: AC-30, AC-31, AC-34, AC-38.

## Acceptance Criteria Evaluation

| AC | Verdict | Evidence (reviewer re-checks marked R) |
| --- | --- | --- |
| AC-1 | PASS | R: `git grep` finds `qt_codes` (line 12) and `make_manifest` (line 17) in the support module and no `def _codes` / `def _manifest` in the three quality-tiers modules. The spec's directory-wide pattern also matches unrelated `_manifest_payload` helpers in four other test files (FA-3). |
| AC-2 | PASS | R: name-by-name comparison of `^def test_` lines: 28 before; 29 after = 28 (one renamed) + `test_parse_quality_tiers_non_scalar_key_reports_qt002`. Executor: `evidence/regression-testing/quality-tiers-split-collect`, `quality-tiers-names-after`. |
| AC-3 | PASS | R: old name absent under `tests/`; `def test_find_classification_errors_empty_projects_reports_qt007() -> None:` at `test_quality_tiers_contract_classification.py:138`; black and ruff exit 0. |
| AC-4 | PASS | R: targeted run, `quality_tiers_contract.py` 191 statements, 0 missed, 78/78 branches. |
| AC-5 | PASS | R: `GitRunResult.stderr` property at `check_quality_tiers.py:59-62`; message logic at lines 99-105; pyright 0 errors. |
| AC-6 | PASS | R: both named tests pass. Executor fail-before: `evidence/regression-testing/qt009-fail-before.2026-10-09T09-00.md`. |
| AC-7 | PASS | Executor: `evidence/regression-testing/quality-tiers-cli.2026-10-09T09-00.md`. |
| AC-8 | PASS | R: `git grep -c` reports 1 for each of the six paths; the old sentence is absent from all six. |
| AC-9 | PASS | R: `test_completion_gate_documentation_contracts.py`, `test_minor_audit_acceptance_criteria_contracts.py`, `test_push_down_claude_resource_contracts.py` passed in the 172-test run. Executor: `evidence/regression-testing/ac-pin-pass-after`, `evidence/qa-gates/py-contract-tests`. |
| AC-10 | PASS | R: diff shows line 3 `Timestamp: 2026-10-02T01-43` and line 4 `Timestamp-Correction:` retaining `2026-10-02T01-44`, citing 01:43:48 and `code-review.2026-10-02T02-55.md` (CR-5), naming #846. |
| AC-11 | PASS | R: diff adds one `Note (added under #846, policy-audit PA-2)` line per file, deletes nothing, and adds no `Command:` / `EXIT_CODE:` row. |
| AC-12 | PASS | R: support module imports only `import type` from `../src/terminal-writer` and `../src/lib/file-system`; no `vscode` or `command-runtime` import. Executor typecheck: `evidence/qa-gates/ts-typecheck`. |
| AC-13 | PASS | R: `npm run test:unit -- subagent-tree-command` reports `Test Suites: 2 passed, 2 total`, `Tests: 14 passed, 14 total`. |
| AC-14 | PASS | R: `git diff --name-status 311dea054..HEAD` over the protected file prints nothing. |
| AC-15 | PASS | R: `extensions/drm-copilot/coverage/lcov.info` reports `src/subagent-tree-command.ts` 211/211 lines, 22/23 branches (above the 85/75 per-file threshold). Executor: `evidence/qa-gates/ts-jest-coverage`. |
| AC-16 | PASS | R: `pyproject.toml` diff is the single `partial_also` line. Closure-dispositions row "#623 Protocol stubs" states the Coverage Exclusion Policy reasoning. |
| AC-17 | PASS | Executor before/after: `evidence/baseline/py-cov-bug-entry-before`, `evidence/regression-testing/partial-also-after`. |
| AC-18 | PASS | R: test file unchanged on the branch; `potential_to_issue_filesystem.py` 31/31 lines, 14/14 branches in `artifacts/python/lcov.info` (pre-overwrite read). |
| AC-19 | PASS | R: `pending validator and executor preflight round 3` absent; `#846` appears on line 7 (Status) and line 228 (P5-T3); "exactly seven tests" retained; P5-T5 corrected expectation stated. |
| AC-20 | PASS | R: diff shows docstring and comment lines only; black, ruff, pyright exit 0; `test_potential_to_issue_move_verification.py` passed in the 172-test run. |
| AC-21 | PASS | R: lines 39, 40 use the anchored form with correction notes; line 66 names the anchored check; `-nxF` appears only inside the three correction notes. Executor: `evidence/regression-testing/764-corrected-grep-historical` (the current-tree run exits 1 because line 75 of the skill has since changed, as recorded). |
| AC-22 | PASS | R: note lists all 11 files with stamp and Timestamp and states the Timestamp field is authoritative; no renames on the branch. |
| AC-23 | PASS | R: diff shows the corrected `#764` `issue.md` line 5. |
| AC-24 | PASS | R: AC-3 text names `io-launcher.test.ts`, the command includes it, the correction note cites `ac3-jest-new-tests.2026-10-08T02-45.md`, checkbox stays `[x]`. Executor run: `evidence/regression-testing/ac3-338-jest`. |
| AC-25 | PASS | R: `git grep -n -i "bundled"` prints only line 40, the correction note. |
| AC-26 | PASS | R: note records Timestamp, the specified Command, EXIT_CODE 0, Output Summary (17), Supersedes list of the four files, status block, and AC-6/AC-14 resolution table; the four superseded files are unchanged on the branch. |
| AC-27 | PASS | R: line 3 `Timestamp: 2026-10-02T05-14`; line 4 retains `2026-10-02T05-01` and `2026-10-02T05-18`, cites `0c6abb95` and CR-11, names #846; only this file changed in the #543 folder. A6 handled as A6-SKIP (closure-dispositions Observations). |
| AC-28 | PASS | R: diff shows `### Changed` directly under `## [Unreleased]` and before `## [0.0.1] - 2026-05-02`, naming `config/poshqc-coverage.json`. |
| AC-29 | PASS | R: the AC-29 `git grep` exits 1 (no match); Status reads `Implemented` citing `code-review.2026-10-07T15-30.md`; `Last Updated` changed. |
| AC-30 | FAIL (awaiting_ci) | The new `It` block exists (`PublishMcpNpmWorkflow.Tests.ps1:236-246`) and static reading indicates it passes, but the criterion requires a Pester run with zero failures. Local Pester was not available (`evidence/qa-gates/ps-pester`, `Outcome: LOCAL-PESTER-UNAVAILABLE`); CI `poshqc / PowerShell QC` has not run. FA-1. |
| AC-31 | FAIL (awaiting_ci) | Text half met: the three poll/equality `Should -Match '(?m)^\s*exit 1\s*$'` assertions are replaced (lines 110-111, 126-127, 226-227); the generic rule at line 148 is unchanged. Pester half pending CI. FA-1. |
| AC-32 | PASS | R: fenced `npm view @danmoisan/drm-copilot-mcp@<version> version` at runbook line 137, inside the section headed at line 128, followed by the substitution sentence. |
| AC-33 | PASS | R: no `.github/workflows/` path in the diff; `test_workflow_npm_token_guard.py` passed in the 172-test run. |
| AC-34 | FAIL (awaiting_ci) | The closure-dispositions file has 27 rows covering every finding and the seven named special cases; all 36 cited paths exist (`evidence/qa-gates/closure-paths-exist`). The #338 A1 row records "CI run result: pending", and the criterion requires the PR CI `Enforce Python coverage thresholds` result. FA-2. |
| AC-35 | PASS | R: threshold script exit 0 on `artifacts/python/coverage.json`; totals 93.70% / 87.97% versus baseline 93.68% / 87.1%. |
| AC-36 | PASS | R: black, ruff, pyright on changed files exit 0; targeted runs pass. Executor whole-repository loop: `evidence/qa-gates/py-loop-summary`. |
| AC-37 | PASS | R: Prettier and ESLint on the three files exit 0; Jest suites pass. Executor full loop: `evidence/qa-gates/ts-loop-summary`. |
| AC-38 | FAIL (awaiting_ci) | Invoke-Formatter and PSScriptAnalyzer were not executed locally (`evidence/qa-gates/ps-formatter-check`, `ps-analyzer`); CI `poshqc` Format and Analyze steps have not run. FA-1. |
| AC-39 | PASS | R: `wc -l` maximum 449 (`test_check_quality_tiers.py`); all `.py`, `.ts`, `.ps1` files written are at most 500 lines. |
| AC-40 | PASS | R: `--diff-filter=DRC` prints nothing. All paths are in the spec list (placeholders resolved) except `issue.md`, `research/research.2026-10-08T23-50.md`, and `docs/features/potential/promoted/2026-10-08-bug-burndown-2026-09-29-review-nits.md`, which are promotion and research inputs rather than implementation writes (FA-4). |

## Findings

| ID | Severity | Remediability | Location | Rule | Evidence |
| --- | --- | --- | --- | --- | --- |
| FA-1 | Blocking | awaiting_ci | AC-30, AC-31, AC-38; `tests/scripts/workflows/PublishMcpNpmWorkflow.Tests.ps1` | acceptance-criteria-tracking Check-Off Protocol rule 1 (evidence before check-off); spec A7 | No Pester, Invoke-Formatter, or PSScriptAnalyzer result exists for the branch. Resolves when the CI `poshqc / PowerShell QC` job is green on the PR head; the orchestrator then checks off AC-30, AC-31, AC-38 at S9. |
| FA-2 | Blocking | awaiting_ci | AC-34; `evidence/other/closure-dispositions.2026-10-09T09-00.md` row "#338 A1" | acceptance-criteria-tracking Check-Off Protocol rule 1; spec A5 | The row awaits the PR CI `Enforce Python coverage thresholds` step result. The local equivalent passes (threshold script exit 0). Resolves when the orchestrator appends the CI result to the row and checks off AC-34 at S9. |
| FA-3 | Nit | n/a | spec AC-1 verification command | Verification command accuracy | `git grep -n -e "^def _codes" -e "^def _manifest" -- tests/scripts/dev_tools/` prints four `_manifest_payload` definitions in unrelated push-down test files, so the literal command does not print nothing. The executor ran the check over the three quality-tiers modules (`evidence/regression-testing/quality-tiers-helper-and-rename`, Block 1) without recording the narrowing as a deviation. The criterion's intent is met. |
| FA-4 | Nit | n/a | spec AC-40 / "Files the Implementation Writes" | Scope declaration completeness | The spec list omits three branch paths created by promotion and research (`issue.md`, `research/research.2026-10-08T23-50.md`, the promoted potential record). The executor compared against the plan's file list plus those pre-existing inputs (`evidence/qa-gates/scope-diff`). No unexpected path exists. |
| FA-5 | Nit | n/a | `docs/features/active/2026-10-08-bug-burndown-2026-09-29-review-nits-846/issue.md` line 5 | Record accuracy | `Status: Promoted -> docs/features/active/bug-burndown-2026-09-29-review-nits/` names a folder that does not exist. This is the `potential_to_issue_content.py` path-generation defect the spec records as an out-of-scope follow-up (spec line 373); it is listed here so the follow-up is not lost. |

## Summary

- 36 of 40 acceptance criteria PASS; 4 FAIL with remediability `awaiting_ci` (AC-30, AC-31, AC-34, AC-38). No criterion fails for a reason a code change on this branch would address.
- Blocking: 2 (FA-1, FA-2), both `awaiting_ci`; autonomous Blocking: 0. Nit: 3.
- Verdict: BLOCKED (awaiting_ci). Merge readiness depends on a green CI `poshqc / PowerShell QC` job and a green `Enforce Python coverage thresholds` step on the PR head.
- Remediation inputs: not produced. No Blocking finding is `autonomous`, and no criterion requires code or documentation remediation on the available evidence.

## Acceptance Criteria Check-off

- Newly checked off in this review: none. All 36 criteria evaluated PASS were already checked in `spec.md`; the 4 criteria evaluated FAIL (awaiting_ci) remain unchecked.

### Acceptance Criteria Status
- Source: docs/features/active/2026-10-08-bug-burndown-2026-09-29-review-nits-846/spec.md
- Total AC items: 40
- Checked off (delivered): 36
- Remaining (unchecked): 4
- Items remaining:
  - AC-30: new Pester `It` block passes (pending CI `poshqc / PowerShell QC`)
  - AC-31: tightened `exit 1` assertions pass in Pester (pending CI `poshqc / PowerShell QC`)
  - AC-34: closure-dispositions record complete, including the #338 A1 CI result (pending PR CI `Enforce Python coverage thresholds`)
  - AC-38: PowerShell formatter and analyzer clean on the test file (pending CI `poshqc / PowerShell QC`)
