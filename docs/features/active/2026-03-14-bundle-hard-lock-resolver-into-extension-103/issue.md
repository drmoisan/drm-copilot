# bundle-hard-lock-resolver-into-extension (Issue #103)
title: "bundle-hard-lock-resolver-into-extension - Plan"
issue: "TBD"
parent: "none"
owner: "Dan Moisan"
last_updated: "2026-03-14T22-47"
status: "Draft"
status_color: "lightgrey"
version: "0.1"
---

# bundle-hard-lock-resolver-into-extension (Potential)

- Date captured: 2026-03-14
- Author: Dan Moisan
- Status: Promoted -> docs/features/active/bundle-hard-lock-resolver-into-extension/ (Issue #103)

- Issue: #103
- Issue URL: https://github.com/drmoisan/drm-copilot/issues/103
- Last Updated: 2026-03-15
- Work Mode: full-feature

## Problem / Why

The hard-lock prompt resolver currently lives only in the repo-root developer tooling, so the VS Code extension cannot offer the same workflow in other workspaces unless users manually copy scripts and prompt templates around. That limits reuse of an already-supported flow and creates pressure to reimplement the behavior inside the extension, which would risk drift from the existing single-source-of-truth Python logic and prompt content.

## Proposed Behavior

Add an extension command that invokes a bundled thin Python wrapper for hard-lock prompt resolution, following the same pattern already used for bundled promotion and scaffolding scripts. The wrapper should delegate in-process to bundled `dev_tools` logic sourced from `scripts/dev_tools/resolve_hard_lock_prompt.py`, use a bundled copy of the execute-hard-lock prompt template sourced from `.github/codex/execute-hard-lock.prompt.md`, and make the existing resolved prompt flow available from the extension in non-repo workspaces without duplicating business logic.

## Acceptance Criteria (early draft)

- [ ] The extension registers a dedicated command for resolving the execute hard-lock prompt and passes the selected target plan path, workspace context, and any required template-selection inputs to a bundled wrapper entry point.
- [ ] The extension ships a thin wrapper under `extensions/drm-copilot/resources/templates/` that contains only runtime bootstrapping and delegation, with the hard-lock resolver behavior implemented in bundled `resources/scripts/dev_tools/` code rather than duplicated in the wrapper.
- [ ] The bundled extension resources include the execute hard-lock prompt template content needed by the resolver so the command can run in workspaces that do not contain a repo-local `.github/codex/execute-hard-lock.prompt.md` file.
- [ ] The bundled resolver preserves the current execute-flow behavior from the root script, including plan-path substitution, work-mode/fallback-resolution behavior, and resolved prompt output suitable for copy/paste into chat.
- [ ] The root script and root prompt template remain the authoring source of truth, with the extension consuming synchronized bundled copies instead of introducing an extension-only implementation path.

## Constraints & Risks

- The extension bundle must stay synchronized with both `scripts/dev_tools/resolve_hard_lock_prompt.py` and `.github/codex/execute-hard-lock.prompt.md`; otherwise the extension command could silently diverge from the repo workflow.
- The resolver depends on adjacent helper logic such as prompt-mode handling, so packaging must include all required bundled Python modules and template assets, not just the top-level entry point.
- Extension-side execution still depends on an available Python runtime, and clipboard behavior may vary by platform or host environment even if prompt generation succeeds.
- Path normalization and workspace-relative substitution must behave correctly for non-repo workspaces and Windows-style paths, since this feature is explicitly meant to work outside the source repository.

## Test Conditions to Consider

- [ ] Unit-test command registration and argument wiring in `extensions/drm-copilot/src/extension.ts`, including the bundled wrapper path and target/workspace arguments passed to the Python runtime.
- [ ] Unit-test the bundled wrapper contract to confirm it adjusts `sys.path`, imports the bundled `dev_tools` module, and forwards execution without reimplementing resolver logic.
- [ ] Verify the bundled resolver can read the packaged execute-hard-lock prompt template and produce resolved output when the active workspace does not contain repo-root `.github/codex` assets.
- [ ] Cover Windows-oriented path handling, including conversion to workspace-relative forward-slash plan paths in the resolved prompt content.
- [ ] Cover failure paths such as missing target plan files, missing Python runtime, or missing bundled resources so the command fails clearly instead of producing partial or misleading output.

## Next Step

- [ ] Promote to GitHub issue (feature request template)
- [ ] Create `docs/features/active/bundle-hard-lock-resolver-into-extension/` folder from the template