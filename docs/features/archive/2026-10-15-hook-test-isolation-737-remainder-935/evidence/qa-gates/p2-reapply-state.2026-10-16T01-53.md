# Phase 2 Reapplied State (P2-T3)

Timestamp: 2026-10-16T01-53
Command: sh SCRATCH/935/issue-935/p2t3.sh (runs `grep -c -F -e <token> <file>` and `awk 'END { print NR }' <file>` in tests/scripts/claude-hooks)
EXIT_CODE: 0

Output Summary: every count meets its stated value; every line count is at or below 500. PASS.

| File | Token | Count | Expected |
| --- | --- | --- | --- |
| EpicStateIsolation.Helpers.ps1 | `function Test-EpicStateIsolationConditionalAncestor` | 1 | 1 |
| EpicStateIsolation.Helpers.ps1 | `no dot-source loads the hook` | 1 | at least 1 |
| enforce-gate-suites.EpicStateIsolation.Branches.Tests.ps1 | `Describe 'issue #903 F-1 conditional ancestors'` | 1 | 1 |
| enforce-gate-suites.EpicStateIsolation.Branches.Tests.ps1 | `hooks/enforce-x.ps1'` | 12 | 12 |
| enforce-gate-suites.EpicStateIsolation.Predicate.Tests.ps1 | `hooks/enforce-x.ps1'` | 10 | 10 |
| enforce-gate-suites.EpicStateIsolation.Tests.ps1 | `hooks/enforce-x.ps1'` | 12 | 12 |

| File | Lines | Limit |
| --- | --- | --- |
| EpicStateIsolation.Helpers.ps1 | 496 | 496 (no drift recorded by P0-T5) |
| enforce-gate-suites.EpicStateIsolation.Branches.Tests.ps1 | 335 | at most 340 |
| enforce-gate-suites.EpicStateIsolation.Predicate.Tests.ps1 | 288 | at most 290 |
| enforce-gate-suites.EpicStateIsolation.Tests.ps1 | 362 | at most 365 |
