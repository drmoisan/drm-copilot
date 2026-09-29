# 2026-09-29-ts-validator-promotion-type-parity-gap-405 (Plan)

- **Issue:** #405
- **Parent (optional):** Epic `orchestrator-state-contract-correctness` (#771). Also covers item 3 of issue #623.
- **Owner:** drmoisan
- **Last Updated:** 2026-09-29T14-19
- **Status:** Draft
- **Version:** 1.0
- **Work Mode:** full-bug
- **Requirements source:** `docs/features/active/2026-09-29-ts-validator-promotion-type-parity-gap-405/spec.md` (16 acceptance criteria under `## Acceptance Criteria`) and `docs/features/active/2026-09-29-ts-validator-promotion-type-parity-gap-405/issue.md` (5 acceptance criteria). Under `full-bug` the spec is the requirements source and `user-story.md` is absent by design.
- **Research source:** `docs/features/active/2026-09-29-ts-validator-promotion-type-parity-gap-405/research/research.2026-09-29T14-30.md`

**Fail-closed evidence rule:** Every baseline, regression, final-QA, and coverage-comparison artifact named below is mandatory. If a required artifact is missing, or any of its `Timestamp:`, `Command:`, `EXIT_CODE:`, or `Output Summary:` fields is absent, or a numeric coverage value is replaced by a placeholder, the verdict is BLOCKED or INCOMPLETE, never PASS. `EXIT_CODE: SKIPPED` is not a valid outcome for any command task in this plan.

**Evidence accounting rule:** Every evidence-producing task names its artifact path. Do not mark an evidence-backed task complete without the artifact on disk. All evidence resolves under `docs/features/active/2026-09-29-ts-validator-promotion-type-parity-gap-405/evidence/` in the `baseline/`, `regression-testing/`, `qa-gates/`, and `other/` subtrees. No evidence is written under `artifacts/`. Coverage JSON and XML files written under `artifacts/python/` and `artifacts/pester/` are tool output read by the evidence artifacts, not evidence artifacts themselves.

**Timestamp convention:** `TIMESTAMP` in an artifact filename means the ISO-8601 `yyyy-MM-ddTHH-mm` value of the run that produced it, for example `2026-09-29T15-10`.

**Expect-fail artifacts:** an artifact for an `[expect-fail]` run records the observed non-zero `EXIT_CODE:` verbatim and additionally carries `ExpectedExitCode: 1`, per `.claude/skills/evidence-and-timestamp-conventions/SKILL.md`. Each such artifact holds exactly one gate.

**Working directories:** every `npm` command runs with the working directory `extensions/drm-copilot`. Every `poetry`, `git`, and `pwsh` command runs with the working directory at the repository root.

**Test-directory correction carried deliberately.** The delegation prompt named `extensions/drm-copilot/tests/` for the TypeScript tests. The tree has no `tests/` directory under the extension, and `extensions/drm-copilot/jest.config.cjs` line 4 sets `testMatch: ["**/test/**/*.test.ts"]`, so a file under `tests/` would never run. TypeScript tests in this plan live under `extensions/drm-copilot/test/lib/validate/`, mirroring `extensions/drm-copilot/src/lib/validate/`. Python and Pester tests live under `tests/`. This is a path correction, not an evidence-path override.

**Property-test decision.** `fast-check` is not declared in `extensions/drm-copilot/package.json` (zero matches for the token there; its only occurrence in `extensions/drm-copilot/package-lock.json` is a funding URL line). `.claude/rules/typescript.md` forbids new runtime dependencies without approval, so this plan does not add it. The T2 property-density obligation for the pure function is met by a deterministic fixed-grid invariant test in P3-T4, which uses no randomness.

**Toolchain scope notes.** The extension has no dependency-cruiser script (zero matches for `depcruise` in `extensions/drm-copilot/package.json`); architecture-boundary tests that exist (for example `extensions/drm-copilot/test/lib/subagent-tree/module-boundary.test.ts`) run inside the Jest suite that P5-T4 executes. Contract and integration stages for this change are the Jest suite, the Pytest suite, and the Pester suite executed in Phase 5. Production Python and production PowerShell are unchanged by this plan, so the Python and Pester legs add tests only.

## Scope of the diff

The committed diff writes exactly these repo-relative paths and no others.

Production, TypeScript:
1. `extensions/drm-copilot/src/lib/validate/orchestrator-state-promotion-tools.ts` (new)
2. `extensions/drm-copilot/src/lib/validate/orchestrator-state-routing.ts`

Configuration:
3. `extensions/drm-copilot/jest.config.cjs`

Tests, TypeScript:
4. `extensions/drm-copilot/test/lib/validate/orchestrator-state-promotion-tools.test.ts` (new)
5. `extensions/drm-copilot/test/lib/validate/orchestrator-state-routing.promotion-type.test.ts` (new)
6. `extensions/drm-copilot/test/lib/validate/orchestrator-state-promotion-type-parity.test.ts` (new)

Tests, Python:
7. `tests/scripts/dev_tools/test_orchestrator_state_promotion_type_parity.py` (new)

Tests, Pester:
8. `tests/scripts/claude-lib/orchestrator-state/OrchestratorStatePromotionType.Parity.Tests.ps1` (new)

Fixtures, twelve new files:
9. `tests/fixtures/orchestrator_state_promotion_type/*.json`

Feature documents and evidence:
10. `docs/features/active/2026-09-29-ts-validator-promotion-type-parity-gap-405/spec.md` and `issue.md` (acceptance-criteria checkboxes only), this plan file, the research file, and `docs/features/active/2026-09-29-ts-validator-promotion-type-parity-gap-405/evidence/**`.

Explicitly not written: `scripts/dev_tools/_orchestrator_state_routing.py`, every file under `.claude/lib/orchestrator-state/`, every file under `extensions/drm-copilot/resources/`, every file under `.claude/hooks/` (including `.claude/hooks/enforce-powershell-batch-budget.ps1`, which belongs to issue #769), `config/orchestration-routing.json`, and the existing `extensions/drm-copilot/test/lib/validate/orchestrator-state-routing.test.ts`, whose in-file matrix is stale and is not extended.

Out of scope and not attempted: issue #343 (`pr_gate`/`ci_gate` route gating), issue #509 (pre-existing-issue evidence in place of a `potential_to_issue` receipt), any Python leg in an enforcement hook, and any change to a bundled PowerShell mirror. Because no file under `.claude/lib/orchestrator-state/` changes, no bundle change is needed; P4-T4 proves the source and bundled copies of `OrchestratorStateRoutingContract.psm1` are byte-identical and that the diff against `origin/main` is empty for both trees.

## Fixed literals this plan introduces

The executor writes these exact strings. They are quoted here, outside any command span, so acceptance conditions that name them are exonerated as literals the plan instructs the executor to create.

- New module file name: `orchestrator-state-promotion-tools.ts`
- Exported function name and call shape: `resolvePromotionEntryTools(`
- Exported constants: `FEATURE_PROMOTION_ENTRY_TOOL`, `BUG_PROMOTION_ENTRY_TOOL`, `BUG_PROMOTION_TYPE`, `PROMOTION_TYPE_KEY`
- Jest threshold key: `"./src/lib/validate/orchestrator-state-promotion-tools.ts"`
- Import specifier written into `orchestrator-state-routing.ts`: `./orchestrator-state-promotion-tools`
- Error strings the corpus pins (both already emitted by the existing validators): `Checkpoint required_mcp_tools must match routing matrix for route large.` and `Checkpoint missing successful MCP receipt: new_potential_bug_entry.`

## Parity corpus construction rule

The corpus is twelve JSON files in `tests/fixtures/orchestrator_state_promotion_type/`, each shaped `{ "name", "notes", "checkpoint", "expected_errors" }`. `name` equals the file stem, `notes` is one sentence naming the behavior class, `checkpoint` is the object handed to each runtime's routing-contract validator, and `expected_errors` is the full ordered error list that validator returns. The routing matrix is the real `config/orchestration-routing.json` in Python and TypeScript, and the pinned `OrchestratorStateRoutingMatrix.psm1` matrix in PowerShell; the two are equal for the five routes used here (lists in `config/orchestration-routing.json` lines 5-33 small, 34-60 large, 61-78 remediation, 79-99 preparation, 122-143 epic, compared against `.claude/lib/orchestrator-state/OrchestratorStateRoutingMatrix.psm1` lines 51-93), and `tests/scripts/claude-lib/orchestrator-state/OrchestratorStateRoutingMatrix.Tests.ps1` line 53 (`Describe 'Pinned routing-matrix constants match config/orchestration-routing.json'`) is the standing parity oracle.

Every `checkpoint` carries exactly these keys and no others:
- `route_id`
- `promotion-type`, omitted only in the absent-key case
- `required_agents`, `required_skills`, `required_mcp_tools`: the declared lists
- `delegation_receipts`: one object `{"agent_name": AGENT}` per required agent of the route
- `skill_receipts`: one object `{"skill": SKILL, "required": true, "evidence": "e"}` per required skill of the route
- `mcp_call_receipts`: one object `{"tool": TOOL, "ok": true, "evidence": "e"}` per tool in the receipt list
- `local_execution_overrides`: `[]`
- `delegation_bypasses`: `[]`
- no `lifecycle_operations` key, which all three runtimes treat as no lifecycle error

Route lists, verbatim from `config/orchestration-routing.json`:
- `small` agents: atomic-planner, atomic-executor, feature-review. Skills: orchestrate, feature-promotion-lifecycle, atomic-plan-contract, acceptance-criteria-tracking, pr-context-artifacts, pr-base-branch-merge-base. Tools: new_potential_entry, potential_to_issue, new_active_feature_folder, collect_pr_context, validate_orchestration_artifacts.
- `large` agents: task-researcher, prd-feature, atomic-planner, atomic-executor, feature-review, pr-author. Skills and tools: identical to `small`.
- `preparation` agents: task-researcher, prd-feature, atomic-planner, atomic-executor. Skills: orchestrate, feature-promotion-lifecycle, atomic-plan-contract. Tools: new_potential_entry, potential_to_issue, new_active_feature_folder, validate_orchestration_artifacts.
- `remediation` agents: atomic-planner, atomic-executor, feature-review. Skills: orchestrate, atomic-plan-contract, acceptance-criteria-tracking, pr-context-artifacts. Tools: collect_pr_context, validate_orchestration_artifacts.
- `epic` agents: orchestrator, pr-author. Skills: epic-orchestrate, orchestrate, feature-promotion-lifecycle, atomic-plan-contract, acceptance-criteria-tracking, evidence-and-timestamp-conventions, pr-context-artifacts, pr-base-branch-merge-base. Tools: collect_pr_context, validate_orchestration_artifacts.

"Raw tools" means the route's tool list exactly as above. "Bug tools" means the raw list with `new_potential_entry` replaced by `new_potential_bug_entry` in place. The ordered error list every runtime produces places the three declared-list equality errors first (agents, skills, tools), then agent, skill, and tool receipt errors in matrix order (`scripts/dev_tools/_orchestrator_state_routing.py` lines 561-590; `OrchestratorStateRoutingContract.psm1` lines 384-417; `extensions/drm-copilot/src/lib/validate/orchestrator-state-routing.ts` lines 410-445).

### Phase 0 — Policy Reads and Baseline Capture

Baseline capture precedes every source edit. Each write-mode formatter task in this phase records `git status --porcelain` immediately before and immediately after the run, so drift the formatter repaired here is visible and is not credited to the final QA loop. If any baseline test or QA command below exits non-zero, stop and report BLOCKED: the plan assumes a green baseline, except where a task states a bounded baseline-relative comparison.

- [ ] [P0-T1] Read the repository policy files in the canonical order and record the read in `docs/features/active/2026-09-29-ts-validator-promotion-type-parity-gap-405/evidence/baseline/`.
  - Read, in this order: `CLAUDE.md`, `.claude/rules/general-code-change.md`, `.claude/rules/general-unit-test.md`, `.claude/rules/typescript.md`, `.claude/rules/typescript-suppressions.md`, `.claude/rules/python.md`, `.claude/rules/python-suppressions.md`, `.claude/rules/powershell.md`, `.claude/rules/quality-tiers.md`, `.claude/rules/orchestrator-state.md`, `.claude/rules/plan-acceptance-gates.md`.
  - Acceptance: `docs/features/active/2026-09-29-ts-validator-promotion-type-parity-gap-405/evidence/baseline/phase0-instructions-read.TIMESTAMP.md` exists and carries `Timestamp:`, `Policy Order:`, and the explicit list of the eleven files read, each as a repo-relative path.

- [ ] [P0-T2] Read the requirements and research inputs under `docs/features/active/2026-09-29-ts-validator-promotion-type-parity-gap-405/` and record the read.
  - Read `docs/features/active/2026-09-29-ts-validator-promotion-type-parity-gap-405/issue.md`, `docs/features/active/2026-09-29-ts-validator-promotion-type-parity-gap-405/spec.md`, and `docs/features/active/2026-09-29-ts-validator-promotion-type-parity-gap-405/research/research.2026-09-29T14-30.md`.
  - Acceptance: `docs/features/active/2026-09-29-ts-validator-promotion-type-parity-gap-405/evidence/baseline/phase0-requirements-read.TIMESTAMP.md` exists, records the three paths, records that the persisted work mode read from `issue.md` is full-bug, records the integer 16 as the count of checkboxes under the `## Acceptance Criteria` heading of `spec.md`, and records the integer 5 as the count of checkboxes under the same heading of `issue.md`.

- [ ] [P0-T3] Record the branch and base-commit baseline in `docs/features/active/2026-09-29-ts-validator-promotion-type-parity-gap-405/evidence/baseline/`.
  - Run `git rev-parse --abbrev-ref HEAD`, `git rev-parse HEAD`, `git rev-parse origin/main`, and `git status --porcelain`.
  - Acceptance: `docs/features/active/2026-09-29-ts-validator-promotion-type-parity-gap-405/evidence/baseline/git-baseline.TIMESTAMP.md` records all four commands with `Timestamp:`, `Command:`, `EXIT_CODE:`, and `Output Summary:`, the branch name is `bug/ts-validator-promotion-type-parity-gap-405`, and both resolved SHAs are recorded verbatim as forty-character values.

- [ ] [P0-T4] Capture the baseline line count of each existing file this diff edits, starting with `extensions/drm-copilot/src/lib/validate/orchestrator-state-routing.ts`.
  - Run `pwsh -NoProfile -Command "foreach ($p in 'extensions/drm-copilot/src/lib/validate/orchestrator-state-routing.ts','extensions/drm-copilot/jest.config.cjs','extensions/drm-copilot/test/lib/validate/orchestrator-state-routing.test.ts','scripts/dev_tools/_orchestrator_state_routing.py') { [pscustomobject]@{ Path = $p; Lines = (Get-Content -LiteralPath $p).Count } }"`.
  - Acceptance: `docs/features/active/2026-09-29-ts-validator-promotion-type-parity-gap-405/evidence/baseline/file-line-counts.TIMESTAMP.md` records `Timestamp:`, `Command:`, `EXIT_CODE:` 0, and an `Output Summary:` listing the four paths with their integer line counts. The research recorded 451 lines for `extensions/drm-copilot/src/lib/validate/orchestrator-state-routing.ts` (last non-blank line is line 451, read directly this pass) and 302 for the stale-matrix test; the artifact records the observed integers and states whether each matches. The Python file is recorded for information only: it already exceeds 500 lines, is not edited by this plan, and is not counted against the size gate.

- [ ] [P0-T5] Capture the bundled-mirror byte-identity baseline for `.claude/lib/orchestrator-state/OrchestratorStateRoutingContract.psm1`.
  - Run `pwsh -NoProfile -Command "Get-FileHash -Algorithm SHA256 -LiteralPath .claude/lib/orchestrator-state/OrchestratorStateRoutingContract.psm1, extensions/drm-copilot/resources/claude-customizations/.claude/lib/orchestrator-state/OrchestratorStateRoutingContract.psm1 | Format-Table Hash, Path -AutoSize"`.
  - Acceptance: `docs/features/active/2026-09-29-ts-validator-promotion-type-parity-gap-405/evidence/baseline/bundle-hash-baseline.TIMESTAMP.md` records `Timestamp:`, `Command:`, `EXIT_CODE:` 0, and an `Output Summary:` carrying both 64-character hashes verbatim and the statement that they are equal. Unequal hashes are a failure of this task and stop the plan, because the plan's premise that no bundle change is needed would not hold.

- [ ] [P0-T6] Capture the TypeScript formatter baseline in `docs/features/active/2026-09-29-ts-validator-promotion-type-parity-gap-405/evidence/baseline/` with a before-and-after tree observation.
  - Run `git status --porcelain`, then `npm run format`, then `git status --porcelain` again.
  - Acceptance: `docs/features/active/2026-09-29-ts-validator-promotion-type-parity-gap-405/evidence/baseline/ts-format.TIMESTAMP.md` records `Timestamp:`, `Command:`, `EXIT_CODE:` 0, and an `Output Summary:` carrying both porcelain listings verbatim plus the explicit list of tracked files the run rewrote. Prettier prints `(unchanged)` after each file it left as it found it; the summary records whether every printed file line ended in `(unchanged)`. When the two listings are identical the summary states that the run left every matched file unchanged. When they differ, the run repaired pre-existing drift: revert every rewritten file that is not in the "Scope of the diff" enumeration with `git checkout --` and record both the rewritten list and the revert in the artifact. Do not carry unrelated formatting into this change set.

- [ ] [P0-T7] Capture the TypeScript lint baseline at `docs/features/active/2026-09-29-ts-validator-promotion-type-parity-gap-405/evidence/baseline/ts-lint.TIMESTAMP.md`.
  - Run `npm run lint`.
  - Acceptance: the artifact records `Timestamp:`, `Command:`, `EXIT_CODE:`, and an `Output Summary:` carrying the integer error count and the integer warning count reported by the run. A clean ESLint run prints no summary line; record empty output plus exit code 0 as the counts 0 and 0, and quote the output verbatim when it is non-empty.

- [ ] [P0-T8] Capture the TypeScript type-check baseline at `docs/features/active/2026-09-29-ts-validator-promotion-type-parity-gap-405/evidence/baseline/ts-typecheck.TIMESTAMP.md`.
  - Run `npm run typecheck`.
  - Acceptance: the artifact records `Timestamp:`, `Command:`, `EXIT_CODE:`, and an `Output Summary:` carrying the integer diagnostic count. A clean `tsc --noEmit` run prints nothing; record empty output plus exit code 0 as the count 0, and quote the output verbatim when it is non-empty.

- [ ] [P0-T9] Capture the TypeScript directory unit-test baseline for `extensions/drm-copilot/test/lib/validate/`.
  - Run `npm run test:unit -- test/lib/validate`.
  - Acceptance: `docs/features/active/2026-09-29-ts-validator-promotion-type-parity-gap-405/evidence/baseline/ts-validate-dir-tests.TIMESTAMP.md` records `Timestamp:`, `Command:`, `EXIT_CODE:` 0, and an `Output Summary:` carrying the integer passed, failed, and total counts from the `Tests:` line and the integer passed and total counts from the `Test Suites:` line. The passed count is the anchor P4-T1 uses for the byte-identical-behavior comparison; record it as the labelled integer `BASELINE_DIR_PASSED`.

- [ ] [P0-T10] Capture the TypeScript full coverage baseline with per-file rows at `docs/features/active/2026-09-29-ts-validator-promotion-type-parity-gap-405/evidence/baseline/ts-coverage.TIMESTAMP.md`.
  - Run `npm run test:coverage -- --coverageReporters=text`. The extension `test:coverage` script already carries `--coverageReporters=lcov --coverageReporters=text-summary`; the extra `text` reporter adds the per-file table.
  - Acceptance: the artifact records `Timestamp:`, `Command:`, `EXIT_CODE:` 0, and an `Output Summary:` carrying the numeric overall statement, branch, function, and line percentages from the `text-summary` block, plus the numeric `% Stmts`, `% Branch`, `% Funcs`, and `% Lines` cells of the table row for `orchestrator-state-routing.ts` (the changed production file; it has no per-file threshold entry today). Placeholder values are not acceptable. An exit code of 0 also records that every existing per-file threshold in `extensions/drm-copilot/jest.config.cjs` passes at baseline.

- [ ] [P0-T11] Capture the Python formatter baseline in `docs/features/active/2026-09-29-ts-validator-promotion-type-parity-gap-405/evidence/baseline/` with a before-and-after tree observation.
  - Run `git status --porcelain`, then `poetry run black .`, then `git status --porcelain` again.
  - Acceptance: `docs/features/active/2026-09-29-ts-validator-promotion-type-parity-gap-405/evidence/baseline/py-black.TIMESTAMP.md` records `Timestamp:`, `Command:`, `EXIT_CODE:` 0, and an `Output Summary:` carrying both porcelain listings verbatim, the integer count of files the run reformatted, and the integer count it left unchanged (Black prints `N files left unchanged` on a clean run and `reformatted` for each file it rewrote). If the two listings differ, revert every rewritten file outside the "Scope of the diff" enumeration with `git checkout --` and record both the rewritten list and the revert.

- [ ] [P0-T12] Capture the Python lint baseline at `docs/features/active/2026-09-29-ts-validator-promotion-type-parity-gap-405/evidence/baseline/py-ruff.TIMESTAMP.md`.
  - Run `poetry run ruff check .`.
  - Acceptance: the artifact records `Timestamp:`, `Command:`, `EXIT_CODE:`, and an `Output Summary:` recording verbatim the final line the run printed (`All checks passed!` on a clean run, otherwise the `Found N errors.` line) together with the integer diagnostic count that line reports. The repository Ruff configuration sets no `fix` key, so this command does not rewrite files; do not record a fixed-file count.

- [ ] [P0-T13] Capture the Python type-check baseline at `docs/features/active/2026-09-29-ts-validator-promotion-type-parity-gap-405/evidence/baseline/py-pyright.TIMESTAMP.md`.
  - Run `poetry run pyright`.
  - Acceptance: the artifact records `Timestamp:`, `Command:`, `EXIT_CODE:`, and an `Output Summary:` carrying the integer error, warning, and information counts from the summary line pyright prints.

- [ ] [P0-T14] Capture the Python full-suite coverage baseline at `docs/features/active/2026-09-29-ts-validator-promotion-type-parity-gap-405/evidence/baseline/py-pytest-coverage.TIMESTAMP.md`.
  - Run `poetry run pytest --cov=scripts.dev_tools --cov-branch --cov-report=term-missing --cov-report=json:artifacts/python/cov-p0-t14.json`.
  - Acceptance: the artifact records `Timestamp:`, `Command:`, `EXIT_CODE:`, and an `Output Summary:` carrying the passed and failed test counts, the node ID of every failed test (so a baseline-relative comparison in P5-T9 is possible when the workspace has a pre-existing failure), and the `percent_statements_covered` and `percent_branches_covered` values read from the `totals` object of `artifacts/python/cov-p0-t14.json`, stated to one decimal place. The terminal `Cover` column combines line and branch data and cannot supply either percentage on its own, so both percentages are read from the JSON, never from the terminal table. A non-zero exit is permitted here only when every failed test is recorded by node ID; that failed-node set is then the exact set P5-T9 must reproduce.

- [ ] [P0-T15] Capture the Python targeted coverage baseline for the routing module at `docs/features/active/2026-09-29-ts-validator-promotion-type-parity-gap-405/evidence/baseline/py-routing-coverage.TIMESTAMP.md`.
  - Run `poetry run pytest tests/scripts/dev_tools/test_validate_orchestrator_state_routing_contract.py --cov=scripts.dev_tools._orchestrator_state_routing --cov-branch --cov-report=term-missing --cov-report=json:artifacts/python/cov-p0-t15.json`.
  - Acceptance: the artifact records `Timestamp:`, `Command:`, `EXIT_CODE:` 0, and an `Output Summary:` carrying the passed count, and for the file `scripts/dev_tools/_orchestrator_state_routing.py` the `percent_statements_covered` and `percent_branches_covered` values read from the `summary` object of that file's entry under `files` in `artifacts/python/cov-p0-t15.json` (an entry under `files` carries no percent keys directly; they live in its `summary` object), stated to one decimal place, plus the raw `Stmts`, `Miss`, `Branch`, and `BrPart` cells of the printed row verbatim. Placeholder values are not acceptable.

- [ ] [P0-T16] Capture the PowerShell formatter baseline in `docs/features/active/2026-09-29-ts-validator-promotion-type-parity-gap-405/evidence/baseline/` with a before-and-after tree observation.
  - Run `git status --porcelain`, then `pwsh -NoLogo -NoProfile -ExecutionPolicy Bypass -Command "& { Import-Module 'scripts/powershell/PoshQC'; Invoke-PoshQCFormat -Root (Get-Location).Path }"`, then `git status --porcelain` again (invocation form from `.vscode/tasks.json` line 525).
  - Acceptance: `docs/features/active/2026-09-29-ts-validator-promotion-type-parity-gap-405/evidence/baseline/ps-format.TIMESTAMP.md` records `Timestamp:`, `Command:`, `EXIT_CODE:` 0, and an `Output Summary:` carrying both porcelain listings verbatim and the list of files the run rewrote. If the listings differ, revert every rewritten file outside the "Scope of the diff" enumeration with `git checkout --` and record both the rewritten list and the revert.

- [ ] [P0-T17] Capture the PowerShell analyzer baseline at `docs/features/active/2026-09-29-ts-validator-promotion-type-parity-gap-405/evidence/baseline/ps-analyze.TIMESTAMP.md`.
  - Run `pwsh -NoLogo -NoProfile -ExecutionPolicy Bypass -Command "& { Import-Module 'scripts/powershell/PoshQC'; Invoke-PoshQCAnalyze -Root (Get-Location).Path }"` (invocation form from `.vscode/tasks.json` line 550).
  - Acceptance: the artifact records `Timestamp:`, `Command:`, `EXIT_CODE:`, and an `Output Summary:` quoting the run's output verbatim and the integer count of error, warning, and information diagnostics it reports. When the run prints no diagnostics, the summary records empty output plus exit code 0 as the counts 0, 0, and 0.

- [ ] [P0-T18] Capture the PowerShell Pester full-suite and coverage baseline at `docs/features/active/2026-09-29-ts-validator-promotion-type-parity-gap-405/evidence/baseline/ps-test-coverage.TIMESTAMP.md`.
  - Run `pwsh -NoLogo -NoProfile -ExecutionPolicy Bypass -Command "& { Import-Module 'scripts/powershell/PoshQC'; Invoke-PoshQCTest -Root (Get-Location).Path }"` (invocation form from `.vscode/tasks.json` line 600). This is the self-hosted module, chosen because it writes `artifacts/pester/pester-junit.xml` and `artifacts/pester/powershell-coverage.xml` (`scripts/powershell/PoshQC/settings/pester.runsettings.psd1` lines 15 and 22), which supply the counts below. Pester reports line and instruction coverage only; there is no PowerShell branch-coverage gate.
  - Acceptance: the artifact records `Timestamp:`, `Command:`, `EXIT_CODE:`, and an `Output Summary:` carrying the integer passed, failed, and total test counts read from `artifacts/pester/pester-junit.xml` (the `tests` and `failures` attributes of the root `testsuites` element), the node names of every failed test, and the integer `missed` and `covered` values of the `LINE` counter for the source file entry named `OrchestratorStateRoutingContract.psm1` plus the report-level `LINE` counter, both read from `artifacts/pester/powershell-coverage.xml`, with the derived line percentage and its arithmetic. `.claude/lib/orchestrator-state/OrchestratorStateRoutingContract.psm1` is in the coverage allow-list (`scripts/powershell/PoshQC/settings/pester.runsettings.psd1` line 120). If the XML layout differs from a JaCoCo-style `counter` element, the artifact quotes the observed element verbatim and derives the percentage from it; a missing value is a failure of this task. A non-zero exit is permitted only when every failed test is recorded by name; that failed-name set is the exact set P5-T13 must reproduce.

### Phase 1 — Parity Corpus and Authority-Runtime Readers

This phase adds the twelve fixtures and the Python and Pester readers. Python and PowerShell already implement the exact-match resolution (`scripts/dev_tools/_orchestrator_state_routing.py` lines 357-406 and `.claude/lib/orchestrator-state/OrchestratorStateRoutingContract.psm1` lines 105-144), so both readers are expected to pass in this phase. That pass is what proves each fixture's `expected_errors` matches the two authority runtimes before the TypeScript side is compared against it. These runs are pass-now baselines of the authorities, not `[expect-fail]` tasks. Each fixture follows the "Parity corpus construction rule" above.

- [ ] [P1-T1] Create `tests/fixtures/orchestrator_state_promotion_type/bug-large-bug-tool-declared-and-recorded.json`.
  - Case: route `large`, `promotion-type` `"bug"`, declared `required_mcp_tools` is the bug tools, `mcp_call_receipts` cover the bug tools. `expected_errors`: `[]`.
  - Acceptance: the file exists, parses as JSON, carries the four keys, and its `name` equals `bug-large-bug-tool-declared-and-recorded`.

- [ ] [P1-T2] Create `tests/fixtures/orchestrator_state_promotion_type/feature-large-feature-tool-declared-and-recorded.json`.
  - Case: route `large`, `promotion-type` `"feature"`, declared tools are the raw tools, receipts cover the raw tools. `expected_errors`: `[]`.
  - Acceptance: the file exists, parses, carries the four keys, and its `name` equals `feature-large-feature-tool-declared-and-recorded`.

- [ ] [P1-T3] Create `tests/fixtures/orchestrator_state_promotion_type/bug-large-feature-tool-only.json`.
  - Case: route `large`, `promotion-type` `"bug"`, declared tools are the raw tools, receipts cover the raw tools. `expected_errors`, in this order: `Checkpoint required_mcp_tools must match routing matrix for route large.` then `Checkpoint missing successful MCP receipt: new_potential_bug_entry.`
  - Acceptance: the file exists, parses, carries the four keys, its `name` equals `bug-large-feature-tool-only`, and `expected_errors` holds exactly those two strings in that order.

- [ ] [P1-T4] Create `tests/fixtures/orchestrator_state_promotion_type/absent-promotion-type-large-feature-tool.json`.
  - Case: route `large`, no `promotion-type` key, declared tools are the raw tools, receipts cover the raw tools. `expected_errors`: `[]`.
  - Acceptance: the file exists, parses, carries the four keys, its `name` equals `absent-promotion-type-large-feature-tool`, and its `checkpoint` has no `promotion-type` key.

- [ ] [P1-T5] Create `tests/fixtures/orchestrator_state_promotion_type/capitalized-bug-large-feature-tool.json`.
  - Case: route `large`, `promotion-type` `"Bug"` (capital B), declared tools are the raw tools, receipts cover the raw tools. `expected_errors`: `[]`, because only the exact string `"bug"` substitutes.
  - Acceptance: the file exists, parses, carries the four keys, and its `name` equals `capitalized-bug-large-feature-tool`.

- [ ] [P1-T6] Create `tests/fixtures/orchestrator_state_promotion_type/leading-space-bug-large-feature-tool.json`.
  - Case: route `large`, `promotion-type` `" bug"` (one leading space), declared tools are the raw tools, receipts cover the raw tools. `expected_errors`: `[]`.
  - Acceptance: the file exists, parses, carries the four keys, and its `name` equals `leading-space-bug-large-feature-tool`.

- [ ] [P1-T7] Create `tests/fixtures/orchestrator_state_promotion_type/non-string-true-large-feature-tool.json`.
  - Case: route `large`, `promotion-type` the JSON boolean `true`, declared tools are the raw tools, receipts cover the raw tools. `expected_errors`: `[]`.
  - Acceptance: the file exists, parses, carries the four keys, its `name` equals `non-string-true-large-feature-tool`, and the `promotion-type` value is the JSON boolean true and not a string.

- [ ] [P1-T8] Create `tests/fixtures/orchestrator_state_promotion_type/null-promotion-type-large-feature-tool.json`.
  - Case: route `large`, `promotion-type` the JSON `null`, declared tools are the raw tools, receipts cover the raw tools. `expected_errors`: `[]`.
  - Acceptance: the file exists, parses, carries the four keys, its `name` equals `null-promotion-type-large-feature-tool`, and the `promotion-type` key is present with the value null.

- [ ] [P1-T9] Create `tests/fixtures/orchestrator_state_promotion_type/bug-small-bug-tool-declared-and-recorded.json`.
  - Case: route `small`, `promotion-type` `"bug"`, declared tools are the bug tools, receipts cover the bug tools. `expected_errors`: `[]`.
  - Acceptance: the file exists, parses, carries the four keys, and its `name` equals `bug-small-bug-tool-declared-and-recorded`.

- [ ] [P1-T10] Create `tests/fixtures/orchestrator_state_promotion_type/bug-preparation-bug-tool-declared-and-recorded.json`.
  - Case: route `preparation`, `promotion-type` `"bug"`, declared tools are the bug tools, receipts cover the bug tools. `expected_errors`: `[]`.
  - Acceptance: the file exists, parses, carries the four keys, and its `name` equals `bug-preparation-bug-tool-declared-and-recorded`.

- [ ] [P1-T11] Create `tests/fixtures/orchestrator_state_promotion_type/bug-remediation-no-op.json`.
  - Case: route `remediation`, `promotion-type` `"bug"`, declared tools are the raw tools (the list has no promotion-entry tool), receipts cover the raw tools. `expected_errors`: `[]`. The case proves the substitution is a no-op on a route whose list lacks `new_potential_entry`.
  - Acceptance: the file exists, parses, carries the four keys, and its `name` equals `bug-remediation-no-op`.

- [ ] [P1-T12] Create `tests/fixtures/orchestrator_state_promotion_type/bug-epic-no-op.json`.
  - Case: route `epic`, `promotion-type` `"bug"`, declared tools are the raw tools, receipts cover the raw tools. `expected_errors`: `[]`.
  - Acceptance: the file exists, parses, carries the four keys, and its `name` equals `bug-epic-no-op`.

- [ ] [P1-T13] Create the Python corpus reader `tests/scripts/dev_tools/test_orchestrator_state_promotion_type_parity.py`.
  - Follow the design of `tests/scripts/dev_tools/test_parallel_cohort_barrier_parity.py` (repository root resolved from `Path(__file__).resolve().parents[3]`; guarded load of each corpus file with `name` equal to the file stem; sorted glob). Import only `validate_routing_contract` from `scripts.dev_tools._orchestrator_state_routing` and call it as `validate_routing_contract(checkpoint)`, which loads the real `config/orchestration-routing.json` matrix. Define `MINIMUM_CORPUS_COUNT = 12`. Tests: `test_corpus_meets_the_documented_minimum_size`, `test_discovered_corpus_count_equals_the_json_file_count`, `test_corpus_exercises_both_verdicts`, and one parametrized `test_corpus_document_reproduces_the_expected_routing_errors` case per file, asserting ordered list equality with `expected_errors`. No temporary file, no external process, no wall-clock read, full type annotations, under 500 lines.
  - Acceptance: the file exists at that path, defines the four test names above, and `(Get-Content -LiteralPath tests/scripts/dev_tools/test_orchestrator_state_promotion_type_parity.py).Count` is below 500, recorded in the P1-T14 artifact.

- [ ] [P1-T14] Run `tests/scripts/dev_tools/test_orchestrator_state_promotion_type_parity.py` against the unchanged Python authority and record the pass.
  - Run `poetry run pytest tests/scripts/dev_tools/test_orchestrator_state_promotion_type_parity.py`.
  - Acceptance: `docs/features/active/2026-09-29-ts-validator-promotion-type-parity-gap-405/evidence/regression-testing/py-parity-authority-pass.TIMESTAMP.md` records `Timestamp:`, `Command:`, `EXIT_CODE:` 0, and an `Output Summary:` carrying the pytest summary line, which must read `15 passed` (three guard tests plus twelve parametrized cases) with zero failed, plus the line count from P1-T13. A failure here means a fixture's `expected_errors` disagrees with the Python authority: correct the fixture, never the assertion.

- [ ] [P1-T15] Create the Pester corpus reader `tests/scripts/claude-lib/orchestrator-state/OrchestratorStatePromotionType.Parity.Tests.ps1`.
  - Follow `tests/scripts/claude-lib/blast-radius/BlastRadius.Parity.Tests.ps1` (discovery-time `Get-ChildItem` enumeration into a `-ForEach` case list) and the header, `#Requires`, and module import of `tests/scripts/claude-lib/orchestrator-state/OrchestratorStateRoutingContract.Tests.ps1` lines 1-39. Resolve the corpus with `(Resolve-Path "$PSScriptRoot/../../../../tests/fixtures/orchestrator_state_promotion_type").Path`. Import `.claude/lib/orchestrator-state/OrchestratorStateRoutingContract.psm1`. Convert each file with `Get-Content -Raw | ConvertFrom-Json` (no `-AsHashtable`, so `checkpoint` binds to the `[psobject] $State` parameter) and call `Get-OrchestratorStateRoutingContractError -State` with the fixture checkpoint. Compare the ordered error list to `expected_errors` as one joined string with `-BeExactly`, so empty and single-element lists are unambiguous. Set `$minimumFixtureCount = 12`. `It` blocks: three discovery guards (minimum size, count equals files on disk, both an empty and a non-empty `expected_errors`) plus one `-ForEach` case per file. No temporary file, no external process, under 500 lines.
  - Acceptance: the file exists at that path and `(Get-Content -LiteralPath tests/scripts/claude-lib/orchestrator-state/OrchestratorStatePromotionType.Parity.Tests.ps1).Count` is below 500, recorded in the P1-T16 artifact.

- [ ] [P1-T16] Run `tests/scripts/claude-lib/orchestrator-state/OrchestratorStatePromotionType.Parity.Tests.ps1` against the unchanged PowerShell authority and record the pass.
  - Run `pwsh -NoLogo -NoProfile -Command '$r = Invoke-Pester -Path tests/scripts/claude-lib/orchestrator-state/OrchestratorStatePromotionType.Parity.Tests.ps1 -Output Detailed -PassThru; exit $r.FailedCount'`. The command exits with the failed-test count, so a passing run exits 0.
  - Acceptance: `docs/features/active/2026-09-29-ts-validator-promotion-type-parity-gap-405/evidence/regression-testing/ps-parity-authority-pass.TIMESTAMP.md` records `Timestamp:`, `Command:`, `EXIT_CODE:` 0, and an `Output Summary:` carrying the Pester summary line `Tests Passed: 15, Failed: 0` (three guards plus twelve cases) and the line count from P1-T15. A failure here means a fixture disagrees with the PowerShell authority: correct the fixture, never the assertion.

### Phase 2 — Regression Tests (must fail first)

These tests exercise the existing, unfixed TypeScript `validateRoutingContract`. Both files import only `validateRoutingContract`, which exists today, so each failure is an assertion failure that reproduces the reported defect and not a missing-module error. No format, lint, type-check, or full-suite gate runs between this phase and P3-T2.

- [ ] [P2-T1] [expect-fail] Create the TypeScript corpus reader `extensions/drm-copilot/test/lib/validate/orchestrator-state-promotion-type-parity.test.ts`.
  - Follow `extensions/drm-copilot/test/lib/validate/parallel-cohort-barrier-parity.test.ts` (corpus directory resolved from `__dirname` walking five levels up to the repository root; guarded load with `unknown` narrowing; sorted `readdirSync`). Read the real matrix once with `fs.readFileSync` of `config/orchestration-routing.json`, resolved from `__dirname` the same way, and parse it with `JSON.parse`. Call `validateRoutingContract(checkpoint, { routingMatrix })` from `../../../src/lib/validate/orchestrator-state-routing`. Define `MINIMUM_CORPUS_COUNT = 12`. Tests: a minimum-size guard, a count-equals-files-on-disk guard, a both-verdicts guard, and one `it.each` case per file named `reproduces the expected routing-contract errors for $name`, asserting `toEqual` on the ordered list. Read committed files only; no temporary file, no timer, no clock; under 500 lines.
  - Acceptance: the file exists at that path, and its line count, recorded in the P2-T2 artifact, is below 500.

- [ ] [P2-T2] [expect-fail] Run `extensions/drm-copilot/test/lib/validate/orchestrator-state-promotion-type-parity.test.ts` and confirm it fails on exactly the four bug-substitution cases.
  - Run `npm run test:unit -- test/lib/validate/orchestrator-state-promotion-type-parity.test.ts`.
  - Acceptance: `docs/features/active/2026-09-29-ts-validator-promotion-type-parity-gap-405/evidence/regression-testing/ts-parity-expect-fail.TIMESTAMP.md` records `Timestamp:`, `Command:`, `EXIT_CODE:` 1, `ExpectedExitCode: 1`, and an `Output Summary:` carrying the `Tests:` line, which must read `4 failed, 11 passed, 15 total`, and the case names of the four failures: `bug-large-bug-tool-declared-and-recorded`, `bug-large-feature-tool-only`, `bug-small-bug-tool-declared-and-recorded`, and `bug-preparation-bug-tool-declared-and-recorded`. The three guard tests and the eight non-substituting cases pass. A run that fails any other case, or fails none of these four, is not the repro and stops the plan for diagnosis.

- [ ] [P2-T3] [expect-fail] Create the TypeScript routing-contract regression test `extensions/drm-copilot/test/lib/validate/orchestrator-state-routing.promotion-type.test.ts`.
  - The file mirrors the four PR #402 Python tests in `tests/scripts/dev_tools/test_validate_orchestrator_state_routing_contract.py` (lines 279, 298, 317, 333) and must not extend the stale matrix in `extensions/drm-copilot/test/lib/validate/orchestrator-state-routing.test.ts`. It loads the real `config/orchestration-routing.json` from `__dirname` (five levels up) and builds a completion-safe `large` checkpoint from the real `routes.large` lists, in the shape of the Python builders `_build_complete_large_state` (line 23) and `_build_complete_large_bug_state` (line 105). Four `it` blocks, named exactly: `accepts a bug-type large-route checkpoint that declares and records new_potential_bug_entry`; `accepts a feature-type large-route checkpoint that declares and records new_potential_entry`; `excludes the removed dead skill names from the real large-route required_skills`; `rejects a bug-type large-route checkpoint that declares and records only new_potential_entry`. The first expects `[]`; the second expects `[]`; the third asserts neither `orchestrator-workflow` nor `repo-automation-adapter` is in the real `routes.large.required_skills`; the fourth asserts the errors contain `Checkpoint required_mcp_tools must match routing matrix for route large.` and `Checkpoint missing successful MCP receipt: new_potential_bug_entry.`, and do not contain `Checkpoint missing successful MCP receipt: new_potential_entry.`. No temporary file; under 500 lines.
  - Acceptance: the file exists at that path and its line count, recorded in the P2-T4 artifact, is below 500.

- [ ] [P2-T4] [expect-fail] Run `extensions/drm-copilot/test/lib/validate/orchestrator-state-routing.promotion-type.test.ts` and confirm it fails on exactly the two bug-type tests.
  - Run `npm run test:unit -- test/lib/validate/orchestrator-state-routing.promotion-type.test.ts`.
  - Acceptance: `docs/features/active/2026-09-29-ts-validator-promotion-type-parity-gap-405/evidence/regression-testing/ts-routing-contract-expect-fail.TIMESTAMP.md` records `Timestamp:`, `Command:`, `EXIT_CODE:` 1, `ExpectedExitCode: 1`, and an `Output Summary:` carrying the `Tests:` line, which must read `2 failed, 2 passed, 4 total`, and the names of the two failures (the bug-type acceptance test and the bug-type rejection test). The feature-type test and the dead-skill-name test pass before the fix, which is the intended no-regression baseline.

### Phase 3 — Minimal Fix, Unit Tests, and Coverage Gate

- [ ] [P3-T1] Create the pure resolver module `extensions/drm-copilot/src/lib/validate/orchestrator-state-promotion-tools.ts`.
  - The module has no `import` statement, no I/O, no clock, and no randomness, and its comments do not contain the substrings `orchestrator-state-routing`, `node:`, or `import {` (P4-T2 searches for them). It exports the four constants `FEATURE_PROMOTION_ENTRY_TOOL` (`"new_potential_entry"`), `BUG_PROMOTION_ENTRY_TOOL` (`"new_potential_bug_entry"`), `BUG_PROMOTION_TYPE` (`"bug"`), and `PROMOTION_TYPE_KEY` (`"promotion-type"`), and the function `resolvePromotionEntryTools(requiredMcpTools: string[], state: Record<string, unknown>): string[]`. Semantics mirror `scripts/dev_tools/_orchestrator_state_routing.py` lines 393-406: substitution only when `state[PROMOTION_TYPE_KEY] === BUG_PROMOTION_TYPE` (strict equality, no trim, no case folding, no coercion, only the hyphenated key); every other value, including absent, `null`, and non-string, returns a new array with the same elements; each element strictly equal to the feature tool becomes the bug tool with order and all other elements preserved; the input array and state are never mutated. The resolver is a separate module so issue #509 can extend it without editing `orchestrator-state-routing.ts`. TSDoc on every export.
  - Acceptance: the file exists at that path, `npm run typecheck` is not run here (the tests that consume the module arrive in P3-T4), and the file's line count, recorded in the P3-T3 artifact, is below 500.

- [ ] [P3-T2] Wire the resolver into `validateRoutingContract` in `extensions/drm-copilot/src/lib/validate/orchestrator-state-routing.ts` at the single defect site.
  - Add one import of `resolvePromotionEntryTools` from `./orchestrator-state-promotion-tools` after the existing imports at lines 1-2. Replace line 408, `const requiredMcpTools = routeList(rawRoute, "required_mcp_tools");`, with a call that passes `routeList(rawRoute, "required_mcp_tools")` and `state` to `resolvePromotionEntryTools`. The one resolved variable then feeds both the `stateList(state, "required_mcp_tools", requiredMcpTools)` equality check at line 420 and the `for (const tool of requiredMcpTools)` receipt loop at line 441, which stay textually unchanged. No other line of the file changes.
  - Acceptance: `git diff origin/main -- extensions/drm-copilot/src/lib/validate/orchestrator-state-routing.ts` shows one added import line and the replaced declaration (its added lines may wrap across several lines after Prettier) and no other changed line, recorded in the P3-T3 artifact together with `git status --porcelain` showing the new module as an untracked path and the routing file as modified.

- [ ] [P3-T3] Re-run both Phase 2 regression files under `extensions/drm-copilot/test/lib/validate/` after the fix and record the pass-after result.
  - Run `npm run test:unit -- test/lib/validate/orchestrator-state-promotion-type-parity.test.ts test/lib/validate/orchestrator-state-routing.promotion-type.test.ts`.
  - Acceptance: `docs/features/active/2026-09-29-ts-validator-promotion-type-parity-gap-405/evidence/regression-testing/ts-regression-pass-after.TIMESTAMP.md` records `Timestamp:`, `Command:`, `EXIT_CODE:` 0, and an `Output Summary:` carrying `Test Suites: 2 passed, 2 total` and `Tests: 19 passed, 19 total` (fifteen corpus tests plus four routing-contract tests), the four case names that failed in P2-T2 now passing, the P3-T1 module line count, and the P3-T2 diff and porcelain observation.

- [ ] [P3-T4] Create the resolver unit tests `extensions/drm-copilot/test/lib/validate/orchestrator-state-promotion-tools.test.ts`.
  - The file mirrors the module under `src/lib/validate/`, imports the four constants and `resolvePromotionEntryTools`, and covers: bug substitution of the feature tool; order and every other tool preserved (the real small-route list as the input); every occurrence substituted when the feature tool appears twice; `"feature"`, an absent key, `null`, and the string values `"Bug"`, `"BUG"`, `" bug"`, `"bug "`, and `""` each return an equal list; the non-string values `true`, `1`, `["bug"]`, and `{}` each return an equal list; the underscore key `promotion_type` set to `"bug"` leaves the list unchanged; a list containing no feature tool is unchanged under `"bug"`; an empty list stays empty; a tool spelled `New_Potential_Entry` is not substituted; the returned array is a different reference from the input and the input, frozen with `Object.freeze`, is not mutated. The T2 property-density obligation is met by one deterministic fixed-grid invariant test that iterates a literal grid of promotion-type values and tool lists and asserts, for every pair, equal length, no feature tool in the output when the type is `"bug"`, output equal to input otherwise, and idempotence. It uses no random source, so a failure is reproducible without a seed. No temporary file; under 500 lines.
  - Acceptance: the file exists at that path and its line count, recorded in the P3-T5 artifact, is below 500.

- [ ] [P3-T5] Run the resolver unit tests in `extensions/drm-copilot/test/lib/validate/orchestrator-state-promotion-tools.test.ts`.
  - Run `npm run test:unit -- test/lib/validate/orchestrator-state-promotion-tools.test.ts`.
  - Acceptance: `docs/features/active/2026-09-29-ts-validator-promotion-type-parity-gap-405/evidence/regression-testing/ts-resolver-unit-tests.TIMESTAMP.md` records `Timestamp:`, `Command:`, `EXIT_CODE:` 0, and an `Output Summary:` carrying the `Tests:` line with zero failed, the integer passed count recorded as the labelled integer `RESOLVER_PASSED` (P4-T1 consumes it), and the file line count from P3-T4.

- [ ] [P3-T6] Add the per-file coverage threshold entry to `extensions/drm-copilot/jest.config.cjs`.
  - Insert an entry keyed `"./src/lib/validate/orchestrator-state-promotion-tools.ts"` with `lines: 85` and `branches: 75`, in the style of the neighbouring entry `"./src/lib/validate/orchestrator-state-core.ts"` at lines 73-76, with a comment stating the map carries no `global` key so a new production file without its own entry would be ungated. Add no other entry, and add no `exclude` or path-ignore entry for any file under `src/`.
  - Acceptance: the P3-T7 artifact shows the entry.

- [ ] [P3-T7] Verify the threshold entry in `extensions/drm-copilot/jest.config.cjs` reads 85 and 75.
  - Run `git grep -n -F -A2 -e "orchestrator-state-promotion-tools.ts" -- extensions/drm-copilot/jest.config.cjs`. The file is tracked, so `git grep` searches its working-tree text.
  - Acceptance: `docs/features/active/2026-09-29-ts-validator-promotion-type-parity-gap-405/evidence/qa-gates/jest-threshold-entry.TIMESTAMP.md` records `Timestamp:`, `Command:`, `EXIT_CODE:` 0, and an `Output Summary:` quoting the output verbatim, which is three lines: the key line, a `lines: 85,` line, and a `branches: 75,` line. Exit code 1 with empty output means the entry is absent and fails this task. Enforcement of the threshold itself happens in P5-T4, where the full coverage run must exit 0.

### Phase 4 — Post-Fix Verification

- [ ] [P4-T1] Re-run the whole `extensions/drm-copilot/test/lib/validate/` directory and confirm existing behavior is unchanged.
  - Run `npm run test:unit -- test/lib/validate`.
  - Acceptance: `docs/features/active/2026-09-29-ts-validator-promotion-type-parity-gap-405/evidence/regression-testing/ts-validate-dir-pass-after.TIMESTAMP.md` records `Timestamp:`, `Command:`, `EXIT_CODE:` 0, and an `Output Summary:` carrying zero failed tests and the passed count, which must equal `BASELINE_DIR_PASSED` (P0-T9) plus 15 plus 4 plus `RESOLVER_PASSED` (P3-T5), with the arithmetic shown. Because every pre-existing test in that directory, including `orchestrator-state-routing.test.ts`, `orchestrator-state-core.completion.test.ts`, and `orchestrator-state-preparation-route.test.ts`, is inside the directory and none is edited, equality of the derived and observed counts shows every existing checkpoint validates as before.

- [ ] [P4-T2] Verify the new module is pure and self-contained at `extensions/drm-copilot/src/lib/validate/orchestrator-state-promotion-tools.ts`.
  - The module is untracked at this point, so use `--no-index`. Run `git grep --no-index -c -F -e "BUG_PROMOTION_ENTRY_TOOL" -- extensions/drm-copilot/src/lib/validate/orchestrator-state-promotion-tools.ts`, then `git grep --no-index -c -F -e "orchestrator-state-routing" -- extensions/drm-copilot/src/lib/validate/orchestrator-state-promotion-tools.ts`, then `git grep --no-index -c -F -e "node:" -- extensions/drm-copilot/src/lib/validate/orchestrator-state-promotion-tools.ts`, then `git grep --no-index -c -F -e "import {" -- extensions/drm-copilot/src/lib/validate/orchestrator-state-promotion-tools.ts`.
  - Acceptance: `docs/features/active/2026-09-29-ts-validator-promotion-type-parity-gap-405/evidence/regression-testing/ts-module-purity.TIMESTAMP.md` records all four commands with `Timestamp:`, `Command:`, `EXIT_CODE:`, and `Output Summary:`. The first command exits 0 and prints a count of at least 1, which proves the path resolves so the three absence checks cannot pass vacuously. The other three exit 1 with empty output, which proves the module imports nothing and does not reference the routing module.

- [ ] [P4-T3] Verify `validateRoutingContract` resolves once in `extensions/drm-copilot/src/lib/validate/orchestrator-state-routing.ts`.
  - Run `git grep -c -F -e "resolvePromotionEntryTools(" -- extensions/drm-copilot/src/lib/validate/orchestrator-state-routing.ts`, then `git grep -c -F -e "./orchestrator-state-promotion-tools" -- extensions/drm-copilot/src/lib/validate/orchestrator-state-routing.ts`.
  - Acceptance: `docs/features/active/2026-09-29-ts-validator-promotion-type-parity-gap-405/evidence/regression-testing/ts-single-resolution.TIMESTAMP.md` records both commands with `Timestamp:`, `Command:`, `EXIT_CODE:`, and `Output Summary:`. Each prints the file path followed by `:1`: one line contains the call, so the resolved list is computed once, and one line carries the import. Behavioral proof that the one resolved value feeds both the equality check and the receipt loop is the `rejects a bug-type large-route checkpoint that declares and records only new_potential_entry` test in P3-T3, which asserts both errors.

- [ ] [P4-T4] Prove no file under `.claude/lib/`, `extensions/drm-copilot/resources/`, `scripts/dev_tools/`, `.claude/hooks/`, or `config/` changed and the bundled mirror is still byte-identical.
  - Run `git diff --name-only origin/main -- .claude/lib extensions/drm-copilot/resources scripts/dev_tools .claude/hooks config`, then `git status --porcelain -- .claude/lib extensions/drm-copilot/resources scripts/dev_tools .claude/hooks config`, then repeat the P0-T5 `Get-FileHash` command.
  - Acceptance: `docs/features/active/2026-09-29-ts-validator-promotion-type-parity-gap-405/evidence/regression-testing/bundle-and-authority-unchanged.TIMESTAMP.md` records `Timestamp:`, `Command:`, `EXIT_CODE:`, and an `Output Summary:` in which the anchored diff listing is empty, the porcelain listing is empty (it lists untracked paths the diff cannot see), and the two SHA-256 hashes are equal and equal to the P0-T5 hashes. This is the evidence that no bundle change is needed.

### Phase 5 — Final QA Loop, Scope Verification, AC Tracking, and Handoff

The three language loops run in the order format, lint, type-check, test. If any step exits non-zero, or its before-and-after `git status --porcelain` observation shows a rewritten file, fix the cause and restart that language's loop from its format task, then continue until one uninterrupted pass completes with every step clean. Record the pass that finally completed clean; the loop-cleanliness statement in each format artifact names it.

- [ ] [P5-T1] Run the TypeScript formatter in `extensions/drm-copilot` with a before-and-after tree observation.
  - Run `git status --porcelain`, then `npm run format`, then `git status --porcelain` again.
  - Acceptance: `docs/features/active/2026-09-29-ts-validator-promotion-type-parity-gap-405/evidence/qa-gates/ts-format.TIMESTAMP.md` records `Timestamp:`, `Command:`, `EXIT_CODE:` 0, and an `Output Summary:` carrying both porcelain listings verbatim. On the clean pass the two listings are identical and every printed Prettier file line ends in `(unchanged)`. A pass whose listings differ rewrote a scope file: keep the rewrite, record it, and restart the loop, so the recorded final pass is the one with identical listings.

- [ ] [P5-T2] Run the TypeScript linter at `docs/features/active/2026-09-29-ts-validator-promotion-type-parity-gap-405/evidence/qa-gates/ts-lint.TIMESTAMP.md`.
  - Run `npm run lint`.
  - Acceptance: the artifact records `Timestamp:`, `Command:`, `EXIT_CODE:` 0, and an `Output Summary:` recording empty output as the counts 0 errors and 0 warnings, or the verbatim output when non-empty. The count must be zero.

- [ ] [P5-T3] Run the TypeScript type check at `docs/features/active/2026-09-29-ts-validator-promotion-type-parity-gap-405/evidence/qa-gates/ts-typecheck.TIMESTAMP.md`.
  - Run `npm run typecheck`.
  - Acceptance: the artifact records `Timestamp:`, `Command:`, `EXIT_CODE:` 0, and an `Output Summary:` recording empty output as the diagnostic count 0, or the verbatim output when non-empty. The count must be zero.

- [ ] [P5-T4] Run the full TypeScript test suite in coverage mode at `docs/features/active/2026-09-29-ts-validator-promotion-type-parity-gap-405/evidence/qa-gates/ts-coverage.TIMESTAMP.md`.
  - Run `npm run test:coverage -- --coverageReporters=text`.
  - Acceptance: the artifact records `Timestamp:`, `Command:`, `EXIT_CODE:` 0 (a zero exit also means every per-file threshold in `extensions/drm-copilot/jest.config.cjs`, including the new `orchestrator-state-promotion-tools.ts` entry at 85 lines and 75 branches, passed), and an `Output Summary:` carrying the passed, failed, and total test counts, the numeric overall statement, branch, function, and line percentages from the `text-summary` block, and the numeric `% Stmts`, `% Branch`, `% Funcs`, and `% Lines` cells of the table rows for `orchestrator-state-promotion-tools.ts` and `orchestrator-state-routing.ts`. Placeholder values are not acceptable.

- [ ] [P5-T5] Run the Python formatter with a before-and-after tree observation at `docs/features/active/2026-09-29-ts-validator-promotion-type-parity-gap-405/evidence/qa-gates/py-black.TIMESTAMP.md`.
  - Run `git status --porcelain`, then `poetry run black .`, then `git status --porcelain` again.
  - Acceptance: the artifact records `Timestamp:`, `Command:`, `EXIT_CODE:` 0, and an `Output Summary:` carrying both porcelain listings verbatim, the integer count reformatted, and the integer count left unchanged. On the clean pass the listings are identical and the reformatted count is 0. A differing pass restarts the Python loop.

- [ ] [P5-T6] Run the Python linter at `docs/features/active/2026-09-29-ts-validator-promotion-type-parity-gap-405/evidence/qa-gates/py-ruff.TIMESTAMP.md`.
  - Run `poetry run ruff check .`.
  - Acceptance: the artifact records `Timestamp:`, `Command:`, `EXIT_CODE:` 0, and an `Output Summary:` recording verbatim the final line `All checks passed!`. Ruff here does not rewrite files, so no fixed-file count is recorded.

- [ ] [P5-T7] Run the Python type check at `docs/features/active/2026-09-29-ts-validator-promotion-type-parity-gap-405/evidence/qa-gates/py-pyright.TIMESTAMP.md`.
  - Run `poetry run pyright`.
  - Acceptance: the artifact records `Timestamp:`, `Command:`, `EXIT_CODE:` 0, and an `Output Summary:` carrying the integer error, warning, and information counts, with errors 0.

- [ ] [P5-T8] Run the targeted Python coverage command for the routing module and the new parity test at `docs/features/active/2026-09-29-ts-validator-promotion-type-parity-gap-405/evidence/qa-gates/py-routing-coverage.TIMESTAMP.md`.
  - Run `poetry run pytest tests/scripts/dev_tools/test_validate_orchestrator_state_routing_contract.py tests/scripts/dev_tools/test_orchestrator_state_promotion_type_parity.py --cov=scripts.dev_tools._orchestrator_state_routing --cov-branch --cov-report=term-missing --cov-report=json:artifacts/python/cov-p5-t8.json`.
  - Acceptance: the artifact records `Timestamp:`, `Command:`, `EXIT_CODE:` 0, and an `Output Summary:` carrying the passed count, which must equal the P0-T15 passed count plus 15, and for `scripts/dev_tools/_orchestrator_state_routing.py` the `percent_statements_covered` and `percent_branches_covered` values from that file's `summary` object in `artifacts/python/cov-p5-t8.json` to one decimal place, plus the raw `Stmts`, `Miss`, `Branch`, and `BrPart` cells verbatim.

- [ ] [P5-T9] Run the full Python suite in coverage mode at `docs/features/active/2026-09-29-ts-validator-promotion-type-parity-gap-405/evidence/qa-gates/py-pytest-coverage.TIMESTAMP.md`.
  - Run `poetry run pytest --cov=scripts.dev_tools --cov-branch --cov-report=term-missing --cov-report=json:artifacts/python/cov-p5-t9.json`.
  - Acceptance: the artifact records `Timestamp:`, `Command:`, `EXIT_CODE:`, and an `Output Summary:` carrying the passed and failed counts, the node ID of every failed test, and the `percent_statements_covered` and `percent_branches_covered` values from the `totals` object of `artifacts/python/cov-p5-t9.json` to one decimal place. The task passes when the failed-node-ID set equals the P0-T14 failed-node-ID set exactly (empty when the baseline was green, in which case the exit code is 0) and the passed count equals the P0-T14 passed count plus 15. A failure outside the baseline set is a real failure.

- [ ] [P5-T10] Run the PowerShell formatter with a before-and-after tree observation at `docs/features/active/2026-09-29-ts-validator-promotion-type-parity-gap-405/evidence/qa-gates/ps-format.TIMESTAMP.md`.
  - Run `git status --porcelain`, then `pwsh -NoLogo -NoProfile -ExecutionPolicy Bypass -Command "& { Import-Module 'scripts/powershell/PoshQC'; Invoke-PoshQCFormat -Root (Get-Location).Path }"`, then `git status --porcelain` again.
  - Acceptance: the artifact records `Timestamp:`, `Command:`, `EXIT_CODE:` 0, and an `Output Summary:` carrying both porcelain listings verbatim and the list of files rewritten. On the clean pass the listings are identical. A differing pass keeps the rewrite and restarts the PowerShell loop.

- [ ] [P5-T11] Run the PowerShell analyzer at `docs/features/active/2026-09-29-ts-validator-promotion-type-parity-gap-405/evidence/qa-gates/ps-analyze.TIMESTAMP.md`.
  - Run `pwsh -NoLogo -NoProfile -ExecutionPolicy Bypass -Command "& { Import-Module 'scripts/powershell/PoshQC'; Invoke-PoshQCAnalyze -Root (Get-Location).Path }"`.
  - Acceptance: the artifact records `Timestamp:`, `Command:`, `EXIT_CODE:` 0, and an `Output Summary:` quoting the run output verbatim and the integer error, warning, and information counts, all 0 for `tests/scripts/claude-lib/orchestrator-state/OrchestratorStatePromotionType.Parity.Tests.ps1`.

- [ ] [P5-T12] Run the targeted Pester run for the new corpus reader at `docs/features/active/2026-09-29-ts-validator-promotion-type-parity-gap-405/evidence/qa-gates/ps-parity-pass.TIMESTAMP.md`.
  - Run `pwsh -NoLogo -NoProfile -Command '$r = Invoke-Pester -Path tests/scripts/claude-lib/orchestrator-state/OrchestratorStatePromotionType.Parity.Tests.ps1 -Output Detailed -PassThru; exit $r.FailedCount'`.
  - Acceptance: the artifact records `Timestamp:`, `Command:`, `EXIT_CODE:` 0, and an `Output Summary:` carrying `Tests Passed: 15, Failed: 0`.

- [ ] [P5-T13] Run the full Pester suite in coverage mode at `docs/features/active/2026-09-29-ts-validator-promotion-type-parity-gap-405/evidence/qa-gates/ps-test-coverage.TIMESTAMP.md`.
  - Run `pwsh -NoLogo -NoProfile -ExecutionPolicy Bypass -Command "& { Import-Module 'scripts/powershell/PoshQC'; Invoke-PoshQCTest -Root (Get-Location).Path }"`.
  - Acceptance: the artifact records `Timestamp:`, `Command:`, `EXIT_CODE:`, and an `Output Summary:` carrying the integer passed, failed, and total counts from `artifacts/pester/pester-junit.xml`, the name of every failed test, and the integer `missed` and `covered` values of the `LINE` counter for `OrchestratorStateRoutingContract.psm1` and for the report as a whole from `artifacts/pester/powershell-coverage.xml`, with derived percentages and arithmetic. The task passes when the failed-test-name set equals the P0-T18 set exactly and the passed count equals the P0-T18 passed count plus 15. There is no PowerShell branch-coverage gate.

- [ ] [P5-T14] Record the TypeScript coverage comparison at `docs/features/active/2026-09-29-ts-validator-promotion-type-parity-gap-405/evidence/qa-gates/ts-coverage-delta.TIMESTAMP.md`.
  - Compare the P0-T10 and P5-T4 artifacts; no command runs.
  - Acceptance: the artifact records `Timestamp:` and `Output Summary:` carrying, for each metric, the baseline value, the post-change value, and the difference: overall statement, branch, function, and line percentages, and the `orchestrator-state-routing.ts` row cells. The task passes when every post-change overall and routing-row value is greater than or equal to its baseline, and the `orchestrator-state-promotion-tools.ts` row shows `% Lines` at or above 85 and `% Branch` at or above 75. The new-code figures are those two row cells.

- [ ] [P5-T15] Record the Python coverage comparison at `docs/features/active/2026-09-29-ts-validator-promotion-type-parity-gap-405/evidence/qa-gates/py-coverage-delta.TIMESTAMP.md`.
  - Compare P0-T14 with P5-T9 and P0-T15 with P5-T8; no command runs.
  - Acceptance: the artifact records `Timestamp:` and `Output Summary:` carrying baseline, post-change, and difference for the repository-wide `percent_statements_covered` and `percent_branches_covered` and for the same two values on `scripts/dev_tools/_orchestrator_state_routing.py`. The task passes when every post-change value is greater than or equal to its baseline. Production Python is unchanged, so the new-code figure is stated as none.

- [ ] [P5-T16] Record the PowerShell coverage comparison at `docs/features/active/2026-09-29-ts-validator-promotion-type-parity-gap-405/evidence/qa-gates/ps-coverage-delta.TIMESTAMP.md`.
  - Compare P0-T18 with P5-T13; no command runs.
  - Acceptance: the artifact records `Timestamp:` and `Output Summary:` carrying baseline, post-change, and difference for the `LINE` percentage of the report as a whole and of `OrchestratorStateRoutingContract.psm1`. The task passes when both post-change values are greater than or equal to their baselines. Production PowerShell is unchanged, so the new-code figure is stated as none, and no branch figure exists for Pester.

- [ ] [P5-T17] Verify the 500-line limit for every file this diff adds or edits, in `docs/features/active/2026-09-29-ts-validator-promotion-type-parity-gap-405/evidence/qa-gates/file-size-gate.TIMESTAMP.md`.
  - Run `pwsh -NoProfile -Command "foreach ($p in 'extensions/drm-copilot/src/lib/validate/orchestrator-state-promotion-tools.ts','extensions/drm-copilot/src/lib/validate/orchestrator-state-routing.ts','extensions/drm-copilot/jest.config.cjs','extensions/drm-copilot/test/lib/validate/orchestrator-state-promotion-tools.test.ts','extensions/drm-copilot/test/lib/validate/orchestrator-state-routing.promotion-type.test.ts','extensions/drm-copilot/test/lib/validate/orchestrator-state-promotion-type-parity.test.ts','tests/scripts/dev_tools/test_orchestrator_state_promotion_type_parity.py','tests/scripts/claude-lib/orchestrator-state/OrchestratorStatePromotionType.Parity.Tests.ps1') { [pscustomobject]@{ Path = $p; Lines = (Get-Content -LiteralPath $p).Count } }"`.
  - Acceptance: the artifact records `Timestamp:`, `Command:`, `EXIT_CODE:` 0, and an `Output Summary:` listing each path with its integer line count. Every count is below 500, and the count for `orchestrator-state-routing.ts` is stated next to its P0-T4 baseline, with the increase (expected to be a few lines, one import plus a wrapped declaration). The twelve fixture files are JSON data and are not counted.

- [ ] [P5-T18] Prove the final diff stays inside the scope enumeration at `docs/features/active/2026-09-29-ts-validator-promotion-type-parity-gap-405/evidence/qa-gates/diff-scope.TIMESTAMP.md`.
  - Run `git diff --name-only origin/main`, then `git status --porcelain`. The porcelain listing supplies the untracked new files the anchored diff cannot enumerate.
  - Acceptance: the artifact records both commands with `Timestamp:`, `Command:`, `EXIT_CODE:`, and `Output Summary:`. The union of the two listings contains only paths from the "Scope of the diff" enumeration; none of `.claude/hooks/enforce-powershell-batch-budget.ps1`, any file under `.claude/lib/`, any file under `extensions/drm-copilot/resources/`, `scripts/dev_tools/_orchestrator_state_routing.py`, or `config/orchestration-routing.json` appears; and the artifact lists the twelve fixture paths and the new test and module paths found as untracked.

- [ ] [P5-T19] Check off the spec acceptance criteria in `docs/features/active/2026-09-29-ts-validator-promotion-type-parity-gap-405/spec.md` per `.claude/skills/acceptance-criteria-tracking/SKILL.md`.
  - Change `- [ ]` to `- [x]` only for a criterion whose evidence artifact from this plan exists on disk and satisfies it: criterion 1 (P3-T3); 2 (P3-T3); 3 (P1-T14, P1-T16, P3-T3); 4 (P3-T1, P3-T5); 5 (P3-T2, P4-T3); 6 (P3-T5); 7 (P1-T1 through P1-T12); 8 (P1-T14); 9 (P3-T3); 10 (P1-T16); 11 (P2-T1, P2-T3); 12 (P3-T6, P3-T7, P5-T4); 13 (P4-T1); 14 (P5-T17); 15 (P4-T4, P5-T18); 16 (P5-T1 through P5-T16). Do not edit any other text of `spec.md` in this task.
  - Run `git grep --no-index -c -F -e "- [x]" -- docs/features/active/2026-09-29-ts-validator-promotion-type-parity-gap-405/spec.md` and `git grep --no-index -c -F -e "- [ ]" -- docs/features/active/2026-09-29-ts-validator-promotion-type-parity-gap-405/spec.md`.
  - Acceptance: `docs/features/active/2026-09-29-ts-validator-promotion-type-parity-gap-405/evidence/other/spec-ac-checkoff.TIMESTAMP.md` records both commands with `Timestamp:`, `Command:`, `EXIT_CODE:`, and `Output Summary:`. The first prints the spec path followed by `:16`; the second exits 1 with empty output, so no unchecked criterion remains. The artifact also lists each criterion number with the evidence artifact that backs it.

- [ ] [P5-T20] Check off the issue acceptance criteria in `docs/features/active/2026-09-29-ts-validator-promotion-type-parity-gap-405/issue.md` per `.claude/skills/acceptance-criteria-tracking/SKILL.md`.
  - Change `- [ ]` to `- [x]` only for a criterion backed by an on-disk artifact: issue criterion 1 (resolver in the routing validator; P3-T1, P3-T2, P4-T3); 2 (bug-type large-route pass; P3-T3); 3 (feature-type large-route no regression; P3-T3, P4-T1); 4 (new TypeScript tests for both cases plus dead-skill and bug-with-only-feature-tool rejection; P2-T3, P3-T3); 5 (full toolchain with no coverage regression; P5-T1 through P5-T16). Do not edit any other text of `issue.md` in this task.
  - Run `git grep --no-index -c -F -e "- [x]" -- docs/features/active/2026-09-29-ts-validator-promotion-type-parity-gap-405/issue.md` and `git grep --no-index -c -F -e "- [ ]" -- docs/features/active/2026-09-29-ts-validator-promotion-type-parity-gap-405/issue.md`.
  - Acceptance: `docs/features/active/2026-09-29-ts-validator-promotion-type-parity-gap-405/evidence/other/issue-ac-checkoff.TIMESTAMP.md` records both commands with `Timestamp:`, `Command:`, `EXIT_CODE:`, and `Output Summary:`. The first prints the issue path followed by `:5`; the second exits 1 with empty output.

- [ ] [P5-T21] Record handoff notes at `docs/features/active/2026-09-29-ts-validator-promotion-type-parity-gap-405/evidence/other/handoff-notes.TIMESTAMP.md`.
  - This task authors notes only; it does not author a pull request, run CI monitoring, or contact GitHub. Record: the summary of the fix (new resolver module, one wired call, per-file jest threshold); the validation performed with a link to each `qa-gates` and `regression-testing` artifact; the parity corpus location and the three readers; the statement that no PowerShell, Python, bundle, or hook file changed; the follow-ups issue #509 (extend `resolvePromotionEntryTools` for pre-existing-issue evidence) and issue #343 (`pr_gate`/`ci_gate` parity), both untouched; and the open item that the text of issue #405 was read from `issue.md` only and the five issue criteria should be reconfirmed against the GitHub issue body when `gh` is available.
  - Acceptance: the file exists at that path and carries `Timestamp:`, the fix summary, the validation list with artifact links, and the follow-up list naming #509 and #343.
