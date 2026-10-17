# Rules Document Enforcement-Tail Hash Baseline (P0-T24)

Timestamp: 2026-09-30T14-31
Command: $t=(Get-Content -Raw -LiteralPath .claude/rules/orchestrator-state.md).Replace([string][char]13 + [char]10, [string][char]10); $i=$t.IndexOf([string][char]10 + '## Enforcement'); [BitConverter]::ToString([Security.Cryptography.SHA256]::HashData([Text.Encoding]::UTF8.GetBytes($t.Substring($i))))
EXIT_CODE: 0
Output Summary: One hyphen-separated hash printed (heading found; `$i` was not -1, since `Substring(-1)` would have thrown):
`9E-81-A5-F1-E4-32-75-31-98-19-43-88-81-51-0B-90-4B-DE-D5-78-D5-6B-AE-D3-B1-BB-B0-2D-21-FF-4B-19`

Execution route: PowerShell execution route (scratchpad `.sh` file that changes to the worktree root and calls `pwsh -NoProfile -Command '<command text>'`, run with `sh`).
