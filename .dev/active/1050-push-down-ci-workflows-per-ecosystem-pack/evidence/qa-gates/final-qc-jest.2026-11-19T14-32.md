# Final QC test gate: Jest (extensions/drm-copilot)

Timestamp: 2026-11-19T14-32
Command: sh .claude/skills/test-execution-policy/scripts/run-test-suite.sh jest-extension --coverage
EXIT_CODE: 0
Output Summary: Test Suites 374 passed of 374; Tests 6185 passed, 0 failed. Repo-wide: lines 97.44% (69097/70909), branches 94.66% (10720/11324), statements 97.44%, functions 92.86%.
Baseline comparison (`baseline-jest.2026-11-19T08-55.md`): lines 97.42% -> 97.44%, branches 94.63% -> 94.66%; no new failing test; no coverage drop; thresholds 85% line and 75% branch met. This cycle changes no production TypeScript file (test helper and test only), so no per-file production figure moved. The new helper function findPythonCoverageStepViolations is exercised by the new test on the real workflow and three negative variants.
