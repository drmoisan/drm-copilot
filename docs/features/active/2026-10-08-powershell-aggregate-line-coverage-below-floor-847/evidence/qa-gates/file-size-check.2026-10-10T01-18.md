# File Size Check (Issue #847, AC-12)

Timestamp: 2026-10-10T01-18
Task: [P7-T11]
Route substitution: per `docs/features/active/2026-10-08-powershell-aggregate-line-coverage-below-floor-847/evidence/other/execution-amendment.2026-10-09T23-50.md` (row "P7-T11 line counts"), the `Get-Content` count is replaced by `git grep -c ''` over the CPFS files. The empty pattern matches every line, so the per-file count is the line count. All 19 files are tracked and unmodified relative to HEAD `1c3d1a4c6` (see `pwsh-format.2026-10-10T01-18.md`).
Command: `git grep --untracked -c '' -- <the 19 CPFS paths in plan order>`
EXIT_CODE: 0
Output Summary:
- scripts/dev-tools/HostTooling.psm1 lines=198
- scripts/dev-tools/HostBootstrapWorkspace.psm1 lines=290
- scripts/dev-tools/HostBootstrap.psm1 lines=463
- scripts/dev-tools/HostVerification.psm1 lines=392
- scripts/dev-tools/SideloadedExtensionPublish.psm1 lines=456
- scripts/dev-tools/bootstrap-host.ps1 lines=35
- scripts/dev-tools/verify-host.ps1 lines=19
- scripts/dev-tools/publish-sideloaded-extension.ps1 lines=83
- tests/scripts/dev-tools/HostTooling.Tests.ps1 lines=253
- tests/scripts/dev-tools/HostBootstrapWorkspace.Tests.ps1 lines=317
- tests/scripts/dev-tools/HostBootstrap.Tests.ps1 lines=314
- tests/scripts/dev-tools/HostBootstrap.Invoke.Tests.ps1 lines=249
- tests/scripts/dev-tools/HostVerification.Tests.ps1 lines=359
- tests/scripts/dev-tools/HostVerification.Invoke.Tests.ps1 lines=164
- tests/scripts/dev-tools/SideloadedExtensionPublish.Tests.ps1 lines=372
- tests/scripts/dev-tools/SideloadedExtensionPublish.Invoke.Tests.ps1 lines=191
- tests/scripts/dev-tools/bootstrap-host.Tests.ps1 lines=102
- tests/scripts/dev-tools/verify-host.Tests.ps1 lines=97
- tests/scripts/dev-tools/publish-sideloaded-extension.Tests.ps1 lines=140
- 19 lines; maximum 463 (`HostBootstrap.psm1`); every value at most 500. No evidence `.ps1` or `.psm1` file was created (the P7-T12 union contains no such path under the feature folder).
- Result: PASS (AC-12).
