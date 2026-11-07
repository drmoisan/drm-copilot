# Gate Rows - Issue 1034 Remediation Cycle 2 (P2-T4)

Timestamp: 2026-11-07T03-41
Command: sh SCRATCH/issue-1034-c2-suite-junit.sh p2t4 <nine suites> (Invoke-Pester with JUnit output to SCRATCH/issue-1034-c2-junit.xml; suites: enforce-docs-complete-gate, enforce-docs-complete-gate-compound, enforce-docs-complete-gate-target, hook-dependency-failure.Claude, hook-dependency-failure.SpecialCases, PreToolUsePayload.Contract, hook-dependency-guard-completeness, hook-imported-modules-no-stdout, enforcement-hooks-no-python-invocation)
EXIT_CODE: 0
Output Summary: PASS. JUnit: tests 1372, failures 0, errors 0, disabled 0. The row 'B1: PreToolUse .claude/hooks/enforce-docs-complete-gate.ps1 blocks naming enforce-docs-complete-gate-target.ps1 when that direct edge fails' is present with status Passed. New Contexts: integration checkout (F1) 3 passed; compound merge scope (F3) 63 passed; merge mentions 8 passed; the helper suite Contexts 115 passed in total.

## Per-file counts

- enforce-docs-complete-gate-compound.Tests.ps1 | total=71 passed=71 failed=0 other=0
- enforce-docs-complete-gate-target.Tests.ps1 | total=115 passed=115 failed=0 other=0
- enforce-docs-complete-gate.Tests.ps1 | total=149 passed=149 failed=0 other=0
- enforcement-hooks-no-python-invocation.Tests.ps1 | total=33 passed=33 failed=0 other=0
- hook-dependency-failure.Claude.Tests.ps1 | total=195 passed=195 failed=0 other=0
- hook-dependency-failure.SpecialCases.Tests.ps1 | total=15 passed=15 failed=0 other=0
- hook-dependency-guard-completeness.Tests.ps1 | total=683 passed=683 failed=0 other=0
- hook-imported-modules-no-stdout.Tests.ps1 | total=25 passed=25 failed=0 other=0
- PreToolUsePayload.Contract.Tests.ps1 | total=86 passed=86 failed=0 other=0

## Passed count per Context of the three gate suites

- enforce-docs-complete-gate-compound.Tests.ps1 :: compound merge scope (F3) | total=63 passed=63
- enforce-docs-complete-gate-compound.Tests.ps1 :: merge mentions | total=8 passed=8
- enforce-docs-complete-gate-target.Tests.ps1 :: Get-DocsCompleteGateMergeTarget | total=12 passed=12
- enforce-docs-complete-gate-target.Tests.ps1 :: Get-DocsCompleteGateUnquotedView | total=3 passed=3
- enforce-docs-complete-gate-target.Tests.ps1 :: Read-DocsCompleteGateMergeOperand | total=28 passed=28
- enforce-docs-complete-gate-target.Tests.ps1 :: Read-DocsCompleteGatePlainCommand | total=53 passed=53
- enforce-docs-complete-gate-target.Tests.ps1 :: Test-DocsCompleteGateMergeCandidate | total=19 passed=19
- enforce-docs-complete-gate.Tests.ps1 :: enforce-docs-complete-gate seams (issue #1034) | total=5 passed=5
- enforce-docs-complete-gate.Tests.ps1 :: entry point | total=2 passed=2
- enforce-docs-complete-gate.Tests.ps1 :: gate disabled | total=14 passed=14
- enforce-docs-complete-gate.Tests.ps1 :: gate enabled | total=20 passed=20
- enforce-docs-complete-gate.Tests.ps1 :: integration checkout (F1) | total=3 passed=3
- enforce-docs-complete-gate.Tests.ps1 :: merge target binding (F1) | total=86 passed=86
- enforce-docs-complete-gate.Tests.ps1 :: merge target controls | total=13 passed=13
- enforce-docs-complete-gate.Tests.ps1 :: payload anomaly | total=2 passed=2
- enforce-docs-complete-gate.Tests.ps1 :: read failures (F2) | total=4 passed=4
