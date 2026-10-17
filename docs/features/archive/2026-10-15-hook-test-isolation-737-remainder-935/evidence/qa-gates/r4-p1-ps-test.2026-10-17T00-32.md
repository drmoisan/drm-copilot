# R4 Phase 1 Local Test (P1-T5, issue #935)

Timestamp: 2026-10-17T00-32
Command: the commands listed below, each with its output (run from the worktree root; scripts under SCRATCH)
EXIT_CODE: 0

Output Summary:
One call: mcp__drm-copilot__run_poshqc_test with scan_folders [tests/scripts/claude-hooks]; disposition returned (stat pre 2026-10-16 20:22:59.479697800 -0400). A returned call means every row of P_BRS and P_HRS passed (the runtime raises when any test fails), including F-1 non-compliant ESR mock inside switch, F-1 non-compliant ESR mock inside foreach, F-1 non-compliant ESR mock inside while, F-1 non-compliant ESR mock inside trap, F-1 non-compliant ESR mock inside a matching Get-Command guard with else, F-1 non-compliant ESR mock inside a matching Get-Command guard with elseif, R1 does not identify unbalanced brace and every existing R1 identifies <Case> row. Every re-run acceptance command below prints its stated value (P_BRS D-LC 438, P_HRS D-LC 460, P_HRH D-LC 448).

```
MCP call: mcp__drm-copilot__run_poshqc_test scan_folders=[tests/scripts/claude-hooks] => returned (ok: true); no D-JUNIT-DIAG needed
stat -c %y artifacts/pester/pester-junit.xml (post) => 2026-10-16 20:31:45.964308200 -0400
Re-run acceptance commands:
== P1-T1 acceptance (P_BRS); expected: six new labels 1 each, Branch = ' 14, three existing labels 1 each, table 1, assertion 1, D-LC 438
1	tests/scripts/claude-hooks/enforce-gate-suites.EpicStateIsolation.Branches.Tests.ps1	grep -c -F -e [Branch = 'ESR mock inside switch']
1	tests/scripts/claude-hooks/enforce-gate-suites.EpicStateIsolation.Branches.Tests.ps1	grep -c -F -e [Branch = 'ESR mock inside foreach']
1	tests/scripts/claude-hooks/enforce-gate-suites.EpicStateIsolation.Branches.Tests.ps1	grep -c -F -e [Branch = 'ESR mock inside while']
1	tests/scripts/claude-hooks/enforce-gate-suites.EpicStateIsolation.Branches.Tests.ps1	grep -c -F -e [Branch = 'ESR mock inside trap']
1	tests/scripts/claude-hooks/enforce-gate-suites.EpicStateIsolation.Branches.Tests.ps1	grep -c -F -e [Branch = 'ESR mock inside a matching Get-Command guard with else']
1	tests/scripts/claude-hooks/enforce-gate-suites.EpicStateIsolation.Branches.Tests.ps1	grep -c -F -e [Branch = 'ESR mock inside a matching Get-Command guard with elseif']
14	tests/scripts/claude-hooks/enforce-gate-suites.EpicStateIsolation.Branches.Tests.ps1	grep -c -F -e [Branch = ']
1	tests/scripts/claude-hooks/enforce-gate-suites.EpicStateIsolation.Branches.Tests.ps1	grep -c -F -e [Branch = 'ESR mock inside try/catch']
1	tests/scripts/claude-hooks/enforce-gate-suites.EpicStateIsolation.Branches.Tests.ps1	grep -c -F -e [Branch = 'ESR mock inside a Get-Command guard naming another seam']
1	tests/scripts/claude-hooks/enforce-gate-suites.EpicStateIsolation.Branches.Tests.ps1	grep -c -F -e [Branch = 'ESR mock inside a matching Get-Command guard']
1	tests/scripts/claude-hooks/enforce-gate-suites.EpicStateIsolation.Branches.Tests.ps1	grep -c -F -e [It 'F-1 non-compliant <Branch>' -ForEach @(]
1	tests/scripts/claude-hooks/enforce-gate-suites.EpicStateIsolation.Branches.Tests.ps1	grep -c -F -e [Mock of Get-EpicScopeCheckpointText missing from outermost BeforeAll]
D-LC tests/scripts/claude-hooks/enforce-gate-suites.EpicStateIsolation.Branches.Tests.ps1: 438
== P1-T2 acceptance (P_HRS); expected: 1, 1, 1, 1, D-LC 460 (454 + 6; cumulative after P2-T10 is 466)
1	tests/scripts/claude-hooks/enforce-gate-suites.EpicStateIsolation.HookReference.Tests.ps1	grep -c -F -e [@{ Case = 'unbalanced brace'; Source = @']
1	tests/scripts/claude-hooks/enforce-gate-suites.EpicStateIsolation.HookReference.Tests.ps1	grep -c -F -e ["$HookRoot}/enforce-x.ps1"]
1	tests/scripts/claude-hooks/enforce-gate-suites.EpicStateIsolation.HookReference.Tests.ps1	grep -c -F -e [@{ Case = 'unbound variable'; Source = @']
1	tests/scripts/claude-hooks/enforce-gate-suites.EpicStateIsolation.HookReference.Tests.ps1	grep -c -F -e [It 'R1 does not identify <Case>' -ForEach @(]
D-LC tests/scripts/claude-hooks/enforce-gate-suites.EpicStateIsolation.HookReference.Tests.ps1: 460
== P1-T4 acceptance (P_HRH); expected: 1, 1, 0, 1, D-LC 448 (P0-T3 value)
1	tests/scripts/claude-hooks/EpicStateIsolation.HookReference.Helpers.ps1	grep -c -F -e [(?:]
1	tests/scripts/claude-hooks/EpicStateIsolation.HookReference.Helpers.ps1	grep -c -F -e [[A-Za-z0-9_]*)?))[]
0	tests/scripts/claude-hooks/EpicStateIsolation.HookReference.Helpers.ps1	grep -c -F -e [}?[]
1	tests/scripts/claude-hooks/EpicStateIsolation.HookReference.Helpers.ps1	grep -c -F -e ['ExpandableLeaf' {]
D-LC tests/scripts/claude-hooks/EpicStateIsolation.HookReference.Helpers.ps1: 448
```
