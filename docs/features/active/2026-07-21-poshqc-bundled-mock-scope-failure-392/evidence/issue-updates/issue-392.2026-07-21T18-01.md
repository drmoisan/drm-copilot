# Issue #392 Update Mirror

Timestamp: 2026-07-21T18-01

POSTING BLOCKED
Reason: The executor did not post to GitHub. No posting instruction was given, and issue/PR posting is handled by the PR-author / orchestration workflow after review. This mirror records the exact resolution text for that step.

PostedAs: unknown (not posted)

---

## Resolution summary (issue #392: PoshQC bundled Pester mock-scope failure)

Root cause: the bundled entry path imports the PoshQC module and calls `Invoke-PoshQCTest -> Invoke-Pester` from within the module's session state. `Invoke-Pester` captures its caller's session state, so every discovered test container executed inside the imported PoshQC module's session state. When the per-file `BeforeAll` guards removed the pre-imported (different-path) bundled instance mid-run, the run's hosting module was orphaned, and `Mock` setup inside `InModuleScope PoshQC` threw `RuntimeException: Mock data are not setup for this scope, what happened?` (throw site confirmed at `Pester.psm1:14896` -> `Get-MockDataForCurrentScope` line 15230). Experiments E1a/E1b isolated module-session-state hosting as the necessary and sufficient condition; E3 confirmed exactly one PoshQC instance is loaded at container run time (not an InModuleScope multi-instance ambiguity).

Fix: host the Pester run in the global session state at the `Invoke-PoshQCTest` seam (`PoshQC.Testing.psm1`):
- `$EnsureModule` default now imports Pester with `-Global`.
- `$InvokePester` default installs an unbound global trampoline function (`function:global:Invoke-PoshQCPesterRun`) built via `[scriptblock]::Create(...)`, invokes it, and removes it in `finally` via `Remove-Item -Path 'Function:\Invoke-PoshQCPesterRun'`. The Pester PassThru result is returned unmodified; no global state leaks (verified `Test-Path` = False post-run).
- The bundled mirror `extensions/drm-copilot/resources/powershell/PoshQC/PoshQC.Testing.psm1` is byte-identical. `pester.runsettings.psd1` (and mirror) add `PoshQC.Testing.psm1` to `CodeCoverage.Path`.
- New unit tests `tests/scripts/powershell/PoshQC/PoshQC.TestingSeamDefaults.Tests.ps1` cover the changed seam defaults. Three Koverage-copy tests in `PoshQC.Comprehensive.Tests.ps1` received an injected `-InvokePester` stub so their module-scope `Mock Invoke-Pester` still intercepts (bypassing the trampoline in those unit tests only).

Verification evidence (all under `docs/features/active/2026-07-21-poshqc-bundled-mock-scope-failure-392/evidence/`):
- Fail-before: `regression-testing/fail-before.e4-bundled.2026-07-21T18-01.md` (bundled path: 31 failed).
- Pass-after direct: `regression-testing/pass-after.direct.2026-07-21T18-01.md` (0 failed).
- Pass-after bundled narrowed: `regression-testing/pass-after.bundled-narrowed.2026-07-21T18-01.md` (0 failed; no trampoline leak).
- Pass-after full bundled suite: `regression-testing/pass-after.bundled-full.2026-07-21T18-01.md` (1341 tests, 0 failed).
- Python parity: `regression-testing/pass-after.python-parity.2026-07-21T18-01.md`.
