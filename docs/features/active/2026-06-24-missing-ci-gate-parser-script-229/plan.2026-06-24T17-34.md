# missing-ci-gate-parser-script (Plan)

- **Issue:** #229
- **Parent (optional):** none
- **Owner:** drmoisan
- **Last Updated:** 2026-06-24T17-34
- **Status:** Draft
- **Version:** 1.0
- **Work Mode:** full-bug

**Fail-closed evidence rule:** Include explicit baseline artifact tasks, final-QA artifact tasks, and coverage-comparison tasks for the in-scope language (PowerShell) per policy. If any required baseline artifact, QA artifact, or coverage-comparison artifact is missing, the audit verdict must be BLOCKED or INCOMPLETE, never PASS.

**Evidence accounting rule:** Each evidence-producing task records the expected artifact path. Do not mark evidence-backed work complete without the artifact. All evidence is written under `docs/features/active/2026-06-24-missing-ci-gate-parser-script-229/evidence/<kind>/`. Non-canonical evidence locations (e.g., `artifacts/baselines/`, `artifacts/qa/`, `artifacts/coverage/`) are prohibited.

## Bundling / Mirror Determination (Resolved by Inspection)

A bundled mirror task under `extensions/drm-copilot/resources/scripts/` is NOT required. Evidence:

- `extensions/drm-copilot/resources/scripts/` contains only a `dev_tools/` Python subtree. There is no `orchestration/`, `powershell/`, or `bash/` subdirectory under that mirror root.
- The sync engine (`extensions/drm-copilot/resources/scripts/dev_tools/agentic_sync.py`) scopes synchronization to `.github` roots, not to `scripts/orchestration/`, `scripts/powershell/`, or `scripts/bash/`.
- The new file `scripts/orchestration/Invoke-CiGateParser.ps1` resides in a path that is not part of any mirrored subtree.

Conclusion: No mirror task is included. The script and its test are authored only under the primary repository paths.

## gh `bucket` Enum Mapping (Explicit, Conservative)

`gh pr checks --required --json bucket,...` reports a per-check `bucket` enum. The parser maps each value as follows:

- `pass`     -> contributes to `success` (a passing required check).
- `fail`     -> forces `conclusion = failure`.
- `cancel`   -> forces `conclusion = failure` (a cancelled required check is treated conservatively as not-passing/terminal-non-success).
- `pending`  -> contributes to `pending` (still in progress).
- `skipping` -> treated as non-blocking: a skipped required check does not force failure and does not force pending; it neither contributes to failure nor to pending. Documented rationale: a skipped check produced no adverse signal and has reached a terminal state, so it is not a regression and is not in progress.

Derivation precedence (evaluated in order over the required-check set):

1. If any check is `fail` or `cancel` -> `failure`.
2. Else if any check is `pending` -> `pending`.
3. Else -> `success` (all remaining checks are `pass` or `skipping`).

Empty required-check set (deterministic, documented): when the input array is empty (no required checks configured), `conclusion = success`. Rationale: there are no required checks that can fail or be in progress, so the gate is vacuously satisfied. This is the single deterministic treatment and is asserted in tests.

Unknown/unrecognized bucket value: forces `conclusion = failure` and the parser throws/writes an explicit error identifying the unrecognized value (fail-fast per general code-change policy). This prevents a silent pass on an enum the parser does not understand.

### Phase 0 — Policy Read & Baseline Capture

- [x] [P0-T1] Read policy files in required order and record evidence to `docs/features/active/2026-06-24-missing-ci-gate-parser-script-229/evidence/baseline/phase0-instructions-read.md`. Artifact MUST contain `Timestamp:`, `Policy Order:`, and an explicit list of files read: `CLAUDE.md`, `.claude/rules/general-code-change.md`, `.claude/rules/general-unit-test.md`, `.claude/rules/powershell.md`, `.claude/rules/quality-tiers.md`. Acceptance: artifact exists with all three required fields populated.
- [x] [P0-T2] Read `.claude/skills/orchestrate/SKILL.md` Step S9 and Checkpoint Schema sections and record the contract fields the script must emit (`head_sha`, `pr_pipeline_run_id`, `pr_pipeline_run_url`, `conclusion`, `verified_at`) to `docs/features/active/2026-06-24-missing-ci-gate-parser-script-229/evidence/baseline/phase0-s9-contract.md`. Acceptance: artifact lists all five `ci_gate` fields and the three conclusion derivation rules.
- [x] [P0-T3] Confirm `scripts/orchestration/Invoke-CiGateParser.ps1` does not exist (`Test-Path` returns `$false`) and that `tests/scripts/orchestration/Invoke-CiGateParser.Tests.ps1` does not exist; record both results to `docs/features/active/2026-06-24-missing-ci-gate-parser-script-229/evidence/baseline/phase0-absence-baseline.md` with `Timestamp:`, `Command:`, `EXIT_CODE:`, `Output Summary:`. Acceptance: artifact records both paths as absent.
- [x] [P0-T4] Capture PowerShell formatting baseline by running `mcp__drm-copilot__run_poshqc_format` against the existing `scripts/` and `tests/` PowerShell scope; record to `docs/features/active/2026-06-24-missing-ci-gate-parser-script-229/evidence/baseline/phase0-poshqc-format-baseline.md` with `Timestamp:`, `Command:`, `EXIT_CODE:`, `Output Summary:`. Acceptance: artifact records exit code and whether any files would be reformatted.
- [x] [P0-T5] Capture PowerShell analyzer baseline by running `mcp__drm-copilot__run_poshqc_analyze`; record to `docs/features/active/2026-06-24-missing-ci-gate-parser-script-229/evidence/baseline/phase0-poshqc-analyze-baseline.md` with `Timestamp:`, `Command:`, `EXIT_CODE:`, `Output Summary:` (rule violation count). Acceptance: artifact records the analyzer exit code and violation count.
- [x] [P0-T6] Capture PowerShell test/coverage baseline by running `mcp__drm-copilot__run_poshqc_test` in coverage mode using `scripts/powershell/PoshQC/settings/pester.runsettings.psd1`; record to `docs/features/active/2026-06-24-missing-ci-gate-parser-script-229/evidence/baseline/phase0-pester-baseline.md` with `Timestamp:`, `Command:`, `EXIT_CODE:`, `Output Summary:` including numeric baseline line and branch coverage percentages. Acceptance: artifact records numeric baseline coverage headline values (not placeholders).

### Phase 1 — Author Parser Script

- [x] [P1-T1] Create directory `scripts/orchestration/` and write `scripts/orchestration/Invoke-CiGateParser.ps1` as an advanced function with `[CmdletBinding()]`, accepting required parameters `-ChecksJson` (string, accepts the `gh pr checks` JSON array; `[Parameter(Mandatory, ValueFromPipeline)]` so the JSON can be piped/stdin) and `-HeadSha` (string, `[ValidateNotNullOrEmpty()]`), and optional parameters `-PrPipelineRunId`, `-PrPipelineRunUrl`, and an injectable clock delegate `-NowProvider` (`[ScriptBlock]`) defaulting to a UTC `Get-Date` producing ISO-8601. The script MUST NOT invoke `gh`. Acceptance: file exists, parses with no syntax errors, defines the parameters with the stated validation attributes.
- [x] [P1-T2] In the same file, implement a pure derivation helper function (e.g., `Get-CiGateConclusion`) that takes a parsed checks array and returns one of `success`/`failure`/`pending` using the precedence in this plan's "gh bucket Enum Mapping" section, including empty-set -> `success` and unknown-bucket -> fail-fast error. Acceptance: function is pure (no I/O, no gh calls), and its branch logic matches the documented precedence exactly.
- [x] [P1-T3] In the same file, implement a thin wrapper (the advanced function body) that: parses `-ChecksJson` via `ConvertFrom-Json` inside a `try/catch` that throws an explicit error on malformed JSON; calls the pure derivation helper; constructs the `ci_gate` object with fields `head_sha`, `pr_pipeline_run_id`, `pr_pipeline_run_url`, `conclusion`, `verified_at` (ISO-8601 from `-NowProvider`); and emits it as a PowerShell object (and supports JSON emission). Acceptance: invoking the function with a valid sample returns an object containing all five fields populated from inputs and derivation.
- [x] [P1-T4] Confirm `scripts/orchestration/Invoke-CiGateParser.ps1` is under 500 lines, uses approved PowerShell verbs, avoids global/script-scoped mutable state, and uses no temporary files. Acceptance: line count < 500 and no `New-TemporaryFile`/temp-path usage present.

### Phase 2 — Author Pester Tests

- [x] [P2-T1] Create `tests/scripts/orchestration/Invoke-CiGateParser.Tests.ps1` with Pester v5 `Describe`/`Context`/`It` structure that dot-sources / imports the script under test deterministically (no live `gh`, no network, no temp files). Acceptance: file exists and imports the script function without invoking external executables.
- [x] [P2-T2] Add test: all required checks `pass` -> `conclusion == "success"`. Acceptance: `It` asserts `success`.
- [x] [P2-T3] Add test: any required check `fail` -> `conclusion == "failure"`. Acceptance: `It` asserts `failure`.
- [x] [P2-T4] Add test: any required check `pending` (with no fail) -> `conclusion == "pending"`. Acceptance: `It` asserts `pending`.
- [x] [P2-T5] Add test: a `cancel` bucket among otherwise-passing checks -> `conclusion == "failure"` (cancel mapped to failure). Acceptance: `It` asserts `failure`.
- [x] [P2-T6] Add test: a `skipping` bucket among otherwise-passing checks -> `conclusion == "success"` (skipping is non-blocking, non-pending). Acceptance: `It` asserts `success`.
- [x] [P2-T7] Add test: empty required-check array -> `conclusion == "success"` (documented vacuous-satisfaction). Acceptance: `It` asserts `success`.
- [x] [P2-T8] Add test: malformed JSON input -> the function throws an explicit error. Acceptance: `It` uses `{ ... } | Should -Throw` with a message assertion identifying malformed JSON.
- [x] [P2-T9] Add test: unknown/unrecognized bucket value -> the function throws an explicit error naming the unrecognized value. Acceptance: `It` asserts the throw and the value is referenced in the message.
- [x] [P2-T10] Add test: `verified_at` is produced via the injected `-NowProvider` clock delegate, asserting an exact deterministic ISO-8601 value (no wall-clock read). Acceptance: `It` injects a fixed clock and asserts the exact `verified_at` string.
- [x] [P2-T11] Add test: field passthrough — `head_sha`, `pr_pipeline_run_id`, `pr_pipeline_run_url` in the emitted object equal the corresponding input parameters. Acceptance: `It` asserts each field equals its input.

### Phase 3 — Final QA Loop (PowerShell)

- [x] [P3-T1] Run `mcp__drm-copilot__run_poshqc_format` over the new script and test; if it changes files, restart this phase from this task. Record to `docs/features/active/2026-06-24-missing-ci-gate-parser-script-229/evidence/qa-gates/p3-poshqc-format.md` with `Timestamp:`, `Command:`, `EXIT_CODE:`, `Output Summary:`. Acceptance: format reports a clean pass with no further changes.
- [x] [P3-T2] Run `mcp__drm-copilot__run_poshqc_analyze`; if violations are reported, fix and restart from P3-T1. Record to `docs/features/active/2026-06-24-missing-ci-gate-parser-script-229/evidence/qa-gates/p3-poshqc-analyze.md` with `Timestamp:`, `Command:`, `EXIT_CODE:`, `Output Summary:` (0 violations required). Acceptance: analyzer reports 0 violations.
- [x] [P3-T3] Run `mcp__drm-copilot__run_poshqc_test` in coverage mode using `scripts/powershell/PoshQC/settings/pester.runsettings.psd1`; if any test fails or files change, fix and restart from P3-T1. Record to `docs/features/active/2026-06-24-missing-ci-gate-parser-script-229/evidence/qa-gates/p3-pester.md` with `Timestamp:`, `Command:`, `EXIT_CODE:`, `Output Summary:` including all-tests-pass status and numeric post-change line and branch coverage. Acceptance: all tests pass and coverage values are recorded.
- [x] [P3-T4] Verify coverage thresholds and no-regression: confirm line coverage for `scripts/orchestration/Invoke-CiGateParser.ps1` is >= 85% and branch coverage >= 75%, and that overall coverage did not regress versus the P0-T6 baseline. Record baseline, post-change, and new-code coverage to `docs/features/active/2026-06-24-missing-ci-gate-parser-script-229/evidence/qa-gates/p3-coverage-delta.md`. Acceptance: new-script line coverage >= 85%, branch >= 75%, no regression on changed lines; if any value is unavailable, mark remediation-required (not PASS).

### Phase 4 — Acceptance-Criteria Verification & Branch Confirmation

- [x] [P4-T1] Run `scripts/orchestration/Invoke-CiGateParser.ps1` against a representative all-pass JSON sample and confirm the emitted `ci_gate.conclusion == "success"` with all five fields populated. Record to `docs/features/active/2026-06-24-missing-ci-gate-parser-script-229/evidence/regression-testing/p4-branch-success.md` with `Timestamp:`, `Command:`, `EXIT_CODE:`, `Output Summary:`. Acceptance: emitted object shows `success`.
- [x] [P4-T2] Run the script against a representative any-fail JSON sample and confirm `conclusion == "failure"`. Record to `docs/features/active/2026-06-24-missing-ci-gate-parser-script-229/evidence/regression-testing/p4-branch-failure.md`. Acceptance: emitted object shows `failure`.
- [x] [P4-T3] Run the script against a representative any-pending JSON sample and confirm `conclusion == "pending"`. Record to `docs/features/active/2026-06-24-missing-ci-gate-parser-script-229/evidence/regression-testing/p4-branch-pending.md`. Acceptance: emitted object shows `pending`.
- [x] [P4-T4] Map each issue #229 expectation to evidence and confirm coverage: (a) script exists at `scripts/orchestration/Invoke-CiGateParser.ps1` [P1-T1]; (b) parses `gh pr checks` JSON into the `ci_gate` object [P1-T3]; (c) derives `conclusion` as success/failure/pending [P1-T2, P4-T1..T3]; (d) unit coverage for success/failure/pending and malformed JSON [P2-T2..T4, P2-T8]. Record the mapping to `docs/features/active/2026-06-24-missing-ci-gate-parser-script-229/evidence/issue-updates/p4-ac-checkoff.md`. Acceptance: every listed expectation has a passing evidence reference.
- [x] [P4-T5] Record final branch/commit state and the list of produced files (`scripts/orchestration/Invoke-CiGateParser.ps1`, `tests/scripts/orchestration/Invoke-CiGateParser.Tests.ps1`) to `docs/features/active/2026-06-24-missing-ci-gate-parser-script-229/evidence/issue-updates/p4-end-state.md` with `Timestamp:`. Acceptance: artifact lists both files and the current commit.
