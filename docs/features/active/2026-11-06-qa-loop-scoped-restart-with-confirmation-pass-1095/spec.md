# qa-loop-scoped-restart-with-confirmation-pass — Spec

- **Issue:** #1095
- **Parent (optional):** none
- **Owner:** drmoisan
- **Last Updated:** 2026-11-06T21-06
- **Status:** Draft
- **Version:** 0.1

## Overview

The Final QA Loop contract (`.claude/skills/atomic-plan-contract/SKILL.md`, section "Final QA Loop", and the "Mandatory Toolchain Loop" in `.claude/rules/general-code-change.md`) says: run format, lint, type check where applicable, then tests with coverage; "if any step fails or changes files, restart the loop from step 1 until a clean pass completes." The restart is always a full pass of the whole toolchain, whatever changed.

Measured cost (epic 1019 session, 2026-11-03 18:36 UTC to 2026-11-07 00:36 UTC, from the agents' own transcripts; calls of 30 seconds or longer only):

- Test and quality-check runs: 739 calls, 1,916 minutes (31.9 hours) of agent time. Executors spent 1,149 of their 2,979 active minutes (39 percent) in these runs.
- Passes per item, counted from the `evidence/qa-gates/format.*.md` files: #1067 five, #1034 five, #1080 four, #1026 three, most others one or two. The count is a proxy; evidence naming varies between items and a few items did not use that file name.
- Longest single runs: 6 to 20 minutes each (#1031).

Why #1034 needed five passes, taken from its own evidence files. Each restart was caused by a change to a few files:

1. Pass 1 to 2: one new test failure (`enforcement-hooks-no-python-invocation.Tests.ps1`, five dynamic-invocation sites in `DocsSurfaceDeltaCommands.psm1`).
2. Pass 2 to 3: a merge of the integration branch (siblings #1024 and #1033).
3. Pass 3 to 4: one test renamed in `Invoke-DocsCommand.RevisionContext.Tests.ps1`.
4. Pass 4 to 5: a repository-root seam change in `enforce-docs-complete-gate.ps1` and its bundle copy after a Python manifest-closure contract test failed.

The rule's intent is sound: a fix can break an earlier stage, and a clean pass proves the final state. The cost is that a one-file fix pays for the whole suite again.


## Behavior

Keep the exit condition and make the intermediate restarts cheaper: **scoped restart, mandatory full confirmation pass.**

- **Scoped pass** (after a failure or an auto-fix, and only if the trigger list below does not require a full pass): rerun format and lint on the changed files; run the type check if the language has one; run the tests that failed, the tests that mirror the changed paths (`tests/` mirror rule), and every contract or parity test that references a changed path (found with `git grep` on the changed file names, covering the bundle-mirror, manifest-closure and push-down contract suites). Coverage is not re-evaluated in a scoped pass.
- **Full pass required** (no scoping) after any of: a merge or rebase that brings in other branches' changes; a change to a shared fixture, test-support module, manifest, lockfile, tool configuration or workflow; a change spanning more than one language; a change to more than a stated number of files (the number to be set in research); or any uncertainty about scope. When in doubt, run the full pass.
- **Confirmation pass:** the loop still ends only with one clean FULL pass, run on the exact tree that goes to review and again before each re-audit that follows a code change. The coverage thresholds (85 percent lines) and all existing gates are evaluated on that pass. A confirmation pass that fails restarts the cycle, so no gate is weakened.
- **Evidence:** each pass records its type (scoped or full), the reason for the restart, the files that triggered it, and its duration, so the saving can be measured. Today per-pass duration is not recorded anywhere, so the size of the saving is an assumption until this lands.

Expected effect, stated as a hypothesis: in #1034 passes 2 to 4 could have been scoped, leaving the pass-3 merge and the final confirmation as full passes. The pass-4 failure (a Python contract test reached by a PowerShell hook change) shows the scope rule must include contract tests that reference changed paths; a scope limited to the changed language would have missed it until the confirmation pass.


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

- `CLAUDE.md` marks `.github/instructions/*` as the canonical policy source and says not to modify it; `.claude/` files mirror it. This change therefore needs the owner's explicit approval and must start from the canonical text.
- Scope selection can miss a regression that the full pass would catch. Mitigation: the mandatory confirmation pass, the conservative trigger list, and CI as the final gate. The residual cost is occasionally an extra scoped pass followed by a full pass that finds the miss.
- The rule adds complexity, against the simplicity-first principle. Keep the trigger list short and mechanical so an agent cannot interpret its way to a weaker check.
- Cross-runtime parity: Claude, Codex and Copilot customizations must carry the same rule; the Codex and Copilot variants have their own executor files.
- Do not apply this to an item that is mid-flight; adopt it for newly planned work so a plan and its executor use the same rule.
- The measured saving is not known. The numbers above bound the opportunity (about 32 agent-hours of test and quality-check runs in this epic) but do not predict the saving.


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
- [ ] Unit coverage areas: the scope-selection rule (changed files to affected tests, including contract and parity tests found by path reference); the full-pass trigger list; evidence validation of pass type and duration.
- [ ] Integration scenarios: replay the #1034 restart sequence against the new rule and confirm which passes become scoped and that the pass-4 contract-test failure is caught by scope selection or by the confirmation pass.
- [ ] Policy checks: all mirrored copies are byte-consistent where they are required to be; plan validators accept the amended text.
