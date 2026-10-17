# Remediation Cycle 2 Baseline TypeScript Test Coverage (P0-T16)

Timestamp: 2026-10-16T06-21
Command: npm --prefix extensions/drm-copilot run test:coverage > SCRATCH/rc2/ts-coverage-baseline.txt 2>&1; grep -e 'Test Suites:' -e 'Tests:' -e 'Lines  ' -e 'Branches  ' SCRATCH/rc2/ts-coverage-baseline.txt; ls -l extensions/drm-copilot/coverage/lcov.info
EXIT_CODE: 0
Output Summary:
- Test Suites: 273 passed, 273 total
- Tests:       4023 passed, 4023 total
- Lines        : 97.27% ( 51226/52661 )
- Branches     : 92.34% ( 7585/8214 )
- -rw-r--r-- 1 DanMoisan 197121 715392 Oct 16 02:20 extensions/drm-copilot/coverage/lcov.info  (local time EDT; 06:20 UTC)
- 0 failed.
