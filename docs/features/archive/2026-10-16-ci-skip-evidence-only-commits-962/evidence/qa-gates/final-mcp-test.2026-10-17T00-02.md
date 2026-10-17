# Final QA pass 1: unit-test stage, route compliance (P6-T4)

Timestamp: 2026-10-17T00-02
Command: mcp__drm-copilot__run_poshqc_test (workspace_root <WORKSPACE_ROOT>, scan_folders ["tests/scripts/ci", "tests/scripts/workflows"])
EXIT_CODE: 0
MCP_CALL: returned
Output Summary: The MCP PoshQC test tool returned (ok=true). Per rule 5, no count, percentage, or finding is read from this result; the counts come from CR-PESTER-LIST (P6-T5) and coverage from CR-PESTER-COV and CR-COV-FILES (P6-T6, P6-T7), which run after this call because it overwrites artifacts/pester/powershell-coverage.xml. CI job: poshqc / PowerShell QC (windows-latest).
