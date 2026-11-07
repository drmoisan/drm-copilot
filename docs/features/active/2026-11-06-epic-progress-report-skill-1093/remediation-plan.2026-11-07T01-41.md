# epic-progress-report-skill - Remediation Plan (Cycle 1)

- **Issue:** #1093
- **Owner:** drmoisan
- **Last Updated:** 2026-11-07T01-41
- **Status:** Ready for preflight
- **Branch:** feature/epic-progress-report-skill
- **Work Mode:** full-feature
- **Remediation mode:** proportionate (R1)
- **Inputs:** `remediation-inputs.2026-11-07T01-41.md` (blocking finding F1, orchestrator addendum OA-1), `policy-audit.2026-11-07T01-41.md`, `code-review.2026-11-07T01-41.md`, `feature-audit.2026-11-07T01-41.md`, `spec.md`, `user-story.md`, `plan.2026-11-06T17-53.md`

## Required References

- General Coding Standards: `.github/instructions/general-code-change.instructions.md`
- General Unit Test Policy: `.github/instructions/general-unit-test.instructions.md`
- PowerShell: `.github/instructions/powershell-code-change.instructions.md`, `.github/instructions/powershell-unit-test.instructions.md`
- Environment facts (tool routes, PoshQC route, batch budget, CI shape, isolation checks): `.claude/skills/execution-environment/SKILL.md`. Tasks below reference that brief and do not restate it.

## Execution Rules

- Commit and push after EVERY completed task. Each commit uses a conventional commit message that references `#1093` and ends with the line `Co-Authored-By: Claude Opus 5.5 <noreply@anthropic.com>`. Commit messages and committed files contain no token, account name, host path or transcript.
- `SCRATCH` is `<session scratchpad>/issue-1093/`; every scratch file name starts with `issue-1093-`. Artifacts record the token `SCRATCH`, never a host path. A scratch copy of a tracked file lives only under `SCRATCH`; the tracked file is never edited for a mutation check.
- PowerShell runs follow `## PowerShell Route and PoshQC MCP Limits` of the execution-environment brief: branch-current Pester runs use the self-hosted PoshQC module from a `sh` launcher under `SCRATCH`; counts come from `artifacts/pester/pester-junit.xml` (or the Pester result object of a direct `Invoke-Pester` run) and per-file line coverage from `artifacts/pester/powershell-coverage.xml`; analyzer findings come from a direct `Invoke-ScriptAnalyzer` run with `scripts/powershell/PoshQC/settings/pssa.settings.psd1`.
- Every evidence artifact carries `Timestamp:`, `Command:`, `EXIT_CODE:` and `Output Summary:`, lives under `<FEATURE>/evidence/<kind>/`, and is named `<name>.<timestamp>.md` with the UTC write time; a consumer selects the lexicographically greatest match. `<FEATURE>` is `docs/features/active/2026-11-06-epic-progress-report-skill-1093`.
- No production change is planned. `CANON` = `.claude/skills/epic-progress-report/scripts`; `ENTRY_SUITE` = `tests/scripts/claude-skills/epic-progress-report/Get-EpicProgressReport.Tests.ps1`; `BUNDLE` = `extensions/drm-copilot/resources/claude-customizations`. If the new case fails at the branch head, the executor stops and reports it, because that means the production write rule is wrong (remediation-inputs `## Constraints`). If any `CANON` file changes, it is re-copied byte-identically to `BUNDLE/.claude/skills/epic-progress-report/scripts/` and the skill contract suite is re-run.
- No change to any acceptance-criterion line of `spec.md` or `user-story.md`, to their checkbox states, to the TL;DR or Full output, to `SKILL.md`, to the bundle, or to any Python file. AC-12, AC-30, AC-31, US-AC-11 and US-AC-15 stay unchecked.

## Implementation Plan (Atomic Tasks)

### Phase 0 — Policy Reads and Remediation Baseline

- [x] [P0-T1] Read, in order, `CLAUDE.md`, `.claude/rules/general-code-change.md`, `.claude/rules/general-unit-test.md`, `.claude/rules/quality-tiers.md`, `.claude/rules/powershell.md`, `.github/copilot-instructions.md`, `.github/instructions/general-code-change.instructions.md`, `.github/instructions/general-unit-test.instructions.md`, `.github/instructions/powershell-code-change.instructions.md`, `.github/instructions/powershell-unit-test.instructions.md`, `.claude/skills/execution-environment/SKILL.md`, and `<FEATURE>/remediation-inputs.2026-11-07T01-41.md`.
  - Acceptance: `<FEATURE>/evidence/remediation-baseline/phase0-instructions-read.<timestamp>.md` exists with `Timestamp:`, `Policy Order:` and the twelve files listed in that order.
- [x] [P0-T2] Run the branch-current Pester route with coverage over `tests/scripts/claude-skills/epic-progress-report` and `tests/scripts/dev-tools` before any edit.
  - Acceptance: `<FEATURE>/evidence/remediation-baseline/pester-coverage.<timestamp>.md` records total, passed and failed counts from the JUnit file, per-container counts for the seven touched suites (the six suites under `tests/scripts/claude-skills/epic-progress-report/` and `tests/scripts/dev-tools/Get-EpicProgressReport.Tests.ps1`) with 163 passed and 0 failed among them and 35 passed in `ENTRY_SUITE`, and the per-file line coverage of the five `CANON` files and `scripts/dev-tools/Get-EpicProgressReport.ps1` read from `artifacts/pester/powershell-coverage.xml`.
- [x] [P0-T3] Record the physical line count of `ENTRY_SUITE` with `@(Get-Content -LiteralPath <path>).Count`.
  - Acceptance: `<FEATURE>/evidence/remediation-baseline/file-size.<timestamp>.md` records the count `563`.

### Phase 1 — F1: Pairing Write Without a New Sample

- [x] [P1-T1] In `ENTRY_SUITE`, `Describe 'Invoke-EpicProgressReport'`, add the case `It 'pairs and writes the stored samples with -PairSamples within 90 seconds of the last sample'` directly after `rewrites the stored samples in pairs with -PairSamples`. Arrange: add `$script:statePath` to `$script:existingPaths`; set `$script:fileText[$script:statePath]` to a version-1 state with `startUnixSeconds` 1767600000 (2026-01-05T08:00:00Z, deliberately different from the fixture `-StartUtc`), `baselineDone` 1, `baselineWeeklyPct` 12.5 and five samples at `$script:fixedNowUnix` minus 1230, 930, 630, 330 and 30 seconds (done 2 each); clone `$script:reportParameter`, remove `StartUtc`, set `PairSamples` to `$true` and `Mode` to `TLDR`. Act: `Invoke-EpicProgressReport` with those arguments. Assert: `Write-EpicProgressState` invoked exactly once (`Should -Invoke ... -Times 1 -Exactly`) and `$script:stateWrites.Count` is 1 with `Path` equal to `$script:statePath`; the written `samples.ts` joined by commas equal now minus 1230, now minus 630 and now minus 30 (no sample at `$script:fixedNowUnix`); `startUnixSeconds` is 1767600000, `baselineDone` is 1 and `baselineWeeklyPct` is 12.5. A one-line comment states that the newest stored sample is 30 seconds old, so the sample rule adds nothing and only the `-PairSamples` term of the write condition in `Invoke-EpicProgressReport` causes the write. Then run `ENTRY_SUITE` alone through the branch-current Pester route and record physical line count.
  - Acceptance: `<FEATURE>/evidence/regression-testing/pairsamples-write-head.<timestamp>.md` records the `ENTRY_SUITE` run with 36 passed and 0 failed, the new case listed as passed, and the physical line count of `ENTRY_SUITE` below 700; `git diff --name-only HEAD~1 HEAD` after the commit lists `tests/scripts/claude-skills/epic-progress-report/Get-EpicProgressReport.Tests.ps1` and no `CANON` path, and `git status --porcelain` is empty after the push.
- [x] [P1-T2] Prove the new case detects the reviewer's mutant without touching the tree. Record `git status --porcelain` (empty) first. Copy the five `CANON` files to `SCRATCH/mutant/.claude/skills/epic-progress-report/scripts/` and `ENTRY_SUITE` to `SCRATCH/mutant/tests/scripts/claude-skills/epic-progress-report/` (same relative layout, so the suite's `$PSScriptRoot` paths resolve into the copy). In the scratch copy of `Get-EpicProgressReport.ps1` only, remove the `-or $PairSamples` term from the state-write condition in `Invoke-EpicProgressReport`. Run the scratch suite with `Invoke-Pester` filtered to the full name of the P1-T1 case, then run the same filter against the tracked `ENTRY_SUITE`. Record the reasoning: with the term removed, the newest sample is 30 seconds old so `Select-EpicProgressSample` returns `Changed` false, `-ResetBaseline` is absent, the condition is false, `Write-EpicProgressState` is never called, and the exactly-once assertion fails.
  - Acceptance: `<FEATURE>/evidence/regression-testing/pairsamples-write-mutation.<timestamp>.md` records the scratch edit as the removed term, the mutant run with 0 passed and 1 failed and its failure message naming the `Write-EpicProgressState` invocation count, the tracked-suite run with 1 passed and 0 failed, the reasoning above, and `git status --porcelain` empty after the runs; `git diff HEAD --name-only -- .claude/skills/epic-progress-report` prints nothing.

### Phase 2 — OA-1 and Test Inventory in spec.md

- [x] [P2-T1] In `<FEATURE>/spec.md` `## Script Additions`, rewrite the resolution sentence of the `-StartUtc` table row to match AC-14 and `Resolve-EpicProgressBaseline`: "Resolution: the passed value, else (with `-ResetBaseline`) now from the clock seam, else the stored value." The rest of the row (the terminating error naming `-StartUtc` and `-ResetBaseline`, raised before any git call) is unchanged. No acceptance-criterion line changes.
  - Acceptance: the `-StartUtc` row of `spec.md` contains the literal `else (with` followed on the same row by `now from the clock seam, else the stored value`; `git diff HEAD~1 HEAD -- docs/features/active/2026-11-06-epic-progress-report-skill-1093/spec.md` after the commit shows exactly one removed and one added line, both the `-StartUtc` row, and no line beginning with `- [`; `spec.md` still holds 28 checked and 3 unchecked AC lines.
- [x] [P2-T2] In `<FEATURE>/spec.md` `## Test Inventory`, extend the `Entry suite additions` bullet with the case added in P1-T1, named by its test name `pairs and writes the stored samples with -PairSamples within 90 seconds of the last sample`: `-PairSamples` within 90 seconds of the last sample writes the paired stored samples without a new sample and carries the stored start and baselines unchanged (remediation F1).
  - Acceptance: the `Entry suite additions` bullet names `pairs and writes the stored samples with -PairSamples within 90 seconds of the last sample`; `git diff HEAD~1 HEAD` on `spec.md` after the commit changes only that bullet line, and no line beginning with `- [`.

### Phase 3 — Final QA and Self-Review

- [x] [P3-T1] Run the PoshQC formatter (`Invoke-PoshQCFormat` with the PSSA settings file, branch module) over `ENTRY_SUITE`. A clean pass logs `Already formatted:` for the file and no line beginning with `Formatted:`. When the file is reformatted, commit the result and restart this phase at P3-T1.
  - Acceptance: `<FEATURE>/evidence/qa-gates/powershell-format.<timestamp>.md` records one `Already formatted:` line for `ENTRY_SUITE`, zero `Formatted:` lines, and `git status --porcelain` empty after the run.
- [x] [P3-T2] Run `Invoke-ScriptAnalyzer` with `scripts/powershell/PoshQC/settings/pssa.settings.psd1` over `ENTRY_SUITE`.
  - Acceptance: `<FEATURE>/evidence/qa-gates/powershell-analyze.<timestamp>.md` records 0 findings; any finding is fixed and the phase restarts at P3-T1.
- [x] [P3-T3] Run the branch-current Pester route with coverage over `tests/scripts/claude-skills/epic-progress-report` and `tests/scripts/dev-tools`.
  - Acceptance: `<FEATURE>/evidence/qa-gates/pester-coverage.<timestamp>.md` records total, passed and failed counts (failed 0), per-container counts for the seven touched suites totalling 164 passed and 0 failed with 36 passed in `ENTRY_SUITE`, and per-file line coverage of at least 85 percent for each of the five `CANON` files and `scripts/dev-tools/Get-EpicProgressReport.ps1` from `artifacts/pester/powershell-coverage.xml`.
- [x] [P3-T4] Write the coverage comparison of P0-T2 and P3-T3.
  - Acceptance: `<FEATURE>/evidence/qa-gates/coverage-delta.<timestamp>.md` lists, for the five `CANON` files and the forwarder, the P0-T2 baseline value and the P3-T3 value, notes that no production line changed, and gives PASS only when every value is at or above 85 percent and none is below its baseline.
- [ ] [P3-T5] Run the seven touched Pester suites in one process in seeded shuffled file order (Fisher-Yates driven by `[System.Random]::new(<seed>)`) with seeds 7, 41 and 1093.
  - Acceptance: `<FEATURE>/evidence/regression-testing/pester-shuffled-order.<timestamp>.md` records each seed, its file order and its counts; every seed gives 164 passed and 0 failed.
- [ ] [P3-T6] Verify mirror parity and file size: compute SHA-256 of each of the five `CANON` files and of its copy under `BUNDLE/.claude/skills/epic-progress-report/scripts/`, and record the physical line count of `ENTRY_SUITE`.
  - Acceptance: `<FEATURE>/evidence/qa-gates/mirror-and-size.<timestamp>.md` records five hash pairs, each pair equal, and the `ENTRY_SUITE` count below 700 and above the P0-T3 count; `git status --porcelain` is empty after the commit.
- [ ] [P3-T7] Add one comment line at the end of the opening comment block of `ENTRY_SUITE` (before `BeforeAll`) stating that issue #1093 added the `-PairSamples` write case for a run within 90 seconds of the last sample; re-run the formatter, the analyzer and `ENTRY_SUITE` on it. Then walk the policy-audit, code-review and feature-audit templates under `docs/features/templates/policy_audit/` against the branch diff from the merge base of `origin/main` and `HEAD`, and commit the header edit together with the self-review as the final code-touching head.
  - Acceptance: the formatter logs `Already formatted:` for `ENTRY_SUITE` and no `Formatted:` line, the analyzer reports 0 findings, `ENTRY_SUITE` gives 36 passed and 0 failed; `<FEATURE>/evidence/qa-gates/self-review.<timestamp>.md` holds one PASS, FAIL or N/A row per checklist item with no FAIL row and a row for F1 and OA-1 each; after the commit and push, `git diff --name-only HEAD~1 HEAD` lists `tests/scripts/claude-skills/epic-progress-report/Get-EpicProgressReport.Tests.ps1` and `git status --porcelain` is empty.

## Remediation Traceability

| Item | Implementing tasks | Proof |
|---|---|---|
| F1 | P1-T1 | `pairs and writes the stored samples with -PairSamples within 90 seconds of the last sample` passes at head (P1-T1, P3-T3, P3-T5) and fails against the mutant (P1-T2) |
| OA-1 | P2-T1 | `spec.md` `-StartUtc` row diff (P2-T1); self-review row (P3-T7) |

NB-1 (AC-09 parenthetical) is not addressed in this cycle: the caller's scope forbids acceptance-criterion text changes, and the rename intent is already proven by `evidence/other/relocation-renames.2026-11-06T23-58.md`.

## Pre-Mortem

- Review checklists: a reviewer can fail the cycle for a test that does not discriminate the write condition, for an AC text change, or for a spec row that still disagrees with `Resolve-EpicProgressBaseline`; prevented by the mutant run in P1-T2, the diff-scoped acceptance of P2-T1 and P2-T2 (no `- [` line in either diff), and the template walk in P3-T7 with no FAIL row.
- Coverage: no production line changes, so per-file coverage cannot drop unless a run collects from the wrong population; prevented by branch-current PoshQC runs with coverage read from `artifacts/pester/powershell-coverage.xml` (P0-T2, P3-T3), never from an MCP summary, and the comparison in P3-T4.
- Mirror parity: no `CANON` or `BUNDLE` file is edited, and the mutant lives only under `SCRATCH`; prevented by the five hash pairs of P3-T6 and the empty canonical diff of P1-T2. No fact of the execution-environment brief changes (no CI job, required context, tool route or batch-budget rule), so no brief-update task exists and the six brief copies stay unchanged; no mirrored file changes, so the Python push-down contract modules are not re-run.
- File size: `ENTRY_SUITE` starts at 563 lines and gains about 25; prevented by the counts in P0-T3, P1-T1 and P3-T6 (`Get-Content` count, not `Measure-Object -Line`), each required below 700.
- Test isolation: the new case writes only script-scope fixtures that `BeforeEach` rebuilds (`existingPaths`, `fileText`, `stateWrites`) and mocks every seam, so it leaves no state behind; the isolation run is a seeded shuffled file-order run of the seven touched Pester suites in one process with seeds 7, 41 and 1093, each seed and file order recorded (P3-T5). No Jest or Python test changes, so the Jest shuffle and Python reversed-order runs are not applicable; the single-process `tests/scripts` and concurrent-shard runs recorded in the prior cycle are not repeated because the change adds one case inside an existing `Describe` with no new module-scope state.
- CI-only behavior: the case uses fixed epoch integers and the existing `/fixture-temp` and `/fixture-repo` path strings that are never touched on disk, no drive letter, backslash literal or wall-clock read; the suite is not under `tests/scripts/claude-hooks`, so it runs only in the Windows shards of `poshqc / PowerShell QC`.
- Evidence: the mutation proof could leave the tree modified or rely on an unrecorded edit; prevented by performing it only on `SCRATCH` copies and recording `git status --porcelain` before and after (P1-T2), with every artifact under `<FEATURE>/evidence/<kind>/` carrying the four required fields and the token `SCRATCH` for scratch locations.

## Test Plan

- Unit: `ENTRY_SUITE` case added in P1-T1 with every seam mocked (fixed now, mocked state reader and writer).
- Mutation check: scratch mutant of the write condition (P1-T2).
- Coverage evidence: baseline `<FEATURE>/evidence/remediation-baseline/pester-coverage.<timestamp>.md`; post-change `<FEATURE>/evidence/qa-gates/pester-coverage.<timestamp>.md`; comparison `<FEATURE>/evidence/qa-gates/coverage-delta.<timestamp>.md`.
