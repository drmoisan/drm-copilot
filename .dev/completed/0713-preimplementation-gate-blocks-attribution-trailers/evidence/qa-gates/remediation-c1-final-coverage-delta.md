# Remediation Cycle 1 - Final Coverage Delta ([P4-T5])

Timestamp: 2026-09-27T05-24

Command: comparison of `evidence/remediation-baseline/remediation-c1-scoped-coverage.md` ([P0-T8]) with `evidence/qa-gates/remediation-c1-final-scoped-coverage.md` ([P4-T4], pass 1)

EXIT_CODE: 0

Output Summary: `.claude` copy 98.25% (168/171) -> 98.26% (169/172); `.codex` copy 98.25% (168/171) -> 98.26% (169/172). Each post-change percent is at least 85 and at least its baseline. Changed-line coverage is 100% (7 of 7) for each copy. PowerShell has no branch-coverage gate (`.claude/rules/powershell.md`). Result: PASS.

| Copy | Baseline | Post-change | Changed-line coverage |
| --- | --- | --- | --- |
| `.claude/hooks/enforce-orchestration-preimplementation-gate-helpers.ps1` | 98.25% (covered=168, missed=3) | 98.26% (covered=169, missed=3) | 7/7 executed = 100% |
| `.codex/hooks/enforce-orchestration-preimplementation-gate-helpers.ps1` | 98.25% (covered=168, missed=3) | 98.26% (covered=169, missed=3) | 7/7 executed = 100% |

Missed lines are unchanged in both runs: 357, 464, 481. The added covered command is line 36 (`$script:TypographicQuoteCharacters` constant); the E3 condition on line 131 is executed. The baseline recorded five CHANGED_LINE entries per copy because the two cycle-1 literals did not yet exist in the file.
