Timestamp: 2026-09-07T10-58

Command: cd extensions/drm-copilot && node run-jest.cjs --testPathPatterns=test/lib/pr-context/collector-core.test.ts --testNamePattern="routes previously-dropped paths into bucketDocs"

EXIT_CODE: 0

Output Summary:
Test Suites: 1 passed, 1 total
Tests: 5 skipped, 1 passed, 6 total

The new regression test now passes against the fixed collector-core.ts, confirming
`.claude/skills/example/SKILL.md` and `src/example.ts` land in bucketDocs after the
terminal `else` branch was added. This is the pass-after evidence required by AC2 and
AC1.
