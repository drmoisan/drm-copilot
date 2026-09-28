# Phase 0 — Policy Instructions Read

Timestamp: 2026-09-08T09-36
Task: [P0-T1]
Command: (read-only inspection of policy files; no command executed)
EXIT_CODE: 0
ExpectedExitCode: 0

Policy Order: CLAUDE.md -> .github/copilot-instructions.md -> .claude/rules/general-code-change.md -> .claude/rules/general-unit-test.md -> .claude/rules/quality-tiers.md -> .claude/rules/shell.md -> .claude/rules/python.md -> .claude/rules/plan-acceptance-gates.md -> .claude/rules/tonality.md

Files read, in the order the plan names them:

1. `CLAUDE.md`
2. `.github/copilot-instructions.md`
3. `.claude/rules/general-code-change.md`
4. `.claude/rules/general-unit-test.md`
5. `.claude/rules/quality-tiers.md`
6. `.claude/rules/shell.md`
7. `.claude/rules/python.md`
8. `.claude/rules/plan-acceptance-gates.md`
9. `.claude/rules/tonality.md`

Output Summary: All nine policy files were located and read. Constraints carried into
execution: the bash toolchain is native (`bash scripts/bash/shell-qc.sh` with the stages
`format`, `check`, `test`, and `test --coverage`) and is run under WSL on Windows; kcov
measures line coverage only and the uniform line threshold is 85 percent; no production,
test, or reusable shell file may exceed 500 lines; tests must not create temporary files
and must drive checked-in fixtures through the documented stub seams; policy documents
under `.claude/rules/` and `.github/instructions/` are not modified; tone is professional,
factual, and neutral.
