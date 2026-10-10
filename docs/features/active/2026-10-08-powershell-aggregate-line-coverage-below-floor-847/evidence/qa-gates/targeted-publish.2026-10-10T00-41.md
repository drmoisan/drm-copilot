# Targeted Run: SideloadedExtensionPublish (Issue #847)

Timestamp: 2026-10-10T00-41
Task: [P4-T4]
Route substitution: per `docs/features/active/2026-10-08-powershell-aggregate-line-coverage-below-floor-847/evidence/other/execution-amendment.2026-10-09T23-50.md` (row "Targeted runs (P1-T3, P2-T6, P3-T4, P4-T4, ...)"), the in-process `Invoke-Pester` targeted run is replaced by (1) `mcp__drm-copilot__run_poshqc_test` for pass/fail, read through JRP from the junit file it writes, and (2) a CI `_poshqc.yml` dispatch on the pushed phase head for per-file coverage, because the MCP runner's installed 127-file allow-list omits the new modules. Thresholds and the JRP/CRP derivations are unchanged.
Command: `mcp__drm-copilot__run_poshqc_test` with `workspace_root` = the agent worktree and `scan_folders` = `["tests/scripts/dev-tools"]`; JRP read with `poetry run python -I <scratchpad>/junit847.py artifacts/pester/pester-junit.xml tests/scripts/dev-tools/SideloadedExtensionPublish.Tests.ps1,tests/scripts/dev-tools/SideloadedExtensionPublish.Invoke.Tests.ps1,tests/scripts/dev-tools/publish-sideloaded-extension.Tests.ps1,tests/scripts/dev-tools/HostVerification.Tests.ps1,tests/scripts/dev-tools/HostVerification.Invoke.Tests.ps1,tests/scripts/dev-tools/HostTooling.Tests.ps1,tests/scripts/dev-tools/HostBootstrapWorkspace.Tests.ps1,tests/scripts/dev-tools/HostBootstrap.Tests.ps1,tests/scripts/dev-tools/HostBootstrap.Invoke.Tests.ps1 AC06-EPERM-RETRY-LIMIT,AC06-EPERM-BACKOFF,AC06-NONEPERM-RETHROW,AC06-PUBLISH-FORCE-CLEANUP,AC06-PUBLISH-STEP-ORDER,AC06-PUBLISH-SKIP-SWITCHES,AC06-PUBLISH-VSIX-MISSING-THROWS,AC06-PUBLISH-CODECOMMAND-NOTFOUND-THROWS`
EXIT_CODE: 0
Output Summary:
- MCP call disposition: `ok: true` (EXIT_CODE 0 records the call disposition; the MCP tool returns no captured output). The suites also passed on the first test iteration; the final run below follows the analyzer correction described in Notes.
- Junit freshness: `artifacts/pester/pester-junit.xml` mtime 2026-10-10T00:40:51Z, written by the final call.
- JRP step 5 (whole dev-tools run): tests=599 failures=0 errors=0 disabled=2; failed testcases: 0.
- JRP steps 2-3:
  - `tests/scripts/dev-tools/SideloadedExtensionPublish.Tests.ps1` cases=27 notPassed=0 -> PASS
  - `tests/scripts/dev-tools/SideloadedExtensionPublish.Invoke.Tests.ps1` cases=13 notPassed=0 -> PASS
  - (context) publish-sideloaded-extension.Tests.ps1 cases=7 (unchanged until P5-T7), HostVerification.Tests.ps1 cases=22, HostVerification.Invoke.Tests.ps1 cases=10, HostTooling.Tests.ps1 cases=19, HostBootstrapWorkspace.Tests.ps1 cases=31, HostBootstrap.Tests.ps1 cases=28, HostBootstrap.Invoke.Tests.ps1 cases=16; all notPassed=0 -> PASS
- JRP step 4 (eight Phase 4 tokens; every hit Passed):
  - AC06-EPERM-RETRY-LIMIT hits=1 PASS
  - AC06-EPERM-BACKOFF hits=1 PASS
  - AC06-NONEPERM-RETHROW hits=1 PASS
  - AC06-PUBLISH-FORCE-CLEANUP hits=1 PASS
  - AC06-PUBLISH-STEP-ORDER hits=1 PASS
  - AC06-PUBLISH-SKIP-SWITCHES hits=3 PASS
  - AC06-PUBLISH-VSIX-MISSING-THROWS hits=1 PASS
  - AC06-PUBLISH-CODECOMMAND-NOTFOUND-THROWS hits=1 PASS
- Derived EXIT_CODE per P1-T3 rule: 0 for the pass/fail part (failures=0, errors=0).
- Coverage source (amendment route): CI run 38010605885 (`workflow_dispatch` of `_poshqc.yml` on head `e0a6cd13aa95e7ec40254906c78391ecd55b4a5e`, the pushed Phase 4 head; checkout commit confirmed in `artifacts/ci/run-38010605885/poshqc-job.log`), job `PowerShell QC` 114089470639, conclusion success. Artifact downloaded to `artifacts/ci/run-38010605885/` (`powershell-coverage.xml`, `pester-junit.xml`, `poshqc-job.log`); CRP/JRP reduction recorded in `artifacts/ci/run-38010605885/reduction.txt` (ROOT `D:/a/drm-copilot/drm-copilot`).
- CRP per-file `scripts/dev-tools/SideloadedExtensionPublish.psm1`: covered=135 missed=4 total=139 pct=97.12 required=119 gap=0 -> PASS (100*135 >= 85*139).
- (information only) CRP per-file `scripts/dev-tools/vscode-cli.helpers.ps1`: covered=15 missed=12 total=27 pct=55.56 (not gated; excluded path, unchanged by this plan).
- CI JRP cross-check (same run): `SideloadedExtensionPublish.Tests.ps1` cases=27 notPassed=0 PASS; `SideloadedExtensionPublish.Invoke.Tests.ps1` cases=13 notPassed=0 PASS; the eight Phase 4 tokens PASS; whole-run tests=6700 failures=0 errors=0 disabled=10.
- CI analyzer: `poshqc-job.log` line 843 `PSScriptAnalyzer passed: no findings under D:\a\drm-copilot\drm-copilot`.
- Verdict (completed 2026-10-10T01-18): PASS. Derived EXIT_CODE 0; JRP steps 2-3 pass for both files; JRP step 4 passes for the eight Phase 4 tokens; CRP per-file passes for `SideloadedExtensionPublish.psm1`.

## Notes

- Analyzer correction: the first `mcp__drm-copilot__run_poshqc_analyze` call after the module was written returned `ok: false` ("PSScriptAnalyzer reported 1 issue(s)."). The MCP tool does not report the rule name, so the finding was located by bisecting the module content with repeated analyzer calls (scan folder `scripts/dev-tools`; the `tests/scripts/dev-tools` folder was clean). The finding followed `return $RepoRoot` in `Resolve-ExtensionProjectRoot`: returning a `[string]`-typed parameter from a `[CmdletBinding()]` function with no `[OutputType()]` was flagged, while returning untyped locals was not. This is consistent with PSUseOutputTypeCorrectly (Information severity, which the repository settings gate). Adding `[OutputType([string])]` to `Resolve-ExtensionProjectRoot` cleared it; behavior is unchanged. A speculative `[OutputType([string])]` on `Invoke-SideloadedExtensionPublish` was removed during the investigation to match the original script. The final analyzer call over both folders returned `ok: true`; CI confirmation is pending.
- MCP formatter (`mcp__drm-copilot__run_poshqc_format`, scan folders `scripts/dev-tools`, `tests/scripts/dev-tools`) left the three Phase 4 files byte-identical on the final content (`git hash-object` before and after: `80fa1ee5`, `dbf01ba5`, `bb19b47f`).
- Sizes: `SideloadedExtensionPublish.psm1` 456 lines, `SideloadedExtensionPublish.Tests.ps1` 372 lines, `SideloadedExtensionPublish.Invoke.Tests.ps1` 191 lines; all LF (zero CR bytes).
- Test recorder design: the step-order list and the npm attempt counter are module-scope objects created with `InModuleScope SideloadedExtensionPublish`, wrapped in a `[pscustomobject]` that the test scope also references, so the `-ModuleName` mock bodies append to the same object whichever session state they run in; values are read back with `InModuleScope`. The `-Sleep` recorder is a scriptblock created inside `InModuleScope`, so it writes to a module-scope list.
