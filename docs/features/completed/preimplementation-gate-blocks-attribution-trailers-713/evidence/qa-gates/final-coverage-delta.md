# P5-T5 Coverage Delta

Timestamp: 2026-09-27T03-46
Pass: 1
Command: comparison of evidence/baseline/p0-scoped-coverage.md ([P0-T11]) and evidence/qa-gates/final-scoped-coverage.md ([P5-T4])
EXIT_CODE: 0
Output Summary: Both canonical helpers copies rose from 97.08% to 98.25% line coverage (both at least 85 and at least baseline). Changed-line coverage is 100% (5 of 5) for each copy. PowerShell has no branch-coverage gate (`.claude/rules/powershell.md`).

| Copy | Baseline (P0-T11) | Post-change (P5-T4) | Changed-line coverage |
| --- | --- | --- | --- |
| `.claude/hooks/enforce-orchestration-preimplementation-gate-helpers.ps1` | 97.08% (covered=166, missed=5; missed 357,406,412,464,481) | 98.25% (covered=168, missed=3; missed 357,464,481) | 100.00% (5 of 5 executed: lines 36, 140, 156, 402, 410) |
| `.codex/hooks/enforce-orchestration-preimplementation-gate-helpers.ps1` | 97.08% (covered=166, missed=5; missed 357,406,412,464,481) | 98.25% (covered=168, missed=3; missed 357,464,481) | 100.00% (5 of 5 executed: lines 36, 140, 156, 402, 410) |

Delta: +1.17 percentage points per copy. Lines 406 and 412 of `Test-ExemptOrchestrationSegmentToken` (the `return $false` for a dangling value-taking option, now reached by the dangling `--trailer` row, and the `$index++` of the equals-form branch, now reached by the `--trailer=` row) moved from missed to executed; no line moved from executed to missed.
