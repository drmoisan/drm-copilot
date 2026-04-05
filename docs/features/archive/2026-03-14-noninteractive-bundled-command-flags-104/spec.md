# 2026-03-14-noninteractive-bundled-command-flags — Spec

- **Issue:** #104
- **Parent (optional):** none
- **Owner:** drmoisan
- **Last Updated:** 2026-03-14T22-59
- **Status:** Draft
- **Version:** 0.1

## Overview

This feature extends the existing bundled workflow commands in `extensions/drm-copilot` so the same public command IDs support both interactive human use and strict non-interactive invocation with explicit flags. The implementation keeps the current Command Palette prompt flow as the zero-argument default while allowing orchestrators and other automation to pass required inputs up front and skip all UI collection.

The provided `issue.md` and implementation research are sufficient to complete this specification. Scope is limited to the existing four live workflow commands, their bundled script argument forwarding, the workspace/bundled contract alignment for `new-potential-entry.ps1`, and the orchestrator agent resources that must switch from raw script calls to extension-command direct invocation.


## Behavior

Each of the four existing workflow handlers in `extensions/drm-copilot/src/extension.ts` must support two invocation modes under the same command ID:

1. **Interactive fallback mode** when no invocation arguments are supplied.
	- Preserve the current `showInputBox`, `showQuickPick`, and `showOpenDialog` flows.
	- Preserve current cancel behavior: if the user dismisses a prompt, the command returns without launching the bundled script.
	- Preserve the current bundled script targets and current command contributions in `extensions/drm-copilot/package.json`.
2. **Strict non-interactive mode** when any invocation arguments are supplied.
	- Treat the incoming command arguments as a CLI-style flag array.
	- Validate all provided flags before any UI call is attempted.
	- Skip all UI entirely in this mode.
	- Fail fast on unknown flags, duplicate flags, missing required values, or invalid values.
	- Forward only validated arguments to the existing bundled script entrypoints via `executeBundledScript` in `extensions/drm-copilot/src/command-runtime.ts`.

Per workflow, the end-to-end behavior is:

1. **`drmCopilotExtension.newPotentialEntry`**
	- Interactive mode keeps prompting for the kebab-case short name.
	- Direct mode requires `-ShortName <value>`.
	- The extension appends `-TemplateRoot <bundled feature-templates path>` internally before invoking `resources/templates/new-potential-entry.ps1`.
2. **`drmCopilotExtension.newPotentialBugEntry`**
	- Interactive mode keeps prompting for the kebab-case short name.
	- Direct mode requires `--short-name <value>`.
	- The extension appends `--template-root <bundled feature-templates path>` internally before invoking `resources/templates/new_potential_bug_entry.py`.
3. **`drmCopilotExtension.potentialToIssue`**
	- Interactive mode keeps the current active-editor auto-detect / file picker behavior plus promotion-type and work-mode quick picks.
	- Direct mode requires `--potential-path <path> --promotion-type <epic|feature|refactor|bug> --work-mode <minor-audit|full-feature|full-bug|full>`.
	- In direct mode, the extension does not attempt active-editor resolution or file-dialog fallback.
4. **`drmCopilotExtension.newActiveFeatureFolder`**
	- Interactive mode keeps the current quick-pick / input-box flow for type, feature name, optional issue number, and work mode.
	- Direct mode requires `--feature-name <value> --type <epic|feature|refactor|bug> --work-mode <minor-audit|full-feature|full-bug|full>` and accepts optional `--issue-number <digits>`.
	- The extension appends `--template-root <bundled feature-templates path>` internally before invoking `resources/templates/new_active_feature_folder.py`.

Notable alternatives and boundary cases:

- **Zero args** always means interactive fallback.
- **Any args present** always means strict non-interactive mode; the handler must not “fill the rest from prompts.”
- **Legacy `full` work mode** remains accepted for backward compatibility and is normalized downstream by `scripts/dev_tools/prompt_mode_contract.py`.
- **Invalid direct input** must raise an actionable error immediately instead of hanging on prompts or partially executing the workflow.
- **Orchestrator docs/resources** in both repo-root and mirrored bundled customizations must be updated to call these command IDs with explicit flag arrays and canonical work modes.


## Inputs / Outputs

- Inputs (CLI flags, files, env vars)
	- Command arguments supplied to the existing VS Code command IDs registered in `extensions/drm-copilot/package.json` and handled in `extensions/drm-copilot/src/extension.ts`.
	- CLI-style direct flags:
		- `drmCopilotExtension.newPotentialEntry`: `-ShortName <kebab-case>`
		- `drmCopilotExtension.newPotentialBugEntry`: `--short-name <kebab-case>`
		- `drmCopilotExtension.potentialToIssue`: `--potential-path <path> --promotion-type <epic|feature|refactor|bug> --work-mode <minor-audit|full-feature|full-bug|full>`
		- `drmCopilotExtension.newActiveFeatureFolder`: `--feature-name <slug> --type <epic|feature|refactor|bug> [--issue-number <digits>] --work-mode <minor-audit|full-feature|full-bug|full>`
	- Extension-managed internal arguments that are not required from the caller:
		- `-TemplateRoot <path>` for `new-potential-entry.ps1`
		- `--template-root <path>` for `new_potential_bug_entry.py`
		- `--template-root <path>` for `new_active_feature_folder.py`
	- Existing runtime environment requirements remain unchanged:
		- `python` must be on `PATH` for Python-backed bundled scripts.
		- `pwsh` or `powershell` must be on `PATH` for PowerShell-backed bundled scripts.
	- No new environment variables, settings keys, or feature flags are introduced by this feature.
- Outputs (artifacts, logs, telemetry)
	- The emitted repo artifacts remain the outputs of the existing workspace tools that bundled scripts already drive:
		- potential entry markdown under `docs/features/potential/`
		- promoted issue-backed docs under `docs/features/active/.../issue.md`, `spec.md`, and `user-story.md` as applicable
		- active feature folder scaffolding under `docs/features/active/`
	- Existing output-channel logging in `extensions/drm-copilot/src/command-runtime.ts` remains the primary execution log surface.
	- Extension-side validation failures should surface as thrown errors under the existing command ID; no external telemetry service is added.
- Config keys and defaults:
	- Default invocation mode is interactive when no args are passed.
	- Accepted work-mode values remain aligned with `WORK_MODE_OPTIONS` in `extensions/drm-copilot/src/extension.ts` and `ACCEPTED_WORK_MODES` in `scripts/dev_tools/prompt_mode_contract.py`.
	- Default template-root resolution remains the extension-bundled `resources/feature-templates` path determined at activation time.
- Versioning or backward-compatibility constraints:
	- Keep the current public command IDs unchanged.
	- Do not add duplicate “direct” command IDs.
	- Keep interactive behavior backward-compatible for existing Command Palette users.
	- Preserve acceptance of legacy `full` in direct mode because downstream Python logic already normalizes it.
	- Align `scripts/dev-tools/new-potential-entry.ps1` with the bundled PowerShell contract so workspace and bundled entrypoints no longer drift.

## API / CLI Surface

List commands, flags, request/response shapes, and examples.

- Public command surface
	- `drmCopilotExtension.newPotentialEntry`
	- `drmCopilotExtension.newPotentialBugEntry`
	- `drmCopilotExtension.potentialToIssue`
	- `drmCopilotExtension.newActiveFeatureFolder`
	- All four commands remain contributed once in `extensions/drm-copilot/package.json`.

- Invocation contract
	- Handler signature must accept invocation arguments from `vscode.commands.executeCommand(...)` and determine mode by argument presence.
	- Accepted direct-mode payload shape is an ordered `string[]` flag list, matching the argv shape already forwarded to `executeBundledScript(...)`.
	- The extension remains responsible for mapping validated direct-mode inputs to the existing bundled script argv surface.

- Example invocations with expected outputs (concise):

```json
{
	"command": "drmCopilotExtension.newPotentialEntry",
	"arguments": ["-ShortName", "noninteractive-bundled-command-flags"]
}
```

Expected result: the handler performs no `showInputBox` call, appends `-TemplateRoot <bundled path>`, and launches `resources/templates/new-potential-entry.ps1`.

```json
{
	"command": "drmCopilotExtension.newPotentialBugEntry",
	"arguments": ["--short-name", "noninteractive-bug-example"]
}
```

Expected result: the handler performs no UI prompt, appends `--template-root <bundled path>`, and launches `resources/templates/new_potential_bug_entry.py`.

```json
{
	"command": "drmCopilotExtension.potentialToIssue",
	"arguments": [
		"--potential-path",
		"docs/features/potential/2026-03-14-noninteractive-bundled-command-flags.md",
		"--promotion-type",
		"feature",
		"--work-mode",
		"full-feature"
	]
}
```

Expected result: the handler skips active-editor lookup, file pickers, and quick picks, then launches `resources/templates/potential_to_issue.py` with the same validated flag set.

```json
{
	"command": "drmCopilotExtension.newActiveFeatureFolder",
	"arguments": [
		"--feature-name",
		"2026-03-14-noninteractive-bundled-command-flags-104",
		"--type",
		"feature",
		"--issue-number",
		"104",
		"--work-mode",
		"full-feature"
	]
}
```

Expected result: the handler skips quick picks and input boxes, appends `--template-root <bundled path>`, and launches `resources/templates/new_active_feature_folder.py`.

- Contracts and validation rules:
	- Short-name values must match `^[a-z0-9]+(-[a-z0-9]+)*$`.
	- Feature-name values must match `^[a-z0-9]+(?:[-_][a-z0-9]+)*$`.
	- `promotion-type` / `type` values must be one of `epic`, `feature`, `refactor`, `bug`.
	- `work-mode` values must be one of `minor-audit`, `full-feature`, `full-bug`, `full`.
	- `issue-number`, when supplied, must contain digits only.
	- Direct mode must reject:
		- unknown flags,
		- duplicate flags,
		- missing required flag values,
		- required flags omitted for that command,
		- invalid enum or pattern values.
	- Direct-mode validation errors must be explicit about which flag is wrong and what accepted values or format are required.
	- Interactive cancellation must remain non-error return behavior.

## Data & State

Data flow, storage, or state changes introduced by this feature.

- Data transformations and invariants:
	- The extension command layer becomes responsible for one deterministic routing decision: `args.length === 0` means interactive mode; `args.length > 0` means strict direct mode.
	- In direct mode, raw invocation arguments are parsed and validated before building the final forwarded argv list.
	- The forwarded argv list must stay aligned with the existing bundled entrypoint contracts rather than introducing a third internal schema.
	- Template-root values remain extension-owned implementation details and must not be required from orchestrators.
	- Work-mode values forwarded to Python-backed flows must stay compatible with `scripts/dev_tools/prompt_mode_contract.py`, including legacy `full` acceptance.
- Caching or persistence details:
	- No new caches, persisted settings, or extension storage keys are introduced.
	- Existing workflow outputs continue to be written only by the downstream bundled scripts and workspace tooling they already call.
- Migration or backfill requirements (if any):
	- No data migration is required.
	- Documentation and agent-resource updates are required so future orchestrator runs use the direct command path instead of raw script commands.
	- `scripts/dev-tools/new-potential-entry.ps1` must add `-TemplateRoot` parity so the workspace script surface matches the bundled PowerShell entrypoint contract going forward.

## Constraints & Risks

- The interactive command surface is already useful for humans, so the change should extend it rather than replace it.
- Command argument shapes must stay aligned across extension command registrations, bundled script entrypoints, and orchestrator documentation to avoid drift.
- Non-interactive invocation needs clear validation rules so orchestrators fail fast instead of hanging on unexpected prompts.
- Touched areas will likely include extension command registrations, bundled script entrypoints/templates, orchestrator agent docs/resources, and relevant extension/orchestrator tests.
- Backward compatibility matters for existing interactive users; prompt-based flows should continue to work when no explicit arguments are passed.
- Compatibility risk: if direct-mode parsing accepts a value shape that the downstream script rejects, automation will still fail later, so extension-side validation should mirror existing prompt validators and known CLI contracts as closely as possible.
- Documentation drift risk: root agent docs under `.github/agents/` and mirrored copies under `extensions/drm-copilot/resources/customizations/.github/agents/` must be updated together.
- Operational caveat: direct invocation still depends on the same runtime discovery in `extensions/drm-copilot/src/command-runtime.ts`, so missing `python`, `pwsh`, or `powershell` remains a hard failure.
- Security constraint: continue using `shell: false` process execution and explicit argv forwarding via `executeBundledScript`; do not introduce shell-joined command strings.
- Performance expectation: argument parsing and validation should be negligible relative to script execution and must not add blocking filesystem or network work before validation completes.


## Implementation Strategy

- Implementation scope (what changes, not sequencing):
	- Update the four workflow handlers in `extensions/drm-copilot/src/extension.ts` so each accepts invocation args and chooses between interactive fallback and strict direct mode.
	- Reuse `executeBundledScript(...)` in `extensions/drm-copilot/src/command-runtime.ts` unchanged as the execution boundary.
	- Keep `extensions/drm-copilot/package.json` command contributions stable; this feature does not introduce new command IDs.
	- Align workspace PowerShell entrypoint `scripts/dev-tools/new-potential-entry.ps1` with the bundled PowerShell argument contract by adding optional `-TemplateRoot` support.
	- Update orchestrator-facing docs/resources in these existing areas:
		- `.github/agents/orchestrator.agent.md`
		- `.github/agents/python-orchestrator.agent.md`
		- `.github/agents/powershell-orchestrator.agent.md`
		- `.github/agents/csharp-orchestrator.agent.md`
		- mirrored copies under `extensions/drm-copilot/resources/customizations/.github/agents/`
	- Update extension tests in:
		- `extensions/drm-copilot/test/extension.test.ts`
		- `extensions/drm-copilot/test/extension.potential-to-issue.test.ts`
		- `extensions/drm-copilot/test/extension.new-active-feature-folder.test.ts`
- New classes/functions/commands to add or update:
	- Update existing command handlers rather than adding new commands.
	- Add or extract pure argument-resolution helpers for each workflow from `extensions/drm-copilot/src/extension.ts` if needed to keep validation logic testable and the file maintainable.
	- Keep prompt helpers such as `promptForShortName`, `promptForChoice`, and `promptForFeatureName` for interactive mode.
	- Add validation helpers for required flags, duplicate/unknown flag detection, and enum/pattern checking when direct mode is active.
- Dependency changes (new/removed packages) and rationale:
	- No new runtime or test dependencies are required.
	- The existing VS Code command API, Jest-based extension test setup, PowerShell entrypoint, and Python CLI workflows already provide the necessary seams.
- Logging/telemetry additions and locations:
	- Continue using the existing `drm-copilot` output channel and `commandId`-scoped logging pattern.
	- Add lightweight extension-side logging in `extensions/drm-copilot/src/extension.ts` for invocation mode selection (`interactive` vs `direct`) and direct-mode validation failures before throwing.
	- Do not add external telemetry or new persisted audit logs for this feature.
- Rollout plan (feature flags, staged deploys, fallback path):
	- No feature flag is required.
	- Land the change behind the existing command IDs with interactive fallback preserved, then update orchestrator docs/resources in the same change so automation can switch immediately.
	- If a direct invocation is malformed, the fallback path is not to prompt; the command must fail explicitly so automated callers notice and correct the invocation contract.

## Definition of Done

- [x] Acceptance criteria in `user-story.md` and this spec are mapped to named extension tests or reproducible command-invocation demos for all four workflows.
- [x] `extensions/drm-copilot/src/extension.ts` supports interactive fallback with zero args and strict direct invocation with explicit flags for all four workflow commands without changing their public IDs.
- [x] Tests are added or updated in `extensions/drm-copilot/test/extension.test.ts`, `extensions/drm-copilot/test/extension.potential-to-issue.test.ts`, and `extensions/drm-copilot/test/extension.new-active-feature-folder.test.ts` to cover direct success paths, prompt skipping, and invalid-argument failures.
- [x] Edge cases are covered by tests for unknown flags, duplicate flags, missing required values, invalid short names, invalid feature names, invalid work modes, invalid promotion types, and non-digit issue numbers.
- [x] Orchestrator docs are updated in both `.github/agents/` and `extensions/drm-copilot/resources/customizations/.github/agents/` to use direct extension-command invocation with explicit work-mode values.
- [x] Output-channel logging is updated, if needed, to make invocation mode selection and validation failures observable under the existing command IDs, with no new external telemetry dependency.
- [x] The relevant extension toolchain pass completes successfully using the repo-standard extension commands for format, lint, typecheck, and unit tests.

## Seeded Test Conditions (from potential)
- [x] Unit coverage verifies command argument parsing, direct-invocation routing, and prompt-skipping behavior when explicit arguments are present for all four command IDs.
- [x] Integration-style extension scenarios verify orchestrator-facing direct calls can create a potential entry, promote a potential doc, and create an active feature folder without any input boxes, quick picks, or file dialogs.
- [x] CLI/API examples remain documented for each workflow, including required flags, optional flags, canonical work-mode values, and the expected error behavior for missing, duplicate, or invalid flags.
