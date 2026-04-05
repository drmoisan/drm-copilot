# `2026-03-14-noninteractive-bundled-command-flags` — User Story

- Issue: #104
- Owner: drmoisan
- Status: Draft
- Last Updated: 2026-03-14T22-59

## Story Statement

- As a repository orchestrator agent, I want to invoke the bundled workflow commands with explicit flags, so that I can create potential entries, promote them, and scaffold active feature folders without blocking on VS Code UI prompts.
- As a human maintainer using the Command Palette, I want the same commands to keep their current interactive prompts when I do not provide arguments, so that automation improves without making manual use clunkier.

## Problem / Why

The bundled workflows already exist, but their extension entrypoints currently assume a person is available to answer input boxes, quick picks, and file dialogs. That breaks deterministic orchestration because automated callers cannot reliably drive those UI interactions and should fail fast when inputs are incomplete instead of hanging for prompts.

This feature adds a direct, flag-driven invocation contract to the existing command IDs while preserving the current interactive fallback for humans. The impact is faster and more reliable orchestration with no regression to the manual Command Palette experience.


## Personas & Scenarios

- Persona: Orchestrator maintainer
  - Maintains `.github/agents/` flows and the mirrored bundled customizations that drive multi-step feature and bug delivery.
  - Cares about deterministic execution, explicit contracts, and failure modes that are machine-readable enough to debug quickly.
  - Cannot depend on interactive VS Code controls because orchestrated runs may execute unattended or through command-execution surfaces that only pass argument arrays.
  - Wants one supported path that uses the bundled extension commands instead of duplicating raw script invocations across multiple agent docs.
  - Is frustrated by workflows that silently fall back to prompts when a required value is missing.
- Persona: Human repository contributor
  - Uses the Command Palette to run repository helpers during day-to-day feature work.
  - Cares about low-friction prompts, not having to remember every flag shape, and keeping existing commands discoverable.
  - Expects manual cancellation to remain a safe no-op.
  - Wants automation improvements to be additive rather than a forced CLI-only workflow.
- Scenario: Orchestrated large-path feature promotion without UI
  - The acting user is an orchestrator agent following the repo’s feature workflow.
  - The trigger is a promoted potential feature that needs issue creation and active-folder scaffolding.
  - The agent invokes `drmCopilotExtension.newPotentialEntry` or `drmCopilotExtension.newPotentialBugEntry` with a short-name flag, then invokes `drmCopilotExtension.potentialToIssue` with the potential doc path, promotion type, and explicit work mode, and finally invokes `drmCopilotExtension.newActiveFeatureFolder` with the long feature name, type, issue number, and work mode.
  - The key decision point is whether all required flags are present and valid; if not, the command must fail immediately with an actionable validation error instead of opening UI.
  - The expected outcome is end-to-end workflow execution with no `showInputBox`, `showQuickPick`, or `showOpenDialog` calls and with the same bundled scripts/artifacts used by the interactive flow.
- Scenario: Manual Command Palette use by a maintainer
  - The acting user is a human maintainer running the command from the VS Code Command Palette.
  - The trigger is an ad hoc need to create or promote a feature document without memorizing flags.
  - The maintainer runs the existing command with no arguments, answers the prompts, and can cancel at any step.
  - The only decision is the same one they have today: choose the desired type/path/work mode through the UI.
  - The expected outcome is unchanged prompt-driven behavior and no requirement to learn the new direct-mode contract unless they want automation.


## Acceptance Criteria

- [x] When invoked with required direct arguments, `drmCopilotExtension.newPotentialEntry`, `drmCopilotExtension.newPotentialBugEntry`, `drmCopilotExtension.potentialToIssue`, and `drmCopilotExtension.newActiveFeatureFolder` execute without calling `showInputBox`, `showQuickPick`, or `showOpenDialog`.
- [x] When invoked with no arguments from the Command Palette, the same four command IDs keep their existing interactive prompt behavior, and user cancellation still aborts without launching the bundled script.
- [x] Root orchestrator docs under `.github/agents/` and mirrored customization docs under `extensions/drm-copilot/resources/customizations/.github/agents/` are updated to use the existing extension command IDs with explicit flag arrays and explicit work-mode values.
- [x] Direct invocation rejects unknown flags, duplicate flags, missing required flags, invalid short names, invalid feature names, invalid promotion types, invalid work modes, and non-digit issue numbers with clear errors and without falling back to interactive prompts.
- [x] `extensions/drm-copilot/package.json` continues to expose only the current public workflow command IDs, and the bundled script entrypoints remain the execution backend for both interactive and non-interactive modes.
- [x] Extension tests cover successful flag-driven execution, prompt-skipping behavior, interactive fallback behavior, and invalid-argument handling in `extensions/drm-copilot/test/extension.test.ts`, `extension.potential-to-issue.test.ts`, and `extension.new-active-feature-folder.test.ts`.


## Non-Goals

- Introducing new public VS Code command IDs for “direct” variants of the workflows.
- Replacing or removing the existing prompt-driven Command Palette experience for human users.
- Rewriting the underlying Python or PowerShell workflow engines beyond the minimal contract-alignment change needed for `scripts/dev-tools/new-potential-entry.ps1`.
- Changing the output artifact shapes produced by the existing potential-entry, promotion, or active-folder scripts.
- Adding new settings, feature flags, external telemetry systems, or unrelated orchestrator workflow redesigns.
