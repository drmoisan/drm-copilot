# parallel-only-test-gates-and-leak-scan - Remediation Plan

- **Issue:** #1094
- **Parent (optional):** none
- **Owner:** drmoisan
- **Status:** Draft
- **Work Mode:** full-feature
- **Remediation-Mode:** design
- **Branch:** feature/parallel-only-test-gates-and-leak-scan-1094
- **Inputs:** `remediation-inputs.2026-11-07T03-22.md` in this folder (RF-1 to RF-4)

## Required References

- Policy order: `policy-compliance-order`. PowerShell and TypeScript are the changed languages in this cycle. `.claude/rules/python.md` applies to the Python gate.
- Requirements: `spec.md`, and the `policy-audit`, `code-review`, and `feature-audit` artifacts stamped `2026-11-07T03-22` in this folder.
- Tool routes, launchers, command-text restrictions, and CI shape are owned by the `execution-environment` skill and are not restated.

## Execution Rules

Terms: `<FEATURE>` is `docs/features/active/2026-11-06-parallel-only-test-gates-and-leak-scan-1094`. `SCRATCH` resolves to `<session scratchpad>/issue-1094/`, and every helper, JUnit file, JSON report, and log lives under it. Evidence records the token, never a host path. The merge base is the merge base of `origin/main` and `HEAD`. The debugging statement is the sentence `A focused run of one test file to debug a specific failure is debugging only.`

- **Working directory.** Every `npm`, `npx`, `poetry`, and `git` command, and every PoshQC call, runs from the item worktree root or the subfolder its task names. A launcher changes into that folder before its first command, because the Bash working directory resets to the main checkout. Run from the main checkout, `npm ci` replaces that checkout's `node_modules` and the generator writes that checkout's files.
- **Commit and push.** Each task ends with one commit and one push to `feature/parallel-only-test-gates-and-leak-scan-1094`. The executor stages only the paths the task names, plus the evidence it writes. `.claude/agent-memory` is never staged.
- **`testResults.xml`.** Pester runs rewrite this tracked file. Restore it with `git checkout -- testResults.xml` before staging.
- **Poetry.** Do not run an unqualified `poetry install` from the item worktree.
- **New code.** Helpers are PowerShell step scripts under `SCRATCH`. No new Python file is written.
- **Parallel gates only (owner directive).** The gates are one `Invoke-PoshQCParallelTest` run, one `pytest -n auto` run, and one Jest run through its normal workers. A suite is re-run only after a fix. No task performs a run of any other form.
- **Test proof.** A task that adds or changes a test is accepted on the named test's presence and content. Phase 2 proves the pass result.
- **Gate failures.** A failure is fixed and the failed gate is re-run. No condition waives a failure, except that the coverage stop in P2-T5 and P2-T6 ends the run.
- **Text mirrors.** A task edits every copy it names, so bundle copies equal their source when the task ends.
- **Evidence.** Every command-step artifact carries `Timestamp:`, `Command:`, `EXIT_CODE:`, and `Output Summary:`, and `EXIT_CODE:` goes non-zero when the task's asserted value fails. Evidence prose does not use the tokens P2-T7 scans for.
- **Scope.** Do not edit `.claude/rules/`, `.github/instructions/`, their bundle copies, `.agents/skills/powershell/`, `.agents/skills/python/`, the other policy mirrors `.agents/skills/csharp/`, `.agents/skills/typescript/`, `.agents/skills/quality-tiers/`, and `.agents/skills/general-unit-test/`, `.claude/agents/epic-orchestrator.md`, `.claude/skills/epic-orchestrate/SKILL.md`, `scripts/dev_tools/validate_policy_audit_artifact.py`, `extensions/drm-copilot/src/lib/validate/policy-audit-artifact.ts`, `.github/workflows/`, `scripts/powershell/PoshQC/`, `.vscode/tasks.json`, `pyproject.toml`, or the Python tools in spec `### 2. Out of scope`. Do not remove a tool-permission entry. Do not add a leak scan. This plan contains no PR, CI-monitoring, or merge task.

## Implementation Plan (Atomic Tasks)

### Phase 0 — Policy Reading and Static Baseline

No test suite runs in this phase.

- [x] [P0-T1] Read the policy files in the `policy-compliance-order` order, including `.claude/rules/powershell.md`, `.claude/rules/typescript.md`, and `.claude/rules/python.md`, then the inputs and the three audit artifacts, and write `<FEATURE>/evidence/remediation-baseline/phase0-instructions-read.<timestamp>.md`.
  - Acceptance: the artifact carries `Timestamp:`, `Policy Order:`, and the list of files read.
- [x] [P0-T2] Capture the PowerShell static baseline for `tests/scripts/claude-runtime` in `<FEATURE>/evidence/remediation-baseline/powershell-format.<timestamp>.md` and `<FEATURE>/evidence/remediation-baseline/powershell-analyze.<timestamp>.md`.
  - Format runs check-only through the no-op `-WriteFile` seam on the branch-current module. Analyzer findings come from a direct `Invoke-ScriptAnalyzer` run with `scripts/powershell/PoshQC/settings/pssa.settings.psd1`.
  - Acceptance: `Output Summary:` states the would-format count and the finding count as numbers, and `git status --porcelain` shows no tracked file changed by the step.
- [x] [P0-T3] Install the Node dependencies the item worktree lacks, confirm `node_modules/jest/package.json` and `extensions/drm-copilot/node_modules/jest/package.json`, and write `<FEATURE>/evidence/remediation-baseline/node-dependencies.<timestamp>.md`.
  - Neither `node_modules` folder exists in the item worktree. Install from the lockfiles, as `_root-typescript-tests.yml` and `_drm-copilot-extension-tests.yml` do: `npm ci` and `npm --prefix extensions/drm-copilot ci`, both from the item worktree root under **Working directory**. The step stops before the first `npm` command if the current folder is not the item worktree root. Both targets are gitignored.
  - If the runner denies the install, stop and return to the orchestrator, naming the missing paths.
  - Acceptance: both files exist, and `git status --porcelain` shows no tracked file changed, including either `package-lock.json`.
- [x] [P0-T4] Capture the TypeScript static baseline for `extensions/drm-copilot/test/lib/validate/policy-audit-artifact.test.ts` in `<FEATURE>/evidence/remediation-baseline/typescript-format.<timestamp>.md`, `<FEATURE>/evidence/remediation-baseline/typescript-lint.<timestamp>.md`, and `<FEATURE>/evidence/remediation-baseline/typescript-typecheck.<timestamp>.md`.
  - From `extensions/drm-copilot/`: `npx prettier --check` and `npx eslint` over that one file, and `npm run typecheck`. CI runs no ESLint stage for this folder, so lint is scoped to the file.
  - Acceptance: each artifact records the tool's real exit code and a numeric finding count.

### Phase 1 — Fixes

**Target wording.** A per-batch step keeps its static tools. Test and coverage figures are read from the single gate run, and a touched file meets the thresholds. The debugging statement appears wherever a required targeted test run is removed. Static analyzer deltas and the word `regressions` in each agent's objective heading stay.

- [x] [P1-T1] Fix RF-2 in step 4 `Implement in batches` of `.claude/agents/powershell-typed-engineer.md`, `.claude/agents/python-typed-engineer.md`, `.claude/agents/csharp-typed-engineer.md`, and `.codex/agents/powershell-typed-engineer.toml`, `.codex/agents/python-typed-engineer.toml`, `.codex/agents/csharp-typed-engineer.toml`, with their mirrors, then run `poetry run python -m scripts.dev_tools.generate_codex_agent_variants` in write mode.
  - Each step keeps its targeted static tool, drops the targeted test run and `confirm per-file coverage`, states that test and coverage results come from the single gate run, and carries the debugging statement.
  - Copy the three `.claude/agents` files to `extensions/drm-copilot/resources/claude-customizations/.claude/agents/`. Edit by hand `.claude-variants/csharp-legacy/agents/csharp-typed-engineer.md` in that bundle and `.codex-variants/csharp-legacy/agents/csharp-typed-engineer.toml` in `codex-and-agents-customizations`; both name MSTest. The generator writes the `-c1` to `-c4` and `-c3-elevated` variants and the Codex bundle copies.
  - No test pins the removed text: searches of `tests/` for the step text returned nothing.
  - Acceptance: the generator's `--check` mode exits 0, each of the eight hand-edited files holds `single gate run` and `debugging only`, and no file under `.codex/agents` or `extensions/drm-copilot/resources` holds `confirm per-file coverage` in a typed-engineer file.
- [x] [P1-T2] Fix RF-1 and RF-2 in the `Implement in small batches` phases of `.github/agents/powershell-typed-engineer.agent.md`, `.github/agents/csharp-typed-engineer.agent.md`, `.github/agents/python-typed-engineer.agent.md`, and `.github/agents/python-execution-only-typed.agent.md`, and copy each to `extensions/drm-copilot/resources/customizations/.github/agents/`.
  - The batch bullet keeps the targeted analyzer, build, Ruff, or Pyright step only. `Confirm coverage does not regress for touched files.` in the first two files becomes the coverage rule. The two Python files drop `targeted Pytest` and `confirm per-file coverage`.
  - `test_copilot_bundle_copies_match_canonical` is the asserting test and stays unchanged. The `COPILOT-PS-TYPED` row still holds, because its token sits outside this passage.
  - Acceptance: each file holds `single gate run` and `debugging only`, none holds `does not regress`, `targeted Pester`, `targeted MSTest`, or `targeted Pytest`, and each equals its bundle copy.
- [x] [P1-T3] Fix RF-1 and RF-2 in `.github/agents/pytest-unit-test-coding.agent.md` and `.github/agents/Powershell DI Unit Test Engineer.agent.md`, and copy each to `extensions/drm-copilot/resources/customizations/.github/agents/`.
  - `pytest-unit-test-coding`: the objective bullet `Coverage does not regress for any file you touch (and overall thresholds remain satisfied)` becomes the coverage rule. `## Phase C` drops `Run targeted tests for the impacted area` and gains the debugging statement.
  - `Powershell DI Unit Test Engineer`: the objective bullet `No decrease in coverage for any file you touch`, which the inputs do not list, becomes the coverage rule. In `## 4) Quality gates (hard stop)`, the failure bullet ends at `Any failure in the single gate run`. `### Iteration runs (required after each batch)` keeps its heading and analyzer bullet, drops `Targeted Pester tests for the impacted area`, and gains the debugging statement.
  - Acceptance: both files hold `debugging only`, neither holds `does not regress`, `No decrease in coverage`, `compared to baseline`, `Targeted Pester`, or `targeted tests`, and each equals its bundle copy.
- [x] [P1-T4] Fix the remaining class instances the sweep found in `.github/agents/tdd-refactor.agent.md`, `.github/agents/5.1-Beast-adjusted.agent.md`, and `.github/agents/gpt-5-beast-mode.agent.md`, and copy each to `extensions/drm-copilot/resources/customizations/.github/agents/`.
  - `tdd-refactor`: `Code coverage maintained or improved` in `## Refactor Phase Checklist` becomes the coverage rule. `running tests frequently` in `## Execution Guidelines` becomes static checks at each step and the single gate run when the refactor is complete.
  - `5.1-Beast-adjusted`: workflow step 8, `Run tests after each change`, becomes static checks after each change and the single gate run when the change is complete, with the debugging statement.
  - `gpt-5-beast-mode`: in `## Workflow (concise)`, `Implement` runs **problems** only after each edit, and `Verify` runs the single gate run and re-runs it only after a fix.
  - Acceptance: each file holds `single gate run`, none holds `maintained or improved`, `running tests frequently`, `Run tests after each`, or `relevant tests using`, and each equals its bundle copy.
- [x] [P1-T5] Add the RF-1 and RF-2 sweep tokens to `$script:SweepToken` in `tests/scripts/claude-runtime/parallel-gate-wording.Tests.ps1`, and update `PGW-SWEEP-HELPER`.
  - The 12 new tokens are `does not regress`, `compared to baseline`, `no decrease in coverage`, `maintained or improved`, `targeted Pester`, `targeted Pytest`, `targeted xUnit`, `targeted MSTest`, `targeted tests`, `run tests after each`, `relevant tests using`, and `running tests frequently`.
  - None matches the debugging statement, `Targeted runs` in the QA-gate skills, `targeted verification evidence`, or a retained policy-audit anchor. At planning time, a search of every sweep root found them only in files P1-T1 to P1-T4 edit and their generated variants.
  - `PGW-SWEEP-HELPER` asserts a count of 33, and its `-Because` text names 33 tokens. `$script:SweepExclusion` is unchanged.
  - Acceptance: the list holds 33 tokens, the count assertion is 33, and the exclusion table is unchanged in a diff against the merge base.
- [x] [P1-T6] Add the two RF-3 cases to `describe("validatePolicyAuditSubstantiveRequirements")` in `extensions/drm-copilot/test/lib/validate/policy-audit-artifact.test.ts`.
  - Add a file constant holding `N/A - no pre-change run`. `extensions/drm-copilot/src/lib/validate/policy-audit-artifact.ts` is not edited.
  - Case `accepts an audit that records no pre-change run`: start from `buildValidPolicyAuditText()`, set both coverage rows' `Baseline Coverage` cells, the `TypeScript baseline coverage artifact:` and `PowerShell baseline coverage artifact:` lines, and both comparison lines' `Baseline:` and `Change:` parts to the no-pre-change form, as `test_validate_policy_audit_text_accepts_no_pre_change_run_record` does, and assert `toEqual([])`.
  - Case `accepts the no-pre-change-run comparison line only through the later Post-change percentage`: `comparisonLineHasLabelledPercentage` is not exported, so the case asserts through the validator on the PowerShell line. Both variants start from the first case's text, so that line's `Baseline:` and `Change:` parts already hold the no-pre-change form and no other percentage follows `Baseline:`. A retained `Change: +2%` would satisfy the pattern and hide the rejection. With the numeric `Post-change:` value, the errors omit `Policy audit comparison line missing numeric baseline for PowerShell.` With `Post-change: N/A.`, the errors contain it. The PowerShell line is required: the TypeScript line carries `New/changed-code coverage: 95%`, which the `Baseline:` pattern would also reach, so that line cannot show the rejection.
  - Acceptance: both named cases exist, and `extensions/drm-copilot/src/lib/validate/policy-audit-artifact.ts` is unchanged in a diff against the merge base.

### Phase 2 — Final QA Toolchain and Self-Review

Static stages run first, so that a suite is not re-run for a formatting change. A fix re-runs the static stages and the gate that failed. Another gate re-runs only when the fix changes a file it exercises. Each pass writes new artifacts.

- [x] [P2-T1] Run format and analyze for `tests/scripts/claude-runtime` on the branch-current `scripts/powershell/PoshQC/PoshQC.psd1` and write `<FEATURE>/evidence/qa-gates/powershell-format.<timestamp>.md` and `<FEATURE>/evidence/qa-gates/powershell-analyze.<timestamp>.md`.
  - Format output carries `Already formatted:` and `Formatted:` lines. A `Formatted:` line means a file changed: commit it and repeat this task.
  - Acceptance: zero `Formatted:` lines, a non-zero `Already formatted:` count, and zero analyzer findings, with `EXIT_CODE:` carrying both.
- [x] [P2-T2] Run the P0-T4 stages for `extensions/drm-copilot/test/lib/validate/policy-audit-artifact.test.ts` and write `<FEATURE>/evidence/qa-gates/typescript-format.<timestamp>.md`, `<FEATURE>/evidence/qa-gates/typescript-lint.<timestamp>.md`, and `<FEATURE>/evidence/qa-gates/typescript-typecheck.<timestamp>.md`.
  - Prettier runs in check mode, and a clean file prints `All matched files use Prettier code style!`. A failure is fixed in the file and this task repeats.
  - Each artifact's step compares its finding count with the P0-T4 value and exits non-zero when the count is higher. `Output Summary:` states both numbers.
  - Acceptance: each `EXIT_CODE:` is 0.
- [ ] [P2-T3] Run Black in check mode, Ruff, and Pyright over `test_discovery_documentation_contracts.py`, `test_execution_environment_brief_contracts.py`, `test_single_pass_preflight_contracts.py`, `test_codex_orchestration_contracts.py`, and `test_validate_policy_audit_artifact.py` under `tests/scripts/dev_tools/`, run `poetry run python -m scripts.dev_tools.generate_codex_agent_variants --check`, and write `<FEATURE>/evidence/qa-gates/python-black.<timestamp>.md`, `<FEATURE>/evidence/qa-gates/python-ruff.<timestamp>.md`, `<FEATURE>/evidence/qa-gates/python-pyright.<timestamp>.md`, and `<FEATURE>/evidence/qa-gates/codex-generator.<timestamp>.md`.
  - These cover the merge commit at the reviewed head, which postdates the earlier artifacts.
  - Acceptance: each `EXIT_CODE:` is 0.
- [ ] [P2-T4] Run the Pester gate with one background `Invoke-PoshQCParallelTest` run and write `<FEATURE>/evidence/qa-gates/pester-parallel.<timestamp>.md`.
  - The launcher exits with `.ExitCode`. Counts come from merged `artifacts/pester/pester-junit.xml`.
  - Acceptance: `EXIT_CODE: 0`, zero failed tests, and the JUnit file holds `PGW-SWEEP-SURFACES` and `PGW-SWEEP-HELPER`, both passed. The artifact lists the `PGW-` count.
- [ ] [P2-T5] Run the Jest gate with one background `npm run test:unit:coverage` run at the repository root, with `--json` and `--outputFile` under `SCRATCH`, and write `<FEATURE>/evidence/qa-gates/jest-coverage.<timestamp>.md`.
  - The root `testMatch` includes `extensions/drm-copilot/test/`, so this run executes the RF-3 cases and writes `coverage/lcov.info`. No `--randomize`, `--runInBand`, or path filter is passed.
  - A PowerShell step script under `SCRATCH` sums `LH`/`LF` and `BRH`/`BRF` from `coverage/lcov.info`, overall and by top-level source root, and reads the record for `extensions/drm-copilot/src/lib/validate/policy-audit-artifact.ts`, after normalizing path separators, because `SF` records use backslashes on Windows. The file's write time must not precede the run start.
  - Acceptance: `EXIT_CODE: 0`, zero failures, both P1-T6 cases passed in the JSON report, and the totals are at or above 85% line and 75% branch. If the totals are below, the step exits non-zero, the artifact lists the per-root figures, and the executor stops and returns to the orchestrator. Nothing is excluded.
- [ ] [P2-T6] Run the pytest gate with one background `poetry run pytest -n auto --cov-branch --cov-report=term-missing --cov` run, with `PYTHONPATH` set for that run to the worktree `packages/discovery-runtime/src`, JSON coverage and JUnit output under `SCRATCH`, and write `<FEATURE>/evidence/qa-gates/pytest-parallel.<timestamp>.md`.
  - The launcher computes the worktree path at run time in the host's native absolute form, sets `PYTHONPATH` for this one command, and records the value as `<worktree>/packages/discovery-runtime/src`.
  - A PowerShell step script under `SCRATCH` reads the JSON `totals`, sums `covered_lines`, `num_statements`, `covered_branches`, and `num_branches` for each root of `[tool.coverage.run] source` after normalizing path separators, and sums `LH`/`LF` and `BRH`/`BRF` from `artifacts/python/lcov.info`, whose write time must not precede the run start.
  - The artifact records JSON totals, lcov totals, and the three per-root rows, whatever the outcome.
  - Acceptance: `EXIT_CODE: 0`, zero failures and errors, and JSON and lcov totals at or above 85% line and 75% branch.
  - Coverage stop: if the totals stay below either threshold, `packages/discovery-runtime/src` still measures 0%, or a test fails only under this import path, then the totals depend on something besides that import path. The step exits non-zero, the artifact lists the per-root figures, and the executor stops and returns to the orchestrator. Nothing is excluded: no `source` or `omit` change, no `# pragma`, and no further run.
- [ ] [P2-T7] Check branch scope and evidence content and write `<FEATURE>/evidence/qa-gates/scope-check.<timestamp>.md`.
  - Scope uses `git diff --name-only` from the merge base, with `git status --porcelain` as its companion. Neither may list a path in `## Execution Rules` under **Scope**. Every `tools:` entry is unchanged in the diff of the agent files against the merge base.
  - Evidence: a case-insensitive scan of `<FEATURE>/evidence/baseline/`, `<FEATURE>/evidence/remediation-baseline/`, `<FEATURE>/evidence/regression-testing/`, and `<FEATURE>/evidence/qa-gates/`, with tokens assembled at run time so the artifact cannot match itself, finds no host path and none of `single-process`, `seeded`, `shuffled`, `reversed-order`, `comparison run`, and `focused run`.
  - Acceptance: `EXIT_CODE: 0`, from a step that exits non-zero on any match.
- [ ] [P2-T8] Walk the policy-audit, code-review, and feature-audit templates under `docs/features/templates/policy_audit/` against the branch diff from the merge base, and write `<FEATURE>/evidence/qa-gates/self-review.<timestamp>.md`.
  - The walk includes this plan's own text under `.claude/rules/tonality.md`, and the owner-report items in `## Open Questions / Notes`.
  - The artifact has one PASS, FAIL, or N/A row per checklist item. A FAIL row is fixed, the QA loop re-runs from P2-T1, and the self-review is rewritten.
  - Acceptance: the artifact holds no FAIL row.

## Acceptance Criteria Traceability

| ID | Finding | Tasks | Proof |
|---|---|---|---|
| RF-1 | Coverage and failure comparisons in Copilot agents; criteria 1 and 8 | P1-T2, P1-T3, P1-T4, P1-T5 | `PGW-SWEEP-SURFACES`, `pester-parallel` |
| RF-2 | Required per-batch targeted runs; criterion 1 | P1-T1 to P1-T5 | `PGW-SWEEP-SURFACES`, `codex-generator`, `pester-parallel` |
| RF-3 | TypeScript validator contract tests; criterion 9 | P1-T6, P2-T5 | The two P1-T6 cases, `jest-coverage` |
| RF-4 | Python coverage artifact | P2-T6 | `pytest-parallel`, `artifacts/python/lcov.info` |
| V-1 | Gates after the fixes | P2-T4, P2-T5, P2-T6 | `pester-parallel`, `jest-coverage`, `pytest-parallel` |
| V-2 | Sweep tokens and count | P1-T5, P2-T4 | `PGW-SWEEP-HELPER` |
| V-3 | Generator check | P1-T1, P2-T3 | `codex-generator` |

## Pre-Mortem

- Review checklists: P2-T8 walks all three templates. TypeScript becomes a changed language, so the next policy audit needs its rows: P2-T5 writes `coverage/lcov.info`, and P0-T4 and P2-T2 supply the static evidence.
- Coverage: No production file changes in this cycle, so no per-file gate applies. P2-T5 and P2-T6 read repo-wide totals against 85% line and 75% branch, and both stop with per-root figures rather than exclude anything.
- Mirror parity: The brief states no fact this cycle changes, so no brief-update task applies. P1-T1 to P1-T4 copy each file to its bundle in the same task, the generator writes the Codex variants, and the two `csharp-legacy` variants are hand-edited in P1-T1. `PGW-SWEEP-SURFACES` reads every copy, so a missed mirror fails the gate.
- File size: `tests/scripts/claude-runtime/parallel-gate-wording.Tests.ps1` holds 247 logical lines and gains a few. `extensions/drm-copilot/test/lib/validate/policy-audit-artifact.test.ts` holds 334 and stays below the 500 guidance tier. Agent files are Markdown and exempt.
- Test isolation: The gates are one `Invoke-PoshQCParallelTest` run, one `pytest -n auto` run, and one Jest run through its normal workers, each re-run only after a fix. The new cases use in-memory text and create no temporary files.
- CI-only behavior: The RF-3 cases run in both root and extension Jest jobs on Linux and Windows and use no path or host state. `PYTHONPATH` is a local measurement setting for the shared environment of a worktree: CI installs from its own checkout, so no CI file changes. `artifacts/python/lcov.info` and `coverage/lcov.info` are gitignored local outputs.
- Evidence: Gate values come from run output, JUnit and JSON files, and the lcov files, never MCP summaries. Runner output stays under `SCRATCH`, and P2-T7 scans the evidence folders, including `remediation-baseline`, for host paths and removed-run citations.

## Open Questions / Notes

- Sweep result: besides the inputs' list, the sweep found `No decrease in coverage` in the DI agent, plus `tdd-refactor`, `5.1-Beast-adjusted`, and `gpt-5-beast-mode` with their bundle copies. No task of the original plan named those three files, so they likely extend the file inventory beyond the branch diff. They are included by the caller's class-sweep directive, and the spec's removal requirement covers agent text in all mirrors.
- `.agents/skills` check: no surface there requires a per-batch targeted test run. `focused tests` in `.agents/skills/powershell/` and `targeted mocking` in `.agents/skills/typescript/` are other senses of those words.
- Retained, for the owner report: `.agents/skills/csharp/`, `.agents/skills/typescript/`, and `.agents/skills/quality-tiers/` state a no-regression rule, and `.agents/skills/general-unit-test/` states `must not reduce coverage`. These mirror policy rules, as `.agents/skills/powershell/` and `.agents/skills/python/` do, and the review excluded policy residuals under Decision 1.
- Retained, with reasons: `tdd-green` runs all tests once; `tdd-red` runs one test to confirm an expected failure, which the expect-fail rule keeps; `All relevant tests pass` in `gpt-5-beast-mode` states an outcome, not a run; and the sample phrase in `5.1-Beast-adjusted` states no requirement.
- Criteria 1, 8, and 9 stay unchecked in `spec.md` and `user-story.md` throughout this plan. The inputs re-check them after reaudit, so no task here changes those boxes.
- Coverage cause: a probe moved the import into the worktree, but the coverage effect has not been measured. The `scripts/dev_tools` root measures 94.27%, so P2-T6 reaches the total only if `packages/discovery-runtime/src` measures roughly 75% or higher.
