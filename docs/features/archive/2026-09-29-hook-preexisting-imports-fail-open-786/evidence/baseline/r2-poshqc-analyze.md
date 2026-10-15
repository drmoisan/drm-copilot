# Remediation Cycle 2 PowerShell Analyzer Baseline ([P0-T7])

Timestamp: 2026-10-10T20-26
Command: sh <SCRATCHPAD>/r.sh ranalyze -Files <six section 3 files> (route sh): Invoke-PoshQCAnalyze -Root $root (R-ANALYZE), then for each file @(Invoke-ScriptAnalyzer -Path <file> -Settings scripts/powershell/PoshQC/settings/pssa.settings.psd1).Count (R-PSSA-FILE)
EXIT_CODE: 0
Output Summary: R-ANALYZE passed with no findings; six PSSA lines, each with count 0.

```text
PSScriptAnalyzer passed: no findings under <WORKSPACE_ROOT>
PSSA: tests/scripts/codex-hooks/validate-feature-review-coverage.Coverage.Tests.ps1 | 0
PSSA: tests/scripts/codex-hooks/validate-codex-subagent-routing.Coverage.Tests.ps1 | 0
PSSA: tests/scripts/codex-hooks/enforce-codex-model-routing.Coverage.Tests.ps1 | 0
PSSA: tests/scripts/codex-hooks/enforce-epic-root-invocation.Coverage.Tests.ps1 | 0
PSSA: tests/scripts/codex-hooks/enforce-epic-wave-barrier.Coverage.Tests.ps1 | 0
PSSA: tests/scripts/codex-hooks/hook-dependency-failure.Codex.Tests.ps1 | 0
```
