# QA Gate: Coverage Delta and Changed-Line Coverage (Issue #973)

Timestamp: 2026-10-17T13-39
Command: poetry run python SCRATCH/issue-973-changed-lines.py <worktree> MB SCRATCH/issue-973-p4t3-report.txt (intersects the executable and missed line sets of the [P4-T3] coverage report with the lines added or modified in git diff -U0 MB -- <file>)
EXIT_CODE: 0

Inputs: baseline `FEATURE/evidence/baseline/ps-tests.2026-10-17T13-08.md` (coverage report copy `SCRATCH/issue-973-baseline-coverage.xml`); post-change `FEATURE/evidence/qa-gates/ps-tests.2026-10-17T13-39.md` (coverage report copy `SCRATCH/issue-973-post-coverage.xml`). `MB` is the merge base of `origin/main` and `HEAD` recorded in `FEATURE/evidence/baseline/execution-context.2026-10-17T13-04.md`.

| File | Baseline line coverage | Post-change line coverage | Changed lines (diff from MB) | Changed executable lines | Changed executable lines covered | Changed-line coverage |
|---|---|---|---|---|---|---|
| `scripts/ci/CiChangeScope.psm1` | 93.08% (121/130) | 93.57% (131/140) | 50 | 10 | 10 | 100.00% |
| `scripts/ci/Invoke-CiChangeScope.ps1` | 88.64% (78/88) | 91.15% (103/113) | 121 | 45 | 45 | 100.00% |

No changed executable line is uncovered. The uncovered lines of both files are pre-existing lines outside the diff: in the entry script, the body of the process boundary `Invoke-CiChangeScopeNative`, the default environment reader of `Get-CiChangeScopeContext`, the default gh and git invoker script blocks of `Invoke-CiChangeScope`, the job-list rethrow branch of `Find-CiChangeScopeBase`, and the CI entry-point guard; in the module, validation-failure branches of the config, NUL-list, run-list, and job-list parsers.

Output Summary: `scripts/ci/CiChangeScope.psm1` 93.08% -> 93.57%, changed-line 100.00%; `scripts/ci/Invoke-CiChangeScope.ps1` 88.64% -> 91.15%, changed-line 100.00%. Post-change and changed-line coverage are at least 85% for both files; no regression.
