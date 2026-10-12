# Phase 2 Settings Suite Fail-Before Run (issue #897, epic child E1)

Timestamp: 2026-10-11T12-56
Task: [P2-T11] [expect-fail]
Command: `Import-Module Pester -MinimumVersion 5.0 -Force; $cfg = New-PesterConfiguration; $cfg.Run.Path = @('tests/scripts/claude-runtime/claude-settings.Tests.ps1'); $cfg.Run.PassThru = $true; $cfg.Run.Exit = $false; $cfg.Output.Verbosity = 'Detailed'; $r = Invoke-Pester -Configuration $cfg` followed by the R-TARGETED container, failure, and total printers.
EXIT_CODE: 1
ExpectedExitCode: 1
Output Summary: expected failure observed. 9 tests; passed=7 failed=2 skipped=0. Exactly two `FAILED:` lines: the `CLAUDE_HOOK_INPUT` test (found 1 offending SubagentStop command in the canonical copy) and the group-retention test (the fifteen-agent group still carries the inline `pwsh -NoProfile -Command ...` entry ahead of the discovery-artifact gate). Every pre-existing `It` passes, as do the new `exit 1` test and the `subagentstop-envelope.ps1` reference test.

## Suite facts recorded for [P2-T10]

- `(Get-Content tests/scripts/claude-runtime/claude-settings.Tests.ps1).Count`: 197 (at most 500; was 155 at [P0-T5])
- Parse: `[System.Management.Automation.Language.Parser]::ParseFile` reports 0 errors.
- No existing `It` was changed; `$script:SettingsCopies`, `$script:BroadSubagentStopMatcher`, and a `Get-SubagentStopCommand` helper were added to the existing `BeforeAll`, and four `It` blocks were appended inside `Describe "claude-settings"`.
- Read-only format check: `Formatted: ` 0, `Already formatted: ` 1; analyzer: `PSScriptAnalyzer passed: no findings under .`.

## Per-test results

```text
Describing claude-settings
  [+] requires .claude/settings.json to omit a default agent and declare canonical worker hook coverage
  [+] requires .claude/settings.json to use the active PowerShell MCP contract
  [+] requires the Bash PreToolUse hook chain to include validate-bash and enforce-promotion-mcp-only
  [+] requires one dedicated prd-feature stop-hook registration in byte-identical settings files
  [+] rejects complete omission, broad-only, duplicate, extra-command, wrong-command, wrong-type, wrong-matcher, and divergent prd-feature registration fixtures
  [-] removes every SubagentStop command that reads CLAUDE_HOOK_INPUT from both settings copies
  [+] keeps no SubagentStop command that ends with exit 1 in either settings copy
  [-] retains the fifteen-agent SubagentStop group with only the discovery-artifact gate in both settings copies
  [+] registers no hook command that references subagentstop-envelope.ps1 in either settings copy
```

## R-TARGETED output (after R-REDACT)

```text
CONTAINER: tests/scripts/claude-runtime/claude-settings.Tests.ps1 | result=Failed | passed=7 | failed=2
FAILED: claude-settings.removes every SubagentStop command that reads CLAUDE_HOOK_INPUT from both settings copies | Expected 0, because the canonical settings must register no SubagentStop command that reads CLAUDE_HOOK_INPUT, but got 1.
FAILED: claude-settings.retains the fifteen-agent SubagentStop group with only the discovery-artifact gate in both settings copies | Expected 'pwsh -NoProfile -File .claude/hooks/validate-discovery-artifact-gate.ps1', but got @('pwsh -NoProfile -Command "$input = $env:CLAUDE_HOOK_INPUT | ConvertFrom-Json; $output = $input.output; if (-not ($output -match '(plan-path|research-path|review-artifact|PREFLIGHT|evidence/)')) { Write-Error 'Subagent stopped without required completion artifact path'; exit 1 }; exit 0"', 'pwsh -NoProfile -File .claude/hooks/validate-discovery-artifact-gate.ps1').
TOTAL: passed=7 failed=2 skipped=0
```
