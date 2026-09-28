# Post-Merge File Sizes and Region Locations (P0-T12)

Timestamp: 2026-09-26T19-39

Command: wc -l scripts/dev_tools/pr_context/models.py scripts/dev_tools/pr_context/feature_docs.py scripts/dev_tools/pr_context/render_feature_excerpts.py scripts/dev_tools/pr_context/render_pr_helpers.py scripts/dev_tools/pr_context/collector.py extensions/drm-copilot/src/lib/pr-context/models.ts extensions/drm-copilot/src/lib/pr-context/feature-docs-parsers.ts extensions/drm-copilot/src/lib/pr-context/render-feature-excerpts.ts extensions/drm-copilot/src/lib/pr-context/render-pr-helpers.ts extensions/drm-copilot/src/lib/pr-context/collector-core.ts extensions/drm-copilot/jest.config.cjs tests/scripts/dev_tools/test_collect_pr_context.py tests/scripts/dev_tools/test_collect_pr_context_part2.py tests/scripts/dev_tools/test_collect_pr_context_part4.py tests/scripts/dev_tools/test_render.py tests/scripts/dev_tools/test_feature_docs.py extensions/drm-copilot/test/lib/pr-context/render-pr-helpers.test.ts extensions/drm-copilot/test/lib/pr-context/feature-docs.test.ts extensions/drm-copilot/test/lib/pr-context/collector-core.test.ts
EXIT_CODE: 0
Command: grep -n -E -e "def (build_issues_to_autoclose_section|build_close_candidates_section|extract_issue_references|collect_and_write)" scripts/dev_tools/pr_context/render_pr_helpers.py scripts/dev_tools/pr_context/collector.py
EXIT_CODE: 0
Command: grep -n -E -e "function (buildIssuesToAutocloseSection|buildCloseCandidatesSection|extractIssueReferences|classifyReferences|classifyOne|formatRef|collectPrContext)" extensions/drm-copilot/src/lib/pr-context/render-pr-helpers.ts extensions/drm-copilot/src/lib/pr-context/collector-core.ts
EXIT_CODE: 0

Output Summary:
Branch: N588 (the M588-only `wc -l tests/scripts/dev_tools/pr_context/test_render_pr_helpers.py` was not run; the file does not exist).

wc -l (19 file rows plus total):
- 198 scripts/dev_tools/pr_context/models.py
- 349 scripts/dev_tools/pr_context/feature_docs.py
- 256 scripts/dev_tools/pr_context/render_feature_excerpts.py
- 291 scripts/dev_tools/pr_context/render_pr_helpers.py
- 474 scripts/dev_tools/pr_context/collector.py
- 312 extensions/drm-copilot/src/lib/pr-context/models.ts
- 322 extensions/drm-copilot/src/lib/pr-context/feature-docs-parsers.ts
- 448 extensions/drm-copilot/src/lib/pr-context/render-feature-excerpts.ts
- 481 extensions/drm-copilot/src/lib/pr-context/render-pr-helpers.ts
- 475 extensions/drm-copilot/src/lib/pr-context/collector-core.ts
- 290 extensions/drm-copilot/jest.config.cjs
- 654 tests/scripts/dev_tools/test_collect_pr_context.py
- 432 tests/scripts/dev_tools/test_collect_pr_context_part2.py
- 1026 tests/scripts/dev_tools/test_collect_pr_context_part4.py
- 570 tests/scripts/dev_tools/test_render.py
- 432 tests/scripts/dev_tools/test_feature_docs.py
- 262 extensions/drm-copilot/test/lib/pr-context/render-pr-helpers.test.ts
- 314 extensions/drm-copilot/test/lib/pr-context/feature-docs.test.ts
- 417 extensions/drm-copilot/test/lib/pr-context/collector-core.test.ts
- 8003 total

Differences from the "This tree (N588)" column: none (all 19 counts match).

Counts already above the "#622 ceiling" (all five are the removal-exempt rows; no stop applies):
- extensions/drm-copilot/src/lib/pr-context/render-pr-helpers.ts: count 481, ceiling 440, difference 41
- extensions/drm-copilot/src/lib/pr-context/collector-core.ts: count 475, ceiling 420, difference 55
- tests/scripts/dev_tools/test_collect_pr_context.py: count 654, ceiling 480, difference 174
- tests/scripts/dev_tools/test_collect_pr_context_part4.py: count 1026, ceiling 497, difference 529
- tests/scripts/dev_tools/test_render.py: count 570, ceiling 435, difference 135
No other file is above its ceiling.

Binding ceilings restated:
- scripts/dev_tools/pr_context/collector.py: 474 (recorded count)
- extensions/drm-copilot/test/lib/pr-context/collector-core.test.ts: 419 (recorded count 417 plus 2)

Function locations:
- scripts/dev_tools/pr_context/render_pr_helpers.py:100: def extract_issue_references
- scripts/dev_tools/pr_context/render_pr_helpers.py:200: def build_close_candidates_section
- scripts/dev_tools/pr_context/render_pr_helpers.py:228: def build_issues_to_autoclose_section
- scripts/dev_tools/pr_context/collector.py:129: def collect_and_write
- extensions/drm-copilot/src/lib/pr-context/render-pr-helpers.ts:162: export function extractIssueReferences
- extensions/drm-copilot/src/lib/pr-context/render-pr-helpers.ts:313: export function buildCloseCandidatesSection
- extensions/drm-copilot/src/lib/pr-context/render-pr-helpers.ts:352: export function buildIssuesToAutocloseSection
- extensions/drm-copilot/src/lib/pr-context/collector-core.ts:115: export function collectPrContext
- extensions/drm-copilot/src/lib/pr-context/collector-core.ts:389: function classifyReferences
- extensions/drm-copilot/src/lib/pr-context/collector-core.ts:433: function classifyOne
- extensions/drm-copilot/src/lib/pr-context/collector-core.ts:452: function formatRef
