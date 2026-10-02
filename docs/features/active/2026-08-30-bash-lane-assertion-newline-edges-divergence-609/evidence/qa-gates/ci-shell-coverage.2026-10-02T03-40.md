# CI shell-coverage evidence (plan deviations D3, D4, D5 closed by CI)

Timestamp: 2026-10-02T03-40
Command: gh run view 36960130609 --job 110691773806 --log
EXIT_CODE: 0
Output Summary: Job "shell-coverage / Shell Coverage (Bats + kcov)" passed on head 54ccddd5 (PR #815). Bats plan 1..507; no `not ok` line in the log; lines 444-449 show `ok 119` through `ok 124` for the six `edges-parity:` cases; `Bash coverage (lines): 93.7%` (merged total, at least 85.0).

Run URL: https://github.com/drmoisan/drm-copilot/actions/runs/36960130609/job/110691773806

## Acceptance criteria checked on this evidence
AC-1, AC-3, AC-4, AC-5, AC-8, AC-11, AC-12, AC-13, AC-17 (all bats suites, shell-qc check, and parity suites green in the same job).

## Gaps left unchecked
- AC-6: no local or CI fail-first run exists; a fail-first bats run at commit 1524e2d2 (cases present, fix absent) must show exactly four `not ok` (operator-run, requires bats). Command: `bats --tap tests/shell/parallel_lane_assertion.bats` at that commit.
- AC-14: the merged total is 93.7%, but the per-file `line-rate` of parallel-lane-assertion.sh, its baseline value, and `hits` on line 88 were not read from `artifacts/pester/kcov/cov.xml` in the uploaded artifact.
