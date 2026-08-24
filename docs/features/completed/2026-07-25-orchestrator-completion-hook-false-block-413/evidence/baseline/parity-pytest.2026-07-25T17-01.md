# Bundle-Parity Pytest Baseline (issue #413)

Timestamp: 2026-07-25T17-01

Command: `poetry run python -m pytest tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py -q` (run at repo root `C:/Users/DanMoisan/repos/drm-copilot/.claude/worktrees/agent-a0fcdf306557436df`)

EXIT_CODE: 0

Output Summary:

```text
.......                                                                  [100%]
7 passed in 0.10s
```

- 7 passed, 0 failed, 0 errors.
- This module contains `test_bundled_claude_payload_contains_all_repo_runtime_contracts`,
  the gate that locks byte parity between `.claude/hooks/validate-orchestrator-output.ps1`
  and its bundled copy at
  `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/validate-orchestrator-output.ps1`.
- Baseline verdict: parity is green before the fix, so any parity failure later in this
  execution is attributable to the change under test.
