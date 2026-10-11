# QA gate: per-file coverage and changed-line check (P4-T6, pass 2)

Timestamp: 2026-10-09T23-14
Command: LCOV (extensions/drm-copilot/coverage/lcov.info from the P4-T5 pass-2 run) read per file with a scratchpad parser; git diff -U0 46dd56a8c2d6df15571f5f088ae2d677e5123b55 -- extensions/drm-copilot/src (added-line numbers from hunk headers); git status --porcelain --untracked-files=all -- extensions/drm-copilot/src (empty: string-ordering.ts is committed, so the diff lists all 66 of its lines as added)
EXIT_CODE: 0
Output Summary:
- Condition 1 (line >= 85 for all 27 files): PASS (lowest: render-pr-helpers.ts 87.08).
- Condition 2 (branch >= 75 for all 27 files): PASS (lowest: engine-pipeline.ts 84.78).
- Condition 3 (zero added lines with a DA record at hit count 0): PASS (0 uncovered added lines across 27 files; 168 added lines carry a DA record).
- ADD-TESTS: NOT REQUIRED. Task result: PASS.

## Per-file table

Values are `pct (hit/found)` from LCOV. "Added (DA)" is the number of added lines that carry a DA record; "Uncovered added" lists those with hit count 0.

| File (under extensions/drm-copilot/) | Post lines | Base lines | Post branches | Base branches | Added (DA) | Uncovered added | Labels |
| --- | --- | --- | --- | --- | --- | --- | --- |
| src/lib/string-ordering.ts | 100.00 (66/66) | n/a (new) | 100.00 (20/20) | n/a (new) | 66 | none | |
| src/lib/pr-context/models.ts | 100.00 (366/366) | 100.00 (391/391) | 100.00 (38/38) | 100.00 (49/49) | 4 | none | |
| src/lib/pr-context/verification-evidence.ts | 99.23 (259/261) | 99.23 (258/260) | 93.94 (31/33) | 93.94 (31/33) | 2 | none | |
| src/lib/pr-context/feature-docs.ts | 94.48 (291/308) | 94.55 (295/312) | 87.27 (48/55) | 87.27 (48/55) | 2 | none | BELOW-BASELINE (lines) |
| src/lib/pr-context/feature-docs-parsers.ts | 98.05 (302/308) | 98.08 (306/312) | 91.23 (52/57) | 91.23 (52/57) | 2 | none | BELOW-BASELINE (lines) |
| src/lib/pr-context/render-pr-helpers.ts | 87.08 (337/387) | 87.08 (337/387) | 94.29 (66/70) | 94.29 (66/70) | 1 | none | |
| src/lib/pr-context/render-feature-excerpts.ts | 97.91 (421/430) | 97.91 (421/430) | 89.66 (78/87) | 89.66 (78/87) | 1 | none | |
| src/lib/pr-context/collector-core.ts | 98.43 (376/382) | 98.43 (376/382) | 92.31 (48/52) | 92.31 (48/52) | 1 | none | |
| src/lib/pr-context/autoclose.ts | 100.00 (294/294) | 100.00 (294/294) | 100.00 (43/43) | 100.00 (43/43) | 1 | none | |
| src/lib/pr-context/collector-output.ts | 97.96 (481/491) | 97.77 (483/494) | 90.54 (67/74) | 89.33 (67/75) | 2 | none | |
| src/lib/codex-native-converter/engine-pipeline.ts | 98.01 (295/301) | 97.73 (302/309) | 84.78 (39/46) | 84.00 (42/50) | 11 | none | |
| src/lib/codex-native-converter/reporting-render.ts | 100.00 (199/199) | 96.65 (202/209) | 88.64 (39/44) | 83.78 (31/37) | 11 | none | |
| src/lib/codex-native-converter/reporting.ts | 100.00 (237/237) | 99.16 (237/239) | 88.00 (44/50) | 81.03 (47/58) | 11 | none | |
| src/lib/codex-native-converter/validation.ts | 99.46 (370/372) | 99.46 (370/372) | 84.91 (45/53) | 86.21 (50/58) | 8 | none | BELOW-BASELINE (branches) |
| src/lib/codex-native-converter/intermediate-state.ts | 100.00 (154/154) | 100.00 (153/153) | 93.75 (15/16) | 90.00 (18/20) | 2 | none | |
| src/lib/codex-native-converter/inventory.ts | 98.09 (308/314) | 98.12 (313/319) | 87.72 (50/57) | 83.82 (57/68) | 4 | none | BELOW-BASELINE (lines) |
| src/lib/codex-native-converter/models.ts | 100.00 (279/279) | 100.00 (280/280) | 100.00 (16/16) | 95.00 (19/20) | 2 | none | |
| src/lib/codex-native-converter/pipeline.ts | 100.00 (154/154) | 100.00 (155/155) | 100.00 (29/29) | 92.68 (38/41) | 7 | none | |
| src/lib/codex-native-converter/pipeline-traces.ts | 100.00 (122/122) | 93.44 (114/122) | 100.00 (20/20) | 83.33 (15/18) | 8 | none | |
| src/lib/push-down/claude-blast-radius-derive-manifests.ts | 100.00 (192/192) | 100.00 (200/200) | 100.00 (21/21) | 95.65 (22/23) | 3 | none | |
| src/lib/push-down/claude-blast-radius-derive-core.ts | 100.00 (392/392) | 100.00 (394/394) | 97.50 (39/40) | 97.50 (39/40) | 4 | none | |
| src/lib/push-down/claude-blast-radius-overlay.ts | 99.55 (445/447) | 99.55 (445/447) | 95.88 (93/97) | 95.88 (93/97) | 2 | none | |
| src/lib/push-down/claude-blast-radius-derive.ts | 99.34 (303/305) | 97.39 (298/306) | 97.30 (36/37) | 94.12 (32/34) | 2 | none | |
| src/lib/push-down/filesystem-adapter.ts | 98.03 (199/203) | 98.04 (200/204) | 90.91 (20/22) | 88.46 (23/26) | 2 | none | BELOW-BASELINE (lines) |
| src/lib/push-down/copilot-customizations-engine.ts | 97.99 (439/448) | 97.99 (439/448) | 86.67 (39/45) | 84.31 (43/51) | 3 | none | |
| src/lib/subagent-tree/tree-assembler.ts | 99.46 (183/184) | 94.71 (179/189) | 90.00 (18/20) | 89.47 (17/19) | 3 | none | |
| src/lib/subagent-tree/quick-pick-labels.ts | 100.00 (135/135) | 100.00 (133/133) | 100.00 (16/16) | 94.44 (17/18) | 3 | none | |

BELOW-BASELINE entries (feature-docs.ts, feature-docs-parsers.ts, inventory.ts, filesystem-adapter.ts lines; validation.ts branches) are recorded and are not failures: each file is at or above 85/75 and none of its added lines is uncovered. The line decreases follow from removing covered lines (import members, comparator bodies) in files that keep pre-existing uncovered lines; the validation.ts branch decrease follows from replacing covered ternary branches with a call.
