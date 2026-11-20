# Correction: Seeded Shuffled Suite Run (issue #935)

Timestamp: 2026-10-16T22-30
Corrects: `evidence/qa-gates/shuffled-suite-run.2026-10-16T20-48.md` (left unedited)
Source: cycle 4 preflight round 3 on the r4 branch (defect D8), persisted as SCRATCH issue-935-r4-preflight.md

## What the earlier artifact claimed

That the seed 935 fixed the container order passed to the runner, so the 13 suites ran in the shuffled order listed.

## What actually happened

`mcp__drm-copilot__run_poshqc_test` does not preserve the order of `scan_folders`:

- `scripts/powershell/PoshQC/PoshQC.FileDiscovery.psm1` line 137 sorts the scan folders (`Sort-Object -Unique`).
- `scripts/powershell/PoshQC/PoshQC.Testing.psm1` line 257 sorts the test files (`Sort-Object -Property FullName -Stable`).
- The JUnit file written by that run lists the 13 containers in full-path order (ManifestBranch first), not in the seeded order (TargetResolution first).

The suites therefore ran in alphabetical full-path order. No order variation took place.

## What remains valid

- All 13 suites ran together in one Pester run and passed: 742 testcases, 742 passed, 0 failed or skipped.
- The per-suite counts and the split equations recorded in the earlier artifact are correct.

## Replacement check

Cycle 4 of the r4 follow-on PR replaces the seeded shuffle with a co-run and isolation check (task P4-T4 of `remediation-plan.2026-10-16T20-56.md`): the touched and consumer suites run together, then each suite that gains rows runs alone, and the per-suite counts must match. A true order shuffle is not available through the PoshQC MCP runner.
