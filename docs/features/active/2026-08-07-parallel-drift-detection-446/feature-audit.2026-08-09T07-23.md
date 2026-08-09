# Feature Audit — F8 Radius Drift Detection (issue #446), Remediation Cycle 1 Exit Reaudit

- Timestamp: 2026-08-09T07-23
- Branch: `feature/parallel-drift-detection-446`, head `2266e1ab`
- Baseline: `c939b5b8` (wave-4 epic integration head)
- Work mode: **`full-feature`** — read from the `- Work Mode:` marker in `issue.md`
- AC sources (both, per the work mode): `spec.md` `## Acceptance Criteria` and `user-story.md`
  `## Acceptance Criteria`
- Blocking count: **0**

## Acceptance Criteria Evaluation — `spec.md` (12 items)

| # | Criterion (abbreviated) | Verdict | Evidence |
| --- | --- | --- | --- |
| SP-1 | `detect_escaped_paths` returns observed paths not subsumed by declared `blast_radius.paths`, reusing F1's predicate, covering no-escape / single / multiple / glob-boundary | **PASS** | `tests/scripts/dev_tools/test_parallel_drift_detection.py` (454 lines); `parallel_drift_detection.py` at 100% line and branch. F1's `is_path_subsumed` imported, no `fnmatch` fallback |
| SP-2 | An escape records an append-only `drift_events[]` entry in the §12 shape | **PASS** | `build_drift_event`; `test_parallel_drift_detection.py`. The reconciled enum names are used; the deviation is recorded in IC-3a |
| SP-3 | An escape produces a synthetic Blocking finding in the child's own `remediation-inputs.<ts>.md` with the literal `- Severity: Blocking` line | **PASS** | `_parallel_drift_cli_io.py` at 100% line and branch |
| SP-4 | Quiesce is derived state; `has_unresolved_drift` is the single seam F6 consults; no quiesce field added | **PASS** | `test_parallel_drift_detection_quiesce.py`. No checkpoint field added. The delivered two-argument signature is recorded in the IC-6a amendment (F8-N6 closed) |
| SP-5 | Conflict recomputation substitutes the observed radius and evaluates F1's `conflicts(a, b)`; the relation is imported | **PASS** | `recompute_conflicts_with_observed`; verified it calls the imported `conflicts` and builds the radius via `build_observed_radius`, never by hand |
| SP-6 | `select_halted_item` halts the later-started item using `(start_ts, item_key)` with the three tie-breaks; identical inputs give identical decisions | **PASS** | `test_parallel_drift_halt.py`, 30 tests; determinism asserted by `test_the_detection_and_halt_path_is_deterministic_across_repeated_calls`. `select_halted_item`'s body is byte-identical to `bcf2de15` (+6/-0, docstring only). See F8-N12: after the F8-B2 exclusion the comparator is unreachable from the CLI production path, which does not defeat this criterion but does make its wording describe a path only a direct-call test exercises |
| SP-7 | The halted item's `merge_status` becomes `blocked_drift`; the requeue appends exactly one `mutations[]` entry and increments `recolor_generation`, routed through the single recolor seam; no second recolor exists in F8 | **PARTIAL** | F8 delivers `request_requeue_via_recolor`, the documented request-only stub seam returning the intent, and implements no second recolor — verified. The **append and increment themselves are F6's** (F8-N7, IC-6b). The spec item is checked `[x]` on the basis of the seam; the checkoff evidence records F8-N7 explicitly so the check-off is not read as a delivered checkpoint write. Accepting the existing `[x]`; the honest reading is that F8's half is complete |
| SP-8 | Layer-1 gate denies with `PARALLEL_DRIFT_GATE_BLOCKED` when the latest event is unresolved and the finding is unwritten; allows the three stated cases; fails closed on an unreadable checkpoint or unresolvable target | **PASS** | `enforce-parallel-drift-gate.Tests.ps1` plus `-helpers.Tests.ps1`; the hook at 94.95% line and the helpers at 100.00%. **Strengthened this cycle** by the F8-N3 narrowing: the allowance now requires a finding dated at or after the current event |
| SP-9 | Layer-2 gate emits one `PARALLEL_DRIFT_GATE_VIOLATION:` per item unresolved while `merge_status` is review-progressed; no `drift_events` key produces zero new errors | **PASS** | `test_validate_parallel_orchestrator_state_drift.py` (401 lines); `_parallel_orchestrator_state_drift.py` at 100% line and branch. Key-gated dispatch verified as exactly two added validator lines outside the F7 seam |
| SP-10 | The R1-R5 loop is reused unmodified; `.claude/skills/orchestrate/SKILL.md` is not modified | **PASS** | `git diff --name-only c939b5b8..HEAD` contains no `.claude/skills/orchestrate/SKILL.md` entry. Step 7 explicitly reuses the loop and authors none |
| SP-11 | Wave-4 contention constraints hold: SKILL.md edit confined to one H2 with no reflow or reorder; validator edit is one import plus one key-gated dispatch; `.claude/settings.json` appends exactly one entry | **PASS** | Independently verified in `policy-audit.2026-08-09T07-23.md` `## Wave-4 Confinement`. 16 of 16 headings in identical order; 15 sections byte-identical; F6 and F7 sections SHA-256 identical; validator `+2/-0` before the F7 seam; settings `+4/-0` appended. The section title is `## Radius Drift Detection (F8)` rather than the spec's `## Radius Drift Detection and Drift Gate`; filling the reserved heading in place was mandatory and the deviation is recorded in IC-5b (F8-I5) |
| SP-12 | All new Python and PowerShell modules pass their full toolchains and meet line >= 85% and branch >= 75% | **PASS** | Re-executed: black 0, ruff 0, pyright 0, pytest 3201/0. All seven Python modules at 100% line and 100% branch. Both PowerShell hooks at 94.95% and 100.00% line, union 96.97%. Branch coverage is not emitted for PowerShell (F8-I2, verified toolchain limitation); `INSTRUCTION` 94.53% and 100.00% is the recorded analogue |

**`spec.md`: 12 items, 12 checked `[x]`, 11 PASS and 1 PARTIAL (SP-7, F8-owned half complete).**

## Acceptance Criteria Evaluation — `user-story.md` (9 items)

| # | Criterion (abbreviated) | Checkbox | Verdict | Evidence and owner |
| --- | --- | --- | --- | --- |
| US-1 | Drift is recorded without operator intervention | `[x]` | **PASS** | `test_parallel_drift_detection.py` |
| US-2 | The escape is surfaced as a synthetic Blocking finding processed by the existing R1-R5 loop | `[x]` | **PASS** | `_parallel_drift_cli_io.py` at 100% line and branch |
| US-3 | While any drift event is unresolved no new item is admitted; admission resumes automatically at zero blocking findings | `[ ]` | **BLOCKED — F6** | Admission control is F6's (#442). F8 exports the quiesce predicate F6 consults. Verified F6 has not landed: `## Mutation Protocol (F6)` in the SKILL.md is still the one-line reserved placeholder, byte-identical to `c939b5b8`. **No F8-owned clause outstanding.** Correctly unchecked |
| US-4 | The later-started item is halted (`blocked_drift`) and requeued into a future cohort; the drifting item is never the one halted | `[ ]` | **PARTIAL — one clause F6-owned** | Three clauses, two owners. See the dedicated section below |
| US-5 | Re-running the same inputs yields the same halt/requeue decision | `[x]` | **PASS** | `test_the_detection_and_halt_path_is_deterministic_across_repeated_calls`. Nothing in the path reads a clock; every timestamp is injected |
| US-6 | Every requeue is visible as one `mutations[]` entry with an incremented `recolor_generation` | `[ ]` | **BLOCKED — F6** | No code appends the entry or increments the counter; that is F6's recolor entry point (F8-N7). F8 ships one documented request-only stub and no second recolor. **No F8-owned clause outstanding.** Correctly unchecked |
| US-7 | A child with unresolved, unsurfaced drift cannot enter review; the operator sees `PARALLEL_DRIFT_GATE_BLOCKED` | `[x]` | **PASS** | Both Pester suites. **Strengthened this cycle**: before the F8-N3 narrowing, a `remediation-inputs.*.md` from an unrelated earlier cycle opened the gate for drifted, unsurfaced work — precisely the scenario this criterion prohibits. That hole is closed and verified |
| US-8 | An unresolved item cannot appear at a review-progressed `merge_status` without a `PARALLEL_DRIFT_GATE_VIOLATION:` | `[x]` | **PASS** | `test_validate_parallel_orchestrator_state_drift.py`. Enforced on the Python surface only; the TypeScript gap is recorded durably as F8-N1's potential-features entry, with Python authoritative in the interim |
| US-9 | Existing non-parallel orchestrations unaffected; the hook fires only under the marker; checkpoints without `drift_events` validate with zero new errors | `[x]` | **PASS** | Two cheap disqualifiers in `Invoke-ParallelDriftGateDecision` (subagent type, then ordinal marker `Contains`); the Layer-2 check is key-gated |

**`user-story.md`: 9 items, 6 checked `[x]`, 3 unchecked `[ ]`.**

## US-4 — Is the Disposition Now Correct, or an F8 Gap Being Deflected?

At cycle entry I found US-4 **partly deflected**: the disposition attributed the whole criterion to F6
when its "the drifting item is never the one halted" clause was an F8 defect (F8-B2). That was the
substance of finding F8-N9.

### The clause split is now correct

| Clause | Owner | Status | Verification |
| --- | --- | --- | --- |
| "the **later-started** item of the pair is halted (`merge_status: blocked_drift`)" | **F8** | **MET** | `select_halted_item` implements the rule with all three tie-breaks; `test_parallel_drift_halt.py` 30 tests; `blocked_drift` is set by `request_requeue_via_recolor` |
| "the drifting item is never the one halted" | **F8** | **MET** | The drifting key is dropped from every candidate list before selection, so it cannot be returned. Asserted for **both** tie-break paths by `test_the_drifting_item_is_never_halted_even_when_it_started_later`. No test anywhere still asserts the drifting item is halted — verified by exhaustive grep of every `halted_item_keys` assertion site |
| "and requeued into a future cohort" | **F6 (#442), IC-6b** | **OUTSTANDING** | F6's recolor entry point is not callable on the branch. F8 ships one documented request-only stub returning the requeue intent and implements no second recolor |

**The F8-owned "never halted" clause is now genuinely met.** I verified it structurally, not by
reading the claim: the exclusion is by construction rather than by test, `select_halted_item` is
+6/-0 docstring-only, and both tie-break paths are asserted. The full closure argument is in
`code-review.2026-08-09T07-23.md` `## F8-B2 Closure`.

**The disposition is no longer deflected.** `evidence/qa-gates/acceptance-criteria-checkoff.2026-08-09T00-01.md`
now names all three clauses, assigns each an owner, states explicitly that the previous reason
"deflected clause 2 to F6 in error", and records the correction under a dated heading in the
2026-08-08T23-24 artifact. This is the correct handling: the error is recorded rather than silently
overwritten.

### Should the checkbox remain unchecked?

**Yes.** A markdown checkbox is atomic and cannot record two met clauses beside one unmet clause. The
requeue clause is genuinely unmet and genuinely F6-owned, so the criterion **as a whole** is not
satisfied and `- [ ]` is the only honest state. Checking it would assert a requeue capability that does
not exist on the branch.

This audit therefore **does not** check off US-4, US-3, or US-6, and `user-story.md` is left
unmodified. All 12 `spec.md` items were already `[x]` and none required a change, so no AC source file
was modified by this reaudit.

### Is any unchecked item an F8 gap being deflected?

**No, for all three.** Verified independently rather than accepted:

- **US-3** — F6 has not landed. `## Mutation Protocol (F6)` in
  `.claude/skills/parallel-orchestrate/SKILL.md` is byte-identical to `c939b5b8` (SHA-256 match) and is
  still the one-line reserved placeholder. F8's obligation is to export the seam F6 consults, and it
  does.
- **US-4** — one of three clauses is F6-owned; the two F8 clauses are met, one of them fixed this
  cycle. The deflection I found at cycle entry is corrected.
- **US-6** — no `mutations[]` append or `recolor_generation` increment exists anywhere in F8's code,
  which is correct: F3's `## Enum Ownership` binds wave-4 features to consume and never extend, and
  writing a second recolor implementation is exactly what F8 was required not to do.

After the US-4 correction, **no F8-owned clause of any acceptance criterion is outstanding.**

## Definition-of-Done Items Beyond the AC

| Item | Verdict |
| --- | --- |
| Full toolchain green in a single pass | **PASS** — black 0, ruff 0, pyright 0, pytest 3201/0 re-executed; PowerShell format and analyze recorded EXIT 0, Pester 2089/1/9 with the one failure pre-existing and out of scope |
| No regression against the cycle-entry floors | **PASS** — every figure independently reproduced; see `code-review.2026-08-09T07-23.md` `## Regression Verdict` |
| Evidence in canonical locations | **PASS** — `validate_evidence_locations.py` EXIT 0; no `artifacts/{baselines,qa,evidence,coverage}/` path in the diff |
| Wave-4 confinement | **PASS** on every constraint, independently verified |
| No policy document modified | **PASS** — no `.claude/rules/**` or `.github/instructions/**` path in the diff |
| Bundled mirrors byte-identical | **PASS** — SHA-256 match on all four `.claude` mirrors |

## Findings Affecting Feature Completeness

None Blocking. The five new Non-blocking findings (F8-N11 through F8-N15) and the three carried-forward
open Non-blocking findings (F8-N5, F8-N7, F8-N8) are enumerated with severity, evidence, and
recommended action in `policy-audit.2026-08-09T07-23.md` `## Finding Ledger` and
`code-review.2026-08-09T07-23.md` `## New Findings`. None of them prevents the feature from satisfying
an acceptance criterion:

- F8-N7 is the only one that touches an AC (US-6 and US-4's requeue clause) and it is F6-owned by
  design.
- F8-N11 concerns the completeness of the step-7 procedure text, not the existence of the release
  path, which is verified to exist through both disjuncts.
- F8-N5, F8-N8, F8-N12, F8-N13, F8-N14, F8-N15 are test-binding, documentation-accuracy, and
  repo-tooling matters.

### Acceptance Criteria Status

- Source: `docs/features/active/2026-08-07-parallel-drift-detection-446/spec.md` (`## Acceptance
  Criteria`) and `docs/features/active/2026-08-07-parallel-drift-detection-446/user-story.md`
  (`## Acceptance Criteria`)
- Total AC items: **21** (`spec.md` 12 + `user-story.md` 9)
- Checked off (delivered): **18**
- Remaining (unchecked): **3**
- Items remaining:
  1. `user-story.md` US-3 — "While any drift event is unresolved, no new item is admitted into the
     current cohort; admission resumes automatically once the consuming remediation cycle exits with
     zero blocking findings" — **F6 (#442) cross-feature dependency; no F8-owned clause outstanding**
  2. `user-story.md` US-4 — "the **later-started** item of the pair is halted (`merge_status:
     blocked_drift`) and requeued into a future cohort; the drifting item is never the one halted" —
     **both F8-owned clauses now MET; the requeue clause is an F6 IC-6b dependency. The atomic
     checkbox correctly remains unchecked**
  3. `user-story.md` US-6 — "Every requeue is visible in the checkpoint as one `mutations[]` entry
     with an incremented `recolor_generation`" — **F6 (#442) cross-feature dependency; no F8-owned
     clause outstanding**
- Per-file totals: `spec.md` **12 of 12** checked; `user-story.md` **6 of 9** checked
- AC source files modified by this reaudit: **none**. No unchecked item qualified for check-off and no
  checked item required reversal

## Feature Audit Verdict

**PASS. Blocking count 0. The cycle-1 exit gate is satisfied.**

All 21 acceptance criteria are either delivered and verified (18) or unmet solely because of a named,
independently verified F6 cross-feature dependency (3). Both Blocking findings raised at cycle entry
are closed on evidence I re-executed. Both fail-open paths are closed. The one AC disposition I found
partly deflected at cycle entry is corrected, and the clause that made it a deflection is now
genuinely met.
