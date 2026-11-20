# Cycle 2 PR CI record (PR 948, head 85179c841f4efee523776c550defa30b0cf10f12)

Timestamp: 2026-10-16T06-05
Command: gh run view 38857583261 --json status,conclusion,headSha; gh run download 38857583261 -n poshqc-test-results; gh run view 38857583261 --log --job 116832400485
EXIT_CODE: 0
Output Summary: CI run 38857583261 on the head above concluded success with 17 of 17 checks passing. Job "poshqc / PowerShell QC" (116832400275) concluded success. Job "quality-checks7 / Code Quality & Tests (3.13)" (116832400485) concluded success.

## poshqc-test-results artifact (job poshqc / PowerShell QC)

- pester-junit.xml: tests=10417, errors=0, failures=0 (full suite).
- Invoke-FullReleaseFlow.ps1 class-level LINE counter: missed 7, covered 131 (131/138 = 94.93%). Baseline 115/122 = 94.26%; the same 7 lines are missed, so there is no regression.
- Invoke-FullReleaseFlow.CheckHelpers.ps1 class-level LINE counter: missed 0, covered 30 (30/30 = 100%). This file was not measurable by the local MCP runner (installed-extension coverage list).
- Combined script and helper: 161/168 = 95.83%.

## Python (job quality-checks7 3.13)

- Step "Enforce Python coverage thresholds" is part of a job that concluded success (thresholds --min-line 85 --min-branch 75).
- pytest TOTAL line: `TOTAL 17638 1108 6368 504 92%` (statements, missed, branches, partial branches, combined percent).
