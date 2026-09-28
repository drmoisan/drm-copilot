# Phase 0 policy read — remediation cycle 3

Timestamp: 2026-09-09T00-00

Task: [P0-T1]

Policy Order: the four files below were read in the order listed, which is the order
`.claude/skills/policy-compliance-order` and `CLAUDE.md` prescribe for a shell-only change
set: repository tone policy, baseline code-change policy, baseline unit-test policy, then
the language-specific rule file for the files in scope (`scripts/bash/**`, `tests/shell/**`,
`tests/fixtures/cleanup_worktrees/**`).

Files read:

1. `.github/copilot-instructions.md`
2. `.github/instructions/general-code-change.instructions.md`
3. `.github/instructions/general-unit-test.instructions.md`
4. `.claude/rules/shell.md`

Command: `cat` on each of the four paths above, in the order listed.

EXIT_CODE: 0

Output Summary: all four files were read in full. The constraints they impose that bound
this cycle's work:

- Tone: strictly professional, factual, neutral; no humor, hyperbole, or metaphor
  (`.github/copilot-instructions.md`).
- Bugfix workflow: a failing regression test comes first, then the minimal targeted fix,
  then the full toolchain in order
  (`.github/instructions/general-code-change.instructions.md`). This plan's Phase 1
  (fixture plus failing tests plus the fail-before record) and Phase 2 (the library fix)
  follow that sequence.
- No temporary files in tests; checked-in fixtures only
  (`.github/instructions/general-unit-test.instructions.md`, section 4).
- Shell toolchain order: `shfmt` format, `shellcheck` lint, no type-check stage, `bats`
  test; restart from step 1 if any stage rewrites files (`.claude/rules/shell.md`).
- No production, test, or reusable shell file may exceed 500 lines
  (`.claude/rules/shell.md`, Coding Standards).
- Tests live under `tests/shell/*.bats` and mirror `scripts/bash/`; stub binaries are
  checked in and wired through an override seam (`.claude/rules/shell.md`).
- kcov measures line coverage only; the uniform 85% line threshold applies and there is no
  bash branch-coverage gate (`.claude/rules/shell.md`, Coverage Expectations).
