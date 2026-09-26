# B2 Scoped Pester with Coverage ([P2-T9])

Timestamp: 2026-09-25T19-19
Command: sh <SCRATCHPAD>/i663/run.sh p2-test  (fresh process: Import-Module ./scripts/powershell/PoshQC/PoshQC.psd1; Invoke-PoshQCTest -Root $root -ScanFolders tests/scripts/claude-lib -SettingsPath scripts/powershell/PoshQC/settings/pester.runsettings.psd1); then sh <SCRATCHPAD>/i663/run.sh p2-report (reads both reports per plan section 5)
EXIT_CODE: 0
Output Summary: 1561 passed, 0 failed; root failures 0, errors 0; EpicScopeResolution.Tests.ps1 passed 21, EpicScopeReadiness.Tests.ps1 passed 14, WorktreeResolution.Manifest.Tests.ps1 passed 16, ClaudeLibModuleConvention.Tests.ps1 failures 0 errors 0; EpicScopeResolution.psm1 89.42% and EpicScopeReadiness.psm1 95.92% line coverage.

Timestamp note: local time (UTC-4); the run started at 2026-09-25T23:19:51Z.

Report last-write times:
- artifacts/pester/pester-junit.xml: 2026-09-25T23:20:54Z (19:20 local)
- artifacts/pester/powershell-coverage.xml: 2026-09-25T23:20:43Z (19:20 local)

Console lines: `Tests Passed: 1561,` / `Failed: 0,`; coverage console line `Covered 34.86% / 0%. 14,121 analyzed Commands in 108 Files.` (command coverage over the whole allow-list for a claude-lib-only scan; informational).

Root testsuites: tests=1561 failures=0 errors=0 disabled=0
Failing testcases: none

| Owning testsuite | tests | failures | errors | passed |
| --- | --- | --- | --- | --- |
| tests/scripts/claude-lib/worktree-resolution/EpicScopeResolution.Tests.ps1 | 21 | 0 | 0 | 21 |
| tests/scripts/claude-lib/worktree-resolution/EpicScopeReadiness.Tests.ps1 | 14 | 0 | 0 | 14 |
| tests/scripts/claude-lib/worktree-resolution/WorktreeResolution.Manifest.Tests.ps1 | 16 | 0 | 0 | 16 |
| tests/scripts/claude-lib/ClaudeLibModuleConvention.Tests.ps1 | 6 | 0 | 0 | 6 |

Line coverage of the new modules:

| File | Percent | covered | missed |
| --- | --- | --- | --- |
| .claude/lib/worktree-resolution/EpicScopeResolution.psm1 | 89.42% | 93 | 11 |
| .claude/lib/worktree-resolution/EpicScopeReadiness.psm1 | 95.92% | 47 | 2 |
