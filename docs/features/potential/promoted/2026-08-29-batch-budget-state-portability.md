# batch-budget-state-portability (Issue #596)

- Date captured: 2026-08-29
- Author: Dan Moisan
- Status: Promoted -> docs/features/active/batch-budget-state-portability/ (Issue #596)

> Automation note: Keep the section headings below unchanged; the promotion tooling maps each of them into the GitHub bug issue template.

- Issue: #596
- Issue URL: https://github.com/drmoisan/drm-copilot/issues/596
- Last Updated: 2026-08-29
## Summary

The batch-budget PreToolUse hooks keep session state that is neither session-scoped nor
worktree-scoped, and the push-down mechanism that publishes the `.claude/**` payload into a consumer
repository has no destination-side `.gitignore` writer at all, so the runtime-created state file
becomes a tracked file in the consumer repository.

This is Feature B (wave 0) of the `claude-runtime-portability` epic
(`docs/features/epics/claude-runtime-portability/epic.md`).

## Environment

- OS/version: Windows 11 Pro 10.0.26200; PowerShell 7 (`pwsh`)
- Python version: not applicable — the affected hooks are PowerShell, and the push-down code is TypeScript
- Command/flags used: the PreToolUse hook invocations of `.claude/hooks/enforce-powershell-batch-budget.ps1` and `.claude/hooks/enforce-python-batch-budget.ps1`; the extension's push-down command
- Data source or fixture: `.claude/state/powershell-batch-budget.<SessionId>.json` (runtime-created; the directory is git-ignored at `.gitignore:68` and does not exist in a fresh checkout)

## Steps to Reproduce

1. Run any agent session in which `$env:CLAUDE_SESSION_ID` is not set, and let the PowerShell
   batch-budget hook record at least one file. The hook writes
   `.claude/state/powershell-batch-budget.default.json`.
2. Start a second, unrelated session that also has no resolved session id. It reads and increments
   the same `default` counter rather than starting a fresh one, and the budget denies work that the
   second session never performed. Nothing resets the counter: the hook has no TTL and no timestamp
   check, and its own deny message instructs the operator to delete the file by hand.
3. From a second git worktree of the same repository, let the hook record a file. The recorded path
   is the raw `file_path` string from the tool payload, so a path belonging to a different worktree
   is counted against the current worktree's budget.
4. Push the `.claude/**` payload down into a consumer repository. No `.gitignore` entry for
   `.claude/state/` is written at the destination, so the runtime-created state file is untracked
   only until someone stages it, and a fresh clone of the consumer repository can carry a tracked
   batch-budget session-state file.

## Expected Behavior

- A session without a resolved session id gets a counter that is distinct per session, or the state
  is reset on a defined condition rather than never.
- Recorded paths are canonicalized and constrained to the current worktree root, so a path from
  another worktree is discarded rather than counted.
- A push-down delivers whatever destination-side ignore configuration the payload requires, so a
  consumer repository never tracks runtime session state. The delivery is idempotent across repeat
  push-downs.

## Actual Behavior

Verified against the current tree at commit `c861ddff`:

- `.claude/hooks/enforce-powershell-batch-budget.ps1:157` declares `[string] $SessionId = 'default'`
  as the parameter default, and lines 248-250 in the entry point assign `$sessionId = 'default'`
  when `$env:CLAUDE_SESSION_ID` is unset. Line 193 composes the state path as
  `powershell-batch-budget.$SessionId.json`. Every session without a resolved session id therefore
  shares one counter.
- `.claude/hooks/enforce-python-batch-budget.ps1` has the identical defect at lines 154, 190, and
  245-247, so the sibling hook is in scope.
- Recorded paths are normalized only by `-replace '\\', '/'` at
  `.claude/hooks/enforce-powershell-batch-budget.ps1:122` and `:183`. There is no `Resolve-Path`,
  no canonicalization, and no check that a recorded path falls under the current worktree root.
- No destination-side `.gitignore` writer exists anywhere in the push-down pipeline.
  `pushDownClaudeCustomizationsServiceCall`
  (`extensions/drm-copilot/src/lib/push-down/push-down-service-call.ts:166`) copies from the
  pre-built bundle root, and `enumerateSourceFiles`
  (`extensions/drm-copilot/src/lib/push-down/copilot-customizations-engine.ts:156`) walks the two
  root folders `.claude` and `config`, excluding only `.claude/settings.local.json`. A repository
  search for `gitignore` under `extensions/drm-copilot/src/` returns exactly one match, an unrelated
  comment in `render-pr-helpers.ts:422`.

Note on scope correction: the originating intake framed the fourth item as a missing `.gitignore`
line. It is larger than that. There is no writer to add the line to, so the fix is net-new
TypeScript capability in the extension.

## Logs / Screenshots

- [ ] Attached minimal logs or screenshot
- Snippet: not applicable. The evidence is the static citations enumerated under Actual Behavior;
  no failing run is required to observe them.

## Impact / Severity

- [ ] Blocker
- [x] High
- [ ] Medium
- [ ] Low

The shared counter denies legitimate work in a session that did not perform it, and the missing
destination ignore entry lets a consumer repository track runtime state, which poisons a fresh
checkout.

## Suspected Cause / Notes

The `'default'` fallback was chosen so the hook has a usable path when the session id is absent,
but it makes the absent-id case collapse to one shared identity instead of separating sessions. The
push-down pipeline was designed to copy a payload, and the destination-side ignore obligation was
never part of that payload contract.

Cross-cutting constraint for any fix:
`tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py::test_bundled_claude_payload_contains_all_repo_runtime_contracts`
asserts every repository `.claude/**` file — excluding `settings.local.json` and the
`.claude/agent-memory/**` subtree — is byte-identical to its copy under
`extensions/drm-copilot/resources/claude-customizations/.claude/**`. Every `.claude/**` edit must be
mirrored into the bundle copy in the same change.

## Proposed Fix / Validation Ideas

- [ ] Unit coverage areas: session-id resolution and state-path composition in both hooks; recorded-path canonicalization and worktree-root containment; the new destination-side ignore writer in the push-down engine, including its idempotency on repeat push-downs.
- [ ] Integration scenario to retest: a push-down into a scratch destination, run twice, asserting the destination ignore configuration is present and unchanged by the second run.
- [ ] Manual verification notes: confirm the bundle mirror stays byte-identical by running the push-down resource-contract test named above.

## Next Step

- [ ] Promote to GitHub issue (bug-report template)
- [ ] Move to active fix folder / branch
