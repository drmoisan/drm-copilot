# Feature Audit — 2026-08-07-parallel-mutation-protocol-442

- **Timestamp:** 2026-08-09T00-19
- **Feature:** `docs/features/active/2026-08-07-parallel-mutation-protocol-442`
- **Issue:** #442 (epic `parallel-orchestration`, child F6, wave 4)
- **Branch:** `feature/parallel-mutation-protocol-442`
- **Baseline (pinned):** `c939b5b8`
- **Work mode:** `full-feature` — AC sources are **both** `spec.md` (`## Acceptance Criteria`,
  15 items) and `user-story.md` (`## Acceptance Criteria`, 9 items). 24 items total.
- **Companion artifacts:** `policy-audit.2026-08-09T00-19.md`, `code-review.2026-08-09T00-19.md`

## Method

Every one of the 24 checked AC items was evaluated independently against the delivered
artifacts and against re-run gates, not against the executor's report. Verdicts are PASS,
PARTIAL, FAIL, or UNVERIFIED with file-and-location evidence. Where an AC's own wording is
narrower than the behavior a reader would expect, the AC is scored against **its own text** and
the discrepancy is recorded separately rather than silently folded into the verdict.

Gates re-run for this audit: `black --check` (382 files unchanged), `ruff check` (all passed),
`pyright` (0 errors), `pytest --cov --cov-branch` (3386 passed, line 92.05% / branch 84.19%),
`Invoke-PoshQCAnalyze` (0 findings), `Invoke-Formatter` per PoshQC's own procedure (already
formatted), `Invoke-PoshQCTest` (2043 passed / 1 pre-existing failure / 9 skipped),
`validate_evidence_locations.py --root .` (exit 0).

## `spec.md` Acceptance Criteria (S1-S15)

| # | Criterion (abbreviated) | Evidence | Verdict |
|---|---|---|---|
| S1 | Engine implements recolor, admission, removal, close, generation accounting, entry construction, completion as pure functions; frozen dataclasses; injected clock | `parallel_mutation_protocol.py:114,164,238,329,360`; `_parallel_mutation_entries.py:58-249`; `@dataclass(frozen=True)` on `ItemRecord`/`AdmissionDecision`/`RemovalDecision`/`RecolorResult`/`MutationEntry` (`_parallel_mutation_models.py:134,216,244,278,326`); `clock` required kwarg at `_parallel_mutation_entries.py:85,136,180,230`; no-wall-clock scan over all 7 modules returns no match; purity test `test_parallel_mutation_protocol_properties.py:483-499`; 100% line/branch on all 7 modules | **PASS** |
| S2 | `/parallel-add` delivered with `context: fork`, `agent: parallel-orchestrator`; proposed → preparation via `route_id: preparation`; edges over all items; admit only when no in-flight conflict, else defer and recolor | `.claude/skills/parallel-add/SKILL.md:1-7` (frontmatter), `:48` (enter `proposed`), `:51-57` (preparation contract unchanged), `:59-66` (edges over ALL items), `:69-76` (admission branches); engine `decide_admission` at `parallel_mutation_protocol.py:114-161`; tests `test_parallel_mutation_protocol.py:328-411` | **PASS** (AC text satisfied literally; see Discrepancy D1 — the rule the AC states is itself unsafe) |
| S3 | `/parallel-remove` implements the FR2 table exactly, incl. no default disposition, detach, abandon via single CLI, merged rejected | `.claude/skills/parallel-remove/SKILL.md:47-53` (table verbatim), `:58-64` (no default), `:93-106` (single CLI invocation, ad hoc prohibited); engine `decide_removal` at `parallel_mutation_protocol.py:238-326`; one test per row at `test_parallel_mutation_protocol_ops.py:115-232` incl. both rejection rows and the non-live `withdrawn`/`blocked` rows | **PASS** |
| S4 | `/parallel-close` delivered; terminates `open`-mode run; rejected while any item `in_flight` | `.claude/skills/parallel-close/SKILL.md:1-7,16-27,48-52`; engine `decide_close` at `parallel_mutation_protocol.py:329-357`; tests `test_parallel_mutation_protocol_ops.py:237-296` | **PASS** |
| S5 | Pinning invariant proven; delegates to F2's coloring without reimplementation; pinned never assigned; P1, P2, P3 pass | Delegation at `parallel_mutation_protocol.py:226` (`compute_cohorts`), induced subgraph at `:220-224`, overlap guard at `:212-215`; P1 `test_..._properties.py:204-257` (repeat equality, input-order independence, exact key set, disjoint from pinned, generation +1); P2 `:260-296` (every edge checked; induced-subgraph equivalence); P3 `:299-368` (6-step generated sequence, pinned state and cohort unchanged); unit `test_parallel_mutation_protocol.py:128-206`; all pass in the 3386-test run | **PASS** |
| S6 | Every add/remove/close/requeue appends exactly one entry with the seven fields matching the per-op table; rejected ops append nothing and change no state | Four constructors `_parallel_mutation_entries.py:80,132,177,212`; seven-field shape `_parallel_mutation_models.py:355-361`; `test_parallel_mutation_protocol_ops.py:346` (exactly seven fields per op case), `:424` (exactly one entry), `:201`/`:277` (rejected ops produce nothing); per-op values `:364-422` | **PASS** |
| S7 | Recompute boundary: deferred add / unstarted remove / requeue each +1; no-conflict admit, detach, abandon, close unchanged; N ops from g end at g + recompute count | Centralized in `_stamped_generation` (`_parallel_mutation_entries.py:58-77`); `test_parallel_mutation_protocol.py:218,227,239` (+1 cases), `:248,258,272` (unchanged cases), `:281-303` (`test_sequence_of_ops_ends_at_start_plus_recompute_count`), `:304-324` (monotonicity across a sequence) | **PASS** |
| S8 | Mode-dependent completion implemented and tested: closed predicate fires only when every non-withdrawn item is `merged`/`worktree_removed`; open never auto-completes, terminates only via `/parallel-close` | `is_closed_mode_complete` at `parallel_mutation_protocol.py:360-393` using F3's `MERGED_MERGE_STATUSES`; tests `test_parallel_mutation_protocol.py:414-472` (parametrized over the `merge_status` enum, withdrawn exemption, one-outstanding-item, default status); open-mode non-auto-completion at `parallel-close/SKILL.md:16-19` and `test_..._mutation_modes.py:41-56` | **PASS** |
| S9 | Validator helper enforces entry shape, non-decreasing `recolor_generation`, **and the mode-dependent completion invariant**, wired by exactly one additive import and one call line; key-gated checkpoints validate unchanged | Wiring verified: `git diff c939b5b8 -- scripts/dev_tools/validate_parallel_orchestrator_state.py` is `+2/-0` (import line 38, call line 325). Invariant 1 `_parallel_orchestrator_state_mutations.py:122-207`; invariant 2 `:235-275`; invariant 3 delegated to `_parallel_orchestrator_state_mode_completion.py:247-289`. Key gate `:304-306`; backward-compat test in `test_validate_parallel_orchestrator_state_mutations.py`. **However** invariant 3's closed-mode arm requires the conjunction of a `close` record **and** an empty current-generation cohort set, and a spec-conformant `closed`-mode run records no `close` at all (`spec.md` FR3; `parallel-close/SKILL.md:25-27`), so that arm is effectively unreachable on conformant data. The delivered invariant is materially narrower than the AC/spec sentence | **PARTIAL** |
| S10 | Hook denies `--disposition abandon` without the marker using prefix `PARALLEL_ABANDON_BLOCKED`, allows with marker, allows out-of-scope, throws on malformed JSON, registered by one additive `PreToolUse`→`Bash` entry | `enforce-parallel-abandon-gate.ps1:38-42` (tokens + reason code), `:221-242` (decision routing), `:225-229` (throw on malformed JSON); registration `+4/-0` in `.claude/settings.json` at index 6 after `enforce-epic-worktree-removal-gate.ps1`; 22 Pester cases, 0 failures (`pester-junit.xml`) | **PASS** |
| S11 | Wave-4 confinement: one appended section in the orchestrate SKILL; nothing reflowed/reordered; no schema field or enum value added; no epic implementation modified | SKILL diff is **one hunk** `@@ -434,7 +434,150 @@`, `144/1`, sole removal is the F6 placeholder; headings at 435 (F6) / 582 (F7) / 586 (F8) preserve order. Validator `+2/-0` outside F7's byte-identical seam. Settings `+4/-0`. `git diff --stat c939b5b8 -- .claude/rules/`, `-- ".claude/hooks/enforce-epic-*"`, and `-- scripts/dev_tools/_parallel_state_*.py` all empty. Enum members imported from F3 (`_parallel_mutation_models.py:65-71`), and `_parallel_orchestrator_state_mutations.py:152-158` actively rejects an eighth field | **PASS** |
| S12 | Atomic plan records and executes the upstream re-verification precondition (F5 sections, F3 `mutations[]` shape, F1 `conflicts`, F2 coloring), divergence resolved in favor of landed shape | `plan.md:40-53` records the reconciliation and its six corrections; per-contract artifacts `evidence/other/upstream-f{1,2,3,5}-*.md` plus `upstream-reconciliation-gate.md` and `upstream-branch-verification.md`; plan tasks P1-T1..P1-T8 all `[x]` (51/51 checked, 0 unchecked). Divergence 6 (`prior_state`) resolved in favor of the landed shape and applied to `spec.md:229-230,244-262` | **PASS** |
| S13 | Python passes Black, Ruff, Pyright with zero findings; pytest with line >= 85% and branch >= 75%; all Python tests under `tests/scripts/dev_tools/`; no file exceeds 500 lines | Re-run: Black `382 files would be left unchanged`; Ruff `All checks passed!`; Pyright `0 errors, 0 warnings, 0 informations`; pytest `3386 passed`; `coverage json` → statements 92.0486%, branches 84.1859%. All 7 Python suites under `tests/scripts/dev_tools/`; `ls scripts/dev_tools/ \| grep -i test` empty (no colocation). Max file 500 lines exactly (`test_parallel_mutation_protocol_ops.py`), at the cap and permitted | **PASS** |
| S14 | PowerShell hook passes PoshQC format and PSScriptAnalyzer with zero findings; Pester tests at the named path cover deny/allow/out-of-scope/malformed-JSON using a mocked read seam | `Invoke-PoshQCAnalyze` → `PSScriptAnalyzer passed: no findings`. Format re-checked with PoshQC's own procedure (LF-normalize + `settings/pssa.settings.psd1`, per `PoshQC.Analyzer.psm1:56-62`) → `ALREADY FORMATTED` for hook and test. `tests/scripts/claude-hooks/enforce-parallel-abandon-gate.Tests.ps1` present, 164 lines, 22 cases / 0 failures, with the four required contexts at `:28,55,75,105` and the mocked seam at `:116-131` | **PASS** |
| S15 | No test creates or uses temporary files; all tests deterministic (injected clock; seeded RNG with printed seed) | Temp-file scan over all 8 new suites (`tmp_path\|tempfile\|TemporaryDirectory\|NamedTemporary\|New-TemporaryFile\|TestDrive`) returns **no match**. Fixed clocks at `test_parallel_mutation_protocol_ops.py:44,61` and `test_..._properties.py:70,76`. Seeded RNG at `test_..._properties.py:125,308`; seed emitted by `GeneratedRun.__str__` (`:174-185`) into every assertion message and into pytest case ids (`:188`). No `sleep`/`Start-Sleep`/retry in any new test. CLI subprocess test monkeypatches both `shutil.which` and `subprocess.run` (`test_parallel_mutation_abandon_cli.py:341-342`), so no process is started and no live `gh`/`git` is invoked | **PASS** |

**`spec.md` totals: 14 PASS, 1 PARTIAL (S9), 0 FAIL, 0 UNVERIFIED.**

## `user-story.md` Acceptance Criteria (U1-U9)

| # | Criterion (abbreviated) | Evidence | Verdict |
|---|---|---|---|
| U1 | `/parallel-add` prepares via `route_id: preparation`, computes edges over all items incl. in-flight, admits only when no in-flight conflict, else defers and recolors | Same evidence as S2: `parallel-add/SKILL.md:51-57,59-66,69-76`; `decide_admission` `parallel_mutation_protocol.py:114-161`; tests `test_parallel_mutation_protocol.py:328-411` | **PASS** (AC text satisfied literally; see Discrepancy D1) |
| U2 | `/parallel-remove` implements the FR2 table exactly for unstarted states; `in_flight` rejected without explicit disposition, never defaulted; `merged` rejected | `parallel-remove/SKILL.md:47-53,58-64`; `decide_removal` branches at `parallel_mutation_protocol.py:299-326`; `test_parallel_mutation_protocol_ops.py:115-199` | **PASS** |
| U3 | `detach` lets an in-flight item finish while the run stops tracking it; `abandon` closes the PR, removes the worktree, marks `withdrawn`, executable only through the hook-gated CLI path | `decide_removal` returns `new_state='withdrawn'` with the recorded disposition and `triggers_recompute=False` (`parallel_mutation_protocol.py:313-319`); `parallel-remove/SKILL.md:86-91` (detach, no side effect), `:93-106` (abandon via the single CLI, ad hoc prohibited); CLI side effects `parallel_mutation_abandon_cli.py:160-197,263-298` in dependency order (PR closed before worktree removed, with the reason stated at `:270-273`); gate registered in `.claude/settings.json`; CLI independently refuses without the marker at `:342-349`; tests `test_parallel_mutation_protocol_ops.py:142-158,414-423` and `test_parallel_mutation_abandon_cli.py` | **PASS** |
| U4 | `/parallel-close` terminates an `open`-mode run and is rejected while any item is `in_flight` | Same as S4: `parallel-close/SKILL.md:16-27,48-52`; `decide_close` `parallel_mutation_protocol.py:329-357`; `test_parallel_mutation_protocol_ops.py:237-296` (incl. every in-flight key reported ascending) | **PASS** |
| U5 | Pinning invariant holds: in-flight never rescheduled by any mutation; recolor is a pure function of `(remaining subgraph, pinned set)`; determinism under mutation against a live in-flight set proven by unit and property tests | Same as S5. Specifically the "against a live in-flight set" clause is discharged by P3 (`test_..._properties.py:302-358`), which holds a generated pinned set fixed across a 6-step add/remove sequence with a recolor reapplied after each op | **PASS** (see Advisory A4 in the policy audit — P3's sequence omits in-flight removals) |
| U6 | Every add/remove/close/requeue appends exactly one entry with the seven fields; generation +1 on each recompute (deferred add, unstarted remove, requeue) and stamped unchanged on non-recompute ops (no-conflict admit, detach, abandon, close); rejected ops append nothing | Same as S6 + S7. `_stamped_generation` (`_parallel_mutation_entries.py:58-77`) is the single increment site; all seven op cases asserted at `test_parallel_mutation_protocol.py:218-303` and `test_parallel_mutation_protocol_ops.py:346-423` | **PASS** |
| U7 | `closed`-mode run completes when every non-withdrawn item is `merged` or `worktree_removed`; `open`-mode never auto-completes and terminates only via `/parallel-close` | Same as S8. U7 states the *semantics*, which the engine predicate implements exactly (`parallel_mutation_protocol.py:360-393`) and which the open-mode rule enforces on the checkpoint (`_parallel_orchestrator_state_mode_completion.py:134-167`). U7 makes no claim about validator scope, so the S9 narrowing does not bear on it | **PASS** |
| U8 | Abandon-gate hook denies `--disposition abandon` without the explicit confirmation marker (reason code `PARALLEL_ABANDON_BLOCKED`) and allows it when present | `enforce-parallel-abandon-gate.ps1:38-42,232-242`; deny reason built from the declared tokens at `:179-199`; Pester `:28-53` (deny incl. whitespace-separated variant) and `:55-73` (allow in both token orders); 22/22 passing | **PASS** |
| U9 | Mutation log and generation counter make a changed cohort table fully traceable from `mutations[]` alone; validator rejects a log whose `recolor_generation` values are not monotonically non-decreasing | `_validate_generation_monotonicity` (`_parallel_orchestrator_state_mutations.py:235-275`) compares against the running maximum rather than the immediate predecessor, so one out-of-order entry does not mask later ones; error string asserted exactly in `test_validate_parallel_orchestrator_state_mutations.py`; entry-shape completeness (`:122-207`) is what makes reconstruction from `mutations[]` alone possible by rejecting a dropped field that F3's `dict.get` reads as an intentional null | **PASS** |

**`user-story.md` totals: 9 PASS, 0 PARTIAL, 0 FAIL, 0 UNVERIFIED.**

## Aggregate

| Verdict | spec.md | user-story.md | Total |
|---|---|---|---|
| PASS | 14 | 9 | **23** |
| PARTIAL | 1 | 0 | **1** |
| FAIL | 0 | 0 | **0** |
| UNVERIFIED | 0 | 0 | **0** |

## Check-Off Honesty

Assessed per the `acceptance-criteria-tracking` skill. **No phantom check-offs were found.**
Every one of the 24 items marked `[x]` corresponds to work that is present in the branch and
that I verified by direct inspection or by re-running the relevant gate. There is no item
checked against undelivered work, and therefore **no Blocking check-off finding**.

One item requires correction:

- **S9 is checked `[x]` but evaluates PARTIAL.** All three FR9 invariants are delivered, wired
  by exactly one import and one call line, key-gated, and at 100% branch coverage — the
  delivery is real. The gap is fidelity of *scope*: invariant 3's closed-mode arm is
  effectively unreachable on spec-conformant data because a conformant `closed`-mode run never
  records a `close` entry. Per the skill, a PARTIAL item should be left unchecked. I have not
  modified the AC source file (my mandate is audit artifacts, not doc edits). The maintainer
  should either (a) amend `spec.md` FR9 invariant 3 and AC S9 to describe the two-signal
  formalization actually implemented — the module docstring at
  `_parallel_orchestrator_state_mode_completion.py:16-43` already documents it precisely — after
  which `[x]` is accurate, or (b) uncheck S9 pending that amendment. Option (a) is the better
  fix; no code change is required.

Two items pass on their own wording while that wording is itself unsafe — recorded as D1 below
rather than as check-off dishonesty, because the executor delivered exactly what the approved
AC specified.

## Discrepancies Between AC Text and Safe Behavior

**D1 — S2 and U1 encode an admission rule that permits contending items into the same cohort.**

Both criteria state that the candidate is admitted into the current cohort "only when the
candidate conflicts with no in-flight item". The implementation matches that sentence exactly,
which is why both score PASS. The sentence is nonetheless unsafe: because `max_concurrency`
caps in-flight items independently of cohort size
(`.claude/skills/parallel-orchestrate/SKILL.md:120-124`), a cohort can durably hold `scheduled`
members, and admitting a candidate that conflicts with such a member places two contending
items in one cohort for the next batch to launch concurrently. Root cause is design
`docs/research/2026-08-07-parallel-orchestration-design-research.md:173`, carried into
`spec.md` FR1 step 4 and then into S2 and U1.

Recorded as **Blocking finding B1** in `policy-audit.2026-08-09T00-19.md`, with the explicit
qualification that it is a requirement-level defect: **the feature implemented its approved
spec faithfully**, and closing it needs a spec and AC amendment, not only a code change. The
alternative acceptable resolution is an explicit entry in `spec.md` § Constraints & Risks plus
a tracked follow-up issue, so it does not ship undocumented.

## Non-AC Checklist Sections (informational)

`spec.md` § Definition of Done (lines 553-559) and § Seeded Test Conditions (lines 563-566) are
**entirely unchecked** while all 15 AC are checked. Neither heading is an AC source under the
`acceptance-criteria-tracking` heading rules, so this is not a check-off violation. Assessed
against the delivered work, the Definition of Done items are substantively met (AC mapped to
tests, tests added, edge cases covered, docs updated, toolchain pass completed) and the Seeded
Test Conditions are met except bullet 4 (dedicated integration scenarios), which is honestly
left unchecked. Recommend resolving the inconsistency before PR authoring.

## Baseline Comparison

| Metric | Baseline (`c939b5b8`) | Head | Delta |
|---|---|---|---|
| Python tests passing | 3007 | **3386** | +379 |
| Python tests failing | 0 | **0** | 0 |
| Python line coverage | 91.82% | **92.05%** | +0.23 pt |
| Python branch coverage | 83.80% | **84.19%** | +0.39 pt |
| PowerShell tests passing | 2021 | **2043** | +22 |
| PowerShell tests failing | 1 (pre-existing) | **1 (same)** | 0 |
| Ruff / Pyright / PSScriptAnalyzer findings | 0 / 0 / 0 | **0 / 0 / 0** | 0 |

No regression on any metric. The +22 PowerShell delta is exactly the new hook suite
(`pester-junit.xml`: `tests="22" failures="0"`), and 2043 − 22 = 2021 reproduces the baseline
passing count exactly, so no pre-existing PowerShell test was broken.

**Pre-existing failure (out of scope, not a regression):**
`tests/scripts/claude-hooks/enforce-pr-author-skill.Tests.ps1:142`, case "allows gh pr create
--body-file artifacts/pr_body_12.md when context exists", `Expected: 'allow' But was: 'deny'`.
Confirmed as the single failure in the 2053-case run by parsing the `<failure>` element's
enclosing `<testcase>`. Neither the hook nor its test appears in the branch diff; the hook
reads the real gitignored `artifacts/orchestration/orchestrator-state.json` rather than a
mocked seam, so its verdict tracks live orchestration state. It was correctly **not** edited to
force a green gate.

## Acceptance Criteria Status

```
### Acceptance Criteria Status
- Source: docs/features/active/2026-08-07-parallel-mutation-protocol-442/spec.md
          docs/features/active/2026-08-07-parallel-mutation-protocol-442/user-story.md
- Total AC items: 24 (15 spec + 9 user-story)
- Checked off (delivered): 24
- Remaining (unchecked): 0
- Items remaining: none
- Reviewer evaluation: 23 PASS, 1 PARTIAL (spec S9), 0 FAIL, 0 UNVERIFIED
- Newly checked off by this review: none (all 24 were already checked by the executor)
- Recommended correction: spec S9 is checked but evaluates PARTIAL; amend the FR9 invariant 3
  and S9 wording to match the delivered two-signal formalization, or uncheck S9 pending that
  amendment.
```

## Verdict

**Feature-audit verdict: SUBSTANTIALLY COMPLETE, remediation required.**

23 of 24 acceptance criteria are genuinely satisfied by delivered, verified work. One (spec S9)
is delivered but narrower in scope than its wording. No criterion is checked against
undelivered work, so there is **no Blocking check-off finding** — the executor's AC tracking was
honest and its reported gate figures were accurate in every value I re-verified.

**Total Blocking findings: 1** (B1, the admission/cohort-independence defect, which is
requirement-level and inherited from design §8.3 rather than an implementation error).

Merge should be gated on resolving B1 — either by spec amendment plus engine change and test,
or by an explicit documented acceptance as a tracked limitation — and on the P1 constant-binding
fix, which is a few lines and closes the same silent-divergence class this feature otherwise
guarded against well.
