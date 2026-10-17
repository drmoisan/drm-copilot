# Full coverage baseline (P0-T12)

Timestamp: 2026-10-16T01-14
Command: mcp__drm-copilot__run_poshqc_test workspace_root=WORKTREE
EXIT_CODE: 1
ExpectedExitCode: 1
RUNNER-SETTINGS: installed-extension
Output Summary: The MCP call returned no result object: 'MCP server "drm-copilot" tool "run_poshqc_test" sent no response or progress for 1817s; aborting.' Under the Evidence derivation (no "Command exited with code N." text) EXIT_CODE is 1. The underlying Pester process kept running after the abort and finished writing both XML files (junit and coverage mtimes stable across four 30-second samples before the copy). JUnit TOTAL=10376 FAILED=0. REPORT-LINE missed=667 covered=11613 LinePercent=94.57. Porcelain listed only the FEATURE evidence directory.

Command: stat -c %Y artifacts/pester/powershell-coverage.xml artifacts/pester/pester-junit.xml (before)
EXIT_CODE: 0
Output: 1792110946 and 1792110977 (the scoped-run files from P0-T9)

Command: stat -c %Y artifacts/pester/powershell-coverage.xml artifacts/pester/pester-junit.xml (after)
EXIT_CODE: 0
Output: 1792112836 and 1792112983 (both greater than before; second sample taken after the run stopped writing)

Command: cp artifacts/pester/powershell-coverage.xml SCRATCH/p0-full/powershell-coverage.xml
EXIT_CODE: 0

Command: cp artifacts/pester/pester-junit.xml SCRATCH/p0-full/pester-junit.xml
EXIT_CODE: 0

Command: git status --porcelain
EXIT_CODE: 0
Output: ?? docs/features/active/2026-10-15-hook-coverage-attribution-gaps-936/evidence/

Command: poetry run python -I SCRATCH/cov936.py counter SCRATCH/p0-full/powershell-coverage.xml
EXIT_CODE: 0
Output: REPORT-LINE missed=667 covered=11613 LinePercent=94.57
