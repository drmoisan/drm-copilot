# push-down-consolidation-and-ecosystem-packs (Issue #1029)

- Date captured: 2026-10-30
- Author: Dan Moisan
- Status: Promoted -> docs/features/active/push-down-consolidation-and-ecosystem-packs/ (Issue #1029)
- Epic: #1018 (shared agent-harness layer across Claude Code, Codex and GitHub Copilot), child 4
- Epic manifest: `docs/features/epics/shared-agent-harness-layer/epic.md` on `epic/shared-agent-harness-layer-integration`

- Issue: #1029
- Issue URL: https://github.com/drmoisan/drm-copilot/issues/1029
- Last Updated: 2026-10-30
## Problem / Why

The repository pushes its agent harness down to destination repositories through three separate push-downs (Claude, Codex, Copilot), each exposed as its own MCP tool with its own payload layout and pack manifests. Epic #1018 makes the shared layer (`AGENTS.md`, `.agents/skills`, generated rules, MCP configuration and agents produced by child 3) the source for all three ecosystems. Three independent push-downs cannot install one shared layer once, cannot let a destination omit an ecosystem it does not use, and cannot protect a destination's own edits consistently.

## Proposed Behavior

- The three push-downs become one pipeline. The existing MCP push-down tools remain as thin wrappers over that pipeline, so current callers keep working.
- A destination selects packs per ecosystem (Claude, Codex, Copilot). The shared layer is always installed. An ecosystem that is not selected installs no files.
- Migration of a destination is non-destructive: the pipeline reports a dry run first, and it never overwrites a destination's own edits, detected by comparing the destination file against the last pushed-down manifest.
- Existing Python ports of the push-down may be reused or called, not added to (epic language rule). Code that ships to destinations is PowerShell or bash; MCP tool wrappers are TypeScript.

## Acceptance Criteria (early draft)

- [ ] One push-down pipeline serves Claude, Codex and Copilot, and the existing MCP push-down tools delegate to it as thin wrappers.
- [ ] A destination chooses packs per ecosystem; the shared layer is always installed; an unused ecosystem installs no files.
- [ ] A push-down reports a dry run before writing.
- [ ] A destination file whose content differs from the last pushed-down manifest entry is not overwritten and is reported.
- [ ] Pack manifests list the generated files produced by child 3.

## Constraints & Risks

- Depends on child 3 (generators) and on child 1 (parity-matrix dispositions, contract format), neither of which exists at planning time (owner decision E3): the plan carries a Phase 0 gate that re-checks those outputs.
- Execution starts after the parallel run `bugs-1001-1002-1003-1006` merges; it touches push-down code and bundled mirrors.
- Language rule: no new Python; pushed-down code is PowerShell or bash; TypeScript only for MCP tools and extension commands.

## Test Conditions to Consider

- [x] Unit coverage areas: pack selection, shared-layer-always rule, unused-ecosystem-installs-nothing, dry-run report, no-overwrite against the last manifest.
- [x] Integration scenarios: a destination pushed down twice with the second run a no-op; a destination with a local edit preserved.
- [ ] CLI/API examples

## Next Step

- [ ] Promote to GitHub issue (feature request template)
- [ ] Create the active feature folder from the template
