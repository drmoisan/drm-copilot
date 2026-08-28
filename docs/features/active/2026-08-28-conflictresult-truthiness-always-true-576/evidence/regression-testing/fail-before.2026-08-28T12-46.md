# Fail-Before Regression Evidence — [P1-T2] [expect-fail]

Timestamp: 2026-08-28T12-46

Command: `poetry run pytest tests/scripts/dev_tools/test_blast_radius_conflicts.py::test_bool_is_false_for_a_disjoint_pair`

EXIT_CODE: 1

ExpectedExitCode: 1

This run was taken **before any production change**. `scripts/dev_tools/_blast_radius_conflicts.py`
is unmodified at this point; the only change in the working tree is the new test function added by
[P1-T1]. A failing outcome is the expected and required result for this task.

## Verbatim Failure Output

```
================================== FAILURES ===================================
___________________ test_bool_is_false_for_a_disjoint_pair ____________________

    def test_bool_is_false_for_a_disjoint_pair() -> None:
        """Project a disjoint pair's result to ``False`` under ``bool``."""
        result = conflicts(
            make_radius(paths=["scripts/dev_tools/a.py"]),
            make_radius(paths=["scripts/dev_tools/b.py"]),
            CONFIG,
        )

        assert result.conflict is False
>       assert bool(result) is False
E       assert True is False
E        +  where True = bool(ConflictResult(conflict=False, reasons=()))

tests\scripts\dev_tools\test_blast_radius_conflicts.py:88: AssertionError
=========================== short test summary info ===========================
FAILED tests/scripts/dev_tools/test_blast_radius_conflicts.py::test_bool_is_false_for_a_disjoint_pair
============================== 1 failed in 0.16s ==============================
```

## The Assertion Line Showing the Divergence

```
>       assert bool(result) is False
E       assert True is False
E        +  where True = bool(ConflictResult(conflict=False, reasons=()))
```

The preceding assertion `assert result.conflict is False` passed, so the explicit field read `False`
for this provably disjoint pair. The failing line shows the boolean projection of the same object
evaluating to `True`. The pytest introspection line names the object under test as
`ConflictResult(conflict=False, reasons=())`, which records both halves of the divergence in one
place: the field is `False` and `bool()` of the object carrying it is `True`.

Output Summary: `EXIT_CODE: 1` with `ExpectedExitCode: 1`. The run reports `1 failed`. The failing
assertion is `assert bool(result) is False`, which pytest renders as `assert True is False` with the
introspection `where True = bool(ConflictResult(conflict=False, reasons=()))`. The projection
evaluated `True` while the explicit `conflict` field on the same object was `False`, which is the
defect this change fixes. Because `ConflictResult` defines neither `__bool__` nor `__len__` at this
point, `bool()` falls through to `object.__bool__` and returns `True` for every instance.
