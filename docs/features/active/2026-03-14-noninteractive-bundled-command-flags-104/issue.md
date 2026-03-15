# noninteractive-bundled-command-flags (Issue #104)
title: "noninteractive-bundled-command-flags - Plan"
issue: "TBD"
parent: "none"
owner: "Dan Moisan"
last_updated: "2026-03-14T22-57"
status: "Draft"
status_color: "lightgrey"
version: "0.1"
---

# noninteractive-bundled-command-flags (Potential)

- Date captured: 2026-03-14
- Author: Dan Moisan
- Status: Promoted -> docs/features/active/noninteractive-bundled-command-flags/ (Issue #104)

- Issue: #104
- Issue URL: https://github.com/drmoisan/drm-copilot/issues/104
- Last Updated: 2026-03-15
- Work Mode: full-feature

## Problem / Why

The extension now exposes real bundled commands for creating potential entries, promoting potential docs to issues, and creating active feature folders, but the command surface is optimized for humans clicking through input boxes and quick picks. That is convenient for interactive use, yet suboptimal for agentic invocation because orchestrators cannot reliably drive menu prompts or UI dialogs. This feature should add explicit non-interactive arguments/flags so orchestrators can call the same workflows directly, deterministically, and without prompt handling.

## Proposed Behavior

Keep the current human-friendly command palette experience as the default interactive path, but add direct-invocation variants that accept explicit arguments for all required inputs. The bundled command workflows for new potential entries, potential-to-issue promotion, and active feature folder creation should support flag-driven execution so orchestrator agents can invoke them without UI/menu interaction.

At a high level:

1. **New Potential Entry / New Potential Bug Entry** should accept the short name as an explicit argument instead of always prompting.
2. **Potential To Issue** should accept the potential doc path, promotion type, and work mode as explicit arguments instead of requiring file pickers and quick picks.
3. **New Active Feature Folder** should accept feature name, type, issue number, and work mode as explicit arguments instead of requiring prompt-driven collection.
4. **Orchestrator agents** should be updated to call the direct-invocation variants so they can run the workflow end to end without pausing for UI.

The expected outcome is a bundled command surface that still works well for people in the command palette, but also exposes deterministic, non-interactive invocation paths for automation.

## Acceptance Criteria (early draft)

- [ ] Bundled commands for new potential entry creation, potential doc promotion, and active feature folder creation accept explicit arguments for all required inputs and can run without showing input boxes, quick picks, or file dialogs when those arguments are provided
- [ ] Interactive command palette behavior remains available for human users when explicit arguments are not supplied
- [ ] Orchestrator agent docs/resources are updated to use the non-interactive direct-invocation path instead of relying on prompt-driven UI flows
- [ ] Direct invocation validates required arguments and fails with clear, actionable errors when required values are missing or invalid
- [ ] Existing command registrations and bundled script entrypoints are updated consistently so the same underlying workflows support both interactive and non-interactive execution paths
- [ ] Relevant extension and orchestration tests cover successful flag-driven execution, interactive fallback behavior, and invalid-argument handling

## Constraints & Risks

- The interactive command surface is already useful for humans, so the change should extend it rather than replace it.
- Command argument shapes must stay aligned across extension command registrations, bundled script entrypoints, and orchestrator documentation to avoid drift.
- Non-interactive invocation needs clear validation rules so orchestrators fail fast instead of hanging on unexpected prompts.
- Touched areas will likely include extension command registrations, bundled script entrypoints/templates, orchestrator agent docs/resources, and relevant extension/orchestrator tests.
- Backward compatibility matters for existing interactive users; prompt-based flows should continue to work when no explicit arguments are passed.

## Test Conditions to Consider

- [ ] Unit coverage for command argument parsing, direct-invocation routing, and prompt-skipping behavior when explicit arguments are present
- [ ] Integration scenarios where orchestrator-facing commands create a potential entry, promote a potential doc, and create an active feature folder without any UI interaction
- [ ] CLI/API examples showing the explicit arguments for each workflow and the expected validation/error behavior for missing or invalid flags

## Next Step

- [ ] Promote to GitHub issue (feature request template)
- [ ] Create `docs/features/active/noninteractive-bundled-command-flags/` folder from the template