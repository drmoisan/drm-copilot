# Blast-radius under-reporting gaps (F1 follow-up) (Issue #452)

- Created: 2026-08-07
- Source: feature-review of `docs/features/active/2026-08-07-parallel-blast-radius-447` (issue #447, epic `parallel-orchestration` F1, wave 0)
- Type: potential refactor / bug
- Blocking for: F4 (`parallel-planner` surface, issue #443) — see Timing below

- Issue: #452
- Issue URL: https://github.com/drmoisan/drm-copilot/issues/452
- Last Updated: 2026-08-08
- Status: Promoted -> docs/features/active/Blast-radius_under-reporting_gaps_F1_follow-up/ (Issue #452)
- Work Mode: full-bug

## Summary

The F1 blast-radius library shipped with two verified under-reporting gaps in radius derivation
and the contention relation. Both are conformant with the approved F1 specification, so neither
blocked F1 delivery, and feature-review recorded zero Blocking findings. Both nonetheless weaken
the epic's fail-closed guarantee (`docs/features/epics/parallel-orchestration/epic.md`,
Shared Design item 7), and epic design section 13.1 names radius under-reporting the dominant
failure mode of the entire parallel-orchestration design.

They are recorded together because they share one root cause class — a radius that omits a
surface two items genuinely share — and one consumer deadline.

## Gap 1 — separator-free repository-root surfaces are unreachable from plan or spec text

`classify_path_token` accepts a token as a concrete repository path only when it contains `/`.
A repository-root file with no path separator therefore can never be extracted from plan or
spec text.

Three of the ten committed `config/blast-radius.json` `shared_surfaces` entries are
separator-free: `poetry.lock`, `package-lock.json`, `quality-tiers.yml`.

Verified:

```
extract_plan_paths("- [ ] [P1-T1] Touch `poetry.lock`.")  ->  ()
```

Consequence: V2 cannot fire for those surfaces at plan time. Two items that both append to
`poetry.lock` show no `shared_surface_overlap` and would be scheduled concurrently.

Conformance: this matches `spec.md:42`, which defines the rule as requiring `/`. Not
implementation drift. Both language implementations reproduce it identically and a test
documents it.

Partial mitigations already in place: these surfaces still reach a radius via
`radius_from_observed_paths` (the F8 drift-detection path) or a planner-declared radius, and
`_shared_surface_findings` builds its touched set from the union of radius concrete paths and
plan concrete paths. Only the plan-text-derived path is blind.

## Gap 2 — `conflicts` ignores listed-directory semantics that V1 honours (finding F-01)

The contention relation's path comparison treats a listed directory and a glob beneath it as
disjoint, while V1's own subsumption helper treats a file under that directory as covered.

Verified in both languages:

```
_entries_overlap("scripts/dev_tools", "scripts/dev_tools/**")        ->  False
is_path_subsumed("scripts/dev_tools/x.py", ["scripts/dev_tools"])    ->  True
```

Consequence: two radii that provably share files can report no `path_overlap`.

Conformance: spec-conformant — `spec.md:118` specifies "concrete×concrete: equality".

Masking: the coarse `modules` map hides this in most realistic cases, because two radii sharing
a directory usually also share a module. It is NOT masked for `artifacts/**` (accepted by
extraction but absent from the module map) or for deserialized radii with an empty `modules`
list.

Not affected: the glob×glob conservative shared-literal-prefix test itself was independently
proven sound during review. This gap is specific to concrete-versus-glob directory comparison.

## Why this was not remediated inside F1

- Both behaviours match the approved F1 specification; changing them mid-execution would have
  deviated from the approved plan and desynchronized the two language implementations and the
  committed 21-file parity fixture corpus.
- F1 is wave 0 and has no callers yet, so no downstream consumer is currently mis-scheduled.
- Feature-review adjudicated both as non-blocking for F1 and recommended a single follow-up.

## Timing — resolve before F4 lands

This is the sharp edge. Design section 5.2 makes the `declared` radius authoritative for
scheduling, and F4 (`parallel-planner`, issue #443) computes the declared radius **by calling
`derive_blast_radius`**. The plan-time blindness therefore propagates into the authoritative
radius unless F4 compensates or F1 is corrected first.

Recommendation: resolve before F4 is executed, not merely before the epic closes.

## Candidate resolutions (not yet decided)

1. Extend path-token classification to recognize a configured set of separator-free root
   surfaces, sourced from the `shared_surfaces` list itself rather than a second hardcoded list.
2. Align `conflicts` path comparison with `is_path_subsumed` so listed-directory prefixes are
   honoured on both sides of the relation, preserving fail-closed semantics.
3. Update the F1 spec and the parity fixture corpus in the same change, so both language
   implementations and the shared corpus move together.

Any resolution must keep the two implementations byte-equivalent in behaviour and must extend
`tests/fixtures/blast_radius/` rather than weakening existing expectations.

## Evidence

- `docs/features/active/2026-08-07-parallel-blast-radius-447/feature-audit.2026-08-07T17-32.md`
- `docs/features/active/2026-08-07-parallel-blast-radius-447/code-review.2026-08-07T17-32.md`
  (finding F-01)
