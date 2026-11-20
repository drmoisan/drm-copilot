# Phase 6 — Bundle-Sync Contract Test (extensions mirror)

- Timestamp: 2026-06-16T11-00
- Issue: #187
- Task: [P6-T1]

## Command

```
poetry run pytest tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py -v
```

## EXIT_CODE

0

## Output Summary

4 passed:
- `test_bundled_claude_payload_contains_required_runtime_files` PASSED
- `test_bundled_claude_payload_contains_all_repo_runtime_contracts` PASSED
  (every changed/created canonical `.claude/` file is byte-identical in the
  `extensions/drm-copilot/resources/claude-customizations/.claude/` mirror)
- `test_bundled_claude_payload_excludes_settings_local_json` PASSED
- `test_bundled_agent_memory_scopes_are_well_formed` PASSED

The `extensions/` mirror parity gate confirms byte-identical propagation of all
Phase 1-5 canonical `.claude/` changes.
