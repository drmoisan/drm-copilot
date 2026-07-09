# fix-convertto-commandresult-empty-array (Plan)

- **Issue:** #298
- **Parent (optional):** none
- **Owner:** drmoisan
- **Last Updated:** 2026-07-03T21-26
- **Status:** Draft
- **Version:** 0.2
- **Mode:** minor-audit
- **Requirements source:** `docs/features/active/2026-07-03-fix-convertto-commandresult-empty-array-298/issue.md` (`## Acceptance Criteria` section is the sole AC source for this plan; `spec.md`/`user-story.md` are intentionally absent and are not required)

**Scope:** Exactly two files in scope:
- Production: `scripts/dev-tools/Invoke-FullReleaseFlow.ps1` (one attribute addition to `ConvertTo-CommandResult`'s `$Output` parameter only)
- Test: `tests/scripts/dev-tools/Invoke-FullReleaseFlow.Tests.ps1` (one new `It` case in the existing "helpers" `Context` block only)

No other file may be edited under this plan (specifically not `Invoke-FullRelease.ps1`, `Invoke-ReleaseTagPush.ps1`, `Invoke-GitExe`, `Invoke-GhExe`, `Invoke-ChildPowerShellScript`, or `scripts/powershell/PoshQC/settings/pester.runsettings.psd1`). No PR-authoring task is included in this plan; PR authoring is handled by the orchestrator separately after review.

**Evidence location:** All evidence artifacts produced by this plan MUST be written under `docs/features/active/2026-07-03-fix-convertto-commandresult-empty-array-298/evidence/<kind>/` per `evidence-and-timestamp-conventions`. Timestamps use `yyyy-MM-ddTHH-mm`. Every command-step artifact records `Timestamp:`, `Command:`, `EXIT_CODE:`, and `Output Summary:`.

**Known pre-existing condition (not in scope to fix):** `scripts/powershell/PoshQC/settings/pester.runsettings.psd1`'s `CodeCoverage.Path` is an allowlist that does not currently include `scripts/dev-tools/Invoke-FullReleaseFlow.ps1`. Coverage-enabled Pester runs in this plan will therefore report an aggregate line/branch coverage number computed only over the files already listed in that allowlist; the new test's exercise of `ConvertTo-CommandResult` will pass/fail correctly, but will not move a per-file coverage number for `Invoke-FullReleaseFlow.ps1` because that file is outside the measured set. Each coverage-recording task below must state this caveat explicitly rather than imply a coverage change for the in-scope production file. Modifying the allowlist is out of scope for this two-file bug fix.

### Phase 0 — Baseline Capture

- [x] [P0-T1] Read `.github/copilot-instructions.md`, `.github/instructions/general-code-change.instructions.md`, `.github/instructions/general-unit-test.instructions.md`, `.github/instructions/powershell-code-change.instructions.md`, and `.github/instructions/powershell-unit-test.instructions.md` in that order, then write `docs/features/active/2026-07-03-fix-convertto-commandresult-empty-array-298/evidence/baseline/phase0-instructions-read.md` containing `Timestamp:`, `Policy Order:` (the five files listed above, in order), and an explicit list of files read. Acceptance: the artifact file exists and contains all three required fields.

- [x] [P0-T2] Run `mcp__drm-copilot__run_poshqc_format` in check mode against `scripts/dev-tools/Invoke-FullReleaseFlow.ps1` and `tests/scripts/dev-tools/Invoke-FullReleaseFlow.Tests.ps1`, then write `docs/features/active/2026-07-03-fix-convertto-commandresult-empty-array-298/evidence/baseline/format-baseline.<timestamp>.md` with `Timestamp:`, `Command:`, `EXIT_CODE:`, and `Output Summary:` (pass/fail and whether any file needed formatting). Acceptance: artifact contains all four fields and the recorded `EXIT_CODE` matches the command's actual exit code.

- [x] [P0-T3] Run `mcp__drm-copilot__run_poshqc_analyze` against `scripts/dev-tools/Invoke-FullReleaseFlow.ps1` and `tests/scripts/dev-tools/Invoke-FullReleaseFlow.Tests.ps1`, then write `docs/features/active/2026-07-03-fix-convertto-commandresult-empty-array-298/evidence/baseline/lint-baseline.<timestamp>.md` with `Timestamp:`, `Command:`, `EXIT_CODE:`, and `Output Summary:` (rule violation count, or zero). Acceptance: artifact contains all four fields and the recorded `EXIT_CODE` matches the command's actual exit code.

- [x] [P0-T4] Run `mcp__drm-copilot__run_poshqc_test` using `scripts/powershell/PoshQC/settings/pester.runsettings.psd1`, scoped to `tests/scripts/dev-tools/Invoke-FullReleaseFlow.Tests.ps1`, then write `docs/features/active/2026-07-03-fix-convertto-commandresult-empty-array-298/evidence/baseline/test-baseline.<timestamp>.md` with `Timestamp:`, `Command:`, `EXIT_CODE:`, and `Output Summary:` recording the pass/fail/total test counts and the numeric aggregate line-coverage percent and branch-coverage percent reported by the `CodeCoverage` output, plus the allowlist caveat stated above. Acceptance: artifact contains all four fields, numeric coverage percentages, and the caveat sentence.

- [x] [P0-T5] [expect-fail] Execute `pwsh -NoProfile -Command ". scripts/dev-tools/Invoke-FullReleaseFlow.ps1 -ConfirmToken no; ConvertTo-CommandResult -Output @() -ExitCode 0"` (the `-ConfirmToken no` placeholder is required because dot-sourcing still binds the script's own mandatory top-level `$ConfirmToken` parameter) to confirm the pre-fix defect reproduces, then write `docs/features/active/2026-07-03-fix-convertto-commandresult-empty-array-298/evidence/regression-testing/fail-before-empty-array.<timestamp>.md` with `Timestamp:`, `Command:`, `EXIT_CODE:` (non-zero or terminating-error status), and `Output Summary:` quoting the exact `ConvertTo-CommandResult: Cannot bind argument to parameter 'Output' because it is an empty array.` error text. Acceptance: artifact exists and quotes that exact error text.

### Phase 1 — Constrained Small-Path Implementation

- [x] [P1-T1] Hand off implementation to the small-path implementation engineer, scoping the directive to exactly the first two items of `docs/features/active/2026-07-03-fix-convertto-commandresult-empty-array-298/issue.md`'s `## Acceptance Criteria` section (add `[AllowEmptyCollection()]` to `$Output` only; no other signature or behavior change), then write `docs/features/active/2026-07-03-fix-convertto-commandresult-empty-array-298/evidence/other/phase1-handoff.<timestamp>.md` with `Timestamp:` and the exact scope text delegated. Acceptance: artifact exists and its scope text matches the two AC items verbatim or by direct reference.

- [x] [P1-T2] Add `[AllowEmptyCollection()]` immediately above the `[Parameter(Mandatory = $true)]` line for the `$Output` parameter in the `ConvertTo-CommandResult` function (currently lines 53-65) of `scripts/dev-tools/Invoke-FullReleaseFlow.ps1`, changing no other line in the function or file. Acceptance: `git diff -- scripts/dev-tools/Invoke-FullReleaseFlow.ps1` shows exactly one added line (`[AllowEmptyCollection()]`) and zero other hunks.

- [x] [P1-T3] Add the following `It` case, verbatim, inside the existing "helpers" `Context` block (currently lines 469-483) of `tests/scripts/dev-tools/Invoke-FullReleaseFlow.Tests.ps1`, changing no other test in the file:
  ```powershell
  It "accepts an empty array as Output without throwing" {
      { ConvertTo-CommandResult -Output @() -ExitCode 0 } | Should -Not -Throw
      $result = ConvertTo-CommandResult -Output @() -ExitCode 0
      $result.Output.Count | Should -Be 0
      $result.ExitCode | Should -Be 0
  }
  ```
  Acceptance: `git diff -- tests/scripts/dev-tools/Invoke-FullReleaseFlow.Tests.ps1` shows only the new `It` block added inside the "helpers" `Context`, with zero other hunks.

- [x] [P1-T4] Re-run the exact command from P0-T5 (`pwsh -NoProfile -Command ". scripts/dev-tools/Invoke-FullReleaseFlow.ps1 -ConfirmToken no; ConvertTo-CommandResult -Output @() -ExitCode 0"`) and confirm it now succeeds (`ConvertTo-CommandResult -Output @() -ExitCode 0` returns an object where `Output.Count -eq 0` and `ExitCode -eq 0`), then write `docs/features/active/2026-07-03-fix-convertto-commandresult-empty-array-298/evidence/regression-testing/pass-after-empty-array.<timestamp>.md` with `Timestamp:`, `Command:`, `EXIT_CODE: 0`, and `Output Summary:` confirming `Output.Count -eq 0` and `ExitCode -eq 0`. Acceptance: artifact exists, records `EXIT_CODE: 0`, and confirms both values.

### Phase 2 — Final QC Loop

- [x] [P2-T1] Run `mcp__drm-copilot__run_poshqc_format` against `scripts/dev-tools/Invoke-FullReleaseFlow.ps1` and `tests/scripts/dev-tools/Invoke-FullReleaseFlow.Tests.ps1`; if it auto-fixes any file, restart this loop from this task. Write `docs/features/active/2026-07-03-fix-convertto-commandresult-empty-array-298/evidence/qa-gates/format-final.<timestamp>.md` with `Timestamp:`, `Command:`, `EXIT_CODE:`, `Output Summary:`. Acceptance: artifact exists, all four fields present, and `EXIT_CODE` reflects a clean pass with zero files changed.

- [x] [P2-T2] Run `mcp__drm-copilot__run_poshqc_analyze` against the same two files (autofix via `mcp__drm-copilot__run_poshqc_analyze_autofix` permitted if findings exist); if any finding is reported or any file is autofixed, restart the loop from P2-T1. Write `docs/features/active/2026-07-03-fix-convertto-commandresult-empty-array-298/evidence/qa-gates/lint-final.<timestamp>.md` with `Timestamp:`, `Command:`, `EXIT_CODE:`, `Output Summary:`. Acceptance: artifact exists, all four fields present, and `Output Summary:` reports zero rule violations.

- [x] [P2-T3] Run `mcp__drm-copilot__run_poshqc_test` using `scripts/powershell/PoshQC/settings/pester.runsettings.psd1`, scoped to `tests/scripts/dev-tools/Invoke-FullReleaseFlow.Tests.ps1`; if any test fails, restart the loop from P2-T1. Write `docs/features/active/2026-07-03-fix-convertto-commandresult-empty-array-298/evidence/qa-gates/test-final.<timestamp>.md` with `Timestamp:`, `Command:`, `EXIT_CODE:`, and `Output Summary:` recording the pass/fail/total test counts (must include the new "accepts an empty array as Output without throwing" case as passing), the numeric post-change aggregate line-coverage percent and branch-coverage percent from the `CodeCoverage` output, and the allowlist caveat stated above. Acceptance: artifact exists, all four fields present, the new test case is named explicitly as passing, and numeric coverage percentages are recorded (not a placeholder).

- [x] [P2-T4] Compare the baseline values recorded in `evidence/baseline/test-baseline.<timestamp>.md` (P0-T4) against the final values recorded in `evidence/qa-gates/test-final.<timestamp>.md` (P2-T3), then write `docs/features/active/2026-07-03-fix-convertto-commandresult-empty-array-298/evidence/qa-gates/coverage-delta.<timestamp>.md` with `Timestamp:`, baseline coverage percent, post-change coverage percent, confirmation of no line/branch coverage regression, and confirmation that total passing test count increased by exactly one (the new "accepts an empty array as Output without throwing" case). Acceptance: artifact exists and states all four values (baseline coverage, post-change coverage, regression verdict, test-count delta) explicitly.
