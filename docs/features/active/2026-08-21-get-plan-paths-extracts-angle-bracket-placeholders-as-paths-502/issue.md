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
- [ ] Move to active fix folder / branch
