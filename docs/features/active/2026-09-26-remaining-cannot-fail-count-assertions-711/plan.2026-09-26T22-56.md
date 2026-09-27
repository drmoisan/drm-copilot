# 2026-09-26-remaining-cannot-fail-count-assertions (Plan)

- **Issue:** #711
- **Parent (optional):** none
- **Owner:** drmoisan
- **Last Updated:** 2026-09-26T22-56
- **Status:** Draft (pending executor preflight)
- **Version:** 1.0
- **Work Mode:** full-bug (spec-driven; `spec.md` is the acceptance-criteria source; no `user-story.md`, per spec D6/D8)

## Scope Recap

Same-line, content-anchored edits to five non-emptiness assertions across exactly four Pester test
files, plus one new in-file `Context`/`It` pair (AC-5's fail-before documentation) and evidence
artifacts under this feature folder's `evidence/` tree. No production file under `.claude/lib`,
`.claude/hooks`, or `scripts` is a write target (AC-9). Files in scope:

- `tests/scripts/claude-lib/blast-radius/BlastRadius.TruthTable.Tests.ps1` (AC-1)
- `tests/scripts/claude-runtime/enforcement-hooks-no-python-invocation.Tests.ps1` (AC-2; exactly 500
  lines pre-edit, zero headroom — edit must be strictly same-line)
- `tests/scripts/claude-lib/discovery-validation/DiscoveryValidation.Tests.ps1` (AC-3, AC-4; 476 lines
  pre-edit, 23 lines of headroom — edits must be same-line)
- `tests/scripts/codex-hooks/codex-pretooluse-integration.Tests.ps1` (AC-5; 203 lines pre-edit, 296
  lines of headroom — the one file that gains lines, via the new `Context`/`It` pair)

Every pre-edit line count and `It`-block count quoted in this plan was independently re-derived
against the current tree during planning (see the Planner Internal Review Record's `CITATION`
entries) and matches `research/research.2026-09-27T03-00.md` exactly: 391 / 500 / 476 / 203 lines and
23 / 27 / 40 / 5 `It` blocks respectively. Per spec D9, these numbers are contextual only; every task
below that depends on a count re-captures it at run time rather than hard-coding the number quoted
here.

**No task in this plan is tagged `[expect-fail]`.** Per spec D3, the chosen evidence mechanisms are:
(a) AC-1 reuses the existing, already-passing "Non-vacuity floor helper" negative controls plus a
before/after content-token check; (b) AC-2/AC-3/AC-4 use a non-committed inline `pwsh -NoProfile
-Command` diagnostic (no script file) proving the shared textual shape's vacuity in isolation, since
the actual guarded values at those three sites are proven (in `spec.md` Root Cause Analysis and
`research.2026-09-27T03-00.md`) never to reach the `$null` state that would exploit it; (c) AC-5's
fail-before evidence is a new, always-passing documentation `It` pair (mirroring #513's own
legacy-expression `It`), not a test expected to fail. No committed Pester test in this change is ever
expected to report a failure; the toolchain-loop rule "restart if any step fails" therefore applies to
unintended failures only.

**Toolchain scope:** PowerShell only. Formatting = `Invoke-PoshQCFormat`; Linting =
`Invoke-PoshQCAnalyze`; type checking is not applicable (`.claude/rules/powershell.md`);
architecture-boundary and contract/schema stages are not applicable to test-only text edits (per
`spec.md` Test Strategy); Testing = `Invoke-Pester`, invoked directly rather than through the MCP
PoshQC test runner, per this repository's own memory record and `spec.md`'s Manual Validation Steps
(the MCP `run_poshqc_test`/`run_poshqc_analyze` results carry no numeric test output and must not be
used as the source of a pass/fail/count assertion). Coverage is not required for this change: all four
files are test code, excluded from production coverage measurement per
`.claude/rules/general-unit-test.md`.

**Evidence path convention:** every artifact path below lives under
`docs/features/active/2026-09-26-remaining-cannot-fail-count-assertions-711/evidence/<kind>/`. Replace
`<timestamp>` in every filename with the actual run time in `yyyy-MM-ddTHH-mm` format at the time the
task executes (`evidence-and-timestamp-conventions`). Every artifact carries at minimum `Timestamp:`,
`Command:`, `EXIT_CODE:`, and `Output Summary:`.

**Fail-closed evidence rule:** if any required baseline, fail-before, or final-QC artifact is missing
or incomplete, the task it belongs to is not checked off and this plan's overall outcome is
remediation-required, never PASS.

---

### Phase 0 — Policy Reads & Baseline Capture

- [ ] [P0-T1] Read `CLAUDE.md` in full.
- [ ] [P0-T2] Read `.claude/rules/general-code-change.md` in full.
- [ ] [P0-T3] Read `.claude/rules/general-unit-test.md` in full.
- [ ] [P0-T4] Read `.claude/rules/quality-tiers.md` in full (referenced by
      `general-code-change.md`'s Module Rigor Tiers section).
- [ ] [P0-T5] Read `.claude/rules/tonality.md` in full (the tone policy `CLAUDE.md` designates as
      authoritative).
- [ ] [P0-T6] Read `.claude/rules/powershell.md` in full (the only language-specific rule file in
      scope; all four target files are `*.ps1`).
- [ ] [P0-T7] Read `.claude/rules/plan-acceptance-gates.md` in full (governs every acceptance
      condition authored in this plan; G1–G9).
- [ ] [P0-T8] Read
      `docs/features/active/2026-09-26-remaining-cannot-fail-count-assertions-711/issue.md` in full.
- [ ] [P0-T9] Read
      `docs/features/active/2026-09-26-remaining-cannot-fail-count-assertions-711/spec.md` in full.
- [ ] [P0-T10] Read
      `docs/features/active/2026-09-26-remaining-cannot-fail-count-assertions-711/research/research.2026-09-27T03-00.md`
      in full.
- [ ] [P0-T11] Write the Phase 0 policy-read evidence artifact to
      `docs/features/active/2026-09-26-remaining-cannot-fail-count-assertions-711/evidence/baseline/phase0-instructions-read.<timestamp>.md`
      containing `Timestamp:`, `Policy Order:` (the exact P0-T1..P0-T7 order above), and an explicit
      list of all ten files read in P0-T1..P0-T10.
- [ ] [P0-T12] Record the pre-implementation commit SHA as the scope-diff baseline for AC-9: run
      `git rev-parse HEAD` from the repository root. Acceptance: command exits 0 and prints a
      40-character hex SHA. Write
      `docs/features/active/2026-09-26-remaining-cannot-fail-count-assertions-711/evidence/baseline/scope-diff-base-sha.<timestamp>.md`
      with `Timestamp:`, `Command:`, `EXIT_CODE:`, and `Output Summary:` (the SHA itself). This SHA is
      the `<base-sha>` referenced in P4-T4.
- [ ] [P0-T13] Baseline line count for
      `tests/scripts/claude-lib/blast-radius/BlastRadius.TruthTable.Tests.ps1`: run
      `(Get-Content -Path 'tests/scripts/claude-lib/blast-radius/BlastRadius.TruthTable.Tests.ps1').Count`.
      Acceptance: EXIT_CODE 0 and a printed integer (expected 391, per independent re-derivation
      during planning; record whatever value is actually printed, per spec D7/D9). Write
      `.../evidence/baseline/blast-radius-truthtable-linecount.<timestamp>.md`.
- [ ] [P0-T14] Baseline Pester run for the same file: run
      `pwsh -NoProfile -Command "$r = Invoke-Pester -Path 'tests/scripts/claude-lib/blast-radius/BlastRadius.TruthTable.Tests.ps1' -PassThru; Write-Output (\"TotalCount=$($r.TotalCount) PassedCount=$($r.PassedCount) FailedCount=$($r.FailedCount)\")"`.
      Acceptance: EXIT_CODE 0 and the printed line shows `FailedCount=0` (expected `TotalCount=23`,
      per re-derivation; record the actual value). Write
      `.../evidence/baseline/blast-radius-truthtable-pester.<timestamp>.md` with the three fields in
      `Output Summary:`.
- [ ] [P0-T15] Baseline line count for
      `tests/scripts/claude-runtime/enforcement-hooks-no-python-invocation.Tests.ps1`: run
      `(Get-Content -Path 'tests/scripts/claude-runtime/enforcement-hooks-no-python-invocation.Tests.ps1').Count`.
      Acceptance: EXIT_CODE 0 and a printed integer (expected 500). Write
      `.../evidence/baseline/enforcement-hooks-linecount.<timestamp>.md`.
- [ ] [P0-T16] Baseline Pester run for the same file: run
      `pwsh -NoProfile -Command "$r = Invoke-Pester -Path 'tests/scripts/claude-runtime/enforcement-hooks-no-python-invocation.Tests.ps1' -PassThru; Write-Output (\"TotalCount=$($r.TotalCount) PassedCount=$($r.PassedCount) FailedCount=$($r.FailedCount)\")"`.
      Acceptance: EXIT_CODE 0 and `FailedCount=0` (expected `TotalCount=27`). Write
      `.../evidence/baseline/enforcement-hooks-pester.<timestamp>.md`.
- [ ] [P0-T17] Baseline line count for
      `tests/scripts/claude-lib/discovery-validation/DiscoveryValidation.Tests.ps1`: run
      `(Get-Content -Path 'tests/scripts/claude-lib/discovery-validation/DiscoveryValidation.Tests.ps1').Count`.
      Acceptance: EXIT_CODE 0 and a printed integer (expected 476). Write
      `.../evidence/baseline/discovery-validation-linecount.<timestamp>.md`.
- [ ] [P0-T18] Baseline Pester run for the same file: run
      `pwsh -NoProfile -Command "$r = Invoke-Pester -Path 'tests/scripts/claude-lib/discovery-validation/DiscoveryValidation.Tests.ps1' -PassThru; Write-Output (\"TotalCount=$($r.TotalCount) PassedCount=$($r.PassedCount) FailedCount=$($r.FailedCount)\")"`.
      Acceptance: EXIT_CODE 0 and `FailedCount=0` (expected `TotalCount=40`). Write
      `.../evidence/baseline/discovery-validation-pester.<timestamp>.md`.
- [ ] [P0-T19] Baseline line count for
      `tests/scripts/codex-hooks/codex-pretooluse-integration.Tests.ps1`: run
      `(Get-Content -Path 'tests/scripts/codex-hooks/codex-pretooluse-integration.Tests.ps1').Count`.
      Acceptance: EXIT_CODE 0 and a printed integer (expected 203). Write
      `.../evidence/baseline/codex-pretooluse-linecount.<timestamp>.md`.
- [ ] [P0-T20] Baseline Pester run for the same file: run
      `pwsh -NoProfile -Command "$r = Invoke-Pester -Path 'tests/scripts/codex-hooks/codex-pretooluse-integration.Tests.ps1' -PassThru; Write-Output (\"TotalCount=$($r.TotalCount) PassedCount=$($r.PassedCount) FailedCount=$($r.FailedCount)\")"`.
      Acceptance: EXIT_CODE 0 and `FailedCount=0` (expected `TotalCount=5`). Write
      `.../evidence/baseline/codex-pretooluse-pester.<timestamp>.md`.
- [ ] [P0-T21] Confirm merge-order-safe uniqueness of all five edit-site content anchors (spec D7)
      before any edit is made, in one combined check. Run, inline, via `pwsh -NoProfile -Command`
      (no script file):
      ```
      $c1 = (Select-String -Path 'tests/scripts/claude-lib/blast-radius/BlastRadius.TruthTable.Tests.ps1' -Pattern '$entries.Count | Should -BeGreaterThan 0' -SimpleMatch).Count
      $c2 = (Select-String -Path 'tests/scripts/claude-runtime/enforcement-hooks-no-python-invocation.Tests.ps1' -Pattern '@($files).Count | Should -BeGreaterThan 0' -SimpleMatch).Count
      $content3 = Get-Content -Raw -Path 'tests/scripts/claude-lib/discovery-validation/DiscoveryValidation.Tests.ps1'
      $pattern3 = [regex]::Escape('Get-DiscoveryProfileValidationError -Text $text') + '(?s).*?' + [regex]::Escape('@($errors).Count | Should -BeGreaterThan 0')
      $c3 = ([regex]::Matches($content3, $pattern3)).Count
      $pattern4 = [regex]::Escape('Get-DiscoverySchemaArtifactValidationError -Text $text') + '(?s).*?' + [regex]::Escape('@($errors).Count | Should -BeGreaterThan 0')
      $c4 = ([regex]::Matches($content3, $pattern4)).Count
      $c5 = (Select-String -Path 'tests/scripts/codex-hooks/codex-pretooluse-integration.Tests.ps1' -Pattern '@($script:Registrations).Count | Should -BeGreaterThan 0' -SimpleMatch).Count
      Write-Output "AC-1=$c1 AC-2=$c2 AC-3=$c3 AC-4=$c4 AC-5=$c5"
      ```
      Acceptance: EXIT_CODE 0 and the printed line reads exactly `AC-1=1 AC-2=1 AC-3=1 AC-4=1 AC-5=1`.
      Each of the five literals quoted above is confirmed present, verbatim, in the current tree (this
      plan's own Planner Internal Review Record cites the same five occurrences). If any count is not
      1, stop: the anchor has drifted (a concurrent sibling edited the line first, per spec D7's
      risk note) and the corresponding P2 edit task must re-resolve its anchor against the current
      file content before proceeding. Write
      `.../evidence/baseline/anchor-uniqueness-confirmation.<timestamp>.md`.

### Phase 1 — Fail-Before Evidence (spec D3 / AC-8)

- [ ] [P1-T1] Confirm AC-1's existing "Non-vacuity floor helper" negative controls
      (`BlastRadius.TruthTable.Tests.ps1`, `Context 'Non-vacuity floor helper'`, six `It` blocks
      already merged by #513) already pass, establishing that `Test-NonVacuousCollection` correctly
      discriminates `$null`, `@()`, an all-`$null` array, and non-empty inputs before AC-1's
      assertion-site edit is made. Run:
      `pwsh -NoProfile -Command "$r = Invoke-Pester -Path 'tests/scripts/claude-lib/blast-radius/BlastRadius.TruthTable.Tests.ps1' -FullNameFilter '*Non-vacuity floor helper*' -PassThru; Write-Output (\"TotalCount=$($r.TotalCount) PassedCount=$($r.PassedCount) FailedCount=$($r.FailedCount)\")"`.
      Acceptance: EXIT_CODE 0 and `FailedCount=0` (expected `TotalCount=6`). Write
      `.../evidence/regression-testing/ac1-existing-negative-controls.<timestamp>.md`.
- [ ] [P1-T2] Run the shared inline diagnostic for AC-2/AC-3/AC-4 (spec D3): a `pwsh -NoProfile
      -Command` expression, no script file, no temporary file, evaluating the old form
      (`@($x).Count -gt 0`) and the new form (`@($x | Where-Object { $null -ne $_ }).Count -gt 0`)
      against `$null` and `@()` — the two inputs the three producers' `return , $collection.ToArray()`
      contract makes unreachable in practice, per spec Root Cause Analysis. Run:
      ```
      foreach ($case in @(@{ Name = 'null'; Value = $null }, @{ Name = 'emptyArray'; Value = @() })) {
        $x = $case.Value
        $old = (@($x).Count -gt 0)
        $new = (@($x | Where-Object { $null -ne $_ }).Count -gt 0)
        Write-Output "input=$($case.Name) oldForm=$old newForm=$new"
      }
      ```
      Acceptance: EXIT_CODE 0 and exactly two printed lines:
      `input=null oldForm=True newForm=False` and `input=emptyArray oldForm=False newForm=False`. The
      first line documents the vacuous shape (`oldForm=True` for `$null`) that the same textual shape
      would exhibit if the guarded value at AC-2/AC-3/AC-4 could ever be a raw `$null`; the second line
      confirms both forms already agree on the empty-array case. Write
      `.../evidence/regression-testing/ac2-ac3-ac4-inline-old-vs-new-form.<timestamp>.md`. This
      artifact is the AC-8 evidence for AC-2, AC-3, and AC-4.

### Phase 2 — Implementation (same-line edits + one new documentation `It` pair)

- [ ] [P2-T1] In `tests/scripts/claude-lib/blast-radius/BlastRadius.TruthTable.Tests.ps1`, replace the
      exact line `            $entries.Count | Should -BeGreaterThan 0` with
      `            Test-NonVacuousCollection -Value $entries | Should -BeTrue` (same indentation, same
      line position). Do not alter the adjacent `$entries = @($script:CommittedConfig['mandate_reads'])`
      assignment or the whitespace check on the following lines. Acceptance (before/after content-token
      check, AC-8 for AC-1): before this edit, the old literal's count is 1 (per P0-T21); after this
      edit, run
      `(Select-String -Path 'tests/scripts/claude-lib/blast-radius/BlastRadius.TruthTable.Tests.ps1' -Pattern '$entries.Count | Should -BeGreaterThan 0' -SimpleMatch).Count` =
      `0`, and
      `(Select-String -Path 'tests/scripts/claude-lib/blast-radius/BlastRadius.TruthTable.Tests.ps1' -Pattern 'Test-NonVacuousCollection -Value $entries | Should -BeTrue' -SimpleMatch).Count` =
      `1`; and `(Get-Content -Path 'tests/scripts/claude-lib/blast-radius/BlastRadius.TruthTable.Tests.ps1').Count`
      equals the value recorded in P0-T13 (net-zero line delta). Write
      `.../evidence/regression-testing/ac1-before-after-token-check.<timestamp>.md` recording all four
      counts.
- [ ] [P2-T2] In `tests/scripts/claude-runtime/enforcement-hooks-no-python-invocation.Tests.ps1`,
      replace the exact line `            @($files).Count | Should -BeGreaterThan 0` with
      `            @($files | Where-Object { $null -ne $_ }).Count | Should -BeGreaterThan 0` (same
      indentation, same line position; this is the file at the 500-line ceiling, per spec D2 — the
      edit must not add a line). Acceptance: after the edit,
      `(Select-String -Path 'tests/scripts/claude-runtime/enforcement-hooks-no-python-invocation.Tests.ps1' -Pattern '@($files).Count | Should -BeGreaterThan 0' -SimpleMatch).Count` =
      `0` and
      `(Select-String -Path 'tests/scripts/claude-runtime/enforcement-hooks-no-python-invocation.Tests.ps1' -Pattern '@($files | Where-Object { $null -ne $_ }).Count | Should -BeGreaterThan 0' -SimpleMatch).Count` =
      `1`; and the file's line count (per `(Get-Content -Path <file>).Count`) equals the value recorded
      in P0-T15 exactly. Write `.../evidence/regression-testing/ac2-before-after-token-check.<timestamp>.md`.
- [ ] [P2-T3] In `tests/scripts/claude-lib/discovery-validation/DiscoveryValidation.Tests.ps1`, replace
      the exact block
      ```
                  $errors = Get-DiscoveryProfileValidationError -Text $text

                  # Assert: rejected, never silently accepted.
                  @($errors).Count | Should -BeGreaterThan 0
                  $errors[0] | Should -Be 'Profile document root must be a mapping.'
      ```
      with the identical block except the assertion line becomes
      `            @($errors | Where-Object { $null -ne $_ }).Count | Should -BeGreaterThan 0` (net
      zero line delta; the `Get-DiscoveryProfileValidationError` call disambiguates this occurrence
      from AC-4's, per spec D7). Acceptance: after the edit, re-run the P0-T21 compound-pattern check
      for the profile-error anchor (same regex construction as P0-T21's `$pattern3`, rebuilt against
      the post-edit file content) and confirm it now returns `0` for the *old* assertion literal
      following that call, and a parallel check using the *new* literal
      (`@($errors | Where-Object { $null -ne $_ }).Count | Should -BeGreaterThan 0`) following the same
      call returns `1`; and the file's line count equals the value recorded in P0-T17 exactly. Write
      `.../evidence/regression-testing/ac3-before-after-token-check.<timestamp>.md`.
- [ ] [P2-T4] In the same file, replace the exact block
      ```
                  $errors = Get-DiscoverySchemaArtifactValidationError -Text $text

                  # Assert
                  @($errors).Count | Should -BeGreaterThan 0
                  ($errors -join "`n") | Should -Match 'not valid with the schema'
      ```
      with the identical block except the assertion line becomes
      `            @($errors | Where-Object { $null -ne $_ }).Count | Should -BeGreaterThan 0` (net
      zero line delta; the `Get-DiscoverySchemaArtifactValidationError` call disambiguates this
      occurrence from AC-3's). Acceptance: analogous to P2-T3, using the schema-error call as the
      compound-pattern anchor; old-literal-following-that-call count = `0`, new-literal-following-that-
      call count = `1`; file line count equals the value recorded in P0-T17 exactly (unchanged again,
      since P2-T3 and P2-T4 are each individually net-zero). Write
      `.../evidence/regression-testing/ac4-before-after-token-check.<timestamp>.md`.
- [ ] [P2-T5] In `tests/scripts/codex-hooks/codex-pretooluse-integration.Tests.ps1`, replace the exact
      line `        @($script:Registrations).Count | Should -BeGreaterThan 0` with
      `        @($script:Registrations | Where-Object { $null -ne $_ }).Count | Should -BeGreaterThan 0`
      (same indentation, same line position; `Get-CodexPreToolUseRegistration` itself is not modified,
      per spec D5). Acceptance: after the edit,
      `(Select-String -Path 'tests/scripts/codex-hooks/codex-pretooluse-integration.Tests.ps1' -Pattern '@($script:Registrations).Count | Should -BeGreaterThan 0' -SimpleMatch).Count` =
      `0` and the corresponding new-literal count = `1`. Write
      `.../evidence/regression-testing/ac5-assertion-before-after-token-check.<timestamp>.md`.
- [ ] [P2-T6] In the same file, add the new fail-before documentation `Context`/`It` pair for AC-5
      (spec D3/AC-8): replace the exact trailing block
      ```
          It 'leaves no Codex batch-budget state behind' {
              # Convention C4: every payload above targets README.md or a read-only
              # command, so the batch-budget entrypoints must never write state.
              $syntheticPythonState = Join-Path $script:RepoRoot '.codex/state/python-batch-budget.native-hook-contract.json'
              $syntheticPowerShellState = Join-Path $script:RepoRoot '.codex/state/powershell-batch-budget.native-hook-contract.json'

              Test-Path -LiteralPath $syntheticPythonState |
                  Should -BeFalse -Because 'benign payloads must not create Python batch-budget state for the synthetic session'
              Test-Path -LiteralPath $syntheticPowerShellState |
                  Should -BeFalse -Because 'benign payloads must not create PowerShell batch-budget state for the synthetic session'
          }
      }
      ```
      with the same block plus, before the final `}`, a new sibling `Context`:
      ```
          Context 'Non-vacuity floor for the registration count' {
              It 'documents that the legacy expression @($null).Count -gt 0 evaluates to $true while the filtered form is $false' {
                  (@($null).Count -gt 0) | Should -BeTrue
                  (@($null | Where-Object { $null -ne $_ }).Count -gt 0) | Should -BeFalse
              }
          }
      ```
      (net +7 lines, mirroring #513's own legacy-expression documentation `It` in
      `BlastRadius.TruthTable.Tests.ps1`). Acceptance: after the edit,
      `(Select-String -Path 'tests/scripts/codex-hooks/codex-pretooluse-integration.Tests.ps1' -Pattern 'Non-vacuity floor for the registration count' -SimpleMatch).Count` =
      `1`; and
      `pwsh -NoProfile -Command "$r = Invoke-Pester -Path 'tests/scripts/codex-hooks/codex-pretooluse-integration.Tests.ps1' -FullNameFilter '*Non-vacuity floor for the registration count*' -PassThru; Write-Output (\"PassedCount=$($r.PassedCount) FailedCount=$($r.FailedCount)\")"`
      prints `PassedCount=1 FailedCount=0`; and the file's line count (per `(Get-Content -Path
      <file>).Count`) equals the value recorded in P0-T19 plus 7 exactly. Write
      `.../evidence/regression-testing/ac5-new-context-it-pair.<timestamp>.md`.

### Phase 3 — Formatting & Linting (toolchain steps 1–2)

- [ ] [P3-T1] Run `Invoke-PoshQCFormat` against all four changed files in one invocation:
      ```
      Import-Module (Resolve-Path './scripts/powershell/PoshQC/PoshQC.psd1') -Force
      $files = @(
        'tests/scripts/claude-lib/blast-radius/BlastRadius.TruthTable.Tests.ps1',
        'tests/scripts/claude-runtime/enforcement-hooks-no-python-invocation.Tests.ps1',
        'tests/scripts/claude-lib/discovery-validation/DiscoveryValidation.Tests.ps1',
        'tests/scripts/codex-hooks/codex-pretooluse-integration.Tests.ps1'
      )
      $out = Invoke-PoshQCFormat -Root (Resolve-Path '.').Path -ScanFolders $files 6>&1
      $out | ForEach-Object { Write-Output $_ }
      ```
      run via `pwsh -NoProfile -Command` (inline; no script file). **Success-case observation beyond
      exit code (G7):** `Invoke-PoshQCFormat`'s own logger prints exactly one line per scanned file,
      reading either `Already formatted: <path>` (no rewrite) or `Formatted: <path>` (the file was
      rewritten) — confirmed by direct reading of
      `scripts/powershell/PoshQC/PoshQC.Analyzer.psm1` lines 56–65 during planning. Acceptance:
      EXIT_CODE 0 and exactly four output lines, one per file in the list above, each beginning with
      one of those two literal tokens. If any file's line reads `Formatted:` (the formatter rewrote
      it), the executor must re-verify that file's P2 edit anchor and line-count acceptance conditions
      still hold post-reformat, and must restart this toolchain loop (P3-T1 → P3-T2 → P4-T1/T2) from
      P3-T1 for that file before continuing. Write
      `.../evidence/qa-gates/format-4-files.<timestamp>.md`.
- [ ] [P3-T2] Run `Invoke-PoshQCAnalyze` against the same four files in one invocation:
      ```
      Import-Module (Resolve-Path './scripts/powershell/PoshQC/PoshQC.psd1') -Force
      $files = @(
        'tests/scripts/claude-lib/blast-radius/BlastRadius.TruthTable.Tests.ps1',
        'tests/scripts/claude-runtime/enforcement-hooks-no-python-invocation.Tests.ps1',
        'tests/scripts/claude-lib/discovery-validation/DiscoveryValidation.Tests.ps1',
        'tests/scripts/codex-hooks/codex-pretooluse-integration.Tests.ps1'
      )
      $out = Invoke-PoshQCAnalyze -Root (Resolve-Path '.').Path -ScanFolders $files 6>&1
      $out | ForEach-Object { Write-Output $_ }
      ```
      run via `pwsh -NoProfile -Command` (inline; no script file). This is a read-only diagnostic tool
      (it does not rewrite tracked source), so its own pass/fail behavior is a sufficient observation:
      confirmed by direct reading of `scripts/powershell/PoshQC/PoshQC.Analyzer.psm1` lines 181–186
      during planning — on success it prints exactly `PSScriptAnalyzer passed: no findings under
      <root>`, and on any finding it throws (`PSScriptAnalyzer reported N issue(s).`), which sets the
      process exit code non-zero. Acceptance: EXIT_CODE 0 and the output contains the literal substring
      `PSScriptAnalyzer passed: no findings under`. If EXIT_CODE is non-zero, restart the toolchain
      loop from P3-T1 after resolving each reported finding. Write
      `.../evidence/qa-gates/analyze-4-files.<timestamp>.md`.

### Phase 4 — Testing, Line-Count Invariant, and Scope Check (AC-6, AC-7, AC-9)

- [ ] [P4-T1] Final per-file Pester run for AC-6's "no reduction in `It` count" and "zero failed"
      requirements. Run, inline via `pwsh -NoProfile -Command`:
      ```
      $files = @(
        'tests/scripts/claude-lib/blast-radius/BlastRadius.TruthTable.Tests.ps1',
        'tests/scripts/claude-runtime/enforcement-hooks-no-python-invocation.Tests.ps1',
        'tests/scripts/claude-lib/discovery-validation/DiscoveryValidation.Tests.ps1',
        'tests/scripts/codex-hooks/codex-pretooluse-integration.Tests.ps1'
      )
      foreach ($f in $files) {
        $r = Invoke-Pester -Path $f -PassThru
        Write-Output "$f TotalCount=$($r.TotalCount) PassedCount=$($r.PassedCount) FailedCount=$($r.FailedCount)"
      }
      ```
      Acceptance: EXIT_CODE 0; for each of the four printed lines, `FailedCount=0`, and `TotalCount` is
      greater than or equal to the corresponding baseline `TotalCount` recorded in P0-T14 (blast-radius),
      P0-T16 (enforcement-hooks), P0-T18 (discovery-validation), and P0-T20 (codex-pretooluse) —
      expected exactly equal for the first three files and exactly baseline+1 for
      `codex-pretooluse-integration.Tests.ps1` (the one new `It` added in P2-T6). Write
      `.../evidence/regression-testing/final-per-file-pester-and-ac6-comparison.<timestamp>.md`,
      explicitly recording each file's baseline vs. final `TotalCount`/`FailedCount` pair.
- [ ] [P4-T2] Final per-directory Pester sweep, matching AC-6's literal "for each of the four affected
      suites" wording. Run, inline via `pwsh -NoProfile -Command`:
      ```
      $dirs = @(
        'tests/scripts/claude-lib/blast-radius',
        'tests/scripts/claude-runtime',
        'tests/scripts/claude-lib/discovery-validation',
        'tests/scripts/codex-hooks'
      )
      foreach ($d in $dirs) {
        $r = Invoke-Pester -Path $d -PassThru
        Write-Output "$d TotalCount=$($r.TotalCount) PassedCount=$($r.PassedCount) FailedCount=$($r.FailedCount)"
      }
      ```
      Acceptance: EXIT_CODE 0 and all four printed lines show `FailedCount=0`. Write
      `.../evidence/regression-testing/final-per-directory-pester.<timestamp>.md`.
- [ ] [P4-T3] Line-count invariant (AC-7). Run, inline via `pwsh -NoProfile -Command`:
      ```
      $files = @(
        'tests/scripts/claude-lib/blast-radius/BlastRadius.TruthTable.Tests.ps1',
        'tests/scripts/claude-runtime/enforcement-hooks-no-python-invocation.Tests.ps1',
        'tests/scripts/claude-lib/discovery-validation/DiscoveryValidation.Tests.ps1',
        'tests/scripts/codex-hooks/codex-pretooluse-integration.Tests.ps1'
      )
      foreach ($f in $files) { Write-Output "$f LineCount=$((Get-Content -Path $f).Count)" }
      ```
      Acceptance: EXIT_CODE 0; all four printed `LineCount` values are `<= 500`; the
      `BlastRadius.TruthTable.Tests.ps1` value equals the P0-T13 baseline exactly (net zero); the
      `enforcement-hooks-no-python-invocation.Tests.ps1` value equals the P0-T15 baseline exactly (net
      zero, satisfying the zero-headroom constraint); the `DiscoveryValidation.Tests.ps1` value equals
      the P0-T17 baseline exactly (net zero, satisfying the 23-line-headroom constraint); the
      `codex-pretooluse-integration.Tests.ps1` value equals the P0-T19 baseline plus 7 exactly. Write
      `.../evidence/qa-gates/final-line-count-invariant.<timestamp>.md`.
- [ ] [P4-T4] Scope check (AC-9): confirm no production file under `.claude/lib`, `.claude/hooks`, or
      `scripts` was modified. Run, anchored to the SHA recorded in P0-T12:
      `git diff --name-status <base-sha> -- .` followed by `git status --porcelain` (the second command
      is the required companion per the name-listing-diff rule, since the diff alone is blind to
      untracked evidence files this change creates). Acceptance: EXIT_CODE 0 for both commands; the
      `git diff --name-status` output lists only the four target test files under `tests/scripts/**`
      plus paths under
      `docs/features/active/2026-09-26-remaining-cannot-fail-count-assertions-711/` (this `spec.md`'s
      checkbox updates and any tracked evidence files); no listed path begins with `.claude/lib/`,
      `.claude/hooks/`, or `scripts/`; the `git status --porcelain` output likewise shows no path
      beginning with `.claude/lib/`, `.claude/hooks/`, or `scripts/`. Write
      `.../evidence/qa-gates/ac9-scope-check.<timestamp>.md` with both commands' full output.

### Phase 5 — Documentation & AC Check-off

- [ ] [P5-T1] Update
      `docs/features/active/2026-09-26-remaining-cannot-fail-count-assertions-711/spec.md`'s
      Acceptance Criteria section: change each of the nine `- [ ] AC-N:` checkboxes (AC-1 through AC-9)
      to `- [x] AC-N:`, and append, in parentheses after each item's existing text, a pointer to the
      evidence artifact(s) that satisfy it (per the Planner Internal Review Record's `AC-MAPPING`
      entries below). Acceptance: `spec.md`'s Acceptance Criteria section contains nine lines, each
      beginning `- [x] AC-`.
- [ ] [P5-T2] Update
      `docs/features/active/2026-09-26-remaining-cannot-fail-count-assertions-711/issue.md`'s
      Acceptance Criteria section: change each of the six `- [ ] AC-N:` checkboxes (AC-1 through AC-6)
      to `- [x] AC-N:`. Acceptance: `issue.md`'s Acceptance Criteria section contains six lines, each
      beginning `- [x] AC-`.
- [ ] [P5-T3] Write the final AC-traceability summary artifact,
      `.../evidence/other/ac-traceability-summary.<timestamp>.md`, mapping each of AC-1 through AC-9
      to its implementing task ID(s) and evidence artifact path(s), by re-reading the updated
      `spec.md` Acceptance Criteria section and cross-checking every reference against the artifacts
      actually written in Phases 0–4. Acceptance: the artifact contains exactly nine `AC-N:` entries,
      one per acceptance criterion, each naming at least one task ID and at least one evidence path
      that exists on disk at the time this task runs.

---

## Notes for the Executor

- Edit every site by content anchor, never by line number (spec D7). If P0-T21 reports a count other
  than 1 for any anchor, stop and re-resolve that anchor against the current file content before
  editing — do not proceed on a stale line-number assumption.
- No task in this plan depends on `origin/main`, any other remote-ref history, gitignored state (for
  example `artifacts/orchestration/*.json`), a temporary file, or a Windows-only path or drive letter,
  per spec's CI Constraints section. All commands above use repository-relative paths and operate on
  tracked files only.
- The two Phase 3 toolchain steps (format, analyze) and the two Phase 4 test steps (per-file,
  per-directory) together compose the mandatory PowerShell QA loop
  (`.claude/rules/general-code-change.md`: format → lint → type-check (n/a) → test). If P3-T1 reports
  any file as `Formatted:` (reformatted), restart from P3-T1 for that file before proceeding to Phase
  4. If P3-T2 or either Phase 4 test step reports a non-zero exit code or any `FailedCount` greater
  than zero, resolve the finding and restart from P3-T1.
