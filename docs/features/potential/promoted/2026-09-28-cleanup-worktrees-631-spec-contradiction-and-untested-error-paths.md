# cleanup-worktrees-631-spec-contradiction-and-untested-error-paths (Issue #756)

- Date captured: 2026-09-28
- Author: Dan Moisan
- Status: Promoted -> docs/features/active/cleanup-worktrees-631-spec-contradiction-and-untested-error-paths/ (Issue #756)

> Automation note: Keep the section headings below unchanged; the promotion tooling maps each of them into the GitHub bug issue template.

- Issue: #756
- Issue URL: https://github.com/drmoisan/drm-copilot/issues/756
- Last Updated: 2026-09-28
## Summary

The final #631 code review (`code-review.2026-09-07T20-15.md`, findings CR-R4-01 and CR-R4-02) recorded two non-blocking Major findings that were never tracked: the #631 `spec.md` still contradicts its own corrected pairwise-probe invariant in two places, and the pairwise hard-failure and `run_report_scans` error paths in the cleanup-worktrees report library carry no test.

## Environment

- OS/version: any (bash toolchain: bats, kcov)
- Python version: n/a
- Command/flags used: `bash scripts/bash/cleanup-worktrees.sh` (report mode)
- Data source or fixture: `tests/fixtures/cleanup_worktrees/scenarios/`

## Steps to Reproduce

1. Read `docs/features/active/2026-09-06-cleanup-worktrees-report-mode-visibility-gaps-631/spec.md` lines 202-212, then lines 280-281 and 410-412.
2. Observe that lines 280 and 411 state a pairwise `merge-base --is-ancestor` hard failure maps to `ANCESTRY_ERROR`, while the invariant section and the delivered code do not map that failure onto the branch verdict.
3. Run the bats suite under kcov and inspect coverage for `scripts/bash/cleanup_worktrees_report_records_lib.sh`: the pairwise-probe `rc=2` path and the `run_report_scans` scan-failure / rc-maximization block are never executed.

## Expected Behavior

- `spec.md` states one consistent contract for a pairwise-probe hard failure, matching the delivered code.
- The pairwise-probe hard-failure path and the `run_report_scans` non-zero-rc paths are pinned by tests.

## Actual Behavior

- CR-R4-01: `spec.md:280` and `spec.md:411` describe the removed verdict-overwrite mechanism; line 411 also prescribes a required test case that cannot exist under the delivered contract.
- CR-R4-02: at review time (CI run 34162347134) line 462 (`rc=2` on a pairwise-probe hard failure) and lines 325-341 (`run_report_scans` scan-failure and rc-maximization block, new in #631) of `cleanup_worktrees_report_records_lib.sh` were unhit. The existing `child_of_ancestry_probe_error` scenario does not cover line 462, because its `merge-base.feature-child.rc = 128` is consumed by the ladder's rung-2 probe. Line numbers are as of the review and may have shifted.

## Logs / Screenshots

- [ ] Attached minimal logs or screenshot
- Snippet: `code-review.2026-09-07T20-15.md` sections CR-R4-01 and CR-R4-02 in the #631 feature folder.

## Impact / Severity

- [ ] Blocker
- [ ] High
- [ ] Medium
- [x] Low

Delivered behavior was verified correct by manual execution; the uncovered paths are advisory error handling that never unlocks a destructive action. The risk is a future change regressing these paths undetected, and the spec misdirecting a reader.

## Suspected Cause / Notes

The #631 remediation plan's documentation scope corrected one paragraph describing the verdict-overwrite mechanism and left two others of the same class. Error-path coverage (R-06) was explicitly deferred for that cycle.

## Proposed Fix / Validation Ideas

- [ ] Rewrite `spec.md:280` and `spec.md:411` to the `spec.md:202-208` contract.
- [ ] Unit coverage areas: add a scenario supplying `merge-base.<a>.<b>.rc = 128` between two branches that both resolve `NOT_MERGED`, asserting the `rc=2` outcome and an unchanged `BRANCH|` verdict.
- [ ] Unit coverage areas: add a scenario that makes a `run_report_scans` scan fail with a non-zero rc and asserts the maximized return code.
- [ ] Manual verification notes: confirm kcov reports both blocks as hit.

## Next Step

- [ ] Promote to GitHub issue (bug-report template)
- [ ] Move to active fix folder / branch
