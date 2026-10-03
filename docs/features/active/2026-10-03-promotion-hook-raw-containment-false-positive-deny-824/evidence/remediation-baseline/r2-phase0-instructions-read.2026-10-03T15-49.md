# r2 P0-T2 policy reads

Timestamp: 2026-10-03T15-49
Command: pwsh -NoProfile -File "SCRATCH/steps/r2-p0-t2.ps1" -Worktree "WORKTREE" (A0 only; prints the TS value)
EXIT_CODE: 0
Policy Order: CLAUDE.md, then .claude/rules/general-code-change.md, then .claude/rules/general-unit-test.md, then language- and domain-specific rules for the files in scope, then tone, plan-gate, evidence, and GitHub Actions policies.
Output Summary: all 14 policy files below were read in the listed order before any code or test change.

Files read, in order:

1. CLAUDE.md
2. .claude/rules/general-code-change.md
3. .claude/rules/general-unit-test.md
4. .claude/rules/quality-tiers.md
5. .claude/rules/powershell.md
6. .claude/rules/shell.md (a .sh and a .bats file change)
7. .claude/rules/python.md (the Python toolchain runs in final QC)
8. .claude/rules/python-suppressions.md
9. .claude/rules/typescript.md (the TypeScript toolchain runs in final QC)
10. .claude/rules/tonality.md
11. .claude/rules/plan-acceptance-gates.md
12. .claude/skills/evidence-and-timestamp-conventions/SKILL.md
13. .github/instructions/github-actions.instructions.md (WORKFLOW changes, D13)
14. .github/instructions/github-actions-ci-cd-best-practices.instructions.md (WORKFLOW changes, D13)

Not read: .claude/rules/csharp.md is not read because no C# file or C# policy file changes in this plan.
