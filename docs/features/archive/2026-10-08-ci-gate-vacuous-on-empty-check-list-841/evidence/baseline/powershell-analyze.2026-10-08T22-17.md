# PSScriptAnalyzer Baseline (#841, P0-T11)

Timestamp: 2026-10-10T09-13
Command: mcp__drm-copilot__run_poshqc_analyze workspace_root=<worktree> scan_folders=[".claude/lib/ci-gate","tests/scripts/claude-lib/ci-gate"]
EXIT_CODE: 0
Output Summary: PSSA-SUMMARY DiagnosticCount=0. PSSA_0=0. The MCP call returned normally (ok=true); per the operator-specified semantics it raises "PSScriptAnalyzer reported N issue(s)." on findings, so a normal return records zero diagnostics. No PSSA lines to record.

ROUTE_SUBSTITUTION: scratch scripts A1-A8 prohibited by operator constraint; substitutes below. The plan command `sh SCRATCH/run-ps.sh SCRATCH/pssa-count.ps1 <2 files>` was replaced by the A5 substitute: the MCP analyze call over the two scan folders (a superset containing the two plan-named files plus `CiGate.Manifest.Tests.ps1`).

MCP result: `{"ok":true,"tool":"run_poshqc_analyze",...,"summary":"Ran bundled PoshQC analyze against '<worktree>' with 2 selected scan folder(s)."}`

DiagnosticCount=0
PSSA_0=0
