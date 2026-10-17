# Brief Copy to the Five Mirror Locations (Issue #973)

Timestamp: 2026-10-17T13-35
Command: sh SCRATCH/issue-973-brief-copy.sh <worktree>; then sh SCRATCH/issue-973-pytest.sh <worktree> (poetry run pytest per contract file, -q --no-cov)
EXIT_CODE: 0

Copy script result (exit code 0); each destination compared with `cmp` after the copy:

- `.agents/skills/execution-environment/SKILL.md`: IDENTICAL
- `.github/skills/execution-environment/SKILL.md`: IDENTICAL
- `extensions/drm-copilot/resources/claude-customizations/.claude/skills/execution-environment/SKILL.md`: IDENTICAL
- `extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/execution-environment/SKILL.md`: IDENTICAL
- `extensions/drm-copilot/resources/customizations/.github/skills/execution-environment/SKILL.md`: IDENTICAL

Contract tests after the copy:

| File | Passed | Failed |
|---|---|---|
| `tests/scripts/dev_tools/test_execution_environment_brief_contracts.py` (includes `test_brief_copies_are_byte_identical`) | 18 | 0 |
| `tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py` | 14 | 0 |
| `tests/scripts/dev_tools/test_push_down_codex_and_agents_resource_contracts.py` | 9 | 0 |
| `tests/scripts/dev_tools/test_single_pass_preflight_contracts.py` | 12 | 0 |

Output Summary: copy script exit code 0; all five mirrors byte-identical to the canonical brief; `test_brief_copies_are_byte_identical` passes (18/18 in its file).
