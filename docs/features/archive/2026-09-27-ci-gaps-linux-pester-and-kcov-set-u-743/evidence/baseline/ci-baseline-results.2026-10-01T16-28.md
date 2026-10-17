# CI Baseline Results (P0-T23)

Timestamp: 2026-10-01T16-28

## _shell-coverage.yml run 36890790108

URL: https://github.com/drmoisan/drm-copilot/actions/runs/36890790108

Command: gh run view 36890790108 --json conclusion,jobs
EXIT_CODE: 0
Output Summary: run conclusion `success`; job `Shell Coverage (Bats + kcov)` databaseId 110465596241 concluded `success`; every step succeeded (`Build kcov from source` skipped, cache hit).

Command: gh run view 36890790108 --log | grep -F 'Bash coverage (lines):'
EXIT_CODE: 0
Output Summary: headline `Bash coverage (lines): 93.4%` (three further matches are usage-text lines containing the literal `NN.N%`).

Command: gh run view 36890790108 --log | grep -c -E ' not ok [0-9]+ '
EXIT_CODE: 1
Output Summary: `0`

Command: gh run view 36890790108 --log | grep -E ' not ok [0-9]+ '
EXIT_CODE: 1
Output Summary: no output.

CI bats baseline failure set: none

Command: gh run download 36890790108 --name shell-coverage --dir <session-scratchpad>/kcov-baseline-743
EXIT_CODE: 0
Output Summary: root `cov.xml` present (also `kcov-merged/`).

Command: sed -n '/shell_qc_lib\.sh"/,/<\/class>/p' <session-scratchpad>/kcov-baseline-743/cov.xml
EXIT_CODE: 0
Output Summary: `<class name="shell_qc_lib_sh__51" filename="scripts/bash/shell_qc_lib.sh" branch-rate="1.0" complexity="1.0" line-rate="0.865">`

Baseline line-rate for scripts/bash/shell_qc_lib.sh: 0.865

## _poshqc.yml run 36890793420

URL: https://github.com/drmoisan/drm-copilot/actions/runs/36890793420

Command: gh run view 36890793420 --json conclusion,jobs
EXIT_CODE: 0
Output Summary: run conclusion `success`; job `PowerShell QC` databaseId 110465608484 concluded `success`; steps `Format PowerShell`, `Analyze PowerShell`, `Test PowerShell`, `Upload PowerShell test artifacts` all `success`.

Command: gh run view 36890793420 --log --job 110465608484 | grep -F 'Tests Passed:'
EXIT_CODE: 0
Output Summary: `Tests Passed: 6084, Failed: 0, Skipped: 10, Inconclusive: 0, NotRun: 0`

`gh run view 36890793420 --log-failed` was not needed: the job had no failed step.

CI Windows Pester baseline failure set: none

Both runs ran on headSha 7282fb31153adb4d3449e5653d64c6b50e09de75.
