# 2026-03-14-bundle-hard-lock-resolver-into-extension — Spec

- **Issue:** #103
- **Parent (optional):** none
- **Owner:** drmoisan
- **Last Updated:** 2026-03-14T22-49
- **Status:** Draft
- **Version:** 0.1

## Overview

This feature makes execute hard-lock prompt resolution available from the VS Code extension without creating an extension-only implementation path. The design keeps `scripts/dev_tools/resolve_hard_lock_prompt.py` and the root `.github/codex/*.prompt.md` files as the canonical authoring sources, while the extension ships synchronized bundled copies using the same wrapper-plus-bundled-script pattern already used for other extension commands.

The only new behavior seam in the root Python resolver is an optional `--template-root` argument so bundled extension assets can be supplied explicitly for non-repo workspaces. All existing prompt substitution, work-mode resolution, fallback handling, and best-effort clipboard behavior stay in the Python resolver rather than moving into TypeScript or wrapper code.


## Behavior

Add a new user-facing command contribution in `extensions/drm-copilot/package.json` and a matching handler in `extensions/drm-copilot/src/extension.ts` for execute hard-lock prompt resolution. The command should follow the existing extension execution model: gather inputs in TypeScript, call `executeBundledScript(...)`, and run a thin Python wrapper from `extensions/drm-copilot/resources/templates/resolve_hard_lock_prompt.py` in the active workspace.

The TypeScript handler should resolve a target plan path using the same ergonomic pattern already used elsewhere in the extension:
- Prefer the active editor when it is a Markdown file under `docs/features/active/`.
- Otherwise open a file picker rooted under `docs/features/active/` and allow the user to choose a target plan file.
- If the user cancels selection, return early without spawning Python.

The handler should pass only the runtime inputs owned by the extension surface: `--target <selected-plan-path>` and `--workspace <workspace-root>`. It should not implement prompt resolution or template lookup itself.

The wrapper in `resources/templates/resolve_hard_lock_prompt.py` should remain adapter-only:
- prepend `extensions/drm-copilot/resources/scripts/` to `sys.path`
- compute the bundled codex root at `extensions/drm-copilot/resources/customizations/.github/codex`
- inject `--template-root <bundled-codex-root>` when the caller did not already supply it
- import `dev_tools.resolve_hard_lock_prompt`
- delegate to the bundled module's `main()` entry point in-process

The bundled Python module at `extensions/drm-copilot/resources/scripts/dev_tools/resolve_hard_lock_prompt.py` should be a synchronized import-rewritten copy of the root resolver, not a separate implementation. The root resolver must accept `--template-root` and resolve templates in this order:
1. `<template-root>/<template-name>` when `--template-root` is supplied
2. `<workspace>/.github/codex/<template-name>`
3. fail with a clear error that identifies the checked path(s)

Once a template is found, the resolver should preserve current behavior:
- normalize the selected target plan path relative to the workspace when possible
- emit forward-slash plan paths in `${plan-path}` substitutions
- resolve `${work-mode}` and `${fallback-reason}` from the nearest deterministic `issue.md`, including parent-folder lookup for versioned plan folders such as `v2`
- print the fully resolved prompt to stdout
- attempt best-effort clipboard copy without turning clipboard failure into command failure

The extension should bundle `execute-hard-lock.prompt.md` and `resume-hard-lock.prompt.md` under `extensions/drm-copilot/resources/customizations/.github/codex/` so the bundled resolver contract stays aligned with the root script's existing `--template-kind execute|resume` behavior, even though this feature only registers an execute command initially.


## Inputs / Outputs

- Inputs (CLI flags, files, env vars)
	- Extension command input:
		- active Markdown editor path under `docs/features/active/`, or
		- a file chosen from `showOpenDialog(...)` rooted under `docs/features/active/`
	- Root and bundled Python CLI flags:
		- `--target <path>`: required path to the selected plan file
		- `--workspace <path>`: optional workspace root; defaults to `Path.cwd()` when omitted
		- `--template-kind execute|resume`: existing selector, default `execute`
		- `--template-root <path>`: new optional directory containing bundled or repo-local hard-lock prompt templates
	- Files read at runtime:
		- selected target plan file passed through `--target`
		- nearest `issue.md` beside the plan file, or parent-folder `issue.md` when the target lives in a version folder like `v2`
		- root authoring sources: `scripts/dev_tools/resolve_hard_lock_prompt.py`, `.github/codex/execute-hard-lock.prompt.md`, `.github/codex/resume-hard-lock.prompt.md`
		- bundled extension copies: `extensions/drm-copilot/resources/scripts/dev_tools/resolve_hard_lock_prompt.py`, `extensions/drm-copilot/resources/customizations/.github/codex/execute-hard-lock.prompt.md`, `extensions/drm-copilot/resources/customizations/.github/codex/resume-hard-lock.prompt.md`
	- Environment/runtime dependencies:
		- Python runtime discoverable on `PATH`
		- platform clipboard mechanism discovered through `pyperclip` or validated native commands (`pbcopy`, `wl-copy`, `xclip`, `xsel`, `clip`, `clip.exe`)
- Outputs (artifacts, logs, telemetry)
	- stdout: the fully resolved prompt text suitable for copy/paste into chat
	- stderr: clipboard success/failure notice and clear runtime errors for missing target/template resources
	- VS Code output channel: command start/failure details emitted by existing extension runtime plumbing
	- Persistent artifacts: none; this command generates prompt text only and should not write feature files or cache state
	- Telemetry: none added by this feature
- Config keys and defaults:
	- `--workspace` defaults to the current working directory in Python when not supplied
	- `--template-kind` defaults to `execute`
	- `--template-root` defaults to unset; template lookup then falls back to `<workspace>/.github/codex`
	- the extension command should inject `--template-root` in the wrapper, not by expanding the public TypeScript command surface
- Versioning or backward-compatibility constraints:
	- `--template-root` must be additive and backward-compatible for existing repo-root CLI usage
	- existing `--target`, `--workspace`, and `--template-kind` behavior must remain unchanged for current callers and tests
	- no new `activationEvents` entry is required because contributed commands activate automatically for the extension's supported VS Code engine range (`^1.108.0`)

## API / CLI Surface

List commands, flags, request/response shapes, and examples.
- Extension command contribution:
	- Command ID: `drmCopilotExtension.resolveExecuteHardLockPrompt`
	- Title: `drm-copilot: Resolve Execute Hard-Lock Prompt`
	- Handler location: `extensions/drm-copilot/src/extension.ts`
	- Runtime entrypoint: `extensions/drm-copilot/resources/templates/resolve_hard_lock_prompt.py`
- Python CLI surface owned by the resolver module:
	- `--target <path>`
	- `--workspace <path>`
	- `--template-kind execute|resume`
	- `--template-root <path>`
- Request/response shape:
	- Request from TypeScript to Python: argv list passed to `executeBundledScript(...)`
	- Response from Python to the extension host: process exit code plus stdout/stderr streams
	- Success contract: exit code `0`, resolved prompt written to stdout, clipboard warning allowed on stderr
	- Failure contract: exit code `1` for missing target, missing template, or template read failure, with human-readable stderr text
- Example invocations with expected outputs (concise):
	- Extension-spawned execute flow: `python resources/templates/resolve_hard_lock_prompt.py --target C:/workspace/docs/features/active/feature-1/plan.md --workspace C:/workspace` resolves `${plan-path}` to `docs/features/active/feature-1/plan.md` and writes the completed execute prompt to stdout.
	- Repo-root CLI flow with workspace templates: `python scripts/dev_tools/resolve_hard_lock_prompt.py --target docs/features/active/feature-1/plan.md --workspace .` keeps current behavior and uses `.github/codex/execute-hard-lock.prompt.md` when `--template-root` is omitted.
	- Explicit bundled-template flow: `python scripts/dev_tools/resolve_hard_lock_prompt.py --target docs/features/active/feature-1/plan.md --workspace C:/workspace --template-root C:/extension/resources/customizations/.github/codex` resolves the same prompt without requiring repo-local codex files.
- Contracts and validation rules:
	- `--target` is required and must point to an existing file
	- `--template-kind` must remain restricted to `execute` or `resume`
	- when `--template-root` is supplied, the resolver must still fall back to workspace `.github/codex` if the requested template file is not present there
	- plan-path substitution must always emit forward slashes, including on Windows
	- wrapper code must not contain prompt business rules beyond import bootstrapping and `--template-root` injection

## Data & State

Data flow, storage, or state changes introduced by this feature.
- Data flow:
	- `extension.ts` selects the target plan file and workspace root
	- `executeBundledScript(...)` launches the wrapper in the active workspace
	- the wrapper adjusts `sys.path` and injects the bundled codex directory via `--template-root`
	- the bundled resolver reads the requested prompt template, target plan path, and nearest deterministic `issue.md`
	- `resolve_prompt(...)` substitutes `${plan-path}`, `${work-mode}`, and `${fallback-reason}` into the raw template content
	- the resolver prints the final prompt and attempts clipboard copy
- Data transformations and invariants:
	- target plan paths are made workspace-relative when possible and always converted to forward slashes before template substitution
	- work-mode resolution remains fail-closed to `full-feature` when `issue.md` is missing, unreadable, or malformed
	- root Python logic and root prompt files remain canonical authoring sources; extension resources are synchronized copies only
	- the wrapper is an adapter layer only and must not become a second logic fork
- Caching or persistence details:
	- no cache is introduced in the extension or Python resolver
	- no workspace files are created, modified, or rewritten by this command
	- clipboard writes remain best-effort and ephemeral
- Migration or backfill requirements (if any):
	- no user data migration is required
	- existing repo-root workflows continue to work unchanged because `--template-root` is optional
	- bundling requires keeping mirrored extension copies synchronized during future changes to the root resolver or root hard-lock templates

## Constraints & Risks

- The extension bundle must stay synchronized with both `scripts/dev_tools/resolve_hard_lock_prompt.py` and `.github/codex/execute-hard-lock.prompt.md`; otherwise the extension command could silently diverge from the repo workflow.
- The resolver depends on adjacent helper logic such as prompt-mode handling, so packaging must include all required bundled Python modules and template assets, not just the top-level entry point.
- Extension-side execution still depends on an available Python runtime, and clipboard behavior may vary by platform or host environment even if prompt generation succeeds.
- Path normalization and workspace-relative substitution must behave correctly for non-repo workspaces and Windows-style paths, since this feature is explicitly meant to work outside the source repository.
- The extension should bundle both hard-lock templates even though only execute is exposed initially; shipping only one template would leave the bundled resolver contract out of sync with the root script's supported `--template-kind` values.
- The TypeScript command surface must stay thin; moving prompt resolution, work-mode selection, or template interpolation into `extension.ts` would violate the single-source-of-truth requirement and increase long-term drift risk.
- Because this command is intended for arbitrary workspaces, file-selection behavior must fail clearly when no workspace is open or when the user selects a non-existent target, rather than assuming repo-relative structure is always available.


## Implementation Strategy

- Implementation scope (what changes, not sequencing):
	- Update `scripts/dev_tools/resolve_hard_lock_prompt.py` to accept `--template-root` and perform template lookup with bundled-root-first, workspace-second behavior.
	- Mirror that resolver into `extensions/drm-copilot/resources/scripts/dev_tools/resolve_hard_lock_prompt.py` using the existing bundled-script import rewrite pattern.
	- Add `extensions/drm-copilot/resources/templates/resolve_hard_lock_prompt.py` as a thin wrapper that injects the bundled codex root.
	- Bundle synchronized prompt assets under `extensions/drm-copilot/resources/customizations/.github/codex/execute-hard-lock.prompt.md` and `extensions/drm-copilot/resources/customizations/.github/codex/resume-hard-lock.prompt.md`.
	- Register a new extension command in `extensions/drm-copilot/src/extension.ts` and add its manifest entry in `extensions/drm-copilot/package.json`.
	- Add or update tests in both the root Python suite and the extension Jest suite to cover the new seam and the new command wiring.
- New classes/functions/commands to add or update:
	- Add command registration for `drmCopilotExtension.resolveExecuteHardLockPrompt` in `extensions/drm-copilot/src/extension.ts` and `extensions/drm-copilot/package.json`.
	- Add a plan-path selection helper in `extensions/drm-copilot/src/extension.ts` adjacent to the existing active-file helpers so active feature plans can be reused before opening a picker.
	- Extend the resolver CLI in `scripts/dev_tools/resolve_hard_lock_prompt.py` and the bundled mirror under `extensions/drm-copilot/resources/scripts/dev_tools/`.
	- Add the thin wrapper entrypoint in `extensions/drm-copilot/resources/templates/resolve_hard_lock_prompt.py`.
	- Add extension Jest coverage in a new test file such as `extensions/drm-copilot/test/extension.resolve-hard-lock-prompt.test.ts` and extend Python coverage in `tests/scripts/dev_tools/test_resolve_hard_lock_prompt.py`.
- Dependency changes (new/removed packages) and rationale:
	- No new runtime or dev dependency is required.
	- Reuse the existing extension-side Python execution contract, the existing bundled `prompt_mode_contract.py`, and the already-packaged `resources/**` asset behavior.
- Logging/telemetry additions and locations:
	- No new telemetry is required.
	- Continue using the extension output channel created in `extensions/drm-copilot/src/command-runtime.ts` for command-level diagnostics.
	- Continue emitting Python stderr messages for missing templates, missing targets, and clipboard outcomes so failures remain understandable when subprocess execution fails.
- Rollout plan (feature flags, staged deploys, fallback path):
	- Ship as a standard extension command with no feature flag.
	- Keep the root CLI usable outside the extension; the new flag is additive rather than a replacement.
	- Use the wrapper-injected bundled codex root for non-repo workspaces while preserving workspace `.github/codex` fallback inside the resolver.
	- Treat synchronized bundled copies as part of normal extension packaging rather than introducing a new synchronization subsystem.

## Definition of Done

- [x] Acceptance criteria in `user-story.md` are mapped to Python coverage in `tests/scripts/dev_tools/test_resolve_hard_lock_prompt.py` and extension coverage in `extensions/drm-copilot/test/extension.resolve-hard-lock-prompt.test.ts`.
- [x] Behavior is verified in both repo-like and non-repo workspaces, including a workspace that lacks `.github/codex/execute-hard-lock.prompt.md` but succeeds through bundled extension assets.
- [x] Tests are updated or added in `tests/scripts/dev_tools/test_resolve_hard_lock_prompt.py` and the extension Jest suite to cover command registration, argv wiring, template-root resolution, and bundled-template execution.
- [x] Edge cases and error handling are covered by tests for Windows-style paths, versioned feature folders, missing target files, missing Python runtime, and missing bundled template assets.
- [x] Docs are updated in `docs/features/active/2026-03-14-bundle-hard-lock-resolver-into-extension-103/` and, if the command is user-facing in the packaged extension, `extensions/drm-copilot/README.md` reflects the new command surface.
- [x] No new telemetry is introduced; existing output-channel and stderr diagnostics are preserved and verified, or any intentional logging changes are documented in the affected extension/Python files.
- [x] Final verification completes the repo-standard Python loop (`poetry run black .`, `poetry run ruff check`, `poetry run pyright`, `poetry run pytest`) and the extension loop (`npm --prefix extensions/drm-copilot run format`, `npm --prefix extensions/drm-copilot run lint`, `npm --prefix extensions/drm-copilot run typecheck`, `npm --prefix extensions/drm-copilot run test:unit`) with all steps passing in a single final pass.

## Seeded Test Conditions (from potential)
- [x] Unit-test command registration and argument wiring in `extensions/drm-copilot/src/extension.ts`, including active-editor reuse, picker fallback rooted under `docs/features/active`, the bundled wrapper path, and the `--target` / `--workspace` args passed to the Python runtime.
- [x] Unit-test the bundled wrapper contract to confirm it prepends `resources/scripts` to `sys.path`, injects `--template-root` pointing at `resources/customizations/.github/codex`, imports `dev_tools.resolve_hard_lock_prompt`, and forwards execution without reimplementing resolver logic.
- [x] Verify the bundled resolver can read the packaged `execute-hard-lock.prompt.md` template and produce resolved output when the active workspace does not contain repo-root `.github/codex` assets, while keeping `resume-hard-lock.prompt.md` bundled for contract parity.
- [x] Cover Windows-oriented path handling, including conversion to workspace-relative forward-slash plan paths in the resolved prompt content and parent `issue.md` lookup for versioned folders such as `v2`.
- [x] Cover failure paths such as missing target plan files, missing Python runtime, no open workspace, or missing bundled template resources so the command fails clearly instead of producing partial or misleading output.
