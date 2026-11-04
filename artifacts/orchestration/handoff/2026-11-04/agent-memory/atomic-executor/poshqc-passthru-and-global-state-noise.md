---
name: poshqc-passthru-and-global-state-noise
description: Invoke-PoshQCTest with a custom -InvokePester returns no result unless Run.PassThru is set; nested-Pester global-state diffs always show Pester's LASTEXITCODE=0 and module auto-load functions
metadata:
  type: project
---

`scripts/powershell/PoshQC/settings/pester.runsettings.psd1` leaves `Run.PassThru` false, and `Invoke-PoshQCTest` tests the option object (always truthy) rather than its value, so a custom `-InvokePester` seam gets a null result after a full 20-minute run. Set `$Config.Run.PassThru = $true` inside the seam before the first long run.

`Invoke-PoshQCTest` never returns the result object to its caller (it only replays a summary), and Pester emits none when its JUnit export throws (TestResult runs in the End plugin step; the catch path exits -1). A plan count source of "the result object when JUnit is truncated" needs a seam with PassThru true, Exit false and TestResult disabled; shards (no seam) fall back to the `Tests Passed:` line of shard.log (issue 1034 preflight, 2026-11-04).

Global-state diffs around a nested `Invoke-Pester` (seen on issue #1066, 2026-11-03):
- Pester itself leaves `$global:LASTEXITCODE = 0`, so a LASTEXITCODE restore cannot be distinguished by a before/after diff.
- `Mock Expand-Archive` auto-loads Microsoft.PowerShell.Archive, adding `Compress-Archive`/`Expand-Archive` to `Function:`; TestHelpers.ps1 defines `function global:Import-ScriptFunction`.

**Why:** a plan acceptance "function names unchanged" was unsatisfiable under a PATH-only fix design and stopped execution at P2-T4.
**How to apply:** in preflight, flag any "no function/global state change" acceptance over a suite that mocks module commands or dot-sources TestHelpers.ps1. Also: `pwsh -File` does not split comma lists into `[string[]]` params, and its top-level script variables are global.
