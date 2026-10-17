# Baseline PowerShell Analysis (P0-T16)

Timestamp: 2026-10-09T02-51
Command: mcp__drm-copilot__run_poshqc_analyze scan_folders [".claude/lib/blast-radius", "tests/scripts/claude-lib/blast-radius"] (substitute for the plan's direct Invoke-ScriptAnalyzer loop)
EXIT_CODE: 0
Output Summary: substitute evidence. PoshQC analyze returned ok:true over both folders, which contain the four P0-T16 files. Per-file `Findings=` integers are not available from the MCP result; the gate result is treated as `Findings=0 Errors=0` for all four files on the basis of ok:true.

## Deviation (PowerShell route denied)

The plan's `Invoke-ScriptAnalyzer` loop needs the PowerShell tool or inline `pwsh`; inline `pwsh` is denied by the worktree-isolation hook (denial text recorded in requirements-source.2026-10-09T02-51.md). Per operator constraint 3, the PoshQC MCP analyzer result is the substitute evidence, and the per-file counts are recorded as unavailable rather than inferred numerically.
