# Policy Audit — 2026-08-07-parallel-mutation-protocol-442 (Remediation Cycle 1 Exit Gate)

- **Timestamp:** 2026-08-09T03-58
- **Issue:** #442 (epic `parallel-orchestration`, child F6, wave 4)
- **Branch:** `feature/parallel-mutation-protocol-442`
- **Whole-branch diff base:** `c939b5b8` (wave-0-3 integration head) — this is the audit scope
- **Remediation-cycle diff base:** `a9e2463c` (base plan's delivered work)
- **HEAD:** `fc10a471`
- **Work Mode:** `full-feature` (from `issue.md`) → AC sources are `spec.md` (v1.2) and `user-story.md`
- **Prior audit:** `policy-audit.2026-08-09T00-19.md` (1 Blocking, 5 Partial, 9 Advisory)

## Overall Verdict

**PASS — remediation cycle 1 exit condition satisfied. Blocking count: 0.**

Both design corrections (C1, C2) are correct on independent re-derivation from the code, not from
the docstrings. Property P4 is genuinely load-bearing: I reproduced all three reversions myself and
additionally established that P4's *contention* assertion catches the removed offset on its own,
which is stronger than the executor claimed. All four remediable Partials are discharged; the fifth
(TypeScript parity) is deferred with a recorded artifact. One new Partial is raised: the spec 1.2
amendment left three pre-1.2 formulations in place, one of them inside the normative
`## Non-Negotiable Constraints` section.

| Classification | Count |
|---|---|
| Blocking | **0** |
| Partial | 2 (1 new, 1 carried at reduced severity) |
| Advisory | 6 |

## Rejected Scope Narrowing

None. The caller directive supplied the whole-branch diff base (`c939b5b8`) and the
remediation-cycle base (`a9e2463c`) as distinct scopes, and explicitly directed a full-branch
confinement verification (directive item 8). No attempted narrowing to a plan, task, phase, or
file subset was present, and no language's coverage was marked out of scope.

## Evidence Location Compliance

No file in the branch diff (`git diff --name-only c939b5b8 fc10a471`) is written under
`artifacts/baselines/`, `artifacts/qa/`, `artifacts/evidence/`, or `artifacts/coverage/`. All
evidence lives under
`docs/features/active/2026-08-07-parallel-mutation-protocol-442/evidence/<kind>/`
(`baseline/`, `remediation-baseline/`, `qa-gates/`, `regression-testing/`, `other/`).

```
$ poetry run python scripts/dev_tools/validate_evidence_locations.py --root .
EXIT=0
```

**PASS.** No `EVIDENCE_LOCATION_OVERRIDE_REJECTED` events occurred during this review.

## Coverage Verification (mandatory, per language with changed files)

| Language | Changed files on branch | Coverage artifact | Repo line | Repo branch | Verdict |
|---|---|---|---|---|---|
| Python | 8 production, 12 test | `artifacts/python/lcov.info` | **92.0491%** (12816/13923) | **84.1920%** (4314/5124) | **PASS** |
| PowerShell | 2 (`.ps1`) | `artifacts/pester/powershell-coverage.xml` | **94.8072%** line / 94.4104% instruction | not emitted by Pester JaCoCo | **PASS** |
| TypeScript | 0 (see note) | n/a | n/a | n/a | N/A — zero changed `.ts` files |
| C# | 0 | n/a | n/a | n/a | N/A — zero changed `.cs` files |

TypeScript note: `extensions/drm-copilot/resources/**` mirrors and `pack-manifests/core.json` are
touched, but no `.ts` source file is in the branch diff. `git diff --name-only c939b5b8 fc10a471`
returns no path under `extensions/drm-copilot/src/`. The verdict `N/A` is therefore admissible for
TypeScript under the Coverage Verification rule (zero changed files), not an excused omission.

### New-file coverage (added in this feature) — threshold: line >= 85%, branch >= 75%

Computed from `artifacts/python/lcov.info` after `poetry run pytest --cov --cov-branch`:

| New Python file | Line | Branch | Verdict |
|---|---|---|---|
| `scripts/dev_tools/parallel_mutation_protocol.py` | 100.00% | 100.00% | PASS |
| `scripts/dev_tools/_parallel_mutation_models.py` | 100.00% | 100.00% | PASS |
| `scripts/dev_tools/_parallel_mutation_entries.py` | 100.00% | 100.00% | PASS |
| `scripts/dev_tools/_parallel_mutation_errors.py` | 100.00% | 100.00% | PASS |
| `scripts/dev_tools/_parallel_orchestrator_state_mutations.py` | 100.00% | 100.00% | PASS |
| `scripts/dev_tools/_parallel_orchestrator_state_mode_completion.py` | 100.00% | 100.00% | PASS |
| `scripts/dev_tools/parallel_mutation_abandon_cli.py` | 100.00% | 100.00% | PASS |
| `.claude/hooks/enforce-parallel-abandon-gate.ps1` (new PS) | 86.96% (40/46) | n/a | PASS |

All seven F6 Python modules are at 100% line and 100% branch — the reported figure is exact.

### Modified-file coverage (no regression on changed lines)

| Modified file | Line | Verdict |
|---|---|---|
| `scripts/dev_tools/validate_parallel_orchestrator_state.py` | 97% (F3-owned; +1 import, +1 call line) | PASS — no regression |
| `pyproject.toml`, `pester.runsettings.psd1`, `pack-manifests/core.json` | config, not measured | N/A |

Repo-wide Python coverage **increased** against the remediation baseline (line 92.0486% → 92.0491%,
branch 84.1859% → 84.1920%). No regression on any changed line.

## Toolchain Verification (all stages re-run by this reviewer)

| Stage | Command | Result | Reported | Verdict |
|---|---|---|---|---|
| Python format | `poetry run black --check .` | `393 files would be left unchanged` | 393 clean | PASS |
| Python lint | `poetry run ruff check .` | `All checks passed!` | clean | PASS |
| Python type-check | `poetry run pyright` | `0 errors, 0 warnings, 0 informations` | 0 errors | PASS |
| Python test | `poetry run pytest --cov --cov-branch` | `3407 passed in 11.69s` | 3407/0 | PASS |
| PS format | PoshQC procedure replicated in-memory (CRLF→LF, `pssa.settings.psd1`) on both F6 `.ps1` files | `FORMAT-CLEAN` ×2 | clean | PASS |
| PS lint | `Invoke-ScriptAnalyzer -Settings scripts/powershell/PoshQC/settings/pssa.settings.psd1` | hook 0 findings, tests 0 findings | 0 findings | PASS |
| PS test | `Invoke-PoshQCTest` | `Passed: 2043, Failed: 1, Skipped: 9` | 2043/1/9 | PASS |

Every reported figure in directive item 12 is verified exact except repo-wide PowerShell line
coverage, where my run measured 94.8072% line / 94.4104% instruction against the reported
94.3362%. Both are far above the 85% threshold; the delta is a measurement-basis difference
(instruction vs line counter), not a regression. Recorded as Advisory A5.

### The single PowerShell failure is the known pre-existing one

Parsed from `artifacts/pester/pester-junit.xml` by locating each `<failure` offset and taking the
nearest *preceding* `<testcase>` opening tag (a non-greedy `<testcase>.*?</testcase>` regex
mis-associates failures):

```
<testsuites ... tests="2053" errors="0" failures="1" disabled="9" time="99.918">
FAILURE -> <testcase name="enforce-pr-author-skill.ps1.allowed commands.allows gh pr create
  --body-file artifacts/pr_body_12.md when context exists" status="Failed"
  classname="...tests\scripts\claude-hooks\enforce-pr-author-skill.Tests.ps1" ...>
```

This is the sole failure and it is exactly the out-of-scope case. The file
`tests/scripts/claude-hooks/enforce-pr-author-skill.Tests.ps1` does **not** appear in
`git diff --name-only c939b5b8 fc10a471`, so neither it nor its hook was edited. **Not a
regression; not counted against this feature.** The restraint in leaving it untouched is correct.

## Finding C1 — Admission checks the full current cohort (prior Blocking B1/R1)

**Verdict: RESOLVED.**

`scripts/dev_tools/parallel_mutation_protocol.py:121-197`. The signature is now
`decide_admission(candidate, conflict_edges, in_flight, *, current_cohort_members) -> AdmissionDecision`,
with `current_cohort_members` required and keyword-only. Line 183 forms
`blocking_keys = in_flight | current_cohort_members`, and lines 188-195 scan both endpoint
positions of every edge, deferring on the first conflict with any blocking key.

The rule strictly generalizes the prior one: every `in_flight` item is a current-cohort member, so
every previously-deferred candidate is still deferred. Keyword-only placement is load-bearing — a
default would silently restore the defective rule, and positional passing of a different set is
impossible.

The prior audit's exact reproduction is now a landed regression test at
`tests/scripts/dev_tools/test_parallel_mutation_admission.py:66-88`
(`test_conflict_with_an_unstarted_current_cohort_member_defers`): item 100 `in_flight`, item 200
`scheduled` in the current cohort, candidate 300 conflicting with 200 only,
`decide_admission(300, [(200, 300)], frozenset({100}), current_cohort_members=frozenset({100, 200}))`
must return `DEFER_AND_RECOLOR`. It does.

## Finding C2 — Pinned-barrier offset (second defect, found by preflight)

**Verdict: RESOLVED. The fix is sound.** Each of the directive's four sub-questions, re-derived
from the code at `scripts/dev_tools/parallel_mutation_protocol.py:283-341`:

**(a) `crosses_pinned` is computed from the full edge list before any induced restriction.**
Lines 302-306 compute the predicate; lines 313-317 take the induced subgraph. The ordering is
textual and unambiguous — the predicate cannot see a restricted list because the restriction has
not yet been formed. The predicate is
`any((first in unstarted_keys and second in pinned) or (second in unstarted_keys and first in pinned) for first, second in conflict_edges)`,
which is exactly the negation of what must be absent, over the whole input list. It cannot
under-approximate for a conformant caller.

The caller contract that makes this hold is enforced in prose:
`.claude/skills/parallel-add/SKILL.md:59-66` is headed "Compute conflict edges over ALL items,
including in-flight ones" and states "do not compute edges over the unstarted subset only." A
caller that restricted the list would drive `crosses_pinned` permanently false and render C2's fix
inert; the skill forbids exactly that.

**(b) The uniform additive shift preserves F2's independence guarantee by injectivity.**
Line 327 computes one `cohort_offset` for the whole assignment; lines 332-336 map every local class
index `i` to `cohort_offset + i`. `i -> cohort_offset + i` is injective on the integers, so two
unstarted items F2 placed in different classes land in different cohorts. Two items F2 placed in
the *same* class share no edge in `induced_edges`, and `induced_edges` contains **every** edge whose
both endpoints are unstarted (line 313-317), so no unstarted-unstarted conflict escapes F2's
guarantee. Independence within the unstarted set is preserved exactly, by F2's own guarantee rather
than by any reimplementation. F2's contract is confirmed at
`scripts/dev_tools/parallel_cohort_computation.py:1-12` ("every cohort is an independent set").

**(c) No pinned item moves.** Lines 283-286 raise `UnknownItemError` if
`unstarted_keys & pinned` is non-empty, so the two sets are provably disjoint before coloring.
`compute_cohorts(unstarted_items, induced_edges)` colors only `unstarted_items`, so the assignment's
key set is a subset of `unstarted_items` and therefore disjoint from `pinned`. A pinned item is
absent from the result, not reassigned. Asserted at
`test_parallel_mutation_protocol_properties.py:275-280` and
`test_parallel_mutation_recolor.py:109`.

**(d) No case where `crosses_pinned` is false yet an unstarted item conflicts with a pinned item.**
`crosses_pinned` false means, by the predicate's own quantifier, that no edge in `conflict_edges`
joins a key in `unstarted_keys` to a key in `pinned`. Since the edge list is the complete conflict
relation (caller contract, above), no such conflict exists. The offset-not-applied branch therefore
places class-0 unstarted keys at `current_cohort` beside the pinned members only when they conflict
with none of them. Sound.

**Residual precondition, documented not defective.** Soundness rests on all pinned items occupying
index `current_cohort`. That follows from the cohort barrier — `current_cohort` advances only on
durable confirmation that every cohort item is `merged` or `worktree_removed`, and an `in_flight`
item is neither. The precondition is stated at
`parallel_mutation_protocol.py:253-262` and at `.claude/skills/parallel-orchestrate/SKILL.md:107`
(`## Cohort Barrier and Max-Concurrency Slot Filling`), and both `parallel-add/SKILL.md:73-80` and
`parallel-remove/SKILL.md:87-92` require it be read from re-verified durable state, never the
cached checkpoint. This is the correct treatment for a value the engine cannot itself verify.

## Finding C2b — Consumer merge obligation

**Verdict: PASS.** Stated in all three required locations and proven both sufficient and necessary.

| Location | Citation |
|---|---|
| `parallel-add/SKILL.md` | lines 103-110 — "MERGED into the single existing current-generation cohort entry at `current_cohort`", "never written as a second cohort entry carrying the same `index`", citing `_parallel_state_structures.py:282-305` |
| `parallel-remove/SKILL.md` | lines 87-92 — "MERGED into the single existing current-generation cohort entry at that index alongside its pinned members, never written as a second entry" |
| `parallel-orchestrate/SKILL.md` `## Mutation Protocol (F6)` | lines 481-484 — "returned keys landing on index `current_cohort` JOIN the pinned members of that one entry instead of forming a second entry with the same index, which F3 invariant 13 rejects" |
| Engine docstring | `_parallel_mutation_models.py:301-309` |

`tests/scripts/dev_tools/test_parallel_mutation_cohort_invariant_binding.py` proves it **by
execution** against F3's landed `validate_parallel_orchestrator_state_text`, not by assertion:

- **Sufficiency** — four positive cases (offset applied at `current_cohort = 0` and at 3;
  offset not applied with the merge performed; empty unstarted set) each assert `errors == []`
  (lines 222-270).
- **Necessity** — `TestMergeObligationIsNecessary` (lines 273-326) deliberately writes the pinned
  entry and the returned keys as **two** current-generation entries sharing index `current_cohort`
  and asserts the validator rejects it. It also guards its own fixture precondition at lines
  299-301 (`min(assignments.values()) == current_cohort`), so the necessity case cannot silently
  degenerate into the offset-applied case.

Without the necessity case a consumer could satisfy the positive tests while emitting duplicate
indices. Its presence is what makes the obligation enforceable rather than advisory.

## Finding C2c — Property P4

**Verdict: PASS. P4 cannot pass while a contention violation exists.**

`tests/scripts/dev_tools/test_parallel_mutation_contention_properties.py:425-493`.

**What it asserts.** `assert_no_conflicting_pair` (lines 283-302) iterates the *full* edge list over
the *complete* cohort map and asserts no edge's endpoints share an index. The map is seeded with the
pinned items at `current_cohort` (line 361) before the unstarted assignments are merged in, so
**edges to pinned items are counted** — the map holds them. The assertion runs after the initial
recolor (line 366) and after **every** step of the admission sequence (line 420).

**Independent verification by mutation.** I reproduced all three reversions against the landed
tests, restoring the file each time (`git status --porcelain` clean afterwards):

| Reversion | Mutation | Result |
|---|---|---|
| 1 — in-flight-only rule | `blocking_keys = in_flight \| current_cohort_members` → `blocking_keys = in_flight` | `9 failed, 4 passed`; P4 among the failures |
| 2 — offset removed | `cohort_offset = current_cohort + 1 if crosses_pinned else current_cohort` → `cohort_offset = 0` | `1 failed, 12 passed`; P4 failed at `:334` (`assert_offset_value`) |
| 3 — unconditional `+1` | same line → `cohort_offset = current_cohort + 1` | `1 failed, 12 passed`; P4 failed at `:334` |

My counts match the executor's evidence for reversion 1 (9 failed) exactly; reversions 2 and 3
produced 1 and 1 failures in this module alone against the executor's 6 and 3, which were measured
across the contention **and** recolor modules together — consistent, not contradictory.

**Additional finding, stronger than claimed.** For reversion 2 the failure surfaced at
`assert_offset_value` because it is evaluated first. To determine whether the contention assertion
is itself load-bearing, I neutralized `assert_offset_value` with an early `return` and re-ran under
the removed offset:

```
AssertionError: conflicting items 102 and 902 share cohort 0 in seed=2 keys=[100, 101, 102]
  pinned=[102] cohort=[100, 101, 102] current_cohort=0 edges=[]
test_parallel_mutation_contention_properties.py:299: AssertionError
```

The contention assertion at line 299 catches the removed offset **independently**. Both assertions
are therefore genuinely load-bearing for C2, which is a stronger result than the executor's
evidence claims.

**The unconditional-offset case is not a contention violation.** An unconditional `+1` also vacates
the pinned index, so no two conflicting items share a cohort. It is over-conservative, not unsound.
`assert_offset_value` (lines 305-337) is required precisely because a pure contention check cannot
distinguish it, and it recomputes `crosses_pinned` from the edge list through a second, independent
derivation (lines 73-96), never from the engine's return value — so the assertion is not vacuous.

**Non-vacuity guards prevent a degenerate generator from passing trivially.** Five distinct guards:

1. Per-run: the generated current cohort must be a genuine independent set of the **full** graph
   (lines 467-471) — otherwise the property would test a fixture no coloring could produce.
2. Corpus: at least one run yields `ADMIT_CURRENT_COHORT` (line 487).
3. Corpus: at least one run yields `DEFER_AND_RECOLOR` (line 488).
4. Corpus: at least one run has an unstarted-to-pinned conflict edge (line 489).
5. Corpus: at least one run **both** lacks such an edge **and** performs a recolor (lines 490-493),
   so the offset-not-applied branch is actually asserted.

Guards 4 and 5 together are what make reversion 3 fail deterministically rather than by chance.
`current_cohort` is varied over 0..4 (line 169) and keys are offset off 1 to 100+ (line 134), so no
assertion can pass by assuming a zero base or zero-based keys.

## Finding P1 (NEW) — PARTIAL — spec 1.2 amendment left three pre-1.2 formulations in place

- **Locations:**
  - `spec.md:457` — `## Non-Negotiable Constraints` item 1: "recoloring is a pure function of
    `(remaining subgraph, pinned set)`" — the **two-argument** pre-1.2 formulation, in a normative
    section, contradicting amended FR4 at `spec.md:176` and amended AC S5.
  - `spec.md:694` — Seeded Test Conditions: "admission decision (no-conflict admit,
    **in-flight-conflict defer**)" — the pre-1.2 admission rule.
  - `spec.md:695` — Seeded Test Conditions: "recoloring is a pure function of
    `(remaining subgraph, pinned set)`" — same stale two-argument form.
- **Violated expectation:** an amended spec must be internally consistent; a normative
  `## Non-Negotiable Constraints` entry that contradicts the amended functional requirement leaves
  two readings of the same contract in one document. The amendment record
  `evidence/other/remediation1-spec-amendment-1.2.md` enumerates FR1 step 4, the recompute
  boundary, the API snippet, Test Strategy scenario 4, FR9 invariant 3, and S2/S5/S9/U1/U5 — it does
  not cover these three sites.
- **Why this is Partial and not Blocking:** no delivered behavior is wrong (the code implements the
  amended FR4), and no acceptance criterion is falsified. `spec.md:694-695` are Seeded Test
  Conditions, which remain `[ ]` unchecked, so no claim is asserted against them.
  `spec.md:457` is a constraints restatement, not an AC.
- **Verification command:**
  `grep -rn "remaining subgraph, pinned set)" docs/features/active/2026-08-07-parallel-mutation-protocol-442/spec.md`
  → returns `457` and `695`. `grep -n "in-flight-conflict defer" .../spec.md` → returns `694`.
  The same grep over `user-story.md` and `.claude/skills/parallel-orchestrate/SKILL.md` returns
  nothing, so the stale text is confined to `spec.md`.
- **Remediation:** three one-line edits — add ", pinned cohort index" at `:457` and `:695`, and
  broaden `:694` to "current-cohort-conflict defer". Documentation only; no code change.

## Finding P2 (CARRIED, reduced) — PARTIAL → the S603 comment format is still not verbatim on the violating line

- **Location:** `scripts/dev_tools/parallel_mutation_abandon_cli.py:152-154`.
- **Violated rule:** `.claude/rules/python-suppressions.md` § S603 requires the comment format
  `# noqa: S603 - static analysis can't verify runtime validation`, and its enforcement checklist
  requires it verbatim. Line 154 carries a bare `# noqa: S603`; the rationale sits on lines 152-153
  as a non-directive comment.
- **What the cycle did fix:** the prior finding had two halves. The *inert directive-shaped comment*
  half is resolved — line 152 no longer begins `# noqa:`, so no line of the file carries a `noqa`
  token that suppresses nothing. Verified: `git grep -n "# noqa" scripts/dev_tools/parallel_mutation_abandon_cli.py`
  returns exactly one match, on the violating line.
- **What remains:** the verbatim-format half. The executor recorded a measured rationale at
  `evidence/other/remediation1-s603-comment-placement.md`: the composed line is 95 characters
  against the 88-character Black/Ruff limit, and shortening the call expression would break the
  `cli.subprocess.run` monkeypatch seam in
  `tests/scripts/dev_tools/test_parallel_mutation_abandon_cli.py`. I confirmed `line-length = 88`
  at `pyproject.toml:85` and `:90`.
- **Reviewer judgment:** **not a merge gate.** Every substantive requirement of the rule is met —
  pre-authorized pattern, `shutil.which` validation at line 148 with fail-fast
  `AbandonSideEffectError`, single-line scope, accurate rationale present. The deviation is from the
  formatting clause alone, is measured rather than asserted, and is recorded. Downgraded from
  Partial-with-required-remediation to Partial-informational.
- **Verification command:** `poetry run ruff check .` → `All checks passed!`

## Advisory

| ID | Item | Location / evidence |
|---|---|---|
| A1 | `spec.md` Definition of Done (7 items) and Seeded Test Conditions (4 items) remain entirely unchecked while all 15 AC are checked. Carried from prior A6; unchanged by this cycle. | `spec.md:687-698` |
| A2 | Two test modules sit at exactly 500 lines with zero headroom: `test_parallel_mutation_protocol_ops.py` (500, byte-unchanged) and `test_parallel_mutation_protocol_properties.py` (500, was 499). The next edit to either forces a split. Carried from prior A7. | `wc -l` |
| A3 | `test_pinned_edges_leave_the_class_structure_but_shift_the_assignment` compares `_classes(...)` of the two assignments, so it no longer asserts `generation` equality the way the old full-`RecolorResult` equality did. Generation is separately and fully covered by `test_generation_is_always_one_beyond_the_current`. Net strictly stronger; noted for completeness only. | `test_parallel_mutation_protocol_properties.py:335-387` |
| A4 | The F6 op-classification imports are placed in a second, comment-separated import block from the same package rather than merged into the existing `_parallel_state_common` group. Ruff has `I` (isort) selected at `pyproject.toml:95` and passes, because isort treats a comment-separated block as its own section. Stylistic. | `_parallel_mutation_models.py:73-80`; `_parallel_orchestrator_state_mutations.py:73-80` |
| A5 | Repo-wide PowerShell coverage: my run measured 94.8072% line / 94.4104% instruction against the reported 94.3362%. A measurement-basis difference (JaCoCo `LINE` vs `INSTRUCTION` counter), not a regression. Both far above 85%. | `artifacts/pester/powershell-coverage.xml` |
| A6 | A `blocked` item may legitimately sit outside every current-generation cohort under F3 invariant 13, so the recolor neither sees nor places it. Not a contention hazard — a `blocked` item does not execute — but it means the cohort map is not a total partition of `items[]`. Informational. | `.claude/rules/parallel-orchestration.md` invariant 13 |

Prior advisories A1 (uncommitted branch), A9 (stale confinement diff stats), and the R4 TypeScript
gap are all discharged by this cycle: the branch now carries two commits, the confinement evidence
was regenerated as `remediation1-confinement-verification.md`, and the parity gap is recorded at
`docs/features/potential/2026-08-09-parallel-f6-typescript-parity-gap.md`. Prior A2, A3, A4, A5,
A8 are unchanged in substance and remain non-gates.

## Wave-4 Confinement Verification (full branch, `c939b5b8` → `fc10a471`)

| Obligation | Verification | Verdict |
|---|---|---|
| `parallel-orchestrate/SKILL.md` edits strictly inside `## Mutation Protocol (F6)` | Heading map: F6 at 435, F7 at 612, F8 at 616. Cycle-1 hunks land at 440, 461, 505, 601 — all within 435..611. | PASS |
| All three wave-4 headings present in original order | `## Mutation Protocol (F6)` 435 → `## Enforcement Hooks (F7)` 612 → `## Radius Drift Detection (F8)` 616 | PASS |
| F7 and F8 bodies untouched | Both remain the one-line placeholder "Reserved for F7/F8; content is appended by that feature and must not be relocated." | PASS |
| F7 validator extension seam byte-identical | `git diff c939b5b8 fc10a471 -- scripts/dev_tools/validate_parallel_orchestrator_state.py` shows exactly two added lines: one import (`:38`) and one call (`:325`), both **above** `# BEGIN F7 EXTENSION SEAM` at `:327`. Seam lines 327-334 unmodified. | PASS |
| `.claude/settings.json` — exactly one appended Bash-matcher entry | One `{ "type": "command", "command": "pwsh -NoProfile -File .claude/hooks/enforce-parallel-abandon-gate.ps1" }` appended after the epic-worktree-removal-gate entry. No existing entry reflowed. | PASS |
| F2 `parallel_cohort_computation.py` untouched | Absent from `git diff --name-only c939b5b8 fc10a471` | PASS |
| F1 blast-radius modules untouched | `compute_blast_radius.py`, `_blast_radius_conflicts.py` absent from the diff | PASS |
| `.claude/rules/**` untouched | No path under `.claude/rules/` in the diff | PASS |
| Every `enforce-epic-*` hook untouched | No `enforce-epic-*` path in the diff | PASS |
| Every epic validator, skill, agent untouched | No `validate_epic_*`, no `.claude/agents/**`, no epic skill in the diff | PASS |
| No field or enum member added to any F3 structure or enum | All nine member sets imported from `_parallel_state_common.py`; `_parallel_state_structures.py` and `_parallel_state_records.py` absent from the diff | PASS |
| `POPULATED_RESERVED_HEADINGS` a one-line append | `parallel_orchestrator_surface_expectations.py:78-84` adds the constant with a single tuple member `("## Mutation Protocol (F6)",)`, leaving F7 and F8 one added line each | PASS |
| Base plan `plan.md` byte-identical to `a9e2463c` | `git diff --stat a9e2463c fc10a471 -- .../plan.md` → empty | PASS |

## File Size and Hygiene

| Obligation | Verification | Verdict |
|---|---|---|
| Every production/test/script file <= 500 lines | Max production 499 (`parallel_mutation_protocol.py`); max test 500 (`_ops.py`, `_properties.py`). No file exceeds 500. | PASS |
| `test_parallel_mutation_protocol_ops.py` exactly 500 and byte-unchanged from `a9e2463c` | `wc -l` = 500; absent from `git diff --stat a9e2463c fc10a471` | PASS |
| No temporary files in tests | `git grep -n "tempfile\|NamedTemporary\|tmp_path" -- tests/scripts/dev_tools/test_parallel_mutation*` → no match. `test_parallel_mutation_cohort_invariant_binding.py` builds its checkpoint as an in-memory JSON string. | PASS |
| No live `gh` or `git` in tests | The only `gh pr`/`git worktree` matches under `tests/` are string literals in unrelated pre-existing epic-hook suites. No F6 test invokes either. | PASS |
| Injected clock seam; no production code under test reads the wall clock | `parallel_mutation_protocol.py:64-67` states every `at` comes from an injected `clock: Callable[[], datetime]`; all four constructors take `clock` as a **required** parameter. Test modules supply `fixed_clock`. | PASS |
| Seeded RNG prints its seed on failure | `GeneratedRun.__str__` emits seed, keys, pinned set, cohort membership, `current_cohort`, and edge list into every assertion message; pytest case ids are `seed{n}` (`SEEDS` at `:47`). | PASS |
| `hypothesis` still absent | Not in `pyproject.toml`; not imported anywhere | PASS |
| Tests under `tests/` mirroring the production tree, no colocation | All twelve F6 test modules under `tests/scripts/dev_tools/`; PS suite under `tests/scripts/claude-hooks/`. No test file under `scripts/`. | PASS |
| No prohibited coverage `exclude` of a production path | `pyproject.toml` per-file-ignores are lint scoping, not coverage exclusion; no production path excluded from coverage | PASS |

## Bundle Mirrors

All six touched `.claude/**` files are byte-identical to their
`extensions/drm-copilot/resources/claude-customizations/` mirrors (SHA-256 equality):

| File | SHA-256 (both copies) |
|---|---|
| `.claude/hooks/enforce-parallel-abandon-gate.ps1` | `21ba3429e084a5a1…` |
| `.claude/settings.json` | `7116a47ab2651…` |
| `.claude/skills/parallel-add/SKILL.md` | `9aaf66a519c57…` |
| `.claude/skills/parallel-close/SKILL.md` | `4d24f9c725c60…` |
| `.claude/skills/parallel-orchestrate/SKILL.md` | `392c1d552a8c2…` |
| `.claude/skills/parallel-remove/SKILL.md` | `e44d3aa680a03…` |

All five are registered in `extensions/drm-copilot/resources/claude-customizations/pack-manifests/core.json`
(hook at `:36`; the four skills at `:83`, `:84`, `:85`, `:87`). **PASS.**

## Suppression Policy

| Suppression | Status |
|---|---|
| `# noqa: S311` ×2 (prior R5) | **REMOVED.** `git grep -rn "noqa: S311" -- "*.py"` exits 1 with no match. Replaced by three `[tool.ruff.lint.per-file-ignores]` entries confined to the three named property modules (`pyproject.toml:109-112`), with a rationale comment citing `.claude/rules/general-unit-test.md` § Determinism Infrastructure. This is narrower than the `tests/**/*` scope the prior audit offered as acceptable, and per-file-ignores is a config mechanism, not a `# noqa` requiring pre-authorization. **PASS.** |
| `# noqa: S603` ×1 | Pre-authorized pattern, substance met, formatting clause deviated with measured rationale. See Finding P2. **PARTIAL (informational).** |
| `# type: ignore` | None added anywhere in the branch diff. **PASS.** |

## CI Context

`.github/workflows/ci.yml` declares `pull_request: branches: [main, development]`, so a PR based on
`epic/parallel-orchestration-integration` schedules no ci.yml run. Local gates are the only
automated signal. I therefore re-ran every gate myself rather than accepting the reported figures,
and independently reproduced all three P4 reversions plus one experiment the executor did not run
(the contention assertion in isolation). No workflow file is in the branch diff, so
`modified-workflow-needs-green-run` does not apply.

## Prior-Finding Disposition

| Prior ID | Class | Disposition | Basis |
|---|---|---|---|
| **B1 / R1** | Blocking | **RESOLVED** | `decide_admission` signature change + regression test + P4 rejects the reversion (9 failed, reproduced) |
| **P1 / R2** | Partial | **RESOLVED** | F3 tuples imported at both sites; 14 identity-binding assertions at `test_parallel_mutation_protocol.py:135-172` including a parametrized guard on the three old copy names |
| **P2 / R3** | Partial | **RESOLVED** | FR9 invariant 3 and AC S9 amended to the delivered two-signal formalization; amendment text verified against the code |
| **P3 / R4** | Partial | **DEFERRED WITH RATIONALE** | `docs/features/potential/2026-08-09-parallel-f6-typescript-parity-gap.md` records the gap, the concrete divergence, and the absence of any parity test |
| **P4 / R5** | Partial | **RESOLVED** | Both `# noqa: S311` removed; confined per-file-ignores added |
| **P5 / R6** | Partial | **PARTIAL (reduced)** | Inert-directive half resolved; verbatim-format half deviated with measured rationale. Not a merge gate. See Finding P2. |
| A1 (uncommitted) | Advisory | RESOLVED | Two commits: `a9e2463c`, `fc10a471` |
| A9 (stale stats) | Advisory | RESOLVED | `remediation1-confinement-verification.md` regenerated |
| A2, A3, A4, A5, A8 | Advisory | Unchanged, non-gates | — |
| A6, A7 | Advisory | Unchanged → A1, A2 above | — |
