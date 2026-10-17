# Baseline PSScriptAnalyzer (P0-T16)

Timestamp: 2026-10-11T23-55
Command: CR-PSSA (scratchpad route) with <LIST> = LIST-PROD-BASE plus LIST-TEST-BASE (10 files), settings scripts/powershell/PoshQC/settings/pssa.settings.psd1
EXIT_CODE: 0
Output Summary: 10 PSSA lines, each findings=0; PSSA-TOTAL: 0; EXIT_CODE_COMPUTED: 0.

## CR-PSSA output

```
PSSA: .claude/hooks/validate-feature-review-coverage.ps1 | findings=0
PSSA: .claude/hooks/feature-review-coverage-thresholds.ps1 | findings=0
PSSA: .codex/hooks/validate-feature-review-coverage.ps1 | findings=0
PSSA: tests/scripts/claude-hooks/validate-feature-review-coverage.Tests.ps1 | findings=0
PSSA: tests/scripts/claude-hooks/validate-feature-review-coverage.Coverage.Tests.ps1 | findings=0
PSSA: tests/scripts/claude-hooks/validate-feature-review-coverage.Issue824.Tests.ps1 | findings=0
PSSA: tests/scripts/claude-hooks/validate-feature-review-coverage.ThresholdsGuard.Tests.ps1 | findings=0
PSSA: tests/scripts/claude-hooks/feature-review-coverage-thresholds.Tests.ps1 | findings=0
PSSA: tests/scripts/codex-hooks/validate-feature-review-coverage.Coverage.Tests.ps1 | findings=0
PSSA: tests/scripts/codex-hooks/legacy-codex-hook-contracts.Tests.ps1 | findings=0
PSSA-TOTAL: 0
EXIT_CODE_COMPUTED: 0
PROCESS_EXIT: 0
```
