# TypeScript Test Gate (P9-T6)

Timestamp: 2026-11-17T10-25
Command: sh .claude/skills/test-execution-policy/scripts/run-test-suite.sh jest-extension --coverage (sh SCRATCH/issue-1035-p9t56-run.sh; node run-jest.cjs in extensions/drm-copilot, normal parallel workers, integration lane excluded; the same form as the Phase 0 baseline). Per-file figures read from extensions/drm-copilot/coverage/lcov.info with SCRATCH/issue-1035-lcov.py, the reader used for the baseline.
EXIT_CODE: 0
Output Summary: Test Suites: 351 passed, 351 total. Tests: 5881 passed, 0 failed, 5881 total. Every coverageThreshold met (the coverage run exits 0 with the per-file threshold map, including root.ts, feature-folder-name.ts and write-scopes.ts). Repo-wide from lcov.info: line 97.25%, branch 94.20% (baseline 97.19%, 94.00%).

## Coverage comparison and fixes

The first P9-T6 run (5871 tests, 0 failed) left six files below their Phase 0 figures. Each was analyzed against the merge-base diff hunks:
- `src/lib/new-active-feature-folder/flow.ts` (line 99.59 to 99.21): changed lines of the workspace-templates fallback had no test. Added flow.test.ts "falls back to the templates area of the resolved root when no template root is given".
- `src/lib/pr-context/feature-docs.ts` (branch 87.27 to 84.48) and `src/lib/pr-context/render-feature-excerpts.ts` (branch 89.66 to 87.78): the changed `activeFeatureSegment` helper carried an unreachable `?? ""` fallback and an untested empty-segment branch. The helper now cuts the segment at the next `/` with `indexOf`, so every branch is reachable, and both suites gained cases for a folder path with no trailing segment and for an empty segment.
- `src/lib/pr-context/feature-docs-parsers.ts` (branch 91.23 to 91.07, file unchanged on the branch), `src/lib/pr-context/verification-evidence.ts` (branch 93.94 to 93.75) and `src/lib/resolve/file-prompt-variables.ts` (line 95.25 to 95.00): the uncovered lines and branches are pre-existing and outside every changed hunk; the drops come from the denominator (v8 branch counts on the unchanged file, and covered code removed by the branch in the other two). Tests were added for pre-existing gaps: parseReadinessValue (no marker, unknown value), a markdown line with no key separator, tryRelativeToWorkspace of the root itself, resolveFolderpath of a bare file name, and stripFrontMatter without a closing delimiter.

The TypeScript loop restarted from formatting after these changes (typescript-static.2026-11-17T10-25.md). After the fixes every file is at or above its baseline:

| File | Line % | Branch % | Baseline line % | Baseline branch % |
| --- | --- | --- | --- | --- |
| src/lib/development-docs/root.ts | 100.00 | 95.74 | absent (threshold 85/75) | absent |
| src/lib/development-docs/feature-folder-name.ts | 100.00 | 100.00 | absent (threshold 85/75) | absent |
| src/lib/development-docs/write-scopes.ts | 100.00 | 100.00 | absent (threshold 85/75) | absent |
| src/lib/new-active-feature-folder/io.ts | 99.51 | 91.78 | 99.49 | 91.67 |
| src/lib/new-active-feature-folder/flow.ts | 99.61 | 94.74 | 99.59 | 93.33 |
| src/lib/potential-to-issue/content.ts | 99.23 | 89.23 | 99.17 | 88.89 |
| src/lib/potential-to-issue/promotion.ts | 99.00 | 84.00 | 98.89 | 83.82 |
| src/lib/resolve/file-prompt-variables.ts | 97.35 | 88.89 | 95.25 | 75.76 |
| src/extension-command-helpers.ts | 99.52 | 94.12 | 99.45 | 93.85 |
| src/lib/new-potential-bug-entry.ts | 97.86 | 87.27 | 97.83 | 87.27 |
| src/repo-automation-service.ts | 98.38 | 93.48 | 98.32 | 93.33 |
| src/lib/pr-context/feature-docs.ts | 94.86 | 88.33 | 94.48 | 87.27 |
| src/lib/pr-context/render-feature-excerpts.ts | 98.01 | 90.22 | 97.91 | 89.66 |
| src/lib/pr-context/verification-evidence.ts | 100.00 | 97.06 | 99.23 | 93.94 |
| src/lib/pr-context/summary-helpers.ts | 94.60 | 89.36 | 94.57 | 89.25 |
| src/lib/pr-context/collector-core.ts | 97.91 | 90.38 | 97.91 | 90.20 |
| src/lib/pr-context/feature-docs-parsers.ts | 99.35 | 98.31 | 98.05 | 91.23 |
| src/lib/validate/epic-orchestrator-state-resolution.ts | 98.85 | 96.99 | 98.85 | 96.99 |
| src/lib/validate/parallel-orchestrator-state-cohort-barrier.ts | 99.51 | 98.91 | 99.51 | 98.88 |
| src/lib/validate/epic-planner-readiness-integrity.ts | 100.00 | 97.47 | 100.00 | 97.40 |
| src/lib/validate/epic-kickoff-artifact.ts | 96.35 | 83.17 | 96.33 | 83.17 |
| src/lib/validate/parallel-kickoff-artifact.ts | 100.00 | 88.79 | 100.00 | 88.79 |
| src/lib/validate/orchestrator-state-issue-adoption.ts | 100.00 | 100.00 | 100.00 | 100.00 |
| src/lib/validate/evidence-locations.ts | 100.00 | 100.00 | 100.00 | 100.00 |
| src/lib/validate/orchestrator-state-feature-folder-record.ts | 100.00 | 100.00 | 100.00 | 100.00 |
| src/lib/json-config.ts | 96.23 | 83.33 | 96.19 | 83.33 |
| src/lib/file-system.ts | 95.72 | 85.29 | 95.60 | 85.29 |
| src/lib/push-down/codex-agents-customizations.ts | 98.48 | 92.54 | 98.48 | 92.54 |

## Negative observations

- P1-T4 (no-vscode-import.test.ts): sh SCRATCH/issue-1035-p1t4-mutant.sh prepended `import * as vscode from "vscode";` to `extensions/drm-copilot/src/lib/development-docs/root.ts` (git diff --stat: 1 insertion) and ran the suite: EXIT=1, "Tests: 1 failed, 7 passed, 8 total", failing case "development-docs modules are host-neutral › extensions/drm-copilot/src/lib/development-docs/root.ts does not import vscode". The file was restored with git checkout and `git status --short` for it is empty.
- P7-T5 (write-scopes.contract.test.ts): recorded in other/task-check.P7-T5.2026-11-17T09-08.md. Removing `  - "Write(/.dev/active/**)"` from `.claude/agents/prd-feature.md` made the checker suite fail with EXIT=1, "Tests: 2 failed, 24 passed, 26 total" (forward coverage on the real tree, and the in-memory one-root case that then counted two missing entries); the file was restored with git checkout.
