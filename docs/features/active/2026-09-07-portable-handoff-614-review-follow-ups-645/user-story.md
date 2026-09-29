# `portable-handoff-614-review-follow-ups` — User Story

- Issue: #645
- Owner: drmoisan
- Status: Draft
- Last Updated: 2026-09-29T19-29

## Story Statement

- As a ..., I want ..., so that ...
- As a ..., I want ..., so that ...

## Problem / Why

The portable prepared-orchestration handoff (#614, PR #638) merged with zero blocking review findings, but the final review cycle (`docs/features/completed/2026-08-31-portable-prepared-orchestration-handoff-614/remediation-inputs.2026-09-07T08-00.md`) recorded five non-blocking items, three Major and two Minor, that were deferred by orchestrator decision so the PR could land. They are durability and diagnosability gaps in the shipped surface, not behavioral defects:

- R16 (Major): the four `throw` statements in `Get-EpicPlanningRegisteredMcpTool` (`.codex/hooks/enforce-epic-planning-only.ps1` lines 58, 67, 72, 77) form the hook's entire rejection contract and none is executed by any test. Changed-line coverage for the file is 83.33%, below the 85% floor as applied to changed lines, while file-level (91.82%) and repository-level (94.77%) coverage pass.
- R17 (Major): `extensions/drm-copilot/jest.config.cjs` registers none of the 14 new production modules (`orchestration-handoff-*`, `semantic-mcp-identity.ts`, `orchestration-handoff-handlers.ts`, `mcp-repo-automation-tool-definitions-handoff.ts`) in its per-file `coverageThreshold` map, so their 99.19% line / 93.68% branch coverage is measured but not enforced.
- R18 (Major): fifteen bare `} catch {` sites across `orchestration-handoff-materializer.ts`, `-authority-service.ts`, `-path-boundary.ts`, and `-materializer-production.ts` discard the caught value before returning a generic structured code, so an operator cannot distinguish an absent file, a permission denial, and a corrupt read behind `HANDOFF_VALIDATOR_UNAVAILABLE`.
- R19 (Minor): `raw_file_sha256` in `scripts/dev_tools/orchestration_handoff_contract_support.py` is exported as public API (re-exported at `orchestration_handoff_contract.py:20`) with no production caller and no test; `test_orchestration_handoff_taskmaster_469.py` recomputes the same digests inline.
- R20 (Minor): the `TransitionPreparedOrchestrationRequest` literal at `orchestration-handoff-materializer-path-boundary.test.ts` lines 182-190 omits the ten independent expected-context fields (TS2740 under `tsconfig.jest.json`), invisible at run time because ts-jest transpiles with `isolatedModules: true`.


## Personas & Scenarios

- Persona: ...
  - who the user is
  - what they care about
  - their constraints
  - their goals and frustrations
  - their context and motivations
- Scenario: ...
  - A concrete, step-by-step narrative that describes how a user accomplishes a goal in a real-world context using the system.
  - who is acting?
  - what triggered the action?
  - what steps do they take?
  - what obstacles or decisions occur?
  - what outcome do they expect?


## Acceptance Criteria

- [ ] All four `throw` statements at `.codex/hooks/enforce-epic-planning-only.ps1` lines 58, 67, 72, 77 show as covered in `artifacts/pester/powershell-coverage.xml`; the file's missed-line set reduces to the nine pre-existing lines; repository PowerShell line coverage stays at or above 94.77%.
- [ ] `npm --prefix extensions/drm-copilot run test:coverage` exits 0 with 14 new per-file `coverageThreshold` entries at `lines: 85, branches: 75` and no `global` key.
- [ ] Zero bare `} catch {` remain in the four handoff modules; each site returns a cause alongside its code; `test_failure_precedence_matches_the_shared_registry` and every existing code-selection test pass unchanged; per-module coverage does not fall below its current figure.
- [ ] `raw_file_sha256` is referenced by at least one non-defining production or test call site, or is absent from both files; Python repository coverage stays at or above 92.89% line and 85.51% branch.
- [ ] `npx tsc -p extensions/drm-copilot/tsconfig.jest.json --noEmit` no longer reports TS2740 at `orchestration-handoff-materializer-path-boundary.test.ts:182`; the suite's assertions are unchanged and pass.
- [ ] No `HANDOFF_*` failure-code assignment, precedence order, fixture byte, or schema changes; Python, TypeScript, and PowerShell toolchains pass in one clean loop.


## Non-Goals

Call out what is explicitly excluded from this feature.
