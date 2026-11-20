# discovery-malformed-root-grant-refuses-all-root-calls (Issue #1007)

- Date captured: 2026-10-30
- Author: Dan Moisan
- Status: Promoted -> docs/features/active/discovery-malformed-root-grant-refuses-all-root-calls/ (Issue #1007)

> Automation note: Keep the section headings below unchanged; the promotion tooling maps each of them into the GitHub bug issue template.

- Issue: #1007
- Issue URL: https://github.com/drmoisan/drm-copilot/issues/1007
- Last Updated: 2026-10-30
## Summary

The discovery root-grant consumer strictly decodes every `.json` file under the workspace `root-grants/` directory on every root call, and nothing prunes consumed or expired grants. One malformed or partially written grant file therefore refuses every root call for the workspace, including `run_discovery_doctor`.

## Environment

- OS/version: any (Windows 11 and Linux observed in review)
- Python version: n/a (TypeScript MCP server path)
- Command/flags used: any controlled discovery root call, e.g. `prepare_discovery_agent` or `run_discovery_doctor`
- Data source or fixture: a discovery workspace with a `root-grants/` directory

## Steps to Reproduce

1. Initialize a discovery workspace and issue at least one root grant through the PreToolUse hook.
2. Place a truncated or non-JSON file with a `.json` extension in `root-grants/` (simulates an interrupted write).
3. Invoke any controlled root call, including the doctor.

## Expected Behavior

The call selects and validates only the grant relevant to it. Undecodable neighbouring grants are skipped and reported. Fail-closed semantics apply to the selected grant only. Consumed or expired grants are pruned, and grant writes are atomic (write then rename).

## Actual Behavior

Every root call is refused because decoding the unrelated malformed file fails, and the condition persists until the file is removed by hand.

## Logs / Screenshots

- [ ] Attached minimal logs or screenshot
- Snippet: identified in code review `docs/features/active/2026-10-17-legacy-discovery-and-parity-980/code-review.2026-10-30T10-19.md` (Minor).

## Impact / Severity

- [ ] Blocker
- [ ] High
- [x] Medium
- [ ] Low

## Suspected Cause / Notes

`extensions/drm-copilot/src/discovery-root-grant.ts` lines 228-245 iterate and strictly decode all grant files. There is no pruning of entries past `expires_at` or already consumed. Deferred from issue #980 by user decision so the feature can merge.

## Proposed Fix / Validation Ideas

- [ ] Unit coverage areas: grant selection ignores undecodable neighbours; malformed selected grant still refuses; pruning of expired and consumed grants; atomic write via temp-name plus rename (in-memory filesystem fake, no temp files in tests).
- [ ] Integration scenario to retest: doctor succeeds with a malformed unrelated grant present.
- [ ] Manual verification notes: confirm the hook-side grant writer (PowerShell) also writes atomically.

## Next Step

- [x] Promote to GitHub issue (bug-report template)
- [ ] Move to active fix folder / branch
