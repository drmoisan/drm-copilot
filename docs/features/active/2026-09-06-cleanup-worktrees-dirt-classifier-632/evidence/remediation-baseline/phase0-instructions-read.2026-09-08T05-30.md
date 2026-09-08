# Phase 0 — Policy Instructions Read

Timestamp: 2026-09-08T04-56

Task: [P0-T1] of `remediation-plan.2026-09-08T05-00.md`

Policy Order:

1. `CLAUDE.md`
2. `.claude/rules/general-code-change.md`
3. `.claude/rules/general-unit-test.md`
4. `.claude/rules/shell.md`
5. `.claude/rules/quality-tiers.md`
6. `.claude/rules/tonality.md`

Files read (six, in the order above):

- `CLAUDE.md` — repository standing instructions, tone policy pointer, policy compliance
  reading order, four-layer runtime architecture.
- `.claude/rules/general-code-change.md` — design principles, mandatory seven-stage toolchain
  loop, 500-line file size limit, error handling, I/O boundaries.
- `.claude/rules/general-unit-test.md` — five core unit-test properties, uniform coverage
  thresholds (line >= 85%), coverage exclusion policy, prohibition on temporary files in
  tests, test file location rules.
- `.claude/rules/shell.md` — bash toolchain order (`shfmt`, `shellcheck`, `bats`, `kcov`),
  the `SHELL_QC_<TOOL>_BIN` override seam, the discovery contract, coverage expectations
  (kcov line coverage only, no bash branch gate), and the 500-line shell file cap.
- `.claude/rules/quality-tiers.md` — T1-T4 tier system, uniform-versus-tier-dependent gate
  matrix, uniform line-coverage floor of 85% and the PowerShell/bash branch-coverage
  exemption.
- `.claude/rules/tonality.md` — required professional tone; prohibitions on humor,
  hyperbole, and decorative metaphor; evidence-first wording.

Constraints carried into execution:

- No production shell file may reach 500 lines. `scripts/bash/cleanup_worktrees_lib.sh` is
  excluded from modification by Binding Constraint 1 of the plan.
- No temporary files in tests; every new scenario is a checked-in fixture directory.
- Every `.claude/**` edit mirrors byte-identically into
  `extensions/drm-copilot/resources/claude-customizations/.claude/**`.
- Evidence resolves only under
  `docs/features/active/2026-09-06-cleanup-worktrees-dirt-classifier-632/evidence/<kind>/`.

Output Summary: All six policy files were read in the stated order. No policy file was
modified. The shell rule confirms the toolchain split this plan's Gate Ownership section
records: `shfmt`, `shellcheck`, and `bats` are locally runnable through
`scripts/bash/shell-qc.sh`, and `kcov` coverage is measured in CI.
