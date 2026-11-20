# A19 Rows Satisfied by Child 2 [P3-T8]

Timestamp: 2026-11-20T15-27
Command: grep of the feature_folder_record path pattern and ERROR_PATH_FORMAT in the three validators and of Resolve-DevelopmentDocsRoot in Get-StageTimingReport.ps1; cmp of OrchestratorStateFeatureFolderRecord.psm1 with its bundle copy; sed copy of waives-feature-folder-path-outside-active.json to waives-feature-folder-path-outside-dev-active.json; sh SCRATCH/issue-1016-tc-p3t8.sh
EXIT_CODE: 0
Output Summary: SATISFIED_BY_CHILD_2 for the three validators and the stage-timing default on the post-flip tree; no production edit. New fixture added; no existing fixture changed (porcelain under tests/fixtures lists only the new file). Parity, feature-folder and stage-timing suites pass: pytest 132 passed, Pester 138 tests 0 failures, Jest 4 suites 149 tests passed.

| Row | Observation | Result |
| --- | --- | --- |
| `.claude/lib/orchestrator-state/OrchestratorStateFeatureFolderRecord.psm1` | `FEATURE_FOLDER_PATH_PATTERN` joins `Get-DevelopmentDocsKnownRoot` (both `docs/features` and `.dev`) with `/active/`; `ERROR_PATH_FORMAT` text unchanged; bundle copy byte-identical | SATISFIED_BY_CHILD_2 |
| `scripts/dev_tools/_orchestrator_state_feature_folder_record.py` | pattern joins `KNOWN_DEVELOPMENT_DOCS_ROOTS`; error text unchanged | SATISFIED_BY_CHILD_2 |
| `extensions/drm-copilot/src/lib/validate/orchestrator-state-feature-folder-record.ts` | `FEATURE_FOLDER_PATH_PATTERN` `^(?:docs\/features|\.dev)\/active\/...`; error text unchanged | SATISFIED_BY_CHILD_2 |
| `scripts/dev-tools/Get-StageTimingReport.ps1` | default evidence root from `Resolve-DevelopmentDocsRoot -WorkspaceRoot` | SATISFIED_BY_CHILD_2 |

## New fixture

`tests/fixtures/orchestrator_state_issue_adoption/waives-feature-folder-path-outside-dev-active.json`: a copy of `waives-feature-folder-path-outside-active.json` with `name` and `notes` adjusted, checkpoint `feature-folder` `.dev/active/0509-sample-feature`, record `path` `.dev/completed/0509-sample-feature`, the evidence string naming the `.dev/active` path, and identical `expected_errors`. The Pester parity suite reports a case for it, and the Python and TypeScript parity suites enumerate the folder; all pass, so the three runtimes produce the identical three expected errors.
