# Phase 0 Policy Read (P0-T1)

Timestamp: 2026-09-30T13-44
Task: [P0-T1]
Branch: bug/promotion-gate-lacks-preexisting-issue-branch-exec-509 (orchestrator branch substitution; see git-baseline artifact)
Location: worktree root
Policy Order: CLAUDE.md -> general code change -> general unit test -> language-specific (Python, PowerShell, TypeScript) -> quality tiers -> orchestrator-state checkpoint contract -> plan acceptance gates -> tonality

Files read, in this order (repository-relative; each read in full with the Read tool from the worktree root):

1. `CLAUDE.md` (56 lines)
2. `.claude/rules/general-code-change.md` (80 lines)
3. `.claude/rules/general-unit-test.md` (105 lines)
4. `.claude/rules/python.md` (100 lines)
5. `.claude/rules/python-suppressions.md` (143 lines)
6. `.claude/rules/powershell.md` (97 lines)
7. `.claude/rules/typescript.md` (74 lines)
8. `.claude/rules/typescript-suppressions.md` (66 lines)
9. `.claude/rules/quality-tiers.md` (51 lines)
10. `.claude/rules/orchestrator-state.md` (163 lines)
11. `.claude/rules/plan-acceptance-gates.md` (257 lines)
12. `.claude/rules/tonality.md` (80 lines)

Command: wc -l over the twelve paths above (line counts recorded in the list)
EXIT_CODE: 0
Output Summary: All twelve policy files exist and were read in the stated order; 1272 lines total. Key constraints noted: 500-line file limit; line coverage >= 85% and branch >= 75% (PowerShell line only); no temporary files in tests; toolchain loop format -> lint -> type-check -> test; no edits to `.claude/rules/` except the plan's orchestrator-authorized additive P7-T1 edit.
