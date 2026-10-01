# Research: TypeScript validator promotion-type parity gap (#405)

Timestamp: 2026-09-29T14-30
Issue: #405 (bug). Epic: `orchestrator-state-contract-correctness` (#771). Also covers #623 item 3.
Scope: read-only investigation. No source, config, or test file was modified.

Verification note: `gh` and Bash were unavailable in this session. The text of issues #405 and #623 was obtained through WebFetch, which returns a model-produced summary rather than verbatim text. Treat the issue wording below as a summary. All code citations were read directly from the worktree.

## 1. Python authority

File: `scripts/dev_tools/_orchestrator_state_routing.py` (595 lines of content; the epic notes it exceeds the 500-line cap and #509 splits it).

- Constants: `FEATURE_PROMOTION_ENTRY_TOOL = "new_potential_entry"` (line 18), `BUG_PROMOTION_ENTRY_TOOL = "new_potential_bug_entry"` (line 19).
- Resolver: `_resolve_promotion_entry_tools(required_mcp_tools, state)` at lines 357-406.
  - Key read: `state.get("promotion-type")` (line 393), the hyphenated key only. `promotion_type` (underscore) is not read.
  - Condition: `promotion_type != "bug"` returns `list(required_mcp_tools)` unchanged (lines 398-399). So substitution happens only for the exact string `"bug"`. There is no trim, no case folding, and no type coercion. Absent, `None`, non-string, `"Bug"`, `" bug"`, `"feature"`, and any other value all leave the list unchanged.
  - Substitution: list comprehension replacing each `new_potential_entry` with `new_potential_bug_entry`, preserving order and all other tools (lines 403-406). Comparison of the tool is exact (case-sensitive).
- Routes affected: the resolver is route-agnostic. It substitutes in whatever list the selected route supplies. Per `config/orchestration-routing.json`, `new_potential_entry` appears in exactly three routes: `small` (line 27), `large` (line 54), `preparation` (line 94). The `remediation`, `parallel`, and `epic` routes do not list it, so substitution is a no-op there.
- Use in `validate_routing_contract` (lines 530-595): the resolved list is computed once (lines 557-559) and drives BOTH
  1. the checkpoint equality check `_state_list(state, "required_mcp_tools", route_id, required_mcp_tools)` (line 571), which emits `Checkpoint required_mcp_tools must match routing matrix for route <route>.` on mismatch, and
  2. the receipt-presence loop (lines 587-590), which emits `Checkpoint missing successful MCP receipt: <tool>.`.
  
  Consequence: for a bug checkpoint, the declared `required_mcp_tools` list in the checkpoint must itself contain `new_potential_bug_entry` (not `new_potential_entry`), or the equality error fires. `required_agents` and `required_skills` are unaffected.
- `_state_list` (409-419): requires `_string_list` (every item non-blank string) and `value != expected` (ordered list equality).

## 2. PowerShell

File: `.claude/lib/orchestrator-state/OrchestratorStateRoutingContract.psm1`.

- `Get-ResolvedRequiredMcpTool` (lines 105-144) mirrors Python. Key `promotion-type` (line 64). Equality via `Test-PythonValueEqual` against `'bug'` (line 134), which is ordinal, case-sensitive, type-strict (`OrchestratorStateCheckpointValue.psm1:215-260`). Tool replacement uses `-ceq` (line 141). Behavior matches Python for absent, non-string, casing, and whitespace values.
- `Get-OrchestratorStateRoutingContractError` (329-426): resolved list feeds both the declared-list equality loop (lines 379-394, message `Checkpoint required_mcp_tools must match routing matrix for route <route>.`) and the receipt loop (412-417). Same dual use as Python.
- `OrchestratorStateCompletion.psm1:418` calls `Get-OrchestratorStateRoutingContractError`; it contains no separate promotion-type logic.
- `OrchestratorStateRoutingMatrix.psm1` pins the matrix (lines 51-94), no disk read (PD-1). Its pinned `small`, `large`, `preparation` lists contain `new_potential_entry`; pinned `large.required_skills` contains no dead skill names. The module states a static config-parity Pester test is the oracle keeping the constants honest (not independently located in this pass).
- Bundled copy: `extensions/drm-copilot/resources/claude-customizations/.claude/lib/orchestrator-state/OrchestratorStateRoutingContract.psm1` has the same non-empty-line count (380) as the source. Byte identity is enforced by `tests/scripts/claude-lib/orchestrator-state/OrchestratorState.Manifest.Tests.ps1:91-104` (SHA-256 per module). Byte identity was not hashed directly in this session because shell access was unavailable. No PowerShell change is required by #405, so the bundle need not change.

## 3. TypeScript: the divergence

File: `extensions/drm-copilot/src/lib/validate/orchestrator-state-routing.ts` (451 lines).

- `validateRoutingContract(state, options)` at lines 380-451. Line 408: `const requiredMcpTools = routeList(rawRoute, "required_mcp_tools");` uses the raw matrix list. It is used at line 420 (`stateList` equality) and line 441 (receipt loop). No resolution exists anywhere in `src/`: the only `promotion-type` occurrence under `src/lib/validate/` is the required-key list at `orchestrator-state-core.ts:62`, and `required_mcp_tools` appears only at `orchestrator-state-routing.ts:408,420,422`.
- Matrix flow: `validateArtifact` (`orchestration-artifacts.ts:279-300`, orchestrator-state case) forwards `fs`, `root`, `routingMatrix`; `orchestrator-state-core.ts:311-322` `resolveRoutingMatrix` prefers `options.routingMatrix`, else `loadRoutingMatrix(fs, root)` (routing.ts:137-140); the value is passed at core.ts:433-444. Production wiring passes `root: input.workspaceRoot` (`validate-orchestration-service-call.ts:105`). Caller of `validateRoutingContract`: only `orchestrator-state-core.ts:441`.
- Exact divergence: for a checkpoint with `promotion-type: "bug"`, TS (a) requires `new_potential_entry` receipt (false missing-receipt error) and (b) requires the declared `required_mcp_tools` to equal the raw matrix list, so a bug checkpoint declaring `new_potential_bug_entry` gets the mismatch error, while Python and PowerShell accept it. Both symptoms come from the single unresolved variable.
- Because the equality check uses the same resolved list in Python/PS, TS must feed the resolved list to both `stateList(...)` and the receipt loop to produce identical error lists (including order: agents, skills, tools equality errors, then receipts in matrix order).

### Where the helper should live

Adding a documented resolver (about 40-50 lines with TSDoc) plus wiring to the 451-line file risks reaching the 500-line cap, and #509 will extend the same resolution. Recommendation: a new module `extensions/drm-copilot/src/lib/validate/orchestrator-state-promotion-tools.ts` exporting:

- constants `FEATURE_PROMOTION_ENTRY_TOOL`, `BUG_PROMOTION_ENTRY_TOOL`, `BUG_PROMOTION_TYPE`, `PROMOTION_TYPE_KEY = "promotion-type"`;
- a pure function `resolvePromotionEntryTools(requiredMcpTools: string[], state: Record<string, unknown>): string[]` (mirror of `_resolve_promotion_entry_tools`: `state["promotion-type"] === "bug"` strict equality, returns a new array, order preserved).

`validateRoutingContract` then changes one line (`resolvePromotionEntryTools(routeList(rawRoute, "required_mcp_tools"), state)`). The module has no import from `orchestrator-state-routing.ts`, so no cycle. #509 can widen this function (or its signature to take an options bag) without touching the 451-line file. Add a per-file `coverageThreshold` entry (85 lines / 75 branches) for the new module in `extensions/drm-copilot/jest.config.cjs`; the map has no `global` key, so a new file is otherwise ungated. Note `orchestrator-state-routing.ts` itself has no entry in that map today.

Rejected alternative: inline the helper in `orchestrator-state-routing.ts`. It works functionally but leaves the file near the cap and forces #509 to split it.

## 4. Claim verification (#623 item 3)

After the fix, for a bug `large`-route checkpoint all three runtimes demand `new_potential_bug_entry` in both the declared list and the receipts, provided TS mirrors the exact-`"bug"` rule. Residual divergences and non-divergences:

- Preparation and small routes: all three runtimes resolve identically because the substitution is route-agnostic and those routes carry `new_potential_entry`. Issue text names only `large`; the fix covers all three by construction. Tests should include `small` and `preparation` in the parity corpus.
- Casing/whitespace: Python and PowerShell are exact and case-sensitive; TS must use `=== "bug"` (no `toLowerCase`, no `trim`) to match. `"Bug"` and `" bug"` therefore leave the feature tool required in all three.
- Key name: hyphenated `promotion-type` only. The `promotion_type` name appears in MCP tool inputs (`mcp-tool-inputs-potential-to-issue.ts:52`) and is unrelated to the checkpoint key; do not read it in the validator.
- Matrix source: Python loads `config/orchestration-routing.json`; PowerShell uses a pinned copy; TS uses the injected matrix or loads the file. Content is equal today for the promotion tool on the three routes; drift is guarded outside this change.
- Dead skill names: absent from the real matrix's `large.required_skills` (config lines 45-52) and from the PowerShell pinned matrix. No residual divergence there. The only dead names in TS are inside the stale local fixture matrix of `test/lib/validate/orchestrator-state-routing.test.ts` (lines 10-35: `orchestrator-workflow`, `repo-automation-adapter`, `feature-reviewer`, `commit-steward`, `collect_commit_context`), which does not mirror the real matrix.
- Not in scope: `pr_gate`/`ci_gate` route-gating parity (#343), per the epic Non-Goals.

## 5. Existing tests and parity pattern

- Python: `tests/scripts/dev_tools/test_validate_orchestrator_state_routing_contract.py` (367 lines). Bug-related tests from PR #402:
  - `test_complete_state_accepts_bug_type_large_route_with_bug_promotion_tool` (line 279): bug promotion with bug tool everywhere passes with `[]`.
  - `test_complete_state_accepts_feature_type_large_route_with_feature_tool` (298): regression guard.
  - `test_large_route_required_skills_excludes_removed_dead_names` (317): reads the real matrix via `load_routing_matrix()` and asserts `orchestrator-workflow` and `repo-automation-adapter` are absent from `routes.large.required_skills`.
  - `test_complete_state_rejects_bug_type_recording_only_feature_tool` (333): sets `promotion-type: bug` on the unmodified feature state and asserts `"Checkpoint missing successful MCP receipt: new_potential_bug_entry."` is in the errors (it also produces the equality error, which the test does not assert).
  - Builders: `_build_complete_large_state` (23), `_build_complete_large_bug_state` (105).
- TypeScript: `extensions/drm-copilot/test/lib/validate/orchestrator-state-routing.test.ts` (302 lines; note TS tests live under `extensions/drm-copilot/test/`, `testMatch: **/test/**/*.test.ts`, not `tests/`). It has no bug or promotion-type tests and uses an in-file stale matrix. Related: `orchestrator-state-core.completion.test.ts`, `orchestrator-state-preparation-route.test.ts` (routingMatrix injection).
- Pester: `tests/scripts/claude-lib/orchestrator-state/OrchestratorStateRoutingContract.Tests.ps1`, `Describe 'C6 bug-promotion tool substitution'` (lines 270-311) with five cases: bug plus feature tool declared, bug plus bug tool declared, feature unaffected, absent key unaffected, substitution preserving order. All are in-memory JSON strings.
- Existing cross-runtime parity precedent (shared fixture corpus): `tests/fixtures/parallel_cohort_barrier/*.json` (each file: `name`, `notes`, `document`, `expected_barrier_errors`) consumed by Python `tests/scripts/dev_tools/test_parallel_cohort_barrier_parity.py` and TS `extensions/drm-copilot/test/lib/validate/parallel-cohort-barrier-parity.test.ts` (corpus dir resolved from `__dirname` by walking up five levels, count floor guard against vacuous pass). Blast-radius corpus follows the same design and is also read by Pester (`tests/scripts/claude-lib/blast-radius/BlastRadius.Parity.Tests.ps1`, `Resolve-Path "$PSScriptRoot/../../../../tests/fixtures/blast_radius"`). A duplicated-inline-fixture precedent also exists (`plan-gate-parity.test.ts` and `test_plan_gate_parity.py`), but the shared-corpus design is the newer, stronger one and is what the epic's "shared checkpoint fixture set" indicator asks for.

### Recommended parity design

- New directory `tests/fixtures/orchestrator_state_promotion_type/` with one JSON file per case. Shape: `{ "name", "notes", "checkpoint": {...}, "expected_errors": [ ... ] }`, where `expected_errors` is the full ordered error list from `validate_routing_contract`-level routing errors (or from completion validation with a checkpoint that otherwise passes), so a single ordered-array equality asserts verdict and content.
- Cases: bug + large + bug tool everywhere (`[]`); feature + large (`[]`); bug + large recording only feature tool (equality error plus missing-receipt error, in order); absent `promotion-type`; `"Bug"` (case); `" bug"` (whitespace); non-string (`true`, `null`); bug + small; bug + preparation; bug + remediation and bug + epic (no-op, verifying route-agnostic behavior).
- Readers: Python parametrized test `tests/scripts/dev_tools/test_orchestrator_state_promotion_type_parity.py` (calls `validate_routing_contract` or `validate_orchestrator_state_text(..., require_complete=True)` with the repo matrix); TS `extensions/drm-copilot/test/lib/validate/orchestrator-state-promotion-type-parity.test.ts` (`validateRoutingContract` with the real matrix read from `config/orchestration-routing.json` via `node:fs` from `__dirname`, mirroring the barrier test); Pester `tests/scripts/claude-lib/orchestrator-state/OrchestratorStatePromotionType.Parity.Tests.ps1` (`Get-OrchestratorStateRoutingContractError` with the fixture JSON piped through `ConvertFrom-Json`). Each asserts the identical ordered `expected_errors` and includes a minimum-corpus-size guard.
- Constraint checks: fixtures are committed files, not temporary files; no runtime creates files. Each test file stays well under 500 lines. Tests mirror source under `tests/` (Python, Pester) and `extensions/drm-copilot/test/` (TS). The PowerShell reader is optional for #405 acceptance (the issue names Python and TS), but is low cost and delivers the epic's leading indicator; decision belongs to the plan.
- Scope caution: the Pester parity reader would use the pinned matrix, so fixture checkpoints must use only route/tool content equal to config (small, large, preparation, remediation, epic are all pinned).
- Additional TS unit tests (in a new `orchestrator-state-promotion-tools.test.ts`, mirroring the new module): bug substitution, order preserved, feature/absent/non-string/`"Bug"`/`" bug"` unchanged, input array not mutated, tool list without the feature tool unchanged. Property test optional: T2 module rule ("at least one property test per pure function") suggests one `fast-check` property (output length equals input length; non-`"bug"` input returns equal list). Confirm `fast-check` is an approved dependency in the extension before relying on it (not verified here).

## 6. Toolchain commands

TypeScript (`extensions/drm-copilot/package.json` scripts, run from `extensions/drm-copilot`):
- Format: `npm run format` (`prettier --write "src/**/*.ts" "test/**/*.ts" "*.json" "*.cjs"`).
- Lint: `npm run lint` (`eslint --no-error-on-unmatched-pattern src test`; config `eslint.config.mjs`).
- Type check: `npm run typecheck` (`tsc -p ./ --noEmit`).
- Unit tests: `npm test` or `npm run test:unit` (`node run-jest.cjs`); with coverage: `npm run test:coverage` (`node run-jest.cjs --coverage --coverageReporters=lcov --coverageReporters=text-summary`). Jest config `jest.config.cjs`: ts-jest with `tsconfig.jest.json`, v8 coverage provider, `collectCoverageFrom: ["src/**/*.ts", "!src/**/*.d.ts"]`, per-file thresholds only (85 lines / 75 branches), no `global` key.
- A single-file run: `node run-jest.cjs test/lib/validate/orchestrator-state-routing.test.ts` (passes through to jest; not executed in this session).

Python (repo root): `poetry run pytest` (task "QC: 4 Pytest: run tests", `.vscode/tasks.json:390-409`); with coverage the task runs `poetry run pytest --cov=src/lexile_corpus_tuner --cov=scripts/dev_tools --cov-report=term-missing --cov-report=lcov:artifacts/python/lcov.info`. `pyproject.toml:115` sets `addopts = "-ra --cov-report=lcov:artifacts/python/lcov.info"`. Targeted: `poetry run pytest tests/scripts/dev_tools/test_validate_orchestrator_state_routing_contract.py`.

Pester: `pwsh -NoProfile -ExecutionPolicy Bypass -Command "& { Import-Module '<repo>/scripts/powershell/PoshQC'; Invoke-PoshQCTest -Root '<repo>' }"` (`.vscode/tasks.json:598-608`). Per project memory, the MCP PoshQC runner has known limitations; the plan should cite the self-hosted module invocation.

Memory-derived caution (from the auto-memory index, not re-verified): bash/pwsh text may be denied in agent worktrees; plan steps should be runnable by the executor's available shell.

## 7. Dead-skill and rejection scenarios

- Dead skill-name scenario: still applicable. Python test `test_large_route_required_skills_excludes_removed_dead_names` (line 317) exists and passes against the current matrix (config lines 45-52 contain neither name). The TS test must mirror it by reading the real `config/orchestration-routing.json` (via `node:fs` from `__dirname`, as the barrier parity test does) and asserting neither `orchestrator-workflow` nor `repo-automation-adapter` is in `routes.large.required_skills`. It should also assert that a bug-type large checkpoint built from the real matrix with no fabricated skill receipts validates cleanly.
- Bug-type-with-only-feature-tool rejection: Python test at line 333 asserts `Checkpoint missing successful MCP receipt: new_potential_bug_entry.` The TS test must assert that message and additionally (stricter than Python) the `Checkpoint required_mcp_tools must match routing matrix for route large.` message, since the declared list still holds the feature tool. Also assert `Checkpoint missing successful MCP receipt: new_potential_entry.` is absent.
- Existing local TS fixture matrix is stale; build the new tests from the real matrix rather than extending it, or refresh it in the same change if the plan prefers.

## Open questions

1. Should the PowerShell Pester reader of the shared corpus be in #405 scope, or only Python and TS? The epic's leading indicator suggests all three; the issue acceptance criteria name only TS.
2. Is `fast-check` available in `extensions/drm-copilot` devDependencies for the property test? Not verified.
3. Confirm the config-parity Pester test that keeps the pinned PowerShell matrix honest exists (referenced by module documentation only).
4. Issue text came from WebFetch summaries; the plan should re-read #405 acceptance criteria verbatim if a shell with `gh` is available.
5. `orchestrator-state-routing.ts` has no per-file jest threshold entry; decide whether to add one in this change (recommended for the new module, optional for the existing file).

## Recommended design (summary)

1. Add `orchestrator-state-promotion-tools.ts` with a pure `resolvePromotionEntryTools`, exact `=== "bug"` semantics on the hyphenated `promotion-type` key.
2. In `validateRoutingContract`, compute the resolved list once and use it for both `stateList` and the receipt loop.
3. Add per-file jest threshold entry for the new module.
4. Add unit tests for the helper and routing-contract bug cases (using the real matrix), plus a shared parity corpus under `tests/fixtures/` read by Python and TS (and optionally Pester).
5. No PowerShell or Python source change; bundle mirror untouched.

No numeric acceptance-criterion counts are proposed in this document, so no Numeric Derivation Evidence section is required.
