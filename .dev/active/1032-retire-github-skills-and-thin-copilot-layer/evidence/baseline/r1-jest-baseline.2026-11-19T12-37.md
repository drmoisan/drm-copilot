# R1 Jest Phase 0 Baseline ([P0-T3])

Plan: remediation-plan.2026-11-19T12-09.md
Timestamp: 2026-11-19T12-37
Command: sh .claude/skills/test-execution-policy/scripts/run-test-suite.sh jest-extension --coverage --coverageReporters=json-summary --coverageReporters=text-summary --coverageDirectory=SCRATCH/jest-r1-baseline-cov --json --outputFile=SCRATCH/jest-r1-baseline.json; summary through sh SCRATCH/issue-1032-r1-run.sh issue-1032-r1-jestsum.ps1
EXIT_CODE: 0
Output Summary: one Jest GATE-RUN of `extensions/drm-copilot` through its normal parallel workers on the merged head (integration lane excluded by the launcher): Test Suites 369 passed of 369; Tests 6119 passed, 0 failed. Failing tests: none. Overall coverage: lines 97.42% (68430/70240), branches 94.63% (10597/11198). `src/lib/push-down/copilot-customizations-engine.ts`: lines 100% (314/314), branches 100% (34/34).

## Named Suites

| Suite | Status | Tests | Failed |
| --- | --- | --- | --- |
| `copilot-customizations-engine.test.ts` | passed | 15 | 0 |
| `push-down-bundle-manifest-completeness.test.ts` | passed | 6 | 0 |
| `push-down-pack-resolver.test.ts` | passed | 20 | 0 |
