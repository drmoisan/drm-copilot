---
name: poshqc-hosted-run-mock-modulename-miss
description: Under Invoke-PoshQCTest-hosted runs (CI shards, Invoke-PoshQCParallelTest) a Mock -ModuleName PoshQC from test code misses the re-imported PoshQC instance; plain Invoke-Pester runs pass
metadata:
  type: project
---

In PoshQC suites, `Mock -CommandName X -ModuleName PoshQC` created from test code is not honored when the run is hosted by `Invoke-PoshQCTest` with its default `-InvokePester` trampoline (CI shards, `Invoke-PoshQCParallelTest`). The trampoline calls an unbound script block from inside the module, so test bodies run in the host PoshQC module session state (`$ExecutionContext.SessionState.Module` reports PoshQC). Calling through `(Get-Module PoshQC).ExportedCommands[...]` does not help. A plain Invoke-Pester run, and an `Invoke-PoshQCTest` run with a script-scope `-InvokePester` seam, both pass, so single-process and coverage runs hide it. Observed on issue 1067, 2026-11-04.

**Why:** a mocked `New-Item` fell through and created `/repo/artifacts` for real (permission denied on Linux; on Windows it would silently write `C:\repo`). It cost a full P6-T4..T13 loop restart.

**How to apply:** when a PoshQC test mocks a command used inside `Invoke-PoshQCTest`, put the whole `It` body in `InModuleScope PoshQC { Mock ...; call; Should -Invoke ... }` without `-ModuleName`, the form `PoshQC.TestingInvokeConfigPaths.Tests.ps1` uses. Verify with a run hosted by `Invoke-PoshQCTest` and the default seam, not only with a plain Invoke-Pester run. Related: [[poshqc-passthru-and-global-state-noise]], [[linux-codespace-pester-host-failures]].
