# targeted-test-cadence — Spec

- **Issue:** #1228
- **Parent (optional):** none
- **Owner:** drmoisan
- **Last Updated:** 2026-11-23T06-50
- **Status:** Draft
- **Version:** 0.1

## Overview

The orchestration rules run the full unit suite at every `[phase-gate]` task, and some skills also require it for remediation cycles and post-merge sync checks. On large destination repositories this repeats a multi-minute full run many times per orchestration. The owner directed on 2026-11-23: "The full test suite for any destination repo should only be run at the beginning of the orchestration and in the qc run. everything else should be targeted tests. this change should be reflected in every rule that operates otherwise for all orchestrators."


## Behavior

- The full test suite runs only at the Phase 0 baseline and in the final QC loop.
- Every other test run is targeted: task checks, `[phase-gate]` tasks, remediation cycles, and main-sync or integration-sync checks. A phase gate keeps format, lint, type check, architecture, and contract checks. Its unit stage is the union of the phase's task test selections (mirrored tests of changed files, tests that import, dot-source, or name a changed module, and contract tests for changed Markdown or configuration paths), run in parallel.
- The change applies to every orchestrator and every surface: Claude (`.claude/`), Codex (`.agents/`, `.codex/`), Copilot (`.github/`), AGENTS.md, rule and agent sources under `scripts/harness-generation/sources/`, and all bundle copies under `extensions/drm-copilot/resources/`.
- The change is recorded as a standing gate reduction in `.dev/engineering/process-reductions/`, with the prior text and revert steps.


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

- No new Python.
- Test runs are parallel only.
- Epic #1217 is editing `.claude/lib/docs` and the docs skills concurrently. Avoid those files.
- Risk: weaker detection of cross-module regressions between Phase 0 and final QC. The final QC full run and CI remain the backstop.


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
- [ ] Docs updated (README, .dev/active/... links)
- [ ] Telemetry/logging added or updated (if applicable)
- [ ] Toolchain pass completed (format → lint → type-check → test)

## Seeded Test Conditions (from potential)
- [ ] Contract tests that read the Test Cadence wording
- [ ] Harness generation drift check
- [ ] Bundle parity tests
