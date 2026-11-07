# reduce-feature-cycle-time-with-revertible-ledger - Remediation Plan (Cycle 2)

- **Issue:** #1097
- **Parent (optional):** none
- **Owner:** drmoisan
- **Last Updated:** 2026-11-07T06-05
- **Status:** Planned by `atomic-planner`; awaiting executor preflight
- **Version:** 1.0
- **Inputs:** `remediation-inputs.2026-11-07T06-05.md`, `policy-audit.2026-11-07T06-05.md`, `code-review.2026-11-07T06-05.md`, `feature-audit.2026-11-07T06-05.md`

## Required References

- General Coding Standards: [`.github/instructions/general-code-change.instructions.md`](../../../../.github/instructions/general-code-change.instructions.md)
- General Unit Test Policy: [`.github/instructions/general-unit-test.instructions.md`](../../../../.github/instructions/general-unit-test.instructions.md)
- PowerShell: [`.github/instructions/powershell-code-change.instructions.md`](../../../../.github/instructions/powershell-code-change.instructions.md), [`.github/instructions/powershell-unit-test.instructions.md`](../../../../.github/instructions/powershell-unit-test.instructions.md)
- TypeScript: [`.github/instructions/typescript-unit-test.instructions.md`](../../../../.github/instructions/typescript-unit-test.instructions.md)

**All work must comply with these policies; do not duplicate their content here.**

## Scope

Blocking finding F1 (no TypeScript coverage artifact and no full-suite run) and the four Minor items of the code review: the `StageTiming.psm1` test cases, the `issue-num` type decision, and the stage-timing paragraph split in the orchestrate skill copies. The three Nit items are not planned because none of their lines is touched. No acceptance-criterion text or checkbox changes, no ledger entry is owed, and no `execution-environment` or `atomic-plan-contract` file and no Epic #1019 folder is edited. `spec.md` is unchanged.

Premise checks, each read against the tree:

- No TypeScript production file changes, so the Jest run is repo-wide evidence only and needs no `coverageThreshold` entry.
- The review names the unexecuted branch of the issue-row sort in `Get-StageTimingSummary` under the heading "open entries". That branch is the shorter-id-first comparison, reached only when two issues differ in id length; a separate test covers it. The open-only stage case is a different rule (the `Attempts -gt OpenCount` condition in the median loop) and gets its own test.
- Decision on `issue-num`: the module accepts both a JSON string and a JSON integer of 1 or more, converting the integer with the invariant culture to the decimal-digit string. A fractional number, a boolean, zero, and a negative number are skipped. The reason text for a skipped file changes from "missing or blank" to a wording that names the accepted types, because the old wording is wrong for a JSON number; `STR-BLANK-ISSUE-FILE-SKIPPED` is the only asserting test and is updated for the new text. The skill states both accepted forms.

## Execution Terms

- `FEATURE` is `docs/features/active/reduce-feature-cycle-time-with-revertible-ledger-1097`.
- `SCRATCH` resolves to `<session scratchpad>/issue-1097/`. Launcher scripts and helper scripts live there, and artifacts record the token, never a host path.
- Tool routes come from the `execution-environment` skill and are not restated here.
- Commits: commit and push after each task with a conventional message and the session attribution lines supplied at execution.
- Testing rule (owner's standing instruction, `spec.md` `## Testing Rule`): tests run in parallel only, with one `Invoke-PoshQCParallelTest` run per gate and one Jest coverage run, re-run only after a fix. No Pytest run is owed because no Python file changes. Phase 1 tasks run no tests; their acceptance names the tests they add, and [P2-T2] proves them.
- A task never runs an unqualified `poetry install` from the worktree. If the worktree environment cannot run a gate, stop and report.
- Reading a Pester gate: `Invoke-PoshQCParallelTest` never calls `exit`, so `EXIT_CODE:` records the `ExitCode` property of the object it returns. The merged `artifacts/pester/pester-junit.xml` and `artifacts/pester/powershell-coverage.xml` are valid only when that value is 0.
- Failure outside the branch: a failing test or coverage threshold whose test file and subject are both absent from the diff from the merge base of `origin/main` and `HEAD`. Absence from that diff shows the code equals the merge base, so no merge-base run is made. The gate artifact names each such failure, `EXIT_CODE:` stays non-zero, the task stays unchecked, and the executor returns the facts to the caller without changing a file for it. Any other failure is on the branch: it is fixed and the loop restarts from [P2-T1].

## Implementation Plan (Atomic Tasks)

### Phase 0 — Baseline Capture

- [x] [P0-T1] Read the policy files in the order of `.claude/skills/policy-compliance-order/SKILL.md` for PowerShell and TypeScript test scope, write `FEATURE/evidence/baseline/phase0-instructions-read.<timestamp>.md`, and from the recorded stage B gates alone, with no suite run, write `FEATURE/evidence/baseline/stage-b-recorded-gates.<timestamp>.md`.
  - Policy artifact: carries `Timestamp:`, `Policy Order:`, and the list of files read.
  - Baseline sources: the lexicographically greatest `FEATURE/evidence/qa-gates/stage-b-powershell-test.*.md` and `FEATURE/evidence/qa-gates/stage-b-typescript-test.*.md`. `Command:` records that the artifact is a read of those two files, and `EXIT_CODE:` is 0 when both were read.
  - Output Summary: the Pester total and failed counts, the `StageTiming.psm1` line coverage, and the repo-wide PowerShell line percentage, each copied from the first source; the Jest suite count of the second source, stated as a 24-suite subset run with coverage off, so no TypeScript coverage figure exists at baseline.
  - Acceptance: both artifacts exist, and the baseline artifact carries `Timestamp:`, `Command:`, `EXIT_CODE:`, and `Output Summary:` with numeric values.

### Phase 1 — Remediation Edits

- [x] [P1-T1] Accept an integer `issue-num` in `ConvertFrom-StageTimingText` in `scripts/dev-tools/StageTiming.psm1`, update the module header comment that describes `issue-num`, and add the Minor test cases to `tests/scripts/dev-tools/StageTiming.Tests.ps1`.
  - Behavior: a string `issue-num` is trimmed as before; a JSON integer of 1 or more is converted with the invariant culture to its decimal string; every other value (blank string, absent key, fractional number, boolean, zero, negative) skips the file with the reason `issue-num is missing, blank, or not a string or a positive integer`. A string file and an integer file for the same issue select as one issue by the existing greatest-leaf rule.
  - New `It` cases: `STR-INTEGER-ISSUE-NUM-READ-AS-STRING-ISSUE` (an integer 9001 reports `Issue` as `9001` and a string and an integer file for one issue yield one issue row); `STR-NON-POSITIVE-OR-FRACTIONAL-ISSUE-NUM-SKIPPED` (`-ForEach` over 0, -3, 1.5, and true, each skipped with the new reason); `STR-MISSING-STARTED-AT-ENTRY-SKIPPED` (an entry with no `started_at` key is skipped with `started_at is not an ISO-8601 time`); `STR-MISSING-STAGE-OR-ATTEMPT-ENTRY-SKIPPED` (an entry with no `stage` key and an entry with no `attempt` key are skipped with `stage is missing or blank` and `attempt is not an integer of 1 or more`); `STR-STAGE-WITH-ONLY-OPEN-ENTRIES-ABSENT-FROM-MEDIANS` (a stage whose entries are all open appears in `Issues` with `OpenCount` equal to `Attempts` and is absent from `Stages`, so removing the `Attempts -gt OpenCount` condition fails it); `STR-ISSUE-ROWS-ORDER-SHORTER-ID-FIRST` (issues `99` and `100` in either evidence order list `99` first, so removing the length comparison fails it).
  - Asserting tests found by searching the test tree for the changed symbol and the asserted text: `STR-BLANK-ISSUE-FILE-SKIPPED` asserts the old reason twice and is updated to the new text, with its inputs unchanged. `STR-MALFORMED-JSON-FILE-SKIPPED`, `STR-STAGE-TIMING-NOT-A-LIST-SKIPPED`, `STR-READ-RETURNS-NAMED-FILES-IN-ORDER`, and every test in `tests/scripts/dev-tools/Get-StageTimingReport.Tests.ps1` use string `issue-num` values or do not assert the reason, so they are unchanged. The committed fixtures under `tests/fixtures/dev-tools/stage-timing` use string values and are unchanged.
  - Acceptance: the six new `It` names exist in the test file, `STR-BLANK-ISSUE-FILE-SKIPPED` asserts the new reason text, and [P2-T2] reports them passing. The module stays under 700 lines and the test file under 500.
- [x] [P1-T2] Split the stage-timing paragraph (list item 6, heading text `Stage timing (issue #1097)`) in `.claude/skills/orchestrate/SKILL.md` and its three mirror copies (listed below) into one list item with five indented sub-bullets, and state the `issue-num` decision in the same edit.
  - Files, edited identically in the stage-timing text: `.claude/skills/orchestrate/SKILL.md`, `.agents/skills/orchestrate/SKILL.md`, `extensions/drm-copilot/resources/claude-customizations/.claude/skills/orchestrate/SKILL.md`, and `extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/orchestrate/SKILL.md`.
  - Sub-bullets: transition handling (one clock reading, `last_updated`, `ended_at`, `started_at`, `attempt`); entry shape and the tolerated-key statement; the evidence file written in the last commit before the merge, naming `issue-num` as a string of decimal digits or an integer of 1 or more, both read as the same issue; the portable-handoff statement; the report entry `scripts/dev-tools/Get-StageTimingReport.ps1` with the wall-clock and merge-stage sentences. Each pinned token of `StageTimingDocumentation.Tests.ps1` (`stage_timing`, `stage-timing.`, `wall-clock`, `The merge stage is not captured.`, and the report entry path) stays contiguous within one sub-bullet, so the whitespace-normalized text those tests read is unchanged in effect.
  - Asserting tests: `STD-SKILL-DOCUMENTS-STAGE-TIMING-IN-EVERY-COPY` is unchanged and re-proves all four copies in [P2-T2]. No test pins the orchestrate skill by hash; `parallel_orchestrator_surface_expectations.py` freezes `epic-orchestrate`, not this file. The push-down contract tests compare each source copy with its bundle copy, so each pair stays byte-equal.
  - Acceptance: `git hash-object` returns equal values for `.claude/skills/orchestrate/SKILL.md` and its bundle copy, and equal values for `.agents/skills/orchestrate/SKILL.md` and its bundle copy; the stage-timing item of each copy spans five sub-bullets and no single physical line holds more than one of them; no other part of the four files changes, as the diff from the merge base of `origin/main` and `HEAD` shows for those paths.

### Phase 2 — Final QA

- [x] [P2-T1] Run the PowerShell format and lint stages over `scripts/dev-tools/StageTiming.psm1` and `tests/scripts/dev-tools/StageTiming.Tests.ps1`, once, and write `FEATURE/evidence/qa-gates/powershell-format-lint.<timestamp>.md`.
  - Format runs `Invoke-PoshQCFormat` check-only, with a no-op `-WriteFile`, over `scripts/dev-tools` and `tests/scripts/dev-tools`. Lint runs `Invoke-ScriptAnalyzer` directly on the two files with `scripts/powershell/PoshQC/settings/pssa.settings.psd1`.
  - Acceptance: the log holds an `Already formatted: ` line and no `Formatted: ` line for each file, and analyzer findings number zero. `EXIT_CODE:` is non-zero when either condition fails. A failure is repaired and this task restarts. No Python or TypeScript file changes, so no Python or TypeScript format stage runs.
- [ ] [P2-T2] Run the two test gates, once each, from the worktree root and then the extension: one `Invoke-PoshQCParallelTest`, writing `FEATURE/evidence/qa-gates/powershell-test.<timestamp>.md`; then the Jest coverage run, writing `FEATURE/evidence/qa-gates/stage-b-typescript-coverage.<timestamp>.md`. Neither run is repeated unless a fix follows a failure.
  - PowerShell artifact: the returned `ExitCode` is 0; the failed count from `artifacts/pester/pester-junit.xml` is zero; every `It` name added or updated by [P1-T1] and the four `STD-SKILL-DOCUMENTS-STAGE-TIMING-IN-EVERY-COPY` cases are present and passing in that file; the `LINE` counter of the `sourcefile` element named `StageTiming.psm1` in `artifacts/pester/powershell-coverage.xml` is at least 85%; the repo-wide line percentage from `Get-PoshQCCoverageLineSummary` is at least 85% and is stated beside the [P0-T1] figures.
  - Jest dependency check, before the Jest run: confirm that `extensions/drm-copilot/node_modules/.bin/jest` exists. When it is absent, run `npm ci` scoped to `extensions/drm-copilot` and nothing else, then confirm again; the install is recorded in the artifact.
  - Jest run, in `extensions/drm-copilot`: `node run-jest.cjs --coverage --coverageReporters=lcov --coverageReporters=text-summary`, the form of the `test:coverage` script. Acceptance: the process exits 0 with zero failing suites and tests; `extensions/drm-copilot/coverage/lcov.info` exists afterwards and stays on disk, because the directory is gitignored and re-review reads it there; the artifact records the suite and test counts and the repo-wide line and branch percentages read from the `text-summary` block, which prints them separately.
  - Both artifacts carry `Timestamp:`, `Command:`, `EXIT_CODE:`, and `Output Summary:`, with figures read from files or direct output and not from MCP results. `EXIT_CODE:` is non-zero when any condition of its artifact fails. A failing suite or a threshold failure is classified under Execution Terms; one outside the branch is recorded with its file and whether it is in the diff, and is not fixed here.
- [ ] [P2-T3] Walk the policy-audit, code-review, and feature-audit templates under `docs/features/templates/policy_audit/` against the branch diff from the merge base of `origin/main` and `HEAD`, and write `FEATURE/evidence/qa-gates/self-review.<timestamp>.md` with one PASS, FAIL, or N/A row per checklist item.
  - Scope rows: the diff since the cycle began is limited to `StageTiming.psm1`, `StageTiming.Tests.ps1`, the four orchestrate skill copies, and `FEATURE`. It holds no `execution-environment` or `atomic-plan-contract` file, no Epic #1019 folder, no ledger entry, no `spec.md` change, and no Python or TypeScript source change. The coverage row names the TypeScript artifact by its `stage-b-typescript-coverage` evidence file and covers PowerShell and TypeScript.
  - Acceptance: F1 and each of the four Minor items has a row naming its proving test or artifact, and no row is FAIL. A FAIL row is fixed, the loop re-runs from [P2-T1], and this artifact is rewritten.

## Pre-Mortem

- Review checklists: the likely finding is a rule with no falsifying test. Each new case is written so that removing the rule it covers fails it: the integer conversion, the missing-key arms, the open-only median condition, and the id-length sort. [P2-T3] maps F1 and the four Minor items to evidence rows. F1 is closed by an artifact, not by an argument.
- Coverage: F1 is closed by the single Jest run in [P2-T2], whose lcov file supplies the repo-wide figures; no TypeScript production file changes, so no per-file figure is owed. `StageTiming.psm1` was previously under 100% only on the lines the new cases execute, so the 85% line floor is met with margin; branch coverage does not apply to PowerShell.
- Mirror parity: [P1-T2] edits all four orchestrate skill copies in one task and checks each source and bundle pair for byte equality. No agent, rule, hook, or manifest file changes, so no pack manifest changes. The cycle alters no fact the `execution-environment` brief states, so no brief-update task is needed.
- File size: the module is 434 lines and gains under 15, and the test file gains under 100; both stay below 500. Markdown is exempt.
- Test isolation: by the owner's standing instruction, recorded in `spec.md` `## Testing Rule`, the isolation runs are one `Invoke-PoshQCParallelTest` run and one Jest run, repeated only after a fix. There are no single-process, seeded-shuffle, reversed-order, or comparison runs, and no Pytest run because no Python file changes. The new tests build in-memory texts, create no file, and set no global state.
- CI-only behavior: test texts are in-memory strings, so the `eol=lf` rule cannot alter them, and no path literal carries a drive letter. The skill copies are outside the docs-only allowlist, so the pull request takes a full run, and the Jest run here is the local counterpart of the extension jobs.
- Evidence: artifacts live under `FEATURE/evidence/baseline/` and `FEATURE/evidence/qa-gates/` with write-time stamps and the four required fields, and record no host path. `extensions/drm-copilot/coverage/lcov.info` is gitignored and is left on disk, not committed. `EXIT_CODE:` carries each acceptance value.

## Test Plan

- Unit: `tests/scripts/dev-tools/StageTiming.Tests.ps1` gains `STR-INTEGER-ISSUE-NUM-READ-AS-STRING-ISSUE`, `STR-NON-POSITIVE-OR-FRACTIONAL-ISSUE-NUM-SKIPPED`, `STR-MISSING-STARTED-AT-ENTRY-SKIPPED`, `STR-MISSING-STAGE-OR-ATTEMPT-ENTRY-SKIPPED`, `STR-STAGE-WITH-ONLY-OPEN-ENTRIES-ABSENT-FROM-MEDIANS`, and `STR-ISSUE-ROWS-ORDER-SHORTER-ID-FIRST`; `STR-BLANK-ISSUE-FILE-SKIPPED` is updated.
- Documentation: `STD-SKILL-DOCUMENTS-STAGE-TIMING-IN-EVERY-COPY` re-proves the four split copies.
- Coverage evidence: baseline in `FEATURE/evidence/baseline/stage-b-recorded-gates.<timestamp>.md`; post-change in the [P2-T2] artifacts.

## Open Questions / Notes

- The reviewed head is the one named in `remediation-inputs.2026-11-07T06-05.md`.
- The `issue-num` decision accepts both forms, with a test, and changes one reason string with its one asserting test.
- The three Nit items stay unplanned; they remain in the code review.
