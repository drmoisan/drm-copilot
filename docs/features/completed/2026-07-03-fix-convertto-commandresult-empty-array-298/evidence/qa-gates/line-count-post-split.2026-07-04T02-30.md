Timestamp: 2026-07-04T02-30
Command: (Get-Content tests/scripts/dev-tools/Invoke-FullReleaseFlow.Tests.ps1 | Measure-Object -Line).Lines
EXIT_CODE: 0
Output Summary: Literal command reports 368. As documented in `evidence/remediation-baseline/line-count-baseline.2026-07-04T02-20.md`, `Measure-Object -Line` undercounts by not counting blank lines. Cross-verified with `wc -l` (accurate physical line count): 425 lines. Both the literal command's result (368) and the accurate physical count (425) are `<= 500`, confirming the split satisfied the 500-line file-size cap.
