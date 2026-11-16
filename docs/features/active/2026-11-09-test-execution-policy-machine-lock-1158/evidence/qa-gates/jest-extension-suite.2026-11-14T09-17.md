# Final QC: Extension Jest Suite (P7-T6)

Timestamp: 2026-11-14T09-17
Command: sh .claude/skills/test-execution-policy/scripts/run-test-suite.sh jest-extension (through SCRATCH/issue-1158-launch.sh); collection proof: sh .claude/skills/test-execution-policy/scripts/run-test-suite.sh jest-extension --listTests
EXIT_CODE: 0
Output Summary: launcher exit 0, with no queue timeout and no refusal. `Test Suites: 338 passed, 338 total`; `Tests: 5543 passed, 5543 total`; 0 failed. The `--listTests` run through the same launcher listed 338 test files, the same as the suite count, and none of them contains `integration`.

## Lane Exclusion

None of the four integration-named files of P0-T6 was collected:

| File | Collected |
|---|---|
| `extensions/drm-copilot/test/extension.collect-commit-context.integration.test.ts` | no |
| `extensions/drm-copilot/test/extension.integration.test.ts` | no |
| `extensions/drm-copilot/test/lib/pr-context/collector-integration.test.ts` | no |
| `extensions/drm-copilot/test/lib/push-down/codex-bundle-publish.integration.test.ts` | no |
