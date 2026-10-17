# Remediation cycle 2 - branch state (P0-T2)

Timestamp: 2026-10-16T19-36
Command: git fetch origin; git rev-parse --abbrev-ref HEAD; git rev-parse HEAD; git rev-parse origin/main; git merge-base origin/main HEAD; git status --porcelain
EXIT_CODE: 0
Output Summary:
BRANCH=bug/ci-merge-queue-for-main-952
REM_BASE_SHA=21c7338aeccb0122d7cbed24c994039741478bce
ORIGIN_MAIN=fa27cd5edcb39a5d5f63054c3e38cefef18ab316
B_NOW=fa27cd5edcb39a5d5f63054c3e38cefef18ab316
B_EXPECTED=fa27cd5edcb39a5d5f63054c3e38cefef18ab316 (B= of docs/features/active/2026-10-16-ci-merge-queue-for-main-952/evidence/baseline/ci-baseline.2026-10-16T18-58.md, the lexicographically greatest ci-baseline.*.md)
B_MATCH=true
PORCELAIN (verbatim):
 M docs/features/active/2026-10-16-ci-merge-queue-for-main-952/remediation-plan.2026-10-16T17-18.md
?? docs/features/active/2026-10-16-ci-merge-queue-for-main-952/evidence/remediation-baseline/c2-phase0-instructions-read.2026-10-16T19-36.md
PORCELAIN_CHECK=PASS (one `?? ...c2-phase0-instructions-read.` line; every other line is the permitted plan-file modification)

## Per-command exit codes

| Command | EXIT_CODE |
|---|---|
| git fetch origin | 0 |
| git rev-parse --abbrev-ref HEAD | 0 |
| git rev-parse HEAD | 0 |
| git rev-parse origin/main | 0 |
| git merge-base origin/main HEAD | 0 |
| git status --porcelain | 0 |

The directive-removal check is recorded separately in `c2-directive-removed.2026-10-16T19-36.md`.
