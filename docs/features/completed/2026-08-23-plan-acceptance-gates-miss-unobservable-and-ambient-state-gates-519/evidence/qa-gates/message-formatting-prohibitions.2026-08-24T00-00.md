# Message-Formatting Prohibitions — [P4-T4]

Timestamp: 2026-08-26T14-05

## Scope

The two message-formatting prohibitions of `.claude/rules/plan-acceptance-gates.md`
("Message Formatting — no `repr()`, no `!r`, no `pythonRepr`") are asserted over the
gate-module sets of both runtimes. This task records that both assertions pass with the
new observability module present in each iterated list, which [P4-T1] added.

- Python module set (`_PYTHON_GATE_MODULES` in `tests/scripts/dev_tools/test_plan_gate_parity.py`):
  `scripts/dev_tools/plan_gate_discrimination.py`, `scripts/dev_tools/plan_gate_coverage.py`,
  `scripts/dev_tools/plan_gate_observability.py`.
- TypeScript module set (`GATE_MODULE_PATHS` in
  `extensions/drm-copilot/test/lib/validate/plan-gate-parity.test.ts`):
  `plan-gate-commands.ts`, `plan-gate-rules.ts`, `plan-gate-discrimination.ts`,
  `plan-gate-observability.ts`.

## Gate 1 — Python `repr` prohibition

Command: `poetry run pytest "tests/scripts/dev_tools/test_plan_gate_parity.py::test_no_repr_formatting_in_gate_messages"`

EXIT_CODE: 0

Output Summary: `1 passed in 0.10s`. The case asserts that neither the `!r` conversion nor a
`repr(` call appears in any of the three Python gate modules, including the newly registered
`scripts/dev_tools/plan_gate_observability.py`.

## Gate 2 — TypeScript `pythonRepr` prohibition

Command: `npm test -- --testPathPatterns plan-gate-parity -t "renders offending values without pythonRepr formatting"` (run from `extensions/drm-copilot`)

EXIT_CODE: 0

Output Summary: `Tests: 3 skipped, 1 passed, 4 total`; `Test Suites: 1 passed, 1 total`. The
single selected case is the prohibition case, and it now iterates four module paths, the
fourth being `extensions/drm-copilot/src/lib/validate/plan-gate-observability.ts`.

## Supporting direct observations

Both assertions are corroborated by direct fixed-string counts against the new modules:

- `grep -c -F -e "!r" scripts/dev_tools/plan_gate_observability.py` reports `0`.
- `grep -c -F "repr(" scripts/dev_tools/plan_gate_observability.py` reports `0`.
- `grep -c -F "pythonRepr(" extensions/drm-copilot/src/lib/validate/plan-gate-observability.ts` reports `0`.

The four new finding strings render every offending span between backticks, with no quoting
helper on either side; the byte identity of those renderings across the two runtimes was
verified independently by [P4-T3].
