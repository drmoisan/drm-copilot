# R1 QC Step 3: PoshQC Pester (Issue #927, loop pass 1, FAILED; CR-5 fallback)

Timestamp: 2026-10-16T08-30
Command: stat -c %Y artifacts/pester/pester-junit.xml
EXIT_CODE: 0
Output Summary: Loop pass 1 failed. The run reports tests=7181 failures=1 errors=0. The single failure is the epic-state isolation discovery row AC-4 for suite E (J15a = 0): with the CR-5 removal applied, the guard still computes six closure seams for tests/scripts/codex-hooks/enforce-epic-merge-gate-docs-only.Tests.ps1 and finds no mock for them in the outermost BeforeAll. Per decision D-R1-6 the authorized fallback TE-R is applied, CR-5 is retained, and the Phase 7 loop restarts at [P7-T1].

JUNIT_MTIME_BEFORE: 1792137653

Command 2: mcp__drm-copilot__run_poshqc_test workspace_root=<WORKSPACE_ROOT> scan_folders=["tests/scripts/claude-hooks", "tests/scripts/codex-hooks", "tests/scripts/claude-runtime"]
MCP_CALL: error Command exited with code 1.

J1 JUNIT_MTIME_AFTER: 1792139381 (greater than before; rewritten)
J2 TESTSUITES: tests=7181 failures=1 errors=0
J3 FAILED: discovery guard (both hook surfaces).AC-4 tests/scripts/codex-hooks/enforce-epic-merge-gate-docs-only.Tests.ps1 complies with the baseline isolation form for every closure seam
J15a: 0

GUARD_FINDING: Expected 0 findings, got 6. Mock of Get-ChildOrchestratorCheckpointContent, Get-EpicOrchestratorCheckpointContent, Get-ParallelOrchestratorCheckpointContent, Get-WorktreeItemCheckpointText, Get-WorktreeItemLiveRoot, and Get-WorktreeRunCheckpointText missing from outermost BeforeAll of tests/scripts/codex-hooks/enforce-epic-merge-gate-docs-only.Tests.ps1 (enforce-gate-suites.EpicStateIsolation.Discovery.Tests.ps1 line 118).
CR5_DECISION: RETAINED
CR5_REASON: the epic-state isolation discovery guard includes the six Claude seams in the closure it computes for the Codex suite, so the mocks and the interception probe are required by repository guard AC-4/AC-6 even though the Codex gate does not call them.
LOOP_ACTION: apply TE-R (Appendix TX), commit and push the correction, restart at [P7-T1].
