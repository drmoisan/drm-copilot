# Fail-before run: package-typecheck-script.test.ts (#647, AC-6)

Timestamp: 2026-10-01T23-18
Command: npm --prefix extensions/drm-copilot run test -- test/package-typecheck-script.test.ts; echo "EXIT=$?"
EXIT_CODE: 1
ExpectedExitCode: 1

State: run after P8-T1 (test created) and before P8-T4 (package.json) and P8-T5 (workflow).

Test Suites: 1 failed, 1 total
Tests:       3 failed, 1 passed, 4 total

Per-test status:
- typecheck script chains typecheck:test: FAIL (Expected "tsc -p ./ --noEmit && npm run typecheck:test", Received "tsc -p ./ --noEmit")
- typecheck:test script checks tsconfig.jest.json: FAIL (Error: extension package.json has no string script 'typecheck:test')
- compile and build do not reference tsconfig.jest.json: PASS
- extension tests workflow runs the typecheck script before tests: FAIL (workflow text does not contain "Type-check extension source and test tree")

Output Summary: EXIT=1 as expected; 3 failed and 1 passed, each failure caused by the missing gate wiring that P8-T4 and P8-T5 add.
