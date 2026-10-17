# R2 Decisions (Issue #927)

Timestamp: 2026-10-16T10-21
Command: Decision record for R2
EXIT_CODE: 0
Output Summary: Eight decisions recorded for remediation cycle 2: the PA-1R route (D-R2-1), the route B invocation form (D-R2-2), the CR-R1 design and changed-line measure (D-R2-3), and NO_ACTION dispositions for CR-R2 to CR-R6 with their reasons.

DECISION D-R2-1: PA-1R regenerated locally under D-RUN-9 (route A MCP over SCAN_FULL per D-RUN-9a; route B direct Invoke-PoshQCTest when route A falls short)
DECISION D-R2-2: route B runs through sh SCRATCH/927/r2/run-poshqc-927.sh (isolation guard refuses command text containing the PowerShell host name)
DECISION D-R2-3: CR-R1 try/finally Dispose; changed-line coverage on the canonical helper; codex copy by whole-file coverage
DECISION CR-R2: NO_ACTION real-process row not added (powershell.md line 74; general-unit-test.md lines 72 and 105; no test location outside the Pester run paths)
DECISION CR-R3: NO_ACTION worst case 20 s under the 30 s Codex registration timeout (D-R1-2)
DECISION CR-R4: NO_ACTION entry-point line 403 runs only as a process; uncovered at baseline (D-R1-12)
DECISION CR-R5: NO_ACTION enforce-epic-merge-gate.ps1 491 of 500 lines; not edited in R2
DECISION CR-R6: NO_ACTION Claude seam mocks retained because the discovery guard requires them (D-R1-6 fallback)
