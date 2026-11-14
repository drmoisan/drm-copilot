# Task Check P1-T1

Timestamp: 2026-11-14T18-35
Command: sh SCRATCH/issue-1173-c1-tsfiles.sh test/mcp-tool-inputs-docs.import-graph.test.ts (Prettier check, ESLint, npm run typecheck); sh .claude/skills/test-execution-policy/scripts/run-test-suite.sh jest-extension --testPathPatterns=import-graph --verbose
EXIT_CODE: 1
ExpectedExitCode: 1
Output Summary:
- Changed files: extensions/drm-copilot/test/mcp-tool-inputs-docs.import-graph.test.ts (new).
- Selection: the new test file itself (rule: a new test file is its own selection; it imports no production module).
- Prettier check: exit 0. ESLint: exit 0. Typecheck: exit 0.
- Jest selection: exit 1 by design ([expect-fail]); 1 passed (in-memory cycle), 3 failed (two cycle tests, grammar module absent). Evidence: evidence/regression-testing/import-cycle-fail-before.2026-11-14T18-35.md.
- Note: a positional test path passed to the jest-extension launcher suite ran 342 suites without the new file ("Ran all test suites."), so the selection uses --testPathPatterns. The positional runs are not evidence.
