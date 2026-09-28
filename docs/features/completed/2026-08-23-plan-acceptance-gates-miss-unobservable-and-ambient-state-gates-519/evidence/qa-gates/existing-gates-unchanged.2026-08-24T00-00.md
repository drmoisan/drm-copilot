# Existing G1-G6 Gate Tests Unchanged — [P4-T5]

Timestamp: 2026-08-26T14-12

## Scope

The four pre-existing G1 through G6 rule-behaviour test files are protected: this change adds
rules but must not edit, weaken, or replace any assertion those files already make. Both an
anchored name-listing diff and a porcelain-status companion are recorded, because a name
listing anchored to `main` reports tracked changes only and would not report a newly created
file at any of the four paths.

Protected paths:

- `tests/scripts/dev_tools/test_plan_gate_discrimination_cov.py`
- `tests/scripts/dev_tools/test_plan_gate_discrimination_literals.py`
- `extensions/drm-copilot/test/lib/validate/plan-gate-discrimination-cov.test.ts`
- `extensions/drm-copilot/test/lib/validate/plan-gate-discrimination-literals.test.ts`

`main` resolves to `245b56a4a1618f25a26e87d60ac0b8894c0b9caa`.

## Gate 1 — anchored name-listing diff

Command: `git diff --name-only main -- tests/scripts/dev_tools/test_plan_gate_discrimination_cov.py tests/scripts/dev_tools/test_plan_gate_discrimination_literals.py extensions/drm-copilot/test/lib/validate/plan-gate-discrimination-cov.test.ts extensions/drm-copilot/test/lib/validate/plan-gate-discrimination-literals.test.ts`

EXIT_CODE: 0

Output Summary: empty. No line was produced, so none of the four paths differs from `main`.
The command was followed immediately by a sentinel echo, and only the sentinel appeared, which
distinguishes an empty result from a suppressed one.

## Gate 2 — porcelain-status companion

Command: `git status --porcelain -- tests/scripts/dev_tools/test_plan_gate_discrimination_cov.py tests/scripts/dev_tools/test_plan_gate_discrimination_literals.py extensions/drm-copilot/test/lib/validate/plan-gate-discrimination-cov.test.ts extensions/drm-copilot/test/lib/validate/plan-gate-discrimination-literals.test.ts`

EXIT_CODE: 0

Output Summary: empty. No entry was produced, so none of the four paths is modified, staged,
or newly created in the working tree. The same sentinel-echo discipline was used.

## Gate 3 — Python G1-G6 suites pass

Command: `poetry run pytest tests/scripts/dev_tools/test_plan_gate_discrimination_cov.py tests/scripts/dev_tools/test_plan_gate_discrimination_literals.py`

EXIT_CODE: 0

Output Summary: `31 passed in 0.10s`; 0 failed.

## Gate 4 — TypeScript G1-G6 suites pass

Command: `npm test -- --testPathPatterns plan-gate-discrimination` (run from `extensions/drm-copilot`)

EXIT_CODE: 0

Output Summary: `Test Suites: 2 passed, 2 total`; `Tests: 32 passed, 32 total`; 0 failed.

## Result

PASS. All four protected files are byte-identical to `main` and every assertion they carry
still passes with the G7, G8, G8b, and G9 rule group wired into both runtimes.
