# Scoped coverage baseline (P0-T9)

Timestamp: 2026-10-16T00-32
Command: mcp__drm-copilot__run_poshqc_test workspace_root=WORKTREE scan_folders=["tests/scripts/codex-hooks"]
EXIT_CODE: 0
RUNNER-SETTINGS: installed-extension
Output Summary: ok true; summary: "Ran bundled PoshQC test against 'WORKTREE' with 1 selected scan folder(s)." REPORT-LINE missed=9432 covered=2848 LinePercent=23.19 (scoped run; population is the full coverage config, so the percentage is low by construction). Both XML files were absent before the run and present after. Porcelain listed only the FEATURE evidence directory.

Command: stat -c %Y artifacts/pester/powershell-coverage.xml artifacts/pester/pester-junit.xml (before)
EXIT_CODE: 1
Output: both files absent ("No such file or directory")

Command: stat -c %Y artifacts/pester/powershell-coverage.xml artifacts/pester/pester-junit.xml (after)
EXIT_CODE: 0
Output: 1792110946 and 1792110977

Command: cp artifacts/pester/powershell-coverage.xml SCRATCH/p0-scoped/powershell-coverage.xml
EXIT_CODE: 0

Command: cp artifacts/pester/pester-junit.xml SCRATCH/p0-scoped/pester-junit.xml
EXIT_CODE: 0

Command: git status --porcelain
EXIT_CODE: 0
Output: ?? docs/features/active/2026-10-15-hook-coverage-attribution-gaps-936/evidence/

Command: poetry run python -I SCRATCH/cov936.py counter SCRATCH/p0-scoped/powershell-coverage.xml
EXIT_CODE: 0
Output: REPORT-LINE missed=9432 covered=2848 LinePercent=23.19

Note: the caller's earlier observation of ambient-state failures in two Codex suites did not recur on this run; the MCP result was ok true.
