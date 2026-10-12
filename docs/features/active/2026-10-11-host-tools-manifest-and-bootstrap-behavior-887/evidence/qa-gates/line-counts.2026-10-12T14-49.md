# Final QC Line Counts (Issue 887)

Timestamp: 2026-10-12T14-49
Command: git grep -c '' -- scripts/host-tools.manifest.json scripts/dev-tools/HostTooling.psm1 scripts/dev-tools/HostBootstrapWorkspace.psm1 scripts/dev-tools/HostBootstrap.psm1 scripts/dev-tools/publish-sideloaded-extension.ps1 tests/scripts/host-tools.manifest.Tests.ps1 tests/scripts/dev-tools/HostTooling.Tests.ps1 tests/scripts/dev-tools/HostBootstrap.Invoke.Tests.ps1 tests/scripts/dev-tools/HostBootstrapWorkspace.Tests.ps1 tests/scripts/dev-tools/HostBootstrap.Tests.ps1 tests/scripts/dev-tools/bootstrap-host.Tests.ps1 tests/scripts/dev-tools/publish-sideloaded-extension.Tests.ps1
EXIT_CODE: 0
Output Summary:
- Twelve path:count lines printed; every count is at most 500 (AC-18).

| File | Post-change | P0-T14 baseline |
|---|---|---|
| scripts/host-tools.manifest.json | 28 | new |
| scripts/dev-tools/HostTooling.psm1 | 207 | 198 |
| scripts/dev-tools/HostBootstrapWorkspace.psm1 | 285 | 290 |
| scripts/dev-tools/HostBootstrap.psm1 | 462 | 463 |
| scripts/dev-tools/publish-sideloaded-extension.ps1 | 96 | 83 |
| tests/scripts/host-tools.manifest.Tests.ps1 | 168 | new |
| tests/scripts/dev-tools/HostTooling.Tests.ps1 | 289 | 253 |
| tests/scripts/dev-tools/HostBootstrap.Invoke.Tests.ps1 | 291 | 249 |
| tests/scripts/dev-tools/HostBootstrapWorkspace.Tests.ps1 | 360 | 317 |
| tests/scripts/dev-tools/HostBootstrap.Tests.ps1 | 320 | 314 |
| tests/scripts/dev-tools/bootstrap-host.Tests.ps1 | 102 | 102 |
| tests/scripts/dev-tools/publish-sideloaded-extension.Tests.ps1 | 254 | 140 |
