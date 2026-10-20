# completion-helpers-missing-from-core-pack-manifest (Issue #984)

- Date captured: 2026-10-20
- Author: Dan Moisan
- Status: Promoted -> docs/features/active/completion-helpers-missing-from-core-pack-manifest/ (Issue #984)

> Automation note: Keep the section headings below unchanged; the promotion tooling maps each of them into the GitHub bug issue template.

- Issue: #984
- Issue URL: https://github.com/drmoisan/drm-copilot/issues/984
- Last Updated: 2026-10-20
## Summary

After a push-down, `.claude/hooks/enforce-completion-consistency.ps1` blocks every `Write` and `Edit` tool call in the target repository, including edits to files unrelated to the orchestrator checkpoint. The hook dot-sources `enforce-completion-helpers.ps1`, but the Claude core pack manifest does not list that file, so it is never pushed down. The load fails, and the hook fails closed before it checks whether the target path is one it governs.

## Environment

- OS/version: Windows 11 (downstream repository TaskMaster)
- Python version: not applicable (PowerShell 7 hook)
- Command/flags used: Claude Code `Edit` tool on `TaskMaster/TaskMaster.csproj`
- Data source or fixture: TaskMaster after harness upgrade commit `5791ee47a` ("(chore): upgrade claude harness for 1.1.19")

## Steps to Reproduce

1. Push down the core Claude customization pack (1.1.19) into a target repository that does not already contain `.claude/hooks/enforce-completion-helpers.ps1`.
2. In that repository, call `Edit` on any file (for example a `.csproj`).
3. Observe `COMPLETION_CONSISTENCY_BLOCKED: the dependency 'enforce-completion-helpers.ps1' failed to load`.

## Expected Behavior

- Every file a pushed-down hook depends on is pushed down with it.
- A hook that governs only `artifacts/orchestration/orchestrator-state.json` does not deny edits to unrelated paths.

## Actual Behavior

```
PreToolUse:Edit hook error: COMPLETION_CONSISTENCY_BLOCKED: the dependency 'enforce-completion-helpers.ps1' failed to load (The term '<repo>\.claude\hooks\enforce-completion-helpers.ps1' is not recognized as a name of a cmdlet, function, script file, or executable program.); the gate fails closed.
```

## Logs / Screenshots

- [x] Attached minimal logs or screenshot
- Snippet: see Actual Behavior.

## Impact / Severity

- [x] Blocker
- [ ] High
- [ ] Medium
- [ ] Low

No file can be changed with the `Write` or `Edit` tool in any repository that received the 1.1.19 core pack. Executor, engineer, and reviewer workflows are blocked. The only workaround is a user-approved bypass through a non-hooked route.

## Suspected Cause / Notes

Root cause (verified):

1. `extensions/drm-copilot/resources/claude-customizations/pack-manifests/core.json` lists `.claude/hooks/enforce-completion-consistency.ps1` but not `.claude/hooks/enforce-completion-helpers.ps1`. The Codex `core.json` already lists `.codex/hooks/enforce-completion-helpers.ps1`.
2. `tests/scripts/dev_tools/test_push_down_claude_pack_manifest_completeness.py` and its TypeScript twin `claude-pack-manifest-completeness.test.ts` carry `.claude/hooks/enforce-completion-helpers.ps1` as a documented pre-existing exception (with `.claude/agents/pr-author.md` and `.claude/hooks/validate-pr-author-output.ps1`) and assert that the exceptions stay absent from every manifest. The guard therefore preserved the gap.
3. `enforce-completion-consistency.ps1` dot-sources the helper and records a failure with `Add-HookDependencyFailure`. The entry point calls `Get-HookDependencyFailureDecision` and returns a deny before the checkpoint path filter (`Test-IsCheckpointPath`) runs. The hook is registered on the Write/Edit PreToolUse matcher, so one missing dependency blocks every file edit.

## Proposed Fix / Validation Ideas

- [ ] Add `.claude/hooks/enforce-completion-helpers.ps1` to the Claude `core.json`; confirm the Codex `core.json` carries its counterpart.
- [ ] Resolve the documented manifest-completeness exceptions (remove the helper exception; evaluate the other two).
- [ ] Add a pack-manifest dependency-closure test: for every manifested hook, parse dot-source and `Import-Module` targets built from `$PSScriptRoot` and assert each resolved file is in the same manifest.
- [ ] In `enforce-completion-consistency.ps1`, decide path scope before the dependency-failure decision: allow paths other than the checkpoint regardless of dependency state; keep failing closed for `artifacts/orchestration/orchestrator-state.json`. Review other path-scoped hooks that use `Get-HookDependencyFailureDecision`.
- [ ] Release notes for the next harness version tell downstream repositories that received 1.1.19 to re-run push-down.

## Acceptance Criteria

- [ ] `core.json` includes `.claude/hooks/enforce-completion-helpers.ps1`, and a fresh push-down into a clean target puts the file in place.
- [ ] A manifest completeness test fails if any manifested hook depends on a sibling or lib file that is missing from the manifest.
- [ ] With the helper deliberately removed, an `Edit` of a path other than the checkpoint is allowed, and an `Edit` of `artifacts/orchestration/orchestrator-state.json` is still denied with `COMPLETION_CONSISTENCY_BLOCKED`.
- [ ] Release notes for the next harness version tell downstream repositories that received 1.1.19 to re-run push-down.

## Next Step

- [ ] Promote to GitHub issue (bug-report template)
- [ ] Move to active fix folder / branch

Evidence: downstream repository TaskMaster, harness upgrade commit `5791ee47a` (1.1.19). Surfaced while fixing TaskMaster PR #999 on 2026-10-20; that edit was made through a one-time user-approved bypass.
