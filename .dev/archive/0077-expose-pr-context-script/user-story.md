# `2026-03-04-expose-pr-context-script` — User Story

- Issue: #77
- Owner: drmoisan
- Status: Draft
- Last Updated: 2026-03-04T23-07

## Story Statement

- As a repository maintainer using the scaffold extension in a destination repo, I want a Command Palette command that runs PR context collection from extension-bundled resources, so that I can generate PR summary artifacts without copying scripts into the destination workspace.
- As a reviewer preparing comparison context, I want to explicitly select the PR base branch from a deterministic branch list before execution, so that generated context is predictable and aligned to the intended review target.

## Problem / Why

The scaffold extension can already run extension-bundled automation against a destination workspace for commit context, but there is no equivalent command path for PR context generation. Today `scripts/dev_tools/pr_context/collector.py` is available only through repo-local script execution, which prevents validating the extension boundary in real destination repositories.

We need a first-class extension command that runs bundled `pr_context` resources from the extension installation while ensuring Git queries and artifact writes target the destination workspace repository. This feature also needs an explicit branch-selection UX so users can choose a comparison base branch instead of relying only on implicit defaults.


## Personas & Scenarios

- Persona: Extension-enabled repository maintainer
  - Works in VS Code with the scaffold extension installed and opens external destination repositories for review prep.
  - Cares about deterministic, repeatable PR context output and clear failure diagnostics.
  - Is constrained by mixed host environments (Windows/macOS/Linux), variable Git/Python availability, and repositories with different branch conventions.
  - Wants one command flow that reliably targets the opened destination workspace and never pollutes repo root with copied tooling scripts.
- Scenario: Collect PR context against a selected base branch
  - Trigger: The maintainer opens a destination repository and runs `Scaffold Utils: Collect PR Context` from the Command Palette.
  - Step 1: The command validates workspace state and resolves the extension-bundled collector entrypoint.
  - Step 2: A branch-selection quick pick appears with deterministic candidates and a deterministic default preselection.
  - Step 3: The maintainer either confirms a branch (continue) or cancels (clean abort).
  - Decision/Obstacle: If runtime or Git probing fails, the maintainer receives actionable error text and structured output-channel logs.
  - Expected outcome: On success, `artifacts/pr_context.summary.txt` and `artifacts/pr_context.appendix.txt` are created in the destination workspace; no collector script is materialized in destination root.


## Acceptance Criteria

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


## Non-Goals

- Changing Python collector business logic in `scripts/dev_tools/pr_context/*` beyond consuming existing supported flags.
- Adding multi-branch comparison, multi-select branch UX, or advanced filtering beyond single-base selection.
- Introducing new artifact formats, alternate artifact destinations, or telemetry systems outside existing `Scaffold Utils` output logging.
- Expanding unrelated extension UX or automation commands (commit context, issue authoring, remediation flows, or policy-audit generation).
