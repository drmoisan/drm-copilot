# `2026-03-14-bundle-hard-lock-resolver-into-extension` — User Story

- Issue: #103
- Owner: drmoisan
- Status: Draft
- Last Updated: 2026-03-14T22-49

## Story Statement

- As a developer using the `drm-copilot` extension in a workspace that is not this repository, I want to run an extension command that resolves the execute hard-lock prompt for a selected feature plan, so that I can use the same guided execution flow without manually copying Python scripts or prompt templates into the workspace.
- As a maintainer of the repo-root developer tooling, I want the extension command to delegate to synchronized bundled copies of the existing Python resolver and hard-lock prompt templates, so that the root script and root prompt files remain the single source of truth and extension behavior does not drift into a second implementation.

## Problem / Why

The hard-lock prompt workflow already exists, but today it is trapped in repo-root tooling that assumes local `.github/codex` assets are present. That makes the extension less useful in other workspaces and nudges future work toward reimplementing the resolver in TypeScript or wrapper code.

This feature removes that gap by packaging synchronized extension-side copies of the canonical Python resolver and hard-lock prompt templates. The goal is reuse, not reinvention: the extension should expose the same resolved execute prompt flow while the root Python and root templates remain the authoring sources.


## Personas & Scenarios

- Persona: Extension-driven feature implementer
  - A developer working in VS Code who uses the `drm-copilot` extension to follow the repo's feature execution workflows.
  - Cares about getting a ready-to-paste execute prompt quickly from the current plan file without leaving the editor.
  - Often works in a workspace that does not contain this repository's root `.github/codex` directory or Python helper scripts.
  - Wants the extension command to behave predictably on Windows paths and feature-folder layouts such as `docs/features/active/<feature>/v2/plan.md`.
  - Gets frustrated when an extension command depends on hidden repo-local files that are not packaged with the extension.
- Persona: Tooling maintainer
  - A maintainer responsible for the Python developer tooling and the VS Code extension packaging contract.
  - Cares about keeping one canonical resolver implementation and one canonical set of prompt templates.
  - Must avoid logic drift between repo-root scripts, bundled extension copies, and wrapper entrypoints.
  - Wants any extension adaptation to be limited to bootstrapping concerns such as resource lookup and runtime argument injection.
- Scenario: Resolve execute hard-lock prompt from the extension in a non-repo workspace
  - A developer opens a feature plan in VS Code and decides to use the hard-lock execute workflow from the command palette.
  - The extension first checks whether the active editor is already a Markdown file under `docs/features/active/`; if so, it reuses that path. Otherwise it prompts the user to choose a plan file from `docs/features/active/`.
  - After the user confirms a target plan, the extension launches the bundled wrapper, passing only `--target` and `--workspace`.
  - The wrapper injects the bundled codex template root and delegates to the bundled Python resolver.
  - The resolver reads the synchronized hard-lock prompt template, resolves `${plan-path}`, `${work-mode}`, and `${fallback-reason}`, prints the completed prompt, and attempts clipboard copy.
  - The developer receives a prompt suitable for immediate paste into chat even though the workspace itself does not contain repo-root `.github/codex` assets.
- Scenario: Maintain canonical sources while adding extension support
  - A maintainer updates the root resolver or one of the root hard-lock templates.
  - The extension packaging flow mirrors those files into bundled resources instead of adding a custom extension-only resolver branch.
  - Tests fail if the command wiring, template-root seam, or bundled resource contract no longer matches the root implementation.
  - The maintainer can evolve the resolver in one place while keeping the extension bundle synchronized and testable.


## Acceptance Criteria

- [x] `extensions/drm-copilot/package.json` contributes `drmCopilotExtension.resolveExecuteHardLockPrompt`, and `extensions/drm-copilot/src/extension.ts` registers a matching handler that reuses an active feature-plan editor when possible or otherwise prompts from `docs/features/active/`, then passes `--target <selected-plan>` and `--workspace <workspace-root>` to the bundled wrapper.
- [x] `extensions/drm-copilot/resources/templates/resolve_hard_lock_prompt.py` remains a thin wrapper that only bootstraps `resources/scripts` onto `sys.path`, injects `--template-root` pointing at bundled codex assets when absent, imports `dev_tools.resolve_hard_lock_prompt`, and delegates to its `main()` function without duplicating prompt-resolution logic.
- [x] The extension package includes synchronized bundled copies of `scripts/dev_tools/resolve_hard_lock_prompt.py`, `.github/codex/execute-hard-lock.prompt.md`, and `.github/codex/resume-hard-lock.prompt.md` under the existing extension resource layout so prompt resolution works in workspaces that do not contain repo-local `.github/codex` assets.
- [x] `scripts/dev_tools/resolve_hard_lock_prompt.py` adds an optional `--template-root` seam that checks the supplied template root first, then falls back to `<workspace>/.github/codex`, while preserving existing `--template-kind`, plan-path normalization, work-mode lookup, fallback-reason substitution, stdout output, and best-effort clipboard behavior.
- [x] The extension command produces the same resolved execute prompt content as the root Python resolver for the same target plan, including forward-slash `${plan-path}` output and deterministic work-mode behavior for versioned plan folders such as `v2`.
- [x] Missing target files, missing Python runtime, or missing bundled template assets fail with clear errors and do not produce partial or misleading success output.


## Non-Goals

- Rewriting hard-lock prompt resolution in TypeScript, Node.js, or wrapper-specific Python logic.
- Replacing or deprecating the repo-root CLI workflow in `scripts/dev_tools/resolve_hard_lock_prompt.py`.
- Removing the Python runtime requirement for extension-side execution.
- Adding a separate user-facing resume hard-lock command in this change; the bundled resume template is included to preserve resolver contract parity, not to expand the command surface yet.
- Introducing a new packaging system, live sync daemon, or extension-managed authoring source for hard-lock templates.
