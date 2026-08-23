# poshqc-coverage-denominator-not-reproducible (Issue #527)

- Date captured: 2026-08-23
- Author: Dan Moisan
- Status: Promoted -> docs/features/active/poshqc-coverage-denominator-not-reproducible/ (Issue #527)

> Automation note: Keep the section headings below unchanged; the promotion tooling maps each of them into the GitHub bug issue template.

- Issue: #527
- Issue URL: https://github.com/drmoisan/drm-copilot/issues/527
- Last Updated: 2026-08-23
## Summary

The PowerShell line-coverage denominator reported by the PoshQC test run is not reproducible across
sessions. Three different totals were recorded for the same 79 files with identical test results,
which makes the reported coverage percentage unverifiable and the coverage gate's number
meaningless even when it passes.

## Environment

- OS/version: Windows 11 Pro 10.0.26200
- Python version: not applicable (PowerShell / Pester)
- Command/flags used: `mcp__drm-copilot__run_poshqc_test`
- Data source or fixture: `artifacts/pester/powershell-coverage.xml`, full repository Pester suite

## Steps to Reproduce

1. Run `mcp__drm-copilot__run_poshqc_test` over the full suite and record the reported line-coverage percentage and its denominator.
2. Run it again in a later session with no change to the tracked tree.
3. Compare the denominators.

## Expected Behavior

For an unchanged tree and an identical set of measured files, the coverage denominator is a function
of the source under measurement and is therefore stable. Two runs should report the same total, so
the percentage can be verified and compared against a threshold and against a baseline.

## Actual Behavior

Three distinct denominators were recorded during issue #500, all over the same 79 files and all with
the same test outcome:

| Denominator | Reported coverage | Recorded in |
| --- | --- | --- |
| 6020 | — | `evidence/qa-gates/final-powershell-poshqc-test.2026-08-22T00-30.md:38` |
| 5969 | 96.47% | `evidence/qa-gates/final-powershell-poshqc-test.2026-08-23T02-59.md`, cited at `2026-08-23T04-45-audit/code-review.2026-08-23T04-45.md:328` |
| 6622 | 96.18% | reviewer's independent re-run, `2026-08-23T04-45-audit/code-review.2026-08-23T04-45.md:329` |

The 5969 and 6622 measurements were taken from the same commit with an identical test result
(3362 passed, 9 skipped, 0 failed), so the difference is in what was measured, not in what was run.
All three clear the 85% line-coverage threshold, so no gate failed — which is precisely why this went
unnoticed across a four-cycle remediation.

## Logs / Screenshots

- [x] Attached minimal logs or screenshot
- Snippet: the reviewer recorded "96.18% (denominator 6622)" against the previously recorded "96.47% (denominator 5969)" over the same 79 files, in `2026-08-23T04-45-audit/code-review.2026-08-23T04-45.md` lines 328-329.

## Impact / Severity

- [ ] Blocker
- [ ] High
- [x] Medium
- [ ] Low

Medium. No gate is currently failing, and correctness of shipped code is unaffected. The damage is to
the integrity of the measurement: a coverage figure that cannot be reproduced cannot be compared
against a baseline, so the "no regression on changed lines" requirement in
`.claude/rules/general-unit-test.md` cannot actually be evaluated for PowerShell. It also costs real
time — this discrepancy had to be investigated during a remediation cycle and recorded as a finding
rather than resolved.

It is not Low because an unstable denominator can mask a genuine regression: a drop in covered lines
can be offset by a shrinking denominator and still report a passing percentage.

## Suspected Cause / Notes

Unknown. The most likely candidate is variation in the set of files included in the coverage run
rather than in the coverage data itself — for example a glob that picks up different files depending
on working directory, worktree, or pre-existing untracked or generated files. The 79-file count was
reported as equal across the two compared runs, so if that count is accurate the variation is in
which lines within those files are counted as coverable, which would point at the coverage
instrumentation rather than at file selection. Both hypotheses are untested.

Two adjacent facts worth noting for whoever investigates:

- PowerShell is exempt from the branch-coverage threshold because Pester does not measure branch coverage (`.claude/rules/quality-tiers.md`), so the line figure is the only PowerShell coverage signal there is. Its stability therefore matters more than it would if a second metric corroborated it.
- Running PoshQC also rewrites `artifacts/pester/powershell-coverage.xml` in place and creates gitignored `.claude/state/*-batch-budget.default.json` files, the latter being issue #510. Any investigation should account for those side effects rather than being surprised by them.

## Proposed Fix / Validation Ideas

- [x] Unit coverage areas: first establish reproducibility as a test. Run the coverage collection twice against an unchanged tree and assert the denominator is identical. That test is the acceptance criterion for any fix, and it must be shown to fail against today's behavior before a fix is written, otherwise it asserts nothing.
- [x] Integration scenario to retest: capture the file list and per-file coverable-line counts from two runs and diff them, to determine whether the variation is in file selection or in line classification. That diff is the diagnostic; the fix cannot be chosen before it exists.
- [ ] Consider recording the denominator alongside the percentage in every coverage evidence artifact, so a future drift is visible in the record rather than only when two figures happen to be compared by a reviewer.
- [x] Manual verification notes: run from a clean worktree with no untracked files present, and separately with the known gitignored state files present, to test whether their presence changes the measured set.

## Next Step

- [x] Promote to GitHub issue (bug-report template)
- [ ] Move to active fix folder / branch
