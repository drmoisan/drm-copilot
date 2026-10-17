# epic-planner-receipt-checks-key-gate (Plan)

- **Issue:** #543 (remainder; this change closes the issue)
- **Parent (optional):** none
- **Owner:** drmoisan
- **Last Updated:** 2026-10-15T07-42
- **Status:** Ready for preflight
- **Version:** 1.0
- **Work Mode:** full-bug (from `issue.md` line 12)
- **Branch:** `bug/epic-planner-receipt-checks-key-gate-543`
- **Requirements source:** `docs/features/active/epic-planner-receipt-checks-key-gate-543/spec.md`, section `## Acceptance Criteria` (18 items, planning-time lines 221-238). `user-story.md` is intentionally absent for this bug and must not be created.
- **Design source:** `docs/features/active/epic-planner-receipt-checks-key-gate-543/research/research.2026-10-15T08-05.md` (Candidate A, research section 3; contingency in section 7.3).
- **Defect report:** `docs/features/active/epic-planner-receipt-checks-key-gate-543/issue.md`

**Fail-closed evidence rule:** Every baseline task, final-QA task, and coverage-comparison task in this plan produces a named artifact. If any required artifact is missing, or carries a placeholder in place of a numeric value, the verdict is BLOCKED or INCOMPLETE, never PASS.

**Evidence accounting rule:** Each evidence-producing task names its artifact path. Do not mark an evidence-backed task complete without the artifact on disk. Every evidence filename has the form `<name>.<timestamp>.md`, where `<timestamp>` is the UTC write time in `yyyy-MM-ddTHH-mm` form, read from the host clock immediately before the write (`date -u +%Y-%m-%dT%H-%M` in the Bash tool). A task that consumes an earlier artifact selects the lexicographically greatest file matching `<name>.*.md` in the named folder. Every artifact carries `Timestamp:`, `Command:`, `EXIT_CODE:`, and `Output Summary:` unless the task states otherwise.

**Evidence location:** All evidence resolves under `docs/features/active/epic-planner-receipt-checks-key-gate-543/evidence/<kind>/`, with `<kind>` drawn from `baseline`, `regression-testing`, `qa-gates`, and `other`, per `.claude/skills/evidence-and-timestamp-conventions/SKILL.md`. No non-canonical evidence path was supplied by the caller or the spec, so no `EVIDENCE_LOCATION_OVERRIDE_REJECTED` record applies.

**Scratch location:** `SCRATCH` resolves to `<session scratchpad>/issue-543/`. Every scratch file this plan names (coverage JSON, diff captures, sorted string lists) lives under the item-unique subdirectory `SCRATCH/543/` (operator policy: one scratch directory per item); no scratch file is written directly under `SCRATCH` or anywhere else. Plans and evidence record the literal token `SCRATCH`, never a host path. Scratch files are not evidence; the evidence is the Markdown artifact that records the values read from them.

---

## The change, already decided

Under `require_ready_for_execution=True`, the per-feature `model_routing_receipt` and `topology_receipt` checks run unconditionally in both runtimes: Python `_validate_ready_features` (`scripts/dev_tools/validate_epic_planner_state.py` lines 222-276, model block 241-269, topology block 270-275, called at line 342) and TypeScript `validateReadyFeatures` (`extensions/drm-copilot/src/lib/validate/epic-planner-state-core.ts` lines 291-364, model block 329-354, topology block 355-360, called at line 438). The correction, which this plan encodes and does not re-litigate:

1. Python: extract lines 241-269 into the new private helper `_validate_feature_model_receipt(feature: dict[str, Any], *, prefix: str) -> list[str]` with an identical body and error order; add the keyword-only parameter `key_gated: bool = False` to `_validate_ready_features`; run the model block when `not key_gated or "model_routing_receipt" in feature` and the topology block when `not key_gated or "topology_receipt" in feature`; pass `key_gated=key_gated` at the call site (line 342). `key_gated` is already computed at line 332.
2. TypeScript: add the parameter `keyGated: boolean` to `validateReadyFeatures`; wrap the model block in `if (!keyGated || "model_routing_receipt" in feature) {` and the topology block in `if (!keyGated || "topology_receipt" in feature) {`; pass `requireLaunchPaths` at the call site (line 438). `requireLaunchPaths` is already computed at lines 425-427 and is not renamed.
3. Presence is key membership, not value truthiness: a present `null` value still runs the check.
4. With either Codex flag asserted, both checks run unconditionally, exactly as before.
5. The skip happens inside the per-feature loop, so `features[i]` indices are preserved.
6. No error string is added, removed, or reworded; no exported or public signature changes; no plumbing, CLI, guidance, mirror, rule, or Jest-config file changes.

## Files the diff will WRITE

Production, Python (1):

- `scripts/dev_tools/validate_epic_planner_state.py`

Production, TypeScript (1):

- `extensions/drm-copilot/src/lib/validate/epic-planner-state-core.ts`

Tests, Python (2):

- `tests/scripts/dev_tools/test_validate_epic_planner_state.py` (in-place update of `test_readiness_requires_resolved_child_model_receipt` only)
- `tests/scripts/dev_tools/test_validate_epic_planner_state_feature_receipts.py` (new)

Tests, TypeScript (2):

- `extensions/drm-copilot/test/lib/validate/epic-planner-state-feature-receipts.test.ts` (new)
- `extensions/drm-copilot/test/lib/validate/validate-orchestration-service-call.test.ts`

Conditional contingency files (created only when P3-T3 records `Contingency: triggered`; research section 7.3):

- `extensions/drm-copilot/src/lib/validate/epic-planner-ready-features.ts` (new)
- `extensions/drm-copilot/test/lib/validate/epic-planner-ready-features.test.ts` (new)

Feature-process files written outside the code diff:

- `docs/features/active/epic-planner-receipt-checks-key-gate-543/spec.md` (checkbox state of the `## Acceptance Criteria` section only; AC18 stays unchecked for S9)
- `docs/features/active/epic-planner-receipt-checks-key-gate-543/plan.2026-10-15T07-42.md` (this file; task checkbox state and the appended `## Plan Deviations` section only)
- Evidence artifacts under `docs/features/active/epic-planner-receipt-checks-key-gate-543/evidence/baseline/`, `evidence/regression-testing/`, `evidence/qa-gates/`, and `evidence/other/`.

No fixture file is created or edited: every test builds its state in memory. No temporary file is used by any test.

Planning-time physical line counts: `validate_epic_planner_state.py` 375, `epic-planner-state-core.ts` 474, `test_validate_epic_planner_state.py` 424, `validate-orchestration-service-call.test.ts` 232; the two new test files do not exist. Expected post-change counts: about 390-395, 486-490, 429, 246, about 150 (new Python file), and about 180 (new TypeScript file). The `epic-planner-state-core.ts` estimate is 474 + 5 (JSDoc replacing the one-line comment at line 291) + 1 (`keyGated: boolean,` parameter line) + 2 + 2 (the two `if` wrappers) + 2 (four-line comment replacing the two-line comment at lines 423-424) + 2 (call site at line 438 wrapped by Prettier to three lines) = 488. Every count must be at or below 500; P3-T3 holds the decision rule for exceeding it.

## Read-only citations (NOT written by this diff)

- Policy (Phase 0 read order): `CLAUDE.md`; `.claude/rules/general-code-change.md`; `.claude/rules/general-unit-test.md`; `.claude/rules/python.md`; `.claude/rules/python-suppressions.md`; `.claude/rules/typescript.md`; `.claude/rules/typescript-suppressions.md`; `.claude/rules/quality-tiers.md`; `.claude/skills/evidence-and-timestamp-conventions/SKILL.md`.
- Tests run but not edited: `tests/scripts/dev_tools/test_validate_epic_planner_state_launch_binding.py`, `tests/scripts/dev_tools/test_epic_planner_readiness.py`, `tests/scripts/dev_tools/test_push_down_codex_and_agents_customizations.py`, `extensions/drm-copilot/test/lib/validate/epic-planner-state-core.test.ts`, `extensions/drm-copilot/test/lib/validate/epic-planner-state-launch-binding.test.ts`, `extensions/drm-copilot/test/lib/validate/epic-planner-readiness-integrity.test.ts`, `extensions/drm-copilot/test/lib/validate/orchestration-artifacts.test.ts`, `extensions/drm-copilot/test/mcp-server-epic-validation.test.ts`.

No file under `.claude/rules/` or `.github/instructions/` is modified by this plan. No PowerShell file is in scope, so no Pester run is planned.

## Explicitly out of scope

- `scripts/dev_tools/validate_orchestration_artifacts.py` (Python CLI unchanged; it keeps running in key-gated mode).
- `.claude/**`, `.github/**`, `.agents/**`, `.codex/**`, `extensions/drm-copilot/resources/**`.
- `extensions/drm-copilot/jest.config.cjs`, `extensions/drm-copilot/src/mcp-tool-inputs.ts`, `extensions/drm-copilot/src/mcp-tool-definitions.ts`, `extensions/drm-copilot/src/mcp-repo-automation-tool-definitions.ts`, `extensions/drm-copilot/src/lib/validate/orchestration-artifacts.ts`.
- `extensions/drm-copilot/test/lib/validate/epic-planner-state-core.test.ts` and `tests/scripts/dev_tools/test_push_down_codex_and_agents_customizations.py` (run, never edited).
- The launch-binding `_validate_model_receipt` check (`scripts/dev_tools/_epic_orchestrator_state_launch_binding.py` lines 166-202) and every PR #829, PR #874, and PR #912 behaviour.

## Named tests and literals introduced by this plan

Quoted verbatim so a search, a pytest node ID, or a Jest `-t` selector for them is a real assertion.

New single-line production tokens (after Black and Prettier formatting):

- Python: `if not key_gated or "model_routing_receipt" in feature:`
- Python: `if not key_gated or "topology_receipt" in feature:`
- Python: `errors.extend(_validate_ready_features(features, key_gated=key_gated))`
- Python: `features: list[dict[str, Any]], *, key_gated: bool = False`
- Python: `def _validate_feature_model_receipt(`
- TypeScript: `if (!keyGated || "model_routing_receipt" in feature) {`
- TypeScript: `if (!keyGated || "topology_receipt" in feature) {`
- TypeScript: `...validateReadyFeatures(featureResult.features, requireLaunchPaths),`
- TypeScript: `keyGated: boolean,`
- Documentation token in both production files: `per-feature receipt`

Asserted message constants, identical names and values in both new test files (Python module-level constants; TypeScript module-level `const`):

- `REPOSITORY_CONTEXT_ERROR` = `Execution-ready planner validation requires repository context.`
- `MODEL_RECEIPT_OBJECT_ERROR` = `Epic planner checkpoint features[0].model_routing_receipt must be an object.`
- `TOPOLOGY_RECEIPT_OBJECT_ERROR` = `Epic planner checkpoint features[0].topology_receipt must be an object.`
- `LOGICAL_AGENT_ERROR` = `Epic planner checkpoint features[0].model_routing_receipt.logical_agent must be 'orchestrator'.`
- `SECOND_TOPOLOGY_RECEIPT_OBJECT_ERROR` = `Epic planner checkpoint features[1].topology_receipt must be an object.`
- `FEATURE0_TOPOLOGY_TOKEN` = `features[0].topology_receipt`
- `FEATURE0_MODEL_TOKEN` = `features[0].model_routing_receipt`

Fixed-string fragments that P6-T3 asserts absent from the new test files (so that no inline string literal is asserted): `toContain("`, `toEqual(["`, `includes("`, `assert "`, `== ["`, and `" in error`. The fragment that P4-T5 asserts absent after the update: `any("model_routing_receipt must be an object" in error`.

Python additionally defines the tuple `ASSERTED_MESSAGES` holding the seven constants in the order above. Python spells each long constant inside parentheses so that every line stays within the 88-column limit (`pyproject.toml` lines 85 and 89; ruff `E` selected at line 95); `LOGICAL_AGENT_ERROR` is split by implicit concatenation into the two pieces `"Epic planner checkpoint features[0].model_routing_receipt.logical_agent "` and `"must be 'orchestrator'."`. TypeScript writes each value as one unbroken double-quoted literal. Every assertion in both files references these constants; neither file asserts an inline string literal.

Python, in `tests/scripts/dev_tools/test_validate_epic_planner_state_feature_receipts.py` (seven node IDs):

- `test_ready_gate_skips_feature_receipts_when_keys_absent` (fail-before regression)
- `test_codex_flag_keeps_feature_receipts_unconditional[require_codex_model_routing]` and `[require_codex_topology]`
- `test_ready_gate_validates_present_null_feature_receipt[model_routing_receipt]` and `[topology_receipt]`
- `test_ready_gate_gates_each_feature_receipt_independently`
- `test_ready_gate_preserves_feature_index_when_receipts_skipped`

Python, in `tests/scripts/dev_tools/test_validate_epic_planner_state.py`:

- `test_readiness_requires_resolved_child_model_receipt` (existing, lines 176-188; updated in place)

TypeScript, in `extensions/drm-copilot/test/lib/validate/epic-planner-state-feature-receipts.test.ts`, inside `describe("validateEpicPlannerStateText per-feature receipt key gate", ...)` (seven test cases):

- `skips the per-feature receipts when the keys are absent without a Codex flag` (fail-before regression twin)
- `keeps the per-feature receipts unconditional under %p` (`it.each` over `{ requireCodexModelRouting: true }` and `{ requireCodexTopology: true }`)
- `validates a present null %s without a Codex flag` (`it.each` over `model_routing_receipt` and `topology_receipt`)
- `gates each per-feature receipt independently`
- `preserves the feature index when receipts are skipped`

TypeScript, in `extensions/drm-copilot/test/lib/validate/validate-orchestration-service-call.test.ts`:

- `threads the Codex flags into epic-planner-state` (existing, lines 160-212; six assertions appended)

## Execution notes

- **Shell routing.** Run `poetry`, `git`, `grep`, `sort`, `tr`, `diff`, and `ls` commands directly in the Bash tool from the worktree root. A command marked "in `extensions/drm-copilot/`" runs as `cd extensions/drm-copilot && <command>` in the Bash tool, because `extensions/drm-copilot/run-jest.cjs` line 28 passes the relative `--config jest.config.cjs`. If a hook denies the `cd`-chained form, substitute `npm --prefix extensions/drm-copilot run lint`, `npm --prefix extensions/drm-copilot run typecheck`, `npm --prefix extensions/drm-copilot test -- <args>` (the `test` script at `extensions/drm-copilot/package.json` line 211 is `node run-jest.cjs`), and, for Prettier, `node extensions/drm-copilot/node_modules/prettier/bin/prettier.cjs --check <paths prefixed with extensions/drm-copilot/>` from the worktree root; record the substituted command in `Command:` and add `Route: npm-prefix`. No command text contains the words that the worktree isolation guard denies; no `sh` wrapper is used. Do not use a multi-line `poetry run python -c`; the only `-c` command in this plan (P6-T3) is a single line.
- **Line counts.** Physical line counts use `grep -c -e '' <path>` in the Bash tool from the worktree root, one path per command. It returns the same value as `(Get-Content <path>).Count`, the form spec AC15 names, for every non-empty file. The executor has no PowerShell tool, and the worktree isolation guard denies starting PowerShell from Bash. Each line-count artifact carries `Equivalent-To: (Get-Content <path>).Count`.
- **Diff anchor.** Every `git diff` is anchored to `main`. P0-T3 records `MAIN_BASE_SHA` (the output of `git merge-base HEAD main`). Before any later `git diff main ...` command, run `git rev-parse main`; if it differs from `MAIN_BASE_SHA` (the shared local `main` ref advanced), substitute the literal `MAIN_BASE_SHA` value for `main` in that command, record the substituted command in `Command:`, and add `Anchor: merge-base`.
- **Git-to-grep pipelines.** Where a task filters a diff, the diff is first written to a `SCRATCH/543/` file with `>` and the filters run against that file, so no command pipes `git` output.
- **Multi-command artifacts.** An artifact that records several commands lists each command's printed result and exit status in `Output Summary:`. Its `EXIT_CODE:` is `0` only when every command's exit status equals the expectation stated in the task. A `grep -c` that prints `0` exits 1 by design; where a task expects a count of `0`, exit 1 is that command's stated expectation.
- **Python branch coverage.** The `term-missing` `Cover` column is a combined statement-plus-branch figure. Per-file line and branch percentages are read from `coverage json` output (`files[<key>].summary.covered_lines / num_statements` and `covered_branches / num_branches`), never derived from the terminal row. The coverage data file is `artifacts/.coverage` (`pyproject.toml` line 121). On Windows the JSON key is `scripts\\dev_tools\\validate_epic_planner_state.py`.
- **Known local-only failure (#510).** `tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py::test_bundled_claude_payload_contains_all_repo_runtime_contracts` (line 89) fails locally on gitignored state. Every full-suite Python run passes the identical `--deselect` for that node; CI covers it.
- **Jest per-test lines.** Where a task asserts individual test titles, the command carries `--reporters=default --verbose`, because the agent session environment can select a summary-only reporter.
- **Batch budget.** `.claude/hooks/enforce-python-batch-budget.ps1` (lines 10-14 and 25-29) denies the fourth distinct Python production file per session and never counts files under `tests/`. This plan writes 1 Python production file. If a write is nevertheless denied by a hook, stop and report the denial text to the orchestrator; do not delete hook state.
- **Phase-boundary commits.** The last task of every phase stages the phase's paths with explicit `git add <paths>`, commits with a conventional message ending in the repository's required commit trailers, and runs `git push origin bug/epic-planner-receipt-checks-key-gate-543`. No force push is used. If a hook denies staging, committing, or pushing, stop and report the denial text to the orchestrator.
- **Acceptance-criteria tick rule.** Per `.claude/skills/acceptance-criteria-tracking/SKILL.md`, each criterion in the `## Acceptance Criteria` section of `spec.md` is changed from `- [ ]` to `- [x]`, with no criterion text changed, immediately after the last of its mapped tasks (P9-T5 mapping) passes verification. AC18 is not ticked by this plan. P9-T5 verifies the result.
- **Restart rule for Phases 1-6.** A task in Phases 1-6 whose acceptance fails is fixed and re-run in place; it does not restart Phase 0.

---

### Phase 0 — Policy reads, scope anchor, and baseline capture

- [x] [P0-T1] Read the policy files in this order and write `docs/features/active/epic-planner-receipt-checks-key-gate-543/evidence/baseline/phase0-instructions-read.<timestamp>.md`: `CLAUDE.md`, `.claude/rules/general-code-change.md`, `.claude/rules/general-unit-test.md`, `.claude/rules/python.md`, `.claude/rules/python-suppressions.md`, `.claude/rules/typescript.md`, `.claude/rules/typescript-suppressions.md`, `.claude/rules/quality-tiers.md`, `.claude/skills/evidence-and-timestamp-conventions/SKILL.md`.
  - Acceptance: the artifact exists and contains `Timestamp:`, `Policy Order: CLAUDE.md -> general code change -> general unit test -> Python (code, suppressions) -> TypeScript (code, suppressions) -> quality tiers -> evidence conventions`, and `Files Read:` listing the nine paths in that order. No Phase 1 task begins before this artifact exists.

- [x] [P0-T2] Read `spec.md`, `issue.md`, and `research/research.2026-10-15T08-05.md` in `docs/features/active/epic-planner-receipt-checks-key-gate-543/` and write `docs/features/active/epic-planner-receipt-checks-key-gate-543/evidence/baseline/scope-confirmation.<timestamp>.md`.
  - Acceptance: the artifact contains `Timestamp:`, the six code paths and two conditional paths from "Files the diff will WRITE", the out-of-scope list from "Explicitly out of scope", `Work Mode: full-bug`, `AC source: spec.md`, and `AC count: 18`.

- [x] [P0-T3] Record the scope anchor in `docs/features/active/epic-planner-receipt-checks-key-gate-543/evidence/baseline/scope-anchor.<timestamp>.md` by running `git rev-parse --abbrev-ref HEAD`, `git rev-parse main`, `git merge-base HEAD main`, and `git status --porcelain` in the Bash tool from the worktree root.
  - Acceptance: `docs/features/active/epic-planner-receipt-checks-key-gate-543/evidence/baseline/scope-anchor.<timestamp>.md` exists with the four fields; `Output Summary:` records the branch name `bug/epic-planner-receipt-checks-key-gate-543`, the `git rev-parse main` SHA, the merge-base SHA on its own line as `MAIN_BASE_SHA: <sha>`, and the porcelain output verbatim. The porcelain output lists no path outside `docs/features/active/epic-planner-receipt-checks-key-gate-543/`; if it lists any other path, stop and report to the orchestrator before Phase 1.

- [x] [P0-T4] Create the scratch directory and confirm the toolchains: run `mkdir -p SCRATCH/543` (with the scratchpad path substituted for `SCRATCH`), `poetry run python --version`, and `ls extensions/drm-copilot/node_modules/jest/package.json extensions/drm-copilot/node_modules/prettier/package.json` in the Bash tool; if `ls` reports either path missing, run `npm --prefix extensions/drm-copilot ci` and repeat the `ls`.
  - Acceptance: `docs/features/active/epic-planner-receipt-checks-key-gate-543/evidence/baseline/toolchain-availability.<timestamp>.md` exists with the four fields; `Output Summary:` records the `Python 3.` version line, both `package.json` paths printed by the final `ls`, and the `added N packages` line when `npm ci` ran. Any other result stops the plan before Phase 1.

- [x] [P0-T5] Write the batch-budget record to `docs/features/active/epic-planner-receipt-checks-key-gate-543/evidence/other/batch-budget.<timestamp>.md`.
  - Acceptance: the artifact exists with `Timestamp:`, `Python production files: 1 (scripts/dev_tools/validate_epic_planner_state.py)`, `Python test files: 2 (not counted by the hook)`, `TypeScript files: 4, plus 2 conditional (no batch-budget hook)`, the cap source (`.claude/hooks/enforce-python-batch-budget.ps1` lines 10-14 and 25-29), and `Resets scheduled: 0`.

- [x] [P0-T6] Record baseline physical line counts by running `grep -c -e '' <path>` in the Bash tool from the worktree root once for each of `scripts/dev_tools/validate_epic_planner_state.py`, `extensions/drm-copilot/src/lib/validate/epic-planner-state-core.ts`, `tests/scripts/dev_tools/test_validate_epic_planner_state.py`, and `extensions/drm-copilot/test/lib/validate/validate-orchestration-service-call.test.ts`.
  - Acceptance: `docs/features/active/epic-planner-receipt-checks-key-gate-543/evidence/baseline/line-counts.<timestamp>.md` exists with the four fields and an `Output Summary:` listing four counts. Planning-time values: 375, 474, 424, 232. A differing count means the tree moved since planning; every line number cited in Phases 1-5 is then re-located by construct (function name and quoted statement) before editing, and the differences are listed in the artifact. The artifact carries `Equivalent-To: (Get-Content <path>).Count`.

- [x] [P0-T7] Capture the Python formatting baseline by running `poetry run black --check scripts/dev_tools/validate_epic_planner_state.py tests/scripts/dev_tools/test_validate_epic_planner_state.py`.
  - Check mode only; no source is written.
  - Acceptance: `docs/features/active/epic-planner-receipt-checks-key-gate-543/evidence/baseline/baseline-python-format.<timestamp>.md` exists with the four fields and an `Output Summary:` recording the Black summary line (on a clean pair it reads `All done!` followed by `2 files would be left unchanged.`). Stop condition: a non-zero exit stops the plan before Phase 1.

- [x] [P0-T8] Capture the Python lint baseline by running `poetry run ruff check scripts/dev_tools/validate_epic_planner_state.py tests/scripts/dev_tools/test_validate_epic_planner_state.py`.
  - The `[tool.ruff]` table in `pyproject.toml` (lines 88-91) sets no `fix = true`, so this command reports and does not rewrite.
  - Acceptance: `docs/features/active/epic-planner-receipt-checks-key-gate-543/evidence/baseline/baseline-python-lint.<timestamp>.md` exists with the four fields and an `Output Summary:` recording `All checks passed!` or the numeric finding count. Stop condition: a non-zero exit stops the plan before Phase 1.

- [x] [P0-T9] Capture the Python type-check baseline by running `poetry run pyright scripts/dev_tools/validate_epic_planner_state.py tests/scripts/dev_tools/test_validate_epic_planner_state.py`.
  - Acceptance: `docs/features/active/epic-planner-receipt-checks-key-gate-543/evidence/baseline/baseline-python-typecheck.<timestamp>.md` exists with the four fields and an `Output Summary:` recording the Pyright summary line with numeric error, warning, and information counts (a clean run prints `0 errors, 0 warnings, 0 informations`). Stop condition: a non-zero exit stops the plan before Phase 1.

- [x] [P0-T10] Capture the Python targeted test and coverage baseline by running `poetry run pytest tests/scripts/dev_tools/test_validate_epic_planner_state.py tests/scripts/dev_tools/test_validate_epic_planner_state_launch_binding.py tests/scripts/dev_tools/test_epic_planner_readiness.py tests/scripts/dev_tools/test_push_down_codex_and_agents_customizations.py --cov=scripts.dev_tools.validate_epic_planner_state --cov-branch --cov-report=term-missing` (the spec's command without the not-yet-created new file).
  - Acceptance: `docs/features/active/epic-planner-receipt-checks-key-gate-543/evidence/baseline/baseline-python-targeted-coverage.<timestamp>.md` exists with the four fields and an `Output Summary:` recording the pytest result line (passed and failed counts) and the `term-missing` row for `scripts/dev_tools/validate_epic_planner_state.py` verbatim (`Stmts`, `Miss`, `Branch`, `BrPart`, `Cover`, `Missing`). Stop condition: any failed test stops the plan before Phase 1.

- [x] [P0-T11] Capture the Python per-file baseline coverage by running `poetry run coverage json --data-file=artifacts/.coverage --include="*validate_epic_planner_state.py" --pretty-print -o SCRATCH/543/coverage-baseline.json` immediately after P0-T10 and reading the JSON.
  - Acceptance: `docs/features/active/epic-planner-receipt-checks-key-gate-543/evidence/baseline/baseline-python-per-file-coverage.<timestamp>.md` exists with the four fields and an `Output Summary:` recording, for `scripts/dev_tools/validate_epic_planner_state.py`, `covered_lines`/`num_statements` and `covered_branches`/`num_branches` from `files[<key>].summary` with both percentages to two decimals, and the `missing_lines` and `missing_branches` lists. No placeholders. Stop condition: a line percentage below 85.00 or a branch percentage below 75.00 at baseline stops the plan before Phase 1 and is reported to the orchestrator.

- [x] [P0-T12] Capture the Python full-suite baseline by running `poetry run pytest -q --deselect tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py::test_bundled_claude_payload_contains_all_repo_runtime_contracts` from the worktree root.
  - Acceptance: `docs/features/active/epic-planner-receipt-checks-key-gate-543/evidence/baseline/baseline-python-full-suite.<timestamp>.md` exists with the four fields and an `Output Summary:` recording the pytest result line (passed, failed, skipped, and deselected counts; deselected must be 1, citing #510) and the node ID of every failed test (or `Failed: none`). A pre-existing failure does not stop the plan; it is recorded so that P7-T8 can require that no new failure appears.

- [x] [P0-T13] Capture the TypeScript formatting baseline by running `npx prettier --check src/lib/validate/epic-planner-state-core.ts test/lib/validate/validate-orchestration-service-call.test.ts` in `extensions/drm-copilot/`.
  - Check mode only; no source is written.
  - Acceptance: `docs/features/active/epic-planner-receipt-checks-key-gate-543/evidence/baseline/baseline-typescript-format.<timestamp>.md` exists with the four fields and an `Output Summary:` recording `All matched files use Prettier code style!` or the list of files reported. Stop condition: a non-zero exit stops the plan before Phase 1.

- [x] [P0-T14] Capture the TypeScript lint baseline by running `npm run lint` in `extensions/drm-copilot/` (script at `extensions/drm-copilot/package.json` line 208; no `--fix`).
  - Acceptance: `docs/features/active/epic-planner-receipt-checks-key-gate-543/evidence/baseline/baseline-typescript-lint.<timestamp>.md` exists with the four fields and an `Output Summary:` recording numeric error and warning counts (0 and 0 when ESLint prints no problem lines). Stop condition: a non-zero exit stops the plan before Phase 1.

- [x] [P0-T15] Capture the TypeScript type-check baseline by running `npm run typecheck` in `extensions/drm-copilot/` (script at `extensions/drm-copilot/package.json` lines 209-210).
  - Acceptance: `docs/features/active/epic-planner-receipt-checks-key-gate-543/evidence/baseline/baseline-typescript-typecheck.<timestamp>.md` exists with the four fields and an `Output Summary:` recording the count of `error TS` lines. Stop condition: a non-zero exit stops the plan before Phase 1.

- [x] [P0-T16] Capture the architecture-boundary baseline for both languages in `docs/features/active/epic-planner-receipt-checks-key-gate-543/evidence/baseline/baseline-architecture.<timestamp>.md` by running `git ls-files -- "*.dependency-cruiser*" "*importlinter*" ".importlinter"` and `grep -c -F -e importlinter pyproject.toml` in the Bash tool from the worktree root.
  - Acceptance: `docs/features/active/epic-planner-receipt-checks-key-gate-543/evidence/baseline/baseline-architecture.<timestamp>.md` exists with the four fields and an `Output Summary:` stating either `no architecture-boundary tool configured for TypeScript or Python; stage not applicable` (first command prints nothing; second prints `0`, exit 1 by design, because the literal `importlinter` is expected to be absent from `pyproject.toml`) or listing each configuration found. If a configuration is found, the summary records the command that runs it and its violation count, and that command becomes the architecture stage in P7-T4 and P8-T4.

- [x] [P0-T17] Capture the TypeScript full-suite test and coverage baseline by running `node run-jest.cjs --coverage --coverageReporters=text --coverageReporters=text-summary` in `extensions/drm-copilot/`.
  - Acceptance: `docs/features/active/epic-planner-receipt-checks-key-gate-543/evidence/baseline/baseline-typescript-test-coverage.<timestamp>.md` exists with the four fields and an `Output Summary:` recording the `Test Suites:` and `Tests:` lines verbatim, the text-summary `Lines` and `Branches` totals, and the `text` table row for `epic-planner-state-core.ts` (`% Stmts | % Branch | % Funcs | % Lines | Uncovered Line #s`) verbatim. No placeholders. Stop conditions: a non-zero exit or any failed test stops the plan before Phase 1; a `% Lines` below 85 or `% Branch` below 75 on that row stops the plan before Phase 1 and is reported to the orchestrator.

- [x] [P0-T18] Capture the TypeScript targeted baseline by running `node run-jest.cjs test/lib/validate/epic-planner-state-core.test.ts test/lib/validate/epic-planner-state-launch-binding.test.ts test/lib/validate/epic-planner-readiness-integrity.test.ts test/lib/validate/validate-orchestration-service-call.test.ts test/lib/validate/orchestration-artifacts.test.ts` in `extensions/drm-copilot/` (the spec's targeted command without the not-yet-created new file; no `--coverage`, because per-file `coverageThreshold` entries fail a subset coverage run).
  - Acceptance: `docs/features/active/epic-planner-receipt-checks-key-gate-543/evidence/baseline/baseline-typescript-targeted.<timestamp>.md` exists with the four fields and an `Output Summary:` recording `Test Suites: 5 passed, 5 total` and the `Tests:` line with 0 failed. Stop condition: any failure stops the plan before Phase 1.

- [x] [P0-T19] Record the baseline checkbox state of `docs/features/active/epic-planner-receipt-checks-key-gate-543/spec.md` by running `grep -c -e '^- \[ \] ' docs/features/active/epic-planner-receipt-checks-key-gate-543/spec.md` and `grep -c -e '^- \[x\] ' docs/features/active/epic-planner-receipt-checks-key-gate-543/spec.md` in the Bash tool.
  - Acceptance: `docs/features/active/epic-planner-receipt-checks-key-gate-543/evidence/baseline/baseline-spec-checkboxes.<timestamp>.md` exists with the four fields and an `Output Summary:` recording `18` unchecked and `0` checked (the 18 acceptance criteria at lines 221-238 are the only checkboxes in the file at planning time; the second command exits 1 by design).

- [x] [P0-T20] Commit and push Phase 0: run `git add docs/features/active/epic-planner-receipt-checks-key-gate-543`, `git commit -m "docs(543): record plan and phase 0 baselines for receipt-checks key gate"` (with the required trailers), and `git push origin bug/epic-planner-receipt-checks-key-gate-543`.
  - Acceptance: the commit and push exit 0; afterwards `git status --porcelain` prints nothing and `git rev-parse HEAD` equals `git rev-parse origin/bug/epic-planner-receipt-checks-key-gate-543`.

### Phase 1 — Fail-before regression tests

- [x] [P1-T1] Create `tests/scripts/dev_tools/test_validate_epic_planner_state_feature_receipts.py` containing only what the regression test uses:
  - Module docstring `"""Tests for the per-feature receipt key gate in the epic-planner ready gate."""`, then `from __future__ import annotations`, `import json`, `from typing import Any`, and `from scripts.dev_tools.validate_epic_planner_state import validate_epic_planner_state_text` (wrapped in parentheses by Black as at `tests/scripts/dev_tools/test_validate_epic_planner_state_launch_binding.py` lines 13-15).
  - The constant `REPOSITORY_CONTEXT_ERROR = (` / `"Execution-ready planner validation requires repository context."` / `)`.
  - `_claude_feature(issue_num: int, *, depends_on: list[int] | None = None) -> dict[str, Any]` returning only the nine `REQUIRED_FEATURE_KEYS` (`scripts/dev_tools/validate_epic_planner_state.py` lines 47-57) with the values used at `tests/scripts/dev_tools/test_validate_epic_planner_state.py` lines 40-48 (`complexity_band` `"C3"`, `preparation_status` `"prepared"`, `preflight_status` `"PREFLIGHT: ALL CLEAR"`, `wave` `0` when `depends_on` is empty and `1` otherwise); no launch-binding key and no receipt key.
  - `_claude_state() -> dict[str, Any]` returning the `_ready_state()` shape at `tests/scripts/dev_tools/test_validate_epic_planner_state.py` lines 71-82 with `"features": [_claude_feature(101), _claude_feature(102, depends_on=[101])]` and no top-level `topology_receipt` key.
  - `_ready_errors(state: dict[str, Any], *, require_codex_model_routing: bool = False, require_codex_topology: bool = False) -> list[str]` calling `validate_epic_planner_state_text(json.dumps(state), require_ready_for_execution=True, require_codex_model_routing=require_codex_model_routing, require_codex_topology=require_codex_topology)` with no readiness context.
  - `test_ready_gate_skips_feature_receipts_when_keys_absent() -> None` with the docstring `"""Skip absent per-feature receipts for a Claude checkpoint without a Codex flag."""`, whose body is `errors = _ready_errors(_claude_state())` followed by the single assertion `assert errors == [REPOSITORY_CONTEXT_ERROR]`.
  - Every helper and constant defined in this file is used by this test, so no unused private function exists.
  - Acceptance: `poetry run pytest --collect-only -q tests/scripts/dev_tools/test_validate_epic_planner_state_feature_receipts.py` exits 0 and lists exactly `tests/scripts/dev_tools/test_validate_epic_planner_state_feature_receipts.py::test_ready_gate_skips_feature_receipts_when_keys_absent`.

- [x] [P1-T2] [expect-fail] Run `poetry run pytest "tests/scripts/dev_tools/test_validate_epic_planner_state_feature_receipts.py::test_ready_gate_skips_feature_receipts_when_keys_absent" -vv` on pre-fix production code.
  - Acceptance: `docs/features/active/epic-planner-receipt-checks-key-gate-543/evidence/regression-testing/fail-before-python.<timestamp>.md` exists with `Timestamp:`, `Command:`, `EXIT_CODE: 1`, `ExpectedExitCode: 1`, and an `Output Summary:` showing `1 failed` and 0 passed for that node, and quoting the assertion diff lines that contain `features[0].model_routing_receipt must be an object.` and `features[0].topology_receipt must be an object.` A failure for any other reason (import error, collection error, fixture error) does not satisfy this task; fix the test and re-run.

- [x] [P1-T3] Create `extensions/drm-copilot/test/lib/validate/epic-planner-state-feature-receipts.test.ts` containing only what the regression twin uses:
  - Imports: `import { describe, expect, it } from "@jest/globals";` and `import { validateEpicPlannerStateText } from "../../../src/lib/validate/epic-planner-state-core";` (the forms at `extensions/drm-copilot/test/lib/validate/epic-planner-state-core.test.ts` lines 1 and 4).
  - `const REPOSITORY_CONTEXT_ERROR = "Execution-ready planner validation requires repository context.";` (one unbroken literal; Prettier may break after `=`).
  - `function claudeFeature(issueNum: number, overrides: Readonly<Record<string, unknown>> = {}): Record<string, unknown>` returning the nine required feature keys with the values at `extensions/drm-copilot/test/lib/validate/epic-planner-state-core.test.ts` lines 42-50, spread with `...overrides`; no launch-binding key and no receipt key.
  - `function claudeState(features: ReadonlyArray<Record<string, unknown>>): Record<string, unknown>` returning the `readyState()` shape at `extensions/drm-copilot/test/lib/validate/epic-planner-state-core.test.ts` lines 69-81 with `features: [...features]` and no `topology_receipt` key.
  - Inside `describe("validateEpicPlannerStateText per-feature receipt key gate", () => { ... })`, the test `it("skips the per-feature receipts when the keys are absent without a Codex flag", () => { ... })`: build `claudeState([claudeFeature(101), claudeFeature(102, { depends_on: [101], wave: 1 })])`, call `validateEpicPlannerStateText(JSON.stringify(state), { requireReadyForExecution: true })`, and assert `expect(errors).toEqual([REPOSITORY_CONTEXT_ERROR]);`. Separate the arrange, act, and assert sections with single blank lines.
  - Every declaration in this file is used by this test (the extension compiles with `noUnusedLocals`, `extensions/drm-copilot/tsconfig.json` line 12).
  - Acceptance: the file exists with that `describe` title and that test title; it uses only options that exist on pre-fix `ValidateEpicPlannerStateOptions` (`epic-planner-state-core.ts` lines 51-60), so it fails behaviourally rather than at compile time.

- [x] [P1-T4] [expect-fail] Run `node run-jest.cjs test/lib/validate/epic-planner-state-feature-receipts.test.ts` in `extensions/drm-copilot/` on pre-fix production code (the spec AC2 command).
  - Acceptance: `docs/features/active/epic-planner-receipt-checks-key-gate-543/evidence/regression-testing/fail-before-typescript.<timestamp>.md` exists with `Timestamp:`, `Command:`, `EXIT_CODE: 1`, `ExpectedExitCode: 1`, and an `Output Summary:` showing `Tests:` with `1 failed` and `1 total`, zero `error TS` lines, and the Jest received-value output containing `features[0].model_routing_receipt must be an object.` and `features[0].topology_receipt must be an object.`

- [x] [P1-T5] Commit and push Phase 1: run `git add tests/scripts/dev_tools/test_validate_epic_planner_state_feature_receipts.py extensions/drm-copilot/test/lib/validate/epic-planner-state-feature-receipts.test.ts docs/features/active/epic-planner-receipt-checks-key-gate-543`, `git commit -m "test(543): add fail-before regression tests for per-feature receipt key gate"` (with the required trailers), and `git push origin bug/epic-planner-receipt-checks-key-gate-543`.
  - Acceptance: the commit and push exit 0; afterwards `git status --porcelain` prints nothing and `git rev-parse HEAD` equals `git rev-parse origin/bug/epic-planner-receipt-checks-key-gate-543`.

### Phase 2 — Python minimal fix

- [x] [P2-T1] Update `scripts/dev_tools/validate_epic_planner_state.py`:
  - Add `def _validate_feature_model_receipt(feature: dict[str, Any], *, prefix: str) -> list[str]:` (Black wraps the signature) directly above `_validate_ready_features`, with the docstring `"""Validate one prepared child's orchestrator model routing receipt."""`, a local `errors: list[str] = []`, the statements of planning-time lines 241-269 moved verbatim (only their indentation changes), and `return errors`.
  - Change the `_validate_ready_features` signature to take `features: list[dict[str, Any]], *, key_gated: bool = False`, written without a trailing comma, so Black wraps it to the three-line form `def _validate_ready_features(` / that parameter line / `) -> list[str]:`.
  - In the loop, replace planning-time lines 241-275 with `if not key_gated or "model_routing_receipt" in feature:` followed by `errors.extend(_validate_feature_model_receipt(feature, prefix=prefix))`, then `if not key_gated or "topology_receipt" in feature:` followed by the existing `_validate_child_topology_receipt(feature.get("topology_receipt"), prefix=f"{prefix}.topology_receipt")` call inside `errors.extend(...)`, unchanged apart from indentation.
  - Change the call at planning-time line 342 to `errors.extend(_validate_ready_features(features, key_gated=key_gated))`.
  - Leave every error string, the `key_gated` assignment (line 332), the lines `validate_epic_planner_child_launch_bindings(` and `features, require_launch_paths=key_gated` (lines 344-345), the planner topology gate (lines 348-351), and the non-Codex checks (lines 226-240) unchanged.
  - Acceptance: `grep -c -F -e 'if not key_gated or "model_routing_receipt" in feature:' -e 'if not key_gated or "topology_receipt" in feature:' -e 'errors.extend(_validate_ready_features(features, key_gated=key_gated))' scripts/dev_tools/validate_epic_planner_state.py` prints `3` (it prints `0` before this task); `poetry run black --check scripts/dev_tools/validate_epic_planner_state.py` exits 0 printing `1 file would be left unchanged.` (if it fails, run `poetry run black scripts/dev_tools/validate_epic_planner_state.py`, which prints `reformatted scripts/dev_tools/validate_epic_planner_state.py` and `1 file reformatted.`, then re-run the check); `poetry run ruff check scripts/dev_tools/validate_epic_planner_state.py` prints `All checks passed!`.

- [x] [P2-T2] Update the documentation in `scripts/dev_tools/validate_epic_planner_state.py` with exactly the text in the three blocks below (each block line carries four leading spaces of list indentation that are not part of the text; the remaining indentation is the source indentation):
  - Replace the `_validate_ready_features` one-line docstring (planning-time line 223) with:

    ```text
        """Require every child to be fully prepared and preflight-cleared.

        When ``key_gated`` is true (no Codex flag), each per-feature receipt check
        runs only for a feature that carries its key (``model_routing_receipt``,
        ``topology_receipt``).
        """
    ```

  - Replace the docstring paragraph at planning-time lines 289-293 with:

    ```text
        ``require_codex_model_routing`` and ``require_codex_topology`` make launch
        evidence, the per-feature receipt checks, and the planner ``topology_receipt``
        unconditional under execution readiness. When neither is set, launch evidence
        is validated only for features that carry a launch path key, the per-feature
        ``model_routing_receipt`` and ``topology_receipt`` checks only for features
        that carry that key, and the planner receipt only when the checkpoint carries
        a top-level ``topology_receipt`` key.
    ```

  - Replace the comment at planning-time lines 330-331 with:

    ```text
            # Launch evidence and the per-feature receipt checks
            # (model_routing_receipt, topology_receipt) are key-gated per feature, and
            # the planner topology receipt by its top-level key, unless a Codex flag
            # is asserted.
    ```

  - No added docstring or comment line contains `Epic planner`, `must be`, or `must match` (P6-T2 depends on this). Every line above is at most 88 columns.
  - Acceptance: `grep -c -F -e 'per-feature receipt' scripts/dev_tools/validate_epic_planner_state.py` prints `3` (it prints `0` before this task); `poetry run ruff check scripts/dev_tools/validate_epic_planner_state.py` prints `All checks passed!`.

- [x] [P2-T3] Record the Python pass-after run by running `poetry run pytest "tests/scripts/dev_tools/test_validate_epic_planner_state_feature_receipts.py::test_ready_gate_skips_feature_receipts_when_keys_absent" -vv`.
  - Acceptance: `docs/features/active/epic-planner-receipt-checks-key-gate-543/evidence/regression-testing/pass-after-python.<timestamp>.md` exists with `Timestamp:`, `Command:`, `EXIT_CODE: 0`, and an `Output Summary:` showing `1 passed` for that node and naming the P1-T2 artifact as the paired fail-before run.

- [x] [P2-T4] Run the existing Python validator suites against the fix: `poetry run pytest tests/scripts/dev_tools/test_validate_epic_planner_state.py tests/scripts/dev_tools/test_validate_epic_planner_state_launch_binding.py tests/scripts/dev_tools/test_epic_planner_readiness.py tests/scripts/dev_tools/test_push_down_codex_and_agents_customizations.py tests/scripts/dev_tools/test_validate_epic_planner_state_feature_receipts.py -q`.
  - Acceptance: `docs/features/active/epic-planner-receipt-checks-key-gate-543/evidence/regression-testing/python-post-fix-suite.<timestamp>.md` exists with `Timestamp:`, `Command:`, `EXIT_CODE: 0`, and an `Output Summary:` recording the result line with 0 failed and a passed count equal to the P0-T10 passed count plus 1.

- [x] [P2-T5] Commit and push Phase 2: run `git add scripts/dev_tools/validate_epic_planner_state.py docs/features/active/epic-planner-receipt-checks-key-gate-543`, `git commit -m "fix(543): key-gate per-feature receipt checks in Python planner ready gate"` (with the required trailers), and `git push origin bug/epic-planner-receipt-checks-key-gate-543`.
  - Acceptance: the commit and push exit 0; afterwards `git status --porcelain` prints nothing and `git rev-parse HEAD` equals `git rev-parse origin/bug/epic-planner-receipt-checks-key-gate-543`.

### Phase 3 — TypeScript minimal fix

- [x] [P3-T1] Update `extensions/drm-copilot/src/lib/validate/epic-planner-state-core.ts`:
  - Add the second parameter line `keyGated: boolean,` to `validateReadyFeatures` (planning-time lines 292-294).
  - Wrap planning-time lines 329-354 (the model-receipt block, from `const receipt = feature["model_routing_receipt"];` through the closing brace of `if (isObject(receipt)) {`) in `if (!keyGated || "model_routing_receipt" in feature) {` ... `}`, and planning-time lines 355-360 (the `validateChildTopologyReceipt` push) in `if (!keyGated || "topology_receipt" in feature) {` ... `}`, re-indenting only.
  - Change the call at planning-time line 438 so its argument list is `featureResult.features, requireLaunchPaths` (Prettier lays it out as `errors.push(` / `...validateReadyFeatures(featureResult.features, requireLaunchPaths),` / `);`).
  - Leave every error string, the `requireLaunchPaths` assignment (lines 425-427), the launch-binding call (lines 439-443), the planner topology gate (lines 444-446), and the non-Codex checks (lines 296-327) unchanged. Do not rename `requireLaunchPaths`.
  - Acceptance: `grep -c -F -e 'if (!keyGated || "model_routing_receipt" in feature) {' -e 'if (!keyGated || "topology_receipt" in feature) {' -e 'keyGated: boolean,' extensions/drm-copilot/src/lib/validate/epic-planner-state-core.ts` prints `3` (it prints `0` before this task).

- [x] [P3-T2] Update the documentation in `extensions/drm-copilot/src/lib/validate/epic-planner-state-core.ts` with exactly the text in the two blocks below (each block line carries four leading spaces of list indentation that are not part of the text; the remaining indentation is the source indentation):
  - Replace the one-line comment at planning-time line 291 with:

    ```text
    /**
     * Require every child to be fully prepared and preflight-cleared. When
     * `keyGated` is true (no Codex flag), each per-feature receipt check runs only
     * for a feature that carries its key (`model_routing_receipt`,
     * `topology_receipt`).
     */
    ```

  - Replace the comment at planning-time lines 423-424 with:

    ```text
        // Launch evidence and the per-feature receipt checks
        // (model_routing_receipt, topology_receipt) are key-gated per feature, and
        // the planner topology receipt by its top-level key, unless a Codex flag
        // is asserted.
    ```

  - No added comment line contains `Epic planner`, `must be`, or `must match`. Every line above is at most 80 columns.
  - Acceptance: `grep -c -F -e 'per-feature receipt' extensions/drm-copilot/src/lib/validate/epic-planner-state-core.ts` prints `2` (it prints `0` before this task).

- [x] [P3-T3] Format and measure `extensions/drm-copilot/src/lib/validate/epic-planner-state-core.ts`, then apply the line-budget decision rule (research section 7.3):
  - Run `npx prettier --check src/lib/validate/epic-planner-state-core.ts` in `extensions/drm-copilot/`. If it reports the file, run `npx prettier --write src/lib/validate/epic-planner-state-core.ts` (its output line for the file names the file without the `(unchanged)` suffix when it rewrote it) and re-run the check until it prints `All matched files use Prettier code style!`.
  - Then run `grep -c -e '' extensions/drm-copilot/src/lib/validate/epic-planner-state-core.ts` in the Bash tool from the worktree root.
  - Decision rule: a count at or below 500 records `Contingency: not triggered`; a count above 500 records `Contingency: triggered`, and P3-T4 then performs the extraction.
  - Acceptance: `docs/features/active/epic-planner-receipt-checks-key-gate-543/evidence/other/ts-line-budget.<timestamp>.md` exists with the four fields and an `Output Summary:` recording the final Prettier check line, the measured count (planning estimate 488), and exactly one of `Contingency: not triggered` or `Contingency: triggered`.

- [x] [P3-T4] Apply the line-budget contingency only when the P3-T3 artifact records `Contingency: triggered`. When it records `Contingency: not triggered`, this task creates no file and is complete once `docs/features/active/epic-planner-receipt-checks-key-gate-543/evidence/other/ts-contingency.<timestamp>.md` records `Contingency: not triggered; no file created`.
  - Triggered branch: create `extensions/drm-copilot/src/lib/validate/epic-planner-ready-features.ts` and move into it, unchanged apart from adding `export`, `isObject` (planning-time lines 62-65), `pythonRepr` (lines 67-81), `validateExpectedTopologyFields` (lines 83-100), `validateChildTopologyReceipt` (lines 116-127), and `validateReadyFeatures` with its JSDoc; import `validateCodexModelRoutingReceipt` and `validateCodexTopologyReceipt` there; in `epic-planner-state-core.ts`, delete the moved declarations, import `isObject`, `pythonRepr`, `validateExpectedTopologyFields`, and `validateReadyFeatures` from `./epic-planner-ready-features`, and remove the `validateCodexModelRoutingReceipt` and `validateCodexTopologyReceipt` imports (lines 12-13) that the core file no longer uses (`noUnusedLocals`). Create the mirrored test `extensions/drm-copilot/test/lib/validate/epic-planner-ready-features.test.ts` with two tests calling `validateReadyFeatures` directly on two receipt-less features: with `keyGated` `true` the result contains no string containing `.model_routing_receipt` or `.topology_receipt`; with `keyGated` `false` it contains `Epic planner checkpoint features[0].model_routing_receipt must be an object.` Run `npx prettier --check` on both new files and the core file in `extensions/drm-copilot/` until it prints `All matched files use Prettier code style!` (repairing with `npx prettier --write` on the reported files, whose output names each rewritten file without the `(unchanged)` suffix), then `grep -c -e '' <path>` in the Bash tool from the worktree root for each of the three files.
  - Acceptance (triggered branch): the `ts-contingency` artifact records the three line counts, each at or below 500; `node run-jest.cjs test/lib/validate/epic-planner-ready-features.test.ts test/lib/validate/epic-planner-state-core.test.ts` in `extensions/drm-copilot/` exits 0 with 0 failed; `npm run typecheck` in `extensions/drm-copilot/` exits 0. From this point every later task that lists TypeScript production or test paths also includes the two contingency paths, and the P3-T1 and P3-T2 `grep` tokens are counted across the core file and `epic-planner-ready-features.ts` together.

- [x] [P3-T5] Record the TypeScript pass-after run by running `node run-jest.cjs test/lib/validate/epic-planner-state-feature-receipts.test.ts` in `extensions/drm-copilot/`.
  - Acceptance: `docs/features/active/epic-planner-receipt-checks-key-gate-543/evidence/regression-testing/pass-after-typescript.<timestamp>.md` exists with `Timestamp:`, `Command:`, `EXIT_CODE: 0`, and an `Output Summary:` showing `Tests:` with `1 passed` and 0 failed, and naming the P1-T4 artifact as the paired fail-before run.

- [x] [P3-T6] Run the existing TypeScript validator suites against the fix: `node run-jest.cjs test/lib/validate/epic-planner-state-core.test.ts test/lib/validate/epic-planner-state-launch-binding.test.ts test/lib/validate/epic-planner-readiness-integrity.test.ts test/lib/validate/validate-orchestration-service-call.test.ts test/lib/validate/orchestration-artifacts.test.ts test/lib/validate/epic-planner-state-feature-receipts.test.ts` in `extensions/drm-copilot/`.
  - Acceptance: `docs/features/active/epic-planner-receipt-checks-key-gate-543/evidence/regression-testing/typescript-post-fix-suite.<timestamp>.md` exists with `Timestamp:`, `Command:`, `EXIT_CODE: 0`, and an `Output Summary:` recording `Test Suites: 6 passed, 6 total` and the `Tests:` line with 0 failed and a passed count equal to the P0-T18 passed count plus 1.

- [x] [P3-T7] Commit and push Phase 3: run `git add extensions/drm-copilot/src/lib/validate/epic-planner-state-core.ts docs/features/active/epic-planner-receipt-checks-key-gate-543` (plus the two contingency paths when P3-T4 created them), `git commit -m "fix(543): key-gate per-feature receipt checks in TypeScript planner ready gate"` (with the required trailers), and `git push origin bug/epic-planner-receipt-checks-key-gate-543`.
  - Acceptance: the commit and push exit 0; afterwards `git status --porcelain` prints nothing and `git rev-parse HEAD` equals `git rev-parse origin/bug/epic-planner-receipt-checks-key-gate-543`.

### Phase 4 — Python tests for the remaining matrix rows

- [x] [P4-T1] Add `test_codex_flag_keeps_feature_receipts_unconditional` to `tests/scripts/dev_tools/test_validate_epic_planner_state_feature_receipts.py`, together with the declarations it is the first to use:
  - Imports `import pytest`, `from scripts.dev_tools.resolve_codex_deployment import resolve_codex_deployment`, and `from scripts.dev_tools.resolve_codex_topology import resolve_codex_topology`.
  - The constants `MODEL_RECEIPT_OBJECT_ERROR` and `TOPOLOGY_RECEIPT_OBJECT_ERROR`, each spelled as `NAME = (` / one literal line / `)` with the values under "Named tests and literals".
  - `_with_receipts(feature: dict[str, Any]) -> dict[str, Any]`, which reads `issue_num = feature["issue_num"]` and sets `feature["model_routing_receipt"]` to `dict(resolve_codex_deployment("orchestrator", "C3", "epic_preparation_child", "C3"))` with `phase` `f"prepare-feature-{issue_num}"` and `delegation_id` `f"prepare-feature-{issue_num}"`, and `feature["topology_receipt"]` to `dict(resolve_codex_topology(["python"], 1, 1, "epic_preparation_child"))` with the same `phase` (the receipts built at `tests/scripts/dev_tools/test_validate_epic_planner_state.py` lines 27-38), and returns the feature.
  - `_state_with_receipts() -> dict[str, Any]` returning `_claude_state()` with `_with_receipts` applied to both features.
  - The test, decorated with `@pytest.mark.parametrize("flag", ["require_codex_model_routing", "require_codex_topology"])`, pops both receipt keys from `features[0]` of `_state_with_receipts()`, calls `_ready_errors(state, require_codex_model_routing=flag == "require_codex_model_routing", require_codex_topology=flag == "require_codex_topology")`, and asserts `MODEL_RECEIPT_OBJECT_ERROR in errors` and `TOPOLOGY_RECEIPT_OBJECT_ERROR in errors`. One-line docstring.
  - Acceptance: `poetry run pytest tests/scripts/dev_tools/test_validate_epic_planner_state_feature_receipts.py -k test_codex_flag_keeps_feature_receipts_unconditional -v` exits 0 with `2 passed`.

- [x] [P4-T2] Add `test_ready_gate_validates_present_null_feature_receipt` to `tests/scripts/dev_tools/test_validate_epic_planner_state_feature_receipts.py`, decorated with `@pytest.mark.parametrize(("key", "expected"), [("model_routing_receipt", MODEL_RECEIPT_OBJECT_ERROR), ("topology_receipt", TOPOLOGY_RECEIPT_OBJECT_ERROR)], ids=["model_routing_receipt", "topology_receipt"])`.
  - Body: `state = _state_with_receipts()`; `state["features"][0][key] = None`; `errors = _ready_errors(state)` with no Codex flag; `assert expected in errors`. One-line docstring stating that a present null key still arms the check.
  - Acceptance: `poetry run pytest tests/scripts/dev_tools/test_validate_epic_planner_state_feature_receipts.py -k test_ready_gate_validates_present_null_feature_receipt -v` exits 0 with `2 passed`.

- [x] [P4-T3] Add `test_ready_gate_gates_each_feature_receipt_independently` to `tests/scripts/dev_tools/test_validate_epic_planner_state_feature_receipts.py`, together with the constants `LOGICAL_AGENT_ERROR` (the two implicit-concatenation pieces under "Named tests and literals", inside parentheses) and `FEATURE0_TOPOLOGY_TOKEN = "features[0].topology_receipt"`.
  - Body: `state = _state_with_receipts()`; `state["features"][0].pop("topology_receipt")`; `state["features"][0]["model_routing_receipt"]["logical_agent"] = "planner"`; `errors = _ready_errors(state)` with no Codex flag; `assert LOGICAL_AGENT_ERROR in errors`; `assert [error for error in errors if FEATURE0_TOPOLOGY_TOKEN in error] == []`. One-line docstring.
  - Acceptance: `poetry run pytest "tests/scripts/dev_tools/test_validate_epic_planner_state_feature_receipts.py::test_ready_gate_gates_each_feature_receipt_independently" -v` exits 0 with `1 passed`.

- [x] [P4-T4] Add `test_ready_gate_preserves_feature_index_when_receipts_skipped` to `tests/scripts/dev_tools/test_validate_epic_planner_state_feature_receipts.py`, together with the constants `SECOND_TOPOLOGY_RECEIPT_OBJECT_ERROR` and `FEATURE0_MODEL_TOKEN = "features[0].model_routing_receipt"` and, after all seven constants, `ASSERTED_MESSAGES = (REPOSITORY_CONTEXT_ERROR, MODEL_RECEIPT_OBJECT_ERROR, TOPOLOGY_RECEIPT_OBJECT_ERROR, LOGICAL_AGENT_ERROR, SECOND_TOPOLOGY_RECEIPT_OBJECT_ERROR, FEATURE0_TOPOLOGY_TOKEN, FEATURE0_MODEL_TOKEN)`.
  - Body: `state = _state_with_receipts()`; pop both receipt keys from `state["features"][0]`; `state["features"][1]["topology_receipt"] = None`; `errors = _ready_errors(state)` with no Codex flag; `assert SECOND_TOPOLOGY_RECEIPT_OBJECT_ERROR in errors`; `assert [error for error in errors if FEATURE0_TOPOLOGY_TOKEN in error or FEATURE0_MODEL_TOKEN in error] == []`. One-line docstring.
  - Acceptance: `poetry run pytest "tests/scripts/dev_tools/test_validate_epic_planner_state_feature_receipts.py::test_ready_gate_preserves_feature_index_when_receipts_skipped" -v` exits 0 with `1 passed`; `grep -c -e '' tests/scripts/dev_tools/test_validate_epic_planner_state_feature_receipts.py` prints a value at or below 500.

- [x] [P4-T5] Update `test_readiness_requires_resolved_child_model_receipt` in place in `tests/scripts/dev_tools/test_validate_epic_planner_state.py` (planning-time lines 176-188):
  - Add `require_codex_model_routing=True` to the `validate_epic_planner_state_text(...)` call (Black explodes the call to one argument per line).
  - Replace the assertion at planning-time line 187 with `expected = (` / `"Epic planner checkpoint features[0].model_routing_receipt must be an object."` / `)` followed by `assert expected in errors`, so every line stays within 88 columns.
  - Leave the docstring, the two state edits (lines 180-181), and the `.model must be 'gpt-5.6-sol'` assertion (line 188) unchanged. Change no other test in the file.
  - Acceptance: `poetry run pytest "tests/scripts/dev_tools/test_validate_epic_planner_state.py::test_readiness_requires_resolved_child_model_receipt" -v` exits 0 with `1 passed`; `grep -c -F -e 'any("model_routing_receipt must be an object" in error' tests/scripts/dev_tools/test_validate_epic_planner_state.py` prints `0` (exit 1 by design; it prints `1` before this task).

- [x] [P4-T6] Run the new Python file and the updated test: `poetry run pytest tests/scripts/dev_tools/test_validate_epic_planner_state_feature_receipts.py "tests/scripts/dev_tools/test_validate_epic_planner_state.py::test_readiness_requires_resolved_child_model_receipt" -v`.
  - Acceptance: `docs/features/active/epic-planner-receipt-checks-key-gate-543/evidence/regression-testing/python-feature-receipts-suite.<timestamp>.md` exists with `Timestamp:`, `Command:`, `EXIT_CODE: 0`, and an `Output Summary:` recording `8 passed` and 0 failed and listing as `PASSED` each of the seven node IDs under "Named tests and literals" for the new file plus `test_readiness_requires_resolved_child_model_receipt`.

- [x] [P4-T7] Commit and push Phase 4: run `git add tests/scripts/dev_tools/test_validate_epic_planner_state_feature_receipts.py tests/scripts/dev_tools/test_validate_epic_planner_state.py docs/features/active/epic-planner-receipt-checks-key-gate-543`, `git commit -m "test(543): cover per-feature receipt key gate matrix in Python"` (with the required trailers), and `git push origin bug/epic-planner-receipt-checks-key-gate-543`.
  - Acceptance: the commit and push exit 0; afterwards `git status --porcelain` prints nothing and `git rev-parse HEAD` equals `git rev-parse origin/bug/epic-planner-receipt-checks-key-gate-543`.

### Phase 5 — TypeScript twins and the MCP service-call assertions

- [x] [P5-T1] Add `it.each(codexFlagCases)("keeps the per-feature receipts unconditional under %p", (flags) => { ... })` inside the `describe` block of `extensions/drm-copilot/test/lib/validate/epic-planner-state-feature-receipts.test.ts`, together with the declarations it is the first to use:
  - Imports `import { resolveCodexTopology } from "../../../src/lib/validate/codex-topology-resolver";` and `import type { ValidateEpicPlannerStateOptions } from "../../../src/lib/validate/epic-planner-state-core";` (the forms at `extensions/drm-copilot/test/lib/validate/epic-planner-state-core.test.ts` lines 3 and 5).
  - `const MODEL_RECEIPT_OBJECT_ERROR` and `const TOPOLOGY_RECEIPT_OBJECT_ERROR` with the values under "Named tests and literals", each as one unbroken literal.
  - `modelReceipt(overrides)` identical to `extensions/drm-copilot/test/lib/validate/epic-planner-state-core.test.ts` lines 17-33; `topologyReceipt()` returning `{ ...resolveCodexTopology(["python"], 1, 1, "epic_preparation_child"), phase: "preparation" }`; `withReceipts(item: Record<string, unknown>): Record<string, unknown>` returning `{ ...item, model_routing_receipt: modelReceipt(), topology_receipt: topologyReceipt() }`.
  - `type CodexFlags = Pick<ValidateEpicPlannerStateOptions, "requireCodexModelRouting" | "requireCodexTopology">;` and `const codexFlagCases: readonly CodexFlags[] = [{ requireCodexModelRouting: true }, { requireCodexTopology: true }];` (the form at `epic-planner-state-core.test.ts` lines 85-93; required by `exactOptionalPropertyTypes`, `extensions/drm-copilot/tsconfig.json` line 14).
  - Body: build `const first = claudeFeature(101);` (no receipts) and `const second = withReceipts(claudeFeature(102, { depends_on: [101], wave: 1 }));`, call `validateEpicPlannerStateText(JSON.stringify(claudeState([first, second])), { requireReadyForExecution: true, ...flags })`, and assert `expect(errors).toContain(MODEL_RECEIPT_OBJECT_ERROR);` and `expect(errors).toContain(TOPOLOGY_RECEIPT_OBJECT_ERROR);`.
  - Acceptance: `node run-jest.cjs test/lib/validate/epic-planner-state-feature-receipts.test.ts -t "keeps the per-feature receipts unconditional"` in `extensions/drm-copilot/` exits 0 with `Tests:` showing `2 passed`.

- [x] [P5-T2] Add `it.each(presentNullCases)("validates a present null %s without a Codex flag", (key, expected) => { ... })` inside the `describe` block of `extensions/drm-copilot/test/lib/validate/epic-planner-state-feature-receipts.test.ts`, with `const presentNullCases: ReadonlyArray<readonly [string, string]> = [["model_routing_receipt", MODEL_RECEIPT_OBJECT_ERROR], ["topology_receipt", TOPOLOGY_RECEIPT_OBJECT_ERROR]];`.
  - Body: `const first = withReceipts(claudeFeature(101));`, `first[key] = null;`, `const second = withReceipts(claudeFeature(102, { depends_on: [101], wave: 1 }));`, call `validateEpicPlannerStateText(JSON.stringify(claudeState([first, second])), { requireReadyForExecution: true })`, and assert `expect(errors).toContain(expected);`.
  - Acceptance: `node run-jest.cjs test/lib/validate/epic-planner-state-feature-receipts.test.ts -t "validates a present null"` in `extensions/drm-copilot/` exits 0 with `Tests:` showing `2 passed`.

- [x] [P5-T3] Add `it("gates each per-feature receipt independently", () => { ... })` inside the `describe` block of `extensions/drm-copilot/test/lib/validate/epic-planner-state-feature-receipts.test.ts`, together with `const LOGICAL_AGENT_ERROR` (one unbroken literal) and `const FEATURE0_TOPOLOGY_TOKEN = "features[0].topology_receipt";`.
  - Body: `const first = withReceipts(claudeFeature(101));`, `delete first["topology_receipt"];`, `first["model_routing_receipt"] = modelReceipt({ logical_agent: "planner" });`, `const second = withReceipts(claudeFeature(102, { depends_on: [101], wave: 1 }));`, call the validator with `{ requireReadyForExecution: true }`, and assert `expect(errors).toContain(LOGICAL_AGENT_ERROR);` and `expect(errors.filter((error) => error.includes(FEATURE0_TOPOLOGY_TOKEN))).toEqual([]);`.
  - Acceptance: `node run-jest.cjs test/lib/validate/epic-planner-state-feature-receipts.test.ts -t "gates each per-feature receipt independently"` in `extensions/drm-copilot/` exits 0 with `Tests:` showing `1 passed`.

- [x] [P5-T4] Add `it("preserves the feature index when receipts are skipped", () => { ... })` inside the `describe` block of `extensions/drm-copilot/test/lib/validate/epic-planner-state-feature-receipts.test.ts`, together with `const SECOND_TOPOLOGY_RECEIPT_OBJECT_ERROR` and `const FEATURE0_MODEL_TOKEN = "features[0].model_routing_receipt";`.
  - Body: `const first = claudeFeature(101);` (no receipts), `const second = withReceipts(claudeFeature(102, { depends_on: [101], wave: 1 }));`, `second["topology_receipt"] = null;`, call the validator with `{ requireReadyForExecution: true }`, and assert `expect(errors).toContain(SECOND_TOPOLOGY_RECEIPT_OBJECT_ERROR);` and `expect(errors.filter((error) => error.includes(FEATURE0_TOPOLOGY_TOKEN) || error.includes(FEATURE0_MODEL_TOKEN))).toEqual([]);`.
  - Acceptance: `node run-jest.cjs test/lib/validate/epic-planner-state-feature-receipts.test.ts -t "preserves the feature index"` in `extensions/drm-copilot/` exits 0 with `Tests:` showing `1 passed`; `grep -c -e '' extensions/drm-copilot/test/lib/validate/epic-planner-state-feature-receipts.test.ts` prints a value at or below 500.

- [x] [P5-T5] Update `extensions/drm-copilot/test/lib/validate/validate-orchestration-service-call.test.ts`: in `it("threads the Codex flags into epic-planner-state")`, after the existing `expect(keyGated).not.toContain("Epic planner topology_receipt");` (planning-time line 211), append `expect(routing).toContain("features[0].model_routing_receipt must be an object.");`, `expect(routing).toContain("features[0].topology_receipt must be an object.");`, `expect(topology).toContain("features[0].model_routing_receipt must be an object.");`, `expect(topology).toContain("features[0].topology_receipt must be an object.");`, `expect(keyGated).not.toContain("features[0].model_routing_receipt");`, and `expect(keyGated).not.toContain("features[0].topology_receipt");`. Change no existing line of the test. This task runs after P3-T1, because both `keyGated` assertions fail on pre-fix code (the fixture at lines 162-172 carries no receipt).
  - Acceptance: `node run-jest.cjs test/lib/validate/validate-orchestration-service-call.test.ts -t "threads the Codex flags into epic-planner-state"` in `extensions/drm-copilot/` exits 0 with `Tests:` showing `1 passed` (the spec AC9 command form, filtered to the named test).

- [x] [P5-T6] Run both edited TypeScript test files: `node run-jest.cjs test/lib/validate/epic-planner-state-feature-receipts.test.ts test/lib/validate/validate-orchestration-service-call.test.ts --reporters=default --verbose` in `extensions/drm-copilot/`.
  - Acceptance: `docs/features/active/epic-planner-receipt-checks-key-gate-543/evidence/regression-testing/typescript-feature-receipts-suites.<timestamp>.md` exists with `Timestamp:`, `Command:`, `EXIT_CODE: 0`, and an `Output Summary:` recording `Test Suites: 2 passed, 2 total`, the `Tests:` line with 0 failed, and the passing lines (prefixed `✓` or, on some Windows consoles, `√`) for the five TypeScript titles under "Named tests and literals" (seven cases including `it.each` expansions) and `threads the Codex flags into epic-planner-state`.

- [x] [P5-T7] Commit and push Phase 5: run `git add extensions/drm-copilot/test/lib/validate/epic-planner-state-feature-receipts.test.ts extensions/drm-copilot/test/lib/validate/validate-orchestration-service-call.test.ts docs/features/active/epic-planner-receipt-checks-key-gate-543`, `git commit -m "test(543): cover per-feature receipt key gate matrix in TypeScript and MCP"` (with the required trailers), and `git push origin bug/epic-planner-receipt-checks-key-gate-543`.
  - Acceptance: the commit and push exit 0; afterwards `git status --porcelain` prints nothing and `git rev-parse HEAD` equals `git rev-parse origin/bug/epic-planner-receipt-checks-key-gate-543`.

### Phase 6 — Predicate, string, parity, preserved-behaviour, scope, and documentation verification

- [x] [P6-T1] Verify the gating predicate (spec AC10) by running, in the Bash tool from the worktree root: `grep -n -F -e 'if not key_gated or "model_routing_receipt" in feature:' -e 'if not key_gated or "topology_receipt" in feature:' -e 'errors.extend(_validate_ready_features(features, key_gated=key_gated))' -e 'features: list[dict[str, Any]], *, key_gated: bool = False' scripts/dev_tools/validate_epic_planner_state.py` and `grep -n -F -e 'if (!keyGated || "model_routing_receipt" in feature) {' -e 'if (!keyGated || "topology_receipt" in feature) {' -e '...validateReadyFeatures(featureResult.features, requireLaunchPaths),' -e 'keyGated: boolean,' extensions/drm-copilot/src/lib/validate/epic-planner-state-core.ts` (plus `extensions/drm-copilot/src/lib/validate/epic-planner-ready-features.ts` as a second file operand when P3-T4 created it).
  - Then read the source around each match and confirm: both `if` lines sit inside the per-feature loop (`for index, feature in enumerate(features):` / `features.forEach((feature, index) => {`); the model block contains only the model-receipt checks and the topology block only the `_validate_child_topology_receipt` / `validateChildTopologyReceipt` call; the `issue_num`, `feature_folder`, `research_path`, `plan_path`, `preparation_status`, and `preflight_status` checks and the at-least-two-features check carry no new condition.
  - Acceptance: `docs/features/active/epic-planner-receipt-checks-key-gate-543/evidence/qa-gates/gating-predicate.<timestamp>.md` exists with the four fields and an `Output Summary:` recording exactly four match lines (with line numbers) for each command and the source-reading confirmation.

- [x] [P6-T2] Verify that no error string was added, removed, or reworded (spec AC11) by running, in the Bash tool from the worktree root: `git diff -U0 main -- scripts/dev_tools/validate_epic_planner_state.py extensions/drm-copilot/src/lib/validate/epic-planner-state-core.ts > SCRATCH/543/prod.diff` (add the contingency module path when P3-T4 created it); `grep -e '^-[^-]' SCRATCH/543/prod.diff > SCRATCH/543/removed-lines.txt`; `grep -e 'Epic planner' -e 'must be' -e 'must match' SCRATCH/543/removed-lines.txt > SCRATCH/543/removed-filtered.txt`; `sed -e 's/^-[[:space:]]*//' SCRATCH/543/removed-filtered.txt > SCRATCH/543/removed-stripped.txt`; `sort SCRATCH/543/removed-stripped.txt > SCRATCH/543/removed-strings.txt`; the same four steps for added lines (`grep -e '^+[^+]'` writing `SCRATCH/543/added-lines.txt`, the same filter writing `SCRATCH/543/added-filtered.txt`, `sed -e 's/^+[[:space:]]*//'` writing `SCRATCH/543/added-stripped.txt`, and `sort`) producing `SCRATCH/543/added-strings.txt`; and `diff SCRATCH/543/removed-strings.txt SCRATCH/543/added-strings.txt`.
  - Then read `SCRATCH/543/prod.diff` and confirm that every removed or added line containing a string literal is either moved unchanged into `_validate_feature_model_receipt` or re-indented inside a new `if` block.
  - Acceptance: `docs/features/active/epic-planner-receipt-checks-key-gate-543/evidence/qa-gates/error-strings-unchanged.<timestamp>.md` exists with the four fields and an `Output Summary:` recording the line counts of `SCRATCH/543/removed-strings.txt` and `SCRATCH/543/added-strings.txt` (equal, and greater than 0 because the moved and re-indented literal lines appear on both sides), the `diff` command printing nothing with exit 0, the anchor used (`main` or `Anchor: merge-base`), the full contents of the removed-strings and added-strings scratch files copied verbatim under the labels `Removed literal lines:` and `Added literal lines:`, and the diff-reading confirmation.

- [x] [P6-T3] Verify byte-identical asserted strings across runtimes (spec AC7) by running, in the Bash tool from the worktree root: `poetry run python -c "import tests.scripts.dev_tools.test_validate_epic_planner_state_feature_receipts as m; print(*m.ASSERTED_MESSAGES, sep=chr(10))" > SCRATCH/543/python-asserted-messages.txt`; `tr -d '\r' < SCRATCH/543/python-asserted-messages.txt > SCRATCH/543/python-asserted-messages.lf.txt`; `grep -c -e '.' SCRATCH/543/python-asserted-messages.lf.txt`; `grep -o -F -f SCRATCH/543/python-asserted-messages.lf.txt extensions/drm-copilot/test/lib/validate/epic-planner-state-feature-receipts.test.ts > SCRATCH/543/ts-asserted-matches.txt`; `sort -u SCRATCH/543/ts-asserted-matches.txt > SCRATCH/543/ts-asserted-unique.txt`; `sort -u SCRATCH/543/python-asserted-messages.lf.txt > SCRATCH/543/python-asserted-sorted.txt`; `diff SCRATCH/543/python-asserted-sorted.txt SCRATCH/543/ts-asserted-unique.txt`; then `grep -c -F -e 'toContain("' -e 'toEqual(["' -e 'includes("' extensions/drm-copilot/test/lib/validate/epic-planner-state-feature-receipts.test.ts` and `grep -c -F -e 'assert "' -e '== ["' -e '" in error' tests/scripts/dev_tools/test_validate_epic_planner_state_feature_receipts.py`.
  - Acceptance: `docs/features/active/epic-planner-receipt-checks-key-gate-543/evidence/qa-gates/byte-identical-strings.<timestamp>.md` exists with the four fields and an `Output Summary:` recording: the third command printing `7`; the `diff` command printing nothing with exit 0; the last two commands each printing `0` (exit 1 by design), meaning neither file asserts an inline string literal; and a side-by-side table of the seven constant names with the Python value (from `SCRATCH/543/python-asserted-sorted.txt`) and the TypeScript value (from `SCRATCH/543/ts-asserted-unique.txt`).

- [x] [P6-T4] Run the spec's targeted Python command: `poetry run pytest tests/scripts/dev_tools/test_validate_epic_planner_state.py tests/scripts/dev_tools/test_validate_epic_planner_state_feature_receipts.py tests/scripts/dev_tools/test_validate_epic_planner_state_launch_binding.py tests/scripts/dev_tools/test_epic_planner_readiness.py tests/scripts/dev_tools/test_push_down_codex_and_agents_customizations.py --cov=scripts.dev_tools.validate_epic_planner_state --cov-branch --cov-report=term-missing`.
  - Acceptance: `docs/features/active/epic-planner-receipt-checks-key-gate-543/evidence/regression-testing/targeted-python.<timestamp>.md` exists with `Timestamp:`, `Command:`, `EXIT_CODE: 0`, and an `Output Summary:` recording the result line with 0 failed and a passed count equal to the P0-T10 passed count plus 7, and the `term-missing` row for `scripts/dev_tools/validate_epic_planner_state.py`.

- [x] [P6-T5] Run the spec's targeted Jest command `node run-jest.cjs test/lib/validate/epic-planner-state-feature-receipts.test.ts test/lib/validate/epic-planner-state-core.test.ts test/lib/validate/epic-planner-state-launch-binding.test.ts test/lib/validate/epic-planner-readiness-integrity.test.ts test/lib/validate/validate-orchestration-service-call.test.ts test/lib/validate/orchestration-artifacts.test.ts` in `extensions/drm-copilot/`.
  - Acceptance: `docs/features/active/epic-planner-receipt-checks-key-gate-543/evidence/regression-testing/targeted-typescript.<timestamp>.md` exists with `Timestamp:`, `Command:`, `EXIT_CODE: 0`, and an `Output Summary:` recording `Test Suites: 6 passed, 6 total` and the `Tests:` line with 0 failed and a passed count equal to the P0-T18 passed count plus 7.

- [x] [P6-T6] Verify the preserved tests (spec AC12) by running `poetry run pytest "tests/scripts/dev_tools/test_validate_epic_planner_state.py::test_readiness_requires_epic_preparation_topology_receipts" "tests/scripts/dev_tools/test_validate_epic_planner_state.py::test_readiness_cross_binds_feature_complexity_and_model_context" "tests/scripts/dev_tools/test_validate_epic_planner_state.py::test_ready_checkpoint_passes_execution_readiness" "tests/scripts/dev_tools/test_validate_epic_planner_state.py::test_cli_dispatches_planner_readiness_flag" "tests/scripts/dev_tools/test_push_down_codex_and_agents_customizations.py::test_consumer_authority_is_typescript_only_and_scope_owners_are_unchanged" -v`, then `git diff main --stat -- tests/scripts/dev_tools/test_validate_epic_planner_state_launch_binding.py tests/scripts/dev_tools/test_epic_planner_readiness.py tests/scripts/dev_tools/test_push_down_codex_and_agents_customizations.py extensions/drm-copilot/test/lib/validate/epic-planner-state-core.test.ts extensions/drm-copilot/test/lib/validate/epic-planner-state-launch-binding.test.ts extensions/drm-copilot/test/lib/validate/epic-planner-readiness-integrity.test.ts`, then `git status --porcelain -- tests/scripts/dev_tools/test_validate_epic_planner_state_launch_binding.py tests/scripts/dev_tools/test_epic_planner_readiness.py tests/scripts/dev_tools/test_push_down_codex_and_agents_customizations.py extensions/drm-copilot/test/lib/validate/epic-planner-state-core.test.ts extensions/drm-copilot/test/lib/validate/epic-planner-state-launch-binding.test.ts extensions/drm-copilot/test/lib/validate/epic-planner-readiness-integrity.test.ts`, then `git diff -U0 main -- tests/scripts/dev_tools/test_validate_epic_planner_state.py`.
  - Acceptance: `docs/features/active/epic-planner-receipt-checks-key-gate-543/evidence/regression-testing/preserved-tests.<timestamp>.md` exists with the four fields and an `Output Summary:` recording `5 passed` for the pytest run; empty output from the `--stat` diff and from the porcelain command; and, from the `-U0` diff, every hunk header copied verbatim with the statement that every hunk lies within old lines 176-188 (the body of `test_readiness_requires_resolved_child_model_receipt`). Together with P6-T4 and P6-T5 exiting 0, this shows the listed tests pass without modification.

- [x] [P6-T7] Verify the out-of-scope paths (spec AC13) by running `git diff main -- scripts/dev_tools/validate_orchestration_artifacts.py .claude .github .agents .codex extensions/drm-copilot/resources extensions/drm-copilot/jest.config.cjs extensions/drm-copilot/src/mcp-tool-inputs.ts extensions/drm-copilot/src/lib/validate/orchestration-artifacts.ts extensions/drm-copilot/test/lib/validate/epic-planner-state-core.test.ts tests/scripts/dev_tools/test_push_down_codex_and_agents_customizations.py` and `git status --porcelain -- scripts/dev_tools/validate_orchestration_artifacts.py .claude .github .agents .codex extensions/drm-copilot/resources extensions/drm-copilot/jest.config.cjs extensions/drm-copilot/src/mcp-tool-inputs.ts extensions/drm-copilot/src/lib/validate/orchestration-artifacts.ts extensions/drm-copilot/test/lib/validate/epic-planner-state-core.test.ts tests/scripts/dev_tools/test_push_down_codex_and_agents_customizations.py` in the Bash tool from the worktree root.
  - Acceptance: `docs/features/active/epic-planner-receipt-checks-key-gate-543/evidence/qa-gates/scope-exclusions.<timestamp>.md` exists with the four fields and an `Output Summary:` stating that both commands printed nothing, and recording the anchor used (`main` or `Anchor: merge-base`).

- [x] [P6-T8] Verify the in-file documentation (spec AC14) by running `grep -n -F -e 'per-feature receipt' scripts/dev_tools/validate_epic_planner_state.py` and `grep -n -F -e 'per-feature receipt' extensions/drm-copilot/src/lib/validate/epic-planner-state-core.ts` (plus the contingency module as a second operand when P3-T4 created it), then reading each matched docstring or comment in full.
  - Acceptance: `docs/features/active/epic-planner-receipt-checks-key-gate-543/evidence/qa-gates/docs-updated.<timestamp>.md` exists with the four fields and an `Output Summary:` recording three Python match lines (inside the `_validate_ready_features` docstring, the `validate_epic_planner_state_text` docstring, and the comment above `key_gated`) and two TypeScript match lines (inside the `validateReadyFeatures` JSDoc and the comment above `requireLaunchPaths`), and the reading confirmation that each of the five locations names `model_routing_receipt` and `topology_receipt` and states that the checks are key-gated unless a Codex flag is asserted.

- [x] [P6-T9] Commit and push Phase 6: run `git add docs/features/active/epic-planner-receipt-checks-key-gate-543`, `git commit -m "docs(543): record verification evidence for receipt-checks key gate"` (with the required trailers), and `git push origin bug/epic-planner-receipt-checks-key-gate-543`.
  - Acceptance: the commit and push exit 0; afterwards `git status --porcelain` prints nothing and `git rev-parse HEAD` equals `git rev-parse origin/bug/epic-planner-receipt-checks-key-gate-543`.

### Phase 7 — Python final QA loop

Loop rule: run P7-T1 through P7-T8 in order. If any stage fails or changes any file, fix the cause, record the restart in `docs/features/active/epic-planner-receipt-checks-key-gate-543/evidence/qa-gates/loop-restarts.<timestamp>.md`, and restart at P7-T1, incrementing `Loop iteration:` in every Phase 7 artifact. Every task is unconditional; `SKIPPED` is not a valid outcome.

- [x] [P7-T1] Python stage 1, formatting: run `poetry run black --check scripts/dev_tools/validate_epic_planner_state.py tests/scripts/dev_tools/test_validate_epic_planner_state.py tests/scripts/dev_tools/test_validate_epic_planner_state_feature_receipts.py`.
  - Acceptance: `docs/features/active/epic-planner-receipt-checks-key-gate-543/evidence/qa-gates/final-python-format.<timestamp>.md` exists with the four fields and `Loop iteration:`; `EXIT_CODE: 0` and the output contains `3 files would be left unchanged.` with no `would reformat` line. If the check fails, run `poetry run black scripts/dev_tools/validate_epic_planner_state.py tests/scripts/dev_tools/test_validate_epic_planner_state.py tests/scripts/dev_tools/test_validate_epic_planner_state_feature_receipts.py`, record its `reformatted <path>` lines and its closing summary (`N file(s) reformatted, M file(s) left unchanged`), and restart the loop.

- [x] [P7-T2] Python stage 2, linting: run `poetry run ruff check scripts/dev_tools/validate_epic_planner_state.py tests/scripts/dev_tools/test_validate_epic_planner_state.py tests/scripts/dev_tools/test_validate_epic_planner_state_feature_receipts.py`.
  - Acceptance: `docs/features/active/epic-planner-receipt-checks-key-gate-543/evidence/qa-gates/final-python-lint.<timestamp>.md` exists with the four fields; `EXIT_CODE: 0` and the output is `All checks passed!`. Any suppression must match `.claude/rules/python-suppressions.md`.

- [x] [P7-T3] Python stage 3, type checking: run `poetry run pyright scripts/dev_tools/validate_epic_planner_state.py tests/scripts/dev_tools/test_validate_epic_planner_state.py tests/scripts/dev_tools/test_validate_epic_planner_state_feature_receipts.py`.
  - Acceptance: `docs/features/active/epic-planner-receipt-checks-key-gate-543/evidence/qa-gates/final-python-typecheck.<timestamp>.md` exists with the four fields; `EXIT_CODE: 0` and the summary line `0 errors, 0 warnings, 0 informations`.

- [x] [P7-T4] Python stage 4, architecture boundaries: re-run the P0-T16 commands against `pyproject.toml` and the tracked tree, writing `docs/features/active/epic-planner-receipt-checks-key-gate-543/evidence/qa-gates/final-python-architecture.<timestamp>.md`.
  - Acceptance: `docs/features/active/epic-planner-receipt-checks-key-gate-543/evidence/qa-gates/final-python-architecture.<timestamp>.md` exists with the four fields and an `Output Summary:` identical in substance to P0-T16 (stage not applicable: no Python architecture-boundary tool for these files, per spec Test Strategy). When P0-T16 found a configured tool, this task runs it and requires zero violations.

- [x] [P7-T5] Python stage 5, unit tests with coverage: run the spec's command `poetry run pytest tests/scripts/dev_tools/test_validate_epic_planner_state.py tests/scripts/dev_tools/test_validate_epic_planner_state_feature_receipts.py tests/scripts/dev_tools/test_validate_epic_planner_state_launch_binding.py tests/scripts/dev_tools/test_epic_planner_readiness.py tests/scripts/dev_tools/test_push_down_codex_and_agents_customizations.py --cov=scripts.dev_tools.validate_epic_planner_state --cov-branch --cov-report=term-missing`.
  - Acceptance: `docs/features/active/epic-planner-receipt-checks-key-gate-543/evidence/qa-gates/final-python-test-coverage.<timestamp>.md` exists with `Timestamp:`, `Command:`, `EXIT_CODE: 0`, and an `Output Summary:` recording the result line (0 failed; passed count equal to the P0-T10 passed count plus 7) and the `term-missing` row for `scripts/dev_tools/validate_epic_planner_state.py` verbatim, including its `Missing` cell.

- [x] [P7-T6] Python per-file coverage: immediately after P7-T5, run `poetry run coverage json --data-file=artifacts/.coverage --include="*validate_epic_planner_state.py" --pretty-print -o SCRATCH/543/coverage-final.json` and read the JSON.
  - Acceptance: `docs/features/active/epic-planner-receipt-checks-key-gate-543/evidence/qa-gates/final-python-per-file-coverage.<timestamp>.md` exists with the four fields and an `Output Summary:` recording `covered_lines`/`num_statements` and `covered_branches`/`num_branches` from `files[<key>].summary` with two-decimal percentages, and the `missing_lines` and `missing_branches` lists. The file shows at least 85.00% line coverage and at least 75.00% branch coverage. A shortfall requires added tests in `tests/scripts/dev_tools/test_validate_epic_planner_state_feature_receipts.py` and a loop restart at P7-T1.

- [x] [P7-T7] Python stage 6, contract/schema compatibility: run `git diff main --stat -- scripts/dev_tools/validate_orchestration_artifacts.py`, `git status --porcelain -- scripts/dev_tools/validate_orchestration_artifacts.py`, `git diff -U0 main -- scripts/dev_tools/validate_epic_planner_state.py > SCRATCH/543/contract-python.diff`, `grep -c -e '^[-+]def [a-z]' SCRATCH/543/contract-python.diff`, and `grep -c -e '^[-+]def _' SCRATCH/543/contract-python.diff`.
  - Acceptance: `docs/features/active/epic-planner-receipt-checks-key-gate-543/evidence/qa-gates/final-python-contract.<timestamp>.md` exists with the four fields; the first two commands print nothing (Python CLI unchanged); the fourth prints `0` (exit 1 by design), confirming no public function signature in `scripts/dev_tools/validate_epic_planner_state.py` was added, removed, or changed; the fifth prints `3` (the removed one-line `_validate_ready_features` definition, the added wrapped `_validate_ready_features` definition, and the added `_validate_feature_model_receipt` definition).

- [x] [P7-T8] Python stage 7, integration and full-suite regression: run `poetry run pytest -q --deselect tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py::test_bundled_claude_payload_contains_all_repo_runtime_contracts` from the worktree root (same selection as P0-T12).
  - Acceptance: `docs/features/active/epic-planner-receipt-checks-key-gate-543/evidence/qa-gates/final-python-full-suite.<timestamp>.md` exists with `Timestamp:`, `Command:`, `EXIT_CODE:`, and an `Output Summary:` recording the result line (deselected 1, citing #510; passed count equal to the P0-T12 passed count plus 7) and the failed node IDs. The set of failed node IDs is empty or a subset of the P0-T12 set; any failure not present in P0-T12 requires a fix and a loop restart at P7-T1. `EXIT_CODE: 0` is required when P0-T12 recorded `Failed: none`.

- [x] [P7-T9] Commit and push Phase 7: run `git add docs/features/active/epic-planner-receipt-checks-key-gate-543` (plus any Python file a loop restart changed), `git commit -m "docs(543): record Python final QA evidence for receipt-checks key gate"` (with the required trailers), and `git push origin bug/epic-planner-receipt-checks-key-gate-543`.
  - Acceptance: the commit and push exit 0; afterwards `git status --porcelain` prints nothing and `git rev-parse HEAD` equals `git rev-parse origin/bug/epic-planner-receipt-checks-key-gate-543`.

### Phase 8 — TypeScript final QA loop

Loop rule: run P8-T1 through P8-T7 in order. If any stage fails or changes any file, fix the cause, record the restart in `docs/features/active/epic-planner-receipt-checks-key-gate-543/evidence/qa-gates/loop-restarts.<timestamp>.md`, and restart at P8-T1, incrementing `Loop iteration:` in every Phase 8 artifact. A TypeScript fix that touches no Python file does not restart Phase 7. Every task is unconditional; `SKIPPED` is not a valid outcome. When P3-T4 created the contingency files, every Prettier path list in this phase also includes `src/lib/validate/epic-planner-ready-features.ts` and `test/lib/validate/epic-planner-ready-features.test.ts`.

- [x] [P8-T1] TypeScript stage 1, formatting: run `npx prettier --check src/lib/validate/epic-planner-state-core.ts test/lib/validate/epic-planner-state-feature-receipts.test.ts test/lib/validate/validate-orchestration-service-call.test.ts` in `extensions/drm-copilot/`.
  - Acceptance: `docs/features/active/epic-planner-receipt-checks-key-gate-543/evidence/qa-gates/final-typescript-format.<timestamp>.md` exists with the four fields and `Loop iteration:`; `EXIT_CODE: 0` and the output contains `All matched files use Prettier code style!`. If the check fails, run `npx prettier --write src/lib/validate/epic-planner-state-core.ts test/lib/validate/epic-planner-state-feature-receipts.test.ts test/lib/validate/validate-orchestration-service-call.test.ts` in `extensions/drm-copilot/` (not `npm run format`, which rewrites files outside the write set), record each output line (a line ending in `(unchanged)` names a file left as-is; every other file line names a rewritten file), and restart the loop.

- [x] [P8-T2] TypeScript stage 2, linting: run `npm run lint` in `extensions/drm-copilot/`.
  - Acceptance: `docs/features/active/epic-planner-receipt-checks-key-gate-543/evidence/qa-gates/final-typescript-lint.<timestamp>.md` exists with the four fields; `EXIT_CODE: 0` and zero problem lines. Any suppression must match `.claude/rules/typescript-suppressions.md`.

- [x] [P8-T3] TypeScript stage 3, type checking: run `npm run typecheck` in `extensions/drm-copilot/`.
  - Acceptance: `docs/features/active/epic-planner-receipt-checks-key-gate-543/evidence/qa-gates/final-typescript-typecheck.<timestamp>.md` exists with the four fields; `EXIT_CODE: 0` and zero `error TS` lines.

- [x] [P8-T4] TypeScript stage 4, architecture boundaries: re-run the P0-T16 commands for `extensions/drm-copilot/`, writing `docs/features/active/epic-planner-receipt-checks-key-gate-543/evidence/qa-gates/final-typescript-architecture.<timestamp>.md`.
  - Acceptance: `docs/features/active/epic-planner-receipt-checks-key-gate-543/evidence/qa-gates/final-typescript-architecture.<timestamp>.md` exists with the four fields and an `Output Summary:` identical in substance to P0-T16 (stage not applicable: the extension has no dependency-cruiser configuration, per spec Test Strategy). When P0-T16 found a `.dependency-cruiser*` configuration, this task runs it and requires zero violations.

- [x] [P8-T5] TypeScript stage 5, unit tests with coverage: run `node run-jest.cjs --coverage --coverageReporters=text --coverageReporters=text-summary` in `extensions/drm-copilot/`.
  - Acceptance: `docs/features/active/epic-planner-receipt-checks-key-gate-543/evidence/qa-gates/final-typescript-test-coverage.<timestamp>.md` exists with `Timestamp:`, `Command:`, `EXIT_CODE: 0` (which also shows every configured `coverageThreshold` entry is met), and an `Output Summary:` recording the `Test Suites:` and `Tests:` lines with 0 failed (passed count equal to the P0-T17 count plus 7, plus the contingency test count when P3-T4 created that file), the text-summary `Lines` and `Branches` totals, and the `text` row for `epic-planner-state-core.ts` verbatim (and for `epic-planner-ready-features.ts` when created), showing `% Lines` at or above 85 and `% Branch` at or above 75, with its `Uncovered Line #s` cell. A shortfall requires added tests in `extensions/drm-copilot/test/lib/validate/epic-planner-state-feature-receipts.test.ts` and a loop restart at P8-T1.

- [x] [P8-T6] TypeScript stage 6, contract/schema compatibility: run `git diff main --stat -- extensions/drm-copilot/src/mcp-tool-definitions.ts extensions/drm-copilot/src/mcp-repo-automation-tool-definitions.ts extensions/drm-copilot/src/mcp-tool-inputs.ts extensions/drm-copilot/src/lib/validate/orchestration-artifacts.ts`, `git status --porcelain -- extensions/drm-copilot/src/mcp-tool-definitions.ts extensions/drm-copilot/src/mcp-repo-automation-tool-definitions.ts extensions/drm-copilot/src/mcp-tool-inputs.ts extensions/drm-copilot/src/lib/validate/orchestration-artifacts.ts`, `git diff -U0 main -- extensions/drm-copilot/src/lib/validate/epic-planner-state-core.ts > SCRATCH/543/contract-typescript.diff`, and `grep -c -e '^[-+]export ' SCRATCH/543/contract-typescript.diff` in the Bash tool from the worktree root.
  - Acceptance: `docs/features/active/epic-planner-receipt-checks-key-gate-543/evidence/qa-gates/final-typescript-contract.<timestamp>.md` exists with the four fields; the first two commands print nothing (MCP input schema and dispatch unchanged) and the fourth prints `0` (exit 1 by design), confirming no exported declaration of `epic-planner-state-core.ts` was added, removed, or changed. The expectation is the same when P3-T4 created the contingency module, because the moved declarations were module-private in the core file and the core file gains only `import` lines.

- [x] [P8-T7] TypeScript stage 7, integration: run `node run-jest.cjs test/lib/validate/epic-planner-state-feature-receipts.test.ts test/lib/validate/epic-planner-state-core.test.ts test/lib/validate/epic-planner-state-launch-binding.test.ts test/lib/validate/epic-planner-readiness-integrity.test.ts test/lib/validate/validate-orchestration-service-call.test.ts test/lib/validate/orchestration-artifacts.test.ts test/mcp-server-epic-validation.test.ts` in `extensions/drm-copilot/`.
  - Acceptance: `docs/features/active/epic-planner-receipt-checks-key-gate-543/evidence/qa-gates/final-typescript-integration.<timestamp>.md` exists with `Timestamp:`, `Command:`, `EXIT_CODE: 0`, and an `Output Summary:` recording `Test Suites: 7 passed, 7 total` and the `Tests:` line with 0 failed.

- [x] [P8-T8] Commit and push Phase 8: run `git add docs/features/active/epic-planner-receipt-checks-key-gate-543` (plus any TypeScript file a loop restart changed), `git commit -m "docs(543): record TypeScript final QA evidence for receipt-checks key gate"` (with the required trailers), and `git push origin bug/epic-planner-receipt-checks-key-gate-543`.
  - Acceptance: the commit and push exit 0; afterwards `git status --porcelain` prints nothing and `git rev-parse HEAD` equals `git rev-parse origin/bug/epic-planner-receipt-checks-key-gate-543`.

### Phase 9 — Coverage delta, clean pass, size, scope, and acceptance check-off

- [x] [P9-T1] Write the coverage-delta verification to `docs/features/active/epic-planner-receipt-checks-key-gate-543/evidence/qa-gates/coverage-delta-verification.<timestamp>.md`, running `git diff -U0 main -- scripts/dev_tools/validate_epic_planner_state.py extensions/drm-copilot/src/lib/validate/epic-planner-state-core.ts > SCRATCH/543/changed-lines.diff` (plus the contingency module path when created) to enumerate added line numbers from the `+` side of each hunk header.
  - Acceptance: the artifact contains `Timestamp:`, `Command:`, `EXIT_CODE: 0`, and an `Output Summary:` reporting, per language, three numeric groups:
    - baseline coverage: Python line and branch percentages from P0-T11; TypeScript `% Lines` and `% Branch` from the P0-T17 row;
    - post-change coverage: Python from P7-T6; TypeScript from the P8-T5 row;
    - new/changed-code coverage: the count of added executable lines that appear in the Python `missing_lines` list of `SCRATCH/543/coverage-final.json` or in the TypeScript `Uncovered Line #s` cell, and, for Python, the count of `missing_branches` arcs whose source line is one of the two new `if not key_gated or ...` lines.
  - Required results: Python and TypeScript line percentages at or above 85.00 and branch percentages at or above 75.00; no post-change percentage lower than its baseline by more than 0.50 points; zero added executable lines uncovered; zero missing arcs from the two new Python conditions. The artifact also records that both outcomes of each new conditional are exercised in each runtime, citing the passing tests: check skipped because the key is absent (the regression tests and the index-preservation tests), check run because a Codex flag is set (the Codex-flag tests), and check run because the key is present (the present-null and independent-gating tests). A missing numeric value makes the verdict INCOMPLETE, not PASS.

- [x] [P9-T2] Write the single-clean-pass record to `docs/features/active/epic-planner-receipt-checks-key-gate-543/evidence/qa-gates/final-qa-clean-pass.<timestamp>.md`.
  - Acceptance: the artifact contains `Timestamp:` and a stage-by-stage table for Python (P7-T1 through P7-T8) and TypeScript (P8-T1 through P8-T7) recording each stage's artifact path, `EXIT_CODE`, and `Loop iteration:` from the final iteration, plus the total number of loop restarts and the reason for each, copied from the latest `loop-restarts.*.md` (or `Restarts: 0`). Every stage in the final iteration shows its expected exit status and no file change.

- [x] [P9-T3] Verify the 500-line limit (spec AC15) for `scripts/dev_tools/validate_epic_planner_state.py`, `extensions/drm-copilot/src/lib/validate/epic-planner-state-core.ts`, and the four test files by running `grep -c -e '' <path>` in the Bash tool from the worktree root once for each of the six code paths in "Files the diff will WRITE" (and each contingency path that P3-T4 created).
  - Acceptance: `docs/features/active/epic-planner-receipt-checks-key-gate-543/evidence/qa-gates/line-counts-final.<timestamp>.md` exists with the four fields and an `Output Summary:` listing each count, each at or below 500, beside the P0-T6 baseline count for the same path where one exists. The artifact carries `Equivalent-To: (Get-Content <path>).Count` (spec AC15 form; see Execution notes, Line counts).

- [x] [P9-T4] Verify the write set in `docs/features/active/epic-planner-receipt-checks-key-gate-543/evidence/qa-gates/scope-verification.<timestamp>.md` by running `git diff main --name-only` and `git status --porcelain` in the Bash tool from the worktree root.
  - Acceptance: `docs/features/active/epic-planner-receipt-checks-key-gate-543/evidence/qa-gates/scope-verification.<timestamp>.md` exists with the four fields and an `Output Summary:` showing that the union of the two outputs, restricted to paths outside `docs/features/active/epic-planner-receipt-checks-key-gate-543/`, is exactly the six code paths in "Files the diff will WRITE" (plus the two contingency paths only when P3-T4 created them), and that no path under "Explicitly out of scope" appears in either output.

- [x] [P9-T5] Update `docs/features/active/epic-planner-receipt-checks-key-gate-543/spec.md`: in the `## Acceptance Criteria` section only, confirm that each criterion AC1-AC17 was changed from `- [ ]` to `- [x]` at its mapped task under the tick rule, and change any of AC1-AC17 whose mapped tasks have all passed but which is still `- [ ]`, changing no criterion text and no other section. AC18 (PR closes the issue) stays `- [ ]` for S9. Mapping (AC numbering is the order of the eighteen items at planning-time lines 221-238): AC1 at P2-T3 (with P1-T2), AC2 at P3-T5 (with P1-T4), AC3 at P4-T1 and P5-T1, AC4 at P4-T2 and P5-T2, AC5 at P4-T3 and P5-T3, AC6 at P4-T4 and P5-T4, AC7 at P6-T3, AC8 at P4-T5, AC9 at P5-T5, AC10 at P6-T1, AC11 at P6-T2, AC12 at P6-T6 (with P6-T4 and P6-T5), AC13 at P6-T7, AC14 at P6-T8, AC15 at P9-T3, AC16 at P9-T2 and P9-T1 (with P7-T6), AC17 at P9-T2 and P9-T1 (with P8-T5). Then run `grep -c -e '^- \[x\] ' docs/features/active/epic-planner-receipt-checks-key-gate-543/spec.md` and `grep -c -e '^- \[ \] ' docs/features/active/epic-planner-receipt-checks-key-gate-543/spec.md`.
  - Acceptance: the first count prints `17` and the second prints `1` (baseline 0 checked and 18 unchecked from P0-T19, with AC1-AC17 moved). `docs/features/active/epic-planner-receipt-checks-key-gate-543/evidence/qa-gates/acceptance-checkoff.<timestamp>.md` exists with `Timestamp:`, `Command:`, `EXIT_CODE: 0`, and an `Output Summary:` recording both counts, one citation line per criterion AC1 through AC17 naming the evidence artifact path or test node that satisfies it, and `AC18: deferred to S9 (PR body Closes #543 and CI success on the final PR head)`. If any of AC1-AC17 cannot be ticked, it stays unticked, the gap is recorded in the artifact, the counts are recorded as found, and the plan outcome is INCOMPLETE, not PASS.

- [x] [P9-T6] Update `docs/features/active/epic-planner-receipt-checks-key-gate-543/plan.2026-10-15T07-42.md`: reconcile every task checkbox in this plan against the evidence on disk, so that a task is `[x]` only when its named artifact exists with the required fields (or, for a task without an artifact, its stated acceptance command was observed to pass), and append a `## Plan Deviations` section recording any deviation applied during execution (or `None`).
  - Acceptance: `grep -c -e '^- \[ \] \[P' docs/features/active/epic-planner-receipt-checks-key-gate-543/plan.2026-10-15T07-42.md` prints `2` (this task and P9-T7) immediately before this task is ticked, and the `## Plan Deviations` heading is present.

- [x] [P9-T7] Commit and push Phase 9: run `git add docs/features/active/epic-planner-receipt-checks-key-gate-543`, `git commit -m "docs(543): record acceptance check-off for receipt-checks key gate"` (with the required trailers), and `git push origin bug/epic-planner-receipt-checks-key-gate-543`; tick this task in the plan before staging, so the commit carries the final checkbox state.
  - Acceptance: the commit and push exit 0; afterwards `git status --porcelain` prints nothing, `git rev-parse HEAD` equals `git rev-parse origin/bug/epic-planner-receipt-checks-key-gate-543`, and `grep -c -e '^- \[ \] \[P' docs/features/active/epic-planner-receipt-checks-key-gate-543/plan.2026-10-15T07-42.md` prints `0` (exit 1 by design).

---

## Planner Review Record

SELF-REVIEW: RE-DERIVED THIS PASS

Preflight revision round 1 (delta applied in place: line counts moved from the PowerShell form to `grep -c -e ''` in Bash; P6-T2 records the removed and added literal lines verbatim; every scratch path moved under `SCRATCH/543/`). Citations re-derived against the current tree in this revision pass:

R1. `docs/features/active/epic-planner-receipt-checks-key-gate-543/spec.md` line 235 (AC15 names `(Get-Content <path>).Count`; the plan records it as the `Equivalent-To:` form) and lines 221-238 (18 criteria, 18 unchecked checkboxes, AC18 at line 238).
R2. `scripts/dev_tools/validate_epic_planner_state.py` physical line count 375 (P0-T6 planning value; ripgrep `^` count).
R3. `extensions/drm-copilot/src/lib/validate/epic-planner-state-core.ts` physical line count 474 (P0-T6 and P3-T3 planning value).
R4. `tests/scripts/dev_tools/test_validate_epic_planner_state.py` physical line count 424 (P0-T6).
R5. `extensions/drm-copilot/test/lib/validate/validate-orchestration-service-call.test.ts` physical line count 232 (P0-T6).
R6. `tests/scripts/dev_tools/test_validate_epic_planner_state_feature_receipts.py` and `extensions/drm-copilot/test/lib/validate/epic-planner-state-feature-receipts.test.ts` do not exist (P4-T4, P5-T4, P9-T3 count them only after creation).
R7. `scripts/dev_tools/validate_epic_planner_state.py` lines 222-276 (P6-T2 sibling): the moved literal lines 256, 262, and 267 contain `must be` or `must match` and are removed and re-added with only indentation changed, so the `Removed literal lines:` and `Added literal lines:` lists are non-empty and equal after leading-whitespace stripping; line 229 (`prefix` literal) is not edited.
R8. `pyproject.toml` line 121 (`data_file = "artifacts/.coverage"`; P0-T11 and P7-T6 siblings whose output paths moved to `SCRATCH/543/`) and line 116 (`addopts` LCOV only; P0-T10 and P7-T5 keep `--cov-report=term-missing`).

Sibling-region checks in this revision: the P9-T1 reference to `SCRATCH/543/coverage-final.json` matches the P7-T6 output path; the P7-T7 and P8-T6 diff captures and their `grep -c` operands use the same `SCRATCH/543/` file names; P0-T4 creates `SCRATCH/543` before any task writes into it; the remaining `Get-Content` text in the plan is limited to the `Equivalent-To:` labels and the AC15 mapping description, and no command span invokes it; every command span runs in the Bash tool.

Citations re-derived against the current tree in the initial authoring pass (file and locator):

1. `scripts/dev_tools/validate_epic_planner_state.py` lines 47-57 (`REQUIRED_FEATURE_KEYS`), lines 89-109 (`_validate_child_topology_receipt`), line 222 (`_validate_ready_features` single-line signature), line 223 (one-line docstring), lines 226-240 (non-Codex checks), lines 241-269 (model block; line 256 literal), lines 270-275 (topology block), lines 287-294 (docstring; paragraph 289-293), line 329 (ready branch), lines 330-331 (comment), line 332 (`key_gated`), line 342 (call), lines 343-347 (launch-binding call with `require_launch_paths=key_gated` at 345), lines 348-351 (planner topology gate), lines 359-362 (repository-context error), line count 375.
2. `extensions/drm-copilot/src/lib/validate/epic-planner-state-core.ts` lines 51-60 (`ValidateEpicPlannerStateOptions`), lines 62-65 (`isObject`), 67-81 (`pythonRepr`), 83-100 (`validateExpectedTopologyFields`), 116-127 (`validateChildTopologyReceipt`), line 291 (one-line comment), lines 292-294 (signature), 296-327 (non-Codex checks), 329-354 (model block), 355-360 (topology block), line 422 (ready branch), 423-424 (comment), 425-427 (`requireLaunchPaths`), 438 (call), 439-443 (launch-binding call), 444-446 (planner gate), 457-460 (repository-context error), line count 474.
3. `tests/scripts/dev_tools/test_validate_epic_planner_state.py` lines 24-61 (`_feature`; receipts at 27-38), 64-84 (`_ready_state`), 87-94 (`test_ready_checkpoint_passes_execution_readiness`), 176-188 (`test_readiness_requires_resolved_child_model_receipt`; assertion at 187, `.model` assertion at 188), 191-210, 213-234, 237 (`test_readiness_requires_forced_epic_planner_persona`), 393-424 (`test_cli_dispatches_planner_readiness_flag`), line count 424.
4. `tests/scripts/dev_tools/test_validate_epic_planner_state_launch_binding.py` lines 13-15 (parenthesized import), 20-33 (launch-binding keys and strip helper).
5. `extensions/drm-copilot/test/lib/validate/epic-planner-state-core.test.ts` lines 1, 3, 4, 5 (imports), 17-33 (`modelReceipt`), 42-50 (required feature values), 68-83 (`readyState`), 85-93 (`CodexFlags`, `codexFlagCases`).
6. `extensions/drm-copilot/test/lib/validate/epic-planner-state-launch-binding.test.ts` line 18 (`delete item[key];`).
7. `extensions/drm-copilot/test/lib/validate/validate-orchestration-service-call.test.ts` lines 160-212 (`threads the Codex flags into epic-planner-state`; fixture 162-172 without receipts; last assertion at 211), line count 232.
8. `tests/scripts/dev_tools/test_push_down_codex_and_agents_customizations.py` line 368 (`test_consumer_authority_is_typescript_only_and_scope_owners_are_unchanged`), lines 397-404 (ready-gate source literals), lines 407-423.
9. `tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py` line 89 (deselected #510 node).
10. `scripts/dev_tools/_epic_orchestrator_state_launch_binding.py` lines 166-202 (`_validate_model_receipt`), 205-208 (`feature_carries_launch_path`), 231-232 (key-gated skip), 234 (launch-binding prefix).
11. `pyproject.toml` lines 85 and 89 (line length 88), 88-91 (`[tool.ruff]`, no `fix`), 94-103 (`select`, `E` at 95), 106 (tests ignore `S101` only), 116 (`addopts` LCOV only), 121 (`data_file`).
12. `extensions/drm-copilot/package.json` lines 207-213 (`format`, `lint`, `typecheck`, `typecheck:test`, `test` scripts).
13. `extensions/drm-copilot/run-jest.cjs` line 28 (relative `--config jest.config.cjs`) and lines 9-19 (prohibited-flag guard; no prohibited flag is used).
14. `extensions/drm-copilot/jest.config.cjs` line 4 (`testMatch`), 17-18 (`collectCoverageFrom`, default reporters), 25 (`coverageThreshold`; no `epic-planner` entry).
15. `extensions/drm-copilot/tsconfig.json` lines 12-14 and 16 (`noUnusedLocals`, `noUnusedParameters`, `exactOptionalPropertyTypes`, `noUncheckedIndexedAccess`); `extensions/drm-copilot/tsconfig.jest.json` line 8 (includes `test/**/*.ts`).
16. `.claude/hooks/enforce-python-batch-budget.ps1` lines 10-14 and 25-29.
17. `docs/features/active/epic-planner-receipt-checks-key-gate-543/spec.md` lines 221-238 (18 criteria; the only 18 checkboxes in the file), lines 193-213 (toolchain commands).
18. `docs/features/active/epic-planner-receipt-checks-key-gate-543/issue.md` line 12 (`Work Mode: full-bug`).
19. `.claude/rules/python-suppressions.md`, `.claude/rules/typescript-suppressions.md`, `.claude/skills/acceptance-criteria-tracking/SKILL.md` (existence confirmed).

Sibling-region checks performed: the `test_consumer_authority` slice from `if require_ready_for_execution:` still contains `validate_epic_planner_child_launch_bindings(` and `require_launch_paths=key_gated` after P2-T1, which edits only line 342 and the loop above; `test_readiness_requires_epic_preparation_topology_receipts` already passes `require_codex_topology=True` (line 222), so it keeps its per-feature assertion; the service-call fixture carries no receipt and no launch key, so the appended `keyGated` assertions fail before P3-T1 and are ordered after it; the TypeScript new file adds each declaration together with its first use because `noUnusedLocals` is set; the Python new file does the same because Pyright strict reports unused private functions; neither production file contains `per-feature` before the change (Grep, no matches), so the post-change counts 3 and 2 are exact; the asserted Python literals over 88 columns are parenthesized or split because ruff `E` includes E501 and only `S101` is ignored for tests.

### Planner internal review record

PLANNER-INTERNAL-REVIEW: PASS
CITATION-TO-TREE: PASS
AC-TRACEABILITY: PASS
SCOPE-BOUNDARY: PASS
CITATION: scripts/dev_tools/validate_epic_planner_state.py | lines 222-276 (_validate_ready_features), line 332 (key_gated), line 342 (call)
CITATION: scripts/dev_tools/validate_epic_planner_state.py | lines 287-294 (docstring), lines 330-331 (comment)
CITATION: extensions/drm-copilot/src/lib/validate/epic-planner-state-core.ts | lines 291-364 (validateReadyFeatures), lines 423-427 (comment and requireLaunchPaths), line 438 (call)
CITATION: tests/scripts/dev_tools/test_validate_epic_planner_state.py | test_readiness_requires_resolved_child_model_receipt, lines 176-188
CITATION: extensions/drm-copilot/test/lib/validate/validate-orchestration-service-call.test.ts | threads the Codex flags into epic-planner-state, lines 160-212
CITATION: extensions/drm-copilot/test/lib/validate/epic-planner-state-core.test.ts | builders lines 17-93
CITATION: tests/scripts/dev_tools/test_push_down_codex_and_agents_customizations.py | lines 397-404 (ready-gate source-text literals)
CITATION: scripts/dev_tools/_epic_orchestrator_state_launch_binding.py | lines 205-208 and 231-234 (key-gated launch skip and prefix)
CITATION: ./pyproject.toml | lines 85, 89, 95, 106, 116, 121
CITATION: extensions/drm-copilot/tsconfig.json | lines 12-16 (noUnusedLocals, exactOptionalPropertyTypes, noUncheckedIndexedAccess)
CITATION: .claude/hooks/enforce-python-batch-budget.ps1 | lines 10-14 and 25-29
CITATION: docs/features/active/epic-planner-receipt-checks-key-gate-543/spec.md | lines 221-238 (18 acceptance criteria)
CITATION: docs/features/active/epic-planner-receipt-checks-key-gate-543/spec.md | line 235 (AC15 line-count form)
AC-INVENTORY: AC1, AC2, AC3, AC4, AC5, AC6, AC7, AC8, AC9, AC10, AC11, AC12, AC13, AC14, AC15, AC16, AC17, AC18
AC-MAPPING: AC1 | IMPLEMENTATION: P1-T1, P2-T1 | TESTS: test_ready_gate_skips_feature_receipts_when_keys_absent | EVIDENCE: evidence/regression-testing/fail-before-python.<timestamp>.md, evidence/regression-testing/pass-after-python.<timestamp>.md
AC-MAPPING: AC2 | IMPLEMENTATION: P1-T3, P3-T1 | TESTS: skips the per-feature receipts when the keys are absent without a Codex flag | EVIDENCE: evidence/regression-testing/fail-before-typescript.<timestamp>.md, evidence/regression-testing/pass-after-typescript.<timestamp>.md
AC-MAPPING: AC3 | IMPLEMENTATION: P4-T1, P5-T1 | TESTS: test_codex_flag_keeps_feature_receipts_unconditional, keeps the per-feature receipts unconditional under %p | EVIDENCE: evidence/regression-testing/python-feature-receipts-suite.<timestamp>.md, evidence/regression-testing/typescript-feature-receipts-suites.<timestamp>.md
AC-MAPPING: AC4 | IMPLEMENTATION: P4-T2, P5-T2 | TESTS: test_ready_gate_validates_present_null_feature_receipt, validates a present null %s without a Codex flag | EVIDENCE: evidence/regression-testing/python-feature-receipts-suite.<timestamp>.md, evidence/regression-testing/typescript-feature-receipts-suites.<timestamp>.md
AC-MAPPING: AC5 | IMPLEMENTATION: P4-T3, P5-T3 | TESTS: test_ready_gate_gates_each_feature_receipt_independently, gates each per-feature receipt independently | EVIDENCE: evidence/regression-testing/python-feature-receipts-suite.<timestamp>.md, evidence/regression-testing/typescript-feature-receipts-suites.<timestamp>.md
AC-MAPPING: AC6 | IMPLEMENTATION: P4-T4, P5-T4 | TESTS: test_ready_gate_preserves_feature_index_when_receipts_skipped, preserves the feature index when receipts are skipped | EVIDENCE: evidence/regression-testing/python-feature-receipts-suite.<timestamp>.md, evidence/regression-testing/typescript-feature-receipts-suites.<timestamp>.md
AC-MAPPING: AC7 | IMPLEMENTATION: P4-T4 (ASSERTED_MESSAGES), P5-T1 through P5-T4 (TypeScript constants) | TESTS: P6-T3 Python-import versus TypeScript fixed-string comparison | EVIDENCE: evidence/qa-gates/byte-identical-strings.<timestamp>.md
AC-MAPPING: AC8 | IMPLEMENTATION: P4-T5 | TESTS: test_readiness_requires_resolved_child_model_receipt | EVIDENCE: evidence/regression-testing/python-feature-receipts-suite.<timestamp>.md
AC-MAPPING: AC9 | IMPLEMENTATION: P5-T5 | TESTS: threads the Codex flags into epic-planner-state | EVIDENCE: evidence/regression-testing/typescript-feature-receipts-suites.<timestamp>.md
AC-MAPPING: AC10 | IMPLEMENTATION: P2-T1, P3-T1 | TESTS: P6-T1 fixed-string token matches plus source reading | EVIDENCE: evidence/qa-gates/gating-predicate.<timestamp>.md
AC-MAPPING: AC11 | IMPLEMENTATION: P2-T1, P3-T1 | TESTS: P6-T2 removed-versus-added literal-line comparison over the main-anchored diff | EVIDENCE: evidence/qa-gates/error-strings-unchanged.<timestamp>.md
AC-MAPPING: AC12 | IMPLEMENTATION: P6-T4, P6-T5, P6-T6 | TESTS: test_readiness_requires_epic_preparation_topology_receipts, test_readiness_cross_binds_feature_complexity_and_model_context, test_ready_checkpoint_passes_execution_readiness, test_cli_dispatches_planner_readiness_flag, test_consumer_authority_is_typescript_only_and_scope_owners_are_unchanged, targeted pytest and Jest commands | EVIDENCE: evidence/regression-testing/preserved-tests.<timestamp>.md, evidence/regression-testing/targeted-python.<timestamp>.md, evidence/regression-testing/targeted-typescript.<timestamp>.md
AC-MAPPING: AC13 | IMPLEMENTATION: P6-T7 | TESTS: main-anchored git diff plus git status --porcelain over the excluded paths | EVIDENCE: evidence/qa-gates/scope-exclusions.<timestamp>.md
AC-MAPPING: AC14 | IMPLEMENTATION: P2-T2, P3-T2 | TESTS: P6-T8 per-feature receipt token matches plus source reading | EVIDENCE: evidence/qa-gates/docs-updated.<timestamp>.md
AC-MAPPING: AC15 | IMPLEMENTATION: P3-T3, P3-T4, P9-T3 | TESTS: grep -c -e '' <path> per file (equivalent to the spec's (Get-Content <path>).Count) | EVIDENCE: evidence/other/ts-line-budget.<timestamp>.md, evidence/qa-gates/line-counts-final.<timestamp>.md
AC-MAPPING: AC16 | IMPLEMENTATION: P7-T1 through P7-T8 | TESTS: black, ruff, pyright, pytest with --cov=scripts.dev_tools.validate_epic_planner_state --cov-branch --cov-report=term-missing | EVIDENCE: evidence/qa-gates/final-python-per-file-coverage.<timestamp>.md, evidence/qa-gates/coverage-delta-verification.<timestamp>.md, evidence/qa-gates/final-qa-clean-pass.<timestamp>.md
AC-MAPPING: AC17 | IMPLEMENTATION: P8-T1 through P8-T7 | TESTS: prettier --check, npm run lint, npm run typecheck, node run-jest.cjs --coverage with text reporters | EVIDENCE: evidence/qa-gates/final-typescript-test-coverage.<timestamp>.md, evidence/qa-gates/coverage-delta-verification.<timestamp>.md, evidence/qa-gates/final-qa-clean-pass.<timestamp>.md
AC-MAPPING: AC18 | IMPLEMENTATION: deferred to S9 pr-author (P9-T5 leaves it unchecked) | TESTS: CI conclusion on the final PR head | EVIDENCE: PR body containing Closes #543 and the CI result recorded at S9
UNRESOLVED-GAPS: NONE
DIRECTIVE: PREFLIGHT VALIDATION ONLY

## Plan Deviations

1. **Route: npm-prefix for some TypeScript commands (P0-T14, P0-T15, P0-T17, P0-T18, P8-T2, P8-T3, P8-T5).** A PreToolUse hook denied a `cd extensions/drm-copilot && ... | tail` form, so these commands used the plan's `npm --prefix extensions/drm-copilot run lint` / `run typecheck` / `test -- <args>` substitutions, with output redirected to `SCRATCH/543/` files. Each artifact records `Route: npm-prefix`. The other TypeScript commands (Prettier and targeted `node run-jest.cjs` runs) used the `cd`-chained form with output redirected to a file, which the hook permitted.
2. **P2-T1: Black reflowed one moved condition.** The extracted `_validate_feature_model_receipt` body is the old loop body with shallower indentation. Black joined the three-line condition `and cast("dict[str, Any]", model_receipt).get("logical_agent")` / `!= "orchestrator"` onto one line, because the line fits within 88 columns at the new indent. No string literal changed; P6-T2 records this.
3. **P4-T4: pre-authorized S105 suppression on two test constants.** Ruff S105 ("possible hardcoded password") fired on `FEATURE0_TOPOLOGY_TOKEN` and `FEATURE0_MODEL_TOKEN` because their names contain `TOKEN`. The plan fixes these names, and they must match the TypeScript names. Each value line carries `# noqa: S105 - test fixture data`, the pre-authorized "S108 / S105 — Hardcoded paths/passwords in tests only" pattern in `.claude/rules/python-suppressions.md`. Black wrapped both constants in parentheses. P6-T3 is unaffected: it compares values, and the comment is not part of a value.
4. **P5-T5: Prettier rewrote only the appended assertions.** After the six assertions were appended, `npx prettier --check` reported the service-call test file. `npx prettier --write` on that file changed the wrapping of the appended lines only; no pre-existing line of the test changed (P6-T6 and the P5-T5 run confirm). This happened before the Phase 8 loop, so no loop restart applies.
5. **Commit-task ticks.** The check-off for each phase's commit task (P0-T20, P5-T7, P6-T9, P7-T9, P8-T8) was recorded on disk after its push was verified, so it is carried by the next phase's commit. The ticks for P1-T5, P2-T5, P3-T7, and P4-T7 were not applied when those tasks passed (push exit 0, empty porcelain, and HEAD equal to the remote branch were all observed). P9-T6 reconciliation applied them.
6. **P7-T3: pyright exit code re-read.** The first pyright invocation was piped into `head`, which returned exit 120 from the closed pipe. The unpiped re-run exited 0 and is the recorded result.
7. **Evidence writing mechanism.** The worktree isolation guard denied a heredoc-based artifact write, so every evidence artifact was written with the file-write tool, using a timestamp read immediately before from `date -u +%Y-%m-%dT%H-%M`. Artifact content and paths follow the plan.
8. **P0-T3 anchor.** Local `main` equalled `origin/main` (adb9aa5f02fc0ae84fd7e6060f758a8b0974eb99) and `MAIN_BASE_SHA`, so no `origin/main` or merge-base substitution was needed for any `git diff main` command.
