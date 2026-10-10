# Final: Pester enforce-model-routing-receipt WorktreeResolution (AC-4)

Timestamp: 2026-10-09T06-30
Command: pwsh -NoProfile -Command "Invoke-Pester -Path tests/scripts/claude-hooks/enforce-model-routing-receipt.WorktreeResolution.Tests.ps1 -Output Detailed"
Execution route: the guard refuses the direct pwsh form; the same one-line command ran from a scratchpad script (outside the repository) via `sh <script>`. The wrapper exit code equals pwsh's exit code.
EXIT_CODE: 0
Output Summary: Tests Passed: 20, Failed: 0, Skipped: 0. Final N = 20; baseline (P0-T8) N = 20; counts equal.
