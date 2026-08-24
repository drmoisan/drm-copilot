Timestamp: 2026-08-22T03-37
Command: (same injected state as P2-T6) filtered Invoke-Pester run against tests/scripts/claude-lib/blast-radius/BlastRadius.TruthTable.Tests.ps1 with Filter.FullName = '*requires every top-level key in both copies to be classified and shared*'
EXIT_CODE: 1
ExpectedExitCode: 1
Output Summary: $result.PassedCount = 0, $result.FailedCount = 1. Failure message: "Expected $null or
empty, but got 'new_top_level_key'." This demonstrates the new Pester exhaustiveness case is
falsifiable: with the same injected unclassified top-level key in the self-hosted copy only, the
case fails and names the injected key.
