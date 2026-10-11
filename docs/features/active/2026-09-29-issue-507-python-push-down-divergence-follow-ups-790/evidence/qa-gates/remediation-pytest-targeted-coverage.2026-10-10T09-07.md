# P2-T4 Python Targeted Tests with Coverage (COVERAGE-CMD, final)

Timestamp: 2026-10-10T09-07
Command: poetry run pytest tests/scripts/dev_tools/test_push_down_claude_customizations.py tests/scripts/dev_tools/test_push_down_claude_gitignore_merge.py tests/scripts/dev_tools/test_push_down_claude_gitignore_delivery.py tests/scripts/dev_tools/test_push_down_claude_gitignore_parity.py tests/scripts/dev_tools/test_push_down_claude_parity.py tests/scripts/dev_tools/test_push_down_claude_pack_selection.py tests/scripts/dev_tools/test_push_down_claude_pack_end_to_end.py tests/scripts/dev_tools/test_push_down_claude_exclusion_filter.py --cov=scripts.dev_tools.push_down_claude_filesystem --cov=scripts.dev_tools.push_down_claude_gitignore_merge --cov=scripts.dev_tools.push_down_claude_customizations --cov=scripts.dev_tools.push_down_claude_pack_selection --cov-branch --cov-report=term-missing --cov-report=json:artifacts/python/coverage-790-remediation.json
EXIT_CODE: 0
Output Summary:
Loop iteration 1. 101 passed in 0.87s (BASELINE_TARGETED_PASSED 97 plus 4). No failed test.

```
Name                                                    Stmts   Miss Branch BrPart  Cover   Missing
scripts\dev_tools\push_down_claude_customizations.py       79      5     16      0    93%   130-139
scripts\dev_tools\push_down_claude_filesystem.py          113      8     28      6    90%   122, 128, 135, 145, 148, 182-183, 326
scripts\dev_tools\push_down_claude_gitignore_merge.py      48      0     14      0   100%
scripts\dev_tools\push_down_claude_pack_selection.py       83      5     30      5    91%   214, 229, 240, 256, 314
TOTAL                                                     323     18     88     11    92%
```

The filesystem row no longer lists 407 or 409-414 in Missing.
