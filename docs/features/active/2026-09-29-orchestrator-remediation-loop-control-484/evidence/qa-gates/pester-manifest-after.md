# Bundle-Manifest Suite After the Fix (P5-T12)

Timestamp: 2026-10-01T22-41
Task: P5-T12
Route: sh-wrapped pwsh -NoProfile -Command (scratchpad script outside the repository)
Command: $r=Invoke-Pester -Path tests/scripts/claude-lib/orchestrator-state/OrchestratorState.Manifest.Tests.ps1 -PassThru; "Passed=$($r.PassedCount) Failed=$($r.FailedCount)"; foreach ($n in @('registers every on-disk orchestrator-state module so none is unregistered','mirrors every orchestrator-state module byte-identically into the bundle')) { "$n=$(@($r.Passed | Where-Object { $_.ExpandedName -ceq $n }).Count)" }
EXIT_CODE: 0

Output:

```
Tests Passed: 6, Failed: 0, Skipped: 0, Inconclusive: 0, NotRun: 0
Passed=6 Failed=0
registers every on-disk orchestrator-state module so none is unregistered=1
mirrors every orchestrator-state module byte-identically into the bundle=1
```

Output Summary: `Failed=0` (EXIT_CODE is `$r.FailedCount` = 0), `Passed=6`, and both named lines end `=1`. The new module is registered in `pack-manifests/core.json` and `$script:ExpectedPaths`, and both new and edited modules are byte-identical in the bundle.
