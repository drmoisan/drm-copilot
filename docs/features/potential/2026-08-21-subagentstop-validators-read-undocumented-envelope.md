# subagentstop-validators-read-undocumented-envelope (Potential Bug)

- Date captured: 2026-08-21
- Author: Dan Moisan
- Status: Draft
- Related: #501 (PreToolUse hooks parse a flat payload and always allow)

> Automation note: Keep the section headings below unchanged; the promotion tooling maps each of them into the GitHub bug issue template.

## Summary

The eight `SubagentStop` validators read `$env:CLAUDE_HOOK_INPUT` and take an `output` property off the parsed root. The documented `SubagentStop` envelope arrives on stdin and exposes `last_assistant_message`, not `output`, and the documented hook environment does not include `CLAUDE_HOOK_INPUT`. These validators are therefore very likely inert for the same two reasons #501 established for the `PreToolUse` surface: wrong transport beneath wrong shape.

This entry was raised by the #501 investigation and deliberately scoped out of that fix, whose acceptance criterion AC-13 asserts these files are absent from its diff. It is recorded separately so the boundary stays honest and the defect is not lost.

## Environment

- OS/version: Windows 11 Pro 10.0.26200
- Python version: n/a - validators are PowerShell; PowerShell 7.6.5
- Command/flags used: `pwsh -NoProfile -File .claude/hooks/validate-orchestrator-output.ps1` with the payload supplied on each transport
- Data source or fixture: `.claude/settings.json` `SubagentStop` registrations at commit `c76a2990`

## Steps to Reproduce

1. Pick any of the eight validators, for example `.claude/hooks/validate-orchestrator-output.ps1`.
2. Invoke it with the documented envelope supplied on stdin, whose root carries `hook_event_name` set to the SubagentStop event and `last_assistant_message` set to text lacking any required completion-artifact path.
3. Invoke it again with the shape the code parses: the `CLAUDE_HOOK_INPUT` environment variable set to a root object carrying `output`.
4. Compare the two decisions.
5. Search the hook directory for the access pattern to enumerate every validator reading `output` off the parsed root.

## Expected Behavior

Step 2 must block. A subagent that stops without the required completion-artifact path should be refused, and steps 2 and 3 should agree because they describe the same event.

## Actual Behavior

Expected, not yet measured: step 2 passes because the property resolves to null and the validator takes its nothing-to-inspect path, while step 3 blocks correctly. The claim is inference from the verified `PreToolUse` result plus the documented envelope, not an observed run. Confirming it is the first task of this fix.

An additional defect is likely present and should be checked at the same time: the inline `SubagentStop` command registered in `.claude/settings.json` uses `Write-Error` followed by `exit 1`. Per the documented semantics, exit 1 is non-blocking; only exit 2 blocks. That command would therefore fail open even with the correct transport and shape.

Affected validators:

`validate-discovery-artifact-gate.ps1`, `validate-executor-output.ps1`, `validate-feature-review-coverage.ps1`, `validate-orchestrator-output.ps1`, `validate-planner-output.ps1`, `validate-pr-author-output.ps1`, `validate-required-artifact-output.ps1`, `validate-task-researcher-output.ps1`.

Two of these — `validate-discovery-artifact-gate.Tests.ps1` and `validate-pr-author-output.Tests.ps1` — also carry the `$LASTEXITCODE | Should -Be 1` assertion that #501 inverted for the `PreToolUse` suites, so their exit-code contract needs the same review.

## Logs / Screenshots

- [ ] Attached minimal logs or screenshot
- Snippet: not yet captured. Capture the differential described in Steps to Reproduce before promoting.

## Impact / Severity

- [ ] Blocker
- [x] High
- [ ] Medium
- [ ] Low

High. These validators are completion gates rather than pre-execution gates, so an inert validator does not permit a dangerous action; it permits an agent to report completion without the artifact that proves it. `validate-orchestrator-output.ps1` is the gate that refuses a DONE lacking model-routing receipts or carrying an unresolved human-interaction requirement. While it is inert, an orchestrator's completion claim is self-attested.

Severity is High rather than Blocker because the failure mode is unverified work being accepted, not unsafe work being executed.

## Suspected Cause / Notes

- Same root cause as #501: the hook payload contract was never captured in one shared reader, so each validator re-implements the parse and the wrong shape propagated by copy.
- `.claude/lib/hook-payload/HookPayload.psm1`, delivered by #501, was written for reuse. It handles stdin-first transport with environment fallback and the redirect guard. A `SubagentStop` reader should extend it rather than duplicate it.
- The `PreToolUse` migration also established the entry-point seam pattern that lets a test assert a process exit code without spawning a child. The same seam applies here and is needed for the exit-1-versus-exit-2 correction.

## Proposed Fix / Validation Ideas

- [ ] Confirm the defect by differential run before changing anything; do not assume the #501 result transfers without measurement.
- [ ] Extend `HookPayload.psm1` with a `SubagentStop` envelope reader rather than writing a second implementation.
- [ ] Unit coverage areas: each validator's payload-parse path against the documented envelope, plus a negative test per validator proving it blocks when it should.
- [ ] Correct the exit-code contract: exit 2 or an emitted block decision, never exit 1, including the inline command in `.claude/settings.json`.
- [ ] Extend the `#501` regression guard so it also covers the `SubagentStop` set, rather than leaving that surface unguarded.
- [ ] Mirror every change under `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/`; byte parity is enforced by `test_bundled_claude_payload_contains_all_repo_runtime_contracts`.

## Next Step

- [ ] Promote to GitHub issue (bug-report template)
- [ ] Move to active fix folder / branch
