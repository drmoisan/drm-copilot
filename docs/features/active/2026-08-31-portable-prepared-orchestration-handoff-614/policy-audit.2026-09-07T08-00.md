# Policy Compliance Audit: Portable Prepared Orchestration Handoff (issue #614)

**Audit Date:** 2026-09-07
**Branch:** `feature/portable-prepared-orchestration-handoff-614` @ `645c40b02039c6c7203fcd5515e1e2ee2168bc01`
**Base:** `main` resolved to `origin/main @ 0542c92a7c589cfe952a0dfd480223960fd1eb33`
**Merge base:** `0542c92a7c589cfe952a0dfd480223960fd1eb33`
**Pull request:** https://github.com/drmoisan/drm-copilot/pull/638
**Scope:** full branch diff versus the resolved base branch — 324 files changed, 32609 insertions, 606 deletions, across 11 commits.

**Code Under Test:** 89 non-documentation files changed. By language: 37 TypeScript files (14 new production modules under `extensions/drm-copilot/src/`, 7 modified production modules, 16 test/test-support files); 19 Python files (3 new production modules and 2 modified modules under `scripts/dev_tools/`, 14 test/test-support files under `tests/scripts/dev_tools/`); 5 PowerShell files (1 production hook `.codex/hooks/enforce-epic-planning-only.ps1` plus its byte-identical bundled copy, and 4 Pester test files); 2 new JSON contract files (`config/orchestration-handoff.schema.json`, `config/orchestration-handoff-registry.json`) plus their bundled copies and 10 test fixtures; and 8 Markdown skill/manifest surfaces. No C# files changed.

**Coverage Metrics by Language:**

| Language | Files Changed | Tests | Test Result | Baseline Coverage | Post-Change Coverage | New Code Coverage |
|----------|--------------|-------|-------------|-------------------|---------------------|-------------------|
| TypeScript | 37 files | 2974 tests | PASS 2974 pass, 0 fail | 96.72% lines, 90.17% branches | 96.88% lines, 90.43% branches | 99.19% lines, 93.68% branches |
| Python | 19 files | 4390 tests | PASS 4390 pass, 0 fail | 92.7087% lines, 85.2994% branches | 92.89% lines, 85.51% branches | 97.71% lines, 92.11% branches |
| PowerShell | 5 files | 3940 tests | PASS 3940 pass, 0 fail | 94.7697% lines, no branch metric | 94.77% lines, no branch metric | 91.82% lines on the one changed production hook |
| JSON | 14 files | N/A | PASS schema and registry parse and validate | N/A (config files) | N/A (config files) | N/A |

**Note:** C# has zero changed files on this branch, so no C# row is recorded. The PowerShell branch column is intentionally absent: Pester measures command (instruction) and line coverage only, so no branch percentage exists to evaluate and no branch threshold applies to PowerShell under `.claude/rules/powershell.md` and `.claude/rules/quality-tiers.md`.

### Coverage Evidence Checklist

- TypeScript baseline coverage artifact: `docs/features/active/2026-08-31-portable-prepared-orchestration-handoff-614/evidence/baseline/typescript-jest-coverage.2026-08-31T07-58.md` and `evidence/remediation-baseline/typescript-jest-coverage.2026-09-07T03-16.md`
- TypeScript post-change coverage artifact: `extensions/drm-copilot/coverage/lcov.info` (generated 2026-09-07 07:23, parsed directly by this audit)
- PowerShell baseline coverage artifact: `docs/features/active/2026-08-31-portable-prepared-orchestration-handoff-614/evidence/remediation-baseline/powershell-pester-coverage.2026-09-07T03-16.md`
- PowerShell post-change coverage artifact: `artifacts/pester/powershell-coverage.xml` (generated 2026-09-07 07:30, parsed directly by this audit)
- Per-language comparison summary: section 1.2.1 of this document

**Non-negotiable verdict rule:** No policy audit may report PASS unless it includes numeric baseline and post-change coverage metrics for every language in scope, plus changed/new-code coverage when required. Those numerics are present above and in section 1.2.1.

**Fail-closed rule:** If any required baseline artifact, QA artifact, or coverage-comparison artifact is absent, the verdict must be BLOCKED or INCOMPLETE, never PASS. Every required artifact was located and parsed; no fail-closed condition applies.

**Evidence rule:** No evidence in this audit was synthesized or inferred. Every percentage was recomputed by this reviewer from the raw coverage artifacts named above, and every toolchain result was reproduced by this reviewer at the current branch head.

---

## Rejected Scope Narrowing

No caller instruction attempted to narrow the audit scope. The delegation prompt supplied the resolved base branch, the merge-base SHA, the branch head, the refreshed PR-context artifact paths, the work mode, and the coverage-artifact locations, and directed a full end-to-end execution of the `feature-review-workflow` skill contract. Each of those inputs is a legitimate scope source under the scope invariant.

Two prompt statements were evaluated against the invariant and found not to be narrowing attempts:

1. "verify from artifacts and evidence records per the skill rather than regenerating where they exist" — this restates the skill's own coverage-verification model (inspect pre-existing coverage artifacts rather than rerun generation). It does not exclude any language or file from the audit. All three languages with changed files received explicit coverage verdicts.
2. "CI run 34117865928 at this head is in progress and is observed separately by the orchestrator's S9 CI gate; do not wait for it" — this defers a duplicate observation of an external gate, not any part of the branch diff. The `modified-workflow-needs-green-run` rule does not fire on this branch (see section 8), so no green-run evidence is required by policy here.

The audit proceeded against the full feature-versus-base diff. Coverage verdicts for TypeScript, Python, and PowerShell are explicit PASS. C# is the only language recorded as not applicable, and it has zero changed files on the branch.

---

## Evidence Location Compliance

The branch diff was scanned for files written under `artifacts/baselines/`, `artifacts/qa/`, `artifacts/evidence/`, or `artifacts/coverage/`.

- Command: `git diff --name-only 0542c92a..HEAD | grep -E "^artifacts/(baselines|qa|evidence|coverage)/"`
- Result: zero matches. No branch file writes evidence to a non-canonical location.
- Supporting validator: `poetry run python scripts/dev_tools/validate_evidence_locations.py --root .` exited 0 with no reported paths.

All 106 evidence artifacts produced across the six execution and review cycles reside under `docs/features/active/2026-08-31-portable-prepared-orchestration-handoff-614/evidence/<kind>/`, using the canonical `baseline`, `remediation-baseline`, `qa-gates`, `regression-testing`, `issue-updates`, and `other` subdirectories. No `EVIDENCE_LOCATION_OVERRIDE_REJECTED` condition arose during this review; this reviewer wrote no evidence artifacts of its own.

**Disposition: PASS.**

---

## Executive Summary

This is the sixth review cycle for issue #614 and the first conducted after the branch was rebased onto `origin/main @ 0542c92a` and pull request #638 was opened. The branch delivers a provider-neutral portable handoff contract that lets a prepared orchestration checkpoint move between Claude and Codex runtimes: a Draft 2020-12 JSON schema and a semantic MCP registry, a Python contract and adapter implementation, a TypeScript runtime authority and materializer exposed through MCP, a preparation-gate hook that admits exactly one mutating operation, and root-to-bundle-to-pack-to-consumer publishing parity.

The full seven-stage toolchain was reproduced by this reviewer at head `645c40b0` and passed in a single pass for every language with changed files. Formatting, linting, type checking, architecture boundary, unit tests, contract and schema checks, and integration-level parity tests are all clean. Coverage was verified by parsing the three canonical coverage artifacts directly rather than by rerunning generation, and every uniform threshold is met with margin: TypeScript 96.88% line and 90.43% branch, Python 92.89% line and 85.51% branch, PowerShell 94.77% line. New-code coverage is 99.19% line for the 14 new TypeScript modules and 97.71% line for the 3 new Python modules, both far above the 85% floor.

The prior cycle's two synthetic CI findings were remediated correctly and test-only. CI-614-001 replaced a read of the gitignored live orchestrator-state checkpoint with a committed fixture and added a fail-fast presence guard; CI-614-002 replaced a Windows-only `C:/workspace` drive-letter literal with a root derived at run time from `path.resolve`, which is absolute on both Windows and POSIX. This reviewer independently confirmed the two residual drive-letter literal files reach none of the four production absolute-path predicates, by reading `resolvePortableHandoffAuthority`, its injected path-boundary seam, and the string-equality workspace comparison in the materializer.

Three findings remain open, all previously identified and deferred by orchestrator decision, none blocking. The most concrete is that the four fail-closed `throw` paths added to the PowerShell registry loader are untested, which puts the changed-line subset of that one file at 83.33%. The other two are the absent per-file coverage-threshold registration for the 14 new TypeScript modules, and 15 bare `catch { }` blocks that discard the underlying cause when mapping to a structured failure code.

**Policy documents evaluated:**
- PASS `general-code-change.instructions.md` (mirrored at `.claude/rules/general-code-change.md`)
- PASS `general-unit-test.instructions.md` (mirrored at `.claude/rules/general-unit-test.md`)

**Language-specific policies evaluated:**
- PASS `python-code-change.instructions.md` + `python-unit-test.instructions.md`
- PASS `powershell-code-change.instructions.md` + `powershell-unit-test.instructions.md`
- PASS `typescript-code-change.instructions.md` + `typescript-unit-test.instructions.md`
- N/A Bash: no bash files changed on this branch
- PASS JSON: `format_json` and `validate_json` conventions, `$schema` present on both new governed files

**Temporary artifacts cleanup:**
- PASS No temporary or one-time scripts were introduced by the branch. The `git status --porcelain` output at head is empty.
- PASS This reviewer created three throwaway parsing scripts in the session scratchpad outside the repository tree; none was written into the working tree, and the working tree remained byte-clean across the entire review, including across the PowerShell format gate.
- Scripts created during review and their disposition: three scratchpad-only Python parsers for lcov and JaCoCo coverage, and one scratchpad-only PowerShell driver for the check-only format gate. All four live outside the repository and none was committed.

---

## 1. General Unit Test Policy Compliance

### 1.1 Core Principles

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Independence** - Tests run in any order | PASS | Every new suite builds its own scenario inside a factory (`createScenario` in `orchestration-handoff-materializer-test-support.ts`, module-level fixture constants in the Python suites) and shares no mutable module state. The Jest run executes 214 suites in parallel workers and the Pester run executes 88 files in one session; both are green, which would not hold under cross-file ordering coupling. Reproduced with the handoff-subset `node run-jest.cjs --testPathPatterns=...` invocation given in Appendix B, which gave 17 suites and 306 tests passed. |
| **Isolation** - Each test targets single behavior | PASS | Suites are split by production module: one test file per new module plus a dedicated negative-coverage file (`orchestration-handoff-contract-negative-coverage.test.ts`) and a dedicated path-boundary file. The Python suites are split by concern into schema, versions, paths, provenance, adapters, contract, and end-to-end TaskMaster files, so a failure names one contract dimension. |
| **Fast Execution** - Tests complete quickly | PASS | Jest: 2974 tests in the full extension run; the 17 handoff-related suites and 306 tests complete in 1.626 s. Pytest: 4302 tests under `tests/scripts/dev_tools` in 7.49 s; the full 4390-test run in 29.41 s. Pester: 3940 tests in 180.597 s, of which the 5 codex-hooks files account for 97.05 s, dominated by real `pwsh` process launches in the hook-contract suites. |
| **Determinism** - Consistent results | PASS | A directed scan of every changed TypeScript test file for `setTimeout`, `setInterval`, `Date.now`, and `Math.random` returned zero matches. Time is supplied through an injected clock seam (`clock: { nowIso8601: jest.fn(() => "2026-08-31T08:00:00Z") }`). The CI-614-002 fix replaced a platform-dependent literal with `path.resolve("virtual-workspace")`, which is derived once per run and compared only against values derived the same way. |
| **Readability & Maintainability** - Clear structure | PASS | Test names state the behavior and the expected outcome ("selects one primary code from multiply-invalid failures", "fails closed for an attested preparation child before its checkpoint exists"). Python tests carry one-line docstrings. Shared setup is factored into three named support modules rather than duplicated. |

### 1.2 Coverage and Scenarios

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Baseline Coverage Documented** | PASS | **Baseline (pre-development, at merge base):** TypeScript 96.72% lines / 90.17% branches; Python 92.7087% lines / 85.2994% branches; PowerShell target hook 93.3333% lines.<br>**Command:** recorded in `evidence/baseline/baseline-summary.2026-08-31T07-58.md`; the comparable full-suite PowerShell baseline is `evidence/remediation-baseline/powershell-pester-coverage.2026-09-07T03-16.md` at 94.7697%.<br>**Timestamp:** 2026-08-31 07:58 and 2026-09-07 03:16.<br>**Note:** the 2026-08-31 PowerShell figure of 18.8011% was produced by a run scoped to `tests/scripts/codex-hooks` only and is not a comparable repository-wide denominator; the full-suite 94.7697% figure is used instead. |
| **No Coverage Regression** | PASS | **Post-change coverage:** TypeScript 96.88% lines / 90.43% branches; Python 92.89% lines / 85.51% branches; PowerShell 94.77% lines.<br>**Change:** TypeScript +0.16% lines, +0.26% branches; Python +0.18% lines, +0.21% branches; PowerShell +0.00% lines.<br>**Status:** No repository-wide regression in any language. On the single changed PowerShell production hook the file-level figure moved from 93.33% (126/135) to 91.82% (146/159): covered lines rose by 20 while executable lines rose by 24, so no previously covered line lost coverage and the level remains above the 85% floor. The 4 newly uncovered lines are carried as a Major finding, not a coverage failure. |
| **New Code Coverage >=90%** | PASS | **New/modified files:** 14 new TypeScript production modules, 3 new Python production modules, 7 modified TypeScript modules, 2 modified Python modules, 1 modified PowerShell hook.<br>**New code coverage:** TypeScript new 99.19% (3426/3454 lines, 519/554 branches); Python new 97.71% (512/524 lines, 140/152 branches). Both exceed 90%.<br>**Calculation method:** the reviewer parsed `SF:`/`LH:`/`LF:`/`BRH:`/`BRF:` records from each lcov artifact, resolved each added path from `git diff --name-status` by path-suffix match, and summed the per-record counters.<br>**Modified-file aggregates:** TypeScript 90.30% (2094/2319 lines), which rises to 98.73% (2094/2121) once the interface-only `repo-automation-service-contract.ts` is set aside; Python 98.34% (296/301 lines). |
| **Comprehensive Coverage** | PASS | Every new production module is individually above the floors. Per-module line coverage: `orchestration-handoff-checkout-context.ts` 100.00%, `orchestration-handoff-contract-support.ts` 100.00%, `orchestration-handoff-materializer-production.ts` 100.00%, `orchestration-handoff-materializer-request.ts` 100.00%, `orchestration-handoff-materializer-support.ts` 100.00%, `semantic-mcp-identity.ts` 100.00%, `orchestration-handoff-handlers.ts` 100.00%, `mcp-repo-automation-tool-definitions-handoff.ts` 100.00%, `orchestration-handoff-validation.ts` 99.19%, `orchestration-handoff-provider-adapters.ts` 99.27%, `orchestration-handoff-contract.ts` 98.79%, `orchestration-handoff-materializer.ts` 98.42%, `orchestration-handoff-authority-service.ts` 98.41%, `orchestration-handoff-path-boundary.ts` 97.56%; Python `orchestration_handoff_adapters.py` 100.00%, `orchestration_handoff_contract.py` 98.70%, `orchestration_handoff_contract_support.py` 91.01%.<br>**Untested code:** four `throw` statements at lines 58, 67, 72, and 77 of `.codex/hooks/enforce-epic-planning-only.ps1`, and the exported-but-unreferenced Python helper `raw_file_sha256`. Both are carried as findings. |
| **Positive Flows** - Valid inputs | PASS | **Positive scenarios tested:** two full valid envelope fixtures drive both directions (`valid-ordinary-claude-to-codex.json`, `valid-parallel-codex-to-claude.json`); the end-to-end TaskMaster #469 fixtures prove Claude-prepared to Codex-execution-ready and the symmetric reverse; `test_supported_newer_minor_version_is_accepted` covers forward-compatible minor versions; the materializer success path asserts `status === "materialized"` with archive, candidate, and atomic-replace calls each observed exactly once. |
| **Negative Flows** - Invalid inputs | PASS | **Negative scenarios tested:** `invalid-contract-cases.json` drives a table-driven negative suite in both Python and TypeScript; named cases include `test_unknown_major_version_has_deterministic_code`, `test_unknown_vocabulary_has_deterministic_code`, `test_unknown_capability_has_deterministic_code`, `test_invalid_transition_has_deterministic_code`, and `test_completed_phase_replay_has_deterministic_code`. `semantic-mcp-alias-cases.json` drives rejection of malformed identifiers, unrelated servers, and unregistered operations. |
| **Edge Cases** - Boundary conditions | PASS | **Edge cases tested:** path-boundary rejection of absolute paths, `..` traversal, symlink escape, and directory rediscovery in `orchestration-handoff-path-boundary.test.ts` and `orchestration-handoff-materializer-path-boundary.test.ts`; both underscore and hyphen MCP transport spellings; the legacy four-field TaskMaster checkpoint, which is the minimum-information migration boundary; and stale plan content detected by raw-byte hash rather than by path alone. |
| **Error Handling** - Error paths | PASS | **Error scenarios tested:** the 16-code `HANDOFF_*` precedence is exercised end to end, with `selectPrimaryHandoffFailure` proven to pick the highest-precedence code from a reversed full list and to return null on an empty list. Dirty-worktree handling is proven to surface `HANDOFF_DIRTY_WORKTREE` last, after all contract and authority checks pass, with dirty paths reported and unmodified. The one gap is the hook-side registry loader's four `throw` paths, recorded as a Major finding. |
| **Concurrency** - If applicable | N/A | The handoff contract, adapters, materializer, and hook are single-threaded request-scoped transforms with no shared mutable state and no async scheduling. Concurrency testing is not applicable. |
| **State Transitions** - If applicable | PASS | The lifecycle is a 12-state machine (`intake` through `completion`) with an explicit `replay_policy` of `forbid_completed_phases`. `no_replay = value.next_transition not in value.completed_phases` at `orchestration_handoff_contract.py:251` enforces it, and `test_completed_phase_replay_has_deterministic_code` plus the TypeScript replay case cover the rejection. Both TaskMaster fixtures assert that a destination resumes at the exact recorded transition. |

### 1.2.1 Per-Language Coverage Comparison

- TypeScript: Baseline: 96.72% lines -> Post-change: 96.88% lines. Change: +0.16% lines and +0.26% branches, from 90.17% to 90.43%. New/changed-code coverage: 99.19% lines across the 14 added production modules. Disposition: PASS. Evidence: `extensions/drm-copilot/coverage/lcov.info` compared against `evidence/baseline/baseline-summary.2026-08-31T07-58.md`.
- Python: Baseline: 92.7087% lines -> Post-change: 92.89% lines. Change: +0.18% lines and +0.21% branches, from 85.2994% to 85.51%. New/changed-code coverage: 97.71% lines across the 3 added production modules. Disposition: PASS. Evidence: `artifacts/python/lcov.info` compared against `evidence/baseline/baseline-summary.2026-08-31T07-58.md`.
- PowerShell: Baseline: 94.7697% lines -> Post-change: 94.77% lines. Change: +0.00% lines repository-wide, with no branch figure because Pester does not measure branch coverage. New/changed-code coverage: 91.82% lines on `.codex/hooks/enforce-epic-planning-only.ps1`, the one changed production script. Disposition: PASS. Evidence: `artifacts/pester/powershell-coverage.xml` compared against `evidence/remediation-baseline/powershell-pester-coverage.2026-09-07T03-16.md`.

### 1.3 Test Structure and Diagnostics

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Clear Failure Messages** | PASS | Assertions compare structured values rather than booleans, so Jest and pytest print a full object diff on failure. Example: `expect(HANDOFF_FAILURE_PRECEDENCE).toEqual(registry["failure_precedence"])` names the exact divergent element. The Pester fixture guard throws `"Preparation checkpoint fixture is missing: <path>"` with the resolved path rather than failing later with a null-content error. |
| **Arrange-Act-Assert Pattern** | PASS | The TypeScript suites use explicit `// Arrange`, `// Act`, `// Assert` comment markers around a `createScenario` call, a single `transition(...)` invocation, and a grouped assertion block. Python tests follow the same three-part shape without markers. |
| **Document Intent** | PASS | Python test functions carry a one-line docstring stating the invariant ("The Python precedence tuple stays bound to the registry ordering."). TypeScript `it(...)` strings describe the behavior rather than the method under test. Pester uses `Describe`/`Context`/`It` nesting that reads as a sentence. |

### 1.4 External Dependencies and Environment

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Avoid External Dependencies** | PASS | No changed test touches a database, network, or remote API. Filesystem access in the new TypeScript suites goes through an injected `FileSystem` seam backed by an in-memory `Map<string, Uint8Array>`. The Pester hook-contract suites launch a real `pwsh` child process, which is a deliberate process-contract test of a hook that only exists as a subprocess entry point, and the process reads a committed fixture rather than live repository state. |
| **Use Mocks/Stubs** | PASS | Mocked components and rationale: `fileSystem` (avoids disk I/O and makes byte content explicit), `pathBoundary` (isolates path-resolution policy from the materializer state machine), `gitStatus` (removes dependence on the reviewer's working-tree state), `clock` (removes wall-clock dependence), and `validator`/`validateDestinationProjection` in the path-boundary suite (narrows that suite to boundary wiring). Production paths are exercised unmocked in the contract, adapter, and provider suites. |
| **Environment Stability** | PASS | A directed scan of every changed test file for `tmpdir`, `mkdtemp`, `TemporaryDirectory`, `NamedTemporaryFile`, `New-TemporaryFile`, and `[IO.Path]::GetTempPath` returned zero matches, so the prohibition on temporary files in tests is satisfied. The CI-614-001 fix removed the last dependence on mutable repository state by replacing a read of the gitignored `artifacts/orchestration/orchestrator-state.json` with the committed fixture `tests/fixtures/codex-hooks/epic-planning-preparation-checkpoint.json`. Fixture bytes are pinned cross-platform: `.gitattributes` marks the two large plan fixtures `-text -eol`, and `git cat-file blob HEAD:<path>` matches the worktree SHA-256 for both source checkpoints, so a Linux runner sees identical bytes. |

### 1.5 Policy Audit Requirement

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Pre-submission Review** | PASS | This document is the required pre-merge policy review for pull request #638. It is the sixth cycle; the five prior policy audits at 2026-08-31T17-20, 2026-09-02T22-17, 2026-09-03T00-07, 2026-09-06T23-30, and 2026-09-07T02-00 remain in the feature folder as the audit trail. Outstanding review items are the three non-blocking findings enumerated in section 8. |

---

## 2. General Code Change Policy Compliance

### 2.1 Before Making Changes

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Clarify the objective** | PASS | The objective is stated in `issue.md`, `spec.md`, and `user-story.md` for issue #614, and traced from the promoted lifecycle record `docs/features/potential/promoted/2026-08-31-portable-prepared-orchestration-handoff.md`. Work mode is persisted as `- Work Mode: full-feature`. |
| **Read existing change plans** | PASS | Planning documents reviewed: `plan.2026-08-31T07-58.md` and five remediation plans at 2026-08-31T17-20, 2026-09-02T22-17, 2026-09-03T00-07, 2026-09-06T23-30, and 2026-09-07T03-16. The 03-16 plan records 41 of 41 tasks checked. |
| **Document the plan** | PASS | Each of the 11 commits carries a conventional-commit subject, a bulleted body describing the change, and a `Refs: #614` trailer. Phase progress is recorded in `evidence/other/progress-commit-00{1,2,3}.2026-08-31T07-58.md`. |

### 2.2 Design Principles

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Simplicity first** | PASS | The contract is expressed as data (a JSON schema plus a registry) with thin validators over it, rather than as a class hierarchy. The failure model is a flat ordered list of 16 string codes with a single selection function, which is simpler than nested exception types and makes cross-language parity checkable by equality. |
| **Reusability** | PASS | Shared logic is factored rather than duplicated: `orchestration-handoff-contract-support.ts` and `orchestration_handoff_contract_support.py` hold the path-normalization, hashing, and legacy-read helpers used by their respective contract modules; `orchestration-handoff-materializer-support.ts` and `-request.ts` split reusable pieces out of the materializer; `semantic-mcp-identity.ts` is consumed by both the validator allowlist and the tool definitions. Three test-support modules remove setup duplication across nine suites. |
| **Extensibility** | PASS | The materializer takes a `HandoffMaterializerDependencies` record with `fileSystem`, `pathBoundary`, `validator`, `gitStatus`, and `clock` seams, so alternative implementations substitute without touching the state machine. `resolvePortableHandoffAuthority` accepts an optional `pathBoundary` and falls back to `createDefaultPathBoundary(fileSystem)`. The registry is versioned (`"version": "1.0.0"`) and the schema is semantically versioned in its `$id`, so both can evolve without breaking pinned consumers. |
| **Separation of concerns** | PASS | Pure contract validation (`orchestration-handoff-contract.ts`) is separate from authority resolution (`-authority-service.ts`), which is separate from materialization I/O (`-materializer.ts`), which is separate from the MCP transport layer (`mcp-handlers/orchestration-handoff-handlers.ts`) and from the tool definitions. Filesystem and git access are confined to injected seams; the production wiring is isolated in `-materializer-production.ts`. |

### 2.3 Module & File Structure

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Cohesive modules** | PASS | Each of the 14 new TypeScript modules has a single stated responsibility reflected in its name, and each is paired one-to-one with a test file under `extensions/drm-copilot/test/lib/validate/` mirroring the source path. The three new Python modules split contract, adapters, and shared support. |
| **Under 500 lines** | PASS | Every changed code file is at or under the 500-line limit. The largest are `tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py` at exactly 500, `scripts/dev_tools/orchestration_handoff_contract.py` at 498, `extensions/drm-copilot/src/repo-automation-service.ts` at 498, `orchestration-handoff-contract.ts` at 497, `test_orchestration_handoff_adapters.py` at 496, `orchestration-handoff-authority-service.test.ts` at 495, `legacy-codex-hook-contracts.Tests.ps1` at 494, and `validate_orchestrator_state.py` at 492. The three exempt Markdown plan fixtures at 1413 lines each are raw text fixtures for contract test data, which the policy exempts explicitly. |
| **Public vs internal** | PASS | Python modules use `__all__`-equivalent explicit re-export syntax (`from ... import x as x`) to mark the intended public surface, and prefix internals with a single underscore (`_build_portable_envelope`, `_require`). TypeScript modules export only the named types and functions their consumers import; helper predicates such as `isRecord` stay module-local. |
| **No circular dependencies** | PASS | The dependency direction is one-way: tool definitions depend on handlers, handlers depend on the authority service and materializer, both depend on the contract and support modules, and the support modules depend on nothing in the feature. `npm run typecheck` (`tsc -p ./ --noEmit`) exited 0, which fails on circular type-only imports under `module: Node16`. |

### 2.4 Naming, Docs, and Comments

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Descriptive names** | PASS | Names state the domain concept without abbreviation: `resolvePortableHandoffAuthority`, `createProductionHandoffMaterializer`, `Get-EpicPlanningRegisteredMcpTool`, `validate_bounded_scheduler_return`, `normalize_repository_relative_path`. Language conventions are respected: `snake_case` for Python functions, `camelCase` for TypeScript functions and locals, `PascalCase` for TypeScript types, approved `Verb-Noun` for PowerShell. |
| **Docs/docstrings** | PASS | Every Python module opens with a structured docstring carrying Purpose, Usage, Flow, Invariants, and Side Effects sections, and every public function carries Purpose/Args/Returns/Raises/Side Effects. TypeScript public exports carry TSDoc blocks; `VIRTUAL_WORKSPACE_ROOT` and `workspacePath` in the test-support module are documented with the platform rationale for their existence. |
| **Comment why, not what** | PASS | Comments explain rationale rather than restating code. Examples: the `jest.config.cjs` block explaining why there is no `global` threshold key; the Pester `BeforeAll` comment explaining that the live checkpoint is gitignored and therefore absent on a fresh CI checkout; and the test-support comment explaining that a drive-letter literal is absolute on Windows and relative on POSIX. |

### 2.5 After Making Changes - Toolchain Execution

| Requirement | Status | Evidence |
|------------|--------|----------|
| **1. Formatting** | PASS | **Command:** `npx prettier --check "src/**/*.ts" "test/**/*.ts" "*.json" "*.cjs"`; `poetry run black --check scripts tests`; check-only `Invoke-PoshQCFormat` with a recorder substituted for the `-WriteFile` seam.<br>**Result:** Prettier reported "All matched files use Prettier code style!" and exited 0. Black reported 473 files unchanged and exited 0. The PowerShell recorder reported `FORMAT_DRIFT_COUNT=0`, and `git status --porcelain` was empty afterwards, confirming the gate ran without mutating the tree. |
| **2. Linting** | PASS | **Command:** `npm run lint` (`eslint --no-error-on-unmatched-pattern src test`); `poetry run ruff check scripts tests`; `Invoke-PoshQCAnalyze -Root <repo>`.<br>**Result:** ESLint exited 0 with no output. Ruff reported "All checks passed!" and exited 0. PSScriptAnalyzer reported `ANALYZE_TOTAL=0`, `ANALYZE_ERRORS=0`, `ANALYZE_WARNINGS=0`. |
| **3. Type checking** | PASS | **Command:** `npm run typecheck` (`tsc -p ./ --noEmit`); `poetry run pyright`.<br>**Result:** TSC exited 0. Pyright reported "0 errors, 0 warnings, 0 informations" and exited 0. Type checking is not applicable to PowerShell. A separate diagnostic compile of the test tree is discussed in section 8. |
| **4. Testing** | PASS | **Command:** the handoff-subset `node run-jest.cjs --testPathPatterns=...` invocation given in Appendix B; `poetry run pytest tests/scripts/dev_tools -q`; `Invoke-Pester` over `tests/scripts/codex-hooks`.<br>**Result:** Jest 17 suites and 306 tests passed, 0 failed. Pytest 4302 passed, 5 skipped, 0 failed. Pester 637 passed, 0 failed, 0 skipped. The executor's full-suite runs recorded in evidence give Jest 214 suites and 2974 tests, pytest 4390 tests, and Pester 3940 tests, all with zero failures. |
| **Full toolchain loop** | PASS | All seven stages completed in a single pass with no auto-fix and no restart. Stages 5 through 7 map to the unit runs above, the contract and schema checks in section 3D, and the publishing-parity and hook-process integration tests. |
| **Explicit reporting** | PASS | Every command above is recorded verbatim in this audit with its exit condition, and each corresponds to a dated evidence record under `evidence/qa-gates/` or `evidence/remediation-baseline/`. |

### 2.6 Summarize and Document

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Summarize changes** | PASS | Summarized in the Executive Summary above and in section 9. Each commit message carries its own scoped summary. |
| **Design choices explained** | PASS | `spec.md` sections Implementation Strategy and Constraints & Risks record the design decisions and the alternatives weighed, including why the registry is a test-enforced parity anchor rather than a runtime load. |
| **Update supporting documents** | PASS | Eight Markdown surfaces were updated in lockstep with the code: `.agents/skills/orchestrate`, `orchestrator-state`, and `repo-automation-adapter`; `.claude/skills/orchestrate` and `powershell-orchestration-state-machine`; and the four corresponding bundled copies under `extensions/drm-copilot/resources/`. The pack manifest `core.json` was extended with the two new config paths. |
| **Provide next steps** | PASS | Section 10 records the recommendation. The three open findings and their disposition are enumerated in section 8 and carried into `remediation-inputs.2026-09-07T08-00.md`. |

---

## 3. Language-Specific Code Change Policy Compliance

### Section 3A: Python Code Change Policy Compliance

#### 3A.1 Tooling & Baseline

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Formatting with Black** | PASS | **Command:** `poetry run black --check scripts tests`<br>**Result:** "473 files would be left unchanged", exit 0. Check-only; no file was rewritten. |
| **Linting with Ruff** | PASS | **Command:** `poetry run ruff check scripts tests`<br>**Result:** "All checks passed!", exit 0. |
| **Type checking with Pyright** | PASS | **Command:** `poetry run pyright`<br>**Result:** "0 errors, 0 warnings, 0 informations", exit 0. |
| **Testing with Pytest** | PASS | **Command:** `poetry run pytest tests/scripts/dev_tools -q`<br>**Result:** 4302 passed, 5 skipped, 0 failed in 7.49 s. The 5 skips are pre-existing parity cases in `test_parallel_manifest_bash_parity.py` that declare no accessor expectation, unrelated to this branch. |

#### 3A.2 Python Design & Typing

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Strong typing** | PASS | Pyright runs clean across the changed modules. Module-level constants are annotated `Final` (`FAILURE_PRECEDENCE: Final = tuple(...)`). `Any` appears only inside explicit `cast(...)` calls in test modules where a JSON fixture is narrowed to a known shape, which is the sanctioned narrowing idiom rather than an untyped escape hatch in production code. |
| **Dataclasses for value objects** | PASS | The envelope and its sub-records are modelled as dataclasses with typed fields and defaults, for example `replay_policy: str = "forbid_completed_phases"` at `orchestration_handoff_contract.py:154`. |
| **Protocols/ABCs for interfaces** | PASS | The provider-adapter boundary is expressed through structural typing rather than inheritance, consistent with the "composition over inheritance" preference. The one place a callable contract is needed uses an explicit `Callable[...]` annotation. |
| **Avoid utility classes** | PASS | No static-method-only class exists in the changed Python. Shared behavior lives in module-level functions in `orchestration_handoff_contract_support.py`. |

#### 3A.3 Python Error Handling

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Specific exceptions** | PASS | Validation failures are returned as structured `HANDOFF_*` codes rather than raised, and the places that do raise use specific messages. No bare `except:` and no broad `except Exception:` without re-raise appears in the changed Python modules. |
| **Logging over print** | PASS | The changed modules perform no console output; they return values to their callers. Reporting is the caller's concern. |
| **Invariants at construction** | PASS | `_require(...)` enforces envelope invariants during construction in `_build_portable_envelope`, so an invalid envelope cannot be represented. Path normalization is enforced at the boundary by `normalize_repository_relative_path(value, *, field=...)`, which takes the field name so the failure names the offending field. |

---

### Section 3B: PowerShell Code Change Policy Compliance

#### 3B.1 Tooling & Baseline

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Formatting with Invoke-Formatter** | PASS | **Command:** `Invoke-PoshQCFormat -Root <repo>` driven check-only by substituting a recorder scriptblock for the `-WriteFile` seam<br>**Result:** `FORMAT_DRIFT_COUNT=0`; `git status --porcelain` empty afterwards. The function has no native check flag, so the dependency seam is the only way to run stage 1 without rewriting files. |
| **Linting with PSScriptAnalyzer** | PASS | **Command:** `Invoke-PoshQCAnalyze -Root <repo>`<br>**Result:** "PSScriptAnalyzer passed: no findings"; `ANALYZE_TOTAL=0`. |
| **Fix all findings** | PASS | There are no findings to fix. |
| **PowerShell 5.1 & 7.6+ compatible** | PASS | The changed hook uses only constructs available in both: `Test-Path -LiteralPath -PathType`, `ConvertFrom-Json`, `[System.Collections.Generic.List[string]]::new()`, `[regex]::Escape`, `Sort-Object -Unique`, and `PSObject.Properties[...]`. No `ForEach-Object -Parallel`, ternary operator, or null-coalescing operator appears. The Pester suites launch `pwsh` explicitly rather than assuming an ambient host. |

#### 3B.2 PowerShell Design & Safety

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Advanced functions** | PASS | `Get-EpicPlanningRegisteredMcpTool` declares `[CmdletBinding()]` and `[OutputType([string[]])]`. `ConvertFrom-EpicPlanningJson` declares `[CmdletBinding()]`. |
| **Parameter validation** | PASS | Both new and changed functions mark parameters `[Parameter(Mandatory)]` with explicit types (`[string] $RegistryPath`, `[string[]] $SemanticIds`), and `ConvertFrom-EpicPlanningJson` uses `[AllowNull()][AllowEmptyString()]` where an empty value is a meaningful input rather than a binding error. |
| **Avoid global state** | PASS | Module state uses the `$script:` scope (`$script:PreparationSemanticMcpIds`, `$script:AllowedPreparationSemanticMcpTools`, `$script:EpicPlanningRepositoryRoot`), not `$global:`. The registry is read once at load into a script-scoped allowlist. |
| **Error handling** | PARTIAL | The hook fails closed by throwing prefixed, specific messages (`EPIC_PLANNING_ONLY_BLOCKED: semantic MCP id '<id>' is not registered.`), which is the correct pattern, and `ConvertFrom-EpicPlanningJson` uses `-ErrorAction Stop` inside `try`/`catch` and rethrows with added context. The gap is coverage, not design: none of the four `throw` paths at lines 58, 67, 72, and 77 is exercised by a test, so the fail-closed contract for the registry loader is asserted by construction only. Recorded as finding F1. |

#### 3B.3 Structure, Naming, and Comments

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Cohesive and under 500 lines** | PASS | `.codex/hooks/enforce-epic-planning-only.ps1` is 321 lines. The four changed Pester files are 494, 101, and two smaller files, all under the limit. |
| **Approved verbs** | PASS | Function names use approved verbs: `Get-EpicPlanningRegisteredMcpTool` (Get), `ConvertFrom-EpicPlanningJson` (ConvertFrom), `Invoke-EpicPlanningOnlyDecision` (Invoke), `Get-EpicPlanningDenyDecision` (Get). |
| **Comment why** | PASS | The new `BeforeAll` comment in `epic-execution-gates.Tests.ps1` explains why the fixture replaced the live checkpoint ("The live checkpoint under /artifacts is gitignored, so it is absent in a fresh checkout and reading it fails on the CI runner"), which is rationale rather than restatement. |

#### 3B.4 Running the Toolchain

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Step 1: Format** | PASS | Executed check-only via the `-WriteFile` recorder seam; zero drift; tree unchanged. |
| **Step 2: Analyze** | PASS | Executed via `Invoke-PoshQCAnalyze -Root <repo>`; zero findings at every severity. |
| **Step 3: Type check** | N/A | Not applicable for PowerShell. |
| **Step 4: Test** | PASS | `Invoke-Pester` over `tests/scripts/codex-hooks` gave 637 passed, 0 failed, 0 skipped. The executor's full-repository Pester run gave 3940 tests with `errors="0" failures="0"`. |
| **Rerun loop if needed** | PASS | One iteration; no stage failed and no stage modified a file. |

---

### Section 3C: TypeScript Code Change Policy Compliance

#### 3C.1 Tooling & Baseline

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Formatting with Prettier** | PASS | **Command:** `npx prettier --check "src/**/*.ts" "test/**/*.ts" "*.json" "*.cjs"`<br>**Result:** "All matched files use Prettier code style!", exit 0. |
| **Linting with ESLint** | PASS | **Command:** `npm run lint`<br>**Result:** exit 0, no output. The configuration enables type-aware parsing over both `src` and `test`. |
| **Type checking with TSC** | PASS | **Command:** `npm run typecheck` (`tsc -p ./ --noEmit`)<br>**Result:** exit 0. `tsconfig.json` enables `strict`, `exactOptionalPropertyTypes`, `noUncheckedIndexedAccess`, `noPropertyAccessFromIndexSignature`, `noImplicitOverride`, `noUnusedLocals`, and `noUnusedParameters`. |
| **Testing with Jest** | PASS | **Command:** `node run-jest.cjs --testPathPatterns=...`<br>**Result:** 17 suites, 306 tests, all passed. |

#### 3C.2 TypeScript Design & Typing

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Avoid `any`** | PASS | A directed scan of all 21 changed production modules for `: any`, `<any>`, and `as any` returned zero matches. Unknown JSON input is typed `unknown` and narrowed through predicates such as `isRecord`. |
| **Type assertions justified** | PASS | Only 5 `as <Type>` assertions exist across the 14 new modules: 3 in `orchestration-handoff-contract-support.ts` and 1 each in `-materializer-production.ts`, `-materializer.ts`, and `orchestration-handoff-handlers.ts`. Each sits immediately after a validating predicate that established the shape. |
| **ES modules** | PASS | All new modules use `import`/`export`. No `require` or `module.exports` appears in the changed production sources. |
| **Error handling** | PARTIAL | Failures are converted into structured `blockedResult(...)` values carrying a `HANDOFF_*` code, which satisfies the fail-fast and no-silent-ignore requirements. However 15 `} catch {` blocks across 4 modules discard the caught value entirely, so the underlying cause is not propagated with added context as the policy requires. Recorded as finding F3. |

#### 3C.3 Structure and Documentation

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Cohesive and under 500 lines** | PASS | Largest new production module is `orchestration-handoff-contract.ts` at 497 lines. All 21 changed production modules are under the limit. |
| **TSDoc on public exports** | PASS | Public functions, interfaces, and the dependency records carry TSDoc blocks stating purpose and the seam contract. |
| **No banned timing APIs** | PASS | `Date.now`, `setTimeout`, `setInterval`, and `Math.random` appear in none of the changed production or test files. Time is injected through the `clock` seam. |

---

### Section 3D: JSON Configuration Policy Compliance

#### 3D.1 JSON Tooling

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Formatting with jq** | PASS | Both new governed files parse cleanly and follow the repository's two-space indentation. `python -c "json.load(...)"` succeeded on `config/orchestration-handoff.schema.json` and `config/orchestration-handoff-registry.json`. |
| **Schema validation** | PASS | The schema declares `"$schema": "https://json-schema.org/draft/2020-12/schema"` with a semantically versioned `$id` of `https://drm-copilot.dev/schemas/orchestration-handoff/2.0.0/schema.json`, `"additionalProperties": false`, and 13 required top-level properties. Both positive fixtures validate and the negative-case fixture drives table-driven rejection in Python and TypeScript. |
| **Required $schema** | PASS | Both `config/orchestration-handoff.schema.json` and `config/orchestration-handoff-registry.json` carry a `$schema` property. |

#### 3D.2 JSON Structure

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Strict JSON only** | PASS | Both files parse with the strict `json` module, which rejects comments and trailing commas. |
| **Deterministic key order** | PASS | The registry preserves a deliberate semantic ordering (`lifecycle_ids`, `semantic_tools`, `provider_adapters`, `transitions`, `capabilities`, `failure_precedence`) in which `failure_precedence` order is load-bearing and must not be sorted; the two parity tests assert exact sequence equality against the Python tuple and the TypeScript constant. |

---

## 4. Language-Specific Unit Test Policy Compliance

### Section 4A: Python Unit Test Policy Compliance

#### 4A.1 Framework and Scope

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Use Pytest** | PASS | All 14 changed Python test files are pytest modules using plain `def test_*` functions and module-level fixture constants. `pytest-cov` with `--cov-branch` supplies coverage. |
| **Coverage expectation** | PASS | Repository-wide Python coverage is 92.89% line and 85.51% branch, both above the 85% and 75% uniform floors. New-module coverage is 97.71% line and 92.11% branch, above the 90% new-code expectation. |

#### 4A.2 Test Style and Structure

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Focused unit tests** | PASS | Each test asserts one contract property, for example `test_failure_precedence_matches_the_shared_registry` asserting only `FAILURE_PRECEDENCE == REGISTRY_FAILURE_PRECEDENCE`. |
| **Mocking sparingly** | PASS | The Python suites use almost no mocking; they drive real functions over committed JSON fixtures. `cast(...)` is used to narrow fixture types, not to substitute behavior. |
| **Organization** | PASS | Tests live under `tests/scripts/dev_tools/`, mirroring `scripts/dev_tools/`, satisfying the mirrored-tree requirement. Shared setup is factored into `orchestration_handoff_taskmaster_469_test_support.py`, `push_down_handoff_test_support.py`, and `validate_orchestrator_state_test_support.py`. |

#### 4A.3 Naming and Readability

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Naming conventions** | PASS | Names state condition and expected outcome: `test_legacy_v1_accepts_only_explicit_migration_facts`, `test_unknown_major_version_has_deterministic_code`, `test_consumer_authority_is_typescript_only_and_scope_owners_are_unchanged`. |
| **Docstrings/comments** | PASS | Each test carries a one-line docstring stating the invariant under test. |

#### 4A.4 Running the Toolchain

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Use Pytest** | PASS | **Command:** `poetry run pytest tests/scripts/dev_tools -q`<br>**Result:** 4302 passed, 5 skipped, 0 failed. |
| **No Alternative Test Runners** | PASS | Only pytest is configured; no unittest runner or alternative harness appears in the changed files. |

---

### Section 4B: PowerShell Unit Test Policy Compliance

#### 4B.1 Framework and Scope

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Use Pester v5.x** | PASS | The changed suites use Pester v5 constructs throughout: `BeforeAll` with `$script:`-scoped setup, `Describe`/`Context`/`It` nesting, `-ForEach` data-driven cases with hashtable rows, and modern `Should -Be` syntax. |
| **Use PoshQC Configuration** | PASS | **Command:** the executor ran the PoshQC runner, producing `artifacts/pester/powershell-coverage.xml` and `artifacts/pester/pester-junit.xml`.<br>**Config:** `scripts/powershell/PoshQC/settings/pester.runsettings.psd1` supplies the `CodeCoverage.Path` denominator. Note that this settings file sets `CoveragePercentTarget = 0`, so a green run does not by itself demonstrate that the line threshold was met; the 94.77% figure in this audit was computed by the reviewer from the JaCoCo report counters, not inferred from the exit code. |
| **PowerShell 5.1 & 7.6+ Compatible** | PASS | Tests resolve `pwsh` explicitly via `Get-Command pwsh -CommandType Application` and launch it through `System.Diagnostics.Process`, so the hook contract is exercised against a known host rather than the ambient one. |

#### 4B.2 Test Style and Structure

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Focused Unit Tests** | PASS | Each `It` asserts one decision outcome of the hook, with the deny reason compared as an exact string. |
| **Test Behavior Over Implementation** | PASS | The suites drive the hook through its real process entry point with a JSON payload on the environment and assert the emitted decision JSON, which is the hook's observable contract, rather than reaching into internal variables. |
| **Mocking Used Sparingly** | PASS | No Pester `Mock` is used in the changed suites. The only substitution is the committed checkpoint fixture supplied through `EPIC_PLANNING_CHECKPOINT_PATH`, which replaces gitignored mutable state with deterministic committed bytes. |
| **Organization** | PASS | **CRITICAL:** Test file location mirrors code file location.<br>**Test file:** `tests/scripts/codex-hooks/epic-execution-gates.Tests.ps1`<br>**Code file:** `.codex/hooks/enforce-epic-planning-only.ps1`<br>The `tests/scripts/codex-hooks/` tree mirrors the `.codex/hooks/` tree, and no test file is colocated with production source. |

#### 4B.3 Naming and Readability

| Requirement | Status | Evidence |
|------------|--------|----------|
| **File Naming** - *.Tests.ps1 | PASS | All four changed files use the `<name>.Tests.ps1` suffix. |
| **Describe/Context/It Structure** | PASS | `epic-execution-gates.Tests.ps1` uses 1 top-level `Describe` ("Codex epic preparation, wave, merge, and worktree gates") with `Context` blocks per gate and `It` blocks per case, several of them `-ForEach` data-driven. |
| **Logical Grouping** | PASS | Cases are grouped by gate: preparation, wave launch, merge, and worktree removal, so a failure localizes to one gate. |
| **Docstrings/Comments** | PASS | `It` names are self-documenting ("denies a child before an upstream merge", "allows the matching final epic PR after a successful CI gate"); comments are reserved for rationale. |

#### 4B.4 Running the Toolchain

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Use PoshQCTest Command** | PASS | The executor's PoshQC run produced both coverage and JUnit artifacts; this reviewer reproduced the codex-hooks subset directly with `Invoke-Pester`, giving 637 passed and 0 failed. |
| **No Alternative Test Runners** | PASS | Pester is the only PowerShell test runner in use. |

---

## 5. Test Coverage Detail

### `orchestration-handoff-contract.ts` and `orchestration_handoff_contract.py` (contract validation)

| Test Name | Scenario Type | Status |
|-----------|--------------|--------|
| `test_failure_precedence_matches_the_shared_registry` | Positive (parity) | PASS |
| registry parity assertion in `orchestration-handoff-contract.test.ts` | Positive (parity) | PASS |
| `selects one primary code from multiply-invalid failures` | Edge Case | PASS |
| `test_unknown_major_version_has_deterministic_code` | Negative | PASS |
| `test_unknown_vocabulary_has_deterministic_code` | Negative | PASS |
| `test_unknown_capability_has_deterministic_code` | Negative | PASS |
| `test_invalid_transition_has_deterministic_code` | Negative | PASS |
| `test_completed_phase_replay_has_deterministic_code` | Error Handling | PASS |
| `test_supported_newer_minor_version_is_accepted` | Positive | PASS |
| `rejects completed-phase replay before dirty-worktree precedence` | Error Handling | PASS |

**Coverage:** `orchestration-handoff-contract.ts` 98.79% lines (491/497), 90.79% branches (69/76). `orchestration_handoff_contract.py` 98.70% lines (303/307), 94.57% branches (87/92).

**Not covered:** a small number of defensive narrowing branches reachable only from an already-rejected envelope shape.

---

### `orchestration-handoff-materializer.ts` (materialization state machine)

| Test Name | Scenario Type | Status |
|-----------|--------------|--------|
| materialize success path with archive, candidate, and atomic replace | Positive | PASS |
| dry-run performs no canonical or user-file mutation | Positive | PASS |
| `HANDOFF_WORKSPACE_MISMATCH` on binding/request divergence | Negative | PASS |
| `HANDOFF_SOURCE_HASH_MISMATCH` on tampered source bytes | Negative | PASS |
| `HANDOFF_DIRTY_WORKTREE` reported after all earlier checks pass | Error Handling | PASS |
| replace-recovery restores the source checkpoint on failure | Error Handling | PASS |
| path-boundary rejection of absolute paths, `..`, and symlink escape | Edge Case | PASS |

**Coverage:** 98.42% lines (437/444), 94.87% branches (74/78).

**Not covered:** 7 lines in the deepest recovery branches, reachable only when a replace and its rollback both fail.

---

### `.codex/hooks/enforce-epic-planning-only.ps1` (preparation gate)

| Test Name | Scenario Type | Status |
|-----------|--------------|--------|
| allows `transition_prepared_orchestration` under the preparation route | Positive | PASS |
| denies shell edit outside the preparation allowlist | Negative | PASS |
| denies production patch to `src/service.py` | Negative | PASS |
| checkpoint bytes unchanged across a denied decision (byte identity) | Error Handling | PASS |
| fails closed for an attested preparation child before its checkpoint exists | Error Handling | PASS |

**Coverage:** 91.82% lines (146/159).

**Not covered:** lines 58, 67, 72, and 77 — the four `throw` statements of `Get-EpicPlanningRegisteredMcpTool` covering an absent registry file, an unregistered semantic id, a mismatched operation, and a malformed transport alias. Nine further uncovered lines (297, 326, 333-335, 340, 349, 353-354) are pre-existing and match the baseline's uncovered set exactly. Recorded as finding F1.

---

## 6. Test Execution Metrics

| Metric | Value | Status |
|--------|-------|--------|
| Total Tests (all languages) | 11304 | PASS |
| Tests Passed | 11304 (100%) | PASS |
| Tests Failed | 0 | PASS |
| Tests Skipped | 14 (9 Pester, 5 pytest), all pre-existing | PASS |
| Execution Time | Jest 2974 tests in the full run; pytest 4390 in 29.41s; Pester 3940 in 180.60s | PASS Fast |
| Average Time per Test | pytest 6.7ms; Pester 45.8ms; Jest 5.3ms on the 306-test handoff subset | PASS Fast |
| Test Suites | Jest 214, Pester 88 files, pytest 14 changed modules | PASS |
| Largest Changed Test File | 500 lines | PASS Maintainable |
| Code Coverage - TypeScript | 96.88% lines, 90.43% branches | PASS |
| Code Coverage - Python | 92.89% lines, 85.51% branches | PASS |
| Code Coverage - PowerShell | 94.77% lines, no branch metric | PASS |

---

## 7. Code Quality Checks

**For Python:**

| Check | Command | Result | Status |
|-------|---------|--------|--------|
| Black Formatting | `poetry run black --check scripts tests` | 473 files unchanged | PASS |
| Ruff Linting | `poetry run ruff check scripts tests` | All checks passed | PASS |
| Pyright Type Checking | `poetry run pyright` | 0 errors, 0 warnings | PASS |
| Pytest Tests | `poetry run pytest tests/scripts/dev_tools -q` | 4302 passed, 5 skipped | PASS |

**For PowerShell:**

| Check | Command | Result | Status |
|-------|---------|--------|--------|
| Invoke-Formatter | `Invoke-PoshQCFormat -Root <repo>` (recorder seam) | 0 files drifted | PASS |
| PSScriptAnalyzer | `Invoke-PoshQCAnalyze -Root <repo>` | 0 findings | PASS |
| Pester Tests | `Invoke-Pester` over `tests/scripts/codex-hooks` | 637 passed, 0 failed | PASS |

**For TypeScript:**

| Check | Command | Result | Status |
|-------|---------|--------|--------|
| Prettier | `npx prettier --check ...` | All matched files formatted | PASS |
| ESLint | `npm run lint` | 0 findings | PASS |
| TSC | `npm run typecheck` | 0 errors | PASS |
| Jest | `node run-jest.cjs --testPathPatterns=...` | 17 suites, 306 tests passed | PASS |

**Notes:**

Two pre-existing repository conditions bear on interpretation and are not introduced by this branch. First, `quality-tiers.yml` does not exist at the repository root despite `.claude/rules/quality-tiers.md` naming it as the source of truth, so the tier-dependent half of the gate matrix (property-test density, mutation score, the untyped-escape-hatch budget, determinism retry rate, golden tests, and E2E scope) cannot be evaluated against an authoritative classification. This audit therefore records no tier assertion for any changed module and evaluates only the uniform gates, all of which are tier-independent under Authoritative Decision #2. Second, no dependency-cruiser configuration exists anywhere in the repository, so stage 4 of the toolchain is satisfied by directed import-boundary scans rather than by a declarative rule set. Both conditions predate the branch and neither appears in the branch diff.

---

## 8. Gaps and Exceptions

### Identified Gaps

Three gaps remain, all previously identified in the 2026-09-07T02-00 cycle and deferred by orchestrator decision. None is blocking.

- **F1 - Untested fail-closed paths in the PowerShell registry loader (Major).** The four `throw` statements at lines 58, 67, 72, and 77 of `.codex/hooks/enforce-epic-planning-only.ps1` are the rejection contract for an absent registry file, an unregistered semantic id, a mismatched operation, and a malformed transport alias. None is exercised. The branch added 24 executable lines to this file and covered 20 of them, so the changed-line subset is 83.33%, below the 85% uniform line floor as applied to changed lines. The file level is 91.82% and no previously covered line regressed, so the language coverage verdict remains PASS. This is the coverage half of AC7's rejection requirement; the TypeScript half is covered by `semantic-mcp-alias-cases.json`. Carried forward from R11/R4. Remediation: add four Pester cases driving each throw.
- **F2 - New TypeScript modules are not registered in the per-file coverage gate (Major).** `extensions/drm-copilot/jest.config.cjs` carries a per-file `coverageThreshold` map and no `global` key, so coverage is enforced only for files named in that map. It contains zero entries for the 14 new handoff modules and was not modified by this branch. Measured coverage for those modules is 99.19% line and 93.68% branch today, so there is no present shortfall, but a future regression on any of them would not fail the run. Carried forward from R10/R7a. Remediation: add 14 entries at `lines: 85, branches: 75`.
- **F3 - Discarded causes in 15 bare catch blocks (Major).** `.claude/rules/general-code-change.md` requires that errors be propagated with added context. Fifteen `} catch {` blocks across `orchestration-handoff-materializer.ts` (10), `orchestration-handoff-authority-service.ts` (2), `orchestration-handoff-path-boundary.ts` (2), and `orchestration-handoff-materializer-production.ts` (1) discard the caught value and return a generic code, most often `HANDOFF_VALIDATOR_UNAVAILABLE`. An absent file, a permission denial, and a malformed read are consequently indistinguishable to an operator. The design intent - deterministic failure codes with no exception leakage across the MCP boundary - is sound, and each catch is narrowly scoped around one or two calls rather than a whole function body, which is why this is Major rather than Blocking. Carried forward from R12/R13. Remediation: bind the caught value and attach a redacted cause string to the existing structured `details` channel.

Two further observations are recorded without remediation items:

- **Test-tree type errors.** `npx tsc -p extensions/drm-copilot/tsconfig.jest.json --noEmit` reports 331 errors across 69 files. This configuration is used by ts-jest for transpilation only; because it sets `isolatedModules: true`, ts-jest does not surface diagnostics, and the enforced gate `npm run typecheck` compiles `src` only and exits 0. Of the 331 errors, 318 sit in 63 files untouched by this branch and are pre-existing. The remaining 13 sit in 6 branch files, the most substantive being `orchestration-handoff-materializer-path-boundary.test.ts:182`, where a `TransitionPreparedOrchestrationRequest` literal omits the ten independent-expected-context fields yet the test asserts a `materialized` outcome. That test stubs the validation dependency, so it does not demonstrate a production defect; it does mean the literal would not catch a future required-field addition. This is a repository-wide condition on an ungated axis, so it is recorded here rather than as a branch finding.
- **Interface-only module at 0% coverage.** `extensions/drm-copilot/src/repo-automation-service-contract.ts` reports 0/198 lines. The file declares five `export interface` members and no runtime construct. `.claude/rules/general-unit-test.md` states that TypeScript interface-only files legitimately report 0% executable coverage. The file remains inside `collectCoverageFrom` rather than being excluded, so it stays in the denominator, which is the stricter of the two permitted treatments. No action required.

### Approved Exceptions

- **PowerShell branch coverage.** No branch-coverage threshold is applied to PowerShell. Pester measures command (instruction) and line coverage only, and `.claude/rules/quality-tiers.md` and `.claude/rules/powershell.md` grant an explicit threshold exemption on that basis. This is a capability limit, not a file-level exclusion: the PowerShell production files remain in the line-coverage denominator.
- **Markdown plan fixtures over 500 lines.** The two 1413-line `plan.2026-08-29T12-22.md` fixtures under `tests/fixtures/orchestration-handoff/taskmaster-469/` exceed the file-size limit. `.claude/rules/general-code-change.md` exempts raw text fixtures for language-processing test data and Markdown documentation. Their byte content is load-bearing: both are pinned by raw SHA-256 in the fixture envelopes and protected from checkout normalization by `-text -eol` entries in `.gitattributes`.

### Removed/Skipped Tests

**None.** No test was removed or newly skipped by this branch. The 14 skipped cases in the full run (9 Pester, 5 pytest) are pre-existing: 2 non-Windows host guards in `new-claude-worktree-session.Tests.ps1`, 7 PSGallery installation cases in `PoshQC.Comprehensive.Tests.ps1`, and 5 manifest parity cases in `test_parallel_manifest_bash_parity.py` that declare no accessor expectation. None sits in a file changed by this branch.

---

## 9. Summary of Changes

### Commits in This PR/Branch

1. **3e143b11** - feat(orchestration): add portable prepared-state handoff contract
2. **b01e5201** - feat(orchestration): add portable handoff runtime authority
3. **d2fb6ead** - feat(orchestration): add portable handoff consumer parity
4. **093c7555** - test(orchestration): close portable handoff QA gaps
5. **f0381327** - docs(orchestration): record portable handoff execution checkpoint
6. **80acb8d5** - fix(orchestration): enforce canonical handoff path containment
7. **f049f6ce** - fix(orchestration): preserve handoff fixture byte identity
8. **e22d002d** - fix(orchestration): require independent expected context for handoff FR-614-005
9. **5b9849f8** - test(orchestration): close FR-614-005 review cycle 4 items R1-R3
10. **fca8c045** - docs(orchestration): add cycle 5 review artifacts for handoff FR-614
11. **645c40b0** - test(orchestration): fix CI handoff test failures for FR-614

### Files Modified

1. **`config/orchestration-handoff.schema.json`** (NEW)
   - Draft 2020-12 schema with a semantically versioned `$id` at version 2.0.0.
   - `additionalProperties: false` with 13 required top-level properties covering identity, binding, source, destination, plan, lifecycle, capabilities, scheduler context, and handoff history.

2. **`config/orchestration-handoff-registry.json`** (NEW)
   - 12 lifecycle ids, 4 semantic MCP tools each with both `drm-copilot` and `drm_copilot` transport aliases, provider adapters, transitions, capabilities, and the ordered 16-code `failure_precedence` list.
   - Exactly one tool is marked `mutating: true`: `drm-copilot.transition_prepared_orchestration`.

3. **`extensions/drm-copilot/src/lib/validate/orchestration-handoff-*.ts`** (12 NEW)
   - Contract validation, support helpers, path boundary, checkout context, provider adapters, authority service, and the materializer split across request, support, production-wiring, and state-machine modules.

4. **`extensions/drm-copilot/src/mcp-handlers/orchestration-handoff-handlers.ts`** and **`src/mcp-repo-automation-tool-definitions-handoff.ts`** (NEW)
   - MCP transport surface for the four semantic operations, at 100.00% line coverage each.

5. **`scripts/dev_tools/orchestration_handoff_contract.py`**, **`_adapters.py`**, **`_contract_support.py`** (NEW)
   - Python contract, bidirectional adapters, and shared helpers, including the legacy-v1 read path and the bounded scheduler-return validator.

6. **`.codex/hooks/enforce-epic-planning-only.ps1`** (MODIFIED)
   - Adds `Get-EpicPlanningRegisteredMcpTool`, which loads the registry at hook load, verifies each semantic id's operation and both transport aliases, and builds the preparation allowlist. 321 lines.

7. **`.gitattributes`** (MODIFIED)
   - Adds `-text -eol` for the two TaskMaster plan fixtures so their bytes survive checkout on any platform, preserving the pinned raw SHA-256 identities.

8. **`tests/fixtures/orchestration-handoff/**`** (10 NEW)
   - Contract positive and negative cases, semantic MCP alias cases, and the bidirectional TaskMaster #469 end-to-end fixtures with pinned source and plan hashes.

9. **Bundled and packed resource copies** (MODIFIED/NEW)
   - `extensions/drm-copilot/resources/config/` copies of both JSON files, the `codex-and-agents-customizations` copy of the hook, five skill Markdown surfaces, and the extended `pack-manifests/core.json`. All verified byte-identical to their root originals by `git hash-object`.

10. **Test suites** (16 TypeScript, 14 Python, 4 PowerShell)
    - One suite per new module plus dedicated negative-coverage, path-boundary, and end-to-end suites, and three shared test-support modules.

---

## 10. Compliance Verdict

### Overall Status: PARTIALLY COMPLIANT

Every uniform gate passes with margin and every mandatory toolchain stage completed cleanly in a single pass at the current branch head, verified by this reviewer rather than accepted from the executor's records. Coverage was recomputed directly from the three canonical artifacts and meets or exceeds the line and branch floors in every language with changed files. The verdict is PARTIALLY COMPLIANT rather than FULLY COMPLIANT solely because three previously identified Major findings remain open: the four untested fail-closed paths in the PowerShell registry loader, the absent per-file coverage-gate registration for the 14 new TypeScript modules, and the 15 catch blocks that discard the underlying cause. None of the three is blocking, and all three were deferred by explicit orchestrator decision in the prior cycle.

**Fail-closed reminder:** This audit does not report a fail-closed condition. Every required baseline artifact, QA artifact, coverage artifact, and coverage-comparison figure was located, parsed, and reported numerically above.

---

### Policy-by-Policy Summary

#### General Code Change Policy (Section 2)
- PASS Before Making Changes: objective, plans, and per-commit documentation all present
- PASS Design Principles: data-driven contract, injected seams, one-way dependency direction
- PASS Module & File Structure: all changed code files at or under 500 lines, no cycles
- PASS Naming, Docs, Comments: structured docstrings, TSDoc, rationale-focused comments
- PASS Toolchain Execution: seven stages, one clean pass, all reproduced by the reviewer
- PASS Summarize & Document: eight documentation surfaces updated in lockstep

#### Language-Specific Code Change Policy (Section 3)

**For Python:**
- PASS Tooling & Baseline: Black, Ruff, Pyright, pytest all clean
- PASS Python Design & Typing: dataclasses, `Final` constants, no production `Any`
- PASS Error Handling: specific messages, invariants enforced at construction

**For PowerShell:**
- PASS Tooling & Baseline: zero format drift, zero analyzer findings
- PARTIAL PowerShell Design & Safety: fail-closed design is correct; its four throw paths are untested (F1)
- PASS Structure & Naming: 321 lines, approved verbs, rationale comments
- PASS Toolchain: one clean pass, tree unmodified by the check-only format gate

**For TypeScript:**
- PASS Tooling & Baseline: Prettier, ESLint, TSC, Jest all clean
- PARTIAL Design & Typing: no `any` and 5 justified assertions; 15 catch blocks discard the cause (F3)
- PASS Structure & Documentation: all modules under 500 lines, no banned timing APIs

#### General Unit Test Policy (Section 1)
- PASS Core Principles: independence, isolation, speed, determinism, readability all evidenced
- PASS Coverage & Scenarios: every threshold met; positive, negative, edge, and error flows covered
- PASS Test Structure: explicit Arrange-Act-Assert, structured assertions, documented intent
- PASS External Dependencies: no network, no database, no temporary files, injected seams throughout
- PASS Policy Audit: this document satisfies the pre-submission review requirement

#### Language-Specific Unit Test Policy (Section 4)

**For Python:**
- PASS Framework & Scope: pytest with `--cov-branch`, 97.71% new-module line coverage
- PASS Test Style & Structure: focused, fixture-driven, mirrored tree
- PASS Naming & Readability: descriptive names plus one-line docstrings
- PASS Toolchain: pytest only

**For PowerShell:**
- PASS Framework & Scope: Pester v5, PoshQC runsettings, 94.77% repository line coverage
- PASS Test Style & Structure: process-contract testing, no mocks, mirrored tree
- PASS Naming & Readability: `.Tests.ps1` suffix, Describe/Context/It, self-documenting names
- PASS Toolchain: Pester only

---

### Metrics Summary

- PASS 11304 of 11304 tests passing (100%), 0 failed, 14 pre-existing skips
- PASS TypeScript 96.88% line and 90.43% branch coverage, against 85% and 75% floors
- PASS Python 92.89% line and 85.51% branch coverage, against 85% and 75% floors
- PASS PowerShell 94.77% line coverage, against the 85% floor; branch threshold not applicable
- PASS New-code coverage 99.19% line (TypeScript) and 97.71% line (Python), against the 90% expectation
- PASS Zero format, lint, and type findings across all three languages
- PASS Zero architecture-boundary violations; no production TypeScript module reaches into the Python tooling tree
- PASS Publishing parity confirmed byte-identical for all five root-to-bundle pairs by `git hash-object`
- PASS Evidence-location validator clean; zero non-canonical evidence paths in the branch diff
- PASS Working tree byte-clean before, during, and after the review

---

### Recommendation

**Ready for merge, conditional on the pull request's own required CI checks concluding green.**

The branch satisfies every uniform quality gate and every mandatory toolchain stage at head `645c40b0`, independently verified. The two CI failures from the prior cycle were remediated test-only and their fixes were confirmed correct by direct inspection of the production seams they depend on, including a check that the residual drive-letter literals reach no absolute-path predicate on any success path. Acceptance criteria stand at 28 of 28.

The three open Major findings should be filed as follow-up work against a subsequent issue rather than gating this merge. F1 is the highest value of the three, because it leaves the hook-side rejection contract for AC7 asserted by construction rather than by test; four Pester cases would close it. F2 is a durability gap that costs nothing today but removes the automated guard on 14 modules. F3 is a diagnosability cost paid at operator time rather than a correctness defect.

Run 34117865928 against this head was still in progress at the time of this audit and is observed by the orchestrator's separate CI gate. This audit does not assert its outcome.

---

## Appendix A: Test Inventory

Representative inventory of the branch's new and changed test surfaces. The full run comprises 11304 cases across three languages.

**TypeScript (16 changed suite files, 306 cases in the handoff subset):**

1. `orchestration-handoff-contract.test.ts` › registry parity › precedence matches the shared registry and has length 16
2. `orchestration-handoff-contract.test.ts` › precedence selection › selects one primary code from multiply-invalid failures
3. `orchestration-handoff-contract.test.ts` › precedence selection › rejects completed-phase replay before dirty-worktree precedence
4. `orchestration-handoff-contract-negative-coverage.test.ts` › table-driven negative cases from `invalid-contract-cases.json`
5. `orchestration-handoff-authority-service.test.ts` › authority resolution with injected path boundary and checkout context
6. `orchestration-handoff-materializer.test.ts` › materialize, dry-run, mismatch, and recovery paths
7. `orchestration-handoff-materializer-path-boundary.test.ts` › boundary wiring with mocked resolution
8. `orchestration-handoff-materializer-production.test.ts` › production seam construction
9. `orchestration-handoff-path-boundary.test.ts` › absolute, traversal, symlink, and rediscovery rejection
10. `orchestration-handoff-provider-adapters.test.ts` › Claude-to-Codex and Codex-to-Claude projection
11. `orchestration-handoff-checkout-context.test.ts` › repository, workspace, branch, and head-relationship binding
12. `semantic-mcp-identity.test.ts` › alias cases from `semantic-mcp-alias-cases.json`
13. `mcp-handlers/orchestration-handoff-handlers.test.ts` › the four semantic operations over the MCP surface
14. `mcp-repo-automation-tool-definitions.test.ts` › tool definition registration
15. `mcp-server.test.ts` › server-level wiring
16. `repo-automation-orchestration-validation.test.ts` › orchestration validation integration

**Python (14 changed modules):**

- `tests/scripts/dev_tools/test_orchestration_handoff_schema.py`
- `tests/scripts/dev_tools/test_orchestration_handoff_contract.py::test_failure_precedence_matches_the_shared_registry`
- `tests/scripts/dev_tools/test_orchestration_handoff_versions.py::test_legacy_v1_accepts_only_explicit_migration_facts`
- `tests/scripts/dev_tools/test_orchestration_handoff_versions.py::test_supported_newer_minor_version_is_accepted`
- `tests/scripts/dev_tools/test_orchestration_handoff_versions.py::test_unknown_major_version_has_deterministic_code`
- `tests/scripts/dev_tools/test_orchestration_handoff_versions.py::test_unknown_vocabulary_has_deterministic_code`
- `tests/scripts/dev_tools/test_orchestration_handoff_versions.py::test_unknown_capability_has_deterministic_code`
- `tests/scripts/dev_tools/test_orchestration_handoff_versions.py::test_invalid_transition_has_deterministic_code`
- `tests/scripts/dev_tools/test_orchestration_handoff_versions.py::test_completed_phase_replay_has_deterministic_code`
- `tests/scripts/dev_tools/test_orchestration_handoff_paths.py`
- `tests/scripts/dev_tools/test_orchestration_handoff_provenance.py`
- `tests/scripts/dev_tools/test_orchestration_handoff_adapters.py`
- `tests/scripts/dev_tools/test_orchestration_handoff_taskmaster_469.py`
- `tests/scripts/dev_tools/test_push_down_codex_and_agents_customizations.py::test_consumer_authority_is_typescript_only_and_scope_owners_are_unchanged`
- `tests/scripts/dev_tools/test_push_down_codex_and_agents_customizations.py::test_codex_guidance_requires_independent_expected_context`
- `tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py`
- `tests/scripts/dev_tools/test_validate_orchestrator_state_completion.py`

**PowerShell (4 changed files, 637 cases in the codex-hooks subset):**

1. `epic-execution-gates.Tests.ps1` › Codex epic preparation, wave, merge, and worktree gates › preparation route › allows the registered mutating transition
2. `epic-execution-gates.Tests.ps1` › preparation route › denies shell edit and production patch, with checkpoint bytes unchanged
3. `epic-execution-gates.Tests.ps1` › wave launch › fails closed for an attested preparation child before its checkpoint exists
4. `epic-execution-gates.Tests.ps1` › merge gate › allows a child after every dependency is merged; denies a child before an upstream merge
5. `epic-execution-gates.Tests.ps1` › worktree removal › allows removal after merge
6. `legacy-codex-hook-contracts.Tests.ps1` › legacy hook process contracts
7. `codex-pretooluse-integration.Tests.ps1` › PreToolUse integration
8. `codex-pretooluse-transport.Tests.ps1` › PreToolUse transport

---

## Appendix B: Toolchain Commands Reference

**For TypeScript** (run from `extensions/drm-copilot`):
```bash
# Formatting (check-only)
npx prettier --check "src/**/*.ts" "test/**/*.ts" "*.json" "*.cjs"

# Linting
npm run lint

# Type checking
npm run typecheck

# Testing
node run-jest.cjs --testPathPatterns="orchestration-handoff|semantic-mcp-identity|mcp-server|repo-automation-orchestration-validation|mcp-repo-automation-tool-definitions"

# Coverage (artifact inspected, not regenerated by this review)
npm run test:coverage   # -> extensions/drm-copilot/coverage/lcov.info
```

**For Python** (run from the repository root):
```bash
# Formatting (check-only)
poetry run black --check scripts tests

# Linting
poetry run ruff check scripts tests

# Type checking
poetry run pyright

# Testing
poetry run pytest tests/scripts/dev_tools -q

# Coverage (artifact inspected, not regenerated by this review)
poetry run pytest --cov=src --cov=scripts/dev_tools --cov-branch   # -> artifacts/python/lcov.info

# Evidence-location validation
poetry run python scripts/dev_tools/validate_evidence_locations.py --root .
```

**For PowerShell:**
```powershell
# Formatting, driven check-only through the -WriteFile dependency seam
Import-Module ./scripts/powershell/PoshQC/PoshQC.psd1 -Force
$drift = New-Object System.Collections.Generic.List[string]
Invoke-PoshQCFormat -Root . `
  -WriteFile { param([string] $Path, [string] $Content) $drift.Add($Path) } `
  -Logger { param([string] $Message) } | Out-Null
$drift.Count   # 0 means no drift

# Linting
Invoke-PoshQCAnalyze -Root .

# Testing
$c = New-PesterConfiguration
$c.Run.Path = 'tests/scripts/codex-hooks'
$c.Run.PassThru = $true
Invoke-Pester -Configuration $c

# Coverage (artifact inspected, not regenerated by this review)
# -> artifacts/pester/powershell-coverage.xml, artifacts/pester/pester-junit.xml
```

**Verification helpers used by this audit:**
```bash
# Scope and evidence-location scans
git diff --name-status 0542c92a..HEAD
git diff --name-only 0542c92a..HEAD | grep -E "^artifacts/(baselines|qa|evidence|coverage)/"

# Publishing byte-identity
git hash-object config/orchestration-handoff.schema.json \
  extensions/drm-copilot/resources/config/orchestration-handoff.schema.json

# Fixture byte identity across checkout normalization
git cat-file blob HEAD:<fixture> | sha256sum
```

---

**Audit Completed By:** feature-review agent
**Audit Date:** 2026-09-07
**Policy Version:** Current (as of audit date)
