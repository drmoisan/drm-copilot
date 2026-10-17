# Phase 0 Policy Read Record (#762)

Timestamp: 2026-09-28T21-52
Policy Order: CLAUDE.md -> .github copilot/tone policy -> .github general and language instructions -> .claude general rules -> .claude language rules (per plan P0-T1 through P0-T4 and the policy-compliance-order skill)
Plan: docs/features/active/2026-09-28-skill-referenced-scripts-not-bundled-762/plan.2026-09-28T23-50.md

## Files Read (reading order)

1. CLAUDE.md (P0-T1)
2. .github/copilot-instructions.md (P0-T1)
3. .github/instructions/general-code-change.instructions.md (P0-T2)
4. .github/instructions/general-unit-test.instructions.md (P0-T2)
5. .github/instructions/python-code-change.instructions.md (P0-T2)
6. .github/instructions/python-unit-test.instructions.md (P0-T2)
7. .github/instructions/powershell-code-change.instructions.md (P0-T2)
8. .github/instructions/powershell-unit-test.instructions.md (P0-T2)
9. .claude/rules/general-code-change.md (P0-T3)
10. .claude/rules/general-unit-test.md (P0-T3)
11. .claude/rules/quality-tiers.md (P0-T3)
12. .claude/rules/tonality.md (P0-T3)
13. .claude/rules/plan-acceptance-gates.md (P0-T3)
14. .claude/rules/python.md (P0-T4)
15. .claude/rules/python-suppressions.md (P0-T4)
16. .claude/rules/self-explanatory-code-commenting.md (P0-T4)
17. .claude/rules/powershell.md (P0-T4)
18. .claude/rules/shell.md (P0-T4)

Total files read: 18

## Notes

- Coverage thresholds applied: line >= 85% (all languages), branch >= 75% (Python only; Pester and kcov measure no branch coverage).
- File-size limit: 500 lines for production, test, and reusable script files.
- `.claude/rules/shell.md` and its bundle mirror are edited in P5-T5/P5-T6 under the operator-directed exception recorded in the plan (orchestrator decision OQ1). No other policy file is written.
