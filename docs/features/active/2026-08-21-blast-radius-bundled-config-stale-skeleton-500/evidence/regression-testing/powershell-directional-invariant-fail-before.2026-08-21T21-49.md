Timestamp: 2026-08-21T21-49
Command: git show fb30a9a58b8422e610a09b07361421e97367807a:extensions/drm-copilot/resources/claude-customizations/config/blast-radius.json > extensions/drm-copilot/resources/claude-customizations/config/blast-radius.json ; then a filtered Invoke-Pester run against tests/scripts/claude-lib/blast-radius/BlastRadius.TruthTable.Tests.ps1 with Filter.FullName = '*requires every separator-free self-hosted shared surface to reach the bundled copy*'
EXIT_CODE: 1
ExpectedExitCode: 1
Output Summary: $result.PassedCount = 0, $result.FailedCount = 1. Failure message: "Expected $null or
empty, but got @('poetry.lock', 'package-lock.json', 'quality-tiers.yml')." This demonstrates the
new Pester case is falsifiable: with the bundled copy reverted to the merge-base state, the
directional invariant fails and names the three missing self-hosted separator-free entries.
