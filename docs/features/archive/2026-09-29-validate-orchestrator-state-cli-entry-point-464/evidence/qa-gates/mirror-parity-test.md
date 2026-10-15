# Mirror-Parity Test (Issue #464)

Timestamp: 2026-09-30T09-12
Command: poetry run pytest tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py::test_bundled_claude_payload_contains_all_repo_runtime_contracts -q -p no:cacheprovider --no-cov
EXIT_CODE: 0 (isolated run); 1 (unisolated run, see below)
Output Summary:
- Isolated run (the gitignored batch-budget state file moved aside for the single pytest process and restored afterwards): `1 passed in 0.12s`, exit code 0.
- Unisolated run (as the plan states the command): `1 failed in 0.12s`, exit code 1, with `Repo file missing from bundle: .claude\state\python-batch-budget.worktree-agent-af9d2cac47d08093f-22913714.json`.
- Cause: the test enumerates the filesystem rather than the git index, and `.claude/state/` is gitignored hook state that the batch-budget hook writes in this worktree. This is the condition tracked as issue #510; CI has no such directory. The failure is environment-conditional and does not come from the issue #464 change.
- The state file was not deleted (deleting it would reset the batch budget). It was moved aside and restored in the same shell command; `git hash-object` returned `a3b7c65507d342053a06490a2de80112f48b6784` before and after, so the file is byte-identical.
- Durable parity check (`git hash-object`, independent of `.claude/state/`):
  - `.claude/rules/orchestrator-state.md` and its bundled mirror: both `371943249df506815c6f145a52b4ef0b18ca2131`.
  - `.claude/skills/orchestrate/SKILL.md` and its bundled mirror: both `90716dea99c3d8bd7294db7793da153c6ddac832`.
- Deviation recorded for `## Implementation Notes`: the plan acceptance `1 passed` holds only for the isolated run.
