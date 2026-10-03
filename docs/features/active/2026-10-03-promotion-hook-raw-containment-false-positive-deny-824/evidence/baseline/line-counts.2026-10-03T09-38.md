# P0-T5 Baseline line counts

Timestamp: 2026-10-03T09-38
Command: foreach ($f in @(<17 files listed in P0-T5>)) { "$f $((Get-Content -LiteralPath $f).Count)" }
EXIT_CODE: 0
Output Summary:
- .claude/hooks/hook-command-invocation.ps1 483
- .codex/hooks/hook-command-invocation.ps1 483
- tests/scripts/codex-hooks/legacy-codex-hook-contracts.Tests.ps1 497
- S1 197; S2 183; S3 330; S4 267; S5 336; S6 108; S7 89; S8 110; S9 147; S10 79; S11 338; S12 352; S13 175; S14 106
- Result: PASS (matches the expected sequence 483, 483, 497, 197, 183, 330, 267, 336, 108, 89, 110, 147, 79, 338, 352, 175, 106)
