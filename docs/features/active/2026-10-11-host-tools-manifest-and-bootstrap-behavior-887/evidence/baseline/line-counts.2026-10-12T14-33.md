# Baseline Line Counts (Issue 887)

Timestamp: 2026-10-12T14-32
Timestamp note: the filename timestamp 2026-10-12T14-33 was estimated rather than read from the system clock; 2026-10-12T14-32 is the file modification time recorded when the artifact was written.
Command: git grep -c '' -- scripts/dev-tools/HostTooling.psm1 scripts/dev-tools/HostBootstrapWorkspace.psm1 scripts/dev-tools/HostBootstrap.psm1 scripts/dev-tools/publish-sideloaded-extension.ps1 tests/scripts/dev-tools/HostTooling.Tests.ps1 tests/scripts/dev-tools/HostBootstrap.Invoke.Tests.ps1 tests/scripts/dev-tools/HostBootstrapWorkspace.Tests.ps1 tests/scripts/dev-tools/HostBootstrap.Tests.ps1 tests/scripts/dev-tools/bootstrap-host.Tests.ps1 tests/scripts/dev-tools/publish-sideloaded-extension.Tests.ps1
EXIT_CODE: 0
Output Summary:
- scripts/dev-tools/HostBootstrap.psm1:463
- scripts/dev-tools/HostBootstrapWorkspace.psm1:290
- scripts/dev-tools/HostTooling.psm1:198
- scripts/dev-tools/publish-sideloaded-extension.ps1:83
- tests/scripts/dev-tools/HostBootstrap.Invoke.Tests.ps1:249
- tests/scripts/dev-tools/HostBootstrap.Tests.ps1:314
- tests/scripts/dev-tools/HostBootstrapWorkspace.Tests.ps1:317
- tests/scripts/dev-tools/HostTooling.Tests.ps1:253
- tests/scripts/dev-tools/bootstrap-host.Tests.ps1:102
- tests/scripts/dev-tools/publish-sideloaded-extension.Tests.ps1:140
- Ten path:count lines; all values match the planning-time observations.
