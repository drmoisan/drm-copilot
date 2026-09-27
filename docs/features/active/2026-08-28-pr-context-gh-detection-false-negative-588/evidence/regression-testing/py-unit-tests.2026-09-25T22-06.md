# Python Unit Tests ([P6-T4])

Timestamp: 2026-09-26T22-02

Command: `poetry run pytest tests/scripts/dev_tools/pr_context/test_render_pr_helpers.py -v` (repository root)

EXIT_CODE: 0

Output Summary:
- Result line: `5 passed in 0.07s` (0 FAILED; 5 #588 cases).
- `PASSED ...::test_build_issues_to_autoclose_section_reports_gh_unavailable_when_empty` (asserts `result.splitlines()[-1] == UNAVAILABLE_BODY`)
- `PASSED ...::test_build_issues_to_autoclose_section_prefers_unavailable_text_over_pass_readiness` (asserts `result.splitlines()[-1] == UNAVAILABLE_BODY`)
- `PASSED ...::test_build_issues_to_autoclose_section_lists_pending_refs_when_gh_unavailable`
- `PASSED ...::test_build_issues_to_autoclose_section_keeps_available_fallback_texts[readiness0-None (no verified closing issues and no deterministic pending issue)]`
- `PASSED ...::test_build_issues_to_autoclose_section_keeps_available_fallback_texts[readiness1-None (no verified closing issues and readiness not PASS)]`
- Node prefix `...` is `tests/scripts/dev_tools/pr_context/test_render_pr_helpers.py`. Final names equal planned names (no title collisions).
