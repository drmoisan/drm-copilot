# Pester Suite and Token Results (Issue #847, AC-05, AC-06)

Timestamp: 2026-10-10T01-18
Task: [P7-T6]
Route substitution: per `docs/features/active/2026-10-08-powershell-aggregate-line-coverage-below-floor-847/evidence/other/execution-amendment.2026-10-09T23-50.md` (rows "FULL_RUN (P7-T3 final)" and "CRP / JRP reductions"), JRP is applied by an equivalent Python reduction to the P7-T3 FULL_RUN junit `artifacts/ci/run-38011932558/pester-junit.xml` (suite match: name, with backslashes normalized, ends with `/` + test path, case-insensitive; PASS iff at least one testcase and every testcase status is `Passed`; token PASS iff at least one hit and every hit `Passed`).
Command: `poetry run python <scratchpad>/reduce847.py artifacts/ci/run-38011932558/powershell-coverage.xml artifacts/ci/run-38011932558/pester-junit.xml` (output `artifacts/ci/run-38011932558/reduction.txt`, lines 16-95).
EXIT_CODE: 0
Output Summary:
- JRP step 5: tests=6709 failures=0 errors=0 disabled=10; failed testcases: 0.
- JRP steps 2-3: all eleven TEST11 suites PASS (exactly one matching suite each; zero non-Passed cases).
- JRP step 4: all 32 tokens PASS (every hit `Passed`).
- Result: PASS (AC-05, AC-06).

## Suites (JRP steps 2-3)

| Test file | cases | notPassed | Result |
|---|---|---|---|
| tests/scripts/dev-tools/HostTooling.Tests.ps1 | 19 | 0 | PASS |
| tests/scripts/dev-tools/HostBootstrapWorkspace.Tests.ps1 | 31 | 0 | PASS |
| tests/scripts/dev-tools/HostBootstrap.Tests.ps1 | 28 | 0 | PASS |
| tests/scripts/dev-tools/HostBootstrap.Invoke.Tests.ps1 | 16 | 0 | PASS |
| tests/scripts/dev-tools/HostVerification.Tests.ps1 | 22 | 0 | PASS |
| tests/scripts/dev-tools/HostVerification.Invoke.Tests.ps1 | 10 | 0 | PASS |
| tests/scripts/dev-tools/SideloadedExtensionPublish.Tests.ps1 | 27 | 0 | PASS |
| tests/scripts/dev-tools/SideloadedExtensionPublish.Invoke.Tests.ps1 | 13 | 0 | PASS |
| tests/scripts/dev-tools/bootstrap-host.Tests.ps1 | 5 | 0 | PASS |
| tests/scripts/dev-tools/verify-host.Tests.ps1 | 3 | 0 | PASS |
| tests/scripts/dev-tools/publish-sideloaded-extension.Tests.ps1 | 8 | 0 | PASS |

## Tokens (JRP step 4) with matching testcase names

- AC05-BOOTSTRAP-DRYRUN-EXIT0 hits=1 PASS — bootstrap-host.ps1 entry point.AC05-BOOTSTRAP-DRYRUN-EXIT0 returns exit code 0 after a dry run and forwards every parameter
- AC05-BOOTSTRAP-NONWINDOWS-EXIT1 hits=1 PASS — bootstrap-host.ps1 entry point.AC05-BOOTSTRAP-NONWINDOWS-EXIT1 rethrows the non-Windows terminating error and sets exit code 1
- AC05-BOOTSTRAP-NOWINGET-EXIT1 hits=1 PASS — bootstrap-host.ps1 entry point.AC05-BOOTSTRAP-NOWINGET-EXIT1 rethrows the missing-winget terminating error and sets exit code 1
- AC05-VERIFY-PASS-EXIT0 hits=1 PASS — verify-host.ps1 entry point.AC05-VERIFY-PASS-EXIT0 writes the passing report and returns exit code 0
- AC05-VERIFY-ONEFAIL-EXIT1 hits=1 PASS — verify-host.ps1 entry point.AC05-VERIFY-ONEFAIL-EXIT1 writes the one-issue summary and returns exit code 1
- AC05-VERIFY-NOMANIFEST-EXIT1 hits=1 PASS — verify-host.ps1 entry point.AC05-VERIFY-NOMANIFEST-EXIT1 rethrows the missing-manifest terminating error and sets exit code 1
- AC05-PUBLISH-VSIX-OUTPUT hits=1 PASS — publish-sideloaded-extension.ps1 entry point - parameter forwarding.AC05-PUBLISH-VSIX-OUTPUT returns the VSIX path and resolves both default expressions
- AC05-PUBLISH-WHATIF-NOSEAMS hits=1 PASS — publish-sideloaded-extension.ps1 entry point - real orchestrator.AC05-PUBLISH-WHATIF-NOSEAMS makes no state-changing seam call under -WhatIf
- AC05-PUBLISH-CODECOMMAND-BOUNDEMPTY hits=1 PASS — publish-sideloaded-extension.ps1 entry point - parameter forwarding.AC05-PUBLISH-CODECOMMAND-BOUNDEMPTY forwards an explicitly bound empty -CodeCommand
- AC05-PUBLISH-CODECOMMAND-UNBOUND hits=1 PASS — publish-sideloaded-extension.ps1 entry point - parameter forwarding.AC05-PUBLISH-CODECOMMAND-UNBOUND forwards no CodeCommand key when -CodeCommand is not supplied
- AC05-PUBLISH-CONFIRM-FORWARDED hits=1 PASS — publish-sideloaded-extension.ps1 entry point - parameter forwarding.AC05-PUBLISH-CONFIRM-FORWARDED forwards -Confirm:$false
- AC06-BOOTSTRAP-DRYRUN-NOSIDEEFFECTS hits=1 PASS — Invoke-BootstrapHost.dry run.AC06-BOOTSTRAP-DRYRUN-NOSIDEEFFECTS performs no installs, registry writes, or clones and prints Would lines
- AC06-BOOTSTRAP-NOMANIFEST-THROWS hits=1 PASS — Invoke-BootstrapHost.failure paths.AC06-BOOTSTRAP-NOMANIFEST-THROWS throws when the host tools manifest is missing
- AC06-BOOTSTRAP-PRECONDITION-ERRORS hits=1 PASS — Invoke-BootstrapHost.failure paths.AC06-BOOTSTRAP-PRECONDITION-ERRORS raises terminating errors for a non-Windows host and a missing winget
- AC06-RUNONCE-SET-APPLY-AND-RESUME hits=1 PASS — Invoke-BootstrapHost.RunOnce resume.AC06-RUNONCE-SET-APPLY-AND-RESUME registers RunOnce with -Apply and -EnableAutoResumeAfterReboot
- AC06-RUNONCE-NOT-SET-WITHOUT-BOTH hits=2 PASS — Invoke-BootstrapHost.dry run.AC06-RUNONCE-NOT-SET-WITHOUT-BOTH does not register RunOnce with only -EnableAutoResumeAfterReboot; Invoke-BootstrapHost.RunOnce resume.AC06-RUNONCE-NOT-SET-WITHOUT-BOTH does not register RunOnce with only -Apply
- AC06-RUNONCE-CLEARED-AFTER-APPLY hits=1 PASS — Invoke-BootstrapHost.RunOnce resume.AC06-RUNONCE-CLEARED-AFTER-APPLY clears RunOnce after a successful apply
- AC06-POETRY-PROJECT-INSTALL-WARNS hits=1 PASS — Invoke-BootstrapHost.apply.AC06-POETRY-PROJECT-INSTALL-WARNS reports a poetry project-install failure as a warning
- AC06-VERIFY-SCRIPT-EXITCODE-IGNORED hits=1 PASS — Invoke-BootstrapHost.apply.AC06-VERIFY-SCRIPT-EXITCODE-IGNORED invokes the sibling verify script by path and ignores its result
- AC06-POETRY-PIP-FALLBACK hits=1 PASS — Install-WithWinget.AC06-POETRY-PIP-FALLBACK falls back to pip when the poetry winget install fails
- AC06-NONPOETRY-RETHROW hits=1 PASS — Install-WithWinget.AC06-NONPOETRY-RETHROW rethrows a winget failure for another package
- AC06-VERIFY-NOMANIFEST-THROWS hits=1 PASS — Invoke-HostVerification.manifest.AC06-VERIFY-NOMANIFEST-THROWS raises Manifest not found at the manifest path when the manifest is missing
- AC06-VERIFY-SECTION-ORDER hits=1 PASS — Invoke-HostVerification.report.AC06-VERIFY-SECTION-ORDER emits the banner, five headings, and item lines in the original order
- AC06-VERIFY-EXIT-BOUNDARY hits=1 PASS — Invoke-HostVerification.report.AC06-VERIFY-EXIT-BOUNDARY returns ExitCode 0 at zero failures and 1 at one failure
- AC06-EPERM-RETRY-LIMIT hits=1 PASS — Invoke-NpmCiWithRetry.AC06-EPERM-RETRY-LIMIT rethrows EPERM after three attempts
- AC06-EPERM-BACKOFF hits=1 PASS — Invoke-NpmCiWithRetry.AC06-EPERM-BACKOFF passes DelaySeconds times the attempt number to the sleep seam
- AC06-NONEPERM-RETHROW hits=1 PASS — Invoke-NpmCiWithRetry.AC06-NONEPERM-RETHROW rethrows a non-EPERM failure without sleeping
- AC06-PUBLISH-FORCE-CLEANUP hits=1 PASS — Invoke-NpmCiWithRetry.AC06-PUBLISH-FORCE-CLEANUP stops node, removes node_modules, and cleans the npm cache
- AC06-PUBLISH-STEP-ORDER hits=1 PASS — Invoke-SideloadedExtensionPublish.with a resolved VS Code CLI.AC06-PUBLISH-STEP-ORDER runs npm ci, compile, vsce package, and install in that order
- AC06-PUBLISH-SKIP-SWITCHES hits=3 PASS — Invoke-SideloadedExtensionPublish.with a resolved VS Code CLI.AC06-PUBLISH-SKIP-SWITCHES suppresses npm ci with -SkipNpmCi; ... suppresses compile with -SkipCompile; ... suppresses CLI resolution and install with -SkipInstall
- AC06-PUBLISH-VSIX-MISSING-THROWS hits=1 PASS — Invoke-SideloadedExtensionPublish.with a resolved VS Code CLI.AC06-PUBLISH-VSIX-MISSING-THROWS throws when vsce did not create the VSIX
- AC06-PUBLISH-CODECOMMAND-NOTFOUND-THROWS hits=1 PASS — Invoke-SideloadedExtensionPublish.VS Code CLI resolution failures.AC06-PUBLISH-CODECOMMAND-NOTFOUND-THROWS throws when an explicit -CodeCommand is not on PATH
