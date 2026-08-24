# Phase 0 — Policy Compliance Reading Evidence

Timestamp: 2026-08-20T09-53

Task: [P0-T1]
Feature: #485 — pr-context verification cannot express expected non-zero exit
Worktree: C:/Users/DanMoisan/repos/drm-copilot/.claude/worktrees/agent-ad8da196d6247bdf4
Branch: bug/pr-context-verification-cannot-express-expected-nonzero-exit-485

Policy Order: `policy-compliance-order` skill sequence — standing instructions, then cross-language
code-change policy, then cross-language unit-test policy, then the language-specific rules for the
languages in scope (Python and TypeScript), then the tier map.

## Files read, in the stated order

1. `CLAUDE.md` (59 lines) — repository tone policy, policy-compliance reading order, four-layer runtime architecture.
2. `.claude/rules/general-code-change.md` (80 lines) — design principles, seven-stage mandatory toolchain loop, 500-line file limit, error handling, naming, I/O boundaries.
3. `.claude/rules/general-unit-test.md` (105 lines) — five core test properties, uniform coverage requirements (line >= 85%, branch >= 75%), coverage exclusion policy, temporary-file prohibition, test-file location rule (mirroring `tests/` tree).
4. `.claude/rules/python.md` (100 lines) — Black / Ruff / Pyright / pytest toolchain and command forms, PEP 8 naming, dataclass and typing standards, pytest rules, coverage-regression-on-changed-lines as a blocking finding.
5. `.claude/rules/python-suppressions.md` (143 lines) — pre-authorized `# noqa` and `# type: ignore` patterns and the escalation path before requesting approval.
6. `.claude/rules/typescript.md` (74 lines) — Prettier / ESLint / tsc / Jest toolchain and command forms, ES-module requirement, naming, testing standards, uniform coverage thresholds.
7. `.claude/rules/typescript-suppressions.md` (66 lines) — pre-authorized single-line `eslint-disable-next-line` and `@ts-expect-error` patterns; file-level disables and `@ts-ignore` prohibited.
8. `.claude/rules/quality-tiers.md` (51 lines) — T1-T4 tier definitions, uniform-versus-tier-dependent gate matrix, rationale for uniform coverage thresholds.

## Constraints carried forward into execution

- Full toolchain loop is mandatory for both Python and TypeScript, restarting from formatting on any
  failure or any file rewrite (`general-code-change.md`, `python.md`, `typescript.md`).
- No production, test, or reusable script file may exceed 500 lines; throwaway agent-session scripts
  are the only exception (`general-code-change.md`).
- Temporary files are prohibited in tests (`general-unit-test.md`); Python tests use the repository
  `mem_fs_path` fixture and TypeScript tests use the in-memory filesystem doubles.
- Coverage: line >= 85%, branch >= 75%, uniform across tiers; regression on changed lines is blocking.
- No policy document under `.claude/rules/` or `.github/instructions/` is modified by this plan.

EXIT_CODE: 0

Output Summary: All eight policy files listed above were read in the stated `policy-compliance-order`
sequence. Line counts were confirmed with `wc -l`. No policy file was modified.
