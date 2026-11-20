# Remediation Inputs: Portable Prepared Orchestration Handoff (Issue #614)

**Cycle entry timestamp:** 2026-09-07T02-00
**Author:** feature-review
**Feature Folder:** `docs/features/active/2026-08-31-portable-prepared-orchestration-handoff-614`
**Base Branch:** `main`, resolved to `origin/main @ 0542c92a7c589cfe952a0dfd480223960fd1eb33`
**Head Branch:** `feature/portable-prepared-orchestration-handoff-614 @ 0decbdbbf6dcdea1231cf6eb3715835b369883ad`
**Merge Base:** `1ed0964045febbb4d92f1cb92661d4b945153a40`

## Source Audit Artifacts

These remediation inputs are derived from, and must be read alongside, the three audit artifacts produced in the same cycle:

- `docs/features/active/2026-08-31-portable-prepared-orchestration-handoff-614/policy-audit.2026-09-07T02-00.md`
- `docs/features/active/2026-08-31-portable-prepared-orchestration-handoff-614/code-review.2026-09-07T02-00.md`
- `docs/features/active/2026-08-31-portable-prepared-orchestration-handoff-614/feature-audit.2026-09-07T02-00.md`

## Blocking Status

**Blocking findings: 0.**

Every mandatory gate is green on the branch head. All seven toolchain stages pass in a single check-only sweep with a clean working tree; all three coverage languages exceed the uniform 85% line and, where the tooling measures it, 75% branch thresholds repo-wide, on changed lines, and per changed production file; no evidence-location or coverage-exclusion violation exists; and all 28 acceptance criteria across `spec.md` and `user-story.md` verify as PASS.

This cycle does not gate the pull request. If the orchestrator is evaluating the remediation-loop exit gate, `blocking_count` is 0 and `exit_condition_met` may be set.

## Priority Ordering

Items R8 and R9 are new this cycle and are the two that matter. Both are Python-side gaps in a two-runtime parity contract, which is the same failure class as R1 and R2 already remediated at commit `0decbdbb`. R10 through R15 are carried forward unchanged from the 2026-09-06T23-30 cycle, where they were deferred by orchestrator decision; each was independently re-verified as still present at head.

Identifier note: the previous cycle used R1-R7. To avoid collision, this cycle numbers its items R8 onward. The mapping from the previous identifiers is stated in each carried-forward item.

---

## Enumerated Fix List

### R8 — Cover the Python binding-check accept path (Major, new this cycle)

- **File:** `scripts/dev_tools/orchestration_handoff_contract.py`, `validate_bindings` at lines 353-366
- **Test file to change:** `tests/scripts/dev_tools/test_orchestration_handoff_contract.py`
- **Current state:** All six mismatch branches at lines 354-365 are covered. The terminal `return None` at line 366, which signals that every observed binding matches the envelope, is uncovered. The function is the accept gate for repository, workspace, issue, feature folder, branch, and plan-hash agreement. Its TypeScript counterpart in `orchestration-handoff-contract.ts` covers its accept path; the module's only uncovered lines are 443-448, a history-mismatch reject branch.
- **Failure mode this leaves open:** a refactor that inverted a comparison, or that added a seventh guard returning a code unconditionally, would pass the entire Python suite while making every valid handoff fail closed. Nothing in the Python suite asserts that acceptance is reachable.
- **Expected behavior after remediation:** a Python test builds a valid envelope, constructs an `observed` mapping whose `repository_id`, `workspace_root`, `issue_number`, `feature_folder`, `branch`, and `plan_sha256` equal the envelope's corresponding values, and asserts `validate_bindings(envelope, observed) is None`. The assertion must use the envelope's own values rather than literals, so the test stays correct if the fixture changes.
- **Verification commands:**
  - `poetry run pytest tests/scripts/dev_tools/test_orchestration_handoff_contract.py -q`
  - `poetry run pytest --cov=scripts/dev_tools --cov-branch --cov-report=term-missing tests/scripts/dev_tools/`
  - Confirm line 366 no longer appears as uncovered for `scripts/dev_tools/orchestration_handoff_contract.py` in `artifacts/python/lcov.info`
- **Policy basis:** `.claude/rules/general-unit-test.md`, Scenario Completeness — "Positive flows with valid inputs" is a required scenario class per unit.
- **Acceptance criteria affected:** spec AC11, user-story US10 (both currently PASS; this closes the durability gap, not a behavioral gap)

### R9 — Wire or exercise the exported Python plan-identity helpers (Major, new this cycle)

- **Files:** `scripts/dev_tools/orchestration_handoff_contract_support.py`, `resolve_pinned_plan_path` at lines 46-54 and `raw_file_sha256` at lines 61-62; re-exported from `scripts/dev_tools/orchestration_handoff_contract.py` at lines 20 and 26
- **Test files to change:** `tests/scripts/dev_tools/test_orchestration_handoff_paths.py` and `tests/scripts/dev_tools/test_orchestration_handoff_taskmaster_469.py`
- **Current state:** `raw_file_sha256` has zero in-repo callers and zero tests; line 62 is uncovered. `resolve_pinned_plan_path` has exactly one caller, the negative test at `test_orchestration_handoff_paths.py` line 147, so its success return at line 54 and its outside-workspace guard at line 51 are both uncovered. Separately, `test_orchestration_handoff_taskmaster_469.py` lines 76-77 recompute the source and plan digests with a direct `hashlib.sha256(...).hexdigest()` call rather than through `raw_file_sha256`. The Python plan-hash check at `orchestration_handoff_contract.py` line 364 compares against a caller-supplied `observed["plan_sha256"]` and never reads the plan file, so no Python code path binds an envelope to real bytes on disk through these helpers.
- **Decide first, then implement.** Two dispositions are acceptable and the choice is a design decision, not a test-only change:
  1. **Wire them in.** If the Python runtime is intended to resolve and hash the pinned plan from disk, route that through `resolve_pinned_plan_path` and `raw_file_sha256` in the validation path, and cover both the accept and the outside-workspace reject branches.
  2. **Keep the caller-supplied-observation model.** If the observation is intentionally supplied by the caller, then have the TaskMaster fixture test call `raw_file_sha256` and `resolve_pinned_plan_path` instead of computing digests inline, so the exported surface is exercised and the duplication is removed.
- **Expected behavior after remediation, under either disposition:** lines 51, 54, and 62 are covered; `test_orchestration_handoff_taskmaster_469.py` no longer calls `hashlib.sha256` directly for the source and plan digests; and a success-path test asserts `resolve_pinned_plan_path` returns the resolved `Path` for a committed fixture file inside the workspace root.
- **Constraint:** do not change the pinned digest values, do not regenerate any fixture, and do not remove the two `.gitattributes` entries that disable EOL normalization for the fixture plan files.
- **Verification commands:**
  - `poetry run pytest tests/scripts/dev_tools/test_orchestration_handoff_paths.py tests/scripts/dev_tools/test_orchestration_handoff_taskmaster_469.py -q`
  - `poetry run pytest --cov=scripts/dev_tools --cov-branch --cov-report=term-missing tests/scripts/dev_tools/`
  - Confirm lines 51, 54, and 62 no longer appear as uncovered for `scripts/dev_tools/orchestration_handoff_contract_support.py` in `artifacts/python/lcov.info`
- **Policy basis:** `.claude/rules/general-code-change.md`, Reusability — avoid copy-paste and share behavior via helper methods. `.claude/rules/general-unit-test.md`, Scenario Completeness — positive flows are required.
- **Acceptance criteria affected:** spec AC3, spec AC13, user-story US1, user-story US11 (all currently PASS; the enforcement is present in the runtimes that perform it, and this closes the unused-abstraction and duplication gap)

### R10 — Register the new modules in the TypeScript coverage gate (Major, carried forward as R7a)

- **File:** `extensions/drm-copilot/jest.config.cjs`
- **Current state:** the config declares no `global` threshold key, so the per-file `coverageThreshold` map is the only mechanism that can fail the coverage run. The branch adds sixteen production modules under `src/**` and registers none of them, while forty-five unrelated modules carry `{ lines: 85, branches: 75 }` entries. The file is unmodified on this branch. Actual coverage for the new modules ranges from 97.56% to 100.00%, so nothing fails today; the defect is that a future regression to 40% on any of them would also exit 0.
- **Severity note:** the 2026-09-06T23-30 cycle classified this a Nit. It is raised to Major here because the scope is the entire new production surface of the feature rather than one file.
- **Expected behavior after remediation:** `{ lines: 85, branches: 75 }` entries exist for the fourteen added `src/**` modules and for `src/mcp-repo-automation-tool-definitions-handoff.ts`, following the existing per-file convention. Do not add an entry for `src/repo-automation-service-contract.ts`; it is interface-only and its 0% is already documented in the config comments at lines 170-177 and 261-266.
- **Verification commands:**
  - `cd extensions/drm-copilot && npm run test:coverage`, confirm the run still exits 0
  - Confirm every added entry names a path that exists, by cross-checking against the `SF:` records in `extensions/drm-copilot/coverage/lcov.info`
- **Policy basis:** `.claude/rules/general-unit-test.md` Coverage Requirements and `.claude/rules/quality-tiers.md` uniform gate matrix — a gate not wired to the changed surface is not a gate.
- **Acceptance criteria affected:** none directly.

### R11 — Bring the hook registry load inside its error contract and cover its failures (Minor, carried forward as R4)

- **File:** `.codex/hooks/enforce-epic-planning-only.ps1`, lines 85-88, with the validating function at lines 48-83
- **Published copy that must stay byte-identical:** `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/enforce-epic-planning-only.ps1`
- **Test file to change:** `tests/scripts/codex-hooks/epic-execution-gates.Tests.ps1`
- **Current state:** `$script:AllowedPreparationSemanticMcpTools = @(Get-EpicPlanningRegisteredMcpTool ...)` executes at script scope, above both the dot-source guard and the top-level `try`. An absent or malformed `config/orchestration-handoff-registry.json` therefore raises an unhandled terminating error instead of the contracted `EPIC_PLANNING_ONLY_BLOCKED:` stderr reason with `exit 2`, and it makes the file impossible to dot-source in that state. All four validation `throw` statements at lines 58, 67, 72, and 77 are unexercised and are the only uncovered changed PowerShell lines on the branch.
- **Expected behavior after remediation:** an absent registry, an unregistered semantic id, a mismatched `operation` field, and a malformed transport alias each produce the `EPIC_PLANNING_ONLY_BLOCKED:` prefixed reason on stderr and exit code 2. Dot-sourcing continues to work regardless of registry state so the existing dot-source-based suites remain usable.
- **Implementation note:** either move the resolution inside the existing top-level `try`, or wrap it in its own `try`/`catch` that writes to stderr and exits 2. If it moves below the dot-source guard, confirm no function referencing `$script:AllowedPreparationSemanticMcpTools` is invoked during dot-sourcing.
- **Verification commands:**
  - `Invoke-PoshQCTest` scoped to `tests/scripts/codex-hooks`
  - `Invoke-PoshQCAnalyze -Root <repo-root>`
  - `poetry run pytest tests/scripts/dev_tools/test_push_down_codex_and_agents_customizations.py -q` to confirm the published copy stays byte-identical
  - Confirm lines 58, 67, 72, and 77 no longer appear as uncovered in `artifacts/pester/powershell-coverage.xml`
- **Policy basis:** `.claude/rules/general-code-change.md` Error Handling; `.claude/rules/general-unit-test.md` Scenario Completeness.
- **Acceptance criteria affected:** spec AC7, user-story US6 (both currently PASS; behavior under a correctly installed registry is unaffected)

### R12 — Make the materializer error narrowing sound (Minor, carried forward as R5)

- **File:** `extensions/drm-copilot/src/lib/validate/orchestration-handoff-materializer.ts`, line 275
- **Current state:** `error instanceof Error && "code" in error ? (error.code as HandoffFailureCode) : "HANDOFF_VALIDATOR_UNAVAILABLE"` narrows on the mere presence of a `code` property and then asserts an unvalidated value into the failure-code union. A Node `ErrnoException` carrying `"ENOENT"` satisfies the guard, and callers route on this field.
- **Expected behavior after remediation:** the narrowing uses `error instanceof HandoffContractError`, whose `code` is already declared `HandoffFailureCode` at `orchestration-handoff-contract-support.ts` line 129, and falls back to `HANDOFF_VALIDATOR_UNAVAILABLE` for every other error. No unvalidated string can enter the result contract.
- **Verification commands:**
  - `cd extensions/drm-copilot && npm run typecheck`
  - `cd extensions/drm-copilot && npm run lint`
  - `cd extensions/drm-copilot && node run-jest.cjs --testPathPattern "orchestration-handoff"`
- **Policy basis:** `.claude/rules/typescript.md` and `.claude/rules/general-code-change.md`.
- **Acceptance criteria affected:** none directly; this hardens the failure-code contract that AC11 and US10 depend on.

### R13 — Preserve the cause behind `HANDOFF_VALIDATOR_UNAVAILABLE` (Minor, carried forward as R6)

- **File:** `extensions/drm-copilot/src/lib/validate/orchestration-handoff-materializer.ts`, 11 `catch` blocks across `prepare` and `stageMaterialization`
- **Current state:** every caught error is discarded, and `HANDOFF_VALIDATOR_UNAVAILABLE` is returned for at least six distinct causes: source or envelope read failure, UTF-8 decode failure, destination-projection validation failure, Git porcelain read failure, candidate write or re-read failure, and atomic replace failure. An operator receiving that code cannot distinguish a filesystem permission error from a genuine validator defect.
- **Expected behavior after remediation:** either the caught cause is logged at `warning` through the project's established logging pattern, or the result carries an optional `diagnostic` string alongside the failure code. If the result shape changes, the change is additive and optional so no existing consumer breaks, and the schema and both runtime contracts stay in agreement.
- **Constraint:** do not change which failure code any condition returns. The deterministic selection is asserted in four runtimes; only diagnostic detail may be added.
- **Verification commands:**
  - `cd extensions/drm-copilot && node run-jest.cjs --testPathPattern "orchestration-handoff"`
  - `poetry run pytest tests/scripts/dev_tools/test_orchestration_handoff_contract.py -q` to confirm the contract surface is unchanged
- **Policy basis:** `.claude/rules/general-code-change.md` Error Handling.
- **Acceptance criteria affected:** none.

### R14 — Replace the split-string contract tuples (Minor, carried forward as R7b)

- **File:** `scripts/dev_tools/orchestration_handoff_contract.py`, lines 43-46 and 67-76
- **Current state:** `PHASE_ORDER` and `FAILURE_PRECEDENCE` are built by calling `.split()` on implicitly concatenated multi-line string literals, where each continuation depends on a trailing space inside the preceding literal. A dropped trailing space silently merges two contract tokens rather than raising. The R2 registry parity assertion added at `0decbdbb` now catches this for `FAILURE_PRECEDENCE`; `PHASE_ORDER` has no such guard.
- **Expected behavior after remediation:** both are explicit tuples of quoted strings, one token per line.
- **Verification commands:**
  - `poetry run pytest tests/scripts/dev_tools/ -q`
  - `poetry run black --check scripts tests`
- **Policy basis:** `.claude/rules/general-code-change.md` — enforce invariants at construction; prefer the construction that cannot fail silently.
- **Acceptance criteria affected:** none.

### R15 — Close the two remaining low-severity gaps (Nit, carried forward as R7c plus one new item)

- **R15a — Cover the already-migrated legacy guard.** `scripts/dev_tools/orchestration_handoff_contract_support.py` line 77, `raise HandoffContractError("legacy.checkpoint", "is invalid")`, is unexercised while the adjacent guards at lines 79 and 83 are covered. Add one test passing a mapping that already carries `schema_version` and assert the raised field is `legacy.checkpoint`. Verify with `poetry run pytest tests/scripts/dev_tools/test_orchestration_handoff_versions.py -q`.
- **R15b — Replace the structural type guard (new this cycle).** `extensions/drm-copilot/src/lib/validate/orchestration-handoff-materializer.ts` discriminates the `TransitionPreparation` union with `isPrepared`, which tests `"result" in preparation`. If `TransitionPreparedOrchestrationResult` ever gains a member named `result`, every blocked result would be misclassified as a prepared transition and the materializer would attempt to write a candidate from an object with no `projectionBytes`. The compiler accepts `in`-narrowing, so the type system would not catch it. Add an explicit literal discriminant, for example `readonly kind: "prepared"` on `PreparedTransition`, and test that instead. Verify with `cd extensions/drm-copilot && npm run typecheck` and `node run-jest.cjs --testPathPattern "orchestration-handoff"`.

---

## Out-of-Scope Observations (No Remediation Item; File Separately If Desired)

These are recorded for the orchestrator's awareness. None is caused by this branch and none belongs in a remediation plan scoped to issue #614.

1. **`quality-tiers.yml` does not exist.** `.claude/rules/quality-tiers.md` names it as the source of truth at repository root and states that adding a project without a tier classification fails CI. It is absent from the repository root and the two levels below it. The tier-dependent gates (property-test density, mutation score, untyped-escape-hatch budget, determinism retry rate, golden tests, E2E scope) therefore cannot be evaluated against an authoritative classification. `policy-audit.2026-09-06T23-30.md` cited a T4 classification "under `quality-tiers.yml`", which is not supportable; this cycle's audit records the tier-dependent gates as unevaluable instead. The uniform gates are tier-independent and all pass.
2. **The PowerShell coverage gate is advisory in tooling.** `scripts/powershell/PoshQC/settings/pester.runsettings.psd1` sets `CoveragePercentTarget = 0` with the comment "don't fail the run on coverage percentage", so the 85% line threshold for PowerShell is enforced by reviewer computation rather than by the test run's exit code.
3. **Headroom against the 500-line limit.** `tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py` is at exactly 500 lines; `scripts/dev_tools/orchestration_handoff_contract.py` and `extensions/drm-copilot/src/repo-automation-service.ts` are at 498; `extensions/drm-copilot/src/lib/validate/orchestration-handoff-contract.ts` is at 497. The limit is satisfied. The next addition to any of these files requires an extraction first, and R14 adds lines to one of them.

---

## Pre-PR Action (Not a Remediation Item)

Rebase the branch onto `origin/main @ 0542c92a7c589cfe952a0dfd480223960fd1eb33` and force-push with lease before opening the pull request. `origin/main` is two commits ahead of the merge base with a release version bump touching `.codex/config.toml`, `extensions/drm-copilot/package.json` and its lock file, `packages/mcp-server/package.json` and its lock file, and the bundled `config.toml` copy. None of those paths appears in the branch diff, so no conflict is expected, but without the rebase the pull-request diff will not reflect the merged state.

---

## Acceptance Criteria Re-check Instruction

No acceptance criterion changed state in this audit. All 15 `spec.md` criteria and all 13 `user-story.md` criteria are `[x]` at head and were confirmed PASS by independent evaluation. `spec.md` AC10, which the 2026-09-06T23-30 cycle unchecked following a PARTIAL evaluation, is resolved by remediation item R3 landing at commit `0decbdbb` and is correctly `[x]`.

The 12 unchecked items under `spec.md` `## Definition of Done` and `## Seeded Test Conditions (from potential)` are not acceptance criteria under `full-feature` work mode and were not modified. Their substance is met on the evidence gathered; see the Summary section of `feature-audit.2026-09-07T02-00.md`. The orchestrator may wish to have them checked before the pull request is opened, but that is a documentation-hygiene action, not a delivery gap.

---

## Do Not Do

- **Do not narrow the audit or remediation scope.** The scope of any remediation plan derived from these inputs is the branch diff against `1ed0964045febbb4d92f1cb92661d4b945153a40`, not a subset of it. Do not mark any language's coverage `N/A`, "plan scope only", "informational only", or "out of scope" when that language has changed files in the branch diff. PowerShell has two changed production files and requires an explicit PASS or FAIL verdict with a computed changed-line figure.
- **Do not weaken any policy.** Do not add a `coverageThreshold` entry below `lines: 85, branches: 75`. Do not add a `coveragePathIgnorePatterns` entry, and do not add any `exclude` entry matching a path under `src/`. Do not lower a threshold to make a file pass. Do not raise `CoveragePercentTarget` in a way that reduces what is measured.
- **Do not exclude a production file from coverage measurement.** `src/repo-automation-service-contract.ts` reports 0% because it is interface-only; it stays inside `collectCoverageFrom`. Excluding it would convert a documented and permitted 0% into a prohibited exclusion.
- **Do not change which failure code any condition returns.** The deterministic `HANDOFF_*` selection is asserted in Python, TypeScript, MCP, and hook tests. R13 may add diagnostic detail; it may not reallocate codes.
- **Do not modify the committed fixtures.** All four pinned digests under `tests/fixtures/orchestration-handoff/taskmaster-469/` were independently recomputed from the on-disk bytes at head `0decbdbb` and match. Do not regenerate, reformat, or re-serialize any fixture file, and do not remove the two `.gitattributes` entries that disable EOL normalization for the fixture plan files. A byte change to any of them breaks AC2, AC3, and AC13 and was already the subject of an earlier repair in this feature.
- **Do not create or use temporary files in tests.** The added suites are free of `tmp_path`, `TemporaryDirectory`, `NamedTemporaryFile`, `mkdtemp`, `os.tmpdir`, `TestDrive`, and `GetTempPath`. Drive filesystem behavior through the injected `HandoffFileSystemBoundary` on the TypeScript side and through committed fixtures on the Python side. R9's success-path test must resolve against a committed fixture file, not a created one.
- **Do not introduce a real clock, sleep, or wall-clock read.** The materializer takes an injected `HandoffClockBoundary`; use it.
- **Do not write evidence outside the canonical scheme.** All evidence for this cycle goes to `docs/features/active/2026-08-31-portable-prepared-orchestration-handoff-614/evidence/<kind>/`. `artifacts/baselines/`, `artifacts/baseline/`, `artifacts/qa/`, `artifacts/qa-gates/`, `artifacts/evidence/`, `artifacts/coverage/`, `artifacts/regression-testing/`, and `artifacts/post-change/` are forbidden.
- **Do not add a dependency.** The handoff surface uses only standard-library modules on the Python side and existing project dependencies on the TypeScript side.
- **Do not expand scope into #467 or #543.** AC15 and US13 depend on this branch changing neither the Codex-native parallel scheduling surface nor the epic-planner ready gate. Do not add a `parallel-*` skill or agent file and do not modify `scripts/dev_tools/validate_epic_planner_state.py`.
- **Do not silently skip a verification step.** If a listed verification command cannot run, record the reason in the cycle evidence rather than omitting the step.

---

## Handoff Note

Under `.claude/skills/remediation-handoff-atomic-planner/SKILL.md`, the remediation plan is authored by `atomic-planner`, not by `feature-review`. This agent produces the remediation inputs only. If the orchestrator elects to run a remediation cycle, it should delegate plan authoring to `atomic-planner` with these inputs and the three audit artifacts inlined in the delegation prompt, then route the resulting plan through `atomic-executor` preflight before execution.

Because `blocking_count` is 0 for this cycle, the orchestrator may instead set `exit_condition_met = true`, proceed to pull-request authoring, and carry R8 through R15 as follow-up work. That choice is the orchestrator's, not this reviewer's. If the pull request proceeds first, R8 and R9 should still be scheduled promptly: both are guards against future Python-versus-TypeScript divergence, which is the exact failure class this feature was built to eliminate, and both are the same class as the R1 and R2 items the previous cycle already judged worth remediating.
