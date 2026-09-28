# F8-B1 Verification — Remediation Cycle 1, F8 (issue #446)

Timestamp: 2026-08-09T00-01
Task: [P2-T11]
Finding remediated: **F8-B1** — the derived resolution had no producer, so the Layer-2 drift gate had
no release path and could permanently block a child.

Command: `poetry run pytest --cov --cov-branch --cov-report=term-missing`

EXIT_CODE: 0

## Output Summary

- Outcome: **3179 passed**, 0 failed, 0 errored, 0 skipped. The cycle-entry count was 3176; the three
  added tests are the resolution seam tests of [P2-T5], [P2-T6], and [P2-T7]. No previously passing
  test failed.
- Repo-wide: 92.03% line (12780/13887), 84.11% branch (4286/5096). Line coverage rose by 0.01
  percentage points; branch coverage is unchanged.
- `scripts/dev_tools/parallel_drift_resolution.py` is at **100.00% line (15/15)** and **100.00%
  branch (0/0)**. The module has no branch arcs: both functions are straight-line, so the branch
  denominator is legitimately zero and the figure is reported as 100% rather than invented.
- The six pre-existing drift modules are all still at 100% line and 100% branch:

| File | Line | Branch |
| --- | --- | --- |
| `scripts/dev_tools/parallel_drift_detection.py` | 100.00% (95/95) | 100.00% (32/32) |
| `scripts/dev_tools/parallel_drift_detection_cli.py` | 100.00% (69/69) | 100.00% (6/6) |
| `scripts/dev_tools/parallel_drift_halt.py` | 100.00% (42/42) | 100.00% (6/6) |
| `scripts/dev_tools/_parallel_drift_shape.py` | 100.00% (40/40) | 100.00% (20/20) |
| `scripts/dev_tools/_parallel_drift_cli_io.py` | 100.00% (41/41) | 100.00% (18/18) |
| `scripts/dev_tools/_parallel_orchestrator_state_drift.py` | 100.00% (44/44) | 100.00% (14/14) |
| `scripts/dev_tools/parallel_drift_resolution.py` (new this cycle) | 100.00% (15/15) | 100.00% (0/0) |
| `scripts/dev_tools/validate_parallel_orchestrator_state.py` | 97.62% (82/84) | 94.12% (32/34) |

`parallel_drift_detection.py` grew by one measured statement (94 to 95) and
`parallel_drift_detection_cli.py` by three (66 to 69); every added statement is covered.

## What Closes the Loop

The finding was that both resolution disjuncts require an affirmative write to
`items[].blast_radius`, and nothing produced that write, emitted a value to write, or named an actor.
All three gaps are now closed, and the closure is asserted end to end rather than per side.

1. **Producer module.** `scripts/dev_tools/parallel_drift_resolution.py` holds
   `build_observed_radius`, the single guarded entry point onto F1's `radius_from_observed_paths`, and
   `request_resolution_write`, the seam that returns a frozen `ResolutionWriteRequest` carrying the
   `items[].blast_radius` update. The seam requests and never writes, mirroring
   `request_requeue_via_recolor`. No schema field was added and no enum was extended: `blast_radius`
   already carries the six invariant-9 keys and `observed` is an existing `blast_radius.source`
   member.
2. **Emitted value.** `evaluate_drift` now returns an `observed_radius` key, populated from
   `request_resolution_write(...).blast_radius` when the diff escaped and `None` when the result is
   `no_escape`. The payload key set is exactly the nine documented keys.
3. **Named actor and trigger.** `#### Six-Step Procedure` is now `#### Seven-Step Procedure`, and step
   7 names the actor (`parallel-orchestrator`), the trigger (the consuming remediation cycle exiting
   with `blocking_count == 0`), both writes, and the statement that no other write clears the derived
   unresolved state. `#### Resolution Semantics` now derives non-deadlock from that named producer,
   and `#### CLI Invocation` documents the ninth payload key.

## The Loop-Closing Seam Test

Test name: `test_applying_the_emitted_observed_radius_resolves_the_recorded_drift`
File: `tests/scripts/dev_tools/test_parallel_drift_resolution.py`

How it closes the loop, in one pass:

1. It builds a checkpoint whose item 446 has a declared radius `["docs/**"]` and one recorded drift
   event at `2026-08-08T10-00` whose `escaped_paths` is `["scripts/dev_tools/escape.py"]`.
2. It asserts `unresolved_drift_item_keys(events, items)` **reports 446** — the before state.
3. It invokes `evaluate_drift` and takes the emitted `observed_radius`. The invocation passes an
   explicit `computed_at` of `2026-08-08T11-00`, strictly later than the event's `at`, because the
   command line defaults `computed_at` to `at` and an equal value does not satisfy disjunct (b).
4. It writes that emitted value **verbatim** into `items[].blast_radius`; no radius is hand-built.
5. It asserts `unresolved_drift_item_keys(events, resolved_items) == ()` — the after state.

The transition from reporting to not reporting is asserted in the same test against the same
derivation, so a producer that emitted a value the derivation does not accept would fail here.

The test additionally isolates disjunct (b) as the mechanism. The later invocation's observed diff is
`["packages/mcp-server/src/index.ts"]`, not the event's escaped path, so the emitted radius's `paths`
do not subsume `scripts/dev_tools/escape.py`. The test asserts that control explicitly
(`ESCAPED_PATH not in emitted["paths"]`), which makes disjunct (a) provably inapplicable and leaves
`source == 'observed'` with a strictly later `computed_at` as the only possible cause of the
transition.

### Non-Vacuity Check

The loop closure was verified to depend on the strict comparison rather than passing incidentally. The
same construction was evaluated at three `computed_at` values against an event `at` of
`2026-08-08T10-00`:

| `computed_at` passed | `unresolved_drift_item_keys` after applying the emitted radius |
| --- | --- |
| `2026-08-08T10-00` (equal — the CLI default) | `(446,)` — still unresolved |
| `2026-08-08T09-30` (earlier) | `(446,)` — still unresolved |
| `2026-08-08T11-00` (strictly later) | `()` — resolved |

Only the strictly later value closes the loop, so the assertion is sensitive to the producer's
`computed_at` and to disjunct (b)'s strictness. This also confirms the plan's premise that relying on
the CLI's `computed_at` default would leave the test unable to pass.

## The Two Supporting Tests

- `test_widening_the_declared_radius_resolves_the_recorded_drift` — the same before-and-after
  transition through disjunct (a): the recorded radius is extended to cover every escaped path while
  `blast_radius.source` stays `declared`, asserted explicitly, so the transition is attributable to
  path subsumption alone.
- `test_request_resolution_write_serializes_the_library_radius_unchanged` — pins the seam's
  `blast_radius` to `radius_from_observed_paths(...).to_dict()` over the same inputs, so the seam
  cannot drift from the library it wraps.

All three pass.
