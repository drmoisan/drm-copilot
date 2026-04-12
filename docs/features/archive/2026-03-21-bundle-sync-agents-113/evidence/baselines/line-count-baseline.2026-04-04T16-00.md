# Line Count Baseline — 2026-04-04T16-00

Timestamp: 2026-04-04T16-00
Branch: feature/bundle-sync-agents-113
Policy limit: 500 lines per file

## Violating Files

| File | Line Count | Limit | Status |
|------|-----------|-------|--------|
| `extensions/drm-copilot/src/extension.ts` | 592 | 500 | VIOLATION |
| `tests/scripts/dev_tools/test_push_down_copilot_customizations.py` | 583 | 500 | VIOLATION |

Commands used:
- `(Get-Content extensions/drm-copilot/src/extension.ts).Count` → 592
- `(Get-Content tests/scripts/dev_tools/test_push_down_copilot_customizations.py).Count` → 583
