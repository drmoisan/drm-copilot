# H3 Jest Phase 0 Baseline ([P0-T4], GATE-RUN)

Timestamp: 2026-11-19T14-49
Plan: plan-h3-sync-writer-retirement.md
Command: sh .claude/skills/test-execution-policy/scripts/run-test-suite.sh jest-extension --coverage --coverageReporters=json-summary --coverageReporters=text-summary --coverageDirectory=SCRATCH/jest-h3-baseline-cov --json --outputFile=SCRATCH/jest-h3-baseline.json (Jest of extensions/drm-copilot through its normal parallel workers; integration and golden lanes excluded by the launcher)
EXIT_CODE: 0
Output Summary: 369 suites passed, 0 failed; 6119 tests passed, 0 failed.
  Overall coverage: lines 97.42% (68430/70240), branches 94.63% (10597/11198).
  src/repo-automation-command-registration-admin.ts: lines 98.26% (452/460), branches 90.27% (65/72).
  src/lib/push-down/reference-rewrites.ts: lines 99.17% (241/243), branches 94.11% (16/17).
  Named suites: extension.test.ts 29/0, extension.workflow-commands.test.ts 27/0, lib/push-down/reference-rewrites.test.ts 15/0, repo-automation-command-registration-admin.test.ts 8/0 (tests/failures).
  extension.integration.test.ts matches the `.integration.test.ts` lane pattern of config/test-execution-policy.json, so the local gate excludes it; it runs in CI (non-blocking deviation recorded under evidence/other/ at P1-T2).
