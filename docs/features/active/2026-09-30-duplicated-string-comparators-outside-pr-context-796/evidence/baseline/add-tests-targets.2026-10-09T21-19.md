# Baseline: Conditional add-tests target files (P0-T19)

Timestamp: 2026-10-09T21-19
Command: git grep --untracked -c -E "^" -- <the 8 edit-mode paths of "Conditional add-tests files"> (run from REPO); Glob for each of the 14 create-mode paths (single brace-expanded Glob over extensions/drm-copilot/test/lib/**/ plus an `ls` cross-check that reported 14 missing paths)
EXIT_CODE: 0
Output Summary:
Edit-mode counts (verbatim, 8 lines):
extensions/drm-copilot/test/lib/codex-native-converter/intermediate-state.test.ts:166
extensions/drm-copilot/test/lib/codex-native-converter/models.test.ts:358
extensions/drm-copilot/test/lib/codex-native-converter/pipeline.test.ts:248
extensions/drm-copilot/test/lib/codex-native-converter/validation.test.ts:242
extensions/drm-copilot/test/lib/pr-context/feature-docs.test.ts:354
extensions/drm-copilot/test/lib/pr-context/render-feature-excerpts.test.ts:257
extensions/drm-copilot/test/lib/pr-context/render-pr-helpers.test.ts:323
extensions/drm-copilot/test/lib/push-down/filesystem-adapter.test.ts:212
All equal the planning-time counts; none is 400 or more.

Create-mode paths (each: no file found):
- extensions/drm-copilot/test/lib/string-ordering-coverage.test.ts: absent
- extensions/drm-copilot/test/lib/pr-context/models-coverage.test.ts: absent
- extensions/drm-copilot/test/lib/pr-context/verification-evidence-coverage.test.ts: absent
- extensions/drm-copilot/test/lib/pr-context/feature-docs-parsers.test.ts: absent
- extensions/drm-copilot/test/lib/pr-context/collector-core-coverage.test.ts: absent
- extensions/drm-copilot/test/lib/pr-context/autoclose-coverage.test.ts: absent
- extensions/drm-copilot/test/lib/pr-context/collector-output-coverage.test.ts: absent
- extensions/drm-copilot/test/lib/codex-native-converter/engine-pipeline.test.ts: absent
- extensions/drm-copilot/test/lib/codex-native-converter/reporting-render.test.ts: absent
- extensions/drm-copilot/test/lib/codex-native-converter/reporting-coverage.test.ts: absent
- extensions/drm-copilot/test/lib/codex-native-converter/pipeline-traces.test.ts: absent
- extensions/drm-copilot/test/lib/push-down/claude-blast-radius-derive-core.test.ts: absent
- extensions/drm-copilot/test/lib/push-down/claude-blast-radius-derive.test.ts: absent
- extensions/drm-copilot/test/lib/push-down/claude-blast-radius-overlay-coverage.test.ts: absent
