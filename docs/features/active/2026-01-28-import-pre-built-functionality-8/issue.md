# import-pre-built-functionality (Issue #8)

- Date captured: 2026-01-28
- Author: Dan Moisan
- Status: Promoted -> docs/features/active/import-pre-built-functionality/ (Issue #8)

- Issue: #8
- Issue URL: https://github.com/drmoisan/drm-copilot/issues/8
- Last Updated: 2026-02-04
## Problem / Why

This repo contains several useful utilities (scripts, tasks, and helper modules), but they are currently “local” to this workspace and not easily reusable across my broader VS Code-based workflows.

I want a single VS Code extension that consolidates these existing utilities and makes them available consistently across codebases (without copy/paste or manual setup). The immediate pain is discoverability and reuse; the longer-term risk is that utilities diverge, become hard to maintain, and are not exposed in a coherent, user-friendly way.

## Proposed Behavior

Create a VS Code extension that consolidates the existing utilities in this repo and exposes a curated subset as an MVP.

The epic focuses on:

- Consolidation: inventory and organize the existing utilities so they can be packaged and invoked from the extension.
- MVP exposure: expose **some** utilities (not necessarily all) via a stable, documented UX (commands/tasks/palettes) that works across workspaces.
- Strategy for full exposure: define and follow a scalable approach to expose the rest of the utilities over time (including any necessary refactoring or rewrites).
- Toolchain readiness: ensure the repo has a working MVP-quality build/lint/typecheck/test toolchain for both the extension and its utility code.

## Acceptance Criteria (early draft)

- [ ] A clear inventory exists of the “existing utilities” in this repo, grouped by category (e.g., tasks, scripts, helper modules) and labeled as: MVP-candidate, later-candidate, or deprecated.
- [ ] The extension packages the consolidated utilities such that they can be invoked from VS Code in any workspace without copying files into that workspace.
- [ ] The MVP exposes a **curated subset** of utilities through a stable surface (e.g., VS Code commands and/or tasks) with names, descriptions, and expected inputs/outputs documented.
- [ ] The MVP does **not** attempt to expose all utilities; there is an explicit “what’s included vs excluded” list.
- [ ] A documented strategy exists for exposing the remaining utilities over time (including criteria for refactor vs rewrite, and how new utilities are added to the extension).
- [ ] Repo quality gates needed for MVP development are operational and repeatable (format, lint, type-check, and tests) and are runnable via the existing VS Code tasks.
- [ ] Any refactoring/rewriting performed as part of consolidation preserves existing behavior (or documents intentional behavior changes) for the utilities that are included in the MVP.

## Constraints & Risks

- Scope risk: “Expose everything” is likely too large for MVP; the epic must keep strict boundaries between MVP exposure and future expansion.
- Compatibility risk: existing utilities may have assumptions about being run from this repo (paths, environment, dependencies) that need to be removed or encapsulated.
- UX risk: adding many commands without a coherent taxonomy could harm discoverability.
- Maintenance risk: refactoring/rewriting during consolidation could introduce regressions without targeted tests.
- Security risk: any utilities that shell out, read/write files, or interpret user-provided input must be surfaced with clear constraints and safe defaults.
- Packaging risk: some utilities may not be suitable for bundling as-is (size, runtime deps, platform specifics) and may require adapters.

## Test Conditions to Consider

- [ ] Unit: utilities selected for MVP can be invoked via their new consolidation layer with deterministic inputs/outputs.
- [ ] Unit: command registration and argument validation for each MVP-exposed command.
- [ ] Integration: running the extension in an Extension Host can invoke MVP utilities without relying on the current repo being the active workspace.
- [ ] Integration: failure modes are user-actionable (missing prerequisites, unsupported platform, invalid inputs).
- [ ] Examples: include copy/paste-able “how to run” examples for each MVP command/task (inputs, outputs, expected side effects).

## Next Step

- [ ] Promote to GitHub issue (feature request template)
- [ ] Create `docs/features/active/import-pre-built-functionality/` folder from the template
