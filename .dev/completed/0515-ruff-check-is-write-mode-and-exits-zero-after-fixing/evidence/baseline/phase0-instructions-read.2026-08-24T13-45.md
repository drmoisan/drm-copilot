# Phase 0 — Policy Instructions Read (P0-T1)

Timestamp: 2026-08-24T13-45

Task: [P0-T1]
Issue: #515
Work Mode: full-bug
Plan: `docs/features/active/2026-08-23-ruff-check-is-write-mode-and-exits-zero-after-fixing-515/plan.2026-08-23T23-21.md`

Policy Order: The order defined by `.claude/skills/policy-compliance-order/SKILL.md` — standing instructions first (`CLAUDE.md`), then the cross-language code-change policy, then the cross-language unit-test policy, then the language-specific rules for the files in scope (Python), followed by the two additional rule files this plan's tasks depend on (`quality-tiers.md` for the coverage thresholds asserted in P4-T5, and `plan-acceptance-gates.md` for the acceptance-condition authoring rules this plan's conditions were written against).

Files read, in order:

1. `CLAUDE.md` (59 lines)
2. `.claude/rules/general-code-change.md` (80 lines)
3. `.claude/rules/general-unit-test.md` (105 lines)
4. `.claude/rules/python.md` (100 lines)
5. `.claude/rules/python-suppressions.md` (143 lines)
6. `.claude/rules/quality-tiers.md` (51 lines)
7. `.claude/rules/plan-acceptance-gates.md` (116 lines)

Command: `wc -l CLAUDE.md .claude/rules/general-code-change.md .claude/rules/general-unit-test.md .claude/rules/python.md .claude/rules/python-suppressions.md .claude/rules/quality-tiers.md .claude/rules/plan-acceptance-gates.md`

EXIT_CODE: 0

Output Summary: All seven policy files are present in the worktree and were read in the order listed above. Line counts confirming presence: 59, 80, 105, 100, 143, 51, 116 (654 total). Constraints carried forward into execution from these reads:

- `CLAUDE.md` and `.claude/skills/policy-compliance-order/SKILL.md` prohibit modifying any document under `.claude/rules/` or `.github/instructions/`. This plan's scope lock is consistent with that prohibition; no task writes such a file.
- `.claude/rules/general-code-change.md` mandates the seven-stage toolchain in order (format, lint, type-check, architecture, unit test, contract, integration) with a restart from stage 1 if any stage fails or auto-fixes a file, and caps any file at 500 lines. Phase 4 implements the Python legs of that loop.
- `.claude/rules/general-unit-test.md` requires tests to live in a `tests/` tree mirroring production structure, prohibits temporary files in tests, prohibits dependence on external processes, and holds line coverage at >= 85% and branch coverage at >= 75%. The Phase 1 module asserts on committed text only and spawns no process, satisfying all three prohibitions.
- `.claude/rules/python.md` fixes the Python toolchain as `poetry run black`, `poetry run ruff check`, `poetry run pyright`, `poetry run pytest --cov --cov-branch --cov-report=term-missing`, run in that order with a restart on any failure or file change.
- `.claude/rules/python-suppressions.md` requires every `# noqa` or `# type: ignore` to match a pre-authorized pattern or carry explicit user approval. The Phase 1 module introduces no suppression.
- `.claude/rules/quality-tiers.md` fixes the uniform thresholds this plan's P4-T5 asserts: line coverage >= 85%, branch coverage >= 75%, no regression on changed lines.
- `.claude/rules/plan-acceptance-gates.md` fixes the acceptance-condition authoring rules (dotted `--cov=` form with the `=` spelling; wrap-tolerant, single-line, non-interpolated asserted literals; named tests preferred over phrase searches). This plan's conditions already conform; no executor deviation is required.

Additional execution-relevant note recorded at read time: because `pyproject.toml` currently enables Ruff fix mode, the read-only lint form `poetry run ruff check --no-fix` is used for every pre-Phase-2 lint invocation this plan names, and no write-mode formatting or fixing command is run at any point in Phase 0 or Phase 1.
