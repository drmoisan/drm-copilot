# portable-handoff-614-review-follow-ups — Spec

- **Issue:** #645
- **Parent (optional):** none
- **Owner:** drmoisan
- **Last Updated:** 2026-09-29T23-55
- **Status:** Draft
- **Version:** 0.2
- **Work Mode:** full-feature
- **Research:** `research/research.2026-09-29T23-40.md` (this folder)

## Overview

The portable prepared-orchestration handoff (#614, PR #638) merged with zero blocking review findings. Its final review cycle (`docs/features/completed/2026-08-31-portable-prepared-orchestration-handoff-614/remediation-inputs.2026-09-07T08-00.md`) recorded non-blocking durability and diagnosability gaps that were deferred so the PR could land. This feature closes the subset that the 2026-09-29 consolidation comment on #645 keeps in scope. The handoff contract does not change behavior.

### Authoritative scope

The 2026-09-29 consolidation comment on #645 supersedes the issue body. Where `issue.md` and this spec disagree, this spec governs.

| Item | Severity | In scope | Summary |
|---|---|---|---|
| R16 | Major | Yes, throws at lines 58, 72, 77 only | `Get-EpicPlanningRegisteredMcpTool` in `.codex/hooks/enforce-epic-planning-only.ps1` has rejection throws that no test executes. The throw at line 67 is already covered by `tests/scripts/codex-hooks/codex-planning-only-registry.Tests.ps1` (`It 'throws for a semantic tool when the registry fixture is invalid'`) and needs no new work. |
| R17 | Major | Yes | `extensions/drm-copilot/jest.config.cjs` enforces no per-file `coverageThreshold` for the 14 handoff production modules. |
| R18 | Major | Yes | 15 bare `} catch {` sites in four handoff modules discard the caught value, so an operator cannot tell an absent file, a permission denial, and a corrupt read apart behind one `HANDOFF_*` code. |
| R19 | Minor | Yes | `raw_file_sha256` is exported public API with no caller and no test. |
| R20 | Minor | **No** | The `INDEPENDENT_CONTEXT` / TS2740 defect in `extensions/drm-copilot/test/lib/validate/orchestration-handoff-materializer-path-boundary.test.ts` is resolved by issue #647. This feature authors no acceptance criterion for R20 and must not edit that test file. |

Two parts of the `issue.md` early-draft acceptance criteria are superseded. The first is the R20 criterion. The second is the reference to line 67 in the R16 criterion. The fixed coverage percentages in `issue.md` (94.77% PowerShell line, 92.89% / 85.51% Python line / branch) are historical values that the research could not re-measure. This spec replaces them with a no-regression rule against a Phase 0 baseline.

## Behavior

1. **R16.** Add Pester cases that call `Get-EpicPlanningRegisteredMcpTool` directly with `-RegistryPath` set to a committed fixture or the committed absent-path sentinel. Each case asserts the exact `EPIC_PLANNING_ONLY_BLOCKED:` message for one of the throws at lines 58, 72, and 77. The hook source is not edited.
2. **R17.** Register the 14 handoff production modules in the `coverageThreshold` map at `{ lines: 85, branches: 75 }`. Add no `global` key and no `coveragePathIgnorePatterns`.
3. **R18.** Rewrite every bare `catch` in the four modules to bind `error: unknown`. Build a redacted cause string from the bound value. Attach that cause to each blocked result that is produced after a caught error. Which `HANDOFF_*` code each condition returns, and the precedence order, stay unchanged.
4. **R19.** Call `raw_file_sha256` from the pinned-fixture hash test in place of the inline `hashlib` recomputation. Production Python files are unchanged.

## Inputs / Outputs

- **Inputs.** No new CLI flag, environment variable, or configuration key. R16 adds two committed fixture registries under `tests/fixtures/codex-hooks/`.
- **Outputs.**
  - `TransitionPreparedOrchestrationResult` and `PortableHandoffAuthorityResult` gain an optional `failureCause?: string`. It is set only on blocked results that follow a caught error or a sentinel failure (see Decision D1).
  - `PortableHandoffMcpToolResult` in `src/mcp-tools.ts` gains an optional `failure_cause?: string`. The handler adds it by conditional spread, so the key is absent when the value is unset.
- **Backward compatibility.**
  - The new fields are additive and optional.
  - MCP `inputSchema` definitions are unchanged. No MCP output schema exists.
  - The envelope schema `config/orchestration-handoff.schema.json` is unchanged.
  - The public `HandoffPathBoundary` interface is unchanged.

## API / CLI Surface

- **Cause-string grammar.** `<stage>: <token>`. Multiple causes are joined with `; `.
  - `<stage>` is a fixed kebab-case label defined in source, for example `checkpoint-read`, `envelope-decode`, `git-status`, `archive-write`, `archive-readback`, `candidate-write`, `candidate-readback`, `candidate-validate`, `candidate-replace`, `candidate-cleanup`, `envelope-read`, `plan-read`, `destination-projection`, `workspace-root`, `target-path`.
  - `<token>` is one of these:
    - `error.code`, when it is a string that matches `^[A-Z][A-Z0-9_]*$` (for example `ENOENT`, `EACCES`, `EEXIST`, `ERR_ENCODING_INVALID_ENCODED_DATA`, `HANDOFF_CANDIDATE_MISMATCH`);
    - otherwise `error.name`, when the value is an `Error`;
    - otherwise the literal `non-error value`;
    - or, at the sentinel sites in D1, a fixed literal (`unresolved`, `invalid`).
  - The helper never reads `error.message` or `error.stack`. A cause string therefore contains no absolute path, file content, or environment value.
- **Helper.** `describeHandoffFailureCause(stage: string, error: unknown): string` is a pure function added to `src/lib/validate/orchestration-handoff-materializer-request.ts`, which already holds `blockedResult`.
- **Example (MCP output, blocked).** `{ "status": "blocked", "primary_failure_code": "HANDOFF_VALIDATOR_UNAVAILABLE", "failure_cause": "checkpoint-read: EACCES", ... }`. Validated and materialized results carry no `failure_cause` key.

## Data & State

- For every input, the following fields are identical to the pre-change behavior: `status`, `primaryFailureCode`, `affectedPaths`, `unsupportedCapabilities`, `handoffId`, and `handoffHistorySha256`.
- The only new data is the optional cause field. Nothing is persisted, and no migration is required.
- Committed fixtures are not modified. The two new R16 fixtures are additions.

## Decisions

### D1 — How "zero bare catch and a cause alongside the code" applies to the four sites that return no code

The four sites are:

- authority-service.ts:168 (`observedPlanSha256`, private);
- materializer-production.ts:49 (`validateDestinationProjection`, returns `readonly string[]` through the `validator` dependency);
- path-boundary.ts:118 (`resolveWorkspaceRoot`, public `HandoffPathBoundary`, returns `string | null`);
- path-boundary.ts:140 (`resolveExistingTarget`, public `HandoffPathBoundary`, returns `string | null`).

**Rule adopted.** Zero bare `catch` is required at all 15 sites, with no exceptions. The cause requirement applies to the *code-returning blocked result*, not to the catch site. Every blocked result that carries a `HANDOFF_*` code must also carry a redacted `failureCause` when a caught error or a sentinel failure produced it. At each sentinel site the bound error is carried as far as that site's existing return contract allows without a breaking change. The caller that selects the code attaches the cause.

| Site | Site-level change | Caller-level cause | Errno surfaced to operator |
|---|---|---|---|
| authority-service.ts:168 | Bind the error. The private `observedPlanSha256` returns a discriminated value (`{ sha256 }` or `{ failureCause }`). No public API is affected. | The caller at lines ~327-330 passes `failureCause` (for example `plan-read: ENOENT`) to `blocked(..., "HANDOFF_PLAN_PATH_INVALID", ...)`. | Yes |
| materializer-production.ts:49 | Bind the error. Return a one-element array, `` [`destination checkpoint must be valid JSON (${token})`] ``. The array length stays 1, so the existing `toHaveLength(1)` assertion and the `.length` consumers at materializer.ts 286 and 408 are unaffected. The `validator` dependency signature is unchanged. | The blocked result at materializer.ts:286 attaches `destination-projection: invalid`. The re-validation at 408 is inside site 8 and receives that site's cause (`candidate-validate: HANDOFF_CANDIDATE_MISMATCH`). | Yes, in the projection message. The result field carries the stage only. |
| path-boundary.ts:118, :140 | Route `realpath` and `stat` through a module-private helper that binds `error: unknown` and returns `{ ok: true, value }` or `{ ok: false, cause }`. The public resolvers map a failure to `null`, which is the unchanged contract. | Callers that map `null` to `HANDOFF_PLAN_PATH_INVALID` attach a stage-level cause: `workspace-root: unresolved` (materializer.ts ~143, authority-service.ts ~276) or `target-path: unresolved` (materializer.ts ~154, authority-service.ts ~128 and ~165). | No. Stage only. |

**Rationale.**

- This is the simplest design that satisfies both constraints: zero bare `catch`, and a redacted cause on every code-returning blocked result.
- It changes no public interface and no MCP input schema, and it adds one optional output field.
- To surface the path-boundary errno, `HandoffPathBoundary` would need a union return or an extra method. That would touch three implementations (`path-boundary.ts`, `createSyntacticHandoffPathBoundary` in `materializer-support.ts`, and `createDefaultPathBoundary` in `authority-service.ts`) plus the test fakes. That exceeds the constraint and the simplicity priority.
- Two alternatives were rejected. Logging the cause was rejected because the modules have no logger seam and a log does not reach the MCP caller. Reusing `affectedPaths` or `unsupportedCapabilities` was rejected because it would overload fields whose semantics are fixed and pinned by tests.
- The errno at the two path-boundary sites is not surfaced. This limitation is recorded under Non-Goals as a candidate follow-up.

### D2 — `materializer.ts` line budget (research open risk 2)

- The projected size after R18 is about 475 lines against the 500-line limit.
- The implementer must count lines after the edit. If the file exceeds 490 lines, move the archive and candidate write-recovery blocks of `stageMaterialization` into the existing module `orchestration-handoff-materializer-support.ts` (77 lines).
- A new production module is not the preferred fallback. If one is created anyway, it must receive its own `coverageThreshold` entry (AC-6).
- The new tests go in a new sibling file, `test/lib/validate/orchestration-handoff-failure-cause.test.ts`. The reason is that `materializer.test.ts` (492 lines) and `authority-service.test.ts` (495 lines) have no headroom.

### D3 — Branch-coverage headroom in `path-boundary.ts` (research open risk 4)

- `orchestration-handoff-path-boundary.ts` has the lowest recorded branch figure (81.13%).
- The module-private helper in D1 adds branches, so its success and failure arms must each be executed by a test. Put that test in `test/lib/validate/orchestration-handoff-path-boundary.test.ts` (224 lines) or in the new failure-cause test file.
- The acceptance rule is the per-file floor (75% branch) plus no regression against the Phase 0 baseline for each of the four R18 modules (AC-17).

### D4 — MCP packaging (research open risk 5)

- `failure_cause` is new optional output on the handoff MCP tools.
- `extensions/drm-copilot/test/packaging/mcp-server-prepack.test.ts` was not read during research. It must be executed and must pass (AC-18).
- If it asserts output field sets, update the assertion additively. It must not be weakened.

### D5 — Property-based testing

- No `quality-tiers.yml` exists in this worktree, and `fast-check` is not a dependency of `extensions/drm-copilot/package.json`.
- Adding a dependency is out of scope.
- The redaction property of `describeHandoffFailureCause` is therefore tested with table-driven example cases (AC-10). If a tier classification that requires property tests is found during planning, the planner must record it and escalate. The planner must not add the dependency unilaterally.

## Constraints & Risks

- **Line limits.** Every file touched must stay at or under 500 lines. Near-limit files are `materializer.ts` (444), `authority-service.test.ts` (495), `materializer.test.ts` (492), and `scripts/dev_tools/orchestration_handoff_contract.py` (498; not edited).
- **Redaction.** Cause strings must not contain absolute paths, file content, or environment values. Only `error.code` / `error.name` class tokens and fixed literals are allowed. Node filesystem error messages, `SyntaxError` messages, and the test fakes' messages all embed paths or input text, so `message` is never read.
- **Hook parity.** The published copy `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/enforce-epic-planning-only.ps1` must stay byte-identical to `.codex/hooks/enforce-epic-planning-only.ps1`. R16 adds tests only.
- **Test purity.** Tests use committed fixtures only. They must not use `TestDrive`, `New-TemporaryFile`, `[System.IO.Path]::GetTempPath`, `$env:TEMP`, Node `os.tmpdir`, or Python `tempfile`/`tmp_path`.
- **#647 overlap.** `orchestration-handoff-materializer-path-boundary.test.ts` must not be edited. If #647 merges first and changes `orchestration-handoff-materializer-test-support.ts`, rebase and adjust the new failure-cause test file.
- **Lint inference.** `@typescript-eslint/no-unused-vars` is inferred to use `caughtErrors: "all"`, so each bound error must be used. The research inferred this and did not execute it. The toolchain loop confirms it.
- **Pre-existing diagnostic.** `npx tsc -p tsconfig.jest.json --noEmit` reports TS2740 at `orchestration-handoff-materializer-path-boundary.test.ts` until #647 lands. That diagnostic is out of scope. It must not count as a regression, and no new diagnostic may appear.

## Implementation Strategy

- **Phase 0 baselines.** Write these to `docs/features/active/2026-09-07-portable-handoff-614-review-follow-ups-645/evidence/baselines/`:
  - per-file line and branch coverage (lcov) for the 14 TypeScript modules;
  - repository Python line and branch coverage;
  - repository PowerShell line coverage;
  - the missed-line set for `.codex/hooks/enforce-epic-planning-only.ps1` from `artifacts/pester/powershell-coverage.xml`;
  - the `tsconfig.jest.json` diagnostic list.
- **Files in scope** (see research section 4):
  - R16: `tests/scripts/codex-hooks/codex-planning-only-registry.Tests.ps1`, plus two new fixtures `tests/fixtures/codex-hooks/invalid-operation-orchestration-handoff-registry.json` and `tests/fixtures/codex-hooks/invalid-alias-orchestration-handoff-registry.json`.
  - R17: `extensions/drm-copilot/jest.config.cjs`.
  - R18 source: under `extensions/drm-copilot/src/lib/validate/`, the files `orchestration-handoff-materializer-request.ts`, `-materializer.ts`, `-authority-service.ts`, `-materializer-production.ts`, `-path-boundary.ts`, and (only under the D2 fallback) `-materializer-support.ts`. Also `src/mcp-repo-automation-tool-definitions-handoff.ts`, `src/mcp-handlers/orchestration-handoff-handlers.ts`, and `src/mcp-tools.ts`.
  - R18 tests: new `test/lib/validate/orchestration-handoff-failure-cause.test.ts`; `test/mcp-handlers/orchestration-handoff-handlers.test.ts`; optionally `test/lib/validate/orchestration-handoff-path-boundary.test.ts`; and `test/packaging/mcp-server-prepack.test.ts` only if D4 requires it.
  - R19: `tests/scripts/dev_tools/test_orchestration_handoff_taskmaster_469.py`; `tests/scripts/dev_tools/orchestration_handoff_taskmaster_469_test_support.py` (add a public `fixture_paths`).
- **Site-level cause behavior.**
  - Sites materializer 351 and 379 (write followed by a recovery readback) bind the outer write error. If the recovery path blocks, the cause includes both stages (for example `archive-write: EEXIST; archive-readback: EACCES`). If the recovery succeeds, no cause is emitted.
  - Site 413 gives the synthetic throw at line ~411 an internal `code` of `HANDOFF_CANDIDATE_MISMATCH`. This marker is not a `HandoffFailureCode` and is not added to the registry.
  - Site 440 (`discardCandidate`) returns the cleanup cause or `null`. Callers at ~414 and ~427 append it as `; candidate-cleanup: <token>`.
- **Dependencies.** None added or removed.
- **Logging/telemetry.** None. The cause travels in the result object.
- **Rollout.** A single PR. No flag is needed because the output change is additive.

## Acceptance Criteria

Each criterion names its verification method. "Phase 0 baseline" means the values recorded under `evidence/baselines/` before any production or test edit.

- [x] AC-1: `tests/scripts/codex-hooks/codex-planning-only-registry.Tests.ps1` contains three new `It` cases that call `Get-EpicPlanningRegisteredMcpTool` directly. Each case asserts the captured `$_.Exception.Message` with `Should -BeExactly` against the exact message of one throw:
  - line 58, using the absent sentinel `tests/fixtures/codex-hooks/absent-orchestration-handoff-registry.json`;
  - line 72, using `invalid-operation-orchestration-handoff-registry.json`;
  - line 77, using `invalid-alias-orchestration-handoff-registry.json`.

  Verification: the PoshQC Pester run (`mcp__drm-copilot__run_poshqc_test`) is followed by a read of `artifacts/pester/pester-junit.xml`, which must report `failures="0"` and `errors="0"` and list the three new cases as passed. The existing line-67 case is unchanged.
- [x] AC-2: `artifacts/pester/powershell-coverage.xml` from the same run shows lines 58, 72, and 77 of `.codex/hooks/enforce-epic-planning-only.ps1` as covered. The file's missed-line set must be a subset of the Phase 0 missed-line set minus {58, 72, 77}, so no new missed line appears. The report-level PowerShell line coverage must be at or above the Phase 0 baseline.
- [x] AC-3: Fixtures and test purity.
  - Exactly two new files are added under `tests/fixtures/codex-hooks/`: `invalid-operation-orchestration-handoff-registry.json` and `invalid-alias-orchestration-handoff-registry.json`.
  - A Grep for `TestDrive|New-TemporaryFile|GetTempPath|\$env:TEMP|tmpdir|tempfile|tmp_path` over every test file added or changed by this feature returns zero matches.
  - `.claude/hooks/check-powershell-test-purity.ps1` does not deny the Pester file.
- [x] AC-4: `git diff --quiet origin/main -- .codex/hooks/enforce-epic-planning-only.ps1 extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/enforce-epic-planning-only.ps1` exits 0. `tests/scripts/dev_tools/test_push_down_codex_and_agents_customizations.py::test_handoff_runtime_has_root_bundle_resource_and_effective_pack_parity` passes.
- [x] AC-5: Static check of `extensions/drm-copilot/jest.config.cjs`.
  - `coverageThreshold` contains the following 14 keys, each set to exactly `{ lines: 85, branches: 75 }`:
    - `./src/lib/validate/orchestration-handoff-authority-service.ts`
    - `./src/lib/validate/orchestration-handoff-checkout-context.ts`
    - `./src/lib/validate/orchestration-handoff-contract-support.ts`
    - `./src/lib/validate/orchestration-handoff-contract.ts`
    - `./src/lib/validate/orchestration-handoff-materializer-production.ts`
    - `./src/lib/validate/orchestration-handoff-materializer-request.ts`
    - `./src/lib/validate/orchestration-handoff-materializer-support.ts`
    - `./src/lib/validate/orchestration-handoff-materializer.ts`
    - `./src/lib/validate/orchestration-handoff-path-boundary.ts`
    - `./src/lib/validate/orchestration-handoff-provider-adapters.ts`
    - `./src/lib/validate/orchestration-handoff-validation.ts`
    - `./src/lib/validate/semantic-mcp-identity.ts`
    - `./src/mcp-handlers/orchestration-handoff-handlers.ts`
    - `./src/mcp-repo-automation-tool-definitions-handoff.ts`
  - The file contains no `global` key and no `coveragePathIgnorePatterns` key. (Member set: research N1.)
- [x] AC-6: `npm --prefix extensions/drm-copilot run test:coverage` exits 0.
  - The lcov output reports each of the 14 files at or above 85% line and 75% branch.
  - Any new production `.ts` file created under `extensions/drm-copilot/src/` by this feature has its own `{ lines: 85, branches: 75 }` entry.
- [x] AC-7: A Grep for `catch\s*\{` over the four modules returns zero matches. The modules are `extensions/drm-copilot/src/lib/validate/orchestration-handoff-materializer.ts`, `-authority-service.ts`, `-path-boundary.ts`, and `-materializer-production.ts`. The same Grep over every `extensions/drm-copilot/src/**/*{handoff,semantic-mcp}*.ts` file also returns zero matches. (Site set: research N2.)
- [x] AC-8: `extensions/drm-copilot/test/lib/validate/orchestration-handoff-failure-cause.test.ts` covers each blocked result that follows a caught error. There is at least one named case per result: materializer checkpoint-read, envelope-decode, git-status, archive-write plus archive-readback, candidate-write plus candidate-readback, candidate-validate, candidate-replace, candidate-cleanup appended; authority envelope-read and plan-read.
  - Each case asserts the unchanged `primaryFailureCode` and a `failureCause` equal to the expected `<stage>: <token>` string.
  - The idempotent-retry case asserts that no `failureCause` is present when recovery succeeds.
- [x] AC-9: Decision D1 is implemented and verified by named tests.
  - The `HandoffPathBoundary` interface declaration is unchanged, as a static check against `origin/main`.
  - The existing tests in `orchestration-handoff-path-boundary.test.ts` pass unchanged, and a test executes both arms of the new module-private helper.
  - Blocked results from `null` path resolution carry `workspace-root: unresolved` or `target-path: unresolved` together with the unchanged `HANDOFF_PLAN_PATH_INVALID`.
  - The authority plan-read case carries `plan-read: <token>`.
  - `validateDestinationProjection` returns exactly one message for invalid JSON, and that message contains the error token. The existing `toHaveLength(1)` assertion in `orchestration-handoff-materializer-production.test.ts` passes unchanged.
  - The blocked result at materializer.ts ~286 carries `destination-projection: invalid`.
- [x] AC-10: Table-driven unit tests of `describeHandoffFailureCause` cover the `error.code` branch, the `error.name` branch, the non-error branch, and a `code` that does not match `^[A-Z][A-Z0-9_]*$`. Given errors whose `message` contains a Windows absolute path, a POSIX absolute path, and an environment-variable-like value, the output contains none of those substrings, and contains no `/` or `\` character.
- [x] AC-11: Additive output is verified in `extensions/drm-copilot/test/mcp-handlers/orchestration-handoff-handlers.test.ts`:
  - the MCP result includes `failure_cause` when `failureCause` is set;
  - the key is absent (`not.toHaveProperty("failure_cause")`) when it is unset;
  - validated and materialized results carry no `failureCause`.
- [x] AC-12: Failure-code assignment and precedence are unchanged.
  - The following tests pass with no edit to their files, confirmed by `git diff --quiet origin/main` on each file:
    - `tests/scripts/dev_tools/test_orchestration_handoff_contract.py::test_failure_precedence_matches_the_shared_registry`;
    - the `HANDOFF_FAILURE_PRECEDENCE` registry-equality test in `extensions/drm-copilot/test/lib/validate/orchestration-handoff-contract.test.ts`;
    - the registry-order selection test in `extensions/drm-copilot/test/lib/validate/orchestration-handoff-authority-service.test.ts`.
  - The `NEGATIVE_SCENARIOS` cases in `tests/scripts/dev_tools/test_orchestration_handoff_taskmaster_469.py` pass, and the `NEGATIVE_SCENARIOS` definition is textually unchanged against `origin/main`. That file is edited only by R19.
  - `config/orchestration-handoff-registry.json` and `extensions/drm-copilot/src/lib/validate/orchestration-handoff-contract.ts` are unchanged against `origin/main`.
- [x] AC-13: No existing fixture or schema changes. `git diff --diff-filter=MDR --name-only origin/main` lists no file under `tests/fixtures/`, `extensions/drm-copilot/test/fixtures/`, `config/`, or `extensions/drm-copilot/resources/config/`. The `inputSchema` blocks in `src/mcp-repo-automation-tool-definitions-handoff.ts` are textually unchanged against `origin/main`.
- [x] AC-14: `git diff --name-only origin/main` does not list `extensions/drm-copilot/test/lib/validate/orchestration-handoff-materializer-path-boundary.test.ts`. R20 is out of scope (resolved by #647).
- [x] AC-15: `raw_file_sha256`, imported from `scripts.dev_tools.orchestration_handoff_contract`, is called in `test_taskmaster_469_fixture_hashes_and_source_history_are_pinned`, and that test passes. A Grep for `hashlib` in `test_orchestration_handoff_taskmaster_469.py` returns zero matches. `scripts/dev_tools/orchestration_handoff_contract.py` and `scripts/dev_tools/orchestration_handoff_contract_support.py` are unchanged against `origin/main`.
- [x] AC-16: `poetry run pytest --cov=src --cov=scripts/dev_tools --cov-branch --cov-report=term-missing` exits 0. The repository Python line and branch coverage are each at or above the Phase 0 baseline.
- [x] AC-17: For each R18 module, lcov line and branch coverage after the change is at or above its Phase 0 baseline and at or above 85% line and 75% branch. The R18 modules are `orchestration-handoff-materializer.ts`, `-authority-service.ts`, `-path-boundary.ts`, `-materializer-production.ts`, and `-materializer-request.ts`.
- [x] AC-18: `extensions/drm-copilot/test/packaging/mcp-server-prepack.test.ts` runs in the `test:coverage` invocation and reports all of its tests passed. None of its assertions is removed or weakened.
- [x] AC-19: Every file added or modified by this feature, other than Markdown documentation and JSON fixtures, is at or under 500 lines, confirmed by a post-edit line count recorded in evidence. If `orchestration-handoff-materializer.ts` exceeds 490 lines, the D2 extraction into `orchestration-handoff-materializer-support.ts` is applied.
- [x] AC-20: The full toolchain loop passes in a single pass for Python, TypeScript, and PowerShell. The loop covers format, lint, type check, tests, and the packaging and parity tests.
  - Python: `black --check`, `ruff check`, `pyright`, `pytest`.
  - TypeScript: `prettier --check`, `npm run lint`, `npm run typecheck`, `npm run test:coverage`.
  - PowerShell: PoshQC format, analyze, and test.

  `npx tsc -p extensions/drm-copilot/tsconfig.jest.json --noEmit` reports no diagnostic outside the Phase 0 diagnostic list.
- [x] AC-21: No dependency is added or removed. `extensions/drm-copilot/package.json` dependency blocks and `pyproject.toml` dependency tables are unchanged against `origin/main`.
- [x] AC-22: Phase 0 baseline evidence and final coverage evidence exist under `docs/features/active/2026-09-07-portable-handoff-614-review-follow-ups-645/evidence/` in the canonical `<kind>/` subfolders. No evidence is written under `artifacts/baselines/`, `artifacts/qa/`, or `artifacts/coverage/`.

## Non-Goals

- R20 (`INDEPENDENT_CONTEXT` / TS2740). This is resolved by #647.
- Surfacing the path-boundary errno through `HandoffPathBoundary` (D1). This is a candidate follow-up that would require an interface change across three implementations.
- Any change to `HANDOFF_*` codes, precedence, the envelope schema, MCP input schemas, or the hook source.
- Adding `fast-check` or any other dependency.

## Definition of Done

- [ ] Acceptance criteria AC-1 through AC-22 verified, with evidence recorded under `evidence/`.
- [ ] Tests added: Pester (R16), jest failure-cause suite and handler mapping (R18), pytest update (R19).
- [ ] Edge cases covered: write-recovery success versus failure, cleanup failure, non-error thrown values, and redaction inputs.
- [ ] Toolchain loop clean in one pass (AC-20).
