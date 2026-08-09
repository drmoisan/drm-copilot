# Acceptance-Criteria Check-Off ([P7-T9])

- Feature: `2026-08-07-parallel-drift-detection-446` (issue #446)
- Task: `[P7-T9]`
- Work Mode: `full-feature` (plan metadata line 9)
- AC sources per the `acceptance-criteria-tracking` skill (full-feature = both files):
  - `docs/features/active/2026-08-07-parallel-drift-detection-446/spec.md`, section
    `## Acceptance Criteria` (line 304)
  - `docs/features/active/2026-08-07-parallel-drift-detection-446/user-story.md`, section
    `## Acceptance Criteria` (line 76)

Timestamp: 2026-08-08T23-24

Command: `git diff` over the two AC source files; evidence gathered from the artifacts and test
files cited per criterion below. No test suite was re-executed for this task; it consumes the
[P7-T1] through [P7-T8] results.

EXIT_CODE: 0

Output Summary: 12 of 12 `spec.md` criteria checked; 6 of 9 `user-story.md` criteria checked.
Three `user-story.md` criteria remain unchecked, all three because their satisfaction depends on
F6 (`parallel-mutation-protocol`, issue #442) landing. F6 is a concurrent wave-4 sibling that has
not landed, so those three are recorded as cross-feature dependencies, not as F8 gaps. Only
`- [ ]` to `- [x]` transitions were made; no criterion text was altered and no criterion was added.

## Scope Note — Which Checkboxes Are Acceptance Criteria

`spec.md` also carries checkbox lists under `## Definition of Done` (line 353) and
`## Seeded Test Conditions (from potential)` (line 376). Neither is an
`## Acceptance Criteria` section, and [P7-T9] scopes the check-off to the
`## Acceptance Criteria` sections of the two files. Those two lists were therefore **not**
modified. They are recorded here as out of AC scope so their unchecked state is not read as an
F8 gap introduced by this task.

## spec.md — `## Acceptance Criteria` (12 items, 12 checked)

### SP-1 `[x]` — `detect_escaped_paths` returns paths not subsumed by declared `blast_radius.paths`

Evidence:

- Implementation: `scripts/dev_tools/parallel_drift_detection.py:104` (`detect_escaped_paths`),
  importing F1's predicate at line 40:
  `from scripts.dev_tools._blast_radius_glob import is_path_subsumed`. The predicate is imported,
  not reimplemented; the plan's `fnmatch.fnmatchcase` fallback was **not** used because a reusable
  predicate exists (IC-1a, `evidence/other/upstream-contract-reconciliation.2026-08-08T21-19.md`).
- Tests in `tests/scripts/dev_tools/test_parallel_drift_detection.py`, all four required matrix
  categories present:
  - no escape — `test_detect_escaped_paths_reports_no_escape_when_every_path_is_covered`
  - single escape — `test_detect_escaped_paths_reports_a_single_escape`
  - multiple escapes — `test_detect_escaped_paths_reports_multiple_escapes_sorted_and_deduplicated`
  - glob boundary cases — `test_detect_escaped_paths_glob_boundary_cases` (parametrized),
    `test_detect_escaped_paths_treats_an_empty_declared_radius_as_covering_nothing`
  - rename old/new both required — `test_detect_escaped_paths_requires_both_rename_paths_to_be_covered`,
    `test_detect_escaped_paths_reports_both_rename_paths_when_neither_is_covered`
- Purity and coverage: 100.00% line / 100.00% branch for the module
  (`evidence/qa-gates/python-test-final.2026-08-08T23-24.md`).

### SP-2 `[x]` — Append-only `drift_events[]` entry with the §12 shape

Evidence:

- Implementation: `build_drift_event` in `scripts/dev_tools/parallel_drift_detection.py`, with the
  key set fixed at line 93 as `DRIFT_EVENT_KEYS = ("item_key", "declared", "observed",
  "escaped_paths", "at", "action")` — exactly the six §12 fields, no additions.
- Tests: `test_build_drift_event_produces_exactly_the_section_12_shape`,
  `test_drift_event_key_set_matches_the_section_12_shape`,
  `test_build_drift_event_accepts_every_member_of_the_action_enum` (parametrized),
  `test_build_drift_event_rejects_an_out_of_enum_action`,
  `test_build_drift_event_rejects_an_empty_escaped_path_list`,
  `test_build_drift_event_returns_a_new_mapping_on_each_call` (append-only: each call returns a
  fresh mapping, so no prior entry is mutated).
- **Reconciled deviation recorded:** the criterion text names three `action` values
  (`blocking_finding_raised`, `halted_later_started`, `resolved`) and then admits "or F3's landed
  enum names, with the reconciliation recorded". F3's landed enum
  (`VALID_DRIFT_ACTIONS`, `scripts/dev_tools/_parallel_state_common.py:76-80`) has **exactly two**
  members, `raised_blocking_finding` and `halted_later_started_item`, and **no `resolved` member**.
  F8 imports that constant rather than redefining it
  (`test_action_constants_are_members_of_the_f3_owned_enum`). The criterion's own escape clause is
  therefore satisfied; the reconciliation is recorded in IC-3a of
  `evidence/other/upstream-contract-reconciliation.2026-08-08T21-19.md`, together with the
  two-disjunct resolution derivation that replaces the non-existent `resolved` member.

### SP-3 `[x]` — Synthetic Blocking finding in the child's own flat `remediation-inputs.<timestamp>.md`

Evidence:

- Documented procedure: `.claude/skills/parallel-orchestrate/SKILL.md`, subsection
  `#### Synthetic Blocking Finding` (within the F8 section), which fixes the path as
  `docs/features/active/<child-slug>/remediation-inputs.<yyyy-MM-ddTHH-mm>.md` in the flat form,
  requires the literal line `- Severity: Blocking` matched case-sensitively, and requires the
  escaped paths, the declared patterns, and the required action.
- Enforcement that the finding must exist before review: the hook's finding-presence seam
  `Test-ParallelDriftFindingPresent` at `.claude/hooks/enforce-parallel-drift-gate.ps1:75`, with
  the file-name constants `$script:FindingFilePrefix = 'remediation-inputs.'` (line 55) and
  `$script:FindingFileSuffix = '.md'` (line 56), and the deny message at line 483 naming
  `remediation-inputs.<timestamp>.md` explicitly.
- Pester tests in `tests/scripts/claude-hooks/enforce-parallel-drift-gate.Tests.ps1`:
  `Test-ParallelDriftFindingPresent reports presence for a remediation-inputs markdown file`,
  `... reports absence when no remediation-inputs file is present`,
  `... reports absence when the feature folder does not exist`,
  `allows an unresolved item once its synthetic finding file is recorded as written`,
  `denies when the latest drift event is unresolved and no finding has been written`.
- **Division of labour recorded (not an F6 dependency):** no F8 module writes the file. The
  SKILL.md subsection assigns the write to `parallel-orchestrator`, which owns the checkpoint and
  reaches the child's checkout through `items[].worktree_path`. `parallel-orchestrator` is F5
  (issue #441) and **has landed** (reconciliation Landing Status table). F8's deliverable for this
  criterion is the specified procedure plus the gate that makes an unwritten finding block review;
  both are present. The plan authored no F8 writer task, consistent with constraint 2.

### SP-4 `[x]` — Quiesce is derived state via `has_unresolved_drift`; no quiesce field added

Evidence:

- Implementation: `has_unresolved_drift(events, items) -> bool` at
  `scripts/dev_tools/parallel_drift_detection.py:237`, exported in `__all__` (line 84) alongside
  `unresolved_drift_item_keys` (line 88). Its docstring at lines 241-244 states it is "the single
  quiesce predicate F6's admission control consults (IC-6a)".
- Tests in `tests/scripts/dev_tools/test_parallel_drift_detection_quiesce.py`, covering all four
  plan-required scenarios plus the reconciled derivation:
  `test_has_unresolved_drift_reports_no_drift_for_an_empty_event_log`,
  `test_unresolved_drift_persists_while_the_radius_still_misses_the_escape`,
  `test_drift_resolves_when_the_radius_widened_to_cover_every_escaped_path` (disjunct a),
  `test_drift_resolves_when_the_radius_was_re_recorded_from_a_later_diff` (disjunct b),
  `test_one_items_resolution_does_not_mask_another_items_drift`,
  `test_the_latest_event_by_timestamp_decides_an_items_verdict`,
  `test_append_order_breaks_a_timestamp_tie_between_two_events`,
  `test_an_unresolvable_item_radius_keeps_the_drift_unresolved` (fail closed).
- **No quiesce field is written anywhere.** Quiesce is computed only.
- **Reconciled deviation:** the criterion says "the latest entry for any `item_key` has
  `action != "resolved"`". F3 defines no `resolved` action, so resolution is derived from the two
  disjuncts adopted in IC-3a (radius widened to cover every escaped path under `is_path_subsumed`,
  or radius re-recorded with `source == 'observed'` and `computed_at` strictly after the event's
  `at`). The predicate's semantics are the negation of that derivation, which is the reconciled
  form of the criterion.
- **Cross-feature note on the "single seam F6's admission control consults" clause:** the export is
  unconditional and there is exactly one such predicate, which is what F8 owes. The act of
  consulting it is the **IC-6a consultation edge, which is F6's to wire and is recorded as F6's
  acceptance dependency, not an F8 deliverable** (reconciliation IC-6a; plan Open Questions
  lines 524-525). F6's `spec.md` presently contains no reference to `has_unresolved_drift` or
  quiesce, so the edge is outstanding on F6's side. The corresponding operator-facing outcome
  criterion is `US-3`, which is left unchecked below for exactly this reason.

### SP-5 `[x]` — Conflict recomputation substitutes the observed radius and imports F1's `conflicts`

Evidence:

- Implementation: `recompute_conflicts_with_observed` in
  `scripts/dev_tools/parallel_drift_detection.py` (exported at line 85), importing from the F1
  facade at line 57 (`conflicts`, `radius_from_observed_paths`, `BlastRadius`). The observed radius
  is built by calling `radius_from_observed_paths`, never by hand — the IC-1b mandate that prevents
  silently dropping the module and shared-surface disjuncts.
- Tests in `tests/scripts/dev_tools/test_parallel_drift_detection_conflicts.py`, all five
  plan-required scenarios plus the no-mock binding:
  `test_recompute_conflicts_reports_nothing_when_no_new_conflict_appears`,
  `test_recompute_conflicts_reports_the_one_newly_conflicting_pair`,
  `test_recompute_conflicts_skips_a_pair_already_recorded_as_an_edge`,
  `test_recompute_conflicts_treats_an_unevaluable_peer_radius_as_conflicting` and
  `test_recompute_conflicts_treats_a_missing_peer_radius_as_conflicting` (fail closed),
  `test_recomputed_pair_feeds_halt_selection_and_yields_later_started_item`,
  `test_recompute_conflicts_builds_the_substituted_radius_from_observed_paths`,
  `test_recompute_conflicts_uses_the_real_relation_without_mocking` (proves the relation is the
  imported one, not a stand-in).
- `conflict_edges[]` is read-only in the tested path
  (`test_recompute_conflicts_skips_a_pair_already_recorded_as_an_edge`,
  `test_recompute_conflicts_ignores_an_unreadable_existing_edge`).

### SP-6 `[x]` — `select_halted_item` halts the later-started item with the three tie-breaks

Evidence:

- Implementation: `select_halted_item` in `scripts/dev_tools/parallel_drift_halt.py` (the
  contingency split the plan's Open Questions authorized), re-exported from
  `scripts/dev_tools/parallel_drift_detection.py:63`.
- Tests in `tests/scripts/dev_tools/test_parallel_drift_halt.py`, one per tie-break branch:
  - distinct timestamps — `test_select_halted_item_halts_the_later_timestamped_item`,
    `test_select_halted_item_ignores_argument_order_for_distinct_timestamps`
  - equal timestamps, larger `issue_num` halted —
    `test_select_halted_item_equal_timestamps_halt_the_larger_issue_number`
  - exactly one missing timestamp —
    `test_select_halted_item_missing_timestamp_makes_the_timestamped_item_earlier`,
    `test_select_halted_item_treats_a_blank_timestamp_as_missing`
  - both missing — `test_select_halted_item_both_timestamps_missing_falls_through_to_the_key`
  - totality/order independence — `test_select_halted_item_is_total_and_order_independent_over_every_pair`
- Determinism: `test_the_detection_and_halt_path_is_deterministic_across_repeated_calls`
  (`tests/scripts/dev_tools/test_parallel_drift_detection_conflicts.py:376`).
- The drifting item is never selected by virtue of drifting: the selection function receives only
  the two start markers and no drift information, documented in the SKILL.md
  `#### Halt the Later-Started Item` subsection.

### SP-7 `[x]` — `merge_status: blocked_drift`, exactly one `mutations[]` entry, generation +1, one seam

Evidence:

- Implementation: `request_requeue_via_recolor` in `scripts/dev_tools/parallel_drift_halt.py`
  (exported at `parallel_drift_detection.py:86`), returning a frozen `RequeueRequest`.
- Tests in `tests/scripts/dev_tools/test_parallel_drift_halt.py`:
  `test_request_requeue_via_recolor_requests_exactly_one_mutation_entry`,
  `test_request_requeue_via_recolor_increments_the_generation_by_exactly_one`,
  `test_request_requeue_via_recolor_requests_the_joint_blocked_drift_write`,
  `test_request_requeue_via_recolor_keeps_blocked_drift_out_of_the_state_slots`,
  `test_request_requeue_via_recolor_leaves_the_disposition_null`,
  `test_requeue_request_is_frozen_so_the_requested_intent_cannot_be_edited`,
  and `test_halt_module_contains_no_graph_coloring_logic` — the grep-style assertion proving no
  Welsh-Powell, cohort-assignment, or graph-coloring logic exists in F8's seam, i.e. no second
  recolor implementation.
- **Why this is checked while `US-4` and `US-6` are not:** this criterion's own text admits the
  alternative — "routed through the single recolor seam (**F6's entry point or the documented
  stub**)". The documented stub is delivered and tested, so the criterion is satisfied as written.
  The two user-story criteria that require the *checkpoint-visible outcome* of that requeue are a
  different assertion and are left unchecked below.
- **Reconciled deviation:** the plan's stated entry shape used
  `new_state: "blocked_drift"`, which is schema-invalid because `mutations[].new_state` is
  validated against the item-state enum. The adopted shape is `new_state: "blocked"` plus the
  separate `merge_status: blocked_drift` joint write required by invariant 8 (reconciliation IC-3a
  correction 4, corroborated by F6 `spec.md:235`). `test_request_requeue_via_recolor_keeps_blocked_drift_out_of_the_state_slots`
  pins the correction.

### SP-8 `[x]` — Layer-1 drift gate (already checked at Phase 5; evidence recorded here)

Evidence:

- Implementation: `.claude/hooks/enforce-parallel-drift-gate.ps1` (under the 500-line limit,
  contains no `git` invocation and no path-glob matching, emits `hookSpecificOutput` JSON).
- All seven plan-required scenarios have tests in
  `tests/scripts/claude-hooks/enforce-parallel-drift-gate.Tests.ps1`:
  `allows a non-feature-review subagent_type even under the marker`;
  `allows a feature-review delegation whose prompt lacks the parallel-mode marker`;
  `allows when the latest drift event is resolved by a later observed radius`;
  `allows an unresolved item once its synthetic finding file is recorded as written`;
  `denies when the latest drift event is unresolved and no finding has been written`;
  `denies (fail closed) when the checkpoint is missing` and
  `denies (fail closed) when the checkpoint content is malformed JSON`;
  `denies (fail closed) when no items[] record resolves to the prompt folder` and
  `denies (fail closed) when the prompt names no feature folder`.
- Marker byte-exactness is asserted against the source of truth:
  `asserts the hook marker constant is a substring of the marker line in SKILL.md`.
- Cross-runtime binding of the resolution derivation:
  `binds the PowerShell unresolved-drift decision to the Python unresolved_drift_item_keys derivation`.
- Registration: `.claude/settings.json` diff is exactly one appended `Agent`-matcher entry
  (4 insertions, 0 deletions) — verified below under SP-11.
- All 59 cases in this suite passed in the [P7-T7] run; hook line coverage 96.53%.

### SP-9 `[x]` — Layer-2 drift gate, key-gated (already checked at Phase 5; evidence recorded here)

Evidence:

- Implementation: `scripts/dev_tools/_parallel_orchestrator_state_drift.py`, dispatched by exactly
  one added call in `scripts/dev_tools/validate_parallel_orchestrator_state.py`.
- Tests in `tests/scripts/dev_tools/test_validate_parallel_orchestrator_state_drift.py`:
  `test_gate_returns_no_error_when_the_checkpoint_has_no_drift_events_key` (key-gated: zero new
  errors without the key);
  `test_gate_reports_one_error_per_progressed_item_with_unresolved_drift` (parametrized over the
  four progressed `merge_status` values);
  `test_progressed_statuses_are_all_members_of_the_f3_merge_status_enum`;
  `test_gate_reports_nothing_when_the_radius_widened_to_cover_the_escape` and
  `test_gate_reports_nothing_when_the_radius_was_rerecorded_from_a_later_diff` (the reconciled
  "resolved" condition);
  `test_gate_reports_nothing_for_an_item_that_has_not_progressed`;
  `test_gate_records_that_a_non_object_event_entry_left_it_unevaluable` and
  `test_gate_fails_closed_on_an_event_the_pure_module_refuses` (shape errors);
  `test_gate_does_not_mutate_the_checkpoint`;
  `test_public_validator_dispatches_the_drift_gate_and_reports_the_violation`,
  `test_public_validator_reports_no_drift_error_without_the_drift_events_key`,
  `test_public_validator_reports_the_gate_violation_under_the_completion_gate`.
- Module coverage 100.00% line / 100.00% branch.

### SP-10 `[x]` — R1-R5 reused unmodified; `.claude/skills/orchestrate/SKILL.md` not modified

Evidence:

- `git diff --stat .claude/skills/orchestrate/SKILL.md` produces **no output** — the file is
  untouched. This is the [P6-T1] acceptance condition and is independently re-verified at [P7-T9].
- No new remediation loop was authored: the SKILL.md F8 section step 6 reads "The child's existing
  R1 through R5 remediation loop processes the finding unmodified", and the synthetic finding is a
  `remediation-inputs.<timestamp>.md` file carrying `- Severity: Blocking`, which is the existing
  input shape the existing loop already consumes.
- Corroborated by `evidence/other/shared-file-edit-confinement.2026-08-09T03-19.md` ([P6-T2]).

### SP-11 `[x]` — Wave-4 contention constraints hold on all three shared files

Evidence, with the measured diffs:

| Shared file | `git diff --numstat` | Confinement verdict |
| --- | --- | --- |
| `.claude/skills/parallel-orchestrate/SKILL.md` | `240  1` | single hunk `@@ -445 +445,240 @@`; the one removed line is the reserved placeholder body being filled in place |
| `scripts/dev_tools/validate_parallel_orchestrator_state.py` | `2  0` | exactly one import line + one dispatch call, zero removed or reflowed lines |
| `.claude/settings.json` | `4  0` | exactly one appended `Agent`-matcher entry object, zero reordering |

- The SKILL.md diff is a **single hunk at line 445**, entirely inside F8's own reserved section, so
  neither sibling reserved section (`## Mutation Protocol (F6)` at 435, `## Enforcement Hooks (F7)`
  at 439) is reflowed, reordered, or retitled.
- The validator edit sits **above** the `BEGIN F7 EXTENSION SEAM` block and adds nothing inside it,
  per the adopted IC-3b edit location. F7's seam remains empty.
- `.claude/settings.json` gains exactly one entry appended after the last existing
  `Agent`-matcher hook; no existing entry moved.
- Full hunk quotations are in `evidence/other/shared-file-edit-confinement.2026-08-09T03-19.md`
  ([P6-T2]).

**RECONCILED TITLE DEVIATION (recorded, criterion treated as satisfied).** This criterion names the
section `## Radius Drift Detection and Drift Gate`. F5's landed reserved H2 is
**`## Radius Drift Detection (F8)` at `.claude/skills/parallel-orchestrate/SKILL.md:443`**, whose
own body instructed "content is appended by that feature and must not be relocated", making an
in-place fill mandatory and a retitle prohibited. Phase 6 therefore filled the reserved section in
place and added the criterion's named string as the first-line H3 inside it:

- Line 443: `## Radius Drift Detection (F8)` — the reserved H2, retained verbatim, not retitled.
- Line 445: `### Radius Drift Detection and Drift Gate` — the criterion's exact named string,
  present as the section's first heading.

Both the reserved-placeholder instruction and the criterion's named string are therefore satisfied
simultaneously, and the SKILL.md contains exactly one section carrying that title text. The
deviation between the criterion's assumed H2 title and the landed H2 title is recorded here and in
IC-5b of `evidence/other/upstream-contract-reconciliation.2026-08-08T21-19.md`.

### SP-12 `[x]` — All new modules pass their toolchains and meet the coverage thresholds

Evidence:

- Python loop, clean in a single pass: `poetry run black .` exit 0, zero reformats
  (`evidence/qa-gates/python-format-final.2026-08-08T23-24.md`); `poetry run ruff check .` exit 0,
  zero errors (`python-lint-final...`); `poetry run pyright` exit 0, zero errors
  (`python-typecheck-final...`); `poetry run pytest --cov --cov-branch` exit 0, 3176 passed /
  0 failed (`python-test-final...`).
- PowerShell loop: `run_poshqc_format` exit 0, zero reformats
  (`powershell-format-final...`); `run_poshqc_analyze` exit 0, zero findings
  (`powershell-analyze-final...`); `run_poshqc_test` exit 1, **all 59 new hook tests passing**, the
  single failure being the unrelated pre-existing `enforce-pr-author-skill.Tests.ps1` case that
  also failed at Phase 0 baseline (`powershell-test-final...`).
- Coverage: all six new Python modules at 100.00% line and 100.00% branch; the new PowerShell hook
  at 96.53% line. Verdict PASS in `evidence/qa-gates/coverage-delta.2026-08-08T23-24.md`.
- **Documented limitation, not a waiver:** PowerShell branch coverage is not emitted by Pester v5
  or by the repository's PoshQC pipeline. The negative claim carries SearchScope, SearchPatterns,
  and SearchResult evidence in both the [P7-T7] and [P7-T8] artifacts. The >= 75% branch threshold
  remains in force wherever measurable and is met at 100.00% for every new Python module.

## user-story.md — `## Acceptance Criteria` (9 items, 6 checked, 3 unchecked)

### US-1 `[x]` — An escaping pre-review diff records a `drift_events[]` entry without operator intervention

Evidence: `build_drift_event` plus the CLI's automatic emission. The CLI
(`scripts/dev_tools/parallel_drift_detection_cli.py`) returns `drift_event` non-null exactly when
`result != "no_escape"`, with no prompt or confirmation step. Tests:
`test_evaluate_drift_reports_no_escape_for_a_diff_inside_the_radius`,
`test_evaluate_drift_reports_no_new_conflict_when_no_peer_contends`,
`test_main_prints_the_detection_result_as_json`,
`test_main_dispatches_the_cli_inputs_into_the_pure_detection_function`. The child-side evaluation
point (between the pre-review commit and the `feature-review` delegation, active only under the
`Parallel mode: true` marker) is documented in the SKILL.md
`#### Child-Side Evaluation Point` subsection. See also SP-2.

### US-2 `[x]` — The escape is surfaced as a synthetic Blocking finding the existing R1-R5 loop processes

Evidence: same as SP-3 (path shape, literal `- Severity: Blocking` line, escaped paths and declared
patterns specified in the SKILL.md `#### Synthetic Blocking Finding` subsection; finding-presence
seam and its five Pester tests) plus SP-10 (no new remediation loop; `orchestrate/SKILL.md`
untouched, so no operator-facing new workflow was introduced).

### US-3 `[ ]` — UNCHECKED — cross-feature dependency on F6 (IC-6a consultation edge)

Criterion: "While any drift event is unresolved, no new item is admitted into the current cohort;
admission resumes automatically once the consuming remediation cycle exits with zero blocking
findings (no manual un-quiesce step exists)."

Reason left unchecked: **admission control is F6's surface, not F8's.** F8 delivers the quiesce
predicate (`has_unresolved_drift`, SP-4) and exports it unconditionally; the act of consulting it to
suspend admission is the **IC-6a consultation edge, which is F6's (`parallel-mutation-protocol`,
issue #442) to wire**. F6 has not landed — verified three ways in the reconciliation artifact:
its SKILL.md section is still the one-line reserved placeholder, its feature folder has no
`evidence/` directory and all-unchecked acceptance criteria, and a repo-wide grep for
`requeue_via_recolor|def recolor|recolor(` returns zero matches. F6's `spec.md` additionally
contains no reference to `has_unresolved_drift`, "unresolved drift", or "quiesce", so the edge is
not yet in F6's own specification. **This is recorded as F6's acceptance dependency, not an F8
gap**, per plan task [P1-T4], the plan's Open Questions note (lines 524-525), and IC-6a of
`evidence/other/upstream-contract-reconciliation.2026-08-08T21-19.md`. No remediation is required of
F8. F8's obligation — export the single predicate and add no quiesce field — is delivered.

### US-4 `[ ]` — UNCHECKED — cross-feature dependency on F6 (recolor entry point, IC-6b)

Criterion: "When the observed radius newly conflicts with a concurrently in-flight item, the
**later-started** item of the pair is halted (`merge_status: blocked_drift`) and requeued into a
future cohort; the drifting item is never the one halted."

Reason left unchecked: the halt half is fully delivered and tested (SP-6: later-started selection
with all three tie-breaks, order independence, determinism, and the structural guarantee that the
selection function receives no drift information so the rule cannot be inverted). The remaining
clause — **"requeued into a future cohort"** — requires F6's recolor entry point, which is **not
callable on the branch**. F6's own spec names it `recolor_unstarted` (not the plan's assumed
`requeue_via_recolor`) and marks its shape provisional; F2's landed
`scripts/dev_tools/parallel_cohort_computation.py` exposes only whole-graph `compute_cohorts` with
no pinned-subgraph recolor, no generation increment, and no `mutations[]` append, so there is
nothing existing to delegate to. F8 therefore ships exactly one documented stub seam that returns
the requeue intent for F6's landing to apply, and implements no second recolor. **Recorded as F6's
acceptance dependency, not an F8 gap** (IC-6b). Note that the F8-scoped form of this same behavior,
`SP-7`, is checked because its criterion text explicitly admits "F6's entry point **or the
documented stub**".

### US-5 `[x]` — Re-running the same detection inputs yields the same halt/requeue decision

Evidence: `test_the_detection_and_halt_path_is_deterministic_across_repeated_calls`
(`tests/scripts/dev_tools/test_parallel_drift_detection_conflicts.py:376`),
`test_request_requeue_via_recolor_is_deterministic_and_returns_fresh_data`,
`test_select_halted_item_is_total_and_order_independent_over_every_pair`. Structural basis: every
timestamp entering the halt decision is a function input; the pure modules perform no I/O and read
no wall clock, with the clock defaulted at the CLI boundary only
(`test_default_timestamp_uses_the_repository_timestamp_shape`,
`test_main_defaults_both_timestamps_from_the_clock_boundary`).

### US-6 `[ ]` — UNCHECKED — cross-feature dependency on F6 (mutation append via the recolor entry point)

Criterion: "Every requeue is visible in the checkpoint as one `mutations[]` entry with an
incremented `recolor_generation`, so the operator can audit how and why the cohort table changed."

Reason left unchecked: F8's seam **requests** exactly one `mutations[]` entry with
`recolor_generation` incremented by exactly one, and that request shape is pinned by tests
(`test_request_requeue_via_recolor_requests_exactly_one_mutation_entry`,
`test_request_requeue_via_recolor_increments_the_generation_by_exactly_one`,
`test_request_requeue_via_recolor_leaves_the_disposition_null`). But the criterion asserts the
operator-visible *checkpoint* outcome, and the append to `mutations[]` is not F8's write:
`.claude/skills/parallel-orchestrate/SKILL.md:394-397` records "`mutations[]`, which only F6 appends
to". The checkpoint-visible requeue therefore depends on F6's recolor entry point landing (IC-6b),
exactly as `US-4` does. **Recorded as F6's acceptance dependency, not an F8 gap.**

### US-7 `[x]` — A child with an unresolved, unsurfaced drift event cannot enter review

Evidence: same as SP-8. The operator-facing denial string is
`PARALLEL_DRIFT_GATE_BLOCKED` (`.claude/hooks/enforce-parallel-drift-gate.ps1:483`), asserted by
`denies when the latest drift event is unresolved and no finding has been written`. Already checked
at Phase 5; evidence recorded here.

### US-8 `[x]` — An unresolved item cannot show a review-progressed `merge_status` without a validator error

Evidence: same as SP-9. `test_gate_reports_one_error_per_progressed_item_with_unresolved_drift` is
parametrized over all four progressed values (`pr_open`, `ci_green`, `merged`,
`worktree_removed`), and `test_progressed_statuses_are_all_members_of_the_f3_merge_status_enum`
binds that list to F3's enum. Already checked at Phase 5; evidence recorded here.

### US-9 `[x]` — Existing non-parallel orchestrations are unaffected

Evidence, both halves:

- Hook fires only under the marker: `allows a feature-review delegation whose prompt lacks the
  parallel-mode marker`, `allows a feature-review delegation whose prompt is absent`,
  `allows when CLAUDE_TOOL_INPUT is empty`, `allows a non-feature-review subagent_type even under
  the marker`. The marker constant is asserted to be a byte-exact substring of the SKILL.md marker
  line (`asserts the hook marker constant is a substring of the marker line in SKILL.md`).
- Checkpoints without `drift_events[]` validate with zero new errors:
  `test_gate_returns_no_error_when_the_checkpoint_has_no_drift_events_key`,
  `test_public_validator_reports_no_drift_error_without_the_drift_events_key`,
  `test_public_validator_still_accepts_a_checkpoint_with_an_empty_drift_log`.
- Whole-suite corroboration: the Python suite grew from 3007 to 3176 passing with **zero**
  failures, and the PowerShell suite's failure count is unchanged at 1 (the pre-existing unrelated
  case), so no existing behavior regressed.

## Cross-Feature Dependency Register (for the epic orchestrator)

| ID | Owner | Blocks which AC | Status |
| --- | --- | --- | --- |
| IC-6a — F6's admission control consults `has_unresolved_drift` | F6, issue #442 | `US-3` (and the consultation clause of `SP-4`) | Outstanding. F8's export is delivered unconditionally. The edge is absent from F6's own `spec.md`, so F6 must add it at its plan time. |
| IC-6b — F6's recolor entry point applies the requeue intent | F6, issue #442 | `US-4` (requeue clause), `US-6` | Outstanding. F8 ships one documented stub seam; F6's entry point is named `recolor_unstarted` in its spec and is not callable. No second recolor exists in F8. |

Neither entry is an F8 defect and neither requires F8 remediation. Both are wave-4 sibling
dependencies recorded for the epic orchestrator to reconcile when F6 lands.

## Deviations Recorded

1. **SKILL.md section title** — criterion names `## Radius Drift Detection and Drift Gate`; the
   landed reserved H2 is `## Radius Drift Detection (F8)` (line 443) and the criterion's named
   string is the first-line H3 at line 445. Treated as satisfied; reconciled under SP-11 and IC-5b.
2. **`action` enum has no `resolved` member** — F3 defines exactly two members; resolution is a
   derived two-disjunct predicate rather than a recorded event. Reconciled under SP-2/SP-4 and
   IC-3a.
3. **`mutations[].new_state`** — the plan's `"blocked_drift"` is schema-invalid; the adopted shape
   is `new_state: "blocked"` plus the `merge_status: blocked_drift` joint write. Reconciled under
   SP-7 and IC-3a correction 4.
4. **Six new Python modules, not three** — the plan named three; the 500-line limit and the plan's
   own contingency note produced `parallel_drift_halt.py`, `_parallel_drift_shape.py`, and
   `_parallel_drift_cli_io.py` as well. All six are coverage-verified.
5. **PowerShell branch coverage unavailable** — toolchain measurement limitation with search
   evidence, explicitly not a threshold waiver. Recorded under SP-12 and in the [P7-T8] artifact.
6. **PowerShell test exit code 1** — attributable solely to the pre-existing, environment-dependent
   `enforce-pr-author-skill.Tests.ps1` failure that also failed at Phase 0 baseline. Zero additional
   failures. Recorded in the [P7-T7] artifact.

## AC Status Summary

### Acceptance Criteria Status
- Source: `docs/features/active/2026-08-07-parallel-drift-detection-446/spec.md` and `docs/features/active/2026-08-07-parallel-drift-detection-446/user-story.md`
- Total AC items: 21
- Checked off (delivered): 18
- Remaining (unchecked): 3
- Items remaining:
  - (`user-story.md`) While any drift event is unresolved, no new item is admitted into the current cohort; admission resumes automatically once the consuming remediation cycle exits with zero blocking findings (no manual un-quiesce step exists). — cross-feature dependency: F6 IC-6a consultation edge
  - (`user-story.md`) When the observed radius newly conflicts with a concurrently in-flight item, the **later-started** item of the pair is halted (`merge_status: blocked_drift`) and requeued into a future cohort; the drifting item is never the one halted. — cross-feature dependency: F6 IC-6b recolor entry point (halt half delivered)
  - (`user-story.md`) Every requeue is visible in the checkpoint as one `mutations[]` entry with an incremented `recolor_generation`, so the operator can audit how and why the cohort table changed. — cross-feature dependency: F6 IC-6b recolor entry point / `mutations[]` append

### Per-File Totals

| AC source file | Total | Checked | Unchecked |
| --- | --- | --- | --- |
| `spec.md` (`## Acceptance Criteria`, line 304) | 12 | 12 | 0 |
| `user-story.md` (`## Acceptance Criteria`, line 76) | 9 | 6 | 3 |
| **Combined** | **21** | **18** | **3** |

All three unchecked items are F6 cross-feature dependencies, not F8 gaps. No F8 remediation is
required for acceptance criteria.
