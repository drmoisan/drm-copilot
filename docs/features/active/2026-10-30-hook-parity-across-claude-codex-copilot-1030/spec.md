# hook-parity-across-claude-codex-copilot — Spec

- **Issue:** #1030
- **Parent (optional):** none
- **Owner:** drmoisan
- **Last Updated:** 2026-10-30T18-37
- **Status:** Draft
- **Version:** 0.1

## Overview

This repository runs enforcement and validation hooks in three agent ecosystems: Claude Code
(`.claude/hooks`, 75 files on `main`), Codex (`.codex/hooks`, 50 files) and GitHub Copilot
(`.github/hooks`, 6 files). The sets were built separately and drifted: some Claude gates have no
Codex counterpart, some Codex hooks exist only to express Codex-specific attestation, and the
Copilot hooks cover only the discovery surface. No record states, for each hook, whether its
function is shared across ecosystems, native to one ecosystem, generated, or deliberately dropped,
so a missing gate in one ecosystem is not detectable.

Epic #1018 settles the design: hook parity is parity of function, tracked in the parity matrix
owned by child 1 (#1025, `config/harness-parity-matrix.json`). Hook counts need not match, and
Codex gains a hook only where its hook system can express the behavior.


## Behavior

- Every hook registration in each ecosystem has a disposition in the parity matrix (shared,
  native, generated, or dropped with a written reason).
- Where a Claude gate's function is expressible in Codex and the matrix marks it shared, the Codex
  counterpart exists and behaves the same on the same inputs; where it is not expressible, the
  matrix records the reason.
- The Copilot hooks under `.github/hooks` receive dispositions; their function is kept native in
  `.github` (the thin Copilot layer that child 6 finalizes).
- Enforcement hooks do not invoke Python.
- Hook registrations in agent frontmatter and in `.codex/config.toml` follow the generator
  ownership that child 3 establishes.
- Bundled mirrors under `extensions/drm-copilot/resources/` stay byte-identical and their parity
  tests stay green.


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

- Depends on child 3 (generator ownership of hook registrations) and on child 1's matrix schema,
  whose `id` encoding is still open.
- Execution starts only after the parallel run `bugs-1001-1002-1003-1006` merges; that run edits
  many hooks.
- Language rule: hooks and their libraries are pushed down to destination repositories, so new
  hook code is PowerShell or bash only.


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
- [ ] Unit coverage areas: each new or ported Codex hook (Pester), matrix hook-entry coverage.
- [ ] Integration scenarios: Linux hook-suite job over `tests/scripts/codex-hooks`.
- [ ] CLI/API examples
