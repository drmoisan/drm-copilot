# Phase 8 Python Contract and Runtime Tests — Issue #670

Timestamp: 2026-09-17T08-54
Task: [P8-T5]
Loop pass: 2
Command: poetry run pytest tests/scripts/dev_tools -q
EXIT_CODE: 1
ExpectedExitCode: 1

Output Summary:
- `1 failed, 4330 passed, 5 skipped in 7.31s`
- Passed-test count: 4330.
- Only failure: `tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py::test_bundled_claude_payload_contains_all_repo_runtime_contracts`
- Assertion message (verbatim): `AssertionError: Repo file missing from bundle: .claude\state\powershell-batch-budget.worktree-agent-a51b6017c8cb9c138-ac477202.json`
- Cause: open issue #510 (`claude-resource-parity-enumerates-gitignored-state`), pre-existing; the cause is the one stated in [P6-T8].
- Durable substitute: a `Get-FileHash -Algorithm SHA256` pair for each of the four mirrored `.claude/**` files, all four matching (recorded in `p8-mirror-resync.2026-09-13T20-46.md`): `.claude/hooks/enforce-epic-merge-gate.ps1` 77C30E88...E24D, `.claude/hooks/enforce-epic-merge-gate-authorization.ps1` 08FB2DE6...29C3, `.claude/rules/orchestrator-state.md` 0085540B...C892, `.claude/skills/parallel-orchestrate/SKILL.md` 6A9743D8...9AB1.
- No other node failed.
