# 2026-03-03-expose-commit-script — Spec

- **Issue:** #74
- **Parent (optional):** none
- **Owner:** drmoisan
- **Last Updated:** 2026-03-03T22-05
- **Status:** Draft
- **Version:** 0.1

## Overview

The scaffold extension already proves that bundled scripts can execute from extension resources and write artifacts into a destination workspace. What is missing is a realistic Git-aware workflow that validates repository introspection behavior, especially for staged changes.

`scripts/dev_tools/collect_commit_context.py` provides the desired commit-context logic today, but only from repository-local script execution paths. Without extension exposure, we cannot validate the production boundary where the extension executes packaged resources while targeting the destination workspace repository.

This feature closes that gap by making commit-context collection an extension command that inspects staged files in the destination workspace and writes `artifacts/commit_context.txt` there. It establishes a reusable contract for future extension-side automation tied to commit and PR preparation.


## Behavior

Add an extension command that invokes an extension-bundled commit-context collector (based on `collect_commit_context.py`) against the active destination workspace root.

At runtime, the command should:
- Validate an open workspace root.
- Resolve and validate required runtime(s) for bundled script invocation.
- Resolve the collector script from extension bundled resources (never copy it into workspace root).
- Execute the collector with process working directory set to the destination workspace root so all Git queries (`status`, `diff --cached`, etc.) target that repository.
- Write commit context output to `artifacts/commit_context.txt` under the destination workspace.
- Surface lifecycle, runtime selection, and failure diagnostics in the `Scaffold Utils` output channel.


## Inputs / Outputs

- Inputs (CLI flags, files, env vars)
	- VS Code command invocation: `scaffoldExtension.collectCommitContext` from Command Palette.
	- Destination workspace root from `vscode.workspace.workspaceFolders` (deterministic root selection policy).
	- Bundled collector script file shipped inside extension resources (based on `scripts/dev_tools/collect_commit_context.py`).
	- Runtime input: Python executable resolved by existing extension runtime probing logic.
	- Collector CLI argument: `--output artifacts/commit_context.txt` (explicit output contract).
	- Git repository state in destination workspace (staged, unstaged, untracked files).
- Outputs (artifacts, logs, telemetry)
	- Artifact: `<destination-workspace>/artifacts/commit_context.txt`.
	- Artifact content includes deterministic section headers for remotes, branch/upstream, short status, staged file list + staged diff, unstaged file list + unstaged diff, untracked files, diff stat, changed Python files, and last commit header.
	- Output channel logging in `Scaffold Utils` for command start, runtime resolution, script path resolution, subprocess execution, completion, and failure diagnostics.
	- User-facing error messages for missing workspace, missing runtime, git resolution failure, or collector non-zero exit.
- Config keys and defaults:
	- Command ID: `scaffoldExtension.collectCommitContext`.
	- Default output path: `artifacts/commit_context.txt` under destination workspace.
	- Runtime preference follows existing extension order for Python resolution.
	- Process execution uses destination workspace as `cwd` and `shell: false` in subprocess spawn.
- Versioning or backward-compatibility constraints:
	- Additive command-only change; no breaking changes to existing extension commands.
	- Preserve existing collector section semantics and `(no staged changes)` markers to avoid downstream parser regressions.
	- Keep no-copy invariant for script execution boundary (extension resource path remains the script source).

## API / CLI Surface

List commands, flags, request/response shapes, and examples.
- Example invocations with expected outputs (concise):
	- Command Palette -> `Scaffold: Collect Commit Context` -> success message in `Scaffold Utils` and artifact created at `artifacts/commit_context.txt`.
	- Command Palette -> `Scaffold: Collect Commit Context` with no open workspace -> immediate actionable error indicating a workspace is required.
	- Command Palette -> `Scaffold: Collect Commit Context` when Python or Git is unavailable -> actionable failure log + surfaced error, no partial success state.
- Contracts and validation rules:
	- Command registration contract:
		- `package.json` contributes `scaffoldExtension.collectCommitContext`.
		- extension activation registers/disposes handler correctly.
	- Execution contract:
		- Collector script path resolves from extension bundled resources, never destination workspace root.
		- Subprocess `cwd` is destination workspace root.
		- Collector argv includes explicit output argument targeting `artifacts/commit_context.txt`.
	- Output contract:
		- Artifact must exist on success and contain all required commit-context sections.
		- When staged set is empty, staged sections contain `(no staged changes)` markers.
	- Failure contract:
		- Missing workspace/runtime/git and non-zero collector exits return explicit errors and are logged with enough context to diagnose root cause.

## Data & State

Data flow, storage, or state changes introduced by this feature.
- Data transformations and invariants:
	- Source data is Git state queried from destination workspace repository at command runtime.
	- Collector transforms Git command outputs into a deterministic, sectioned plaintext artifact.
	- Invariant: artifact sections remain present even when certain data is empty; empty staged data is represented with `(no staged changes)` markers.
	- Invariant: all Git introspection is scoped to destination workspace via process `cwd`, not extension source repository.
- Caching or persistence details:
	- No long-lived in-memory cache is introduced.
	- Persistent output is a single artifact file: `artifacts/commit_context.txt`, overwritten on each successful run.
	- Logs are appended to `Scaffold Utils` output channel for runtime diagnostics during the command session.
- Migration or backfill requirements (if any):
	- None. Existing repositories require no schema migration or artifact backfill.
	- Feature is forward-only and command-triggered.

## Constraints & Risks

- Must preserve extension boundary: execution originates extension-side while operating on destination workspace filesystem and Git repository.
- Cross-platform behavior (Windows/macOS/Linux) must keep runtime probing and path handling deterministic.
- Git executable availability and repository-state failures must surface as explicit, actionable errors.
- Large staged/unstaged diffs can increase artifact size and command duration; logging must preserve diagnosability without freezing UX.
- Multi-root workspaces require a deterministic root-selection rule to avoid collecting context from the wrong repository.
- Scope control: this feature exposes commit-context collection only; it does not include commit-message authoring UX.


## Implementation Strategy

- Implementation scope (what changes, not sequencing):
	- Extend scaffold extension command surface to expose commit-context collection as a first-class command.
	- Reuse existing extension runtime/script execution plumbing for workspace validation, runtime probing, and subprocess spawning.
	- Bundle collector script as extension resource and execute it directly from extension install location.
	- Add/expand extension unit and integration tests for happy-path and error-path requirements.
	- Update feature docs and extension-facing documentation to reflect command behavior and artifact contract.
- New classes/functions/commands to add or update:
	- `extensions/scaffold-extension/package.json`
		- Add command contribution entry for `scaffoldExtension.collectCommitContext`.
	- `extensions/scaffold-extension/src/extension.ts`
		- Register command handler for commit-context collection.
		- Reuse/extend existing helpers for workspace root selection, runtime detection, bundled script resolution, and process execution.
	- `extensions/scaffold-extension/resources/...`
		- Add bundled collector script copy/sync target for extension-side execution.
	- `extensions/scaffold-extension/test/extension.test.ts`
		- Add unit tests for registration, workspace validation, runtime selection, bundled script path resolution, and spawn `cwd`/args.
	- `extensions/scaffold-extension/test/extension.integration.test.ts`
		- Add integration-style tests for artifact generation behavior and no-script-materialization invariant.
- Dependency changes (new/removed packages) and rationale:
	- No new external dependencies required.
	- Existing VS Code API, Node subprocess APIs, and bundled Python collector are sufficient.
- Logging/telemetry additions and locations:
	- Log command lifecycle events to `Scaffold Utils`: invocation, workspace detection result, runtime probe result, resolved script path, process start, process exit code, and failure diagnostics.
	- Ensure error logs differentiate runtime resolution failures from collector/git execution failures.
- Rollout plan (feature flags, staged deploys, fallback path):
	- Roll out as additive command in the scaffold extension without feature flag.
	- Fallback behavior on failure is explicit error surfacing; no silent fallback to workspace-local script execution.
	- Maintain existing commands unchanged to reduce regression risk.

## Definition of Done

- [x] Acceptance criteria documented and mapped to tests or demos (see `user-story.md` + this spec's Acceptance/Seeded Test sections).
- [x] Behavior matches acceptance criteria in all documented environments (pending final QC evidence capture).
- [x] Tests updated/added (unit/integration as applicable) (targeted scenario tests added in scaffold-extension suite).
- [x] Edge cases and error handling covered by tests (workspace/runtime/non-zero/stderr scenarios covered).
- [x] Docs updated (README, docs/features/active/... links) (`user-story.md` and `spec.md` completed for feature folder).
- [x] Telemetry/logging added or updated (if applicable) (command-scoped lifecycle output lines for collect command).
- [x] Toolchain pass completed (format → lint → type-check → test) (validated again during remediation closure).

## Evidence Links

- Baseline artifact: [`evidence/baseline/baseline.test.2026-03-03T21-15.md`](./evidence/baseline/baseline.test.2026-03-03T21-15.md)
- QA artifact: [`evidence/qa-gates/final-qc.pass1.test.2026-03-03T21-15.md`](./evidence/qa-gates/final-qc.pass1.test.2026-03-03T21-15.md)
- Remediation closure: [`evidence/other/remediation-closure.2026-03-03T22-05.md`](./evidence/other/remediation-closure.2026-03-03T22-05.md)

## Seeded Test Conditions (from potential)
- [ ] Unit coverage areas
- [ ] Command registration and disposal behavior
- [ ] Workspace root discovery success/failure
- [ ] Bundled script path resolution logic
- [ ] Runtime detection and ordered fallback behavior
- [ ] Spawn arguments include destination workspace working directory and output path
- [ ] Integration scenarios
- [ ] Destination repo with staged tracked file changes
- [ ] Destination repo with unstaged and untracked changes
- [ ] Destination repo with no staged changes still produces artifact with expected "no staged changes" markers
- [ ] Artifact content sections validated and deterministic
- [ ] No script materialization in workspace root
- [ ] Workspace path containing spaces/unicode executes successfully
- [ ] CLI/API examples
- [ ] Command Palette usage for commit-context collection
- [ ] Optional command argument support for output path (if added)
