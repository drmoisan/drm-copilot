# Remediation Cycle 3 Baseline TypeScript Test Coverage (P0-T16)

Timestamp: 2026-10-16T08-23
Command: npm --prefix extensions/drm-copilot run test:coverage > SCRATCH/rc3/ts-coverage-baseline.txt 2>&1; grep -e 'Test Suites:' -e 'Tests:' -e 'Lines  ' -e 'Branches  ' SCRATCH/rc3/ts-coverage-baseline.txt; ls -l extensions/drm-copilot/coverage/lcov.info
EXIT_CODE: 0
Output Summary:
- Test Suites: 277 passed, 277 total
- Tests:       4051 passed, 4051 total
- Lines        : 97.32% ( 51271/52679 )
- Branches     : 92.48% ( 7631/8251 )
- -rw-r--r-- 1 DanMoisan 197121 716442 Oct 16 04:22 extensions/drm-copilot/coverage/lcov.info (local time; 08:22 UTC)
- 0 failed.
