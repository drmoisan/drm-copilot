# Divergence-walk citation (Issue #500)

Timestamp: 2026-08-21T23:04:29Z
Issue: #500
Task: [P0-T16]

Command: none. This task records an already-discharged verification obligation as a plan input
rather than re-running it.

EXIT_CODE: 0

## Cited artifact

`docs/features/active/2026-08-21-blast-radius-bundled-config-stale-skeleton-500/evidence/other/divergence-commit-walk.2026-08-21T21-47.md`

That artifact discharges Executor Verification Obligation 1 from the research artifact (the
`git log --follow` divergence walk over both copies of `config/blast-radius.json`). It records
`EXIT_CODE: 0` for both invocations and a per-commit key-shape table. No task in the plan of record
re-runs the walk; tasks cite it.

## Output Summary — the two load-bearing findings restated

1. **The bundled copy was born divergent, not drifted.** It first appears at commit `944d58d3`
   (issue #462) already carrying 3 `shared_surfaces`, 0 `shared_surface_globs`, and a 4-entry
   module map, against a then-current self-hosted shape of 10 / 3 / 14. It was never a copy of the
   self-hosted set for those two keys, so there is no commit at which they diverged and no prior
   state to restore.

2. **`mandate_reads` never diverged.** Commits `40db8ecc` (self-hosted) and `374ec9d7`
   (bundled) both added the same six entries under issue #489, and both copies still carry six.
   Cause C is therefore a gap shared by BOTH copies, not a bundled-only staleness. The four missing
   entries must be appended to each copy, which is what tasks [P3-T3] and [P3-T5] do.

## Consequence the drift gate must encode

The drift gate must assert **portable-set equality** for `shared_surfaces` and
`shared_surface_globs` — bundled `shared_surfaces` equal to the declared
`PORTABLE_SHARED_SURFACES` constant and a subset of the self-hosted list, bundled
`shared_surface_globs` empty and a subset of the self-hosted list — and **never byte-equality
against the self-hosted file** for those two keys. Byte-equality is the correct relation only for
the Class 1 keys `version`, `over_breadth_fraction`, and `mandate_reads`, which the walk shows
were maintained in step. This is exactly the three-class partition tasks [P6-T2], [P6-T3], and
[P6-T4] implement.
