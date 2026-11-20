# -WhatIf tests fail without the ShouldProcess gate (cycle 1, P1-T4 and P1-T5)

Timestamp: 2026-11-03T20-41
Command: Invoke-Pester over tests/scripts/claude-lib/docs/Invoke-DocsCommand.Tests.ps1 with the ShouldProcess condition in Write-DocsFileText temporarily replaced by a constant true, then reverted (launched through a sh script under SCRATCH)
EXIT_CODE: 0
ExpectedExitCode: 0
Output Summary: with the gate present, 46 tests, 46 passed (44 baseline plus 2 new). With the gate removed, 46 tests, 44 passed, 2 failed, and the two failures are exactly the two new -WhatIf tests (creates neither the file nor its directory; writes nothing and throws nothing under a true WhatIfPreference). Files written by the mutated run under artifacts/ were removed and the gate was restored (digest equality recorded in the bundle-mirror-remediation artifact).

P1-T5 check: DocsSchema.Tests.ps1 with the mock using Write-Error with -ErrorAction SilentlyContinue (option 1): 37 tests, 37 passed, and the captured run output contains 0 matches for the token "The value does not match".
