# Targeted Run: HostVerification (Issue #847)

Timestamp: 2026-10-10T00-21
Task: [P3-T4]
Route substitution: per `docs/features/active/2026-10-08-powershell-aggregate-line-coverage-below-floor-847/evidence/other/execution-amendment.2026-10-09T23-50.md` (row "Targeted runs (P1-T3, P2-T6, P3-T4, ...)"), the in-process `Invoke-Pester` targeted run is replaced by (1) `mcp__drm-copilot__run_poshqc_test` for pass/fail, read through JRP from the junit file it writes, and (2) a CI `_poshqc.yml` dispatch on the pushed phase head for per-file coverage, because the MCP runner's installed 127-file allow-list omits the new modules. Thresholds and the JRP/CRP derivations are unchanged.
Command: `mcp__drm-copilot__run_poshqc_test` with `workspace_root` = the agent worktree and `scan_folders` = `["tests/scripts/dev-tools"]`; JRP read with `poetry run python -I <scratchpad>/junit847.py artifacts/pester/pester-junit.xml tests/scripts/dev-tools/HostVerification.Tests.ps1,tests/scripts/dev-tools/HostVerification.Invoke.Tests.ps1,tests/scripts/dev-tools/HostTooling.Tests.ps1,tests/scripts/dev-tools/HostBootstrapWorkspace.Tests.ps1,tests/scripts/dev-tools/HostBootstrap.Tests.ps1,tests/scripts/dev-tools/HostBootstrap.Invoke.Tests.ps1 AC06-VERIFY-NOMANIFEST-THROWS,AC06-VERIFY-SECTION-ORDER,AC06-VERIFY-EXIT-BOUNDARY`
EXIT_CODE: 0
Output Summary:
- MCP call disposition: `ok: true` on the first iteration (EXIT_CODE 0 records the call disposition; the MCP tool returns no captured output).
- Junit freshness: `artifacts/pester/pester-junit.xml` mtime 2026-10-10T00:19:55Z, written by this call.
- JRP step 5 (whole dev-tools run): tests=559 failures=0 errors=0 disabled=2; failed testcases: 0.
- JRP steps 2-3:
  - `tests/scripts/dev-tools/HostVerification.Tests.ps1` cases=22 notPassed=0 -> PASS
  - `tests/scripts/dev-tools/HostVerification.Invoke.Tests.ps1` cases=10 notPassed=0 -> PASS
  - (context) HostTooling.Tests.ps1 cases=19, HostBootstrapWorkspace.Tests.ps1 cases=31, HostBootstrap.Tests.ps1 cases=28, HostBootstrap.Invoke.Tests.ps1 cases=16; all notPassed=0 -> PASS
- JRP step 4 (three Phase 3 tokens; every hit Passed):
  - AC06-VERIFY-NOMANIFEST-THROWS hits=1 PASS
  - AC06-VERIFY-SECTION-ORDER hits=1 PASS
  - AC06-VERIFY-EXIT-BOUNDARY hits=1 PASS
- Derived EXIT_CODE per P1-T3 rule: 0 for the pass/fail part (failures=0, errors=0).
- CRP per-file `scripts/dev-tools/HostVerification.psm1`: PENDING CI.
- (context) CRP per-file `scripts/dev-tools/HostTooling.psm1`: PENDING CI for this head (Phase 1 head value 94.74% recorded in `targeted-hosttooling.2026-10-09T23-51.md`).
- This task stays unchecked until the orchestrator-supplied CI coverage XML yields a passing CRP row (>= 85%) for `HostVerification.psm1`.

## Notes

- MCP formatter (`mcp__drm-copilot__run_poshqc_format`, scan folders `scripts/dev-tools`, `tests/scripts/dev-tools`) left the three Phase 3 files byte-identical (`git hash-object` before and after: `fb7643d8`, `dc69766e`, `ea0d65f9`). MCP analyzer (same folders) returned `ok: true`; analyzer findings are confirmed from CI only.
- Sizes: `HostVerification.psm1` 392 lines, `HostVerification.Tests.ps1` 359 lines, `HostVerification.Invoke.Tests.ps1` 164 lines; all LF (zero CR bytes).
