# 2026-03-21-bundle-sync-agents — Spec

- **Issue:** #113
- **Parent (optional):** none
- **Owner:** drmoisan
- **Last Updated:** 2026-03-21T20-41
- **Status:** Draft
- **Version:** 0.1

## Overview

The repository already has `scripts/dev-tools/sync-agents-from-instructions.ps1`, but it is not exposed through the VS Code extension command surface that currently drives other destination-workspace workflows. Users who push bundled tooling into another workspace can sync customization files there, but they cannot trigger `AGENTS.md` regeneration from the extension in the same way.

The current script also hard-codes a fixed section list and rewrites section titles instead of discovering the canonical instruction sources that actually exist under `.github/`. That makes the sync brittle when new instruction files are added, renamed, or reorganized, and creates drift between the generated `AGENTS.md` content and the instruction set the repo actually ships.

This feature adds a bundled extension command for syncing `AGENTS.md` in the open workspace and updates the sync implementation so it generates output from the workspace's actual instruction files instead of a manually maintained section list. The scope is limited to deterministic generation of `AGENTS.md` from the destination workspace's `.github/` instruction sources while preserving the existing repository-local PowerShell entrypoint.


## Behavior

Add a new extension command that runs a bundled `sync-agents-from-instructions` workflow against the current destination workspace root, following the same execution model used by `drmCopilotExtension.pushDownCopilotCustomizations` and the other live bundled commands.

Update the sync implementation so generation is discovery-based instead of section-list-based. The script should treat `.github/copilot-instructions.md` as the canonical repository-wide preamble, scan the destination workspace’s `.github/` tree for applicable `*.instructions.md` files, strip frontmatter, and combine their bodies into a deterministic `AGENTS.md` output without requiring a manually maintained array of section definitions. The generated file should still remain clearly marked as derived output and should preserve a stable ordering so repeated runs are idempotent.

On the main path, a user runs the new extension command from VS Code while a destination workspace is open. The extension resolves the active workspace root, invokes the bundled PowerShell sync script with that workspace as `cwd`, and forwards the same path as the repo root argument. The script then requires `.github/copilot-instructions.md`, discovers supported `*.instructions.md` files under `.github/`, strips YAML frontmatter from each source, derives section content and labels deterministically, and writes a regenerated `AGENTS.md` at the workspace root.

On alternative paths, the same sync logic remains available through the existing repo-root PowerShell script for direct repository-local use. If the workspace is missing `.github/copilot-instructions.md` or no supported instruction files are discovered, the workflow stops without writing partial output and surfaces an actionable error through the existing command execution path.


## Inputs / Outputs

- Inputs (CLI flags, files, env vars)
	- Extension command invocation from VS Code: `drmCopilotExtension.syncAgentsFromInstructions`
	- Repo-root CLI invocation: `scripts/dev-tools/sync-agents-from-instructions.ps1 -RepoRoot <workspace-root>`
	- Required file input: `<workspace-root>/.github/copilot-instructions.md`
	- Discovered file inputs: supported `*.instructions.md` files under `<workspace-root>/.github/`
	- No environment variables are required by the documented feature scope.
- Outputs (artifacts, logs, telemetry)
	- Generated artifact: `<workspace-root>/AGENTS.md`
	- Command/runtime output: success or failure details surfaced through the extension's existing bundled-script execution output path
	- Script behavior: no partial `AGENTS.md` should be produced when required inputs are missing
- Config keys and defaults:
	- `RepoRoot` remains the explicit PowerShell parameter for direct script use.
	- The default direct-script behavior continues to resolve the repository root when `-RepoRoot` is not provided.
- Versioning or backward-compatibility constraints:
	- The existing repository-local PowerShell entrypoint must remain supported.
	- The bundled extension copy must remain aligned with the repo-root script so the extension command and direct script run generate the same output for the same workspace contents.

## API / CLI Surface

List commands, flags, request/response shapes, and examples.
- Extension command contribution
	- Command ID: `drmCopilotExtension.syncAgentsFromInstructions`
	- Command title: `drm-copilot: Sync AGENTS.md from Instructions`
	- Runtime model: the extension executes a bundled PowerShell script from the extension installation path while targeting the open workspace root
- PowerShell script surface
	- Script: `scripts/dev-tools/sync-agents-from-instructions.ps1`
	- Primary parameter: `-RepoRoot <path>`
	- Write target: `<RepoRoot>/AGENTS.md`
- Example invocations with expected outputs (concise):
	- VS Code Command Palette: run `drm-copilot: Sync AGENTS.md from Instructions` while the destination workspace is open; expected result is a regenerated workspace-root `AGENTS.md` based on that workspace's `.github` instruction files.
	- PowerShell: `pwsh -File scripts/dev-tools/sync-agents-from-instructions.ps1 -RepoRoot C:\path\to\workspace`; expected result is the same `AGENTS.md` content the extension command would generate for that workspace.
- Contracts and validation rules:
	- `.github/copilot-instructions.md` is required and must be read as the canonical preamble.
	- Only supported `*.instructions.md` files under `.github/` are included in discovery-based aggregation.
	- YAML frontmatter is removed from aggregated source content before rendering.
	- Ordering must be deterministic so repeated runs with unchanged inputs produce identical output.
	- Missing required inputs or zero discovered instruction files must fail with an actionable error rather than writing misleading output.

## Data & State

Data flow, storage, or state changes introduced by this feature.
- Data transformations and invariants:
	- The generator reads the canonical preamble from `.github/copilot-instructions.md` and discovers instruction bodies from supported `*.instructions.md` files under `.github/`.
	- Each discovered source is transformed by stripping YAML frontmatter before aggregation.
	- The generated file is derived from a single deterministic ordered file list so the header note and rendered body stay in sync.
	- Generated content must exclude unsupported `.github` assets such as prompts, agent definitions, and generated outputs outside the supported instruction scope.
	- Section labels must use a deterministic fallback strategy when source files do not expose the same metadata or heading shape.
- Caching or persistence details:
	- No new cache is introduced.
	- Persistent output is limited to rewriting `<workspace-root>/AGENTS.md`.
- Migration or backfill requirements (if any):
	- No migration or backfill is required.
	- The next sync run after adding a new supported instruction file is expected to include that file automatically.

## Constraints & Risks

- Scope should stay limited to generating `AGENTS.md` for the destination workspace; this idea does not require changing the semantics of the underlying instruction files themselves.
- Discovery must be deterministic. If file ordering depends on platform-specific enumeration order, two developers could generate different `AGENTS.md` output from the same repo state.
- The script must avoid recursively ingesting generated or mirrored outputs such as `AGENTS.md` itself, otherwise the generated file can become self-referential or duplicate content.
- Title generation is a compatibility risk. Some instruction files have frontmatter metadata and markdown headings today, but future files may not. The implementation should define a stable fallback for section labels.
- Bundling the command into the extension adds one more workspace-execution path that must remain aligned between the repo-root script and the bundled extension copy.
- Compatibility risk remains if repo-root and bundled PowerShell copies drift, because the feature depends on both paths producing the same result for the same workspace contents.
- Operational risk remains if error handling reports only generic failures, because users need a clear message when required `.github` sources are absent.


## Implementation Strategy

- Implementation scope (what changes, not sequencing):
	- Update the repo-root PowerShell sync script so it discovers supported instruction files from the destination workspace and generates `AGENTS.md` from the discovered set.
	- Add a bundled PowerShell copy of the sync script to the extension resources and expose it through a new extension command.
	- Extend the existing test surfaces that already cover the root PowerShell script, extension command registration and execution, and any command-reference rewrite behavior that depends on the new live command.
- New classes/functions/commands to add or update:
	- PowerShell script entrypoint: `scripts/dev-tools/sync-agents-from-instructions.ps1`
	- Bundled PowerShell template: `extensions/drm-copilot/resources/templates/sync-agents-from-instructions.ps1`
	- Extension command contribution: `extensions/drm-copilot/package.json`
	- Extension command registration: `extensions/drm-copilot/src/extension.ts`
	- Existing execution surface used without architectural change: `extensions/drm-copilot/src/command-runtime.ts`
	- Existing tests to extend:
		- `tests/scripts/dev-tools/sync-agents-from-instructions.Tests.ps1`
		- `extensions/drm-copilot/test/extension.test.ts`
		- `extensions/drm-copilot/test/extension.integration.test.ts`
		- `tests/scripts/dev_tools/test_push_down_copilot_customizations.py` if pushed-down command references are updated
- Dependency changes (new/removed packages) and rationale:
	- No new runtime dependencies are required.
	- The documented implementation stays within existing PowerShell, TypeScript, Jest, Pester, and Python test infrastructure.
- Logging/telemetry additions and locations:
	- Use the existing extension bundled-script output/logging path for command execution results.
	- Surface explicit PowerShell errors for missing required inputs or zero discovered instruction files.
	- No new telemetry requirement is documented in the issue or research.
- Rollout plan (feature flags, staged deploys, fallback path):
	- No feature flag is required in the documented scope.
	- Repository-local fallback remains direct invocation of `scripts/dev-tools/sync-agents-from-instructions.ps1`.
	- The extension command becomes an additional entrypoint, not a replacement for the root script.

## Definition of Done

- [ ] Acceptance criteria are mapped to concrete verification in the PowerShell, Jest, and any rewrite-catalog test surfaces identified in research.
- [ ] Behavior matches the documented extension-command path and the existing direct PowerShell script path for the same workspace contents.
- [ ] Tests are added or updated in `tests/scripts/dev-tools/sync-agents-from-instructions.Tests.ps1`, `extensions/drm-copilot/test/extension.test.ts`, and `extensions/drm-copilot/test/extension.integration.test.ts`, with rewrite-catalog tests updated if command references change.
- [ ] Edge cases for missing `.github/copilot-instructions.md`, zero discovered instruction files, deterministic ordering, frontmatter stripping, and automatic inclusion of new instruction files are covered by tests.
- [ ] Documentation is updated where the command surface is described, including this feature folder and any README content chosen by implementation.
- [ ] Existing extension output or script error reporting clearly surfaces success and actionable failure details; no separate telemetry addition is required unless implementation introduces one.
- [ ] The relevant toolchain passes for all touched languages and surfaces after implementation work is complete.

## Seeded Test Conditions (from potential)
- [ ] Unit coverage areas
- Discovery of `.github/copilot-instructions.md` plus `*.instructions.md` files from the destination workspace
- Frontmatter stripping, empty-file handling, deterministic ordering, and section-label derivation
- Exclusion of generated outputs or unsupported files from the aggregation set
- [ ] Integration scenarios
- Extension command execution updates `AGENTS.md` successfully in a workspace that contains the expected `.github/` instruction sources
- Workspace with an added instruction file is resynced without any code changes and includes the new content
- Workspace missing required inputs fails fast with a clear error surfaced through the extension output/logging path
- [ ] CLI/API examples
- Manual invocation of `scripts/dev-tools/sync-agents-from-instructions.ps1` against an explicit repo root still works for repository-local use
- Extension command invocation produces the same `AGENTS.md` result as the direct script run for the same workspace contents
