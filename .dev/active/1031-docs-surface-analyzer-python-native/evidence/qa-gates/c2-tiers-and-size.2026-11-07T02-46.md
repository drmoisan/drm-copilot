# [P3-T16] File size and quality tiers

Timestamp: 2026-11-07T02-46
Command: wc -l on both files (each ends with one line feed, so the count is the logical line count); poetry run python -m scripts.dev_tools.check_quality_tiers
EXIT_CODE: 0
Output Summary: script 485 and test file 499 logical lines; tiers check OK; quality-tiers.yml unchanged against MERGE_BASE.

## Counts

| File | Logical lines | Limit |
|---|---|---|
| `LIB/Invoke-DocsCommand.ps1` | 485 | below 500 |
| `TESTS/Invoke-DocsCommand.Tests.ps1` | 499 | below 700 |

`poetry run python -m scripts.dev_tools.check_quality_tiers` printed `quality-tiers: OK (30 entries, 30 discovered projects)`. `git diff --name-only MERGE_BASE -- quality-tiers.yml` printed nothing, so the file is unchanged (S21, U21).
