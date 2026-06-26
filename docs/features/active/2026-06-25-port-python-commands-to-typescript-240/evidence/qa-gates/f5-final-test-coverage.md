# F5 Final QA — Test + Coverage

Timestamp: 2026-06-26T01-43
Command: node run-jest.cjs --coverage --collectCoverageFrom="src/lib/**/*.ts" (run from extensions/drm-copilot/)
EXIT_CODE: 0

Output Summary:
- Test Suites: 60 passed, 60 total
- Tests: 698 passed, 698 total
- Coverage (src/lib/** scope), All files: Lines 96.30%, Branch 88.06%
- `lib/resolve` group: Lines 96.80%, Branch 83.79%

Per-new-file coverage (line% / branch%):
- src/lib/resolve/hard-lock-prompt.ts: 94.33% / 83.58%
- src/lib/resolve/file-prompt-core.ts: 98.67% / 84.00%
- src/lib/resolve/file-prompt-variables.ts: 95.25% / 75.75%
- src/lib/resolve/file-prompt-transforms.ts (split sibling of file-prompt-variables.ts): 100% / 86.66%
- src/lib/resolve/resolve-prompts-service-call.ts: 100% / 100%

Threshold check: every new src/lib/resolve/** file meets line >= 85% and branch >= 75%.
