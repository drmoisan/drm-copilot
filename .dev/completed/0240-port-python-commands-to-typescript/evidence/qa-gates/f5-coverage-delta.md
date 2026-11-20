# F5 Coverage Delta / Threshold Verification

Timestamp: 2026-06-26T01-43
Command:
- Baseline (P0-T3): node run-jest.cjs --coverage --collectCoverageFrom="src/lib/**/*.ts" (see f5-ts-test-baseline.md)
- Post-change (P3-T4): node run-jest.cjs --coverage --collectCoverageFrom="src/lib/**/*.ts" (see f5-final-test-coverage.md)
EXIT_CODE: 0

Output Summary:

Overall src/lib/** coverage:
- Baseline: Lines 96.09%, Branch 89.40%
- Post-change: Lines 96.30%, Branch 88.06%
- Line coverage increased (+0.21pp). Branch coverage decreased by 1.34pp, attributable solely to adding new resolver modules that introduce additional branches; existing lines and branches were not made less covered. Post-change overall branch (88.06%) remains well above the 75% policy floor.

New/changed-code coverage (each new src/lib/resolve/** file, line% / branch%):
- hard-lock-prompt.ts: 94.33% / 83.58%
- file-prompt-core.ts: 98.67% / 84.00%
- file-prompt-variables.ts: 95.25% / 75.75%
- file-prompt-transforms.ts: 100% / 86.66%
- resolve-prompts-service-call.ts: 100% / 100%

Threshold verification:
- Every new file meets line >= 85% and branch >= 75%.
- No regression on changed lines: the new code is the only changed/added production code and all new files exceed the policy floors.
- Overall src/lib/** line coverage did not regress (96.09% -> 96.30%).

Result: PASS. All required numeric coverage values are present and meet thresholds.
