# portable-handoff-614-review-follow-ups — Spec

- **Issue:** #645
- **Parent (optional):** none
- **Owner:** drmoisan
- **Last Updated:** 2026-09-29T19-29
- **Status:** Draft
- **Version:** 0.1

## Overview

The portable prepared-orchestration handoff (#614, PR #638) merged with zero blocking review findings, but the final review cycle (`docs/features/completed/2026-08-31-portable-prepared-orchestration-handoff-614/remediation-inputs.2026-09-07T08-00.md`) recorded five non-blocking items, three Major and two Minor, that were deferred by orchestrator decision so the PR could land. They are durability and diagnosability gaps in the shipped surface, not behavioral defects:

- R16 (Major): the four `throw` statements in `Get-EpicPlanningRegisteredMcpTool` (`.codex/hooks/enforce-epic-planning-only.ps1` lines 58, 67, 72, 77) form the hook's entire rejection contract and none is executed by any test. Changed-line coverage for the file is 83.33%, below the 85% floor as applied to changed lines, while file-level (91.82%) and repository-level (94.77%) coverage pass.
- R17 (Major): `extensions/drm-copilot/jest.config.cjs` registers none of the 14 new production modules (`orchestration-handoff-*`, `semantic-mcp-identity.ts`, `orchestration-handoff-handlers.ts`, `mcp-repo-automation-tool-definitions-handoff.ts`) in its per-file `coverageThreshold` map, so their 99.19% line / 93.68% branch coverage is measured but not enforced.
- R18 (Major): fifteen bare `} catch {` sites across `orchestration-handoff-materializer.ts`, `-authority-service.ts`, `-path-boundary.ts`, and `-materializer-production.ts` discard the caught value before returning a generic structured code, so an operator cannot distinguish an absent file, a permission denial, and a corrupt read behind `HANDOFF_VALIDATOR_UNAVAILABLE`.
- R19 (Minor): `raw_file_sha256` in `scripts/dev_tools/orchestration_handoff_contract_support.py` is exported as public API (re-exported at `orchestration_handoff_contract.py:20`) with no production caller and no test; `test_orchestration_handoff_taskmaster_469.py` recomputes the same digests inline.
- R20 (Minor): the `TransitionPreparedOrchestrationRequest` literal at `orchestration-handoff-materializer-path-boundary.test.ts` lines 182-190 omits the ten independent expected-context fields (TS2740 under `tsconfig.jest.json`), invisible at run time because ts-jest transpiles with `isolatedModules: true`.


## Behavior

Close all five items in one bounded, test-and-hardening change with no behavioral change to the handoff contract:

1. R16: add four Pester cases, one per `throw`, asserting the exact `EPIC_PLANNING_ONLY_BLOCKED:` message, using `-RegistryPath` as the seam with committed fixture registries under `tests/fixtures/codex-hooks/` (no `TestDrive`, `New-TemporaryFile`, or temp paths).
2. R17: add 14 `coverageThreshold` entries at `lines: 85, branches: 75`; no `global` key, no `coveragePathIgnorePatterns`, no entry below the floors.
3. R18: bind the caught value (`catch (error: unknown)`, as line 272 of the materializer already does) and attach a redacted cause string to the existing `blockedResult` details channel; do not change which `HANDOFF_*` code any condition returns and do not reorder precedence.
4. R19: call `raw_file_sha256` from the fixture-hashing path that currently recomputes digests inline (preferred), or remove the definition and re-export.
5. R20: import and spread `INDEPENDENT_CONTEXT` from `orchestration-handoff-materializer-test-support.ts` as the sibling suites do.


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

- Several touched files sit near the 500-line limit: `orchestration_handoff_contract.py` (498), `repo-automation-service.ts` (498), `orchestration-handoff-contract.ts` (497), `test_push_down_claude_resource_contracts.py` (500). R18 and R19 may require an extraction first.
- R18 must not include absolute paths or environment values in the cause string beyond what `affectedPaths` already exposes.
- The PowerShell published copy `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/enforce-epic-planning-only.ps1` must stay byte-identical to the source hook; R16 adds tests only.
- Tests must not create temporary files (repository policy).


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
- [ ] Four Pester cases for the registry loader rejection paths with committed fixture registries.
- [ ] Jest coverage run under the 14 new thresholds.
- [ ] Parity suites in Python, TypeScript, MCP, and hook tests confirming unchanged failure-code selection after R18.
- [ ] Test-tree type-check (`tsconfig.jest.json`) showing the TS2740 at the path-boundary suite is gone and no new diagnostic appears.
