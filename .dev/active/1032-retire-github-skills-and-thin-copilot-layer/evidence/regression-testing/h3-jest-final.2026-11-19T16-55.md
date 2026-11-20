# H3 Final Jest Gate ([P2-T2], GATE-RUN)

Timestamp: 2026-11-19T16-55
Plan: plan-h3-sync-writer-retirement.md
Command: sh .claude/skills/test-execution-policy/scripts/run-test-suite.sh jest-extension --coverage --coverageReporters=json-summary --coverageReporters=text-summary --coverageDirectory=SCRATCH/jest-h3-final-cov --json --outputFile=SCRATCH/jest-h3-final.json (Jest of extensions/drm-copilot through its normal parallel workers)
EXIT_CODE: 0
Output Summary: 369 suites passed, 0 failed; 6115 tests passed, 0 failed (Phase 0: 6119; the four deleted local-lane tests of P1-T2 and P1-T3).
  Overall coverage: lines 97.42% (68402/70212), branches 94.63% (10595/11196); Phase 0: lines 97.42%, branches 94.63%.
  src/repo-automation-command-registration-admin.ts: lines 98.17% (431/439), branches 90.00% (63/70); Phase 0: 98.26% (452/460), 90.27% (65/72) — the decrease comes from removing covered code (21 lines, 2 branches); see the coverage delta.
  src/lib/push-down/reference-rewrites.ts: lines 99.15% (234/236), branches 94.11% (16/17); Phase 0: 99.17% (241/243), 94.11% (16/17).
  Named suites: extension.test.ts 28/0, extension.workflow-commands.test.ts 25/0, lib/push-down/reference-rewrites.test.ts 14/0 (includes `contains all six catalog entries keyed by normalized reference`), repo-automation-command-registration-admin.test.ts 8/0.
  extension.integration.test.ts is in the integration lane and runs in CI only (`integration-lane-deviation-h3.2026-11-19T15-15.md`).
