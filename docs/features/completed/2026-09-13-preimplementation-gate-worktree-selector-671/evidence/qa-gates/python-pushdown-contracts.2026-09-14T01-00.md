# Final QA — Python Push-Down Contract Tests (issue #671)

Timestamp: 2026-09-17T08-29
Task: [P6-T5]
Command: poetry run pytest tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py tests/scripts/dev_tools/test_push_down_claude_pack_manifest_completeness.py -v -p no:cacheprovider --no-cov (worktree root, via a scratchpad `sh` wrapper)
EXIT_CODE: 0

Output Summary:
- Final run: 16 collected; passed=16, failed=0 ("16 passed in 0.16s").
- `test_bundled_claude_payload_contains_all_repo_runtime_contracts`: PASSED.
- No Python file was edited.

## First run (superseded)

- Timestamp: 2026-09-17T08-29
- EXIT_CODE: 1
- Result: 15 passed, 1 failed. The failure was `test_bundled_claude_payload_contains_all_repo_runtime_contracts`, with "Repo file missing from bundle: .claude\state\powershell-batch-budget.worktree-agent-a6dbf51ad3a3ac686-4c625983.json".
- Cause: the PowerShell batch-budget hook had recreated its gitignored session state file under `.claude/state/` when the parity suite was written ([P4-T2]). The parity test enumerates every file under `.claude/`, including gitignored runtime state. This is the known local-only failure mode tracked as issue #510; it does not involve any file this plan changes.
- Action: the plan-authorized batch-budget reset (the same `Get-ChildItem`/`Remove-Item` procedure as [P2-T3] and [P4-T1]) deleted that one state file (it recorded testFiles = [the parity suite]); after the reset, `.claude/state/` held no files. The run above was then repeated unchanged.
