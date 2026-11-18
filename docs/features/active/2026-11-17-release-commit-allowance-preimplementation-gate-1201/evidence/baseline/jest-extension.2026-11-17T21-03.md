# Phase 0 baseline - Jest extension gate

Timestamp: 2026-11-17T21-02
Command: env -u VIRTUAL_ENV sh .claude/skills/test-execution-policy/scripts/run-test-suite.sh jest-extension --coverage --coverageReporters=json-summary --coverageReporters=lcov --coverageReporters=text-summary --coverageDirectory=SCRATCH/issue-1201-p0-jest-cov (Jest through its normal parallel workers in extensions/drm-copilot)
EXIT_CODE: 0
Output Summary:
- Run window 2026-11-17T21-02 to 2026-11-17T21-03 UTC: Test Suites 344 passed of 344; Tests 5681 passed of 5681; 0 failed. coverageThreshold map: no threshold failure reported.
- Repo-wide (coverage-summary total): lines 64780/66650 = 97.19%; branches 9998/10636 = 94%; functions 92.27%.
- src/lib/push-down/claude-customizations.ts: lines 496/496 = 100%; branches 61/63 = 96.82%; functions 68.18%.
- The LCOV and JSON summary of this run are kept as SCRATCH/issue-1201-p0-jest-cov for the final comparison.
