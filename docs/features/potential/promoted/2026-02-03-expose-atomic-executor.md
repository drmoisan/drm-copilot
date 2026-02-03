---
title: "expose-atomic-executor - Issue"
issue: "6"
parent: "none"
owner: "Dan Moisan"
last_updated: "2026-02-03T14-38"
status: "Promoted"
status_color: "blue"
version: "0.1"
---

# expose-atomic-executor (Issue #6)

- Date captured: 2026-02-03
- Author: Dan Moisan
- Status: Promoted -> docs/features/active/expose-atomic-executor/ (Issue #6)

- Issue: #6
- Issue URL: https://github.com/drmoisan/drm-copilot/issues/6
- Last Updated: 2026-02-03
## Problem / Why

The extension currently exposes `atomic_executor` by running it via a workspace task that assumes the destination repo is this repo (or has the same Poetry environment, `pyproject.toml`, and `scripts/` Python package layout).

This does not scale to “execute plans in an arbitrary destination repo” because many repos will not have Poetry installed, will not have `scripts.dev_tools.atomic_executor` available on `PYTHONPATH`, and may not have the expected prompt template paths.

We want a reliable, extension-owned way to run the atomic executor against the currently-open workspace (or a selected workspace folder) without requiring the repo to vendor DRM Copilot tooling.

## Proposed Behavior

Expose `atomic_executor` as a first-class extension command that can execute an atomic plan against a selected destination repo.

High-level flow:

- The user invokes a command like “DRM Copilot: Atomic Executor (execute plan…)”.
- The extension prompts the user to select:
	- The target workspace folder (for multi-root workspaces).
	- A feature folder path or a specific plan file path.
	- The preferred model (optional) and key execution knobs (at minimum `--max-fix-attempts`).
- The extension runs `atomic_executor` as an extension-bundled “sidecar tool”:
	- Uses a user-selected or auto-detected Python interpreter on the extension host.
	- Executes `python -m scripts.dev_tools.atomic_executor.cli execute-all ...`.
	- Sets `cwd` to the destination repo root.
	- Sets `PYTHONPATH` (or equivalent) so the Python process imports the executor code from the extension install directory, not from the destination repo.
	- Always passes `--workspace <destination repo root>`.
- Output is streamed to a terminal/task output, and cancellation is supported via VS Code task cancellation.

Template handling:

- If the destination repo has `.github/prompts/execute-plan-template.md`, the tool may use it.
- Otherwise, the extension should prefer a bundled template (or fail with a clear, actionable error explaining how to add the template).

Safety/compatibility behavior:

- The command is disabled or blocked in environments where spawning processes is not supported (web extension host / `vscode.dev`).
- The command is blocked when the workspace is untrusted (Workspace Trust), with guidance on how to trust it.
- Before launching, the extension shows an explicit confirmation including:
	- Destination repo root
	- Selected plan/feature path
	- Key flags (model, max-fix-attempts, allow-shell / trust-workspace settings)

## Acceptance Criteria (early draft)

- [ ] Running “Atomic Executor (execute plan…)” against a destination repo does not require that repo to have Poetry, `pyproject.toml`, or `scripts.dev_tools.atomic_executor` present.
- [ ] The executor is launched using a Python interpreter resolved by the extension (setting + auto-detect fallback), and failures show actionable guidance (e.g., “Python not found; configure drm-copilot.pythonPath”).
- [ ] The extension sets the process environment so imports resolve from the extension bundle (e.g., `PYTHONPATH=<extensionRoot>`), and execution uses `cwd=<destination repo root>`.
- [ ] The extension always passes `--workspace <destination repo root>` so plan execution targets the selected repo, independent of where the plan file is located.
- [ ] In a multi-root workspace, the user is prompted to pick which workspace folder is the destination repo, and that selection is honored.
- [ ] If the destination repo does not contain the default prompt template path, the command either:
	- uses the extension-bundled template by passing `--prompt-template <extensionPath>/...`, or
	- fails fast with a message describing how to add/locate the template.
- [ ] The command is blocked when Workspace Trust is disabled for the folder, with a clear message explaining why and how to enable trust.
- [ ] The command is unavailable (or shows a “not supported” message) when running in the web extension host where child processes cannot be created.
- [ ] Output is streamed to a VS Code terminal/task output and includes enough context to diagnose failures (resolved repo root, selected plan path, key args).

## Constraints & Risks

- VS Code Web / `vscode.dev` limitation: cannot spawn processes; this feature is desktop/remote only.
- Interpreter availability: the extension host must have Python available. Auto-detection may be brittle on some systems; a user-configured setting is required.
- Remote environments (SSH/WSL/Codespaces): the Python interpreter must be on the remote extension host, not only on the local machine.
- Packaging risk: `.vscodeignore` may exclude `.github/**` or other resources needed by `atomic_executor` (prompt templates, etc.). Packaging must be validated.
- Security/safety: `atomic_executor` can run shell commands and modify the repo. Require Workspace Trust and show an explicit confirmation before execution.
- Dependency assumptions: the executor can invoke tools like `git`, `npm`, `poetry`, `gh`, etc. Destination repos may not have these tools installed; errors must be clear and should fail fast.
- Performance: executor runs QC loops (format/lint/typecheck/tests) and may be long-running; cancellation and progress visibility are important.

## Test Conditions to Consider

- [ ] Unit coverage areas
	- [ ] Token/arg resolution for destination repo paths (workspace root, plan path, prompt template override).
	- [ ] Python interpreter resolution logic (setting → PATH fallback → failure messaging).
	- [ ] Environment construction for subprocess/task execution (ensuring `PYTHONPATH` is set and merged correctly).
	- [ ] Workspace trust gating logic.
	- [ ] Web/virtual workspace gating logic (feature hidden/blocked appropriately).
- [ ] Integration scenarios
	- [ ] Run against a non-DRM repo that has no Poetry config; verify executor still starts and can locate the plan.
	- [ ] Run in multi-root workspace and confirm the chosen folder is used as `cwd` and `--workspace`.
	- [ ] Run in Remote SSH/WSL (if supported in CI/dev) with a configured Python path.
	- [ ] Missing template scenario: destination repo lacks `.github/prompts/execute-plan-template.md` and the extension uses bundled template (or fails with guidance).
	- [ ] Python missing scenario: command fails with actionable remediation.
	- [ ] Workspace untrusted scenario: command is blocked.
- [ ] CLI/API examples
	- [ ] Example invocation (conceptual):
		- `python -m scripts.dev_tools.atomic_executor.cli execute-all <feature-or-plan> --workspace <repoRoot> --preferred-model <model> --max-fix-attempts 10`
	- [ ] Example environment:
		- `PYTHONPATH=<extensionInstallRoot>`

## Next Step

- [ ] Promote to GitHub issue (feature request template)
- [ ] Create `docs/features/active/expose-atomic-executor/` folder from the template
- [ ] Identify and document the minimal packaged resources required by the executor (Python package files + prompt template(s)).
- [ ] Decide on template strategy: require repo-local template vs ship bundled template (default to bundled for portability).
- [ ] Decide on interpreter strategy: setting-only vs setting + auto-detect (recommend setting + auto-detect).
