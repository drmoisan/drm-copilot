# Verification — Test-DiscoveryHostCapability.Entry.Tests.ps1 alone after the escape (P2-T5)

Timestamp: 2026-11-04T15-50
Command: sh SCRATCH/issue-1067-runpaths.sh after-dhe tests/scripts/dev-tools/Test-DiscoveryHostCapability.Entry.Tests.ps1 (fresh pwsh -NoProfile process running SCRATCH/issue-1067-run-pester.ps1)
EXIT_CODE: 0

```
TOTAL Tests=4 Passed=4 Failed=0 Skipped=0 NotRun=0
FILE tests/scripts/dev-tools/Test-DiscoveryHostCapability.Entry.Tests.ps1 tests=4 failed=0
CONTAINERS Total=1 Failed=0
PROBE POSHQC_SKIP_SCRIPT_EXECUTION=absent
PROBE GH-FUNCTION=absent
```

Output Summary: Tests=4 (equal to P0-T6), Failed=0; the escaped ParameterFilter still matches exactly once (`Should -Invoke Test-Path -Times 1 -Exactly` passes).
