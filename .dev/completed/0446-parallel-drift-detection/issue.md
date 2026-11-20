# parallel-drift-detection (Issue #446)

- Date captured: 2026-08-07
- Author: Dan Moisan
- Status: Promoted -> docs/features/active/parallel-drift-detection/ (Issue #446)
- Epic: `parallel-orchestration` (child F8)
- Design source: `docs/research/2026-08-07-parallel-orchestration-design-research.md` sections 7, 9, 12

- Issue: #446
- Issue URL: https://github.com/drmoisan/drm-copilot/issues/446
- Last Updated: 2026-08-07
- Work Mode: full-feature

## Problem / Why

The `parallel` orchestration surface schedules items concurrently based on each item's **declared**
blast radius. The declared radius is derived heuristically from the approved atomic plan (design
section 5.3), and derivation can under-report. An in-flight item whose actual diff escapes its
declared radius invalidates the concurrency guarantee for every item running beside it. Design
section 7 names this the dominant failure mode of the whole design and the compensating control for
heuristic derivation.

V1 coverage validation (owned by F1 `parallel-blast-radius`) bounds under-reporting at plan time.
Radius-drift detection bounds it at execution time. The two together are the paired mitigation for
open risk 13.1; neither eliminates the risk.

## Proposed Behavior

Implement the design section 7 six-step procedure, evaluated at each child's pre-review commit:

1. Compare `git diff --name-only` against the declared `blast_radius.paths`.
2. On escape, record a `drift_events[]` entry and raise a synthetic Blocking finding in the child's
   own `remediation-inputs.<timestamp>.md`.
3. Quiesce: suspend admission of new items into the current cohort.
4. Recompute conflicts using the observed radius.
5. If the escape newly conflicts with a concurrently in-flight item, halt the **later-started** item
   of the pair, set its state to `blocked_drift`, and requeue it into a future cohort.
6. The child's existing R1-R5 remediation loop processes the finding unmodified.

Also implement the **drift gate** from design section 9: block a child's transition to review while
an unresolved `drift_events[]` entry exists for that item.

## Acceptance Criteria (early draft)

- [ ] Diff-versus-declared comparison detects paths outside `blast_radius.paths` and returns the escaped set.
- [ ] An escape records a `drift_events[]` entry with the section 12 shape `{ item_key, declared, observed, escaped_paths[], at, action }`.
- [ ] An escape raises a synthetic Blocking finding written into the child's own `remediation-inputs.<timestamp>.md`.
- [ ] Quiesce suspends admission of new items into the current cohort.
- [ ] Conflict recomputation uses the observed radius via F1's `conflicts(a, b)` relation.
- [ ] A newly conflicting pair halts the **later-started** item, sets its `merge_status` to `blocked_drift`, and requeues it into a future cohort.
- [ ] The requeue appends a `mutations[]` entry and increments `recolor_generation`.
- [ ] The drift gate blocks a child's transition to review while an unresolved `drift_events[]` entry exists for that item.
- [ ] The R1-R5 remediation loop is reused unmodified; no new remediation loop is authored.

## Constraints & Risks

- **Halt the later-started item, not the drifting item.** Deliberate per design section 7: the
  drifting item's work is already broader than planned and is more expensive to unwind.
- **Reuse R1-R5 unmodified.** The drift finding is processed exactly as a local blocking finding.
- **Additive only.** Do not modify or refactor the existing epic implementations.
- **Surface name is `parallel` throughout.**
- **Wave-4 contention.** F6 (`parallel-mutation-protocol`) and F7 (`parallel-enforcement-hooks`)
  execute concurrently and also extend `.claude/skills/parallel-orchestrate/SKILL.md` and
  `validate_parallel_orchestrator_state.py`. All edits must be confined to a distinct, explicitly
  named new section and must not reflow or reorder existing sections.
- **F3 owns the checkpoint schema** including `drift_events[]`; this feature populates that
  structure rather than adding schema fields.
- **Shared recolor path with F6.** The step 5 requeue and F6's mutation-driven recolor must both go
  through the same recolor path and both increment `recolor_generation` (design section 8.6).

## Test Conditions to Consider

- [ ] Unit coverage: escape detection (no escape, single escape, multiple escapes, glob boundary cases).
- [ ] Unit coverage: later-started selection when two in-flight items newly conflict.
- [ ] Unit coverage: drift gate blocks review transition while unresolved; permits it once resolved.
- [ ] Unit coverage: `drift_events[]` and `mutations[]` record shapes and `recolor_generation` increment.
- [ ] Integration scenario: drift event flows into the child's `remediation-inputs.<timestamp>.md` unchanged.
- [ ] Determinism: identical inputs produce identical halt/requeue decisions.

## Next Step

- [ ] Promote to GitHub issue (feature request template)
- [ ] Create `docs/features/active/parallel-drift-detection/` folder from the template
