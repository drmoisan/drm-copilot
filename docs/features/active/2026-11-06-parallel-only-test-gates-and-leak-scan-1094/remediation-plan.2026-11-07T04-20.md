# parallel-only-test-gates-and-leak-scan - Remediation Plan

- **Issue:** #1094
- **Parent (optional):** none
- **Owner:** drmoisan
- **Last Updated:** 2026-11-07T04-20
- **Status:** Draft
- **Version:** 0.2
- **Work Mode:** full-feature
- **Remediation-Mode:** design
- **Branch:** feature/parallel-only-test-gates-and-leak-scan-1094
- **Inputs:** `remediation-inputs.2026-11-07T04-20.md` in this folder (RF-5 and both `Optional in the Same Edit` items)

## Required References

- Policy order: `policy-compliance-order`. PowerShell is the only changed language in this cycle. `.claude/rules/python.md` applies to the Python gate.
- Requirements: `spec.md`, and the `policy-audit`, `code-review`, and `feature-audit` artifacts stamped `2026-11-07T04-20` in this folder.
- Tool routes, launchers, command-text restrictions, and CI shape are owned by the `execution-environment` skill and are not restated.

## Execution Rules

Terms: `<FEATURE>` is `docs/features/active/2026-11-06-parallel-only-test-gates-and-leak-scan-1094`. `SCRATCH` resolves to `<session scratchpad>/issue-1094/`, and every helper, JUnit file, JSON report, and log lives under it. Evidence records the token, never a host path. The merge base is the merge base of `origin/main` and `HEAD`. The debugging statement is the sentence `A focused run of one test file to debug a specific failure is debugging only.` The Copilot bundle is `extensions/drm-copilot/resources/customizations/.github/agents/`.

- **Working directory.** Every `poetry` and `git` command, and every PoshQC call, runs from the item worktree root. A launcher changes into that folder before its first command, because the Bash working directory resets to the main checkout.
- **Commit and push.** Each task ends with one commit and one push to `feature/parallel-only-test-gates-and-leak-scan-1094`. The executor stages only the paths the task names, plus the evidence it writes. `.claude/agent-memory` is never staged.
- **`testResults.xml`.** Pester runs rewrite this tracked file. Restore it with `git checkout -- testResults.xml` before staging.
- **Poetry.** Do not run an unqualified `poetry install` from the item worktree.
- **New code.** Helpers are PowerShell step scripts under `SCRATCH`. No new Python file is written.
- **Parallel gates only (owner directive).** The gates are one `Invoke-PoshQCParallelTest` run and one `pytest -n auto` run. A suite is re-run only after a fix. No task performs a run of any other form, and a task that adds or changes a test is accepted on the test's content. Phase 2 proves the pass result.
- **Gate failures.** A failure is fixed, the static stages re-run, and the failed gate re-runs. Another gate re-runs only when the fix changes a file it exercises. No condition waives a failure.
- **Text mirrors.** A task edits every copy it names, so each bundle copy equals its source when the task ends. All pairs held the same number of lines at planning time, so a copy changes only the edited text.
- **Evidence.** Every command-step artifact carries `Timestamp:`, `Command:`, `EXIT_CODE:`, and `Output Summary:`, and `EXIT_CODE:` goes non-zero when the task's asserted value fails. Evidence prose does not use the tokens P2-T4 scans for.
- **Scope.** Do not edit `.claude/rules/`, `.github/instructions/`, their bundle copies, `.agents/skills/powershell/`, `.agents/skills/python/`, the other policy mirrors `.agents/skills/csharp/`, `.agents/skills/typescript/`, `.agents/skills/quality-tiers/`, and `.agents/skills/general-unit-test/`, `.claude/agents/epic-orchestrator.md`, `.claude/skills/epic-orchestrate/SKILL.md`, `scripts/dev_tools/validate_policy_audit_artifact.py`, `extensions/drm-copilot/src/lib/validate/policy-audit-artifact.ts`, `.github/workflows/`, `scripts/powershell/PoshQC/`, `.vscode/tasks.json`, `pyproject.toml`, or the Python tools in spec `### 2. Out of scope`. Do not remove a tool-permission entry. Do not add a leak scan. This plan contains no PR, CI-monitoring, or merge task.

## Implementation Plan (Atomic Tasks)

### Phase 0 — Policy Reading and Static Baseline

No test suite runs in this phase.

- [x] [P0-T1] Read the policy files in the `policy-compliance-order` order, including `.claude/rules/powershell.md` and `.claude/rules/python.md`, then the inputs and the three audit artifacts, and write `<FEATURE>/evidence/remediation-baseline/phase0-instructions-read.<timestamp>.md`.
  - Acceptance: the artifact carries `Timestamp:`, `Policy Order:`, and the list of files read.
- [x] [P0-T2] Capture the PowerShell static baseline for `tests/scripts/claude-runtime` in `<FEATURE>/evidence/remediation-baseline/powershell-format.<timestamp>.md` and `<FEATURE>/evidence/remediation-baseline/powershell-analyze.<timestamp>.md`.
  - Format runs check-only through the no-op `-WriteFile` seam on the branch-current module. Analyzer findings come from a direct `Invoke-ScriptAnalyzer` run with `scripts/powershell/PoshQC/settings/pssa.settings.psd1`.
  - Acceptance: `Output Summary:` states the would-format count and the finding count as numbers, and `git status --porcelain` shows no tracked file changed by the step.

### Phase 1 — Fixes

- [x] [P1-T1] Fix RF-5 in Phase D, step `4) Tests`, of `.github/agents/staged-review.agent.md`, and copy the file to the Copilot bundle.
  - The two current bullets of step 4 are replaced. The step states the parallel gates for the languages in scope, one `Invoke-PoshQCParallelTest` run and one `pytest -n auto` run, each re-run only after a fix, and it carries the debugging statement.
  - Steps 1 to 3 and the `Rules:` list stay, so the evidence rule then applies to the gates.
  - `.claude/agents/staged-review.md` holds no test step, and `.codex/agents/staged-review.toml` holds none, so neither changes.
  - Acceptance: both copies hold `Invoke-PoshQCParallelTest`, `pytest -n auto`, and `debugging only`, neither holds `smallest applicable subset` or `repo-required full test suite`, and the copies are equal.
- [x] [P1-T2] Apply the debugging statement to `.github/agents/tdd-green.agent.md` and `.github/agents/tdd-red.agent.md`, reword the verification steps of `docs/features/templates/bug/plan.yyyy-MM-ddTHH-mm.md`, and copy each file to its bundle.
  - In `## Execution Guidelines`, the statement follows the text of `tdd-green` step 2 `Run the failing test` and of `tdd-red` step 5 `Verify the test fails`. The step text stays, as the inputs direct.
  - In the bug template, task `[P4-T1]` becomes `Re-run the repro to confirm expected behavior`, and the test result stays with `[P4-T2]`.
  - In the same file, the sweep found the same class in task `[P2-T2]`. Its text after the `[expect-fail]` tag becomes `Run the parallel test gate to confirm the new regression test fails and captures the repro`. This matches the expect-fail example in `.github/agents/atomic_planning.agent.md`, whose acceptance is the gate failing on the new test.
  - The agent copies go to the Copilot bundle, and the template goes to `extensions/drm-copilot/resources/feature-templates/bug/plan.yyyy-MM-ddTHH-mm.md`.
  - No test pins the changed text: searches of `tests/` and `extensions/drm-copilot/test/` returned nothing. `test_plan_templates_carry_premortem_skeleton` in `test_single_pass_preflight_contracts.py` reads the template's `## Pre-Mortem` labels, which do not change, and requires the template to equal its bundle copy byte for byte, which this task's copy keeps. It stays unchanged.
  - Acceptance: both agents and their copies hold `debugging only`, neither template copy holds `repro and regression test` or `Run the regression to confirm`, and each pair is equal.
- [x] [P1-T3] Fix the hits the sweep added in `.github/agents/typescript-engineer.agent.md`, `.github/agents/gpt-5-beast-mode.agent.md`, and `.github/agents/python-typed-engineer.agent.md`, and copy each to the Copilot bundle.
  - `typescript-engineer`: the `TDD Red Phase` handoff `prompt` requires the failing output of the smallest failing test. Append the debugging statement at the end of that frontmatter string, inside its double quotes.
  - `gpt-5-beast-mode`: in `## Stop conditions`, the condition `All relevant tests pass (or you add/execute new minimal tests).` becomes `The single gate run passes.` The check mark stays.
  - `python-typed-engineer`: in `Mode obligations`, the `minor-audit` bullet's `require static baseline, targeted, and end-state evidence obligations` becomes `require static baseline, targeted verification evidence read from the gate run, and end-state evidence obligations`, which is the wording of the plan contract. The rest of the bullet stays.
  - The `.claude/agents` and `.codex/agents` forms of these agents hold none of this text, so they do not change.
  - None of the three is in `_COPILOT_EDITED`, so `test_copilot_bundle_copies_match_canonical` does not compare them. The task confirms equality itself.
  - Acceptance: both `typescript-engineer` copies hold `debugging only`, neither `gpt-5-beast-mode` copy holds `relevant tests pass`, neither `python-typed-engineer` copy holds `baseline, targeted, and end-state`, and each pair is equal.
- [x] [P1-T4] Add the sweep tokens and the wording rows to `tests/scripts/claude-runtime/parallel-gate-wording.Tests.ps1`, and update `PGW-SWEEP-HELPER`.
  - Add five tokens to `$script:SweepToken`: `smallest applicable subset`, `relevant tests pass`, `baseline, targeted, and end-state`, `repro and regression test`, and `Run the regression to confirm`. At planning time, a case-insensitive search of `.claude`, `.github`, `.agents`, `.codex`, `docs/features/templates`, and the bundles found each only in the files P1-T1 to P1-T3 edit.
  - `PGW-SWEEP-HELPER` is the existing test that changes: its count assertion and its `-Because` text go from 33 to 38. `PGW-SWEEP-SURFACES` needs no edit, and `$script:SweepExclusion` stays unchanged. No other test names the count.
  - The `tdd-green`, `tdd-red`, and `typescript-engineer` step text stays, so a sweep token cannot guard it. Add rows to the `PGW-<Id>` `-ForEach` table instead, with `Forbidden = @()`: `COPILOT-TDD-GREEN`, `COPILOT-TDD-RED`, and `COPILOT-TS-ENGINEER`, each with `-BUNDLE`, requiring `debugging only`; and `COPILOT-STAGED-REVIEW` with `-BUNDLE`, requiring `Invoke-PoshQCParallelTest`, `pytest -n auto`, and `debugging only`.
  - Acceptance: the list holds 38 tokens, the count assertion is 38, the eight rows exist, and the exclusion table is unchanged in a `git diff HEAD` of the test file taken before this task's commit. The file does not exist at the merge base, so a diff from there cannot show this.

### Phase 2 — Final QA Toolchain and Self-Review

Static stages run first, so that a suite is not re-run for a formatting change. Each pass writes new artifacts.

- [x] [P2-T1] Run format and analyze for `tests/scripts/claude-runtime` on the branch-current `scripts/powershell/PoshQC/PoshQC.psd1` and write `<FEATURE>/evidence/qa-gates/powershell-format.<timestamp>.md` and `<FEATURE>/evidence/qa-gates/powershell-analyze.<timestamp>.md`.
  - Format output carries `Already formatted:` and `Formatted:` lines. A `Formatted:` line means a file changed: commit it and repeat this task.
  - Acceptance: zero `Formatted:` lines, a non-zero `Already formatted:` count, and zero analyzer findings, with `EXIT_CODE:` carrying both.
- [x] [P2-T2] Run the Pester gate with one background `Invoke-PoshQCParallelTest` run and write `<FEATURE>/evidence/qa-gates/pester-parallel.<timestamp>.md`.
  - The launcher exits with `.ExitCode`, which is read first. Counts come from the merged `artifacts/pester/pester-junit.xml`, and line coverage from the root LINE counter of `artifacts/pester/powershell-coverage.xml`. A failed run can leave older merged files, so each file's write time must not precede the run start.
  - Acceptance: `EXIT_CODE: 0`, zero failed tests, 56 `PGW-` testcases, `PGW-SWEEP-SURFACES` and `PGW-SWEEP-HELPER` both passed, and repo-wide line coverage at or above 85%. `Output Summary:` states the counts and the percentage.
- [x] [P2-T3] Run the pytest gate with one background `poetry run pytest -n auto --cov-branch --cov-report=term-missing --cov` run, with `PYTHONPATH` set for that run to the worktree `packages/discovery-runtime/src`, JSON coverage and JUnit output under `SCRATCH`, and write `<FEATURE>/evidence/qa-gates/pytest-parallel.<timestamp>.md`.
  - The launcher computes the worktree path at run time in the host's native absolute form, sets `PYTHONPATH` for this one command, and records the value as `<worktree>/packages/discovery-runtime/src`.
  - A PowerShell step script under `SCRATCH` reads the JSON `totals` and sums `LH`/`LF` and `BRH`/`BRF` from `artifacts/python/lcov.info`, whose write time must not precede the run start.
  - Acceptance: `EXIT_CODE: 0`, zero failures and errors, and JSON and lcov totals at or above 85% line and 75% branch. If a total is below, the step exits non-zero, and the executor stops and returns to the orchestrator. Nothing is excluded.
- [x] [P2-T4] Check branch scope, copy equality, the removed text, and evidence content, and write `<FEATURE>/evidence/qa-gates/scope-check.<timestamp>.md`.
  - Scope uses `git diff --name-only` from the merge base, with `git status --porcelain` as its companion. Neither may list a path in `## Execution Rules` under **Scope**. Every `tools:` entry is unchanged in the diff of the agent files against the merge base.
  - Copies: a hash comparison shows the six edited agents equal their Copilot bundle copies and the bug template equals its bundle copy.
  - Text: a case-insensitive search of the `$script:SweepRoot` folders for the five P1-T4 tokens finds no hit. The test file sits outside those folders.
  - Evidence: a case-insensitive scan of `<FEATURE>/evidence/baseline/`, `<FEATURE>/evidence/remediation-baseline/`, `<FEATURE>/evidence/regression-testing/`, and `<FEATURE>/evidence/qa-gates/`, with tokens assembled at run time so the artifact cannot match itself, finds no host path and none of `single-process`, `seeded`, `shuffled`, `reversed-order`, `comparison run`, and `focused run`. `<FEATURE>/evidence/regression-testing/` does not exist on this branch, so the step skips a folder that is absent and scans every file in the others.
  - Acceptance: `EXIT_CODE: 0`, from a step that exits non-zero on any match or inequality.
- [x] [P2-T5] Walk the policy-audit, code-review, and feature-audit templates under `docs/features/templates/policy_audit/` against the branch diff from the merge base, and write `<FEATURE>/evidence/qa-gates/self-review.<timestamp>.md`.
  - The walk includes this plan's own text under `.claude/rules/tonality.md`, and the items in `## Open Questions / Notes`.
  - The artifact has one PASS, FAIL, or N/A row per checklist item. A FAIL row is fixed, the QA loop re-runs from P2-T1, and the self-review is rewritten.
  - Acceptance: the artifact holds no FAIL row.

## Acceptance Criteria Traceability

| ID | Finding | Tasks | Proof |
|---|---|---|---|
| RF-5 | Required subset run in `staged-review`; criterion 1 | P1-T1, P1-T4 | `PGW-COPILOT-STAGED-REVIEW`, `PGW-SWEEP-SURFACES`, `pester-parallel` |
| OPT-1 | Debugging statement in `tdd-green` and `tdd-red` | P1-T2, P1-T4 | `PGW-COPILOT-TDD-GREEN`, `PGW-COPILOT-TDD-RED`, `pester-parallel` |
| OPT-2 | Bug template verification steps | P1-T2, P1-T4 | `PGW-SWEEP-SURFACES`, `pester-parallel` |
| SW-1 | Class sweep hits beyond the inputs | P1-T2, P1-T3, P1-T4 | `PGW-COPILOT-TS-ENGINEER`, `PGW-SWEEP-SURFACES`, `pester-parallel` |
| V-1 | Gates describe the final head | P2-T2, P2-T3 | `pester-parallel`, `pytest-parallel` |
| V-2 | Sweep tokens and count | P1-T4, P2-T2 | `PGW-SWEEP-HELPER` |
| V-3 | Copies are equal and the removed text is gone | P1-T1 to P1-T3, P2-T4 | `scope-check` |
| V-4 | Coverage at or above the thresholds | P2-T2, P2-T3 | `pester-parallel`, `pytest-parallel` |

## Pre-Mortem

- Review checklists: P2-T5 walks all three templates against the diff from the merge base. RF-5 escaped two cycles because the sweep was token-driven, so this cycle read each hit in context and records the outcome in `## Open Questions / Notes`.
- Coverage: No production file changes in this cycle, so no per-file gate applies. P2-T2 reads repo-wide line coverage against 85%, and P2-T3 reads totals against 85% line and 75% branch. Nothing is excluded.
- Mirror parity: The brief states no fact this cycle changes, so no brief-update task applies. Each of P1-T1 to P1-T3 copies its files to their bundles, and P2-T4 compares all seven pairs by hash, because `_COPILOT_EDITED` covers none of them. The Claude and Codex forms hold none of the edited text, so the generator is not run.
- File size: `tests/scripts/claude-runtime/parallel-gate-wording.Tests.ps1` holds about 250 logical lines and gains about ten, below the 500 guidance tier. Agents and templates are Markdown and exempt.
- Test isolation: The gates are one `Invoke-PoshQCParallelTest` run and one `pytest -n auto` run, each re-run only after a fix. The new rows read files in place and create no temporary files.
- CI-only behavior: The new rows use forward-slash relative paths with exact file-name case, and the rows run in the Windows shards. `PYTHONPATH` is a local measurement setting, so no CI file changes.
- Evidence: Gate values come from run output, JUnit and JSON files, and coverage files, never MCP summaries. Runner output stays under `SCRATCH`, and P2-T4 scans the evidence folders for host paths and removed-run citations.

## Open Questions / Notes

Sweep method: case-insensitive searches of `.claude`, `.github`, `.agents`, `.codex`, `docs/features/templates`, and `extensions/drm-copilot/resources` for `subset`, `smallest`, `targeted`, `impacted`, `affected tests`, `relevant tests`, `run the tests for`, `partial`, `focused`, run-verb phrases near a test word, runner filter flags, and test words near `touched`, `changed`, `staged`, or `modified`. Each hit was read in context. Bundle copies carry the same text as their sources, so an entry below covers both.

Fixed in this plan:

- `.github/agents/staged-review.agent.md`: RF-5 (P1-T1).
- `.github/agents/tdd-green.agent.md` and `.github/agents/tdd-red.agent.md`: inputs' optional item (P1-T2).
- `docs/features/templates/bug/plan.yyyy-MM-ddTHH-mm.md`: template task `[P4-T1]` from the inputs, and `[P2-T2]` from the sweep (P1-T2).
- `.github/agents/typescript-engineer.agent.md`: the handoff requires a recorded failing run, as `tdd-red` does (P1-T3).
- `.github/agents/gpt-5-beast-mode.agent.md`: `All relevant tests pass`. The previous cycle retained this as an outcome. It is reversed here, because it is a required stop condition resting on a partial set, and it directs executing new minimal tests (P1-T3).
- `.github/agents/python-typed-engineer.agent.md`: `targeted` evidence without the gate-run qualifier that every sibling carries (P1-T3).

Judged unrelated, with reasons:

- `targeted verification evidence tasks read from the gate run` in `atomic-plan-contract` and in the Copilot executor and planning agents: this already reads from the gate and requires no separate run.
- `Do not report success based on partial or targeted runs` in the QA-gate skills, and the debugging statement wherever it appears: these prohibit the class.
- `run targeted` analyzer, Ruff, Pyright, or build steps in the typed-engineer agents: static tools, which the spec keeps.
- `caller-supplied subset`, `subset of changed files`, and the plan-subset text in `feature-review` and `feature-review-workflow`: they forbid narrowing audit scope.
- `YAML construct outside the supported subset`, `strict subset`, and `unstarted subset` in the parallel skills and agents, and `subset` in `.claude/lib` and hook code: other senses. `partial run` in `parallel-run` is an orchestration run.
- `smallest failing regression test` and `smallest seam`, `smallest change`, `smallest fix`, `smallest alternative`, `smallest set of call sites`, and `smallest useful unit` across agents and templates: these describe what to write or change, not what to run.
- `targeted` in research, search, discovery, edits, mocks, and experiments (`staged-review`, `gpt-5-beast-mode`, `commentary-remediation`, `hlbpa`, `translate-*`, `repo-automation-adapter`, `create-technical-spike`): no test run.
- `relevant test references` in `extract-feature-contract`: a contract field that lists tests. It directs no run.
- `impacted modules and any regression tests for invariants` in the refactor plan template, and `impacted` in the bug and refactor spec templates: these describe test planning or scope. The same section reads results from the single gate run.
- `targeted script` in `.github/agents/status_updater.agent.md`: it lists evidence kinds for a status update, requires no run, and names no test subset.
- `Run all tests` in `tdd-green`, `run existing tests` in the two Beast agents, and the sample phrase in `5.1-Beast-adjusted`: no subset is named, and the code review records the sample phrase as Info.
- `Run tests/type checks` in the refactor plan template, the expect-fail rules in the Copilot executors, and the fail-before rules in `epic-review` and `evidence-and-timestamp-conventions`: no subset is named. Their examples use the gate command.
- `dotnet test tests/*.ArchitectureTests/*.csproj` in `csharp-qa-gate`: the architecture stage of the toolchain, not a partial unit-test run.
- `targeted re-runs` in `.github/workflows/README.md`: CI dispatch documentation, outside the named surfaces, and workflows are out of scope.
- `.github/instructions/`, `.claude/rules/`, `.agents/skills/powershell/`, and `.agents/skills/python/` hits, such as `focused tests`: forbidden surfaces, left unedited. They also use another sense.

Decisions for the reviewer:

- Token count: the inputs state 34 for one token. The caller's sweep directive adds four tokens, so the count is 38.
- `tdd-green` and `tdd-red` keep their step text, as the inputs direct, so a sweep token would fail against them. Rows requiring `debugging only` guard them instead. `typescript-engineer` follows the same form. Those steps still describe one-test runs, and the owner may prefer to reword them to the gate form the bug template now uses.
- The code review records that token sweeps match known phrasing only, so a paraphrase can return without failing a test. This plan narrows that risk and does not close it.
- Jest: no TypeScript file changes, so no Jest gate runs, per the inputs and the owner directive. `coverage/lcov.info` was not visible to a file search at planning time; because it is gitignored, its absence is unconfirmed. The inputs make any single run a reaudit step.
- Criterion 1 stays unchecked in `spec.md` and `user-story.md` throughout this plan. The inputs re-check it after reaudit.
