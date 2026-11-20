# fix-convertto-commandresult-empty-array (Remediation Plan)

- **Issue:** #298
- **Parent (optional):** none
- **Owner:** drmoisan
- **Last Updated:** 2026-07-04T02-15
- **Status:** Draft
- **Version:** 0.1 (remediation cycle 1)
- **Mode:** minor-audit (remediation of two policy-audit Blocking findings; all 5 acceptance criteria in `issue.md` already independently verified PASS per `feature-audit.2026-07-04T02-04.md`)
- **Requirements source:** `docs/features/active/2026-07-03-fix-convertto-commandresult-empty-array-298/remediation-inputs.2026-07-04T02-04.md` (authoritative fix list; do not re-derive findings). `issue.md`'s `## Acceptance Criteria` section remains the sole AC source and is not modified by this remediation cycle.

**Scope:** Exactly three files in scope for this remediation cycle:
- Test: `tests/scripts/dev-tools/Invoke-FullReleaseFlow.Tests.ps1` (remove one `Context` block only — no assertion changes)
- Test (new): `tests/scripts/dev-tools/Invoke-FullReleaseFlow.AdditionalFailurePaths.Tests.ps1` (new sibling file receiving the moved `Context` block verbatim)
- Config: `scripts/powershell/PoshQC/settings/pester.runsettings.psd1` (one new `CodeCoverage.Path` entry + comment only)

No other file may be edited under this plan. Specifically: do not modify `scripts/dev-tools/Invoke-FullReleaseFlow.ps1` (the `[AllowEmptyCollection()]` fix already merged is correct and complete), do not modify `.github/instructions/*.md` or `.claude/rules/*.md`, and do not change `CoveragePercentTarget` or any other coverage threshold in `pester.runsettings.psd1`.

**Evidence location:** All evidence artifacts produced by this plan MUST be written under `docs/features/active/2026-07-03-fix-convertto-commandresult-empty-array-298/evidence/<kind>/` per `evidence-and-timestamp-conventions`. This remediation cycle's baseline evidence uses the `remediation-baseline/` canonical sub-path (distinct from the original feature baseline already recorded under `evidence/baseline/`). Timestamps use `yyyy-MM-ddTHH-mm`. Every command-step artifact records `Timestamp:`, `Command:`, `EXIT_CODE:`, and `Output Summary:`.

**Fix mapping:**
- Fix 1 (`## 2.3 Module & File Structure` Blocking finding — file over 500-line cap) → Phase 1.
- Fix 2 (`## Coverage Verification` Blocking finding — production file not in `CodeCoverage.Path`) → Phase 2.

---

### Phase 0 — Remediation Baseline Capture

- [x] [P0-T1] Read, in order, `.github/copilot-instructions.md`, `.github/instructions/general-code-change.instructions.md`, `.github/instructions/general-unit-test.instructions.md`, and `.github/instructions/powershell-code-change.instructions.md` / `.github/instructions/powershell-unit-test.instructions.md`, then write `docs/features/active/2026-07-03-fix-convertto-commandresult-empty-array-298/evidence/remediation-baseline/phase0-instructions-read.<timestamp>.md` containing `Timestamp:`, `Policy Order:` (the files listed above, in order), and an explicit list of files read. Acceptance: the artifact exists and contains all three required fields.

- [x] [P0-T2] Run `git rev-parse HEAD` to capture the commit SHA at the start of this remediation cycle, then write `docs/features/active/2026-07-03-fix-convertto-commandresult-empty-array-298/evidence/remediation-baseline/head-sha-baseline.<timestamp>.md` with `Timestamp:`, `Command:`, `EXIT_CODE:`, and `Output Summary:` (the full 40-character SHA). Acceptance: artifact exists, `EXIT_CODE: 0`, and the SHA is recorded in full. This SHA is the reference point for the "untouched file" diff checks in Phase 3.

- [x] [P0-T3] Run `(Get-Content tests/scripts/dev-tools/Invoke-FullReleaseFlow.Tests.ps1 | Measure-Object -Line).Lines` and confirm it reports `507`, then write `docs/features/active/2026-07-03-fix-convertto-commandresult-empty-array-298/evidence/remediation-baseline/line-count-baseline.<timestamp>.md` with `Timestamp:`, `Command:`, `EXIT_CODE:`, and `Output Summary:` (the reported line count). Acceptance: artifact exists and the recorded count is `507`, matching the remediation-inputs' documented current state.

- [x] [P0-T4] Run `(Select-String -Path scripts/powershell/PoshQC/settings/pester.runsettings.psd1 -Pattern "Invoke-FullReleaseFlow.ps1" -AllMatches | Measure-Object).Count` and confirm it reports `0`, then write `docs/features/active/2026-07-03-fix-convertto-commandresult-empty-array-298/evidence/remediation-baseline/coverage-allowlist-baseline.<timestamp>.md` with `Timestamp:`, `Command:`, `EXIT_CODE:`, and `Output Summary:` (the match count). Acceptance: artifact exists and the recorded count is `0`.

- [x] [P0-T5] Run `(Select-String -Path artifacts/pester/powershell-coverage.xml -Pattern "Invoke-FullReleaseFlow" -AllMatches | Measure-Object).Count` and confirm it reports `0`, then write `docs/features/active/2026-07-03-fix-convertto-commandresult-empty-array-298/evidence/remediation-baseline/coverage-xml-baseline.<timestamp>.md` with `Timestamp:`, `Command:`, `EXIT_CODE:`, and `Output Summary:` (the match count). Acceptance: artifact exists and the recorded count is `0`, confirming the canonical coverage artifact does not yet mention the production file.

- [x] [P0-T6] Run `mcp__drm-copilot__run_poshqc_test` using the current (unmodified) `scripts/powershell/PoshQC/settings/pester.runsettings.psd1`, scoped to `tests/scripts/dev-tools/Invoke-FullReleaseFlow.Tests.ps1` only, then write `docs/features/active/2026-07-03-fix-convertto-commandresult-empty-array-298/evidence/remediation-baseline/test-baseline.<timestamp>.md` with `Timestamp:`, `Command:`, `EXIT_CODE:`, and `Output Summary:` recording the pass/fail/total test counts (expected: 26 passed, 0 failed) and the numeric aggregate line-coverage and branch-coverage percentages reported by the `CodeCoverage` output. Acceptance: artifact exists, all four fields present, and the recorded passed-test count is `26`.

### Phase 1 — Fix 1: Split Oversized Test File

- [x] [P1-T1] Re-read the "Testing Standards" section of `.claude/rules/powershell.md` (specifically "Organize tests to mirror code structure" and "Name test files `*.Tests.ps1`") and record the sibling-file naming decision in `docs/features/active/2026-07-03-fix-convertto-commandresult-empty-array-298/evidence/other/sibling-file-naming-decision.<timestamp>.md` with `Timestamp:`, the chosen path `tests/scripts/dev-tools/Invoke-FullReleaseFlow.AdditionalFailurePaths.Tests.ps1`, and a rationale sentence confirming the name mirrors the production script's location (`scripts/dev-tools/Invoke-FullReleaseFlow.ps1`) and satisfies the `*.Tests.ps1` naming rule. Acceptance: artifact exists and states the chosen filename and rationale explicitly.

- [x] [P1-T2] Create `tests/scripts/dev-tools/Invoke-FullReleaseFlow.AdditionalFailurePaths.Tests.ps1` with the following content (the `Context "additional failure paths"` block moved verbatim, byte-identical, from the current lines 387-467 of `tests/scripts/dev-tools/Invoke-FullReleaseFlow.Tests.ps1`, with its own minimal `Describe`/`BeforeAll`/`BeforeEach` scaffold providing exactly the state variables that block's `It` bodies reference):
  ```powershell
  Set-StrictMode -Version Latest
  Describe "Invoke-FullReleaseFlow.ps1 - Invoke-FullReleaseFlowGuarded - additional failure paths" {
      BeforeAll {
          $script:scriptPath = (Resolve-Path -Path (Join-Path -Path $PSScriptRoot -ChildPath "../../../scripts/dev-tools/Invoke-FullReleaseFlow.ps1")).Path
          . $script:scriptPath -ConfirmToken 'no'
      }

      BeforeEach {
          $script:capturedMessage = $null
          $script:capturedGitArgsList = [System.Collections.Generic.List[object]]::new()
          $script:capturedGhArgsList = [System.Collections.Generic.List[object]]::new()
          $script:capturedChildCalls = [System.Collections.Generic.List[object]]::new()
          $script:branchReadCount = 0
      }

      Context "additional failure paths" {
          It "returns 1 when preflight command '<FailingCommand>' fails" -ForEach @(
              @{ FailingCommand = 'status --porcelain'; ExpectedMessage = 'Failed to read git status' }
              @{ FailingCommand = 'branch --show-current'; ExpectedMessage = 'Failed to read current git branch' }
              @{ FailingCommand = 'fetch origin main'; ExpectedMessage = 'Failed to fetch origin/main' }
              @{ FailingCommand = 'rev-parse main'; ExpectedMessage = 'Failed to resolve local main' }
              @{ FailingCommand = 'rev-parse origin/main'; ExpectedMessage = 'Failed to resolve origin/main' }
          ) {
              $script:failingCommand = $FailingCommand
              Mock -CommandName Write-StderrLine -MockWith { param([string]$Message) $script:capturedMessage = $Message }
              Mock -CommandName Invoke-GitExe -MockWith {
                  param([string[]]$GitArgs)
                  $joined = $GitArgs -join " "
                  if ($joined -eq $script:failingCommand) { return @{ Output = @('failed'); ExitCode = 1 } }
                  if ($joined -eq 'branch --show-current') { return @{ Output = @('main'); ExitCode = 0 } }
                  if ($joined -eq 'rev-parse main' -or $joined -eq 'rev-parse origin/main') { return @{ Output = @('abc123'); ExitCode = 0 } }
                  return @{ Output = @(); ExitCode = 0 }
              }
              Mock -CommandName Invoke-GhExe -MockWith { param([string[]]$GhArgs) $null = $GhArgs; throw "gh wrapper should not be invoked" }
              Mock -CommandName Invoke-ChildPowerShellScript -MockWith {
                  param([string]$ScriptPath, [string[]]$ScriptArguments)
                  $null = $ScriptPath
                  $null = $ScriptArguments
                  throw "child script wrapper should not be invoked"
              }

              $result = Invoke-FullReleaseFlowGuarded -ConfirmToken "yes" -RepoRoot "/repo"

              $result | Should -Be 1
              $script:capturedMessage | Should -Match $ExpectedMessage
              Should -Invoke -CommandName Invoke-ChildPowerShellScript -Times 0 -Exactly
          }

          It "returns 1 and stops correctly for post-PR scenario '<Scenario>'" -ForEach @(
              @{ Scenario = 'FullScript'; ExpectedMessage = 'Full release PR script failed'; ExpectedChildCount = 1 }
              @{ Scenario = 'ReleaseBranchRead'; ExpectedMessage = 'Failed to read release branch'; ExpectedChildCount = 1 }
              @{ Scenario = 'ReleaseBranchMain'; ExpectedMessage = 'Release branch could not be determined'; ExpectedChildCount = 1 }
              @{ Scenario = 'EmptyPrNumber'; ExpectedMessage = 'gh returned no pull request number'; ExpectedChildCount = 1 }
              @{ Scenario = 'PullMain'; ExpectedMessage = 'Failed to pull merged main'; ExpectedChildCount = 1 }
              @{ Scenario = 'TagPush'; ExpectedMessage = 'Release tag push script failed'; ExpectedChildCount = 2 }
          ) {
              $script:postPrScenario = $Scenario
              Mock -CommandName Write-StderrLine -MockWith { param([string]$Message) $script:capturedMessage = $Message }
              Mock -CommandName Invoke-GitExe -MockWith {
                  param([string[]]$GitArgs)
                  $script:capturedGitArgsList.Add($GitArgs)
                  $joined = $GitArgs -join " "
                  if ($joined -eq 'branch --show-current') {
                      $script:branchReadCount++
                      if ($script:branchReadCount -eq 1) { return @{ Output = @('main'); ExitCode = 0 } }
                      if ($script:postPrScenario -eq 'ReleaseBranchRead') { return @{ Output = @('failed'); ExitCode = 1 } }
                      if ($script:postPrScenario -eq 'ReleaseBranchMain') { return @{ Output = @('main'); ExitCode = 0 } }
                      return @{ Output = @('release/full-20260703171500'); ExitCode = 0 }
                  }
                  if ($joined -eq 'rev-parse main' -or $joined -eq 'rev-parse origin/main') { return @{ Output = @('abc123'); ExitCode = 0 } }
                  if ($joined -eq 'pull origin main' -and $script:postPrScenario -eq 'PullMain') { return @{ Output = @('failed'); ExitCode = 1 } }
                  return @{ Output = @(); ExitCode = 0 }
              }
              Mock -CommandName Invoke-GhExe -MockWith {
                  param([string[]]$GhArgs)
                  $joined = $GhArgs -join " "
                  if ($joined -match '^pr view ' -and $script:postPrScenario -eq 'EmptyPrNumber') { return @{ Output = @(''); ExitCode = 0 } }
                  if ($joined -match '^pr view ') { return @{ Output = @('291'); ExitCode = 0 } }
                  return @{ Output = @('ok'); ExitCode = 0 }
              }
              Mock -CommandName Invoke-ChildPowerShellScript -MockWith {
                  param([string]$ScriptPath, [string[]]$ScriptArguments)
                  $null = $ScriptArguments
                  $script:capturedChildCalls.Add($ScriptPath)
                  if ($script:postPrScenario -eq 'FullScript') { return 7 }
                  if ($script:postPrScenario -eq 'TagPush' -and $ScriptPath -match 'Invoke-ReleaseTagPush') { return 9 }
                  return 0
              }

              $result = Invoke-FullReleaseFlowGuarded -ConfirmToken "yes" -RepoRoot "/repo"

              $result | Should -Be 1
              $script:capturedMessage | Should -Match $ExpectedMessage
              @($script:capturedChildCalls).Count | Should -Be $ExpectedChildCount
          }
      }
  }
  ```
  Acceptance: the new file exists at the stated path, and every `It` body (assertions, `-ForEach` data sets, mock definitions) is byte-identical to the corresponding block currently at lines 387-467 of `tests/scripts/dev-tools/Invoke-FullReleaseFlow.Tests.ps1`.

- [x] [P1-T3] Remove the `Context "additional failure paths" { ... }` block (currently lines 387-467) entirely from `tests/scripts/dev-tools/Invoke-FullReleaseFlow.Tests.ps1`, changing no other line, `Context`, `It`, mock, or assertion in the file. Acceptance: `git diff -- tests/scripts/dev-tools/Invoke-FullReleaseFlow.Tests.ps1` shows only one deletion hunk covering that block, with zero additions and zero other hunks.

- [x] [P1-T4] Run `(Get-Content tests/scripts/dev-tools/Invoke-FullReleaseFlow.Tests.ps1 | Measure-Object -Line).Lines` and confirm it reports `<= 500`, then write `docs/features/active/2026-07-03-fix-convertto-commandresult-empty-array-298/evidence/qa-gates/line-count-post-split.<timestamp>.md` with `Timestamp:`, `Command:`, `EXIT_CODE:`, and `Output Summary:` (the reported line count). Acceptance: artifact exists and the recorded count is `<= 500`.

- [x] [P1-T5] Run `mcp__drm-copilot__run_poshqc_test` using the current (still-unmodified) `scripts/powershell/PoshQC/settings/pester.runsettings.psd1`, scoped to both `tests/scripts/dev-tools/Invoke-FullReleaseFlow.Tests.ps1` and `tests/scripts/dev-tools/Invoke-FullReleaseFlow.AdditionalFailurePaths.Tests.ps1`, then write `docs/features/active/2026-07-03-fix-convertto-commandresult-empty-array-298/evidence/qa-gates/test-post-split.<timestamp>.md` with `Timestamp:`, `Command:`, `EXIT_CODE:`, and `Output Summary:` recording the combined pass/fail/total test count across both files. Acceptance: artifact exists, `EXIT_CODE: 0`, and the recorded total is exactly `26` passed, `0` failed (confirming the split moved tests without removing, weakening, or skipping any of them).

### Phase 2 — Fix 2: Register Production File in Coverage Allowlist

- [x] [P2-T1] Edit `scripts/powershell/PoshQC/settings/pester.runsettings.psd1`'s `CodeCoverage.Path` array to add one new comment block followed by one new path entry, inserted immediately after the existing `'.claude/hooks/enforce-pr-author-skill.epic-base-branch.ps1'` line and before the array's closing `)`, following the file's existing comment style (see the Issue #214/#272/#275 precedent comments already in the file):
  ```powershell
              # Issue #298 fixed ConvertTo-CommandResult's handling of an empty array Output
              # parameter in this script; measured here so the change produces real per-file
              # coverage evidence going forward.
              'scripts/dev-tools/Invoke-FullReleaseFlow.ps1'
  ```
  Change no other line in the file (specifically, leave `CoveragePercentTarget`, `Enabled`, `OutputFormat`, `OutputPath`, and every existing `Path` entry unchanged). Acceptance: `git diff -- scripts/powershell/PoshQC/settings/pester.runsettings.psd1` shows only the added comment lines and the one added path string, with zero other hunks.

- [x] [P2-T2] Run `(Select-String -Path scripts/powershell/PoshQC/settings/pester.runsettings.psd1 -Pattern "Invoke-FullReleaseFlow.ps1" -AllMatches | Measure-Object).Count` and confirm it reports `1`, then write `docs/features/active/2026-07-03-fix-convertto-commandresult-empty-array-298/evidence/qa-gates/coverage-allowlist-added.<timestamp>.md` with `Timestamp:`, `Command:`, `EXIT_CODE:`, and `Output Summary:` (the match count). Acceptance: artifact exists and the recorded count is `1`.

### Phase 3 — Final QC Loop

- [x] [P3-T1] Run `mcp__drm-copilot__run_poshqc_format` scoped to `tests/scripts/dev-tools/Invoke-FullReleaseFlow.Tests.ps1`, `tests/scripts/dev-tools/Invoke-FullReleaseFlow.AdditionalFailurePaths.Tests.ps1`, and `scripts/powershell/PoshQC/settings/pester.runsettings.psd1`. If any file is auto-formatted, restart this loop from this task. Write `docs/features/active/2026-07-03-fix-convertto-commandresult-empty-array-298/evidence/qa-gates/format-final.<timestamp>.md` with `Timestamp:`, `Command:`, `EXIT_CODE:`, and `Output Summary:`. Acceptance: artifact exists, all four fields present, and `EXIT_CODE` reflects a clean pass with zero files changed.

- [x] [P3-T2] Run `mcp__drm-copilot__run_poshqc_analyze` against the same three files (autofix via `mcp__drm-copilot__run_poshqc_analyze_autofix` permitted if findings exist); if any finding is reported or any file is autofixed, restart the loop from P3-T1. Write `docs/features/active/2026-07-03-fix-convertto-commandresult-empty-array-298/evidence/qa-gates/lint-final.<timestamp>.md` with `Timestamp:`, `Command:`, `EXIT_CODE:`, and `Output Summary:`. Acceptance: artifact exists, all four fields present, and `Output Summary:` reports zero rule violations.

- [x] [P3-T3] Run `mcp__drm-copilot__run_poshqc_test` using the updated `scripts/powershell/PoshQC/settings/pester.runsettings.psd1`, scoped to both `tests/scripts/dev-tools/Invoke-FullReleaseFlow.Tests.ps1` and `tests/scripts/dev-tools/Invoke-FullReleaseFlow.AdditionalFailurePaths.Tests.ps1`; if any test fails, restart the loop from P3-T1. Write `docs/features/active/2026-07-03-fix-convertto-commandresult-empty-array-298/evidence/qa-gates/test-final.<timestamp>.md` with `Timestamp:`, `Command:`, `EXIT_CODE:`, and `Output Summary:` recording the combined pass/fail/total test count (must be `26` passed, `0` failed) and the numeric aggregate line-coverage and branch-coverage percentages from the `CodeCoverage` output. Acceptance: artifact exists, all four fields present, recorded total is `26` passed / `0` failed, and numeric coverage percentages are recorded (not a placeholder).

- [x] [P3-T4] Run `(Get-Content tests/scripts/dev-tools/Invoke-FullReleaseFlow.Tests.ps1 | Measure-Object -Line).Lines` and confirm it reports `<= 500`, then write `docs/features/active/2026-07-03-fix-convertto-commandresult-empty-array-298/evidence/qa-gates/line-count-final.<timestamp>.md` with `Timestamp:`, `Command:`, `EXIT_CODE:`, and `Output Summary:` (the reported line count). Acceptance: artifact exists and the recorded count is `<= 500`.

- [x] [P3-T5] Parse `artifacts/pester/powershell-coverage.xml` (JaCoCo schema) for the `<class>` element whose `sourcefilename` attribute equals `Invoke-FullReleaseFlow.ps1`, read that class's top-level `<counter type="LINE" missed="..." covered="...">` attributes, and compute `line coverage % = covered / (covered + missed) * 100`. Confirm the computed percentage is non-zero and `>= 85`. Write `docs/features/active/2026-07-03-fix-convertto-commandresult-empty-array-298/evidence/qa-gates/coverage-per-file-verification.<timestamp>.md` with `Timestamp:`, `Command:` (the exact parsing command/expression used), `EXIT_CODE:`, and `Output Summary:` (the extracted `missed`/`covered` counts and computed percentage). Acceptance: artifact exists, all four fields present, and the recorded computed percentage is `>= 85`.

- [x] [P3-T6] Run `git diff <HEAD SHA from P0-T2> -- scripts/dev-tools/Invoke-FullReleaseFlow.ps1` and confirm the output is empty, then write `docs/features/active/2026-07-03-fix-convertto-commandresult-empty-array-298/evidence/qa-gates/production-file-untouched.<timestamp>.md` with `Timestamp:`, `Command:`, `EXIT_CODE:`, and `Output Summary:` confirming zero diff. Acceptance: artifact exists and confirms empty diff output, verifying `ConvertTo-CommandResult`'s signature was not modified during this remediation cycle.

- [x] [P3-T7] Run `git diff --name-only <HEAD SHA from P0-T2> -- .github/instructions .claude/rules` and confirm the output is empty, then write `docs/features/active/2026-07-03-fix-convertto-commandresult-empty-array-298/evidence/qa-gates/policy-files-untouched.<timestamp>.md` with `Timestamp:`, `Command:`, `EXIT_CODE:`, and `Output Summary:` confirming zero changed files. Acceptance: artifact exists and confirms empty output, verifying no policy document was modified during this remediation cycle.

- [x] [P3-T8] Compare the baseline values recorded in `evidence/remediation-baseline/line-count-baseline.<timestamp>.md` (P0-T3), `evidence/remediation-baseline/coverage-allowlist-baseline.<timestamp>.md` (P0-T4), `evidence/remediation-baseline/coverage-xml-baseline.<timestamp>.md` (P0-T5), and `evidence/remediation-baseline/test-baseline.<timestamp>.md` (P0-T6) against the final values recorded in P1-T4, P2-T2, P3-T3, P3-T4, and P3-T5, then write `docs/features/active/2026-07-03-fix-convertto-commandresult-empty-array-298/evidence/qa-gates/remediation-summary.<timestamp>.md` with `Timestamp:` and explicit statements confirming: (a) test file line count moved from `507` to `<= 500`; (b) `CodeCoverage.Path` match count moved from `0` to `1`; (c) coverage-xml per-file line coverage for `Invoke-FullReleaseFlow.ps1` moved from absent/`0` matches to a non-zero value `>= 85%`; (d) total passing test count remained exactly `26` across both cycles (no test removed, weakened, or skipped); (e) `CoveragePercentTarget` and all other coverage thresholds in `pester.runsettings.psd1` are unchanged from baseline (no threshold lowered, no suppression added). Acceptance: artifact exists and explicitly states all five (a)-(e) confirmations with their before/after values.
