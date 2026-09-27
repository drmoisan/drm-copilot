# Remediation Cycle 1 - P0-T7 PowerShell Format and Analyzer Baseline (read-only)

Timestamp: 2026-09-27T04-52
Command: sh <SCRATCHPAD>/x713-analyze.sh (R-ANALYZE)
EXIT_CODE: 0
FORMAT_CHECK_EXIT_CODE: 0 (sh <SCRATCHPAD>/x713-fmtcheck.sh, R-FMTCHECK with a no-op WriteFile seam)
Output Summary: R-FMTCHECK reported FORMAT_CHANGED_COUNT 0 and FORMAT_ALREADY_COUNT 531 (every scanned file already formatted); the tree was unchanged across the check. R-ANALYZE reported `PSScriptAnalyzer passed: no findings under <WORKSPACE_ROOT>` and ANALYZE_RESULT: passed.

FORMAT_CHANGED_COUNT: 0
FORMAT_ALREADY_COUNT: 531
FORMAT_CHANGED: none

## Tree Delta

Porcelain before R-FMTCHECK (`git status --porcelain`):

```text
 M docs/features/active/preimplementation-gate-blocks-attribution-trailers-713/remediation-plan.2026-09-27T05-05.md
?? docs/features/active/preimplementation-gate-blocks-attribution-trailers-713/evidence/remediation-baseline/
```

Porcelain after R-FMTCHECK (`git status --porcelain`):

```text
 M docs/features/active/preimplementation-gate-blocks-attribution-trailers-713/remediation-plan.2026-09-27T05-05.md
?? docs/features/active/preimplementation-gate-blocks-attribution-trailers-713/evidence/remediation-baseline/
```

The two outputs are identical.

## R-ANALYZE output

```text
PSScriptAnalyzer passed: no findings under <WORKSPACE_ROOT>
ANALYZE_RESULT: passed
```
