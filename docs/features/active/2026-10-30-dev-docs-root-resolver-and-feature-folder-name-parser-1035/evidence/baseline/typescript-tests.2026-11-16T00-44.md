# P0-T5 Jest Gate — Phase 0 baseline

Timestamp: 2026-11-16T00-44
Command: sh .claude/skills/test-execution-policy/scripts/run-test-suite.sh jest-extension --coverage (node run-jest.cjs in extensions/drm-copilot, normal parallel workers, integration lane excluded)
EXIT_CODE: 0
Output Summary: Test Suites: 344 passed, 344 total. Tests: 5681 passed, 0 failed, 5681 total. Every coverageThreshold met. Repo-wide from extensions/drm-copilot/coverage/lcov.info: line 97.19%, branch 94.00%. Per-file figures below; the three new development-docs files are absent before the change and are judged against the thresholds.

| File | Line % | Branch % |
| --- | --- | --- |
| src/lib/development-docs/root.ts | absent | absent |
| src/lib/development-docs/feature-folder-name.ts | absent | absent |
| src/lib/development-docs/write-scopes.ts | absent | absent |
| src/lib/new-active-feature-folder/io.ts | 99.49 | 91.67 |
| src/lib/new-active-feature-folder/flow.ts | 99.59 | 93.33 |
| src/lib/potential-to-issue/content.ts | 99.17 | 88.89 |
| src/lib/potential-to-issue/promotion.ts | 98.89 | 83.82 |
| src/lib/resolve/file-prompt-variables.ts | 95.25 | 75.76 |
| src/extension-command-helpers.ts | 99.45 | 93.85 |
| src/lib/new-potential-bug-entry.ts | 97.83 | 87.27 |
| src/repo-automation-service.ts | 98.32 | 93.33 |
| src/lib/pr-context/feature-docs.ts | 94.48 | 87.27 |
| src/lib/pr-context/render-feature-excerpts.ts | 97.91 | 89.66 |
| src/lib/pr-context/verification-evidence.ts | 99.23 | 93.94 |
| src/lib/pr-context/summary-helpers.ts | 94.57 | 89.25 |
| src/lib/pr-context/collector-core.ts | 97.91 | 90.20 |
| src/lib/pr-context/feature-docs-parsers.ts | 98.05 | 91.23 |
| src/lib/validate/epic-orchestrator-state-resolution.ts | 98.85 | 96.99 |
| src/lib/validate/parallel-orchestrator-state-cohort-barrier.ts | 99.51 | 98.88 |
| src/lib/validate/epic-planner-readiness-integrity.ts | 100.00 | 97.40 |
| src/lib/validate/epic-kickoff-artifact.ts | 96.33 | 83.17 |
| src/lib/validate/parallel-kickoff-artifact.ts | 100.00 | 88.79 |
| src/lib/validate/orchestrator-state-issue-adoption.ts | 100.00 | 100.00 |
| src/lib/validate/evidence-locations.ts | 100.00 | 100.00 |
| src/lib/validate/orchestrator-state-feature-folder-record.ts | 100.00 | 100.00 |
| src/lib/json-config.ts | 96.19 | 83.33 |
| src/lib/file-system.ts | 95.60 | 85.29 |
| src/lib/push-down/codex-agents-customizations.ts | 98.48 | 92.54 |
