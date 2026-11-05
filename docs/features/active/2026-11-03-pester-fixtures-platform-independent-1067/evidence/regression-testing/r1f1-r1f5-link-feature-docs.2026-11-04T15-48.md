# Pass-after — link-feature-docs.Tests.ps1 alone (P1-T4)

Timestamp: 2026-11-04T15-48
Command: sh SCRATCH/issue-1067-runpaths.sh after-lfd tests/scripts/dev-tools/link-feature-docs.Tests.ps1 (fresh pwsh -NoProfile process running SCRATCH/issue-1067-run-pester.ps1)
EXIT_CODE: 0

```
TOTAL Tests=21 Passed=21 Failed=0 Skipped=0 NotRun=0
FILE tests/scripts/dev-tools/link-feature-docs.Tests.ps1 tests=21 failed=0
CONTAINERS Total=1 Failed=0
PROBE POSHQC_SKIP_SCRIPT_EXECUTION=absent
PROBE GH-FUNCTION=absent
```

## Execution note (first attempt)

The first run after the `[P1-T2]` edit (2026-11-04T15-47) reported `PROBE POSHQC_SKIP_SCRIPT_EXECUTION=absent` and `PROBE GH-FUNCTION=present`. A probe (`SCRATCH/issue-1067-remove-probe.ps1`) showed that `Remove-Item -Path Function:\global:gh -Force -ErrorAction SilentlyContinue` leaves the global function defined and records no error, while `Remove-Item -Path Function:\gh` removes it (`AFTER-QUALIFIED=True`, `AFTER-UNQUALIFIED=False`). The removal branch of the `AfterAll` was changed to the unqualified path, which is the form the R1-F5 reference pattern uses (`Remove-Item -Path Function:\prompt`), with a one-line comment stating why. The restore branch keeps `Set-Item -Path Function:\global:gh`, which `[P1-T7]` exercises. The run above is the re-run after that correction.

Output Summary: Tests=21 (equal to P0-T3), Failed=0, PROBE POSHQC_SKIP_SCRIPT_EXECUTION=absent and PROBE GH-FUNCTION=absent; pass-after for R1-F1 and R1-F5 against the P0-T3 fail-before (=1 and present).
