# AC 22 Line Caps (P10-T7)

Timestamp: 2026-09-26T20-34
Branch: N588

Command: wc -l scripts/dev_tools/pr_context/models.py scripts/dev_tools/pr_context/feature_docs.py scripts/dev_tools/pr_context/render_feature_excerpts.py scripts/dev_tools/pr_context/render_pr_helpers.py scripts/dev_tools/pr_context/autoclose.py scripts/dev_tools/pr_context/collector.py extensions/drm-copilot/src/lib/pr-context/models.ts extensions/drm-copilot/src/lib/pr-context/feature-docs-parsers.ts extensions/drm-copilot/src/lib/pr-context/render-feature-excerpts.ts extensions/drm-copilot/src/lib/pr-context/render-pr-helpers.ts extensions/drm-copilot/src/lib/pr-context/autoclose.ts extensions/drm-copilot/src/lib/pr-context/collector-core.ts extensions/drm-copilot/jest.config.cjs tests/scripts/dev_tools/pr_context/test_issue_reference_pattern.py tests/scripts/dev_tools/pr_context/test_autoclose.py tests/scripts/dev_tools/pr_context/test_autoclose_collector.py tests/scripts/dev_tools/pr_context/test_autoclose_builder.py tests/scripts/dev_tools/test_collect_pr_context.py tests/scripts/dev_tools/test_collect_pr_context_part2.py tests/scripts/dev_tools/test_collect_pr_context_part4.py tests/scripts/dev_tools/test_collect_pr_context_part5.py tests/scripts/dev_tools/test_render.py tests/scripts/dev_tools/test_render_resolve_feature_dir.py tests/scripts/dev_tools/test_feature_docs.py extensions/drm-copilot/test/lib/pr-context/issue-reference-pattern.test.ts extensions/drm-copilot/test/lib/pr-context/autoclose.test.ts extensions/drm-copilot/test/lib/pr-context/collector-core-autoclose.test.ts extensions/drm-copilot/test/lib/pr-context/render-pr-helpers.test.ts extensions/drm-copilot/test/lib/pr-context/feature-docs.test.ts extensions/drm-copilot/test/lib/pr-context/collector-core.test.ts extensions/drm-copilot/src/lib/pr-context/collector-output.ts
EXIT_CODE: 0
Output Summary: 31 file rows plus `10516 total` (30 N588 budget rows plus collector-output.ts). Count / #622 ceiling, every row at most 500 and at most its ceiling:

| File | Count | Ceiling |
|---|---|---|
| scripts/dev_tools/pr_context/models.py | 209 | 225 |
| scripts/dev_tools/pr_context/feature_docs.py | 356 | 360 |
| scripts/dev_tools/pr_context/render_feature_excerpts.py | 261 | 262 |
| scripts/dev_tools/pr_context/render_pr_helpers.py | 315 | 345 |
| scripts/dev_tools/pr_context/autoclose.py | 161 | 200 |
| scripts/dev_tools/pr_context/collector.py | 461 | 474 ([P0-T12] count) |
| extensions/drm-copilot/src/lib/pr-context/models.ts | 337 | 350 |
| extensions/drm-copilot/src/lib/pr-context/feature-docs-parsers.ts | 323 | 328 |
| extensions/drm-copilot/src/lib/pr-context/render-feature-excerpts.ts | 452 | 455 |
| extensions/drm-copilot/src/lib/pr-context/render-pr-helpers.ts | 417 | 440 |
| extensions/drm-copilot/src/lib/pr-context/autoclose.ts | 298 | 340 |
| extensions/drm-copilot/src/lib/pr-context/collector-core.ts | 396 | 420 |
| extensions/drm-copilot/jest.config.cjs | 312 | 330 |
| tests/scripts/dev_tools/pr_context/test_issue_reference_pattern.py | 131 | 150 |
| tests/scripts/dev_tools/pr_context/test_autoclose.py | 258 | 260 |
| tests/scripts/dev_tools/pr_context/test_autoclose_collector.py | 458 | 460 |
| tests/scripts/dev_tools/pr_context/test_autoclose_builder.py | 175 | 200 |
| tests/scripts/dev_tools/test_collect_pr_context.py | 480 | 480 |
| tests/scripts/dev_tools/test_collect_pr_context_part2.py | 432 | 432 |
| tests/scripts/dev_tools/test_collect_pr_context_part4.py | 497 | 497 |
| tests/scripts/dev_tools/test_collect_pr_context_part5.py | 380 | 400 |
| tests/scripts/dev_tools/test_render.py | 429 | 435 |
| tests/scripts/dev_tools/test_render_resolve_feature_dir.py | 151 | 160 |
| tests/scripts/dev_tools/test_feature_docs.py | 432 | 436 |
| extensions/drm-copilot/test/lib/pr-context/issue-reference-pattern.test.ts | 92 | 150 |
| extensions/drm-copilot/test/lib/pr-context/autoclose.test.ts | 413 | 460 |
| extensions/drm-copilot/test/lib/pr-context/collector-core-autoclose.test.ts | 401 | 420 |
| extensions/drm-copilot/test/lib/pr-context/render-pr-helpers.test.ts | 265 | 345 |
| extensions/drm-copilot/test/lib/pr-context/feature-docs.test.ts | 311 | 316 |
| extensions/drm-copilot/test/lib/pr-context/collector-core.test.ts | 419 | 419 ([P0-T12] count 417 plus 2) |
| extensions/drm-copilot/src/lib/pr-context/collector-output.ts | 494 | 500 (not modified) |

No file is named under the [P10-T6] exception, so no additional row applies. All caps pass.
