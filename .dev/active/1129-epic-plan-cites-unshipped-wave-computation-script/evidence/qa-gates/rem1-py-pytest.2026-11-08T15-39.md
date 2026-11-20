# rem1-py-pytest

Timestamp: 2026-11-08T15-39
Command: env -u VIRTUAL_ENV poetry run pytest -n auto --cov-branch --cov-report=term-missing --cov-report=json:SCRATCH/issue-1129-cov-rem1.json --cov
EXIT_CODE: 0
Output Summary:
16559 passed, 6 skipped, 0 failed in 272.50s (pytest -n auto; Phase 0 baseline 16537 passed, 6 skipped, 0 failed; cycle-0 final 16555 passed).
Named tests green: test_every_epic_surface_citation_is_shipped, test_epic_surface_sets_cover_every_epic_surface_in_tree, test_find_unshipped_citations_normalizes_module_form, test_find_unshipped_citations_strips_dot_slash_prefix, and test_corpus_case_matches_reference[case-variant-keys] (confirmed by a verbose focused re-run of the two test files, debugging only; the gate run reported zero failures).
Coverage from the JSON report (cycle 1 changes only test files, so production figures equal the cycle-0 final):
repo-wide: lines 97.11% (34296/35317) branches 94.36% (12648/13404)
scripts/dev_tools/epic_wave_computation.py: lines 100.00% (34/34) branches 100.00% (12/12)
scripts/dev_tools/push_down_codex_and_agents_customizations.py: lines 98.18% (108/110) branches 88.89% (16/18)
scripts/dev_tools/validate_epic_planner_state.py: lines 100.00% (191/191) branches 99.00% (99/100)
