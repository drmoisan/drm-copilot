# `2026-08-07-parallel-drift-detection` — User Story

- Issue: #446
- Owner: drmoisan
- Status: Draft
- Last Updated: 2026-08-07
- Spec: `docs/features/active/2026-08-07-parallel-drift-detection-446/spec.md`

## Story Statement

- As an engineer running a parallel batch, I want an in-flight item whose diff escapes its declared
  blast radius to be detected at its pre-review commit and surfaced as a Blocking finding in that
  item's own remediation inputs, so that the escape is remediated by the same R1-R5 loop I already
  trust and never reaches review or merge unresolved.
- As an engineer running a parallel batch, I want a detected escape to quiesce cohort admission,
  recompute conflicts with the observed radius, and — when a new conflict appears — halt and
  requeue the later-started item of the pair, so that the concurrency guarantee is restored without
  discarding the drifting item's broader-than-planned work.
- As an engineer resuming or auditing a parallel run, I want every drift event, halt, and requeue
  recorded in the checkpoint (`drift_events[]`, `mutations[]`, `recolor_generation`), so that a
  cohort table that changed mid-run is traceable rather than silently rewritten.

## Problem / Why

The `parallel` orchestration surface schedules items concurrently based on each item's **declared**
blast radius. The declared radius is derived heuristically from the approved atomic plan (design
§5.3), and derivation can under-report. An in-flight item whose actual diff escapes its declared
radius invalidates the concurrency guarantee for every item running beside it. Design §7 names this
the dominant failure mode of the whole design and the compensating control for heuristic
derivation.

V1 coverage validation (owned by F1 `parallel-blast-radius`) bounds under-reporting at plan time.
Radius-drift detection bounds it at execution time. The two together are the paired mitigation for
open risk §13.1; neither eliminates the risk.

## Personas & Scenarios

- Persona: **Operator of a parallel batch** — an engineer who launches `parallel-run` over several
  thematically unrelated bugs and features and expects them to merge to `main` independently.
  - Cares about: the concurrency guarantee holding without manual diff inspection; deterministic,
    explainable scheduling decisions; not losing completed work when a schedule changes.
  - Constraints: does not watch each child orchestration; relies on hooks and validators to stop
    unsafe transitions; resumes runs from the checkpoint.
  - Goals: maximum safe throughput; a clear audit trail when the run deviates from the plan.
  - Frustrations: silent schedule rewrites; failures surfaced only after merge.

- Scenario 1 — escape with no new conflict:
  - The operator has a cohort of three items in flight. Item #512 reaches its pre-review commit and
    its diff touches a file outside its declared `blast_radius.paths`.
  - Drift detection records a `drift_events[]` entry (`action: blocking_finding_raised`) and writes
    a synthetic Blocking finding into #512's own `remediation-inputs.<timestamp>.md`. Admission of
    new items into the current cohort is suspended. Conflict recomputation with the observed radius
    finds no new conflict with the other two in-flight items, so nothing is halted.
  - #512's ordinary R1-R5 remediation loop consumes the finding (plan, preflight, resolve,
    re-review). When the cycle exits with zero blocking findings, a `resolved` event is appended,
    quiesce clears itself, and the run proceeds. The operator intervened at no point.

- Scenario 2 — escape that creates a new conflict:
  - Items #520 (started 10:04) and #531 (started 10:12) are in flight. #520's pre-review diff
    escapes its radius, and recomputation with the observed radius shows a new conflict between
    #520 and #531.
  - The later-started item, #531, is halted: its `merge_status` becomes `blocked_drift`, a
    `mutations[]` entry is appended, `recolor_generation` increments, and #531 is requeued into a
    future cohort through the shared recolor path. #520 — whose broader work already exists — keeps
    running and remediates its drift finding through R1-R5.
  - The operator later reads the checkpoint and can reconstruct exactly what changed and why from
    `drift_events[]` and `mutations[]`.

- Scenario 3 — the gate stops an unsurfaced escape:
  - A child with an unresolved drift event whose finding has not yet been written is about to be
    delegated to `feature-review`. The Layer-1 hook denies the delegation with
    `PARALLEL_DRIFT_GATE_BLOCKED`. If the run's checkpoint ever records a review-progressed
    `merge_status` for an item with an unresolved drift event, the Layer-2 validator reports
    `PARALLEL_DRIFT_GATE_VIOLATION:` at `SubagentStop`, so the defect cannot pass silently.

## Acceptance Criteria

- [ ] When an in-flight item's pre-review diff includes a path outside its declared
      `blast_radius.paths`, the run records a `drift_events[]` entry for that item without
      operator intervention.
- [ ] The escape is surfaced to the affected child as a synthetic Blocking finding in that child's
      own `remediation-inputs.<timestamp>.md`, containing the literal `- Severity: Blocking` line,
      and the child's existing R1-R5 remediation loop processes it with no operator-facing new
      workflow.
- [ ] While any drift event is unresolved, no new item is admitted into the current cohort;
      admission resumes automatically once the consuming remediation cycle exits with zero
      blocking findings (no manual un-quiesce step exists).
- [ ] When the observed radius newly conflicts with a concurrently in-flight item, the
      **later-started** item of the pair is halted (`merge_status: blocked_drift`) and requeued
      into a future cohort; the drifting item is never the one halted.
- [ ] Re-running the same detection inputs yields the same halt/requeue decision, so the operator
      can reproduce and explain any scheduling change.
- [ ] Every requeue is visible in the checkpoint as one `mutations[]` entry with an incremented
      `recolor_generation`, so the operator can audit how and why the cohort table changed.
- [ ] A child with an unresolved, unsurfaced drift event cannot enter review: the operator sees a
      `PARALLEL_DRIFT_GATE_BLOCKED` denial rather than a review of drifted work.
- [ ] An item with an unresolved drift event cannot appear in the checkpoint with a
      review-progressed `merge_status` (`pr_open`, `ci_green`, `merged`, `worktree_removed`)
      without the validator reporting a `PARALLEL_DRIFT_GATE_VIOLATION:` error.
- [ ] Existing non-parallel orchestrations are unaffected: the hook fires only under the
      `Parallel mode: true` marker, and checkpoints without a `drift_events[]` key validate with
      zero new errors.

## Non-Goals

- Preventing drift from occurring. Detection compensates for heuristic radius derivation; the
  plan-time bound (F1's V1 validation) and the atomic-plan contract are out of scope.
- Halting or unwinding the drifting item. The design halts the later-started item of a newly
  conflicting pair; no configuration to invert this is provided.
- A new remediation workflow. Resolution is the existing R1-R5 loop, unmodified.
- Defining or extending the checkpoint schema (`drift_events[]`, `mutations[]`,
  `conflict_edges[]`, `recolor_generation`, `merge_status` enum) — owned by F3; this feature only
  populates those structures.
- Implementing recoloring or admission control — owned by F6; this feature routes its requeue
  through F6's recolor path via a single seam and exports the quiesce predicate F6 consults.
- Key-level partitioning of shared surfaces and any change to the epic surface (epic Non-Goals).
