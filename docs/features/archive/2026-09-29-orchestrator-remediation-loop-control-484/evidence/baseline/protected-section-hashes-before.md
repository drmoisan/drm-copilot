# Protected Section Hashes (P0-T11)

Timestamp: 2026-10-01T21-07
Task: P0-T11
Route: sh-wrapped pwsh -NoProfile -Command (pwsh 7.6.6)

Command: foreach ($f in @(@('.claude/rules/orchestrator-state.md', @('## Blocked-Reason Vocabulary','## Enforcement','## Bare-Module CLI Contract')), @('.agents/skills/orchestrator-state/SKILL.md', @('## Enforcement')))) { $t=(Get-Content -Raw -LiteralPath $f[0]).Replace([string][char]13 + [char]10, [string][char]10); foreach ($h in $f[1]) { $i=$t.IndexOf([string][char]10 + $h + [char]10); if ($i -lt 0) { "$($f[0]) $h MISSING" } else { $j=$t.IndexOf([string][char]10 + '## ', $i + 1); if ($j -lt 0) { $j=$t.Length }; "$($f[0]) $h " + [BitConverter]::ToString([Security.Cryptography.SHA256]::HashData([Text.Encoding]::UTF8.GetBytes($t.Substring($i, $j - $i)))) } } }
EXIT_CODE: 0
Output:

```
.claude/rules/orchestrator-state.md ## Blocked-Reason Vocabulary C9-EC-D9-51-F5-AE-AD-8C-D0-A9-08-0A-1C-93-6B-A5-6F-BE-8A-9E-6A-3E-D9-66-F0-67-C5-B2-1E-55-AB-7B
.claude/rules/orchestrator-state.md ## Enforcement 8D-74-32-67-8E-E8-B3-B4-38-89-02-1A-CB-DA-3C-44-45-CB-32-70-BE-BC-C8-6E-08-B8-53-99-15-D1-20-82
.claude/rules/orchestrator-state.md ## Bare-Module CLI Contract AD-7F-46-C1-66-E9-02-AE-3C-87-EA-35-11-93-03-FD-F4-B7-38-D2-D6-10-08-BA-E8-2B-F8-E1-CC-FC-4F-E0
.agents/skills/orchestrator-state/SKILL.md ## Enforcement 50-C5-21-67-EE-C3-17-47-77-58-DB-57-0B-D7-93-7D-23-43-D0-A6-D8-45-E0-D8-05-21-0A-32-14-EB-A8-DF
```

## Output Summary:

- Four lines, none containing `MISSING`.
- Result: PASS. These hashes are the comparison values for the protected-section checks later in the plan.
