# 2026-10-30-retire-github-skills-and-thin-copilot-layer - Remediation Plan (Cycle 3)

- **Issue:** #1032
- **Parent:** epic #1018, child 6
- **Branch:** `feature/retire-github-skills-and-thin-copilot-layer-1032`
- **Work Mode:** full-feature
- **Remediation-Mode:** proportionate (inputs file); preflight and execution run in one executor delegation
- **Inputs:** `remediation-inputs.2026-11-20T05-28.md` in this folder (finding CR-1), with the CR-1 row of `code-review.2026-11-20T05-16.md` as source; model and term source: `remediation-plan.2026-11-19T19-58.md`.
- **Scope:** test-only. The one edited file is `tests/scripts/claude-runtime/copilot-layer-retirement.Tests.ps1`. No production file, spec criterion or interface changes.

## Required References

- Policies: `.claude/rules/general-code-change.md`, `.claude/rules/general-unit-test.md`, `.claude/rules/powershell.md`.
- Tool routes, test-execution launcher, command-text restrictions, CI shape: `.claude/skills/execution-environment/SKILL.md` (not restated here).
- Evidence naming and stamping: `.claude/skills/evidence-and-timestamp-conventions/SKILL.md`.

## Terms

- `<FEATURE>`: `docs/features/active/2026-10-30-retire-github-skills-and-thin-copilot-layer-1032`.
- `SUITE`: `tests/scripts/claude-runtime/copilot-layer-retirement.Tests.ps1` (`GUARD-SUITE` of the earlier plans).
- `BRIEF-RULE`: helper `Test-ClrBriefCount`, whose retired-path branch is the check that a brief copy names the retired path (violation text `names the retired path`).
- `COLLISION-RULE`: helper `Test-ClrCollisionControl`, whose workspace-case branch compares each of the three location keys and `chat.useClaudeMdFile` with `false` before the workspace case counts as complete.
- `CASE-A`: new `It` titled `CLR-BRIEF-COUNT-REJECTS a brief copy that names the retired path`.
- `CASE-B`: new `It` titled `CLR-COLLISION-CONTROLS-REJECTS a complete workspace case with a wrong value`.
- `RETIRED-PATH`: the retired skills path, built in `BeforeAll` as `$script:RetiredPath` from its two parts; the plan and the new cases never carry it as a literal.
- `BASELINE-REF`: the greatest `<FEATURE>/evidence/regression-testing/c2-pester-final.*.md`, the cycle-2 Pester final record. Decision under OD-4 (cost-benefit rule): no fresh baseline gate run, because this cycle changes only a test file and the record describes the same branch immediately before this cycle.
- `SCRATCH`: `<session scratchpad>/issue-1032/`; scratch file names start with `issue-1032-c3-`; artifacts record the token `SCRATCH`, never a host path.
- Commit cadence: each completed task is committed and pushed without force; a task with no tracked change commits its evidence and the plan check-off only.
- Every artifact is `<name>.<timestamp>.md`, stamped from the clock at write time, append-only, and carries `Plan: remediation-plan.2026-11-20T05-28.md`. Command artifacts carry `Timestamp:`, `Command:`, `EXIT_CODE:` and `Output Summary:`. The `c3-` prefix keeps them apart from earlier cycles.

## Planning-Time Observations (re-derived this pass, re-checked by P0-T1)

- `BRIEF-RULE` ends its brief loop with the retired-path check; existing `CLR-BRIEF-COUNT-REJECTS a source count and a missing S6 target` feeds a brief without the retired path, so no case reaches that branch.
- `COLLISION-RULE` has `CLR-COLLISION-CONTROLS-REJECTS no complete case, a kept-default key, and a settings_required file` as its only negative case; its settings fixture has no `chat.` collision key, so the workspace value comparison never runs in a negative case.
- No test or config outside `docs/` names `SUITE`, so no count pin or shard-weight entry asserts its test count. The suite holds 417 logical lines, below the 500-line guidance tier, so both cases fit without a split.
- Existing tests that assert `BRIEF-RULE` or `COLLISION-RULE` behavior are the two positive cases and the two existing negative cases named above; the helpers do not change, so all four are unchanged (unaffected).

## Language Classification

| Planned artifact | Change | Classification |
| --- | --- | --- |
| `SUITE` | Add `CASE-A` and `CASE-B` | Existing PowerShell test (permitted) |
| Broken-branch copies and helper scripts | Written under `SCRATCH`, never committed | PowerShell or `sh` helpers, throwaway |
| Evidence records | Write | Markdown |

No artifact adds Python; no production or hook file is edited.

## Implementation Plan (Atomic Tasks)

### Phase 0 — Baseline Reference

- [x] [P0-T1] Baseline and premise check: read `BASELINE-REF` (`docs/features/active/2026-10-30-retire-github-skills-and-thin-copilot-layer-1032/evidence/regression-testing/c2-pester-final.2026-11-20T04-55.md`) and copy its pass and fail counts, the `copilot-layer-retirement.Tests.ps1` suite row (22 tests, 0 failures) and repository-wide line coverage; confirm in `SUITE` that `BRIEF-RULE` holds the retired-path branch, that `COLLISION-RULE` holds the workspace value comparison, and that neither `CASE-A` nor `CASE-B` exists; record the logical line count of `SUITE` and the branch head (`BaseHead:`). Run no gate.
  - Acceptance: `<FEATURE>/evidence/baseline/c3-baseline-ref.<timestamp>.md` carries `Timestamp:`, `Command:` (the reads), `EXIT_CODE: 0`, `BaseHead:`, `SuiteLogicalLines:` and an `Output Summary:` naming the source record, its counts and coverage (96.84% line), the two confirmed branches and `CasesPresent: no`; a missing record or a present case records `blocked: premise_falsified` and stops the run.

### Phase 1 — Cases, Fail-Before Proof and Final QA

The edits and the final QA loop share one phase, so the final gate is the only full gate after the edit (OD-4, cost-benefit, as in cycle 2: the change is two in-memory test cases).

- [x] [P1-T1] Add `CASE-A` to `SUITE` (`tests/scripts/claude-runtime/copilot-layer-retirement.Tests.ps1`), directly after the existing `CLR-BRIEF-COUNT-REJECTS a source count and a missing S6 target` case. Arrange: an ordered brief map with one entry whose text joins every element of `$script:BriefTargets` and appends `$script:RetiredPath` (so it holds all targets and no source wording), and a contract map with one entry holding `in all four byte-identical copies`. Act: `Test-ClrBriefCount` with `$script:RetiredPath`. Assert: the violation count is exactly 1 and that violation matches `names the retired path`. In-memory only, no file read or written. Task check: `SUITE` through the launcher `pester` suite with `-TestPath`.
  - Acceptance: `CASE-A` passes and every pre-existing case of `SUITE` still passes (23 tests here, 24 after P1-T2); `SUITE` carries no literal of `RETIRED-PATH`; `<FEATURE>/evidence/other/task-check.P1-T1.<timestamp>.md` records the changed file, the selection rule, each command with its exit code and the results; the change is committed and pushed without force.
- [x] [P1-T2] Add `CASE-B` to `SUITE`, directly after the existing `CLR-COLLISION-CONTROLS-REJECTS no complete case, a kept-default key, and a settings_required file` case. Arrange: an in-memory settings JSON string holding all four `$script:CollisionKeys` keys, complete and correct except `chat.agentSkillsLocations` maps `.claude/skills` to `true`, and no kept-default key; readme text `# Readme` followed by a newline (no collision-controls section, so the user case does not hold); `RequiredFileExists` false. Act: `Test-ClrCollisionControl`. Assert: the violation count is exactly 1 and it matches `exactly one AD-3 case must hold in full`. In-memory only. Task check: as P1-T1.
  - Acceptance: `CASE-B` passes and `SUITE` runs 24 tests with 0 failures; `<FEATURE>/evidence/other/task-check.P1-T2.<timestamp>.md` records the changed file, selection, commands with exit codes and results; committed and pushed without force.
- [x] [P1-T3] Fail-before proof for `CASE-A`: a helper under `SCRATCH` reads `SUITE` text in memory, writes a variant copy under `SCRATCH` in which the retired-path branch of `BRIEF-RULE` is removed, points the variant's `$script:RepoRoot` at the repository root read at run time, and runs the variant through the launcher `pester` suite with `-TestPath`. The variant is never copied into the tree. If the launcher cannot run a path outside the repository, write the dossier `<FEATURE>/evidence/regression-testing/fail-before-exception.<timestamp>.md` with `WhyFailingRunImpossible:` and an alternative proof that dot-sources the variant helper in memory and shows the violation count 0 for the `CASE-A` fixture against 1 for the committed helper.
  - Acceptance: `<FEATURE>/evidence/regression-testing/c3-fail-before-case-a.<timestamp>.md` records the variant description, a non-zero `EXIT_CODE`, and `CASE-A` among the failing tests by name, or the dossier above exists with the 0 against 1 comparison; no variant file is tracked (`git status --porcelain` shows none); the artifact is committed and pushed without force.
- [x] [P1-T4] Fail-before proof for `CASE-B` in `tests/scripts/claude-runtime/copilot-layer-retirement.Tests.ps1`, in the same form as P1-T3: the variant removes the value comparison of the three location keys and `chat.useClaudeMdFile` from the workspace branch of `COLLISION-RULE`, so a key-presence-only workspace case counts as complete.
  - Acceptance: `<FEATURE>/evidence/regression-testing/c3-fail-before-case-b.<timestamp>.md` records the variant description, a non-zero `EXIT_CODE`, and `CASE-B` among the failing tests by name, or a `fail-before-exception.<timestamp>.md` dossier with the 0 against 1 comparison for the `CASE-B` fixture; no variant file is tracked; committed and pushed without force.
- [x] [P1-T5] Final static loop for `SUITE`: PSScriptAnalyzer with `scripts/powershell/PoshQC/settings/pssa.settings.psd1`, and the formatter comparison (format the file text in memory with `Invoke-Formatter` and compare it with the file text; the file is not rewritten, and a clean run reports zero differing text). Restart from this task on any finding or difference.
  - Acceptance: `<FEATURE>/evidence/qa-gates/c3-final-static.<timestamp>.md` records each step's command, exit code, finding count 0 and difference count 0; committed and pushed without force.
- [ ] [P1-T6] File-size and scope check: record the logical line count of `SUITE` (`tests/scripts/claude-runtime/copilot-layer-retirement.Tests.ps1`) and confirm it is at most 500 and not above `SuiteLogicalLines` of `c3-baseline-ref` by more than 40; list the files changed since `BaseHead` with `git diff --name-only` anchored at `BaseHead` read from the greatest `c3-baseline-ref.*.md`, with a `git status --porcelain` companion for untracked files.
  - Acceptance: `<FEATURE>/evidence/qa-gates/c3-file-size-scope.<timestamp>.md` records the line count within the bound and a changed-file list in which the only non-evidence tracked path is `SUITE` and every other path lies under `<FEATURE>` (this plan, the cycle's evidence and check-offs); no `*.py` added; committed and pushed without force.
- [ ] [P1-T7] Final Pester gate, once: one `Invoke-PoshQCParallelTest` run through the launcher `pester` suite (no `-TestPath`), integration and golden lanes excluded; a failure is fixed and the loop restarts at P1-T5. Read counts from `artifacts/pester/pester-junit.xml` and line coverage from `artifacts/pester/powershell-coverage.xml`.
  - Acceptance: `<FEATURE>/evidence/regression-testing/c3-pester-final.<timestamp>.md` records `ExitCode` 0, zero failures and errors, the `SUITE` row at 24 tests with 0 failures including `CASE-A` and `CASE-B`, `ProcessReductionChain.Ledger.Tests.ps1` and `FileSizePolicy.RepoGate.Tests.ps1` passing, and repository-wide line coverage compared with `BASELINE-REF` (96.84% line) with no drop (covered and missed counts both stated); a launcher exit 75 is recorded as a queue timeout and the gate is re-run; committed and pushed without force.
- [ ] [P1-T8] Walk the policy-audit, code-review and feature-audit templates under `docs/features/templates/policy_audit/` against the diff from `BaseHead` (plan and evidence plus the one test file), with CR-1 checked against P1-T3, P1-T4 and P1-T7.
  - Acceptance: `<FEATURE>/evidence/qa-gates/self-review.<timestamp>.md` carries `Plan: remediation-plan.2026-11-20T05-28.md` and one PASS, FAIL or N/A row per checklist item with no FAIL row; a FAIL is fixed and the loop restarts at P1-T5 before a new file is written; committed and pushed without force.

## Finding Traceability

| Finding or criterion | Implementing task | Check that fails if broken |
| --- | --- | --- |
| CR-1 retired-path branch of `BRIEF-RULE` | P1-T1, P1-T3 | `CASE-A`, shown failing against the variant without the branch |
| CR-1 workspace value comparison of `COLLISION-RULE` | P1-T2, P1-T4 | `CASE-B`, shown failing against the variant without the comparison |
| In-memory fixtures, no literal retired path | P1-T1, P1-T2 | `CASE-A` and `CASE-B` build text in memory; `RETIRED-PATH` comes from `$script:RetiredPath` |
| No coverage drop, zero failures | P0-T1, P1-T7 | `c3-pester-final` against `BASELINE-REF` |
| Static and size conformance | P1-T5, P1-T6 | PSScriptAnalyzer findings, formatter difference, line count bound |

## Pre-Mortem

- Review checklists: likely findings are a case that passes against a broken helper, a fixture that trips a second violation, and a literal `RETIRED-PATH` in the suite; P1-T3 and P1-T4 prove each case fails against a broken variant, both cases assert an exact count of 1, and P1-T8 walks all three templates.
- Coverage: only a test file changes, so production coverage is unchanged by design; `BASELINE-REF` stands in for a fresh baseline (OD-4, cost-benefit) and P1-T7 compares repository-wide line coverage from the single gate run with it; the new cases add behavior coverage for two branches that had none.
- Mirror parity: not applicable. `SUITE` has no bundle or mirror copy, and the cycle adds no CI job, required context, tool route or batch-budget rule, so no execution-environment brief update is needed.
- File size: `SUITE` holds 417 logical lines and gains about 30, below the 500-line guidance tier; P1-T6 records the count and the bound, and `FileSizePolicy.RepoGate.Tests.ps1` runs in the P1-T7 gate.
- Test isolation: one `Invoke-PoshQCParallelTest` run through the launcher at P1-T7, re-run only after a fix; task checks and fail-before runs are selections, not gates; no serial, shuffled or reversed run; both cases are in-memory and leave no state, and the variants live under `SCRATCH` outside the test tree so no sibling suite discovers them.
- CI-only behavior: the cases read no file, drive letter or `origin` ref and use text only, so they behave the same on the Windows shard jobs; the Linux hook-suite job does not run `SUITE`; CI on the pushed head is the integration-lane evidence.
- Evidence: every task names its artifact under `<FEATURE>/evidence/<kind>/`, stamped from the clock at write time, append-only, with this plan's `Plan:` value; scratch locations are recorded as `SCRATCH`; no receipt id or time is composed; no force push.
