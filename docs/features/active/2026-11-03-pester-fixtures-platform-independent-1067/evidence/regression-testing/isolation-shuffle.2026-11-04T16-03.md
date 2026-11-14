# Isolation — seeded shuffled file order, restart pass (P3-T4)

Timestamp: 2026-11-04T16-03
Command: sh SCRATCH/issue-1067-shuffle5.sh (for each seed, one fresh pwsh -NoProfile process running SCRATCH/issue-1067-run-pester.ps1 -Seed <seed> over the five change-set suites)
EXIT_CODE: 0

All files are under tests/scripts/dev-tools/.

| Seed | File order | Result | POSHQC_SKIP_SCRIPT_EXECUTION | GH-FUNCTION |
|---|---|---|---|---|
| 1067 | Enter-DrmCopilotShell, Test-DiscoveryHostCapability, link-parent-child, Test-DiscoveryHostCapability.Entry, link-feature-docs | Tests=62 Passed=62 Failed=0 | absent | absent |
| 2026 | Test-DiscoveryHostCapability, Test-DiscoveryHostCapability.Entry, Enter-DrmCopilotShell, link-parent-child, link-feature-docs | Tests=62 Passed=62 Failed=0 | absent | absent |
| 7 | Enter-DrmCopilotShell, link-feature-docs, Test-DiscoveryHostCapability, Test-DiscoveryHostCapability.Entry, link-parent-child | Tests=62 Passed=62 Failed=0 | absent | absent |

(Each name stands for `<name>.Tests.ps1`.)

Output Summary: seeds 1067, 2026, and 7 each pass 62 of 62 with Failed=0, and both probes are absent at the end of every run; orders and results are identical to the first pass (`isolation-shuffle.2026-11-04T15-53.md`).
