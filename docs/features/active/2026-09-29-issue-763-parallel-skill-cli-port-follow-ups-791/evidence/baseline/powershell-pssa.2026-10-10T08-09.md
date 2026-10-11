# Baseline — PSScriptAnalyzer (PoshQC MCP analyze)

Timestamp: 2026-10-10T08-09
Task: [P0-T13]
Command: mcp__drm-copilot__run_poshqc_analyze (workspace_root = agent worktree root; scan_folders omitted, so the configured scan set was used)
EXIT_CODE: 0
CI-DEFERRED: yes

Output Summary:
- MCP result: `{"ok":true,"tool":"run_poshqc_analyze", ... "summary":"Ran bundled PoshQC analyze against '<worktree root>'."}`
- Call disposition: ok = true. EXIT_CODE 0 records the `ok: true` disposition; the MCP result carries no analyzer output.
- PSSA_FINDINGS: not available from the MCP result. The numeric baseline for `tests/scripts/claude-hooks/enforce-parallel-abandon-gate.TriggerScoping.Tests.ps1` will be taken from the CI PowerShell job log on the pull request.
- The scratchpad runners `run-ps-791.sh`, `pssa-791.ps1`, `format-check-791.ps1`, and `pester-791.ps1` were not created, per the operator constraint. Deviation recorded in `evidence/other/execution-deviations.2026-10-10T08-02.md`.
