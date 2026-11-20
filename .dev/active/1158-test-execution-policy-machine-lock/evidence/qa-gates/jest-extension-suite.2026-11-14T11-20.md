# Final QC: Extension Jest Suite (P7-T6, loop restart after the #1162 merge)

Timestamp: 2026-11-14T11-20
Command: sh .claude/skills/test-execution-policy/scripts/run-test-suite.sh jest-extension (through SCRATCH/issue-1158-launch.sh); collection proof: sh .claude/skills/test-execution-policy/scripts/run-test-suite.sh jest-extension --listTests
EXIT_CODE: 0
Output Summary: the launcher exited 0, with no queue timeout and no refusal. Jest reported `Test Suites: 340 passed, 340 total` and `Tests: 5616 passed, 5616 total`, with 0 failed. The `--listTests` run through the same launcher listed 340 test files, the same as the suite count, and none of them contains `integration`.

## Lane Exclusion

None of the four integration-named files of P0-T6 was collected:

- `extensions/drm-copilot/test/extension.collect-commit-context.integration.test.ts`
- `extensions/drm-copilot/test/extension.integration.test.ts`
- `extensions/drm-copilot/test/lib/pr-context/collector-integration.test.ts`
- `extensions/drm-copilot/test/lib/push-down/codex-bundle-publish.integration.test.ts`
