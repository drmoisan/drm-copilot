# `push-down-consolidation-and-ecosystem-packs` — User Story

- Issue: #1029
- Parent: epic #1018, child 4
- Owner: drmoisan
- Status: Draft
- Last Updated: 2026-10-30
- Spec: `docs/features/active/2026-10-30-push-down-consolidation-and-ecosystem-packs-1029/spec.md`

## Story Statement

- As a destination-repository maintainer, I want to install only the agent ecosystems and packs my repository uses, with the shared layer always present, so that my repository does not receive files for tools it does not run.
- As a destination-repository maintainer, I want to preview a push-down before it writes anything and to have my own edits to pushed-down files left in place and reported, so that updating the harness never silently discards local work.
- As the repository owner, I want one push-down pipeline behind the existing MCP tools, so that the shared layer is installed and protected the same way for Claude, Codex and Copilot, and current callers keep working.

## Problem / Why

The repository pushes its agent harness down to destination repositories through three separate push-downs (Claude, Codex, Copilot), each exposed as its own MCP tool with its own payload layout and pack manifests. Epic #1018 makes the shared layer (`AGENTS.md`, `.agents/skills`, generated rules, MCP configuration and agents produced by child 3) the source for all three ecosystems. Three independent push-downs cannot install one shared layer once, cannot let a destination omit an ecosystem it does not use, and cannot protect a destination's own edits consistently. Today every enumerated file is written unconditionally, no push-down has a dry run, and the per-run summary artifact carries no content hash, so a local edit is overwritten without notice.

## Personas & Scenarios

- Persona: destination-repository maintainer
  - Maintains a repository that receives the harness through the MCP push-down tools.
  - Cares about keeping local customizations (edited rules, skills, configuration) and about a predictable, reviewable diff after each push-down.
  - Constraint: may use only one or two of the three ecosystems; does not want unused tool folders in the repository.
  - Frustration: a push-down today overwrites edited files and gives no preview.
- Persona: repository owner (drmoisan)
  - Maintains the harness source and the three push-down tools.
  - Cares about one implementation, additive MCP contracts, and the epic language rule (TypeScript only for MCP and extension commands; no new Python).
- Scenario: first consolidated push-down to a Codex-only destination
  - The maintainer calls `push_down_codex_and_agents_customizations` with `dry_run: true`.
  - The report lists the shared layer and the Codex layer; files that already exist and differ are listed as `unmanaged-conflict`; no file is written.
  - The maintainer resolves or accepts the conflicts, then calls the tool without `dry_run` (optionally with `overwrite_unmanaged: true`).
  - The destination receives the shared layer and Codex files only, plus `.push-down-manifest.json`; no `.claude` or `.github` file is written.
- Scenario: update after a local edit
  - The maintainer edited a pushed-down rule. A later push-down with a new payload reports that file as `conflict`, leaves it unchanged, and updates every other changed file.
  - Running the same push-down again changes no file outside `artifacts/`.

## Acceptance Criteria

- [ ] The MCP tools `push_down_claude_customizations`, `push_down_codex_and_agents_customizations` and `push_down_copilot_customizations` keep their names and existing inputs and results, and each delegates to the same pipeline for its own ecosystem.
- [ ] Every push-down installs the shared layer, whichever ecosystem's tool is called.
- [ ] A push-down for one ecosystem writes no file under another ecosystem's layer.
- [ ] A maintainer can select packs per ecosystem, including for Copilot, and only `core` plus the selected packs of that ecosystem are installed.
- [ ] A dry run returns the full plan (path, layer, pack and action per file) and leaves the destination unchanged.
- [ ] An apply run reports the same plan it executes, computed before its first write.
- [ ] A file the maintainer edited since the last push-down is not overwritten and is reported as a conflict.
- [ ] A destination pushed down by an earlier release (no manifest) is not overwritten where its files differ from the payload; those files are reported, and an explicit `overwrite_unmanaged: true` opt-in overwrites them.
- [ ] A second push-down with no source change and no destination change changes no file outside `artifacts/`.
- [ ] The destination receives `.push-down-manifest.json` at its root with a SHA-256 hash per managed file and the pack selection per ecosystem, and with no timestamp and no absolute path.
- [ ] Destination exclusions in `.push-down-exclusions` are honored by all three tools, and files of a deselected pack or ecosystem are reported as orphaned rather than deleted.
- [ ] The pack manifests list the generated files that child 3 (#1028) produces, as confirmed at the Phase 0 gate.
- [ ] No new Python file is added, and no TypeScript or Python file is pushed down to destinations.

## Non-Goals

- A new unified MCP push-down tool (owner question O-2).
- Deleting orphaned files from destinations (O-7).
- Pushing generators down to destinations (O-9).
- Destination-side hooks or skill helpers that check local edits.
- Changes to enforcement hooks, to the Python push-down ports, or to files of the in-flight parallel run `bugs-1001-1002-1003-1006` before it merges.
