# Baseline: actionlint on ci.yml (Issue #973)

Timestamp: 2026-10-17T13-09
Command: sh SCRATCH/issue-973-run.sh issue-973-actionlint.ps1 -Root <worktree> (PowerShell 7; scripts/dev-tools/run-actionlint.ps1 .github/workflows/ci.yml)
EXIT_CODE: 0

actionlint resolved from PATH; no `tools/` directory was created. Output: `Running actionlint...` and no finding lines.

Output Summary: actionlint exit code 0; 0 findings on `.github/workflows/ci.yml`.
