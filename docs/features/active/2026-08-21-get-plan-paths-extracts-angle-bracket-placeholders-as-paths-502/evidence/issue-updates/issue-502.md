# Issue Update Mirror — issue #502

Timestamp: 2026-08-23T05-48

Feature: 2026-08-21-get-plan-paths-extracts-angle-bracket-placeholders-as-paths-502 (issue #502)
Task: [P8-T17]
Run: revision-6 re-run. This mirror supersedes the previous run's text, which recorded AC-8 as a
failure; it is now recorded as withdrawn as unsatisfiable, and AC-22 as a pass with a documented
discrepancy.

PostedAs: unknown

**POSTING NOT PERFORMED.** No GitHub API call was made. This execution had no instruction to post to the
issue tracker, and posting is a remote side effect the plan does not authorize: [P8-T17] requires the two
local documents to be updated and this mirror to be written, not that a comment be published. The exact
text intended for the issue is recorded verbatim below so that whoever posts it publishes the same words.

The same text was written into the `## Outcome` section of both the feature `issue.md` and the feature
`spec.md`.

---

## Exact text

## Outcome — issue #502 resolved

The placeholder-shape defect is fixed in both runtimes. A token containing any of the five placeholder
or interpolation markers is now rejected by the path classifier before it can become a radius entry, so
two items that cite the same mandated artifact shape no longer acquire a `path_overlap` conflict edge on
a string that names no file.

**What changed.** Two new leaf modules hold the shape predicates —
`scripts/dev_tools/_blast_radius_token_shapes.py` and
`.claude/lib/blast-radius/BlastRadiusTokenShape.psm1` — and the guard is wired into
`classify_path_token` and `Get-PathTokenKind`, after the root-surface test and before the separator
guard. The new modules were mandatory rather than stylistic: the two extraction modules stood at 497 and
498 lines against a hard 500-line limit, so an in-place guard was arithmetically impossible. Both
finished at 475 and 472 lines, with more headroom than they started with. The rejection is silent,
returning the same no-classification value the four sibling rejections return; no diagnostic channel, no
finding rule, and no signature change on any pre-existing surface was added.

**Measured effect over the 58-plan corpus**, before and after, with a constant derivation timestamp and a
byte-identical item list:

| Quantity | Before | After |
| --- | --- | --- |
| conflict edges | 1282 | 1267 |
| density | 77.6% | 76.6% |
| cohorts | 32 | 32 |
| maximum cohort width | 4 | 4 |
| total radius path entries | 3729 | 2472 |

1257 path entries were dropped and **every single one contains a marker character**; zero marker-free
entries were dropped and zero entries were added. The nine-item clique induced by the mandated
evidence-path shape is gone as a clique: all 36 of its pairs lost the placeholder reason, 12 edges
disappeared outright, and the 24 that survive do so on unrelated reasons, none marker-bearing. Cohort
count and maximum width did not move: at this density the graph still needs the same number of cohorts,
so the gain is in the edge set and the entry count, not yet in the schedule.

**The three planner decisions, by name.**

- **AC-9 — reuse, do not add.** `tests/fixtures/blast_radius/conflict-path-overlap.json` was reused
  unmodified as the real-path negative control instead of adding a near-duplicate. A pre-existing fixture
  written before the fix existed and committed unmodified proves the fix did not perturb an
  independently authored assertion; a control authored alongside the fix proves only that its author
  expected it to pass. Verified by a zero-exit diff against the anchor. The decision was taken when four
  fixtures were planned; three were added, and the corpus floors deliberately stay at 30.
- **AC-19 — pre-registered edge-count delta of 53.** Fixed before any code change, witnessed by a
  recorded commit SHA and a clean working tree across all three edited locations. **The actual delta is
  15**, at or below the one-sided upper bound. The measured pair set is 63, of which 50 pairs still
  conflict on non-placeholder reasons and 13 were removed; the two remaining removed edges are
  placeholder-induced through the module level and through a glob-versus-placeholder match, which the
  plan's single-equation identity did not anticipate. Both halves of the corrected accounting balance
  exactly and the deviation is explained rather than absorbed.
- **AC-41 — declare the edge, do not sequence.** The single `path_overlap` edge with issue #500 on
  `.claude/rules/parallel-orchestration.md` and its bundled mirror is declared and accepted. Under the
  per-edge cohort barrier the two items are already mutually excluded, and a dependency key is
  prohibited on this surface, so declaring the edge *is* the sequencing decision. In the event the
  question resolved itself: #500 merged as pull request #514 before this execution completed.

**Final toolchain state.** Python: 4095 tests passing, line coverage 92.61% and branch coverage 89.82%,
both marginally above the 92.60% and 89.81% baseline, with changed-line coverage 100% on both touched
modules. PowerShell: 3389 tests, zero failures, line coverage 96.46% against a 96.47% baseline with the
missed-line count identical at 211, so no line regressed. TypeScript: a confirmed no-op at 195 suites
and 2654 tests, unchanged from baseline. All ten toolchain gates passed in a single uninterrupted pass.

**One acceptance criterion is withdrawn as unsatisfiable.** AC-8 required a conflict fixture asserting
that a placeholder-only overlap yields no conflict. That fixture cannot be both satisfiable and
discriminating: a conflict fixture supplies literal recorded radii straight to the conflict relation, and
`classify_path_token` has exactly two callers — the extraction module and the declared-radius
normalization entry point — neither of which the conflict chain calls. Its verdict is therefore invariant
under this fix. The literal clause is withdrawn and its substance is discharged twice over: by a named
normalization-plus-conflict test in each runtime, each asserting both that the pre-normalization pair
conflicts and that the normalized pair does not, and by the post-fix integration repro that is the
issue's own Steps to Reproduce. Both runtimes report conflict false post-fix with the negative control
still false.

**One acceptance criterion is partial.** AC-36's "with the new module measured" clause is not observable
through the MCP Pester tool, which executes from a published npm package whose bundled coverage
allow-list predates this change. Both in-repository allow-lists carry the entry, and a direct measurement
against the repository allow-list shows the module at 100% line coverage (19 of 19 lines). The MCP runtime
picks it up at the next publish with no further change.

**Acceptance criteria.** Of the 41 numbered criteria, 39 pass, 1 is partial (AC-36), and 1 is withdrawn
(AC-8). All 11 traceability rows pass. No item is unverified and none is a failure. AC-22 passes with a
documented one-count discrepancy: its literal arithmetic reads 29 while the executed floors are 30, which
is the more conservative value and still non-vacuous against 35 fixtures on disk. The full mapping, with a
named artifact per item, is at `evidence/qa-gates/acceptance-criteria-status.md`.

---

## Posting instructions for whoever publishes this

- Post the section above, from the `## Outcome` heading to the end of the acceptance-criteria paragraph,
  as a **comment** on issue #502.
- If it is instead posted as an issue-body update, record `PostedAs: body`, the issue URL, and
  `IssueUpdatedAt:` in this file, and mirror the same update into the local `issue.md`, which already
  carries the identical text.
- If posted as a comment, record `PostedAs: comment` and the comment URL in this file.
