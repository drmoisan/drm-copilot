# `portable-handoff-614-review-follow-ups` — User Story

- Issue: #645
- Owner: drmoisan
- Status: Draft
- Last Updated: 2026-09-29T23-55
- Spec: `spec.md` (this folder). The spec's acceptance criteria govern where the two documents differ.

## Story Statement

- As an orchestration operator, I want each blocked portable-handoff result to state a redacted cause next to its `HANDOFF_*` code, so that I can tell an absent file, a permission denial, and a corrupt read apart without reproducing the failure.
- As a repository maintainer, I want the 14 handoff production modules to have enforced per-file coverage floors, so that a future change cannot silently lower their coverage.
- As a hook maintainer, I want every untested rejection path of the epic planning-only hook's registry loader to be executed by a test that asserts the exact message, so that a change to the rejection contract fails CI.
- As a Python maintainer, I want `raw_file_sha256` to have a real call site, so that the public API carries no dead surface and the fixture-hash test uses the shared helper.

## Problem / Why

The portable prepared-orchestration handoff (#614, PR #638) shipped with non-blocking review findings deferred. The 2026-09-29 consolidation comment on #645 limits this feature to four of them:

- **R16.** The throws at lines 58, 72, and 77 of `Get-EpicPlanningRegisteredMcpTool` (`.codex/hooks/enforce-epic-planning-only.ps1`) are not executed by any test. The throw at line 67 is already covered.
- **R17.** `extensions/drm-copilot/jest.config.cjs` measures, but does not enforce, coverage for the 14 handoff production modules.
- **R18.** 15 bare `} catch {` sites in four handoff modules discard the caught error. The returned code alone does not identify the cause.
- **R19.** `raw_file_sha256` is exported with no caller, and a test recomputes the same digests inline.

R20 (`INDEPENDENT_CONTEXT` / TS2740 in `orchestration-handoff-materializer-path-boundary.test.ts`) is out of scope because issue #647 resolves it.

## Personas & Scenarios

- **Persona: orchestration operator.**
  - Runs the prepared-orchestration transition and authority MCP tools across checkouts.
  - Cares about acting on a blocked result without reading source code.
  - Constraint: the result must not leak host paths or environment values beyond what `affectedPaths` already exposes.
- **Persona: repository maintainer / reviewer.**
  - Relies on CI gates, not on manual inspection, to keep coverage at 85% line / 75% branch per file.
- **Scenario: permission denial during materialization.**
  1. The operator invokes the transition tool.
  2. The source checkpoint cannot be read because of a permission error.
  3. Before this change, the result shows only `HANDOFF_VALIDATOR_UNAVAILABLE`.
  4. After this change, the same code is returned, together with `failure_cause: "checkpoint-read: EACCES"`.
  5. The operator fixes the file permission instead of investigating the validator.
- **Scenario: unresolvable workspace root.**
  1. The path boundary cannot resolve the workspace root.
  2. The result keeps `HANDOFF_PLAN_PATH_INVALID` and adds `failure_cause: "workspace-root: unresolved"`.
  3. The operator knows which path stage failed.
  4. The underlying errno is not surfaced for this stage, because the public `HandoffPathBoundary` interface is unchanged (spec Decision D1).
- **Scenario: registry drift in the hook.**
  1. A maintainer edits the registry loader's validation.
  2. A Pester case asserting an exact `EPIC_PLANNING_ONLY_BLOCKED:` message fails.
  3. The contract change is caught before merge.

## Acceptance Criteria

- [x] US-1 (operator diagnosability): Every blocked handoff result that follows a caught error or a path-resolution sentinel failure carries a `failureCause` (and, in MCP output, `failure_cause`) in the form `<stage>: <token>`. This is verified by the named cases in `extensions/drm-copilot/test/lib/validate/orchestration-handoff-failure-cause.test.ts` and `extensions/drm-copilot/test/mcp-handlers/orchestration-handoff-handlers.test.ts` (spec AC-8, AC-9, AC-11).
- [x] US-2 (redaction): Cause strings contain only `error.code` / `error.name` class tokens or fixed literals. They contain no absolute path, file content, or environment value. This is verified by the table-driven helper tests (spec AC-10).
- [x] US-3 (no contract change): For every input, `status`, `primaryFailureCode`, `affectedPaths`, `unsupportedCapabilities`, `handoffId`, and `handoffHistorySha256` are unchanged. `HANDOFF_*` assignment and precedence, existing fixtures, the envelope schema, MCP input schemas, and the public `HandoffPathBoundary` interface are unchanged. Validated and materialized results carry no cause (spec AC-9, AC-11, AC-12, AC-13).
- [x] US-4 (zero bare catch): A Grep for `catch\s*\{` over the four R18 handoff modules, and over every handoff or semantic-mcp source file, returns zero matches (spec AC-7).
- [x] US-5 (enforced coverage floors): `extensions/drm-copilot/jest.config.cjs` has 14 per-file `coverageThreshold` entries at `{ lines: 85, branches: 75 }`, with no `global` key and no `coveragePathIgnorePatterns`. `npm --prefix extensions/drm-copilot run test:coverage` exits 0 (spec AC-5, AC-6, AC-17).
- [x] US-6 (tested hook rejection contract): Pester cases assert the exact messages of the throws at lines 58, 72, and 77 using committed fixtures only. The PowerShell coverage report shows those lines as covered. The hook source and its published copy are byte-identical and unchanged (spec AC-1, AC-2, AC-3, AC-4).
- [x] US-7 (no dead public API): `raw_file_sha256` is called by `test_taskmaster_469_fixture_hashes_and_source_history_are_pinned`, which passes. The inline `hashlib` recomputation is removed, and the production Python files are unchanged (spec AC-15).
- [x] US-8 (no regression): Python, PowerShell, and per-module TypeScript coverage are at or above the Phase 0 baseline. Every touched file is at or under 500 lines. `mcp-server-prepack.test.ts` passes. The full toolchain loop passes in one pass with no new `tsconfig.jest.json` diagnostic (spec AC-16 through AC-20).
- [x] US-9 (scope boundary): `orchestration-handoff-materializer-path-boundary.test.ts` is not modified, and no dependency is added (spec AC-14, AC-21).

## Non-Goals

- R20 (`INDEPENDENT_CONTEXT` / TS2740), which is resolved by #647.
- Surfacing the path-boundary errno. This is a candidate follow-up that requires a `HandoffPathBoundary` interface change.
- Changing the hook source, `HANDOFF_*` codes, precedence, or any schema.
