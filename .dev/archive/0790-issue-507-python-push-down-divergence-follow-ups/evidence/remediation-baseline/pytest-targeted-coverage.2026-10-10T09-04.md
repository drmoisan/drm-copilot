# P0-T6 Remediation Coverage Baseline (COVERAGE-CMD, unmodified tree)

Timestamp: 2026-10-10T09-04
Command: poetry run pytest tests/scripts/dev_tools/test_push_down_claude_customizations.py tests/scripts/dev_tools/test_push_down_claude_gitignore_merge.py tests/scripts/dev_tools/test_push_down_claude_gitignore_delivery.py tests/scripts/dev_tools/test_push_down_claude_gitignore_parity.py tests/scripts/dev_tools/test_push_down_claude_parity.py tests/scripts/dev_tools/test_push_down_claude_pack_selection.py tests/scripts/dev_tools/test_push_down_claude_pack_end_to_end.py tests/scripts/dev_tools/test_push_down_claude_exclusion_filter.py --cov=scripts.dev_tools.push_down_claude_filesystem --cov=scripts.dev_tools.push_down_claude_gitignore_merge --cov=scripts.dev_tools.push_down_claude_customizations --cov=scripts.dev_tools.push_down_claude_pack_selection --cov-branch --cov-report=term-missing --cov-report=json:artifacts/python/coverage-790-remediation-baseline.json
EXIT_CODE: 0
Output Summary:
97 passed in 0.95s (BASELINE_TARGETED_PASSED = 97). No failed test.

```
Name                                                    Stmts   Miss Branch BrPart  Cover   Missing
scripts\dev_tools\push_down_claude_customizations.py       79      5     16      0    93%   130-139
scripts\dev_tools\push_down_claude_filesystem.py          113     13     28      8    84%   122, 128, 135, 145, 148, 182-183, 326, 407, 409-414
scripts\dev_tools\push_down_claude_gitignore_merge.py      48      0     14      0   100%
scripts\dev_tools\push_down_claude_pack_selection.py       83      5     30      5    91%   214, 229, 240, 256, 314
TOTAL                                                     323     23     88     13    90%
```

The filesystem row lists Missing entries 407 and 409-414, as expected.
