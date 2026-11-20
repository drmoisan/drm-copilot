# [P3-T9] Jest runs over the suites that read the changed bundle file

Timestamp: 2026-11-07T02-35
Command: node run-jest.cjs test/packaging/discovery-resources.test.ts test/lib/push-down/claude-pack-manifest-completeness.test.ts, then the same two suites with --randomize --seed=1031, in extensions/drm-copilot/
EXIT_CODE: 0
Output Summary: both runs: 33 passed, 0 failed; seed 1031 recorded.

## Runs

| Run | Seed | Suites | Passed | Failed |
|---|---|---|---|---|
| ordered | none | 2 | 33 | 0 |
| shuffled | 1031 | 2 | 33 | 0 |
