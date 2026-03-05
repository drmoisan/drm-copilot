# 2026-03-04-expose-pr-context-script — Spec

- **Issue:** #77
- **Parent (optional):** none
- **Owner:** drmoisan
- **Last Updated:** 2026-03-04T23-07
- **Status:** Draft
- **Version:** 0.1

## Overview

The scaffold extension can already run extension-bundled automation against a destination workspace for commit context, but there is no equivalent command path for PR context generation. Today `scripts/dev_tools/pr_context/collector.py` is available only through repo-local script execution, which prevents validating the extension boundary in real destination repositories.

We need a first-class extension command that runs bundled `pr_context` resources from the extension installation while ensuring Git queries and artifact writes target the destination workspace repository. This feature also needs an explicit branch-selection UX so users can choose a comparison base branch instead of relying only on implicit defaults.


## Behavior

Add a new scaffold extension command (parallel to commit-context exposure) that executes the bundled `pr_context` collector in the active destination workspace.

At runtime, the command should:
- Validate exactly one destination workspace root target before execution (or fail with actionable guidance when no workspace is available).
- Resolve the bundled collector entrypoint from extension resources (for example `resources/scripts/dev_tools/pr_context/collector.py`) and never copy or materialize script files into the destination workspace root.
- Open a secondary branch-selection step (Quick Pick) after command invocation:
	- list deterministic candidate branches from destination repo refs,
	- preselect a deterministic default branch,
	- allow explicit user cancel that aborts execution without side effects.
- Execute collector process with `cwd` set to the destination workspace root so all Git/gh operations resolve against that repository.
- Invoke collector with explicit output flags for destination artifacts (`artifacts/pr_context.summary.txt` and `artifacts/pr_context.appendix.txt`) under the destination workspace.
- Log lifecycle events and failures to `Scaffold Utils` output channel with enough context to diagnose runtime, Git, and branch-selection failures.

Scope is limited to exposing `pr_context` execution and the branch-selection flow only (no additional authoring, review, or unrelated command UX).


## Inputs / Outputs

- Inputs (CLI flags, files, env vars)
	- Extension command ID: `scaffoldExtension.collectPrContext`.
	- Workspace input: exactly one destination workspace folder from VS Code workspace context.
	- Branch input: single branch selected from a secondary Quick Pick list.
	- Bundled collector entrypoint: extension resource path (`resources/scripts/dev_tools/pr_context/collector.py`) resolved from extension installation directory.
	- Collector CLI args passed by extension:
		- `--base <selected-branch>`
		- `--out artifacts/pr_context.summary.txt`
		- `--appendix-out artifacts/pr_context.appendix.txt`
	- Process context:
		- `cwd` is destination workspace root.
		- `shell: false` and explicit argv list.
	- Runtime prerequisite: Python runtime discoverable by existing extension runtime resolution path.
- Outputs (artifacts, logs, telemetry)
	- Destination artifacts (relative to destination workspace root):
		- `artifacts/pr_context.summary.txt`
		- `artifacts/pr_context.appendix.txt`
	- Output-channel logs in `Scaffold Utils`:
		- command start/end,
		- selected base branch,
		- runtime resolution failures,
		- branch discovery and cancellation outcomes,
		- collector exit status and stderr/stdout context on non-zero exits.
	- User-visible notifications:
		- success message on artifact generation,
		- actionable error messages on deterministic failure paths.
- Config keys and defaults:
	- No new persisted user/workspace settings introduced in this feature.
	- Default branch preselection is deterministic:
		1. `refs/remotes/origin/HEAD` symbolic target when available.
		2. Stable priority candidates from `origin/*` (for example `main`, `master`, `develop`, `trunk`, release-like refs), then lexicographic order.
		3. Deterministic local-branch fallback only when remote candidates are unavailable.
- Versioning or backward-compatibility constraints:
	- Existing commands remain unchanged.
	- Existing collector default behavior remains available for non-extension call paths.
	- Feature adds one new command and does not alter existing artifact contracts.

## API / CLI Surface

List commands, flags, request/response shapes, and examples.
- Extension command contribution:
	- Command ID: `scaffoldExtension.collectPrContext`
	- Command title: `Scaffold Utils: Collect PR Context`
	- Invocation path: Command Palette -> `Scaffold Utils: Collect PR Context` -> base-branch Quick Pick.
- Branch-selection contract:
	- Input shape: single branch name string.
	- Cancel shape: `undefined` result from Quick Pick.
	- Cancel semantics: abort before process spawn; do not mutate artifacts.
- Collector invocation contract:
	- Python entrypoint executed from extension resources (never destination copy).
	- Required args:
		- `--base <selected-branch>`
		- `--out artifacts/pr_context.summary.txt`
		- `--appendix-out artifacts/pr_context.appendix.txt`
	- Execution context: destination workspace root as `cwd`.
- Example invocations with expected outputs (concise):
	- Happy path: user selects `origin/main` -> process exits `0` -> two artifact files written under destination `artifacts/`.
	- Cancel path: user dismisses Quick Pick -> no process spawn -> no artifact changes.
	- Missing workspace path: command invoked without workspace -> immediate user error + output log -> no process spawn.
- Contracts and validation rules:
	- Must fail fast when workspace root is missing or ambiguous.
	- Must validate branch candidate list is non-empty before presenting default selection.
	- Must treat collector non-zero exit as command failure and log diagnostic context.

## Data & State

Data flow, storage, or state changes introduced by this feature.
- Data transformations and invariants:
	- Destination repo refs are transformed into Quick Pick items with stable ordering.
	- Exactly one selected branch value is forwarded as `--base`.
	- Artifact output paths remain fixed and relative to destination workspace root.
	- Invariant: execution source is extension-bundled script path; destination workspace is execution target only.
- Caching or persistence details:
	- No new persistent storage introduced.
	- Optional in-memory branch-candidate list exists only for the single command invocation lifecycle.
- Migration or backfill requirements (if any):
	- None. Existing repositories and generated artifacts remain compatible.

## Constraints & Risks

- Must preserve extension boundary: execution originates from extension-bundled resources while acting on destination workspace repo state.
- Branch discovery and defaulting must be deterministic across Windows/macOS/Linux and resilient when remotes/default branch metadata are incomplete.
- GitHub CLI or Git availability may differ between extension host environments; failures must be explicit and diagnosable.
- Multi-root workspace behavior must stay deterministic to avoid selecting the wrong repository root.
- Scope control: no unrelated UX expansion beyond exposing `pr_context` command + branch selection for comparison base.


## Implementation Strategy

- Implementation scope (what changes, not sequencing):
	- Add one new extension command that reuses the existing bundled-script execution boundary.
	- Add deterministic branch-candidate discovery and branch-selection Quick Pick flow.
	- Wire collector args/output contracts for destination workspace execution.
	- Add/extend tests for registration, branch UX behavior, spawn contracts, and deterministic failures.
- New classes/functions/commands to add or update:
	- `extensions/scaffold-extension/package.json`
		- Add command contribution for `scaffoldExtension.collectPrContext`.
	- `extensions/scaffold-extension/src/extension.ts`
		- Register new command.
		- Add helper to discover deterministic branch candidates.
		- Add helper to show base-branch Quick Pick with deterministic default and cancel semantics.
		- Invoke existing bundled-script executor with explicit PR-context args and destination `cwd`.
	- `extensions/scaffold-extension/test/extension.test.ts`
		- Add unit tests for command wiring, branch-selection behavior, no-workspace failure, and error logging.
	- `extensions/scaffold-extension/test/extension.integration.test.ts`
		- Add integration scenarios for destination artifact generation and no script materialization in destination root.
- Dependency changes (new/removed packages) and rationale:
	- None expected; implementation uses existing VS Code APIs and existing extension subprocess/runtime helpers.
- Logging/telemetry additions and locations:
	- Output channel: `Scaffold Utils`.
	- Required log points:
		- command invoked,
		- branch candidates discovered + default selected,
		- branch selection canceled,
		- runtime resolution status,
		- spawned collector argv/cwd (sanitized),
		- collector completion or failure context.
- Rollout plan (feature flags, staged deploys, fallback path):
	- No feature flag; command is additive.
	- Fallback behavior on failure is explicit user error + diagnostic logs; no silent retries.
	- Existing commit-context and other extension commands continue unchanged.

## Definition of Done

- [ ] Acceptance criteria documented and mapped to tests or demos (evidence target: updated `user-story.md` + test matrix entries below)
- [ ] Behavior matches acceptance criteria in all documented environments (evidence target: extension unit/integration test runs on supported host OS matrix)
- [ ] Tests updated/added (unit/integration as applicable) (evidence target: `extensions/scaffold-extension/test/extension.test.ts` and `extensions/scaffold-extension/test/extension.integration.test.ts`)
- [ ] Edge cases and error handling covered by tests (evidence target: no-workspace, cancel, runtime missing, Git probe failure, non-zero collector exit tests)
- [ ] Docs updated (README, docs/features/active/... links) (evidence target: this spec + user story + any command-list update if applicable)
- [ ] Telemetry/logging added or updated (if applicable) (evidence target: `Scaffold Utils` output assertions in unit tests)
- [ ] Toolchain pass completed (format → lint → type-check → test) (evidence target: CI/local command logs attached in implementation PR)

## Seeded Test Conditions (from potential)
- [ ] Unit coverage areas
	- [ ] Command contribution/registration and disposal behavior (`scaffoldExtension.collectPrContext` contributed and disposable tracked)
	- [ ] Workspace root validation and no-workspace failure path (assert no subprocess spawn)
	- [ ] Bundled `pr_context` script path resolution (extension install path, not workspace path)
	- [ ] Branch list retrieval, deterministic default selection, and cancel behavior (`showQuickPick` returns selection or `undefined`)
	- [ ] Spawn arguments include explicit `--base`, destination artifact paths, and destination `cwd`
	- [ ] Error logging assertions for runtime resolution, Git failures, and non-zero exits
- [ ] Integration scenarios
	- [ ] Destination repository happy-path run generates both PR-context artifacts
	- [ ] User-selected non-default branch is passed through and reflected in generated outputs/logs
	- [ ] Branch-selection cancel exits cleanly with no artifact writes
	- [ ] Workspace path with spaces/unicode preserves execution and output path guarantees
	- [ ] No bundled script materialization in destination workspace root
- [ ] CLI/API examples
	- [ ] Command Palette flow: `Scaffold Utils: Collect PR Context` -> branch picker -> success notification/log path
	- [ ] Failure examples: missing workspace, runtime missing, Git failure, branch-selection abort
