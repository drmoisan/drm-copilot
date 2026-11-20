# codex-review-coverage-hook-reads-stale-or-foreign-artifacts (Issue #1114)

- Date captured: 2026-11-07
- Author: Dan Moisan
- Status: Promoted -> docs/features/active/codex-review-coverage-hook-reads-stale-or-foreign-artifacts/ (Issue #1114)

> Automation note: Keep the section headings below unchanged; the promotion tooling maps each of them into the GitHub bug issue template.

- Issue: #1114
- Issue URL: https://github.com/drmoisan/drm-copilot/issues/1114
- Last Updated: 2026-11-07
## Summary

The Codex review coverage hook, `.codex/hooks/validate-feature-review-coverage.ps1`, reads coverage reports with no freshness check, and it selects the newest policy audit across all active feature folders. It can therefore judge a review against stale coverage or against another item's audit. Issue #1105 (PR #1113) fixed the same defect class in the Claude hooks and left this Codex twin out of scope.

## Environment

- OS/version: Windows 11 Pro, PowerShell 7
- Python version: 3.13 (Poetry environment)
- Command/flags used: Codex runtime review stop with `.codex/hooks/validate-feature-review-coverage.ps1`
- Data source or fixture: any checkout with more than one active feature folder, or with a coverage report older than the item's latest commit

## Steps to Reproduce

1. Have two active feature folders, each with a policy audit, with the other item's audit written more recently.
2. Run a Codex feature review for the first item.
3. Observe the hook select the other item's audit.
4. Separately, leave a coverage report older than the item's newest commit, and observe the hook accept it.

## Expected Behavior

The hook reads the policy audit of the item under review, and the coverage report from that item's worktree. It blocks with a clear message when the report is missing or older than the newest item commit that touches the language, matching the Claude behaviour from #1105.

## Actual Behavior

The hook picks the newest policy audit across all active feature folders and reads coverage reports without checking their age. A review can pass or fail on another item's audit or on stale coverage.

## Logs / Screenshots

- [ ] Attached minimal logs or screenshot
- Snippet: reported by the #1105 orchestrator, 2026-11-07, as an out-of-scope finding.

## Impact / Severity

- [ ] Blocker
- [x] High
- [ ] Medium
- [ ] Low

## Suspected Cause / Notes

The Claude fix added `.claude/hooks/subagentstop-target-worktree.ps1`, which reuses `Resolve-HookTargetWorktree`, plus a freshness check. The Codex hook predates it and resolves the audit by recency, not by item.

## Proposed Fix / Validation Ideas

- [ ] Unit coverage areas: audit selection by item identity; coverage freshness against the newest item commit per language; a missing report; another item's newer audit present.
- [ ] Integration scenario to retest: a Codex review stop with two active items and a stale report.
- [ ] Manual verification notes: reuse the #1105 design and helpers where the Codex runtime allows, and keep behaviour unchanged for a single-item checkout with a fresh report.

## Next Step

- [ ] Promote to GitHub issue (bug-report template)
- [ ] Move to active fix folder / branch
