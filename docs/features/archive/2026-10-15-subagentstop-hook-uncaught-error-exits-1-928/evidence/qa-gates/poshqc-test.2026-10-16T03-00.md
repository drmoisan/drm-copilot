# Final PoshQC Test (issue #928, P6-T6, loop pass 1)

Timestamp: 2026-10-16T03-00
Command: mcp__drm-copilot__run_poshqc_test
MCP_DISPOSITION: ok
EXIT_CODE: 0

Scope: scan_folders ["tests/scripts/claude-hooks", "tests/scripts/claude-runtime"], workspace_root WORKTREE_ROOT. The test call started at 2026-10-16T03-00; the report was written at 2026-10-16T03-14.
Follow-up command: poetry run python SCRATCH/928/junit_rows.py artifacts/pester/pester-junit.xml subagentstop-uncaught-error.Tests.ps1 hook-dependency-guard-completeness.Tests.ps1 hook-dependency-failure.Claude.Tests.ps1 claude-settings.Tests.ps1 subagentstop-envelope.Tests.ps1 subagentstop-envelope-orchestrator-family.Registration.Tests.ps1 validate-required-artifact-output.Envelope.Tests.ps1 enforce-gate-suites.EpicStateIsolation.Discovery.Tests.ps1 (exit 0)

Output Summary:
- MTIME_UTC 2026-10-16T03-14 (not earlier than Timestamp 2026-10-16T03-00)
- TOTALS tests 5332 failures 0 errors 0
- ANYFAIL lines: none
- SUITE subagentstop-uncaught-error.Tests.ps1 MATCHED 11 FAILED 0
- SUITE hook-dependency-guard-completeness.Tests.ps1 MATCHED 598 FAILED 0
- SUITE hook-dependency-failure.Claude.Tests.ps1 MATCHED 148 FAILED 0
- SUITE claude-settings.Tests.ps1 MATCHED 9 FAILED 0
- SUITE subagentstop-envelope.Tests.ps1 MATCHED 78 FAILED 0
- SUITE subagentstop-envelope-orchestrator-family.Registration.Tests.ps1 MATCHED 11 FAILED 0
- SUITE validate-required-artifact-output.Envelope.Tests.ps1 MATCHED 15 FAILED 0
- SUITE enforce-gate-suites.EpicStateIsolation.Discovery.Tests.ps1 MATCHED 344 FAILED 0

Named rows for the P6-T1..P6-T3 edits (all PASS):
- PASS REG-4 validate-orchestrator-output.ps1 / validate-executor-output.ps1 / validate-planner-output.ps1 / validate-required-artifact-output.ps1 calls Exit-SubagentStopBlock twice at script scope after the inline S1 tail
- PASS E-RA-10 calls Exit-SubagentStopBlock exactly twice, neither inside the missing-argument if block
- PASS baseline mock interception probe (subagentstop-uncaught-error.Tests.ps1)
- PASS AC-6 tests/scripts/claude-hooks/subagentstop-uncaught-error.Tests.ps1 calls the interception probe from inside an It
- PASS AC-4 tests/scripts/claude-hooks/subagentstop-uncaught-error.Tests.ps1 complies with the baseline isolation form for every closure seam
- PASS U1 (nine rows) and U2 in subagentstop-uncaught-error.Tests.ps1
