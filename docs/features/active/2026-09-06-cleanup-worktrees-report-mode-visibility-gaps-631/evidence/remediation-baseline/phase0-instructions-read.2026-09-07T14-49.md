# Phase 0 — Policy Reads (remediation cycle 1, issue #631)

Timestamp: 2026-09-07T14-49

Policy Order:

1. `CLAUDE.md`
2. `.claude/rules/general-code-change.md`
3. `.claude/rules/general-unit-test.md`
4. `.claude/rules/quality-tiers.md`
5. `.claude/rules/shell.md`

## Files Read

- `CLAUDE.md` (56 lines) — repository tone policy, policy-compliance reading order, four-layer
  runtime architecture, orchestration checkpoint path.
- `.claude/rules/general-code-change.md` (80 lines) — design principles, module rigor tiers,
  the mandatory seven-stage toolchain loop, the **500-line file-size cap** on production, test,
  and reusable script files, error handling, naming, I/O boundaries.
- `.claude/rules/general-unit-test.md` (105 lines) — five core unit-test properties, the
  >= 85% line / >= 75% branch coverage requirements with the PowerShell/bash branch exemption,
  the **Coverage Exclusion Policy** (no production file may be excluded), the **Scenario
  Completeness** list (positive, negative, edge/boundary, error handling, concurrency, state
  transitions), Arrange-Act-Assert structure, the **prohibition on temporary files in tests**,
  and the `tests/` mirror-layout requirement.
- `.claude/rules/quality-tiers.md` (51 lines) — T1-T4 tier definitions, `quality-tiers.yml` as
  source of truth, the uniform-vs-tier-dependent gate matrix, the **uniform 85% line-coverage
  threshold across all tiers**, and the **bash branch-coverage exemption** (kcov does not
  measure branch coverage; the exemption is a capability limit, not a licence to exclude files
  from the denominator).
- `.claude/rules/shell.md` (93 lines) — the four-stage bash order
  (`format`, `check`, type-check not applicable, `test` / `test --coverage`), native bash
  invocation with no Python or Poetry dependency, the `SHELL_QC_<TOOL>_BIN` override seam, the
  discovery contract (`tools/`, `scripts/`, `.claude/lib/bash/`), the
  **`Bash coverage (lines): NN.N%`** summary line kcov prints, CI-vs-local version drift with
  CI as canonical, the 500-line shell file cap, and the requirement that tests use checked-in
  fixtures rather than temporary files.

## Binding Constraints Carried Into Execution

- 500-line cap on every shell file touched by this cycle.
- No temporary files or scratch git repositories in tests; checked-in fixtures and the
  `CLEANUP_WT_GIT_BIN` / `CLEANUP_WT_SCAN_BIN` / `CLEANUP_WT_ORPHAN_ROOTS` /
  `CLEANUP_WT_SCAN_GITFILE_NAME` stub seams only.
- No coverage exclusion, coverage suppression, or lint suppression added to make a gate pass.
- Bash toolchain order: format -> check -> test -> test --coverage; restart from stage 1 on any
  failure or file rewrite.
- Uniform >= 85.0% bash line coverage; no bash branch-coverage gate.

EXIT_CODE: 0
