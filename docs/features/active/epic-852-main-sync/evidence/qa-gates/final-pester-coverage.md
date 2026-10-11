# Final PowerShell Coverage (QC loop pass 1)

Timestamp: 2026-10-11T00-40
Task: [P3-T5]
Command: cd <WORKSPACE_ROOT> && sh <SCRATCHPAD>/r.sh rpester   (Invoke-PoshQCTest -Root $root -SettingsPath scripts/powershell/PoshQC/settings/pester.runsettings.psd1) ; then sh <SCRATCHPAD>/r.sh rcov .claude/hooks/validate-feature-review-coverage.ps1:47 .codex/hooks/validate-feature-review-coverage.ps1 .claude/hooks/feature-review-coverage-thresholds.ps1
EXIT_CODE: 0

Console lines (ANSI color codes removed):

```text
Tests Passed: 9784, Failed: 0, Skipped: 10, Inconclusive: 0, NotRun: 0
Covered 89.16% / 0%. 25,877 analyzed Commands in 197 Files.
```

R-COV output:

```text
JUNIT_ROOT: tests=9794 failures=0 errors=0
REPORT_LINE: 90.43 | covered=16116 | missed=1705
COVERAGE: .claude/hooks/validate-feature-review-coverage.ps1 | 98.62 | covered=215 | missed=3 | SOURCEFILE_MATCHES: 1
LINE: .claude/hooks/validate-feature-review-coverage.ps1:47 | ci=3 | mi=0
COVERAGE: .codex/hooks/validate-feature-review-coverage.ps1 | 99.29 | covered=140 | missed=1 | SOURCEFILE_MATCHES: 1
COVERAGE: .claude/hooks/feature-review-coverage-thresholds.ps1 | 100.00 | covered=21 | missed=0 | SOURCEFILE_MATCHES: 1
```

Line 47 is the guarded thresholds dot-source line (see [P2-T3]).

Output Summary: 9784 passed, 0 failed (JUnit failures=0, errors=0). Overall 89.16% (console command coverage), 90.43% (XML line counter). `.claude/hooks/validate-feature-review-coverage.ps1` 98.62% (SOURCEFILE_MATCHES: 1); `.claude/hooks/feature-review-coverage-thresholds.ps1` 100.00% (SOURCEFILE_MATCHES: 1); `.codex/hooks/validate-feature-review-coverage.ps1` 99.29%. Guarded line 47: ci=3, mi=0 (covered).
