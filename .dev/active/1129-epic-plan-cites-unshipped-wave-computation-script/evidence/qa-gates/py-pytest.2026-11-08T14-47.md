# py-pytest

Timestamp: 2026-11-08T14-47
Command: env -u VIRTUAL_ENV poetry run pytest -n auto --cov-branch --cov-report=term-missing --cov-report=json:SCRATCH/issue-1129-cov-final.json --cov
EXIT_CODE: 0
Output Summary:
16555 passed, 6 skipped, 0 failed in 287.17s (pytest -n auto; baseline 16537 passed, 6 skipped).
Named tests green: test_every_epic_surface_citation_is_shipped, test_corpus_case_matches_reference (8 corpus cases), test_frozen_epic_surface_matches_pinned_baseline_digest (both pinned surfaces), test_epic_wave_directory_publishes_stored_resources (confirmed by a verbose focused re-run, debugging only; the gate run reported zero failures).
Coverage from the JSON report:
repo-wide: lines 97.11% (34296/35317) branches 94.36% (12648/13404)
scripts/dev_tools/epic_wave_computation.py: lines 100.00% (34/34) branches 100.00% (12/12)
scripts/dev_tools/push_down_codex_and_agents_customizations.py: lines 98.18% (108/110) branches 88.89% (16/18)
scripts/dev_tools/validate_epic_planner_state.py: lines 100.00% (191/191) branches 99.00% (99/100)
