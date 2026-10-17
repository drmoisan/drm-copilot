# Phase 0 Policy Reads (issue #763)

Timestamp: 2026-09-29T17-39
Policy Order: CLAUDE.md, general code-change, general unit-test, then language rules for Python, PowerShell, shell, TypeScript

Plan: docs/features/active/2026-09-28-parallel-skills-invoke-unbundled-python-clis-763/plan.2026-09-29T14-14.md
Tasks: P0-T1 through P0-T5

## Files read, in reading order (27)

P0-T1:
1. CLAUDE.md
2. .github/copilot-instructions.md
3. .github/instructions/tonality.instructions.md

P0-T2:
4. .github/instructions/general-code-change.instructions.md
5. .github/instructions/general-unit-test.instructions.md
6. .github/instructions/self-explanatory-code-commenting.instructions.md

P0-T3:
7. .github/instructions/python-code-change.instructions.md
8. .github/instructions/python-unit-test.instructions.md
9. .github/instructions/python-suppressions.instructions.md
10. .github/instructions/powershell-code-change.instructions.md
11. .github/instructions/powershell-unit-test.instructions.md
12. .github/instructions/typescript-code-change.instructions.md
13. .github/instructions/typescript-unit-test.instructions.md
14. .github/instructions/typescript-suppressions.instructions.md

P0-T4:
15. .claude/rules/general-code-change.md
16. .claude/rules/general-unit-test.md
17. .claude/rules/quality-tiers.md
18. .claude/rules/tonality.md
19. .claude/rules/plan-acceptance-gates.md
20. .claude/rules/self-explanatory-code-commenting.md

P0-T5:
21. .claude/rules/python.md
22. .claude/rules/python-suppressions.md
23. .claude/rules/powershell.md
24. .claude/rules/shell.md
25. .claude/rules/typescript.md
26. .claude/rules/typescript-suppressions.md
27. .claude/rules/parallel-orchestration.md

## Notes

- Every file was read in full from the worktree. Items 15-18 were additionally confirmed byte-identical
  (cmp) to the copies loaded as session instructions.
- Key constraints carried forward: 500-line file limit; no temporary files in tests; line coverage
  >= 85% for every language and branch coverage >= 75% for Python; no regression on changed lines;
  PowerShell toolchain through the PoshQC MCP functions (route-compliance) with values read from
  on-disk XML per the plan; shell toolchain shfmt, shellcheck, bats; Python black, ruff, pyright,
  pytest.
