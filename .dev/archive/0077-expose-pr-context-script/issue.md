# expose-pr-context-script (Issue #77)
title: "expose-pr-context-script - Plan"
issue: "TBD"
parent: "none"
owner: "Dan Moisan"
last_updated: "2026-03-04T23-06"
status: "Draft"
status_color: "lightgrey"
version: "0.1"
---

# expose-pr-context-script (Potential)

- Date captured: 2026-03-04
- Author: Dan Moisan
- Status: Promoted -> docs/features/active/expose-pr-context-script/ (Issue #77)

- Issue: #77
- Issue URL: https://github.com/drmoisan/drm-copilot/issues/77
- Last Updated: 2026-03-05
- Work Mode: full

## Problem / Why

The scaffold extension can already run extension-bundled automation against a destination workspace for commit context, but there is no equivalent command path for PR context generation. Today `scripts/dev_tools/pr_context/collector.py` is available only through repo-local script execution, which prevents validating the extension boundary in real destination repositories.

We need a first-class extension command that runs bundled `pr_context` resources from the extension installation while ensuring Git queries and artifact writes target the destination workspace repository. This feature also needs an explicit branch-selection UX so users can choose a comparison base branch instead of relying only on implicit defaults.

## Proposed Behavior

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

## Acceptance Criteria (early draft)

- [ ] Extension contributes a discoverable Command Palette command for PR context collection (for example `drmCopilotExtension.collectPrContext`) with clear title/description aligned to existing scaffold commands.
- [ ] Command validates destination workspace root before runtime probing; if no workspace is open, the command fails fast with actionable error text and does not spawn a process.
- [ ] Command resolves and executes only extension-bundled `pr_context` script resources; no collector script files are created in the destination workspace root.
- [ ] Command presents a secondary branch-selection UX that lists branch candidates from the destination repository and preselects a deterministic default base branch.
- [ ] Deterministic default branch behavior is defined and testable (for example: repository default remote branch when available; otherwise stable fallback ordering), and is used when user confirms without changing selection.
- [ ] Canceling the branch-selection UI deterministically aborts execution with no artifact mutation and no spawned collector process.
- [ ] Collector execution always uses destination workspace root as process `cwd`, and all relative paths/CLI arguments resolve against that destination repository.
- [ ] Collector writes artifacts under destination workspace at `artifacts/pr_context.summary.txt` and `artifacts/pr_context.appendix.txt`.
- [ ] Command guarantees destination-artifact output paths even when workspace path contains spaces or unicode characters.
- [ ] Command never materializes bundled script payloads in destination workspace root as a staging step.
- [ ] Runtime resolution failures (for Python), Git command failures, and invalid/missing branch-selection state surface actionable user errors and structured output-channel logs.
- [ ] Non-zero collector exit codes propagate as command failure with stderr/stdout context captured in `Scaffold Utils` logs.
- [ ] Unit tests cover command contribution/registration, workspace validation, bundled path resolution, branch-candidate loading/defaulting, cancel handling, spawn args, and destination `cwd` guarantees.
- [ ] Integration tests cover end-to-end command flow in a fixture repository, including branch selection, destination artifact generation, and no script materialization in destination workspace root.

## Constraints & Risks

- Must preserve extension boundary: execution originates from extension-bundled resources while acting on destination workspace repo state.
- Branch discovery and defaulting must be deterministic across Windows/macOS/Linux and resilient when remotes/default branch metadata are incomplete.
- GitHub CLI or Git availability may differ between extension host environments; failures must be explicit and diagnosable.
- Multi-root workspace behavior must stay deterministic to avoid selecting the wrong repository root.
- Scope control: no unrelated UX expansion beyond exposing `pr_context` command + branch selection for comparison base.

## Test Conditions to Consider

- [ ] Unit coverage areas
	- [ ] Command contribution/registration and disposal behavior
	- [ ] Workspace root validation and no-workspace failure path
	- [ ] Bundled `pr_context` script path resolution (extension install path, not workspace path)
	- [ ] Branch list retrieval, deterministic default selection, and cancel behavior
	- [ ] Spawn arguments include explicit `--base`, destination artifact paths, and destination `cwd`
	- [ ] Error logging assertions for runtime resolution, Git failures, and non-zero exits
- [ ] Integration scenarios
	- [ ] Destination repository happy-path run generates both PR-context artifacts
	- [ ] User-selected non-default branch is passed through and reflected in generated outputs/logs
	- [ ] Branch-selection cancel exits cleanly with no artifact writes
	- [ ] Workspace path with spaces/unicode preserves execution and output path guarantees
	- [ ] No bundled script materialization in destination workspace root
- [ ] CLI/API examples
	- [ ] Command Palette flow: `Scaffold: Collect PR Context` -> branch picker -> success notification/log path
	- [ ] Failure examples: missing workspace, runtime missing, Git failure, branch-selection abort

## Next Step

- [ ] Promote to GitHub issue (feature request template)
- [ ] Create `docs/features/active/expose-pr-context-script/` folder from the template