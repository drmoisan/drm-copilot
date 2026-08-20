# Gate — over-limit file growth and untouched existing test modules (AC20, AC25)

Timestamp: 2026-08-20T09-53

Task: [P5-T6]

Command: git diff --numstat 71aebdb9a1e4752b191b3c9d4e677b807ea6fdec -- scripts/dev_tools/pr_context/collector.py tests/scripts/dev_tools/test_collect_pr_context_part4.py tests/scripts/dev_tools/test_collect_pr_context.py
EXIT_CODE: 0

## Complete output

```
4	0	scripts/dev_tools/pr_context/collector.py
```

That is the entire output: exactly one row.

## Reading of the output

- `scripts/dev_tools/pr_context/collector.py` — **4 added lines, 0 deleted**, within the AC20 cap of
  at most 5 added lines. The four lines are the intent comment, the two per-record locals, and the
  splat entry, as [P5-T1] specifies. The file's 619-line pre-existing overage is recorded at [P0-T4]
  and is not created by this change.
- `tests/scripts/dev_tools/test_collect_pr_context_part4.py` — **no row emitted**.
- `tests/scripts/dev_tools/test_collect_pr_context.py` — **no row emitted**.

Absence of a row is the passing signal for the two test modules. A numstat run never emits a literal
`0	0` row for an unmodified path, so the presence of ANY row for either file would be the failure
condition. Neither appears, so both over-limit test modules received zero changed lines. The new
Python collector-level cases live in the new sibling module
`tests/scripts/dev_tools/test_collect_pr_context_expected_exit.py` (117 lines) instead.

Output Summary: One numstat row total — `collector.py` at 4 added / 0 deleted, inside the AC20 cap of
5. No row for `test_collect_pr_context_part4.py` and no row for `test_collect_pr_context.py`, which
is how an unmodified path is represented and therefore the passing signal for AC20's second clause
and AC25's first clause. AC25 is re-confirmed after the final QC pass at [P8-T11].
