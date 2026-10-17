# subagentstop-artifact-gates-review-notes-929 (Issue #929)

- Date captured: 2026-10-15
- Author: Dan Moisan
- Issue: #929
- Issue URL: https://github.com/drmoisan/drm-copilot/issues/929
- Origin: filed before orchestration (adopted; verified read-only with `gh issue view 929` on 2026-10-15)
- Lifecycle record: docs/features/potential/promoted/2026-10-15-subagentstop-artifact-gates-review-notes-905.md (ref `origin/docs/followups-2026-10-15`)
- Work Mode: full-bug
- Work Mode Selection Note: the issue and lifecycle record request `minor-audit`. The selected mode is `full-bug` because the scope touches more than the minor-audit budget (two production validators, seven Pester suites, and one new shared test helper) and the preparation route requires `spec.md`.
- Last Updated: 2026-10-15

## Summary

Non-blocking review notes from epic #904 child E3 (#905, PR #908) on the four artifact-gate SubagentStop validators, other than NB-6 (filed separately as #928).

## Environment

- OS/version: any
- Python version: n/a
- Command/flags used: see Steps
- Data source or fixture: main at f6915d42

## Steps to Reproduce

See the E3 feature folder `subagentstop-envelope-artifact-gates-905` (under `docs/features/active/` or `docs/features/archive/`), file `code-review.2026-10-12T04-58.md`, rows NB-1 to NB-5 and NB-7 to NB-11.

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

Concurrency note: issue #928 (NB-6, unhandled-error exit 2) runs concurrently and edits the SubagentStop validators and `.claude/hooks/subagentstop-envelope.ps1`. Production edits to those files in this item are kept minimal, and any unavoidable overlap is recorded in the plan.

## Proposed Fix / Validation Ideas

- Fix NB-2 and NB-11 with tests.
- Add the missing R3/R4 cases (NB-1, NB-3) and a corpus run that exercises validator dispatch (NB-9).
- Extract one shared envelope test builder (NB-4); remove the alias (NB-5); update the AC-20/AC-11 wording (NB-7, NB-8).
- Record NB-10 as a review-process note, with no code change.

Acceptance criteria for this `full-bug` item are authoritative in `spec.md`.
