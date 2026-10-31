# Full Pester Run over tests/scripts with Coverage (issue #1009)

Timestamp: 2026-10-30T18-43
Command: sh SCRATCH/issue-1009-full.sh full2 (fresh PowerShell 7 process: Import-Module scripts/powershell/PoshQC/PoshQC.psd1; Invoke-PoshQCTest -Root <worktree> -ScanFolders tests/scripts, coverage population from config/poshqc-coverage.json; counts from artifacts/pester/pester-junit.xml)
EXIT_CODE: 0
Output Summary: JUnit total=13329 passed=13319 failed=0 skipped=10 (tests completed in 764.46s). `tests/scripts/ci/FileSizePolicy.RepoGate.Tests.ps1` 5/5 passed. The 10 skipped tests are pre-existing skip conditions outside this change; none is in a file this change creates or edits.

Coverage from this run: HookTargetWorktree.psm1 151/152 = 99.34%; hook-target-worktree.ps1 148/149 = 99.33%; Claude batch-budget hooks 143/152 = 94.08% each; Codex batch-budget hooks 114/119 = 95.80% each.

Loop history: the first full run (SCRATCH label full1) reported 13317 passed and 2 failed, both in `tests/scripts/claude-hooks/enforce-gate-suites.EpicStateIsolation.Discovery.Tests.ps1` (AC-4 rows for the two Claude target-worktree suites). After the fix described in `format.2026-10-30T18-27.md`, the loop was re-run from [P9-T1] through [P9-T9] (all clean) and this fresh full run passed.
