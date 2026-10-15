# Test Purity: CR-1 Regression Suites (RW15, RW16)

Timestamp: 2026-10-08T20-22
Command: . ./.claude/hooks/check-powershell-test-purity.ps1; foreach ($p in @('tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-mode-resolution.TargetFolder.Tests.ps1', 'tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-mode-resolution.TargetFolder.Tests.ps1')) { $j = @{ tool_name = 'Write'; tool_input = @{ file_path = $p; content = (Get-Content -Raw -LiteralPath $p) } } | ConvertTo-Json -Depth 5 -Compress; $d = Invoke-PowerShellTestPurityDecision -ToolInputRaw $j; if ($null -eq $d) { 'PURITY-CLEAN ' + $p } else { 'PURITY-FINDING ' + $p + ' ' + $d.hookSpecificOutput.permissionDecisionReason } }
Shell: sh <scratchpad>/c2-565-r1-run.sh <scratchpad>/c2-565-r1-P1-T7.ps1
EXIT_CODE: 0
Output Summary: Two PURITY-CLEAN lines; the purity hook raises no finding on either edited suite.

```
PURITY-CLEAN tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-mode-resolution.TargetFolder.Tests.ps1
PURITY-CLEAN tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-mode-resolution.TargetFolder.Tests.ps1
```

## Re-run after the It-title correction (2026-10-08T20-23)

The first fail-before run showed that Pester treats `<sibling>` in an `It` title as a template token and renders it empty. The four affected titles in each suite (M10p, M10e, M11p, M11e) were changed from `a bare #<sibling>` to `a bare #302 sibling reference`; no assertion changed. The same command was re-run on the corrected files with exit code 0:

```
PURITY-CLEAN tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-mode-resolution.TargetFolder.Tests.ps1
PURITY-CLEAN tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-mode-resolution.TargetFolder.Tests.ps1
```
