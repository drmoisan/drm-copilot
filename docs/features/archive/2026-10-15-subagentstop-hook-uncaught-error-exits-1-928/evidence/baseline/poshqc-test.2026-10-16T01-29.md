# Baseline PoshQC Test (issue #928)

Timestamp: 2026-10-16T01-10
Command: mcp__drm-copilot__run_poshqc_test
MCP_DISPOSITION: ok
EXIT_CODE: 0

Scope: scan_folders ["tests/scripts/claude-hooks", "tests/scripts/claude-runtime"], workspace_root WORKTREE_ROOT. The test call started at 2026-10-16T01-10 and completed at 2026-10-16T01-29.
Follow-up command: poetry run python SCRATCH/928/junit_rows.py artifacts/pester/pester-junit.xml hook-dependency-guard-completeness.Tests.ps1 hook-dependency-failure.Claude.Tests.ps1 claude-settings.Tests.ps1 subagentstop-envelope.Tests.ps1 (exit 0)

Output Summary:
- MTIME_UTC 2026-10-16T01-29 (not earlier than Timestamp 2026-10-16T01-10)
- TOTALS tests 5319 failures 0 errors 0
- ANYFAIL lines: none (pre-existing failure set is empty)
- SUITE hook-dependency-guard-completeness.Tests.ps1 MATCHED 598 FAILED 0
- SUITE hook-dependency-failure.Claude.Tests.ps1 MATCHED 148 FAILED 0
- SUITE claude-settings.Tests.ps1 MATCHED 9 FAILED 0
- SUITE subagentstop-envelope.Tests.ps1 MATCHED 78 FAILED 0
