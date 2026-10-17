# R4 Local Test after the Perf Edits (P4-T10, issue #935)

Timestamp: 2026-10-17T01-07
Command: the commands listed below, each with its output (run from the worktree root; scripts under SCRATCH)
EXIT_CODE: 0

Output Summary:
One call: mcp__drm-copilot__run_poshqc_test with scan_folders [tests/scripts/claude-hooks]; disposition returned (stat pre 2026-10-16 20:54:00.975145600 -0400). A returned call means every row of P_DS passed (the runtime raises when any test fails): every per-suite AC-4 and AC-6 row, the AC-2, AC-3, AC-5, AC-5b and F-3 non-vacuity rows, and the six rows of Describe issue #935 PERF memo; together with every row of the other EpicStateIsolation suites that dot-source P_DH (including the HookReference F-3 closure stays literal-seeded row). Every re-run acceptance command other than D-LC and the It count prints its stated value; re-run D-LC values print the cumulative end-of-Phase-4 values P_DH 373 (292 + 81), P_CH 227 (224 + 3), P_DS 458 (356 + 102); the re-run P4-T7 It count prints 29 (DS-IT-COUNT 23 + 6). (Per-task D-LC and It-count expectations in the script headers of P4-T3 to P4-T7 are superseded here by the cumulative values.)

```
MCP call: mcp__drm-copilot__run_poshqc_test scan_folders=[tests/scripts/claude-hooks] => returned (ok: true) on the first call; no D-JUNIT-DIAG needed
stat -c %y artifacts/pester/pester-junit.xml (post) => 2026-10-16 21:06:34.390556100 -0400
Re-run acceptance commands (D-LC compared with the cumulative end-of-Phase-4 value: P_DH 373, P_CH 227, P_DS 458; It count compared with DS-IT-COUNT + 6 = 29):
== P4-T3 acceptance (P_DH); expected: seven literals 1 each, '    return {' 0, ParseCache 1, D-LC 292 + 17 = 309 (Phase 4 cumulative 373)
1	tests/scripts/claude-hooks/EpicStateIsolation.Discovery.Helpers.ps1	grep -c -F -e [$script:EpicStateCensusCache = [System.Collections.Generic.Dictionary[string, object]]::new([System.StringComparer]::Ordinal)]
1	tests/scripts/claude-hooks/EpicStateIsolation.Discovery.Helpers.ps1	grep -c -F -e [$script:EpicStateClosureNodeCache = [System.Collections.Generic.Dictionary[object, object]]::new()]
1	tests/scripts/claude-hooks/EpicStateIsolation.Discovery.Helpers.ps1	grep -c -F -e [$script:EpicStateReaderCache = [System.Collections.Generic.Dictionary[string, object]]::new([System.StringComparer]::Ordinal)]
1	tests/scripts/claude-hooks/EpicStateIsolation.Discovery.Helpers.ps1	grep -c -F -e [The census, closure-node and reader memos follow the same exception (issue #935, PERF):]
1	tests/scripts/claude-hooks/EpicStateIsolation.Discovery.Helpers.ps1	grep -c -F -e [The same script block is returned for a repository root on every call (issue #935, PERF).]
1	tests/scripts/claude-hooks/EpicStateIsolation.Discovery.Helpers.ps1	grep -c -F -e [    if ($script:EpicStateReaderCache.ContainsKey($RepoRoot)) { return $script:EpicStateReaderCache[$RepoRoot] }]
1	tests/scripts/claude-hooks/EpicStateIsolation.Discovery.Helpers.ps1	grep -c -F -e [    $script:EpicStateReaderCache[$RepoRoot] = $reader]
0	tests/scripts/claude-hooks/EpicStateIsolation.Discovery.Helpers.ps1	grep -c -F -e [    return {]
1	tests/scripts/claude-hooks/EpicStateIsolation.Discovery.Helpers.ps1	grep -c -F -e [$script:EpicStateParseCache = @{}]
D-LC tests/scripts/claude-hooks/EpicStateIsolation.Discovery.Helpers.ps1: 373
== P4-T4 acceptance (P_DH); expected: five literals 1 each, census function 1, old record 0, D-LC 309 + 19 = 328 (Phase 4 cumulative 373)
1	tests/scripts/claude-hooks/EpicStateIsolation.Discovery.Helpers.ps1	grep -c -F -e [function Get-EpicStateFileSeamCensus {]
1	tests/scripts/claude-hooks/EpicStateIsolation.Discovery.Helpers.ps1	grep -c -F -e [    foreach ($file in $ClosureFile) { Get-EpicStateFileSeamCensus -Path $file.Path -Text $file.Text }]
1	tests/scripts/claude-hooks/EpicStateIsolation.Discovery.Helpers.ps1	grep -c -F -e [    $key = $Path + [char]0 + $Text]
1	tests/scripts/claude-hooks/EpicStateIsolation.Discovery.Helpers.ps1	grep -c -F -e [DefiningFile = $Path }]
1	tests/scripts/claude-hooks/EpicStateIsolation.Discovery.Helpers.ps1	grep -c -F -e [$script:EpicStateCensusCache[$key] = [object[]]@($records)]
1	tests/scripts/claude-hooks/EpicStateIsolation.Discovery.Helpers.ps1	grep -c -F -e [function Get-EpicStateSeamCensus {]
0	tests/scripts/claude-hooks/EpicStateIsolation.Discovery.Helpers.ps1	grep -c -F -e [DefiningFile = $file.Path }]
D-LC tests/scripts/claude-hooks/EpicStateIsolation.Discovery.Helpers.ps1: 373
== P4-T5 acceptance (P_DH); expected: 1, 1, 1, 1, 1, Tuple 2, '& $ReadSource' 1, old break 0, closure function 1, D-LC 328 + 45 = 373 (<= 500; Phase 4 cumulative 373)
1	tests/scripts/claude-hooks/EpicStateIsolation.Discovery.Helpers.ps1	grep -c -F -e [function Get-EpicStateMemoSourceText {]
1	tests/scripts/claude-hooks/EpicStateIsolation.Discovery.Helpers.ps1	grep -c -F -e [function Get-EpicStateClosureSuccessor {]
1	tests/scripts/claude-hooks/EpicStateIsolation.Discovery.Helpers.ps1	grep -c -F -e [foreach ($candidate in @(Get-EpicStateClosureSuccessor -Path $path -ReadSource $ReadSource -LibraryDirectory $LibraryDirectory)) {]
1	tests/scripts/claude-hooks/EpicStateIsolation.Discovery.Helpers.ps1	grep -c -F -e [            if (-not $loaded.Contains($candidate)) { $queue.Enqueue($candidate) }]
1	tests/scripts/claude-hooks/EpicStateIsolation.Discovery.Helpers.ps1	grep -c -F -e [Get-EpicStateClosureSuccessor), so each file is read and resolved once (issue #935, PERF).]
2	tests/scripts/claude-hooks/EpicStateIsolation.Discovery.Helpers.ps1	grep -c -F -e [[System.Tuple[object, string]]::new($ReadSource,]
1	tests/scripts/claude-hooks/EpicStateIsolation.Discovery.Helpers.ps1	grep -c -F -e [& $ReadSource]
0	tests/scripts/claude-hooks/EpicStateIsolation.Discovery.Helpers.ps1	grep -c -F -e [if ($loaded.Contains($candidate)) { break }]
1	tests/scripts/claude-hooks/EpicStateIsolation.Discovery.Helpers.ps1	grep -c -F -e [function Get-EpicStateLoadedSourceClosure {]
D-LC tests/scripts/claude-hooks/EpicStateIsolation.Discovery.Helpers.ps1: 373
== P4-T6 acceptance (P_CH); expected: five literals 1 each, 'seam -join' 0, finding text 1, D-LC 224 + 3 = 227 (Phase 4 cumulative 227)
1	tests/scripts/claude-hooks/EpicStateIsolation.Compliance.Helpers.ps1	grep -c -F -e [holds the probe seams of the suite passes them as -Seam, which skips the scan (issue #935, PERF).]
1	tests/scripts/claude-hooks/EpicStateIsolation.Compliance.Helpers.ps1	grep -c -F -e [        [string[]] $Seam]
1	tests/scripts/claude-hooks/EpicStateIsolation.Compliance.Helpers.ps1	grep -c -F -e [PSBoundParameters.ContainsKey('Seam')]
1	tests/scripts/claude-hooks/EpicStateIsolation.Compliance.Helpers.ps1	grep -c -F -e [if ($probeSeam.Count -eq 0) { return }]
1	tests/scripts/claude-hooks/EpicStateIsolation.Compliance.Helpers.ps1	grep -c -F -e [probeSeam -join]
0	tests/scripts/claude-hooks/EpicStateIsolation.Compliance.Helpers.ps1	grep -c -F -e [seam -join]
1	tests/scripts/claude-hooks/EpicStateIsolation.Compliance.Helpers.ps1	grep -c -F -e [but never calls Invoke-EpicStateInterceptionProbe from inside an It]
D-LC tests/scripts/claude-hooks/EpicStateIsolation.Compliance.Helpers.ps1: 227
== P4-T7 acceptance (P_DS); expected: seven literals 1 each, VariableLoadReport[Surface] 2, DiscoveredSuite call 1, collect 1, old comment 0, four row literals 1 each, AC-6 3, It count 23 (DS-IT-COUNT; 29 after P4-T8), D-LC 356 + 10 = 366 (Phase 4 cumulative 458)
1	tests/scripts/claude-hooks/enforce-gate-suites.EpicStateIsolation.Discovery.Tests.ps1	grep -c -F -e [Suite discovery and the probe-seam scan run once in BeforeDiscovery and reach the run phase]
1	tests/scripts/claude-hooks/enforce-gate-suites.EpicStateIsolation.Discovery.Tests.ps1	grep -c -F -e [$probeSeam = @(Get-EpicStateProbeSeam -RepoRoot $discoveryRoot -RelativePath $row.Path)]
1	tests/scripts/claude-hooks/enforce-gate-suites.EpicStateIsolation.Discovery.Tests.ps1	grep -c -F -e [-ForEach @(@{ DiscoveredSuiteBySurface = $script:DiscoveredSuiteBySurface }) {]
1	tests/scripts/claude-hooks/enforce-gate-suites.EpicStateIsolation.Discovery.Tests.ps1	grep -c -F -e [-RelativePath $Path -Seam $Seam)]
1	tests/scripts/claude-hooks/enforce-gate-suites.EpicStateIsolation.Discovery.Tests.ps1	grep -c -F -e [foreach ($suite in @($DiscoveredSuiteBySurface[$Surface])) {]
1	tests/scripts/claude-hooks/enforce-gate-suites.EpicStateIsolation.Discovery.Tests.ps1	grep -c -F -e [{ $script:VariableLoadLine = @($script:VariableLoadReport[$Surface]) } | Should -Not -Throw]
1	tests/scripts/claude-hooks/enforce-gate-suites.EpicStateIsolation.Discovery.Tests.ps1	grep -c -F -e [$lines = @($script:VariableLoadReport[$Surface])]
2	tests/scripts/claude-hooks/enforce-gate-suites.EpicStateIsolation.Discovery.Tests.ps1	grep -c -F -e [$script:VariableLoadReport[$Surface]]
1	tests/scripts/claude-hooks/enforce-gate-suites.EpicStateIsolation.Discovery.Tests.ps1	grep -c -F -e [Get-EpicStateDiscoveredSuite -RepoRoot $script:RepoRoot -Surface $Surface]
1	tests/scripts/claude-hooks/enforce-gate-suites.EpicStateIsolation.Discovery.Tests.ps1	grep -c -F -e [$collect = {]
0	tests/scripts/claude-hooks/enforce-gate-suites.EpicStateIsolation.Discovery.Tests.ps1	grep -c -F -e [collect the report lines independently of the AC-5b row.]
1	tests/scripts/claude-hooks/enforce-gate-suites.EpicStateIsolation.Discovery.Tests.ps1	grep -c -F -e [It 'AC-5b variable-built hook-load report ]
1	tests/scripts/claude-hooks/enforce-gate-suites.EpicStateIsolation.Discovery.Tests.ps1	grep -c -F -e [It 'F-3 non-vacuity ]
1	tests/scripts/claude-hooks/enforce-gate-suites.EpicStateIsolation.Discovery.Tests.ps1	grep -c -F -e [It 'AC-5 process-spawning report ]
1	tests/scripts/claude-hooks/enforce-gate-suites.EpicStateIsolation.Discovery.Tests.ps1	grep -c -F -e [$lines.Count | Should -BeGreaterThan 0 -Because]
3	tests/scripts/claude-hooks/enforce-gate-suites.EpicStateIsolation.Discovery.Tests.ps1	grep -c -F -e [It 'AC-6 ]
29	tests/scripts/claude-hooks/enforce-gate-suites.EpicStateIsolation.Discovery.Tests.ps1	grep -c -E -e [^    It ']
D-LC tests/scripts/claude-hooks/enforce-gate-suites.EpicStateIsolation.Discovery.Tests.ps1: 458
== P4-T8 acceptance (P_DS); expected: seven literals 1 each, It count 23 + 6 = 29, '.Tests.ps1' 17 (value before this task: 17), D-LC 366 + 92 = 458 (<= 500; Phase 4 cumulative 458)
1	tests/scripts/claude-hooks/enforce-gate-suites.EpicStateIsolation.Discovery.Tests.ps1	grep -c -F -e [Describe 'issue #935 PERF memo' {]
1	tests/scripts/claude-hooks/enforce-gate-suites.EpicStateIsolation.Discovery.Tests.ps1	grep -c -F -e [It 'PERF census memo returns the cached records for a repeated file' {]
1	tests/scripts/claude-hooks/enforce-gate-suites.EpicStateIsolation.Discovery.Tests.ps1	grep -c -F -e [It 'PERF census memo recomputes for changed text' {]
1	tests/scripts/claude-hooks/enforce-gate-suites.EpicStateIsolation.Discovery.Tests.ps1	grep -c -F -e [It 'PERF census memo keys by path as well as text' {]
1	tests/scripts/claude-hooks/enforce-gate-suites.EpicStateIsolation.Discovery.Tests.ps1	grep -c -F -e [It 'PERF closure memo reads each file once for a repeated closure' {]
1	tests/scripts/claude-hooks/enforce-gate-suites.EpicStateIsolation.Discovery.Tests.ps1	grep -c -F -e [It 'PERF closure memo recomputes for a reader with changed text' {]
1	tests/scripts/claude-hooks/enforce-gate-suites.EpicStateIsolation.Discovery.Tests.ps1	grep -c -F -e [It 'PERF memo starts empty when the helper is dot-sourced' {]
29	tests/scripts/claude-hooks/enforce-gate-suites.EpicStateIsolation.Discovery.Tests.ps1	grep -c -E -e [^    It ']
17	tests/scripts/claude-hooks/enforce-gate-suites.EpicStateIsolation.Discovery.Tests.ps1	grep -c -F -e [.Tests.ps1]
D-LC tests/scripts/claude-hooks/enforce-gate-suites.EpicStateIsolation.Discovery.Tests.ps1: 458
```
