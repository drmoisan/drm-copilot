# Post-Change Physical Line Counts (P6-T9, AC-16)

Timestamp: 2026-10-29T15-00
Command: wc -l <path> for each path below (from the worktree root); git diff --quiet HEAD -- tests/scripts/dev_tools/test_orchestrator_state_issue_adoption.py tests/scripts/claude-hooks/validate-orchestrator-output.Tests.ps1
EXIT_CODE: 0
Output Summary: All 23 code, test, and script files are at or below 500 physical lines (maximum 497, `extensions/drm-copilot/jest.config.cjs`). The two near-limit files are byte-unchanged against HEAD (git diff --quiet exit 0). Before counts come from `evidence/baseline/line-counts.2026-10-29T14-14.md`.

| Path | Before | After |
| --- | --- | --- |
| `scripts/dev_tools/_orchestrator_state_issue_adoption.py` | 352 | 365 |
| `tests/scripts/dev_tools/orchestrator_state_issue_adoption_test_support.py` | 187 | 283 |
| `tests/scripts/dev_tools/test_orchestrator_state_issue_adoption_waivers.py` | 338 | 340 |
| `tests/scripts/dev_tools/test_orchestrator_state_issue_adoption_parity.py` | 222 | 222 |
| `extensions/drm-copilot/src/lib/validate/orchestrator-state-issue-adoption.ts` | 324 | 332 |
| `extensions/drm-copilot/test/lib/validate/orchestrator-state-issue-adoption.test.ts` | 477 | 484 |
| `extensions/drm-copilot/test/lib/validate/orchestrator-state-issue-adoption-parity.test.ts` | 176 | 176 |
| `extensions/drm-copilot/jest.config.cjs` | 493 | 497 |
| `.claude/lib/orchestrator-state/OrchestratorStateIssueAdoption.psm1` | 396 | 401 |
| `.claude/hooks/validate-orchestrator-output.ps1` | 346 | 368 |
| `tests/scripts/claude-lib/orchestrator-state/OrchestratorStateIssueAdoption.Tests.ps1` | 437 | 437 |
| `tests/scripts/claude-lib/orchestrator-state/OrchestratorStateIssueAdoption.Parity.Tests.ps1` | 111 | 111 |
| `tests/scripts/claude-lib/orchestrator-state/OrchestratorState.Manifest.Tests.ps1` | 108 | 109 |
| `tests/scripts/dev_tools/test_orchestrator_state_issue_adoption.py` (near-limit, unchanged) | 462 | 462 |
| `tests/scripts/claude-hooks/validate-orchestrator-output.Tests.ps1` (near-limit, unchanged) | 454 | 454 |
| `scripts/dev_tools/_orchestrator_state_feature_folder_record.py` (new) | n/a | 181 |
| `tests/scripts/dev_tools/test_orchestrator_state_issue_adoption_feature_folder.py` (new) | n/a | 378 |
| `extensions/drm-copilot/src/lib/validate/orchestrator-state-feature-folder-record.ts` (new) | n/a | 136 |
| `extensions/drm-copilot/test/lib/validate/orchestrator-state-issue-adoption-feature-folder.test.ts` (new) | n/a | 292 |
| `.claude/lib/orchestrator-state/OrchestratorStateFeatureFolderRecord.psm1` (new) | n/a | 166 |
| `.claude/hooks/validate-orchestrator-output-feature-folder.ps1` (new) | n/a | 146 |
| `tests/scripts/claude-lib/orchestrator-state/OrchestratorStateFeatureFolderRecord.Tests.ps1` (new) | n/a | 249 |
| `tests/scripts/claude-hooks/validate-orchestrator-output.FeatureFolder.Tests.ps1` (new) | n/a | 192 |
