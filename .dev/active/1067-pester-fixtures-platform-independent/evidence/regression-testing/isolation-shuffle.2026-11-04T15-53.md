# Isolation — seeded shuffled file order over the five change-set suites (P3-T4)

Timestamp: 2026-11-04T15-53
Command: sh SCRATCH/issue-1067-shuffle5.sh (for each seed, one fresh pwsh -NoProfile process running SCRATCH/issue-1067-run-pester.ps1 -Seed <seed> over the five change-set suites; Fisher-Yates shuffle with System.Random(seed))
EXIT_CODE: 0

## Seed 1067

Order: 1 Enter-DrmCopilotShell.Tests.ps1, 2 Test-DiscoveryHostCapability.Tests.ps1, 3 link-parent-child.Tests.ps1, 4 Test-DiscoveryHostCapability.Entry.Tests.ps1, 5 link-feature-docs.Tests.ps1 (all under tests/scripts/dev-tools/)

```
TOTAL Tests=62 Passed=62 Failed=0 Skipped=0 NotRun=0
PROBE POSHQC_SKIP_SCRIPT_EXECUTION=absent
PROBE GH-FUNCTION=absent
```

## Seed 2026

Order: 1 Test-DiscoveryHostCapability.Tests.ps1, 2 Test-DiscoveryHostCapability.Entry.Tests.ps1, 3 Enter-DrmCopilotShell.Tests.ps1, 4 link-parent-child.Tests.ps1, 5 link-feature-docs.Tests.ps1

```
TOTAL Tests=62 Passed=62 Failed=0 Skipped=0 NotRun=0
PROBE POSHQC_SKIP_SCRIPT_EXECUTION=absent
PROBE GH-FUNCTION=absent
```

## Seed 7

Order: 1 Enter-DrmCopilotShell.Tests.ps1, 2 link-feature-docs.Tests.ps1, 3 Test-DiscoveryHostCapability.Tests.ps1, 4 Test-DiscoveryHostCapability.Entry.Tests.ps1, 5 link-parent-child.Tests.ps1

```
TOTAL Tests=62 Passed=62 Failed=0 Skipped=0 NotRun=0
PROBE POSHQC_SKIP_SCRIPT_EXECUTION=absent
PROBE GH-FUNCTION=absent
```

Output Summary: three seeds (1067, 2026, 7), each 62 tests (21 + 22 + 9 + 4 + 6) with Failed=0, and both probes absent at the end of every run. Seed 7 runs link-feature-docs before link-parent-child with tests in between, so the gh removal and the variable restore are exercised with later suites present.
