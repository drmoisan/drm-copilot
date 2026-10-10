# 2026-10-08-epic-planner-topology-receipt-gate (Plan)

- **Issue:** #543 (residual scope)
- **Parent (optional):** none
- **Owner:** drmoisan
- **Last Updated:** 2026-10-08T14-30
- **Status:** Ready for preflight
- **Version:** 1.0
- **Work Mode:** full-bug (from `issue.md` line 10)
- **Branch:** `bug/epic-planner-topology-receipt-gate-543`
- **Requirements source:** `docs/features/active/2026-10-08-epic-planner-topology-receipt-gate-543/spec.md`, section `## Acceptance Criteria` (14 items, planning-time lines 223-236). `user-story.md` is intentionally absent for this bug and must not be created.
- **Design source:** `docs/features/active/2026-10-08-epic-planner-topology-receipt-gate-543/research/research.2026-10-08T14-00.md` (Approach A).
- **Defect report:** `docs/features/active/2026-10-08-epic-planner-topology-receipt-gate-543/issue.md`

**Fail-closed evidence rule:** Every baseline task, final-QA task, and coverage-comparison task in this plan produces a named artifact. If any required artifact is missing, or carries a placeholder in place of a numeric value, the verdict is BLOCKED or INCOMPLETE, never PASS.

**Evidence accounting rule:** Each evidence-producing task names its artifact path. Do not mark an evidence-backed task complete without the artifact on disk. `<ts>` in an artifact name is the execution timestamp in `yyyy-MM-ddTHH-mm` form, read from the host clock at the time the command runs.

**Evidence location:** All evidence resolves under `docs/features/active/2026-10-08-epic-planner-topology-receipt-gate-543/evidence/<kind>/`, with `<kind>` drawn from `baseline`, `regression-testing`, `qa-gates`, and `other`, per `.claude/skills/evidence-and-timestamp-conventions/SKILL.md`. No non-canonical evidence path was supplied by the caller or the spec, so no `EVIDENCE_LOCATION_OVERRIDE_REJECTED` record applies.

**Artifact-only tool output:** `artifacts/python/coverage-543-topology-baseline.json` and `artifacts/python/coverage-543-topology-final.json` are intermediate tool outputs under the gitignored `/artifacts` tree (`.gitignore` line 6). They are not evidence; the evidence is the Markdown artifact under `evidence/` that records the values read from them.

---

## The change, already decided

Under `require_ready_for_execution=True`, the planner-level topology-receipt check runs unconditionally in both runtimes: the Python call at `scripts/dev_tools/validate_epic_planner_state.py` line 345 and the TypeScript call at `extensions/drm-copilot/src/lib/validate/epic-planner-state-core.ts` line 443. The correction, which this plan encodes and does not re-litigate:

1. Python: wrap the call in the condition quoted below, reusing `key_gated` (line 329).
2. TypeScript: wrap the call in the condition quoted below, reusing `requireLaunchPaths` (lines 424-426).
3. Presence is key membership, not value truthiness: a present `null` value still runs the check.
4. With either Codex flag asserted, the check runs unconditionally, exactly as before.
5. No error string is added, removed, or reworded; no function signature changes; no plumbing, CLI, guidance, mirror, rule, or Jest-config file changes.
6. The per-feature `model_routing_receipt` / `topology_receipt` checks in `_validate_ready_features` / `validateReadyFeatures` stay unconditional (spec Non-goals); the PR therefore states "Partially addresses #543".

## Files the diff will WRITE

Production, Python (1):

- `scripts/dev_tools/validate_epic_planner_state.py`

Production, TypeScript (1):

- `extensions/drm-copilot/src/lib/validate/epic-planner-state-core.ts`

Tests, Python (1):

- `tests/scripts/dev_tools/test_validate_epic_planner_state.py`

Tests, TypeScript (2):

- `extensions/drm-copilot/test/lib/validate/epic-planner-state-core.test.ts`
- `extensions/drm-copilot/test/lib/validate/validate-orchestration-service-call.test.ts`

Feature-process files written outside the code diff:

- `docs/features/active/2026-10-08-epic-planner-topology-receipt-gate-543/spec.md` (checkbox state of the `## Acceptance Criteria` section only; each criterion is ticked at its mapped task under the Execution-notes acceptance-criteria tick rule, and P9-T5 verifies the result and completes any criterion still unticked)
- `docs/features/active/2026-10-08-epic-planner-topology-receipt-gate-543/plan.2026-10-08T13-56.md` (this file; task checkbox state only; P9-T6)
- Evidence artifacts under `docs/features/active/2026-10-08-epic-planner-topology-receipt-gate-543/evidence/baseline/`, `evidence/regression-testing/`, `evidence/qa-gates/`, and `evidence/other/`.

No file is created by the code diff; every code file above exists at planning time. No fixture file is created or edited: every test builds its state in memory from the existing `_ready_state()` (Python, lines 64-84) and `readyState()` (TypeScript, lines 67-82) builders.

Planning-time physical line counts: `validate_epic_planner_state.py` 369, `epic-planner-state-core.ts` 471, `test_validate_epic_planner_state.py` 360, `epic-planner-state-core.test.ts` 413, `validate-orchestration-service-call.test.ts` 225. Expected post-change counts: about 373, 474, 428, 490, and 232 respectively (232 is 225 plus 7: the routing and topology toContain assertions are 82 and 83 columns and each wraps to three lines, and the 68-column keyGated assertion stays on one line); every one must be at or below 500. The 490 estimate for epic-planner-state-core.test.ts is 413 plus 77 added lines: 1 import type line (kept on one line, as the existing 97-character line 4 import is), 15 module-level lines (the four-line CodexFlags type, the two four-line case tables, and three separating blank lines), and 13, 17, 13, and 18 lines for the P1-T4, P5-T1, P5-T2, and P5-T3 tests (each including its trailing blank separator). It assumes Prettier's three-argument it.each(table)(title, fn) layout (as at extensions/drm-copilot/test/mcp-repo-automation-tool-definitions.test.ts lines 293-295), the single-line it(title, () => { header for plain it calls (as at line 148 of extensions/drm-copilot/test/lib/validate/epic-planner-state-core.test.ts, 84 characters), and the comment-free test bodies required by P1-T4 and P5-T1 through P5-T3.

## Read-only citations (NOT written by this diff)

- Policy: `CLAUDE.md`; `.github/copilot-instructions.md`; `.github/instructions/general-code-change.instructions.md`; `.github/instructions/general-unit-test.instructions.md`; `.github/instructions/python-code-change.instructions.md`; `.github/instructions/python-unit-test.instructions.md`; `.github/instructions/python-suppressions.instructions.md`; `.github/instructions/typescript-code-change.instructions.md`; `.github/instructions/typescript-unit-test.instructions.md`; `.github/instructions/typescript-suppressions.instructions.md`; `.claude/rules/general-code-change.md`; `.claude/rules/general-unit-test.md`; `.claude/rules/python.md`; `.claude/rules/python-suppressions.md`; `.claude/rules/typescript.md`; `.claude/rules/typescript-suppressions.md`; `.claude/rules/quality-tiers.md`; `.claude/rules/tonality.md`; `.claude/rules/plan-acceptance-gates.md`; `.claude/skills/evidence-and-timestamp-conventions/SKILL.md`.
- Tests run but not edited: `tests/scripts/dev_tools/test_validate_epic_planner_state_launch_binding.py`, `tests/scripts/dev_tools/test_epic_planner_readiness.py`, `tests/scripts/dev_tools/test_push_down_codex_and_agents_customizations.py`, `extensions/drm-copilot/test/lib/validate/epic-planner-state-launch-binding.test.ts`, `extensions/drm-copilot/test/lib/validate/epic-planner-readiness-integrity.test.ts`, `extensions/drm-copilot/test/mcp-server-epic-validation.test.ts`.

No file under `.claude/rules/` or `.github/instructions/` is modified by this plan.

## Explicitly out of scope

- `scripts/dev_tools/validate_orchestration_artifacts.py` (495 lines; Python CLI unchanged).
- `.claude/**`, `.github/**`, `.agents/**`, `.codex/**`, `extensions/drm-copilot/resources/**`.
- `extensions/drm-copilot/jest.config.cjs` (no per-file threshold entry is added; research section 10).
- `extensions/drm-copilot/src/mcp-tool-inputs.ts`, `extensions/drm-copilot/src/mcp-tool-definitions.ts`, `extensions/drm-copilot/src/mcp-repo-automation-tool-definitions.ts`, `extensions/drm-copilot/src/lib/validate/orchestration-artifacts.ts`.
- The per-feature receipt checks (`scripts/dev_tools/validate_epic_planner_state.py` lines 222-276; `epic-planner-state-core.ts` lines 292-364) and the `REQUIRED_KEYS` / `REQUIRED_FEATURE_KEYS` contract gap (spec Rollout; follow-up issue, not filed by this plan).

## Named tests and literals introduced by this plan

Quoted verbatim so a search or a `-k` / `-t` selector for them is a real assertion.

New production condition lines (single-line tokens after Black and Prettier formatting):

- Python: `if not key_gated or "topology_receipt" in state:`
- TypeScript: `if (!requireLaunchPaths || "topology_receipt" in value) {`

Python, in `tests/scripts/dev_tools/test_validate_epic_planner_state.py`:

- `test_readiness_requires_epic_preparation_topology_receipts` (existing; call updated to pass `require_codex_topology=True`)
- `test_ready_gate_skips_planner_topology_receipt_when_key_absent` (new; fail-before regression test)
- `test_codex_flag_keeps_planner_topology_receipt_unconditional` (new; parametrized over `"require_codex_model_routing"` and `"require_codex_topology"`)
- `test_ready_gate_validates_present_null_planner_topology_receipt` (new)
- `test_ready_gate_accepts_present_valid_planner_topology_receipt` (new; parametrized over `require_codex_topology` `False` and `True`)

TypeScript, in `extensions/drm-copilot/test/lib/validate/epic-planner-state-core.test.ts` (inside the existing `describe("validateEpicPlannerStateText")` block):

- `skips the planner topology receipt when the key is absent without a Codex flag` (new; fail-before regression twin)
- `keeps the planner topology receipt unconditional under %p` (new; `it.each` over `{ requireCodexModelRouting: true }` and `{ requireCodexTopology: true }`)
- `validates a present null planner topology receipt without a Codex flag` (new)
- `accepts a present valid planner topology receipt under %p` (new; `it.each` over `{}` and `{ requireCodexTopology: true }`)

TypeScript, in `extensions/drm-copilot/test/lib/validate/validate-orchestration-service-call.test.ts`:

- `threads the Codex flags into epic-planner-state` (existing, lines 160-205; three assertions appended)

Byte-identical error string asserted in both runtimes: `Epic planner topology_receipt must be an object.`

Substring asserted absent in both runtimes: `Epic planner topology_receipt` (it does not occur inside the per-feature prefix `Epic planner checkpoint features[0].topology_receipt`).

## Execution notes

- **Shell routing.** Run `poetry`, `git`, `grep`, `awk`, and `ls` commands directly in the Bash tool from the worktree root. A command marked "in `extensions/drm-copilot/`" runs as `cd extensions/drm-copilot && <command>` in the Bash tool, because `extensions/drm-copilot/run-jest.cjs` line 28 passes the relative `--config jest.config.cjs`. If a hook denies the `cd`-chained form, substitute `npm --prefix extensions/drm-copilot run <script> -- <args>` for `npm run` and `node run-jest.cjs` invocations (the `test` script at `extensions/drm-copilot/package.json` line 211 is `node run-jest.cjs`), record the substituted command in `Command:`, and add `Route: npm-prefix`. No `sh` wrapper and no PowerShell route is used.
- **Scope anchor.** P0-T3 records the merge base as a literal 40-character SHA. In every later command, the token `MERGE_BASE_SHA` is replaced by that literal SHA before the command runs, and the artifact's `Command:` records the substituted command. The anchor stays fixed if `origin/main` advances. Spec acceptance criteria 8 and 10 name `git diff main`; this plan runs the anchored form against the recorded merge base, which is the deterministic equivalent, and each affected artifact records that substitution.
- **Line counts.** Physical line counts use `awk 'END{print NR}' <path>` in the Bash tool, which counts every line including a final line without a newline. Spec acceptance criterion 14 names `(Get-Content <path>).Count`; the `awk` form returns the same physical count without a PowerShell route, and P9-T3 records the substitution.
- **Multi-command artifacts.** An artifact that records several commands lists each command's printed result and exit status in `Output Summary:`. Its `EXIT_CODE:` is `0` only when every command's exit status equals the expectation stated in the task. A `grep -c` that prints `0` exits 1 by design; where a task expects a count of `0`, exit 1 is that command's stated expectation.
- **Python branch coverage.** The `term-missing` `Cover` column is a combined statement-plus-branch figure. Per-file line and branch percentages are read from `coverage json` output (`files[<key>].summary.covered_lines / num_statements` and `covered_branches / num_branches`), never derived from the terminal row. The coverage data file is `artifacts/.coverage` (`pyproject.toml` line 121). On Windows the JSON key is `scripts\\dev_tools\\validate_epic_planner_state.py`.
- **Known local-only failure (#510).** `tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py::test_bundled_claude_payload_contains_all_repo_runtime_contracts` (line 89) enumerates the on-disk `.claude` tree and fails locally regardless of this change. Every full-suite Python run (baseline and final) passes the identical `--deselect` for that node.
- **Batch budget.** `.claude/hooks/enforce-python-batch-budget.ps1` (lines 10-13 and 25-29) denies the fourth distinct Python production file per session and does not count test files. This plan writes 1 Python production file and 1 Python test file (2 Python files in total), and 3 TypeScript files (1 production, 2 test), for which no batch-budget hook exists (`.claude/hooks/` holds only the Python and PowerShell budget hooks). Under either counting rule no limit is reached, so no reset is scheduled. If a write is nevertheless denied by the hook, stop and report the denial text to the orchestrator; do not delete hook state.
- **Acceptance-criteria tick rule.** Per .claude/skills/acceptance-criteria-tracking/SKILL.md (Check-Off Protocol, Timing), each criterion in the ## Acceptance Criteria section of spec.md is changed from - [ ] to - [x], with no criterion text changed, immediately after the last of its mapped tasks in the P9-T5 mapping passes verification. No other spec checkbox is changed. P9-T5 verifies the result.
- **Restart rule for regression tasks.** A task in Phases 1-6 whose acceptance fails is fixed and re-run in place; it does not restart Phase 0.

---

### Phase 0 — Policy reads, environment, and baseline capture

- [x] [P0-T1] Read the policy files in order and write the Phase 0 read record to `docs/features/active/2026-10-08-epic-planner-topology-receipt-gate-543/evidence/baseline/phase0-instructions-read.md`.
  - Files, in order: the twenty policy paths listed under "Read-only citations", in the order listed there (`CLAUDE.md` first, `.claude/skills/evidence-and-timestamp-conventions/SKILL.md` last).
  - Acceptance: the artifact exists and contains `Timestamp:`, `Policy Order: CLAUDE.md -> .github policy (general, Python, TypeScript) -> .claude/rules (general, Python, TypeScript, tiers, tonality, plan gates) -> evidence conventions`, and `Files Read:` listing the twenty paths in that order. No Phase 1 task begins before this artifact exists.

- [x] [P0-T2] Read `spec.md`, `issue.md`, and `research/research.2026-10-08T14-00.md` in this feature folder and write `docs/features/active/2026-10-08-epic-planner-topology-receipt-gate-543/evidence/baseline/scope-confirmation.<ts>.md`.
  - Acceptance: the artifact contains `Timestamp:`, the five code paths from "Files the diff will WRITE", the out-of-scope list from "Explicitly out of scope", `Work Mode: full-bug`, and `AC count: 14`.

- [x] [P0-T3] Record the scope anchor by running `git fetch origin main`, then `git merge-base HEAD origin/main`, then `git status --porcelain`, each in the Bash tool from the worktree root.
  - Acceptance: `docs/features/active/2026-10-08-epic-planner-topology-receipt-gate-543/evidence/baseline/scope-anchor.<ts>.md` exists with `Timestamp:`, `Command:` (all three), `EXIT_CODE: 0`, and `Output Summary:` recording the 40-character merge-base SHA on its own line as `MERGE_BASE_SHA: <sha>` and the porcelain output verbatim. The porcelain output lists no path outside `docs/features/active/2026-10-08-epic-planner-topology-receipt-gate-543/`; if it lists any other path, stop and report to the orchestrator before Phase 1.

- [x] [P0-T4] Confirm the toolchains: run `poetry run python --version` and `ls extensions/drm-copilot/node_modules/jest/package.json extensions/drm-copilot/node_modules/prettier/package.json` in the Bash tool; if `ls` reports either path missing, run `npm ci` in `extensions/drm-copilot/` and repeat the `ls`.
  - Acceptance: `docs/features/active/2026-10-08-epic-planner-topology-receipt-gate-543/evidence/baseline/toolchain-availability.<ts>.md` exists with `Timestamp:`, `Command:`, `EXIT_CODE: 0`, and `Output Summary:` recording the `Python 3.` version line and both `package.json` paths printed by the final `ls` (plus the `added N packages` line when `npm ci` ran). Any other result stops the plan before Phase 1.

- [x] [P0-T5] Write the batch-budget record to `docs/features/active/2026-10-08-epic-planner-topology-receipt-gate-543/evidence/other/batch-budget.<ts>.md`.
  - Acceptance: the artifact exists with `Timestamp:`, `Python production files: 1 (scripts/dev_tools/validate_epic_planner_state.py)`, `Python test files: 1 (tests/scripts/dev_tools/test_validate_epic_planner_state.py; not counted by the hook)`, `TypeScript files: 3 (no batch-budget hook)`, the cap source (`.claude/hooks/enforce-python-batch-budget.ps1` lines 10-13 and 25-29), and `Resets scheduled: 0`.

- [x] [P0-T6] Record baseline physical line counts by running `awk 'END{print NR}' <path>` once for each of the five code paths in "Files the diff will WRITE".
  - Acceptance: `docs/features/active/2026-10-08-epic-planner-topology-receipt-gate-543/evidence/baseline/line-counts.<ts>.md` exists with `Timestamp:`, `Command:`, `EXIT_CODE: 0`, and `Output Summary:` listing five counts. Planning-time values: 369, 471, 360, 413, 225 (in the order of "Files the diff will WRITE"). Any differing count is listed explicitly; a differing count means the tree moved since planning, and every line number cited in Phases 1-3 is then re-located by construct (function name and quoted statement) before editing.

- [x] [P0-T7] Capture the Python formatting baseline by running `poetry run black --check scripts/dev_tools/validate_epic_planner_state.py tests/scripts/dev_tools/test_validate_epic_planner_state.py`.
  - Check mode only; no source is written.
  - Acceptance: `docs/features/active/2026-10-08-epic-planner-topology-receipt-gate-543/evidence/baseline/baseline-python-format.<ts>.md` exists with `Timestamp:`, `Command:`, `EXIT_CODE:`, and `Output Summary:` recording the Black summary line (on a clean pair it reads `2 files would be left unchanged.`). Stop condition: a non-zero exit stops the plan before Phase 1, because the final gate P7-T1 requires exit 0 over these files.

- [x] [P0-T8] Capture the Python lint baseline by running `poetry run ruff check scripts/dev_tools/validate_epic_planner_state.py tests/scripts/dev_tools/test_validate_epic_planner_state.py`.
  - The `[tool.ruff]` table in `pyproject.toml` sets no `fix = true`, so this command reports and does not rewrite.
  - Acceptance: `docs/features/active/2026-10-08-epic-planner-topology-receipt-gate-543/evidence/baseline/baseline-python-lint.<ts>.md` exists with the four fields and an `Output Summary:` recording `All checks passed!` or the numeric finding count. Stop condition: a non-zero exit stops the plan before Phase 1.

- [x] [P0-T9] Capture the Python type-check baseline by running `poetry run pyright scripts/dev_tools/validate_epic_planner_state.py tests/scripts/dev_tools/test_validate_epic_planner_state.py`.
  - Acceptance: `docs/features/active/2026-10-08-epic-planner-topology-receipt-gate-543/evidence/baseline/baseline-python-typecheck.<ts>.md` exists with the four fields and an `Output Summary:` recording the Pyright summary line with numeric error, warning, and information counts (a clean run prints `0 errors, 0 warnings, 0 informations`). Stop condition: a non-zero exit stops the plan before Phase 1.

- [x] [P0-T10] Capture the Python full-suite test and coverage baseline by running `poetry run pytest --cov=scripts.dev_tools --cov-branch --cov-report=term-missing --deselect tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py::test_bundled_claude_payload_contains_all_repo_runtime_contracts` from the worktree root.
  - Acceptance: `docs/features/active/2026-10-08-epic-planner-topology-receipt-gate-543/evidence/baseline/baseline-python-test-coverage.<ts>.md` exists with `Timestamp:`, `Command:`, `EXIT_CODE:`, and an `Output Summary:` recording the pytest result line (passed, failed, skipped, and deselected counts; deselected must be 1, citing #510), the `TOTAL` row verbatim, and the `term-missing` row for `scripts/dev_tools/validate_epic_planner_state.py` including its `Missing` cell. Stop condition: if any test fails, stop and report the failing node IDs to the orchestrator before Phase 1.

- [x] [P0-T11] Capture the Python per-file baseline coverage by running `poetry run coverage json --data-file=artifacts/.coverage --include="*validate_epic_planner_state.py" --pretty-print -o artifacts/python/coverage-543-topology-baseline.json` immediately after P0-T10 and reading the JSON.
  - Acceptance: `docs/features/active/2026-10-08-epic-planner-topology-receipt-gate-543/evidence/baseline/baseline-python-per-file-coverage.<ts>.md` exists with the four fields and an `Output Summary:` recording, for `scripts/dev_tools/validate_epic_planner_state.py`, `covered_lines`/`num_statements` and `covered_branches`/`num_branches` from `files[<key>].summary` with both percentages to two decimals, and the `missing_lines` and `missing_branches` lists. No placeholders. Stop condition: a line percentage below 85.00 or a branch percentage below 75.00 at baseline stops the plan before Phase 1 and is reported to the orchestrator.

- [x] [P0-T12] Capture the Python targeted-module baseline by running the spec's targeted command: `poetry run pytest tests/scripts/dev_tools/test_validate_epic_planner_state.py tests/scripts/dev_tools/test_validate_epic_planner_state_launch_binding.py tests/scripts/dev_tools/test_epic_planner_readiness.py tests/scripts/dev_tools/test_push_down_codex_and_agents_customizations.py --cov=scripts.dev_tools.validate_epic_planner_state --cov-branch --cov-report=term-missing`.
  - Acceptance: `docs/features/active/2026-10-08-epic-planner-topology-receipt-gate-543/evidence/baseline/baseline-python-targeted.<ts>.md` exists with the four fields and an `Output Summary:` recording the result line with 0 failed and the `term-missing` row for `scripts/dev_tools/validate_epic_planner_state.py` (the targeted-module headline). Stop condition: any failed test stops the plan before Phase 1.

- [x] [P0-T13] Capture the TypeScript formatting baseline by running `npx prettier --check src/lib/validate/epic-planner-state-core.ts test/lib/validate/epic-planner-state-core.test.ts test/lib/validate/validate-orchestration-service-call.test.ts` in `extensions/drm-copilot/`.
  - Check mode only; no source is written.
  - Acceptance: `docs/features/active/2026-10-08-epic-planner-topology-receipt-gate-543/evidence/baseline/baseline-typescript-format.<ts>.md` exists with the four fields and an `Output Summary:` recording `All matched files use Prettier code style!` or the list of files reported. Stop condition: a non-zero exit stops the plan before Phase 1.

- [x] [P0-T14] Capture the TypeScript lint baseline by running `npm run lint` in `extensions/drm-copilot/` (script at `extensions/drm-copilot/package.json` line 208).
  - Acceptance: `docs/features/active/2026-10-08-epic-planner-topology-receipt-gate-543/evidence/baseline/baseline-typescript-lint.<ts>.md` exists with the four fields and an `Output Summary:` recording numeric error and warning counts (0 and 0 when ESLint prints no problem lines). Stop condition: a non-zero exit stops the plan before Phase 1.

- [x] [P0-T15] Capture the TypeScript type-check baseline by running `npm run typecheck` in `extensions/drm-copilot/` (script at `extensions/drm-copilot/package.json` line 209).
  - Acceptance: `docs/features/active/2026-10-08-epic-planner-topology-receipt-gate-543/evidence/baseline/baseline-typescript-typecheck.<ts>.md` exists with the four fields and an `Output Summary:` recording the count of `error TS` lines. Stop condition: a non-zero exit stops the plan before Phase 1.

- [x] [P0-T16] Capture the architecture-boundary baseline for both languages by running `git ls-files -- "*.dependency-cruiser*" "*importlinter*" ".importlinter"` and `grep -c -F -e importlinter pyproject.toml` in the Bash tool from the worktree root.
  - Acceptance: `docs/features/active/2026-10-08-epic-planner-topology-receipt-gate-543/evidence/baseline/baseline-architecture.<ts>.md` exists with the four fields and an `Output Summary:` stating either `no architecture-boundary tool configured for TypeScript or Python; stage recorded as a presence check` (first command prints nothing; second prints `0`, because the literal `importlinter` is expected to be absent from `pyproject.toml`) or listing each configuration found. If a configuration is found, the summary records the command that runs it and its violation count, and that command becomes the architecture stage in P7-T4 and P8-T4.

- [x] [P0-T17] Capture the TypeScript full-suite test and coverage baseline by running `node run-jest.cjs --coverage --coverageReporters=text --coverageReporters=text-summary` in `extensions/drm-copilot/`.
  - Acceptance: `docs/features/active/2026-10-08-epic-planner-topology-receipt-gate-543/evidence/baseline/baseline-typescript-test-coverage.<ts>.md` exists with the four fields and an `Output Summary:` recording the `Test Suites:` and `Tests:` lines verbatim, the text-summary `Lines` and `Branches` totals, and the `text` table row for `epic-planner-state-core.ts` (`% Stmts | % Branch | % Funcs | % Lines | Uncovered Line #s`) verbatim. No placeholders. Stop conditions: a non-zero exit or any failed test stops the plan before Phase 1; a `% Lines` below 85 or `% Branch` below 75 on that row stops the plan before Phase 1 and is reported to the orchestrator.

- [x] [P0-T18] Capture the TypeScript targeted baseline by running the spec's targeted command `node run-jest.cjs test/lib/validate/epic-planner-state-core.test.ts test/lib/validate/validate-orchestration-service-call.test.ts test/lib/validate/epic-planner-state-launch-binding.test.ts test/lib/validate/epic-planner-readiness-integrity.test.ts` in `extensions/drm-copilot/` (no `--coverage`, because per-file `coverageThreshold` entries fail a subset coverage run).
  - Acceptance: `docs/features/active/2026-10-08-epic-planner-topology-receipt-gate-543/evidence/baseline/baseline-typescript-targeted.<ts>.md` exists with the four fields and an `Output Summary:` recording `Test Suites: 4 passed, 4 total` and the `Tests:` line with 0 failed. Stop condition: any failure stops the plan before Phase 1.

- [x] [P0-T19] Record the baseline checkbox state of `docs/features/active/2026-10-08-epic-planner-topology-receipt-gate-543/spec.md` by running `grep -c -e '^- \[ \] ' docs/features/active/2026-10-08-epic-planner-topology-receipt-gate-543/spec.md` and `grep -c -e '^- \[x\] ' docs/features/active/2026-10-08-epic-planner-topology-receipt-gate-543/spec.md` in the Bash tool.
  - Acceptance: `docs/features/active/2026-10-08-epic-planner-topology-receipt-gate-543/evidence/baseline/baseline-spec-checkboxes.<ts>.md` exists with the four fields and an `Output Summary:` recording `20` unchecked and `1` checked (14 acceptance criteria, 3 Test Strategy items, and 3 Impact/Severity boxes unchecked; the `High` severity box checked, at planning time).

### Phase 1 — Fail-before regression tests

- [ ] [P1-T1] Update `tests/scripts/dev_tools/test_validate_epic_planner_state.py`: in `test_readiness_requires_epic_preparation_topology_receipts` (planning-time lines 213-234), change the call at planning-time line 222 from `json.dumps(state), require_ready_for_execution=True` to `json.dumps(state), require_ready_for_execution=True, require_codex_topology=True` (an 88-character line at its 8-space indent, within the 88-column limit at `pyproject.toml` lines 85 and 89, so Black keeps it on one line). Change nothing else in the test: its three `any(...)` assertions, including the per-feature ones, are retained unchanged.
  - Rationale: this test pins the defect (it asserts the top-level error with no Codex flag). Under a Codex flag the check stays unconditional both before and after the fix, so the test passes in both states and does not block the fix tasks.
  - Acceptance: `poetry run pytest "tests/scripts/dev_tools/test_validate_epic_planner_state.py::test_readiness_requires_epic_preparation_topology_receipts" -v` exits 0 with `1 passed` on pre-fix production code.

- [ ] [P1-T2] Add `test_ready_gate_skips_planner_topology_receipt_when_key_absent` to `tests/scripts/dev_tools/test_validate_epic_planner_state.py`, placed after `test_readiness_requires_forced_epic_planner_persona`.
  - Body (Arrange-Act-Assert): `state = _ready_state()`; `state.pop("topology_receipt")`; `errors = validate_epic_planner_state_text(json.dumps(state), require_ready_for_execution=True)` with no Codex flag; `offending = [error for error in errors if "Epic planner topology_receipt" in error]`; a single `assert offending == []`, so the pre-fix failure prints the offending list on one line. One-line docstring: `Skip the planner receipt check for a Claude checkpoint without the key.`
  - Acceptance: the function exists with exactly that name; it uses no temporary file, clock, or network; `poetry run python -m py_compile tests/scripts/dev_tools/test_validate_epic_planner_state.py` exits 0.

- [ ] [P1-T3] [expect-fail] Run `poetry run pytest "tests/scripts/dev_tools/test_validate_epic_planner_state.py::test_ready_gate_skips_planner_topology_receipt_when_key_absent" -vv` on pre-fix production code.
  - Acceptance: `docs/features/active/2026-10-08-epic-planner-topology-receipt-gate-543/evidence/regression-testing/fail-before-python.<ts>.md` exists with `Timestamp:`, `Command:`, `EXIT_CODE: 1`, `ExpectedExitCode: 1`, and an `Output Summary:` showing `1 failed` and 0 passed for that node, and citing the single assertion-output line, which contains `Epic planner topology_receipt must be an object.` and `== []`. A failure for any other reason (import error, collection error, fixture error) does not satisfy this task; fix the test and re-run.

- [ ] [P1-T4] Add the Jest test `skips the planner topology receipt when the key is absent without a Codex flag` to `extensions/drm-copilot/test/lib/validate/epic-planner-state-core.test.ts`, inside the `describe("validateEpicPlannerStateText")` block, placed after `it("requires the forced epic-planner topology receipt")` (planning-time lines 330-346).
  - Body: `const state = readyState();` then `delete state["topology_receipt"];` (the same `delete` form already used at `extensions/drm-copilot/test/lib/validate/epic-planner-state-launch-binding.test.ts` line 18), call `validateEpicPlannerStateText(JSON.stringify(state), { requireReadyForExecution: true })`, and assert `expect(errors.filter((error) => error.includes("Epic planner topology_receipt"))).toEqual([]);`.
  - Style: separate the arrange, act, and assert sections with single blank lines and add no // Arrange, // Act, or // Assert comment lines, matching the neighbouring test at planning-time lines 330-346; this keeps the file within the 500-line limit.
  - Acceptance: the test exists with exactly that title; it uses only options that exist on pre-fix `ValidateEpicPlannerStateOptions` (lines 51-60), so it fails behaviourally rather than at compile time.

- [ ] [P1-T5] [expect-fail] Run `node run-jest.cjs test/lib/validate/epic-planner-state-core.test.ts -t "skips the planner topology receipt when the key is absent"` in `extensions/drm-copilot/` on pre-fix production code.
  - Acceptance: `docs/features/active/2026-10-08-epic-planner-topology-receipt-gate-543/evidence/regression-testing/fail-before-typescript.<ts>.md` exists with `Timestamp:`, `Command:`, `EXIT_CODE: 1`, `ExpectedExitCode: 1`, and an `Output Summary:` showing `Tests:` with `1 failed` for that title, zero `error TS` lines, and the Jest received-value output containing `Epic planner topology_receipt must be an object.`

### Phase 2 — Python production fix

- [ ] [P2-T1] Update `scripts/dev_tools/validate_epic_planner_state.py` in `validate_epic_planner_state_text`:
  - Replace the call at planning-time line 345 with the condition `if not key_gated or "topology_receipt" in state:` followed by the indented call `errors.extend(_validate_planner_topology_receipt(state.get("topology_receipt")))`, wrapped by Black into the three-line `errors.extend(` / argument / `)` form.
  - Replace the comment at planning-time line 328 with the two lines `# Launch evidence (per feature) and the planner topology receipt (top-level` and `# key) are key-gated unless a Codex flag is asserted.`
  - Replace the docstring paragraph at planning-time lines 289-291 with text stating that both Codex flags make launch evidence and the planner `topology_receipt` unconditional under execution readiness, and that when neither flag is set, launch evidence is validated only for features carrying a launch path key and the planner receipt only when the checkpoint carries a top-level `topology_receipt` key. The docstring must not contain the text `Epic planner`, and it writes the key name in the reStructuredText double-backtick form already used on line 289 (two backticks, `topology_receipt`, two backticks), never inside double quotes, so the P6-T5 count of added lines containing the quoted-key membership test stays at two.
  - Leave `_validate_planner_topology_receipt`, `_validate_ready_features`, the `key_gated` assignment (line 329), and the lines `validate_epic_planner_child_launch_bindings(` and `features, require_launch_paths=key_gated` unchanged.
  - Acceptance: `grep -c -F -e 'if not key_gated or "topology_receipt" in state:' scripts/dev_tools/validate_epic_planner_state.py` prints `1` (it prints `0` before this task); `poetry run pytest tests/scripts/dev_tools/test_validate_epic_planner_state.py` exits 0 with 0 failed; `awk 'END{print NR}' scripts/dev_tools/validate_epic_planner_state.py` prints a value at or below 500.

- [ ] [P2-T2] Record the Python pass-after run by running `poetry run pytest "tests/scripts/dev_tools/test_validate_epic_planner_state.py::test_ready_gate_skips_planner_topology_receipt_when_key_absent" -vv`.
  - Acceptance: `docs/features/active/2026-10-08-epic-planner-topology-receipt-gate-543/evidence/regression-testing/pass-after-python.<ts>.md` exists with `Timestamp:`, `Command:`, `EXIT_CODE: 0`, and an `Output Summary:` showing `1 passed` for that node and citing the P1-T3 artifact as the paired fail-before run.

### Phase 3 — TypeScript production fix

- [ ] [P3-T1] Update `extensions/drm-copilot/src/lib/validate/epic-planner-state-core.ts` in `validateEpicPlannerStateText`:
  - Replace the statement at planning-time line 443 with the three-line block opened by `if (!requireLaunchPaths || "topology_receipt" in value) {`, containing `errors.push(...validatePlannerTopologyReceipt(value["topology_receipt"]));`, and closed by `}`.
  - Replace the comment at planning-time line 423 with the two lines `// Launch evidence (per feature) and the planner topology receipt (top-level` and `// key) are key-gated unless a Codex flag is asserted.`
  - Leave `validatePlannerTopologyReceipt` (lines 102-114), `validateReadyFeatures`, and the `requireLaunchPaths` assignment (lines 424-426) unchanged. Do not rename `requireLaunchPaths`.
  - Acceptance: `grep -c -F -e 'if (!requireLaunchPaths || "topology_receipt" in value) {' extensions/drm-copilot/src/lib/validate/epic-planner-state-core.ts` prints `1` (it prints `0` before this task); `node run-jest.cjs test/lib/validate/epic-planner-state-core.test.ts` in `extensions/drm-copilot/` exits 0 with 0 failed; `awk 'END{print NR}' extensions/drm-copilot/src/lib/validate/epic-planner-state-core.ts` prints a value at or below 500 (expected 474).

- [ ] [P3-T2] Record the TypeScript pass-after run by running `node run-jest.cjs test/lib/validate/epic-planner-state-core.test.ts -t "skips the planner topology receipt when the key is absent"` in `extensions/drm-copilot/`.
  - Acceptance: `docs/features/active/2026-10-08-epic-planner-topology-receipt-gate-543/evidence/regression-testing/pass-after-typescript.<ts>.md` exists with `Timestamp:`, `Command:`, `EXIT_CODE: 0`, and an `Output Summary:` showing `Tests:` with `1 passed` and 0 failed for that title, and citing the P1-T5 artifact as the paired fail-before run.

### Phase 4 — Python tests for the remaining matrix rows

- [ ] [P4-T1] Add `test_codex_flag_keeps_planner_topology_receipt_unconditional` to `tests/scripts/dev_tools/test_validate_epic_planner_state.py`, decorated with `@pytest.mark.parametrize("flag", ["require_codex_model_routing", "require_codex_topology"])`.
  - Body: `state = _ready_state()`; `state.pop("topology_receipt")`; call `validate_epic_planner_state_text(json.dumps(state), require_ready_for_execution=True, require_codex_model_routing=flag == "require_codex_model_routing", require_codex_topology=flag == "require_codex_topology")` (explicit keyword arguments rather than `**` unpacking, so Pyright checks each argument type); assert `"Epic planner topology_receipt must be an object." in errors`. One-line docstring.
  - Acceptance: `poetry run pytest tests/scripts/dev_tools/test_validate_epic_planner_state.py -k test_codex_flag_keeps_planner_topology_receipt_unconditional -v` exits 0 with `2 passed`.

- [ ] [P4-T2] Add `test_ready_gate_validates_present_null_planner_topology_receipt` to `tests/scripts/dev_tools/test_validate_epic_planner_state.py`.
  - Body: `state = _ready_state()`; `state["topology_receipt"] = None`; call `validate_epic_planner_state_text(json.dumps(state), require_ready_for_execution=True)` with no Codex flag; assert `"Epic planner topology_receipt must be an object." in errors`. One-line docstring stating that a present null key still arms the check.
  - Acceptance: `poetry run pytest "tests/scripts/dev_tools/test_validate_epic_planner_state.py::test_ready_gate_validates_present_null_planner_topology_receipt" -v` exits 0 with `1 passed`.

- [ ] [P4-T3] Add `test_ready_gate_accepts_present_valid_planner_topology_receipt` to `tests/scripts/dev_tools/test_validate_epic_planner_state.py`, decorated with `@pytest.mark.parametrize("require_codex_topology", [False, True])`.
  - Body: `state = _ready_state()` (which carries the valid forced planner receipt, lines 67-70 and 83); call `validate_epic_planner_state_text(json.dumps(state), require_ready_for_execution=True, require_codex_topology=require_codex_topology)`; assert that no returned error contains `"Epic planner topology_receipt"`, using the same `offending == []` form as P1-T2. One-line docstring.
  - Acceptance: `poetry run pytest tests/scripts/dev_tools/test_validate_epic_planner_state.py -k test_ready_gate_accepts_present_valid_planner_topology_receipt -v` exits 0 with `2 passed`; `awk 'END{print NR}' tests/scripts/dev_tools/test_validate_epic_planner_state.py` prints a value at or below 500.

- [ ] [P4-T4] Run the whole Python test file: `poetry run pytest tests/scripts/dev_tools/test_validate_epic_planner_state.py -v`.
  - Acceptance: `docs/features/active/2026-10-08-epic-planner-topology-receipt-gate-543/evidence/regression-testing/python-topology-suite.<ts>.md` exists with `Timestamp:`, `Command:`, `EXIT_CODE: 0`, and an `Output Summary:` recording 0 failed and listing as `PASSED` each of the five Python names under "Named tests and literals introduced by this plan" (seven node IDs in total, counting both parameters of each parametrized test), plus `test_readiness_requires_forced_epic_planner_persona` and `test_cli_dispatches_planner_readiness_flag`.

### Phase 5 — TypeScript twins and the MCP service-call assertion

- [ ] [P5-T1] Add `it.each(codexFlagCases)("keeps the planner topology receipt unconditional under %p", (flags) => { ... })` to `extensions/drm-copilot/test/lib/validate/epic-planner-state-core.test.ts`, inside the same `describe` block, after the P1-T4 test.
  - Typing (the extension compiles with `exactOptionalPropertyTypes: true`, `extensions/drm-copilot/tsconfig.json` line 14): add the statement `import type { ValidateEpicPlannerStateOptions } from "../../../src/lib/validate/epic-planner-state-core";` directly after the existing line 4 import, and declare at module level, after `readyState()`, `type CodexFlags = Pick<ValidateEpicPlannerStateOptions, "requireCodexModelRouting" | "requireCodexTopology">;` and `const codexFlagCases: readonly CodexFlags[] = [{ requireCodexModelRouting: true }, { requireCodexTopology: true }];`. The separate import type statement is accepted by the configured rule set (extensions/drm-copilot/eslint.config.mjs: eslint.configs.recommended plus tseslint.configs.recommended, neither of which enables a duplicate-import rule); the same form is used at extensions/drm-copilot/test/lib/json-config.test.ts line 3.
  - Body: `readyState()`, `delete state["topology_receipt"];`, call `validateEpicPlannerStateText(JSON.stringify(state), { requireReadyForExecution: true, ...flags })`, assert `expect(errors).toContain("Epic planner topology_receipt must be an object.");`.
  - Style: separate the arrange, act, and assert sections with single blank lines and add no // Arrange, // Act, or // Assert comment lines, matching the neighbouring test at planning-time lines 330-346; this keeps the file within the 500-line limit.
  - Acceptance: `node run-jest.cjs test/lib/validate/epic-planner-state-core.test.ts -t "keeps the planner topology receipt unconditional"` in `extensions/drm-copilot/` exits 0 with `Tests:` showing `2 passed`.

- [ ] [P5-T2] Add `it("validates a present null planner topology receipt without a Codex flag")` to `extensions/drm-copilot/test/lib/validate/epic-planner-state-core.test.ts`, inside the same `describe` block.
  - Body: `readyState()`, set `state["topology_receipt"] = null;`, call `validateEpicPlannerStateText(JSON.stringify(state), { requireReadyForExecution: true })`, assert `expect(errors).toContain("Epic planner topology_receipt must be an object.");`.
  - Style: separate the arrange, act, and assert sections with single blank lines and add no // Arrange, // Act, or // Assert comment lines, matching the neighbouring test at planning-time lines 330-346; this keeps the file within the 500-line limit.
  - Acceptance: `node run-jest.cjs test/lib/validate/epic-planner-state-core.test.ts -t "validates a present null planner topology receipt"` in `extensions/drm-copilot/` exits 0 with `Tests:` showing `1 passed`.

- [ ] [P5-T3] Add `it.each(validReceiptCases)("accepts a present valid planner topology receipt under %p", (flags) => { ... })` to `extensions/drm-copilot/test/lib/validate/epic-planner-state-core.test.ts`, inside the same `describe` block, with the module-level declaration `const validReceiptCases: readonly CodexFlags[] = [{}, { requireCodexTopology: true }];` placed beside `codexFlagCases` from P5-T1.
  - Body: `readyState()` unchanged (it carries `topologyReceipt("epic-planner")`, line 80), call `validateEpicPlannerStateText(JSON.stringify(state), { requireReadyForExecution: true, ...flags })`, assert `expect(errors.filter((error) => error.includes("Epic planner topology_receipt"))).toEqual([]);`.
  - Style: separate the arrange, act, and assert sections with single blank lines and add no // Arrange, // Act, or // Assert comment lines, matching the neighbouring test at planning-time lines 330-346; this keeps the file within the 500-line limit.
  - Acceptance: `node run-jest.cjs test/lib/validate/epic-planner-state-core.test.ts -t "accepts a present valid planner topology receipt"` in `extensions/drm-copilot/` exits 0 with `Tests:` showing `2 passed`; `awk 'END{print NR}' extensions/drm-copilot/test/lib/validate/epic-planner-state-core.test.ts` prints a value at or below 500.

- [ ] [P5-T4] Update `extensions/drm-copilot/test/lib/validate/validate-orchestration-service-call.test.ts`: in `it("threads the Codex flags into epic-planner-state")`, after the existing `expect(keyGated).not.toContain(" launch binding");` (planning-time line 204), append `expect(routing).toContain("Epic planner topology_receipt must be an object.");`, `expect(topology).toContain("Epic planner topology_receipt must be an object.");`, and `expect(keyGated).not.toContain("Epic planner topology_receipt");`. Change no existing line of the test. This task runs after P3-T1, because the `keyGated` assertion fails on pre-fix code (the fixture at lines 173-176 carries no top-level `topology_receipt`).
  - Acceptance: `node run-jest.cjs test/lib/validate/validate-orchestration-service-call.test.ts -t "threads the Codex flags into epic-planner-state"` in `extensions/drm-copilot/` exits 0 with `Tests:` showing `1 passed`.

- [ ] [P5-T5] Run both edited TypeScript test files: `node run-jest.cjs test/lib/validate/epic-planner-state-core.test.ts test/lib/validate/validate-orchestration-service-call.test.ts --verbose` in `extensions/drm-copilot/`.
  - Acceptance: `docs/features/active/2026-10-08-epic-planner-topology-receipt-gate-543/evidence/regression-testing/typescript-topology-suites.<ts>.md` exists with `Timestamp:`, `Command:`, `EXIT_CODE: 0`, and an `Output Summary:` recording `Test Suites: 2 passed, 2 total`, the `Tests:` line with 0 failed, and the passing lines (prefixed `✓` or, on some Windows consoles, `√`) for the four new TypeScript titles (six test cases including `it.each` expansions), `requires the forced epic-planner topology receipt`, and `threads the Codex flags into epic-planner-state`.

### Phase 6 — Targeted, preserved-behaviour, source, and scope verification

- [ ] [P6-T1] Run the spec's targeted Python command: `poetry run pytest tests/scripts/dev_tools/test_validate_epic_planner_state.py tests/scripts/dev_tools/test_validate_epic_planner_state_launch_binding.py tests/scripts/dev_tools/test_epic_planner_readiness.py tests/scripts/dev_tools/test_push_down_codex_and_agents_customizations.py --cov=scripts.dev_tools.validate_epic_planner_state --cov-branch --cov-report=term-missing`.
  - Acceptance: `docs/features/active/2026-10-08-epic-planner-topology-receipt-gate-543/evidence/regression-testing/targeted-python.<ts>.md` exists with `Timestamp:`, `Command:`, `EXIT_CODE: 0`, and an `Output Summary:` recording the result line with 0 failed and the `term-missing` row for `scripts/dev_tools/validate_epic_planner_state.py`.

- [ ] [P6-T2] Verify the preserved Python tests (spec acceptance criterion 9) by running `poetry run pytest "tests/scripts/dev_tools/test_validate_epic_planner_state.py::test_readiness_requires_forced_epic_planner_persona" "tests/scripts/dev_tools/test_validate_epic_planner_state.py::test_cli_dispatches_planner_readiness_flag" "tests/scripts/dev_tools/test_push_down_codex_and_agents_customizations.py::test_consumer_authority_is_typescript_only_and_scope_owners_are_unchanged" -v`, then `git diff MERGE_BASE_SHA --stat -- tests/scripts/dev_tools/test_push_down_codex_and_agents_customizations.py`, then `git status --porcelain -- tests/scripts/dev_tools/test_push_down_codex_and_agents_customizations.py`, then `git diff -U0 MERGE_BASE_SHA -- tests/scripts/dev_tools/test_validate_epic_planner_state.py`.
  - Acceptance: `docs/features/active/2026-10-08-epic-planner-topology-receipt-gate-543/evidence/regression-testing/preserved-python.<ts>.md` exists with `Timestamp:`, `Command:` (all four, with the SHA substituted), `EXIT_CODE: 0`, and an `Output Summary:` recording `3 passed` for the pytest run; empty output from the `--stat` diff and from the porcelain command; and, from the `-U0` diff, every hunk header copied verbatim with the statement that every hunk with a non-zero old-line count starts and ends within old lines 213-234 (the body of `test_readiness_requires_epic_preparation_topology_receipts`; with the P1-T1 edit as specified this is one hunk whose header begins `@@ -222 `), while every other hunk has an old-line count of `0` (pure insertions). This shows that `test_readiness_requires_forced_epic_planner_persona` (lines 237-251) and `test_cli_dispatches_planner_readiness_flag` (lines 329-360) were not modified.

- [ ] [P6-T3] Run the spec's targeted Jest command `node run-jest.cjs test/lib/validate/epic-planner-state-core.test.ts test/lib/validate/validate-orchestration-service-call.test.ts test/lib/validate/epic-planner-state-launch-binding.test.ts test/lib/validate/epic-planner-readiness-integrity.test.ts` in `extensions/drm-copilot/`.
  - Acceptance: `docs/features/active/2026-10-08-epic-planner-topology-receipt-gate-543/evidence/regression-testing/targeted-typescript.<ts>.md` exists with `Timestamp:`, `Command:`, `EXIT_CODE: 0`, and an `Output Summary:` recording `Test Suites: 4 passed, 4 total` and the `Tests:` line with 0 failed.

- [ ] [P6-T4] Verify the preserved TypeScript test (spec acceptance criterion 9) by running `node run-jest.cjs test/lib/validate/epic-planner-state-core.test.ts -t "requires the forced epic-planner topology receipt"` in `extensions/drm-copilot/`, then, from the worktree root, `git diff -U0 MERGE_BASE_SHA -- extensions/drm-copilot/test/lib/validate/epic-planner-state-core.test.ts`.
  - Acceptance: `docs/features/active/2026-10-08-epic-planner-topology-receipt-gate-543/evidence/regression-testing/preserved-typescript.<ts>.md` exists with `Timestamp:`, `Command:` (both, SHA substituted), `EXIT_CODE: 0`, and an `Output Summary:` recording `Tests:` with `1 passed` for that title and every hunk header of the diff copied verbatim, with the statement that every hunk has an old-line count of `0` (pure insertions). This shows that the test at planning-time lines 330-346 was not modified.

- [ ] [P6-T5] Verify the call-site gate and the unchanged error strings (spec acceptance criterion 8) by running, in the Bash tool from the worktree root: `grep -n -F -e 'if not key_gated or "topology_receipt" in state:' scripts/dev_tools/validate_epic_planner_state.py`; `grep -n -F -e 'if (!requireLaunchPaths || "topology_receipt" in value) {' extensions/drm-copilot/src/lib/validate/epic-planner-state-core.ts`; `git diff -U0 MERGE_BASE_SHA -- scripts/dev_tools/validate_epic_planner_state.py extensions/drm-copilot/src/lib/validate/epic-planner-state-core.ts | grep -e '^[-+][^-+]' | grep -c -e 'Epic planner'`; and `git diff -U0 MERGE_BASE_SHA -- scripts/dev_tools/validate_epic_planner_state.py extensions/drm-copilot/src/lib/validate/epic-planner-state-core.ts | grep -c -F -e '"topology_receipt" in '`.
  - Then read the source around each match and confirm that the existing planner topology call is the only statement inside each new block and that the block sits inside the `require_ready_for_execution` / `options.requireReadyForExecution === true` branch.
  - Acceptance: `docs/features/active/2026-10-08-epic-planner-topology-receipt-gate-543/evidence/qa-gates/call-site-and-strings.<ts>.md` exists with `Timestamp:`, `Command:` (all four, SHA substituted), `EXIT_CODE: 0`, and an `Output Summary:` recording exactly one match line (with line number) for each of the first two commands; the third command printing `0` (exit 1, its stated expectation), meaning no added or removed line in either production file contains `Epic planner`; the fourth command printing `2` (one added condition line per runtime); the source-reading confirmation; and the note that the spec's `git diff main` is run as the anchored merge-base diff.

- [ ] [P6-T6] Verify the excluded paths (spec acceptance criterion 10) by running `git diff MERGE_BASE_SHA -- scripts/dev_tools/validate_orchestration_artifacts.py .claude .github .agents .codex extensions/drm-copilot/resources extensions/drm-copilot/jest.config.cjs extensions/drm-copilot/src/mcp-tool-inputs.ts` and `git status --porcelain -- scripts/dev_tools/validate_orchestration_artifacts.py .claude .github .agents .codex extensions/drm-copilot/resources extensions/drm-copilot/jest.config.cjs extensions/drm-copilot/src/mcp-tool-inputs.ts` in the Bash tool from the worktree root.
  - Acceptance: `docs/features/active/2026-10-08-epic-planner-topology-receipt-gate-543/evidence/qa-gates/scope-exclusions.<ts>.md` exists with `Timestamp:`, `Command:` (both, SHA substituted), `EXIT_CODE: 0`, and an `Output Summary:` stating that both commands printed nothing, and noting that the diff is anchored to the recorded merge base in place of the spec's `git diff main`. Gitignored state (`.claude/state/`, `.claude/agent-memory`, `.gitignore` lines 69-70) does not appear in either output by construction.

### Phase 7 — Python final QA loop (seven stages)

Loop rule: run P7-T1 through P7-T8 in order. If any stage fails or changes any file, fix the cause, record the restart in `docs/features/active/2026-10-08-epic-planner-topology-receipt-gate-543/evidence/qa-gates/loop-restarts.<ts>.md`, and restart at P7-T1, incrementing `Loop iteration:` in every Phase 7 artifact. Every task is unconditional; `SKIPPED` is not a valid outcome.

- [ ] [P7-T1] Python stage 1, formatting: run `poetry run black --check scripts/dev_tools/validate_epic_planner_state.py tests/scripts/dev_tools/test_validate_epic_planner_state.py`.
  - Acceptance: `docs/features/active/2026-10-08-epic-planner-topology-receipt-gate-543/evidence/qa-gates/final-python-format.<ts>.md` exists with the four fields and `Loop iteration:`; `EXIT_CODE: 0` and the output contains `2 files would be left unchanged.` with no `would reformat` line. If the check fails, run `poetry run black scripts/dev_tools/validate_epic_planner_state.py tests/scripts/dev_tools/test_validate_epic_planner_state.py`, record its `reformatted <path>` lines and its closing summary (`N file(s) reformatted, M file(s) left unchanged`), and restart the loop.

- [ ] [P7-T2] Python stage 2, linting: run `poetry run ruff check scripts/dev_tools/validate_epic_planner_state.py tests/scripts/dev_tools/test_validate_epic_planner_state.py`.
  - Acceptance: `docs/features/active/2026-10-08-epic-planner-topology-receipt-gate-543/evidence/qa-gates/final-python-lint.<ts>.md` exists with the four fields; `EXIT_CODE: 0` and the output is `All checks passed!`. Any suppression must match `.claude/rules/python-suppressions.md`.

- [ ] [P7-T3] Python stage 3, type checking: run `poetry run pyright scripts/dev_tools/validate_epic_planner_state.py tests/scripts/dev_tools/test_validate_epic_planner_state.py`.
  - Acceptance: `docs/features/active/2026-10-08-epic-planner-topology-receipt-gate-543/evidence/qa-gates/final-python-typecheck.<ts>.md` exists with the four fields; `EXIT_CODE: 0` and the summary line `0 errors, 0 warnings, 0 informations`.

- [ ] [P7-T4] Python stage 4, architecture boundaries: re-run the P0-T16 commands.
  - Acceptance: `docs/features/active/2026-10-08-epic-planner-topology-receipt-gate-543/evidence/qa-gates/final-python-architecture.<ts>.md` exists with the four fields and an `Output Summary:` identical in substance to P0-T16. When P0-T16 found a configured tool, this task runs it and requires zero violations.

- [ ] [P7-T5] Python stage 5, unit tests with coverage: run `poetry run pytest --cov=scripts.dev_tools --cov-branch --cov-report=term-missing --deselect tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py::test_bundled_claude_payload_contains_all_repo_runtime_contracts` from the worktree root (same selection as P0-T10).
  - Acceptance: `docs/features/active/2026-10-08-epic-planner-topology-receipt-gate-543/evidence/qa-gates/final-python-test-coverage.<ts>.md` exists with `Timestamp:`, `Command:`, `EXIT_CODE: 0`, and an `Output Summary:` recording the result line (0 failed, 1 deselected, citing #510; passed count equal to the P0-T10 passed count plus 6, the new parametrized cases from P1-T2 and P4-T1 through P4-T3), the `TOTAL` row verbatim, and the `term-missing` row for `scripts/dev_tools/validate_epic_planner_state.py` including its `Missing` cell.

- [ ] [P7-T6] Python per-file coverage: immediately after P7-T5, run `poetry run coverage json --data-file=artifacts/.coverage --include="*validate_epic_planner_state.py" --pretty-print -o artifacts/python/coverage-543-topology-final.json` and read the JSON.
  - Acceptance: `docs/features/active/2026-10-08-epic-planner-topology-receipt-gate-543/evidence/qa-gates/final-python-per-file-coverage.<ts>.md` exists with the four fields and an `Output Summary:` recording `covered_lines`/`num_statements` and `covered_branches`/`num_branches` from `files[<key>].summary` with two-decimal percentages, and the `missing_lines` and `missing_branches` lists. The file shows at least 85.00% line coverage and at least 75.00% branch coverage. A shortfall requires added tests in `tests/scripts/dev_tools/test_validate_epic_planner_state.py` and a loop restart at P7-T1.

- [ ] [P7-T7] Python stage 6, contract/schema compatibility: run `git diff MERGE_BASE_SHA --stat -- scripts/dev_tools/validate_orchestration_artifacts.py`, `git status --porcelain -- scripts/dev_tools/validate_orchestration_artifacts.py`, and `git diff -U0 MERGE_BASE_SHA -- scripts/dev_tools/validate_epic_planner_state.py | grep -c -e '^[-+]def '`.
  - Acceptance: `docs/features/active/2026-10-08-epic-planner-topology-receipt-gate-543/evidence/qa-gates/final-python-contract.<ts>.md` exists with the four fields (SHA substituted); the first two commands print nothing (Python CLI unchanged) and the third prints `0` (exit 1, its stated expectation), confirming no function signature in `scripts/dev_tools/validate_epic_planner_state.py` was added, removed, or changed.

- [ ] [P7-T8] Python stage 7, integration: re-run the P6-T1 command.
  - Acceptance: `docs/features/active/2026-10-08-epic-planner-topology-receipt-gate-543/evidence/qa-gates/final-python-integration.<ts>.md` exists with `Timestamp:`, `Command:`, `EXIT_CODE: 0`, and an `Output Summary:` recording the result line with 0 failed.

### Phase 8 — TypeScript final QA loop (seven stages)

Loop rule: run P8-T1 through P8-T7 in order. If any stage fails or changes any file, fix the cause, record the restart in `docs/features/active/2026-10-08-epic-planner-topology-receipt-gate-543/evidence/qa-gates/loop-restarts.<ts>.md`, and restart at P8-T1, incrementing `Loop iteration:` in every Phase 8 artifact. A TypeScript fix that touches no Python file does not restart Phase 7. Every task is unconditional; `SKIPPED` is not a valid outcome.

- [ ] [P8-T1] TypeScript stage 1, formatting: run `npx prettier --check src/lib/validate/epic-planner-state-core.ts test/lib/validate/epic-planner-state-core.test.ts test/lib/validate/validate-orchestration-service-call.test.ts` in `extensions/drm-copilot/`.
  - Acceptance: `docs/features/active/2026-10-08-epic-planner-topology-receipt-gate-543/evidence/qa-gates/final-typescript-format.<ts>.md` exists with the four fields and `Loop iteration:`; `EXIT_CODE: 0` and the output contains `All matched files use Prettier code style!`. If the check fails, run `npx prettier --write src/lib/validate/epic-planner-state-core.ts test/lib/validate/epic-planner-state-core.test.ts test/lib/validate/validate-orchestration-service-call.test.ts` in `extensions/drm-copilot/` (not `npm run format`, which rewrites files outside the write set), record each output line (a line ending in `(unchanged)` names a file left as-is; every other file line names a rewritten file), and restart the loop.

- [ ] [P8-T2] TypeScript stage 2, linting: run `npm run lint` in `extensions/drm-copilot/`.
  - Acceptance: `docs/features/active/2026-10-08-epic-planner-topology-receipt-gate-543/evidence/qa-gates/final-typescript-lint.<ts>.md` exists with the four fields; `EXIT_CODE: 0` and zero problem lines. Any suppression must match `.claude/rules/typescript-suppressions.md`.

- [ ] [P8-T3] TypeScript stage 3, type checking: run `npm run typecheck` in `extensions/drm-copilot/`.
  - Acceptance: `docs/features/active/2026-10-08-epic-planner-topology-receipt-gate-543/evidence/qa-gates/final-typescript-typecheck.<ts>.md` exists with the four fields; `EXIT_CODE: 0` and zero `error TS` lines.

- [ ] [P8-T4] TypeScript stage 4, architecture boundaries: re-run the P0-T16 commands.
  - Acceptance: `docs/features/active/2026-10-08-epic-planner-topology-receipt-gate-543/evidence/qa-gates/final-typescript-architecture.<ts>.md` exists with the four fields and an `Output Summary:` identical in substance to P0-T16. When P0-T16 found a `.dependency-cruiser*` configuration, this task runs it and requires zero violations.

- [ ] [P8-T5] TypeScript stage 5, unit tests with coverage: run `node run-jest.cjs --coverage --coverageReporters=text --coverageReporters=text-summary` in `extensions/drm-copilot/`.
  - Acceptance: `docs/features/active/2026-10-08-epic-planner-topology-receipt-gate-543/evidence/qa-gates/final-typescript-test-coverage.<ts>.md` exists with `Timestamp:`, `Command:`, `EXIT_CODE: 0` (which also shows every configured `coverageThreshold` entry is met), and an `Output Summary:` recording the `Test Suites:` and `Tests:` lines with 0 failed (passed count equal to the P0-T17 count plus 6), the text-summary `Lines` and `Branches` totals, and the `text` row for `epic-planner-state-core.ts` verbatim, showing `% Lines` at or above 85 and `% Branch` at or above 75, with its `Uncovered Line #s` cell. A shortfall requires added tests in `extensions/drm-copilot/test/lib/validate/epic-planner-state-core.test.ts` and a loop restart at P8-T1.

- [ ] [P8-T6] TypeScript stage 6, contract/schema compatibility: run `git diff MERGE_BASE_SHA --stat -- extensions/drm-copilot/src/mcp-tool-definitions.ts extensions/drm-copilot/src/mcp-repo-automation-tool-definitions.ts extensions/drm-copilot/src/mcp-tool-inputs.ts extensions/drm-copilot/src/lib/validate/orchestration-artifacts.ts`, `git status --porcelain -- extensions/drm-copilot/src/mcp-tool-definitions.ts extensions/drm-copilot/src/mcp-repo-automation-tool-definitions.ts extensions/drm-copilot/src/mcp-tool-inputs.ts extensions/drm-copilot/src/lib/validate/orchestration-artifacts.ts`, and `git diff -U0 MERGE_BASE_SHA -- extensions/drm-copilot/src/lib/validate/epic-planner-state-core.ts | grep -c -e '^[-+]export '` in the Bash tool from the worktree root.
  - Acceptance: `docs/features/active/2026-10-08-epic-planner-topology-receipt-gate-543/evidence/qa-gates/final-typescript-contract.<ts>.md` exists with the four fields (SHA substituted); the first two commands print nothing (MCP input schema and dispatch unchanged) and the third prints `0` (exit 1, its stated expectation), confirming no exported declaration of `epic-planner-state-core.ts` changed.

- [ ] [P8-T7] TypeScript stage 7, integration: run `node run-jest.cjs test/lib/validate/epic-planner-state-core.test.ts test/lib/validate/validate-orchestration-service-call.test.ts test/lib/validate/epic-planner-state-launch-binding.test.ts test/lib/validate/epic-planner-readiness-integrity.test.ts test/mcp-server-epic-validation.test.ts` in `extensions/drm-copilot/`.
  - Acceptance: `docs/features/active/2026-10-08-epic-planner-topology-receipt-gate-543/evidence/qa-gates/final-typescript-integration.<ts>.md` exists with `Timestamp:`, `Command:`, `EXIT_CODE: 0`, and an `Output Summary:` recording `Test Suites: 5 passed, 5 total` and the `Tests:` line with 0 failed.

### Phase 9 — Coverage delta, size, scope, and acceptance check-off

- [ ] [P9-T1] Write the coverage-delta verification to `docs/features/active/2026-10-08-epic-planner-topology-receipt-gate-543/evidence/qa-gates/coverage-delta-verification.<ts>.md`, running `git diff -U0 MERGE_BASE_SHA -- scripts/dev_tools/validate_epic_planner_state.py extensions/drm-copilot/src/lib/validate/epic-planner-state-core.ts` to enumerate added line numbers from the `+` side of each hunk.
  - Acceptance: the artifact contains `Timestamp:`, `Command:` (SHA substituted), `EXIT_CODE: 0`, and an `Output Summary:` reporting, per language, three numeric groups:
    - baseline coverage: Python line and branch percentages from P0-T11; TypeScript `% Lines` and `% Branch` from the P0-T17 row;
    - post-change coverage: Python from P7-T6; TypeScript from the P8-T5 row;
    - new/changed-code coverage: the count of added executable lines that appear in the Python `missing_lines` list of `artifacts/python/coverage-543-topology-final.json` or in the TypeScript `Uncovered Line #s` cell, and, for Python, the count of `missing_branches` arcs whose source line is the new `if not key_gated` line.
  - Required results: Python and TypeScript line percentages at or above 85.00 and branch percentages at or above 75.00; no post-change percentage lower than its baseline by more than 0.50 points; zero added executable lines uncovered; zero missing arcs from the new Python condition. The artifact also records that both outcomes of the new conditional are exercised in each runtime, citing the passing tests: check skipped (P1-T2 / P1-T4), check run because a Codex flag is set (P4-T1 / P5-T1), and check run because the key is present (P4-T2, P4-T3 / P5-T2, P5-T3). A missing numeric value makes the verdict INCOMPLETE, not PASS.

- [ ] [P9-T2] Write the single-clean-pass record to `docs/features/active/2026-10-08-epic-planner-topology-receipt-gate-543/evidence/qa-gates/final-qa-clean-pass.<ts>.md`.
  - Acceptance: the artifact contains `Timestamp:` and a stage-by-stage table for Python (P7-T1 through P7-T8) and TypeScript (P8-T1 through P8-T7) recording each stage's artifact path, `EXIT_CODE`, and `Loop iteration:` from the final iteration, plus the total number of loop restarts and the reason for each, copied from `loop-restarts.<ts>.md` (or `Restarts: 0`). Every stage in the final iteration shows its expected exit status and no file change.

- [ ] [P9-T3] Verify the 500-line limit (spec acceptance criterion 14) by running `awk 'END{print NR}' <path>` once for each of the five code paths in "Files the diff will WRITE".
  - Acceptance: `docs/features/active/2026-10-08-epic-planner-topology-receipt-gate-543/evidence/qa-gates/line-counts-final.<ts>.md` exists with the four fields and an `Output Summary:` listing five counts, each at or below 500, beside the P0-T6 baseline count for the same path, and noting that `awk 'END{print NR}'` is used in place of the spec's `(Get-Content <path>).Count` and returns the same physical line count.

- [ ] [P9-T4] Verify the write set by running `git diff MERGE_BASE_SHA --name-only` and `git status --porcelain` in the Bash tool from the worktree root.
  - Acceptance: `docs/features/active/2026-10-08-epic-planner-topology-receipt-gate-543/evidence/qa-gates/scope-verification.<ts>.md` exists with the four fields (SHA substituted) and an `Output Summary:` showing that the union of the two outputs, restricted to paths outside `docs/features/active/2026-10-08-epic-planner-topology-receipt-gate-543/`, is exactly the five code paths in "Files the diff will WRITE", and that no path under "Explicitly out of scope" appears in either output.

- [ ] [P9-T5] Update `docs/features/active/2026-10-08-epic-planner-topology-receipt-gate-543/spec.md`: in the `## Acceptance Criteria` section only, confirm that each criterion line was changed from `- [ ]` to `- [x]` at its mapped task under the tick rule in Execution notes, and change any criterion whose mapped tasks have all passed but which is still `- [ ]`, changing no criterion text and no other section. Mapping (AC numbering is the order of the fourteen items at planning-time lines 223-236): AC1 at P2-T2 (with P1-T3), AC2 at P4-T1, AC3 at P4-T2, AC4 at P4-T3, AC5 at P1-T1 and P4-T4, AC6 at P5-T5, AC7 at P5-T4, AC8 at P6-T5, AC9 at P6-T2 and P6-T4, AC10 at P6-T6, AC11 at P9-T2, AC12 at P9-T1 (with P7-T6), AC13 at P9-T1 (with P8-T5), AC14 at P9-T3. Then run `grep -c -e '^- \[x\] ' docs/features/active/2026-10-08-epic-planner-topology-receipt-gate-543/spec.md` and `grep -c -e '^- \[ \] ' docs/features/active/2026-10-08-epic-planner-topology-receipt-gate-543/spec.md`.
  - Acceptance: the first count prints `15` and the second prints `6` (baseline 1 checked and 20 unchecked from P0-T19, with the 14 criteria moved). `docs/features/active/2026-10-08-epic-planner-topology-receipt-gate-543/evidence/qa-gates/acceptance-checkoff.<ts>.md` exists with `Timestamp:`, `Command:`, `EXIT_CODE: 0`, and an `Output Summary:` recording both counts, one citation line per criterion AC1 through AC14 naming the evidence artifact path or test node that satisfies it, and two notes: AC8 and AC10 use the recorded merge-base anchor in place of `git diff main`; AC14 uses `awk 'END{print NR}'` in place of `(Get-Content <path>).Count`. If any criterion cannot be ticked, it stays unticked, the gap is recorded in the artifact, the counts are recorded as found, and the plan outcome is INCOMPLETE, not PASS.

- [ ] [P9-T6] Update `docs/features/active/2026-10-08-epic-planner-topology-receipt-gate-543/plan.2026-10-08T13-56.md`: reconcile every task checkbox in this plan against the evidence on disk, so that a task is `[x]` only when its named artifact exists with the required fields (or, for a task without an artifact, its stated acceptance command was observed to pass), and append a `## Plan Deviations` section recording any deviation applied during execution (or `None`).
  - Acceptance: `grep -c -e '^- \[ \] \[P' docs/features/active/2026-10-08-epic-planner-topology-receipt-gate-543/plan.2026-10-08T13-56.md` prints `1` (this task, ticked last) immediately before this task is ticked, and the `## Plan Deviations` heading is present.

---

## Planner Review Record

SELF-REVIEW: RE-DERIVED THIS PASS

Citations re-derived against the current tree in this pass (file and locator):

1. `scripts/dev_tools/validate_epic_planner_state.py` lines 62-86 (`_validate_planner_topology_receipt` definition and the `Epic planner topology_receipt` prefix rewrite at line 67).
2. `scripts/dev_tools/validate_epic_planner_state.py` lines 289-291 (docstring paragraph to replace).
3. `scripts/dev_tools/validate_epic_planner_state.py` line 327 (`if require_ready_for_execution:`), line 328 (comment), line 329 (`key_gated` assignment).
4. `scripts/dev_tools/validate_epic_planner_state.py` lines 340-343 (`validate_epic_planner_child_launch_bindings(` and `features, require_launch_paths=key_gated`, unchanged).
5. `scripts/dev_tools/validate_epic_planner_state.py` line 345 (the call to gate; 88 characters at its current 8-space indent and 92 characters at the 12-space indent inside the new if, so Black wraps it into the three-line form).
6. `scripts/dev_tools/validate_epic_planner_state.py` line count 369.
7. `extensions/drm-copilot/src/lib/validate/epic-planner-state-core.ts` lines 51-60 (`ValidateEpicPlannerStateOptions`), lines 102-114 (`validatePlannerTopologyReceipt`).
8. `extensions/drm-copilot/src/lib/validate/epic-planner-state-core.ts` line 422 (ready branch), line 423 (comment), lines 424-426 (`requireLaunchPaths`), line 443 (call to gate), line count 471.
9. `tests/scripts/dev_tools/test_validate_epic_planner_state.py` lines 64-84 (`_ready_state`, top-level receipt at line 83), lines 213-234 (defect-pinning test; call at line 222), lines 237-251 (`test_readiness_requires_forced_epic_planner_persona`), lines 329-360 (`test_cli_dispatches_planner_readiness_flag`), line count 360.
10. `extensions/drm-copilot/test/lib/validate/epic-planner-state-core.test.ts` lines 67-82 (`readyState`), lines 330-346 (`requires the forced epic-planner topology receipt`), line count 413.
11. `extensions/drm-copilot/test/lib/validate/validate-orchestration-service-call.test.ts` lines 160-205 (`threads the Codex flags into epic-planner-state`; fixture without top-level receipt at lines 173-176; last assertion at line 204), line count 225.
12. `extensions/drm-copilot/test/lib/validate/epic-planner-state-launch-binding.test.ts` line 18 (`delete item[key];` lint-accepted precedent).
13. `tests/scripts/dev_tools/test_push_down_codex_and_agents_customizations.py` lines 368-404 (`test_consumer_authority_is_typescript_only_and_scope_owners_are_unchanged`; literals at lines 403-404).
14. `tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py` line 89 (deselected #510 node).
15. `.claude/hooks/enforce-python-batch-budget.ps1` lines 10-13 and 25-29 (production-only cap; test files not counted).
16. `pyproject.toml` line 116 (`addopts` carries only an LCOV reporter) and line 121 (`data_file = "artifacts/.coverage"`); `[tool.ruff]` at line 88 sets no `fix = true`.
17. `extensions/drm-copilot/run-jest.cjs` line 28 (relative `--config jest.config.cjs`, so commands run in `extensions/drm-copilot/`).
18. `extensions/drm-copilot/package.json` lines 208, 209, 211 (`lint`, `typecheck`, `test` scripts).
19. `extensions/drm-copilot/jest.config.cjs` line 18 (default reporters overridden by the command-line `--coverageReporters`).
20. `docs/features/active/2026-10-08-epic-planner-topology-receipt-gate-543/spec.md` lines 223-236 (14 criteria); checkbox counts 20 unchecked, 1 checked.
21. `.gitignore` line 6 (`/artifacts`) and lines 69-70 (`.claude/agent-memory`, `.claude/state/`).
22. `extensions/drm-copilot/tsconfig.json` line 14 (`exactOptionalPropertyTypes: true`, the reason for the typed `it.each` tables in P5-T1 and P5-T3) and `pyproject.toml` lines 85 and 89 (88-column limit for the P1-T1 line).

Sibling-region checks performed: no other test asserts the absent-key planner error (search for `Epic planner topology_receipt` outside `docs/` matched only the two production definitions, the TypeScript test lines 341 and 344, and Python test line 226); the `test_consumer_authority` slice from `if require_ready_for_execution:` still contains both asserted literals after the change; the service-call fixture lacks a top-level `topology_receipt`, so the appended `keyGated` assertion fails before P3-T1 and is therefore ordered after it.

Revision pass (preflight defects D1-D4), citations re-derived against the current tree in this pass:

23. `extensions/drm-copilot/test/mcp-repo-automation-tool-definitions.test.ts` lines 293-295 (`it.each([...])(` / title / `(toolName) => {` three-argument Prettier layout).
24. `extensions/drm-copilot/test/lib/validate/epic-planner-state-core.test.ts` lines 330-346 (no `// Arrange`, `// Act`, `// Assert` comment lines; sections separated by single blank lines at 335 and 339), line 4 (value import), line count 413.
25. `extensions/drm-copilot/eslint.config.mjs` lines 4-21 (`eslint.configs.recommended`, `...tseslint.configs.recommended`, only rule override `no-console`; no duplicate-import rule enabled).
26. `extensions/drm-copilot/test/lib/json-config.test.ts` line 3 (`import type { FileSystem } from "../../src/lib/file-system";`).
27. `scripts/dev_tools/validate_epic_planner_state.py` line 345 (88 characters at its 8-space indent; 92 at a 12-space indent).
28. `.claude/skills/acceptance-criteria-tracking/SKILL.md` line 52 (`## Check-Off Protocol`) and line 71 (`Timing:` check off as soon as the corresponding plan task passes verification).
29. `docs/features/active/2026-10-08-epic-planner-topology-receipt-gate-543/spec.md` lines 221-236 (`## Acceptance Criteria`, 14 unchecked criteria at 223-236); other checkboxes at lines 26-29 and 185-187 (1 checked, 20 unchecked in total).

Revision-pass sibling checks: `extensions/drm-copilot/test/lib/validate/epic-planner-state-launch-binding.test.ts` lines 4-5 import `validateEpicPlannerStateText` and `import type { ValidateEpicPlannerStateOptions }` from the same `epic-planner-state-core` module as two statements, a same-module precedent for the P5-T1 import that passes the current lint gate; with the merged-import fallback removed from P5-T1, the P6-T4 pure-insertion statement has no exception path left to reference; P9-T5 still begins with `Update` and names the spec path, and its mapping sentence, both `grep -c` commands, and the `15` / `6` acceptance counts are unchanged; the P2-T1 Black-wrap statement agrees with the corrected 88/92 figures.

Revision pass (sibling-region inconsistencies R1-R2), citations re-derived against the current tree in this pass:

30. `extensions/drm-copilot/test/lib/validate/epic-planner-state-core.test.ts` lines 330-346 (comment-free forced-receipt test, blank separators at 335 and 339; the P1-T4 Style sub-bullet now matches P5-T1 through P5-T3), line 4 (97-character single-specifier import kept on one line), line 148 (84-character `it(title, () => {` header kept on one line), lines 67-82 (`readyState`), line count 413.
31. `extensions/drm-copilot/test/lib/validate/epic-planner-state-launch-binding.test.ts` line 5 (`import type { ValidateEpicPlannerStateOptions }` on one line) and line 18 (`delete item[key];`).
32. `extensions/drm-copilot/src/lib/validate/epic-planner-state-core.ts` lines 51-60 (`ValidateEpicPlannerStateOptions` with `requireReadyForExecution`, `requireCodexModelRouting`, `requireCodexTopology`).
33. `extensions/drm-copilot/test/mcp-repo-automation-tool-definitions.test.ts` lines 293-295 (three-argument `it.each` layout).
34. Line-count re-derivation for `epic-planner-state-core.test.ts`: 413 + 1 + 15 + 13 + 17 + 13 + 18 = 490 (P1-T4 filter line at its 6-space indent is 80 columns and fits; the P5-T3 filter line at an 8-space indent is 82 columns and wraps; each `toContain("Epic planner topology_receipt must be an object.")` line exceeds 80 columns at 4- and 6-space indents and wraps to three lines).

Revision-pass sibling checks: the "Files the diff will WRITE" `spec.md` entry now agrees with the Execution-notes acceptance-criteria tick rule and with P9-T5 (confirm-and-complete wording; the `15` / `6` counts are unchanged); the P5-T1 through P5-T3 Style sub-bullets are unchanged; P3-T1 still expects 474 for `epic-planner-state-core.ts`; no other plan line cites the superseded 488 estimate; the Python Arrange-Act-Assert label in P1-T2 governs a different file and is unchanged.

Revision pass (preflight round 2 citation defects D5-D6), citations re-derived against the current tree in this pass:

35. `extensions/drm-copilot/test/lib/validate/epic-planner-state-core.test.ts` line 4 (`import { validateEpicPlannerStateText } from "../../../src/lib/validate/epic-planner-state-core";`, 97 characters) and line 148 (`  it("requires worthiness and features to use their object and list shapes", () => {`, 84 characters, the single-line plain `it` header precedent).
36. `extensions/drm-copilot/test/mcp-repo-automation-tool-definitions.test.ts` line 148 (`const repoDefinition = REPO_AUTOMATION_TOOL_DEFINITIONS.find(`; not an `it` header, so it is no longer cited as the header precedent; lines 293-295 remain the `it.each` layout citation).
37. `extensions/drm-copilot/test/lib/validate/validate-orchestration-service-call.test.ts` line 204 (`expect(keyGated).not.toContain(" launch binding");`, the P5-T4 insertion anchor) and line count 225; post-change estimate 232 = 225 + 3 (routing assertion, 82 columns, wraps to three lines) + 3 (topology assertion, 83 columns, wraps to three lines) + 1 (keyGated assertion, 68 columns, one line).

Revision-pass sibling checks: no other plan line cites `95-character`, `85-character`, or the superseded `230` service-call estimate; the P5-T4 assertion literals are unchanged; the 490 estimate for `epic-planner-state-core.test.ts` and its component counts in item 34 are unchanged; lines 202-203 of the service-call test (72 and 73 columns) remain unedited per P5-T4.

### Planner internal review record

PLANNER-INTERNAL-REVIEW: PASS
CITATION-TO-TREE: PASS
AC-TRACEABILITY: PASS
SCOPE-BOUNDARY: PASS
CITATION: scripts/dev_tools/validate_epic_planner_state.py | lines 327-345 (ready branch, key_gated at 329, planner topology call at 345)
CITATION: scripts/dev_tools/validate_epic_planner_state.py | lines 289-291 (docstring paragraph)
CITATION: extensions/drm-copilot/src/lib/validate/epic-planner-state-core.ts | lines 422-443 (ready branch, requireLaunchPaths at 424-426, call at 443)
CITATION: tests/scripts/dev_tools/test_validate_epic_planner_state.py | test_readiness_requires_epic_preparation_topology_receipts, lines 213-234
CITATION: extensions/drm-copilot/test/lib/validate/epic-planner-state-core.test.ts | readyState lines 67-82; forced-receipt test lines 330-346; line count 413 (post-change estimate 490)
CITATION: extensions/drm-copilot/test/lib/validate/validate-orchestration-service-call.test.ts | threads the Codex flags into epic-planner-state, lines 160-205
CITATION: tests/scripts/dev_tools/test_push_down_codex_and_agents_customizations.py | lines 400-404 (ready-gate source-text literals)
CITATION: .claude/hooks/enforce-python-batch-budget.ps1 | lines 10-13 and 25-29
CITATION: docs/features/active/2026-10-08-epic-planner-topology-receipt-gate-543/spec.md | lines 223-236
CITATION: extensions/drm-copilot/eslint.config.mjs | lines 4-21 (recommended configs only; no duplicate-import rule)
CITATION: .claude/skills/acceptance-criteria-tracking/SKILL.md | line 71 (Check-Off Protocol, Timing)
AC-INVENTORY: AC1, AC2, AC3, AC4, AC5, AC6, AC7, AC8, AC9, AC10, AC11, AC12, AC13, AC14
AC-MAPPING: AC1 | IMPLEMENTATION: P1-T2, P2-T1 | TESTS: test_ready_gate_skips_planner_topology_receipt_when_key_absent | EVIDENCE: evidence/regression-testing/fail-before-python.<ts>.md, evidence/regression-testing/pass-after-python.<ts>.md
AC-MAPPING: AC2 | IMPLEMENTATION: P4-T1 | TESTS: test_codex_flag_keeps_planner_topology_receipt_unconditional | EVIDENCE: evidence/regression-testing/python-topology-suite.<ts>.md
AC-MAPPING: AC3 | IMPLEMENTATION: P4-T2 | TESTS: test_ready_gate_validates_present_null_planner_topology_receipt | EVIDENCE: evidence/regression-testing/python-topology-suite.<ts>.md
AC-MAPPING: AC4 | IMPLEMENTATION: P4-T3 | TESTS: test_ready_gate_accepts_present_valid_planner_topology_receipt | EVIDENCE: evidence/regression-testing/python-topology-suite.<ts>.md
AC-MAPPING: AC5 | IMPLEMENTATION: P1-T1 | TESTS: test_readiness_requires_epic_preparation_topology_receipts | EVIDENCE: evidence/regression-testing/python-topology-suite.<ts>.md, evidence/regression-testing/preserved-python.<ts>.md
AC-MAPPING: AC6 | IMPLEMENTATION: P1-T4, P3-T1, P5-T1, P5-T2, P5-T3 | TESTS: four epic-planner-state-core.test.ts titles under Named tests | EVIDENCE: evidence/regression-testing/fail-before-typescript.<ts>.md, evidence/regression-testing/pass-after-typescript.<ts>.md, evidence/regression-testing/typescript-topology-suites.<ts>.md
AC-MAPPING: AC7 | IMPLEMENTATION: P5-T4 | TESTS: threads the Codex flags into epic-planner-state | EVIDENCE: evidence/regression-testing/typescript-topology-suites.<ts>.md
AC-MAPPING: AC8 | IMPLEMENTATION: P2-T1, P3-T1 | TESTS: P6-T5 grep and anchored-diff checks | EVIDENCE: evidence/qa-gates/call-site-and-strings.<ts>.md
AC-MAPPING: AC9 | IMPLEMENTATION: P6-T1, P6-T3 | TESTS: test_readiness_requires_forced_epic_planner_persona, requires the forced epic-planner topology receipt, test_consumer_authority_is_typescript_only_and_scope_owners_are_unchanged, test_cli_dispatches_planner_readiness_flag | EVIDENCE: evidence/regression-testing/preserved-python.<ts>.md, evidence/regression-testing/preserved-typescript.<ts>.md, evidence/regression-testing/targeted-python.<ts>.md, evidence/regression-testing/targeted-typescript.<ts>.md
AC-MAPPING: AC10 | IMPLEMENTATION: P6-T6 | TESTS: anchored git diff plus git status --porcelain over excluded paths | EVIDENCE: evidence/qa-gates/scope-exclusions.<ts>.md
AC-MAPPING: AC11 | IMPLEMENTATION: P7-T1 through P7-T8, P8-T1 through P8-T7 | TESTS: black, ruff, pyright, pytest, prettier, ESLint, tsc, Jest | EVIDENCE: evidence/qa-gates/final-qa-clean-pass.<ts>.md
AC-MAPPING: AC12 | IMPLEMENTATION: P7-T5, P7-T6 | TESTS: full Python suite with --cov=scripts.dev_tools | EVIDENCE: evidence/qa-gates/final-python-per-file-coverage.<ts>.md, evidence/qa-gates/coverage-delta-verification.<ts>.md
AC-MAPPING: AC13 | IMPLEMENTATION: P8-T5 | TESTS: full Jest suite with text coverage reporter | EVIDENCE: evidence/qa-gates/final-typescript-test-coverage.<ts>.md, evidence/qa-gates/coverage-delta-verification.<ts>.md
AC-MAPPING: AC14 | IMPLEMENTATION: P9-T3 | TESTS: awk physical line count per file | EVIDENCE: evidence/qa-gates/line-counts-final.<ts>.md
UNRESOLVED-GAPS: NONE
