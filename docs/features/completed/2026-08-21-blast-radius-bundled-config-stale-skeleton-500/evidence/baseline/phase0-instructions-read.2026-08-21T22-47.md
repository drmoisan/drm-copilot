# Phase 0 — Policy instructions read record (Issue #500)

Timestamp: 2026-08-21T22:47:28Z
Issue: #500
Task: [P0-T1]

Policy Order: The order mandated by `CLAUDE.md` ("Policy Compliance Reading Order") and by
`.claude/skills/policy-compliance-order/SKILL.md`. Repository tone and communication policy first,
then the baseline cross-language code-change and unit-test rules, then the language-specific
policies for every language in scope (Python, TypeScript, PowerShell), then the `.claude/rules/`
mirrors and the domain rules that govern this change set.

## Files read, in order

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

## Binding constraints carried forward

- 500-line ceiling on every production, test, and reusable script file.
- Toolchain loop order per language: format, lint, type-check (not applicable to PowerShell), test.
  Restart from formatting if any stage fails or rewrites a file.
- Coverage thresholds are uniform across T1-T4: line >= 85%, branch >= 75% for languages whose
  tooling measures branch coverage. Pester measures no branch coverage, so PowerShell carries the
  line threshold only.
- No production file may be excluded from coverage measurement.
- Bugfix workflow: failing regression test first, minimal targeted fix, then local verification.
- Evidence paths resolve to `<FEATURE>/evidence/<kind>/` only.

EXIT_CODE: 0
Output Summary: All 21 policy files listed above were read before any repository edit was made. No
conflicting instruction was encountered between the `.github/instructions/` sources and their
`.claude/rules/` mirrors.
