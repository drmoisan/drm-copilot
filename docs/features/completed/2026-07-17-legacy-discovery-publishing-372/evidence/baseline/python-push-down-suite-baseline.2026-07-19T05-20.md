Timestamp: 2026-07-19T05-20
Command: `poetry run pytest tests/scripts/dev_tools/test_push_down_claude_customizations.py tests/scripts/dev_tools/test_push_down_claude_memory_scope.py tests/scripts/dev_tools/test_push_down_claude_pack_end_to_end.py tests/scripts/dev_tools/test_push_down_claude_pack_memory_modes.py tests/scripts/dev_tools/test_push_down_claude_pack_selection.py tests/scripts/dev_tools/test_push_down_codex_and_agents_customizations.py tests/scripts/dev_tools/test_push_down_codex_pack_selection.py tests/scripts/dev_tools/test_push_down_copilot_customizations.py tests/scripts/dev_tools/test_push_down_copilot_customizations_helpers.py tests/scripts/dev_tools/test_push_down_copilot_customizations_rewrites.py --cov=scripts/dev_tools --cov-branch --cov-report=term-missing -v`
EXIT_CODE: 0
Output Summary: 97 passed in 3.87s. Per-module coverage for the push-down modules directly
exercised by this suite: `push_down_claude_customizations.py` 91% line, `push_down_claude_filesystem.py`
89% line / branch-partial, `push_down_claude_pack_selection.py` 90%, `push_down_codex_and_agents_customizations.py`
96%, `push_down_codex_filesystem.py` 92%, `push_down_codex_pack_selection.py` 98%,
`push_down_copilot_customizations.py` 93%, `push_down_copilot_customizations_filesystem.py` 87%,
`push_down_copilot_customizations_rewrites.py` 97%. Repository-wide `scripts/dev_tools` TOTAL for
this targeted run: 12474 stmts, 5% line coverage (this run does not exercise most of the
`scripts/dev_tools` package; the 5% total is expected for this narrow suite and is not the
repository-wide baseline).
