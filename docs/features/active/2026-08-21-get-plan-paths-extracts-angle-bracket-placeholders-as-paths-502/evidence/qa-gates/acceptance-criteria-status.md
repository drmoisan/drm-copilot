# QA Gate — Acceptance-Criteria Status — [P8-T16]

Timestamp: 2026-08-23T04-36

Feature: 2026-08-21-get-plan-paths-extracts-angle-bracket-placeholders-as-paths-502 (issue #502)
Task: [P8-T16]
AC source of record: `docs/features/active/2026-08-21-get-plan-paths-extracts-angle-bracket-placeholders-as-paths-502/spec.md`
Work Mode: full-bug — `spec.md` is the sole acceptance-criteria source; `user-story.md` is
intentionally absent and its absence is not a blocker.

## Counts, stated explicitly so a miscount fails the gate

| Set | Count |
| --- | --- |
| numbered criteria AC-1 through AC-41 in the `## Acceptance Criteria` section | **41** |
| rows of the `### Traceability to issue.md` table | **11** |
| **total mapped items** | **52** |

The four impact/severity radios and the one logs-attached checkbox are **not** counted: they sit
outside the `## Acceptance Criteria` section and are not criteria. A fixed-string count of numbered
criteria within that section returns 41, matching the table below row for row.

## Verdict summary

Tallied separately for the two sets, because they are two enumerations and a combined count would
obscure which set each verdict belongs to.

| Verdict | Numbered criteria (41) | Traceability rows (11) |
| --- | --- | --- |
| pass | **38** | **10** |
| partial | **2** (AC-22, AC-36) | **1** (row 4) |
| fail | **1** (AC-8) | 0 |
| blocked | 0 | 0 |
| unverified | **0** | **0** |
| total | **41** | **11** |

No item in either set is recorded as unverified.

## A. Marker rejection in both runtimes, paired per runtime

| AC | Verdict | Satisfied by | Evidence artifact |
| --- | --- | --- | --- |
| AC-1 | **pass** | [P2-T2] — parametrized predicate test over all five probes; 16 tests pass | `evidence/regression-testing/python-classifier-marker-pass-after.md` |
| AC-2 | **pass** | [P1-T1], [P2-T4] — parametrized classifier test, five cases, all passing after the guard | `evidence/regression-testing/python-classifier-marker-pass-after.md` |
| AC-3 | **pass** | [P3-T4] — five paired cases, each asserting the predicate and the classifier on the same probe | `evidence/regression-testing/powershell-classifier-marker-pass-after.md` |
| AC-4 | **pass** | [P1-T3], [P3-T4] — file contains zero double-quoted strings, each case asserts probe content and exact length before classification, and the single-quote constraint comment is present | `evidence/regression-testing/powershell-classifier-marker-fail-before.md` |
| AC-5 | **pass** | [P2-T2] `test_contains_placeholder_marker_reads_the_filename_position`; [P3-T4] `reads a marker in the filename position` | `evidence/regression-testing/python-classifier-marker-pass-after.md`, `evidence/regression-testing/powershell-classifier-marker-pass-after.md` |
| AC-6 | **pass** | [P2-T2] `test_contains_placeholder_marker_handles_a_degenerate_token` (3 cases); [P3-T4] `returns a verdict without throwing for the degenerate token` (3 cases) | same two artifacts |

## B. Real-path acceptance preserved (negative controls)

| AC | Verdict | Satisfied by | Evidence artifact |
| --- | --- | --- | --- |
| AC-7 | **pass** | [P1-T1] `test_real_path_on_same_task_line_survives_placeholder_rejection`, passing before and after; [P5-T1] fixture asserted by both parity suites; [P3-T4] `does not report a marker-free real repository path` | `evidence/regression-testing/python-classifier-marker-pass-after.md`, `evidence/qa-gates/parity-corpus.md` |
| AC-8 | **fail** | **[P5-T3] blocked.** The fixture was not created: a conflict fixture is compared as literal recorded radii and the conflict relation never invokes the classifier, so its verdict is invariant under this fix and the stated acceptance is unreachable. The behaviour AC-8 describes is nonetheless measured, through the derivation seam the guard governs, at [P0-T16] and [P7-T7]. | `evidence/other/p5-t3-blocker-conflict-fixture-seam.md`, `evidence/qa-gates/conflict-graph-density.md` |
| AC-9 | **pass** | [P5-T7] — the reuse decision is recorded explicitly in the plan's AC-9 section, and `tests/fixtures/blast_radius/conflict-path-overlap.json` (expected conflict true) is byte-unmodified against the anchor | `evidence/qa-gates/negative-control-reuse.md` |
| AC-10 | **pass** | [P5-T12], [P8-T14] — zero modified entries under the fixture tree in either the porcelain status or the anchored diff; all 32 top-level fixtures and the nested verification-integrity capture are byte-unchanged; both parity suites pass | `evidence/qa-gates/fixture-corpus-diff.md`, `evidence/qa-gates/silent-drop-audit.md` |
| AC-11 | **pass** | [P5-T8] `test_normalize_declared_radius_strips_a_placeholder_entry` plus its re-resolution companion; [P5-T9] the PowerShell counterpart. All three levels asserted. | `evidence/qa-gates/parity-corpus.md` |
| AC-12 | **pass** | [P5-T4] — fixture exists with an empty expected findings list and is asserted by both parity suites | `evidence/qa-gates/parity-corpus.md` |
| AC-13 | **pass** | [P5-T10] `test_placeholder_shaped_shared_surface_glob_match_is_dropped`, with all three docstring elements verified present, plus a concrete-filename discrimination control | `evidence/qa-gates/parity-corpus.md` |

## C. Corpus measurement, before and after, with positive control

| AC | Verdict | Satisfied by | Evidence artifact |
| --- | --- | --- | --- |
| AC-14 | **pass** | [P0-T12], [P0-T13] — executed five-marker probes in both runtimes pre-fix, single-quoted with content and length assertions | `evidence/baseline/marker-probe-python.md`, `evidence/baseline/marker-probe-powershell.md` |
| AC-15 | **pass** | [P0-T14], [P7-T1] — 58 items (non-zero, identical in both states), edges 1282 to 1267, density 77.6% to 76.6%, cohorts 32 to 32, max width 4 to 4, constant derivation timestamp | `evidence/baseline/conflict-graph-density-before.md`, `evidence/qa-gates/conflict-graph-density.md` |
| AC-16 | **pass** | [P7-T2] — entries 3729 to 2472, full set difference enumerated per item, **zero** marker-free entries dropped, zero entries added | `evidence/qa-gates/conflict-graph-density.md` |
| AC-17 | **pass** | [P7-T3] — all five probes survive; the three with pre-registered carrier counts match exactly at 8, 16, and 7; the own-folder glob and the line-suffixed citation both present | `evidence/qa-gates/conflict-graph-density.md` |
| AC-18 | **pass** | [P7-T4] — the 486-487 edge survives with reason kind and detail byte-identical to the before-state recording | `evidence/qa-gates/conflict-graph-density.md` |
| AC-19 | **pass** | [P0-T15] fixed 53 before implementation, witnessed by a recorded commit SHA and a clean status over all three edited locations; [P7-T5] reports prediction against actual (delta 15, bound satisfied) and explains the identity deviation rather than absorbing it | `evidence/baseline/edge-delta-prediction.md`, `evidence/qa-gates/conflict-graph-density.md` |
| AC-20 | **pass** | [P7-T6] — the nine-item clique matches the pre-registered set exactly; all 36 pairs lost the placeholder reason; 12 removed, 24 survive, and **zero** survivors retain a marker-bearing reason. Attribution of the 24: 23 carry a `path_overlap` on a real marker-free path; the single remaining pair (344 and 442) survives on `module_overlap = config`. See the note below. | `evidence/qa-gates/conflict-graph-density.md` |

**Note on AC-20's one non-path survivor.** AC-20 asks that a surviving edge be attributable to a
shared real path. Twenty-three of the twenty-four are. The pair for issues 344 and 442 survives on a
shared *module* rather than a shared path. It is still real evidence rather than a placeholder
residue, and the argument is exact: after the fix every radius entry in the corpus is marker-free, so
any module resolved in the after state is resolved from marker-free real paths in both radii. The edge
is therefore a genuine contention signal one level above the path level, which is the same class of
signal AC-20 is protecting. It is recorded here rather than folded into the count.

## D. Parity fixtures and corpus-floor counters

| AC | Verdict | Satisfied by | Evidence artifact |
| --- | --- | --- | --- |
| AC-21 | **pass** | [P5-T1], [P5-T2], [P5-T4] — all three new fixtures carry the same input/expected shape as `derivation-directory-shaped-rejected.json` and each is asserted by both parity suites across the radius and findings channels | `evidence/qa-gates/parity-corpus.md` |
| AC-22 | **partial** | [P5-T5], [P5-T6] — both floors are raised from 26 and are **equal to each other at 30**. The criterion's arithmetic is "26 plus the number of newly added fixtures", which is 29 for the three fixtures actually added; the plan fixed 30 on the assumption of four. Both floor assertions hold and remain non-vacuous against 35 files on disk, and the equality requirement is met. | `evidence/qa-gates/parity-corpus.md`, `evidence/other/p5-t3-blocker-conflict-fixture-seam.md` |
| AC-23 | **pass** | [P5-T11] — 73 passed in the Python suite, 76 passed in the PowerShell parity suite, zero failures; all four channels agree across the 35-fixture corpus; the three non-vacuity tests pass in each suite | `evidence/qa-gates/parity-corpus.md` |

## E. Byte-mirror parity and registration surfaces

| AC | Verdict | Satisfied by | Evidence artifact |
| --- | --- | --- | --- |
| AC-24 | **pass** | [P6-T3] — the named test passes, asserting byte-identical mirrors for the new module, the changed extraction module, and the amended rule file | `evidence/qa-gates/rule-file-mirror.md` |
| AC-25 | **pass** | [P4-T3], [P4-T6] — the manifest lists the new module exactly once; the manifest Pester file reports 4 tests 0 failures and the pack-manifest-completeness Jest suite reports 15 passing | `evidence/qa-gates/registration-surfaces.md` |
| AC-26 | **pass** | [P4-T4], [P4-T5], [P4-T6] — the entry is present in both allow-lists (80 entries at the anchor versus 81 now, so exactly one added and none removed), the two files are byte-identical, and the bundled-parity test passes | `evidence/qa-gates/registration-surfaces.md` |
| AC-27 | **pass** | [P8-T12] — whole-diff keyword sweep found no exclusion entry of any kind in any configuration file; both new production modules are in their runtime's coverage denominator at 100% line coverage | `evidence/qa-gates/coverage-exclusion-audit.md` |
| AC-28 | **pass** | [P8-T15] — the declared radius enumerates the Pester runsettings in `shared_surfaces` and validation reports 0 findings, hence no V2 Blocking finding | `evidence/qa-gates/declared-radius-validation.md` |

## F. Rule-file prose amendment

| AC | Verdict | Satisfied by | Evidence artifact |
| --- | --- | --- | --- |
| AC-29 | **pass** | [P6-T1] — the file states `four token shapes` on a single line, names the fourth as a placeholder or interpolation marker, renders the five-marker set in a fenced block, and cross-references the acceptance-gate rule file as its origin | `evidence/qa-gates/rule-file-amendment.md` |
| AC-30 | **pass** | [P6-T1] — all five additional records present and located in the artifact's element table | `evidence/qa-gates/rule-file-amendment.md` |
| AC-31 | **pass** | [P6-T1] for the pathspec-scoped claim; [P8-T13] for the whole-repository claim — no added line references a schema file and no added path is a schema file | `evidence/qa-gates/rule-file-amendment.md`, `evidence/qa-gates/contract-scope-audit.md` |
| AC-32 | **pass** | [P6-T4] — `git diff --exit-code` returns 0 against both `main` and the merge base for the acceptance-gate rule file and the Copilot instruction tree, and a porcelain status over the same pathspec is empty | `evidence/qa-gates/policy-file-untouched.md` |

## G. Structural limits, toolchain, and scope containment

| AC | Verdict | Satisfied by | Evidence artifact |
| --- | --- | --- | --- |
| AC-33 | **pass** | [P8-T11] — 475, 472, 144, and 187 lines; all four at or under 500, with more headroom than at baseline | `evidence/qa-gates/file-size-limit.md` |
| AC-34 | **pass** | [P3-T2], [P3-T4] — a module-export assertion confirms the relocated span function and the new predicate are both resolvable from the extraction module | `evidence/regression-testing/powershell-classifier-marker-pass-after.md` |
| AC-35 | **pass** | [P8-T1] through [P8-T5] — single uninterrupted pass with no failure and no auto-fix (zero `reformatted ` lines, zero `Fixed ` lines); line 92.61% >= 85%, branch 89.82% >= 75%; changed-line coverage 100% on both touched modules and no regression | `evidence/qa-gates/final-python-format.md`, `final-python-lint.md`, `final-python-typecheck.md`, `final-python-test-coverage.md`, `python-coverage-delta.md` |
| AC-36 | **partial** | [P8-T6] through [P8-T9] — format, analyze, and test complete in a single pass with 3388 tests and 0 failures; line coverage 96.46% >= 85%. The clause "with the new module measured" is not observable through the MCP tool, which executes from a published npm package whose bundled allow-list predates this change. Both in-repository allow-lists carry the entry, and a direct measurement against the repository allow-list shows the module at 100% line coverage (19 of 19 lines). | `evidence/qa-gates/final-powershell-format.md`, `final-powershell-analyze.md`, `final-powershell-test-coverage.md`, `powershell-coverage-delta.md` |
| AC-37 | **pass** | [P8-T10] — all four npm commands exit 0; 195 suites and 2654 tests pass, counts unchanged from baseline, confirming a no-op for that runtime | `evidence/qa-gates/final-typescript-suites.md` |
| AC-38 | **pass** | [P8-T13] — no signature on a pre-existing public surface, no return type, no artifact type, no CLI flag, no MCP input-schema property, no finding-rule literal, and no configuration key added or changed | `evidence/qa-gates/contract-scope-audit.md` |
| AC-39 | **pass** | [P8-T14] — no new finding rule, no severity literal, no diagnostic emission of any kind in either runtime; zero pre-existing fixture files modified | `evidence/qa-gates/silent-drop-audit.md` |
| AC-40 | **pass** | [P7-T7] — the repro reports conflict false post-fix in both runtimes, with the negative control still false | `evidence/qa-gates/conflict-graph-density.md` |
| AC-41 | **pass** | The decision is recorded in the plan's AC-41 section — declare and accept the single `path_overlap` edge — and reproduced with its three-part rationale in the radius artifact, which additionally records that #500 merged before this execution completed | `evidence/qa-gates/declared-radius-validation.md` |

## Traceability to `issue.md` — 11 rows

| # | `issue.md` item | Spec coverage | Verdict | Evidence artifact |
| --- | --- | --- | --- | --- |
| 1 | Unit coverage — placeholder feature-doc tokens not harvested | AC-1, AC-2, AC-3, AC-7 | **pass** | `evidence/regression-testing/python-classifier-marker-pass-after.md`, `evidence/regression-testing/powershell-classifier-marker-pass-after.md` |
| 2 | Unit coverage — a real path on the same task line still is | AC-7 | **pass** | `evidence/regression-testing/python-classifier-marker-pass-after.md` |
| 3 | Unit coverage — interpolation forms behave as separately specified rather than by assumption | AC-1, AC-2, AC-3, AC-14 | **pass** | `evidence/baseline/marker-probe-python.md`, `evidence/baseline/marker-probe-powershell.md` |
| 4 | Integration — two-item conflict probe reports conflict false with the placeholder | AC-8, AC-40 | **partial** | AC-40 passes at [P7-T7] in both runtimes; AC-8's fixture is blocked. `evidence/qa-gates/conflict-graph-density.md`, `evidence/other/p5-t3-blocker-conflict-fixture-seam.md` |
| 5 | Integration — existing conflict true preserved for two items sharing a real file | AC-9, AC-10, AC-18 | **pass** | `evidence/qa-gates/negative-control-reuse.md`, `evidence/qa-gates/conflict-graph-density.md` |
| 6 | Manual verification — re-derive radii over committed plans, record density and cohort count before and after | AC-15, AC-20 | **pass** | `evidence/baseline/conflict-graph-density-before.md`, `evidence/qa-gates/conflict-graph-density.md` |
| 7 | Manual verification — keep a positive control; a fix that drops real paths must be caught immediately | AC-16, AC-17, AC-18, AC-19 | **pass** | `evidence/qa-gates/conflict-graph-density.md` |
| 8 | Reuse the marker set from the acceptance-gate rule file rather than inventing a second one | AC-29, AC-32, AC-38 | **pass** | `evidence/qa-gates/rule-file-amendment.md`, `evidence/qa-gates/policy-file-untouched.md`. The set is additionally pinned equal by `test_marker_tuple_agrees_with_the_acceptance_gate_tuple`. |
| 9 | Decide silent drop versus diagnostic | AC-39 | **pass** | `evidence/qa-gates/silent-drop-audit.md` |
| 10 | Accept the false-negative trade knowingly, or narrow to bracket pairs | AC-29, AC-30 | **pass** | `evidence/qa-gates/rule-file-amendment.md` — the five-marker set is reused and the narrowing alternative is rejected |
| 11 | Logs attached | AC-14, AC-15 supersede with executed evidence | **pass** | `evidence/baseline/marker-probe-python.md`, `evidence/baseline/marker-probe-powershell.md`, `evidence/qa-gates/conflict-graph-density.md` |

## Output Summary

Exactly **41** numbered criterion rows and exactly **11** traceability rows are mapped, for **52**
items in total. Every item carries a named artifact path and a verdict; **none** is recorded as
unverified.

Of the **41** numbered criteria: **38 pass**, **2 are partial** — AC-22 on the floor arithmetic and
AC-36 on the MCP allow-list publish boundary — and **1 fails**, AC-8, blocked by [P5-T3]'s
unreachable acceptance condition. Of the **11** traceability rows: **10 pass** and **1 is partial**,
row 4, which inherits AC-8's failure while its companion AC-40 passes. Each partial and the single
failure carries its reason and its supporting measurement inline rather than being absorbed.
