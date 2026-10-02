# Baseline — Target Jest File (issue #647, remediation cycle 1)

Timestamp: 2026-10-02T00-34
Command: npm --prefix extensions/drm-copilot run test -- test/lib/validate/build-validate-orchestration-service-call-input.test.ts > <SCRATCH>/jest-target-base.txt 2>&1; echo "EXIT=$?"; grep -E '^(Test Suites|Tests):' <SCRATCH>/jest-target-base.txt
EXIT_CODE: 0
Output Summary:
- Test Suites: 1 passed, 1 total
- Tests:       5 passed, 5 total
- TARGET_BASE_PASSED = 5; FAILED = 0.
- Result: pass (baseline expectation met).
