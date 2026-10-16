# Baseline line counts (P0-T7)

Timestamp: 2026-10-16T02-18

Command: pwsh -NoProfile -NonInteractive -Command '(Get-Content -LiteralPath scripts/dev-tools/HostBootstrap.psm1).Count; (Get-Content -LiteralPath tests/scripts/dev-tools/HostBootstrap.Invoke.Tests.ps1).Count'

EXIT_CODE: 0

Output Summary: Printed counts 462 (scripts/dev-tools/HostBootstrap.psm1) and 291 (tests/scripts/dev-tools/HostBootstrap.Invoke.Tests.ps1). Decision: new tests go in HostBootstrap.Invoke.Tests.ps1; HostBootstrap.Poetry.Tests.ps1 is not created.
