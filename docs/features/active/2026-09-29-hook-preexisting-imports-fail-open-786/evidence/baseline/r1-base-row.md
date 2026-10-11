# Remediation Cycle 1 Baseline Row for validate-orchestrator-output-resolution.ps1 ([P0-T10])

Timestamp: 2026-10-10T08-48
Command: route script 1 <SCRATCHPAD>/r1-p0t10a.ps1: git archive --format=zip -o <SCRATCHPAD>/r1-base.zip 86e457a003be0c60b65e01156e4cccd6495dfd1a; Expand-Archive -LiteralPath <SCRATCHPAD>/r1-base.zip -DestinationPath <SCRATCHPAD>/r1-base; git cat-file -e 86e457a003be0c60b65e01156e4cccd6495dfd1a:.claude/hooks/validate-orchestrator-output-resolution.ps1. Route script 2 <SCRATCHPAD>/r1-p0t10b.ps1 (named exception: working directory <SCRATCHPAD>/r1-base): Set-Location -LiteralPath <SCRATCHPAD>/r1-base; $root = (Get-Location).Path; Import-Module ./scripts/powershell/PoshQC/PoshQC.psd1 -Force; Invoke-PoshQCTest -Root $root -SettingsPath scripts/powershell/PoshQC/settings/pester.runsettings.psd1. Route script 3 <SCRATCHPAD>/r1-p0t10c.ps1: R-COV over <SCRATCHPAD>/r1-base/artifacts/pester/powershell-coverage.xml. All route sh.
EXIT_CODE: 0
Output Summary: BASE extraction run reports `Tests Passed: 8420, Failed: 0`; validate-orchestrator-output-resolution.ps1 at BASE is 98.96 (covered 95, missed 1); control validate-orchestrator-output.ps1 is 94.62 (missed 7), equal to the p0-pester-coverage.md value.

ARCHIVE_EXIT_CODE: 0
CAT_FILE_EXIT_CODE: 0
ROOT-IS-EXTRACTION: yes
BASE run exit code (route script 2): 0 (does not gate)
BASE run console:

```text
Tests completed in 519.08s
Tests Passed: 8420, Failed: 0, Skipped: 10, Inconclusive: 0, NotRun: 0
Covered 85.99% / 0%. 24,808 analyzed Commands in 190 Files.
```

COVERAGE_LAST_WRITE: 2026-10-10T08-58-06

BASELINE-ROW: .claude/hooks/validate-orchestrator-output-resolution.ps1 | 98.96 | covered=95 | missed=1 | SOURCEFILE_MATCHES: 1
CONTROL: .claude/hooks/validate-orchestrator-output.ps1 | 94.62 | missed=7 | SOURCEFILE_MATCHES: 1
CONTROL-MATCH: yes

The extraction is not a git worktree and is never staged.
