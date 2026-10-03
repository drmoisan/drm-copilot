# P6-T9 Line counts of every changed or added PowerShell file (AC-28, AC-25)

Timestamp: 2026-10-03T10-13
Command: foreach ($f in @(<25 files listed in P6-T9>)) { "$f $((Get-Content -LiteralPath $f).Count)" }; @(Get-ChildItem .codex/hooks -Filter *.ps1 -File | Where-Object { (Get-Content -LiteralPath $_.FullName).Count -gt 500 }).Count
EXIT_CODE: 0
Output Summary:
- .claude/hooks/hook-command-invocation.ps1 491; .codex/hooks/hook-command-invocation.ps1 491; both bundle invocation copies 491 (ceiling 495)
- .claude/hooks/hook-command-raw-invocation.ps1 109; .codex/hooks/hook-command-raw-invocation.ps1 109; both bundle raw-invocation copies 109
- U1 tests/scripts/claude-hooks/hook-command-raw-invocation.Tests.ps1 77; U2 tests/scripts/codex-hooks/hook-command-raw-invocation.Tests.ps1 77 (limit 200)
- LEGACY tests/scripts/codex-hooks/legacy-codex-hook-contracts.Tests.ps1 497
- S1 260/300, S2 246/290, S3 347/350, S4 284/290, S5 354/360, S6 135/140, S7 115/125, S8 130/140, S9 155/165, S10 87/95, S11 346/360, S12 360/375, S13 189/195, S14 117/125 (each within its P1 budget)
- .codex/hooks files over 500 lines: 0
- Every listed count is at most 500
- Result: PASS
