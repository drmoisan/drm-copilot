# extension-release-for-824-and-852-changes (Issue #893)

- Date captured: 2026-10-11
- Author: Dan Moisan
- Status: Promoted -> docs/features/active/extension-release-for-824-and-852-changes/ (Issue #893)
- Origin: issue #824 follow-up FU-823-4 (PR #879 Follow-ups item 2); epic #852 (PR #855 via integration PR #883)

> Automation note: Keep the section headings below unchanged; the promotion tooling maps each of them into the GitHub bug issue template.

- Issue: #893
- Issue URL: https://github.com/drmoisan/drm-copilot/issues/893
- Last Updated: 2026-10-11
## Summary

The drm-copilot extension has not been rebuilt, published or reinstalled since the #824 changes merged. `extensions/drm-copilot/package.json:6` is still `"version": "1.1.18"`, last bumped in c4c2dcfb3 on 2026-10-02, before PR #855 (2026-10-09, via #883) and PR #879 (2026-10-10). Consumers receive pushed-down customizations from the installed extension payload, so none of these changes reach consuming repositories until a release.

## Environment

- OS/version: any consumer of the drm-copilot VS Code extension / MCP server
- Python version: n/a
- Command/flags used: push-down MCP tools (`push_down_claude_customizations` and the Codex and Copilot equivalents) from the installed extension
- Data source or fixture: main at 2ef8d361; `extensions/drm-copilot/package.json`

## Steps to Reproduce

1. Read `extensions/drm-copilot/package.json` version on main.
2. Compare with the merge dates of PR #855 and PR #879.
3. Run a push-down into a consumer repository from the installed extension and check whether `.claude/rules/quality-tiers.md` carries the #823 adoption gate.

## Expected Behavior

After user-facing customization changes merge, a release is cut (version bump, build, publish, reinstall) and a consumer push-down delivers the merged content.

## Actual Behavior

- Version 1.1.18 predates both PRs; no release carries the #824 or epic #852 changes.
- `docs/features/active/2026-10-03-issue-823-tier-rule-adoption-follow-ups-824/issue.md:30-36`: "Status: Open (out of scope for #824; no release automation is run)", with a request to verify on the next consumer push-down that `.claude/rules/quality-tiers.md` carries the adoption gate. `spec.md` lines 50, 128, 300, 304 and 306 repeat the deferral.
- PR #879 Follow-ups item 2: "FU-823-4: extension rebuild, publish, and reinstall (remains open; consumers receive these changes only after it)."

## Logs / Screenshots

- [ ] Attached minimal logs or screenshot
- Snippet: see the quotes above. Issue #824 Addendum 2 marks FU-823-4 as "done separately, after #824 merges".

## Impact / Severity

- [ ] Blocker
- [ ] High
- [x] Medium
- [ ] Low

Medium. Consumer repositories continue to receive the pre-#824 hooks and rules, including the promotion-hook false-positive deny that #824 fixed.

## Suspected Cause / Notes

- Release automation supports patch increments only (see #522) and the publish is an operator step; the push-down serves the installed extension payload, not repository files.
- This item is the only remaining reason #824 is open.

## Proposed Fix / Validation Ideas

- [ ] Bump the extension version past 1.1.18, build, publish, and reinstall.
- [ ] Manual verification notes: run a consumer push-down and confirm `.claude/rules/quality-tiers.md` carries the adoption gate and `.claude/hooks/enforce-promotion-mcp-only.ps1` carries the structural matcher from #855.
- [ ] Close #824 once the release is verified.

## Next Step

- [ ] Promote to GitHub issue (bug-report template)
- [ ] Move to active fix folder / branch