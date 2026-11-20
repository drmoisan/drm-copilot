# Pass-after — link-parent-child.Tests.ps1 alone (P1-T5)

Timestamp: 2026-11-04T15-48
Command: sh SCRATCH/issue-1067-runpaths.sh after-lpc tests/scripts/dev-tools/link-parent-child.Tests.ps1 (fresh pwsh -NoProfile process running SCRATCH/issue-1067-run-pester.ps1; run at 2026-11-04T15-47)
EXIT_CODE: 0

```
TOTAL Tests=22 Passed=22 Failed=0 Skipped=0 NotRun=0
FILE tests/scripts/dev-tools/link-parent-child.Tests.ps1 tests=22 failed=0
CONTAINERS Total=1 Failed=0
PROBE POSHQC_SKIP_SCRIPT_EXECUTION=absent
PROBE GH-FUNCTION=absent
```

Output Summary: Tests=22 (equal to P0-T4), Failed=0, PROBE POSHQC_SKIP_SCRIPT_EXECUTION=absent; pass-after for R1-F1 against the P0-T4 fail-before (=1).
