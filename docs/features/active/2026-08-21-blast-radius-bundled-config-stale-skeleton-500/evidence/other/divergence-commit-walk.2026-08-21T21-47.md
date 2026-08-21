# Divergence commit walk — config/blast-radius.json vs the bundled copy

Timestamp: 2026-08-21T21:47:24Z
Issue: #500
Purpose: discharge Executor Verification Obligation 1 from the research artifact.

## Commands

```
$ git log --follow --oneline -- config/blast-radius.json
40db8ecc feat(489): add mandate_reads config key and reduce the module map
a45a993b fix(blast-radius): stop parallel-run module map forcing full serial contention
aa19fe19 feat(blast-radius): add cross-language blast-radius library (#447)

$ git log --follow --oneline -- extensions/drm-copilot/resources/claude-customizations/config/blast-radius.json
374ec9d7 feat(489): carry mandate_reads through the push-down derivation
a45a993b fix(blast-radius): stop parallel-run module map forcing full serial contention
944d58d3 feat(462): carry the config tree through push-down and close the manifest gaps
```

EXIT_CODE: 0 (both invocations)

## Per-commit key shape

| Commit | Copy | modules | shared_surfaces | shared_surface_globs | mandate_reads |
| --- | --- | --- | --- | --- | --- |
| 944d58d3 | bundled | 4 (claude-runtime, config, docs, tests) | 3 | 0 | 0 |
| a45a993b | bundled | 2 (claude-runtime, config) | 3 | 0 | 0 |
| 374ec9d7 | bundled | 2 (claude-runtime, config) | 3 | 0 | 6 |
| aa19fe19 | self-hosted | 14 | 10 | 3 | 0 |
| a45a993b | self-hosted | 12 | 10 | 3 | 0 |
| 40db8ecc | self-hosted | 7 | 10 | 3 | 6 |

## Findings

1. **The bundled copy was born divergent, not drifted.** It first appears at `944d58d3`
   (issue #462, the commit that added the `config` tree to the push-down payload) already carrying
   3 `shared_surfaces`, 0 `shared_surface_globs`, and a 4-entry module map. It was never a copy of
   the then-current self-hosted 10/3/14 shape. The `shared_surfaces` and `shared_surface_globs`
   keys therefore never converged; there is no commit at which they diverged.

2. **`a45a993b` (issue #472) maintained both copies in step.** It removed the `docs` and `tests`
   location-bucket modules from the bundled copy (4 -> 2) and from the self-hosted copy (14 -> 12).
   This is direct evidence that the bundled copy is hand-maintained and that a maintainer has
   previously remembered to update it, which is why the omission at `#489` reads as an oversight
   rather than a policy.

3. **`modules` diverged at issue #489, which forked into two commits.** `40db8ecc` reduced the
   self-hosted map 12 -> 7, removing `claude-runtime` among the five disqualified umbrellas.
   `374ec9d7` touched the bundled copy in the same issue but only to add `mandate_reads`; it left
   `claude-runtime` in place. That is the single divergence event for the `modules` key.

4. **`mandate_reads` did NOT diverge.** Both `40db8ecc` and `374ec9d7` added the same 6 entries, and
   both copies still carry 6. Cause C of this bug is therefore a gap shared by both copies, not a
   bundled-only staleness, which matches the research finding that the four missing entries affect
   the self-hosted config as well.

## Consequence for the fix

The research artifact's "stale skeleton" framing is accurate for `modules`, and imprecise for
`shared_surfaces` / `shared_surface_globs`: those were authored narrow at `944d58d3` and never
intended to mirror the self-hosted set. That strengthens rather than weakens the planned change.
Correcting them is a deliberate widening of an under-specified default, justified by the
surfaces/modules asymmetry, and not a re-synchronisation of a copy that fell behind. The drift gate
must therefore assert a *portable-set* equality for these keys rather than byte-equality with the
self-hosted file, which is exactly the three-class partition the research recommends.
