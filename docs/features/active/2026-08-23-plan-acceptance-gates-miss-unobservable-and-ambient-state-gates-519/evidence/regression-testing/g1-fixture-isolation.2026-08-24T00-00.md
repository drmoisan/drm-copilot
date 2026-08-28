# G1 Fixture Isolation Restored — [P4-T9]

Timestamp: 2026-08-26T14-55

## Repair applied

**The primary and preferred repair was applied: the fixture was repaired, not the assertion.**
No assertion anywhere in
`tests/scripts/dev_tools/test_validate_orchestration_artifacts_plan_gates.py` was modified,
weakened, or removed. The alternative permitted repair — amending the single stderr assertion —
was **not** used, because the fixture repair did not perturb any other test in the file.

## The defect this repairs

The shared `_G1_PLAN` fixture stated the acceptance command
`poetry run pytest -q --cov=scripts/dev_tools/foo.py`. That command supplies no terminal
reporter, and the project `addopts` value supplies none either, so it genuinely prints no
coverage table. G9 therefore reported it — correctly. The resulting warning-prefixed line on
stderr broke the final assertion of `test_main_emits_blocking_error_on_stderr_and_exits_one`,
which requires the stderr stream to carry no warning-prefixed line.

The fixture was written to exercise G1 alone. It acquired a second, unintended finding only
because the rule that reports a missing terminal reporter did not exist when it was written.
Restoring its isolation is therefore the correct repair, and weakening the stderr assertion
would have discarded a real signal in order to accommodate a fixture defect.

### Reproduction before the repair

Command: `poetry run pytest tests/scripts/dev_tools/test_validate_orchestration_artifacts_plan_gates.py`

EXIT_CODE: 1

Output Summary: `1 failed, 11 passed in 0.27s`. The single failure was
`test_main_emits_blocking_error_on_stderr_and_exits_one`, at the assertion
`assert "PLAN GATE WARNING: " not in captured.err`, with the reported stderr carrying
`PLAN GATE WARNING: [P1-T1] coverage command \`poetry run pytest -q --cov=scripts/dev_tools/foo.py\` supplies no terminal reporter and the project addopts supplies none either, so no coverage table is printed. Add --cov-report=term-missing.`

## The change

The token `--cov-report=term-missing` was inserted ahead of the fixture's existing coverage
value. The coverage value itself is left exactly as it stands, because
`--cov=scripts/dev_tools/foo.py` is the filesystem-path spelling G1 exists to reject and is the
whole point of the fixture. The string was split across two adjacent Python literals so the line
stays inside the formatter's width; adjacent-literal concatenation produces the same single list
element, so the plan text the validator sees is one line exactly as before. An explanatory
comment records why the token is there, so a later reader does not remove it.

The anchored diff against `main` for this file touches the `_G1_PLAN` block and nothing else.
`main` resolves to `245b56a4a1618f25a26e87d60ac0b8894c0b9caa`.

## Gate 1 — the whole file passes

Command: `poetry run pytest tests/scripts/dev_tools/test_validate_orchestration_artifacts_plan_gates.py`

EXIT_CODE: 0

Output Summary: `12 passed in 0.25s`; **0 failed**. `_G1_PLAN` is shared by three tests —
`test_validate_plan_text_includes_g1_blocking_finding` (line 239),
`test_main_emits_blocking_error_on_stderr_and_exits_one` (line 251, formerly failing), and two
further `main`-route tests at lines 308 and 388 — and all of them pass unmodified.

## Gate 2 — G1's finding string and count are unchanged

Command: `poetry run pytest "tests/scripts/dev_tools/test_validate_orchestration_artifacts_plan_gates.py::test_validate_plan_text_includes_g1_blocking_finding"`

EXIT_CODE: 0

Output Summary: `1 passed in 0.09s`. That named test asserts the finding count is exactly 1 and
asserts the remedy text the finding carries, so its passing establishes that the repair did not
change what G1 reports for this fixture.

### Direct confirmation

Command: `poetry run python -c "import tests.scripts.dev_tools.test_validate_orchestration_artifacts_plan_gates as t; import scripts.dev_tools.validate_orchestration_artifacts as v; e=v.validate_plan_text(t._G1_PLAN); print('COUNT',len(e)); print('STRING',e[0])"`

EXIT_CODE: 0

Output Summary:

```
COUNT 1
STRING [P1-T1] --cov argument `scripts/dev_tools/foo.py` names a filesystem path; coverage.py accepts only directories or importable names. Use --cov=scripts.dev_tools.foo.
```

The count is 1 and the string is byte-identical to `_EXPECTED_G1` as recorded in the [P0-T13]
baseline artifact `evidence/baseline/plan-gate-preexisting-output.2026-08-24T00-00.md`. The
single-line `-c` form was used deliberately: a multi-line `-c` is a silent no-op on this
platform and would have made this confirmation read as a pass while measuring nothing.

## Line count

The file measures **449** lines after the repair and the formatting stage, against the 500-line
hard limit. The [P4-T8] artifact records this value.

## Result

PASS. Fixture isolation is restored by the primary repair, every assertion in the file is
unmodified, all 12 tests pass, and G1's finding string and count of 1 for this fixture are
unchanged.
