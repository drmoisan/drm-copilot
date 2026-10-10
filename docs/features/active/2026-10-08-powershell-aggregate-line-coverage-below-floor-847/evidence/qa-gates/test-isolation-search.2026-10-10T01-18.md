# Test Isolation Search (Issue #847, AC-07)

Timestamp: 2026-10-10T01-18
Task: [P7-T7]
Route note: the plan command is run from the Bash tool (per `docs/features/active/2026-10-08-powershell-aggregate-line-coverage-below-floor-847/evidence/other/execution-amendment.2026-10-09T23-50.md`, PowerShell-tool commands are not used in the agent worktree); the `git grep` text is unchanged and `"EXIT_CODE=$LASTEXITCODE"` is rendered as `echo "EXIT_CODE=$?"`.
Command: `git grep --untracked -n -F -e 'TestDrive:' -e 'New-TemporaryFile' -e 'GetTempPath' -e '$env:TEMP' -e '$env:TMP' -- tests/scripts/dev-tools/HostTooling.Tests.ps1 tests/scripts/dev-tools/HostBootstrapWorkspace.Tests.ps1 tests/scripts/dev-tools/HostBootstrap.Tests.ps1 tests/scripts/dev-tools/HostBootstrap.Invoke.Tests.ps1 tests/scripts/dev-tools/HostVerification.Tests.ps1 tests/scripts/dev-tools/HostVerification.Invoke.Tests.ps1 tests/scripts/dev-tools/SideloadedExtensionPublish.Tests.ps1 tests/scripts/dev-tools/SideloadedExtensionPublish.Invoke.Tests.ps1 tests/scripts/dev-tools/bootstrap-host.Tests.ps1 tests/scripts/dev-tools/verify-host.Tests.ps1 tests/scripts/dev-tools/publish-sideloaded-extension.Tests.ps1; echo "EXIT_CODE=$?"`
EXIT_CODE: 1
ExpectedExitCode: 1
Output Summary:
- No match lines printed; `EXIT_CODE=1` (git grep exits 1 when nothing matches).
- All eleven TEST11 suites passed in the final FULL_RUN with the fail-closed default mocks in place: see `evidence/qa-gates/pester-suite-results.2026-10-10T01-18.md` (eleven suites PASS, 32 tokens PASS, failures=0 errors=0).
- Result: PASS (AC-07).
