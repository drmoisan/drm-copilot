# Python Unit and Updated Tests — [P6-T13]

Timestamp: 2026-09-26T20-18
Branch: N588
Command: poetry run pytest tests/scripts/dev_tools/pr_context tests/scripts/dev_tools/test_collect_pr_context.py tests/scripts/dev_tools/test_collect_pr_context_part2.py tests/scripts/dev_tools/test_collect_pr_context_part4.py tests/scripts/dev_tools/test_collect_pr_context_part5.py tests/scripts/dev_tools/test_render.py tests/scripts/dev_tools/test_render_resolve_feature_dir.py tests/scripts/dev_tools/test_feature_docs.py tests/scripts/dev_tools/test_pr_context_integration.py -v
EXIT_CODE: 0
Output Summary: Result line `276 passed in 0.46s`; no failed count. Every Python test named under "Named tests" (outside the M588-only entry) is reported PASSED, with the following PASSED counts per test name:
- test_issue_reference_pattern.py: test_extractors_reject_non_bare_number_tokens 39; test_extractors_accept_bare_number_tokens 18; test_issue_reference_pattern_matches_typescript_literal 1; test_autoclose_literals_match_typescript_source 1.
- test_autoclose_collector.py: C1 test_collector_excludes_scraped_tokens_from_autoclose_when_gh_unavailable 1; C2 test_collector_excludes_prose_cited_closed_issue_from_autoclose 1; C3 test_collector_excludes_prose_cited_open_out_of_scope_issue_from_autoclose 1; C4 test_collector_excludes_closed_pending_primary_without_printing_it 4; C5 test_collector_keeps_open_pending_primary 2; C6 test_collector_fetches_each_issue_once 1; C7 test_narrative_mentions_excluded_from_autoclose_section 1; C8 test_pass_readiness_autoclose_section 1.
- test_autoclose.py: all 12 tests 1 each (select_pending_primary x9, classify_references x3).
- test_autoclose_builder.py: appends_unverified_annotation_when_gh_unavailable 1; omits_annotation_when_gh_available 1; renders_not_open_text_when_pending_excluded 1; fallback_precedence 5 (available-non-empty, available-empty-excluded, available-empty-pass, available-empty-non-pass, unavailable-non-empty).
- Changed existing tests: test_build_close_candidates_section_lists_referenced_issues_as_detected_only 1; test_extract_issue_references_filters_and_deduplicates 1; test_gather_feature_excerpts_reads_active_docs 1; test_extract_issue_references_ignores_jira 2 (test_render.py and test_feature_docs.py); test_build_close_candidates_section_combines_author_and_ref 1; test_extract_issue_references_mixed 1; test_gather_feature_excerpts_extracts_issue_refs 1.
N588: tests/scripts/dev_tools/pr_context/test_render_pr_helpers.py does not exist and was not collected.
