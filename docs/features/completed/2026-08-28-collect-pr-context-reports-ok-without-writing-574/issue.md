# collect-pr-context-reports-ok-without-writing (Issue #574)

- Date captured: 2026-08-28
- Author: Dan Moisan
- Status: Promoted -> docs/features/active/collect-pr-context-reports-ok-without-writing/ (Issue #574)

> Automation note: Keep the section headings below unchanged; the promotion tooling maps each of them into the GitHub bug issue template.

- Issue: #574
- Issue URL: https://github.com/drmoisan/drm-copilot/issues/574
- Last Updated: 2026-08-28
- Work Mode: full-bug

## Summary

The `collect_pr_context` MCP tool can report `ok: true` without writing its context artifacts, and because earlier artifacts persist at the same paths, a stale file satisfies any existence check. Consumers (pr-author, review workflows) can then build a PR body or review from a previous invocation's context without any error surfacing.

## Environment

- OS/version: Windows 11 Pro 10.0.26200
- Python version: n/a (MCP server tool)
- Command/flags used: `mcp__drm-copilot__collect_pr_context` invoked by orchestrator/pr-author flows
- Data source or fixture: observed repeatedly during the parallel run `critical-bug-fixes` (completed 2026-08-26); recorded in that run's checkpoint receipts

## Steps to Reproduce

1. Invoke `collect_pr_context` once successfully; context artifacts are written.
2. Invoke it again under a condition where it fails to write (observed during the run; exact trigger not isolated — candidates include a base-branch resolution failure or a silent internal error).
3. The tool returns `ok: true`; the artifact paths still hold the previous invocation's content; downstream existence checks pass.

## Expected Behavior

`ok: true` if and only if the context artifacts for THIS invocation were written. Any failure to write returns an error. Additionally, artifacts should be verifiable as fresh (for example, an embedded invocation timestamp or head SHA the consumer can cross-check), so a stale file cannot masquerade as current.

## Actual Behavior

`ok: true` was returned with no write performed. The stale prior artifact satisfied the existence check, so the failure was only detected when content did not match the branch under review. This recurred across multiple items in the run and was worked around by consumers re-verifying artifact content against `git log`/`gh pr view` before use.

## Logs / Screenshots

- [ ] Attached minimal logs or screenshot
- Snippet: recorded in `artifacts/orchestration/parallel-orchestrator-state.json` receipts of the critical-bug-fixes run (infrastructure-findings notes).

## Impact / Severity

- [ ] Blocker
- [x] High
- [ ] Medium
- [ ] Low

A PR body or review generated from stale context misdescribes the diff it accompanies. The failure is silent and survives existence checks, so it propagates into outward-facing artifacts.

## Suspected Cause / Notes

Not yet isolated; the tool appears to treat some internal failure paths as success. The stale-file hazard is independent of the root cause: even after the success-reporting bug is fixed, artifacts without freshness markers remain unverifiable. Note the exact reproduction trigger needs isolation during research — the run's receipts record the observations but not a minimal trigger.

## Proposed Fix / Validation Ideas

- [ ] Unit coverage: failure-to-write paths return an error, never `ok: true`.
- [ ] Freshness marker (timestamp + head SHA) embedded in artifacts; consumer-side cross-check documented in `pr-context-artifacts` skill.
- [ ] Integration scenario: invoke against a branch where write fails; assert error surfaces and stale artifact is not consumed.

## Next Step

- [x] Promote to GitHub issue (bug-report template)
- [ ] Move to active fix folder / branch
