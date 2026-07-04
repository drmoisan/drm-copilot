# F8 Final QA — Test + Coverage

Timestamp: 2026-06-26T00-00
Command: `node run-jest.cjs --coverage --collectCoverageFrom="src/lib/**/*.ts"` (run from `extensions/drm-copilot/`)
EXIT_CODE: 0

Output Summary:
- Test Suites: 85 passed, 85 total.
- Tests: 999 passed, 999 total.
- Overall `src/lib/**` (All files): line 97.73%, branch 88.29%.
- `lib/new-active-feature-folder` cluster aggregate: line 99.22%, branch 91.5%.

Per-file coverage for the new files (line% / branch%):
- `src/lib/new-active-feature-folder/models.ts` — line 97.36%, branch 83.33%.
- `src/lib/new-active-feature-folder/markdown.ts` — line 100%, branch 93.1%.
- `src/lib/new-active-feature-folder/io.ts` — line 98.89%, branch 88.88%.
- `src/lib/new-active-feature-folder/docs.ts` — line 100%, branch 100%.
- `src/lib/new-active-feature-folder/flow.ts` — line 99.54%, branch 92.1%.
- `src/lib/new-active-feature-folder/index.ts` — line 100%, branch 100% (re-export-only facade; the 10.34% function metric reflects the re-export pattern and carries no executable behavior per `.claude/rules/general-unit-test.md`).
- `src/lib/new-active-feature-folder/new-active-feature-folder-service-call.ts` — line 100%, branch 100%.

Threshold check: every new executable file meets line >= 85% and branch >= 75%.
No `markdown-header.ts`, `io-launcher.ts`, or `flow-minor-audit.ts` split was required (all files stayed under 500 lines), so those contingent files do not exist.
