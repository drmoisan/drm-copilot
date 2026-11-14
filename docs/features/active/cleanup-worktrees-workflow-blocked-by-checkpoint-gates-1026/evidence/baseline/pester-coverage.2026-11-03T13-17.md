# Baseline Pester With Coverage (Issue #1026)

Timestamp: 2026-11-03T13-17
Command: sh SCRATCH/issue-1026-bg.sh SCRATCH/issue-1026-fullrun.txt baseline-full (fresh single-process PowerShell 7: Import-Module scripts/powershell/PoshQC/PoshQC.psd1; Invoke-PoshQCTest -Root <item worktree> -ScanFolders tests/scripts)
EXIT_CODE: 0
Output Summary: artifacts/pester/pester-junit.xml: 13723 testcases, 13713 passed, 0 failed, 10 skipped (testsuites failures=0 errors=0 disabled=10). Pester console: Tests completed in 914.95s; Covered 92.84% of 34,743 analyzed commands in 260 files. artifacts/pester/powershell-coverage.xml total line coverage 93.62% (21249 covered, 1449 missed). Per-file line coverage of the five existing production files is in the table below.

Run start: the run began at 2026-11-03T12-56 from the committed branch state; the coverage population and the test discovery were fixed at start. New files created later in the session were not part of this run (`.claude/hooks/hook-cleanup-context.ps1` is absent from the coverage XML).

| File | Lines covered | Lines missed | Line coverage |
|---|---|---|---|
| `.claude/hooks/enforce-orchestration-preimplementation-gate.ps1` | 153 | 6 | 96.23% |
| `.codex/hooks/enforce-orchestration-preimplementation-gate.ps1` | 169 | 0 | 100% |
| `.claude/hooks/enforce-pr-author-skill-helpers.ps1` | 129 | 3 | 97.73% |
| `.claude/hooks/enforce-pr-author-skill.docs-only.ps1` | 53 | 1 | 98.15% |
| `.claude/hooks/enforce-model-routing-receipt.ps1` | 81 | 3 | 96.43% |

Copies of both baseline XML files are kept as SCRATCH/baseline-coverage.xml and SCRATCH/baseline-junit.xml for the P9-T4 comparison.
