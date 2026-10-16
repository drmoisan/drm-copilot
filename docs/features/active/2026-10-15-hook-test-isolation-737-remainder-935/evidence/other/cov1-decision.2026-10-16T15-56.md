# COV-1 Decision Record (issue #935)

Timestamp: 2026-10-16T15-56
Finding: COV-1 (AC-24), status `human_decision_required (NO-WRITE-SET-CANDIDATE-RESTORES)` recorded in `evidence/qa-gates/r3-cov-status.2026-10-16T15-15.md` after remediation cycle 3.

## Decision

Option 2 of the P3-T5 decision options: Pester profiler-mode coverage (`CodeCoverage.UseBreakpoints = $false`).

## Authorizing basis

- Directive from the parallel-run coordinator (parallel_slug `bug-burndown-2026-10-15`), received by the #935 item orchestrator on 2026-10-16 at about 15:45Z, in response to the cycle 3 COV-1 status record. The directive selects option 2 and states that #935 must not make the change itself.
- Issue #953 (PR #959, "fix(953): switch PoshQC coverage to Pester profiler mode and pin Pester 5.9.0 (<6.0)") sets `UseBreakpoints = $false` in `scripts/powershell/PoshQC/settings/pester.runsettings.psd1` and its extension mirror. Making the same edit in #935 would duplicate it and conflict with #953.

## Consequences for #935

- #935 makes no change to `scripts/powershell/PoshQC/settings/pester.runsettings.psd1`, its mirror, or any other coverage configuration. The spec Write Set and AC-21 are unchanged.
- After PR #959 merges, origin/main is merged into `bug/hook-test-isolation-737-remainder-935` (no force-push) and `.claude/lib/worktree-resolution/WorktreeResolution.psm1` is re-measured with the D-FILE-READ procedure of `remediation-plan.2026-10-16T07-55.md`.
- If the re-measured value reaches TARGET 142, AC-24 is recorded PASS.
- If it remains below 142 under profiler mode, AC-24 is recorded as accepted under option 1 (accept the attribution loss), with the per-file evidence, and the attribution loss is reported as an unrelated follow-up for filing.
- AC-24 is decided from the PR CI coverage file on the final PR head (plan task P7-T6) together with the re-measurement above.

## Amendment 2026-10-16T16-06 (review EV-2)

The cycle 3 re-audit (`feature-audit.2026-10-16T16-02.md`, finding EV-2) showed that main's own CI now also credits `WorktreeResolution.psm1` with 112 of 144 lines, and that at an equal 18437-line population the PR's remaining gap against main (105 covered lines) lies in `.claude/lib/orchestrator-state/` and `.claude/lib/worktree-resolution/EpicScopeResolution.psm1`, which this branch does not change. A single-file check against 142 therefore does not decide AC-24. AC-24 is decided as follows, from the PR CI coverage file on the final PR head after PR #959 has merged and origin/main has been merged into the branch:

- Compare the root LINE percentage with the baseline (90.42%, `evidence/baseline/ci-baseline.2026-10-16T00-11.md`) and with main's CI coverage file at the final merge-base, and record a per-file LINE diff against main at that merge-base.
- PASS when the root percentage is at or above 85% and not lower than main at the final merge-base, and the per-file diff shows no file covered less on the PR than on main.
- Otherwise, when every file covered less on the PR is a production file that the branch does not change (confirmed by `git diff --name-only <merge-base> HEAD`), AC-24 is recorded as accepted under option 1 (attribution loss), and the loss is listed in the final report as an unrelated follow-up with the per-file evidence.
- A file covered less on the PR that the branch does change would be a #935 defect and is not covered by this acceptance.

## Related cycle 3 evidence

- Bisection: `evidence/other/r3-cov-bisection.2026-10-16T14-13.md` (terminal `T-U4-NO-LONGER`; after the origin/main merge at `1d364d0c1`, reverting all nine U4 paths no longer restores 142).
- Fix trials FX-1, FX-2, FX-23: each `FIX-NOT-RESTORED` (covered 127).
- EV-1 correction: `evidence/other/r3-ev1-correction.2026-10-16T15-16.md`.
