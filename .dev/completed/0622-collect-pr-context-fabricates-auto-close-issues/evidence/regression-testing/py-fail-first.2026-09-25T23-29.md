# Python Fail-First Run on Pre-Fix Production Code (P2-T9)

Timestamp: 2026-09-26T19-57
Command: poetry run pytest tests/scripts/dev_tools/pr_context/test_issue_reference_pattern.py tests/scripts/dev_tools/pr_context/test_autoclose_collector.py -v
EXIT_CODE: 1
ExpectedExitCode: 1

Output Summary:
- Result line: `37 failed, 34 passed in 0.24s`. Every failure is an AssertionError; no collection or import error occurred.
- Failed (30): `test_extractors_reject_non_bare_number_tokens` for inputs `#ISO-8601`, `#CR-1`, `ISO-8601`, `CR-1`, `UTF-8`, `SHA-256`, `AC-12`, `#12abc`, `#12_`, and `#١٢` (node id `#١٢`) under each of `feature_docs`, `render_pr_helpers`, and `render_feature_excerpts`. Pre-fix extractors return the letter-prefixed token or the digit prefix (for example `['ISO-8601']`, `['#12']`).
- Failed (7): C1 `test_collector_excludes_scraped_tokens_from_autoclose_when_gh_unavailable` (the author-asserted block lists `#468`, `#622`, `#CR-1`, `#ISO-8601`); C2 `test_collector_excludes_prose_cited_closed_issue_from_autoclose` (`#468` in the author-asserted block); C3 `test_collector_excludes_prose_cited_open_out_of_scope_issue_from_autoclose` (`#584` in the author-asserted block); C4 `test_collector_excludes_closed_pending_primary_without_printing_it[closed-issue|unknown-state|pull-request|unclassified]` (last section line is `- #622`).
- Passed (34): all 18 `test_extractors_accept_bare_number_tokens` cases; reject cases `abc#12`, `#`, and `""` under all three extractors (9); `test_issue_reference_pattern_matches_typescript_literal`; `test_autoclose_literals_match_typescript_source`; C5 `test_collector_keeps_open_pending_primary[open|OPEN]`; C6 `test_collector_fetches_each_issue_once`; C7 `test_narrative_mentions_excluded_from_autoclose_section`; C8 `test_pass_readiness_autoclose_section`.
