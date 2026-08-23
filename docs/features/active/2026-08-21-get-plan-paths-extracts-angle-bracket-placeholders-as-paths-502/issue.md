# get-plan-paths-extracts-angle-bracket-placeholders-as-paths (Issue #502)

- Date captured: 2026-08-21
- Author: Dan Moisan
- Status: Promoted -> docs/features/active/2026-08-21-get-plan-paths-extracts-angle-bracket-placeholders-as-paths-502/ (Issue #502)

> Automation note: Keep the section headings below unchanged; the promotion tooling maps each of them into the GitHub bug issue template.

- Issue: #502
- Issue URL: https://github.com/drmoisan/drm-copilot/issues/502
- Origin: reported first in drmoisan/TaskMaster as issue #580; this record is the drm-copilot lifecycle entry
- Last Updated: 2026-08-22
- Work Mode: full-bug

## Summary

`Get-PlanPaths` harvests angle-bracket placeholder tokens such as `<FEATURE>/spec.md` as if they were real repository paths. Two genuinely disjoint work items whose plans both document a command shape using that placeholder therefore conflict on `path_overlap`, inflating the parallel conflict graph and suppressing concurrency that should be available.

## Environment

- OS/version: Windows 11 Pro 10.0.26200
- Python version: n/a — the destination-runtime implementation is PowerShell; PowerShell 7.6.5
- Command/flags used: `Get-BlastRadius`, `Test-BlastRadiusConflict` from `.claude/lib/blast-radius/BlastRadius.psm1`
- Data source or fixture: reproduced in the destination repository `drmoisan/TaskMaster` at `b9a9b92c`; `.claude/lib/blast-radius/BlastRadiusExtraction.psm1` in this repository carries no placeholder rejection

## Steps to Reproduce

1. Import `.claude/lib/blast-radius/BlastRadius.psm1` and load `config/blast-radius.json`.
2. Build two radii from structured plan text. Each task line must be a well-formed `- [ ] [P1-T1]` entry with inline-code tokens, since that is the only form the extractor harvests. Give item A `` `<FEATURE>/spec.md` `` plus `` `QuickFiler/A.cs` ``, and item B `` `<FEATURE>/spec.md` `` plus `` `ToDoModel/B.cs` `` — different feature folders, disjoint real files.
3. Inspect `paths` on each radius.
4. Call `Test-BlastRadiusConflict` on the pair.
5. Repeat steps 2 through 4 with the placeholder removed, as a negative control.

## Expected Behavior

A placeholder is not a write claim. `<FEATURE>/spec.md` documents a path *shape*, exactly as the plan-acceptance-gate rules already recognise for command shapes, where a token containing `<`, `>`, `${`, `$(`, or `%` is treated as a documented shape rather than a real assertion. `Get-PlanPaths` should reject such tokens, and the two disjoint items should report `conflict=False`.

## Actual Behavior

The placeholder is harvested into `paths` verbatim and the pair conflicts:

```text
paths          : <FEATURE>/spec.md | QuickFiler/Real.cs | docs/features/active/probe-1/**
placeholder-only overlap  -> conflict=True
   {"detail":"<FEATURE>/spec.md ~ <FEATURE>/spec.md","kind":"path_overlap"}
control, no placeholder   -> conflict=False
```

The control isolates the cause: the only difference between the two runs is the placeholder token, and it alone flips the verdict.

Measured frequency over the 16 committed plans under `docs/features/active/` in TaskMaster: `<FEATURE>/spec.md` appears in 5 of 16 and `<FEATURE>/issue.md` in 4 of 16, so the spurious clique is not hypothetical.

Note the asymmetry with the sibling rule set. `.claude/rules/plan-acceptance-gates.md` already defines a placeholder guard for acceptance-gate literals, listing exactly the markers `<`, `>`, `${`, `$(`, and `%`, and records a preflight measurement justifying it. The blast-radius extractor does not apply the same guard, so the two subsystems disagree about whether a placeholder is real.

## Logs / Screenshots

- [x] Attached minimal logs or screenshot
- Snippet is inlined under **Actual Behavior** above.
- ~~Scope correction to an earlier report: `${VAR}/y.cs` was **not** reproduced as extracting — that form is already rejected. The defect is specific to the angle-bracket shape, so a fix should not assume the interpolation forms are also affected without re-testing each one.~~
- **RETRACTED 2026-08-22 — the scope correction above is wrong.** It instructed re-testing each form, and that re-test overturned it. All five markers are accepted as `concrete` by both runtimes. Measured with single-quoted probes against `classify_path_token` (`scripts/dev_tools/_blast_radius_extraction.py`) and `Get-PathTokenKind` (`.claude/lib/blast-radius/BlastRadiusExtraction.psm1`):

  ```text
  <FEATURE>/spec.md   -> concrete      ${FEATURE}/spec.md -> concrete
  ${VAR}/y.cs         -> concrete      $(VAR)/y.cs        -> concrete
  %VAR%/y.cs          -> concrete
  ```

  The original probe most likely used a PowerShell double-quoted string, in which `"${VAR}/y.cs"` interpolates to `/y.cs` and is then rejected by the leading-separator guard — an artifact of the probe, not of the classifier. The defect is therefore **not** specific to the angle-bracket shape: the fix must reject the full marker set `<`, `>`, `${`, `$(`, `%`, matching the set already specified in `.claude/rules/plan-acceptance-gates.md`, so the two subsystems agree.

## Impact / Severity

- [ ] Blocker
- [ ] High
- [x] Medium
- [ ] Low

Medium. It fails **closed**, so it costs concurrency rather than correctness — the opposite direction from the missing-shared-surfaces defect, which fails open. It contributes to a measured conflict-graph density of 83.3% over TaskMaster's committed plans, where `compute-cohorts.sh` produced 11 cohorts for 16 items with a maximum parallel width of 2, rendering a large `max_concurrency` inert.

## Suspected Cause / Notes

- `.claude/lib/blast-radius/BlastRadiusExtraction.psm1` — `Get-PlanPaths` applies shape rules (rejecting a wildcard-free token whose final component names a directory, a `docs/features/` glob whose wildcard truncates the feature-folder segment, and a contract token with no ASCII letter) but has no placeholder rule.
- Reuse the marker set already specified in `.claude/rules/plan-acceptance-gates.md` rather than inventing a second one, so the two subsystems agree.
- That rule file also documents a known false-negative class for the same guard: a literal using `<`, `>`, or `%` as an ordinary character — a TypeScript generic, a comparison operator, a version constraint — is skipped. Accept that trade knowingly here, or narrow the marker set to bracket *pairs* enclosing an identifier-like token, which would cover `<FEATURE>` without swallowing every bare angle bracket.
- Consider also whether the token should be dropped silently or recorded as a diagnostic. A plan that cites `<FEATURE>/spec.md` is arguably under-specified, and a warning would surface that rather than hide it.

## Proposed Fix / Validation Ideas

- [x] Unit coverage areas — cases asserting `<FEATURE>/spec.md` and `<FEATURE>/issue.md` are not harvested; that a real path in the same task line still is; and that the interpolation forms behave as separately specified rather than by assumption.
- [x] Integration scenario to retest — the two-item conflict probe above, asserting `conflict=False` with the placeholder and preserving the existing `conflict=True` for two items that share a real file.
- [x] Manual verification notes — re-derive radii for the committed plans and record conflict-graph density and cohort count before and after. Keep a positive control in the same run: a fix that drops real paths would show as a density collapse and must be caught immediately.

## Next Step

- [x] Promote to GitHub issue (bug-report template)
- [x] Move to active fix folder / branch

## Outcome — issue #502 resolved, with two recorded deviations

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
