# Remediation Cycle 1 Full Pester Baseline with Coverage ([P0-T10])

Timestamp: 2026-09-25T21-14
Command: sh <SCRATCHPAD>/rem1/runout.sh qc-test-full  (fresh PowerShell 7 process: Import-Module ./scripts/powershell/PoshQC/PoshQC.psd1; Invoke-PoshQCTest -Root $root -SettingsPath scripts/powershell/PoshQC/settings/pester.runsettings.psd1), then sh <SCRATCHPAD>/rem1/runout.sh report-baseline (reads the two reports per main-plan section 5)
EXIT_CODE: 0
Output Summary: Tests Passed: 5049; root tests 5058, failures 0, errors 0, disabled 9; no failing testcase. Line coverage: .claude helpers 96.97% (160/5), .codex helpers 96.97% (160/5), EpicScopeResolution.psm1 90.38% (94/10). Overall 95.83%.

Timestamp note: `Timestamp:` is the local run start (2026-09-25T21-14, UTC 2026-09-26T01:14:31Z). Both report last-write times (JUnit 2026-09-26T01:18:18Z, coverage 2026-09-26T01:17:25Z) are after it.

| Field | Value |
| --- | --- |
| Console line | `Tests Passed: 5049,` |
| Root tests | 5058 |
| Root failures | 0 |
| Root errors | 0 |
| Root disabled | 9 |
| Failing testcases | none |
| .claude/hooks/enforce-orchestration-preimplementation-gate-helpers.ps1 | 96.97% (covered 160, missed 5) |
| .codex/hooks/enforce-orchestration-preimplementation-gate-helpers.ps1 | 96.97% (covered 160, missed 5) |
| .claude/lib/worktree-resolution/EpicScopeResolution.psm1 | 90.38% (covered 94, missed 10) |

## Output

```
# Run (filtered to StartUtc, the coverage summary, EndUtc, and the exit code; WhatIf and verifier messages from tests are omitted because one carries a host path)
StartUtc: 2026-09-26T01:14:31.2931080Z
Covered 95.06% / 0%. 14,193 analyzed Commands in 109 Files.
EndUtc: 2026-09-26T01:18:18.9968457Z
PROCESS_EXIT_CODE: 0

# Report (artifacts/pester/pester-junit.xml and artifacts/pester/powershell-coverage.xml)
JUnitLastWriteUtc: 2026-09-26T01:18:18.9171775Z
CoverageLastWriteUtc: 2026-09-26T01:17:25.4593567Z
ConsoleLine: Tests Passed: 5049,
Root: tests=5058 failures=0 errors=0 disabled=9
FailingTestcases: none
OverallLine: 95.83% covered=9828 missed=428
File .claude/hooks/enforce-orchestration-preimplementation-gate-helpers.ps1: 96.97% covered=160 missed=5 lineElements=165
File .codex/hooks/enforce-orchestration-preimplementation-gate-helpers.ps1: 96.97% covered=160 missed=5 lineElements=165
File .claude/lib/worktree-resolution/EpicScopeResolution.psm1: 90.38% covered=94 missed=10 lineElements=104
CoverageFilesBelow85OrUnmeasured: 0
REPORT_EXIT_CODE: 0
PROCESS_EXIT_CODE: 0
```
