# Parity-Guard Discrimination Demonstration — Mutation Run (Issue #486)

Timestamp: 2026-08-20T21-39
Task: [P2-T2] [expect-fail]
Working directory: worktree root `C:/Users/DanMoisan/repos/drm-copilot/.claude/worktrees/agent-af11eae4f37cb0d9d`

A failing run is the expected and required outcome of this task. It proves the generalized
`_PYTHON_GATE_MODULES` assertion actually reads the newly extracted module; a passing run here would
have proven the opposite and required rework of [P2-T1].

## Mutation applied

Exactly one line was appended to the end of `scripts/dev_tools/plan_gate_coverage.py`:

```
# TEMPORARY parity-guard mutation for [P2-T2]: repr( token, reverted by [P2-T3].
```

Command: `poetry run pytest tests/scripts/dev_tools/test_plan_gate_parity.py::test_no_repr_formatting_in_gate_messages -q`

EXIT_CODE: 1

Raw output:

```
F                                                                        [100%]
================================== FAILURES ===================================
__________________ test_no_repr_formatting_in_gate_messages ___________________

    def test_no_repr_formatting_in_gate_messages() -> None:
        """Every Python gate module renders values without `repr`-style formatting.

        The prohibition covers the whole module set rather than one file, so moving
        finding-string code into a sibling module cannot silently escape it.
        """

        # Arrange / Act / Assert: both prohibited substrings are checked for every
        # module in the set, and each assertion names the module it read so a
        # failure identifies the offending file directly.
        for module in _PYTHON_GATE_MODULES:
            source = module.read_text(encoding="utf-8")
            assert "!r" not in source, f"`!r` conversion present in {module.name}"
>           assert "repr(" not in source, f"`repr(` call present in {module.name}"
E           AssertionError: `repr(` call present in plan_gate_coverage.py
E           assert 'repr(' not in '"""Evaluate...y [P2-T3].\n'
tests\scripts\dev_tools\test_plan_gate_parity.py:284: AssertionError
=========================== short test summary info ===========================
FAILED tests/scripts/dev_tools/test_plan_gate_parity.py::test_no_repr_formatting_in_gate_messages
1 failed in 0.13s
```

Output Summary: **1 failed, 0 passed, EXIT_CODE 1** — the expected outcome. The failing assertion is
the one added by [P2-T1], and its message names the new module explicitly:
`AssertionError: repr( call present in plan_gate_coverage.py`. The assertion therefore covers
`scripts/dev_tools/plan_gate_coverage.py`, so the module split does not silently escape the
`.claude/rules/plan-acceptance-gates.md` § Message Formatting prohibition. The mutation is reverted
and re-verified in [P2-T3].
