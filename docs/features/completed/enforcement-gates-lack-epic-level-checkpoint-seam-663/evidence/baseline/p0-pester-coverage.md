# Full Pester Baseline with Coverage ([P0-T10])

Timestamp: 2026-09-25T19-01
Command: sh <SCRATCHPAD>/i663/run.sh qc-test-full  (fresh process: Import-Module ./scripts/powershell/PoshQC/PoshQC.psd1; Invoke-PoshQCTest -Root $root -SettingsPath scripts/powershell/PoshQC/settings/pester.runsettings.psd1); then sh <SCRATCHPAD>/i663/run.sh p0-report (reads both reports per plan section 5)
EXIT_CODE: 0
Output Summary: 4954 passed, 0 failed, 9 skipped; root tests=4963 failures=0 errors=0 disabled=9; overall line coverage 95.77%; all six measured files at or above 85%.

Timestamp note: `Timestamp:` is local time (UTC-4); the run started at 2026-09-25T23:01:51Z (19:01 local).

Report last-write times:
- artifacts/pester/pester-junit.xml: 2026-09-25T23:05:46Z (19:05 local)
- artifacts/pester/powershell-coverage.xml: 2026-09-25T23:04:47Z (19:04 local)

Console line: `Tests Passed: 4954, Failed: 0, Skipped: 9, Inconclusive: 0, NotRun: 0` (Pester prints these fields on separate lines; `Tests Passed: 4954,` begins the sequence). Coverage console line: `Covered 94.99% / 0%. 13,904 analyzed Commands in 106 Files.` (command coverage, informational).

Root testsuites: tests=4963 failures=0 errors=0 disabled=9

Failing testcases: none

Overall line coverage: 95.77% (covered=9603, missed=424)

Per-file line coverage:

| File | Percent | covered | missed |
| --- | --- | --- | --- |
| .claude/hooks/enforce-orchestration-preimplementation-gate-helpers.ps1 | 96.71% | 147 | 5 |
| .codex/hooks/enforce-orchestration-preimplementation-gate-helpers.ps1 | 96.71% | 147 | 5 |
| .claude/hooks/enforce-pr-author-skill-helpers.ps1 | 96.67% | 87 | 3 |
| .claude/hooks/enforce-pr-author-skill.epic-base-branch.ps1 | 92.31% | 24 | 2 |
| .claude/hooks/enforce-model-routing-receipt.ps1 | 94.74% | 54 | 3 |
| .claude/hooks/enforce-orchestration-preimplementation-gate.ps1 | 88.31% | 136 | 18 |
