# Phase 0 Policy Read Record (issue #990)

Timestamp: 2026-10-28T21-11
Policy Order: policy-compliance-order (CLAUDE.md, general code change, general unit test, language-specific rules)

Files read, in order:

1. `CLAUDE.md`
2. `.claude/rules/general-code-change.md`
3. `.claude/rules/general-unit-test.md`
4. `.claude/rules/quality-tiers.md`
5. `.claude/rules/powershell.md`
6. `.claude/rules/shell.md`
7. `.github/instructions/general-code-change.instructions.md`
8. `.github/instructions/general-unit-test.instructions.md`
9. `.github/instructions/powershell-code-change.instructions.md`
10. `.github/instructions/powershell-unit-test.instructions.md`

Notes:

- Policy-file edits in this plan (`.github/instructions/*`, `.claude/rules/*` mirrors) are covered by the user approval recorded in `issue.md` `## Constraints & Risks`.
- `quality-tiers.yml` exists at the repository root, so the tier rules apply; the new `.claude/lib/file-size-policy` project is classified in [P1-T3].
