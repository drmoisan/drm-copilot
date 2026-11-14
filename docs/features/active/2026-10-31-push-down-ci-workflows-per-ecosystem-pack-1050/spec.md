# 2026-10-31-push-down-ci-workflows-per-ecosystem-pack — Spec

- **Issue:** #1050
- **Parent (optional):** none
- **Owner:** drmoisan
- **Last Updated:** 2026-11-14T09-31
- **Status:** Draft
- **Version:** 0.1

## Overview

The push-down ships rules, skills, agents, hooks and libraries per ecosystem option (Python, PowerShell, TypeScript, and .NET in legacy and current forms). It ships no CI: `extensions/drm-copilot/resources/` contains no GitHub workflow files.

The harness assumes CI exists. The merge gate and the S9 step read check names and a required-context list, and the toolchain rules assume artifact paths such as `artifacts/python/coverage.json` for the coverage-threshold step. A destination without matching CI makes those gates unsatisfiable or vacuous, so agents wait for checks that never run. Each destination currently builds its own CI, and the check names drift from what the harness expects.

This repository's workflows are already reusable (`_quality-checks.yml`, `_poshqc.yml`, `_root-typescript-tests.yml`, `_shell-coverage.yml`), which makes a thin-caller push-down possible.


## Behavior

1. **One CI template per ecosystem pack.** Selecting a pack option selects its jobs: Python, PowerShell, TypeScript, .NET (legacy and current). Each template carries stable check names and the artifact paths the toolchain rules expect.
2. **Thin callers by default.** The push-down writes a small workflow that calls the source repository's reusable workflows at a pinned ref. A fix reaches destinations by bumping the pin, with no copy drift. Where the source repository is not reachable from the destination, the push-down ships copies and records their hashes in the manifest defined by the vendored-code coverage carve-out (issue #1049).
3. **Required checks as data.** The push-down emits the required-check list as a data file. The merge gate, the execution-environment brief and the branch-protection setup read it instead of a hard-coded, repository-specific list.
4. **Never overwrite.** New workflows are written beside existing ones. A conflicting existing workflow is reported (see the integration tooling entry) and left untouched.
5. **Branch protection is explicit.** Setting required status checks changes repository settings, so it is an opt-in step, never a side effect of the push-down.


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

- CI is the most destination-specific surface: runners, secrets, publish and deploy jobs, version matrices and the branch-protection ruleset. The default must be additive.
- A thin caller needs read access to the source repository's workflows. A private source requires the copy mode.
- Overlaps the shared agent-harness layer epic (#1018): push-down consolidation and ecosystem packs (#1029). Depends on the manifest from #1049.
- A pinned ref that is never bumped leaves destinations on old CI; the bump process needs documentation.


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
- [x] Unit coverage areas: template selection per pack; required-check data generation; conflict detection for an existing workflow.
- [x] Integration scenarios: push to a scratch destination for each pack and confirm the generated workflow parses and exposes the expected check names.
- [ ] CLI/API examples
