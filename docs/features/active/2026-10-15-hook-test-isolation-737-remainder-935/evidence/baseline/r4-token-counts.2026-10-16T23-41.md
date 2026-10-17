# R4 Token and Line-Count Baseline (P0-T3, issue #935)

Timestamp: 2026-10-16T23-41
Command: the commands listed below, each with its output (run from the worktree root; scripts under SCRATCH)
EXIT_CODE: 0

Output Summary:
Every count equals its P0-T3 expected value. DS-IT-COUNT = 23. MAIN-TASK-COUNT = 68. D-LC: P_BRS 335, P_HRH 448, P_HRS 454, P_H 433, P_DH 292, P_CH 224, P_MB 91, P_DS 356 (all at or below 500), P_MAIN 219. Each line below is: count, file, command.

```
== P_BRS
1	tests/scripts/claude-hooks/enforce-gate-suites.EpicStateIsolation.Branches.Tests.ps1	grep -c -F -e [It 'F-1 non-compliant <Branch>' -ForEach @(]
8	tests/scripts/claude-hooks/enforce-gate-suites.EpicStateIsolation.Branches.Tests.ps1	grep -c -F -e [Branch = ']
1	tests/scripts/claude-hooks/enforce-gate-suites.EpicStateIsolation.Branches.Tests.ps1	grep -c -F -e [Branch = 'ESR mock inside try/catch']
1	tests/scripts/claude-hooks/enforce-gate-suites.EpicStateIsolation.Branches.Tests.ps1	grep -c -F -e [Branch = 'ESR mock inside a Get-Command guard naming another seam']
1	tests/scripts/claude-hooks/enforce-gate-suites.EpicStateIsolation.Branches.Tests.ps1	grep -c -F -e [Branch = 'ESR mock inside a matching Get-Command guard']
0	tests/scripts/claude-hooks/enforce-gate-suites.EpicStateIsolation.Branches.Tests.ps1	grep -c -F -e [Branch = 'ESR mock inside switch']
0	tests/scripts/claude-hooks/enforce-gate-suites.EpicStateIsolation.Branches.Tests.ps1	grep -c -F -e [Branch = 'ESR mock inside foreach']
0	tests/scripts/claude-hooks/enforce-gate-suites.EpicStateIsolation.Branches.Tests.ps1	grep -c -F -e [Branch = 'ESR mock inside while']
0	tests/scripts/claude-hooks/enforce-gate-suites.EpicStateIsolation.Branches.Tests.ps1	grep -c -F -e [Branch = 'ESR mock inside trap']
0	tests/scripts/claude-hooks/enforce-gate-suites.EpicStateIsolation.Branches.Tests.ps1	grep -c -F -e [Branch = 'ESR mock inside a matching Get-Command guard with else']
0	tests/scripts/claude-hooks/enforce-gate-suites.EpicStateIsolation.Branches.Tests.ps1	grep -c -F -e [Branch = 'ESR mock inside a matching Get-Command guard with elseif']
1	tests/scripts/claude-hooks/enforce-gate-suites.EpicStateIsolation.Branches.Tests.ps1	grep -c -F -e [Mock of Get-EpicScopeCheckpointText missing from outermost BeforeAll]
== P_HRH
1	tests/scripts/claude-hooks/EpicStateIsolation.HookReference.Helpers.ps1	grep -c -F -e [calls helpers defined there]
1	tests/scripts/claude-hooks/EpicStateIsolation.HookReference.Helpers.ps1	grep -c -F -e [Get-EpicStateIsolationStringConstant]
1	tests/scripts/claude-hooks/EpicStateIsolation.HookReference.Helpers.ps1	grep -c -F -e [AdditionalChildPath element), $null for a segment that is not a string constant.]
1	tests/scripts/claude-hooks/EpicStateIsolation.HookReference.Helpers.ps1	grep -c -F -e [}?[]
0	tests/scripts/claude-hooks/EpicStateIsolation.HookReference.Helpers.ps1	grep -c -F -e [(?:]
D-CB-READ tests/scripts/claude-hooks/EpicStateIsolation.HookReference.Helpers.ps1:
cmdletbinding=6 misplaced=0
NOCB Get-EpicStateIsolationHookDotSource
NOCB Get-EpicStateIsolationHookReference
NOCB Get-EpicStateIsolationHookRoot
NOCB Get-EpicStateIsolationJoinPathPart
NOCB Get-EpicStateIsolationJoinPathSegment
NOCB Get-EpicStateIsolationReferenceRecord
NOCB Get-EpicStateIsolationVariableBinding
NOCB Get-EpicStateIsolationVariableKey
NOCB Test-EpicStateIsolationHelperDotSource
NOCB Test-EpicStateIsolationHookLiteral
NOCB Test-EpicStateIsolationHookReference
NOCB Test-EpicStateIsolationHooksRootBinding
NOCB Test-EpicStateIsolationVariableBoundToHook
== P_HRS
1	tests/scripts/claude-hooks/enforce-gate-suites.EpicStateIsolation.HookReference.Tests.ps1	grep -c -F -e [@{ Case = 'unbound variable'; Source = @']
0	tests/scripts/claude-hooks/enforce-gate-suites.EpicStateIsolation.HookReference.Tests.ps1	grep -c -F -e [@{ Case = 'unbalanced brace'; Source = @']
1	tests/scripts/claude-hooks/enforce-gate-suites.EpicStateIsolation.HookReference.Tests.ps1	grep -c -F -e [    .claude/hooks and .codex/hooks.]
== P_H
1	tests/scripts/claude-hooks/EpicStateIsolation.Helpers.ps1	grep -c -F -e [Dot-sourced by enforce-gate-suites.EpicStateIsolation.Tests.ps1.]
1	tests/scripts/claude-hooks/EpicStateIsolation.Helpers.ps1	grep -c -F -e [    # pipeline naming the Command's target.]
D-CB-READ tests/scripts/claude-hooks/EpicStateIsolation.Helpers.ps1:
cmdletbinding=0 misplaced=0
NOCB Get-EpicStateIsolationBoundConstant
NOCB Get-EpicStateIsolationCommandDepth
NOCB Get-EpicStateIsolationDefaultRequirement
NOCB Get-EpicStateIsolationDirectCommand
NOCB Get-EpicStateIsolationElementText
NOCB Get-EpicStateIsolationFinding
NOCB Get-EpicStateIsolationHelperSeam
NOCB Get-EpicStateIsolationMockBinding
NOCB Get-EpicStateIsolationOutermostBlock
NOCB Get-EpicStateIsolationPairFinding
NOCB Get-EpicStateIsolationStringConstant
NOCB Get-EpicStateIsolationSuiteFinding
NOCB Get-EpicStateIsolationTextFinding
NOCB Test-EpicStateIsolationConditionalAncestor
NOCB Test-EpicStateIsolationModuleImport
NOCB Test-EpicStateIsolationModulePathNode
NOCB Test-EpicStateIsolationNullBody
== P_DH
1	tests/scripts/claude-hooks/EpicStateIsolation.Discovery.Helpers.ps1	grep -c -F -e [Dot-sourced by enforce-gate-suites.EpicStateIsolation.Discovery.Tests.ps1 and by the]
1	tests/scripts/claude-hooks/EpicStateIsolation.Discovery.Helpers.ps1	grep -c -F -e [before calling any of them (issue #935, CR-R4).]
1	tests/scripts/claude-hooks/EpicStateIsolation.Discovery.Helpers.ps1	grep -c -F -e [excluding EpicStateIsolation helpers.]
1	tests/scripts/claude-hooks/EpicStateIsolation.Discovery.Helpers.ps1	grep -c -F -e [_-])hooks/(?]
1	tests/scripts/claude-hooks/EpicStateIsolation.Discovery.Helpers.ps1	grep -c -F -e [    foreach ($literal in (Get-EpicStateParsedSource -Text $SuiteText).Literal) {]
2	tests/scripts/claude-hooks/EpicStateIsolation.Discovery.Helpers.ps1	grep -c -F -e [return [string[]]$names.ToArray()]
D-CB-READ tests/scripts/claude-hooks/EpicStateIsolation.Discovery.Helpers.ps1:
cmdletbinding=0 misplaced=0
NOCB Format-EpicStateCensusLine
NOCB Get-EpicStateDiscoveredSuite
NOCB Get-EpicStateHookLiteral
NOCB Get-EpicStateLibraryDirectory
NOCB Get-EpicStateLoadedSourceClosure
NOCB Get-EpicStateParsedSource
NOCB Get-EpicStateProcessSpawningHook
NOCB Get-EpicStateSeamCensus
NOCB Get-EpicStateSourceReader
NOCB Get-EpicStateSuiteCensusRow
NOCB Get-EpicStateVariableHookLoad
NOCB Resolve-EpicStateRelativePath
1	tests/scripts/claude-hooks/EpicStateIsolation.Discovery.Helpers.ps1	grep -c -F -e [$script:EpicStateParseCache = @{}]
1	tests/scripts/claude-hooks/EpicStateIsolation.Discovery.Helpers.ps1	grep -c -F -e [is deterministic, keyed by source text, and lives for one test session only (#737 F-6).]
0	tests/scripts/claude-hooks/EpicStateIsolation.Discovery.Helpers.ps1	grep -c -F -e [EpicStateCensusCache]
1	tests/scripts/claude-hooks/EpicStateIsolation.Discovery.Helpers.ps1	grep -c -F -e [    return {]
1	tests/scripts/claude-hooks/EpicStateIsolation.Discovery.Helpers.ps1	grep -c -F -e [    }.GetNewClosure()]
1	tests/scripts/claude-hooks/EpicStateIsolation.Discovery.Helpers.ps1	grep -c -F -e [function Get-EpicStateSeamCensus {]
1	tests/scripts/claude-hooks/EpicStateIsolation.Discovery.Helpers.ps1	grep -c -F -e [DefiningFile = $file.Path }]
1	tests/scripts/claude-hooks/EpicStateIsolation.Discovery.Helpers.ps1	grep -c -F -e [required because the closure includes variable-driven loads.]
1	tests/scripts/claude-hooks/EpicStateIsolation.Discovery.Helpers.ps1	grep -c -F -e [        $text = & $ReadSource $path]
1	tests/scripts/claude-hooks/EpicStateIsolation.Discovery.Helpers.ps1	grep -c -F -e [                if ($null -ne (& $ReadSource $candidate)) {]
2	tests/scripts/claude-hooks/EpicStateIsolation.Discovery.Helpers.ps1	grep -c -F -e [& $ReadSource]
== P_CH
D-CB-READ tests/scripts/claude-hooks/EpicStateIsolation.Compliance.Helpers.ps1:
cmdletbinding=0 misplaced=0
NOCB Get-EpicStateProbeFinding
NOCB Get-EpicStateProbeSeam
NOCB Get-EpicStateProcessSpawningReport
NOCB Get-EpicStateSeamRequirement
NOCB Get-EpicStateSuiteCompliance
NOCB Get-EpicStateSuiteState
NOCB Get-EpicStateVariableHookLoadReport
NOCB Test-EpicStateProbeCalledFromIt
NOCB Test-EpicStateResolverPinnedForm
NOCB Test-EpicStateSeamUnderTestForm
1	tests/scripts/claude-hooks/EpicStateIsolation.Compliance.Helpers.ps1	grep -c -F -e [    $seam = @(Get-EpicStateProbeSeam -RepoRoot $RepoRoot -RelativePath $RelativePath -ReadSource $ReadSource)]
1	tests/scripts/claude-hooks/EpicStateIsolation.Compliance.Helpers.ps1	grep -c -F -e [seam -join]
1	tests/scripts/claude-hooks/EpicStateIsolation.Compliance.Helpers.ps1	grep -c -F -e [    # never calls the interception probe from inside an It; nothing otherwise.]
== P_DS
1	tests/scripts/claude-hooks/enforce-gate-suites.EpicStateIsolation.Discovery.Tests.ps1	grep -c -F -e [    rule over in-memory text.]
1	tests/scripts/claude-hooks/enforce-gate-suites.EpicStateIsolation.Discovery.Tests.ps1	grep -c -F -e [-RelativePath $row.Path).Count -gt 0) { @{ Path = $row.Path } }]
1	tests/scripts/claude-hooks/enforce-gate-suites.EpicStateIsolation.Discovery.Tests.ps1	grep -c -F -e [Describe 'discovery guard (both hook surfaces)' {]
4	tests/scripts/claude-hooks/enforce-gate-suites.EpicStateIsolation.Discovery.Tests.ps1	grep -c -F -e [Get-EpicStateDiscoveredSuite -RepoRoot $script:RepoRoot -Surface $Surface]
2	tests/scripts/claude-hooks/enforce-gate-suites.EpicStateIsolation.Discovery.Tests.ps1	grep -c -F -e [$collect = {]
1	tests/scripts/claude-hooks/enforce-gate-suites.EpicStateIsolation.Discovery.Tests.ps1	grep -c -F -e [        $findings = @(Get-EpicStateProbeFinding -RepoRoot $script:RepoRoot -RelativePath $Path)]
1	tests/scripts/claude-hooks/enforce-gate-suites.EpicStateIsolation.Discovery.Tests.ps1	grep -c -F -e [collect the report lines independently of the AC-5b row.]
1	tests/scripts/claude-hooks/enforce-gate-suites.EpicStateIsolation.Discovery.Tests.ps1	grep -c -F -e [the extra name satisfies its requirement and the empty array literal adds no finding.]
0	tests/scripts/claude-hooks/enforce-gate-suites.EpicStateIsolation.Discovery.Tests.ps1	grep -c -F -e [VariableLoadReport]
0	tests/scripts/claude-hooks/enforce-gate-suites.EpicStateIsolation.Discovery.Tests.ps1	grep -c -F -e [PERF memo]
23	tests/scripts/claude-hooks/enforce-gate-suites.EpicStateIsolation.Discovery.Tests.ps1	grep -c -E -e [^    It ']
== P_MB
1	tests/scripts/claude-hooks/enforce-epic-worktree-removal-gate.ManifestBranch.Tests.ps1	grep -c -F -e [pre-existing Describe above]
== P_SPEC
1	docs/features/active/2026-10-15-hook-test-isolation-737-remainder-935/spec.md	grep -c -F -e [- [x] AC-24: ]
26	docs/features/active/2026-10-15-hook-test-isolation-737-remainder-935/spec.md	grep -c -F -e [- [x] AC-]
0	docs/features/active/2026-10-15-hook-test-isolation-737-remainder-935/spec.md	grep -c -F -e [- [ ] AC-]
1	docs/features/active/2026-10-15-hook-test-isolation-737-remainder-935/spec.md	grep -c -F -e [Decision record: `evidence/other/cov1-decision-option1.2026-10-16T20-38.md`.]
1	docs/features/active/2026-10-15-hook-test-isolation-737-remainder-935/spec.md	grep -c -F -e [- **Last Updated:** 2026-10-15]
1	docs/features/active/2026-10-15-hook-test-isolation-737-remainder-935/spec.md	grep -c -F -e [- **Status:** Draft]
1	docs/features/active/2026-10-15-hook-test-isolation-737-remainder-935/spec.md	grep -c -F -e [- **Version:** 0.2]
== P_ISSUE
1	docs/features/active/2026-10-15-hook-test-isolation-737-remainder-935/issue.md	grep -c -F -e [docs/features/active/hook-test-isolation-737-remainder/ (Issue #935)]
1	docs/features/active/2026-10-15-hook-test-isolation-737-remainder-935/issue.md	grep -c -F -e [- [ ] Promote to GitHub issue (bug-report template)]
1	docs/features/active/2026-10-15-hook-test-isolation-737-remainder-935/issue.md	grep -c -F -e [- [ ] Move to active fix folder / branch]
== P_MAIN
1	docs/features/active/2026-10-15-hook-test-isolation-737-remainder-935/plan.2026-10-15T17-44.md	grep -c -F -e [- [ ] [P7-T6] [orchestrator] Coverage comparison (AC-24):]
1	docs/features/active/2026-10-15-hook-test-isolation-737-remainder-935/plan.2026-10-15T17-44.md	grep -c -F -e [Acceptance: every AC is `PASS` with an artifact name, or the item routes to remediation.]
0	docs/features/active/2026-10-15-hook-test-isolation-737-remainder-935/plan.2026-10-15T17-44.md	grep -c -F -e [ACCEPTED-OPTION-1]
68	docs/features/active/2026-10-15-hook-test-isolation-737-remainder-935/plan.2026-10-15T17-44.md	grep -c -E -e [^- \[[ x]\] \[P[0-9]+-T[0-9]+\]]
== D-LC
D-LC tests/scripts/claude-hooks/enforce-gate-suites.EpicStateIsolation.Branches.Tests.ps1: 335
D-LC tests/scripts/claude-hooks/EpicStateIsolation.HookReference.Helpers.ps1: 448
D-LC tests/scripts/claude-hooks/enforce-gate-suites.EpicStateIsolation.HookReference.Tests.ps1: 454
D-LC tests/scripts/claude-hooks/EpicStateIsolation.Helpers.ps1: 433
D-LC tests/scripts/claude-hooks/EpicStateIsolation.Discovery.Helpers.ps1: 292
D-LC tests/scripts/claude-hooks/EpicStateIsolation.Compliance.Helpers.ps1: 224
D-LC tests/scripts/claude-hooks/enforce-epic-worktree-removal-gate.ManifestBranch.Tests.ps1: 91
D-LC tests/scripts/claude-hooks/enforce-gate-suites.EpicStateIsolation.Discovery.Tests.ps1: 356
D-LC docs/features/active/2026-10-15-hook-test-isolation-737-remainder-935/plan.2026-10-15T17-44.md: 219
```
