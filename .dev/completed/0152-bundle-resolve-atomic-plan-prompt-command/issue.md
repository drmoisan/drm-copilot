# bundle-resolve-atomic-plan-prompt-command (Issue #152)

- Date captured: 2026-04-17
- Author: Dan Moisan
- Status: Promoted -> docs/features/active/bundle-resolve-atomic-plan-prompt-command/ (Issue #152)

- Issue: #152
- Issue URL: https://github.com/drmoisan/drm-copilot/issues/152
- Last Updated: 2026-04-17
- Work Mode: full-feature

## Problem / Why

The repository currently exposes `Dev: Resolve Atomic Plan Prompt` only as a VS Code task that shells out through `poetry run python scripts/dev_tools/resolve_file_prompt.py` with the repo-local `.github/prompts/generate-atomic-plan.prompt.md` template. That works inside this repository, but it does not provide the same capability in a destination workspace that only has the extension installed. The gap is that there is no bundled extension command equivalent for resolving the atomic-plan prompt from the active plan file and copying the resolved prompt to the clipboard without depending on repo-local scripts or extra setup.

## Proposed Behavior

Add a new bundled extension command that mirrors the current `Dev: Resolve Atomic Plan Prompt` task for the active plan file. The command should use bundled extension resources to resolve the atomic-plan prompt template against the active plan markdown file and copy the resolved prompt to the clipboard.

At a high level:

1. The command should resolve the currently active plan file instead of requiring a repo task or local script path.
2. The extension should bundle the required prompt template and Python wrapper/module resources so the workflow runs in destination workspaces with only the extension installed.
3. The resolved prompt should be copied to the clipboard as the primary outcome.
4. If the active editor is missing or does not point to an eligible plan markdown file, the command should stop with a clear, actionable error instead of silently succeeding.

The desired outcome is a destination-workspace command surface that matches the existing repo task behavior for atomic-plan prompt resolution while following the same bundled-command pattern already used for `resolveExecuteHardLockPrompt`.

## Acceptance Criteria (early draft)

- [x] A new bundled extension command is available for resolving the atomic-plan prompt for the active plan file without invoking `poetry`, repo-local scripts, or any workspace-local installation step
- [x] When the active editor is an eligible plan markdown file, invoking the command resolves the bundled atomic-plan prompt template against that file and copies the resolved prompt to the clipboard
- [x] The command uses bundled extension resources for the prompt template and resolver logic so the same behavior works in a destination workspace that only has the extension installed
- [x] When there is no active editor or the active file is not an eligible plan markdown file, the command fails with a clear, actionable error message
- [x] The bundled command follows the existing extension command pattern closely enough that its registration, service invocation, and bundled-resource wiring are covered by extension tests

## Constraints & Risks

- The implementation should follow the same bundled-command model as other extension-backed workflows, especially `resolveExecuteHardLockPrompt`, rather than introducing a special repo-only execution path.
- The destination workspace requirement means the command cannot depend on `.vscode/tasks.json`, `poetry`, or `scripts/dev_tools/resolve_file_prompt.py` living in the target workspace.
- The bundled prompt template and resolver behavior must stay aligned with the existing atomic-plan task semantics so users do not get different prompt output depending on whether they run the repo task or the extension command.
- Clipboard copy is part of the requested outcome, so failure handling needs to be explicit if clipboard integration is unavailable or the copy step cannot complete.
- Scope should remain limited to adding the bundled command equivalent for atomic-plan prompt resolution; broader command-surface refactors are out of scope for this entry.

## Test Conditions to Consider

- [ ] Unit coverage for command registration, active-plan-file resolution, bundled service invocation, and invalid-active-editor handling
- [ ] Integration scenarios covering the command in a destination-workspace-style environment where only extension-bundled resources are available
- [ ] Command behavior examples for a successful active plan resolution path and for the no-active-plan / invalid-active-file error path

## Next Step

- [ ] Promote to GitHub issue (feature request template)
- [ ] Create `docs/features/active/bundle-resolve-atomic-plan-prompt-command/` folder from the template