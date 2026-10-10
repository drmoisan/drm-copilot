# Targeted Run: HostBootstrapWorkspace and HostBootstrap (Issue #847)

Timestamp: 2026-10-10T00-02
Task: [P2-T6]
Route substitution: per `docs/features/active/2026-10-08-powershell-aggregate-line-coverage-below-floor-847/evidence/other/execution-amendment.2026-10-09T23-50.md` (row "Targeted runs (P1-T3, P2-T6, ...)"), the in-process `Invoke-Pester` targeted run is replaced by (1) `mcp__drm-copilot__run_poshqc_test` for pass/fail, read through JRP from the junit file it writes, and (2) a CI `_poshqc.yml` dispatch on the pushed phase head for per-file coverage, because the MCP runner's installed 127-file allow-list omits the new modules. Thresholds and the JRP/CRP derivations are unchanged.
Command: `mcp__drm-copilot__run_poshqc_test` with `workspace_root` = the agent worktree and `scan_folders` = `["tests/scripts/dev-tools"]`; JRP read with `poetry run python -I <scratchpad>/junit847.py artifacts/pester/pester-junit.xml tests/scripts/dev-tools/HostTooling.Tests.ps1,tests/scripts/dev-tools/HostBootstrapWorkspace.Tests.ps1,tests/scripts/dev-tools/HostBootstrap.Tests.ps1,tests/scripts/dev-tools/HostBootstrap.Invoke.Tests.ps1 <the ten Phase 2 tokens>`
EXIT_CODE: 0
Output Summary:
- MCP call disposition: `ok: true` (EXIT_CODE 0 records the call disposition; the MCP tool returns no captured output). An earlier iteration in this phase returned `ok: false` ("Command exited with code 3") with three failing cases caused by mock bodies emitting `$null`; the mocks were corrected and the run repeated.
- Junit freshness: `artifacts/pester/pester-junit.xml` mtime 2026-10-10T00:02:06Z, written by the final call.
- JRP step 5 (whole dev-tools run): tests=527 failures=0 errors=0 disabled=2; failed testcases: 0.
- JRP steps 2-3:
  - `tests/scripts/dev-tools/HostBootstrapWorkspace.Tests.ps1` cases=31 notPassed=0 -> PASS
  - `tests/scripts/dev-tools/HostBootstrap.Tests.ps1` cases=28 notPassed=0 -> PASS
  - `tests/scripts/dev-tools/HostBootstrap.Invoke.Tests.ps1` cases=16 notPassed=0 -> PASS
  - (context) `tests/scripts/dev-tools/HostTooling.Tests.ps1` cases=19 notPassed=0 -> PASS
- JRP step 4 (ten Phase 2 tokens; every hit Passed):
  - AC06-BOOTSTRAP-DRYRUN-NOSIDEEFFECTS hits=1 PASS
  - AC06-BOOTSTRAP-NOMANIFEST-THROWS hits=1 PASS
  - AC06-BOOTSTRAP-PRECONDITION-ERRORS hits=1 PASS
  - AC06-RUNONCE-SET-APPLY-AND-RESUME hits=1 PASS
  - AC06-RUNONCE-NOT-SET-WITHOUT-BOTH hits=2 PASS
  - AC06-RUNONCE-CLEARED-AFTER-APPLY hits=1 PASS
  - AC06-POETRY-PROJECT-INSTALL-WARNS hits=1 PASS
  - AC06-VERIFY-SCRIPT-EXITCODE-IGNORED hits=1 PASS
  - AC06-POETRY-PIP-FALLBACK hits=1 PASS
  - AC06-NONPOETRY-RETHROW hits=1 PASS
- Derived EXIT_CODE per P1-T3 rule: 0 for the pass/fail part (failures=0, errors=0).
- CRP per-file `scripts/dev-tools/HostBootstrapWorkspace.psm1`: PENDING CI.
- CRP per-file `scripts/dev-tools/HostBootstrap.psm1`: PENDING CI.
- (context) CRP per-file `scripts/dev-tools/HostTooling.psm1`: PENDING CI.
- This task stays unchecked until the orchestrator-supplied CI coverage XML yields passing CRP rows (>= 85%) for both Phase 2 modules.

## Notes

- HostBootstrap size contingency applied (plan Test design rules): with `Invoke-BootstrapHost` added, `HostBootstrap.psm1` would have exceeded 500 lines (401 lines before the orchestrator's ~165 lines). The five process wrappers `Invoke-HostBootstrapWinget`, `Invoke-HostBootstrapNpm`, `Invoke-HostBootstrapWsl`, `Invoke-HostBootstrapPoetry`, and `Invoke-HostBootstrapVerifyScript` moved to `scripts/dev-tools/HostBootstrapWorkspace.psm1` (now eleven exports; `HostBootstrap.psm1` exports eleven), and their tests are in `tests/scripts/dev-tools/HostBootstrapWorkspace.Tests.ps1`. Final sizes: HostBootstrap.psm1 463 lines, HostBootstrapWorkspace.psm1 290 lines.
- MCP formatter (`mcp__drm-copilot__run_poshqc_format`, scan folders `scripts/dev-tools`, `tests/scripts/dev-tools`) left all seven Phase 1-2 files byte-identical (git hash-object before and after equal). MCP analyzer (`mcp__drm-copilot__run_poshqc_analyze`, same folders) returned `ok: true`; analyzer findings are confirmed from CI only.
