# R2 Load-Bearing Check — Issue #614 Remediation

Timestamp: 2026-09-07T01-52
Cycle: 2026-09-06T23-30
Task: [P2-T2] `[expect-fail]`
ExpectedExitCode: 1
EXIT_CODE: 1

The `ExpectedExitCode` above applies to the mutated run recorded in step 2, which is the
deliberately failing run this task exists to produce. The restoration steps recorded in
steps 3 through 5 each exited 0.

## 1. Mutation applied

In `scripts/dev_tools/orchestration_handoff_contract.py`, line 68 was replaced.

Original text:

```
    "HANDOFF_UNSUPPORTED_VERSION HANDOFF_SOURCE_HASH_MISMATCH "
```

Mutated text:

```
    "HANDOFF_SOURCE_HASH_MISMATCH HANDOFF_UNSUPPORTED_VERSION "
```

The mutation swaps the first two entries of the `FAILURE_PRECEDENCE` tuple and changes no
other character of the file.

## 2. Mutated run

Command: `poetry run pytest "tests/scripts/dev_tools/test_orchestration_handoff_contract.py::test_failure_precedence_matches_the_shared_registry" -q`
EXIT_CODE: 1

```
F                                                                        [100%]
================================== FAILURES ===================================
_____________ test_failure_precedence_matches_the_shared_registry _____________

    def test_failure_precedence_matches_the_shared_registry() -> None:
        """The Python precedence tuple stays bound to the registry ordering."""

>       assert FAILURE_PRECEDENCE == REGISTRY_FAILURE_PRECEDENCE
E       AssertionError: assert ('HANDOFF_SOU...ISMATCH', ...) == ('HANDOFF_UNS...ISMATCH', ...)
E
E         At index 0 diff: 'HANDOFF_SOURCE_HASH_MISMATCH' != 'HANDOFF_UNSUPPORTED_VERSION'
E         Use -v to get more diff

tests\scripts\dev_tools\test_orchestration_handoff_contract.py:108: AssertionError
=========================== short test summary info ===========================
FAILED tests/scripts/dev_tools/test_orchestration_handoff_contract.py::test_failure_precedence_matches_the_shared_registry
1 failed in 0.40s
```

The failure names `test_failure_precedence_matches_the_shared_registry` and reports the
index-0 divergence introduced by the mutation. The assertion is therefore load-bearing: it
detects a reordering of the Python precedence tuple away from the registry.

## 3. Restoration

Line 68 was restored to its exact original text.

## 4. Byte identity against `a7b80f2d`

Command: `git diff --exit-code a7b80f2df6d849aa65de416655fa58beb4412998 -- scripts/dev_tools/orchestration_handoff_contract.py`
EXIT_CODE: 0

The command printed no hunk and exited 0, so the file is byte-identical to `a7b80f2d`.

Command: `git status --porcelain=v1 -- scripts/dev_tools/orchestration_handoff_contract.py`
EXIT_CODE: 0

```
```

No row was printed for that path.

## 5. Re-run after restoration

Command: `poetry run pytest "tests/scripts/dev_tools/test_orchestration_handoff_contract.py::test_failure_precedence_matches_the_shared_registry" -q`
EXIT_CODE: 0

```
.                                                                        [100%]
1 passed in 0.06s
```

Output Summary: With line 68 reordered, the parity test fails with exit code 1 and an
index-0 assertion diff, proving the assertion is load-bearing. After restoration the file
is byte-identical to `a7b80f2d` by both `git diff --exit-code` and `git status`, and the
same pytest node passes. `scripts/dev_tools/orchestration_handoff_contract.py` is not a net
change of this plan.
