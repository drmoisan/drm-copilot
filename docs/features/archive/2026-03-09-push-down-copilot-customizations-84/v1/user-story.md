# `2026-03-09-push-down-copilot-customizations` — User Story

- Issue: #84
- Owner: drmoisan
- Status: Draft
- Last Updated: 2026-03-09T23-14

## Story Statement

- As a repository maintainer who curates shared Copilot customization files, I want a dedicated one-way push-down tool that copies the repo's `.github` customization trees into another workspace, so that downstream workspaces receive a complete, current customization pack without manual file-by-file copying.
- As a developer using the `drm-copilot` extension in a destination workspace, I want copied guidance to reference packaged extension commands or explicit placeholders instead of repo-local script paths, so that every documented action either works from the extension or fails with a deterministic not-implemented message.

## Problem / Why

`scripts/dev_tools/agentic_sync.py` currently synchronizes shared `.github` content between two repositories, but it does not provide a one-way "push down" flow that copies the current repo's Copilot customizations into an arbitrary destination workspace. When these files are moved today, embedded references to repo-local scripts such as `scripts/dev_tools/...` or `scripts/dev-tools/...` do not travel cleanly, so the copied guidance can point at commands that do not exist in the destination workspace.

This feature would close that gap by turning the local `.github/agents/`, `.github/instructions/`, `.github/prompts/`, and `.github/skills/` trees into a destination-workspace-ready customization pack. It also needs to keep those copied files executable in practice by rewriting script references to packaged extension commands and exposing explicit placeholders where command coverage is not implemented yet.


## Personas & Scenarios

- Persona: Repository maintainer standardizing Copilot workspace customizations
  - Maintains shared `.github/agents/`, `.github/instructions/`, `.github/prompts/`, and `.github/skills/` content in this repository.
  - Cares about reproducible rollout into another workspace without breaking script references embedded in docs, prompts, or skills.
  - Works under repo policy constraints that favor deterministic tooling, no temp-file-based tests, and minimal regression risk for existing sync workflows.
  - Wants a one-way publishing flow that is clearly separate from the current bidirectional `scripts/dev_tools/agentic_sync.py` behavior.
  - Is frustrated by destination workspaces receiving copied guidance that still points at `scripts/dev_tools/...` or `scripts/dev-tools/...` paths that do not exist there.
- Scenario: Push the current repo's Copilot customization pack into a second workspace
  - The repository maintainer updates local `.github` customization files and needs to publish the latest set into another workspace before asking another developer to use them.
  - They run the new Python push-down entry point against the destination workspace root.
  - The tool enumerates the four scoped `.github` trees, rewrites supported script references to extension command references, creates missing destination directories, and overwrites same-path destination files.
  - When the copied content references PR-context collection, the rewritten text points at the existing packaged extension command; when the copied content references uncovered scripts such as `new_active_feature_folder` or `potential_to_issue`, the rewritten text points at placeholder extension commands instead of dead workspace paths.
  - The maintainer reviews the summary artifact/log, confirms that unmatched references were reported rather than silently rewritten, and expects the destination workspace to contain a working customization pack whose command references are either implemented or deterministically not yet implemented.


## Acceptance Criteria

- [ ] A Python entry point can push down all files from `.github/agents/`, `.github/instructions/`, `.github/prompts/`, and `.github/skills/` into a destination workspace while preserving each file's relative path under `.github/`.
- [ ] When the destination workspace already contains a file at the same relative path, the push-down run overwrites that file with the source-repo version instead of skipping or merging it.
- [ ] Copied files that reference already-exposed tooling are rewritten from repo-local script paths to packaged extension command references that match the extension's bundled execution model.
- [ ] Copied files that reference tooling not yet exposed by the extension are rewritten to stable placeholder command references, and invoking those placeholders surfaces a clear not-implemented failure rather than a missing-file/path error.
- [ ] The implementation introduces a dedicated one-way Python entry point for push-down behavior, leaving the current bidirectional `scripts/dev_tools/agentic_sync.py` contract unchanged unless small shared helpers are extracted without altering sync semantics.
- [ ] Rewrites normalize both `scripts/dev_tools/...` and `scripts/dev-tools/...` references to the same catalog entry so mixed slash styles on Windows or cross-platform docs resolve to the same extension-command target.
- [ ] If a text file contains a script-like reference that is outside the initial verified command catalog, the file content remains unchanged and the run summary reports that unmatched reference explicitly.
- [ ] Invalid destination input fails before partial copy begins, with a deterministic error that explains why the destination workspace root is unusable.
- [ ] Automated coverage includes Python tests for enumeration/copy/overwrite/rewrite/unmatched-reference reporting behavior and extension tests for command contribution, packaged-path execution, and placeholder-command failure paths.


## Non-Goals

- Expanding the full extension command surface for every script mentioned anywhere in `.github` content; the first release only covers the verified rewrite surface plus placeholders for uncovered references.
- Changing the current two-way synchronization behavior of `scripts/dev_tools/agentic_sync.py` into a dual-mode CLI unless future work explicitly chooses that direction.
- Rewriting arbitrary prose or all shell snippets in copied files; rewrites are limited to supported, evidence-backed script-reference patterns.
- Turning rewritten command references into clickable `command:` URIs inside ordinary repository markdown files; copied files should use stable textual command references instead.
- Adding destination-side script copies outside the scoped `.github` trees; execution should remain extension-backed rather than recreating local `scripts/` trees in the target workspace.
