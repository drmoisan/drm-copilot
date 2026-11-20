# Final pytest gate (P6-T4)

Timestamp: 2026-11-09T16-59
Command: sh SCRATCH/issue-1153-pytest.sh (from the worktree root: env -u VIRTUAL_ENV poetry run pytest -n auto --cov-report=term --cov -q -rfE)
EXIT_CODE: 0
Output Summary:
  Summary line: 16590 passed, 6 skipped in 175.67s (0:02:55).
  Failed: 0. Errors: 0. Failing node ids: none (no FAILED or ERROR line in the output).
  Phase 0 baseline (evidence/baseline/pytest.2026-11-09T15-44.md): 16590 passed, 6 skipped, 0 failed; no failure is new.
  Repo-wide coverage (TOTAL row of the term report): 35355 statements, 1021 missed, 97% (baseline 35355, 1021, 97%; no drop).
  Named push-down and citation tests: test_push_down_claude_resource_contracts.py, test_push_down_claude_pack_manifest_completeness.py, test_push_down_pack_manifest_dependency_closure.py, and test_epic_skill_script_citations_shipped.py are under tests/scripts/dev_tools/ in the collected tree and pass (the run reports 0 failures; a focused debug run of the four files after P5-T1 reported 42 passed).
  Added files since the merge base of origin/main and HEAD (git diff --name-only --diff-filter=A): 29 files, 0 with a .py suffix; git status --porcelain lists no .py file (no untracked or modified Python file).
