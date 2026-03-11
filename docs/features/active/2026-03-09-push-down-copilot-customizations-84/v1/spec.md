# 2026-03-09-push-down-copilot-customizations — Spec

- **Issue:** #84
- **Parent (optional):** none
- **Owner:** drmoisan
- **Last Updated:** 2026-03-09T23-14
- **Status:** Draft
- **Version:** 0.1

## Overview

`scripts/dev_tools/agentic_sync.py` currently synchronizes shared `.github` content between two repositories, but it does not provide a one-way "push down" flow that copies the current repo's Copilot customizations into an arbitrary destination workspace. When these files are moved today, embedded references to repo-local scripts such as `scripts/dev_tools/...` or `scripts/dev-tools/...` do not travel cleanly, so the copied guidance can point at commands that do not exist in the destination workspace.

This feature would close that gap by turning the local `.github/agents/`, `.github/instructions/`, `.github/prompts/`, and `.github/skills/` trees into a destination-workspace-ready customization pack. It also needs to keep those copied files executable in practice by rewriting script references to packaged extension commands and exposing explicit placeholders where command coverage is not implemented yet.


## Behavior

A Python push-down tool should copy every file under `.github/agents/`, `.github/instructions/`, `.github/prompts/`, and `.github/skills/` from this repo into a destination workspace, preserving relative paths under `.github/` and creating missing directories as needed. If the destination workspace already contains a file at the same relative path, the local source copy should overwrite it.

During copy, the tool should rewrite supported script references inside copied text files so they point to packaged extension commands/resources rather than repo-local script paths. The rewrite map should align with command exposure in `extensions/drm-copilot/src/extension.ts` and existing bundled execution patterns that resolve scripts from extension resources. If a copied file references a script that is not yet exposed, the extension should expose a stable placeholder command that fails with an explicit not-implemented error instead of leaving a dead workspace path reference.

The initial scope likely includes Python tooling changes, extension command exposure, rewrite mapping, and tests that verify overwrite behavior plus rewritten command usability.

- Main path:
	- Enumerate the four scoped source roots in deterministic order and discover files by relative `.github/...` path.
	- For text-eligible files, normalize slash variants in script references before catalog lookup, then rewrite only anchored, supported script/module references.
	- Replace references to implemented tooling with canonical textual extension-command references aligned with the packaged command surface.
	- Replace references to uncovered but verified scripts with canonical textual placeholder-command references that intentionally fail with a deterministic not-implemented error when invoked from the extension.
	- Create any missing destination directories, write the rewritten or original file content, and record whether the destination file was newly created or overwritten.
- Notable alternative and failure paths:
	- If a copied file contains an unknown script-like reference that is outside the initial verified catalog, leave that text unchanged and report it in the run summary instead of guessing at a rewrite target.
	- If a file cannot be safely treated as text, copy it without rewrite and record that it bypassed rewrite handling.
	- If the destination workspace root is invalid or unusable, fail the run before partial copy begins.
	- Existing `scripts/dev_tools/agentic_sync.py` behavior remains separate from this flow; the push-down tool is a publisher, not a bidirectional reconciliation mode.


## Inputs / Outputs

- Inputs (CLI flags, files, env vars)
	- Required CLI input: destination workspace root for the one-way push-down run.
	- Proposed Python entry point: `poetry run python -m scripts.dev_tools.push_down_copilot_customizations --destination <workspace-root>`.
	- Source content is the current repo checkout under `.github/agents/`, `.github/instructions/`, `.github/prompts/`, and `.github/skills/`.
	- No environment variables are required for the base flow.
- Outputs (artifacts, logs, telemetry)
	- Destination workspace receives overwritten or newly created `.github/...` files only; the tool does not copy repo-local `scripts/` content into the target workspace.
	- The run should emit a JSON summary artifact under a dedicated push-down artifact location, with counts and per-file detail for copied files, overwritten files, rewrites applied, placeholder rewrites applied, and unmatched references left unchanged.
	- Extension-side placeholder execution should log the deterministic not-implemented failure through the existing extension output/error path rather than surfacing a missing-file error.
- Config keys and defaults:
	- The source root set is fixed to the four existing `.github` folders already scoped in the repo.
	- Initial rewrite coverage is intentionally narrow and evidence-based: the existing real packaged command for PR-context collection plus placeholder coverage for the currently verified uncovered scripts referenced by copied docs.
	- Unmatched references default to pass-through behavior plus summary reporting.
- Versioning or backward-compatibility constraints:
	- The current `scripts/dev_tools/agentic_sync.py` CLI remains intact; this feature adds a new one-way entry point instead of overloading the existing sync contract.
	- Rewritten command references must remain aligned with command contributions in `extensions/drm-copilot/package.json` and registrations in `extensions/drm-copilot/src/extension.ts`.

## API / CLI Surface

List commands, flags, request/response shapes, and examples.
- Python push-down command
	- Proposed module entry point: `scripts.dev_tools.push_down_copilot_customizations`.
	- Required flag: `--destination`, pointing at the destination workspace root that will receive the copied `.github` trees.
	- Example invocation with expected output shape (concise):
		- `poetry run python -m scripts.dev_tools.push_down_copilot_customizations --destination C:\work\target-repo`
		- Expected result: process completes successfully, target workspace `.github/...` files are updated, and a JSON summary records copied, overwritten, rewritten, and unmatched-reference counts.
- Rewritten command-reference contract in copied files
	- Implemented commands should be rewritten to a stable textual reference that includes both the user-facing command title and the command ID so the copied docs remain readable even outside a trusted markdown execution surface.
	- Placeholder commands should use the same textual format, but the underlying command implementation must throw a deterministic not-implemented error when invoked.
- Extension command surface
	- Existing real bundled command in scope: PR-context collection.
	- Initial placeholder coverage should be limited to the currently verified uncovered scripts referenced in copied docs: `scripts.dev_tools.new_active_feature_folder`, `scripts.dev_tools.potential_to_issue`, `scripts/dev_tools/new_potential_bug_entry.py`, and `scripts/dev-tools/new-potential-entry.ps1`.
- Contracts and validation rules:
	- Destination path must resolve to a workspace root distinct from the source repo.
	- Rewrite matching must normalize `scripts/dev_tools` and `scripts/dev-tools` spellings before lookup.
	- Unknown script-like references must not be rewritten heuristically.
	- Placeholder error text must be stable enough for deterministic test assertions.

## Data & State

Data flow, storage, or state changes introduced by this feature.
- Data transformations and invariants:
	- The tool walks only the four scoped source roots and preserves each file's relative path under `.github/`.
	- Enumeration order should be deterministic (by root, then relative path) so summary artifacts and tests remain stable across runs.
	- Text rewrite is a pure transformation over copied file content: original reference -> normalized lookup key -> implemented or placeholder command reference -> destination file write.
	- The tool must preserve file content exactly when no rewrite applies or when a reference is intentionally left unmatched.
- Caching or persistence details:
	- No long-lived cache is required.
	- Persistent output is limited to the destination workspace files plus a per-run summary artifact in the source repo's artifact area.
	- Extension-side state remains command registration only; placeholder commands do not introduce new persisted state.
- Migration or backfill requirements (if any):
	- No migration is required because this is a new one-way publishing flow.
	- Existing copied workspaces can be refreshed by rerunning the push-down command, which overwrites same-path `.github` files with the current source-repo version.

## Constraints & Risks

- Rewrite coverage is the main scope risk: `.github` content includes mixed command styles (`scripts/dev_tools`, `scripts/dev-tools`, `poetry run python -m ...`, PowerShell examples), so the mapping must be broad enough to catch real references without rewriting unrelated prose.
- Overwrite behavior is intentionally destructive for matching destination files, so the tool should make that contract explicit and produce a summary artifact/log of what it copied and rewrote.
- Command exposure and rewrite mapping must stay in sync with `extensions/drm-copilot/src/extension.ts`; otherwise copied docs will drift faster than the packaged commands they depend on.
- Placeholder exposure reduces broken links but expands extension surface area, so command IDs, error messaging, and packaged resource layout need to remain stable across platforms and future packaging changes.
- Plain repository markdown files are not a valid target for generic VS Code `command:` URIs, so rewritten output must remain textual rather than assuming trusted markdown execution.
- Windows path separators and mixed slash spellings in existing docs increase the risk of duplicate or missed catalog matches unless normalization happens before lookup.


## Implementation Strategy

- Implementation scope (what changes, not sequencing):
	- Add a new one-way Python publishing entry point instead of extending the current bidirectional sync CLI behavior.
	- Introduce a shared rewrite/command catalog that defines normalized script keys, command IDs/titles, and whether each target is implemented or placeholder-only.
	- Update extension command contribution and registration logic so the same verified command surface exposed in the extension is what the Python rewrite layer emits into copied files.
- New classes/functions/commands to add or update:
	- `scripts/dev_tools/push_down_copilot_customizations.py`: orchestration entry point for enumeration, rewrite, overwrite-copy, and summary artifact generation.
	- Shared Python helpers or dataclasses for per-file copy/rewrite results, ideally following the small artifact-model pattern already used by `agentic_sync.py`.
	- `extensions/drm-copilot/src/extension.ts`: centralize registration of implemented commands and placeholder commands from the same conceptual catalog; keep the bundled execution path for the existing real PR-context command.
	- `extensions/drm-copilot/package.json`: add command contributions for any new textual references emitted by the rewrite catalog, including narrow placeholder coverage for currently uncovered scripts.
	- Tests: add Python coverage for push-down behavior and extend extension tests for placeholder registration/error handling.
- Dependency changes (new/removed packages) and rationale:
	- No new runtime dependency is required.
	- Python standard-library copy and path utilities already support overwrite semantics, and the extension already has the bundled-script execution pattern needed for real commands.
- Logging/telemetry additions and locations:
	- Write a dedicated push-down JSON artifact summarizing source/destination roots, copied files, overwritten files, rewrite targets, placeholder rewrites, and unmatched references.
	- Use the existing extension output/error channel pattern to surface deterministic placeholder failures and real-command execution results.
- Rollout plan (feature flags, staged deploys, fallback path):
	- Ship the one-way publisher and extension-command additions without changing the existing sync command surface.
	- Keep first-release rewrite coverage intentionally narrow: the verified PR-context command plus placeholder coverage for the currently evidenced uncovered scripts.
	- If additional `.github` references are discovered later, extend the catalog incrementally rather than broadening rewrite heuristics.
	- Fallback behavior for unknown references is safe pass-through plus artifact reporting, not speculative rewriting.

## Definition of Done

- [ ] Acceptance criteria documented and mapped to concrete verification steps in Python and extension tests, plus any required manual demo of rewritten copied files.
- [ ] Behavior matches acceptance criteria in the documented Windows workspace flow, including overwrite semantics, textual command rewrites, and deterministic placeholder failures.
- [ ] Tests updated/added, including Python coverage for `push_down_copilot_customizations` and extension coverage for new command contributions and placeholder execution paths.
- [ ] Edge cases and error handling covered by tests, including invalid destination input, mixed slash normalization, unknown references left unchanged, and text-versus-non-text rewrite handling.
- [ ] Docs updated, including this active feature folder and any related extension command documentation that explains the rewritten command references.
- [ ] Telemetry/logging added or updated via the push-down summary artifact and extension output/error reporting for placeholder commands.
- [ ] Toolchain pass completed (format → lint → type-check → test) for the touched Python and extension surfaces in one final clean pass.

## Seeded Test Conditions (from potential)
- [ ] Unit coverage areas: root-folder enumeration, destination directory creation, overwrite of existing files, rewrite of known script-reference patterns, and pass-through of content that should not be rewritten.
- [ ] Integration scenarios: push into an empty workspace, push into a workspace with conflicting `.github` files, and validate that rewritten references resolve to packaged extension commands instead of destination-workspace script paths.
- [ ] CLI/API examples: one-way push invocation from source repo to destination workspace, expected artifact/log output for copied and rewritten files, and placeholder-command invocation that raises a deterministic not-implemented error.
- [ ] Path/OS edge cases: Windows-style backslashes and mixed `scripts/dev_tools` vs `scripts/dev-tools` references should normalize to the same packaged-command target.
