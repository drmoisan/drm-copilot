# 2026-10-31-pushed-down-vendored-code-coverage-carve-out — Spec

- **Issue:** #1049
- **Parent (optional):** none
- **Owner:** drmoisan
- **Last Updated:** 2026-10-31T14-03
- **Status:** Draft
- **Version:** 0.1

## Overview

The push-down copies hooks, skills, agents, libraries and rules into destination repositories. It does not copy the Pester tests that cover them: `extensions/drm-copilot/resources/` contains no `*.Tests.ps1` files, and the push-down source does not reference tests. A destination repository therefore receives PowerShell production code without its suite.

The pushed-down rule `general-unit-test.md` states that no production file may be excluded from coverage and lists the only permitted exclusions (build output, tests and test infrastructure, non-production config, `node_modules`). A destination that enforces that rule must cover the pushed-down hooks, and at least one destination has done so by recreating a Pester suite locally. Those recreated tests duplicate coverage already established upstream, drift from the hooks on every push-down, and can fail for reasons unrelated to the destination's own code.

Packages and plugins conventionally ship without their tests, and consumers do not hold vendored code to their own coverage targets. The rule has no vendored-code category, so a destination cannot exempt pushed-down files without violating it.


## Behavior

1. Add a vendored-code exception to the pushed-down coverage rules (`general-unit-test.md` and its mirrors): files written by the push-down and unchanged since may be excluded from the destination's coverage measurement. The exception covers only paths on the push-down's recorded file list, never a directory glob such as `.claude/**`.
2. The push-down records a content hash for every file it writes (a manifest in the destination, written at push time).
3. A destination check recomputes the hashes. A file whose hash differs from the manifest, or that is absent from it, is treated as destination-owned code and returns to the coverage denominator. A local hook added by the destination is covered by default.
4. The destination's coverage configuration generates its exclusion list from the manifest instead of hand-maintaining paths.
5. Document the policy for destination maintainers: pushed-down code is tested upstream, a modified copy is owned and tested locally, and recreated duplicate tests may be removed.


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

- A blanket directory exclusion hides destination edits and local additions from coverage. The exact-path and hash conditions are required.
- Environment-specific regressions in a destination (case-sensitive paths, different worktree layout) are no longer caught by locally recreated tests. The upstream Linux hook-suite job covers part of this; the remainder is a residual risk to record.
- The change edits rules that are also in this repository's own enforcement. This repository keeps its tests and is not exempt; the exception applies to destination repositories only.
- Scope overlaps with the shared agent-harness layer epic (#1018, push-down consolidation). Sequence it after that work or as one of its children to avoid editing the same push-down code twice.
- No new Python; the manifest writer and the check are PowerShell or bash, and the push-down itself is TypeScript.


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
- [x] Unit coverage areas: manifest generation (paths, hashes, ordering); the destination check (unchanged, modified, added, removed file); exclusion-list derivation.
- [x] Integration scenarios: push to a scratch destination, run its coverage configuration, modify one hook and confirm it re-enters the denominator.
- [ ] CLI/API examples
