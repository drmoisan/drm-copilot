# Baseline — Full Jest Suite with Coverage (issue #647, remediation cycle 1)

Timestamp: 2026-10-02T00-34
Command: npm --prefix extensions/drm-copilot run test:coverage > <SCRATCH>/coverage-base.txt 2>&1; echo "EXIT=$?"; grep -E '^(Test Suites|Tests):' <SCRATCH>/coverage-base.txt; grep -E '^ *(Statements|Branches|Functions|Lines) +:' <SCRATCH>/coverage-base.txt
EXIT_CODE: 0
Output Summary:
- Test Suites: 250 passed, 250 total
- Tests:       3786 passed, 3786 total
- Statements   : 97.07% ( 50618/52144 )
- Branches     : 91.35% ( 7391/8090 )
- Functions    : 91.52% ( 1522/1663 )
- Lines        : 97.07% ( 50618/52144 )
- FULL_BASE_PASSED = 3786 (expected 3786; pass); FAILED = 0.
- LINES_BASE_PCT = 97.07; BRANCHES_BASE_PCT = 91.35. Both equal the reference values 97.07 and 91.35.
- Separate `Lines` and `Branches` rows were printed.
