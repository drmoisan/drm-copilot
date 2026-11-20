# Phase 3 Python Lint — Issue #440 (F7)

Task: [P3-T5]

Timestamp: 2026-08-08T22-11

Command: `poetry run ruff check .`

EXIT_CODE: 0

## Run Sequence

| Invocation | EXIT_CODE | Result |
| --- | --- | --- |
| 1 | 1 | `Found 1 error.` — `S105 Possible hardcoded password assigned to: "VIOLATION_TOKEN"` at `tests/scripts/dev_tools/test_validate_parallel_orchestrator_state_cohort_barrier.py:32:19` |
| 2 | 0 | `All checks passed!` |

## Finding Resolution (no suppression used)

`S105` fired on the module constant `VIOLATION_TOKEN = "PARALLEL_COHORT_BARRIER_VIOLATION"`.
The rule is a name-based heuristic: ruff flags a string literal assigned to any
identifier containing `TOKEN`, `PASSWORD`, or `SECRET`. The literal is the design
section 9 invariant label, not a credential.

`.claude/rules/python-suppressions.md` pre-authorizes `# noqa: S105 - test fixture data`
for exactly this situation, but the same policy requires attempting resolution
without a suppression first. The finding was therefore resolved by renaming the
constant to `VIOLATION_LABEL`, which does not match the heuristic. No `# noqa`
and no `# type: ignore` was added anywhere in Phase 3. The rename does not weaken
the byte-exactness assertion: the literal string value is unchanged, and the
test `test_violation_message_matches_the_exact_literal_form` asserts the full
message with no interpolation at all.

Per Binding Constraint 9 the loop restarted from P3-T4 after the rename; black
reported `376 files left unchanged` and ruff then reported `All checks passed!`.

Output Summary: PASS. EXIT_CODE 0 with `All checks passed!` across the whole
repository on invocation 2. One finding was raised and fixed at source: ruff
`S105` on the test constant `VIOLATION_TOKEN` was a name-heuristic false positive
for the invariant label `PARALLEL_COHORT_BARRIER_VIOLATION`, resolved by renaming
the constant to `VIOLATION_LABEL` rather than by adding the pre-authorized
`# noqa: S105`. Zero suppressions were introduced in Phase 3.
