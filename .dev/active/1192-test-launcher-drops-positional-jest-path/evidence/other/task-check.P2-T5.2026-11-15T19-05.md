# Task check P2-T5

Timestamp: 2026-11-15T19-05
Command: `git grep -n -F "seven docs MCP" -- extensions/drm-copilot/jest.config.cjs`; `git grep -n -F "five docs MCP" -- extensions/drm-copilot/jest.config.cjs`; the launcher `jest-extension` suite with the single positional `test/jest-config-resolution.test.ts` via `sh SCRATCH/issue-1192-jestsel.sh`.
EXIT_CODE: 0 for the first search and the Jest run; 1 for the second search, with no output, as required.
Output Summary:
- Changed file: `extensions/drm-copilot/jest.config.cjs` (comment text only; `jest.docs-coverage.json` lists seven modules).
- Search results: the "seven docs MCP" token matches once; the "five docs MCP" token returns no match.
- Jest through the launcher with the positional: `Test Suites: 1 passed, 1 total`, `Tests: 11 passed, 11 total`, `Ran all test suites matching test/jest-config-resolution.test.ts.` The positional now selects only that file and the config loads. Before the fix this call ran the full suite minus the file.
- Selection rule: the contract tests that read the config path; none pins the comment.
