# r1 P0-T22 — Jest baseline with coverage

Timestamp: 2026-10-03T12-50
Command: pwsh -NoProfile -File SCRATCH/steps/r1-p0-t22.ps1 -Worktree WORKTREE; step script runs `npm --prefix extensions/drm-copilot run test:coverage *> "$Scratch/r1-jest-baseline.log"; $jestExit = $LASTEXITCODE; "JEST-EXIT=$jestExit"`, the summary Select-String line, and the P0-T22 RELAY line
EXIT_CODE: 0
Output Summary:
- JEST-EXIT=0 (relayed; both Lines and Branches percentages present)
- Statements   : 97.09% ( 50858/52382 )
- Branches     : 91.37% ( 7419/8119 )
- Lines        : 97.09% ( 50858/52382 )
- Test Suites: 251 passed, 251 total
- Tests:       3808 passed, 3808 total
- No `●` line. BASELINE-JEST-FAILURES = (empty).
