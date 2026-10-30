# 2026-10-30-docs-enforcement-and-ci — Spec

- **Issue:** #1034
- **Parent (optional):** none
- **Owner:** drmoisan
- **Last Updated:** 2026-10-30T18-40
- **Status:** Draft
- **Version:** 0.1

## Overview

The documentation-estate tooling of epic #1019 can check pages and emit a `docs-complete`
receipt, but nothing enforces either result. A destination repository can change its documentable
surface (for example add a CLI command) without changing its coverage ledger, and an epic
integration branch can merge to `main` without a passing receipt for its head revision. In one
consumer repository, a feature epic changed 138 `src/` files while only 4 of 79 documentation
pages were edited, and the gap was found by hand. The epic's correspondence half needs a CI
surface, a merge gate, and a review check that act on the tooling's results.


## Behavior

- A consumer reusable workflow `_docs-quality.yml` runs `pwsh` with
  `.claude/lib/docs/Invoke-DocsCommand.ps1` `check` and `validate -Mode docs-complete`. It is
  delivered as a template row that `Invoke-DocsCommand.ps1 -Command init` writes from
  `.claude/lib/docs/templates/` (the delivery contract decided by #1020).
- A new PowerShell module `.claude/lib/docs/DocsSurfaceDelta.psm1` and the subcommand
  `surface-delta -Base <ref>` (one dispatch-table row under this child's anchor in
  `Invoke-DocsCommand.ps1`) report surface elements added or changed since a base revision that
  have no matching ledger change.
- A PowerShell hook `.claude/hooks/enforce-docs-complete-gate.ps1`, opt-in through the consumer
  profile, denies the epic integration-to-`main` merge unless a passing persisted receipt pins the
  head revision. Disabled by default.
- `.claude/settings.json` registers the hook; `.claude/agents/feature-review.md` and its Codex,
  Copilot and push-down mirrors gain a surface-change-without-ledger-change check.
- All pushed-down code is PowerShell; linting remains optional (owner decision D4).


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

- Language rule (owner directive 2026-10-30, refined): pushed-down helpers, hooks and libs are
  PowerShell or bash; TypeScript only for MCP and extension commands; no new Python.
- Pure functions take strings and hashtables; tests create no temporary files.
- The hook and its registration are pushed down; mirror parity, pack-manifest completeness and
  dependency-closure contract tests apply.
- Upstream contracts (#1020, #1021, #1023) are being re-prepared concurrently; this child takes
  them from the epic document.


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
- [ ] Pester unit suites for `DocsSurfaceDelta.psm1` and the hook (hook suite under `tests/scripts/claude-hooks/`)
- [ ] Template-row test for the `init` workflow template
- [ ] Mirror parity tests for `feature-review` surfaces
