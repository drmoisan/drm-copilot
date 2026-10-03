# P4-T4 AC-2: remaining Test-CommandLineRawContainment references

Timestamp: 2026-10-03T10-00
Command: Select-String -Path .claude/hooks/*.ps1, .codex/hooks/*.ps1 -SimpleMatch -Pattern 'Test-CommandLineRawContainment' (relative path:line:text); Select-String 'function Test-CommandLineMention' over both invocation files
EXIT_CODE: 0
Output Summary:
- .claude\hooks\hook-command-invocation.ps1:94:function Test-CommandLineRawContainment {
- .claude\hooks\hook-command-invocation.ps1:490:return (Test-CommandLineRawContainment -RawText ([string]$CommandText) -CommandWord $CommandWord -SubcommandPath $SubcommandPath)
- .codex\hooks\hook-command-invocation.ps1:94:function Test-CommandLineRawContainment {
- .codex\hooks\hook-command-invocation.ps1:490:return (Test-CommandLineRawContainment -RawText ([string]$CommandText) -CommandWord $CommandWord -SubcommandPath $SubcommandPath)
- function Test-CommandLineMention: line 465 on both surfaces (490 > 465, so Test-CommandLineMention is the only remaining caller)
- Exactly four lines, two per hooks root, all in hook-command-invocation.ps1
- Result: PASS
