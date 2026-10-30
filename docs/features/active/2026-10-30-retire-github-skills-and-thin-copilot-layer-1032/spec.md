# 2026-10-30-retire-github-skills-and-thin-copilot-layer — Spec

- **Issue:** #1032
- **Parent (optional):** none
- **Owner:** drmoisan
- **Last Updated:** 2026-10-30T18-39
- **Status:** Draft
- **Version:** 0.1

## Overview

Epic #1018 moves the three agent ecosystems in this repository onto shared cross-tool conventions so that each tool loads every skill and instruction exactly once with default settings. GitHub Copilot in VS Code reads `.github/skills`, `.claude/skills` and `.agents/skills`, so the `.github/skills` folder (a strict subset of the other two skill folders) causes duplicate loading. `.github/agents` duplicates agent definitions that Copilot in VS Code also reads from `.claude/agents`. Collision controls currently live only in the owner's personal user settings; other users do not have them.


## Behavior

- Retire `.github/skills` after its three unique sections, in `feature-promotion-lifecycle` and `feature-review-workflow`, are ported to the shared skill source or recorded as stale.
- Retire `.github/agents`, or reduce it to a generated file, according to the result of child 1's experiment on whether the Copilot CLI and Copilot cloud agent read Claude-format `.claude/agents`.
- Keep a thin Copilot layer: prompts, handoffs and hooks stay native in `.github`; `.github/copilot-instructions.md` holds Copilot-only text.
- Deliver Copilot collision controls in workspace `.vscode/settings.json` if workspace scope works (child 1 experiment E4); otherwise document them. `.vscode/settings.json` is gitignored, so the delivery approach is an owner question with a default.
- Update the push-down packs and bundled extension mirrors for every removed file.


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

- Depends on children 4 (push-down consolidation and packs) and 5 (hook parity) and on child 1's experiment results; planned before they exist (owner decision E3), so the plan carries a Phase 0 gate that re-checks them.
- Execution starts only after the parallel run `bugs-1001-1002-1003-1006` merges; that run edits `.github/skills/execution-environment/SKILL.md`.
- Language rule: anything pushed down is PowerShell or bash; TypeScript only for MCP tools and extension commands; no new Python.


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
- [x] Unit coverage areas: pack-manifest completeness and dependency closure after removals; bundle parity.
- [x] Integration scenarios: Copilot loads each skill once with the workspace settings (owner-run).
- [ ] CLI/API examples
