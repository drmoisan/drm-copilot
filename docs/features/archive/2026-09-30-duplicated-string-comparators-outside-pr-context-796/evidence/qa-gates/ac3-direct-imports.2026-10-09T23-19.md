# QA gate: AC-2/AC-3 direct imports, no re-export, per-site calls (P4-T9, pass 2)

Timestamp: 2026-10-09T23-19
Command: (1) git grep --untracked -n -F 'import { compareCodePoint } from "../string-ordering";' -- extensions/drm-copilot/src; (2) git grep --untracked -n -F "string-ordering" -- extensions/drm-copilot/src; (3) git grep --untracked -n -E "export[^(]*compareCodePoint" -- extensions/drm-copilot/src; (4) git grep --untracked -n -F "compareCodePoint" -- extensions/drm-copilot/src/lib/pr-context/models.ts; (5) git grep --untracked -c -w -F "compareCodePoint" -- <the 26 CHANGED-PROD paths>
EXIT_CODE: 0
Output Summary:
- (1) exit 0, exactly 26 lines, one in each CHANGED-PROD file (engine-pipeline:19, intermediate-state:16, inventory:21, cnc models:16, pipeline-traces:14, pipeline:16, reporting-render:16, reporting:17, validation:14, autoclose:25, collector-core:21, collector-output:18, feature-docs-parsers:18, feature-docs:21, pr-context models:27, render-feature-excerpts:19, render-pr-helpers:19, verification-evidence:22, derive-core:47, derive-manifests:27, derive:44, overlay:23, copilot-customizations-engine:23, filesystem-adapter:3, quick-pick-labels:17, tree-assembler:1).
- (2) exit 0, 26 lines, the same 26 import lines and no other (baseline P0-T17: no match). No re-export or other reference to the module path.
- (3) exit 0, exactly one line: `extensions/drm-copilot/src/lib/string-ordering.ts:53:export function compareCodePoint(left: string, right: string): number {`.
- (4) exit 0: lines 27 (IMPORT-LINE), 351 (`{@link compareCodePoint}` in the sortedSet doc comment), 354 (sortedSet call). Every line is at or after the IMPORT-LINE, so the models.ts header no longer names it.
- (5) 26 path:count lines; every count meets its minimum (actual/minimum):
  - pr-context: models.ts 3/3, verification-evidence.ts 2/2, feature-docs.ts 3/3, feature-docs-parsers.ts 3/3, render-pr-helpers.ts 3/3, render-feature-excerpts.ts 2/2, collector-core.ts 4/4, autoclose.ts 3/3, collector-output.ts 2/2
  - codex-native-converter: engine-pipeline.ts 9/9, reporting-render.ts 11/11, reporting.ts 7/7, validation.ts 5/5, intermediate-state.ts 2/2, inventory.ts 4/4, models.ts 2/2, pipeline.ts 5/5, pipeline-traces.ts 4/4
  - push-down: claude-blast-radius-derive-manifests.ts 2/2, claude-blast-radius-derive-core.ts 3/3, claude-blast-radius-overlay.ts 2/2, claude-blast-radius-derive.ts 2/2, filesystem-adapter.ts 2/2, copilot-customizations-engine.ts 3/3
  - subagent-tree: tree-assembler.ts 2/2, quick-pick-labels.ts 2/2
- Together with P4-T3 (pass 2, 0 errors), every production import resolves to the shared module and each site still calls it.
- Result: PASS.
