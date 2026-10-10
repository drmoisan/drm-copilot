# Phase 0 Policy Read Record (Issue #543)

Timestamp: 2026-10-10T08-00
Task: [P0-T1]
Policy Order: CLAUDE.md -> .github policy (general, Python, TypeScript) -> .claude/rules (general, Python, TypeScript, tiers, tonality, plan gates) -> evidence conventions

Files Read:
1. CLAUDE.md
2. .github/copilot-instructions.md
3. .github/instructions/general-code-change.instructions.md
4. .github/instructions/general-unit-test.instructions.md
5. .github/instructions/python-code-change.instructions.md
6. .github/instructions/python-unit-test.instructions.md
7. .github/instructions/python-suppressions.instructions.md
8. .github/instructions/typescript-code-change.instructions.md
9. .github/instructions/typescript-unit-test.instructions.md
10. .github/instructions/typescript-suppressions.instructions.md
11. .claude/rules/general-code-change.md
12. .claude/rules/general-unit-test.md
13. .claude/rules/python.md
14. .claude/rules/python-suppressions.md
15. .claude/rules/typescript.md
16. .claude/rules/typescript-suppressions.md
17. .claude/rules/quality-tiers.md
18. .claude/rules/tonality.md
19. .claude/rules/plan-acceptance-gates.md
20. .claude/skills/evidence-and-timestamp-conventions/SKILL.md

Notes:
- All twenty files were read from the worktree checkout on branch `bug/epic-planner-topology-receipt-gate-543`.
- Applicable constraints carried into execution: 500-line file limit; line coverage >= 85% and branch coverage >= 75%; no temporary files in tests; Arrange-Act-Assert structure; suppressions only per pre-authorized patterns; full toolchain loop with restart on failure or file change; evidence under `<FEATURE>/evidence/<kind>/`.
