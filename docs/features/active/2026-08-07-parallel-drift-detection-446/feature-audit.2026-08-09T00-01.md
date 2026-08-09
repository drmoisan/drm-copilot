# Feature Audit — F8 Radius Drift Detection (issue #446)

- Timestamp: 2026-08-09T00-01
- Branch: `feature/parallel-drift-detection-446`, commit `bcf2de15`
- Baseline: `c939b5b8` (epic integration head)
- Work mode: `full-feature` (`issue.md:12`)
- AC sources: `spec.md` `## Acceptance Criteria` (12 items) and `user-story.md`
  `## Acceptance Criteria` (9 items); total 21
- Verification basis: 205 tests re-executed during this review (all passing), independent
  recomputation of Python LCOV and PowerShell JaCoCo coverage, SHA-256 mirror comparison, and direct
  reading of the branch diff

## Verdict

The feature substantially delivers its execution-time drift-detection half. Nineteen of the
twenty-one acceptance criteria are met as written; one is met with a recorded reconciliation
deviation; one (spec #7) is PARTIAL by the criterion's own escape clause. Two Blocking defects sit
outside the AC text and block acceptance: the derived resolution has no producer (F8-B1) and halt
selection can select the drifting item (F8-B2). The second contradicts a user-story acceptance
criterion that is, correctly, unchecked.

## `spec.md` — Acceptance Criteria Evaluation (12 items)

| # | Criterion (abbreviated) | Verdict | Evidence | Checkbox action |
| --- | --- | --- | --- | --- |
| SP-1 | `detect_escaped_paths` returns paths not subsumed, reusing F1's predicate; no-escape, single, multiple, glob boundaries, rename both paths | **PASS** | `parallel_drift_detection.py:104-139` imports `is_path_subsumed` from `_blast_radius_glob`; no `fnmatch` fallback anywhere; `test_parallel_drift_detection.py` lines 135-292 cover all five categories including `test_detect_escaped_paths_requires_both_rename_paths_to_be_covered` | already `[x]`, retained |
| SP-2 | Append-only `drift_events[]` entry in the §12 shape, `item_key` = `issue_num`, `action` from F3's landed enum | **PASS** | `build_drift_event` (`:142-190`) returns exactly `DRIFT_EVENT_KEYS`; `test_build_drift_event_produces_exactly_the_section_12_shape`; F3 enum names adopted (`raised_blocking_finding`, `halted_later_started_item`) with the deviation recorded in IC-3a | already `[x]`, retained |
| SP-3 | Escape produces a synthetic Blocking finding in the child's flat `remediation-inputs.<ts>.md` with the literal `- Severity: Blocking` line, escaped paths, declared patterns | **PASS (procedure-only)** | `.claude/skills/parallel-orchestrate/SKILL.md` `#### Synthetic Blocking Finding` specifies the flat path, the actor (`parallel-orchestrator`), the `items[].worktree_path` route, the null-`worktree_path` consequence, the case-sensitive literal line, and the required contents. Consistent with the two existing synthetic-finding producers, which are also agent-procedural; the spec's Implementation Strategy defines no writer module | already `[x]`, retained |
| SP-4 | Quiesce is derived; the exported predicate is F6's single seam; no quiesce field added | **PASS with recorded deviation** | `has_unresolved_drift` (`:237-264`) exported; no quiesce field written anywhere; the criterion's literal `action != "resolved"` test is unimplementable because F3 defines no `resolved` member, and the reconciliation's IC-3a derivation replaces it. Signature widened to `(events, items)` — see F8-N6 | already `[x]`, retained |
| SP-5 | Conflict recomputation substitutes the observed radius and evaluates F1's `conflicts`; imported, not reimplemented | **PASS** | `recompute_conflicts_with_observed` (`:267-338`) builds the radius with `radius_from_observed_paths` and calls the facade `conflicts`; `test_recompute_conflicts_uses_the_real_relation_without_mocking` exercises the real relation unmocked; `test_recompute_conflicts_builds_the_substituted_radius_from_observed_paths` pins the constructor | already `[x]`, retained |
| SP-6 | `select_halted_item` halts the later-started item with the three documented tie-breaks; identical inputs, identical decisions | **PASS** | `parallel_drift_halt.py:167-195` and `_start_rank` (`:267-283`); one test per tie-break (`:57-123`); `test_select_halted_item_is_total_and_order_independent_over_every_pair`; `test_the_detection_and_halt_path_is_deterministic_across_repeated_calls`. The criterion as written concerns the mechanics only; the "never halt the drifting item" obligation lives in spec Constraints #1 and US-4, and is unmet (F8-B2) | already `[x]`, retained |
| SP-7 | Halted item's `merge_status` set to `blocked_drift`; requeue appends exactly one `mutations[]` entry and increments `recolor_generation` by one, routed through the single seam; no second recolor | **PARTIAL** | `request_requeue_via_recolor` (`:198-264`) returns a frozen `RequeueRequest` carrying the joint `blocked_drift`/`blocked` write, one invariant-16 mutation, and `generation + 1`. Nothing appends or increments: no checkpoint writer exists in F8. The single-seam and no-second-recolor halves are fully met and proved structurally by `test_halt_module_contains_no_graph_coloring_logic` | already `[x]`, **retained** — the criterion's own text admits "or the documented stub", and unchecking is outside the reviewer protocol; the gap is recorded here and in remediation inputs |
| SP-8 | Layer-1 hook denies with `PARALLEL_DRIFT_GATE_BLOCKED` when unresolved and unsurfaced; allows non-feature-review, no marker, resolved; fails closed on unreadable checkpoint or unresolved target | **PASS** | `enforce-parallel-drift-gate.ps1:419-484`; all seven scenarios have tests (`Tests.ps1` lines 47-158). Caveat F8-N3: the "has not been written" condition is satisfied by any `remediation-inputs.*.md`, including a stale one | already `[x]`, retained |
| SP-9 | Layer-2 invariant emits one `PARALLEL_DRIFT_GATE_VIOLATION:` per item unresolved with progressed `merge_status`; no `drift_events[]` key produces zero new errors | **PASS** | `_parallel_orchestrator_state_drift.py:90-149`; `test_gate_returns_no_error_when_the_checkpoint_has_no_drift_events_key`; per-status parametrized tests; ascending-order test; five tests exercise the public validator entry point end to end | already `[x]`, retained |
| SP-10 | R1-R5 reused unmodified; `.claude/skills/orchestrate/SKILL.md` not modified | **PASS** | `.claude/skills/orchestrate/SKILL.md` absent from `git diff c939b5b8..HEAD`; no remediation-loop file touched; the SKILL.md section states the loop is reused with the `remediation_pass` cap of 3 | already `[x]`, retained |
| SP-11 | Wave-4 contention constraints: SKILL.md edit confined to the single section with no reflow or reorder; validator edit is one import plus one dispatch; settings.json appends exactly one entry | **PASS with recorded deviation** | Validator diff is exactly `+2/-0`, dispatch above and outside the F7 seam; settings.json one appended entry; SKILL.md hunk confined to the F8 section with both siblings byte-identical and in original order. Deviation: the section title is the landed `## Radius Drift Detection (F8)`, not the spec's `## Radius Drift Detection and Drift Gate`, recorded in IC-5b (F8-I5) | already `[x]`, retained |
| SP-12 | All new Python and PowerShell modules pass their toolchains and meet line >= 85% and branch >= 75% | **PASS** | Python four stages `EXIT_CODE: 0`; six new modules 100% line / 100% branch, independently recomputed; repo-wide 92.02% / 84.11%; hook 96.53% line. PowerShell branch metric not emitted by Pester/JaCoCo — verified limitation, not a waiver (F8-I2). PowerShell test stage `EXIT_CODE: 1` from one verified pre-existing unrelated failure (F8-I3) | already `[x]`, retained |

`spec.md` totals: 12 items, 12 checked, 0 unchecked. Evaluations: 10 PASS, 1 PASS (procedure-only),
1 PARTIAL.

## `user-story.md` — Acceptance Criteria Evaluation (9 items)

| # | Criterion (abbreviated) | Verdict | Evidence | Checkbox action |
| --- | --- | --- | --- | --- |
| US-1 | An in-flight item's pre-review diff outside the declared radius records a `drift_events[]` entry without operator intervention | **PASS** | `evaluate_drift` (`parallel_drift_detection_cli.py:207-292`) emits the event whenever `escaped` is non-empty, with no prompt or confirmation; `test_evaluate_drift_reports_no_new_conflict_when_no_peer_contends` and the halt tests assert the event | already `[x]`, retained |
| US-2 | The escape is surfaced as a synthetic Blocking finding in the child's own `remediation-inputs.<ts>.md` with the literal `- Severity: Blocking` line, processed by the existing R1-R5 loop with no new operator workflow | **PASS (procedure-only)** | Same evidence as SP-3, plus the SKILL.md `#### Resolution Semantics` statement that the loop is reused unmodified with the shared `remediation_pass` cap | already `[x]`, retained |
| US-3 | While any drift event is unresolved no new item is admitted into the current cohort; admission resumes automatically with no manual un-quiesce step | **UNVERIFIED — cross-feature (F6)** | Admission control is F6's (IC-6a). Verified F6 has not landed: `## Mutation Protocol (F6)` is still its one-line placeholder, no `recolor_unstarted`/`requeue_via_recolor` symbol exists anywhere in `scripts/` or `.claude/`, and F6's own `spec.md` has no reference to `has_unresolved_drift` or quiesce. F8's obligations — export the single predicate, write no quiesce field — are delivered | `[ ]` retained unchecked |
| US-4 | The **later-started** item of a newly conflicting pair is halted (`merge_status: blocked_drift`) and requeued into a future cohort; **the drifting item is never the one halted** | **FAIL (partly cross-feature)** | Two unmet clauses with different owners. (i) "requeued into a future cohort" — F6's recolor entry point is not callable; F8 ships the documented stub returning the intent. (ii) "the drifting item is never the one halted" — **unmet by F8**: `_halted_item_keys` applies later-started selection to pairs that always contain the drifting item, so the drifting item is halted whenever it started later. Demonstrated by `test_evaluate_drift_halts_the_later_started_item_of_a_new_conflict`, where drifting item 446 is the asserted `halted_item_keys` value. See F8-B2 | `[ ]` retained unchecked |
| US-5 | Re-running the same detection inputs yields the same halt/requeue decision | **PASS** | `test_the_detection_and_halt_path_is_deterministic_across_repeated_calls` compares escapes, pairs, halt key, and requeue request field by field across two passes; no pure module reads a clock | already `[x]`, retained |
| US-6 | Every requeue is visible as one `mutations[]` entry with an incremented `recolor_generation` | **UNVERIFIED — cross-feature (F6)** | `mutations[]` is appended only by F6 (`SKILL.md:394-397`, "`mutations[]`, which only F6 appends to"). F8 forms the entry once, in the single seam, in the invariant-16 shape, and returns it. No writer exists on the branch | `[ ]` retained unchecked |
| US-7 | A child with an unresolved, unsurfaced drift event cannot enter review; the operator sees a `PARALLEL_DRIFT_GATE_BLOCKED` denial | **PASS** | `Invoke-ParallelDriftGateDecision:471-483`; `denies when the latest drift event is unresolved and no finding has been written`; four additional fail-closed deny tests. Caveat F8-N3 | already `[x]`, retained |
| US-8 | An item with unresolved drift cannot appear with a review-progressed `merge_status` without a `PARALLEL_DRIFT_GATE_VIOLATION:` error | **PASS** | `PROGRESSED_MERGE_STATUSES` is exactly `{pr_open, ci_green, merged, worktree_removed}` and is asserted a subset of F3's `VALID_MERGE_STATUS` at run time; parametrized per-status tests; `test_public_validator_dispatches_the_drift_gate_and_reports_the_violation` proves the error reaches the public entry point | already `[x]`, retained |
| US-9 | Existing non-parallel orchestrations unaffected: the hook fires only under the marker, and checkpoints without `drift_events[]` validate with zero new errors | **PASS** | Hook returns allow unless `subagent_type -ceq 'feature-review'` **and** the prompt ordinally contains `Parallel mode: true` (`:440-446`), with tests for empty input, non-feature-review, missing marker, and absent prompt; `validate_drift_gate` returns `[]` when the key is absent, asserted both on the helper and through the public entry point | already `[x]`, retained |

`user-story.md` totals: 9 items, 6 checked, 3 unchecked. Evaluations: 6 PASS (one procedure-only),
2 UNVERIFIED cross-feature, 1 FAIL.

## Adjudication of the Executor's Unchecked Disposition

The executor left three items unchecked and attributed all three to F6 cross-feature dependencies.
Assessed individually:

| Item | Executor's stated reason | Adjudication |
| --- | --- | --- |
| US-3 (IC-6a admission-control consultation edge) | F6's to wire; F8 exports the predicate regardless | **CORRECT, not deflection.** Admission control is unambiguously F6's scope per the epic decomposition and `.claude/rules/parallel-orchestration.md`. F8's two obligations are delivered and tested. F6's non-landing was verified three independent ways in the reconciliation and re-verified here (no F6 symbol exists in `scripts/` or `.claude/`) |
| US-4 (requeue-into-a-future-cohort clause) | Halt half fully delivered; only the requeue clause awaits F6's recolor entry point | **PARTLY DEFLECTED.** The requeue attribution is correct — F2's landed `parallel_cohort_computation.py` exposes only whole-graph `compute_cohorts`, so there is genuinely nothing to delegate to, and a second recolor is prohibited. But the criterion's third clause, "the drifting item is never the one halted", is unmet **by F8** and is not a cross-feature dependency. The stated reason relies on the narrowed claim that "the selection function receives no drift information so the rule cannot be inverted", which is true and beside the point: the drifting item is selected by start order, not by drift, and it is still the item halted. Recorded as F8-B2, with the disposition defect as F8-N9 |
| US-6 (`mutations[]`-visibility clause) | F6's to append; F8 forms the entry in the seam | **CORRECT, not deflection.** F5's own SKILL.md states `mutations[]` is appended only by F6. F8 forming the entry and returning it is the maximum F8 can deliver without implementing a second writer |

Two of the three dispositions are correct. The third is correct in outcome — the item must remain
unchecked — but its reason understates an F8 defect as a cross-feature wait.

## Definition of Done

| Item | Status |
| --- | --- |
| AC mapped to tests and checked off with evidence | Substantially met; 3 items outstanding, 1 for an F8 defect |
| Behavior matches AC; all Assumed contracts reconciled | Met for IC-1a, IC-1b, IC-3a, IC-3b, IC-5a, IC-5b; IC-6a/IC-6b recorded as documented stub-and-export against an unlanded F6 |
| Tests added per the Test Plan; edge cases and error handling covered | Met and exceeded — the plan named 4 test files; 7 plus a support module were delivered |
| Docs updated: SKILL.md section authored | Met (in the landed reserved section, title deviation recorded) |
| Python toolchain pass | Met, four stages `EXIT_CODE: 0`, independently spot-verified |
| PowerShell toolchain pass | Format and analyze met; test `EXIT_CODE: 1` from one verified pre-existing unrelated failure |

The `## Definition of Done` checkboxes in `spec.md` remain unchecked. They are not acceptance
criteria under the `full-feature` mode resolution and were not modified by this review.

## Seeded Test Conditions (`spec.md`)

| Condition | Status |
| --- | --- |
| Escape detection: none / single / multiple / glob boundaries | Covered |
| Later-started selection when two in-flight items newly conflict | Covered (all three tie-breaks plus order independence) |
| Drift gate blocks review while unresolved; permits once resolved | Covered at both layers |
| `drift_events[]` and `mutations[]` record shapes and `recolor_generation` increment | Covered as constructed shapes and requested intent; no checkpoint write exists (SP-7) |
| Integration scenario: drift event flows into the child's `remediation-inputs.<ts>.md` unchanged | Documented, not mechanized or tested |
| Determinism: identical inputs produce identical halt/requeue decisions | Covered |

These checkboxes are seeded test conditions rather than acceptance criteria and were not modified.

## Baseline Comparison

| Dimension | Baseline `c939b5b8` | Head `bcf2de15` |
| --- | --- | --- |
| Drift detection modules | none | 6 new Python modules, 1 new PowerShell hook |
| Layer-2 drift gate | absent | key-gated invariant dispatched from the public validator |
| Layer-1 drift gate | absent | registered `PreToolUse` `Agent` hook |
| SKILL.md F8 section | one-line reserved placeholder | 241-line procedure in the same reserved section |
| Python tests | 3007 passing | 3176 passing (+169) |
| Python line / branch coverage | 91.82% / 83.80% | 92.02% / 84.11% |
| PowerShell measured production files | 41 | 47 (hook added to `CodeCoverage.Path`) |
| PowerShell pre-existing failure | 1 (`enforce-pr-author-skill.Tests.ps1`) | same 1, unchanged |

No previously covered line lost coverage in either language. No regression was introduced in any
existing test.

## Gaps Requiring Remediation

| ID | Severity | Gap | Related AC |
| --- | --- | --- | --- |
| F8-B1 | Blocking | The derived resolution has no producer and no documented resolving write, so the Layer-2 gate can permanently block an item's merge progression | SP-4, SP-9, US-8 (all met as written; the gap is the missing release path) |
| F8-B2 | Blocking | Halt selection can select the drifting item, contradicting `spec.md` Constraints #1 and US-4 | US-4 |
| F8-N7 | Non-blocking | No code appends the `mutations[]` entry or increments `recolor_generation`; SP-7's check-off rests on its stub escape clause | SP-7, US-6 |
| F8-N1 | Non-blocking | TypeScript Layer-2 gate parity absent with no durable repo-level record | US-8 |
| F8-N3 | Non-blocking | Any `remediation-inputs.*.md` satisfies the Layer-1 finding-presence check | SP-8, US-7 |
| F8-N9 | Non-blocking | US-4's unchecked-disposition reason omits the "never halted" clause | US-4 |

The full finding register, including the remaining Non-blocking and Informational items, is in
`policy-audit.2026-08-09T00-01.md`; the analysis and remedies are in
`code-review.2026-08-09T00-01.md`.

## Acceptance Criteria Status

### Acceptance Criteria Status
- Source: `docs/features/active/2026-08-07-parallel-drift-detection-446/spec.md` and
  `docs/features/active/2026-08-07-parallel-drift-detection-446/user-story.md`
- Total AC items: 21
- Checked off (delivered): 18
- Remaining (unchecked): 3
- Items remaining:
  - (`user-story.md`) While any drift event is unresolved, no new item is admitted into the current
    cohort; admission resumes automatically once the consuming remediation cycle exits with zero
    blocking findings (no manual un-quiesce step exists). — UNVERIFIED, cross-feature: F6 IC-6a
    consultation edge. Disposition adjudicated CORRECT.
  - (`user-story.md`) When the observed radius newly conflicts with a concurrently in-flight item,
    the **later-started** item of the pair is halted (`merge_status: blocked_drift`) and requeued
    into a future cohort; the drifting item is never the one halted. — FAIL. Two unmet clauses:
    the requeue clause is cross-feature (F6 IC-6b); the "drifting item is never halted" clause is an
    F8 defect (F8-B2). Disposition adjudicated PARTLY DEFLECTED.
  - (`user-story.md`) Every requeue is visible in the checkpoint as one `mutations[]` entry with an
    incremented `recolor_generation`, so the operator can audit how and why the cohort table
    changed. — UNVERIFIED, cross-feature: F6 IC-6b `mutations[]` append. Disposition adjudicated
    CORRECT.

### Per-File Totals

| AC source file | Total | Checked | Unchecked |
| --- | --- | --- | --- |
| `spec.md` (`## Acceptance Criteria`, line 304) | 12 | 12 | 0 |
| `user-story.md` (`## Acceptance Criteria`, line 76) | 9 | 6 | 3 |
| **Combined** | **21** | **18** | **3** |

### Check-Off Actions Taken by This Review

No checkbox was modified. Every item this review evaluated PASS was already `[x]`, so no
check-off was required. The three unchecked items are evaluated UNVERIFIED, FAIL, and UNVERIFIED
respectively and correctly remain `[ ]`. One already-checked item, SP-7, is evaluated PARTIAL; its
checkbox was retained because the criterion's own text admits the documented stub and because
unchecking is outside the reviewer protocol of the `acceptance-criteria-tracking` skill. The gap is
recorded above and in the remediation inputs.
