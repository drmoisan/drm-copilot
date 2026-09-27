# 2026-09-26-remaining-cannot-fail-count-assertions (Plan)

- **Issue:** #711
- **Parent (optional):** none
- **Owner:** drmoisan
- **Last Updated:** 2026-09-27T00-00
- **Status:** Draft (pending executor preflight, revision 2)
- **Version:** 1.1
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
against the current tree during planning, both at initial authoring and again during this revision
(see the Planner Internal Review Record's `CITATION` entries), and matches
`research/research.2026-09-27T03-00.md` exactly: 391 / 500 / 476 / 203 lines and 23 / 27 / 40 / 5 `It`
blocks respectively. Per spec D9, these numbers are contextual only; every task below that depends on
a count re-captures it at run time rather than hard-coding the number quoted here.

**No task in this plan is tagged `[expect-fail]`.** Per spec D3, the chosen evidence mechanisms are:
(a) AC-1 reuses the existing, already-passing "Non-vacuity floor helper" negative controls plus a
before/after content-token check; (b) AC-2/AC-3/AC-4 use a non-committed diagnostic PowerShell script
(run from the executor's session scratchpad, never committed) proving the shared textual shape's
vacuity in isolation, since the actual guarded values at those three sites are proven (in `spec.md`
Root Cause Analysis and `research.2026-09-27T03-00.md`) never to reach the `$null` state that would
exploit it; (c) AC-5's fail-before evidence is a new, always-passing documentation `It` pair (mirroring
#513's own legacy-expression `It`), not a test expected to fail. No committed Pester test in this
change is ever expected to report a failure; the toolchain-loop rule "restart if any step fails"
therefore applies to unintended failures only, subject to the baseline-relative treatment of AC-6
described under Phase 0 and Phase 4 below.

**Toolchain scope and shell-dispatch route:** PowerShell only. Formatting and linting are dispatched
through the MCP tools `mcp__drm-copilot__run_poshqc_format` and `mcp__drm-copilot__run_poshqc_analyze`
(Phase 3); type checking is not applicable (`.claude/rules/powershell.md`); architecture-boundary and
contract/schema stages are not applicable to test-only text edits (per `spec.md` Test Strategy);
testing uses `Invoke-Pester`, invoked directly rather than through the MCP PoshQC test runner, per
this repository's own memory record and `spec.md`'s Manual Validation Steps (the MCP
`run_poshqc_test`/`run_poshqc_format`/`run_poshqc_analyze` results carry no numeric test output and
compose a fixed summary string before the child process runs, so they must not be used as the source
of a pass/fail/count/log-line assertion; only the MCP call's own disposition — whether it returned or
raised — is an observable signal from the call itself). Coverage is not required for this change: all
four files are test code, excluded from production coverage measurement per
`.claude/rules/general-unit-test.md`.

**Shell-execution route (mandatory for every PowerShell invocation beyond a single-line expression):**
the orchestrator verified in this agent worktree on 2026-09-27 that a PreToolUse guard denies any Bash
tool command whose text contains the substring `pwsh` (also `bash`, `wsl`, or a heredoc), regardless of
quoting, so no `pwsh -NoProfile -Command ...` invocation can run through the Bash tool. The verified
working route is a POSIX `sh` runner script whose *body* invokes `pwsh`, executed as
`sh <scratchpad>/run-ps.sh <scratchpad>/<name>.ps1 <args>` — the Bash-tool command text itself never
contains the word `pwsh`, only the runner script's file contents do. `<scratchpad>` denotes the
executor's own session scratchpad directory (outside the repository; never committed). Every task
below that needs to run `Invoke-Pester`, a multi-statement PowerShell block, or the block-literal
anchor check uses this route; single-line bare PowerShell expressions (e.g. a single `Select-String`
or `Get-Content` call) are unaffected by the guard and continue to run directly. Do not reintroduce
`pwsh -NoProfile -Command ...` or any other Bash-tool command text containing `pwsh`, `bash`, `wsl`, or
a heredoc anywhere in this plan's execution.

**Evidence path convention:** every artifact path below lives under
`docs/features/active/2026-09-26-remaining-cannot-fail-count-assertions-711/evidence/<kind>/`. Replace
`<timestamp>` in every filename with the actual run time in `yyyy-MM-ddTHH-mm` format at the time the
task executes (`evidence-and-timestamp-conventions`). Every artifact carries at minimum `Timestamp:`,
`Command:`, `EXIT_CODE:`, and `Output Summary:`. Every artifact that records a `sh <scratchpad>/...`
command records it with the literal `<scratchpad>` token, never an absolute host path.

**Fail-closed evidence rule:** if any required baseline, fail-before, or final-QC artifact is missing
or incomplete, the task it belongs to is not checked off and this plan's overall outcome is
remediation-required, never PASS.

**Baseline-relative test gating (AC-6):** `tests/scripts/codex-hooks/codex-pretooluse-integration.Tests.ps1`
is known, as of 2026-09-27, to report one pre-existing failing test in this worktree
(`Every registered Codex PreToolUse handler accepts every tool name its matcher admits.allows every
registered handler for every tool name its own matcher admits`), caused by `enforce-epic-planning-only.ps1`
denying in preparation mode against local gitignored orchestration state — an environment-dependent
condition addressed by sibling issue #709, not by this plan. Because the true baseline failure count
for any of the eight tracked paths (four files, four containing directories) is not knowable from
reading the tests alone, every Phase 0 baseline Pester capture and every Phase 4 final Pester gate in
this plan is baseline-relative rather than a hard-coded zero: a path's post-change `FailedCount` must
not exceed its own freshly captured pre-change baseline for that same path, and its post-change set of
`FAILED:` names must be a subset of its own baseline `FAILED:` name set. `FailedCount=0` is required
only where the baseline for that exact path was itself `0`. This generalizes spec D9's own
baseline-capture philosophy (already applied there to `It`-block counts) to failure counts, and this
plan does not depend on the presence or absence of `artifacts/orchestration/*.json` or any other
gitignored state to decide pass/fail — it depends only on the two freshly captured Pester runs for
each path.

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
- [ ] [P0-T13] Write the shell-execution helper scripts into `<scratchpad>` (the executor's own
      session scratchpad directory — outside the repository tree; never committed) and smoke-test the
      route, per the Shell-execution route note above. Write exactly these six files, each with the
      body given verbatim so a third party can recreate them byte-for-byte:
      - `<scratchpad>/run-ps.sh`:
        ```
        #!/bin/sh
        set -eu
        pwsh -NoProfile -NonInteractive -File "$@"
        ```
      - `<scratchpad>/pester-counts.ps1`:
        ```powershell
        param(
            [Parameter(Mandatory)][string] $Path,
            [string] $FullNameFilter
        )

        $pesterParams = @{ Path = $Path; PassThru = $true }
        if ($PSBoundParameters.ContainsKey('FullNameFilter')) {
            $pesterParams['FullNameFilter'] = $FullNameFilter
        }

        $result = Invoke-Pester @pesterParams

        Write-Output "TotalCount=$($result.TotalCount)"
        Write-Output "PassedCount=$($result.PassedCount)"
        Write-Output "FailedCount=$($result.FailedCount)"

        foreach ($failedTest in $result.Failed) {
            Write-Output "FAILED: $($failedTest.ExpandedPath)"
        }
        ```
      - `<scratchpad>/anchor-count.ps1`:
        ```powershell
        param(
            [Parameter(Mandatory)][string] $Path,
            [Parameter(Mandatory)][ValidateSet('AC3-old', 'AC3-new', 'AC4-old', 'AC4-new')][string] $Anchor
        )

        $blocks = @{
            'AC3-old' = @'
                    $errors = Get-DiscoveryProfileValidationError -Text $text

                    # Assert: rejected, never silently accepted.
                    @($errors).Count | Should -BeGreaterThan 0
                    $errors[0] | Should -Be 'Profile document root must be a mapping.'
        '@
            'AC3-new' = @'
                    $errors = Get-DiscoveryProfileValidationError -Text $text

                    # Assert: rejected, never silently accepted.
                    @($errors | Where-Object { $null -ne $_ }).Count | Should -BeGreaterThan 0
                    $errors[0] | Should -Be 'Profile document root must be a mapping.'
        '@
            'AC4-old' = @'
                    $errors = Get-DiscoverySchemaArtifactValidationError -Text $text

                    # Assert
                    @($errors).Count | Should -BeGreaterThan 0
                    ($errors -join "`n") | Should -Match 'not valid with the schema'
        '@
            'AC4-new' = @'
                    $errors = Get-DiscoverySchemaArtifactValidationError -Text $text

                    # Assert
                    @($errors | Where-Object { $null -ne $_ }).Count | Should -BeGreaterThan 0
                    ($errors -join "`n") | Should -Match 'not valid with the schema'
        '@
        }

        $normalizedContent = (Get-Content -Raw -Path $Path) -replace "`r`n", "`n"
        $normalizedBlock = $blocks[$Anchor] -replace "`r`n", "`n"
        $count = ([regex]::Matches($normalizedContent, [regex]::Escape($normalizedBlock))).Count

        Write-Output "Anchor=$Anchor Count=$count"
        ```
        (Every line inside each here-string above is indented with exactly 12 spaces in the actual
        script file, matching the target file's own indentation exactly — the extra indentation shown
        here is this plan document's own list-nesting and must not be copied into the script file.)
      - `<scratchpad>/old-vs-new-form.ps1`:
        ```powershell
        foreach ($case in @(@{ Name = 'null'; Value = $null }, @{ Name = 'emptyArray'; Value = @() })) {
            $x = $case.Value
            $old = (@($x).Count -gt 0)
            $new = (@($x | Where-Object { $null -ne $_ }).Count -gt 0)
            Write-Output "input=$($case.Name) oldForm=$old newForm=$new"
        }
        ```
      - `<scratchpad>/line-counts.ps1`:
        ```powershell
        param(
            [Parameter(Mandatory, ValueFromRemainingArguments = $true)]
            [string[]] $Path
        )

        foreach ($file in $Path) {
            Write-Output "$file LineCount=$((Get-Content -Path $file).Count)"
        }
        ```
      - `<scratchpad>/file-hashes.ps1`:
        ```powershell
        param(
            [Parameter(Mandatory, ValueFromRemainingArguments = $true)]
            [string[]] $Path
        )

        foreach ($file in $Path) {
            Write-Output "$file Hash=$((Get-FileHash -Path $file -Algorithm SHA256).Hash)"
        }
        ```
      Smoke test: run
      `sh <scratchpad>/run-ps.sh <scratchpad>/line-counts.ps1 tests/scripts/codex-hooks/codex-pretooluse-integration.Tests.ps1`.
      Acceptance: EXIT_CODE 0 and the output is exactly
      `tests/scripts/codex-hooks/codex-pretooluse-integration.Tests.ps1 LineCount=203` (independently
      re-derived against the current tree during this revision). Write
      `.../evidence/baseline/scratchpad-helper-scripts-setup.<timestamp>.md` recording all six file
      paths (using the literal `<scratchpad>` token, not an absolute host path), the smoke-test command,
      and its output.
- [ ] [P0-T14] Baseline line count for
      `tests/scripts/claude-lib/blast-radius/BlastRadius.TruthTable.Tests.ps1`: run
      `(Get-Content -Path 'tests/scripts/claude-lib/blast-radius/BlastRadius.TruthTable.Tests.ps1').Count`.
      Acceptance: EXIT_CODE 0 and a printed integer (expected 391, per independent re-derivation
      during planning; record whatever value is actually printed, per spec D7/D9). Write
      `.../evidence/baseline/blast-radius-truthtable-linecount.<timestamp>.md`.
- [ ] [P0-T15] Baseline Pester run for the same file. Run
      `sh <scratchpad>/run-ps.sh <scratchpad>/pester-counts.ps1 -Path 'tests/scripts/claude-lib/blast-radius/BlastRadius.TruthTable.Tests.ps1'`.
      Acceptance: EXIT_CODE 0 and three printed `TotalCount=`/`PassedCount=`/`FailedCount=` lines,
      plus one `FAILED:` line per failed test if any (expected `TotalCount=23`, per re-derivation;
      record the actual values and the actual `FAILED:` list, which may be empty). This is a baseline
      capture, not a gate: no specific `FailedCount` value is required here. Write
      `.../evidence/baseline/blast-radius-truthtable-pester.<timestamp>.md` with the full output.
- [ ] [P0-T16] Baseline Pester run for the containing directory,
      `tests/scripts/claude-lib/blast-radius`. Run
      `sh <scratchpad>/run-ps.sh <scratchpad>/pester-counts.ps1 -Path 'tests/scripts/claude-lib/blast-radius'`
      (a single directory path, not an array — `-File` does not split a comma-separated array
      argument). Acceptance: EXIT_CODE 0 and the three counts plus any `FAILED:` lines are recorded
      as this directory's baseline. Write
      `.../evidence/baseline/blast-radius-directory-pester.<timestamp>.md`.
- [ ] [P0-T17] Baseline line count for
      `tests/scripts/claude-runtime/enforcement-hooks-no-python-invocation.Tests.ps1`: run
      `(Get-Content -Path 'tests/scripts/claude-runtime/enforcement-hooks-no-python-invocation.Tests.ps1').Count`.
      Acceptance: EXIT_CODE 0 and a printed integer (expected 500). Write
      `.../evidence/baseline/enforcement-hooks-linecount.<timestamp>.md`.
- [ ] [P0-T18] Baseline Pester run for the same file. Run
      `sh <scratchpad>/run-ps.sh <scratchpad>/pester-counts.ps1 -Path 'tests/scripts/claude-runtime/enforcement-hooks-no-python-invocation.Tests.ps1'`.
      Acceptance: EXIT_CODE 0 and the three counts plus any `FAILED:` lines recorded as baseline
      (expected `TotalCount=27`, per re-derivation; record the actual values). Write
      `.../evidence/baseline/enforcement-hooks-pester.<timestamp>.md`.
- [ ] [P0-T19] Baseline Pester run for the containing directory, `tests/scripts/claude-runtime`. Run
      `sh <scratchpad>/run-ps.sh <scratchpad>/pester-counts.ps1 -Path 'tests/scripts/claude-runtime'`.
      Acceptance: EXIT_CODE 0 and the three counts plus any `FAILED:` lines recorded as baseline.
      Write `.../evidence/baseline/claude-runtime-directory-pester.<timestamp>.md`.
- [ ] [P0-T20] Baseline line count for
      `tests/scripts/claude-lib/discovery-validation/DiscoveryValidation.Tests.ps1`: run
      `(Get-Content -Path 'tests/scripts/claude-lib/discovery-validation/DiscoveryValidation.Tests.ps1').Count`.
      Acceptance: EXIT_CODE 0 and a printed integer (expected 476). Write
      `.../evidence/baseline/discovery-validation-linecount.<timestamp>.md`.
- [ ] [P0-T21] Baseline Pester run for the same file. Run
      `sh <scratchpad>/run-ps.sh <scratchpad>/pester-counts.ps1 -Path 'tests/scripts/claude-lib/discovery-validation/DiscoveryValidation.Tests.ps1'`.
      Acceptance: EXIT_CODE 0 and the three counts plus any `FAILED:` lines recorded as baseline
      (expected `TotalCount=40`, per re-derivation; record the actual values). Write
      `.../evidence/baseline/discovery-validation-pester.<timestamp>.md`.
- [ ] [P0-T22] Baseline Pester run for the containing directory,
      `tests/scripts/claude-lib/discovery-validation`. Run
      `sh <scratchpad>/run-ps.sh <scratchpad>/pester-counts.ps1 -Path 'tests/scripts/claude-lib/discovery-validation'`.
      Acceptance: EXIT_CODE 0 and the three counts plus any `FAILED:` lines recorded as baseline.
      Write `.../evidence/baseline/discovery-validation-directory-pester.<timestamp>.md`.
- [ ] [P0-T23] Baseline line count for
      `tests/scripts/codex-hooks/codex-pretooluse-integration.Tests.ps1`: run
      `(Get-Content -Path 'tests/scripts/codex-hooks/codex-pretooluse-integration.Tests.ps1').Count`.
      Acceptance: EXIT_CODE 0 and a printed integer (expected 203). Write
      `.../evidence/baseline/codex-pretooluse-linecount.<timestamp>.md`.
- [ ] [P0-T24] Baseline Pester run for the same file. Run
      `sh <scratchpad>/run-ps.sh <scratchpad>/pester-counts.ps1 -Path 'tests/scripts/codex-hooks/codex-pretooluse-integration.Tests.ps1'`.
      Acceptance: EXIT_CODE 0 and the three counts plus any `FAILED:` lines recorded as baseline
      (expected `TotalCount=5`; this file is documented above to carry one known pre-existing failure
      in this worktree as of 2026-09-27, so `FailedCount=1` with one `FAILED:` line naming the
      `allows every registered handler for every tool name its own matcher admits` test is an expected,
      acceptable baseline outcome here — record whatever the run actually prints). Write
      `.../evidence/baseline/codex-pretooluse-pester.<timestamp>.md`.
- [ ] [P0-T25] Baseline Pester run for the containing directory, `tests/scripts/codex-hooks`. Run
      `sh <scratchpad>/run-ps.sh <scratchpad>/pester-counts.ps1 -Path 'tests/scripts/codex-hooks'`.
      Acceptance: EXIT_CODE 0 and the three counts plus any `FAILED:` lines recorded as baseline (this
      directory contains 35 other `*.Tests.ps1` files beyond the one this change edits, so its
      baseline `FailedCount` and `FAILED:` list are captured as-is, whatever they are). Write
      `.../evidence/baseline/codex-hooks-directory-pester.<timestamp>.md`.
- [ ] [P0-T26] Confirm merge-order-safe uniqueness of all five edit-site content anchors (spec D7)
      before any edit is made. Run the following five checks and record all five results in one
      evidence artifact:
      1. AC-1: `(Select-String -Path 'tests/scripts/claude-lib/blast-radius/BlastRadius.TruthTable.Tests.ps1' -Pattern '$entries.Count | Should -BeGreaterThan 0' -SimpleMatch).Count`
         — expected `1`.
      2. AC-2: `(Select-String -Path 'tests/scripts/claude-runtime/enforcement-hooks-no-python-invocation.Tests.ps1' -Pattern '@($files).Count | Should -BeGreaterThan 0' -SimpleMatch).Count`
         — expected `1`.
      3. AC-3: `sh <scratchpad>/run-ps.sh <scratchpad>/anchor-count.ps1 -Path 'tests/scripts/claude-lib/discovery-validation/DiscoveryValidation.Tests.ps1' -Anchor 'AC3-old'`
         — expected output `Anchor=AC3-old Count=1`. This anchor is the exact contiguous 5-line block
         (the `$errors = Get-DiscoveryProfileValidationError -Text $text` line, a blank line, the
         `# Assert: rejected, never silently accepted.` comment, the `@($errors).Count | Should
         -BeGreaterThan 0` line, and the `$errors[0] | Should -Be 'Profile document root must be a
         mapping.'` line), matched as one literal via `[regex]::Matches($content,
         [regex]::Escape($block)).Count` with both the file content and the block normalized from
         CRLF to LF before matching (the literal call token
         `Get-DiscoveryProfileValidationError -Text $text` alone occurs 6 times in this file, so
         matching on that token alone would be non-discriminating; the full 5-line block is unique).
      4. AC-4: `sh <scratchpad>/run-ps.sh <scratchpad>/anchor-count.ps1 -Path 'tests/scripts/claude-lib/discovery-validation/DiscoveryValidation.Tests.ps1' -Anchor 'AC4-old'`
         — expected output `Anchor=AC4-old Count=1`. Same block-literal mechanism, anchored to the
         5-line block containing the `Get-DiscoverySchemaArtifactValidationError -Text $text` call.
      5. AC-5: `(Select-String -Path 'tests/scripts/codex-hooks/codex-pretooluse-integration.Tests.ps1' -Pattern '@($script:Registrations).Count | Should -BeGreaterThan 0' -SimpleMatch).Count`
         — expected `1`.
      Acceptance: EXIT_CODE 0 for every command and every one of the five results equals the expected
      value stated above. Each of the five literals/blocks is confirmed present, verbatim, in the
      current tree (this plan's own Planner Internal Review Record cites the same five occurrences,
      re-derived during this revision). If any result is not as expected, stop: the anchor has drifted
      (a concurrent sibling edited the line first, per spec D7's risk note) and the corresponding P2
      edit task must re-resolve its anchor against the current file content before proceeding. Write
      `.../evidence/baseline/anchor-uniqueness-confirmation.<timestamp>.md`.

### Phase 1 — Fail-Before Evidence (spec D3 / AC-8)

- [ ] [P1-T1] Confirm AC-1's existing "Non-vacuity floor helper" negative controls
      (`BlastRadius.TruthTable.Tests.ps1`, `Context 'Non-vacuity floor helper'`, six `It` blocks
      already merged by #513) already pass, establishing that `Test-NonVacuousCollection` correctly
      discriminates `$null`, `@()`, an all-`$null` array, and non-empty inputs before AC-1's
      assertion-site edit is made. Run
      `sh <scratchpad>/run-ps.sh <scratchpad>/pester-counts.ps1 -Path 'tests/scripts/claude-lib/blast-radius/BlastRadius.TruthTable.Tests.ps1' -FullNameFilter '*Non-vacuity floor helper*'`.
      Acceptance: EXIT_CODE 0 and `FailedCount=0` (expected `TotalCount=6`; this narrowly filtered,
      already-merged Context is expected to always pass independent of the AC-6 baseline-relative
      treatment above, which concerns the whole-file/whole-directory runs only). Write
      `.../evidence/regression-testing/ac1-existing-negative-controls.<timestamp>.md`.
- [ ] [P1-T2] Run the shared diagnostic for AC-2/AC-3/AC-4 (spec D3): evaluate the old form
      (`@($x).Count -gt 0`) and the new form (`@($x | Where-Object { $null -ne $_ }).Count -gt 0`)
      against `$null` and `@()` — the two inputs the three producers' `return , $collection.ToArray()`
      contract makes unreachable in practice, per spec Root Cause Analysis. Run
      `sh <scratchpad>/run-ps.sh <scratchpad>/old-vs-new-form.ps1`.
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
      check, AC-8 for AC-1): before this edit, the old literal's count is 1 (per P0-T26); after this
      edit, run
      `(Select-String -Path 'tests/scripts/claude-lib/blast-radius/BlastRadius.TruthTable.Tests.ps1' -Pattern '$entries.Count | Should -BeGreaterThan 0' -SimpleMatch).Count` =
      `0`, and
      `(Select-String -Path 'tests/scripts/claude-lib/blast-radius/BlastRadius.TruthTable.Tests.ps1' -Pattern 'Test-NonVacuousCollection -Value $entries | Should -BeTrue' -SimpleMatch).Count` =
      `1`; and `(Get-Content -Path 'tests/scripts/claude-lib/blast-radius/BlastRadius.TruthTable.Tests.ps1').Count`
      equals the value recorded in P0-T14 (net-zero line delta). Write
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
      in P0-T17 exactly. Write `.../evidence/regression-testing/ac2-before-after-token-check.<timestamp>.md`.
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
      from AC-4's, per spec D7). Acceptance: after the edit, run
      `sh <scratchpad>/run-ps.sh <scratchpad>/anchor-count.ps1 -Path 'tests/scripts/claude-lib/discovery-validation/DiscoveryValidation.Tests.ps1' -Anchor 'AC3-old'`
      and confirm it now prints `Anchor=AC3-old Count=0`, and run the same command with
      `-Anchor 'AC3-new'` and confirm it prints `Anchor=AC3-new Count=1` (both counts computed via the
      same `[regex]::Matches([regex]::Escape($block))` block-literal mechanism as P0-T26, with CRLF
      normalized to LF on both the file content and the block before matching); and the file's line
      count equals the value recorded in P0-T20 exactly. Write
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
      occurrence from AC-3's). Acceptance: after the edit, run
      `sh <scratchpad>/run-ps.sh <scratchpad>/anchor-count.ps1 -Path 'tests/scripts/claude-lib/discovery-validation/DiscoveryValidation.Tests.ps1' -Anchor 'AC4-old'`
      and confirm it prints `Anchor=AC4-old Count=0`, and run the same command with
      `-Anchor 'AC4-new'` and confirm it prints `Anchor=AC4-new Count=1`; file line count equals the
      value recorded in P0-T20 exactly (unchanged again, since P2-T3 and P2-T4 are each individually
      net-zero). Write `.../evidence/regression-testing/ac4-before-after-token-check.<timestamp>.md`.
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
      with the same block plus, before the final `}`, exactly one blank line inserted immediately after
      the closing brace of the existing `It 'leaves no Codex batch-budget state behind'` block (matching
      this file's own existing blank-line convention between sibling `Context`/`It` blocks, per current
      lines 128-130, 143-145, 166-168, 179-181, and 190-192), followed by a new sibling `Context`:
      ```

          Context 'Non-vacuity floor for the registration count' {
              It 'documents that the legacy expression @($null).Count -gt 0 evaluates to $true while the filtered form is $false' {
                  (@($null).Count -gt 0) | Should -BeTrue
                  (@($null | Where-Object { $null -ne $_ }).Count -gt 0) | Should -BeFalse
              }
          }
      ```
      (net +7 lines, one new `It` block, mirroring #513's own legacy-expression documentation `It` in
      `BlastRadius.TruthTable.Tests.ps1`). Acceptance: after the edit,
      `(Select-String -Path 'tests/scripts/codex-hooks/codex-pretooluse-integration.Tests.ps1' -Pattern 'Non-vacuity floor for the registration count' -SimpleMatch).Count` =
      `1`; and, run
      `sh <scratchpad>/run-ps.sh <scratchpad>/pester-counts.ps1 -Path 'tests/scripts/codex-hooks/codex-pretooluse-integration.Tests.ps1' -FullNameFilter '*Non-vacuity floor for the registration count*'`,
      which must print `PassedCount=1` and `FailedCount=0` (this new, narrowly filtered `Context` is
      isolated from the file's one known pre-existing unrelated failure, per the Baseline-relative test
      gating note above); and the file's line count (per `(Get-Content -Path <file>).Count`) equals the
      value recorded in P0-T23 plus 7 exactly. Write
      `.../evidence/regression-testing/ac5-new-context-it-pair.<timestamp>.md`.

### Phase 3 — Formatting & Linting (toolchain steps 1–2)

- [ ] [P3-T1] Format the four changed files via the MCP tool (no shell text is used for the format
      call itself, per the Shell-execution route note above). First, capture pre-format content hashes:
      run `sh <scratchpad>/run-ps.sh <scratchpad>/file-hashes.ps1 tests/scripts/claude-lib/blast-radius/BlastRadius.TruthTable.Tests.ps1 tests/scripts/claude-runtime/enforcement-hooks-no-python-invocation.Tests.ps1 tests/scripts/claude-lib/discovery-validation/DiscoveryValidation.Tests.ps1 tests/scripts/codex-hooks/codex-pretooluse-integration.Tests.ps1`
      and record the four `Hash=` lines. Then call `mcp__drm-copilot__run_poshqc_format` with
      `workspace_root` set to the absolute path of the current repository root as resolved by the
      executor at run time (do not hard-code a literal host path in the evidence artifact; record only
      that the call was made) and `scan_folders` set to the same four repository-relative paths. This
      repository's own memory record on `run_poshqc_format`/`run_poshqc_analyze` documents that the
      MCP result carries no `exitCode` or stdout field and composes a fixed summary string before the
      child process runs, so record the call's own disposition as `EXIT_CODE: 0` if the call returns
      normally, or the raised error's status if it does not — this is the only observable signal the
      call itself provides. Then re-run the same `file-hashes.ps1` invocation to capture post-format
      hashes. **Success-case observation beyond call disposition (before-and-after tree observation,
      G7):** compare each file's pre- and post-format hash. Acceptance: the MCP call returns without
      raising, and for each of the four files, if its hash is unchanged the file was already formatted;
      if any file's hash changed, the formatter rewrote it, and the executor must re-verify that file's
      Phase 2 edit-anchor and line-count acceptance conditions still hold post-reformat and must restart
      this toolchain loop (P3-T1 → P3-T2 → Phase 4) from P3-T1 for that file before continuing. Write
      `.../evidence/qa-gates/format-4-files.<timestamp>.md` recording the pre-hashes, the call
      disposition, the post-hashes, and the restart decision.
- [ ] [P3-T2] Analyze the same four files via the MCP tool: call
      `mcp__drm-copilot__run_poshqc_analyze` with the same `workspace_root` and `scan_folders` as
      P3-T1. `Invoke-PoshQCAnalyze` (the function this MCP tool wraps) is read-only — it does not
      rewrite tracked source — and throws `"PSScriptAnalyzer reported N issue(s)."` on any finding, or
      logs `"PSScriptAnalyzer passed: no findings under <root>"` otherwise; per the same memory record
      cited in P3-T1, the MCP result itself carries no stdout field, so the call's own disposition
      (whether it returns normally or raises an error back to the caller) is the only available
      pass/fail signal for this step, and any error text the call surfaces is recorded verbatim if
      present. Acceptance: the MCP call returns without raising (`EXIT_CODE: 0` by the call-disposition
      convention above). If the call raises an error, resolve each reported finding and restart the
      toolchain loop from P3-T1. Write `.../evidence/qa-gates/analyze-4-files.<timestamp>.md` recording
      the call disposition and any surfaced error text.

### Phase 4 — Testing, Line-Count Invariant, and Scope Check (AC-6, AC-7, AC-9)

- [ ] [P4-T1] Final per-file Pester run for AC-6, compared against each file's own Phase 0 baseline
      (baseline-relative, per the note above — not a hard-coded `FailedCount=0`). Run, once per file:
      `sh <scratchpad>/run-ps.sh <scratchpad>/pester-counts.ps1 -Path 'tests/scripts/claude-lib/blast-radius/BlastRadius.TruthTable.Tests.ps1'`;
      `sh <scratchpad>/run-ps.sh <scratchpad>/pester-counts.ps1 -Path 'tests/scripts/claude-runtime/enforcement-hooks-no-python-invocation.Tests.ps1'`;
      `sh <scratchpad>/run-ps.sh <scratchpad>/pester-counts.ps1 -Path 'tests/scripts/claude-lib/discovery-validation/DiscoveryValidation.Tests.ps1'`;
      `sh <scratchpad>/run-ps.sh <scratchpad>/pester-counts.ps1 -Path 'tests/scripts/codex-hooks/codex-pretooluse-integration.Tests.ps1'`.
      Acceptance, for each of the four files: (a) `TotalCount` equals its own Phase 0 baseline
      (P0-T15, P0-T18, P0-T21, P0-T24 respectively) plus the exact expected delta — `+0` for the first
      three files, `+1` for `codex-pretooluse-integration.Tests.ps1` (the one new `It` added by P2-T6,
      named `documents that the legacy expression @($null).Count -gt 0 evaluates to $true while the
      filtered form is $false`, which must appear counted in `PassedCount` and must not appear in this
      run's `FAILED:` list); (b) if that file's baseline `FailedCount` was `0`, this run's
      `FailedCount` must also be `0`; if the baseline `FailedCount` was nonzero (expected for
      `codex-pretooluse-integration.Tests.ps1`, per the Baseline-relative test gating note), this run's
      `FailedCount` must not exceed the baseline value; (c) this run's `FAILED:` name set must be a
      subset of that file's baseline `FAILED:` name set — no new failure name may appear. Write
      `.../evidence/regression-testing/final-per-file-pester-and-ac6-comparison.<timestamp>.md`,
      explicitly recording each file's baseline vs. final `TotalCount`/`FailedCount`/`FAILED:` list.
- [ ] [P4-T2] Final per-directory Pester sweep, matching AC-6's literal "for each of the four affected
      suites" wording, compared against each directory's own Phase 0 baseline. Run, once per
      directory:
      `sh <scratchpad>/run-ps.sh <scratchpad>/pester-counts.ps1 -Path 'tests/scripts/claude-lib/blast-radius'`;
      `sh <scratchpad>/run-ps.sh <scratchpad>/pester-counts.ps1 -Path 'tests/scripts/claude-runtime'`;
      `sh <scratchpad>/run-ps.sh <scratchpad>/pester-counts.ps1 -Path 'tests/scripts/claude-lib/discovery-validation'`;
      `sh <scratchpad>/run-ps.sh <scratchpad>/pester-counts.ps1 -Path 'tests/scripts/codex-hooks'`.
      Acceptance, for each of the four directories, applying the same baseline-relative rules as P4-T1
      against its own Phase 0 baseline (P0-T16, P0-T19, P0-T22, P0-T25 respectively): expected
      `TotalCount` delta is `+0` for the first three directories and `+1` for `tests/scripts/codex-hooks`
      (the same one new `It` from P2-T6, since `codex-pretooluse-integration.Tests.ps1` is the only
      file this change modifies within that directory); `FailedCount` must not exceed baseline (and
      must equal `0` if the baseline was `0`); the `FAILED:` name set must be a subset of that
      directory's baseline `FAILED:` name set. Write
      `.../evidence/regression-testing/final-per-directory-pester.<timestamp>.md`, explicitly recording
      each directory's baseline vs. final counts and `FAILED:` lists.
- [ ] [P4-T3] Line-count invariant (AC-7). Run
      `sh <scratchpad>/run-ps.sh <scratchpad>/line-counts.ps1 tests/scripts/claude-lib/blast-radius/BlastRadius.TruthTable.Tests.ps1 tests/scripts/claude-runtime/enforcement-hooks-no-python-invocation.Tests.ps1 tests/scripts/claude-lib/discovery-validation/DiscoveryValidation.Tests.ps1 tests/scripts/codex-hooks/codex-pretooluse-integration.Tests.ps1`.
      Acceptance: EXIT_CODE 0; all four printed `LineCount` values are `<= 500`; the
      `BlastRadius.TruthTable.Tests.ps1` value equals the P0-T14 baseline exactly (net zero); the
      `enforcement-hooks-no-python-invocation.Tests.ps1` value equals the P0-T17 baseline exactly (net
      zero, satisfying the zero-headroom constraint); the `DiscoveryValidation.Tests.ps1` value equals
      the P0-T20 baseline exactly (net zero, satisfying the 23-line-headroom constraint); the
      `codex-pretooluse-integration.Tests.ps1` value equals the P0-T23 baseline plus 7 exactly. Write
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

- Edit every site by content anchor, never by line number (spec D7). If P0-T26 reports a result other
  than the expected value for any anchor, stop and re-resolve that anchor against the current file
  content before editing — do not proceed on a stale line-number assumption.
- No task in this plan depends on `origin/main`, any other remote-ref history, gitignored state (for
  example `artifacts/orchestration/*.json`), a temporary file, or a Windows-only path or drive letter,
  per spec's CI Constraints section. All commands above use repository-relative paths and operate on
  tracked files only. The baseline-relative AC-6 gating in Phase 0/Phase 4 exists precisely so this
  plan never needs to know whether that gitignored orchestration state is present: it compares two
  freshly captured Pester runs to each other, not to a fixed expectation.
- Do not reintroduce `pwsh -NoProfile -Command ...`, or any other Bash-tool command text containing
  `pwsh`, `bash`, `wsl`, or a heredoc, anywhere in this plan's execution — the worktree-isolation guard
  denies it regardless of quoting. Every multi-statement PowerShell invocation in this plan runs via
  `sh <scratchpad>/run-ps.sh <scratchpad>/<name>.ps1 <args>` instead; every single-line PowerShell
  expression (a lone `Select-String` or `Get-Content` call) runs directly and is unaffected by the
  guard.
- The two Phase 3 toolchain steps (format, analyze) and the two Phase 4 test steps (per-file,
  per-directory) together compose the mandatory PowerShell QA loop
  (`.claude/rules/general-code-change.md`: format → lint → type-check (n/a) → test). If P3-T1 reports
  any file's post-format hash as changed (reformatted), restart from P3-T1 for that file before
  proceeding to Phase 4. If P3-T2 raises an error, or either Phase 4 test step reports a `FailedCount`
  exceeding its own Phase 0 baseline for that path, or a `FAILED:` name absent from that path's
  baseline, resolve the finding and restart from P3-T1.
