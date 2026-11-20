# Phase 0 Policy Reads (#647)

Timestamp: 2026-10-01T23-18
Policy Order: CLAUDE.md -> .github/copilot-instructions.md -> general code change -> general unit test -> TypeScript code change and unit test -> GitHub Actions -> .claude/rules/ mirrors (general-code-change, general-unit-test, typescript, typescript-suppressions, ci-workflows)

Files read:

1. CLAUDE.md
2. .github/copilot-instructions.md
3. .github/instructions/general-code-change.instructions.md
4. .github/instructions/general-unit-test.instructions.md
5. .github/instructions/typescript-code-change.instructions.md
6. .github/instructions/typescript-unit-test.instructions.md
7. .github/instructions/github-actions.instructions.md
8. .claude/rules/general-code-change.md
9. .claude/rules/general-unit-test.md
10. .claude/rules/typescript.md
11. .claude/rules/typescript-suppressions.md
12. .claude/rules/ci-workflows.md

Output Summary: 12 policy files read in the CLAUDE.md order. Constraints carried into execution: no suppressions or `any`, ES modules only, no temporary files in tests, 500-line file limit, format -> lint -> type-check -> test loop, workflow must pass actionlint.
