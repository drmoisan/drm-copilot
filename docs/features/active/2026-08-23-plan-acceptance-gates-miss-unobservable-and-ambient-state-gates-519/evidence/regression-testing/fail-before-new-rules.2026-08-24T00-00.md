# Fail-before evidence — new observability rules do not yet exist

Timestamp: 2026-08-26T00-14
Command: `poetry run pytest "tests/scripts/dev_tools/test_plan_gate_observability.py::test_defective_plan_fixture_produces_g7_and_g8_findings"`
EXIT_CODE: 1
ExpectedExitCode: 1

Output Summary:
`1 failed` in 0.08s. The single collected case
`test_defective_plan_fixture_produces_g7_and_g8_findings` failed with
`assert 0 == 2` / `where 0 = len([])`, so the observed union length of the
blocking and warning channels is **0** against the expected 2.

The fixture is a one-phase plan whose single task states, as its two acceptance
spans, the two defective forms frozen in the standing-rules section of the plan:
a write-mode formatter invocation whose attributed task text carries none of the
formatter's observation markers, and an unanchored `git diff` that compares the
worktree against the index. Neither span carries a `--cov` argument and neither
is a grep-family invocation, so no existing G1 through G6 rule can fire on it,
and the evaluation is made with no repository context so G2, G3, G5, and G6 do
not run at all. That is why the observed union length before the fix is exactly
0 rather than merely below 2.

Pass-after half: [P2-T5], which appends the new rule-group call to
`evaluate_plan_gates` in `scripts/dev_tools/plan_gate_discrimination.py`.

Verbatim failure excerpt:

```text
tests\scripts\dev_tools\test_plan_gate_observability.py F                [100%]

================================== FAILURES ===================================
___________ test_defective_plan_fixture_produces_g7_and_g8_findings ___________
        # Assert
>       assert len(findings) == 2
E       assert 0 == 2
E        +  where 0 = len([])

tests\scripts\dev_tools\test_plan_gate_observability.py:37: AssertionError
=========================== short test summary info ===========================
FAILED tests/scripts/dev_tools/test_plan_gate_observability.py::test_defective_plan_fixture_produces_g7_and_g8_findings
============================== 1 failed in 0.08s ==============================
```
