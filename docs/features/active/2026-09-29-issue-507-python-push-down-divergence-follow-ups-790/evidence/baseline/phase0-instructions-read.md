# Phase 0 Policy Reads (P0-T2)

Timestamp: 2026-10-10T07-59
Policy Order: (1) standing instructions and tone; (2) general code change; (3) general unit test; (4) Python; (5) TypeScript; (6) quality tiers and plan acceptance gates; (7) evidence conventions. Files were read in full with the Read tool from the #790 worktree, in the order listed below.

Files read (20, in order):

1. `CLAUDE.md`
2. `.github/copilot-instructions.md`
3. `.claude/rules/tonality.md`
4. `.github/instructions/general-code-change.instructions.md`
5. `.claude/rules/general-code-change.md`
6. `.github/instructions/general-unit-test.instructions.md`
7. `.claude/rules/general-unit-test.md`
8. `.github/instructions/python-code-change.instructions.md`
9. `.github/instructions/python-unit-test.instructions.md`
10. `.github/instructions/python-suppressions.instructions.md`
11. `.claude/rules/python.md`
12. `.claude/rules/python-suppressions.md`
13. `.github/instructions/typescript-code-change.instructions.md`
14. `.github/instructions/typescript-unit-test.instructions.md`
15. `.github/instructions/typescript-suppressions.instructions.md`
16. `.claude/rules/typescript.md`
17. `.claude/rules/typescript-suppressions.md`
18. `.claude/rules/quality-tiers.md`
19. `.claude/rules/plan-acceptance-gates.md`
20. `.claude/skills/evidence-and-timestamp-conventions/SKILL.md`

Key constraints noted: 500-line file cap; no temporary files in tests; format -> lint -> type-check -> test loop with restart on change or failure; coverage line >= 85% and branch >= 75%; no regression on changed lines; suppressions only per pre-authorized patterns; evidence only under `<FEATURE>/evidence/<kind>/`; Timestamp read from host clock in `yyyy-MM-ddTHH-mm` form.
