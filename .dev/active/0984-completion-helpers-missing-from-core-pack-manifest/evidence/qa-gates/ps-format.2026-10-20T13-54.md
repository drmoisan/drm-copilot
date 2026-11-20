# QA Gate: PowerShell Format (Issue #984)

Timestamp: 2026-10-20T13-54
Command: mcp__drm-copilot__run_poshqc_format with scan folders .claude/hooks, .codex/hooks, tests/scripts/claude-hooks, tests/scripts/codex-hooks, tests/scripts/claude-runtime, with git status --porcelain recorded before and after; then sh SCRATCH/issue-984-ps.sh issue-984-ps-check.ps1 -Mode format -ListFile SCRATCH/issue-984-p6-ps-files.txt (non-writing Invoke-Formatter comparison)
EXIT_CODE: 0
Output Summary: the porcelain listing after the MCP format run equals the listing before it (diff empty; git diff --stat unchanged at 27 files, 213 insertions, 122 deletions); the non-writing check reports 0 of 11 files whose formatted text differs (TOTAL: 0). The MCP result carries no output, so no count is read from it.

Files checked: `.claude/hooks/enforce-completion-consistency.ps1`, `.claude/hooks/enforce-discovery-artifact-gate.ps1`, `.claude/hooks/enforce-python-batch-budget.ps1`, `.claude/hooks/enforce-powershell-batch-budget.ps1`, `.codex/hooks/enforce-python-batch-budget.ps1`, `.codex/hooks/enforce-powershell-batch-budget.ps1`, `tests/scripts/claude-runtime/HookImportFailureExemptions.Helpers.ps1`, `tests/scripts/claude-hooks/enforce-completion-consistency.HelperImportFailure.Tests.ps1`, `tests/scripts/claude-hooks/enforce-discovery-artifact-gate.ValidationImportFailure.Tests.ps1`, `tests/scripts/claude-hooks/enforce-batch-budget.RouteImportFailure.Tests.ps1`, `tests/scripts/codex-hooks/codex-batch-budget.RouteImportFailure.Tests.ps1`
