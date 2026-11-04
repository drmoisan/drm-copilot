---
name: pester-junit-sources-on-failing-hosts
description: Where Pester JUnit/counts can be read when the host has pre-existing failures (merged parallel JUnit absent, built-in export breaks on 0x1B, keys unstable)
metadata:
  type: project
---

On a host with pre-existing Pester failures (e.g. Linux Codespace, #1067), three plan assumptions fail (observed 2026-11-03, issue #1066 preflight revision):

- `Invoke-PoshQCParallelTest` writes no merged `artifacts/pester/pester-junit.xml`: `Invoke-PoshQCParallelMerge` skips the merge when any shard exits non-zero, and `Run.Exit = $true` in `pester.runsettings.psd1` makes a shard with failures exit non-zero. Read per-shard `artifacts/pester/parallel/shard-<i>/pester-junit.xml` instead.
- `Invoke-PoshQCParallelTest` has no scan-folder parameter (only `-Root`, `-WorkerCount` and seams); shards scan `config/poshqc-scan.json` folders, which in practice means `tests/scripts`. Do not plan `-ScanFolders` on it (seen 2026-11-04, #1034).
- Pester's built-in JUnit export truncates when a failure message holds 0x1B. Write JUnit from the PassThru result (Invoke-PoshQCTest accepts an `-InvokePester` seam for this).
- Failing-test keys are unstable: a failed `BeforeAll` leaves template names unexpanded and keys repeat. Compare per-container counts (tests, failed, failed blocks, failed container), not key sets.

**Why:** each one made a planned acceptance condition unsatisfiable or noise-driven and cost a preflight round.
**How to apply:** when a plan compares Pester runs on a non-CI host, specify per-container count profiles and the JUnit source explicitly; treat keys as information only.
