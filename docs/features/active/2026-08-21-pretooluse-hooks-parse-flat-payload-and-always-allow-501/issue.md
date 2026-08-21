# pretooluse-hooks-parse-flat-payload-and-always-allow (Potential Bug)

- Date captured: 2026-08-21
- Author: Dan Moisan
- Status: Promoted
- GitHub issue: #501

> Automation note: Keep the section headings below unchanged; the promotion tooling maps each of them into the GitHub bug issue template.

- Work Mode: full-bug

## Summary

Every `PreToolUse` hook reads the tool payload as `$toolInput.<property>`, but Claude Code nests it as `$toolInput.tool_input.<property>`. The property resolves to `$null`, the hooks take their "nothing to inspect" early-return, and each one emits `permissionDecision: allow`. The entire `.claude/hooks` enforcement surface therefore fails open. The Pester suites encode the same flat shape, so they pass and the defect is invisible to CI.

## Environment

- OS/version: Windows 11 Pro 10.0.26200
- Python version: n/a - hooks are PowerShell; PowerShell 7.6.5
- Command/flags used: `pwsh -NoProfile -File .claude/hooks/enforce-epic-merge-gate.ps1` with `CLAUDE_TOOL_INPUT` set to each payload shape
- Data source or fixture: observed in the destination repository `drmoisan/TaskMaster` at `b9a9b92c`; the same code is present in this repository at `.claude/hooks/enforce-epic-merge-gate.ps1:363`

## Steps to Reproduce

1. Ensure no checkpoint satisfies the gate - for example `artifacts/orchestration/orchestrator-state.json` with `epic_mode: false` and `step9_status: "verified"`, and no epic or parallel checkpoint present.
2. Invoke the hook with the shape Claude Code actually sends, setting `CLAUDE_TOOL_INPUT` to a payload whose `tool_input` object carries `command` set to `gh pr merge 999 --merge`, and run `pwsh -NoProfile -File .claude/hooks/enforce-epic-merge-gate.ps1`.
3. Invoke the same hook with the flat shape the code parses, setting `CLAUDE_TOOL_INPUT` to a payload whose root object carries `command` set to the same value.
4. Compare the two decisions.
5. Search the hook directory for the access pattern, counting per file how many times a property is read directly off the parsed payload root.

## Expected Behavior

Step 2 must deny. No checkpoint satisfies the gate, so `gh pr merge --merge` should be refused with `EPIC_MERGE_GATE_BLOCKED`. Steps 2 and 3 should produce the same decision, because they describe the same tool call.

## Actual Behavior

Step 2 allows. Step 3 denies with the correct reason. The decision logic is sound; the payload shape it reads is wrong.

`Invoke-EpicMergeGateDecision` assigns the command text from the payload root at `.claude/hooks/enforce-epic-merge-gate.ps1:363`. Against the nested payload that property is absent, so the command text is null, and the guard three lines later returns the allow decision. The gate is never reached. It cannot deny anything, for any command, under any checkpoint state.

**This is systemic, not local to one hook.** In this repository 20 of 36 hook files read a property directly off the parsed payload root, and exactly one (`enforce-epic-invocation-origin.ps1`) reads the nested shape. The affected property reads include the command, subagent type, prompt, and file path, so the defect is not confined to command-matching gates. Hooks that read the command directly off the root:

`enforce-epic-merge-gate`, `enforce-epic-worktree-removal-gate`, `enforce-parallel-abandon-gate`, `enforce-parallel-worktree-removal-gate`, `enforce-pr-author-skill`, `enforce-promotion-mcp-only`.

Hooks that read other properties off the same flat root include `enforce-parallel-cohort-barrier` and `enforce-parallel-drift-gate`, both of which read the subagent type and the prompt, so the parallel surface's own safety gates are equally inert.

**Why the tests did not catch it.** `tests/scripts/claude-hooks/enforce-epic-merge-gate.Tests.ps1` constructs the flat shape throughout. The suite validates the parser against a payload the harness never sends, so it is green and confers false confidence. The same pattern appears across the hook test suites.

**Push-down surface.** The 20 affected hooks are mirrored under `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/`. A fix that does not update the mirror is reverted in the destination repository on the next push-down.

## Logs / Screenshots

- [x] Attached minimal logs or screenshot
- Snippet - differential test, same hook, same checkpoint state, same session. Under the nested shape the hook emits a `PreToolUse` result whose `permissionDecision` is `allow` and which carries no reason. Under the flat shape the same hook emits `permissionDecision` `deny` with a reason beginning `EPIC_MERGE_GATE_BLOCKED:` and ending `No checkpoint satisfied this gate.`

- Corroborating field observation. In one TaskMaster session on 2026-08-21 the following all completed with no hook objection, each of which a working gate should have challenged:
  - four `gh pr merge --merge` invocations (PRs drmoisan/TaskMaster#575, drmoisan/TaskMaster#573, drmoisan/TaskMaster#574, drmoisan/TaskMaster#577) with no checkpoint satisfying any of the three allow-branches;
  - PR-creation and PR-body-edit paths that `enforce-pr-author-skill` is supposed to gate on a matching SHA-256 receipt - the receipt happened to exist, but was never actually demanded;
  - issue-creation paths that `enforce-promotion-mcp-only` is supposed to redirect to the MCP surface.

## Impact / Severity

- [x] Blocker
- [ ] High
- [ ] Medium
- [ ] Low

Blocker. Every deterministic safety gate in the runtime is inert wherever this payload shape is used, including the merge gate, the PR-authoring receipt gate, the promotion-path gate, the batch-budget gates, the cohort barrier, the drift gate, and the worktree-removal gates. The failure is silent and fails open, and the test suite reports green. Any workflow whose safety argument rests on a `PreToolUse` hook currently has no enforcement at all.

## Suspected Cause / Notes

- The `PreToolUse` payload contract was never captured as a single shared reader; each hook re-implements the parse inline, so the wrong shape propagated by copy.
- `enforce-epic-invocation-origin.ps1` is the sole hook reading the nested shape, which suggests the correct shape was known at least once and did not spread.
- The mirrored copies under `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/` must change with the originals or the push-down reverts the fix.
- The exact payload envelope Claude Code emits, and whether any hook event other than `PreToolUse` uses a different envelope, must be confirmed by research before the fix shape is fixed.

## Proposed Fix / Validation Ideas

- [ ] Unit coverage areas: every affected hook's payload-parse path, exercised against the nested shape; a negative test per hook proving the gate denies when it should.
- [ ] Integration scenario to retest: the differential test in Steps to Reproduce, asserting the nested and flat forms produce the same decision, or that only the nested form is honoured.
- [ ] Manual verification notes: confirm `enforce-epic-merge-gate` denies an unauthorised merge command under the payload Claude Code actually sends.
- [ ] Regression guard: a test that fails if any hook reads a payload property directly off the parsed root instead of through the shared reader.

## Next Step

- [x] Promote to GitHub issue (bug-report template) - promoted as #501
- [ ] Move to active fix folder / branch
