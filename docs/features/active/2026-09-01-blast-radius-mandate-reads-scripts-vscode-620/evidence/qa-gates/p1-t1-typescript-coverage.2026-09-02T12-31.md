---
Feature: 2026-09-01-blast-radius-mandate-reads-scripts-vscode-620
Phase: 1
Task: P1-T1
---

# Phase 1 — TypeScript Coverage Capture

Timestamp: 2026-09-02T12-31

Command: npm run test:coverage

Working Directory: extensions/drm-copilot

EXIT_CODE: 0

## Output Summary

TypeScript coverage command completed successfully. Repository-wide coverage metrics:
- **Line coverage: 96.72%** (44234/45730 statements)
- **Branch coverage: 90.17%** (6297/6983 branches)
- Function coverage: 89.93% (1295/1440 functions)

All coverage thresholds met:
- Line coverage 96.72% >= required 85% ✓
- Branch coverage 90.17% >= required 75% ✓

Test suites: 203 passed, 203 total
Tests: 2735 passed, 2735 total
Snapshots: 0 total
Execution time: 9.584 seconds

## Coverage Artifact Location

Coverage report artifact location: `extensions/drm-copilot/coverage/lcov.info`
File size: 602K (57258 lines)
Format: LCOV (coverage.py compatible)
Generated: 2026-09-02 08:33 UTC

## Coverage LCOV File Sample

The `coverage/lcov.info` file exists and contains valid LCOV format data. Sample excerpt (first 100 lines):

```
TN:
SF:src\claude-worktree-session.ts
FN:78,formatWorktreeTimestamp
FN:98,buildWorktreeGroupDirectory
FN:120,deriveWorktreeGroupDirectory
FN:139,buildWorktreePath
FN:156,buildBuildBranchName
FN:175,quoteForPwsh
FN:195,buildWorktreeSessionCommands
FNF:7
FNH:7
FNDA:21,formatWorktreeTimestamp
FNDA:26,buildWorktreeGroupDirectory
FNDA:42,deriveWorktreeGroupDirectory
FNDA:23,buildWorktreePath
FNDA:20,buildBranchName
FNDA:233,quoteForPwsh
FNDA:26,buildWorktreeSessionCommands
DA:1,1
DA:2,1
...
[57258 total lines in LCOV file]
```

The file contains complete coverage instrumentation for all 203 test suites that passed execution.

## Notes on Changed File Exclusion (AC-5)

The changed file in this remediation cycle (`config-carriage.test-helpers.ts`) is located under `extensions/drm-copilot/test/lib/push-down/` and is correctly excluded from `collectCoverageFrom` scope in `jest.config.cjs`. Per repository coverage policy, test files are excluded from coverage measurement denominators. This exclusion is correct and policy-compliant. The file's absence from coverage metrics does not constitute a defect or gap.
