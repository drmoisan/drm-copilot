# Remediation Cycle 1 Baseline TypeScript Full Suite and lcov (P0-T19)

Timestamp: 2026-10-16T03-51
Command: npm --prefix extensions/drm-copilot run test:coverage > SCRATCH/rc1/ts-coverage-baseline.txt 2>&1; grep -e 'Test Suites:' -e 'Tests:' -e 'Lines  ' -e 'Branches  ' SCRATCH/rc1/ts-coverage-baseline.txt; ls -l extensions/drm-copilot/coverage/lcov.info
EXIT_CODE: 0
Output Summary:
- Test Suites: 271 passed, 271 total
- Tests:       4009 passed, 4009 total
- Branches     : 92.29% ( 7568/8200 )
- Lines        : 97.26% ( 51173/52610 )
- -rw-r--r-- 1 DanMoisan 197121 714570 Oct 15 23:50 extensions/drm-copilot/coverage/lcov.info (exists; local time)
