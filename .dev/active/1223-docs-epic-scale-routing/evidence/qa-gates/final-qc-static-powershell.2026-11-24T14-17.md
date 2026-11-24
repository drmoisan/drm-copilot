# Final QC static: PowerShell (P3-T1)

Timestamp: 2026-11-24T14-17
Command: (1) mcp__drm-copilot__run_poshqc_format over the worktree, then `git status --porcelain`; (2) mcp__drm-copilot__run_poshqc_analyze over the worktree; (3) sh SCRATCH/issue-1223-analyze.sh (direct Invoke-ScriptAnalyzer -Recurse with scripts/powershell/PoshQC/settings/pssa.settings.psd1 over scripts and tests/scripts)
EXIT_CODE: 0
Output Summary:
- Format (PoshQC MCP, ok: true, exit code not exposed by the MCP result): finding count 0; the porcelain status after the run was empty (no rewrite).
- Analyze (PoshQC MCP, ok: true, exit code not exposed): finding count read from the direct run, 0.
- Direct analyzer: folder=scripts findings=0; folder=tests/scripts findings=0; TOTAL_FINDINGS=0; exit code 0. The run prints one "Object reference not set to an instance of an object" parser notice that is not a finding.
- Comparison with the Phase 0 baseline (static-powershell.2026-11-24T11-53.md): findings 0 before, 0 after; no regression. The new test file adds 0 findings.
