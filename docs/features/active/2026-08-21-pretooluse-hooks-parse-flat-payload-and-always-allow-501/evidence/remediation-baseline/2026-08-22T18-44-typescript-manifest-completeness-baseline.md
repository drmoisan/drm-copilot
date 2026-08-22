# Baseline — TypeScript manifest-completeness test (expect-fail)

Timestamp: 2026-08-22T18-44
Command: npx jest --config extensions/drm-copilot/jest.config.cjs test/lib/push-down/claude-pack-manifest-completeness.test.ts
EXIT_CODE: 1
Output Summary: Test Suites: 1 failed, 1 total. Tests: 1 failed, 14 passed, 15 total. The test named "lists every bundled .claude agent, skill, and hook file in some pack manifest" failed with a missing array of ['.claude/hooks/enforce-parallel-cohort-barrier-helpers.ps1', '.claude/hooks/enforce-pr-author-skill-helpers.ps1', '.claude/lib/hook-payload/HookPayload.psm1'] (TypeScript scope additionally covers .claude/lib/, so HookPayload.psm1 also surfaces here). Confirms the CI failure reproduces locally before the fix.
