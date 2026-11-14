# Remediation Plan R1 (cycle 1) - Issue #1048 pytest-xdist parallel test cycle

Canonical issue number: 1048. Branch: `feature/pytest-xdist-parallel-test-cycle-1048`. Feature folder `FEATURE` = `docs/features/active/2026-10-31-pytest-xdist-parallel-test-cycle-1048`. Remediation mode: proportionate.

Inputs: `FEATURE/remediation-inputs.2026-10-31T21-02.md` (F1, CR-2), `FEATURE/feature-audit.2026-10-31T21-02.md`, `FEATURE/code-review.2026-10-31T21-02.md`, `FEATURE/spec.md`, and `FEATURE/evidence/other/validate-json-tasks.2026-10-31T18-16.md`.

`SCRATCH` is `<session scratchpad>/issue-1048/`; scratch file names start with `issue-1048-`. Tool routes, launchers, and command-text restrictions follow the `execution-environment` skill and are not restated here.

## Scope

- F1 (autonomous): amend two `spec.md` acceptance criteria and check both off. No other criterion is touched.
- CR-2 (minor): add Pester tests for the two `-Root` fallback statements of `Invoke-PoshQCParallelTest` in `scripts/powershell/PoshQC/PoshQC.Parallel.psm1`. Test-only; no production change unless a test proves a defect.

Out of scope: Phase 9 items (P9-T1 to P9-T5), the CI-dependent criteria (`spec.md` S1, S2, S9, S21, S24, S29 and `user-story.md` U2, U5, U8), CR-3, `json_config.py`, `.vscode/` governed globs, and any Python file. The pytest suite is not run because no Python file is touched.

## Implementation Plan (Atomic Tasks)

### Phase 0 — Policy Reading and Baseline Capture

- [x] [P0-T1] Read, in order, `CLAUDE.md`, `.claude/rules/general-code-change.md`, `.claude/rules/general-unit-test.md`, `.claude/rules/powershell.md`, and the execution-environment brief, and write `FEATURE/evidence/baseline/phase0-instructions-read.<timestamp>.md`.
  - Acceptance: the artifact carries `Timestamp:`, `Policy Order:`, and the list of files read.
- [x] [P0-T2] Capture the PowerShell analyzer baseline with a direct `Invoke-ScriptAnalyzer` run using `scripts/powershell/PoshQC/settings/pssa.settings.psd1` over `tests/scripts/powershell/PoshQC/PoshQC.ParallelRunner.Tests.ps1`, and write `FEATURE/evidence/baseline/pssa.<timestamp>.md`.
  - Acceptance: the artifact carries `Timestamp:`, `Command:`, `EXIT_CODE:`, `Output Summary:` with the finding count.
- [x] [P0-T3] Capture the Pester baseline by running `Invoke-PoshQCTest` for `tests/scripts/powershell/PoshQC` with coverage through the brief's PowerShell route, and write `FEATURE/evidence/baseline/pester-poshqc.<timestamp>.md`.
  - Acceptance: the artifact records failures read from `artifacts/pester/pester-junit.xml` and the numeric line coverage of `PoshQC.Parallel.psm1` read from `artifacts/pester/powershell-coverage.xml`, plus `Timestamp:`, `Command:`, `EXIT_CODE:`, `Output Summary:`.
- [x] [P0-T4] Record the physical line count of `tests/scripts/powershell/PoshQC/PoshQC.ParallelRunner.Tests.ps1` (counted with `wc -l`) in `FEATURE/evidence/baseline/file-sizes.<timestamp>.md`.
  - Acceptance: the artifact records the numeric count.

### Phase 1 — F1: acceptance-criteria wording correction

- [x] [P1-T1] Re-verify the replacement verification: write a helper under `SCRATCH` (`issue-1048-tasks-jsonc-check.py`) that removes full-line `//` comments from `.vscode/tasks.json`, parses it with `json.loads`, and checks that the labels `QC: 4 Pytest: run tests`, `QC: 4 Pytest: run tests (parallel)`, `QC: 4 Pytest: run tests with coverage (parallel)`, `PoshQC: 4 test (Pester)`, and `PoshQC: 4 test (Pester, parallel)` are present; run it with Poetry and write `FEATURE/evidence/other/spec-ac-jsonc-amendment.<timestamp>.md`.
  - Acceptance: the artifact carries `Timestamp:`, `Command:`, `EXIT_CODE: 0`, `Output Summary:` with the parsed task count and the five labels each reported present, and cites `FEATURE/evidence/other/validate-json-tasks.2026-10-31T18-16.md` as the record that `validate_json` does not read `.vscode/tasks.json` (outside `GOVERNED_GLOBS` in `scripts/dev_tools/json_config.py`).
- [x] [P1-T2] In `FEATURE/spec.md` `## Acceptance Criteria`, in the Part 1 item beginning "`.vscode/tasks.json` contains a parallel unit-test task" and the Part 2 item beginning "A VS Code task runs `Invoke-PoshQCParallelTest`", replace only the clause "passes governed-JSON validation" with the clause "parses as JSONC (full-line comments removed) with every required label present; the file is outside the governed-JSON globs, so `validate_json` does not apply (evidence: `evidence/other/spec-ac-jsonc-amendment.<timestamp>.md`)", substituting the P1-T1 file name. Change nothing else in either item and add no criterion.
  - Acceptance: the diff of `FEATURE/spec.md` against the merge base of `origin/main` and `HEAD` shows only the two clause replacements (plus the two checkbox changes of P1-T3); `git grep -n -e "governed-JSON validation" -- FEATURE/spec.md` reports only the unrelated text at the spec's Part 1 requirement item 4 (it is the scope statement, not an acceptance criterion) and no `## Acceptance Criteria` line.
- [x] [P1-T3] Following the `acceptance-criteria-tracking` skill, check off exactly the two amended items in `FEATURE/spec.md` (`- [ ]` to `- [x]`) after P1-T1 exits 0.
  - Acceptance: exactly two lines change from unchecked to checked; the CI-dependent criteria S1, S2, S9, S21, S24, S29 in `spec.md` and U2, U5, U8 in `user-story.md` remain unchecked, and `user-story.md` is unchanged.

### Phase 2 — CR-2: cover the `-Root` fallbacks

- [x] [P2-T1] In `tests/scripts/powershell/PoshQC/PoshQC.ParallelRunner.Tests.ps1`, inside `Describe 'Invoke-PoshQCParallelTest'`, add the test `PR10-OMITTED-ROOT-USES-CURRENT-LOCATION`: build seams with `$script:NewSeams`, remove the `Root` key, run `Invoke-PoshQCParallelTest @seams -WorkerCount 1` with the location set by `Push-Location -LiteralPath $PSScriptRoot` inside `try`/`finally` with `Pop-Location`, and assert the captured shard command in `$state.Started[0].Arguments[4]` contains `-Root '<(Get-Location).ProviderPath>'` and that `$state.Resets[0]` begins with that root joined to `artifacts/pester/parallel`.
  - Acceptance: the test exists and passes; it uses only the existing injected seams (no `Start-Process`, no sleeps, no temp file, no process-directory change left behind).
- [x] [P2-T2] In the same file add the test `PR11-RELATIVE-ROOT-RESOLVES-AGAINST-CURRENT-LOCATION`: with the same location handling, pass `-Root 'relative-root'` (a name that need not exist) and assert the captured shard command contains `-Root '<GetFullPath of the current location joined with relative-root>'` computed in the test with `[IO.Path]::GetFullPath([IO.Path]::Combine((Get-Location).ProviderPath, 'relative-root'))`.
  - Acceptance: the test exists and passes under the same constraints as P2-T1. If either fallback cannot be reached through an existing seam, the task instead records that finding (seam, reason) in `FEATURE/evidence/other/cr2-root-fallback-unreachable.<timestamp>.md` and adds no seam.
- [x] [P2-T3] Confirm no production file changed: `git diff --name-only` against the merge base of `origin/main` and `HEAD`, paired with `git status --porcelain`, lists no file under `scripts/powershell/PoshQC/` and none under `extensions/drm-copilot/resources/`.
  - Acceptance: zero such paths, so the bundled mirror stays byte-identical to the repository copy with nothing to sync.
- [x] [P2-T4] Existing-test disposition: no production behavior changes, so `PR01` through `PR09` in the same file and `tests/scripts/powershell/PoshQC/` merge tests are unchanged because unaffected; the task writes this disposition in `FEATURE/evidence/other/cr2-test-disposition.<timestamp>.md`.
  - Acceptance: the artifact exists with `Timestamp:` and the disposition statement.

### Phase 3 — Final QA loop and self-review

- [x] [P3-T1] Run PoshQC format (`mcp__drm-copilot__run_poshqc_format`) over the touched test file and write `FEATURE/evidence/qa-gates/poshqc-format.<timestamp>.md`.
  - Acceptance: the artifact carries the four required fields and records a before-and-after observation that the file hash is unchanged by the run (a change restarts the loop).
- [x] [P3-T2] Run a direct `Invoke-ScriptAnalyzer` with `scripts/powershell/PoshQC/settings/pssa.settings.psd1` over the touched test file and write `FEATURE/evidence/qa-gates/pssa.<timestamp>.md`.
  - Acceptance: zero findings, or none beyond the P0-T2 baseline.
- [x] [P3-T3] Run `Invoke-PoshQCTest` for `tests/scripts/powershell/PoshQC` with coverage and write `FEATURE/evidence/qa-gates/pester-poshqc.<timestamp>.md`.
  - Acceptance: zero failures read from `artifacts/pester/pester-junit.xml`; `PR10-OMITTED-ROOT-USES-CURRENT-LOCATION` and `PR11-RELATIVE-ROOT-RESOLVES-AGAINST-CURRENT-LOCATION` each pass; line coverage of `PoshQC.Parallel.psm1` read from `artifacts/pester/powershell-coverage.xml` is at least 96.00% and above the P0-T3 value; the artifact records numeric baseline and post-change values.
- [x] [P3-T4] Run the touched Pester suites in one process in a seeded shuffled file order with three seeds (each seed and its file order recorded) and write `FEATURE/evidence/regression-testing/pester-shuffle.<timestamp>.md`.
  - Acceptance: zero failures for every seed; each seed and file order is listed.
- [x] [P3-T5] Run a fresh single-process Pester run over `tests/scripts/powershell/PoshQC` and write `FEATURE/evidence/regression-testing/pester-single-process.<timestamp>.md`.
  - Acceptance: zero failures read from `artifacts/pester/pester-junit.xml`, confirming `Push-Location`/`Pop-Location` leaves no leaked location.
- [x] [P3-T6] Record the physical line count of the touched test file (counted with `wc -l`) in `FEATURE/evidence/qa-gates/file-size.<timestamp>.md`.
  - Acceptance: the count is at most 800 and is compared with P0-T4.
- [x] [P3-T7] Walk the policy-audit, code-review, and feature-audit templates under `docs/features/templates/policy_audit/` against the branch diff from the merge base of `origin/main` and `HEAD`, and write `FEATURE/evidence/qa-gates/self-review.<timestamp>.md` with one PASS, FAIL, or N/A row per checklist item.
  - Acceptance: no FAIL row; any FAIL is fixed and the Phase 3 loop re-run before this file is rewritten.

## Pre-Mortem

- Review checklists: P3-T7 walks all three review templates against the diff, including tonality of the amended spec wording and the new test names.
- Coverage: CR-2 targets the two uncovered `-Root` statements; P3-T3 asserts `PoshQC.Parallel.psm1` line coverage of at least 96.00% from the coverage XML, and no coverage exclusion is added. PowerShell has no branch gate. Python coverage is not applicable because no Python file is touched.
- Mirror parity: no PoshQC production file or brief fact changes, so the bundle and the six brief copies stay byte-identical; P2-T3 verifies zero production-path changes and no task updates the brief because no stated fact changes.
- File size: P0-T4 and P3-T6 keep the test file at or below 800 logical lines.
- Test isolation: P3-T4 runs the touched Pester suites in a seeded shuffled file order with three seeds, each recorded; P3-T5 runs the single-process CI shape. The location change in the new tests is wrapped in `try`/`finally` with `Pop-Location`. Jest and Python isolation runs are not applicable because no TypeScript or Python file changes.
- CI-only behavior: the new tests build expected roots from `Get-Location` and `GetFullPath`, with no drive letters or backslash literals; they sit outside the Linux hook-suite folders. The CI-dependent criteria stay unchecked for orchestrator step 9.
- Evidence: all artifacts go under `FEATURE/evidence/<kind>/` with `Timestamp:`, `Command:`, `EXIT_CODE:`, `Output Summary:` and write-time UTC stamps; SCRATCH is recorded as the token only.
