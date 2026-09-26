# Phase 0 PowerShell Test and Coverage Baseline (Issue #697)

Timestamp: 2026-09-25T20-40
Command: pwsh -NoProfile -Command 'Import-Module ./scripts/powershell/PoshQC/PoshQC.psd1 -Force; Invoke-PoshQCTest -Root (Get-Location).Path -SettingsPath scripts/powershell/PoshQC/settings/pester.runsettings.psd1'
EXIT_CODE: 0
Output Summary:
- `Tests Passed: 4954, Failed: 0, Skipped: 9, Inconclusive: 0, NotRun: 0`
- Total cases: 4963 (4954 passed + 9 skipped)
- Failing `It` blocks (rule 15): none.
- `artifacts/pester/powershell-coverage.xml` report-root LINE counter: covered 9603, missed 424 (95.77%).
- Per-file LINE counters (attributed through the `package` element; package names shown with the worktree root replaced):
  - `.codex/hooks/enforce-epic-planning-only.ps1` (package `<WORKSPACE_ROOT>/.codex/hooks`, sourcefile `enforce-epic-planning-only.ps1`): covered 146, missed 13 (91.82%)
  - `.claude/lib/codex-routing/CodexDeployment.psm1` (package `<WORKSPACE_ROOT>/.claude/lib/codex-routing`, sourcefile `CodexDeployment.psm1`): covered 68, missed 0 (100.00%)
