# Phase 0 — Coverage-Bearing Pester Baseline (remediation cycle 2)

Timestamp: 2026-08-28T01-34
Task: [P0-T6]
Command: `pwsh -NoProfile -Command "Set-Location -LiteralPath 'C:\Users\DanMoisan\repos\drm-copilot\.claude\worktrees\agent-a502f12120e44837d'; Import-Module ./scripts/powershell/PoshQC/PoshQC.psd1 -Force; Invoke-PoshQCTest -Root (Get-Location).Path -SettingsPath 'scripts/powershell/PoshQC/settings/pester.runsettings.psd1'"`
EXIT_CODE: 0

## Why the self-hosted invocation, not the MCP test runner

This is the self-hosted `Invoke-PoshQCTest` invocation rather than
`mcp__drm-copilot__run_poshqc_test`. The MCP runner reads its Pester settings from the **installed**
extension payload, so it would ignore the two `CodeCoverage.Path` entries this feature registered in
the repository copy of `scripts/powershell/PoshQC/settings/pester.runsettings.psd1`. Running it would
measure a different file set and the Codex gate hook would not appear in the report.

## Test result

```
Tests completed in 114.79s
Tests Passed: 3816, Failed: 0, Skipped: 9, Inconclusive: 0, NotRun: 0
```

- **Passed: 3816**
- **Failed: 0**
- Skipped: 9
- Inconclusive: 0
- NotRun: 0
- **Total case count: 3825** (3816 + 0 + 9 + 0 + 0)

Process exit code observed as `0`.

## Coverage

The Pester console headline reads `Covered 94.15% / 0%. 10,525 analyzed Commands in 88 Files.` That
figure is **instruction (command) coverage** and is deliberately **not** recorded as the line figure.

The repository-wide LINE figure is read from the `LINE` counter at the **report root** of
`artifacts/pester/powershell-coverage.xml`:

| Counter type | Missed | Covered | Total |
| --- | --- | --- | --- |
| INSTRUCTION | 616 | 9909 | 10525 |
| **LINE** | **405** | **7209** | **7614** |
| METHOD | 37 | 630 | 667 |
| CLASS | 0 | 88 | 88 |

**Repository-wide LINE coverage: 94.68 percent** (7209 covered of 7614 total; 94.6809 percent
unrounded). This is at or above the 85 percent uniform threshold of
`.claude/rules/quality-tiers.md`.

Pester measures no branch coverage, so no branch figure is recorded and none is required per
`.claude/rules/powershell.md`.

Output Summary: 3825 total cases, **3816 passed**, **0 failed**, 9 skipped. Repository-wide LINE
coverage is **94.68 percent** (7209 / 7614), read from the report-root LINE counter of
`artifacts/pester/powershell-coverage.xml` and at or above the 85 percent threshold. EXIT_CODE 0.
