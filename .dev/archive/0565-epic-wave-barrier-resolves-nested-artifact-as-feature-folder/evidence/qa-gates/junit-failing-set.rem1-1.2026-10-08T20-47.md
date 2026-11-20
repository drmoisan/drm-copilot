# Final QC (Remediation Cycle 1, Iteration 1): Failing Set (JUnit)

Timestamp: 2026-10-08T20-47
Command: [xml]$j = Get-Content -Raw -LiteralPath artifacts/pester/pester-junit.xml; $f = @($j.SelectNodes('//testcase[failure]')); 'JUnitFailures=' + $f.Count; $f | ForEach-Object { 'FAILCASE ' + $_.ParentNode.GetAttribute('name').Replace((Get-Location).Path + [System.IO.Path]::DirectorySeparatorChar, '') + ' :: ' + $_.GetAttribute('name') }; 'JUNIT-WRITTEN ' + (Get-Item -LiteralPath artifacts/pester/pester-junit.xml).LastWriteTime.ToString('yyyy-MM-dd HH:mm:ss'); 'COVERAGE-WRITTEN ' + (Get-Item -LiteralPath artifacts/pester/powershell-coverage.xml).LastWriteTime.ToString('yyyy-MM-dd HH:mm:ss')
Shell: sh <scratchpad>/c2-565-r1-run.sh <scratchpad>/c2-565-r1-P0-T24.ps1 (JUNIT template plus two write-time lines)
EXIT_CODE: 0
Output Summary: JUnitFailures=2. Both FAILCASE lines are identical to lines 11-12 of evidence/baseline/junit-failing-set.2026-10-08T17-53.md. BlockOrContainerFailures=0 (P5-T9 exit code 2 minus 2). ExpectedExitCode: 2 was added to the P5-T9 artifact.

```
JUnitFailures=2
FAILCASE tests\scripts\claude-hooks\enforce-pr-author-skill.Tests.ps1 :: enforce-pr-author-skill.ps1.allowed commands.allows gh pr create --body-file artifacts/pr_body_12.md when context exists
FAILCASE tests\scripts\codex-hooks\codex-pretooluse-integration.Tests.ps1 :: Every registered Codex PreToolUse handler accepts every tool name its matcher admits.allows every registered handler for every tool name its own matcher admits
JUNIT-WRITTEN 2026-10-08 20:46:58
COVERAGE-WRITTEN 2026-10-08 20:44:39
BlockOrContainerFailures=0
```
