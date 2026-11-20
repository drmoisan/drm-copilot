# Phase gate P1 (P1-T5)

Timestamp: 2026-11-15T18-50
Command: stages 1 to 6 across the repository: (1) `mcp__drm-copilot__run_poshqc_format`; (2) `mcp__drm-copilot__run_poshqc_analyze` plus the direct per-file analyzer run `sh SCRATCH/issue-1192-static2.sh` over the two edited test files; (3) type check not applicable for PowerShell; (4) no architecture-boundary suite for this change; (5) one launcher `pester` run (`Invoke-PoshQCParallelTest`, 8 workers); (6) contract checks, one launcher `pytest` run over the four push-down contract tests plus `tests/scripts/dev_tools/test_execution_environment_brief_contracts.py`.
EXIT_CODE: 1
ExpectedExitCode: 1
Output Summary:
- Format: MCP result ok; `git status --porcelain` lists only the two edited test files and files under FEATURE before and after, so the format step changed no further tracked file. Direct compare: 0 drift in the two edited test files.
- Analyze: MCP result ok (an ok flag carries no findings); direct analyzer findings 0 for both edited test files.
- Pester gate: exit 1, wall-clock 845.09 s. Shard 4 Failed 1 (Passed 3675); shard 8 Failed 8 (Passed 3605); shards 1, 2, 3, 5, 6, 7 exit 0. No merged coverage written (a failing run writes none).
- Expected failures, each confirmed failing and listed by name (the five tests of the fail-before artifact; the four builder tests fail once per hook copy):
  1. `suite command builder.builds the jest suite with one --testPathIgnorePatterns word per pattern and keeps a positional extra` (`.claude/hooks`, `.codex/hooks`)
  2. `suite command builder.places a single jest positional before the first --testPathIgnorePatterns word` (both copies)
  3. `suite command builder.places a jest positional and a flag extra before every --testPathIgnorePatterns word` (both copies)
  4. `suite command builder.places a pester -TestPath extra before -ExcludeTag and keeps both exclusion groups intact` (both copies)
  5. `Invoke-TestSuiteLauncher argument and field reach (issue #1158, D26, D27).places a jest-extension positional before the first --testPathIgnorePatterns word in ArgumentList`
- No other test failed.
- Contract checks: 56 passed, 0 failed (pytest -n auto, 24 workers), EXIT_CODE 0.
- Queue note: several launcher attempts exited 75 (lock held by a sibling worktree's suite) and were re-run after the holder finished; they are queue timeouts, not failures.
