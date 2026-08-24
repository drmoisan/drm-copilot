# QA Gate — Acceptance-Criteria Status — [P8-T16]

Timestamp: 2026-08-23T05-44

Feature: 2026-08-21-get-plan-paths-extracts-angle-bracket-placeholders-as-paths-502 (issue #502)
Task: [P8-T16]
Run: revision-6 re-run. Rewritten for the AC-8 disposition and the AC-22 documented decision.
AC source of record: the `## Acceptance Criteria` section of the feature spec.
Work Mode: full-bug — the spec is the sole acceptance-criteria source; a user story is intentionally
absent and its absence is not a blocker.

## Counts, stated explicitly so a miscount fails the gate

| Set | Count |
| --- | --- |
| numbered criteria AC-1 through AC-41 in the `## Acceptance Criteria` section | **41** |
| rows of the `### Traceability to issue.md` table | **11** |
| **total mapped items** | **52** |

The four impact/severity radios and the one logs-attached checkbox are **not** counted: they sit outside
the `## Acceptance Criteria` section and are not criteria. A fixed-string count of numbered criteria
within that section returns 41, matching the table below row for row.

## Verdict summary

Tallied separately for the two sets, because they are two enumerations and a combined count would
obscure which set each verdict belongs to.

| Verdict | Numbered criteria (41) | Traceability rows (11) |
| --- | --- | --- |
| pass | **39** | **11** |
| partial | **1** (AC-36) | 0 |
| withdrawn as unsatisfiable | **1** (AC-8) | 0 |
| fail | **0** | 0 |
| unverified | **0** | **0** |
| total | **41** | **11** |

No item in either set is recorded as unverified, and **no item is recorded as a failure.** The two
changes from the previous run are both dispositions the coordinator recorded as decisions rather than
outcomes to re-open: AC-8 moved from fail to withdrawn, and AC-22 moved from partial to pass with a
documented one-count discrepancy.

## AC-8 — withdrawn as unsatisfiable, with its substance discharged twice

**Disposition: the literal clause is withdrawn. It is not an unmet criterion.**

AC-8 required `tests/fixtures/blast_radius/conflict-placeholder-only-overlap.json` to exist and to
report conflict false in both parity suites. That clause is unsatisfiable, and the seam analysis was
verified independently: `classify_path_token` has exactly two callers, the extraction module and the
declared-radius normalization entry point, and the conflict chain calls neither. A conflict fixture
supplies literal recorded radii straight to the conflict relation, so its verdict is **invariant under
this fix**. The fixture can be satisfiable or discriminating, never both — with the placeholder present
it reports conflict true before and after the fix; with it absent it reports false before and after and
duplicates an existing fixture.

**The substance of AC-8 — two items whose only shared entry is a placeholder token report no conflict,
in both runtimes — is discharged twice over:**

| Discharge | Artifact |
| --- | --- |
| as a **regression test** in each runtime, asserting both that the pre-normalization pair conflicts and that the normalized pair does not | `evidence/regression-testing/placeholder-pair-normalization-tests.md` ([P5-T3]) |
| as an **executed integration probe** in both runtimes, which is the issue's own Steps to Reproduce | `evidence/qa-gates/conflict-graph-density.md` ([P7-T7]) |

The [P5-T3] tests are the stronger of the two for regression purposes, because their post-normalization
assertion routes through the classifier and therefore fails on a tree where the guard is absent. The
full analysis and the withdrawal reasoning are at
`evidence/other/p5-t3-blocker-conflict-fixture-seam.md`.

## AC-22 — pass, with a documented one-count discrepancy

**Disposition: pass. The floors stay at 30 and must not be changed.**

AC-22 requires the two corpus floors to be raised from 26 to "26 plus the number of newly added
fixtures" and to be equal to each other. Both floors read **30** and are **equal**, and both were raised
from 26. Three fixtures were added, so the literal arithmetic reads 29.

The executed value of 30 is correct in substance and is retained deliberately:

- the on-disk corpus is **35** fixtures, so a floor of 30 still passes the non-vacuity assertion in both
  suites, which is the property the floor exists to provide;
- 30 sits above the pre-change 26, so the floor was genuinely raised;
- 30 is the more conservative of the two candidate values;
- lowering it to 29 would force a further full Phase 8 restart for no functional gain.

The discrepancy arises because the floors were set by [P5-T5] and [P5-T6] when four fixtures were
planned, and revision 6 later reduced the count to three by replacing [P5-T3]'s fixture with a named
test per runtime. It is recorded here as a documented decision so an auditor meets it as such rather
than as an unexplained mismatch.

## A. Marker rejection in both runtimes, paired per runtime

| AC | Verdict | Satisfied by | Evidence artifact |
| --- | --- | --- | --- |
| AC-1 | **pass** | [P2-T2] parametrized predicate test over all five probes | `evidence/regression-testing/python-classifier-marker-pass-after.md` |
| AC-2 | **pass** | [P1-T1], [P2-T4] parametrized classifier test, five cases | `evidence/regression-testing/python-classifier-marker-pass-after.md` |
| AC-3 | **pass** | [P3-T4] five paired cases, predicate and classifier on the same probe | `evidence/regression-testing/powershell-classifier-marker-pass-after.md` |
| AC-4 | **pass** | [P1-T3], [P3-T4] zero double-quoted strings, content and length assertions, constraint comment present | `evidence/regression-testing/powershell-classifier-marker-fail-before.md` |
| AC-5 | **pass** | [P2-T2] and [P3-T4] filename-position cases | both pass-after artifacts |
| AC-6 | **pass** | [P2-T2] and [P3-T4] three degenerate-input cases each | both pass-after artifacts |

## B. Real-path acceptance preserved (negative controls)

| AC | Verdict | Satisfied by | Evidence artifact |
| --- | --- | --- | --- |
| AC-7 | **pass** | [P1-T1] positive control passing before and after; [P5-T1] fixture in both parity suites; [P3-T4] marker-free real-path case | `evidence/regression-testing/python-classifier-marker-pass-after.md`, `evidence/qa-gates/parity-corpus.md` |
| AC-8 | **withdrawn** | literal fixture clause unsatisfiable; substance discharged by [P5-T3] and [P7-T7]. See the dedicated section above. | `evidence/other/p5-t3-blocker-conflict-fixture-seam.md`, `evidence/regression-testing/placeholder-pair-normalization-tests.md`, `evidence/qa-gates/conflict-graph-density.md` |
| AC-9 | **pass** | [P5-T7] reuse decision recorded in the plan; the reused fixture is byte-unmodified against the anchor | `evidence/qa-gates/negative-control-reuse.md` |
| AC-10 | **pass** | [P5-T12], [P8-T14] zero modified entries; all 32 top-level fixtures and the nested capture byte-unchanged; both parity suites pass | `evidence/qa-gates/fixture-corpus-diff.md`, `evidence/qa-gates/silent-drop-audit.md` |
| AC-11 | **pass** | [P5-T8] two Python tests, [P5-T9] two PowerShell tests; all three levels asserted | `evidence/qa-gates/parity-corpus.md` |
| AC-12 | **pass** | [P5-T4] fixture with an empty expected findings list, asserted by both suites | `evidence/qa-gates/parity-corpus.md` |
| AC-13 | **pass** | [P5-T10] fail-open trade test with all three docstring elements verified, plus a concrete-filename control | `evidence/qa-gates/parity-corpus.md` |

## C. Corpus measurement, before and after, with positive control

| AC | Verdict | Satisfied by | Evidence artifact |
| --- | --- | --- | --- |
| AC-14 | **pass** | [P0-T12], [P0-T13] executed five-marker probes in both runtimes pre-fix, single-quoted with content and length assertions | `evidence/baseline/marker-probe-python.md`, `evidence/baseline/marker-probe-powershell.md` |
| AC-15 | **pass** | [P0-T14], [P7-T1] 58 items non-zero and identical in both states; edges 1282 to 1267; density 77.6% to 76.6%; cohorts 32 to 32; max width 4 to 4 | `evidence/baseline/conflict-graph-density-before.md`, `evidence/qa-gates/conflict-graph-density.md` |
| AC-16 | **pass** | [P7-T2] entries 3729 to 2472, full set difference enumerated per item, **zero** marker-free drops, zero additions | `evidence/qa-gates/conflict-graph-density.md` |
| AC-17 | **pass** | [P7-T3] all five probes survive; the three with pre-registered counts match exactly at 8, 16, and 7 | `evidence/qa-gates/conflict-graph-density.md` |
| AC-18 | **pass** | [P7-T4] the 486-487 edge survives with reason kind and detail byte-identical to before | `evidence/qa-gates/conflict-graph-density.md` |
| AC-19 | **pass** | [P0-T15] fixed 53 pre-implementation with a witnessed SHA and clean status; [P7-T5] delta 15, bound satisfied, identity deviation explained | `evidence/baseline/edge-delta-prediction.md`, `evidence/qa-gates/conflict-graph-density.md` |
| AC-20 | **pass** | [P7-T6] clique matches the pre-registered set; all 36 pairs lost the placeholder reason; 12 removed, 24 survive, **zero** retaining a marker-bearing reason | `evidence/qa-gates/conflict-graph-density.md` |

AC-20 note, carried forward: 23 of the 24 surviving clique pairs carry a `path_overlap` on a real
marker-free path. The pair for issues 344 and 442 survives on a shared module rather than a shared path.
It is still real evidence rather than placeholder residue, and the argument is exact: after the fix every
radius entry in the corpus is marker-free, so any module resolved in the after state is resolved from
marker-free real paths in both radii.

## D. Parity fixtures and corpus-floor counters

| AC | Verdict | Satisfied by | Evidence artifact |
| --- | --- | --- | --- |
| AC-21 | **pass** | [P5-T1], [P5-T2], [P5-T4] all three fixtures carry the template shape and each is asserted by both suites across the radius and findings channels | `evidence/qa-gates/parity-corpus.md` |
| AC-22 | **pass** | [P5-T5], [P5-T6] both floors raised from 26, equal at 30, non-vacuous against 35 files. One-count discrepancy documented in the dedicated section above. | `evidence/qa-gates/parity-corpus.md` |
| AC-23 | **pass** | [P5-T11] 73 Python and 76 PowerShell parity passes, zero failures; four channels agree; three non-vacuity tests pass in each suite | `evidence/qa-gates/parity-corpus.md` |

## E. Byte-mirror parity and registration surfaces

| AC | Verdict | Satisfied by | Evidence artifact |
| --- | --- | --- | --- |
| AC-24 | **pass** | [P6-T3] the named test passes, asserting byte-identical mirrors for the new module, the changed extraction module, and the amended rule file | `evidence/qa-gates/rule-file-mirror.md` |
| AC-25 | **pass** | [P4-T3], [P4-T6] manifest lists the module exactly once; manifest Pester 4 tests 0 failures; Jest suite 15 passing | `evidence/qa-gates/registration-surfaces.md` |
| AC-26 | **pass** | [P4-T4], [P4-T5], [P4-T6] entry present in both allow-lists, 80 entries at anchor versus 81 now, files byte-identical, bundled-parity test passes | `evidence/qa-gates/registration-surfaces.md` |
| AC-27 | **pass** | [P8-T12] no exclusion entry of any kind; neither runsettings contains an exclusion key; both new modules in their coverage denominator at 100% | `evidence/qa-gates/coverage-exclusion-audit.md` |
| AC-28 | **pass** | [P8-T15] the runsettings is enumerated in shared surfaces and validation reports 0 findings, hence no V2 Blocking finding | `evidence/qa-gates/declared-radius-validation.md` |

## F. Rule-file prose amendment

| AC | Verdict | Satisfied by | Evidence artifact |
| --- | --- | --- | --- |
| AC-29 | **pass** | [P6-T1] `four token shapes` on a single line, fourth shape named, marker set in a fenced block, acceptance-gate rule file cross-referenced | `evidence/qa-gates/rule-file-amendment.md` |
| AC-30 | **pass** | [P6-T1] all five additional records present, located in the artifact's element table | `evidence/qa-gates/rule-file-amendment.md` |
| AC-31 | **pass** | [P6-T1] pathspec-scoped claim; [P8-T13] whole-repository claim, zero added schema paths | `evidence/qa-gates/rule-file-amendment.md`, `evidence/qa-gates/contract-scope-audit.md` |
| AC-32 | **pass** | [P6-T4] zero-exit diff against both anchors plus an empty porcelain status over the same pathspec | `evidence/qa-gates/policy-file-untouched.md` |

## G. Structural limits, toolchain, and scope containment

| AC | Verdict | Satisfied by | Evidence artifact |
| --- | --- | --- | --- |
| AC-33 | **pass** | [P8-T11] 475, 472, 144, 187 lines; all at or under 500, with more headroom than at baseline | `evidence/qa-gates/file-size-limit.md` |
| AC-34 | **pass** | [P3-T2], [P3-T4] module-export assertion confirms the relocated span function and the new predicate are both resolvable from the extraction module | `evidence/regression-testing/powershell-classifier-marker-pass-after.md` |
| AC-35 | **pass** | [P8-T1] to [P8-T5] single uninterrupted pass, no failure and no auto-fix (zero `reformatted ` lines, zero `Fixed ` lines); line 92.61% and branch 89.82%; changed-line coverage 100% on both touched modules; no regression | the five final Python QA-gate artifacts |
| AC-36 | **partial** | [P8-T6] to [P8-T9] format, analyze, and test pass in a single pass with 3389 tests and 0 failures; line coverage 96.46%. The "with the new module measured" clause is not observable through the MCP tool, which executes from a published npm package whose bundled allow-list predates this change. Both in-repository allow-lists carry the entry, and a direct measurement on this tree shows the module at 100% line coverage (19 of 19 lines). | the four final PowerShell QA-gate artifacts |
| AC-37 | **pass** | [P8-T10] all four npm commands exit 0; 195 suites and 2654 tests pass, counts unchanged from baseline | `evidence/qa-gates/final-typescript-suites.md` |
| AC-38 | **pass** | [P8-T13] no signature on a pre-existing public surface, no return type, no artifact type, no CLI flag, no MCP input-schema property, no finding-rule literal, no configuration key | `evidence/qa-gates/contract-scope-audit.md` |
| AC-39 | **pass** | [P8-T14] no new finding rule, no severity literal, no diagnostic emission in either runtime; zero pre-existing fixtures modified; all three added fixtures declare empty findings | `evidence/qa-gates/silent-drop-audit.md` |
| AC-40 | **pass** | [P7-T7] the repro reports conflict false post-fix in both runtimes, negative control still false | `evidence/qa-gates/conflict-graph-density.md` |
| AC-41 | **pass** | decision recorded in the plan and reproduced with its three-part rationale in the radius artifact, which also records that #500 merged before this execution completed | `evidence/qa-gates/declared-radius-validation.md` |

## Traceability to `issue.md` — 11 rows

| # | `issue.md` item | Spec coverage | Verdict | Evidence artifact |
| --- | --- | --- | --- | --- |
| 1 | Unit coverage — placeholder feature-doc tokens not harvested | AC-1, AC-2, AC-3, AC-7 | **pass** | the two classifier pass-after artifacts |
| 2 | Unit coverage — a real path on the same task line still is | AC-7 | **pass** | `evidence/regression-testing/python-classifier-marker-pass-after.md` |
| 3 | Unit coverage — interpolation forms behave as separately specified rather than by assumption | AC-1, AC-2, AC-3, AC-14 | **pass** | the two marker-probe baselines |
| 4 | Integration — two-item conflict probe reports conflict false with the placeholder | AC-8, AC-40 | **pass** | AC-40 passes at [P7-T7] in both runtimes, and AC-8's substance is now discharged by the [P5-T3] named tests. This row moved from partial to pass in revision 6: the fixture clause it inherited is withdrawn, and both of its underlying obligations are met. `evidence/regression-testing/placeholder-pair-normalization-tests.md`, `evidence/qa-gates/conflict-graph-density.md` |
| 5 | Integration — existing conflict true preserved for two items sharing a real file | AC-9, AC-10, AC-18 | **pass** | `evidence/qa-gates/negative-control-reuse.md`, `evidence/qa-gates/conflict-graph-density.md` |
| 6 | Manual verification — re-derive radii over committed plans, record density and cohort count before and after | AC-15, AC-20 | **pass** | the before and after conflict-graph-density artifacts |
| 7 | Manual verification — keep a positive control; a fix that drops real paths must be caught immediately | AC-16, AC-17, AC-18, AC-19 | **pass** | `evidence/qa-gates/conflict-graph-density.md` |
| 8 | Reuse the marker set from the acceptance-gate rule file rather than inventing a second one | AC-29, AC-32, AC-38 | **pass** | `evidence/qa-gates/rule-file-amendment.md`, `evidence/qa-gates/policy-file-untouched.md`. The set is additionally pinned equal by a named test. |
| 9 | Decide silent drop versus diagnostic | AC-39 | **pass** | `evidence/qa-gates/silent-drop-audit.md` |
| 10 | Accept the false-negative trade knowingly, or narrow to bracket pairs | AC-29, AC-30 | **pass** | `evidence/qa-gates/rule-file-amendment.md` — the five-marker set is reused and the narrowing alternative is rejected |
| 11 | Logs attached | AC-14, AC-15 supersede with executed evidence | **pass** | the two marker-probe baselines and the conflict-graph-density artifact |

## Output Summary

Exactly **41** numbered criterion rows and exactly **11** traceability rows are mapped, for **52** items
in total. Every item carries a named artifact path and a verdict; **none** is recorded as unverified and
**none** is recorded as a failure.

Of the **41** numbered criteria: **39 pass**, **1 is partial** (AC-36, on the MCP allow-list publish
boundary), and **1 is withdrawn as unsatisfiable** (AC-8, whose substance is discharged twice over by the
[P5-T3] named tests and the [P7-T7] executed repro). All **11** traceability rows pass; row 4 moved from
partial to pass because the fixture clause it inherited is withdrawn and both of its underlying
obligations are met. AC-22 moved from partial to pass with its one-count floor discrepancy recorded as a
documented decision. Each disposition carries its reason and its supporting measurement inline rather
than being absorbed.
