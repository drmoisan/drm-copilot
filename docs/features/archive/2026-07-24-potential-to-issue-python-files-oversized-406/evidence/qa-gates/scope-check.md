Timestamp: 2026-09-30T10-26
Command: git diff --name-only origin/main -- scripts tests extensions ; git status --porcelain -- scripts tests extensions
EXIT_CODE: 0
Output Summary: Union of paths equals exactly the eight declared paths; no path under extensions/ appears.
git diff --name-only origin/main (tracked changes):
scripts/dev_tools/potential_to_issue.py
tests/scripts/dev_tools/test_potential_to_issue.py
tests/scripts/dev_tools/test_potential_to_issue_content.py
git status --porcelain (untracked, created by this work):
?? scripts/dev_tools/potential_to_issue_adapters.py
?? tests/scripts/dev_tools/potential_to_issue_test_support.py
?? tests/scripts/dev_tools/test_potential_to_issue_bug_bodies.py
?? tests/scripts/dev_tools/test_potential_to_issue_cli_and_adapters.py
?? tests/scripts/dev_tools/test_potential_to_issue_work_modes.py
Coverage outputs (artifacts/python/lcov.info, artifacts/.coverage) fall outside the scoped paths.
