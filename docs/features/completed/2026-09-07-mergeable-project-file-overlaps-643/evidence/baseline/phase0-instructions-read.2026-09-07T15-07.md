# Phase 0 — Policy Read Record (issue #643, task [P0-T1])

- Timestamp: 2026-09-07T15:07Z
- Task: `[P0-T1]`
- Plan: `docs/features/active/2026-09-07-mergeable-project-file-overlaps-643/plan.2026-09-07T08-13.md`
- Repository root (worktree): `C:\Users\DanMoisan\repos\drm-copilot-wt\2026-09-07T08-09`
- Branch: `feature/mergeable-project-file-overlaps-643`
- Command: `cat` on each path listed below, read in the stated order from the worktree root
- EXIT_CODE: 0

## Policy Order

The reading order is the one mandated by `CLAUDE.md` ("Policy Compliance Reading Order") and by
`.claude/skills/policy-compliance-order/SKILL.md` ("Required Policy Reading Order (Baseline)"):
repository tone policy first, then the baseline cross-language code-change and unit-test policies,
then the language-specific policies for every language in scope (Python, TypeScript, PowerShell),
then the `.claude/rules/` mirrors and the domain rules that govern this feature, then the skills
that bind plan format, evidence location, and acceptance-criteria tracking.

## Files Read, In Order

1. `.github/copilot-instructions.md`
2. `.github/instructions/general-code-change.instructions.md`
3. `.github/instructions/general-unit-test.instructions.md`
4. `.github/instructions/python-code-change.instructions.md`
5. `.github/instructions/python-unit-test.instructions.md`
6. `.github/instructions/typescript-code-change.instructions.md`
7. `.github/instructions/typescript-unit-test.instructions.md`
8. `.github/instructions/powershell-code-change.instructions.md`
9. `.github/instructions/powershell-unit-test.instructions.md`
10. `.claude/rules/general-code-change.md`
11. `.claude/rules/general-unit-test.md`
12. `.claude/rules/quality-tiers.md`
13. `.claude/rules/parallel-orchestration.md`
14. `.claude/rules/plan-acceptance-gates.md`
15. `.claude/rules/python.md`
16. `.claude/rules/python-suppressions.md`
17. `.claude/rules/typescript.md`
18. `.claude/rules/typescript-suppressions.md`
19. `.claude/rules/powershell.md`
20. `.claude/rules/self-explanatory-code-commenting.md`
21. `.claude/rules/tonality.md`
22. `.claude/skills/atomic-plan-contract/SKILL.md`
23. `.claude/skills/evidence-and-timestamp-conventions/SKILL.md`
24. `.claude/skills/acceptance-criteria-tracking/SKILL.md`

## Output Summary

All 24 files above were read in the listed order. Constraints carried forward into execution:

- Toolchain order is format, lint, type-check, test per language, restarting from step 1 on any
  failure or file rewrite (`.github/instructions/general-code-change.instructions.md` section 8).
- The 500-line ceiling applies to production code, test code, and reusable scripts; Markdown and
  raw text fixtures are exempt (`.claude/rules/general-code-change.md`).
- Coverage thresholds are uniform across T1-T4: line/statement >= 85%, branch >= 75% where the
  tooling measures branches. Pester measures no branch coverage, so no PowerShell branch gate
  applies (`.claude/rules/quality-tiers.md`, `.claude/rules/powershell.md`).
- Temporary files in tests are prohibited (`.claude/rules/general-unit-test.md`).
- Python suppressions and TypeScript suppressions require a pre-authorized pattern or explicit user
  approval (`.claude/rules/python-suppressions.md`, `.claude/rules/typescript-suppressions.md`).
- PowerShell toolchain runs through the MCP PoshQC functions; per-batch change budget is 3
  production and 3 test PowerShell files (`.claude/rules/powershell.md`), which plan constraint C9
  governs for this execution.
- Python docstring and intent-comment requirements apply to every new function, loop, and branch
  (`.claude/rules/self-explanatory-code-commenting.md`).
- Evidence resolves to `<FEATURE>/evidence/<kind>/` with `Timestamp:`, `Command:`, `EXIT_CODE:`,
  and `Output Summary:` on every command-step artifact
  (`.claude/skills/evidence-and-timestamp-conventions/SKILL.md`).
- Acceptance criteria are checked off only after verification, changing `- [ ]` to `- [x]` and
  never editing criterion text (`.claude/skills/acceptance-criteria-tracking/SKILL.md`).
- Tone is professional, factual, and neutral in every artifact and report
  (`.github/copilot-instructions.md`, `.claude/rules/tonality.md`).
