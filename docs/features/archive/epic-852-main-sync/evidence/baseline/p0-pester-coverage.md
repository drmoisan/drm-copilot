# Phase 0 Baseline PowerShell Coverage

Timestamp: 2026-10-10T23-59
Task: [P0-T9]
Command: cd <WORKSPACE_ROOT> && sh <SCRATCHPAD>/r.sh rpester   (Import-Module ./scripts/powershell/PoshQC/PoshQC.psd1 -Force; Invoke-PoshQCTest -Root $root -SettingsPath scripts/powershell/PoshQC/settings/pester.runsettings.psd1) ; then sh <SCRATCHPAD>/r.sh rcov .claude/hooks/validate-feature-review-coverage.ps1 .codex/hooks/validate-feature-review-coverage.ps1
EXIT_CODE: 0

Console lines (ANSI color codes removed):

```text
Tests Passed: 9495, Failed: 0, Skipped: 10, Inconclusive: 0, NotRun: 0
Covered 87.07% / 0%. 25,713 analyzed Commands in 192 Files.
```

R-COV output:

```text
JUNIT_ROOT: tests=9505 failures=0 errors=0
REPORT_LINE: 87.97 | covered=15570 | missed=2129
COVERAGE: .claude/hooks/validate-feature-review-coverage.ps1 | 97.22 | covered=210 | missed=6 | SOURCEFILE_MATCHES: 1
COVERAGE: .codex/hooks/validate-feature-review-coverage.ps1 | 99.29 | covered=140 | missed=1 | SOURCEFILE_MATCHES: 1
```

Note: `Covered 87.07%` is the Pester console command-coverage headline; `REPORT_LINE` is the report-level LINE counter from the CoverageGutters XML (87.97% line coverage).

Output Summary: 9495 passed, 0 failed, 10 skipped. Overall coverage 87.07% (console command coverage), 87.97% (XML line counter). `.claude/hooks/validate-feature-review-coverage.ps1` 97.22% (SOURCEFILE_MATCHES: 1); `.codex/hooks/validate-feature-review-coverage.ps1` 99.29% (SOURCEFILE_MATCHES: 1).
