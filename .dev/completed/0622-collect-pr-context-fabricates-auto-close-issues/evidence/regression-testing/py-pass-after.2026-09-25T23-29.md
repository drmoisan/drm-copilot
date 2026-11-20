# Python Pass-After Run on Fixed Production Code (P5-T1)

Timestamp: 2026-09-26T20-30
Command: poetry run pytest tests/scripts/dev_tools/pr_context/test_issue_reference_pattern.py tests/scripts/dev_tools/pr_context/test_autoclose_collector.py -v
EXIT_CODE: 0

Output Summary:
- Result line: `71 passed in 0.19s`. 0 failed, 0 errors.
- Every one of the 37 node IDs that failed in [P2-T9] (evidence/regression-testing/py-fail-first.2026-09-25T23-29.md) is reported PASSED:

  - tests/scripts/dev_tools/pr_context/test_issue_reference_pattern.py::test_extractors_reject_non_bare_number_tokens[feature_docs-#ISO-8601] PASSED
  - tests/scripts/dev_tools/pr_context/test_issue_reference_pattern.py::test_extractors_reject_non_bare_number_tokens[feature_docs-#CR-1] PASSED
  - tests/scripts/dev_tools/pr_context/test_issue_reference_pattern.py::test_extractors_reject_non_bare_number_tokens[feature_docs-ISO-8601] PASSED
  - tests/scripts/dev_tools/pr_context/test_issue_reference_pattern.py::test_extractors_reject_non_bare_number_tokens[feature_docs-CR-1] PASSED
  - tests/scripts/dev_tools/pr_context/test_issue_reference_pattern.py::test_extractors_reject_non_bare_number_tokens[feature_docs-UTF-8] PASSED
  - tests/scripts/dev_tools/pr_context/test_issue_reference_pattern.py::test_extractors_reject_non_bare_number_tokens[feature_docs-SHA-256] PASSED
  - tests/scripts/dev_tools/pr_context/test_issue_reference_pattern.py::test_extractors_reject_non_bare_number_tokens[feature_docs-AC-12] PASSED
  - tests/scripts/dev_tools/pr_context/test_issue_reference_pattern.py::test_extractors_reject_non_bare_number_tokens[feature_docs-#12abc] PASSED
  - tests/scripts/dev_tools/pr_context/test_issue_reference_pattern.py::test_extractors_reject_non_bare_number_tokens[feature_docs-#12_] PASSED
  - tests/scripts/dev_tools/pr_context/test_issue_reference_pattern.py::test_extractors_reject_non_bare_number_tokens[feature_docs-#\u0661\u0662] PASSED
  - tests/scripts/dev_tools/pr_context/test_issue_reference_pattern.py::test_extractors_reject_non_bare_number_tokens[render_pr_helpers-#ISO-8601] PASSED
  - tests/scripts/dev_tools/pr_context/test_issue_reference_pattern.py::test_extractors_reject_non_bare_number_tokens[render_pr_helpers-#CR-1] PASSED
  - tests/scripts/dev_tools/pr_context/test_issue_reference_pattern.py::test_extractors_reject_non_bare_number_tokens[render_pr_helpers-ISO-8601] PASSED
  - tests/scripts/dev_tools/pr_context/test_issue_reference_pattern.py::test_extractors_reject_non_bare_number_tokens[render_pr_helpers-CR-1] PASSED
  - tests/scripts/dev_tools/pr_context/test_issue_reference_pattern.py::test_extractors_reject_non_bare_number_tokens[render_pr_helpers-UTF-8] PASSED
  - tests/scripts/dev_tools/pr_context/test_issue_reference_pattern.py::test_extractors_reject_non_bare_number_tokens[render_pr_helpers-SHA-256] PASSED
  - tests/scripts/dev_tools/pr_context/test_issue_reference_pattern.py::test_extractors_reject_non_bare_number_tokens[render_pr_helpers-AC-12] PASSED
  - tests/scripts/dev_tools/pr_context/test_issue_reference_pattern.py::test_extractors_reject_non_bare_number_tokens[render_pr_helpers-#12abc] PASSED
  - tests/scripts/dev_tools/pr_context/test_issue_reference_pattern.py::test_extractors_reject_non_bare_number_tokens[render_pr_helpers-#12_] PASSED
  - tests/scripts/dev_tools/pr_context/test_issue_reference_pattern.py::test_extractors_reject_non_bare_number_tokens[render_pr_helpers-#\u0661\u0662] PASSED
  - tests/scripts/dev_tools/pr_context/test_issue_reference_pattern.py::test_extractors_reject_non_bare_number_tokens[render_feature_excerpts-#ISO-8601] PASSED
  - tests/scripts/dev_tools/pr_context/test_issue_reference_pattern.py::test_extractors_reject_non_bare_number_tokens[render_feature_excerpts-#CR-1] PASSED
  - tests/scripts/dev_tools/pr_context/test_issue_reference_pattern.py::test_extractors_reject_non_bare_number_tokens[render_feature_excerpts-ISO-8601] PASSED
  - tests/scripts/dev_tools/pr_context/test_issue_reference_pattern.py::test_extractors_reject_non_bare_number_tokens[render_feature_excerpts-CR-1] PASSED
  - tests/scripts/dev_tools/pr_context/test_issue_reference_pattern.py::test_extractors_reject_non_bare_number_tokens[render_feature_excerpts-UTF-8] PASSED
  - tests/scripts/dev_tools/pr_context/test_issue_reference_pattern.py::test_extractors_reject_non_bare_number_tokens[render_feature_excerpts-SHA-256] PASSED
  - tests/scripts/dev_tools/pr_context/test_issue_reference_pattern.py::test_extractors_reject_non_bare_number_tokens[render_feature_excerpts-AC-12] PASSED
  - tests/scripts/dev_tools/pr_context/test_issue_reference_pattern.py::test_extractors_reject_non_bare_number_tokens[render_feature_excerpts-#12abc] PASSED
  - tests/scripts/dev_tools/pr_context/test_issue_reference_pattern.py::test_extractors_reject_non_bare_number_tokens[render_feature_excerpts-#12_] PASSED
  - tests/scripts/dev_tools/pr_context/test_issue_reference_pattern.py::test_extractors_reject_non_bare_number_tokens[render_feature_excerpts-#\u0661\u0662] PASSED
  - tests/scripts/dev_tools/pr_context/test_autoclose_collector.py::test_collector_excludes_scraped_tokens_from_autoclose_when_gh_unavailable PASSED
  - tests/scripts/dev_tools/pr_context/test_autoclose_collector.py::test_collector_excludes_prose_cited_closed_issue_from_autoclose PASSED
  - tests/scripts/dev_tools/pr_context/test_autoclose_collector.py::test_collector_excludes_prose_cited_open_out_of_scope_issue_from_autoclose PASSED
  - tests/scripts/dev_tools/pr_context/test_autoclose_collector.py::test_collector_excludes_closed_pending_primary_without_printing_it[closed-issue] PASSED
  - tests/scripts/dev_tools/pr_context/test_autoclose_collector.py::test_collector_excludes_closed_pending_primary_without_printing_it[unknown-state] PASSED
  - tests/scripts/dev_tools/pr_context/test_autoclose_collector.py::test_collector_excludes_closed_pending_primary_without_printing_it[pull-request] PASSED
  - tests/scripts/dev_tools/pr_context/test_autoclose_collector.py::test_collector_excludes_closed_pending_primary_without_printing_it[unclassified] PASSED

- The 34 tests that passed in [P2-T9] also pass (18 acceptance cases, the reject cases for abc#12, #, and the empty string under all three extractors, both parity tests, C5 x2, C6, C7, C8).
