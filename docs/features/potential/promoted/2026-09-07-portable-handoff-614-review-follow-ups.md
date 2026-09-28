# portable-handoff-614-review-follow-ups (Issue #645)

- Date captured: 2026-09-07
- Author: Dan Moisan
- Status: Promoted -> docs/features/active/portable-handoff-614-review-follow-ups/ (Issue #645)

- Issue: #645
- Issue URL: https://github.com/drmoisan/drm-copilot/issues/645
- Last Updated: 2026-09-07
## Problem / Why

The portable prepared-orchestration handoff (#614, PR #638) merged with zero blocking review findings, but the final review cycle (`docs/features/active/2026-08-31-portable-prepared-orchestration-handoff-614/remediation-inputs.2026-09-07T08-00.md`) recorded five non-blocking items, three Major and two Minor, that were deferred by orchestrator decision so the PR could land. They are durability and diagnosability gaps in the shipped surface, not behavioral defects:

- R16 (Major): the four `throw` statements in `Get-EpicPlanningRegisteredMcpTool` (`.codex/hooks/enforce-epic-planning-only.ps1` lines 58, 67, 72, 77) form the hook's entire rejection contract and none is executed by any test. Changed-line coverage for the file is 83.33%, below the 85% floor as applied to changed lines, while file-level (91.82%) and repository-level (94.77%) coverage pass.
- R17 (Major): `extensions/drm-copilot/jest.config.cjs` registers none of the 14 new production modules (`orchestration-handoff-*`, `semantic-mcp-identity.ts`, `orchestration-handoff-handlers.ts`, `mcp-repo-automation-tool-definitions-handoff.ts`) in its per-file `coverageThreshold` map, so their 99.19% line / 93.68% branch coverage is measured but not enforced.
- R18 (Major): fifteen bare `} catch {` sites across `orchestration-handoff-materializer.ts`, `-authority-service.ts`, `-path-boundary.ts`, and `-materializer-production.ts` discard the caught value before returning a generic structured code, so an operator cannot distinguish an absent file, a permission denial, and a corrupt read behind `HANDOFF_VALIDATOR_UNAVAILABLE`.
- R19 (Minor): `raw_file_sha256` in `scripts/dev_tools/orchestration_handoff_contract_support.py` is exported as public API (re-exported at `orchestration_handoff_contract.py:20`) with no production caller and no test; `test_orchestration_handoff_taskmaster_469.py` recomputes the same digests inline.
- R20 (Minor): the `TransitionPreparedOrchestrationRequest` literal at `orchestration-handoff-materializer-path-boundary.test.ts` lines 182-190 omits the ten independent expected-context fields (TS2740 under `tsconfig.jest.json`), invisible at run time because ts-jest transpiles with `isolatedModules: true`.

## Proposed Behavior

Close all five items in one bounded, test-and-hardening change with no behavioral change to the handoff contract:

1. R16: add four Pester cases, one per `throw`, asserting the exact `EPIC_PLANNING_ONLY_BLOCKED:` message, using `-RegistryPath` as the seam with committed fixture registries under `tests/fixtures/codex-hooks/` (no `TestDrive`, `New-TemporaryFile`, or temp paths).
2. R17: add 14 `coverageThreshold` entries at `lines: 85, branches: 75`; no `global` key, no `coveragePathIgnorePatterns`, no entry below the floors.
3. R18: bind the caught value (`catch (error: unknown)`, as line 272 of the materializer already does) and attach a redacted cause string to the existing `blockedResult` details channel; do not change which `HANDOFF_*` code any condition returns and do not reorder precedence.
4. R19: call `raw_file_sha256` from the fixture-hashing path that currently recomputes digests inline (preferred), or remove the definition and re-export.
5. R20: import and spread `INDEPENDENT_CONTEXT` from `orchestration-handoff-materializer-test-support.ts` as the sibling suites do.

## Acceptance Criteria (early draft)

- [ ] All four `throw` statements at `.codex/hooks/enforce-epic-planning-only.ps1` lines 58, 67, 72, 77 show as covered in `artifacts/pester/powershell-coverage.xml`; the file's missed-line set reduces to the nine pre-existing lines; repository PowerShell line coverage stays at or above 94.77%.
- [ ] `npm --prefix extensions/drm-copilot run test:coverage` exits 0 with 14 new per-file `coverageThreshold` entries at `lines: 85, branches: 75` and no `global` key.
- [ ] Zero bare `} catch {` remain in the four handoff modules; each site returns a cause alongside its code; `test_failure_precedence_matches_the_shared_registry` and every existing code-selection test pass unchanged; per-module coverage does not fall below its current figure.
- [ ] `raw_file_sha256` is referenced by at least one non-defining production or test call site, or is absent from both files; Python repository coverage stays at or above 92.89% line and 85.51% branch.
- [ ] `npx tsc -p extensions/drm-copilot/tsconfig.jest.json --noEmit` no longer reports TS2740 at `orchestration-handoff-materializer-path-boundary.test.ts:182`; the suite's assertions are unchanged and pass.
- [ ] No `HANDOFF_*` failure-code assignment, precedence order, fixture byte, or schema changes; Python, TypeScript, and PowerShell toolchains pass in one clean loop.

## Constraints & Risks

- Several touched files sit near the 500-line limit: `orchestration_handoff_contract.py` (498), `repo-automation-service.ts` (498), `orchestration-handoff-contract.ts` (497), `test_push_down_claude_resource_contracts.py` (500). R18 and R19 may require an extraction first.
- R18 must not include absolute paths or environment values in the cause string beyond what `affectedPaths` already exposes.
- The PowerShell published copy `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/enforce-epic-planning-only.ps1` must stay byte-identical to the source hook; R16 adds tests only.
- Tests must not create temporary files (repository policy).

## Test Conditions to Consider

- [ ] Four Pester cases for the registry loader rejection paths with committed fixture registries.
- [ ] Jest coverage run under the 14 new thresholds.
- [ ] Parity suites in Python, TypeScript, MCP, and hook tests confirming unchanged failure-code selection after R18.
- [ ] Test-tree type-check (`tsconfig.jest.json`) showing the TS2740 at the path-boundary suite is gone and no new diagnostic appears.

## Next Step

- [ ] Promote to GitHub issue (feature request template)
- [ ] Create `docs/features/active/portable-handoff-614-review-follow-ups/` folder from the template
