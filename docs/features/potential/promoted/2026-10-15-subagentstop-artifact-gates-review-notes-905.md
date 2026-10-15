# subagentstop-artifact-gates-review-notes-905 (Issue #929)

- Date captured: 2026-10-15
- Author: Dan Moisan
- Status: Promoted -> docs/features/active/subagentstop-artifact-gates-review-notes-905/ (Issue #929)
- Work Mode: minor-audit

> Automation note: Keep the section headings below unchanged; the promotion tooling maps each of them into the GitHub bug issue template.

- Issue: #929
- Issue URL: https://github.com/drmoisan/drm-copilot/issues/929
- Last Updated: 2026-10-15
## Summary

Non-blocking review notes from epic #904 child E3 (#905, PR #908) on the four artifact-gate SubagentStop validators, other than NB-6 (filed separately).

## Environment

- OS/version: any
- Python version: n/a
- Command/flags used: see Steps
- Data source or fixture: main at f6915d42

## Steps to Reproduce

See docs/features/active/subagentstop-envelope-artifact-gates-905/code-review.2026-10-12T04-58.md, rows NB-1 to NB-5 and NB-7 to NB-11.

## Expected Behavior

The items below are resolved or explicitly closed as no-action.

## Actual Behavior

- NB-1: R3 rejection unit tests (`validate-prd-feature-output.Tests.ps1:211-212`, `validate-task-researcher-output.Coverage.Tests.ps1:309-311`) are not exhaustive.
- NB-2: R3 admits whole-worktree scope values that then enumerate a narrower covered set (`validate-prd-feature-output.ps1:51`, `validate-task-researcher-output.ps1:202`).
- NB-3: R4 has one unit case; the spec's lone-backtick example is untested (`validate-discovery-artifact-gate.Tests.ps1:344-357`).
- NB-4: `New-SubagentStopEnvelopeJson` is defined in seven suites, each with a PSUseShouldProcess suppression.
- NB-5: redundant `agentOutput` alias (`validate-task-researcher-output.ps1:243-244`).
- NB-7: AC-20's literal grep no longer matches after the `validatorResult` rename (`validate-discovery-artifact-gate.ps1:233-236`).
- NB-8: AC-11 wording satisfied only by a Before-runs commit.
- NB-9: the discovery corpus ran with the default declaration reader, so validator dispatch was not exercised.
- NB-10: the canonical coverage XML was absent from the review worktree.
- NB-11: an unreachable dependency-decision statement returns `{ExitCode; Reason}` where callers read `Ok`/`Message` (`validate-task-researcher-output.ps1:239-240`).

## Logs / Screenshots

- [x] Attached minimal logs or screenshot
- Snippet: E3 code-review 2026-10-12T04-58 rows NB-1..NB-11.

## Impact / Severity

- [ ] Blocker
- [ ] High
- [ ] Medium
- [x] Low

## Suspected Cause / Notes

NB-2 and NB-11 are behavioral; NB-1, NB-3, NB-4 and NB-9 are test gaps; NB-5, NB-7, NB-8 and NB-10 are hygiene.

## Proposed Fix / Validation Ideas

- [ ] Fix NB-2 and NB-11 with tests.
- [ ] Add the missing R3/R4 cases (NB-1, NB-3) and a corpus run that exercises validator dispatch (NB-9).
- [ ] Extract one shared envelope test builder (NB-4); remove the alias (NB-5); update the AC-20/AC-11 wording (NB-7, NB-8).
- [ ] Record NB-10 as a review-process note or close as no action.

## Next Step

- [ ] Promote to GitHub issue (bug-report template)
- [ ] Move to active fix folder / branch