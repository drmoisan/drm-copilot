# [P6-T11] Jest isolation

Timestamp: 2026-11-04T18-45

## Run 1 (gate)

Command: node run-jest.cjs test/packaging/discovery-resources.test.ts test/packaging/mcp-server-prepack.test.ts (in extensions/drm-copilot, through SCRATCH/issue-1031-jest.sh)
EXIT_CODE: 0
Output Summary: Test Suites: 2 passed, 2 total; Tests: 14 passed, 14 total; 0 failed.

## Run 2 (seeded random order)

Command: node run-jest.cjs --randomize --seed=1031 test/packaging/discovery-resources.test.ts test/packaging/mcp-server-prepack.test.ts
EXIT_CODE: 0
Output Summary: Seed: 1031; Test Suites: 2 passed, 2 total; Tests: 14 passed, 14 total; 0 failed.
