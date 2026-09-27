# gate-suites-read-unmocked-local-epic-state (Plan)

- **Issue:** #709
- **Parent (optional):** none
- **Owner:** drmoisan
- **Last Updated:** 2026-09-27T00-20
- **Status:** Revision round 2 applied (7 preflight deltas); ready for executor preflight
- **Version:** 1.2
- **Work Mode:** full-bug (from `issue.md` metadata; `spec.md` is the sole acceptance-criteria source)
- **Branch:** `bug/gate-suites-read-unmocked-local-epic-state-709`
- **Feature folder:** `docs/features/active/gate-suites-read-unmocked-local-epic-state-709/` (referred to below as `<FEATURE>`)
- **Requirements:** `<FEATURE>/spec.md` (AC1-AC9), `<FEATURE>/issue.md`, `<FEATURE>/research/research.2026-09-26T23-00.md`

**Fail-closed evidence rule:** Include explicit baseline artifact tasks, final-QA artifact tasks, and coverage-comparison tasks for each in-scope language when policy requires coverage. If any required baseline artifact, QA artifact, or coverage-comparison artifact is missing, the audit verdict must be BLOCKED or INCOMPLETE, never PASS.

**Evidence accounting rule:** Record the expected artifact path or location in each evidence-producing task. Do not mark evidence-backed work complete without the artifact.

## Scope Summary

Test-only change. No production file, hook, library module, push-down mirror under `extensions/drm-copilot/resources/`, or Pester settings file is edited.

Files written by this plan (exact set; nothing else outside `<FEATURE>/` is written):

| ID | Repository-relative path | Change |
|---|---|---|
| S1 | `tests/scripts/claude-hooks/enforce-pr-author-skill.TargetResolution.Tests.ps1` | two-line insertion |
| S2 | `tests/scripts/claude-hooks/enforce-pr-author-skill.WorktreeResolution.Tests.ps1` | two-line insertion |
| S3 | `tests/scripts/claude-hooks/enforce-model-routing-receipt.WorktreeResolution.Tests.ps1` | two-line insertion |
| S4 | `tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.Tests.ps1` | two-line insertion |
| S5 | `tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.TriggerScoping.Tests.ps1` | two-line insertion |
| S6 | `tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.CommandExemption.Tests.ps1` | two-line insertion |
| S7 | `tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-absolute-paths.Tests.ps1` | two-line insertion |
| N1 | `tests/scripts/claude-hooks/enforce-gate-suites.EpicStateIsolation.Tests.ps1` | new file |

Read-only in this plan (run or read, never written): `tests/scripts/claude-hooks/enforce-pr-author-skill.EpicScope.Tests.ps1`, `tests/scripts/claude-hooks/enforce-model-routing-receipt.EpicScope.Tests.ps1`, `tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.EpicScope.Tests.ps1`, `.claude/lib/worktree-resolution/EpicScopeResolution.psm1`, `scripts/powershell/PoshQC/settings/pester.runsettings.psd1`, `scripts/powershell/PoshQC/settings/pssa.settings.psd1`.

## Evidence Location

All evidence is written under `<FEATURE>/evidence/<kind>/` with kinds `baseline`, `regression-testing`, `qa-gates`, `other`, and `remediation-baseline` only.

EVIDENCE_LOCATION_OVERRIDE_REJECTED: docs/features/active/gate-suites-read-unmocked-local-epic-state-709/evidence/baselines/ replaced with docs/features/active/gate-suites-read-unmocked-local-epic-state-709/evidence/baseline/

`spec.md` AC5 names `evidence/baselines/` (plural). That kind is not canonical; this plan writes the before-change records to `<FEATURE>/evidence/baseline/`, and the AC5 check-off task (P5-T14) records the substitution in the `ac-checkoff` artifact.

`<ts>` in an artifact name is the executor's write time in `yyyy-MM-ddTHH-mm` form. Every command-step artifact carries `Timestamp:`, `Command:`, `EXIT_CODE:`, and `Output Summary:`; an artifact whose expected exit code is non-zero also carries `ExpectedExitCode: 1`. Artifacts record repository-relative paths only; replace any absolute worktree prefix that a tool prints with `<repo>` before writing.

## Hermeticity Constraints (apply to N1 and to every edit)

- No temporary files: no `New-TemporaryFile`, no `TestDrive:`, no writes under `$env:TEMP`, no `GetTempPath`/`GetTempFileName`.
- No gitignored state: no read of any file under `artifacts/orchestration/`.
- No git history: no reference to `origin/main`, no git invocation from test code (the CI checkout is depth-1).
- No drive letters or Windows-only paths; synthetic roots use `/synthetic-worktrees/...`; repository files are located from `$PSScriptRoot` with `Join-Path` or `Resolve-Path`.

## Merge-Order Independence (D6)

Siblings #710 and #713 may edit S4-S6; #707 and #708 touch other files. This plan never assumes a sibling merged first or last. Insertion points are located by content anchor (table below), never by line number. The research line numbers are informational only.

### Edit Protocol (EP) for S1-S7

| ID | Outermost `BeforeAll` | Anchor line (trimmed, verbatim) | Indent | Import line form |
|---|---|---|---|---|
| S1 | the `BeforeAll` directly inside `Describe 'enforce-pr-author-skill.ps1 target resolution'` | `. $script:UnderTest` | 8 spaces | FORM-R |
| S2 | the file-level `BeforeAll` (before the only `Describe`) | `Import-Module (Join-Path $script:HookRoot 'lib/worktree-resolution/WorktreeTargetResolution.psm1')` | 4 spaces | FORM-H |
| S3 | the file-level `BeforeAll` (before the only `Describe`) | `Import-Module (Join-Path $script:HookRoot 'lib/worktree-resolution/WorktreeTargetResolution.psm1')` | 4 spaces | FORM-H |
| S4 | the `BeforeAll` directly inside `Describe 'enforce-orchestration-preimplementation-gate.ps1'` | `. $script:UnderTest` | 8 spaces | FORM-R |
| S5 | the `BeforeAll` directly inside `Describe 'enforce-orchestration-preimplementation-gate.ps1 trigger scoping (issue #545)'` | `. $script:UnderTest` | 8 spaces | FORM-R |
| S6 | the `BeforeAll` directly inside `Describe 'enforce-orchestration-preimplementation-gate.ps1 command exemption (issue #539)'` | `. $script:UnderTest` | 8 spaces | FORM-R |
| S7 | the `BeforeAll` directly inside `Describe 'enforce-orchestration-preimplementation-gate.ps1 absolute-path classification'` | `. $script:UnderTest` | 8 spaces | FORM-R |

Inserted lines (verbatim, before indentation):

- FORM-R import line: `Import-Module (Resolve-Path "$PSScriptRoot/../../../.claude/lib/worktree-resolution/EpicScopeResolution.psm1").Path`
- FORM-H import line: `Import-Module (Join-Path $script:HookRoot 'lib/worktree-resolution/EpicScopeResolution.psm1')`
- Mock line (all seven): `Mock Get-EpicScopeCheckpointText -ModuleName EpicScopeResolution { $null }`

Protocol steps, applied by every edit task:

1. EP-1 Locate the outermost `BeforeAll` named in the table by reading the file; do not use a line number.
2. EP-2 Inside that block, count lines whose trimmed text equals the anchor. Exactly one is required. If the count is not one, make no edit, record `ANCHOR-COUNT: <n>` in the batch artifact, and stop with BLOCKED for orchestrator review.
3. EP-3 Idempotence. If that block already contains a line whose trimmed text equals the Mock line, and an `Import-Module` line naming `EpicScopeResolution.psm1` without `-Force` sits between the anchor and that Mock line, make no edit and record `ALREADY-PRESENT: <path>`. If only one of the two lines is present, or the import carries `-Force`, or either sits before the anchor, make no edit and stop with BLOCKED (sibling divergence; escalate).
4. EP-4 Otherwise insert the import line and then the Mock line, in that order, directly after the anchor line, at the table's indentation, using the file's existing line-ending convention. Do not add a comment, blank line, or any other change. Do not reflow, reorder, or reformat any existing line.
5. EP-5 Confirm the edit using the CR "Merge-base substitution" rule: run `git merge-base HEAD origin/main` as its own command, then run `git diff --numstat <MERGE-BASE-SHA> -- <path>` with the printed 40-character SHA as a literal operand, and observe the line `2	0	<path>` (two insertions, zero deletions). For an `ALREADY-PRESENT` suite, record the observed numstat output instead.

## Command Reference (CR)

Every CR body is run from the worktree root. Primary invocation: through the PowerShell tool as `pwsh -NoProfile -Command { <body>; exit $code }`, which runs in a fresh process. Fallback, only when the agent-worktree isolation guard denies text containing `pwsh`: run `& { <body> }` directly in the PowerShell tool and take `EXIT_CODE` from the printed `EXIT_CODE_COMPUTED:` line. The artifact `Command:` field records which form ran and the list name substituted for `<LIST>`.

Route C, used when the executor has no PowerShell tool and whenever the Bash isolation guard refuses text containing `pwsh`: write the CR body (with `<LIST>` or `<ROWS>` substituted, ending in `exit $code`) to a `.ps1` file in the session scratchpad directory; write a scratchpad `.sh` file whose one command line runs `pwsh -NoProfile -File` on that `.ps1`; run `sh <that .sh>` through the Bash tool from the worktree root. `EXIT_CODE` is the process exit code, cross-checked against the printed `EXIT_CODE_COMPUTED:` line; if the two disagree, record both and stop with BLOCKED. Route C also carries the non-CR PowerShell commands in P0-T4, P0-T5, and P5-T8; for those the `.ps1` ends in `exit 0` and `EXIT_CODE` is the process exit code. Scratchpad script files are executor-side, outside the repository, and are not test files; the Hermeticity Constraints do not apply to them. CR-PESTER-FULL always runs through Route C; the `.sh` redirects combined output to a scratchpad log and writes the process exit code to a scratchpad file, the Bash call uses `run_in_background`, and the executor reads the log and exit-code file after the completion notification.

Merge-base substitution: the Bash isolation guard refuses a `$(git merge-base HEAD origin/main)` substitution. Wherever this plan needs the merge-base as a `git diff` operand (EP-5, P5-T1, P5-T6, P5-T9, P5-T10), run `git merge-base HEAD origin/main` as its own command in the same task, then run the diff with the printed 40-character SHA as a literal operand, written below as `<MERGE-BASE-SHA>`. Record both commands in the artifact `Command:` field.

Route note for counts: every count, finding, and percentage asserted by this plan is read from the direct CR commands. The `run_poshqc_*` MCP tools return a summary composed before the child process runs and read installed-extension settings, so they carry no per-test output (spec.md "Test Strategy"). `mcp__drm-copilot__run_poshqc_analyze` with `scan_folders` `["tests/scripts/claude-hooks"]` may run as a supplementary route-compliance step; record only its call disposition, never a count from it. `mcp__drm-copilot__run_poshqc_test` must not run between CR-PESTER-FULL and CR-COV, because it overwrites `artifacts/pester/powershell-coverage.xml`.

Success-output observation rule: the first run of each CR (in Phase 0) is the observation run. Before any later task asserts over a CR's output, that Phase 0 artifact must show the success-case literal named in the task. If a named literal is absent from a successful run, record the observed output and stop with BLOCKED; do not substitute a different literal.

### File lists

- LIST-SEVEN: S1, S2, S3, S4, S5, S6, S7 (paths from the Scope Summary table).
- LIST-EPICSCOPE: `tests/scripts/claude-hooks/enforce-pr-author-skill.EpicScope.Tests.ps1`, `tests/scripts/claude-hooks/enforce-model-routing-receipt.EpicScope.Tests.ps1`, `tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.EpicScope.Tests.ps1`.
- LIST-BASE: LIST-SEVEN followed by LIST-EPICSCOPE (10 files).
- LIST-NEW: N1.
- LIST-CHANGED: LIST-SEVEN followed by N1 (8 files).
- LIST-FINAL: LIST-BASE followed by N1 (11 files).
- LIST-B2: S4, S5, S6. LIST-B3: S7, S2, S3. LIST-B4: S1.

### CR-PESTER-LIST (direct Pester over an explicit file list)

```powershell
$Paths = @( <LIST> )
Import-Module Pester -MinimumVersion 5.0.0 -ErrorAction Stop
$configuration = New-PesterConfiguration
$configuration.Run.Path = $Paths
$configuration.Run.PassThru = $true
$configuration.Output.Verbosity = 'Normal'
$result = Invoke-Pester -Configuration $configuration
foreach ($container in $result.Containers) { "CONTAINER: $([System.IO.Path]::GetFileName([string]$container.Item)) | Result=$($container.Result)" }
foreach ($group in ($result.Tests | Group-Object { [System.IO.Path]::GetFileName($_.ScriptBlock.File) } | Sort-Object Name)) {
    $passed = @($group.Group | Where-Object Result -EQ 'Passed').Count
    $failed = @($group.Group | Where-Object Result -EQ 'Failed').Count
    $skipped = @($group.Group | Where-Object Result -EQ 'Skipped').Count
    $notRun = @($group.Group | Where-Object Result -EQ 'NotRun').Count
    "SUITE: $($group.Name) | Passed=$passed | Failed=$failed | Skipped=$skipped | NotRun=$notRun"
}
foreach ($test in $result.Failed) { "FAILED: $($test.ExpandedPath) :: $((($test.ErrorRecord | Select-Object -First 1).Exception.Message) -replace '\s+', ' ')" }
"TOTAL: Passed=$($result.PassedCount) | Failed=$($result.FailedCount) | Skipped=$($result.SkippedCount) | NotRun=$($result.NotRunCount) | FailedBlocks=$($result.FailedBlocksCount) | FailedContainers=$($result.FailedContainersCount)"
$code = if ($result.Result -eq 'Passed') { 0 } else { 1 }
"EXIT_CODE_COMPUTED: $code"
```

Success-case literals: one `SUITE:` line per file in the list, one `CONTAINER:` line per file with `Result=Passed`, a `TOTAL:` line with `Failed=0`, and `EXIT_CODE_COMPUTED: 0`.

### CR-FORMAT-CHECK (read-only; mirrors the comparison in `Invoke-PoshQCFormat`)

```powershell
$Paths = @( <LIST> )
Import-Module PSScriptAnalyzer -ErrorAction Stop
$settings = (Resolve-Path 'scripts/powershell/PoshQC/settings/pssa.settings.psd1').Path
$drift = 0
foreach ($path in $Paths) {
    $normalized = (Get-Content -Raw -LiteralPath $path) -replace "`r?`n", "`n"
    $formatted = Invoke-Formatter -ScriptDefinition $normalized -Settings $settings
    if ($formatted -ne $normalized) { $drift++; "FORMAT-DRIFT: $path" } else { "FORMAT-CLEAN: $path" }
}
"FORMAT-DRIFT-COUNT: $drift"
$code = [int]($drift -gt 0)
"EXIT_CODE_COMPUTED: $code"
```

Success-case literals: one `FORMAT-CLEAN:` line per file, `FORMAT-DRIFT-COUNT: 0`, `EXIT_CODE_COMPUTED: 0`. This check writes no file.

### CR-PSSA (PSScriptAnalyzer with repository settings, same severities as `Invoke-PoshQCAnalyze`)

```powershell
$Paths = @( <LIST> )
Import-Module PSScriptAnalyzer -ErrorAction Stop
$settings = (Resolve-Path 'scripts/powershell/PoshQC/settings/pssa.settings.psd1').Path
$total = 0
foreach ($path in $Paths) {
    $findings = @(Invoke-ScriptAnalyzer -Path $path -Settings $settings -Severity Error, Warning, Information)
    $total += $findings.Count
    "PSSA: $($path) | findings=$($findings.Count)"
    foreach ($finding in $findings) { "PSSA-FINDING: $($path):$($finding.Line) $($finding.RuleName) $($finding.Severity)" }
}
"PSSA-TOTAL: $total"
$code = [int]($total -gt 0)
"EXIT_CODE_COMPUTED: $code"
```

Success-case literals: one `PSSA:` line per file with `findings=0`, `PSSA-TOTAL: 0`, `EXIT_CODE_COMPUTED: 0`.

### CR-PESTER-FULL (full configured run, CI parity with `.github/workflows/_poshqc.yml`)

Route C body (the `.ps1` contents): `Import-Module ./scripts/powershell/PoshQC/PoshQC.psm1; Invoke-PoshQCTest; exit 0`

This uses `scripts/powershell/PoshQC/settings/pester.runsettings.psd1` (`Run.Path` includes `tests/scripts`; `Run.Exit = $true`; coverage written to `artifacts/pester/powershell-coverage.xml`). Because `Run.Exit = $true`, a failing run terminates the process inside `Invoke-Pester` with exit code `FailedCount + FailedBlocksCount + FailedContainersCount` (or `-1` if the run throws), after the coverage and JUnit files are written; the trailing `exit 0` is reached only on a zero-failure run. This CR prints no `EXIT_CODE_COMPUTED:` line; `EXIT_CODE` is the process exit code. Pester prints the single-line summary `Tests Passed: <n>, Failed: <n>, Skipped: <n>, Inconclusive: <n>, NotRun: <n>` on every run, and `Invoke-PoshQCTest` (`scripts/powershell/PoshQC/PoshQC.Testing.psm1`) replays the same line after a zero-failure run. Record the process exit code, the last such summary line, any `BeforeAll \ AfterAll failed:` or `Container failed:` line with the list below it, and every line that begins `[-]` (absolute prefixes replaced with `<repo>`).

### CR-COV (line coverage of `EpicScopeResolution.psm1` from the full run)

```powershell
[xml] $report = Get-Content -Raw -LiteralPath 'artifacts/pester/powershell-coverage.xml'
$nodes = @($report.SelectNodes('//sourcefile') | Where-Object { ([string]$_.name).Replace([string][char]92, '/') -like '*EpicScopeResolution.psm1' })
"SOURCEFILE-MATCHES: $($nodes.Count)"
foreach ($node in $nodes) {
    $line = $node.SelectSingleNode("counter[@type='LINE']")
    $covered = [int]$line.covered
    $missed = [int]$line.missed
    "EPIC-SCOPE-LINE-COVERAGE: covered=$covered | missed=$missed | percent=$([math]::Round(100 * $covered / ($covered + $missed), 2))"
}
$code = [int]($nodes.Count -ne 1)
"EXIT_CODE_COMPUTED: $code"
```

Success-case literals: `SOURCEFILE-MATCHES: 1` and one `EPIC-SCOPE-LINE-COVERAGE:` line with numeric values. The source-file name is matched by suffix because the CoverageGutters format may record either a bare file name or a path; the name itself is not printed, so no absolute path reaches an artifact.

### CR-ANCHOR (anchor and idempotence survey)

```powershell
$Rows = @( <ROWS> )   # one @{ Path = '<suite path>'; Anchor = '<anchor literal from the EP table>' } per suite in LIST-SEVEN
$mockLine = 'Mock Get-EpicScopeCheckpointText -ModuleName EpicScopeResolution { $null }'
$bad = 0
foreach ($row in $Rows) {
    $lines = Get-Content -LiteralPath $row.Path
    $anchor = @($lines | Where-Object { $_.Trim() -ceq $row.Anchor }).Count
    $mock = @($lines | Where-Object { $_.Trim() -ceq $mockLine }).Count
    $import = @($lines | Where-Object { $_ -match 'Import-Module' -and $_ -match 'EpicScopeResolution\.psm1' }).Count
    if ($anchor -ne 1) { $bad++ }
    "ANCHOR: $($row.Path) | anchor=$anchor | mock=$mock | import=$import | lines=$($lines.Count)"
}
$code = [int]($bad -gt 0)
"EXIT_CODE_COMPUTED: $code"
```

In `<ROWS>`, double every single quote inside an anchor literal (the S2 and S3 anchors contain single quotes).

Success-case literals: one `ANCHOR:` line per suite and `EXIT_CODE_COMPUTED: 0`. `mock=0` with `import=0` classifies the suite MOCK-ABSENT; `mock=1` with `import=1` classifies it MOCK-PRESENT; any other pair is unclassified.

## Batch Budget

The PowerShell per-batch cap is three test files (`.claude/hooks/enforce-powershell-batch-budget.ps1`). Batches: B1 = N1 (Phase 1); B2 = S4, S5, S6 (Phase 2); B3 = S7, S2, S3 (Phase 3); B4 = S1 (Phase 4). Whenever a write is denied by the budget hook, delete the state file the denial message names (under `.claude/state/`, gitignored), and retry the same write once. Record each reset (state-file name and time) in the artifact of the task that triggered it. Do not raise the cap.

### Phase 0 — Policy Reads and Baseline Capture

- [ ] [P0-T1] Read, in order, `CLAUDE.md`, `.github/copilot-instructions.md`, `.github/instructions/tonality.instructions.md`, `.github/instructions/general-code-change.instructions.md`, `.github/instructions/general-unit-test.instructions.md`, `.github/instructions/powershell-code-change.instructions.md`, `.github/instructions/powershell-unit-test.instructions.md`, `.claude/rules/general-code-change.md`, `.claude/rules/general-unit-test.md`, `.claude/rules/quality-tiers.md`, `.claude/rules/powershell.md`, and `.claude/rules/tonality.md`. Write `<FEATURE>/evidence/baseline/phase0-instructions-read.md` containing `Timestamp:`, `Policy Order:`, and the twelve repository-relative paths in the order read. Done when the artifact exists with all three fields and twelve paths.
- [ ] [P0-T2] Read `<FEATURE>/issue.md`, `<FEATURE>/spec.md`, and `<FEATURE>/research/research.2026-09-26T23-00.md`. Write `<FEATURE>/evidence/baseline/phase0-requirements-read.<ts>.md` with `Timestamp:`, `Work Mode: full-bug`, the AC inventory `AC1` through `AC9` (spec.md "Acceptance Criteria" bullets in document order), the decisions `D1` through `D10`, and the evidence override line from the "Evidence Location" section of this plan. Done when the artifact lists nine AC IDs and ten decision IDs.
- [ ] [P0-T3] Branch freshness and base record. Run this task before any checkbox in this plan is marked (mark P0-T1 and P0-T2 after P0-T3 completes), so that no tracked file is modified when a rebase runs. Run `git status --porcelain --untracked-files=no` (it must print nothing; otherwise stop with BLOCKED), then `git fetch origin main`, then `git rev-list --count HEAD..origin/main`. If the count is not `0`, run `git rebase origin/main` before any file under `tests/` is written; at this point the branch carries only `docs/features/active/` commits for this feature, so no conflict is expected. If the rebase reports a conflict, run `git rebase --abort` and stop with BLOCKED. Then run `git rev-list --count HEAD..origin/main` again, `git rev-parse --abbrev-ref HEAD`, `git rev-parse HEAD`, and `git merge-base HEAD origin/main`. The executor does not push; pushing is the orchestrator's responsibility. Write `<FEATURE>/evidence/baseline/git-base.<ts>.md` with `Timestamp:`, `Command:` (every command run), `EXIT_CODE:`, and `Output Summary:` carrying the before and after counts, the rebase outcome (`NOT-NEEDED`, `REBASED`, or `CONFLICT-ABORTED`), the branch name `bug/gate-suites-read-unmocked-local-epic-state-709`, the HEAD SHA, and the merge-base SHA. Done when the after count is `0`, the recorded branch name matches, and both SHAs are 40 hex characters.
- [ ] [P0-T4] Hermeticity precondition: run `Test-Path -LiteralPath 'artifacts/orchestration/epic-orchestrator-state.json'` from the worktree root and write `<FEATURE>/evidence/baseline/epic-state-presence.<ts>.md` (`Timestamp:`, `Command:`, `EXIT_CODE:`, `Output Summary:` with `EPIC-STATE-PRESENT: True` or `EPIC-STATE-PRESENT: False`). Done when the value is `False`. If `True`, do not delete or edit the file; stop with BLOCKED, because baseline counts would not reflect the CI condition that AC5 compares against.
- [ ] [P0-T5] Record toolchain versions: run `Get-Module -ListAvailable Pester, PSScriptAnalyzer | Sort-Object Name, Version -Descending | Select-Object Name, Version` and `$PSVersionTable.PSVersion`. Write `<FEATURE>/evidence/baseline/toolchain-versions.<ts>.md` with the four schema fields. Done when the highest Pester version is 5.x and PowerShell is 7.x; otherwise stop with BLOCKED.
- [ ] [P0-T6] Verify that a module-scoped `Mock` declared in a file-level (root) `BeforeAll` applies inside nested `Describe`/`Context` blocks, which S2 and S3 rely on (D2). Run, via the CR invocation rules (primary, fallback, or Route C), the in-memory probe below (no file is created), and write `<FEATURE>/evidence/baseline/pester-root-beforeall-mock-probe.<ts>.md` with the four schema fields. Done when the output contains `PROBE: Passed=1 | Failed=0`. If it does not, stop with BLOCKED: the D2 placement for S2 and S3 would be ineffective and the spec requires revision.

```powershell
Import-Module Pester -MinimumVersion 5.0.0 -ErrorAction Stop
$probe = {
    BeforeAll {
        New-Module -Name Probe709 -ScriptBlock {
            function Get-Probe709Seam { 'real' }
            function Get-Probe709Value { Get-Probe709Seam }
            Export-ModuleMember -Function Get-Probe709Seam, Get-Probe709Value
        } | Import-Module
        Mock Get-Probe709Seam -ModuleName Probe709 { 'mocked' }
    }
    Describe 'probe' { Context 'nested' { It 'sees the root-level module-scoped mock' { Get-Probe709Value | Should -Be 'mocked' } } }
}
$configuration = New-PesterConfiguration
$configuration.Run.Container = New-PesterContainer -ScriptBlock $probe
$configuration.Run.PassThru = $true
$result = Invoke-Pester -Configuration $configuration
"PROBE: Passed=$($result.PassedCount) | Failed=$($result.FailedCount)"
$code = [int]($result.Result -ne 'Passed')
"EXIT_CODE_COMPUTED: $code"
```

- [ ] [P0-T7] Run CR-ANCHOR over the seven rows of the EP table (S1-S7 paths with their anchor literals) and write `<FEATURE>/evidence/baseline/suite-anchors.<ts>.md` with the four schema fields and a per-suite classification `MOCK-ABSENT` or `MOCK-PRESENT`. Done when every `ANCHOR:` line shows `anchor=1` and `lines` at most 498. Define `ABSENT-COUNT` as the number of `MOCK-ABSENT` suites; later tasks use it. If any `anchor` value is not 1, stop with BLOCKED. A suite whose `mock` and `import` values are neither `0` and `0` nor `1` and `1` is unclassified; stop with BLOCKED.
- [ ] [P0-T8] Baseline format check: run CR-FORMAT-CHECK with `<LIST>` = LIST-SEVEN and write `<FEATURE>/evidence/baseline/format-check-baseline.<ts>.md` with the four schema fields. Done when the output shows seven `FORMAT-CLEAN:` lines and `FORMAT-DRIFT-COUNT: 0`. If any suite shows `FORMAT-DRIFT:`, stop with BLOCKED: formatting that suite later would change untouched lines, which D6 prohibits.
- [ ] [P0-T9] Baseline analyzer: run CR-PSSA with `<LIST>` = LIST-SEVEN and write `<FEATURE>/evidence/baseline/pssa-baseline.<ts>.md` with the four schema fields and every `PSSA-FINDING:` line. Done when the artifact records `PSSA-TOTAL:` with a numeric value (zero expected; any pre-existing finding is recorded, not fixed). If `PSSA-TOTAL` is not 0, stop with BLOCKED: fixing a finding in a suite would change untouched lines, which D6 prohibits, and P5-T3 requires zero.
- [ ] [P0-T10] Baseline targeted Pester: run CR-PESTER-LIST with `<LIST>` = LIST-BASE and write `<FEATURE>/evidence/baseline/pester-targeted-baseline.<ts>.md` with the four schema fields and all ten `SUITE:` lines verbatim in `Output Summary:`. Done when there are ten `SUITE:` lines, ten `CONTAINER:` lines with `Result=Passed`, and `EXIT_CODE: 0`. If any test fails, record the `FAILED:` lines and stop with BLOCKED (pre-existing failure outside #709 scope).
- [ ] [P0-T11] Baseline full configured Pester run: run CR-PESTER-FULL and write `<FEATURE>/evidence/baseline/pester-full-baseline.<ts>.md` with the four schema fields; `Output Summary:` carries the run summary named in CR-PESTER-FULL (the `Tests Passed:` line, plus any `BeforeAll \ AfterAll failed:` or `Container failed:` lines) and every `[-]` line. Done when the artifact contains that summary and the exit code. Pre-existing failures are recorded, not fixed.
- [ ] [P0-T12] Baseline coverage: immediately after P0-T11, run CR-COV and write `<FEATURE>/evidence/baseline/coverage-epic-scope-baseline.<ts>.md` with the four schema fields; `Output Summary:` carries the `SOURCEFILE-MATCHES:` and `EPIC-SCOPE-LINE-COVERAGE:` lines. Done when the output shows `SOURCEFILE-MATCHES: 1` and a numeric `percent=` value. If the match count is not 1, record the element names of the first three XML levels and stop with BLOCKED, because AC9 cannot be measured.

### Phase 1 — Regression File and Fail-Before Evidence (Batch B1)

Phase preamble: N1 is written before any suite edit so that the structural guard records the unprotected state. N1 loads no hook, is 500 lines or fewer, and follows the Hermeticity Constraints. Required `It` count after P1-T3: 7 path rows + 9 predicate rows + 4 control rows + 4 treatment rows = 24.

- [ ] [P1-T1] Create `tests/scripts/claude-hooks/enforce-gate-suites.EpicStateIsolation.Tests.ps1` containing: the `#Requires -Version 7.0` and Pester 5 `#Requires` lines; a comment-based header stating the purpose (issue #709), that the explicit seven-path list does not guard future reaching suites (D9), and that the file creates no file and reads no gitignored state; a file-level `BeforeAll` that sets `$script:RepoRoot = (Resolve-Path "$PSScriptRoot/../../..").Path` and defines `Get-EpicStateIsolationFinding` (input: a `ScriptBlockAst`; output: an array of finding strings, empty when compliant) and `Get-EpicStateIsolationSuiteFinding` (input: a repository-relative path; returns a `suite file not found` finding naming the path when absent, a parse-error finding when `[System.Management.Automation.Language.Parser]::ParseFile` reports errors, otherwise the result of `Get-EpicStateIsolationFinding` with each finding prefixed by the path); and `Describe 'gate suites isolate the epic checkpoint read (structural guard)'` with one `It '<Path> isolates the epic checkpoint read in its outermost BeforeAll' -ForEach` over seven hashtable rows `@{ Path = '<literal S1-S7 path>' }` (no glob), asserting `@($findings).Count | Should -Be 0 -Because ($findings -join '; ')`. Done when the file exists, parses without errors, and contains the seven literal paths.

`Get-EpicStateIsolationFinding` rules (the finding strings are fixed as quoted):

1. The outermost `BeforeAll` is the `BeforeAll` `CommandAst` with the fewest `CommandAst` ancestors (file-level when present, else the first-level `Describe` one; ties resolved by earliest offset); none gives "no outermost BeforeAll".
2. Within it, a qualifying Mock is a `CommandAst` named `Mock` whose target is `Get-EpicScopeCheckpointText`, given positionally or through `-CommandName`; none gives "Mock of Get-EpicScopeCheckpointText missing from outermost BeforeAll".
3. The qualifying Mock must carry `-ModuleName EpicScopeResolution`, else "Mock lacks -ModuleName EpicScopeResolution"; its script-block argument (positional or `-MockWith`) must contain exactly one statement whose trimmed text is `$null`, else "Mock body is not exactly $null".
4. Within the same block an `Import-Module` `CommandAst` whose argument text contains `EpicScopeResolution.psm1` must exist, else "Import-Module of EpicScopeResolution.psm1 missing from outermost BeforeAll"; it must carry no `-Force` parameter, else "Import-Module of EpicScopeResolution.psm1 uses -Force".
5. The first dot-sourced command (`InvocationOperator` `Dot`) in the block must start before the import, and the import must start before the Mock, else "hook dot-source, Import-Module, Mock order violated".

- [ ] [P1-T2] Add to `tests/scripts/claude-hooks/enforce-gate-suites.EpicStateIsolation.Tests.ps1`, inside the structural-guard `Describe`, `Context 'guard predicate discrimination'` with nine `It` rows that build ASTs in memory with `[System.Management.Automation.Language.Parser]::ParseInput` over single-quoted here-string fixtures (no file). Rows: (1) compliant positional form, zero findings; (2) compliant `-CommandName`/`-MockWith` form, zero findings; (3) Mock targets `Get-EpicScopeWorktreeHeadBranch`, finding contains "missing from outermost BeforeAll"; (4) Mock without `-ModuleName`, finding contains "lacks -ModuleName"; (5) Mock body `{ '' }`, finding contains "not exactly"; (6) a `Describe`-level `BeforeAll` holding the dot-source and the import, and the Mock only in a nested `Context` `BeforeAll`, finding contains "missing from outermost BeforeAll"; (7) import with `-Force`, finding contains "uses -Force"; (8) import and Mock placed before the dot-source, finding contains "order violated"; (9) `Get-EpicStateIsolationSuiteFinding` on `/synthetic-worktrees/missing/enforce-missing.Tests.ps1`, finding contains "suite file not found" and the path. Done when the file contains the nine rows and still parses without errors.
- [ ] [P1-T3] Add to `tests/scripts/claude-hooks/enforce-gate-suites.EpicStateIsolation.Tests.ps1` `Describe 'the Get-EpicScopeCheckpointText mock blocks the epic-state read (seam sufficiency)'` whose `BeforeAll` imports `.claude/lib/worktree-resolution/EpicScopeResolution.psm1` from `$script:RepoRoot` with `-Force`, defines an in-memory hostile ready epic JSON with `"route_id":"epic"` and `"integration_branch":"epic/hostile-integration"`, and defines a helper that registers, in `-ModuleName EpicScopeResolution` scope, mocks of `Find-WorktreeResolutionRoot` (returns `$Path` when it is like `/synthetic-worktrees/*`, else `/synthetic-worktrees/local-checkout`), `Get-WorktreeResolutionGitEntryKind` (`'File'`), `Get-WorktreeResolutionGitFileText` (the hostile JSON, captured with `.GetNewClosure()`), `Get-EpicScopeWorktreeHeadBranch` (`'epic/hostile-integration'`), and `Test-EpicScopeMergeInProgress` (`$false`). Four shapes via `-ForEach`: gate 1 `gh pr create --head epic/hostile-integration --body-file artifacts/pr_body_1.md`; gate 3 a prompt ending with a `branch: epic/hostile-integration` line; gate 4 `git add scripts/powershell/Sample.ps1` with `-MatchWorktreeHead`; gate 4 selector `git -C /synthetic-worktrees/selected-item add scripts/powershell/Sample.ps1` with `-MatchWorktreeHead` and `-WorktreeSelector /synthetic-worktrees/selected-item`. Every call passes `-SessionRoot /synthetic-worktrees/local-checkout`. Control `It` per shape (helper only): `IsEpicScope` is `$true` and `Get-WorktreeResolutionGitFileText` is invoked exactly once with a `-ParameterFilter` of `$Path -like '*epic-orchestrator-state.json'`. Treatment `It` per shape (helper plus `Mock Get-EpicScopeCheckpointText -ModuleName EpicScopeResolution { $null }`): `IsEpicScope` is `$false`, `Reason` is `epic-checkpoint-absent-or-unparseable`, `Get-EpicScopeCheckpointText` invoked exactly once, and `Get-WorktreeResolutionGitFileText` (same filter), `Get-EpicScopeWorktreeHeadBranch`, and `Test-EpicScopeMergeInProgress` each invoked `-Times 0 -Exactly`. Done when the file parses, contains 24 `It` expansions in total, and is 500 lines or fewer.
- [ ] [P1-T4] [expect-fail] Fail-before run: run CR-PESTER-LIST with `<LIST>` = LIST-NEW before any suite edit and write `<FEATURE>/evidence/regression-testing/fail-before.<ts>.md` with `Timestamp:`, `Command:`, `EXIT_CODE:`, `ExpectedExitCode: 1`, and `Output Summary:` carrying the `TOTAL:` line and every `FAILED:` line. Done when `Failed` equals `ABSENT-COUNT` from P0-T7, each `FAILED:` line is a structural-guard path row naming one MOCK-ABSENT suite path and carrying the "missing from outermost BeforeAll" text, `Passed` equals 24 minus `ABSENT-COUNT`, and no predicate, control, or treatment row fails. If `ABSENT-COUNT` is 0 (every suite already protected by a sibling), write `<FEATURE>/evidence/regression-testing/fail-before-exception.<ts>.md` with `WhyFailingRunImpossible:` and the P0-T7 `ANCHOR:` lines as alternative proof instead.

### Phase 2 — Gate-4 Suite Isolation (Batch B2)

- [ ] [P2-T1] Apply the Edit Protocol to S4 `tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.Tests.ps1` (anchor `. $script:UnderTest`, FORM-R, 8 spaces). Done when EP-5 shows `2	0	tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.Tests.ps1`, or EP-3 recorded `ALREADY-PRESENT`.
- [ ] [P2-T2] Apply the Edit Protocol to S5 `tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.TriggerScoping.Tests.ps1` (anchor `. $script:UnderTest`, FORM-R, 8 spaces). Done when EP-5 shows `2	0	tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.TriggerScoping.Tests.ps1`, or EP-3 recorded `ALREADY-PRESENT`.
- [ ] [P2-T3] Apply the Edit Protocol to S6 `tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.CommandExemption.Tests.ps1` (anchor `. $script:UnderTest`, FORM-R, 8 spaces). Done when EP-5 shows `2	0	tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.CommandExemption.Tests.ps1`, or EP-3 recorded `ALREADY-PRESENT`, and the file is 500 lines or fewer.
- [ ] [P2-T4] Batch B2 verification: run CR-PESTER-LIST with `<LIST>` = LIST-B2 and write `<FEATURE>/evidence/regression-testing/batch-b2-suites.<ts>.md` with the four schema fields, the three `SUITE:` lines, and the three EP-5 numstat lines. Done when `EXIT_CODE: 0` and each `SUITE:` line equals, field for field, the same suite's line in the P0-T10 artifact.

### Phase 3 — Gate-4 Absolute-Path and Worktree-Resolution Suite Isolation (Batch B3)

- [ ] [P3-T1] Apply the Edit Protocol to S7 `tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-absolute-paths.Tests.ps1` (anchor `. $script:UnderTest`, FORM-R, 8 spaces). Done when EP-5 shows `2	0	tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-absolute-paths.Tests.ps1`, or EP-3 recorded `ALREADY-PRESENT`.
- [ ] [P3-T2] Apply the Edit Protocol to S2 `tests/scripts/claude-hooks/enforce-pr-author-skill.WorktreeResolution.Tests.ps1` (file-level `BeforeAll`, anchor is the `WorktreeTargetResolution.psm1` import line, FORM-H, 4 spaces; the inserted lines land before the `WorktreeResolutionFixture.Helpers.ps1` dot-source). Done when EP-5 shows `2	0	tests/scripts/claude-hooks/enforce-pr-author-skill.WorktreeResolution.Tests.ps1`, or EP-3 recorded `ALREADY-PRESENT`.
- [ ] [P3-T3] Apply the Edit Protocol to S3 `tests/scripts/claude-hooks/enforce-model-routing-receipt.WorktreeResolution.Tests.ps1` (file-level `BeforeAll`, anchor is the `WorktreeTargetResolution.psm1` import line, FORM-H, 4 spaces). Done when EP-5 shows `2	0	tests/scripts/claude-hooks/enforce-model-routing-receipt.WorktreeResolution.Tests.ps1`, or EP-3 recorded `ALREADY-PRESENT`.
- [ ] [P3-T4] Batch B3 verification: run CR-PESTER-LIST with `<LIST>` = LIST-B3 and write `<FEATURE>/evidence/regression-testing/batch-b3-suites.<ts>.md` with the four schema fields, the three `SUITE:` lines, and the three EP-5 numstat lines. Done when `EXIT_CODE: 0` and each `SUITE:` line equals the same suite's line in the P0-T10 artifact.

### Phase 4 — Gate-1 Target-Resolution Suite Isolation and Pass-After Evidence (Batch B4)

- [ ] [P4-T1] Apply the Edit Protocol to S1 `tests/scripts/claude-hooks/enforce-pr-author-skill.TargetResolution.Tests.ps1` (anchor `. $script:UnderTest` inside the `Describe`-level `BeforeAll`, FORM-R, 8 spaces). Done when EP-5 shows `2	0	tests/scripts/claude-hooks/enforce-pr-author-skill.TargetResolution.Tests.ps1`, or EP-3 recorded `ALREADY-PRESENT`.
- [ ] [P4-T2] Batch B4 verification: run CR-PESTER-LIST with `<LIST>` = LIST-B4 and write `<FEATURE>/evidence/regression-testing/batch-b4-suites.<ts>.md` with the four schema fields, the `SUITE:` line, and the EP-5 numstat line. Done when `EXIT_CODE: 0` and the `SUITE:` line equals the S1 line in the P0-T10 artifact.
- [ ] [P4-T3] Pass-after run: run CR-PESTER-LIST with `<LIST>` = LIST-NEW and write `<FEATURE>/evidence/regression-testing/pass-after.<ts>.md` with the four schema fields and the `TOTAL:` line. Done when the output shows `TOTAL: Passed=24 | Failed=0` followed by `| Skipped=0 | NotRun=0`, and `EXIT_CODE: 0`.
- [ ] [P4-T4] Unchanged-behavior run: run CR-PESTER-LIST with `<LIST>` = LIST-BASE and write `<FEATURE>/evidence/regression-testing/pester-targeted-after.<ts>.md` with the four schema fields, all ten `SUITE:` lines, and a comparison table (suite, baseline line from P0-T10, after line, `EQUAL` or `DIFFERENT`). Done when `EXIT_CODE: 0` and all ten rows are `EQUAL`.
- [ ] [P4-T5] Write `<FEATURE>/evidence/other/follow-ups.md` with `Timestamp:` and two entries: D8 (verify and, if needed, isolate the relative-path epic-checkpoint reads in the suites for `.claude/hooks/enforce-epic-merge-gate.ps1`, `.claude/hooks/enforce-epic-worktree-removal-gate.ps1`, `.claude/hooks/enforce-epic-wave-barrier.ps1`, and `.claude/hooks/enforce-parallel-worktree-removal-gate.ps1`) and D9 (the explicit seven-path list in `tests/scripts/claude-hooks/enforce-gate-suites.EpicStateIsolation.Tests.ps1` does not guard a future reaching suite). Done when the artifact contains both entries.

### Phase 5 — Final QA Loop, Scope Verification, and Acceptance Check-off

Loop rule: P5-T2 through P5-T6 form the PowerShell QA loop (format, analyze, test; PowerShell has no type-check stage). If any of them fails or any file changes during them, fix the cause, then restart at P5-T2; the one exception is the pre-existing-failure branch stated in P5-T5. A task in this loop is checked only from the pass in which all five succeeded without a file change.

Check-off rule (P5-T11 through P5-T18 and P5-T20): `ACn` is the nth bullet of the `spec.md` "Acceptance Criteria" section (the P0-T2 inventory). A check-off task changes only that bullet's `- [ ]` to `- [x]` in `spec.md`; no other character of `spec.md` changes. The cited artifact paths are recorded in `<FEATURE>/evidence/qa-gates/ac-checkoff.<ts>.md`, created by the first check-off task that runs and extended by each later check-off task, under a section headed with the AC ID that carries its own `Timestamp:` line.

- [ ] [P5-T1] Freshness check: run `git fetch origin main`, `git rev-list --count HEAD..origin/main`, and `git status --porcelain --untracked-files=all`, and write `<FEATURE>/evidence/qa-gates/freshness.<ts>.md` with the four schema fields. Done when the count is `0`. If it is not `0`, stop and hand back to the orchestrator for a rebase. After the orchestrator reports the rebase complete, apply this in-place procedure; it creates and removes no git worktree. (a) Run `git merge-base HEAD origin/main` for the new merge-base SHA. (b) Re-run CR-ANCHOR over LIST-SEVEN into the same artifact; each suite must show `mock=1` and `import=1`; otherwise stop with BLOCKED. (c) Run `git diff --name-only <old MERGE-BASE-SHA> <new MERGE-BASE-SHA>`, with the old SHA taken from the P0-T3 artifact, and record `git status --porcelain` alongside; every LIST-BASE path it lists is rebase-touched. (d) For each rebase-touched LIST-SEVEN suite not recorded `ALREADY-PRESENT`, in groups of at most three under the Batch Budget, remove the two inserted lines with the Edit tool and confirm `git diff --numstat <new MERGE-BASE-SHA> -- <path>` prints nothing. (e) Run CR-PESTER-LIST over the rebase-touched LIST-BASE suites (touched LIST-EPICSCOPE suites run unchanged) and write `<FEATURE>/evidence/remediation-baseline/pester-targeted-rebased.<ts>.md` with the four schema fields and their `SUITE:` lines. (f) Re-apply EP-4 to each suite edited in (d) and confirm EP-5 shows `2	0	<path>` against the new merge-base SHA. (g) Run `git fetch origin main` and `git rev-list --count HEAD..origin/main` again and record the output in the same artifact; the Done condition applies to this count. P5-T4 then compares the rebase-touched suites against the remediation artifact instead of P0-T10.
- [ ] [P5-T2] QA loop step 1, format: run CR-FORMAT-CHECK with `<LIST>` = LIST-CHANGED and write `<FEATURE>/evidence/qa-gates/format-check.<ts>.md` with the four schema fields. Done when the output shows eight `FORMAT-CLEAN:` lines, `FORMAT-DRIFT-COUNT: 0`, and `EXIT_CODE: 0`. On drift, write the formatter output for that one file only (same normalization as `Invoke-PoshQCFormat`), confirm with EP-5 that S1-S7 still show `2	0`, and restart the loop.
- [ ] [P5-T3] QA loop step 2, analyze: run CR-PSSA with `<LIST>` = LIST-CHANGED and write `<FEATURE>/evidence/qa-gates/pssa.<ts>.md` with the four schema fields. Done when the output shows eight `PSSA:` lines with `findings=0`, `PSSA-TOTAL: 0`, and `EXIT_CODE: 0`.
- [ ] [P5-T4] QA loop step 3, targeted tests: run CR-PESTER-LIST with `<LIST>` = LIST-FINAL and write `<FEATURE>/evidence/qa-gates/pester-targeted.<ts>.md` with the four schema fields and all eleven `SUITE:` lines. Done when `EXIT_CODE: 0`, the N1 line shows `Passed=24 | Failed=0`, and the other ten `SUITE:` lines equal their baseline lines (P0-T10, or the P5-T1 remediation baseline for rebase-touched suites).
- [ ] [P5-T5] QA loop step 4, full configured run: run CR-PESTER-FULL and write `<FEATURE>/evidence/qa-gates/pester-full.<ts>.md` with the four schema fields, the run summary named in CR-PESTER-FULL, and every `[-]` line. Done when the exit code is 0 and the last `Tests Passed:` line shows `Failed: 0`. If failures remain that are also listed in the P0-T11 artifact, record them as pre-existing, leave AC8 unchecked, and escalate; do not fix them under #709. In that case do not restart the loop: run P5-T6 once, leave P5-T5, P5-T7, and P5-T17 unchecked, continue at P5-T8, and report the escalation (failing test names from both artifacts) at plan completion. Any failure not listed in the P0-T11 artifact follows the loop rule.
- [ ] [P5-T6] QA loop step 5, coverage comparison: immediately after P5-T5, run CR-COV and write `<FEATURE>/evidence/qa-gates/coverage-epic-scope.<ts>.md` with the four schema fields and a comparison block: baseline percent (P0-T12), post-change percent, delta, the 85% line threshold, and the changed-production-code figure. Derive that figure in this task by running `git merge-base HEAD origin/main`, then `git diff --numstat <MERGE-BASE-SHA> -- .claude extensions scripts` with the printed SHA as a literal operand, and `git status --porcelain --untracked-files=all -- .claude extensions scripts`; when both print nothing, record `Changed production lines: 0` and `New/changed-code coverage: not applicable (no production line changed)`. Done when the diff and status commands both print nothing and `SOURCEFILE-MATCHES: 1` and the post-change percent is greater than or equal to the baseline percent for `.claude/lib/worktree-resolution/EpicScopeResolution.psm1`. Branch coverage is not measured for PowerShell and is not recorded.
- [ ] [P5-T7] Record the QA loop result in `<FEATURE>/evidence/qa-gates/qa-loop.<ts>.md`: `Timestamp:`, the number of loop passes, and the five artifact paths from the final clean pass of P5-T2 through P5-T6. Done when the artifact names one pass in which all five steps succeeded without a file change.
- [ ] [P5-T8] Hermeticity scan of `tests/scripts/claude-hooks/enforce-gate-suites.EpicStateIsolation.Tests.ps1`: run, through the CR invocation rules (Route C when the executor has no PowerShell tool), `"HERMETICITY-MATCH-COUNT: $(@(Select-String -LiteralPath 'tests/scripts/claude-hooks/enforce-gate-suites.EpicStateIsolation.Tests.ps1' -Pattern 'New-TemporaryFile', 'TestDrive', 'env:TEMP', 'GetTempPath', 'GetTempFileName', 'origin/main', 'Set-Content', 'Out-File', 'New-Item', '[A-Za-z]:[\\/]').Count)"` and write `<FEATURE>/evidence/qa-gates/hermeticity-scan.<ts>.md` with the four schema fields and the printed count line. Done when the output shows `HERMETICITY-MATCH-COUNT: 0`. The searched tokens are "New-TemporaryFile", "TestDrive", "env:TEMP", "GetTempPath", "GetTempFileName", "origin/main", "Set-Content", "Out-File", "New-Item", and a drive-letter path pattern; a match is fixed in N1 and the QA loop restarts at P5-T2.
- [ ] [P5-T9] Scope verification: run `git merge-base HEAD origin/main`, then `git diff --name-only <MERGE-BASE-SHA>` with the printed SHA as a literal operand, and `git status --porcelain --untracked-files=all`, and write `<FEATURE>/evidence/qa-gates/scope-diff.<ts>.md` with the four schema fields and the union of listed paths. Done when every listed path is one of the eight LIST-CHANGED paths or begins with `docs/features/active/gate-suites-read-unmocked-local-epic-state-709/`, and no listed path is one of the three LIST-EPICSCOPE paths or begins with `.claude/`, `extensions/`, or `scripts/`.
- [ ] [P5-T10] Insertion-shape verification: run `git merge-base HEAD origin/main`, then, with the printed SHA as a literal operand, `git diff --numstat <MERGE-BASE-SHA> -- tests/scripts/claude-hooks/enforce-pr-author-skill.TargetResolution.Tests.ps1 tests/scripts/claude-hooks/enforce-pr-author-skill.WorktreeResolution.Tests.ps1 tests/scripts/claude-hooks/enforce-model-routing-receipt.WorktreeResolution.Tests.ps1 tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.Tests.ps1 tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.TriggerScoping.Tests.ps1 tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.CommandExemption.Tests.ps1 tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-absolute-paths.Tests.ps1` together with `git status --porcelain --untracked-files=all` and write `<FEATURE>/evidence/qa-gates/suite-diff-numstat.<ts>.md` with the four schema fields and the numstat lines. Done when every suite not classified `ALREADY-PRESENT` shows `2` insertions and `0` deletions, and each of the eight LIST-CHANGED files is 500 lines or fewer (line counts recorded in the same artifact).
- [ ] [P5-T11] Check off AC1 in `<FEATURE>/spec.md` when the P5-T4 artifact shows the N1 structural-guard rows passing and the P5-T10 artifact confirms the insertion shape for S1-S7. Record both artifact paths in `<FEATURE>/evidence/qa-gates/ac-checkoff.<ts>.md` under `AC1`, with `Timestamp:`; only the AC1 checkbox changes in `spec.md`. Done when the AC1 box is checked and the `AC1` section of the check-off artifact names both paths.
- [ ] [P5-T12] Check off AC2 in `<FEATURE>/spec.md` when `tests/scripts/claude-hooks/enforce-gate-suites.EpicStateIsolation.Tests.ps1` exists and the P1-T4 fail-before artifact (or the fail-before exception dossier) under `<FEATURE>/evidence/regression-testing/` exists. Record the artifact path in `<FEATURE>/evidence/qa-gates/ac-checkoff.<ts>.md` under `AC2`, with `Timestamp:`; only the AC2 checkbox changes in `spec.md`. Done when the AC2 box is checked and the `AC2` section names the path.
- [ ] [P5-T13] Check off AC3 in `<FEATURE>/spec.md` when the P4-T3 pass-after artifact and the P1-T4 fail-before artifact both show zero failed control or treatment rows of the seam-sufficiency `Describe` in `tests/scripts/claude-hooks/enforce-gate-suites.EpicStateIsolation.Tests.ps1`. Record both artifact paths in `<FEATURE>/evidence/qa-gates/ac-checkoff.<ts>.md` under `AC3`, with `Timestamp:`; only the AC3 checkbox changes in `spec.md`. Done when the AC3 box is checked and the `AC3` section names both paths.
- [ ] [P5-T14] Check off AC5 in `<FEATURE>/spec.md` when the P4-T4 comparison in `<FEATURE>/evidence/regression-testing/pester-targeted-after.<ts>.md` shows `EQUAL` for S1-S7 against `<FEATURE>/evidence/baseline/pester-targeted-baseline.<ts>.md`. Record both artifact paths in `<FEATURE>/evidence/qa-gates/ac-checkoff.<ts>.md` under `AC5`, with `Timestamp:` and the statement that the baseline was written to `evidence/baseline/` instead of the non-canonical `evidence/baselines/`; only the AC5 checkbox changes in `spec.md`. Done when the AC5 box is checked and the `AC5` section names both paths and carries the substitution statement.
- [ ] [P5-T15] Check off AC6 in `<FEATURE>/spec.md` when the P5-T9 scope artifact lists none of the three LIST-EPICSCOPE paths and the P4-T4 comparison shows `EQUAL` for all three. Record both artifact paths in `<FEATURE>/evidence/qa-gates/ac-checkoff.<ts>.md` under `AC6`, with `Timestamp:`; only the AC6 checkbox changes in `spec.md`. Done when the AC6 box is checked and the `AC6` section names both paths.
- [ ] [P5-T16] Check off AC7 in `<FEATURE>/spec.md` when the P5-T9 scope artifact under `<FEATURE>/evidence/qa-gates/` lists only the eight LIST-CHANGED paths plus paths under `<FEATURE>/`. Record the artifact path in `<FEATURE>/evidence/qa-gates/ac-checkoff.<ts>.md` under `AC7`, with `Timestamp:`; only the AC7 checkbox changes in `spec.md`. Done when the AC7 box is checked and the `AC7` section names the path.
- [ ] [P5-T17] Check off AC8 in `<FEATURE>/spec.md` when the P5-T7 QA-loop artifact names a clean pass whose P5-T2, P5-T3, P5-T4, and P5-T5 artifacts under `<FEATURE>/evidence/qa-gates/` show `FORMAT-DRIFT-COUNT: 0`, `PSSA-TOTAL: 0`, `EXIT_CODE: 0`, and `Failed: 0` respectively. Record the four artifact paths in `<FEATURE>/evidence/qa-gates/ac-checkoff.<ts>.md` under `AC8`, with `Timestamp:`; only the AC8 checkbox changes in `spec.md`. Done when the AC8 box is checked and the `AC8` section names the four paths.
- [ ] [P5-T18] Check off AC9 in `<FEATURE>/spec.md` when the P5-T6 coverage artifact under `<FEATURE>/evidence/qa-gates/` shows a post-change percent greater than or equal to the P0-T12 baseline percent. Record both artifact paths in `<FEATURE>/evidence/qa-gates/ac-checkoff.<ts>.md` under `AC9`, with `Timestamp:`; only the AC9 checkbox changes in `spec.md`. Done when the AC9 box is checked and the `AC9` section names both paths.

**Post-PR tasks (P5-T19, P5-T20):** these two tasks run only after the orchestrator has opened the pull request and a CI run exists for the branch head. Both stay unchecked until then; every earlier task is completable without them.

- [ ] [P5-T19] Record the CI result for AC4: run `gh run list --branch bug/gate-suites-read-unmocked-local-epic-state-709 --workflow ci.yml --limit 1 --json conclusion,headSha,databaseId`, then `gh run view <databaseId> --json jobs` to find the job whose name contains `PowerShell QC` and its conclusion, then `gh run download <databaseId> --name poshqc-test-results --dir <scratchpad>/ci-709` (session scratchpad, outside the repository), and read the `<testsuite ...>` element of `pester-junit.xml` whose `name` attribute ends with `enforce-gate-suites.EpicStateIsolation.Tests.ps1`. Write `<FEATURE>/evidence/qa-gates/ci-poshqc.<ts>.md` with the four schema fields, the head SHA, the job conclusion, and that element's `tests`, `failures`, `errors`, and `skipped` attributes (name attribute reduced to the file name). Done when the job conclusion is `success`, the head SHA equals `git rev-parse HEAD`, and the element shows `tests="24"`, `failures="0"`, `errors="0"`, and `skipped="0"`. The count 24 is the Phase 1 total: 7 structural-guard path rows (P1-T1) + 9 predicate rows (P1-T2) + 4 control rows + 4 treatment rows (P1-T3), the same count P1-T3, P4-T3, and P5-T4 assert. The artifact `poshqc-test-results` and the file `artifacts/pester/pester-junit.xml` are named by the upload step of `.github/workflows/_poshqc.yml` and by `TestResult.OutputPath` in `scripts/powershell/PoshQC/settings/pester.runsettings.psd1`. This task stays unchecked until a CI run exists.
- [ ] [P5-T20] Check off AC4 in `<FEATURE>/spec.md` when the P5-T8 hermeticity-scan artifact shows `HERMETICITY-MATCH-COUNT: 0` and the P5-T19 CI artifact shows `success` and `tests="24"` with `failures="0"`. Record both artifact paths in `<FEATURE>/evidence/qa-gates/ac-checkoff.<ts>.md` under `AC4`, with `Timestamp:`; only the AC4 checkbox changes in `spec.md`. Done when the AC4 box is checked and the `AC4` section names both paths; it stays unchecked while P5-T19 is unchecked.
