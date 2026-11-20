# Gate — every push-down test, including the copilot-side contracts (AC23)

Timestamp: 2026-08-20T09-53

Task: [P6-T6]

Command: poetry run pytest tests/scripts/dev_tools/ -k push_down
EXIT_CODE: 0

## Result

```
==================== 121 passed, 3791 deselected in 1.18s =====================
```

- Passed: 121
- Failed: 0

## Every push-down test module that ran

Collected with `poetry run pytest tests/scripts/dev_tools/ -k push_down --collect-only -q`:

1. `tests/scripts/dev_tools/test_push_down_claude_customizations.py`
2. `tests/scripts/dev_tools/test_push_down_claude_memory_scope.py`
3. `tests/scripts/dev_tools/test_push_down_claude_pack_end_to_end.py`
4. `tests/scripts/dev_tools/test_push_down_claude_pack_manifest_completeness.py`
5. `tests/scripts/dev_tools/test_push_down_claude_pack_memory_modes.py`
6. `tests/scripts/dev_tools/test_push_down_claude_pack_selection.py`
7. `tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py`
8. `tests/scripts/dev_tools/test_push_down_codex_and_agents_customizations.py`
9. `tests/scripts/dev_tools/test_push_down_codex_and_agents_pack_manifest_completeness.py`
10. `tests/scripts/dev_tools/test_push_down_codex_and_agents_resource_contracts.py`
11. `tests/scripts/dev_tools/test_push_down_codex_pack_selection.py`
12. `tests/scripts/dev_tools/test_push_down_copilot_customizations.py`
13. `tests/scripts/dev_tools/test_push_down_copilot_customizations_helpers.py`
14. `tests/scripts/dev_tools/test_push_down_copilot_customizations_rewrites.py`

Modules 12 through 14 are the copilot-side push-down tests that [P6-T5] did not name; they pass as
well, so the copilot bundled root
(`extensions/drm-copilot/resources/customizations/.github/skills/evidence-and-timestamp-conventions/SKILL.md`)
is consistent with its canonical source after the edit.

Output Summary: 121 passed, 0 failed; exit code 0 across all 14 push-down test modules, including the
three copilot-side modules not named at [P6-T5]. No mirror is stale after the six-copy documentation
edit.
