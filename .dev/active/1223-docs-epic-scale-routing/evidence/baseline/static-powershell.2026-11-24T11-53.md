# PowerShell static baseline (P0-T1)

Timestamp: 2026-11-24T11-53
Command: mcp__drm-copilot__run_poshqc_format (workspace root = this worktree); then `git status --porcelain`; then sh SCRATCH/issue-1223-analyze.sh (direct `Invoke-ScriptAnalyzer -Recurse -Settings scripts/powershell/PoshQC/settings/pssa.settings.psd1` over `scripts` and `tests/scripts`)
EXIT_CODE: 0
Output Summary:
- Format step (PoshQC MCP, exit code not exposed by the MCP result; `ok: true`): `git status --porcelain` listed no modified tracked file after the format run.
- Analyzer step: `folder=scripts findings=0`, `folder=tests/scripts findings=0`, `TOTAL_FINDINGS=0`, exit code 0.
- The new test file does not exist yet; the baseline is the repository result.
