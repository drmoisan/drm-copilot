# QA Gate — fix_all Targeted Pytest (P3-T2) (Issue #393)

Timestamp: 2026-07-21T18-45
Command: poetry run pytest tests/scripts/dev_tools/test_fix_all_branches.py tests/scripts/dev_tools/test_fix_all.py -q
EXIT_CODE: 0
Output Summary: 37 passed in 0.24s. No test edits were required: the fake runner keys by step
name ("Shell: format" / "Shell: check" / "Shell: test"), not by command list, so repointing
the three command lists in `scripts/dev_tools/fix_all_branches.py` from
`["poetry","run","python","-m","scripts.dev_tools.shell_qc","<cmd>"]` to
`["bash","scripts/bash/shell-qc.sh","<cmd>"]` did not affect assertions. `grep -n "shell_qc"
scripts/dev_tools/fix_all_branches.py` returns no hits. The three step names are unchanged.
