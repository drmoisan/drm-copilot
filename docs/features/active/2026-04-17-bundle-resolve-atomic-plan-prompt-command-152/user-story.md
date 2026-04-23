# `bundle-resolve-atomic-plan-prompt-command` — User Story

- Issue: #152
- Owner: drmoisan
- Status: Draft
- Last Updated: 2026-04-17T19-54

## Story Statement

- As a repository maintainer using the extension command surface, I want to resolve the atomic-plan prompt from the active plan file, so that I can copy the exact planner prompt without running the repo-only VS Code task.
- As a user working in a destination workspace with only the extension installed, I want the same atomic-plan prompt workflow to run from bundled assets, so that I do not need `poetry`, repo-local scripts, or repository-specific setup.

## Problem / Why

The repository currently exposes `Dev: Resolve Atomic Plan Prompt` only as a VS Code task that shells out through `poetry run python scripts/dev_tools/resolve_file_prompt.py` with the repo-local `.github/prompts/generate-atomic-plan.prompt.md` template. That works inside this repository, but it does not provide the same capability in a destination workspace that only has the extension installed. The gap is that there is no bundled extension command equivalent for resolving the atomic-plan prompt from the active plan file and copying the resolved prompt to the clipboard without depending on repo-local scripts or extra setup.


## Personas & Scenarios

- Persona: Extension-driven feature maintainer
  - Works on feature folders and plan documents inside VS Code.
  - Cares about getting the exact atomic-plan prompt content that matches the repository's current planner workflow.
  - Often switches between this repository and destination workspaces where repo-local tasks and Python setup may not exist.
  - Wants a command that works from the active plan file with minimal decisions and clear failure messages when the file context is wrong.
  - Is frustrated by workflows that depend on local scripts or that silently accept the wrong markdown file.
- Persona: Destination-workspace extension user
  - Uses the published extension outside this repository.
  - Cares about command parity with repository automation features that are already bundled into the extension.
  - Cannot assume `.vscode/tasks.json`, `poetry`, or `scripts/dev_tools/resolve_file_prompt.py` exist in the current workspace.
  - Wants the extension to carry everything required to resolve and copy the planner prompt.
- Scenario: Resolve the atomic-plan prompt from an active plan
  - The extension-driven feature maintainer has `plan.md` open inside `docs/features/active/2026-04-17-bundle-resolve-atomic-plan-prompt-command-152/` and needs the planner prompt for the next workflow step.
  - They invoke the new `Resolve Atomic Plan Prompt` command from the extension command surface.
  - The command validates that the active file is a plan markdown file, uses bundled prompt and resolver resources, and resolves the prompt using the same document-discovery and work-mode rules as the existing repo task.
  - The resolved prompt is copied to the clipboard so the maintainer can paste it into the downstream planner workflow immediately.
  - If the maintainer instead has `spec.md` or `issue.md` open, the command stops with an actionable message telling them to open or select a valid plan markdown file.


## Acceptance Criteria

- [x] The extension contributes a new `drmCopilotExtension.resolveAtomicPlanPrompt` command that resolves the atomic-plan prompt without invoking `poetry`, `.vscode/tasks.json`, repo-local scripts, or workspace-local installation steps
- [x] When the active editor is an eligible plan markdown file under `docs/features/active/**`, invoking the command resolves the bundled atomic-plan prompt template against that plan and copies the resolved prompt to the clipboard
- [x] The command uses bundled prompt and resolver resources so the output behavior stays aligned with the current `resolve_file_prompt.py` task semantics in a destination workspace that only has the extension installed
- [x] If the active editor is missing, cancelled, or points to `issue.md`, `spec.md`, `user-story.md`, or another ineligible markdown file, the command stops with a clear, actionable error instead of silently succeeding
- [x] Extension tests cover command registration, eligible-plan resolution, invalid-target rejection, bundled-service invocation, and bundled-resource wiring for the new command


## Non-Goals

- Replacing or removing the existing repository-local `Dev: Resolve Atomic Plan Prompt` task.
- Refactoring unrelated document-workflow commands or changing the broader extension command architecture.
- Changing the atomic-plan prompt template contract, placeholder semantics, or work-mode rules beyond what is required to bundle the existing behavior.
- Supporting non-plan documents such as `issue.md`, `spec.md`, `user-story.md`, or arbitrary markdown files as valid targets for this command.
- Expanding scope to a broader MCP-surface refactor unless that parity work is explicitly approved separately.
