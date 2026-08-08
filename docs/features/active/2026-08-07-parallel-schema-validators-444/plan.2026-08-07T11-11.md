# 2026-08-07-parallel-schema-validators - Plan

- **Issue:** #444
- **Parent (optional):** `parallel-orchestration` epic (child feature F3, wave 1)
- **Owner:** drmoisan
- **Last Updated:** 2026-08-07T13-40
- **Status:** Ready for Preflight (revision 2)
- **Version:** 1.2
- **Work Mode:** full-feature (AC sources: `spec.md` and `user-story.md`)

## Required References

- General Coding Standards: [`.github/instructions/general-code-change.instructions.md`](../../../../.github/instructions/general-code-change.instructions.md)
- General Unit Test Policy: [`.github/instructions/general-unit-test.instructions.md`](../../../../.github/instructions/general-unit-test.instructions.md)
- Python policy: `.claude/rules/python.md`, `.claude/rules/python-suppressions.md`, `.claude/rules/self-explanatory-code-commenting.md`
- TypeScript policy: `.claude/rules/typescript.md`, `.claude/rules/typescript-suppressions.md`
- Enforcement precedent: `.claude/rules/orchestrator-state.md`
- Authoritative requirements: `docs/features/active/2026-08-07-parallel-schema-validators-444/spec.md` (schemas S1-S8, invariants 1-21 / P1-P9 / M1-M7, assumptions A1-A8), `docs/features/active/2026-08-07-parallel-schema-validators-444/user-story.md`
- Research: `docs/features/active/2026-08-07-parallel-schema-validators-444/research/2026-08-07T12-00-parallel-schema-validators-research.md`; design `docs/research/2026-08-07-parallel-orchestration-design-research.md` sections 11-12; epic `docs/features/epics/parallel-orchestration/epic.md`

**All work must comply with these policies; do not duplicate their content here.**

## Plan Conventions

- Evidence root (canonical, non-overridable): `docs/features/active/2026-08-07-parallel-schema-validators-444/evidence/`. Baseline evidence goes to `evidence/baseline/`; final-QC evidence goes to `evidence/qa-gates/`; other verification evidence goes to `evidence/other/`. No `artifacts/`-rooted evidence path is permitted.
- `<ts>` in artifact filenames denotes the execution-time ISO-8601 timestamp `yyyy-MM-ddTHH-mm`.
- Every command-step evidence artifact must record `Timestamp:`, `Command:`, `EXIT_CODE:`, and `Output Summary:`. Test-step artifacts must record numeric line and branch coverage in `Output Summary:`.
- Python commands run from the repository root. TypeScript commands run from `extensions/drm-copilot/`.
- Final-QC command tasks are unconditional. `EXIT_CODE: SKIPPED` is not a valid outcome for any command task in this plan unless the task text itself authorizes a branch.
- Non-negotiable design constraints enforced throughout: no `depends_on` field anywhere (ordering is blast-radius overlap); `issue_num` is the primary key; no integration branch and no `integration_branch` / `epic_merge_pr` fields; `mode` defaults to `closed` and `max_concurrency` defaults to 4 (bound 1..8 per A7); the checkpoint is a cache re-derivable from `git worktree list --porcelain`, `git branch`, and `gh pr view --json state,mergedAt,headRefOid`; no JSON Schema file is authored or imported; the epic validators are not modified; no production or test file exceeds 500 lines; tests live under `tests/scripts/dev_tools/` (Pytest) and `extensions/drm-copilot/test/` (Jest), never colocated.
- Acceptance-criteria tracking follows `.claude/skills/acceptance-criteria-tracking/SKILL.md`: check off each satisfied AC in BOTH `spec.md` and `user-story.md` as soon as the delivering task passes verification. The mapping is in "Acceptance Criteria Mapping" below.
- Modified (not created) files in scope: `scripts/dev_tools/validate_orchestration_artifacts.py`, `config/orchestration-routing.json`, `extensions/drm-copilot/resources/config/orchestration-routing.json`, `extensions/drm-copilot/src/mcp-tool-inputs.ts`, `extensions/drm-copilot/src/mcp-tool-definitions.ts`, `extensions/drm-copilot/src/mcp-repo-automation-tool-definitions.ts`, `extensions/drm-copilot/src/lib/validate/orchestration-artifacts.ts`, and `extensions/drm-copilot/jest.config.cjs`. No other existing file is modified.

## Implementation Plan (Atomic Tasks)

### Phase 0 — Compliance and Baseline Capture

- [x] [P0-T1] Read the policy files in this order: `CLAUDE.md`, `.claude/rules/general-code-change.md`, `.claude/rules/general-unit-test.md`, `.claude/rules/python.md`, `.claude/rules/python-suppressions.md`, `.claude/rules/typescript.md`, `.claude/rules/typescript-suppressions.md`, `.claude/rules/self-explanatory-code-commenting.md`, `.claude/rules/orchestrator-state.md`, `.claude/rules/quality-tiers.md`, then write the read receipt
  - Acceptance: `docs/features/active/2026-08-07-parallel-schema-validators-444/evidence/baseline/phase0-instructions-read.md` exists with `Timestamp:`, `Policy Order:`, and the explicit list of files read
- [x] [P0-T2] Capture the Python formatting baseline by running `poetry run black --check .` from the repository root
  - Acceptance: `docs/features/active/2026-08-07-parallel-schema-validators-444/evidence/baseline/python-format-baseline.<ts>.md` exists with `Timestamp:`, `Command:`, `EXIT_CODE:`, `Output Summary:`
- [x] [P0-T3] Capture the Python lint baseline by running `poetry run ruff check --no-fix .` from the repository root (the `--no-fix` flag is required because `pyproject.toml` sets `[tool.ruff] fix = true`, which would otherwise mutate the tree during baseline capture), followed by `git status --porcelain` to confirm no file changed
  - Acceptance: `docs/features/active/2026-08-07-parallel-schema-validators-444/evidence/baseline/python-lint-baseline.<ts>.md` exists with all four required fields; `Output Summary:` records the diagnostic count and a changed-file count of 0
- [x] [P0-T4] Capture the Python type-check baseline by running `poetry run pyright` from the repository root
  - Acceptance: `docs/features/active/2026-08-07-parallel-schema-validators-444/evidence/baseline/python-typecheck-baseline.<ts>.md` exists with all four required fields
- [x] [P0-T5] Capture the Python coverage-enabled test baseline by running `poetry run pytest --cov --cov-branch --cov-report=term-missing` from the repository root
  - Acceptance: `docs/features/active/2026-08-07-parallel-schema-validators-444/evidence/baseline/python-test-coverage-baseline.<ts>.md` exists with all four required fields and numeric baseline line and branch coverage percentages in `Output Summary:`
- [x] [P0-T6] Capture the TypeScript formatting baseline by running `npm run format` in `extensions/drm-copilot/` followed by `git status --porcelain` to record whether any files changed
  - Acceptance: `docs/features/active/2026-08-07-parallel-schema-validators-444/evidence/baseline/ts-format-baseline.<ts>.md` exists with all four required fields; `Output Summary:` records the changed-file count (expected 0 on a clean baseline)
- [x] [P0-T7] Capture the TypeScript lint baseline by running `npm run lint` in `extensions/drm-copilot/`
  - Acceptance: `docs/features/active/2026-08-07-parallel-schema-validators-444/evidence/baseline/ts-lint-baseline.<ts>.md` exists with all four required fields
- [x] [P0-T8] Capture the TypeScript type-check baseline by running `npm run typecheck` in `extensions/drm-copilot/`
  - Acceptance: `docs/features/active/2026-08-07-parallel-schema-validators-444/evidence/baseline/ts-typecheck-baseline.<ts>.md` exists with all four required fields
- [x] [P0-T9] Capture the TypeScript coverage-enabled test baseline by running `npm run test:coverage` in `extensions/drm-copilot/`
  - Acceptance: `docs/features/active/2026-08-07-parallel-schema-validators-444/evidence/baseline/ts-test-coverage-baseline.<ts>.md` exists with all four required fields and numeric baseline line and branch coverage percentages in `Output Summary:`
- [x] [P0-T10] Record the observed state of `quality-tiers.yml` at the repository root (present or absent) for risk R3 reconciliation in Phase 6
  - Acceptance: `docs/features/active/2026-08-07-parallel-schema-validators-444/evidence/baseline/quality-tiers-observed.<ts>.md` exists with `Timestamp:` and an explicit present/absent statement including the checked path

### Phase 1 — Python Orchestrator Checkpoint Validator

- [x] [P1-T1] Create `scripts/dev_tools/_parallel_state_common.py` with the nine S4 enum constants (`VALID_ITEM_STATES` 8 values, `VALID_MERGE_STATUS` 8 values, `VALID_SOURCES` 3, `VALID_KINDS` 2, `VALID_MODES` 2, `VALID_MUTATION_OPS` 4, `VALID_DISPOSITIONS` detach/abandon, `VALID_EDGE_REASONS` 4, `VALID_DRIFT_ACTIONS` 2) plus shared non-empty-string and positive-integer (non-boolean) helpers
  - Acceptance: module imports cleanly; constants carry exactly the spec S4 member sets; full docstrings per commenting policy
- [x] [P1-T2] Implement the `blast_radius` block validator in `scripts/dev_tools/_parallel_state_common.py` enforcing spec invariant 9 (four list-of-non-empty-string fields, `source` enum, non-empty `computed_at`), emitting `Parallel checkpoint`-prefixed error strings parameterized by a caller-supplied context prefix
  - Acceptance: function returns one literal error string per violated condition and an empty list for a valid block
- [x] [P1-T3] Implement the item-shape validator in `scripts/dev_tools/_parallel_state_common.py` enforcing spec invariants 5-8 (`issue_num` positive-int uniqueness, non-empty `feature_folder`, item `state` enum, optional `merge_status` enum, state/merge-status consistency)
  - Acceptance: each malformed condition yields a distinct error string naming the offending item; absent `merge_status` yields zero errors
- [x] [P1-T4] Implement the prohibited-key scanner in `scripts/dev_tools/_parallel_state_common.py` rejecting `depends_on` at any nesting level and `integration_branch` / `epic_merge_pr` at any level (spec invariants 10-11), reusable by all three validators
  - Acceptance: scanner walks arbitrarily nested dicts/lists and returns one error per prohibited key found; clean input returns an empty list
- [x] [P1-T5] Create `scripts/dev_tools/_parallel_state_structures.py` with the `cohorts[]` validators enforcing spec invariants 12-14 (shape and key resolution; current-generation index uniqueness and exactly-one coverage of every non-withdrawn/non-terminal item; `current_cohort` bound)
  - Acceptance: each invariant-12/13/14 malformed condition yields a distinct error; an item absent from all current-generation cohorts is accepted only in state `withdrawn`, `merged`, or `blocked`
- [x] [P1-T6] Implement the `conflict_edges[]` validator in `scripts/dev_tools/_parallel_state_structures.py` enforcing spec invariant 15 / S7 (distinct resolving endpoints, `a < b` normalization, duplicate-pair rejection, reason enum)
  - Acceptance: self-edge, unresolved endpoint, unnormalized pair, duplicate pair, and out-of-enum reason each yield a distinct error
- [x] [P1-T7] Implement the `mutations[]` validator in `scripts/dev_tools/_parallel_state_structures.py` enforcing spec invariants 16-17 / S5 (op enum; op-specific null rules for `item_key`, `prior_state`, `new_state`; non-empty `at`; in-flight-removal `detach`/`abandon` disposition rule; null disposition elsewhere; `recolor_generation` non-negative and `<=` top-level)
  - Acceptance: every S5 table row and both invariant-17 branches are enforced with distinct errors; state-transition legality is deliberately not checked (F6 scope)
- [x] [P1-T8] Implement the `drift_events[]` validator (spec invariant 18 / S6: resolving `item_key`, list-of-non-empty-string `declared`/`observed`, non-empty `escaped_paths`, non-empty `at`, action enum) and the receipt-array list-type checks (invariant 19) in `scripts/dev_tools/_parallel_state_structures.py`
  - Acceptance: each S6 condition yields a distinct error; absent receipt arrays yield zero errors; non-list receipt values yield one error each
- [x] [P1-T9] Create `scripts/dev_tools/validate_parallel_orchestrator_state.py` exposing `validate_parallel_orchestrator_state_text(text: str, *, require_complete: bool = False) -> list[str]`: invalid-JSON single-element list, non-object-root rejection, required-key check (spec invariant 1, one error per missing key), `route_id == 'parallel'`, mode enum, bounded concurrency 1..8 non-boolean (invariants 2-4), and orchestration of the Phase 1 helper validators, all with the `Parallel checkpoint` error prefix
  - Acceptance: valid checkpoint returns `[]`; the validator never mutates its input; absolute imports; file at or under 500 lines
- [x] [P1-T10] Implement the mode-dependent completion gate in `scripts/dev_tools/validate_parallel_orchestrator_state.py` (spec invariants 20-21), active only under `require_complete`: closed mode requires every non-withdrawn item to have `merge_status` in `{merged, worktree_removed}`; open mode additionally requires a `mutations[]` entry with `op == 'close'`
  - Acceptance: gate contributes zero errors when `require_complete` is False; both mode branches and the withdrawn-item exemption are enforced
- [x] [P1-T11] Add the clearly delimited, appendable F7 helper-invocation block to the entry point of `scripts/dev_tools/validate_parallel_orchestrator_state.py`, documented in comments as the insertion seam for F7's Layer-2 cohort-ordering invariant (`PARALLEL_COHORT_BARRIER_VIOLATION`, design section 9 Layer 2) so F7's edit is one appended helper call with no reflow of existing code
  - Acceptance: the block is delimited by explicit begin/end comment markers naming F7 and the invariant token, and existing helper calls are outside the block
- [x] [P1-T12] Create `tests/scripts/dev_tools/test_validate_parallel_orchestrator_state.py` with a shared `build_valid_parallel_state()` builder and tests for spec invariants 1-11, 14, and 19, plus invalid-JSON, non-object-root, and absent-optional-receipts backward-compatibility cases, using `pytest.mark.parametrize` for enum-membership matrices and `json.dumps`-serialized dicts (no temp files)
  - Acceptance: file passes and stays at or under 500 lines; each invariant has a valid case and each malformed case
- [x] [P1-T13] Create `tests/scripts/dev_tools/test_validate_parallel_orchestrator_state_structures.py` covering spec invariants 12-13 and 15-18 (cohorts, conflict edges, mutations including the disposition rule, drift events), importing the builder from the sibling test module
  - Acceptance: file passes and stays at or under 500 lines; the exactly-one cohort-coverage rule, `a < b` normalization, duplicate-pair rejection, and all S5 null rules have explicit cases
- [x] [P1-T14] Create `tests/scripts/dev_tools/test_validate_parallel_orchestrator_state_completion.py` covering spec invariants 20-21: closed-mode completion pass/fail, open-mode close-mutation requirement, withdrawn-item exemption, and the gate-off default
  - Acceptance: file passes and stays at or under 500 lines
- [x] [P1-T15] Run `poetry run pytest tests/scripts/dev_tools/test_validate_parallel_orchestrator_state.py tests/scripts/dev_tools/test_validate_parallel_orchestrator_state_structures.py tests/scripts/dev_tools/test_validate_parallel_orchestrator_state_completion.py` and confirm a clean pass
  - Acceptance: exit code 0 with zero failures

### Phase 2 — Python Manifest Contract and Planner Checkpoint Validator

- [x] [P2-T1] Create `scripts/dev_tools/parallel_manifest_contract.py` with LF/CRLF/CR-tolerant frontmatter extraction (precedent commit `b845c505`) and the `validate_parallel_manifest_text(text: str) -> list[str]` entry enforcing spec invariants M1 (frontmatter block parseable by `yaml.safe_load` into a mapping), M2 (non-empty `parallel` slug), and M5 (non-empty `created_at`), with the `Parallel manifest` error prefix
  - Acceptance: missing, unterminated, unparseable, and non-mapping frontmatter each yield a single-element or per-condition error list; all three line-ending forms parse
- [x] [P2-T2] Implement spec invariants M3-M4 and the default-resolving accessors `manifest_mode(mapping) -> str` (returns `"closed"` when `mode` absent) and `manifest_max_concurrency(mapping) -> int` (returns `4` when absent) in `scripts/dev_tools/parallel_manifest_contract.py`, with present values validated against the `closed|open` enum and the 1..8 integer bound (A7)
  - Acceptance: absent keys yield zero validator errors and the documented defaults from the accessors; out-of-enum and out-of-range present values yield errors
- [x] [P2-T3] Implement spec invariants M6-M7 in `scripts/dev_tools/parallel_manifest_contract.py`: `items` list validation per the S1 item table (reusing the `_parallel_state_common` item and blast-radius validators, including `issue_num` uniqueness and `kind` enum) and prohibited-key rejection (`depends_on` at any level, `integration_branch` at top level)
  - Acceptance: each S1 item violation and each prohibited key yields a distinct error; an empty `items` list is valid; file at or under 500 lines
- [x] [P2-T4] Create `scripts/dev_tools/validate_parallel_planner_state.py` exposing `validate_parallel_planner_state_text(text: str, *, require_ready_for_execution: bool = False) -> list[str]` enforcing spec invariants P1-P4 with the `Parallel planner checkpoint` error prefix: the S3 required top-level keys, non-empty `parallel_slug` / `parallel_manifest_path`, mode and concurrency checks, per-item required keys (`issue_num`, `feature_folder`, `kind`, `state`, `blast_radius`, `preparation_status`, `research_path`, `plan_path`, `preflight_status`), optional `complexity_band` in C1..C4, prohibited keys, and cohort/edge/`recolor_generation` checks via the Phase 1 helper modules
  - Acceptance: valid checkpoint returns `[]`; one error per missing key; recoloring recomputation is deliberately not performed (spec P5, F4 scope); file at or under 500 lines
- [x] [P2-T5] Implement the structural ready gate (spec invariants P6-P9) in `scripts/dev_tools/validate_parallel_planner_state.py`, active only under `require_ready_for_execution`: at least two items; per-item `preparation_status == 'prepared'`, `preflight_status == 'PREFLIGHT: ALL CLEAR'`, non-empty `research_path` and `plan_path`, `blast_radius.source == 'declared'`; `next_step == 'PARALLEL_EXECUTION_READY'`; `kickoff_prompt_path` exactly `artifacts/orchestration/parallel-kickoff-<parallel_slug>.md` (A6)
  - Acceptance: gate contributes zero errors when the flag is False; each P6-P9 condition has a distinct error
- [x] [P2-T6] Create `tests/scripts/dev_tools/test_parallel_manifest_contract.py` covering M1-M7, CRLF and CR tolerance, both default accessors, `issue_num` uniqueness, blast-radius shape, and the `depends_on` / `integration_branch` rejections
  - Acceptance: file passes and stays at or under 500 lines; each manifest invariant has a valid case, each malformed case, and the absent-optional-key case
- [x] [P2-T7] Create `tests/scripts/dev_tools/test_validate_parallel_planner_state.py` covering P1-P4 and P6-P9 with a ready-gate positive case and per-field negative cases, including the sentinel and kickoff-path checks and the `complexity_band` enum
  - Acceptance: file passes and stays at or under 500 lines
- [x] [P2-T8] Run `poetry run pytest tests/scripts/dev_tools/test_parallel_manifest_contract.py tests/scripts/dev_tools/test_validate_parallel_planner_state.py` and confirm a clean pass
  - Acceptance: exit code 0 with zero failures

### Phase 3 — Python CLI Dispatch Wiring

- [x] [P3-T1] Update `scripts/dev_tools/validate_orchestration_artifacts.py` additively: register subparser `parallel-orchestrator-state` (with `--require-complete`) and subparser `parallel-planner-state` (with `--require-ready-for-execution`), add the two imports and two dispatch branches, and leave every existing artifact type and the `Unsupported artifact type: {type}` fallback byte-unchanged
  - Acceptance: both new types dispatch to the new validators; file remains at or under 500 lines; no existing subparser or branch is modified
- [x] [P3-T2] Create `tests/scripts/dev_tools/test_validate_orchestration_artifacts_parallel_dispatch.py` (a new file; the existing epic dispatch test is untouched) exercising both new subparsers and flags via monkeypatched `validator._read_text` and `validator.main([...])` exit codes, plus one explicit unknown-artifact-type failure case
  - Acceptance: file passes and stays at or under 500 lines; pass and fail exit codes asserted for both new types
- [x] [P3-T3] Run `poetry run pytest tests/scripts/dev_tools/test_validate_orchestration_artifacts_parallel_dispatch.py` and confirm a clean pass
  - Acceptance: exit code 0 with zero failures

### Phase 4 — TypeScript Validator Cores (Full-Parity Port)

- [x] [P4-T1] Create `extensions/drm-copilot/src/lib/validate/parallel-state-shared.ts` porting the `_parallel_state_common.py` enum constants and the item / blast-radius / prohibited-key validators with error strings byte-identical to the Python source
  - Acceptance: exported constants and functions mirror the Python module; file at or under 500 lines; no new runtime dependencies
- [x] [P4-T2] Create `extensions/drm-copilot/src/lib/validate/parallel-state-structures.ts` porting the cohorts / conflict-edges / mutations / drift-events / receipt-array validators with error strings byte-identical to `_parallel_state_structures.py`
  - Acceptance: every invariant-12-19 error string matches the Python literal; file at or under 500 lines
- [x] [P4-T3] Create `extensions/drm-copilot/src/lib/validate/parallel-orchestrator-state-core.ts` exposing `validateParallelOrchestratorStateText(text, options)` mirroring spec invariants 1-21 (completion gate behind `requireComplete`) with byte-identical error strings, including a comment-delimited F7 seam matching the Python entry point
  - Acceptance: valid checkpoint returns an empty array; file at or under 500 lines
- [x] [P4-T4] Create `extensions/drm-copilot/src/lib/validate/parallel-planner-state-core.ts` exposing `validateParallelPlannerStateText(text, options)` mirroring spec invariants P1-P4 and P6-P9 (ready gate behind `requireReadyForExecution`) with byte-identical error strings
  - Acceptance: valid checkpoint returns an empty array; file at or under 500 lines
- [x] [P4-T5] Create `extensions/drm-copilot/test/lib/validate/parallel-state-test-support.ts` (a non-`.test.ts` support module, matching the established `epic-planner-launch-evidence-test-support.ts` convention, so it is not collected by `testMatch` and adds no Jest suite) exporting `buildValidParallelState()` returning a minimally valid parallel-orchestrator checkpoint object for mutation by the Phase 4 test files
  - Acceptance: module is not collected as a test suite; file at or under 500 lines; the returned object validates with zero errors through `validateParallelOrchestratorStateText`
- [x] [P4-T6] Create `extensions/drm-copilot/test/lib/validate/parallel-orchestrator-state-core.test.ts` importing `buildValidParallelState()` from `./parallel-state-test-support` and covering spec invariants 1-11, 14, and 19 plus invalid-JSON, non-object-root, and absent-optional-receipts cases, with the error-string literals asserted byte-identical to the Python source strings, using `it.each` for enum matrices
  - Acceptance: file passes and stays at or under 500 lines
- [x] [P4-T7] Create `extensions/drm-copilot/test/lib/validate/parallel-orchestrator-state-structures.test.ts` covering spec invariants 12-13 and 15-18 with byte-identical error-string assertions, importing `buildValidParallelState()` from `./parallel-state-test-support`
  - Acceptance: file passes and stays at or under 500 lines
- [x] [P4-T8] Create `extensions/drm-copilot/test/lib/validate/parallel-orchestrator-state-completion.test.ts` covering spec invariants 20-21 (closed-mode completion, open-mode close-mutation requirement, withdrawn-item exemption, gate-off default) with byte-identical error-string assertions, importing `buildValidParallelState()` from `./parallel-state-test-support`
  - Acceptance: file passes and stays at or under 500 lines
- [x] [P4-T9] Create `extensions/drm-copilot/test/lib/validate/parallel-planner-state-core.test.ts` mirroring P1-P9 with byte-identical error-string assertions
  - Acceptance: file passes and stays at or under 500 lines
- [x] [P4-T10] Run the four new Jest test files from `extensions/drm-copilot/` (`node run-jest.cjs test/lib/validate/parallel-orchestrator-state-core.test.ts test/lib/validate/parallel-orchestrator-state-structures.test.ts test/lib/validate/parallel-orchestrator-state-completion.test.ts test/lib/validate/parallel-planner-state-core.test.ts`) and confirm a clean pass
  - Acceptance: exit code 0 with zero failures

### Phase 5 — MCP Artifact-Type Wiring (TypeScript)

- [x] [P5-T1] Update `extensions/drm-copilot/src/mcp-tool-inputs.ts` to add `"parallel-orchestrator-state"` and `"parallel-planner-state"` to `VALID_ARTIFACT_TYPES`
  - Acceptance: both values resolve through `resolveValidateOrchestrationArtifactsToolInput`; unknown values still fail with the existing message prefix
- [x] [P5-T2] Update `extensions/drm-copilot/src/lib/validate/orchestration-artifacts.ts` with two new `switch` cases dispatching `parallel-orchestrator-state` and `parallel-planner-state` to the Phase 4 cores, threading the existing `requireComplete` and `requireReadyForExecution` flags; the default `Unsupported artifact type: {type}` branch is unchanged
  - Acceptance: both types validate through `validateArtifact`; no existing case is modified; file at or under 500 lines
- [x] [P5-T3] Update `extensions/drm-copilot/src/mcp-tool-definitions.ts` to add both values to the `artifact_type` enum and to extend the `require_complete` and `require_ready_for_execution` descriptions to name the parallel types
  - Acceptance: definition schema lists both new enum values with updated flag descriptions
- [x] [P5-T4] Update `extensions/drm-copilot/src/mcp-repo-automation-tool-definitions.ts` with the identical enum and description edits
  - Acceptance: both definition surfaces carry byte-identical `artifact_type` enum lists
- [x] [P5-T5] Add `coverageThreshold` entries (`lines: 85`, `branches: 75`) to `extensions/drm-copilot/jest.config.cjs` for `./src/lib/validate/parallel-state-shared.ts`, `./src/lib/validate/parallel-state-structures.ts`, `./src/lib/validate/parallel-orchestrator-state-core.ts`, and `./src/lib/validate/parallel-planner-state-core.ts`, matching the existing per-production-file gate convention; no existing entry is modified
  - Acceptance: all four entries are present; `npm run test:coverage` enforces the thresholds against the four new modules
- [x] [P5-T6] Create `extensions/drm-copilot/test/mcp-tool-inputs-parallel-validation.test.ts` with `it.each` over both new artifact types asserting input resolution and flag forwarding, plus one unknown-artifact-type negative case
  - Acceptance: file passes and stays at or under 500 lines
- [x] [P5-T7] Create `extensions/drm-copilot/test/mcp-parallel-validation-definitions.test.ts` asserting via `expect.arrayContaining` that both definition surfaces carry both new enum values and stay aligned
  - Acceptance: file passes and stays at or under 500 lines
- [x] [P5-T8] Create `extensions/drm-copilot/test/mcp-server-parallel-validation.test.ts` performing an in-memory MCP round trip (`InMemoryTransport.createLinkedPair()`) against a mocked `RepoAutomationService` for both new artifact types
  - Acceptance: file passes and stays at or under 500 lines; the tool call is forwarded with resolved input for both types
- [x] [P5-T9] Run the three new MCP Jest test files from `extensions/drm-copilot/` (`node run-jest.cjs test/mcp-tool-inputs-parallel-validation.test.ts test/mcp-parallel-validation-definitions.test.ts test/mcp-server-parallel-validation.test.ts`) and confirm a clean pass
  - Acceptance: exit code 0 with zero failures
- [x] [P5-T10] Create `extensions/drm-copilot/test/lib/validate/orchestration-artifacts-parallel-dispatch.test.ts` (a NEW file; the existing `orchestration-artifacts.test.ts` is untouched and is already at 508 lines) asserting that `validateArtifact` routes `parallel-orchestrator-state` and `parallel-planner-state` to the Phase 4 cores and threads `requireComplete` / `requireReadyForExecution`, mirroring the existing epic dispatch cases, plus one unknown-artifact-type case asserting the unchanged `Unsupported artifact type: {type}` message
  - Acceptance: file passes and stays at or under 500 lines; both routing assertions and both flag-threading assertions are present
- [x] [P5-T11] Run `node run-jest.cjs test/lib/validate/orchestration-artifacts-parallel-dispatch.test.ts` from `extensions/drm-copilot/` and confirm a clean pass
  - Acceptance: exit code 0 with zero failures

### Phase 6 — Routing Config, Rule File, and Structural Verifications

- [x] [P6-T1] Add the `parallel` route entry from the spec's Implementation Strategy (description, `requires_pr_gate: false`, `required_agents`, provisional `required_skills` including `parallel-orchestrate`, `required_mcp_tools`) to `config/orchestration-routing.json`, inserting the new entry BEFORE the existing `epic` entry (the `epic` entry is the last member of `routes` at `config/orchestration-routing.json:100-121`; appending after it would force a trailing comma onto the `epic` block's closing brace and violate the byte-unchanged constraint); write the entry's arrays in the file's existing expanded one-element-per-line style rather than the spec snippet's compact style, so the diff reads consistently
  - Acceptance: JSON parses; existing route entries are byte-unchanged; the new entry's arrays are one element per line
- [x] [P6-T2] Apply the byte-identical `parallel` route edit to `extensions/drm-copilot/resources/config/orchestration-routing.json`
  - Acceptance: both routing files are byte-for-byte identical
- [x] [P6-T3] Run `poetry run pytest tests/scripts/dev_tools/test_orchestration_routing_config_parity.py` and confirm the byte-identity parity test passes
  - Acceptance: exit code 0 with zero failures
- [x] [P6-T4] Create `.claude/rules/parallel-orchestration.md` recording the V-O invariants 1-21, planner invariants P1-P9 (with the deliberate P5 omission noted), and manifest invariants M1-M7 as numbered prose in the style of `.claude/rules/orchestrator-state.md`
  - Acceptance: every invariant number in the spec appears in the rule file with matching semantics
- [x] [P6-T5] Add the doctrine sections to `.claude/rules/parallel-orchestration.md`: the Foreign Schema Warning restated for the parallel artifacts, the cache-not-source-of-truth doctrine (naming `git worktree list --porcelain`, `git branch`, and `gh pr view --json state,mergedAt,headRefOid`), the S8 omitted-epic-fields table, the A7 concurrency bound (1..8, default 4), the A8 drift recording rule, the enum-ownership statement (F6/F7/F8 consume, never extend), and the F7 seam note
  - Acceptance: all seven content elements are present and consistent with `spec.md`
- [x] [P6-T6] Reconcile `quality-tiers.yml` per risk R3 using the observed state from P0-T10: if the file exists at the repository root, classify every new module in it; if it does not exist, record its absence (this task's branch is explicitly authorized)
  - Acceptance: `docs/features/active/2026-08-07-parallel-schema-validators-444/evidence/other/quality-tiers-classification.<ts>.md` exists with `Timestamp:` and either the classification applied or the recorded absence
- [x] [P6-T7] Apply the spec's conditional property-test requirement using the P6-T6 outcome (this task's branches are explicitly authorized): (a) if no T1/T2 classification applies, record the tier-based exemption; (b) if the new modules are classified T1 or T2 AND `hypothesis` is a declared dev dependency in `pyproject.toml`, add at least one property test per pure helper (prohibited-key scanner over arbitrary nested dicts; edge normalization over arbitrary int pairs) in a NEW file `tests/scripts/dev_tools/test_parallel_state_properties.py` (not in the existing Phase 1/2 test files, which have insufficient headroom against the 500-line cap); (c) if the new modules are classified T1 or T2 AND `hypothesis` is NOT a declared dependency, record the exemption plus an explicit escalation note — do not add `hypothesis` to `pyproject.toml`, because `.claude/rules/python.md` prohibits adding dependencies without explicit user instruction
  - Acceptance: `docs/features/active/2026-08-07-parallel-schema-validators-444/evidence/other/property-test-decision.<ts>.md` exists with `Timestamp:`, the branch taken, and either the added property-test names and file path or the recorded exemption and, under branch (c), the escalation note
- [x] [P6-T8] Verify the epic validators are unmodified by running `git status --porcelain` and `git diff --name-only` scoped to `scripts/dev_tools/validate_epic_*`, `scripts/dev_tools/_epic_*`, `extensions/drm-copilot/src/lib/validate/epic-*`, `tests/scripts/dev_tools/test_validate_epic_*`, and `extensions/drm-copilot/test/lib/validate/epic-*`, confirming empty output
  - Acceptance: `docs/features/active/2026-08-07-parallel-schema-validators-444/evidence/qa-gates/epic-unchanged.<ts>.md` exists with `Timestamp:`, `Command:`, `EXIT_CODE:`, `Output Summary:`, `SearchScope:`, and an explicit empty-result statement
- [x] [P6-T9] Verify the 500-line cap by measuring the line count of every file created or modified by Phases 1-6 (all `scripts/dev_tools/*parallel*` modules, `scripts/dev_tools/validate_orchestration_artifacts.py`, all new TS production and test files — explicitly including `extensions/drm-copilot/test/lib/validate/orchestration-artifacts-parallel-dispatch.test.ts` and the non-suite support module `extensions/drm-copilot/test/lib/validate/parallel-state-test-support.ts` — all new Python test files, the four modified TypeScript files `extensions/drm-copilot/src/mcp-tool-inputs.ts`, `extensions/drm-copilot/src/mcp-tool-definitions.ts`, `extensions/drm-copilot/src/mcp-repo-automation-tool-definitions.ts`, and `extensions/drm-copilot/src/lib/validate/orchestration-artifacts.ts`, and `extensions/drm-copilot/jest.config.cjs`, plus `tests/scripts/dev_tools/test_parallel_state_properties.py` when P6-T7 branch (b) fired) and confirming every count is at or under 500
  - Acceptance: `docs/features/active/2026-08-07-parallel-schema-validators-444/evidence/qa-gates/file-size-verification.<ts>.md` exists listing each file path with its line count, all at or under 500

### Phase 7 — Final QA Loop, Coverage Verification, and AC Reconciliation

Loop rule for this phase: run each language's steps in order (format, lint, type-check, coverage-enabled test). If any step fails or changes files, fix the cause and restart that language's loop from its first step until all four steps pass cleanly in a single pass. Every command below is unconditional; `EXIT_CODE: SKIPPED` is invalid.

- [x] [P7-T1] Run `poetry run black .` from the repository root as the Python final-QC format step; restart the Python loop from this step if any file changes
  - Acceptance: `docs/features/active/2026-08-07-parallel-schema-validators-444/evidence/qa-gates/final-qc-python-format.<ts>.md` exists with `Timestamp:`, `Command:`, `EXIT_CODE:`, `Output Summary:` from the final clean pass
- [x] [P7-T2] Run `poetry run ruff check .` from the repository root as the Python final-QC lint step, followed by `git status --porcelain` so changed-file detection is deterministic rather than dependent on ruff's `show-fixes` output; if any file changed, restart the Python loop from P7-T1
  - Acceptance: `docs/features/active/2026-08-07-parallel-schema-validators-444/evidence/qa-gates/final-qc-python-lint.<ts>.md` exists with all four required fields and exit code 0; `Output Summary:` records the changed-file count (0 on the final pass)
- [x] [P7-T3] Run `poetry run pyright` from the repository root as the Python final-QC type-check step
  - Acceptance: `docs/features/active/2026-08-07-parallel-schema-validators-444/evidence/qa-gates/final-qc-python-typecheck.<ts>.md` exists with all four required fields and exit code 0
- [x] [P7-T4] Run `poetry run pytest --cov --cov-branch --cov-report=term-missing` from the repository root as the Python final-QC test step
  - Acceptance: `docs/features/active/2026-08-07-parallel-schema-validators-444/evidence/qa-gates/final-qc-python-test-coverage.<ts>.md` exists with all four required fields, exit code 0, and numeric post-change line and branch coverage percentages in `Output Summary:`
- [x] [P7-T5] Run `npm run format` in `extensions/drm-copilot/` as the TypeScript final-QC format step, followed by `git status --porcelain`; restart the TypeScript loop from this step if any file changes
  - Acceptance: `docs/features/active/2026-08-07-parallel-schema-validators-444/evidence/qa-gates/final-qc-ts-format.<ts>.md` exists with all four required fields and a recorded changed-file count of 0 on the final pass
- [x] [P7-T6] Run `npm run lint` in `extensions/drm-copilot/` as the TypeScript final-QC lint step
  - Acceptance: `docs/features/active/2026-08-07-parallel-schema-validators-444/evidence/qa-gates/final-qc-ts-lint.<ts>.md` exists with all four required fields and exit code 0
- [x] [P7-T7] Run `npm run typecheck` in `extensions/drm-copilot/` as the TypeScript final-QC type-check step
  - Acceptance: `docs/features/active/2026-08-07-parallel-schema-validators-444/evidence/qa-gates/final-qc-ts-typecheck.<ts>.md` exists with all four required fields and exit code 0
- [x] [P7-T8] Run `npm run test:coverage` in `extensions/drm-copilot/` as the TypeScript final-QC test step
  - Acceptance: `docs/features/active/2026-08-07-parallel-schema-validators-444/evidence/qa-gates/final-qc-ts-test-coverage.<ts>.md` exists with all four required fields, exit code 0, and numeric post-change line and branch coverage percentages in `Output Summary:`
- [x] [P7-T9] Produce the coverage delta and threshold verification comparing the P0-T5/P0-T9 baselines against the P7-T4/P7-T8 results: derive per-new-module TypeScript line and branch percentages from `extensions/drm-copilot/coverage/lcov.info` (the `text-summary` reporter emits aggregate totals only) and per-new-module Python percentages from the `--cov-report=term-missing` per-file table; report baseline coverage, post-change coverage, and new/changed-code coverage per new module, and verify line coverage >= 85% and branch coverage >= 75% for every new Python and TypeScript module with no regression on changed lines; if any required numeric value is unavailable, the outcome is remediation-required, not PASS
  - Acceptance: `docs/features/active/2026-08-07-parallel-schema-validators-444/evidence/qa-gates/coverage-delta.<ts>.md` exists with all three coverage figures per language, per-new-module values, and an explicit threshold verdict
- [x] [P7-T10] Check off every verified acceptance criterion in `docs/features/active/2026-08-07-parallel-schema-validators-444/spec.md` (19 items under `## Acceptance Criteria`) per the acceptance-criteria-tracking protocol, leaving any unmet item unchecked with a documented gap
  - Acceptance: `spec.md` checkbox state matches delivered, verified work item-for-item
- [x] [P7-T11] Check off every verified acceptance criterion in `docs/features/active/2026-08-07-parallel-schema-validators-444/user-story.md` (13 items under `## Acceptance Criteria`) per the same protocol
  - Acceptance: `user-story.md` checkbox state matches delivered, verified work item-for-item
- [x] [P7-T12] Produce the Acceptance Criteria Status summary (source files, total, checked, remaining with texts) in the executor completion report per `.claude/skills/acceptance-criteria-tracking/SKILL.md`
  - Acceptance: the summary block is present in the completion report and consistent with the checkbox state in both source files

## Acceptance Criteria Mapping

Spec ACs are numbered SA1-SA19 in the order they appear under `## Acceptance Criteria` in `spec.md`; user-story ACs are UA1-UA13 in the order they appear in `user-story.md`.

| AC | Summary | Delivering tasks | Verifying tasks |
| --- | --- | --- | --- |
| SA1 | `parallel_manifest_contract.py` with accessors, M1-M7 | P2-T1, P2-T2, P2-T3 | P2-T6, P2-T8 |
| SA2 | Orchestrator validator, invariants 1-19 + gated 20-21 | P1-T9, P1-T10 | P1-T12, P1-T13, P1-T14, P1-T15 |
| SA3 | Delimited F7 seam | P1-T11 | P1-T11 acceptance check |
| SA4 | Planner validator, P1-P4 + gated P6-P9 | P2-T4, P2-T5 | P2-T7, P2-T8 |
| SA5 | Helper modules exist; 500-line cap | P1-T1 through P1-T8 | P6-T9 |
| SA6 | Exact S4 enum member sets | P1-T1 | P1-T12, P2-T6, P2-T7 |
| SA7 | `mutations[]` full S5 shape | P1-T7 | P1-T13 |
| SA8 | `drift_events[]` full S6 shape | P1-T8 | P1-T13 |
| SA9 | `conflict_edges[]` full S7 shape | P1-T6 | P1-T13 |
| SA10 | Prohibited-key rejections with negative tests | P1-T4, P2-T3 | P1-T12, P2-T6, P2-T7 |
| SA11 | CLI subparsers; unknown type still fails | P3-T1 | P3-T2, P3-T3 |
| SA12 | TS cores byte-identical; dispatch wired | P4-T1 through P4-T4, P5-T2 | P4-T6, P4-T7, P4-T8, P4-T9, P4-T10, P5-T10, P5-T11 |
| SA13 | MCP inputs and both definition surfaces; alignment test | P5-T1, P5-T3, P5-T4 | P5-T6, P5-T7, P5-T9 |
| SA14 | `parallel` route entry with byte-identical mirror | P6-T1, P6-T2 | P6-T3 |
| SA15 | `.claude/rules/parallel-orchestration.md` complete | P6-T4, P6-T5 | P6-T5 acceptance check |
| SA16 | Six Python + eight TS test files with invariant coverage (see Notes: SA16 file-count divergence) | P1-T12, P1-T13, P1-T14, P2-T6, P2-T7, P3-T2, P4-T5, P4-T6, P4-T7, P4-T8, P4-T9, P5-T6, P5-T7, P5-T8, P5-T10 | P7-T4, P7-T8 |
| SA17 | Coverage >= 85% line / >= 75% branch per new module | all test tasks; P5-T5 (Jest per-file `coverageThreshold` gate) | P7-T9 |
| SA18 | Epic validators unmodified | constraint on all tasks | P6-T8 |
| SA19 | Full toolchain loop single pass, both surfaces | P7-T1 through P7-T8 | P7-T1 through P7-T8 artifacts |
| UA1 | Manifest schema with defaults | P2-T1, P2-T2, P2-T3 | P2-T6 |
| UA2 | Checkpoint schema per design section 12 | P1-T5 through P1-T9 | P1-T12, P1-T13 |
| UA3 | Orchestrator validator with completion gating | P1-T9, P1-T10 | P1-T14 |
| UA4 | Planner validator with readiness gate | P2-T4, P2-T5 | P2-T7 |
| UA5 | Both artifact types on CLI and MCP; unknown fails | P3-T1, P5-T1, P5-T2, P5-T3, P5-T4 | P3-T2, P5-T6, P5-T9, P5-T10, P5-T11 |
| UA6 | TS error strings byte-identical | P4-T1 through P4-T4 | P4-T6, P4-T7, P4-T8, P4-T9 |
| UA7 | Prose rule file | P6-T4, P6-T5 | P6-T5 acceptance check |
| UA8 | `route_id: parallel` in both config files | P6-T1, P6-T2 | P6-T3 |
| UA9 | No `depends_on`; explicitly rejected | P1-T4, P2-T3 | P1-T12, P2-T6 |
| UA10 | No integration-branch fields; explicitly rejected | P1-T4 | P1-T12 |
| UA11 | S5-S7 fully shaped for F6/F7/F8 | P1-T6, P1-T7, P1-T8 | P1-T13 |
| UA12 | Epic validators unmodified | constraint on all tasks | P6-T8 |
| UA13 | Coverage thresholds; canonical test placement | all test tasks; P5-T5 (Jest per-file `coverageThreshold` gate) | P7-T9, P6-T9 |

## Test Plan

- Unit (Python, Pytest, `tests/scripts/dev_tools/`): six files — `test_validate_parallel_orchestrator_state.py`, `test_validate_parallel_orchestrator_state_structures.py`, `test_validate_parallel_orchestrator_state_completion.py`, `test_validate_parallel_planner_state.py`, `test_parallel_manifest_contract.py`, `test_validate_orchestration_artifacts_parallel_dispatch.py`. Per-invariant discipline: valid case, each malformed case, absent-optional-key case; `pytest.mark.parametrize` for enum matrices; no temp files; checkpoints built as dicts and serialized with `json.dumps`.
- Unit (TypeScript, Jest, `extensions/drm-copilot/test/`): eight files — `lib/validate/parallel-orchestrator-state-core.test.ts`, `lib/validate/parallel-orchestrator-state-structures.test.ts`, `lib/validate/parallel-orchestrator-state-completion.test.ts`, `lib/validate/parallel-planner-state-core.test.ts`, `lib/validate/orchestration-artifacts-parallel-dispatch.test.ts`, `mcp-tool-inputs-parallel-validation.test.ts`, `mcp-parallel-validation-definitions.test.ts`, `mcp-server-parallel-validation.test.ts`. The shared builder ships separately in `lib/validate/parallel-state-test-support.ts`, a non-suite support module (not a `.test.ts` file, not collected by `testMatch`, and not counted among the eight test files). Error strings asserted byte-identical to the Python source. Coverage for the four new production modules is gated by per-file `coverageThreshold` entries in `extensions/drm-copilot/jest.config.cjs` (P5-T5).
- Contract/parity: `tests/scripts/dev_tools/test_orchestration_routing_config_parity.py` (byte-identity of the two routing config files); the definitions test keeps both MCP definition surfaces aligned; the Python test suites serve as the parity oracle for the TS port.
- Integration-style: `mcp-server-parallel-validation.test.ts` in-memory MCP round trip; CLI dispatch tests via `validator.main([...])` exit codes.
- Seven-stage toolchain mapping: stages 1-3 and 5 are the per-language commands in Phase 7; stage 4 (architecture boundary) has no configured runner covering `scripts/dev_tools/` or the extension's validate library on this branch; stage 6 (contract/schema) is exercised by the routing-config parity and definitions-alignment tests inside the test stage; stage 7 (integration) is exercised by the in-memory MCP round-trip test inside the Jest stage.
- Coverage evidence: baselines at `docs/features/active/2026-08-07-parallel-schema-validators-444/evidence/baseline/python-test-coverage-baseline.<ts>.md` and `evidence/baseline/ts-test-coverage-baseline.<ts>.md`; post-change at `evidence/qa-gates/final-qc-python-test-coverage.<ts>.md` and `evidence/qa-gates/final-qc-ts-test-coverage.<ts>.md`; comparison at `evidence/qa-gates/coverage-delta.<ts>.md` (all under the feature evidence root).
- Expect-fail tasks: none. All new tests target new modules; there is no fail-before regression scenario in this feature, so no `[expect-fail]` tags are required.

## Open Questions / Notes

- SA16 file-count divergence: SA16's spec text reads "TypeScript tests at the five planned files". This plan delivers the TypeScript orchestrator-state test as three files (`parallel-orchestrator-state-core.test.ts`, `parallel-orchestrator-state-structures.test.ts`, `parallel-orchestrator-state-completion.test.ts`) rather than one, mirroring the Python test partition, because the roughly 60-70 assertions required by invariants 1-21 do not fit in a single file under the 500-line cap (the shared builder lives in the non-suite support module `parallel-state-test-support.ts`), and adds `orchestration-artifacts-parallel-dispatch.test.ts` to verify the `validateArtifact` dispatch wiring in a new file because the existing `orchestration-artifacts.test.ts` is already at 508 lines. The delivered eight-file TypeScript set is a superset of the planned five; the AC is satisfied as a superset and the divergence is recorded here so it is auditable rather than silent.
- Records-module split: `scripts/dev_tools/_parallel_state_records.py` and `extensions/drm-copilot/src/lib/validate/parallel-state-records.ts` are both absent from this plan's named file set above (only `_parallel_state_structures.py` and `parallel-state-structures.ts` are named). Both modules exist in the delivered tree and hold the records-shape validators (drift-event and receipt-array checks) that were split out of `_parallel_state_structures.py` / `parallel-state-structures.ts`, matching the same 500-line-cap justification recorded for the SA16 divergence above: the combined structures-plus-records validator set does not fit one file per language under the cap, so the records-shape checks were factored into their own sibling module in each language. The split is a superset delivery, not a scope reduction; it is recorded here so it is auditable rather than silent.
- Upstream assumptions A1-A8 (spec) remain the contract until F1/F2 specs land; any divergence is reconciled at spec review, not during execution of this plan.
- The `required_skills` list in the `parallel` route entry names `parallel-orchestrate` before that skill exists (F5). This is provisional data, not a file reference; F5 confirms or amends it.
- Invariant 13 strictness is resolved as "exactly one" (spec decision, research R5); if F4 later finds partial colorings legitimate mid-mutation, F4 raises the divergence at its own spec review.
- No JSON Schema file is authored or imported for any artifact; enforcement is Python validator logic, the TS parity port, and the prose rule file, per `.claude/rules/orchestrator-state.md`.
- The manifest validator ships as a standalone Python module (spec decision 3.2-A); the MCP surface grows by exactly the two promised `artifact_type` values.
