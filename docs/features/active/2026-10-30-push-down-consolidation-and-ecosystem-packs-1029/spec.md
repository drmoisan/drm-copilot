# push-down-consolidation-and-ecosystem-packs — Spec

- **Issue:** #1029
- **Parent (optional):** none
- **Owner:** drmoisan
- **Last Updated:** 2026-10-30T18-37
- **Status:** Draft
- **Version:** 0.1

## Overview

The repository pushes its agent harness down to destination repositories through three separate push-downs (Claude, Codex, Copilot), each exposed as its own MCP tool with its own payload layout and pack manifests. Epic #1018 makes the shared layer (`AGENTS.md`, `.agents/skills`, generated rules, MCP configuration and agents produced by child 3) the source for all three ecosystems. Three independent push-downs cannot install one shared layer once, cannot let a destination omit an ecosystem it does not use, and cannot protect a destination's own edits consistently.


## Behavior

- The three push-downs become one pipeline. The existing MCP push-down tools remain as thin wrappers over that pipeline, so current callers keep working.
- A destination selects packs per ecosystem (Claude, Codex, Copilot). The shared layer is always installed. An ecosystem that is not selected installs no files.
- Migration of a destination is non-destructive: the pipeline reports a dry run first, and it never overwrites a destination's own edits, detected by comparing the destination file against the last pushed-down manifest.
- Existing Python ports of the push-down may be reused or called, not added to (epic language rule). Code that ships to destinations is PowerShell or bash; MCP tool wrappers are TypeScript.


## Inputs / Outputs

- Inputs (CLI flags, files, env vars)
- Outputs (artifacts, logs, telemetry)
- Config keys and defaults:
- Versioning or backward-compatibility constraints:

## API / CLI Surface

List commands, flags, request/response shapes, and examples.
- Example invocations with expected outputs (concise):
- Contracts and validation rules:

## Data & State

Data flow, storage, or state changes introduced by this feature.
- Data transformations and invariants:
- Caching or persistence details:
- Migration or backfill requirements (if any):

## Constraints & Risks

- Depends on child 3 (generators) and on child 1 (parity-matrix dispositions, contract format), neither of which exists at planning time (owner decision E3): the plan carries a Phase 0 gate that re-checks those outputs.
- Execution starts after the parallel run `bugs-1001-1002-1003-1006` merges; it touches push-down code and bundled mirrors.
- Language rule: no new Python; pushed-down code is PowerShell or bash; TypeScript only for MCP tools and extension commands.


## Implementation Strategy

- Implementation scope (what changes, not sequencing):
- New classes/functions/commands to add or update:
- Dependency changes (new/removed packages) and rationale:
- Logging/telemetry additions and locations:
- Rollout plan (feature flags, staged deploys, fallback path):

## Definition of Done

- [ ] Acceptance criteria documented and mapped to tests or demos
- [ ] Behavior matches acceptance criteria in all documented environments
- [ ] Tests updated/added (unit/integration as applicable)
- [ ] Edge cases and error handling covered by tests
- [ ] Docs updated (README, docs/features/active/... links)
- [ ] Telemetry/logging added or updated (if applicable)
- [ ] Toolchain pass completed (format → lint → type-check → test)

## Seeded Test Conditions (from potential)
- [x] Unit coverage areas: pack selection, shared-layer-always rule, unused-ecosystem-installs-nothing, dry-run report, no-overwrite against the last manifest.
- [x] Integration scenarios: a destination pushed down twice with the second run a no-op; a destination with a local edit preserved.
- [ ] CLI/API examples
