# Final QA — Line Counts (P8-T5)

Timestamp: 2026-09-27T15-55

Command: sh `<scratchpad>`/run-ps.sh `<scratchpad>`/line-counts.ps1 tests/scripts/dev_tools/test_blast_radius_regression_452.py tests/scripts/claude-lib/blast-radius/BlastRadius.Regression452.Tests.ps1

EXIT_CODE: 0

```
tests/scripts/dev_tools/test_blast_radius_regression_452.py LineCount=487
tests/scripts/claude-lib/blast-radius/BlastRadius.Regression452.Tests.ps1 LineCount=290
```

Acceptance evaluation:

| File | LineCount (physical) | Limit | Result |
| --- | --- | --- | --- |
| tests/scripts/dev_tools/test_blast_radius_regression_452.py | 487 | <= 500 | pass |
| tests/scripts/claude-lib/blast-radius/BlastRadius.Regression452.Tests.ps1 | 290 | <= 500 | pass |

The JSON corpus and Markdown documents are exempt from the 500-line limit under the AC-18 wording.

Output Summary: PASS. EXIT_CODE 0; the Python consumer has 487 lines and the Pester consumer has 290 lines, both at or below the 500-line limit (AC-18).
