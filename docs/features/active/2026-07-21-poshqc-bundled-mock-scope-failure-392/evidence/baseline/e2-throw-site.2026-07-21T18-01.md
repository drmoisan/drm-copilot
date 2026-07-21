# Experiment E2 — Throw site of the mock-scope failure (Issue #392)

Timestamp: 2026-07-21T18-01
Command: Faithful in-memory reproduction of the `Invoke-PoshQCTest` default `$InvokePester` seam (a scriptblock bound to the PoshQC module session state via `$module.NewBoundScriptBlock`, with Pester imported into module scope, no `-Global`), invoked with `Run.PassThru` so the failed test's `ErrorRecord.ScriptStackTrace` is available in-process. Throwaway script executed from the session scratchpad. Rationale for deviation: the run settings emit JUnitXml (`artifacts/pester/pester-junit.xml`), and the JUnit `<failure>` node carries only the message text, not the Pester `ScriptStackTrace`; the seam-faithful PassThru reproduction is the mechanically necessary way to obtain the stack frame.
EXIT_CODE: 0 (script ran; reproduced 26/26 mock failures in `PoshQC.Comprehensive.Tests.ps1`)
Output Summary:
- Reproduced Passed=0, Failed=26 under module-session-state hosting (identical error text).
- Identified throw site (exactly one): `Mock` at `Pester.psm1: line 14896` (the mock-setup call site), which calls `Get-MockDataForCurrentScope` where the throw is raised at `Pester.psm1: line 15230`.
- NOT the `Invoke-Mock` invocation-path caller at `line 15868`.
- Quoted top stack frames:
  ```
  at Get-MockDataForCurrentScope, ...\Pester\5.6.1\Pester.psm1: line 15230
  at Mock, ...\Pester\5.6.1\Pester.psm1: line 14896
  at <ScriptBlock>, ...\tests\scripts\powershell\PoshQC\PoshQC.Comprehensive.Tests.ps1: line 30
  at InModuleScope, ...\Pester\5.6.1\Pester.psm1: line 10709
  ```
- Interpretation: the failure occurs at `Mock` setup time (a `Mock -CommandName` call inside `InModuleScope PoshQC`), consistent with research candidate 1 (setup-path throw), because the mock plugin data table for the current scope is absent once the run is hosted in the module session state.
