# Feature Audit — 2026-08-07-parallel-mutation-protocol-442 (Remediation Cycle 1 Exit Gate)

- **Timestamp:** 2026-08-09T03-58
- **Issue:** #442 (epic `parallel-orchestration`, child F6, wave 4)
- **Branch:** `feature/parallel-mutation-protocol-442`
- **Baseline:** `c939b5b8` (whole-branch diff base); remediation-cycle base `a9e2463c`; HEAD `fc10a471`
- **Work Mode:** `full-feature` (marker in `issue.md`) → AC sources are **`spec.md` (v1.2)** and
  **`user-story.md`**
- **Prior audit:** `feature-audit.2026-08-09T00-19.md` (D1 = the C1 defect)

## Overall Verdict

**PASS.** All 15 spec AC (S1-S15) and all 9 user-story AC (U1-U9) are satisfied under the **amended**
1.2 text. Every `[x]` check-off is honest. No AC was added, removed, or renumbered by the amendment.
Both design corrections are recorded as deliberate divergences from the epic design research with
rationale. **Blocking count: 0.**

## AC Set Integrity Under the 1.2 Amendment

| Source | AC count at `a9e2463c` | AC count at `fc10a471` | Added | Removed | Renumbered | Verdict |
|---|---|---|---|---|---|---|
| `spec.md` § Acceptance Criteria | 15 | **15** | 0 | 0 | 0 | PASS |
| `user-story.md` § Acceptance Criteria | 9 | **9** | 0 | 0 | 0 | PASS |

Verification: `awk '/^## Acceptance Criteria/{f=1;next} /^## /{f=0} f && /^- \[/{n++}'` over both
files at both revisions. The amendment changed the **text** of S2, S5, S9 and U1, U5 only; the
ordinal position of every item is unchanged, so S-numbers and U-numbers used by the prior audit
remain valid references. `grep -c "^- \[ \]"` over the AC sections returns 0 for both files.

The amendment record `evidence/other/remediation1-ac-set-integrity.md` makes the same claim; I
verified it independently rather than accepting it.

## Design Corrections Recorded as Deliberate Divergences

`spec.md:56-140` (`### Design corrections (spec 1.2)`) records both corrections with:

- the defective rule and where it came from — C1 quoted verbatim from
  `docs/research/2026-08-07-parallel-orchestration-design-research.md` **line 173** ("No conflict
  with any in-flight item, admit into the current cohort");
- the composed reasoning that makes each unsafe — C1 from `max_concurrency` slot filling within a
  cohort; C2 from the three-fact composition (dropped edge → isolated vertex → F2 class 0 → index 0
  is the current cohort while the barrier holds `current_cohort` at 0);
- the corrected rule, stated as four numbered steps for C2;
- the rejected alternative and why — an unconditional `+1` "would evacuate the running cohort of
  its not-yet-launched `scheduled` members even when no unstarted item conflicts with a pinned item,
  needlessly reducing concurrency with no correctness gain";
- an explicit **Deliberate divergence** paragraph (`:135-140`) naming the design document, both
  divergence points, and stating that document is **NOT amended** by this feature and remains the
  historical design record with this spec normative;
- an explicit **F2 is not modified** paragraph (`:130-133`).

**PASS.** Both divergences are recorded with rationale, and the epic design research is left
unmodified — correct, since F6 may not amend an epic-level artifact.

## Spec AC Evaluation (S1-S15) — under amended text

| # | Criterion (abbreviated) | Status | Evidence |
|---|---|---|---|
| S1 | Engine module exists with recolor, admission, removal, close, generation-accounting, entry, completion as **pure** functions; frozen dataclasses; injectable clock | **PASS** | `parallel_mutation_protocol.py` (499 lines) + `_parallel_mutation_entries.py`, `_parallel_mutation_models.py`, `_parallel_mutation_errors.py`. Purity asserted by `test_no_engine_call_mutates_the_generated_run`, `test_recolor_does_not_mutate_its_inputs`, `test_recolor_result_mapping_is_read_only`. `clock` is a **required** parameter on all four constructors. |
| S2 | `/parallel-add` skill; admits "only when the candidate conflicts with **no member of the current cohort, in-flight or unstarted**" (amended) | **PASS** | `.claude/skills/parallel-add/SKILL.md:68-110`. Engine at `parallel_mutation_protocol.py:183`. Regression test `test_conflict_with_an_unstarted_current_cohort_member_defers` at `test_parallel_mutation_admission.py:66`. Amended text is satisfied by the delivered code, not the reverse. |
| S3 | `/parallel-remove` implements the design §8.4 table exactly | **PASS** | `decide_removal` at `:344-432`, one branch per row. `parallel-remove/SKILL.md`. Row-per-test in `test_parallel_mutation_protocol_ops.py` (byte-unchanged). |
| S4 | `/parallel-close` skill; rejected while any item `in_flight` | **PASS** | `decide_close` at `:435-463` collects **all** blocking keys before raising. `parallel-close/SKILL.md`. |
| S5 | Pinning invariant proven by tests; recolor is a pure function of `(remaining subgraph, pinned set, pinned cohort index)`; assigns every unstarted item an index **strictly above** the pinned index whenever any unstarted item conflicts with a pinned item; P1, P2, P3, **P4** pass (amended) | **PASS** | Signature at `:200-207`. Offset at `:327`. P1 `TestPropertyOneDeterminism`, P2 `TestPropertyTwoIndependentSets`, P3 `test_parallel_mutation_pin_stability_properties.py`, P4 `test_parallel_mutation_contention_properties.py:425-493`. All four pass; I independently reproduced P4's three reversions. |
| S6 | Exactly one `mutations[]` entry per op with the seven fields; rejected ops append nothing | **PASS** | Four constructors; `MutationEntry.__post_init__` at `_parallel_mutation_models.py:389-450`. Rejection paths raise before constructing. |
| S7 | Recompute boundary; N ops from `g` end at `g + recompute count`, verified by test | **PASS** | `parallel_mutation_protocol.py:52-57`; `test_parallel_mutation_protocol_ops.py`. `spec.md:329-331` records that the offset changes only **which** index is assigned, never how many times the generation increments. |
| S8 | Mode-dependent completion: closed-mode predicate; open never auto-completes | **PASS** | `is_closed_mode_complete` at `:466-499`; `_parallel_orchestrator_state_mode_completion.py`. |
| S9 | Validator helper enforces entry shape, monotone generation, and the completion invariant **in its two-signal formalization** (close record + empty current-generation cohort set; close terminal in open mode; no firing on healthy in-progress or idle open; closed-mode completion guarded by F3 invariant 20 and deliberately not duplicated); wired by exactly one additive import and one call line (amended) | **PASS** | Amended clause-by-clause verified against `_parallel_orchestrator_state_mode_completion.py:249-289` (see `code-review.2026-08-09T03-58.md` § "The FR9 amendment matches the code"). Wiring: `validate_parallel_orchestrator_state.py:38` (import) and `:325` (call) — exactly two added lines, both **outside** the F7 seam. Upgraded from **PARTIAL** in the prior audit. |
| S10 | Abandon-gate hook: deny/allow/out-of-scope/malformed-JSON; registered by one additive `.claude/settings.json` entry | **PASS** | `enforce-parallel-abandon-gate.ps1` (259 lines, 0 analyzer findings, 86.96% line coverage). `.claude/settings.json` gains exactly one Bash-matcher entry. |
| S11 | Wave-4 contention constraint honored: only edit to `parallel-orchestrate/SKILL.md` is one appended section; no shared-file section reflowed or reordered; no schema field or enum value added; no existing epic implementation modified | **PASS** | Full confinement table in `policy-audit.2026-08-09T03-58.md`. Cycle-1 hunks at 440/461/505/601 all inside `## Mutation Protocol (F6)` (435..611). F7 and F8 placeholder bodies unchanged. F7 seam bytes unchanged. F2, F1, `.claude/rules/**`, `enforce-epic-*`, all epic validators/skills/agents absent from the diff. All nine enum member sets imported from `_parallel_state_common.py`. |
| S12 | Plan records and executes upstream re-verification before execution | **PASS** | `evidence/other/upstream-f1-conflicts-signature.md`, `upstream-f2-coloring-signature.md`, `upstream-f3-mutations-schema.md`, `upstream-f5-skill-sections.md`, `upstream-branch-verification.md`, `upstream-reconciliation-gate.md`. `plan.md` byte-identical to `a9e2463c`. |
| S13 | Black, Ruff, Pyright zero findings; line >= 85% and branch >= 75%; all Python tests under `tests/scripts/dev_tools/`; no file exceeds 500 lines | **PASS** | Re-run by this reviewer: black `393 files unchanged`; ruff `All checks passed!`; pyright `0 errors, 0 warnings, 0 informations`; `3407 passed`; line **92.0491%**, branch **84.1920%**. All twelve F6 test modules under `tests/scripts/dev_tools/`. Max file 500 lines. |
| S14 | PowerShell hook passes PoshQC format and PSScriptAnalyzer with zero findings; Pester covers deny/allow/out-of-scope/malformed-JSON with a **mocked read seam** | **PASS** | PoshQC procedure replicated in-memory: `FORMAT-CLEAN` on both F6 `.ps1` files. `Invoke-ScriptAnalyzer` with `pssa.settings.psd1`: 0 findings on each. `enforce-parallel-abandon-gate.Tests.ps1` (164 lines) passes within the 2043-passed run. |
| S15 | No test creates or uses temporary files; all tests deterministic (injected clock; seeded RNG with printed seed) | **PASS** | No `tempfile`/`tmp_path`/`NamedTemporary` in any F6 test. `test_parallel_mutation_cohort_invariant_binding.py` builds its checkpoint as an in-memory JSON string. `fixed_clock` in every property module. `GeneratedRun.__str__` prints seed + full shape into every assertion message; case ids are `seed{n}`. |

**15 of 15 PASS.** No item is PARTIAL, FAIL, or UNVERIFIED. Every `[x]` is honest under the amended
text; no criterion is checked whose amended text is unsatisfied.

## User-Story AC Evaluation (U1-U9) — under amended text

| # | Criterion (abbreviated) | Status | Evidence |
|---|---|---|---|
| U1 | `/parallel-add` prepares via a preparation-mode child run, computes edges over all items including in-flight, and admits "only when the candidate conflicts with **no member of the current cohort, in-flight or unstarted**" (amended) | **PASS** | `parallel-add/SKILL.md:47-110`. Step 3 heading is "Compute conflict edges over ALL items, including in-flight ones" and states "do not compute edges over the unstarted subset only." Engine at `:183`. Upgraded from PARTIAL. |
| U2 | `/parallel-remove` implements the §8.4 table; no default disposition; `merged` rejected | **PASS** | `decide_removal` at `:344-432`; `InFlightRemovalRequiresDispositionError`, `MergedItemRemovalRejectedError`. |
| U3 | `detach` lets the item finish; `abandon` closes PR, removes worktree, marks `withdrawn`, executable only through the hook-gated CLI | **PASS** | `parallel_mutation_abandon_cli.py` (362 lines, 100% line/branch); `enforce-parallel-abandon-gate.ps1`; `test_parallel_abandon_token_seam.py`. |
| U4 | `/parallel-close` terminates an open run; rejected while any item `in_flight` | **PASS** | `decide_close` at `:435-463`. |
| U5 | Pinning invariant: in-flight items never rescheduled; recolor is a pure function of `(remaining subgraph, pinned set, pinned cohort index)` and **never places an unstarted item in the pinned items' cohort when the two conflict** (amended) | **PASS** | Offset at `:327`; C2 regression at `test_parallel_mutation_recolor.py:66-99`; `TestPinnedBarrierOffset` four scenarios at `:202-311`; P4 at the composed level. Upgraded from PARTIAL. |
| U6 | Exactly one `mutations[]` entry per op; generation increments on recompute, stamped unchanged otherwise; rejected ops append nothing | **PASS** | Per-op table at `spec.md:335+`; `test_parallel_mutation_protocol_ops.py`. |
| U7 | Mode-dependent completion: closed completes on terminal merge status; open never auto-completes | **PASS** | `is_closed_mode_complete`; `_parallel_orchestrator_state_mode_completion.py`. |
| U8 | Abandon gate denies without the marker (`PARALLEL_ABANDON_BLOCKED`) and allows with it | **PASS** | `enforce-parallel-abandon-gate.ps1`; Pester suite. |
| U9 | Mutation log and generation counter make a changed cohort table fully traceable; validator rejects a non-monotone `recolor_generation` | **PASS** | `_parallel_orchestrator_state_mutations.py` monotonicity check; `test_validate_parallel_orchestrator_state_mutations.py`. |

**9 of 9 PASS.**

## Prior-Audit Discrepancy Disposition

| Prior ID | Description | Disposition |
|---|---|---|
| **D1** | `decide_admission` admitted a candidate conflicting with a `scheduled` member of the current cohort, breaking that cohort's independent-set property. Requirement-level defect inherited from design §8.3 line 173. | **RESOLVED** via the prior audit's option 1 (spec amendment + engine change + test). `spec.md` FR1 step 4, AC S2, and `user-story.md` U1 amended; `decide_admission` signature changed; regression test landed; P4 rejects the reversion (9 failed, independently reproduced). |
| S9 = PARTIAL | FR9 invariant 3 narrower than its spec/AC wording | **RESOLVED** → S9 now PASS. FR9 invariant 3 and AC S9 amended to the delivered two-signal formalization; the amended text matches the code clause by clause. |
| A6 (advisory) | Definition of Done and Seeded Test Conditions entirely unchecked while all AC checked | **UNCHANGED.** Carried forward as Advisory A1 in `policy-audit.2026-08-09T03-58.md`. Not an AC source under `full-feature`, so not a gate. |

## Second Defect Found During Remediation (C2) — not in the prior audit

The remediation preflight found a second defect the prior audit did not: `recolor_unstarted` dropped
the candidate-to-pinned **constraint** along with the pinned **vertices**, so a candidate deferred
because it conflicted with an in-flight item became an isolated vertex and F2 returned it to class 0
— which is the current cohort whenever `current_cohort == 0`, and the barrier cannot advance
`current_cohort` while any item is `in_flight`. Without C2, C1's fix was cosmetic on its primary
trigger.

Directing it fixed rather than deferred was the correct call: deferring it would have left an AC
(S5/U5) checked whose substance — "in-flight items are never rescheduled by any mutation" in its
operative sense — was not delivered.

The fix is sound on independent re-derivation. Full analysis in
`policy-audit.2026-08-09T03-58.md` § Finding C2, covering all four soundness sub-questions
(predicate computed before the restriction; injectivity of the uniform shift; no pinned item moves;
no false-negative on the predicate) plus the caller contract at `parallel-add/SKILL.md:59-66` that
prevents the predicate from being under-approximated.

## Reported Deviations — assessment

| # | Deviation | Assessment |
|---|---|---|
| a | `[P3-T8]` recorded `PENDING-PHASE-5` instead of `MIGRATED` for documented call shapes | **Not substantive.** Phase ordering is binding, and the migrating tasks are Phase 5. Discharged by `[P5-T7]`; all four call shapes are now migrated, verified by reading the three skills. |
| b | Fifth test module `test_parallel_mutation_pin_stability_properties.py` (286 lines) created because the contention module measured 584 against the 500 cap | **Not substantive; correct.** The alternatives were breaching the absolute cap or violating the plan's self-containment rule. Both P3 tests are present with their original names and assertions. |
| c | Three plan-internal budgets exceeded (220/200, 493/400, 326/260) | **Arithmetic correction.** All three are under the absolute 500-line cap, which is the policy constraint; the budgets are planning estimates. |
| d | `[P6-T4]` added four `per-file-ignores` lines rather than three | **Arithmetic correction.** One rationale comment plus three module entries, the third for the fifth module created under deviation (b). Confined to the same table. |
| e | `[P4-T12]` recorded a fourth disposition, `corrected (renamed)` | **Legitimate.** `[P4-T7]` explicitly directs the test be moved **and** corrected, and the corrected biconditional predicate makes the old name false. I verified the rename against the `a9e2463c` original: same corpus, same independent-derivation structure, blocking set widened from `pinned` to `pinned \| current_cohort_members`. Strictly stronger, not weakened. |

None is a substantive problem.

## Acceptance Criteria Status

```
### Acceptance Criteria Status
- Source: docs/features/active/2026-08-07-parallel-mutation-protocol-442/spec.md (v1.2),
          docs/features/active/2026-08-07-parallel-mutation-protocol-442/user-story.md
- Total AC items: 24 (15 spec + 9 user-story)
- Checked off (delivered): 24
- Remaining (unchecked): 0
- Items remaining: none
```

No AC item was newly checked off by this review — all 24 were already `[x]`, and this audit
confirms every one is honest under the amended text. No item required unchecking.

Non-AC checklists in `spec.md` (Definition of Done, 7 items; Seeded Test Conditions, 4 items) remain
entirely `[ ]`. Under `full-feature` these are not AC sources, so they are not gates; recorded as
Advisory A1 in `policy-audit.2026-08-09T03-58.md`. Two of the unchecked Seeded Test Conditions
(`spec.md:694-695`) additionally still carry pre-1.2 wording — Finding P1.
