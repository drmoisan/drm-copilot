# 2026-10-30-harness-survey-gold-standard-contracts-parity-matrix — Spec

- **Issue:** #1025
- **Parent (optional):** none
- **Owner:** drmoisan
- **Last Updated:** 2026-10-30T17-06
- **Status:** Draft
- **Version:** 0.1

## Overview

Epic #1018 restructures the three agent ecosystems in this repository (Claude Code, Codex and GitHub Copilot) onto shared cross-tool conventions. Before any generator, push-down or retirement work can start, the epic needs three settled inputs that do not exist today:

- A content-level comparison of the 90 skill names across `.claude/skills`, `.agents/skills` and `.github/skills`. The existing heading comparison (12 byte-identical, 27 wording-only, 16 material differences among 55 shared names) overstates differences because the same topic appears under different headings.
- A tool-neutral gold-standard contract for each shared skill, against which each ecosystem's expression can be judged.
- A machine-readable parity matrix that gives every native feature of every ecosystem a disposition, so later children can prove that no native capability is lost.

Several behaviors that the design depends on are also unverified: Copilot duplicate-skill listing, Codex tolerance of Claude-only frontmatter, whether the Copilot CLI and cloud agent read `.claude/agents`, whether Copilot settings work at workspace scope, and details of the Claude hooks, subagent and permissions documentation.


## Behavior

- A content-level survey of all 90 skill names, recording for each shared skill the substantive differences between ecosystems.
- A tool-neutral contract per shared skill at `.agents/skills/<name>/references/standard.md` with three parts: objective, observable behaviors, acceptance checks.
- A classification of every cross-ecosystem difference as positive, negative, neutral or mechanism-only, judged against the skill's objective, with an owner bulk-approval artifact; only disputed cases are escalated individually.
- A machine-readable parity matrix (location and schema owned by this child, outside `docs/`) that assigns every native feature of every ecosystem one disposition: shared, native, generated, or dropped with a written reason.
- A completeness test, written in TypeScript or PowerShell, that fails when a native feature has no disposition or a dropped feature has no reason.
- The unverified-behavior experiments. Experiments that need VS Code or Codex are delivered as owner-run runbook steps with a recorded-result artifact and an explicit stop.

Children 3 to 6 of epic #1018 consume the parity-matrix location and schema and the contract format, so this child states them precisely.


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

- Language directive (owner): new scripts, tools, checkers and tests are TypeScript or PowerShell; existing Python may be reused or called but not extended with new entry points.
- Execution starts only after the in-flight parallel run `bugs-1001-1002-1003-1006` merges to `main`; this child does not edit files that run changes.
- Experiments that need VS Code or Codex cannot run in an agent session and require owner steps.
- Scale: 90 skill names, about 25 Claude agents, 98 unique Codex agents, 46 Copilot agents, 125 hook files.


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
- [ ] Unit coverage areas: parity-matrix schema validation and the completeness rule (missing disposition, dropped without reason, unknown disposition); contract presence per shared skill.
- [ ] Integration scenarios: the completeness test run against the committed matrix in CI.
- [ ] CLI/API examples
