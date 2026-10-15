Timestamp: 2026-10-12T09-20
Command: poetry run pytest tests/scripts/dev_tools/test_push_down_claude_customizations.py tests/scripts/dev_tools/test_push_down_claude_gitignore_merge.py tests/scripts/dev_tools/test_push_down_claude_gitignore_delivery.py tests/scripts/dev_tools/test_push_down_claude_parity.py tests/scripts/dev_tools/test_push_down_claude_pack_selection.py tests/scripts/dev_tools/test_push_down_claude_pack_end_to_end.py tests/scripts/dev_tools/test_push_down_claude_exclusion_filter.py tests/scripts/dev_tools/test_push_down_claude_memory_scope.py tests/scripts/dev_tools/test_push_down_claude_pack_memory_modes.py --cov=scripts.dev_tools.push_down_claude_filesystem --cov=scripts.dev_tools.push_down_claude_gitignore_merge --cov=scripts.dev_tools.push_down_claude_customizations --cov=scripts.dev_tools.push_down_claude_pack_selection --cov-branch --cov-report=term-missing
EXIT_CODE: 0
Output Summary:
116 passed in 1.00s (failed count 0; greater than the P0-T6 count of 100). EXIT_CODE 0 is inferred from the all-passed summary line with no error output; the Bash tool does not display the numeric exit status.

Name                                                    Stmts   Miss Branch BrPart  Cover   Missing
---------------------------------------------------------------------------------------------------
scripts\dev_tools\push_down_claude_customizations.py       79      5     16      0    93%   130-139
scripts\dev_tools\push_down_claude_filesystem.py          113      4     28      2    96%   145, 182-183, 326
scripts\dev_tools\push_down_claude_gitignore_merge.py      48      0     14      0   100%
scripts\dev_tools\push_down_claude_pack_selection.py       83      5     30      5    91%   214, 229, 240, 256, 314
---------------------------------------------------------------------------------------------------
TOTAL                                                     323     14     88      7    94%
