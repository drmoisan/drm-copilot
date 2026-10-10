# Add-tests scope (P4-T18, pass 1)

Timestamp: 2026-10-09T22-37
Command: Read docs/features/active/2026-09-30-duplicated-string-comparators-outside-pr-context-796/evidence/qa-gates/coverage-delta.2026-10-09T22-35.md and LCOV (extensions/drm-copilot/coverage/lcov.info, pass-1 run); git grep --untracked -c -E "^[[:space:]]*it\(" -- extensions/drm-copilot/test/lib/codex-native-converter/pipeline.test.ts
EXIT_CODE: 0
Output Summary:
- ADD-TESTS: REQUIRED (source: coverage-delta.2026-10-09T22-35.md).
- ADD-TESTS-SET (6 files, exactly the files that artifact lists as failing):

| Production file (extensions/drm-copilot/src/lib/...) | Failing conditions | DA hit-0 lines (added lines marked *) | Target test file and mode | PRE_IT_COUNT |
| --- | --- | --- | --- | --- |
| codex-native-converter/engine-pipeline.ts | 3 | 127, 128, 142, 143, 194, 195, 241* | test/lib/codex-native-converter/engine-pipeline.test.ts (create, P4-T26) | 0 |
| codex-native-converter/pipeline.ts | 3 | 58* | test/lib/codex-native-converter/pipeline.test.ts (edit, P4-T33) | 7 |
| codex-native-converter/pipeline-traces.ts | 3 | 92, 93, 114*, 115, 120* | test/lib/codex-native-converter/pipeline-traces.test.ts (create, P4-T29) | 0 |
| codex-native-converter/reporting-render.ts | 3 | 79*, 80, 81, 82, 182*, 187, 188 | test/lib/codex-native-converter/reporting-render.test.ts (create, P4-T27) | 0 |
| codex-native-converter/reporting.ts | 3 | 150*, 155, 156 | test/lib/codex-native-converter/reporting-coverage.test.ts (create, P4-T28) | 0 |
| push-down/claude-blast-radius-derive.ts | 3 | 100, 101, 124, 125, 126*, 127 | test/lib/push-down/claude-blast-radius-derive.test.ts (create, P4-T31; node:fs mock per ADD-TESTS-RULES (d)) | 0 |

- Condition 2 does not fail for any member, so no BRDA records are required.
- PRE_IT_COUNT for the one edit-mode entrant (verbatim command output): `extensions/drm-copilot/test/lib/codex-native-converter/pipeline.test.ts:7`.
- Paths in the target column are relative to extensions/drm-copilot/.
