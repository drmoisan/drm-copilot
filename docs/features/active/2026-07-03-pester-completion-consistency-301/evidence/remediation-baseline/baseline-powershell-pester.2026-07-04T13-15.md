# Baseline PowerShell Pester Run — Remediation Cycle 2 (Pre-Fix, Coverage-Enabled)

Timestamp: 2026-07-04T13-15

## Tool-Routing Note (carried forward from cycle 1)

`mcp__drm-copilot__run_poshqc_test` resolves its settings from the bundled extension copy at `extensions/drm-copilot/resources/powershell/PoshQC/settings/pester.runsettings.psd1`, not the repo-root `scripts/powershell/PoshQC/settings/pester.runsettings.psd1`. An initial invocation of the MCP tool against the two target test files was executed and confirmed this: the resulting `artifacts/pester/powershell-coverage.xml` contained no `enforce-completion-consistency.ps1` or `enforce-completion-helpers.ps1` entries at all (case-insensitive `grep -in "completion"` returned zero matches), because the bundled extension's `CodeCoverage.Path` array (15 entries) does not include the four in-scope hook files. This matches the mechanical constraint documented in cycle 1's `evidence/qa-gates/final-powershell-pester.2026-07-04T12-00.md`.

To measure against the correct repo-root `scripts/powershell/PoshQC/settings/pester.runsettings.psd1` (the file plan task P0-T6 specifies as "current, unmodified since cycle 1"), the same equivalent-invocation substitution used in cycle 1 was applied: importing the workspace's own `PoshQC` module directly, which resolves `SettingsPath` from its own `$ModuleRoot`.

Command: `pwsh -NoLogo -NoProfile -ExecutionPolicy Bypass -Command "Import-Module './scripts/powershell/PoshQC' -Force; Invoke-PoshQCTest -Root '.' -ScanFolders @('tests/scripts/claude-hooks/enforce-completion-consistency.Tests.ps1','tests/scripts/claude-hooks/enforce-completion-consistency-codex.Tests.ps1')"`
EXIT_CODE: 0

Output Summary: 51 tests discovered and executed (`enforce-completion-consistency-codex.Tests.ps1`: 2 tests; `enforce-completion-consistency.Tests.ps1`: 49 tests). Tool output: `Tests Passed: 51, Failed: 0, Skipped: 0, Inconclusive: 0, NotRun: 0`. Coverage report regenerated at `artifacts/pester/powershell-coverage.xml` using the current (unmodified since cycle 1) repo-root `CodeCoverage.Path` array, which already lists all four in-scope hook files (added in cycle 1, unchanged this cycle). This confirms the test file used in this baseline run is the unmodified (pre-Phase-1) `enforce-completion-consistency-codex.Tests.ps1`, which still dot-sources the bundled-mirror `.codex` path.

## P0-T7: Per-File `<counter type="LINE">` Extraction (Pre-Fix)

Command: `grep -n "<sourcefile" artifacts/pester/powershell-coverage.xml`

```
636:    <sourcefile name="enforce-completion-consistency.ps1">     (package: .claude/hooks)
765:    <sourcefile name="enforce-completion-helpers.ps1">          (package: .claude/hooks)
1605:    <sourcefile name="enforce-completion-consistency.ps1">    (package: .codex/hooks)
1734:    <sourcefile name="enforce-completion-helpers.ps1">         (package: .codex/hooks)
```

Extracted `<counter type="LINE">` values (line numbers cited as they appear in the current `artifacts/pester/powershell-coverage.xml`):

| File | LINE missed | LINE covered | Line % | Evidence line |
|---|---|---|---|---|
| `.claude/hooks/enforce-completion-consistency.ps1` | 10 | 113 | 113/123 = 91.87% | line 761 |
| `.claude/hooks/enforce-completion-helpers.ps1` | 3 | 40 | 40/43 = 93.02% | line 810 |
| `.codex/hooks/enforce-completion-consistency.ps1` | 123 | 0 | 0/123 = 0.00% | line 1730 |
| `.codex/hooks/enforce-completion-helpers.ps1` | 43 | 0 | 0/43 = 0.00% | line 1779 |

Confirmation: `.claude/hooks/enforce-completion-consistency.ps1` = 91.87% and `.claude/hooks/enforce-completion-helpers.ps1` = 93.02%, matching the cycle-1 final figures exactly (no regression yet expected, since neither file nor its test has been modified in cycle 2 prior to this baseline). `.codex/hooks/enforce-completion-consistency.ps1` and `.codex/hooks/enforce-completion-helpers.ps1` remain at 0.00%, confirming the pre-fix gap this cycle addresses.
