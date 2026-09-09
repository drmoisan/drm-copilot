# dirt-classifier-typechange-member-unpinned (Issue #660)

- Date captured: 2026-09-08
- Author: Dan Moisan
- Status: Promoted -> docs/features/active/dirt-classifier-typechange-member-unpinned/ (Issue #660)
- Consolidates: #661 (closed 2026-09-09). The GitHub issue body was rewritten on 2026-09-09 to cover both test-suite blind spots; the consolidated root cause and test-only blast radius are recorded there.

> Automation note: Keep the section headings below unchanged; the promotion tooling maps each of them into the GitHub bug issue template.

- Issue: #660
- Issue URL: https://github.com/drmoisan/drm-copilot/issues/660
- Last Updated: 2026-09-08
## Summary

In `scripts/bash/cleanup_worktrees_dirt_lib.sh` the content-bearing porcelain-column class is `[MARCTU]`. The `T` (typechange) member is present in the source but held by no bats assertion: mutating the class to `[MARCU]` leaves the full suite green. The shipped code is correct and there is no data-loss path; the exposure is that a later edit could drop `T` and no test would object.

## Environment

- OS/version: Windows 11 Pro 10.0.26200; bats 1.13.0 under WSL Ubuntu and via `npx --yes bats`.
- Python version: not applicable (bash).
- Command/flags used: `bash scripts/bash/shell-qc.sh test` after a scratch mutation of the character class.
- Data source or fixture: `tests/fixtures/cleanup_worktrees/` dirt scenarios; child #632 cycle-3 exit re-audit (finding NF-1).

## Steps to Reproduce

1. On a scratch copy, change `[MARCTU]` to `[MARCU]` in `scripts/bash/cleanup_worktrees_dirt_lib.sh`.
2. Run the cleanup-worktrees bats suites.
3. Observe every test passes.

## Expected Behavior

A porcelain entry with status `T` (typechange, for example a file replaced by a symlink) is classified as content-bearing, and a test pins that behavior so the mutation fails at least one case.

## Actual Behavior

No fixture carries a `T` entry, so the member is unverified. The #632 reviewer weighed this against the remediation cap and recommended a follow-up rather than a fourth cycle.

## Logs / Screenshots

- [x] Attached minimal logs or screenshot
- Snippet:

```
mutation [MARCTU] -> [MARCU]: bats 1..15 all ok (no assertion held the T member)
```

## Impact / Severity

- [ ] Blocker
- [ ] High
- [ ] Medium
- [x] Low

Future regression exposure only.

## Suspected Cause / Notes

- The dirt scenarios cover `M`, `A`, `R`, `C`, `U`, and `??` but no typechange entry.
- The stub-driven fixture model makes adding a `T` scenario a checked-in `status.<path>.out` line, no temporary files needed.

## Proposed Fix / Validation Ideas

- [x] Unit coverage areas: one scenario with a `T ` porcelain line asserting the `DIRTFILE|` verdict and the worktree's `DIRTSUM|` summary; a negative control that the `[MARCU]` mutation fails it.
- [ ] Integration scenario to retest: none.
- [x] Manual verification notes: verify on a real repo that `git status --porcelain` reports `T` for a file-to-symlink replacement on the platform in use.

## Next Step

- [x] Promote to GitHub issue (bug-report template)
- [ ] Move to active fix folder / branch
