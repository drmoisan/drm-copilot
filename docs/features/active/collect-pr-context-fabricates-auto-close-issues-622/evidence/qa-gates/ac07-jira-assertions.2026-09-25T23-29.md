# AC 7 Former JIRA Assertions Removed (P10-T3)

Timestamp: 2026-09-26T20-30
Branch: N588

Command: git grep -n -F -e '"ABC-99"]' -e '"ABC-123"]' -e '"PROJECT-100"]' -e '"XYZ-456"]' -e '"XYZ-456",' -e '"ABC-456" in excerpts' -e 'assert "ABC-456" in result' -e 'assert "XYZ-789" in result' -e 'issueRefs).toContain("ABC-456")' -e '"ABC-10"}' -- tests/scripts/dev_tools extensions/drm-copilot/test/lib/pr-context
EXIT_CODE: 1
ExpectedExitCode: 1
Output Summary: No output. Every former positive JIRA assertion (10 lines on the pre-change tree, per the plan) is gone from the Python and TypeScript test trees. The inverted tests passed in [P6-T13] (`evidence/regression-testing/py-unit-tests.2026-09-25T23-29.md`, EXIT_CODE 0, `276 passed`): test_extract_issue_references_ignores_jira (test_render.py and test_feature_docs.py), test_extract_issue_references_filters_and_deduplicates, test_extract_issue_references_mixed, test_gather_feature_excerpts_reads_active_docs, test_gather_feature_excerpts_extracts_issue_refs, test_build_close_candidates_section_lists_referenced_issues_as_detected_only, test_build_close_candidates_section_combines_author_and_ref. In [P7-T6] (`evidence/regression-testing/ts-unit-tests.2026-09-25T23-29.md`, EXIT_CODE 0, `197 passed, 197 total`): feature-docs.test.ts `ignores JIRA-style references` and `extracts issue references from the combined doc text`.
