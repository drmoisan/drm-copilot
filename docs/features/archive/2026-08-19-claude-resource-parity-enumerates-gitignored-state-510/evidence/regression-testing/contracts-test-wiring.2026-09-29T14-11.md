# P3-T3 Contracts test wiring

Timestamp: 2026-10-07T11-07
Command: git -C <worktree> grep -n -F "filter_distributable_claude_paths" -- tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py; git -C <worktree> grep -c -F -e "Repo file missing from bundle" -e "Bundle content differs from repo for" -- tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py; git -C <worktree> diff origin/main -U0 -- tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py
EXIT_CODE: 0
Output Summary:
- Helper grep: EXIT_CODE 0, three matching lines (line 18 import, line 100 comment, line 101 call `repo_runtime_files = filter_distributable_claude_paths(list_scoped_files(REPO_ROOT))`).
- Assertion-message grep -c: EXIT_CODE 0, count 2 (`Repo file missing from bundle`, `Bundle content differs from repo for`).
- Diff observation (`git diff origin/main -U0`): hunks touch only the module docstring, the import block, the deleted `AGENT_MEMORY_RELATIVE_ROOT`/`_is_agent_memory_path` block (33 lines), the test docstring, the two-line comment, and the filter. Piping the diff through `grep -c -F` for both assertion message tokens printed 0, so no added or removed line contains either token.
- Contracts test file is 467 lines (baseline 500); Black and Ruff were run on it after the edit (Black reformatted the filter call onto one line once, then reported `1 file left unchanged`; Ruff `All checks passed!`).
