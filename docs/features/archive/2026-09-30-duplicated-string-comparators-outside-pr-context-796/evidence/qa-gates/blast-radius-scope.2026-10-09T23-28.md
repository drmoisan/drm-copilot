# QA gate: Blast-radius scope (P4-T15, pass 2)

Timestamp: 2026-10-09T23-28
Command: git diff --name-only 46dd56a8c2d6df15571f5f088ae2d677e5123b55 -- extensions/drm-copilot tests scripts packages; git status --porcelain --untracked-files=all -- extensions/drm-copilot tests scripts packages
EXIT_CODE: 0
Output Summary:
- name-only diff: 37 paths = the 36 core Blast-radius files (27 production, 8 core tests, jest.config.cjs; the 35 under src/ and test/ match the P4-T14 name-status listing, plus extensions/drm-copilot/jest.config.cjs) + extensions/drm-copilot/test/lib/codex-native-converter/pipeline.test.ts (edit-mode add-tests file, committed state unchanged; its working-tree edit also appears in the porcelain listing).
- porcelain (verbatim):
   M extensions/drm-copilot/test/lib/codex-native-converter/pipeline.test.ts
  ?? extensions/drm-copilot/test/lib/codex-native-converter/engine-pipeline.test.ts
  ?? extensions/drm-copilot/test/lib/codex-native-converter/pipeline-traces.test.ts
  ?? extensions/drm-copilot/test/lib/codex-native-converter/reporting-coverage.test.ts
  ?? extensions/drm-copilot/test/lib/codex-native-converter/reporting-render.test.ts
  ?? extensions/drm-copilot/test/lib/push-down/claude-blast-radius-derive.test.ts
- Union minus BASELINE-DRIFT (empty) = 42 paths = 36 core files + the 6 ADD-TESTS-WRITTEN paths of add-tests-record.2026-10-09T23-05.md. Each ADD-TESTS-WRITTEN member is listed in the "Conditional add-tests files" subsection of the plan.
- No path under extensions/drm-copilot/resources/, tests/, scripts/, or packages/ appears.
- Result: PASS.
