# P0-T2 Phase 0 policy reads

Timestamp: 2026-10-02T03-31
Policy Order: (1) tone; (2) general code change; (3) general unit test; (4) shell language rule; (5) tier and plan-acceptance gates; (6) evidence conventions. Order as stated in plan task P0-T2.

Files read (in this order, from the worktree checkout on branch bug/cleanup-worktrees-scan-roots-and-orphan-root-split-741 at df5eb303129a30289a7d81775fdadaa40631be63):

1. `.github/copilot-instructions.md` (8 lines)
2. `CLAUDE.md` (56 lines)
3. `.claude/rules/tonality.md` (80 lines)
4. `.github/instructions/general-code-change.instructions.md` (290 lines)
5. `.claude/rules/general-code-change.md` (80 lines)
6. `.github/instructions/general-unit-test.instructions.md` (106 lines)
7. `.claude/rules/general-unit-test.md` (105 lines)
8. `.claude/rules/shell.md` (94 lines)
9. `.claude/rules/quality-tiers.md` (51 lines)
10. `.claude/rules/plan-acceptance-gates.md` (257 lines)
11. `.claude/skills/evidence-and-timestamp-conventions/SKILL.md` (180 lines)

Key constraints noted for this plan:
- 500-line cap for production and test files; no temporary files in tests; Arrange-Act-Assert with a purpose comment per test.
- Shell toolchain order: shfmt, shellcheck, (no type check), bats; kcov line coverage >= 85%; no bash branch gate; CI tool versions are canonical.
- Evidence artifacts: canonical `<FEATURE>/evidence/<kind>/`; `Timestamp:` is local host time in yyyy-MM-ddTHH-mm form; `Command:`, `EXIT_CODE:`, `Output Summary:` per command-step artifact; `ExpectedExitCode:` for a non-zero expected exit.
- Tone: professional, factual, no hyperbole.
