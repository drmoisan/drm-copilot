# Remediation cycle 1 final pytest gate (P2-T4)

Timestamp: 2026-11-09T17-53
Command: sh SCRATCH/issue-1153-pytest.sh (from the worktree root: env -u VIRTUAL_ENV poetry run pytest -n auto --cov-report=term --cov -q -rfE)
EXIT_CODE: 0
Output Summary:
  One run. Summary line: 16590 passed, 6 skipped in 174.89s (0:02:54).
  Failed: 0. Errors: 0. Failing node ids: none (no FAILED or ERROR line in the output).
  Main final gate (evidence/qa-gates/pytest.2026-11-09T16-59.md): 16590 passed, 6 skipped, 0 failed; no failure is new.
  Repo-wide coverage (TOTAL row of the term report): 35355 statements, 1021 missed, 97% (main final gate 35355, 1021, 97%; not below it).
  Named push-down and citation tests: test_push_down_claude_resource_contracts.py, test_push_down_claude_pack_manifest_completeness.py, test_push_down_pack_manifest_dependency_closure.py, and test_epic_skill_script_citations_shipped.py exist under tests/scripts/dev_tools/ in the collected tree and pass (the run reports 0 failures and 0 errors).
  Added files since the merge base of origin/main and HEAD (git diff --name-only --diff-filter=A <merge base> HEAD): 44 files, 0 with a .py suffix; git status --porcelain is empty (no untracked or modified file, so no unlisted Python file).
