# Post-change scoped coverage run (P1-T7)

Timestamp: 2026-10-16T01-28
Command: mcp__drm-copilot__run_poshqc_test workspace_root=WORKTREE scan_folders=["tests/scripts/codex-hooks"]
EXIT_CODE: 0
ExpectedExitCode: 0
RUNNER-SETTINGS: installed-extension
Output Summary: ok true; summary: "Ran bundled PoshQC test against 'WORKTREE' with 1 selected scan folder(s)." REPORT-LINE missed=9432 covered=2848 LinePercent=23.19 (scoped run; identical to the scoped baseline). Baseline test-scoped EXIT_CODE was 0, so ExpectedExitCode is 0. Porcelain listed only FEATURE evidence paths.

Command: stat -c %Y artifacts/pester/powershell-coverage.xml artifacts/pester/pester-junit.xml (before)
EXIT_CODE: 0
Output: 1792112836 and 1792112983 (full-run files from P0-T12)

Command: stat -c %Y artifacts/pester/powershell-coverage.xml artifacts/pester/pester-junit.xml (after)
EXIT_CODE: 0
Output: 1792114029 and 1792114063 (both greater than before)

Command: cp artifacts/pester/powershell-coverage.xml SCRATCH/p1-scoped/powershell-coverage.xml
EXIT_CODE: 0

Command: cp artifacts/pester/pester-junit.xml SCRATCH/p1-scoped/pester-junit.xml
EXIT_CODE: 0

Command: git status --porcelain
EXIT_CODE: 0
Output: only untracked paths under docs/features/active/2026-10-15-hook-coverage-attribution-gaps-936/evidence/regression-testing/

Command: poetry run python -I SCRATCH/cov936.py counter SCRATCH/p1-scoped/powershell-coverage.xml
EXIT_CODE: 0
Output: REPORT-LINE missed=9432 covered=2848 LinePercent=23.19
