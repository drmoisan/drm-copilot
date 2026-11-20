# handoff-failure-cause-fallback-and-name-gaps (Issue #844)

- Date captured: 2026-10-08
- Author: Dan Moisan
- Status: Promoted -> docs/features/active/handoff-failure-cause-fallback-and-name-gaps/ (Issue #844)

> Automation note: Keep the section headings below unchanged; the promotion tooling maps each of them into the GitHub bug issue template.

- Issue: #844
- Issue URL: https://github.com/drmoisan/drm-copilot/issues/844
- Last Updated: 2026-10-08
## Summary

#645 (PR merged in the bug-burndown-2026-09-29 parallel run) attached a `failureCause` to blocked handoff results that follow a caught error. Its policy audit recorded three non-blocking gaps: three pre-existing catch sites outside the spec's scope still return a blocked result with no cause on their fallback arm (NB-2); `describeHandoffFailureCause` uses `error.name` without checking it against a pattern (NB-3); and the spec's AC-8 names a single test file while the cases are split across two (NB-1).

## Environment

- OS/version: any
- Python version: n/a (TypeScript, `extensions/drm-copilot`)
- Command/flags used: the MCP orchestration handoff materializer and authority service; `npm --prefix extensions/drm-copilot run test:unit -- test/lib/validate/orchestration-handoff-failure-cause.test.ts test/lib/validate/orchestration-handoff-failure-cause-authority.test.ts`
- Data source or fixture: origin/main at fb413fce; `docs/features/active/2026-09-07-portable-handoff-614-review-follow-ups-645/policy-audit.2026-10-07T22-49.md` lines 436-438

## Steps to Reproduce

1. NB-2: read `extensions/drm-copilot/src/lib/validate/orchestration-handoff-authority-service.ts:148-157`. A non-`HandoffContractError` thrown by `parseHandoffEnvelopeText` returns `blocked(request, "HANDOFF_UNSUPPORTED_VERSION")` with no cause.
2. NB-2: read `orchestration-handoff-materializer.ts:282-293`. A projection error without a `code` returns `blockedResult(..., "HANDOFF_VALIDATOR_UNAVAILABLE", {...})` with no `failureCause`.
3. NB-2: read `orchestration-handoff-materializer-production.ts:33-43`. A non-`HandoffContractError` from envelope validation yields `primaryFailureCode: "HANDOFF_UNSUPPORTED_VERSION"` and the caught error is dropped; the result surfaces at `orchestration-handoff-materializer.ts:189-201` with no cause.
4. NB-3: read `orchestration-handoff-materializer-request.ts:32-46`. The `code` property is checked against `HANDOFF_ERROR_CODE_PATTERN` (line 38), but for any `Error` the function returns `${stage}: ${error.name}` (lines 42-43) with no pattern check.
5. NB-1: compare spec AC-8 (`spec.md:189` in the #645 folder), which names only `test/lib/validate/orchestration-handoff-failure-cause.test.ts`, with the test tree: the authority cases are in `orchestration-handoff-failure-cause-authority.test.ts`.

## Expected Behavior

- Every blocked handoff result that follows a caught error carries a `failureCause` (US-1 wording), including the non-`HandoffContractError` fallback arms, for example `envelope-parse: <token>` and `destination-projection: <token>`.
- `error.name` is used as the cause token only when it matches an identifier pattern; otherwise the token is `Error`. A test row covers a custom error class with an arbitrary `name`.
- AC-8 names both test files.

## Actual Behavior

- The three fallback arms listed in Steps 1-3 return blocked results without `failureCause`. These sites were already bound (`catch (error: unknown)`) before #645, so they were outside its 15-bare-site scope and the AC-8 enumeration.
- A custom `Error` subclass can set an arbitrary `name`, which is copied into the cause string unvalidated. Built-in names and Node system errors are not affected.
- AC-8 text and the delivered file layout differ. The split followed the plan's pre-approved overflow branch (P5-T11/P5-T12; `evidence/other/authority-test-placement.2026-10-07T22-20.md`) because a single file would have been 608 lines, above the 500-line limit.

All three were verified by reading the cited lines on main at fb413fce; no runtime reproduction was performed.

## Logs / Screenshots

- [ ] Attached minimal logs or screenshot
- Snippet: `orchestration-handoff-materializer-request.ts:42-44`:
  ```ts
  if (error instanceof Error) {
    return `${stage}: ${error.name}`;
  }
  ```

## Impact / Severity

- [ ] Blocker
- [ ] High
- [ ] Medium
- [x] Low

Diagnostics only. An operator receiving one of the three fallback results has no cause to act on, and an unvalidated `name` can place arbitrary text in the cause field. No handoff outcome changes.

## Suspected Cause / Notes

- Originating item: #645 (bug-burndown-2026-09-29 parallel run). Source: policy audit NB-1, NB-2, NB-3 (`policy-audit.2026-10-07T22-49.md:436-438`); the audit states "NB-1 through NB-3 are suitable for a follow-up issue" (line 557). NB-4 through NB-8 are informational and not included.
- No open issue covers these gaps (checked `gh issue list --state open` on 2026-10-08).

## Proposed Fix / Validation Ideas

- [ ] Unit coverage areas: one case per fallback arm asserting a stage-prefixed `failureCause`; one `describeHandoffFailureCause` row for a custom `Error` whose `name` contains non-identifier characters.
- [ ] Integration scenario to retest: none required beyond the MCP handler tests in `test/mcp-handlers/orchestration-handoff-handlers.test.ts`.
- [ ] Manual verification notes: amend AC-8 in the #645 `spec.md` (or its completed-folder copy) to name both test files. `orchestration-handoff-contract.ts` is at 497 lines and `orchestration-handoff-materializer.ts` at 488, so changes there need line-budget planning.

## Next Step

- [ ] Promote to GitHub issue (bug-report template)
- [ ] Move to active fix folder / branch
