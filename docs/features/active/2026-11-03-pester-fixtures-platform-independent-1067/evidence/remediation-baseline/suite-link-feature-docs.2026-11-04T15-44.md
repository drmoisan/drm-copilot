# Baseline — link-feature-docs.Tests.ps1 alone (P0-T3)

Timestamp: 2026-11-04T15-44
Command: sh SCRATCH/issue-1067-runpaths.sh base-lfd tests/scripts/dev-tools/link-feature-docs.Tests.ps1 (fresh pwsh -NoProfile process running SCRATCH/issue-1067-run-pester.ps1)
EXIT_CODE: 0

```
TOTAL Tests=21 Passed=21 Failed=0 Skipped=0 NotRun=0
FILE tests/scripts/dev-tools/link-feature-docs.Tests.ps1 tests=21 failed=0
CONTAINERS Total=1 Failed=0
PROBE POSHQC_SKIP_SCRIPT_EXECUTION=1
PROBE GH-FUNCTION=present
```

Output Summary: 21 tests, Failed=0. PROBE POSHQC_SKIP_SCRIPT_EXECUTION=1 is the fail-before signal for R1-F1 (the run script removes the variable before the run, so the suite set it and left it). PROBE GH-FUNCTION=present is the fail-before signal for R1-F5 (the process starts without a profile, so the suite defined `gh` and left it).
