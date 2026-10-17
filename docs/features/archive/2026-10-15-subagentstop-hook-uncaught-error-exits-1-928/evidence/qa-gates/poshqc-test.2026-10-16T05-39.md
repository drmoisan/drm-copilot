# PoshQC Test (remediation cycle 1 final QC, pass 1)

Timestamp: 2026-10-16T05-28
Command: mcp__drm-copilot__run_poshqc_test
MCP_DISPOSITION: ok
EXIT_CODE: 0
Scope: scan_folders ["tests/scripts/claude-hooks", "tests/scripts/claude-runtime"], workspace_root WORKTREE_ROOT
Returned summary: Ran bundled PoshQC test against 'WORKTREE_ROOT' with 2 selected scan folder(s).
Second command: poetry run python SCRATCH/928/junit_rows.py artifacts/pester/pester-junit.xml subagentstop-uncaught-error.Tests.ps1 hook-dependency-guard-completeness.Tests.ps1 hook-dependency-failure.Claude.Tests.ps1 claude-settings.Tests.ps1 subagentstop-envelope.Tests.ps1 subagentstop-envelope-orchestrator-family.Registration.Tests.ps1 validate-required-artifact-output.Envelope.Tests.ps1 enforce-gate-suites.EpicStateIsolation.Discovery.Tests.ps1
Output Summary:
- Timestamp is the UTC clock read immediately before the MCP test call; the file name carries the write time.
- MTIME_UTC 2026-10-16T05-39 (not earlier than Timestamp)
- TOTALS tests 5334 failures 0 errors 0 (baseline 5332; +2 U1-ST rows)
- ANYFAIL lines: none
- SUITE subagentstop-uncaught-error.Tests.ps1 MATCHED 13 FAILED 0
- SUITE hook-dependency-guard-completeness.Tests.ps1 MATCHED 598 FAILED 0
- SUITE hook-dependency-failure.Claude.Tests.ps1 MATCHED 148 FAILED 0
- SUITE claude-settings.Tests.ps1 MATCHED 9 FAILED 0
- SUITE subagentstop-envelope.Tests.ps1 MATCHED 78 FAILED 0
- SUITE subagentstop-envelope-orchestrator-family.Registration.Tests.ps1 MATCHED 11 FAILED 0
- SUITE validate-required-artifact-output.Envelope.Tests.ps1 MATCHED 15 FAILED 0
- SUITE enforce-gate-suites.EpicStateIsolation.Discovery.Tests.ps1 MATCHED 344 FAILED 0
- PASS U1-ST: .claude/hooks/validate-discovery-artifact-gate.ps1 blocks with exit 2 when the validation call raises a statement-terminating error
- PASS U1-ST: .claude/hooks/validate-pr-author-output.ps1 blocks with exit 2 when the validation call raises a statement-terminating error
