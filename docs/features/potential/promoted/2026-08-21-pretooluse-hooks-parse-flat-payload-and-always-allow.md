# pretooluse-hooks-parse-flat-payload-and-always-allow (Issue #501)

- Date captured: 2026-08-21
- Author: Dan Moisan
- Status: Resolved -> docs/features/active/2026-08-21-pretooluse-hooks-parse-flat-payload-and-always-allow-501/ (Issue #501, closed by PR #504)

> Automation note: Keep the section headings below unchanged; the promotion tooling maps each of them into the GitHub bug issue template.

- Issue: #501
- Issue URL: https://github.com/drmoisan/drm-copilot/issues/501
- Origin: reported first in drmoisan/TaskMaster as issue #579; this record is the drm-copilot lifecycle entry
- Last Updated: 2026-08-22
## Summary

Every `PreToolUse` hook reads the tool payload as `$toolInput.command`, but Claude Code nests it as `$toolInput.tool_input.command`. The property resolves to `$null`, the hooks take their "nothing to inspect" early-return, and each one emits `permissionDecision: allow`. The entire `.claude/hooks` enforcement surface therefore fails open. The Pester suites encode the same flat shape, so they pass and the defect is invisible to CI.

## Environment

- OS/version: Windows 11 Pro 10.0.26200
- Python version: n/a — hooks are PowerShell; PowerShell 7.6.5
- Command/flags used: `pwsh -NoProfile -File .claude/hooks/enforce-epic-merge-gate.ps1` with `CLAUDE_TOOL_INPUT` set to each payload shape
- Data source or fixture: observed in the destination repository `drmoisan/TaskMaster` at `b9a9b92c`; the same code is present in this repository at `.claude/hooks/enforce-epic-merge-gate.ps1:363`

## Steps to Reproduce

1. Ensure no checkpoint satisfies the gate — for example `artifacts/orchestration/orchestrator-state.json` with `epic_mode: false` and `step9_status: "verified"`, and no epic or parallel checkpoint present.
2. Invoke the hook with the shape Claude Code actually sends:
   `CLAUDE_TOOL_INPUT='{"tool_name":"Bash","tool_input":{"command":"gh pr merge 999 --merge"}}' pwsh -NoProfile -File .claude/hooks/enforce-epic-merge-gate.ps1`
3. Invoke the same hook with the flat shape the code parses:
   `CLAUDE_TOOL_INPUT='{"command":"gh pr merge 999 --merge"}' pwsh -NoProfile -File .claude/hooks/enforce-epic-merge-gate.ps1`
4. Compare the two decisions.
5. Grep the hook directory for the access pattern: `grep -c '$toolInput.command' .claude/hooks/*.ps1`.

## Expected Behavior

Step 2 must deny. No checkpoint satisfies the gate, so `gh pr merge --merge` should be refused with `EPIC_MERGE_GATE_BLOCKED`. Steps 2 and 3 should produce the same decision, because they describe the same tool call.

## Actual Behavior

Step 2 allows. Step 3 denies with the correct reason. The decision logic is sound; the payload shape it reads is wrong.

`Invoke-EpicMergeGateDecision` does `$commandText = $toolInput.command` (`.claude/hooks/enforce-epic-merge-gate.ps1:363`). Against the nested payload that property is absent, so `$commandText` is `$null`, and the guard three lines later returns the allow decision:

```powershell
$commandText = $toolInput.command
if (-not $commandText) {
    return Get-EpicMergeGateAllowDecision
}
```

The gate is never reached. It cannot deny anything, for any command, under any checkpoint state.

**This is systemic, not local to one hook.** 24 of 36 hook files read `$env:CLAUDE_TOOL_INPUT`, and a scan for the access pattern finds the flat form in at least 19 of them and the nested form in **zero**:

`check-powershell-test-purity`, `check-python-test-purity`, `enforce-checkpoint-monotonic`, `enforce-completion-consistency`, `enforce-discovery-artifact-gate`, `enforce-epic-merge-gate`, `enforce-epic-wave-barrier`, `enforce-epic-worktree-removal-gate`, `enforce-evidence-locations`, `enforce-feature-folder-order`, `enforce-parallel-abandon-gate`, `enforce-parallel-cohort-barrier`, `enforce-parallel-drift-gate`, `enforce-parallel-worktree-removal-gate`, `enforce-powershell-batch-budget`, `enforce-pr-author-skill`, `enforce-prd-feature-before-planner`, `enforce-promotion-mcp-only`, `enforce-python-batch-budget`.

**Why the tests did not catch it.** `tests/scripts/claude-hooks/enforce-epic-merge-gate.Tests.ps1` constructs the flat shape throughout — `'{"command":"git status"}'`, `'{"command":"gh pr merge 10 --squash"}'`, `'{"command":"gh pr merge --merge"}'`. The suite validates the parser against a payload the harness never sends, so it is green and confers false confidence. The same pattern appears across the hook test suites.

## Logs / Screenshots

- [x] Attached minimal logs or screenshot
- Snippet — differential test, same hook, same checkpoint state, same session:

  ```text
  === nested shape (what Claude Code sends) ===
  {"hookSpecificOutput":{"hookEventName":"PreToolUse","permissionDecision":"allow"}}

  === FLAT shape (what the hook actually parses) ===
  {"hookSpecificOutput":{"hookEventName":"PreToolUse","permissionDecision":"deny",
   "permissionDecisionReason":"EPIC_MERGE_GATE_BLOCKED: gh pr merge --merge requires either a
   per-feature checkpoint with epic_mode == true and step9_status == \"passed\", ... No checkpoint
   satisfied this gate."}}
  ```

- Corroborating field observation. In one TaskMaster session on 2026-08-21 the following all completed with no hook objection, each of which a working gate should have challenged:
  - four `gh pr merge --merge` invocations (PRs #575, #573, #574, #577) with no checkpoint satisfying any of the three allow-branches;
  - `gh pr create --body-file` / `gh pr edit --body-file`, which `enforce-pr-author-skill` is supposed to gate on a matching SHA-256 receipt — the receipt happened to exist, but was never actually demanded;
  - `gh issue create` paths that `enforce-promotion-mcp-only` is supposed to redirect to the MCP surface.

## Impact / Severity

- [x] Blocker
- [ ] High
- [ ] Medium
- [ ] Low

Blocker. Every deterministic safety gate in the runtime is inert wherever this payload shape is used, including the merge gate, the PR-authoring receipt gate, the promotion-path gate, the batch-budget gates, the cohort barrier, the drift gate, and the worktree-removal gates. The failure is silent and fails open, and the test suite reports green. Any workflow whose safety argument rests on a `PreToolUse` hook currently has no enforcement at all.

## Suspected Cause / Notes

- The payload contract is `{ "tool_name": "...", "tool_input": { ... } }`. The command text is at `tool_input.command`; a `Write`/`Edit` path is at `tool_input.file_path`.
- Extraction should be centralised rather than repeated in 19+ files. A single shared helper — for example `Get-HookToolInput` in `.claude/lib/` returning the inner `tool_input` object — would fix every hook in one place and prevent recurrence.
- Prefer tolerant extraction during migration: read `tool_input.command` and fall back to `.command`, so a hook works under either shape while callers are updated.
- A second, independent question is worth settling in the same change: whether Claude Code supplies the payload via the `CLAUDE_TOOL_INPUT` environment variable at all, or on **stdin**. All 24 hooks read the environment variable, and only `persist-session-id.ps1` reads stdin. This was not verified from inside the session and is not part of the reproduction above, but if the harness uses stdin then the env-var read is a second fail-open on the same surface.

## Proposed Fix / Validation Ideas

- [x] Unit coverage areas — for every hook, a paired test asserting the SAME decision for the nested and the flat payload. The existing flat-only cases must be kept and a nested twin added; a nested case alone would simply relocate the blind spot.
- [x] Integration scenario to retest — an end-to-end check that a real `gh pr merge --merge` is denied with no satisfying checkpoint. The differential test above is the minimal form.
- [x] Manual verification notes — after the fix, confirm the gates still ALLOW correctly: a satisfying checkpoint must permit the merge, and out-of-scope commands such as `git status` and `gh pr merge 10 --squash` must remain allowed. A fix that denies everything is worse than the defect.

## Next Step

- [x] Promote to GitHub issue (bug-report template)
- [ ] Move to active fix folder / branch
