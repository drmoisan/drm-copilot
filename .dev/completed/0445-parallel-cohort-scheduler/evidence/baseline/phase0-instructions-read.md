# Phase 0 — Policy Compliance Read Evidence

Timestamp: 2026-08-07T14-17

Task: [P0-T1]
Plan: `docs/features/active/2026-08-07-parallel-cohort-scheduler-445/plan.2026-08-07T11-11.md`
Branch: `feature/parallel-cohort-scheduler-445`

Policy Order: `CLAUDE.md` -> `.claude/rules/general-code-change.md` -> `.claude/rules/general-unit-test.md` -> `.claude/rules/python.md` -> `.claude/rules/python-suppressions.md` -> `.claude/rules/self-explanatory-code-commenting.md` -> `.claude/rules/quality-tiers.md`

## Files Read (in order)

1. `CLAUDE.md`
2. `.claude/rules/general-code-change.md`
3. `.claude/rules/general-unit-test.md`
4. `.claude/rules/python.md`
5. `.claude/rules/python-suppressions.md`
6. `.claude/rules/self-explanatory-code-commenting.md`
7. `.claude/rules/quality-tiers.md`

All seven files were read in full before any Phase 1 task began. The order matches the
`policy-compliance-order` skill as specialized for a Python-only change set, and matches the
`## Required References` section of the approved plan.

## Constraints Extracted for This Feature

- Toolchain order for Python is format (`poetry run black .`) -> lint (`poetry run ruff check .`)
  -> type-check (`poetry run pyright`) -> test (`poetry run pytest --cov --cov-branch --cov-report=term-missing`),
  restarting from step 1 whenever a step fails or changes files
  (`.claude/rules/python.md`, `.claude/rules/general-code-change.md`).
- Coverage thresholds are uniform across tiers: line >= 85%, branch >= 75%
  (`.claude/rules/quality-tiers.md`, `.claude/rules/general-unit-test.md`).
- No production, test, or reusable script file may exceed 500 lines
  (`.claude/rules/general-code-change.md`).
- Test files must live under `tests/` mirroring the production tree; colocation is prohibited
  (`.claude/rules/general-unit-test.md`).
- No new dependencies without explicit instruction; the plan additionally forbids adding `hypothesis`
  (`.claude/rules/python.md`).
- `# noqa` and `# type: ignore` suppressions require a pre-authorized pattern or explicit approval
  (`.claude/rules/python-suppressions.md`).
- Google-style docstrings are mandatory for every class and function; loops, comprehensions,
  branches, and multi-step blocks require intent comments; numbered notes are prohibited
  (`.claude/rules/self-explanatory-code-commenting.md`).
- Tone for all authored content is professional, factual, and neutral (`CLAUDE.md`).
