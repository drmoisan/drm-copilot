# Remediation Cycle 1 Push-Down Contract Baseline ([P0-T11])

Timestamp: 2026-09-25T21-19
Command: delete .claude/state/*-batch-budget.*.json (none present); git status --porcelain --ignored -- .claude/state; poetry run pytest tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py tests/scripts/dev_tools/test_push_down_claude_pack_manifest_completeness.py tests/scripts/dev_tools/test_push_down_codex_and_agents_resource_contracts.py tests/scripts/dev_tools/test_push_down_codex_and_agents_pack_manifest_completeness.py -q
EXIT_CODE: 0
Output Summary: 27 passed in 0.32s. No failed or errored test.

Batch-budget files deleted: none present (`.claude/state/` held no file).

## Porcelain (`git status --porcelain --ignored -- .claude/state`)

```
(empty)
```

## Summary Line

```
27 passed in 0.32s
```

Failed or errored node IDs: none
