# Baseline Failing Set (JUnit)

Timestamp: 2026-10-08T17-53
Command: [xml]$j = Get-Content -Raw -LiteralPath artifacts/pester/pester-junit.xml; $f = @($j.SelectNodes('//testcase[failure]')); 'JUnitFailures=' + $f.Count; $f | ForEach-Object { 'FAILCASE ' + $_.ParentNode.GetAttribute('name').Replace((Get-Location).Path + [System.IO.Path]::DirectorySeparatorChar, '') + ' :: ' + $_.GetAttribute('name') }
Shell: sh <scratchpad>/c2-565-run.sh <scratchpad>/c2-565-P0-T20.ps1
EXIT_CODE: 0
Output Summary: JUnitFailures=2, equal to the Failed: 2 value on the P0-T19 Tests Passed line. BlockOrContainerFailures=0 (P0-T19 exit code 2 minus 2).

```
JUnitFailures=2
FAILCASE tests\scripts\claude-hooks\enforce-pr-author-skill.Tests.ps1 :: enforce-pr-author-skill.ps1.allowed commands.allows gh pr create --body-file artifacts/pr_body_12.md when context exists
FAILCASE tests\scripts\codex-hooks\codex-pretooluse-integration.Tests.ps1 :: Every registered Codex PreToolUse handler accepts every tool name its matcher admits.allows every registered handler for every tool name its own matcher admits
BlockOrContainerFailures=0
```

Neither failing suite is in the plan write set.
