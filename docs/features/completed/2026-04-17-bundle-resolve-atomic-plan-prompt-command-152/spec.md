# bundle-resolve-atomic-plan-prompt-command — Spec

- **Issue:** #152
- **Parent (optional):** none
- **Owner:** drmoisan
- **Last Updated:** 2026-04-17T19-54
- **Status:** Draft
- **Version:** 0.1

## Overview

The repository currently exposes `Dev: Resolve Atomic Plan Prompt` only as a VS Code task that shells out through `poetry run python scripts/dev_tools/resolve_file_prompt.py` with the repo-local `.github/prompts/generate-atomic-plan.prompt.md` template. That works inside this repository, but it does not provide the same capability in a destination workspace that only has the extension installed. The gap is that there is no bundled extension command equivalent for resolving the atomic-plan prompt from the active plan file and copying the resolved prompt to the clipboard without depending on repo-local scripts or extra setup.

This feature adds a bundled extension command for the existing atomic-plan prompt workflow without changing the prompt contract or expanding the command surface beyond this one use case. The provided issue and research are sufficient to complete this spec for the scoped feature work.


## Behavior

Add a new bundled extension command that mirrors the current `Dev: Resolve Atomic Plan Prompt` task for the active plan file. The command should use bundled extension resources to resolve the atomic-plan prompt template against the active plan markdown file and copy the resolved prompt to the clipboard.

At a high level:

1. The command should resolve the currently active plan file instead of requiring a repo task or local script path.
2. The extension should bundle the required prompt template and Python wrapper/module resources so the workflow runs in destination workspaces with only the extension installed.
3. The resolved prompt should be copied to the clipboard as the primary outcome.
4. If the active editor is missing or does not point to an eligible plan markdown file, the command should stop with a clear, actionable error instead of silently succeeding.

The desired outcome is a destination-workspace command surface that matches the existing repo task behavior for atomic-plan prompt resolution while following the same bundled-command pattern already used for `resolveExecuteHardLockPrompt`.

Expected end-to-end flow:

1. The user invokes the new extension command while a feature-plan markdown file is active, or after selecting a valid plan file from the active-features area.
2. The command validates that the target is an eligible plan markdown file under `docs/features/active/**` and rejects non-plan documents such as `issue.md`, `spec.md`, and `user-story.md`.
3. The command delegates to a bundled wrapper that injects the bundled atomic-plan prompt template and runs bundled resolver logic equivalent to the current repo task.
4. The bundled resolver reads the target plan and the related feature documents used by the existing prompt contract, applies the current placeholder substitution rules, preserves minor-audit prompt rewriting, and omits optional documents when they are absent.
5. On success, the resolved prompt text is copied to the clipboard and the command reports success through the extension command surface.
6. On failure, the command stops and shows an actionable error describing the missing active plan context, invalid file selection, runtime failure, or clipboard failure.

Notable alternative paths:

- If the active editor is not a valid plan file, the command may prompt the user to pick a valid plan markdown file from `docs/features/active/`; the selected file must still pass the same validation.
- If the user cancels file selection, the command exits without copying anything and without mutating workspace state.
- If bundled runtime prerequisites cannot execute, the command fails explicitly instead of falling back to repo tasks, `poetry`, or workspace-local scripts.


## Inputs / Outputs

- Inputs (CLI flags, files, env vars)
	- Active target file: a markdown file in `docs/features/active/**` whose basename starts with `plan` (for example `plan.md` or `plan.2026-04-17T19-54.md`).
	- Bundled prompt template: `extensions/drm-copilot/resources/customizations/.github/prompts/generate-atomic-plan.prompt.md`.
	- Bundled wrapper entry point: `extensions/drm-copilot/resources/templates/resolve_atomic_plan_prompt.py`.
	- Bundled resolver module: `extensions/drm-copilot/resources/scripts/dev_tools/resolve_file_prompt.py`.
	- Resolver inputs forwarded by the command: `--target <plan-path>` and an injected bundled `--template <template-path>` value.
	- Environment/config: no new environment variables or user configuration keys are required for this feature.
- Outputs (artifacts, logs, telemetry)
	- Primary output: the fully resolved atomic-plan prompt copied to the system clipboard.
	- User feedback: a success confirmation or a clear error message surfaced through the extension command UI.
	- Logs: command/service execution diagnostics consistent with the existing repo-automation service pattern.
	- Files/artifacts: none persisted by the command itself.
- Config keys and defaults:
	- No new settings are introduced.
	- The command defaults to the active eligible plan file when available and otherwise uses validated file selection from the active feature tree.
- Versioning or backward-compatibility constraints:
	- Existing repo task behavior remains unchanged.
	- Prompt resolution semantics must remain aligned with `scripts/dev_tools/resolve_file_prompt.py` and `.github/prompts/generate-atomic-plan.prompt.md`.
	- The new command must not broaden valid targets beyond atomic-plan markdown files.

## API / CLI Surface

List commands, flags, request/response shapes, and examples.
- Command ID: `drmCopilotExtension.resolveAtomicPlanPrompt`
- VS Code contribution title: `drm-copilot: Resolve Atomic Plan Prompt`
- Service method shape: `resolveAtomicPlanPrompt({ workspaceRoot, invocationId, target })`
- Bundled Python entry point contract:
	- command invokes `resources/templates/resolve_atomic_plan_prompt.py`
	- wrapper injects bundled prompt template path when the caller does not provide one
	- wrapper forwards `--target <plan-path>` to bundled resolver logic
- Example invocations with expected outputs (concise):
	- Active valid plan file open -> invoke `drmCopilotExtension.resolveAtomicPlanPrompt` -> clipboard contains the resolved planner prompt for that plan.
	- Active invalid markdown file open -> invoke command -> user receives an error instructing them to open or select a valid plan markdown file under `docs/features/active/`.
	- No active editor, user selects valid `plan...md` file from picker -> command resolves prompt and copies it to the clipboard.
- Contracts and validation rules:
	- The command accepts plan markdown files only; `issue.md`, `spec.md`, `user-story.md`, and unrelated markdown files are invalid targets.
	- The command must use bundled resources only and must not invoke `.vscode/tasks.json`, `poetry`, or workspace-local scripts.
	- Resolver output must preserve the current variable-substitution contract, including related-document discovery and work-mode-aware prompt shaping.
	- Clipboard copy is part of the success contract; if it cannot complete, the command must report failure.

## Data & State

Data flow, storage, or state changes introduced by this feature.
- Data transformations and invariants:
	- The command reads the target plan markdown and the sibling feature documents referenced by the existing resolver contract.
	- The bundled resolver substitutes the same placeholders the current repo task supports, including `${file}`, `${folderpath}`, `${name}`, `${spec}`, `${user-story}`, `${research}`, `${work-mode}`, and `${fallback-reason}`.
	- Minor-audit mode continues to rewrite the prompt as the current resolver does; missing optional documents continue to be omitted rather than replaced with broken placeholders.
	- The target validation invariant is strict: only plan markdown files are eligible inputs.
- Caching or persistence details:
	- No new cache is introduced.
	- No workspace files are created or modified.
	- Clipboard contents are updated only on successful resolution.
- Migration or backfill requirements (if any):
	- None. This is an additive command that does not require migration of existing tasks, documents, or settings.

## Constraints & Risks

- The implementation should follow the same bundled-command model as other extension-backed workflows, especially `resolveExecuteHardLockPrompt`, rather than introducing a special repo-only execution path.
- The destination workspace requirement means the command cannot depend on `.vscode/tasks.json`, `poetry`, or `scripts/dev_tools/resolve_file_prompt.py` living in the target workspace.
- The bundled prompt template and resolver behavior must stay aligned with the existing atomic-plan task semantics so users do not get different prompt output depending on whether they run the repo task or the extension command.
- Clipboard copy is part of the requested outcome, so failure handling needs to be explicit if clipboard integration is unavailable or the copy step cannot complete.
- Scope should remain limited to adding the bundled command equivalent for atomic-plan prompt resolution; broader command-surface refactors are out of scope for this entry.
- Reusing the current generic active-feature markdown helper without tighter validation would incorrectly allow non-plan documents and would violate the feature contract.
- Duplicating prompt-resolution behavior in TypeScript would increase long-term drift risk versus the current Python-based resolver contract.


## Implementation Strategy

- Implementation scope (what changes, not sequencing):
	- Add one new bundled extension command equivalent to the existing repo task.
	- Reuse the bundled-command/service/wrapper pattern already used for `resolveExecuteHardLockPrompt`.
	- Keep prompt-resolution semantics in Python so the repo task and bundled command stay aligned.
- New classes/functions/commands to add or update:
	- `extensions/drm-copilot/package.json` -> contribute `drmCopilotExtension.resolveAtomicPlanPrompt`.
	- `extensions/drm-copilot/src/document-workflow-commands.ts` -> register the new command and delegate to the repo automation service.
	- `extensions/drm-copilot/src/extension-command-helpers.ts` -> add or parameterize a helper that accepts only eligible plan markdown files.
	- `extensions/drm-copilot/src/repo-automation-service.ts` -> add `resolveAtomicPlanPrompt(...)` using bundled script execution.
	- `extensions/drm-copilot/resources/templates/resolve_atomic_plan_prompt.py` -> add the bundled wrapper that injects the bundled prompt template path.
	- `extensions/drm-copilot/resources/scripts/dev_tools/resolve_file_prompt.py` -> bundle the canonical resolver logic used by the repo task.
	- `extensions/drm-copilot/src/extension.ts` -> wire the additional document-workflow disposable into activation.
	- `extensions/drm-copilot/test/extension.resolve-atomic-plan-prompt.test.ts` and `extensions/drm-copilot/test/repo-automation-service.test.ts` -> add command and service coverage.
- Dependency changes (new/removed packages) and rationale:
	- No new runtime or development dependencies are required.
	- The implementation should reuse the existing bundled Python/runtime infrastructure and existing prompt-mode helper already present in the extension bundle.
- Logging/telemetry additions and locations:
	- Reuse the existing repo-automation command execution diagnostics in `repo-automation-service.ts`.
	- Add user-facing error messages for invalid target selection, runtime failure, and clipboard-copy failure at the command boundary.
	- No new telemetry stream is required unless existing extension command telemetry conventions already apply to new commands in this area.
- Rollout plan (feature flags, staged deploys, fallback path):
	- Ship as an additive command with no feature flag.
	- Keep the existing repo task available as the repository-local baseline during rollout.
	- Do not add a fallback to repo-local scripts in destination workspaces; failure must remain explicit.

## Definition of Done

- [x] Acceptance criteria in `user-story.md` and `spec.md` are mapped to concrete Jest coverage or command demos
- [x] The extension command behavior matches the documented success, picker, cancellation, and invalid-target flows in both repo and destination-workspace-style scenarios
- [x] Jest tests cover command registration, active eligible-plan reuse, validated picker fallback, bundled-service invocation, and runtime failure handling
- [x] Edge cases cover no active editor, non-plan markdown targets, missing bundled runtime prerequisites, and clipboard failure reporting
- [x] Feature docs are updated in `docs/features/active/2026-04-17-bundle-resolve-atomic-plan-prompt-command-152/`, and any user-facing command documentation is updated if the command is exposed in extension docs
- [x] Existing repo-automation logging or user-facing error surfaces are updated wherever the new command introduces a new failure path
- [x] The extension toolchain completes a clean pass for formatting, linting, type-checking, and tests after implementation

## Seeded Test Conditions (from potential)
- [x] Unit coverage for command registration, active eligible-plan detection, picker-based plan selection, bundled service invocation, and invalid active editor or invalid target handling
- [x] Service-level coverage that verifies wrapper argv forwarding to `resolve_atomic_plan_prompt.py` and bundled asset path injection
- [x] Integration scenarios covering the command in a destination-workspace-style environment where only extension-bundled resources are available
- [x] Command behavior examples for a successful active plan resolution path, picker fallback after no active editor, and the invalid-active-file error path
