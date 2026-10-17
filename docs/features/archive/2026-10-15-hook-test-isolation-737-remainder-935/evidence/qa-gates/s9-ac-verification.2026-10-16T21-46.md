# S9 Acceptance-Criteria Verification (issue #935, PR #956)

Timestamp: 2026-10-16T21-46
Command: gh pr checks 956; gh run download 38963921545 -n poshqc-test-results and -n poshqc-linux-hook-test-results; gh run view 38963921545 --log --job 117185556598; gh run download 38404520141 -n poshqc-linux-hook-test-results; gh run download 38948304976 -n poshqc-test-results; D-JUNIT, D-COV and per-file LINE diff (scratch helpers under SCRATCH); git diff --name-only origin/main...HEAD
EXIT_CODE: 0
Output Summary: every criterion below is verified against CI run 38963921545 (pull_request, head 048d76cd8939319c08a9531015733dc53371795e, conclusion success, 17/17 checks pass). AC-24 is accepted under the coordinator's option 1 decision. Commits after 048d76cd8 change documents only (feature folder), so the code under test is unchanged.

Consolidates the Phase 7 orchestrator tasks P7-T2 to P7-T9 of `plan.2026-10-15T17-44.md` for this head.

## CI runs used

| Purpose | Run | Head | Result |
|---|---|---|---|
| Final PR CI (D-FINAL) | 38963921545 | 048d76cd8 | success, 17/17 checks |
| Baseline (P7-T1) | 38730332356 | adb9aa5f0 | success, 90.42% line coverage |
| Main at the final merge-base | 38948304976 | fa27cd5ed | success, 90.23% line coverage |
| AC-6 fail-before | 38404520141 | a25519222 | Linux hook-suite artifact still available |

## P7-T2 — jobs (AC-23 CI half, AC-19 Python half)

All 17 checks pass, including `poshqc / PowerShell QC`, `poshqc / PowerShell hook suites (Linux)` and the four `quality-checks7 / Code Quality & Tests (3.10-3.13)` jobs.

## P7-T3 — rows (AC-1, AC-2, AC-3, AC-4, AC-5, AC-10, AC-11, AC-12 non-vacuity, AC-13)

D-JUNIT over `pester-junit.xml` (Windows) and `pester-junit-linux-hooks.xml` (Linux): 55 row tokens per file, 110 checks, every one `PASS` (at least one matching testcase, none with a failure, error or skipped child). Tokens: the 28 R1, R2 and F-3 rows of the HookReference suite (expanded `<Case>`, `<Form>`, `<Reader>` names), the six F-1/F-2 rows plus `AC-13 non-compliant` and `AC-13 compliant` in the Branches suite, `AC-8` in the Predicate suite, and the Discovery rows listed under P7-T4. Whole-suite status in both files: Branches 16/0 bad, Predicate 10/0, legacy guard 25/0, HookReference 41/0, Discovery 365/0.

## P7-T4 — Discovery (AC-7, AC-8)

Discovery suite: 365 testcases, 0 failures, in both files. Present and passing in both: the `AC-4` row for each of the seven AC-6 suites, the `AC-4` rows for the three new split suites, `AC-2 no hard-coded suite list in N2`, `AC-2 no hard-coded suite list or decision D9 note in the legacy guard`, both `AC-5b` rows, both `F-3 non-vacuity` rows, both `AC-5 process-spawning report` rows and `AC-5 process-spawning fixture is reported and does not fail`. `git diff --name-only origin/main...HEAD` lists none of the seven AC-6 suites.

## P7-T5 — split counts (AC-14 to AC-18), Windows file

| Suite | Passed | Equation |
|---|---|---|
| enforce-epic-worktree-removal-gate.Tests.ps1 + ManifestBranch | 47 + 5 = 52 | baseline 51 + 1 |
| enforce-prd-feature-before-planner.TargetResolution + CallTarget | 20 + 6 = 26 | baseline 25 + 1 |
| ...command-exemption.Tests.ps1 + Selectors | 60 + 61 = 121 | baseline 120 + 1 |
| enforcement-hooks-no-python-invocation.Tests.ps1 | 32 | baseline 32 |
| ...preimplementation-gate-epic-scope.Tests.ps1 | 54 | baseline 54 |

## P7-T6 — coverage (AC-24)

- Final head: covered 16531, missed 1906, 89.66% (16531 / 18437). The 85% floor holds.
- Baseline 90.42% (18116 lines); main at the final merge-base fa27cd5ed: 90.23% (16636 / 18437).
- Per-file LINE diff, main at fa27cd5ed versus the PR head: lower on the PR only in `.claude/lib/orchestrator-state/` (CompletionChecks -25, EpicWaveBarrier -11, IssueAdoption -20, ModelReceipts -21, Receipts -21, RoutingContract -5, Unconditional -1) and `.claude/lib/worktree-resolution/EpicScopeResolution.psm1` (-1). None of these files is in the branch diff.
- `config/poshqc-coverage.json` is not in the diff; no production file is excluded.
- Result: AC-24 ACCEPTED-OPTION-1 per `evidence/other/cov1-decision-option1.2026-10-16T20-38.md` (attribution loss in unchanged production files; baseline clause not met as written).

## P7-T7 — AC-5b report (AC-12)

`gh run view 38963921545 --log --job 117185556598` (`poshqc / PowerShell hook suites (Linux)`): 37 distinct `REPORT-VARIABLE-LOAD:` lines, 23 with prefix `tests/scripts/claude-hooks/` and 14 with prefix `tests/scripts/codex-hooks/`. The line list is the measured input for the deferred F-3 enforcement follow-up (copy kept under SCRATCH as issue-935-variable-load.txt).

## P7-T8 — AC-6 JUnit confirmation

Run 38404520141, `pester-junit-linux-hooks.xml`: exactly seven failing Discovery testcases, the `AC-4` row of each AC-6 suite (`hook-command-consumers.Issue824`, `hook-command-invocation.Issue824Regression`, `hook-dependency-failure.Claude`, `hook-dependency-failure.SpecialCases`, `session-root-reads-850.Constraints`, `codex-epic-runtime-contracts`, `hook-dependency-failure.Codex`), each failure message containing `no dot-source loads the hook`. No other Discovery testcase failed. This confirms `evidence/regression-testing/fail-before-ac6.2026-10-16T01-54.md`.

## P7-T9 — other rows and PR body (AC-19, AC-26)

- `tests/scripts/claude-runtime/test-name-uniqueness.Tests.ps1`: 5 testcases, 0 failures; `tests/scripts/claude-lib/blast-radius/BlastRadius.HistoricalRuns.Tests.ps1`: 9 testcases, 0 failures; the four `quality-checks7` jobs (which run `test_blast_radius_historical_runs.py`) pass. None of these three files is in the diff.
- PR #956 body (refreshed 2026-10-16T20:42Z, receipt sha256 2d7c9905...) contains `N-2`, `F-6`, `F-3`, `shape-B` and `I-3`.

## Scope (AC-20, AC-21, AC-22)

`git diff --name-only origin/main...HEAD` (merge-base fa27cd5ed): 18 paths outside the feature folder, all in the spec Write Set; none under `.claude/`, `.codex/`, `.github/`, `extensions/`, `scripts/` or `config/`; none of the AC-6 suites, `validate-*-output*` suites, `validate-discovery-artifact-gate`, `hook-dependency-failure*` suites, preimplementation-gate modes or epic-scope suites.
