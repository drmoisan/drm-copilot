# Phase 0 Policy Read — [P0-T1]

Timestamp: 2026-09-07T10-56
Plan: docs/features/active/2026-08-31-portable-prepared-orchestration-handoff-614/remediation-plan.2026-09-07T03-16.md
Task: [P0-T1]
Head: fca8c0455dd7207b21096e70fe7ffbf8cfc56ca1

Policy Order: standing instructions first (`CLAUDE.md`), then the repository tone policy, then the cross-language code-change and unit-test baselines, then the language-specific instruction files for every language this plan touches (TypeScript, PowerShell, Python) with their suppression policies, then the mirrored `.claude/rules/` files in the same precedence, then the tier, architecture-boundary, plan-acceptance-gate, and tonality rules. Where a `.claude/rules/` file mirrors a `.github/instructions/` file, the `.github/` file is authoritative.

Files read, in the order read (21):

1. `CLAUDE.md`
2. `.github/copilot-instructions.md`
3. `.github/instructions/general-code-change.instructions.md`
4. `.github/instructions/general-unit-test.instructions.md`
5. `.github/instructions/typescript-code-change.instructions.md`
6. `.github/instructions/typescript-unit-test.instructions.md`
7. `.github/instructions/typescript-suppressions.instructions.md`
8. `.github/instructions/powershell-code-change.instructions.md`
9. `.github/instructions/powershell-unit-test.instructions.md`
10. `.github/instructions/python-code-change.instructions.md`
11. `.github/instructions/python-unit-test.instructions.md`
12. `.claude/rules/general-code-change.md`
13. `.claude/rules/general-unit-test.md`
14. `.claude/rules/typescript.md`
15. `.claude/rules/typescript-suppressions.md`
16. `.claude/rules/powershell.md`
17. `.claude/rules/python.md`
18. `.claude/rules/quality-tiers.md`
19. `.claude/rules/architecture-boundaries.md`
20. `.claude/rules/plan-acceptance-gates.md`
21. `.claude/rules/tonality.md`

Command: `for f in <the 21 paths above>; do test -f "$f" && wc -l < "$f"; done` (existence and line-count confirmation), followed by `cat` of each path.
EXIT_CODE: 0

Output Summary: All 21 policy paths exist and were read. Line counts observed: CLAUDE.md 56; copilot-instructions.md 8; general-code-change.instructions.md 290; general-unit-test.instructions.md 106; typescript-code-change.instructions.md 203; typescript-unit-test.instructions.md 112; typescript-suppressions.instructions.md 157; powershell-code-change.instructions.md 81; powershell-unit-test.instructions.md 69; python-code-change.instructions.md 232; python-unit-test.instructions.md 71; general-code-change.md 80; general-unit-test.md 105; typescript.md 74; typescript-suppressions.md 66; powershell.md 97; python.md 100; quality-tiers.md 51; architecture-boundaries.md 46; plan-acceptance-gates.md 257; tonality.md 80. Constraints carried into execution: the 500-line file-size limit applies to every file this plan touches; PowerShell toolchain steps must run through the MCP PoshQC functions and not through task wrappers; TypeScript work uses Prettier, ESLint, tsc, and Jest in that order; no suppression outside the two pre-authorized single-line patterns; no temporary files in tests; uniform coverage floors of 85% line and 75% branch where the tooling measures branch.
