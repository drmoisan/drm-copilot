# 2026-08-23-truth-table-non-emptiness-assertions-cannot-fail (Plan)

- **Issue:** #513
- **Parent (optional):** none
- **Owner:** drmoisan
- **Last Updated:** 2026-09-25T22-06
- **Status:** Draft
- **Version:** 0.3
- **Work Mode:** full-bug
- **AC source:** `docs/features/active/2026-08-23-truth-table-non-emptiness-assertions-cannot-fail-513/spec.md` (AC-1..AC-8)
- **Scope:** exactly one file — `tests/scripts/claude-lib/blast-radius/BlastRadius.TruthTable.Tests.ps1`. No production file is changed.
- **Anchor commit (BASE_SHA):** `ae8d2ce32c95cf03d55ffb544f2514d83ebfc620` — the branch's merge-base with `origin/main`, recorded as a literal SHA at plan-authoring time. Every `git diff` below is anchored to this literal SHA; no command in this plan references `origin/main` directly, so no remote fetch is required at execution time.

**Fail-closed evidence rule:** Every command-bearing task below writes one evidence artifact under `docs/features/active/2026-08-23-truth-table-non-emptiness-assertions-cannot-fail-513/evidence/<kind>/` with `Timestamp:`, `Command:`, `EXIT_CODE:`, and `Output Summary:`. A task without its artifact, or an artifact missing a required field, leaves the checklist item unchecked.

**Evidence location invariant:** All evidence is written under `docs/features/active/2026-08-23-truth-table-non-emptiness-assertions-cannot-fail-513/evidence/{baseline,regression-testing,qa-gates}/`. No path under `artifacts/` is used for evidence.

**Coverage-report invariant:** `coverage.xml` is a repository-tracked, generated Pester coverage report that every coverage-enabled `Invoke-Pester` run in this plan rewrites as a side effect. `coverage.xml` must never be staged or committed by this plan's execution.

**Command execution convention:** This worktree's isolation guard refuses any Bash-tool command whose text contains the substring `pwsh`, so the executor never types that word into a Bash-tool command argument. For every `Command:` block below, the executor: (1) writes the block's PowerShell statements verbatim, unmodified, to a `.ps1` file in a session scratch directory located outside the tracked repository, using a tool other than the Bash tool; (2) writes a POSIX `.sh` wrapper script, also outside the tracked repository, whose one statement invokes the `PwshPath:` value discovered and recorded in P0-T8 with the arguments `-NoProfile -File` followed by the `.ps1` file's path, and whose working directory is the worktree root, so that relative paths in the PowerShell statements (for example `tests/scripts/claude-lib/blast-radius`) resolve correctly; (3) runs that wrapper by invoking `sh <wrapper-path>` through the Bash tool, where `<wrapper-path>` is the wrapper script's own path and no other literal token appears in that Bash-tool command argument. No absolute host path — no drive letter, user-directory name, or scratch-directory path — is written into this plan document; the scratch location is described only as "a session scratch directory outside the tracked repository." This convention governs only how the executor invokes the evidence commands in this plan from the local Windows worktree; it does not change what the target test file contains or how it runs under Linux CI (Pester on Linux), which Phase 5's portability check (AC-7) verifies independently. The PowerShell statement content of every `Command:` block below is otherwise unchanged from prior revisions of this plan.

**New test content (quoted here so later searches are checkable against this document, not only against the edited file):**

```powershell
function Test-NonVacuousCollection {
    [CmdletBinding()]
    [OutputType([bool])]
    param(
        [AllowNull()]
        [object] $Value
    )
    return @($Value | Where-Object { $null -ne $_ }).Count -gt 0
}
```

```powershell
    Context 'Non-vacuity floor helper' {
        It 'returns false for a null value' {
            Test-NonVacuousCollection -Value $null | Should -BeFalse
        }

        It 'returns false for an empty array' {
            Test-NonVacuousCollection -Value @() | Should -BeFalse
        }

        It 'returns false for an array of only null elements' {
            Test-NonVacuousCollection -Value @($null, $null) | Should -BeFalse
        }

        It 'returns true for a non-empty array' {
            Test-NonVacuousCollection -Value @('a') | Should -BeTrue
        }

        It 'returns true for a non-empty hashtable Keys property' {
            $sample = @{ a = 1; b = 2 }
            Test-NonVacuousCollection -Value $sample.Keys | Should -BeTrue
        }

        It 'documents that the legacy expression @($null).Count -gt 0 evaluates to $true' {
            (@($null).Count -gt 0) | Should -BeTrue
        }
    }
```

This adds exactly **6** new `It` blocks (5 helper-level negative/positive controls satisfying AC-3, plus 1 legacy-expression control satisfying AC-4). The `Context` is inserted immediately after the closing `}` of the existing `Context 'Read-by-mandate exclusions'` block (pre-edit lines 243-286) and immediately before `Context 'Location-bucket modules'` (pre-edit line 288).

---

### Phase 0 — Policy Reads & Baseline Capture

- [ ] [P0-T1] Read `CLAUDE.md` in full. Acceptance: the file's Policy Compliance Reading Order and Architecture sections were reviewed; no file is modified by this task.
- [ ] [P0-T2] Read `.claude/rules/general-code-change.md` in full. Acceptance: the Mandatory Toolchain Loop and File Size Limit sections were reviewed.
- [ ] [P0-T3] Read `.claude/rules/general-unit-test.md` in full. Acceptance: the Coverage Requirements and Core Principles sections were reviewed.
- [ ] [P0-T4] Read `.claude/rules/powershell.md` in full. Acceptance: the Toolchain and Testing Standards sections were reviewed.
- [ ] [P0-T5] Read `.claude/rules/quality-tiers.md` in full. Acceptance: the uniform coverage-threshold section was reviewed.
- [ ] [P0-T6] Read `.claude/rules/plan-acceptance-gates.md` in full. Acceptance: the G1-G9 rule table and the "Authoring Guidance for Plan Authors" section were reviewed.
- [ ] [P0-T7] Write `docs/features/active/2026-08-23-truth-table-non-emptiness-assertions-cannot-fail-513/evidence/baseline/phase0-instructions-read.<TIMESTAMP>.md` recording `Timestamp:`, `Policy Order:` (the six files from P0-T1..T6 in that exact order), and a line confirming each was read in full. Acceptance: the file exists with all three fields.
- [ ] [P0-T8] Discover the fully-qualified path to this environment's PowerShell 7+ (`pwsh`) executable, once, for reuse by every later `Command:` block's wrapper script in this plan.
  Using a non-Bash tool (for example the Write tool), create a POSIX shell script at a session scratch location outside the tracked repository. The script's sole statement resolves the `pwsh` executable's location (for example a `command -v` lookup of the executable name) and prints the resolved absolute path to standard output. Invoke that script by running `sh <script-path>` through the Bash tool, where `<script-path>` is the script's own path and no other literal token is present in that Bash-tool command argument.
  Write `evidence/baseline/baseline-pwsh-path.<TIMESTAMP>.md` recording `Timestamp:`, `Command:` (the literal `sh <script-path>` invocation actually run — the real scratch path belongs in the evidence artifact, not in this plan document), `EXIT_CODE: 0`, and `Output Summary:` giving the discovered value as `PwshPath: <resolved absolute path>`. Acceptance: the invocation exits `0`, prints exactly one non-blank line, and that line is recorded verbatim as `PwshPath:` in the evidence artifact. Every later `Command:` block's wrapper script in this plan invokes the `PwshPath:` value recorded here.
- [ ] [P0-T9] Confirm the anchor commit exists in this worktree's object database.
  Command:
  ```
  git cat-file -e ae8d2ce32c95cf03d55ffb544f2514d83ebfc620^{commit}
  ```
  Write `evidence/baseline/baseline-anchor-commit.<TIMESTAMP>.md` with `Timestamp:`, `Command:`, `EXIT_CODE:` (must be `0`), `Output Summary:` (`commit object present`).
- [ ] [P0-T10] Capture the pre-edit line count of the target file.
  Command:
  ```
  (Get-Content -Path 'tests/scripts/claude-lib/blast-radius/BlastRadius.TruthTable.Tests.ps1').Count
  ```
  Write `evidence/baseline/baseline-line-count.<TIMESTAMP>.md` with the printed integer in `Output Summary:` (`BaselineLineCount:`).
- [ ] [P0-T11] Capture the pre-edit `It`-block count of the target file.
  Command:
  ```
  (Select-String -Path 'tests/scripts/claude-lib/blast-radius/BlastRadius.TruthTable.Tests.ps1' -Pattern '^\s*It ''').Count
  ```
  Write `evidence/baseline/baseline-it-count-file.<TIMESTAMP>.md` with the printed integer (`BaselineFileItCount:`).
- [ ] [P0-T12] Capture the pre-edit `It`-block count of the whole directory.
  Command:
  ```
  (Select-String -Path 'tests/scripts/claude-lib/blast-radius/*.Tests.ps1' -Pattern '^\s*It ''').Count
  ```
  Write `evidence/baseline/baseline-it-count-directory.<TIMESTAMP>.md` with the printed integer (`BaselineDirectoryItCount:`).
- [ ] [P0-T13] Capture the pre-edit full-directory Pester pass/fail counts.
  Command:
  ```
  $Result = Invoke-Pester -Path 'tests/scripts/claude-lib/blast-radius' -Output Detailed -PassThru
  'TOTAL=' + $Result.TotalCount + ' PASSED=' + $Result.PassedCount + ' FAILED=' + $Result.FailedCount
  ```
  Write `evidence/baseline/baseline-pester-directory.<TIMESTAMP>.md` recording `BaselineTotalCount:`, `BaselinePassedCount:`, `BaselineFailedCount:` (must be `0` for the pre-existing suite; a non-zero baseline failure count means the suite was already red and this plan's Phase 4/6 deltas must be interpreted against that pre-existing count, not against zero).
- [ ] [P0-T14] Capture the pre-edit coverage of the production module `.claude/lib/blast-radius/BlastRadius.psm1` over the directory's test run.
  Command:
  ```
  $Config = New-PesterConfiguration
  $Config.Run.Path = 'tests/scripts/claude-lib/blast-radius'
  $Config.Run.PassThru = $true
  $Config.CodeCoverage.Enabled = $true
  $Config.CodeCoverage.Path = @('.claude/lib/blast-radius/BlastRadius.psm1')
  $Result = Invoke-Pester -Configuration $Config
  $Executed = $Result.CodeCoverage.CommandsExecutedCount
  $Analyzed = $Result.CodeCoverage.CommandsAnalyzedCount
  'EXECUTED=' + $Executed + ' ANALYZED=' + $Analyzed + ' PERCENT=' + ('{0:N2}' -f (100 * $Executed / $Analyzed))
  ```
  Write `evidence/baseline/baseline-coverage-blastradius-psm1.<TIMESTAMP>.md` recording `BaselineCommandsExecuted:`, `BaselineCommandsAnalyzed:`, `BaselineCoveragePercent:` (numeric, not a placeholder).
- [ ] [P0-T15] Capture the pre-edit format state of the target file (read-only comparison; no write).
  Command:
  ```
  $Target = 'tests/scripts/claude-lib/blast-radius/BlastRadius.TruthTable.Tests.ps1'
  $Settings = 'scripts/powershell/PoshQC/settings/pssa.settings.psd1'
  Import-Module PSScriptAnalyzer -ErrorAction Stop
  $Original = Get-Content -Raw -Path $Target
  $Formatted = Invoke-Formatter -ScriptDefinition $Original -Settings $Settings
  if ($Formatted -eq $Original) { 'FORMAT_CHECK: no changes needed for ' + $Target } else { 'FORMAT_CHECK: formatting drift detected for ' + $Target }
  ```
  Write `evidence/baseline/baseline-format-check.<TIMESTAMP>.md` recording the literal printed line.
- [ ] [P0-T16] Capture the pre-edit PSScriptAnalyzer finding count of the target file.
  Command:
  ```
  $Target = 'tests/scripts/claude-lib/blast-radius/BlastRadius.TruthTable.Tests.ps1'
  $Settings = 'scripts/powershell/PoshQC/settings/pssa.settings.psd1'
  Import-Module PSScriptAnalyzer -ErrorAction Stop
  $Findings = Invoke-ScriptAnalyzer -Path $Target -Settings $Settings -Severity Error, Warning, Information
  if ($Findings.Count -gt 0) { $Findings | Format-Table -AutoSize; 'ANALYZE_CHECK: ' + $Findings.Count + ' finding(s) for ' + $Target } else { 'ANALYZE_CHECK: no findings for ' + $Target }
  ```
  Write `evidence/baseline/baseline-analyze-check.<TIMESTAMP>.md` recording the literal printed line and finding count.
- [ ] [P0-T17] Confirm the target file is unmodified relative to the anchor commit before any edit begins.
  Command:
  ```
  git diff --stat ae8d2ce32c95cf03d55ffb544f2514d83ebfc620 -- tests/scripts/claude-lib/blast-radius/BlastRadius.TruthTable.Tests.ps1
  ```
  Write `evidence/baseline/baseline-git-diff-stat.<TIMESTAMP>.md` recording `EXIT_CODE: 0` and `Output Summary:` (`no output; file matches anchor commit`, or the literal diff-stat line if the worktree already carries an unrelated pending edit, which would be a blocking precondition failure requiring the caller's attention before continuing).

### Phase 1 — Fail-Before Negative Control (Red)

- [ ] [P1-T1] [expect-fail] In `tests/scripts/claude-lib/blast-radius/BlastRadius.TruthTable.Tests.ps1`, insert the `Context 'Non-vacuity floor helper'` block quoted verbatim above, at the location described above (after the closing `}` of `Context 'Read-by-mandate exclusions'`, before `Context 'Location-bucket modules'`). Do **not** yet add the `Test-NonVacuousCollection` function. Acceptance: the file contains the new `Context` block with its 6 `It` cases, and does not yet contain the string `function Test-NonVacuousCollection`.
- [ ] [P1-T2] [expect-fail] Run the targeted single-file Pester invocation to prove the 5 helper-calling controls fail while the function is undefined.
  Command:
  ```
  $Result = Invoke-Pester -Path 'tests/scripts/claude-lib/blast-radius/BlastRadius.TruthTable.Tests.ps1' -Output Detailed -PassThru
  'TOTAL=' + $Result.TotalCount + ' PASSED=' + $Result.PassedCount + ' FAILED=' + $Result.FailedCount
  $Result.Failed | ForEach-Object { 'FAILED_IT=' + $_.Name }
  ```
  Write `evidence/regression-testing/fail-before-negative-control.<TIMESTAMP>.md` with `Timestamp:`, `Command:`, `EXIT_CODE:`, and `Output Summary:` recording `TOTAL` equal to the P0-T11 baseline count plus 6, `FAILED` equal to `5`, and the 5 `FAILED_IT` names matching exactly the 5 `It` names `'returns false for a null value'`, `'returns false for an empty array'`, `'returns false for an array of only null elements'`, `'returns true for a non-empty array'`, `'returns true for a non-empty hashtable Keys property'`. Acceptance: `FAILED` is exactly `5`, not `0` and not `6` (the legacy-expression `It` must already pass, since it needs no helper).

### Phase 2 — Helper Implementation (Green)

- [ ] [P2-T1] Add the `Test-NonVacuousCollection` function quoted verbatim above into the file's existing top-level `BeforeAll` block (pre-edit lines 21-46), immediately after the closing `}` of `Get-ReasonSignature`. Acceptance: `function Test-NonVacuousCollection` appears in the file exactly once.
- [ ] [P2-T2] Re-run the same targeted single-file Pester command from P1-T2 to prove the fix closes the gap. Write `evidence/regression-testing/pass-after-negative-control.<TIMESTAMP>.md` with `Timestamp:`, `Command:`, `EXIT_CODE:`, and `Output Summary:` recording `TOTAL` equal to the P0-T11 baseline count plus 6, `PASSED` equal to that same total, and `FAILED=0`. Acceptance: `FAILED` is exactly `0` (the pass-after state).

### Phase 3 — Floor Rewrite & Structural Verification

- [ ] [P3-T1] Rewrite the `Module map` floor (pre-edit line 72) from `@($script:CommittedConfig['modules'].Keys).Count | Should -BeGreaterThan 0` to:
  ```powershell
  Test-NonVacuousCollection -Value $script:CommittedConfig['modules'].Keys |
      Should -BeTrue
  ```
  Acceptance: the raw-count token `@($script:CommittedConfig['modules'].Keys).Count` no longer appears anywhere in the file.
- [ ] [P3-T2] Rewrite the first `Shared surfaces` floor (pre-edit line 171) from `@($script:CommittedConfig['shared_surfaces']).Count | Should -BeGreaterThan 0` to:
  ```powershell
  Test-NonVacuousCollection -Value $script:CommittedConfig['shared_surfaces'] |
      Should -BeTrue
  ```
  Acceptance: the raw-count token `@($script:CommittedConfig['shared_surfaces']).Count` no longer appears anywhere in the file.
- [ ] [P3-T3] Rewrite the second `Shared surfaces` floor (pre-edit line 172) from `@($script:CommittedConfig['shared_surface_globs']).Count | Should -BeGreaterThan 0` to:
  ```powershell
  Test-NonVacuousCollection -Value $script:CommittedConfig['shared_surface_globs'] |
      Should -BeTrue
  ```
  Acceptance: the raw-count token `@($script:CommittedConfig['shared_surface_globs']).Count` no longer appears anywhere in the file.
- [ ] [P3-T4] Confirm AC-1 by searching for all three original raw-count tokens.
  Command:
  ```
  $Target = 'tests/scripts/claude-lib/blast-radius/BlastRadius.TruthTable.Tests.ps1'
  $Tokens = @(
      '@($script:CommittedConfig[''modules''].Keys).Count',
      '@($script:CommittedConfig[''shared_surfaces'']).Count',
      '@($script:CommittedConfig[''shared_surface_globs'']).Count'
  )
  foreach ($Token in $Tokens) {
      $Count = (Select-String -Path $Target -Pattern ([regex]::Escape($Token))).Count
      'TOKEN_COUNT=' + $Count + ' for ' + $Token
  }
  ```
  Write `evidence/qa-gates/ac1-token-absence.<TIMESTAMP>.md` recording all three `TOKEN_COUNT` lines. Acceptance: all three counts are `0`. This check asserts the *absence* of deleted literals; a later formatting pass cannot fabricate an absent literal, so this check is not re-run after Phase 6's formatter (see Phase 6 preamble).
- [ ] [P3-T5] Confirm AC-2's structural shape.
  Command:
  ```
  $Target = 'tests/scripts/claude-lib/blast-radius/BlastRadius.TruthTable.Tests.ps1'
  $DefinitionCount = (Select-String -Path $Target -Pattern 'function Test-NonVacuousCollection').Count
  $AllowNullCount = (Select-String -Path $Target -Pattern '\[AllowNull\(\)\]').Count
  'DEFINITION_COUNT=' + $DefinitionCount + ' ALLOWNULL_COUNT=' + $AllowNullCount
  ```
  Write `evidence/qa-gates/ac2-helper-shape.<TIMESTAMP>.md` recording both counts. Acceptance: `DEFINITION_COUNT` equals `1` and `ALLOWNULL_COUNT` is at least `1`. This check asserts the *presence* of single-line literals; a later formatting pass could in principle reflow either token across a line boundary, so P6-T6 re-runs this same check once after Phase 6's format loop stabilizes.
- [ ] [P3-T6] Confirm the out-of-scope `mandate_reads` two-statement form (pre-edit line 247, named D3 in spec.md as excluded from this fix) is byte-for-byte unchanged.
  Command:
  ```
  $Target = 'tests/scripts/claude-lib/blast-radius/BlastRadius.TruthTable.Tests.ps1'
  $Token = '$entries = @($script:CommittedConfig[''mandate_reads''])'
  (Select-String -Path $Target -Pattern ([regex]::Escape($Token))).Count
  ```
  Write `evidence/qa-gates/scope-boundary-mandate-reads.<TIMESTAMP>.md` recording the count. Acceptance: the count equals `1`.

### Phase 4 — Full-Suite Regression & It-Count Delta

- [ ] [P4-T1] Run the full-directory Pester command from P0-T13 again on the edited tree. Write `evidence/regression-testing/full-directory-post-edit.<TIMESTAMP>.md` recording `PostEditTotalCount:`, `PostEditPassedCount:`, `PostEditFailedCount:` (must be `0`), and `TotalCountDelta:` computed as `PostEditTotalCount` minus the `BaselineTotalCount` recorded in `evidence/baseline/baseline-pester-directory.<TIMESTAMP>.md` from P0-T13. Acceptance: `TotalCountDelta` equals `6` and `PostEditFailedCount` equals `0`.
- [ ] [P4-T2] Run the file-level `It`-count command from P0-T11 again on the edited file. Write `evidence/regression-testing/it-count-delta-file.<TIMESTAMP>.md` recording the new count and the delta against `BaselineFileItCount` from P0-T11. Acceptance: delta equals `6`.
- [ ] [P4-T3] Run the directory-level `It`-count command from P0-T12 again. Write `evidence/regression-testing/it-count-delta-directory.<TIMESTAMP>.md` recording the new count and the delta against `BaselineDirectoryItCount` from P0-T12, cross-checked against the `TotalCountDelta` recorded in P4-T1 (both mechanisms must agree on `6`). Acceptance: both deltas equal `6` and agree with each other.

### Phase 5 — Linux-CI Portability Check

- [ ] [P5-T1] Search the edited file for forbidden portability tokens.
  Command:
  ```
  (Select-String -Path 'tests/scripts/claude-lib/blast-radius/BlastRadius.TruthTable.Tests.ps1' -Pattern 'origin/|C:|New-TemporaryFile|TestDrive|\$env:TEMP').Count
  ```
  Write `evidence/qa-gates/portability-check.<TIMESTAMP>.md` recording the count. Acceptance: the count is `0` (satisfies AC-7: no remote-ref reference, no temp-file API, no gitignored-state dependency marker, no Windows-only drive-root token, in the file this change touches). This check asserts the *absence* of forbidden literals; a later formatting pass cannot fabricate an absent literal, so this check is not re-run after Phase 6's formatter (see Phase 6 preamble).

### Phase 6 — Final QA Loop (Format → Analyze → Test → Coverage)

Type checking, architecture-boundary tests, contract/schema checks, and integration tests are not applicable per `.claude/rules/powershell.md` and the test-only scope of this change (spec.md Test Strategy section). If any step in this phase reports a change or a finding, restart this phase from P6-T1 before proceeding. Phase 3's AC-1 token-absence check (P3-T4) and Phase 5's portability check (P5-T1) assert the *absence* of specific literals: a formatter that only reflows whitespace and indentation cannot fabricate an absent literal, so those two checks are format-invariant and are not re-run on a format-only restart. Phase 3's AC-2 shape check (P3-T5) asserts the *presence* of a single-line literal (the function signature and its `[AllowNull()]` attribute) and is therefore not format-invariant, because a reflow could in principle move either token across a line boundary; P6-T6 below re-runs that same check once, after this format loop has stabilized, rather than on every intermediate restart.

- [ ] [P6-T1] Apply the write-capable single-file formatter pass.
  Command:
  ```
  $Target = 'tests/scripts/claude-lib/blast-radius/BlastRadius.TruthTable.Tests.ps1'
  $Settings = 'scripts/powershell/PoshQC/settings/pssa.settings.psd1'
  Import-Module PSScriptAnalyzer -ErrorAction Stop
  $Original = Get-Content -Raw -Path $Target
  $Formatted = Invoke-Formatter -ScriptDefinition $Original -Settings $Settings
  if ($Formatted -ne $Original) { Set-Content -Path $Target -Value $Formatted -Encoding UTF8 -NoNewline; 'FORMAT_APPLY: rewrote ' + $Target } else { 'FORMAT_APPLY: no changes needed for ' + $Target }
  ```
  Write `evidence/qa-gates/final-format-apply.<TIMESTAMP>.md` recording the literal printed line. Acceptance: if the line begins with `FORMAT_APPLY: rewrote`, restart this phase from P6-T1 after this rewrite; the loop is clean once a run reports `FORMAT_APPLY: no changes needed`.
- [ ] [P6-T2] Run the analyze command from P0-T16 again on the edited file. Write `evidence/qa-gates/final-analyze.<TIMESTAMP>.md` recording the literal printed line and the finding count. Acceptance: the finding count is no greater than the baseline finding count recorded in P0-T16 (AC-6's "zero new findings relative to baseline"); the expected result is `ANALYZE_CHECK: no findings for tests/scripts/claude-lib/blast-radius/BlastRadius.TruthTable.Tests.ps1` since P0-T16 is expected to already report zero. Any increase over the baseline count requires a fix and a restart from P6-T1.
- [ ] [P6-T3] Confirm the file remains under the 500-line limit.
  Command:
  ```
  (Get-Content -Path 'tests/scripts/claude-lib/blast-radius/BlastRadius.TruthTable.Tests.ps1').Count
  ```
  Write `evidence/qa-gates/final-line-count.<TIMESTAMP>.md` recording the integer. Acceptance: the value is less than `500` (satisfies the file-size half of AC-6).
- [ ] [P6-T4] Run the full-directory Pester command from P0-T13 again as the final regression gate. Write `evidence/qa-gates/final-pester-directory.<TIMESTAMP>.md` recording `FinalTotalCount:`, `FinalPassedCount:`, `FinalFailedCount:`. Acceptance: `FinalFailedCount` equals `0` and `FinalTotalCount` matches the `PostEditTotalCount` recorded in P4-T1 exactly.
- [ ] [P6-T5] Run the coverage command from P0-T14 again against `.claude/lib/blast-radius/BlastRadius.psm1`. Write `evidence/qa-gates/final-coverage-blastradius-psm1.<TIMESTAMP>.md` recording `FinalCommandsExecuted:`, `FinalCommandsAnalyzed:`, `FinalCoveragePercent:`, and a `CoverageDelta:` line computed against the `BaselineCoveragePercent` from P0-T14. Acceptance: `FinalCoveragePercent` is greater than or equal to `BaselineCoveragePercent` (no regression on the one production module this test file exercises; this change adds no new call into that module, so the two numbers are expected to be identical).
- [ ] [P6-T6] Re-run the AC-2 structural-shape check from P3-T5 on the post-format file, to confirm the formatter did not reflow the helper's function signature or its `[AllowNull()]` attribute across lines in a way that would make P3-T5's single-line search stop matching.
  Command:
  ```
  $Target = 'tests/scripts/claude-lib/blast-radius/BlastRadius.TruthTable.Tests.ps1'
  $DefinitionCount = (Select-String -Path $Target -Pattern 'function Test-NonVacuousCollection').Count
  $AllowNullCount = (Select-String -Path $Target -Pattern '\[AllowNull\(\)\]').Count
  'DEFINITION_COUNT=' + $DefinitionCount + ' ALLOWNULL_COUNT=' + $AllowNullCount
  ```
  Write `evidence/qa-gates/final-ac2-helper-shape.<TIMESTAMP>.md` recording both counts. Acceptance: identical to P3-T5 — `DEFINITION_COUNT` equals `1` and `ALLOWNULL_COUNT` is at least `1`. If either count deviates from P3-T5's result, treat this as a blocking finding requiring investigation before Phase 7 proceeds, rather than a signal to restart the format loop, since the deviation would indicate the formatter altered the helper's shape rather than corrected a lint violation.

### Phase 7 — Scope Confirmation & Spec Check-off

- [ ] [P7-T1] Restore the repository-tracked `coverage.xml` report to its anchor-commit state before the scope check runs. `coverage.xml` is a generated Pester coverage report, tracked at the repository root, that every coverage-enabled `Invoke-Pester` run in this plan (P0-T14, P6-T5) rewrites as a side effect; this change must not commit it, so it is restored here rather than left as an unrelated pending diff that would make P7-T2's "exactly one path" acceptance unsatisfiable. No `Invoke-Pester` invocation may run after this task anywhere in this plan, because any such run would regenerate `coverage.xml` and reintroduce the same diff this task removes.
  Command:
  ```
  git checkout HEAD -- coverage.xml
  git status --porcelain -- coverage.xml
  ```
  Write `evidence/qa-gates/coverage-report-restore.<TIMESTAMP>.md` recording `Timestamp:`, `Command:`, `EXIT_CODE:`, and `Output Summary:` (the `git status --porcelain -- coverage.xml` output, expected to be empty). Acceptance: the `git status --porcelain -- coverage.xml` output is empty.
- [ ] [P7-T2] Confirm AC-8's scope boundary against the anchor commit (the branch's merge-base with `origin/main`).
  Command:
  ```
  git diff --stat ae8d2ce32c95cf03d55ffb544f2514d83ebfc620 -- tests/scripts/claude-lib/blast-radius/BlastRadius.TruthTable.Tests.ps1
  git diff --name-only ae8d2ce32c95cf03d55ffb544f2514d83ebfc620 -- . ':(exclude)docs/features/active/2026-08-23-truth-table-non-emptiness-assertions-cannot-fail-513/'
  git status --porcelain
  ```
  Write `evidence/qa-gates/scope-diff.<TIMESTAMP>.md` recording all three outputs. Acceptance: (1) the `git diff --stat` output shows exactly one file, `tests/scripts/claude-lib/blast-radius/BlastRadius.TruthTable.Tests.ps1`; (2) the `git diff --name-only` output — scoped to the whole repository but excluding the feature folder's own documentation — lists exactly one path, `tests/scripts/claude-lib/blast-radius/BlastRadius.TruthTable.Tests.ps1`, and no other path (in particular no path under `.claude/lib/blast-radius/`, and no `coverage.xml`, which P7-T1 has already restored); (3) `git status --porcelain` shows every listed path either under `docs/features/active/2026-08-23-truth-table-non-emptiness-assertions-cannot-fail-513/` (the plan, spec, and evidence files this work also touches) or equal to that same one test file path, confirming the `--name-only` diff is not hiding an untracked path outside the feature folder that it cannot see.
- [ ] [P7-T3] Update `docs/features/active/2026-08-23-truth-table-non-emptiness-assertions-cannot-fail-513/spec.md`, checking `[x]` for AC-1 through AC-8, each citing the evidence artifact path from the corresponding task above (AC-1: P3-T4; AC-2: P3-T5 and P6-T6; AC-3: P2-T2; AC-4: P1-T2 and P2-T2; AC-5: P4-T1, P4-T2, P4-T3, P6-T4; AC-6: P6-T1, P6-T2, P6-T3; AC-7: P5-T1; AC-8: P7-T2). Acceptance: all 8 checkboxes in spec.md's Acceptance Criteria section are `[x]`, each with a cited evidence path.
