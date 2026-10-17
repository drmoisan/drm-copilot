# PowerShell Coverage Comparison (P6-T9)

Timestamp: 2026-10-08T22-36
Command: comparison of P0-T25, P6-T7, P6-T8
EXIT_CODE: 0
Output Summary:
- Baseline: BASE_HOOK_PCT = 94.55 (HOOK, P0-T25); SIB and PORT were NEW-FILE at baseline.
- Final LinePercent (P6-T7): HOOK 94.62; SIB 98.96; PORT 100.
- Changed-line ChangedPercent (P6-T8): HOOK 96.43; SIB 98.96; PORT 100.
- HOOK line coverage moved from 94.55 to 94.62 (no regression).
- Threshold: every final LinePercent and every ChangedPercent is at least 85.

Result: PASS. The Python comparison is made by P6-T14.
