# F8-B2 Verification — Remediation Cycle 1, F8 (issue #446)

Timestamp: 2026-08-09T00-01
Task: [P3-T9]
Finding remediated: **F8-B2** — halt selection could select the drifting item, contradicting
`spec.md` line 48, `user-story.md` line 90, and `user-story.md` lines 108-109.

Command: `poetry run pytest --cov --cov-branch --cov-report=term-missing`

EXIT_CODE: 0

## Output Summary

- Outcome: **3181 passed**, 0 failed, 0 errored, 0 skipped. Cycle entry was 3176; the five added tests
  are the three Phase 2 resolution tests and the two Phase 3 exclusion tests.
- Repo-wide: 92.03% line (12785/13892), 84.12% branch (4290/5100).

### No Test Asserts the Drifting Item Is Halted

Verified by enumerating every assertion on a halt result across `tests/scripts/dev_tools/`:

| Location | Assertion | Drifting item present? |
| --- | --- | --- |
| `test_parallel_drift_detection_cli.py:212` | `halted_item_keys == []` | no |
| `test_parallel_drift_detection_cli.py:228` | `halted_item_keys == []` | no |
| `test_parallel_drift_detection_cli.py:306` | `halted_item_keys == [445]` | no (corrected this cycle) |
| `test_parallel_drift_detection_cli_halt.py:57` | `halted_item_keys == [445]` | no (corrected this cycle) |
| `test_parallel_drift_detection_cli_halt.py:79` | `halted_item_keys == [445, 447]` | no (corrected this cycle) |
| `test_parallel_drift_detection_cli_halt.py:104` | `halted_item_keys == [445]` | no (added this cycle) |
| `test_parallel_drift_detection_cli_halt.py:117` | `halted_item_keys == [445]` | no (added this cycle) |
| `test_parallel_drift_detection_cli_halt.py:139` | `halted == (448,)` | no (added this cycle) |
| `test_parallel_drift_detection_conflicts.py:378` | `halted == (445,)` | no (corrected this cycle) |
| `test_parallel_drift_halt.py:65` | `halted == 441` | comparator-level, no drifting item exists |

**No test asserts the drifting item is halted through `halted_item_keys` or through
`evaluate_drift`.** The drifting item in every drift-path fixture is 446, and 446 appears in no
asserted halt result.

### The Comparator-Level Assertion Is Recorded as Correct and Unchanged

`test_the_detection_and_halt_path_is_deterministic_across_repeated_calls`
(`tests/scripts/dev_tools/test_parallel_drift_detection_conflicts.py`, assertion
`assert results[0][2] == 446` at line 420) asserts that `select_halted_item` returns 446 for a pair of
equal-timestamp markers. That assertion is **correct and was not changed**, for two reasons:

1. It calls `select_halted_item` **directly**, with two `ItemStart` markers and no drift information.
   The comparator's contract is the bare later-started rule with its three tie-breaks; for equal
   timestamps the larger `issue_num` is deemed later-started, so 446 is the correct comparator result.
2. This plan tasks no change to `select_halted_item`. The drifting-item exclusion is applied at the
   call site, one level up, where the drifting key is known. The comparator is therefore still
   exercised, and still asserted, on its own contract.

The test body is byte-identical to its `bcf2de15` form; the diff of that file against `bcf2de15`
touches only the import block and the one whole-path test [P3-T7] corrects.

### Coverage of the Two Modules F8-B2 Touched

| File | Line | Branch |
| --- | --- | --- |
| `scripts/dev_tools/parallel_drift_detection_cli.py` | **100.00% (74/74)** | **100.00% (10/10)** |
| `scripts/dev_tools/parallel_drift_halt.py` | **100.00% (42/42)** | **100.00% (6/6)** |

The CLI module's branch denominator rose from 6 to 10 with the exclusion's candidate-count branch, and
every new arc is covered: the one-candidate arc by the drift-path tests, the two-candidate arc by
`test_halted_item_keys_applies_the_comparator_to_a_pair_without_the_drifter`. No zero-candidate branch
was written, so no unreachable arc exists to depress the figure.

All other feature modules are unchanged at 100% line and branch, and
`scripts/dev_tools/validate_parallel_orchestrator_state.py` remains 97.62% line / 94.12% branch.

## How the Exclusion Works

The exclusion is applied at the call site in `scripts/dev_tools/parallel_drift_detection_cli.py`, in
`halted_item_keys`, which now takes a third parameter `drifting_item_key`. `evaluate_drift` passes
`item_key`, the key of the item whose diff escaped.

For each newly conflicting pair, the function builds the pair's candidate list by dropping the
drifting key, then:

- halts the single remaining candidate when one remains (the pair contained the drifting item), or
- applies `select_halted_item` to the two remaining candidates when two remain (the pair did not).

The candidate count is provably 1 or 2 for every input, so **no zero-candidate branch is written**:
a recomputed pair is a canonical `(a, b)` with `a < b` and two distinct keys per F3 invariant 15, and
`select_halted_item` raises `ParallelDriftInputError` on duplicate keys, so dropping one key can never
empty the list. Writing a zero-candidate branch would have created an unreachable arc and broken the
100% branch-coverage floor.

`halted_item_keys` never returns `drifting_item_key`, because that key is removed from every
candidate list before any selection occurs.

### The Never-Halt-the-Drifting-Item Test

Test name: `test_the_drifting_item_is_never_halted_even_when_it_started_later`
File: `tests/scripts/dev_tools/test_parallel_drift_detection_cli_halt.py`

It proves the drifting item is never returned even when it is the later starter by **both** tie-breaks:

- **Case one, later by timestamp.** Drifting item 446 carries `worktree_created_at`
  `2026-08-08T09-00` against peer 445 at `2026-08-08T08-00`, so the timestamp comparison deems 446
  later-started. Asserted: `446 not in halted_item_keys` and `halted_item_keys == [445]`.
- **Case two, later by the item-key tie-break.** Both items carry `worktree_created_at`
  `2026-08-08T08-00`, so the comparator falls through to the item-key tie-break and deems the larger
  `issue_num` — 446, the drifting item — later-started. Asserted: `446 not in halted_item_keys` and
  `halted_item_keys == [445]`.

Both cases route through `evaluate_drift`, so the assertion covers the production call path rather
than the helper in isolation.

## `select_halted_item` Is Unchanged Apart From Its Docstring

`git diff bcf2de15 -- scripts/dev_tools/parallel_drift_halt.py` is exactly six added lines and zero
removed lines, all inside `select_halted_item`'s docstring:

```diff
@@ -174,6 +174,12 @@ def select_halted_item(a: ItemStart, b: ItemStart) -> int:
     present on exactly one item makes that timestamped item earlier-started;
     both unknown falls through to the item-key tie-break.

+    Drifting-item exclusion is applied by the caller, not here, because the spec
+    fixes this signature as ``(a, b)`` with no drifting-item parameter and this
+    function receives no drift information at all; the call site
+    ``halted_item_keys`` in ``parallel_drift_detection_cli`` drops the drifting key
+    from a pair's candidates before this comparator runs.
+
     Args:
```

The signature `select_halted_item(a: ItemStart, b: ItemStart) -> int` and the whole function body,
including all three tie-breaks and the duplicate-key guard, are byte-identical to their `bcf2de15`
form. `poetry run pytest tests/scripts/dev_tools/test_parallel_drift_halt.py` passes with **30 tests**
and that test file is unmodified by this cycle.

## Deviation Recorded — call-site helper name

[P3-T1] and [P3-T6] name the call-site helper `_halted_item_keys`. Passing a pair directly to it from
`tests/scripts/dev_tools/test_parallel_drift_detection_cli_halt.py`, which [P3-T6] requires in order
to exercise the two-remaining-candidate branch, produced a Pyright `reportPrivateUsage` error: a
private name imported outside its declaring module. Pyright runs in strict mode over `tests/` and is a
mandatory gate with zero permitted errors, and `reportPrivateUsage` has no pre-authorized suppression
in `.claude/rules/python-suppressions.md`.

Conflict-recomputation always returns pairs containing the drifting key, so the two-candidate arc is
unreachable from the public `evaluate_drift` surface; direct invocation is the only way to cover it,
and leaving it uncovered would have broken [P3-T6]'s own 100%-branch-coverage acceptance clause.

The function was therefore renamed `halted_item_keys`. It is the same function with the same
behaviour, and it is deliberately **not** added to the module's `__all__`, so the module's documented
public surface is unchanged. Only the identifier differs from the plan's wording. This is the same
class of deviation, with the same cause, as the shared-fixture rename recorded in
`split-parity.2026-08-09T00-01.md`.

## Additional Test Corrected Beyond the Plan's Enumeration

`test_main_prints_the_detection_result_as_json`
(`tests/scripts/dev_tools/test_parallel_drift_detection_cli.py:306`) also asserted the pre-fix
behaviour, `halted_item_keys == [446]`, as an incidental part of a stdout-serialization test. The plan
enumerated three tests to correct ([P3-T3], [P3-T4], [P3-T7]); this is a fourth instance of the same
defect class. It was corrected to `[445]` with a one-line explanatory comment, because [P3-T9] requires
`EXIT_CODE: 0` and leaving it would have asserted exactly the behaviour F8-B2 prohibits. No assertion
was weakened or removed.
