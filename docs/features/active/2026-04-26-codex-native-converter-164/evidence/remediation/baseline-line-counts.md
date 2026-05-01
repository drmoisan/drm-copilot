# Baseline Line Counts

**Task:** P0-T6  
**Timestamp:** 2026-04-30T22:00  
**Commands:**
- `(Get-Content scripts/dev_tools/codex_native_converter/engine.py).Count`
- `(Get-Content scripts/dev_tools/codex_native_converter/models.py).Count`
- `(Get-Content scripts/dev_tools/codex_native_converter/reporting.py).Count`
**EXIT_CODE:** 0  

## Output Summary

| File | Current Lines | Target (Post-Split) |
|------|--------------|---------------------|
| `engine.py` | **1015** | ≤500 |
| `models.py` | **599** | ≤500 |
| `reporting.py` | **512** | ≤500 |

All three files exceed the 500-line policy limit. Remediation phases R1, R2, R3 are required.
