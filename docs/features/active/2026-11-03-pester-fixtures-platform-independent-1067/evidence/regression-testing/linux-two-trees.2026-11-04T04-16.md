# Linux Run: tests/scripts/dev-tools and tests/scripts/powershell/PoshQC (P6-T7)

Timestamp: 2026-11-04T04-16
Command: pwsh -NoProfile -NonInteractive -File SCRATCH/issue-1067-run-pester.ps1 -Root <worktree> -Paths tests/scripts/dev-tools tests/scripts/powershell/PoshQC (one fresh PowerShell 7 process, coverage and JUnit off, PassThru, no shuffle)
EXIT_CODE: 0
Output Summary:
- TOTAL Tests=934 Passed=925 Failed=0 Skipped=9 NotRun=0 (baseline 2026-11-04T03-19: 925 tests, 827 passed, 89 failed, 9 skipped; 9 tests added by this item)
- CONTAINERS Total=60 Failed=0; every FILE line reports failed=0.
- Probes after the run: POSHQC_SKIP_SCRIPT_EXECUTION=1, GLOBAL_PROMPT_CHANGED=False, LEAKED_GLOBAL_FUNCTIONS=0, LASTEXITCODE=0.
- The remaining POSHQC_SKIP_SCRIPT_EXECUTION leak comes from `tests/scripts/dev-tools/link-feature-docs.Tests.ps1` and `tests/scripts/dev-tools/link-parent-child.Tests.ps1`, which set the variable without restoring it. Both are outside this item's change set; recorded as a new finding for follow-up, not changed here.
