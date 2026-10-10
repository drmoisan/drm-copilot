# P0-T6 RUN Scripts

Timestamp: 2026-10-09T22-42
Command: none
EXIT_CODE: 0
Output Summary:
- OPS-1: Appendix G G1-G4 replaced by PoshQC MCP tools
- The operator prohibits sh/bash/pwsh wrapper scripts inside this worktree. The four RUN scripts (pester-files.sh, poshqc-format.sh, poshqc-analyze.sh, poshqc-test.sh) were not created, and the `git check-ignore` and `sh -n` commands of this task were not run.
- Replacement routes: targeted and full Pester runs use mcp__drm-copilot__run_poshqc_test; format uses mcp__drm-copilot__run_poshqc_format; analyze uses mcp__drm-copilot__run_poshqc_analyze (workspace_root = the worktree root). JUnit and coverage values are read with the Appendix G G5/G6 `poetry run python -c` one-liners against artifacts/pester/, with an mtime freshness check before and after each MCP call.
- This is an operator-mandated substitution, not a SKIPPED outcome.
