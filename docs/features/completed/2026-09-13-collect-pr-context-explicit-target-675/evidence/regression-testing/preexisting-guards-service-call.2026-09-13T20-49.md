Timestamp: 2026-09-17T13:48Z
Command: node run-jest.cjs test/lib/pr-context/pr-context-service-call.test.ts -t "<name>" (from extensions/drm-copilot/), run once per test name below.
EXIT_CODE: 0
Output Summary: Each of the four commands exited 0 reporting 1 passed test (with the remaining 7 tests in the suite skipped by the `-t` filter):
- `writes exactly the paths it reports in result.artifacts` — 1 passed
- `writes both artifacts and succeeds when the GitHub CLI is unavailable` — 1 passed
- `raises when a stale file is present and the write is discarded` — 1 passed
- `raises naming the appendix when the summary write succeeds and the appendix write fails` — 1 passed

All four currently-passing regression guards required by the epic ("Currently-passing cases are included as regression guards, not omitted as redundant") remain passing after the empty-diff guard landed in Phase 6.
