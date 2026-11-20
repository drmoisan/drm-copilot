# Baseline — link-parent-child.Tests.ps1 alone (P0-T4)

Timestamp: 2026-11-04T15-44
Command: sh SCRATCH/issue-1067-runpaths.sh base-lpc tests/scripts/dev-tools/link-parent-child.Tests.ps1 (fresh pwsh -NoProfile process running SCRATCH/issue-1067-run-pester.ps1)
EXIT_CODE: 0

```
TOTAL Tests=22 Passed=22 Failed=0 Skipped=0 NotRun=0
FILE tests/scripts/dev-tools/link-parent-child.Tests.ps1 tests=22 failed=0
CONTAINERS Total=1 Failed=0
PROBE POSHQC_SKIP_SCRIPT_EXECUTION=1
PROBE GH-FUNCTION=absent
```

Output Summary: 22 tests, Failed=0. PROBE POSHQC_SKIP_SCRIPT_EXECUTION=1 is the fail-before signal for R1-F1 in this suite.
