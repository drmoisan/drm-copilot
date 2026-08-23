# truth-table-non-emptiness-assertions-cannot-fail (Issue #513)

- Date captured: 2026-08-23
- Author: Dan Moisan
- Status: Promoted -> docs/features/active/truth-table-non-emptiness-assertions-cannot-fail/ (Issue #513)

> Automation note: Keep the section headings below unchanged; the promotion tooling maps each of them into the GitHub bug issue template.

- Issue: #513
- Issue URL: https://github.com/drmoisan/drm-copilot/issues/513
- Last Updated: 2026-08-23
## Summary

Three non-emptiness assertions in `tests/scripts/claude-lib/blast-radius/BlastRadius.TruthTable.Tests.ps1`
cannot fail, because `@($null).Count` is `1` in PowerShell rather than `0`. Each reads
`@($x).Count | Should -BeGreaterThan 0`, so the assertion passes even when `$x` is null.

## Environment

- OS/version: Windows 11 Pro 10.0.26200
- Python version: not applicable (PowerShell / Pester)
- Command/flags used: `mcp__drm-copilot__run_poshqc_test` scoped to `tests/scripts/claude-lib/blast-radius`
- Data source or fixture: `config/blast-radius.json` and its bundled copy under `extensions/drm-copilot/resources/claude-customizations/config/`

## Steps to Reproduce

1. In `pwsh`, evaluate `@($null).Count`. It returns `1`, not `0`.
2. Read `BlastRadius.TruthTable.Tests.ps1` at lines 72, 171, and 172. Each asserts
   `@($x).Count | Should -BeGreaterThan 0` as a non-vacuity floor.
3. Substitute a null value for the collection each line guards. The assertion still passes.

## Expected Behavior

A non-vacuity floor should fail when the collection it guards is null or empty, so that a later
assertion over that collection cannot silently iterate zero elements and report success.

## Actual Behavior

The floor passes on a null input. `@($null)` wraps the null in a single-element array, so `.Count`
is `1` and `Should -BeGreaterThan 0` is satisfied. The floor therefore does not establish the
property it exists to establish.

## Logs / Screenshots

- [x] Attached minimal logs or screenshot
- Snippet: `pwsh -c '@($null).Count'` prints `1`.

## Impact / Severity

- [ ] Blocker
- [ ] High
- [ ] Medium
- [x] Low

Low because the affected floors are currently compensated. The four-state floor added by issue #500's
cycle 3 covers the same ground, and the fifth case added by cycle 4 uses the sound form. The defect
is that the three older floors would not catch a regression on their own.

## Suspected Cause / Notes

Pre-existing. The three lines are present at merge-base `bee15c06` and were not touched by the
issue #500 branch. Found during the issue #500 cycle-4 exit re-audit and recorded there as finding
I3; see
`docs/features/active/2026-08-21-blast-radius-bundled-config-stale-skeleton-500/2026-08-23T04-45-audit/code-review.2026-08-23T04-45.md`.

The correct form is already in the same test tree. The floor added by issue #500 uses
`@($x | Where-Object { ... })`, which yields a genuinely empty array on a null input and therefore
fails as intended. That is the pattern the three older lines should adopt.

This is an instance of the recurring class tracked in `.claude/rules/plan-acceptance-gates.md`: a
verification step that reads as a gate but cannot fail with respect to the property it asserts.

## Proposed Fix / Validation Ideas

- [x] Unit coverage areas: rewrite the three floors to the `@($x | Where-Object { ... })` form used
      by the cycle-4 case, then perturb each guarded collection to null and confirm each floor now
      fails. A floor that does not fail under that perturbation has not been fixed.
- [ ] Integration scenario to retest: full `tests/scripts/claude-lib/blast-radius` directory run;
      the total should be unchanged.
- [x] Manual verification notes: confirm in `pwsh` that the replacement expression returns `0` for a
      null input before relying on it.

## Next Step

- [x] Promote to GitHub issue (bug-report template)
- [ ] Move to active fix folder / branch
