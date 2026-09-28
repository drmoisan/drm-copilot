# Remediation Inputs: Portable Prepared Orchestration Handoff (Issue #614)

**Cycle entry timestamp:** 2026-09-06T23-30
**Author:** feature-review
**Feature Folder:** `docs/features/active/2026-08-31-portable-prepared-orchestration-handoff-614`
**Base Branch:** `main`, resolved to `origin/main @ 0542c92a7c589cfe952a0dfd480223960fd1eb33`
**Head Branch:** `feature/portable-prepared-orchestration-handoff-614 @ a7b80f2df6d849aa65de416655fa58beb4412998`
**Merge Base:** `1ed0964045febbb4d92f1cb92661d4b945153a40`

## Source Audit Artifacts

These remediation inputs are derived from, and must be read alongside, the three audit artifacts produced in the same cycle:

- `docs/features/active/2026-08-31-portable-prepared-orchestration-handoff-614/policy-audit.2026-09-06T23-30.md`
- `docs/features/active/2026-08-31-portable-prepared-orchestration-handoff-614/code-review.2026-09-06T23-30.md`
- `docs/features/active/2026-08-31-portable-prepared-orchestration-handoff-614/feature-audit.2026-09-06T23-30.md`

## Blocking Status

**Blocking findings: 0.**

Every mandatory gate is green on the branch head. All seven toolchain stages pass, all three coverage languages exceed the uniform 85% line and, where applicable, 75% branch thresholds repo-wide, on changed lines, and per changed file, no evidence-location or coverage-exclusion violation exists, and 27 of the 28 acceptance criteria are fully verified with the twenty-eighth PARTIAL on a test-verification sub-clause that holds by construction.

This cycle therefore does not gate the pull request. The items below are remediation-required in the sense that they close identified policy gaps under `.claude/rules/general-unit-test.md`, but none blocks the merge. If the orchestrator is evaluating the remediation-loop exit gate, `blocking_count` is 0 and `exit_condition_met` may be set.

## Priority Ordering

Items R1 and R2 are the two that matter. Both are cross-runtime drift guards: the Python and TypeScript implementations of the same contract are bound to the shared registry and exercised for negative behavior in one direction only. A feature whose stated purpose is to keep two ecosystems in agreement should not ship with a one-sided parity gate. Items R3 through R7 are ordinary follow-up work.

---

## Enumerated Fix List

### R1 — Cover the Python destination-projection integrity guard (Major)

- **File:** `scripts/dev_tools/orchestration_handoff_adapters.py`, lines 191-216
- **Test file to change:** `tests/scripts/dev_tools/test_orchestration_handoff_adapters.py`
- **Current state:** All five rejection branches of `_validate_projection_facts` are unexercised. The uncovered lines are 196, 198, 202, 210, and 215. The function is invoked from both provider adapters at lines 330 and 404. Its TypeScript counterpart in `orchestration-handoff-provider-adapters.ts` reaches 99.27% line and 95.65% branch coverage.
- **Expected behavior after remediation:** Each of the five rejections raises `HandoffContractError` with the documented field name and is asserted by a dedicated test:
  1. `facts.plan != envelope.plan` raises with field `projection.plan`
  2. `facts.lifecycle != envelope.lifecycle` raises with field `projection.lifecycle`
  3. `facts.scheduler_context != envelope.scheduler_context` raises with field `projection.scheduler_context`
  4. A non-SHA-256 `envelope_sha256` or `history_entry_sha256` raises with field `projection.envelope_sha256` or `projection.history_entry_sha256`
  5. `facts.history_entry_sha256` differing from `envelope.handoff_history[-1].entry_sha256` raises with field `projection.history_entry_sha256`
- **Verification commands:**
  - `poetry run pytest tests/scripts/dev_tools/test_orchestration_handoff_adapters.py -q`
  - `poetry run pytest --cov=scripts/dev_tools --cov-branch --cov-report=term-missing tests/scripts/dev_tools/test_orchestration_handoff_adapters.py`
  - Confirm lines 196, 198, 202, 210, and 215 no longer appear as uncovered in `artifacts/python/lcov.info`
- **Policy basis:** `.claude/rules/general-unit-test.md`, Scenario Completeness — negative flows for invalid inputs and error-handling behavior are required per unit; untested critical behavior is not acceptable even when the percentage looks good.
- **Acceptance criteria affected:** spec AC4, spec AC5, user-story US3 (all currently PASS; this closes the durability gap, not a behavioral gap)

### R2 — Bind the Python failure precedence to the shared registry (Major)

- **File:** `scripts/dev_tools/orchestration_handoff_contract.py`, lines 67-76
- **Test file to change:** `tests/scripts/dev_tools/test_orchestration_handoff_contract.py`
- **Current state:** `FAILURE_PRECEDENCE` restates the sixteen-entry `failure_precedence` array from `config/orchestration-handoff-registry.json` as a Python literal with no parity assertion. TypeScript asserts `expect(HANDOFF_FAILURE_PRECEDENCE).toEqual(registry["failure_precedence"])` at `extensions/drm-copilot/test/lib/validate/orchestration-handoff-contract.test.ts` line 267. The Python suites load the registry only for `capabilities.supported`, at `test_orchestration_handoff_contract.py` line 28 and `test_orchestration_handoff_versions.py` line 31.
- **Expected behavior after remediation:** A Python test asserts `orchestration_handoff_contract.FAILURE_PRECEDENCE == tuple(REGISTRY["failure_precedence"])`, so an edit to either the registry or the Python literal that breaks agreement fails the suite. The assertion must compare the full ordered sequence, not set membership, because the ordering is the contract.
- **Verification commands:**
  - `poetry run pytest tests/scripts/dev_tools/test_orchestration_handoff_contract.py -q`
  - Sanity check that the assertion is load-bearing: temporarily reorder two entries in the Python literal, confirm the new test fails, then revert
- **Policy basis:** `.claude/rules/general-code-change.md`, Reusability — avoid copy-paste and share behavior through a single source of truth. The registry is the declared single source; only one of two runtimes is bound to it.
- **Acceptance criteria affected:** spec AC11, user-story US10 (both currently PASS; this closes the divergence risk)

### R3 — Cover the materialization recovery branches (Minor)

- **File:** `extensions/drm-copilot/src/lib/validate/orchestration-handoff-materializer.ts`, lines 340-434
- **Test file to change:** `extensions/drm-copilot/test/lib/validate/orchestration-handoff-materializer.test.ts`
- **Current state:** `stageMaterialization` has one success-path test. Uncovered lines are 358-363, 392-398, and 411-424, which are five distinct recovery branches: pre-existing archive whose digest matches the expected source, pre-existing archive whose digest differs, pre-existing candidate whose digest matches or differs, candidate re-read or re-validation failure including its cleanup attempt, and atomic-replace failure.
- **Expected behavior after remediation:** Each branch is driven through the injected `HandoffFileSystemBoundary` and asserted on three points: the returned `primaryFailureCode`, the reported `affectedPaths`, and that `status` is never `materialized`. Specifically:
  - Pre-existing archive with a matching digest proceeds rather than failing (idempotent retry)
  - Pre-existing archive with a differing digest returns `HANDOFF_SOURCE_HASH_MISMATCH` with the archive path in `affectedPaths`
  - Pre-existing candidate with a differing digest returns `HANDOFF_VALIDATOR_UNAVAILABLE` with the candidate path in `affectedPaths`
  - Candidate re-validation failure removes the candidate and returns `HANDOFF_VALIDATOR_UNAVAILABLE`
  - Atomic-replace failure returns `HANDOFF_VALIDATOR_UNAVAILABLE` and leaves the source checkpoint unread and unwritten
- **Additional correction in the same area:** The candidate re-validation failure path at lines 411-424 attempts `removeFile` on the candidate and carries a comment about naming the retained candidate for explicit cleanup. The adjacent `replaceFile` failure path at lines 427-433 makes no cleanup attempt and reports `destinationPath` rather than the retained candidate path, so an operator recovering from a failed rename is not told which file to delete. Make the two adjacent paths agree on the recovery contract.
- **Verification commands:**
  - `cd extensions/drm-copilot && node run-jest.cjs --testPathPattern "orchestration-handoff-materializer"`
  - `cd extensions/drm-copilot && npm run test:coverage`, then confirm lines 358-363, 392-398, and 411-424 no longer appear as uncovered in `extensions/drm-copilot/coverage/lcov.info`
- **Policy basis:** `.claude/rules/general-unit-test.md`, Scenario Completeness — error-handling behavior must be covered.
- **Acceptance criteria affected:** spec AC10 (currently PARTIAL). Re-check AC10 to `- [x]` in `spec.md` only after these tests exist and pass.

### R4 — Bring the hook registry load inside its error contract and cover its failures (Minor)

- **File:** `.codex/hooks/enforce-epic-planning-only.ps1`, lines 85-88, with the validating function at lines 57-78
- **Published copy that must stay byte-identical:** `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/enforce-epic-planning-only.ps1`
- **Test file to change:** `tests/scripts/codex-hooks/epic-execution-gates.Tests.ps1`
- **Current state:** `$script:AllowedPreparationSemanticMcpTools = @(Get-EpicPlanningRegisteredMcpTool ...)` executes at script scope, above both the dot-source guard at line 315 and the top-level `try` at line 319. A missing or malformed `config/orchestration-handoff-registry.json` therefore raises an unhandled terminating error instead of the hook's contracted `exit 2` with a stderr reason, and it also makes the file impossible to dot-source for testing in that state. All four validation `throw` statements at lines 58, 67, 72, and 77 are unexercised, and they are the only uncovered changed PowerShell lines on the branch.
- **Expected behavior after remediation:** A missing registry, an unregistered semantic id, a mismatched `operation` field, and a malformed transport alias each produce the hook's standard failure contract: the `EPIC_PLANNING_ONLY_BLOCKED:` prefixed reason written to stderr and exit code 2. Dot-sourcing the file continues to work regardless of registry state, so the existing dot-source-based tests remain usable.
- **Implementation note:** Either move the resolution inside the existing top-level `try` block, or wrap it in its own `try`/`catch` that writes the message to stderr and exits 2. If the resolution moves below the dot-source guard, confirm that no function referencing `$script:AllowedPreparationSemanticMcpTools` is invoked during dot-sourcing.
- **Verification commands:**
  - `mcp__drm-copilot__run_poshqc_test` (scoped to `tests/scripts/codex-hooks`)
  - `mcp__drm-copilot__run_poshqc_analyze`
  - `poetry run pytest tests/scripts/dev_tools/test_push_down_codex_and_agents_customizations.py -q` to confirm the published copy remains byte-identical
  - Confirm lines 58, 67, 72, and 77 no longer appear as uncovered in `artifacts/pester/powershell-coverage.xml`
- **Policy basis:** `.claude/rules/general-code-change.md`, Error Handling — fail fast and explicitly, and do not let an invariant violation escape the module's declared failure contract. `.claude/rules/general-unit-test.md`, Scenario Completeness.
- **Acceptance criteria affected:** spec AC7, user-story US6 (both currently PASS; the behavior under a correctly installed registry is unaffected)

### R5 — Make the materializer error narrowing sound (Minor)

- **File:** `extensions/drm-copilot/src/lib/validate/orchestration-handoff-materializer.ts`, line 276
- **Current state:** `error instanceof Error && "code" in error ? (error.code as HandoffFailureCode) : "HANDOFF_VALIDATOR_UNAVAILABLE"` narrows on the mere presence of a `code` property and then asserts an unvalidated value into the failure-code union. A Node `ErrnoException` carrying `"ENOENT"` satisfies that guard, and callers route on this field.
- **Expected behavior after remediation:** The narrowing uses `error instanceof HandoffContractError`, whose `code` is already declared `HandoffFailureCode` at `orchestration-handoff-contract-support.ts` line 129, and falls back to `HANDOFF_VALIDATOR_UNAVAILABLE` for every other error. No unvalidated string can enter the result contract.
- **Verification commands:**
  - `cd extensions/drm-copilot && npm run typecheck`
  - `cd extensions/drm-copilot && npm run lint`
  - `cd extensions/drm-copilot && node run-jest.cjs --testPathPattern "orchestration-handoff"`
- **Policy basis:** `.claude/rules/typescript.md` and `.claude/rules/general-code-change.md` — the public result contract is the routing surface for every consumer; values outside a declared union must not enter it unchecked.
- **Acceptance criteria affected:** None directly. This hardens the failure-code contract that AC11 and US10 depend on.

### R6 — Preserve the cause behind `HANDOFF_VALIDATOR_UNAVAILABLE` (Minor)

- **File:** `extensions/drm-copilot/src/lib/validate/orchestration-handoff-materializer.ts`, 11 `catch` blocks across `prepare` and `stageMaterialization`
- **Current state:** Every caught error is discarded without logging, and `HANDOFF_VALIDATOR_UNAVAILABLE` is returned for at least six distinct causes: source or envelope read failure, UTF-8 decode failure, destination-projection validation failure, Git porcelain read failure, candidate write or re-read failure, and atomic replace failure. An operator receiving that code cannot distinguish a filesystem permission error from a genuine validator defect.
- **Expected behavior after remediation:** Either the caught cause is logged at `warning` through the project's established logging pattern, or the result carries an optional `diagnostic` string alongside the failure code. If the result shape changes, the change is additive and optional so no existing consumer breaks, and the schema and both runtime contracts stay in agreement.
- **Constraint:** Do not change which failure code is returned for any condition. The deterministic code selection is contract behavior asserted by tests in four runtimes; only the diagnostic detail may be added.
- **Verification commands:**
  - `cd extensions/drm-copilot && node run-jest.cjs --testPathPattern "orchestration-handoff"`
  - `poetry run pytest tests/scripts/dev_tools/test_orchestration_handoff_contract.py -q` to confirm the contract surface is unchanged
- **Policy basis:** `.claude/rules/general-code-change.md`, Error Handling — do not use broad catch-all handlers unless you immediately re-raise or propagate with added context.
- **Acceptance criteria affected:** None. This is a diagnosability improvement.

### R7 — Close the three remaining low-severity gaps (Nit)

- **R7a — Register the new modules in the coverage gate.** `extensions/drm-copilot/jest.config.cjs` has no `global` key, so the per-file `coverageThreshold` map is the only enforcement mechanism. The branch adds fifteen `src/**` production modules and registers none of them; the config file is unmodified on this branch. Add `{ lines: 85, branches: 75 }` entries for each, following the existing per-file convention already applied to 45 other modules. Do not add an entry for `src/repo-automation-service-contract.ts`; it is interface-only and its omission is already documented at lines 170-177 and 261-266. Verify with `cd extensions/drm-copilot && npm run test:coverage` and confirm the run still exits 0.
- **R7b — Replace the split-string contract tuples.** `scripts/dev_tools/orchestration_handoff_contract.py` lines 43-46 and 67-76 build `PHASE_ORDER` and `FAILURE_PRECEDENCE` by calling `.split()` on implicitly concatenated multi-line string literals, where each continuation depends on a trailing space inside the preceding literal. A dropped space silently merges two contract tokens rather than raising. Replace both with explicit tuples of quoted strings, one token per line. This also makes R2's parity assertion easier to read. Verify with `poetry run pytest tests/scripts/dev_tools/ -q` and `poetry run black --check .`.
- **R7c — Cover the already-migrated legacy guard.** `scripts/dev_tools/orchestration_handoff_contract_support.py` line 77, `raise HandoffContractError("legacy.checkpoint", "is invalid")`, is unexercised while the adjacent guards at lines 79 and 83 are covered. Add one test passing an object that already carries `schema_version`. Verify with `poetry run pytest tests/scripts/dev_tools/test_orchestration_handoff_versions.py -q`.

---

## Acceptance Criteria Re-check Instruction

`spec.md` AC10 was changed from `- [x]` to `- [ ]` by this audit following a PARTIAL evaluation. Re-check it to `- [x]` only after R3 lands and its tests pass. Do not re-check it as part of any other item.

No other acceptance criterion changed state. The remaining 14 `spec.md` criteria and all 13 `user-story.md` criteria are checked and confirmed PASS.

---

## Do Not Do

- **Do not narrow the audit scope.** The scope of any remediation plan derived from these inputs is the branch diff against `1ed0964045febbb4d92f1cb92661d4b945153a40`, not a subset of it. Do not mark any language's coverage `N/A`, "plan scope only", "informational only", or "out of scope" when that language has changed files in the branch diff. PowerShell has two changed production files and requires an explicit PASS or FAIL verdict with a computed changed-line figure. The executor's `fr-614-005-coverage-comparison.2026-09-03T00-07.md` record contains exactly this narrowing for PowerShell; it is rejected in `policy-audit.2026-09-06T23-30.md` and must not be repeated.
- **Do not weaken any policy.** Do not add a `coverageThreshold` entry below `lines: 85, branches: 75`. Do not add a `coveragePathIgnorePatterns` entry, and do not add any `exclude` entry that matches a path under `src/`. Do not lower a threshold to make a file pass.
- **Do not exclude a production file from coverage measurement.** `src/repo-automation-service-contract.ts` reports 0% because it is interface-only; it stays inside `collectCoverageFrom`. Excluding it would convert a documented and permitted 0% into a prohibited exclusion.
- **Do not change which failure code any condition returns.** The deterministic `HANDOFF_*` selection is asserted in Python, TypeScript, MCP, and hook tests. R6 may add diagnostic detail; it may not reallocate codes.
- **Do not modify the committed fixtures.** All four pinned digests under `tests/fixtures/orchestration-handoff/taskmaster-469/` were independently verified against the committed blobs at `a7b80f2d`. Do not regenerate, reformat, or re-serialize any fixture file, and do not remove the two `.gitattributes` entries that disable EOL normalization for the fixture plan files. A byte change to any of them breaks AC2, AC3, and AC13 and was already the subject of an earlier repair in this feature.
- **Do not create or use temporary files in tests.** The added suites are currently free of `tmp_path`, `TemporaryDirectory`, `NamedTemporaryFile`, and `os.tmpdir`. Drive filesystem behavior through the injected `HandoffFileSystemBoundary` instead.
- **Do not write evidence outside the canonical scheme.** All evidence for this cycle goes to `docs/features/active/2026-08-31-portable-prepared-orchestration-handoff-614/evidence/<kind>/`. `artifacts/baselines/`, `artifacts/qa/`, `artifacts/evidence/`, and `artifacts/coverage/` are forbidden.
- **Do not add a dependency.** The handoff surface uses only standard-library modules on the Python side and existing project dependencies on the TypeScript side.
- **Do not expand scope into #467 or #543.** AC15 and US13 depend on this branch changing neither the Codex-native parallel scheduling surface nor the epic-planner ready gate. Do not add a `parallel-*` skill or agent file and do not modify `scripts/dev_tools/validate_epic_planner_state.py`.
- **Do not silently skip a verification step.** If a listed verification command cannot run, record the reason in the cycle evidence rather than omitting the step.

---

## Handoff Note

Under `.claude/skills/remediation-handoff-atomic-planner/SKILL.md`, the remediation plan is authored by `atomic-planner`, not by `feature-review`. This agent produces the remediation inputs only. The orchestrator should delegate plan authoring to `atomic-planner` with these inputs and the three audit artifacts inlined in the delegation prompt, then route the resulting plan through `atomic-executor` preflight before execution.

Because `blocking_count` is 0 for this cycle, the orchestrator may alternatively set `exit_condition_met = true`, proceed to pull-request authoring, and carry R1 through R7 as follow-up work. That choice is the orchestrator's, not this reviewer's. If the pull request proceeds first, R1 and R2 should still be scheduled promptly: both are guards against future Python-versus-TypeScript divergence, which is the exact failure class this feature was built to eliminate.
