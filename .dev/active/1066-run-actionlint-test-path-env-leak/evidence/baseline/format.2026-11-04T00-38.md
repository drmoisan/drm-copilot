# Baseline Format (P0-T11)

Timestamp: 2026-11-04T00-38
Command: pwsh -NoProfile -File SCRATCH/issue-1066-format-lint.ps1 -Root <worktree root> -Files tests/scripts/dev-tools/run-actionlint.Tests.ps1 (Invoke-Formatter -ScriptDefinition <file content> -Settings scripts/powershell/PoshQC/settings/pssa.settings.psd1, compared ordinally with the file content; no write)
EXIT_CODE: 0
Output Summary:
- `FORMAT tests/scripts/dev-tools/run-actionlint.Tests.ps1: unchanged`

| File | Result |
|---|---|
| tests/scripts/dev-tools/run-actionlint.Tests.ps1 | unchanged |
