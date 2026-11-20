# P0-T9 PowerShell Format Baseline (read-only)

Timestamp: 2026-09-27T03-23
Command: sh <SCRATCHPAD>/x713-fmtcheck.sh (R-FMTCHECK: Invoke-PoshQCFormat -Root $root with a no-op WriteFile seam)
EXIT_CODE: 0
Output Summary: R-FMTCHECK reported 0 files whose formatter output differs and 530 files already formatted. The porcelain status before and after the check is identical, so the check wrote nothing.

FORMAT_CHANGED_COUNT: 0
FORMAT_ALREADY_COUNT: 530

FORMAT_CHANGED lines: none

Other commands:

- `git status --porcelain` (before): EXIT_CODE 0
- `git status --porcelain` (after): EXIT_CODE 0

## Tree Delta

Before:

```text
 M docs/features/active/preimplementation-gate-blocks-attribution-trailers-713/plan.2026-09-27T00-23.md
?? docs/features/active/preimplementation-gate-blocks-attribution-trailers-713/evidence/
```

After:

```text
 M docs/features/active/preimplementation-gate-blocks-attribution-trailers-713/plan.2026-09-27T00-23.md
?? docs/features/active/preimplementation-gate-blocks-attribution-trailers-713/evidence/
```

The two outputs are identical.
