# Task Check P4-T1

Timestamp: 2026-11-18T10-22
Command: npx prettier --check / eslint / tsc x2 (extensions/drm-copilot); sh .claude/skills/test-execution-policy/scripts/run-test-suite.sh jest-extension test/lib/push-down/push-down-bundle-manifest-completeness
EXIT_CODE: 1
ExpectedExitCode: 1
Output Summary: Static checks exit 0 for the new test file. The selection (the new test itself) fails by design ([expect-fail]): 4 of 6 cases pass and the Claude and Codex listing cases fail with 14 and 40 unlisted paths, recorded in `evidence/regression-testing/completeness-first-run.2026-11-18T10-21.md`. P4-T2 and P4-T3 make it pass before P4-T6.

- Changed files: `extensions/drm-copilot/test/lib/push-down/push-down-bundle-manifest-completeness.test.ts`
- Selection rule: the new test file.
