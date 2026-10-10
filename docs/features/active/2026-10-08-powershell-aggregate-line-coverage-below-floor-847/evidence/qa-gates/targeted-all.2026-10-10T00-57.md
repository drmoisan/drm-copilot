# Targeted Run: All TEST11 Suites (Issue #847)

Timestamp: 2026-10-10T00-57
Task: [P5-T8]
Route substitution: per `docs/features/active/2026-10-08-powershell-aggregate-line-coverage-below-floor-847/evidence/other/execution-amendment.2026-10-09T23-50.md` (row "Targeted runs (P1-T3, P2-T6, P3-T4, P4-T4, P5-T8)"), the in-process `Invoke-Pester` targeted run is replaced by (1) `mcp__drm-copilot__run_poshqc_test` for pass/fail, read through JRP from the junit file it writes, and (2) a CI `_poshqc.yml` dispatch on the pushed phase head for per-file coverage, because the MCP runner's installed 127-file allow-list omits the new modules. Thresholds and the JRP/CRP derivations are unchanged.
Command: `mcp__drm-copilot__run_poshqc_test` with `workspace_root` = the agent worktree and `scan_folders` = `["tests/scripts/dev-tools"]`; JRP read with `poetry run python -I <scratchpad>/junit847.py artifacts/pester/pester-junit.xml <the eleven TEST11 paths, comma-separated> <the 32 AC tokens, comma-separated>`
EXIT_CODE: 0
Output Summary:
- MCP call disposition: `ok: true` (EXIT_CODE 0 records the call disposition; the MCP tool returns no captured output). An earlier iteration in this phase returned `ok: false` ("Command exited with code 6") with six failing cases in `publish-sideloaded-extension.Tests.ps1`: the test-scope mock body of `Invoke-SideloadedExtensionPublish` read `$script:fixtureVsixPath`, which resolves in the entry script's scope under StrictMode. The mock body was changed to an inline literal and the loop restarted at format.
- Loop for the passing iteration: `mcp__drm-copilot__run_poshqc_format` (scan folders `scripts/dev-tools`, `tests/scripts/dev-tools`) left the six Phase 5 files byte-identical (`git hash-object` before and after: `2a6d98e5` bootstrap-host.ps1, `0449280a` verify-host.ps1, `ac8def3e` publish-sideloaded-extension.ps1, `fce14b43` bootstrap-host.Tests.ps1, `270eb7e0` verify-host.Tests.ps1, `53b1665a` publish-sideloaded-extension.Tests.ps1); `mcp__drm-copilot__run_poshqc_analyze` (same folders) returned `ok: true`, so neither the PSAvoidGlobalVars fallback nor the PSShouldProcess contingency was triggered; `mcp__drm-copilot__run_poshqc_test` returned `ok: true`.
- Junit freshness: `artifacts/pester/pester-junit.xml` mtime 1791593842 (2026-10-10T00:57Z), written by the passing call.
- JRP step 5 (whole dev-tools run): tests=608 failures=0 errors=0 disabled=2; failed testcases: 0.
- JRP steps 2-3 (all eleven TEST11 files):
  - `tests/scripts/dev-tools/HostTooling.Tests.ps1` cases=19 notPassed=0 -> PASS
  - `tests/scripts/dev-tools/HostBootstrapWorkspace.Tests.ps1` cases=31 notPassed=0 -> PASS
  - `tests/scripts/dev-tools/HostBootstrap.Tests.ps1` cases=28 notPassed=0 -> PASS
  - `tests/scripts/dev-tools/HostBootstrap.Invoke.Tests.ps1` cases=16 notPassed=0 -> PASS
  - `tests/scripts/dev-tools/HostVerification.Tests.ps1` cases=22 notPassed=0 -> PASS
  - `tests/scripts/dev-tools/HostVerification.Invoke.Tests.ps1` cases=10 notPassed=0 -> PASS
  - `tests/scripts/dev-tools/SideloadedExtensionPublish.Tests.ps1` cases=27 notPassed=0 -> PASS
  - `tests/scripts/dev-tools/SideloadedExtensionPublish.Invoke.Tests.ps1` cases=13 notPassed=0 -> PASS
  - `tests/scripts/dev-tools/bootstrap-host.Tests.ps1` cases=5 notPassed=0 -> PASS
  - `tests/scripts/dev-tools/verify-host.Tests.ps1` cases=3 notPassed=0 -> PASS
  - `tests/scripts/dev-tools/publish-sideloaded-extension.Tests.ps1` cases=8 notPassed=0 -> PASS
- JRP step 4 (all 32 tokens; every hit Passed):
  - AC05-BOOTSTRAP-DRYRUN-EXIT0 hits=1 PASS
  - AC05-BOOTSTRAP-NONWINDOWS-EXIT1 hits=1 PASS
  - AC05-BOOTSTRAP-NOWINGET-EXIT1 hits=1 PASS
  - AC05-VERIFY-PASS-EXIT0 hits=1 PASS
  - AC05-VERIFY-ONEFAIL-EXIT1 hits=1 PASS
  - AC05-VERIFY-NOMANIFEST-EXIT1 hits=1 PASS
  - AC05-PUBLISH-VSIX-OUTPUT hits=1 PASS
  - AC05-PUBLISH-WHATIF-NOSEAMS hits=1 PASS
  - AC05-PUBLISH-CODECOMMAND-BOUNDEMPTY hits=1 PASS
  - AC05-PUBLISH-CODECOMMAND-UNBOUND hits=1 PASS
  - AC05-PUBLISH-CONFIRM-FORWARDED hits=1 PASS
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
  - AC06-VERIFY-NOMANIFEST-THROWS hits=1 PASS
  - AC06-VERIFY-SECTION-ORDER hits=1 PASS
  - AC06-VERIFY-EXIT-BOUNDARY hits=1 PASS
  - AC06-EPERM-RETRY-LIMIT hits=1 PASS
  - AC06-EPERM-BACKOFF hits=1 PASS
  - AC06-NONEPERM-RETHROW hits=1 PASS
  - AC06-PUBLISH-FORCE-CLEANUP hits=1 PASS
  - AC06-PUBLISH-STEP-ORDER hits=1 PASS
  - AC06-PUBLISH-SKIP-SWITCHES hits=3 PASS
  - AC06-PUBLISH-VSIX-MISSING-THROWS hits=1 PASS
  - AC06-PUBLISH-CODECOMMAND-NOTFOUND-THROWS hits=1 PASS
- Derived EXIT_CODE per P1-T3 rule: 0 for the pass/fail part (failures=0, errors=0).
- Coverage source (amendment route): CI run 38011932558 (`workflow_dispatch` of `_poshqc.yml` on head `1c3d1a4c6d0cc741081f45511c3ab6c5adf2d184`, which contains the Phase 5 commit `19d151f98` plus only the Phase 6 docs commit; checkout commit confirmed in `artifacts/ci/run-38011932558/poshqc-job.log`), job `PowerShell QC` 114093650487, conclusion success. Artifact downloaded to `artifacts/ci/run-38011932558/`; reduction in `artifacts/ci/run-38011932558/reduction.txt` (ROOT `D:/a/drm-copilot/drm-copilot`).
- CRP per-file (D = `scripts/dev-tools`):
  - `HostTooling.psm1` covered=36 missed=2 total=38 pct=94.74 -> PASS
  - `HostBootstrapWorkspace.psm1` covered=70 missed=0 total=70 pct=100.0 -> PASS
  - `HostBootstrap.psm1` covered=155 missed=0 total=155 pct=100.0 -> PASS
  - `HostVerification.psm1` covered=149 missed=0 total=149 pct=100.0 -> PASS
  - `SideloadedExtensionPublish.psm1` covered=136 missed=3 total=139 pct=97.84 -> PASS
  - `bootstrap-host.ps1` covered=7 missed=0 total=7 pct=100.0 -> PASS
  - `verify-host.ps1` covered=7 missed=0 total=7 pct=100.0 -> PASS
  - `publish-sideloaded-extension.ps1` covered=24 missed=0 total=24 pct=100.0 -> PASS
- (information) CRP row `vscode-cli.helpers.ps1`: covered=15 missed=12 total=27 pct=55.56 (not gated; excluded path).
- CI JRP cross-check (same run): all eleven TEST11 suites PASS with the case counts listed above; all 32 tokens PASS; whole-run tests=6709 failures=0 errors=0 disabled=10.
- Verdict (completed 2026-10-10T01-18): PASS. Derived EXIT_CODE 0; JRP steps 2-3 pass for all eleven files; JRP step 4 passes for all 32 tokens; CRP per-file passes for each PROD8 file. AC-03 is decided by P7-T5.

## Notes

- Sizes (all LF, zero CR bytes): `bootstrap-host.ps1` 35 lines, `verify-host.ps1` 19 lines, `publish-sideloaded-extension.ps1` 83 lines, `bootstrap-host.Tests.ps1` 102 lines, `verify-host.Tests.ps1` 97 lines, `publish-sideloaded-extension.Tests.ps1` 140 lines.
- Forbidden-literal search over the three new or rewritten entry test files (`git grep --untracked -n -F` for `Start-Process`, `Start-Sleep`, `New-TemporaryFile`, `GetTempPath`, `GetTempFileName`, `TestDrive:`, `$env:TEMP`, `$env:TMP`, `$global:`, `Import-ScriptFunction`) printed no match lines.
- Additional entry cases beyond the token cases (no new token): `bootstrap-host.Tests.ps1` forwards `-Apply` with the other switches off, and dot-sourcing the entry does not run the orchestrator (the retained dot-source guard); `publish-sideloaded-extension.Tests.ps1` forwards `-Verbose` and `-WarningAction` but not `-ErrorAction` (required by P5-T7), and forwards the five switch parameters.
- `scripts/dev-tools/bootstrap-host.helpers.ps1` deleted with `git rm` (P5-T4); `git grep --untracked -n -F -e bootstrap-host.helpers -- . ':(exclude)docs/features'` printed no match lines.
