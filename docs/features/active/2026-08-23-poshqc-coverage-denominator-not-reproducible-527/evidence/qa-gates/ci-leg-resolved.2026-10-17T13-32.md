# CI Leg Resolved (round 2, S9, AC-01)

Timestamp: 2026-10-17T13-32
Command: gh pr checks 974 (all checks), then gh run view 39036329041 --log, reading the `Code coverage population` lines of `poshqc / PowerShell QC shard 1`, `shard 2`, `shard 3` and the `Merged PowerShell line coverage` line of the aggregator `poshqc / PowerShell QC`
EXIT_CODE: 0
Output Summary: the CI full run on the PR head matches the local denominator. Each of the three shards logs `source=config; files=215`, and the aggregator logs `Merged PowerShell line coverage: 17607 of 19095 lines (92.21%), 1488 missed.` The merged LINE total (covered plus missed) is 19095 and the file count is 215, equal to the local values in `ci-leg-pending.2026-10-17T13-03.md` (215 files, ROOT_LINE_TOTAL 19095).

Run: GitHub Actions run 39036329041 for PR head 87ab9274d60ce06ac641a15b54a2dafa381f263c. Its `CI full run` job succeeded, so it is a valid full-run base. Every check on the head passed (24 checks, none pending or failing).

Comparison:

| Value | Local (run A, B, C) | CI (full run) | Equal |
| --- | --- | --- | --- |
| Files in the coverage population | 215 | 215 (each shard, source=config) | yes |
| LINE total (missed + covered) | 19095 | 19095 (17607 covered + 1488 missed) | yes |

Notes:

- The CI log does not print a key-set hash, so the local `KEY_SHA256` is not compared with a CI value. File count and LINE total are the CI values the log records. The file-key comparison across shards and the local runs is recorded in `research/research.2026-10-17T12-35.md`.
- The covered count (numerator) depends on which tests ran and is not part of this criterion.

Status: RESOLVED. AC-01 is checked off in `spec.md`.
