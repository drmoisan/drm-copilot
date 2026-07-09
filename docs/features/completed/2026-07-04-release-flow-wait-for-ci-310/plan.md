# release-flow-wait-for-ci (Plan) — Issue #310

- **Issue:** #310
- **Feature folder:** `docs/features/active/2026-07-04-release-flow-wait-for-ci-310`
- **Work Mode:** full-bug (per `issue.md`)
- **Production file in scope:** `scripts/dev-tools/Invoke-FullReleaseFlow.ps1`
- **Test files in scope:** `tests/scripts/dev-tools/Invoke-FullReleaseFlow.Tests.ps1`, `tests/scripts/dev-tools/Invoke-FullReleaseFlow.AdditionalFailurePaths.Tests.ps1`, and a new sibling `tests/scripts/dev-tools/Invoke-FullReleaseFlow.ChecksWait.Tests.ps1`
- **Evidence root:** `docs/features/active/2026-07-04-release-flow-wait-for-ci-310/evidence/` (canonical `<FEATURE>/evidence/<kind>/` scheme; no `artifacts/baselines|qa|coverage/` paths are used)

## Root Cause (already diagnosed)

`Invoke-FullReleaseFlowGuarded` in `scripts/dev-tools/Invoke-FullReleaseFlow.ps1` calls `gh pr checks $prNumber --watch` exactly once right after `gh pr create`. GitHub takes several seconds to register workflow checks after PR creation; during that window `gh pr checks --watch` finds no checks and exits non-zero immediately, so the flow declares failure and returns 1 before CI has run, even though the checks subsequently pass.

## Acceptance Criteria (spec.md is an unfilled template; this section is the authoritative AC source for this plan)

- [x] AC1 — The flow waits (bounded) for required checks to **register** before treating an empty/not-yet-reported check set as a failure. Mapped: Phase 2 (P2-T1), Phase 5 (P5-T1).
- [x] AC2 — The flow waits (bounded) for registered checks to **complete** (leave the pending bucket) before evaluating pass/fail. Mapped: Phase 2 (P2-T1), Phase 5 (P5-T2).
- [x] AC3 — `gh pr merge ... --merge --delete-branch` runs only after every required check reports bucket `pass` or `skipping`. Mapped: Phase 3 (P3-T1), Phase 4 (P4-T2).
- [x] AC4 — On a genuine check failure (bucket `fail`/`cancel`), the flow returns 1 and performs no merge and no tag push. Mapped: Phase 3 (P3-T1), Phase 4 (P4-T3), Phase 5 (P5-T5).
- [x] AC5 — On registration timeout or completion timeout, the flow returns 1 and performs no merge and no tag push. Mapped: Phase 5 (P5-T3, P5-T4).
- [x] AC6 — All new/updated tests use the existing dot-source + `Mock` seam pattern (`Invoke-GhExe`, `Invoke-GitExe`, `Invoke-ChildPowerShellScript`, `Invoke-Sleep`, `Write-StderrLine`); no real git/gh/network/sleep. Mapped: Phase 4, Phase 5.
- [x] AC7 — Full PowerShell toolchain (format → analyze → test-with-coverage) passes in a single clean pass, with no line/branch coverage regression on `scripts/dev-tools/Invoke-FullReleaseFlow.ps1`. Mapped: Phase 6.
- [x] AC8 — `scripts/dev-tools/Invoke-FullReleaseFlow.ps1` and every touched test file remain <= 500 lines. Mapped: Phase 3 (P3-T5), Phase 5 (P5-T7).

## Exact Function Contracts To Implement (binding on Phase 1–3 tasks)

```powershell
function Invoke-Sleep {
    # Wrapper seam: Start-Sleep -Seconds $Seconds. Mandatory [int]$Seconds. OutputType([void]).
}

function Wait-ForPullRequestChecks {
    # Params: [string]$PrNumber (mandatory),
    #         [int]$RegistrationMaxAttempts = 24, [int]$RegistrationIntervalSeconds = 5,
    #         [int]$CompletionMaxAttempts = 60, [int]$CompletionIntervalSeconds = 10.
    # OutputType([int]): 0 = success, 1 = timeout or genuine failure.
    # Poll command (both phases): Invoke-GhExe -GhArgs @('pr','checks',$PrNumber,'--required','--json','bucket')
    # Phase A (registration): while poll.ExitCode -ne 0, Invoke-Sleep -Seconds $RegistrationIntervalSeconds and retry,
    #   up to $RegistrationMaxAttempts. Exhausted -> Write-StderrLine "Pull request checks did not register within
    #   the timeout for PR #$PrNumber." ; return 1.
    # Once poll.ExitCode -eq 0, join Output lines and ConvertFrom-Json to an array of {bucket} objects.
    # Phase B (completion): if any bucket is 'fail' or 'cancel' -> Write-StderrLine "A required check failed for
    #   PR #$PrNumber." ; return 1 immediately (no further waiting). If all buckets are 'pass' or 'skipping' ->
    #   return 0. If any bucket is 'pending' -> Invoke-Sleep -Seconds $CompletionIntervalSeconds, re-poll with the
    #   same gh args, re-evaluate, up to $CompletionMaxAttempts. Exhausted while still pending -> Write-StderrLine
    #   "Pull request checks did not complete within the timeout for PR #$PrNumber." ; return 1.
}
```

Wiring in `Invoke-FullReleaseFlowGuarded`: replace the single `$checks = Invoke-GhExe -GhArgs @('pr','checks',$prNumber,'--watch')` block with:

```powershell
$checksResult = Wait-ForPullRequestChecks -PrNumber $prNumber
if ($checksResult -ne 0) {
    return 1
}
```

(`Wait-ForPullRequestChecks` itself writes the specific stderr message; the guarded function does not add a second message.)

---

### Phase 0 — Baseline Capture

- [x] [P0-T1] Read `.claude/rules/CLAUDE.md`, `.claude/rules/general-code-change.md`, `.claude/rules/general-unit-test.md`, `.claude/rules/quality-tiers.md`, and `.claude/rules/powershell.md` in that order, then write `docs/features/active/2026-07-04-release-flow-wait-for-ci-310/evidence/baseline/phase0-instructions-read.md` containing `Timestamp:`, `Policy Order:` (the five file paths in the order read), and a completion line per file. Acceptance: file exists with all five paths listed in order.
  - Verify: `Read` the artifact and confirm all five entries are present.
- [x] [P0-T2] Capture a PoshQC format baseline for the four in-scope files (production script + two existing test files; new test file does not exist yet so is out of scope for this task) and write `docs/features/active/2026-07-04-release-flow-wait-for-ci-310/evidence/baseline/format-baseline.<timestamp>.md` with `Timestamp:`, `Command:`, `EXIT_CODE:`, `Output Summary:`.
  - Verify: `mcp__drm-copilot__run_poshqc_format` against `scripts/dev-tools/Invoke-FullReleaseFlow.ps1`, `tests/scripts/dev-tools/Invoke-FullReleaseFlow.Tests.ps1`, `tests/scripts/dev-tools/Invoke-FullReleaseFlow.AdditionalFailurePaths.Tests.ps1`; EXIT_CODE 0 and no files changed is the pass condition recorded in the artifact.
- [x] [P0-T3] Capture a PSScriptAnalyzer baseline for the same three files and write `docs/features/active/2026-07-04-release-flow-wait-for-ci-310/evidence/baseline/lint-baseline.<timestamp>.md` with `Timestamp:`, `Command:`, `EXIT_CODE:`, `Output Summary:` (finding count).
  - Verify: `mcp__drm-copilot__run_poshqc_analyze` against the same three files.
- [x] [P0-T4] Capture a Pester baseline run with coverage enabled (`scripts/powershell/PoshQC/settings/pester.runsettings.psd1`) scoped to `tests/scripts/dev-tools/Invoke-FullReleaseFlow.Tests.ps1` and `tests/scripts/dev-tools/Invoke-FullReleaseFlow.AdditionalFailurePaths.Tests.ps1`, and write `docs/features/active/2026-07-04-release-flow-wait-for-ci-310/evidence/baseline/test-baseline.<timestamp>.md` with `Timestamp:`, `Command:`, `EXIT_CODE:`, `Output Summary:` including numeric line and branch coverage for `scripts/dev-tools/Invoke-FullReleaseFlow.ps1` (currently in the `CodeCoverage.Path` allowlist).
  - Verify: `mcp__drm-copilot__run_poshqc_test` with the runsettings above; EXIT_CODE 0, all existing tests passing, coverage percentages recorded.

### Phase 1 — Add Mockable Sleep Seam

- [x] [P1-T1] Add the `Invoke-Sleep` function to `scripts/dev-tools/Invoke-FullReleaseFlow.ps1` immediately after `Invoke-ChildPowerShellScript`, matching the contract above (mandatory `[int]$Seconds`, calls `Start-Sleep -Seconds $Seconds`, `[OutputType([void])]`, full comment-based help with `.SYNOPSIS`/`.DESCRIPTION`/`.PARAMETER Seconds`/`.OUTPUTS`).
  - Verify: `Grep` for `function Invoke-Sleep` in the file returns exactly one match.
- [x] [P1-T2] Run PoshQC format on `scripts/dev-tools/Invoke-FullReleaseFlow.ps1` and confirm no residual diff beyond the `Invoke-Sleep` addition.
  - Verify: `mcp__drm-copilot__run_poshqc_format` on `scripts/dev-tools/Invoke-FullReleaseFlow.ps1`; EXIT_CODE 0, no further file changes on a second run.
- [x] [P1-T3] Run PoshQC analyze on `scripts/dev-tools/Invoke-FullReleaseFlow.ps1` and confirm zero findings.
  - Verify: `mcp__drm-copilot__run_poshqc_analyze` on `scripts/dev-tools/Invoke-FullReleaseFlow.ps1`; 0 findings.

### Phase 2 — Add Bounded Checks-Wait Function

- [x] [P2-T1] Implement `Wait-ForPullRequestChecks` in `scripts/dev-tools/Invoke-FullReleaseFlow.ps1` (placed after `Invoke-Sleep` and before `Invoke-FullReleaseFlowGuarded`) exactly per the contract above: registration loop bounded by `RegistrationMaxAttempts`/`RegistrationIntervalSeconds`, completion loop bounded by `CompletionMaxAttempts`/`CompletionIntervalSeconds`, gh poll args `@('pr','checks',$PrNumber,'--required','--json','bucket')`, JSON parsed via `ConvertFrom-Json` on the joined output, bucket classification (`fail`/`cancel` = genuine failure, `pending` = keep waiting, `pass`/`skipping` = success), and full comment-based help.
  - Verify: `Grep` for `function Wait-ForPullRequestChecks` in the file returns exactly one match; functional correctness is verified by Phase 5 tests.
- [x] [P2-T2] Run PoshQC format on `scripts/dev-tools/Invoke-FullReleaseFlow.ps1`; confirm no residual diff.
  - Verify: `mcp__drm-copilot__run_poshqc_format` on `scripts/dev-tools/Invoke-FullReleaseFlow.ps1`; EXIT_CODE 0.
- [x] [P2-T3] Run PoshQC analyze on `scripts/dev-tools/Invoke-FullReleaseFlow.ps1`; confirm zero findings.
  - Verify: `mcp__drm-copilot__run_poshqc_analyze` on `scripts/dev-tools/Invoke-FullReleaseFlow.ps1`; 0 findings.

### Phase 3 — Wire Wait Function Into Guarded Flow

- [x] [P3-T1] In `Invoke-FullReleaseFlowGuarded`, replace the `$checks = Invoke-GhExe -GhArgs @('pr','checks',$prNumber,'--watch')` block (and its `if ($checks.ExitCode -ne 0) { ...; return 1 }` guard) with the `$checksResult = Wait-ForPullRequestChecks -PrNumber $prNumber; if ($checksResult -ne 0) { return 1 }` block shown above, leaving the subsequent `gh pr merge $prNumber --merge --delete-branch` call unchanged.
  - Verify: `Grep` for `pr', 'checks'` in the file with `--watch` returns zero matches; `Grep` for `Wait-ForPullRequestChecks` in `Invoke-FullReleaseFlowGuarded` returns one match.
- [x] [P3-T2] Confirm no other call site (`Invoke-FullReleaseFlowGuarded` preflight, PR-number resolution, post-merge checkout/pull/tag-push blocks) was altered.
  - Verify: `Read` `scripts/dev-tools/Invoke-FullReleaseFlow.ps1` and diff by inspection against the pre-change version captured in P0 evidence; confirm only the checks block changed.
- [x] [P3-T3] Run PoshQC format on `scripts/dev-tools/Invoke-FullReleaseFlow.ps1`; confirm no residual diff.
  - Verify: `mcp__drm-copilot__run_poshqc_format` on `scripts/dev-tools/Invoke-FullReleaseFlow.ps1`; EXIT_CODE 0.
- [x] [P3-T4] Run PoshQC analyze on `scripts/dev-tools/Invoke-FullReleaseFlow.ps1`; confirm zero findings.
  - Verify: `mcp__drm-copilot__run_poshqc_analyze` on `scripts/dev-tools/Invoke-FullReleaseFlow.ps1`; 0 findings.
- [x] [P3-T5] Confirm `scripts/dev-tools/Invoke-FullReleaseFlow.ps1` is <= 500 lines after all Phase 1–3 changes.
  - Verify: `Read` the file and confirm the reported total line count is <= 500.

### Phase 4 — Update Existing Pester Tests For The New Call Sequence

- [x] [P4-T1] In `tests/scripts/dev-tools/Invoke-FullReleaseFlow.Tests.ps1`, update `Initialize-SuccessfulGhFlowMock` so the branch matching `'pr checks 291 --watch'` is replaced with a branch matching `'pr checks 291 --required --json bucket'` that returns `@{ Output = @('[{"bucket":"pass"}]'); ExitCode = 0 }`.
  - Verify: `Grep` for `--watch` in this file returns zero matches.
- [x] [P4-T2] Update the "successful automated flow" `It` block's `$ghFlat` assertion to expect the sequence `@('pr view release/full-20260703171500 --json number --jq .number', 'pr checks 291 --required --json bucket', 'pr merge 291 --merge --delete-branch')`.
  - Verify: `mcp__drm-copilot__run_poshqc_test` scoped to this file's "successful automated flow" test; the test passes.
- [x] [P4-T3] Update the "stops before merge, pull, and tag push when checks fail" `It` block: change the gh mock's `'pr checks 291 --watch'` branch to a `'pr checks 291 --required --json bucket'` branch returning `@{ Output = @('[{"bucket":"fail"}]'); ExitCode = 0 }`, and change the expected message match from `"checks did not pass"` to `"A required check failed for PR #291"`.
  - Verify: `mcp__drm-copilot__run_poshqc_test` scoped to this test; the test passes and asserts no merge, no checkout, no pull, no tag push (existing assertions retained).
- [x] [P4-T4] In `tests/scripts/dev-tools/Invoke-FullReleaseFlow.Tests.ps1`, in the "stops before checkout, pull, and tag push when merge fails" `It` block (the gh mock around the current line 334), update the inline `Invoke-GhExe` mock's `'pr checks 291 --watch'` branch (currently returns `@{ Output = @('checks passed'); ExitCode = 0 }`) to match `'pr checks 291 --required --json bucket'` and return `@{ Output = @('[{"bucket":"pass"}]'); ExitCode = 0 }`, so the checks-wait step succeeds and the test continues to exercise only the merge-failure path (`$result | Should -Be 1`, message `"merge failed"`).
  - Verify: `Grep` for `--watch` in this file returns zero matches; run `mcp__drm-copilot__run_poshqc_test` scoped to the "stops before checkout, pull, and tag push when merge fails" test; the test passes.
- [x] [P4-T5] Add `Mock -CommandName Invoke-Sleep -MockWith { param([int]$Seconds) $null = $Seconds }` to the shared `BeforeEach` block in `tests/scripts/dev-tools/Invoke-FullReleaseFlow.Tests.ps1` so no test in this file invokes real `Start-Sleep`.
  - Verify: `Grep` for `Invoke-Sleep` in this file returns at least one `Mock -CommandName Invoke-Sleep` registration.
- [x] [P4-T6] In `tests/scripts/dev-tools/Invoke-FullReleaseFlow.AdditionalFailurePaths.Tests.ps1`, update the gh mock used by the `'<Scenario>'`-parameterized "post-PR scenario" test so that a branch matching `$joined -match '^pr checks '` returns `@{ Output = @('[{"bucket":"pass"}]'); ExitCode = 0 }` before the existing generic `@{ Output = @('ok'); ExitCode = 0 }` fallback, so the `PullMain` and `TagPush` scenarios (which reach the checks-wait call) resolve to success. This file does not currently mock `pr checks` explicitly (its default fallback returns generic `@{ Output = @('ok'); ExitCode = 0 }` for anything except `pr view`); confirm by inspection that a raw `'ok'` string is not valid JSON for `ConvertFrom-Json` bucket parsing, so the explicit `^pr checks ` branch added by this task is required — the generic fallback alone is not sufficient for the new poll call to classify as passing.
  - Verify: `Grep` for `pr checks` in this file returns at least one match.
- [x] [P4-T7] Add `Mock -CommandName Invoke-Sleep -MockWith { param([int]$Seconds) $null = $Seconds }` to the shared `BeforeEach` block in `tests/scripts/dev-tools/Invoke-FullReleaseFlow.AdditionalFailurePaths.Tests.ps1`.
  - Verify: `Grep` for `Invoke-Sleep` in this file returns at least one `Mock -CommandName Invoke-Sleep` registration.
- [x] [P4-T8] Run the full Pester suite for both updated files and confirm all tests pass.
  - Verify: `mcp__drm-copilot__run_poshqc_test` scoped to `tests/scripts/dev-tools/Invoke-FullReleaseFlow.Tests.ps1` and `tests/scripts/dev-tools/Invoke-FullReleaseFlow.AdditionalFailurePaths.Tests.ps1`; EXIT_CODE 0, 0 failed.
- [x] [P4-T9] Grep for the exact string `pr checks 291 --watch` across both `tests/scripts/dev-tools/Invoke-FullReleaseFlow.Tests.ps1` and `tests/scripts/dev-tools/Invoke-FullReleaseFlow.AdditionalFailurePaths.Tests.ps1` and confirm zero matches in either file, verifying no stale `--watch` mock branch (including the third branch at the former line ~334, addressed by P4-T4) remains in either file.
  - Verify: `Grep` for the literal string `pr checks 291 --watch` across both files with `output_mode: count`; total match count across both files is 0.

### Phase 5 — Add New Pester Tests For `Wait-ForPullRequestChecks` Scenarios

- [x] [P5-T1] Create `tests/scripts/dev-tools/Invoke-FullReleaseFlow.ChecksWait.Tests.ps1` (dot-sourcing the production script the same way as the existing test files) with an `It` "waits through the registration race then merges" test: mock `Invoke-GhExe` so the `pr checks ... --required --json bucket` call returns `@{ Output = @('no checks reported on the ''release/full-20260703171500'' branch'); ExitCode = 1 }` for the first 2 calls, then `@{ Output = @('[{"bucket":"pass"}]'); ExitCode = 0 }` on the 3rd call; mock `Invoke-Sleep` to record invocation count; assert `Wait-ForPullRequestChecks -PrNumber '291' -RegistrationMaxAttempts 5 -RegistrationIntervalSeconds 1` returns `0` and `Invoke-Sleep` was called exactly 2 times.
  - Verify: `mcp__drm-copilot__run_poshqc_test` scoped to this file's registration-race test; the test passes.
- [x] [P5-T2] Add an `It` "waits through pending checks then completes" test: mock `Invoke-GhExe` so the first poll returns `@{ Output = @('[{"bucket":"pending"}]'); ExitCode = 0 }` and the second poll returns `@{ Output = @('[{"bucket":"pass"}]'); ExitCode = 0 }`; mock `Invoke-Sleep`; assert `Wait-ForPullRequestChecks -PrNumber '291' -CompletionMaxAttempts 5 -CompletionIntervalSeconds 1` returns `0` and `Invoke-Sleep` was called exactly 1 time.
  - Verify: `mcp__drm-copilot__run_poshqc_test` scoped to this test; the test passes.
- [x] [P5-T3] Add an `It` "returns failure on registration timeout" test: mock `Invoke-GhExe` so every poll returns `@{ Output = @('no checks reported'); ExitCode = 1 }`; mock `Invoke-Sleep`; mock `Write-StderrLine` to capture the message; assert `Wait-ForPullRequestChecks -PrNumber '291' -RegistrationMaxAttempts 3 -RegistrationIntervalSeconds 1` returns `1`, the captured message matches `"did not register within the timeout"`, and `Invoke-GhExe` was called exactly 3 times.
  - Verify: `mcp__drm-copilot__run_poshqc_test` scoped to this test; the test passes.
- [x] [P5-T4] Add an `It` "returns failure on completion timeout" test: mock `Invoke-GhExe` so every poll returns `@{ Output = @('[{"bucket":"pending"}]'); ExitCode = 0 }`; mock `Invoke-Sleep`; mock `Write-StderrLine` to capture the message; assert `Wait-ForPullRequestChecks -PrNumber '291' -CompletionMaxAttempts 3 -CompletionIntervalSeconds 1` returns `1` and the captured message matches `"did not complete within the timeout"`.
  - Verify: `mcp__drm-copilot__run_poshqc_test` scoped to this test; the test passes.
- [x] [P5-T5] Add an `It` "returns failure immediately on a genuine check failure without exhausting the completion timeout" test: mock `Invoke-GhExe` so the first poll returns `@{ Output = @('[{"bucket":"fail"}]'); ExitCode = 0 }`; mock `Invoke-Sleep`; mock `Write-StderrLine` to capture the message; assert `Wait-ForPullRequestChecks -PrNumber '291' -CompletionMaxAttempts 50` returns `1`, the captured message matches `"A required check failed for PR #291"`, and `Invoke-GhExe` was called exactly 1 time (no further polling).
  - Verify: `mcp__drm-copilot__run_poshqc_test` scoped to this test; the test passes.
- [x] [P5-T6] Add an `It` "invokes the sleep seam between registration polls and between completion polls" test asserting `Should -Invoke -CommandName Invoke-Sleep` with the exact expected `-Times` count for a combined scenario (2 registration retries + 1 completion retry = 3 total sleeps) using the same mock shapes as P5-T1/P5-T2 combined into one scenario.
  - Verify: `mcp__drm-copilot__run_poshqc_test` scoped to this test; the test passes.
- [x] [P5-T7] Confirm `tests/scripts/dev-tools/Invoke-FullReleaseFlow.ChecksWait.Tests.ps1` is <= 500 lines. If it exceeds 500 lines, split the completion/timeout scenarios (P5-T3, P5-T4, P5-T6) into a sibling `tests/scripts/dev-tools/Invoke-FullReleaseFlow.ChecksWait.TimeoutPaths.Tests.ps1` file (mirroring the existing `AdditionalFailurePaths` split pattern) and record the split decision.
  - Verify: `Read` the file(s) and confirm each is <= 500 lines.
- [x] [P5-T8] Run PoshQC format and analyze on the new test file(s) from P5-T1–P5-T7.
  - Verify: `mcp__drm-copilot__run_poshqc_format` then `mcp__drm-copilot__run_poshqc_analyze` on the new file(s); EXIT_CODE 0 and 0 findings for both.

### Phase 6 — Final QA Loop (Full Toolchain, Coverage, and No-Regression Verification)

- [x] [P6-T1] Run PoshQC format across all touched files (`scripts/dev-tools/Invoke-FullReleaseFlow.ps1`, `tests/scripts/dev-tools/Invoke-FullReleaseFlow.Tests.ps1`, `tests/scripts/dev-tools/Invoke-FullReleaseFlow.AdditionalFailurePaths.Tests.ps1`, and the new Phase 5 file(s)) and write `docs/features/active/2026-07-04-release-flow-wait-for-ci-310/evidence/qa-gates/format-final.<timestamp>.md` with `Timestamp:`, `Command:`, `EXIT_CODE:`, `Output Summary:`.
  - Verify: `mcp__drm-copilot__run_poshqc_format`; EXIT_CODE 0 and zero files changed on a repeat run.
- [x] [P6-T2] Run PoshQC analyze across the same files and write `docs/features/active/2026-07-04-release-flow-wait-for-ci-310/evidence/qa-gates/lint-final.<timestamp>.md` with `Timestamp:`, `Command:`, `EXIT_CODE:`, `Output Summary:`.
  - Verify: `mcp__drm-copilot__run_poshqc_analyze`; 0 findings.
- [x] [P6-T3] Run the full Pester suite with coverage enabled (`scripts/powershell/PoshQC/settings/pester.runsettings.psd1`) scoped to all touched test files and write `docs/features/active/2026-07-04-release-flow-wait-for-ci-310/evidence/qa-gates/test-final.<timestamp>.md` with `Timestamp:`, `Command:`, `EXIT_CODE:`, `Output Summary:` including numeric line and branch coverage for `scripts/dev-tools/Invoke-FullReleaseFlow.ps1`.
  - Verify: `mcp__drm-copilot__run_poshqc_test`; EXIT_CODE 0, 0 failed.
- [x] [P6-T4] Compare P6-T3 coverage numbers against the P0-T4 baseline and write `docs/features/active/2026-07-04-release-flow-wait-for-ci-310/evidence/qa-gates/coverage-delta.<timestamp>.md` recording baseline line/branch percent, post-change line/branch percent, and confirming line coverage >= 85% and branch coverage >= 75% with no regression on changed lines.
  - Verify: `Read` both the P0-T4 and P6-T3 artifacts and confirm the recorded percentages satisfy the thresholds; if any threshold is not met, this task fails and the plan outcome is remediation-required, not PASS.
- [x] [P6-T5] If P6-T1, P6-T2, or P6-T3 changed any file or reported a failure, restart the loop from P6-T1 and repeat until a single clean pass (format → analyze → test) completes with no file changes and no failures.
  - Verify: the final `test-final.<timestamp>.md` artifact records EXIT_CODE 0 with no preceding restart needed, or documents each restart and its resolution.

---

DIRECTIVE: PREFLIGHT VALIDATION ONLY
