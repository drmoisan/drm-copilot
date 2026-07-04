# Phase 0 — Bundle-Sync Contract-Test Baseline

- Timestamp: 2026-06-16T11-00
- Issue: #187
- Task: [P0-T4]

## Command

```
poetry run pytest tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py
```

## EXIT_CODE

0

## Output Summary

4 passed in 0.09s. All bundle-sync contract tests pass at baseline (the
`extensions/` mirror is byte-identical to the canonical `.claude/` runtime for
all currently tracked runtime contracts, and `settings.local.json` is excluded
from the bundled payload).
