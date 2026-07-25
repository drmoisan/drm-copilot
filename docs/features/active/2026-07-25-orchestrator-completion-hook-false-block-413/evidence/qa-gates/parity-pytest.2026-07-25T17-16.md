# Bundle-Parity Pytest Gate After Resync (issue #413, [P3-T5])

Timestamp: 2026-07-25T17-16

Command: `poetry run python -m pytest tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py -q` (run at repo root `C:/Users/DanMoisan/repos/drm-copilot/.claude/worktrees/agent-a0fcdf306557436df`)

EXIT_CODE: 0

Output Summary:

```text
.......                                                                  [100%]
7 passed in 0.08s
```

- 7 passed, 0 failed, 0 errors.
- Includes `test_bundled_claude_payload_contains_all_repo_runtime_contracts`, the gate that
  fails on any byte difference between `.claude/hooks/validate-orchestrator-output.ps1` and
  `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/validate-orchestrator-output.ps1`.
- Run performed after the [P3-T1]/[P3-T2] hook edits and the [P3-T3] bundled resync, so it
  gates the post-fix state. The result matches the Phase 0 baseline (7 passed), confirming
  the change introduced no parity drift.
