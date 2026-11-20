# push-down-copilot-customizations (Issue #84)
title: "push-down-copilot-customizations - Plan"
issue: "TBD"
parent: "none"
owner: "Dan Moisan"
last_updated: "2026-03-09T23-12"
status: "Draft"
status_color: "lightgrey"
version: "0.1"
---

# push-down-copilot-customizations (Potential)

- Date captured: 2026-03-09
- Author: Dan Moisan
- Status: Promoted -> docs/features/active/push-down-copilot-customizations/ (Issue #84)

- Issue: #84
- Issue URL: https://github.com/drmoisan/drm-copilot/issues/84
- Last Updated: 2026-03-10
- Work Mode: full

## Problem / Why

`scripts/dev_tools/agentic_sync.py` currently synchronizes shared `.github` content between two repositories, but it does not provide a one-way "push down" flow that copies the current repo's Copilot customizations into an arbitrary destination workspace. When these files are moved today, embedded references to repo-local scripts such as `scripts/dev_tools/...` or `scripts/dev-tools/...` do not travel cleanly, so the copied guidance can point at commands that do not exist in the destination workspace.

This feature would close that gap by turning the local `.github/agents/`, `.github/instructions/`, `.github/prompts/`, and `.github/skills/` trees into a destination-workspace-ready customization pack. It also needs to keep those copied files executable in practice by rewriting script references to packaged extension commands and exposing explicit placeholders where command coverage is not implemented yet.

## Proposed Behavior

A Python push-down tool should copy every file under `.github/agents/`, `.github/instructions/`, `.github/prompts/`, and `.github/skills/` from this repo into a destination workspace, preserving relative paths under `.github/` and creating missing directories as needed. If the destination workspace already contains a file at the same relative path, the local source copy should overwrite it.

During copy, the tool should rewrite supported script references inside copied text files so they point to packaged extension commands/resources rather than repo-local script paths. The rewrite map should align with command exposure in `extensions/drm-copilot/src/extension.ts` and existing bundled execution patterns that resolve scripts from extension resources. If a copied file references a script that is not yet exposed, the extension should expose a stable placeholder command that fails with an explicit not-implemented error instead of leaving a dead workspace path reference.

The initial scope likely includes Python tooling changes, extension command exposure, rewrite mapping, and tests that verify overwrite behavior plus rewritten command usability.

## Acceptance Criteria (early draft)

- [ ] A Python entry point can push down all files from `.github/agents/`, `.github/instructions/`, `.github/prompts/`, and `.github/skills/` into a destination workspace while preserving each file's relative path under `.github/`.
- [ ] When the destination workspace already contains a file at the same relative path, the push-down run overwrites that file with the source-repo version instead of skipping or merging it.
- [ ] Copied files that reference already-exposed tooling are rewritten from repo-local script paths to packaged extension command references that match the extension's bundled execution model.
- [ ] Copied files that reference tooling not yet exposed by the extension are rewritten to stable placeholder command references, and invoking those placeholders surfaces a clear not-implemented failure rather than a missing-file/path error.
- [ ] Existing bidirectional sync behavior in `scripts/dev_tools/agentic_sync.py` is either preserved unchanged or intentionally separated behind a new push-down mode/entry point so current sync workflows do not regress.
- [ ] Automated coverage includes Python tests for enumeration/copy/overwrite/rewrite behavior and extension tests for command exposure, packaged-path execution, and placeholder-command failure paths.

## Constraints & Risks

- Rewrite coverage is the main scope risk: `.github` content includes mixed command styles (`scripts/dev_tools`, `scripts/dev-tools`, `poetry run python -m ...`, PowerShell examples), so the mapping must be broad enough to catch real references without rewriting unrelated prose.
- Overwrite behavior is intentionally destructive for matching destination files, so the tool should make that contract explicit and produce a summary artifact/log of what it copied and rewrote.
- Command exposure and rewrite mapping must stay in sync with `extensions/drm-copilot/src/extension.ts`; otherwise copied docs will drift faster than the packaged commands they depend on.
- Placeholder exposure reduces broken links but expands extension surface area, so command IDs, error messaging, and packaged resource layout need to remain stable across platforms and future packaging changes.

## Test Conditions to Consider

- [ ] Unit coverage areas: root-folder enumeration, destination directory creation, overwrite of existing files, rewrite of known script-reference patterns, and pass-through of content that should not be rewritten.
- [ ] Integration scenarios: push into an empty workspace, push into a workspace with conflicting `.github` files, and validate that rewritten references resolve to packaged extension commands instead of destination-workspace script paths.
- [ ] CLI/API examples: one-way push invocation from source repo to destination workspace, expected artifact/log output for copied and rewritten files, and placeholder-command invocation that raises a deterministic not-implemented error.
- [ ] Path/OS edge cases: Windows-style backslashes and mixed `scripts/dev_tools` vs `scripts/dev-tools` references should normalize to the same packaged-command target.

## Next Step

- [ ] Promote to GitHub issue with scope called out explicitly as Python push-down tooling, extension command exposure in `extensions/drm-copilot/src/extension.ts`, reference rewriting, placeholder commands for uncovered scripts, and test coverage across both Python and extension layers.
- [ ] Create `docs/features/active/push-down-copilot-customizations/` from the template and capture whether this work extends `scripts/dev_tools/agentic_sync.py` directly or introduces a separate push-down entry point.