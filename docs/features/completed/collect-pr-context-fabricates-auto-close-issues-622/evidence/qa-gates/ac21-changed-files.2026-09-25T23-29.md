# AC 21 Full Changed-File Inventory (P10-T6)

Timestamp: 2026-09-26T20-33
Branch: N588

Command: git diff --name-only ae8d2ce32c95cf03d55ffb544f2514d83ebfc620 HEAD
EXIT_CODE: 0
Output Summary: 83 paths. 53 are under `docs/features/active/collect-pr-context-fabricates-auto-close-issues-622/` (evidence, issue.md, plan, research, spec.md). The remaining 30 are exactly the 30 N588 budget rows of the file-size budget table, with no path outside that set:
- Python production (6): scripts/dev_tools/pr_context/models.py, feature_docs.py, render_feature_excerpts.py, render_pr_helpers.py, autoclose.py, collector.py.
- TypeScript production (7): extensions/drm-copilot/src/lib/pr-context/models.ts, feature-docs-parsers.ts, render-feature-excerpts.ts, render-pr-helpers.ts, autoclose.ts, collector-core.ts; extensions/drm-copilot/jest.config.cjs.
- Python tests (11): tests/scripts/dev_tools/pr_context/test_issue_reference_pattern.py, test_autoclose.py, test_autoclose_collector.py, test_autoclose_builder.py; tests/scripts/dev_tools/test_collect_pr_context.py, test_collect_pr_context_part2.py, test_collect_pr_context_part4.py, test_collect_pr_context_part5.py, test_render.py, test_render_resolve_feature_dir.py, test_feature_docs.py.
- TypeScript tests (6): extensions/drm-copilot/test/lib/pr-context/issue-reference-pattern.test.ts, autoclose.test.ts, collector-core-autoclose.test.ts, render-pr-helpers.test.ts, feature-docs.test.ts, collector-core.test.ts.
No mirrored test file was added under the [P8-T5] or [P9-T5] coverage rule, so no exception entry applies. `tests/scripts/dev_tools/pr_context/test_render_pr_helpers.py` (M588-only row) is absent, as expected in N588.

Command: git status --porcelain
EXIT_CODE: 0
Output Summary: 8 lines, all under `docs/features/active/collect-pr-context-fabricates-auto-close-issues-622/`: ` M plan.2026-09-25T23-29.md` and seven untracked Phase 10 artifacts in `evidence/qa-gates/` (ac01-pattern-absent, ac01-pattern-defined, ac02-extractors, ac07-jira-assertions, ac08-ac27-absent, ac08-ac27-counts, ac21-excluded-paths). These are committed by [P10-T12].
