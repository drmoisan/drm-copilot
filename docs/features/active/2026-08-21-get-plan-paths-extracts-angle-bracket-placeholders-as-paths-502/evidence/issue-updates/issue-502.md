# Issue Update Mirror — issue #502

Timestamp: 2026-08-23T04-42

Feature: 2026-08-21-get-plan-paths-extracts-angle-bracket-placeholders-as-paths-502 (issue #502)
Task: [P8-T17]

PostedAs: unknown

**POSTING NOT PERFORMED.** No GitHub API call was made. This execution had no instruction to post to
the issue tracker, and posting is a remote side effect that the plan does not authorize: [P8-T17]
requires the two local documents to be updated and this mirror to be written, not that a comment be
published. The exact text intended for the issue is recorded below verbatim so that whoever posts it
publishes the same words.

The same text was written into the local `## Outcome` section of both
`docs/features/active/2026-08-21-get-plan-paths-extracts-angle-bracket-placeholders-as-paths-502/issue.md`
and
`docs/features/active/2026-08-21-get-plan-paths-extracts-angle-bracket-placeholders-as-paths-502/spec.md`.

---

## Exact text

### Outcome — issue #502 resolved, with two recorded deviations

The placeholder-shape defect is fixed in both runtimes. A token containing any of the five
placeholder or interpolation markers is now rejected by the path classifier before it can become a
radius entry, so two items that cite the same mandated artifact shape no longer acquire a
`path_overlap` conflict edge on a string that names no file.

**What changed.** Two new leaf modules hold the shape predicates —
`scripts/dev_tools/_blast_radius_token_shapes.py` and
`.claude/lib/blast-radius/BlastRadiusTokenShape.psm1` — and the guard is wired into
`classify_path_token` and `Get-PathTokenKind`, after the root-surface test and before the separator
guard. The new modules were mandatory rather than stylistic: the two extraction modules stood at 497
and 498 lines against a hard 500-line limit, so an in-place guard was arithmetically impossible. Both
extraction modules finished at 475 and 472 lines, with more headroom than they started with. The
rejection is silent, returning the same no-classification value the four sibling rejections return;
no diagnostic channel, no finding rule, and no signature change was added.

**Measured effect over the 58-plan corpus**, before and after, with a constant derivation timestamp
and a byte-identical item list:

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
disappeared outright, and the 24 that survive do so on unrelated reasons, none of them
marker-bearing. Cohort count and maximum width did not move: at this density the graph still needs
the same number of cohorts, so the gain is in the edge set and the entry count, not yet in the
schedule.

**The three planner decisions, by name.**

- **AC-9 — reuse, do not add.** `tests/fixtures/blast_radius/conflict-path-overlap.json` was reused
  unmodified as the real-path negative control instead of adding a near-duplicate. A pre-existing
  fixture written before the fix existed and committed unmodified proves the fix did not perturb an
  independently authored assertion; a control authored alongside the fix proves only that its author
  expected it to pass. Verified by a zero-exit diff against the anchor.
- **AC-19 — pre-registered edge-count delta of 53.** Fixed before any code change, witnessed by a
  recorded commit SHA and a clean working tree across all three edited locations. **The actual delta
  is 15**, at or below the one-sided upper bound. The measured pair set is 63, of which 50 pairs still
  conflict on non-placeholder reasons and 13 were removed; the two remaining removed edges are
  placeholder-induced through the module level and through a glob-versus-placeholder match, which the
  plan's single-equation identity did not anticipate. Both halves of the corrected accounting balance
  exactly and the deviation is explained rather than absorbed.
- **AC-41 — declare the edge, do not sequence.** The single `path_overlap` edge with issue #500 on
  `.claude/rules/parallel-orchestration.md` and its bundled mirror is declared and accepted. Under the
  per-edge cohort barrier the two items are already mutually excluded, and `depends_on` is a
  prohibited key on this surface, so declaring the edge *is* the sequencing decision. In the event the
  question resolved itself: #500 merged as pull request #514 before this execution completed.

**Final coverage.** Python line coverage 92.61% and branch coverage 89.82%, both marginally above the
92.60% and 89.81% baseline, with 4094 tests passing. PowerShell line coverage 96.46% against a 96.47%
baseline with 3388 tests and zero failures; the missed-line count is identical at 211 in both states,
so no line regressed. Both new production modules measure 100% line and, where measurable, 100% branch
coverage, and changed-line coverage is 100% on all four touched production files. TypeScript is a
confirmed no-op at 195 suites and 2654 tests, unchanged from baseline.

**Deviation 1 — AC-8 is not met.** The conflict fixture
`tests/fixtures/blast_radius/conflict-placeholder-only-overlap.json` was not created. Its acceptance
condition is unreachable: a conflict fixture is compared as literal recorded radii and the conflict
relation never invokes the classifier, so the fixture's verdict is invariant under this fix. It could
be satisfiable or discriminating, never both. The behaviour AC-8 describes is measured instead through
the derivation seam the guard actually governs, where the placeholder-only overlap reports conflict
true before the fix and conflict false after it, in both runtimes, with the negative control false
throughout. A plan revision replacing the task with a normalization-plus-conflict assertion is
requested.

**Deviation 2 — AC-36's measured-module clause and AC-22's floor arithmetic.** The MCP Pester tool
executes from a published npm package whose bundled coverage allow-list predates this change, so its
coverage output does not yet list the new module. Both in-repository allow-lists carry the entry and a
direct measurement against the repository allow-list shows the module at 100% line coverage (19 of 19
lines); the MCP runtime will pick it up at the next publish with no further change. AC-22's floor
arithmetic reads 30 rather than 29 because the plan fixed 30 on the assumption of four new fixtures
and three were added; both floors are equal and both remain non-vacuous against 35 files on disk.

**Acceptance criteria.** Of the 41 numbered criteria, 38 pass, 2 are partial (AC-22, AC-36), and 1
fails (AC-8). Of the 11 traceability rows, 10 pass and 1 is partial. No item is unverified. The full
mapping, with a named artifact per item, is at
`docs/features/active/2026-08-21-get-plan-paths-extracts-angle-bracket-placeholders-as-paths-502/evidence/qa-gates/acceptance-criteria-status.md`.

---

## Posting instructions for whoever publishes this

- Post the section above, from the `### Outcome` heading to the end of the acceptance-criteria
  paragraph, as a **comment** on issue #502.
- If it is instead posted as an issue-body update, record `PostedAs: body`, the issue URL, and
  `IssueUpdatedAt:` in this file, and mirror the same update into the local `issue.md`, which already
  carries the identical text.
- If posted as a comment, record `PostedAs: comment` and the comment URL in this file.
