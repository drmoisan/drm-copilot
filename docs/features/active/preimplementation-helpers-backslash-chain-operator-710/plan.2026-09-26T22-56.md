# preimplementation-helpers-backslash-chain-operator (Plan)

- **Issue:** #710
- **Parent (optional):** none
- **Owner:** drmoisan
- **Last Updated:** 2026-09-26T23-50
- **Status:** Draft (awaiting validator run and executor preflight)
- **Version:** 1.0
- **Work Mode:** full-bug (`issue.md` marker `- Work Mode: full-bug`). Acceptance-criteria source: `docs/features/active/preimplementation-helpers-backslash-chain-operator-710/spec.md`, section `## Acceptance Criteria`, 11 criteria inventoried as AC-1 through AC-11 in document order (spec lines 206 to 216). No `user-story.md` exists or is required.
- **Research:** `docs/features/active/preimplementation-helpers-backslash-chain-operator-710/research/research.2026-09-26T23-05.md`
- **Branch:** `bug/preimplementation-helpers-backslash-chain-operator-710`. The base commit is whatever `HEAD` is when [P0-T3] runs; it is recorded as `BASE_SHA` and every diff in this plan is anchored to it. No task reads `origin/main`.
- **Execution scope:** Phases 0 to 6 only. Pushing, pull-request authoring, CI monitoring, and feature review are performed later by the parallel orchestrator and are not tasks of this plan.
- **Implementation delegation:** every change is made by `atomic-executor` applying the `.claude/rules/powershell.md` standards and toolchain. The executor spawns no sub-agent.

**Fail-closed evidence rule:** PowerShell is the only in-scope language. Baseline artifacts are produced in Phase 0 ([P0-T6] to [P0-T11]), final-QC artifacts in Phase 5 ([P5-T2] to [P5-T7]), and the coverage comparison in [P5-T5]. If any of these artifacts is missing or incomplete, the audit verdict is BLOCKED or INCOMPLETE, never PASS.

**Evidence accounting rule:** every evidence-producing task names its artifact path. No evidence-backed task is checked off without its artifact on disk.

`EVIDENCE_LOCATION_OVERRIDE_REJECTED: docs/features/active/preimplementation-helpers-backslash-chain-operator-710/evidence/coverage/ replaced with docs/features/active/preimplementation-helpers-backslash-chain-operator-710/evidence/qa-gates/` (spec AC-10 and the spec test strategy name `evidence/coverage/`, which is not a canonical evidence kind).

`EVIDENCE_LOCATION_OVERRIDE_REJECTED: docs/features/active/preimplementation-helpers-backslash-chain-operator-710/evidence/regression/ replaced with docs/features/active/preimplementation-helpers-backslash-chain-operator-710/evidence/regression-testing/` (spec AC-1 and the spec test strategy name `evidence/regression/`, which is not a canonical evidence kind).

---

## 0. Rules binding on every task

1. **Evidence location and schema.** Every artifact is written under `docs/features/active/preimplementation-helpers-backslash-chain-operator-710/evidence/<kind>/` with `<kind>` one of `baseline`, `regression-testing`, `qa-gates`, `other`. Every command-step artifact carries `Timestamp:` (format `yyyy-MM-ddTHH-mm`), `Command:`, `EXIT_CODE:`, and `Output Summary:`. An artifact whose gate is expected to exit non-zero also carries `ExpectedExitCode: 1`. `EXIT_CODE: SKIPPED` is never a passing outcome, and no task in this plan authorizes a skip.
2. **No host data.** No artifact, test, or document written by this plan contains an absolute filesystem path, a drive letter, a user-profile path, or the executing account name. Where a command prints such a value, the artifact records it with the worktree root replaced by `<WORKSPACE_ROOT>` and the session scratchpad replaced by `<SCRATCHPAD>`.
3. **Fresh process.** Every PowerShell script of section 5 runs in a fresh PowerShell 7 process started with `-NoProfile` through the route [P0-T4] selects, with the worktree root as the working directory. Scripts live in the session scratchpad (never in the repository), use repository-relative paths only, and obtain the root with `$root = (Get-Location).Path`.
4. **No count is read from a PoshQC MCP result.** The MCP tools `mcp__drm-copilot__run_poshqc_format`, `mcp__drm-copilot__run_poshqc_analyze`, and `mcp__drm-copilot__run_poshqc_test` return a summary composed before the child process runs and carry no command output. The executor may run them as a supplementary check, but every count, percentage, test name, or finding that an acceptance condition reads comes from a script of section 5 run by the route of rule 3.
5. **Merge-order independence.** Every edit to the helpers file is derived from its content at execution time, located by the text anchors of section 3 inside the `Split-OrchestrationCommandLine` region that [P0-T5] measures, never by base line numbers. The four helper copies must be byte-identical when [P0-T5] runs. If they are not, execution stops as BLOCKED (section 3, "Divergent copies").
6. **Mirrors are byte copies.** The three non-canonical helper copies are written only with `Copy-Item -LiteralPath <source> -Destination <mirror> -Force` inside a section-5 script, never with Write or Edit. Each copy task appends the repository-relative source, destination, and both SHA256 values to `docs/features/active/preimplementation-helpers-backslash-chain-operator-710/evidence/other/mirror-log.md`.
7. **Commit form.** Every commit stages and commits named paths only: `git add -- <path> ...` followed by `git commit -F <SCRATCHPAD>/<name>.txt -- <path> ...` with the same path list. No `-A`, no `.`, no directory pathspec. The message file follows the executing session's attribution instructions. No task pushes. If a hook denies a staging or commit command, the executor records the denial text in `docs/features/active/preimplementation-helpers-backslash-chain-operator-710/evidence/other/commits.md` and stops as BLOCKED; it does not bypass the hook.
8. **Porcelain scope.** After [P0-T3], a clean-tree condition is stated as "lists no path outside `docs/features/active/preimplementation-helpers-backslash-chain-operator-710/`", because each task's own artifact is uncommitted when the observation is taken.
9. **Pre-existing failures (pre-declared rule).** Phase 0 records the failing Pester test names of the scoped run ([P0-T6], set `B_SCOPED`) and of the full run ([P0-T9], set `B_FULL`). A later Pester gate passes when its failing-name set is a subset of the matching baseline set **and** no test in `tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-helpers.ChainEscape.Tests.ps1`, `tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-helpers.Parity.Tests.ps1`, or `tests/scripts/codex-hooks/legacy-codex-hook-contracts.Tests.ps1` fails. An acceptance criterion that requires a suite to be green is checked off only when that suite has zero failures; otherwise its line stays `- [ ]` and the pre-existing failure names are recorded (Phase 6).
10. **Batching (D8).** Batch 1 is `.claude/hooks/enforce-orchestration-preimplementation-gate-helpers.ps1` (Edit), `.codex/hooks/enforce-orchestration-preimplementation-gate-helpers.ps1` (byte copy), and `tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-helpers.ChainEscape.Tests.ps1` (Write); it spans Phases 1 and 2. Batch 2 is the two extension mirrors (byte copies) in Phase 3. Between the batches the four copies differ, so no task between [P2-T1] and [P3-T2] runs the Parity suite or `tests/scripts/codex-hooks/legacy-codex-hook-contracts.Tests.ps1`.

## 1. Scope and decisions

Binding decisions from `spec.md` "Design Decisions": D1 (escape state added to `Split-OrchestrationCommandLine`), D2 (no change to `ConvertTo-OrchestrationCommandToken`, `Test-OrchestrationCommandTextUnresolvable`, or `Test-ExemptOrchestrationOperand`), D3 (new suite over the two canonical copies), D4 (byte-copy mirrors, SHA256 record), D5 (net-zero line delta, edits confined to `Split-OrchestrationCommandLine`), D6 (CI Pester runs on `windows-latest` only), D7 (operand gap recorded as a follow-up), D8 (two batches), D9 (uniform gates only; `quality-tiers.yml` absent).

Out of scope: the `.\.` operand gap (D7, recorded in [P4-T1]); comment, heredoc, and `$'...'` modelling; every gate file; pack manifests; runsettings.

## 2. Write set (complete)

This plan writes exactly these repository paths:

1. `.claude/hooks/enforce-orchestration-preimplementation-gate-helpers.ps1` (Edit, [P2-T1])
2. `.codex/hooks/enforce-orchestration-preimplementation-gate-helpers.ps1` (byte copy, [P2-T3])
3. `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-orchestration-preimplementation-gate-helpers.ps1` (byte copy, [P3-T2])
4. `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/enforce-orchestration-preimplementation-gate-helpers.ps1` (byte copy, [P3-T2])
5. `tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-helpers.ChainEscape.Tests.ps1` (new, [P1-T2])
6. `docs/features/active/preimplementation-helpers-backslash-chain-operator-710/spec.md` (AC check-offs only, Phase 6)
7. This plan file (checklist state only)
8. Evidence files under `docs/features/active/preimplementation-helpers-backslash-chain-operator-710/evidence/baseline/`, `.../evidence/regression-testing/`, `.../evidence/qa-gates/`, and `.../evidence/other/`, each named in its task.

Every other path cited in this plan is read only. `.claude/hooks/enforce-orchestration-preimplementation-gate.ps1`, `.codex/hooks/enforce-orchestration-preimplementation-gate.ps1`, `.claude/hooks/enforce-orchestration-preimplementation-gate-epic-scope.ps1`, the CommandExemption suites, and `scripts/powershell/PoshQC/settings/pester.runsettings.psd1` are not written.

## 3. The production edit (derived from current content)

All three edits are inside the region `[FUNC_START, FUNC_END]` of `.claude/hooks/enforce-orchestration-preimplementation-gate-helpers.ps1`, where `FUNC_START` is the first line equal to `function Split-OrchestrationCommandLine {` and `FUNC_END` is the first later line equal to `}`. On base `2dce111e` the region is lines 58 to 108 and the file has 497 lines; the values measured by [P0-T5] govern.

**Edit E1 (help text, net -1 line).** Replace the four consecutive `.DESCRIPTION` lines inside the region:

```text
        Realizes D4 row 13. Quote state is tracked while scanning so a chain operator
        inside a quoted span does not split. The returned `Balanced` flag reports whether
        the scan ended outside every quote; unbalanced text is not splittable and the
        caller denies (D4 rows 11 and 13). Empty and whitespace-only segments are dropped.
```

with these three lines (eight leading spaces each):

```text
        Realizes D4 row 13. Quote state and POSIX backslash escapes (issue #710) are tracked, so a quoted or
        escaped chain operator does not split. `Balanced` reports whether the scan ended outside every quote;
        the caller denies unbalanced text (D4 rows 11 and 13). Empty and whitespace-only segments are dropped.
```

**Edit E2 (escape state, net 0 lines).** Replace the empty line that immediately follows the region line `    $openQuote = [char]0` with the line (four leading spaces):

```text
    $escaped = $false
```

**Edit E3 (pairwise consumption, net +1 line).** Insert, immediately after the region line `    foreach ($character in $CommandText.ToCharArray()) {`, the line (eight leading spaces):

```text
        if ($escaped -or ($character -eq '\' -and $openQuote -ne "'")) { $escaped = -not $escaped; [void]$current.Append($character); continue }
```

Net line delta: -1 + 0 + 1 = 0, so the post-edit line count equals `PRE_EDIT_LINE_COUNT`. `git diff --numstat` against `BASE_SHA` reports 5 added and 5 deleted lines for the file. No line outside the region changes. The quote branch, the operator branch, the return statement, and every other function are untouched.

Semantics (research section 2, spec technical table): a backslash outside a single-quoted span sets `$escaped` and is appended; the next character, whatever it is, is appended without quote or operator evaluation and clears `$escaped`. Inside single quotes a backslash is literal. `Balanced` still depends only on `$openQuote`, so a trailing lone backslash stays balanced.

**Divergent copies.** If [P0-T5] reports `BYTE_IDENTICAL: False`, execution stops as BLOCKED before any write, with the reason: "the four helper copies differ at execution time; the D4 byte-copy step would overwrite a sibling change present in only some copies, and applying the same hunk to each copy cannot make copies that differ outside the hunk byte-identical." The four `LINES:` and `SHA256:` values are the report. The plan does not choose a winning copy.

**Missing anchors.** If any anchor count in [P0-T5] is not exactly 1, if the line after the `$openQuote` anchor is not empty, or if `ESCAPE_LINES` is not 0, execution stops as BLOCKED and the [P0-T5] output is reported as a plan-revision input (a sibling has changed `Split-OrchestrationCommandLine`).

## 4. Regression suite (exact content)

[P1-T2] writes `tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-helpers.ChainEscape.Tests.ps1` with exactly this content (LF line endings, no trailing whitespace):

```powershell
#Requires -Version 7.0
#Requires -Modules @{ ModuleName = 'Pester'; ModuleVersion = '5.0.0' }

# Issue #710 - POSIX backslash escapes in the command-chain scanner of the preimplementation
# gate helpers module. Each case calls the pure functions Split-OrchestrationCommandLine and
# Test-ExemptOrchestrationStagingCommand directly, once against the Claude canonical copy and
# once against the Codex canonical copy, each resolved from this file's own directory with
# Join-Path. The cases read the two helper files only and start no child process. The two
# bundled copies are covered by the SHA256 identity case in the helpers parity suite.

Describe 'preimplementation gate helpers chain escapes (<Surface>)' -ForEach @(
    @{ Surface = '.claude/hooks' }
    @{ Surface = '.codex/hooks' }
) {
    BeforeAll {
        $repoRoot = (Resolve-Path (Join-Path $PSScriptRoot '../../..')).Path
        $helpersPath = Join-Path (Join-Path $repoRoot $Surface) 'enforce-orchestration-preimplementation-gate-helpers.ps1'
        . $helpersPath
    }

    It 'treats a mid-line escaped semicolon as literal' {
        # Arrange
        $commandText = 'find . -exec cmd {} \; -print'

        # Act
        $result = Split-OrchestrationCommandLine -CommandText $commandText

        # Assert
        $result.Balanced | Should -BeTrue
        @($result.Segments).Count | Should -Be 1 -Because 'an escaped semicolon is a literal character'
        $result.Segments[0] | Should -BeExactly $commandText
    }

    It 'treats an escaped ampersand as literal' {
        # Arrange
        $commandText = 'a\&b c'

        # Act
        $result = Split-OrchestrationCommandLine -CommandText $commandText

        # Assert
        @($result.Segments).Count | Should -Be 1 -Because 'an escaped ampersand is a literal character'
        $result.Segments[0] | Should -BeExactly $commandText
    }

    It 'treats an escaped pipe as literal' {
        # Arrange
        $commandText = 'a\|b c'

        # Act
        $result = Split-OrchestrationCommandLine -CommandText $commandText

        # Assert
        @($result.Segments).Count | Should -Be 1 -Because 'an escaped pipe is a literal character'
        $result.Segments[0] | Should -BeExactly $commandText
    }

    It 'treats backslash-newline as a line continuation' {
        # Arrange
        $commandText = 'a\' + [char]10 + 'b'

        # Act
        $result = Split-OrchestrationCommandLine -CommandText $commandText

        # Assert
        @($result.Segments).Count | Should -Be 1 -Because 'an escaped newline continues the line'
        $result.Segments[0] | Should -BeExactly $commandText
    }

    It 'still splits on unescaped <Operator>' -ForEach @(
        @{ Operator = ';'; CommandText = 'a; b' }
        @{ Operator = '&&'; CommandText = 'a && b' }
        @{ Operator = '||'; CommandText = 'a || b' }
        @{ Operator = '|'; CommandText = 'a | b' }
        @{ Operator = '&'; CommandText = 'a & b' }
    ) {
        # Act
        $result = Split-OrchestrationCommandLine -CommandText $CommandText

        # Assert
        $result.Balanced | Should -BeTrue
        @($result.Segments).Count | Should -Be 2 -Because "an unescaped $Operator is a chain operator"
    }

    It 'still splits after an escaped backslash' {
        # Arrange
        $commandText = 'a\\; b'

        # Act
        $result = Split-OrchestrationCommandLine -CommandText $commandText

        # Assert
        @($result.Segments).Count | Should -Be 2 -Because 'an escaped backslash leaves the semicolon live'
        $result.Segments[0] | Should -BeExactly 'a\\'
    }

    It 'does not split after an odd run of backslashes' {
        # Arrange
        $commandText = 'a\\\; b'

        # Act
        $result = Split-OrchestrationCommandLine -CommandText $commandText

        # Assert
        @($result.Segments).Count | Should -Be 1 -Because 'the third backslash escapes the semicolon'
    }

    It 'splits on the unescaped ampersand after an escaped one' {
        # Arrange
        $commandText = 'a\&& b'

        # Act
        $result = Split-OrchestrationCommandLine -CommandText $commandText

        # Assert
        @($result.Segments).Count | Should -Be 2 -Because 'only the first ampersand is escaped'
    }

    It 'keeps backslash literal inside single quotes' {
        # Arrange
        $commandText = '''a\''; b'

        # Act
        $result = Split-OrchestrationCommandLine -CommandText $commandText

        # Assert
        $result.Balanced | Should -BeTrue
        @($result.Segments).Count | Should -Be 2 -Because 'a backslash does not escape inside single quotes'
    }

    It 'consumes an escaped double quote inside double quotes' {
        # Arrange
        $commandText = '"a\"; b"'

        # Act
        $result = Split-OrchestrationCommandLine -CommandText $commandText

        # Assert
        $result.Balanced | Should -BeTrue -Because 'the escaped double quote does not close the span'
        @($result.Segments).Count | Should -Be 1
    }

    It 'does not open a quote on an unquoted escaped double quote' {
        # Arrange
        $commandText = 'a\"'

        # Act
        $result = Split-OrchestrationCommandLine -CommandText $commandText

        # Assert
        $result.Balanced | Should -BeTrue -Because 'an escaped double quote is a literal character'
        @($result.Segments).Count | Should -Be 1
    }

    It 'treats a trailing lone backslash as balanced' {
        # Arrange
        $commandText = 'a\'

        # Act
        $result = Split-OrchestrationCommandLine -CommandText $commandText

        # Assert
        $result.Balanced | Should -BeTrue
        @($result.Segments).Count | Should -Be 1
        $result.Segments[0] | Should -BeExactly $commandText
    }

    It 'returns no segments for an empty command' {
        # Act
        $result = Split-OrchestrationCommandLine -CommandText ''

        # Assert
        $result.Balanced | Should -BeTrue
        @($result.Segments).Count | Should -Be 0
    }

    It 'exempts a commit whose message contains an escaped semicolon' {
        # Arrange
        $commandText = 'git commit -m fix\;done -- docs/features/active/x/spec.md'

        # Act
        $isExempt = Test-ExemptOrchestrationStagingCommand -CommandText $commandText

        # Assert
        $isExempt | Should -BeTrue -Because 'the shell runs one git commit whose message is fix;done'
    }

    It 'does not exempt a chained command after an escaped backslash' {
        # Arrange
        $commandText = 'git commit -m fix\\; touch src/x -- docs/features/active/x/spec.md'

        # Act
        $isExempt = Test-ExemptOrchestrationStagingCommand -CommandText $commandText

        # Assert
        $isExempt | Should -BeFalse -Because 'the semicolon after an escaped backslash starts a second command'
    }
}
```

Expanded test inventory: 19 `It` expansions per surface, 38 in total. The `-ForEach` operator row expands to the five names `still splits on unescaped ;`, `still splits on unescaped &&`, `still splits on unescaped ||`, `still splits on unescaped |`, and `still splits on unescaped &`.

Fail-before derivation (analytical, from the scanner at helpers lines 74 to 107 on base, which has no escape state): the eight names below fail on each surface before the fix, 16 failures in total; the other 11 names per surface (22 in total) pass before and after the fix.

1. `treats a mid-line escaped semicolon as literal` (base: 2 segments)
2. `treats an escaped ampersand as literal` (base: 2 segments)
3. `treats an escaped pipe as literal` (base: 2 segments)
4. `treats backslash-newline as a line continuation` (base: splits on LF)
5. `does not split after an odd run of backslashes` (base: 2 segments)
6. `consumes an escaped double quote inside double quotes` (base: the escaped quote closes the span, unbalanced)
7. `does not open a quote on an unquoted escaped double quote` (base: unbalanced)
8. `exempts a commit whose message contains an escaped semicolon` (base: second segment `done -- ...` is not a git invocation, false)

## 5. Command routes and scripts

- **Route selection ([P0-T4]).** Tried in this order; the first that is not refused before execution (a tool or hook denial) is recorded and used for the rest of the plan:
  1. `direct`: `pwsh -NoProfile -File <SCRATCHPAD>/<name>.ps1` (Bash or PowerShell tool). This is the fresh `pwsh -NoProfile` process the caller specified; `-File` is used in place of `-Command` so the process exit code equals the script's `exit` value and backslash fixtures need no shell quoting.
  2. `sh`: Bash tool `sh <SCRATCHPAD>/<name>.sh`, whose body is the single line `exec pwsh -NoProfile -File "$(dirname "$0")/<name>.ps1"`.
  3. `child`: PowerShell tool `& ([System.Diagnostics.Process]::GetCurrentProcess().MainModule.FileName) -NoProfile -File <SCRATCHPAD>/<name>.ps1`.
- **R-SCOPED (scoped Pester runner).** `$ErrorActionPreference = 'Stop'`; `Import-Module Pester -MinimumVersion 5.0.0`; `$configuration = New-PesterConfiguration`; `$configuration.Run.Path = @(<repository-relative test files>)`; `$configuration.Run.PassThru = $true`; `$configuration.Output.Verbosity = 'Normal'`; `$result = Invoke-Pester -Configuration $configuration`; print `PassedCount: <n>`, `FailedCount: <n>`, `FailedBlocksCount: <n>`, `FailedContainersCount: <n>`, then one `FAILED: <ExpandedPath>` line per failed test and one `PASSED: <ExpandedPath>` line per passed test; `exit ([int](($result.FailedCount + $result.FailedBlocksCount + $result.FailedContainersCount) -gt 0))`.
- **R-COV (scoped coverage runner).** R-SCOPED plus, before `Invoke-Pester`: `$configuration.CodeCoverage.Enabled = $true`; `$configuration.CodeCoverage.Path = @('.claude/hooks/enforce-orchestration-preimplementation-gate-helpers.ps1', '.codex/hooks/enforce-orchestration-preimplementation-gate-helpers.ps1')`; `$configuration.CodeCoverage.OutputPath = '<SCRATCHPAD>/<name>.coverage.xml'`. After the run, for each of the two paths: resolve the full path; `$executed` = distinct `Line` values of `$result.CodeCoverage.CommandsExecuted` whose `File` equals it; `$missed` = distinct `Line` values of `$result.CodeCoverage.CommandsMissed` whose `File` equals it and that are not in `$executed`; print `LINE_COVERAGE: <relative path> covered=<executed count> missed=<missed count> percent=<100 x covered / (covered + missed), 2 decimals>` and `MISSED_LINES: <relative path> <comma-separated missed lines or none>`. Then, for each of the two paths and each of the literals `$escaped = $false` and `if ($escaped -or`, find the line numbers containing the literal and print `CHANGED_LINE: <relative path>:<line> executed|missed|not-a-command` (no line is printed when the literal is absent). A line counts as covered when at least one command on it executed, which matches the JaCoCo `LINE` counter.
- **HRS (helper-reaching suite set).** `tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.CommandExemption.Tests.ps1`, `tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-command-exemption.Tests.ps1`, `tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.EpicScope.Tests.ps1`, `tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.TriggerScoping.Tests.ps1`, `tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.Tests.ps1`, `tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-trigger-scoping.Tests.ps1`, `tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-mode-resolution.Tests.ps1`, `tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-mode-routing.Tests.ps1`, `tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-helpers.Parity.Tests.ps1`, `tests/scripts/codex-hooks/legacy-codex-hook-contracts.Tests.ps1` (10 files).
- **R-DETECT (helper detection).** For each of the four helper copies (canonical first, then `.codex/hooks`, then the claude-customizations mirror, then the codex-and-agents-customizations mirror) print `LINES: <path> <(Get-Content -LiteralPath <path>).Count>`, `SHA256: <path> <Get-FileHash -Algorithm SHA256>`, and `CR_PRESENT: <path> <whether [IO.File]::ReadAllText contains a carriage return>`; print `BYTE_IDENTICAL: <True when the four hashes are equal>`. For the canonical file print `FUNC_START: <n>` and `FUNC_END: <n>` per section 3; then, counting only lines inside the region, one `ANCHOR: <label> count=<n> line=<first line or 0>` line for each of: `OLD_DESC_1` to `OLD_DESC_4` (the four E1 source lines), `NEW_DESC_1` to `NEW_DESC_3` (the three E1 replacement lines), `OPENQUOTE` (`    $openQuote = [char]0`), `FOREACH` (`    foreach ($character in $CommandText.ToCharArray()) {`), `ESCAPED_INIT` (`    $escaped = $false`), and `ESCAPE_IF` (the E3 line); print `LINE_AFTER_OPENQUOTE: <empty|escaped-init|other>`, `LINE_AFTER_FOREACH: <escape-if|other>`, and `ESCAPE_LINES: <count of lines in the whole file containing $escaped>`. Anchor text is compared with `-ceq` on whole lines.
- **R-FMT (formatter stability probe).** Import `PSScriptAnalyzer`; read the target file with `Get-Content -Raw`; replace CRLF with LF; run `Invoke-Formatter -ScriptDefinition <text> -Settings scripts/powershell/PoshQC/settings/pssa.settings.psd1`; print `FORMAT_STABLE: <formatted -eq normalized>` and `FORMATTED_LINE_COUNT: <line count of the formatted text>`. This mirrors `Invoke-PoshQCFormat` (`scripts/powershell/PoshQC/PoshQC.Analyzer.psm1` lines 56 to 66) for one file and writes nothing.
- **R-FORMAT / R-ANALYZE.** Import `scripts/powershell/PoshQC/PoshQC.psm1`; run `Invoke-PoshQCFormat -Root $root` or `Invoke-PoshQCAnalyze -Root $root`. The formatter logs `Formatted: <path>` per rewritten file and `Already formatted: <path>` otherwise (`PoshQC.Analyzer.psm1` lines 62 and 64). The analyzer prints `PSScriptAnalyzer passed: no findings under <root>` on success (line 185) and throws `PSScriptAnalyzer reported <N> issue(s).` otherwise (line 183).
- **R-FULL (full Pester, two scripts).** Script A imports `scripts/powershell/PoshQC/PoshQC.psm1` and runs `Invoke-PoshQCTest -Root $root`, the command CI runs at `.github/workflows/_poshqc.yml` line 42; `Run.Exit = $true` in the runsettings (line 4) can end the process on failure, so script B runs separately. Script B reads `artifacts/pester/pester-junit.xml` (runsettings line 15), prints `JUNIT_LAST_WRITE_UTC: <time>`, `JUNIT_TESTS: <n>`, `JUNIT_FAILURES: <n>`, `JUNIT_ERRORS: <n>` from the root element, one `JUNIT_SUITE: <relative path> tests=<n> failures=<n> errors=<n>` line per testsuite (the `name` attribute with the worktree root removed and `\` replaced by `/`), and one `JUNIT_FAILED: <relative path> :: <testcase name>` line per testcase carrying a `failure` or `error` child.
- **R-PYTEST.** `poetry run pytest tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py -q`, which prints a final summary line with a passed count and any failed or error counts. A failure of only `tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py::test_bundled_claude_payload_contains_all_repo_runtime_contracts` that also failed at baseline is the known local-only issue #510 (gitignored `.claude/state` files) and is recorded as `KNOWN_ISSUE_510`, not as a regression.

---

### Phase 0 — Policy Reading, Detection, and Baseline Capture

- [ ] [P0-T1] Read, in this order: `CLAUDE.md`, `.github/copilot-instructions.md`, `.github/instructions/tonality.instructions.md`, `.github/instructions/general-code-change.instructions.md`, `.github/instructions/general-unit-test.instructions.md`, `.github/instructions/powershell-code-change.instructions.md`, `.github/instructions/powershell-unit-test.instructions.md`, `.claude/rules/general-code-change.md`, `.claude/rules/general-unit-test.md`, `.claude/rules/quality-tiers.md`, `.claude/rules/powershell.md`, `.claude/rules/tonality.md`, `.claude/rules/plan-acceptance-gates.md`. Write `docs/features/active/preimplementation-helpers-backslash-chain-operator-710/evidence/baseline/phase0-instructions-read.md` with `Timestamp:`, `Policy Order:` (the 13 paths in order), and `Files Read:` (the same 13). Acceptance: the three labels are present and `Files Read:` lists exactly 13 paths.
- [ ] [P0-T2] Read `docs/features/active/preimplementation-helpers-backslash-chain-operator-710/issue.md`, `docs/features/active/preimplementation-helpers-backslash-chain-operator-710/spec.md`, `docs/features/active/preimplementation-helpers-backslash-chain-operator-710/research/research.2026-09-26T23-05.md`, and this plan. Write `docs/features/active/preimplementation-helpers-backslash-chain-operator-710/evidence/baseline/p0-feature-documents-read.md` with `Timestamp:`, `Files Read:` (four paths), and `AC Inventory:` giving, for every `- [ ]` line below `## Acceptance Criteria` in `spec.md`, its identifier (AC-1 upward in document order), its line number, and its full text. Acceptance: exactly 11 entries, AC-1 to AC-11, at spec lines 206 to 216 in order.
- [ ] [P0-T3] Record the base: run `git rev-parse --abbrev-ref HEAD`, `git rev-parse HEAD`, and `git status --porcelain`. Write `docs/features/active/preimplementation-helpers-backslash-chain-operator-710/evidence/baseline/p0-base-ref.md` (four schema fields) with `BRANCH:`, `BASE_SHA:` (the `HEAD` value), and a `Porcelain:` section holding the status output verbatim. Acceptance: `BRANCH:` reads `bug/preimplementation-helpers-backslash-chain-operator-710`; `BASE_SHA:` is 40 hexadecimal characters; every porcelain path begins with `docs/features/active/preimplementation-helpers-backslash-chain-operator-710/`.
- [ ] [P0-T4] Select the route and observe R-SCOPED success-case output: write `<SCRATCHPAD>/p0-probe.ps1` as R-SCOPED with `Run.Path` `tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-helpers.Parity.Tests.ps1` and launch it by the first non-refused route of section 5. Write `docs/features/active/preimplementation-helpers-backslash-chain-operator-710/evidence/baseline/p0-execution-route.md` (four schema fields) with exactly one `ROUTE_SELECTED:` line (`direct`, `sh`, or `child`), any refusal text with host tokens replaced, and the probe output. Acceptance: `EXIT_CODE: 0`; the output contains `PassedCount: 2`, `FailedCount: 0`, `FailedBlocksCount: 0`, `FailedContainersCount: 0`, and `PASSED:` lines ending with `keeps all four surface copies of the helpers module byte-identical by SHA256 hash` and `keeps every surface copy of the helpers module under the 500-line cap`. If all three routes are refused, record `ROUTE_SELECTED: none`, stop, and report BLOCKED.
- [ ] [P0-T5] Helper detection (merge-order guard): run R-DETECT. Write `docs/features/active/preimplementation-helpers-backslash-chain-operator-710/evidence/baseline/p0-helpers-detection.md` (four schema fields) with the output verbatim and the line `PRE_EDIT_LINE_COUNT: <the canonical LINES value>`. Acceptance: four `LINES:`, four `SHA256:`, and four `CR_PRESENT:` lines; `BYTE_IDENTICAL: True`; the canonical `LINES` value is at most 500; anchors `OLD_DESC_1` to `OLD_DESC_4`, `OPENQUOTE`, and `FOREACH` each have `count=1`; `NEW_DESC_1` to `NEW_DESC_3`, `ESCAPED_INIT`, and `ESCAPE_IF` each have `count=0`; `LINE_AFTER_OPENQUOTE: empty`; `ESCAPE_LINES: 0`. When `BYTE_IDENTICAL: False`, stop as BLOCKED with the section 3 "Divergent copies" reason; when any other condition fails, stop as BLOCKED per section 3 "Missing anchors".
- [ ] [P0-T6] Scoped coverage baseline: run R-COV over the 10 HRS files of section 5. Write `docs/features/active/preimplementation-helpers-backslash-chain-operator-710/evidence/baseline/p0-scoped-coverage.md` (four schema fields) with the four count lines, every `FAILED:` line (or `none`), both `LINE_COVERAGE:` lines, and both `MISSED_LINES:` lines, and a `B_SCOPED:` section listing the failed `ExpandedPath` values. Acceptance: the four counts and both `percent=` values are numbers (this task observes the R-COV success-case output before [P5-T4] asserts over it); `Output Summary:` states the passed count, the failed count, and both percentages. If either `LINE_COVERAGE:` line is absent, stop and report BLOCKED as a plan-revision input.
- [ ] [P0-T7] PowerShell format baseline: record `git status --porcelain`; run R-FORMAT; record `git status --porcelain` again. Write `docs/features/active/preimplementation-helpers-backslash-chain-operator-710/evidence/baseline/p0-poshqc-format.md` (four schema fields) with the count of lines beginning `Formatted: `, the count beginning `Already formatted: `, and a `Tree Delta:` section holding both porcelain outputs. If any tracked file was rewritten, revert each with `git checkout -- <path>`, list the paths with host tokens replaced, and record a third porcelain output. Acceptance: both counts are numbers, the `Already formatted: ` count is greater than 0, and the final porcelain output equals the first.
- [ ] [P0-T8] PowerShell analyzer baseline: run R-ANALYZE. Write `docs/features/active/preimplementation-helpers-backslash-chain-operator-710/evidence/baseline/p0-poshqc-analyze.md` (four schema fields) with either the line beginning `PSScriptAnalyzer passed: no findings under` (root replaced by `<WORKSPACE_ROOT>`) or the `PSScriptAnalyzer reported <N> issue(s).` line and the findings table with host tokens replaced. Acceptance: exactly one of the two outcomes is recorded, with `N` numeric when findings exist.
- [ ] [P0-T9] Full Pester baseline: run R-FULL script A, then script B. Write `docs/features/active/preimplementation-helpers-backslash-chain-operator-710/evidence/baseline/p0-pester-full.md` (four schema fields; `Command:` names both scripts; `EXIT_CODE:` is script A's) with any console line beginning `Tests Passed:`, and script B's `JUNIT_LAST_WRITE_UTC:`, `JUNIT_TESTS:`, `JUNIT_FAILURES:`, `JUNIT_ERRORS:` lines, every `JUNIT_FAILED:` line (or `none`), and a `B_FULL:` section repeating the `JUNIT_FAILED:` entries. Acceptance: `JUNIT_LAST_WRITE_UTC:` is at or after `Timestamp:`; `JUNIT_TESTS:`, `JUNIT_FAILURES:`, and `JUNIT_ERRORS:` are numbers. A non-zero failure count is recorded, not waived.
- [ ] [P0-T10] Push-down contract baseline: record `git status --porcelain --ignored -- .claude/state`, then run R-PYTEST. Write `docs/features/active/preimplementation-helpers-backslash-chain-operator-710/evidence/baseline/p0-pytest-push-down.md` (four schema fields) with the status output, the final summary line verbatim, and the node ID of every failed or errored test (or `none`). Acceptance: the summary line is recorded with a numeric passed count.
- [ ] [P0-T11] Formatter stability probe on the unmodified canonical file: run R-FMT on `.claude/hooks/enforce-orchestration-preimplementation-gate-helpers.ps1`. Write `docs/features/active/preimplementation-helpers-backslash-chain-operator-710/evidence/baseline/p0-format-stability.md` (four schema fields). Acceptance: the output contains `FORMAT_STABLE: True` and `FORMATTED_LINE_COUNT:` equal to `PRE_EDIT_LINE_COUNT` (this observes the probe's success-case output before [P2-T2] asserts over it). Otherwise stop and report BLOCKED as a plan-revision input.
- [ ] [P0-T12] Baseline gate: read the artifacts of [P0-T6] to [P0-T10] and write `docs/features/active/preimplementation-helpers-backslash-chain-operator-710/evidence/baseline/p0-baseline-summary.md` (`Timestamp:` and one row per check reading `GREEN` or `NOT GREEN - <condition>`). Halting checks: [P0-T7] `Formatted: ` count is 0; [P0-T8] records the `PSScriptAnalyzer passed: no findings under` outcome. Recording checks (rule 9, no halt): [P0-T6] `FailedCount: 0` and both percentages at least 85; [P0-T9] `JUNIT_FAILURES: 0` and `JUNIT_ERRORS: 0`; [P0-T10] no failed node. Acceptance: every halting row reads `GREEN`; when a halting row reads `NOT GREEN`, execution stops before Phase 1 and the row is reported as a plan-revision input, because the final QC loop could not then complete a clean pass. Recording rows are copied into `B_SCOPED` and `B_FULL` as found.

### Phase 1 — Batch 1 (Part 1): Regression Suite and Fail-Before Evidence

- [ ] [P1-T1] Append the entry `Batch 1` to `docs/features/active/preimplementation-helpers-backslash-chain-operator-710/evidence/other/batch-log.md` with `Timestamp:` and the three batch-1 paths of rule 10, marking the Edit/Write slots used (1 production, 1 test) and the byte copy (1). Acceptance: the entry names exactly those three paths.
- [ ] [P1-T2] Create `tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-helpers.ChainEscape.Tests.ps1` with exactly the section 4 content. Acceptance: the file exists; `(Get-Content -LiteralPath tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-helpers.ChainEscape.Tests.ps1).Count` is at most 500; `[IO.File]::ReadAllText` of the file contains no carriage return; `Select-String -SimpleMatch -Pattern "It '" -Path tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-helpers.ChainEscape.Tests.ps1` returns exactly 15 lines. Record the three observations in `docs/features/active/preimplementation-helpers-backslash-chain-operator-710/evidence/other/test-file-created.md` (`Timestamp:` required).
- [ ] [P1-T3] Portability inspection for AC-8 (D3 constraints): run a section-5 script that counts, in `tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-helpers.ChainEscape.Tests.ps1`, the matching lines for each simple-match token `origin/`, `artifacts/`, `.claude/state`, `Invoke-OrchestrationPreimplementationGateDecision`, `gate.ps1`, `Set-Location`, `TestDrive`, `& git`, `Start-Process`, and `New-TemporaryFile`; for the regular expression `[A-Za-z]:[\\/]`; and for the positive controls `Join-Path` and `$PSScriptRoot`. Write `docs/features/active/preimplementation-helpers-backslash-chain-operator-710/evidence/qa-gates/test-portability-inspection.md` (four schema fields) with one `TOKEN: <token> matches=<n>` line each. Acceptance: every listed token and the regular expression report `matches=0`; `Join-Path` reports `matches=3` (the header comment line and the two `BeforeAll` lines of section 4); `$PSScriptRoot` reports `matches=1`.
- [ ] [P1-T4] [expect-fail] Run R-SCOPED over `tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-helpers.ChainEscape.Tests.ps1` before any production change. Write `docs/features/active/preimplementation-helpers-backslash-chain-operator-710/evidence/regression-testing/fail-before-chain-escape.md` with the four schema fields, `ExpectedExitCode: 1`, and the runner output. Acceptance: `EXIT_CODE: 1`; `PassedCount: 22`; `FailedCount: 16`; `FailedBlocksCount: 0`; `FailedContainersCount: 0`; the `FAILED:` lines are exactly the eight section 4 fail-before names, each once with `(.claude/hooks)` and once with `(.codex/hooks)` in its path. Any other outcome stops execution and is reported as a plan-revision input.

### Phase 2 — Batch 1 (Part 2): Canonical Fix and Codex Copy

- [ ] [P2-T1] Apply edits E1, E2, and E3 of section 3 to `.claude/hooks/enforce-orchestration-preimplementation-gate-helpers.ps1`, locating each by its anchor text inside the region measured in [P0-T5] and changing no other line. Acceptance: verified by [P2-T2].
- [ ] [P2-T2] Post-edit checks: run R-DETECT and R-FMT on the canonical file, `git diff --numstat BASE_SHA -- .claude/hooks/enforce-orchestration-preimplementation-gate-helpers.ps1`, and `git diff -U0 BASE_SHA -- .claude/hooks/enforce-orchestration-preimplementation-gate-helpers.ps1` (substituting the recorded `BASE_SHA`), plus `git status --porcelain`. Write `docs/features/active/preimplementation-helpers-backslash-chain-operator-710/evidence/qa-gates/canonical-edit-checks.md` (four schema fields) with the outputs, `PRE_EDIT_LINE_COUNT:` from [P0-T5], `POST_EDIT_LINE_COUNT:`, and every `@@` hunk header with its pre-image start line. Acceptance: `POST_EDIT_LINE_COUNT` equals `PRE_EDIT_LINE_COUNT` and is at most 500; the canonical `CR_PRESENT:` value equals its [P0-T5] value; `OLD_DESC_1` to `OLD_DESC_4` have `count=0`; `NEW_DESC_1` to `NEW_DESC_3`, `ESCAPED_INIT`, `ESCAPE_IF`, `OPENQUOTE`, and `FOREACH` have `count=1`; `LINE_AFTER_OPENQUOTE: escaped-init`; `LINE_AFTER_FOREACH: escape-if`; `ESCAPE_LINES: 2`; `FORMAT_STABLE: True`; the numstat line reads `5`, `5`, and the path; every hunk's pre-image start line lies within `[FUNC_START, FUNC_END]` from [P0-T5]; the porcelain output lists `.claude/hooks/enforce-orchestration-preimplementation-gate-helpers.ps1` and the new test file and no other path outside the feature folder. If `FORMAT_STABLE: False` and `FORMATTED_LINE_COUNT` equals `PRE_EDIT_LINE_COUNT`, write the formatter output to the canonical file with `Set-Content -NoNewline -Encoding UTF8` (the PoshQC write form) and rerun this task; if `FORMATTED_LINE_COUNT` differs, stop as BLOCKED because D5 cannot hold with the formatter's layout.
- [ ] [P2-T3] Byte-copy `.claude/hooks/enforce-orchestration-preimplementation-gate-helpers.ps1` to `.codex/hooks/enforce-orchestration-preimplementation-gate-helpers.ps1` per rule 6. Acceptance: the `docs/features/active/preimplementation-helpers-backslash-chain-operator-710/evidence/other/mirror-log.md` entry records two equal SHA256 values.
- [ ] [P2-T4] Pass-after run: R-SCOPED over `tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-helpers.ChainEscape.Tests.ps1`. Write `docs/features/active/preimplementation-helpers-backslash-chain-operator-710/evidence/qa-gates/pass-after-chain-escape.md` (four schema fields) with the runner output. Acceptance: `EXIT_CODE: 0`; `PassedCount: 38`; `FailedCount: 0`; `FailedBlocksCount: 0`; `FailedContainersCount: 0`; each of the 19 expanded names of section 4 appears on exactly two `PASSED:` lines, one containing `(.claude/hooks)` and one containing `(.codex/hooks)`.
- [ ] [P2-T5] Batch-1 existing-suite check (no Parity, rule 10): R-SCOPED over `tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.CommandExemption.Tests.ps1` and `tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-command-exemption.Tests.ps1`. Write `docs/features/active/preimplementation-helpers-backslash-chain-operator-710/evidence/qa-gates/batch1-command-exemption.md` (four schema fields) with the runner output and the `B_SCOPED` entries for those two files. Acceptance: `FailedBlocksCount: 0`; `FailedContainersCount: 0`; every `FAILED:` path is in `B_SCOPED` (rule 9); when `B_SCOPED` holds no entry for these files, `EXIT_CODE: 0` and `FailedCount: 0`.

### Phase 3 — Batch 2: Extension Mirrors and Parity

- [ ] [P3-T1] Append the entry `Batch 2` to `docs/features/active/preimplementation-helpers-backslash-chain-operator-710/evidence/other/batch-log.md` with `Timestamp:` and the two extension mirror paths, marking zero Edit/Write slots and two byte copies. Acceptance: the entry names exactly `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-orchestration-preimplementation-gate-helpers.ps1` and `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/enforce-orchestration-preimplementation-gate-helpers.ps1`.
- [ ] [P3-T2] Byte-copy `.claude/hooks/enforce-orchestration-preimplementation-gate-helpers.ps1` to `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-orchestration-preimplementation-gate-helpers.ps1` and to `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/enforce-orchestration-preimplementation-gate-helpers.ps1` per rule 6. Acceptance: the two new `docs/features/active/preimplementation-helpers-backslash-chain-operator-710/evidence/other/mirror-log.md` entries each record two equal SHA256 values.
- [ ] [P3-T3] Parity record (AC-6, AC-7): run R-DETECT. Write `docs/features/active/preimplementation-helpers-backslash-chain-operator-710/evidence/qa-gates/mirror-parity-sha256.md` (four schema fields) with the four `LINES:`, `SHA256:`, and `CR_PRESENT:` lines, `BYTE_IDENTICAL:`, `PRE_EDIT_LINE_COUNT:`, and `POST_EDIT_LINE_COUNT:`. Acceptance: `BYTE_IDENTICAL: True`; all four `LINES` values equal `PRE_EDIT_LINE_COUNT` and are at most 500; the four `SHA256` values are 64 hexadecimal characters and differ from the [P0-T5] value.
- [ ] [P3-T4] Parity and legacy contract run: R-SCOPED over `tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-helpers.Parity.Tests.ps1` and `tests/scripts/codex-hooks/legacy-codex-hook-contracts.Tests.ps1`. Write `docs/features/active/preimplementation-helpers-backslash-chain-operator-710/evidence/qa-gates/parity-and-legacy-contracts.md` (four schema fields) with the runner output. Acceptance: `EXIT_CODE: 0`; `FailedCount: 0`; `FailedBlocksCount: 0`; `FailedContainersCount: 0`; `PASSED:` lines end with `keeps all four surface copies of the helpers module byte-identical by SHA256 hash` and `keeps every surface copy of the helpers module under the 500-line cap`; a `PASSED:` line ends with `parse-checks each root and bundled hook and keeps every file within 500 lines`.
- [ ] [P3-T5] Commit the implementation per rule 7: `git add --` and `git commit -F <SCRATCHPAD>/commit-710-fix.txt --` with exactly the five paths 1 to 5 of section 2. Then run `git show --name-only --format= HEAD` and `git status --porcelain`, and append the commit SHA and both outputs (labelled `Porcelain (post-commit):`) to `docs/features/active/preimplementation-helpers-backslash-chain-operator-710/evidence/other/commits.md` (`Timestamp:` required). Acceptance: `git show --name-only --format= HEAD` lists exactly the five paths; the porcelain output lists no path outside the feature folder.

### Phase 4 — Scope Verification and Follow-Up Records

- [ ] [P4-T1] Record the D7 follow-up (AC-11): write `docs/features/active/preimplementation-helpers-backslash-chain-operator-710/evidence/other/follow-up-d7-operand-gap.md` with `Timestamp:`, `Title:` (`Unquoted .\. operand segments pass the staging exemption`), `Function:` (`Test-ExemptOrchestrationOperand` in `.claude/hooks/enforce-orchestration-preimplementation-gate-helpers.ps1` and its three copies), `Reproduction:` (the operand `docs/features/active/.\./.\./.\./src/x.ps1` in a `git add` command normalizes to `docs/features/active/./././././src/x.ps1`, which has no `..` segment, while bash removes the escapes and stages `src/x.ps1`; analytical, research section 8 D-b), `Candidate fixes:` (reject `.` segments as LACS L5 does at `Test-ExemptOrchestrationSelector`, or treat an unquoted backslash adjacent to `.` as unresolvable; to be confirmed test-first), `Relation to #710:` (not widened or closed; the scanner change does not alter tokenization or operand normalization), and `Filing route:` (a separate issue promoted through `mcp__drm-copilot__potential_to_issue` by the orchestrator; this plan runs no `gh issue create`). Acceptance: all seven labels present with non-empty values.
- [ ] [P4-T2] Record the sibling notice: write `docs/features/active/preimplementation-helpers-backslash-chain-operator-710/evidence/other/sibling-713-line-count-notice.md` with `Timestamp:`, `PRE_EDIT_LINE_COUNT:`, `POST_EDIT_LINE_COUNT:` (from [P2-T2]), and the statement that #710 changes only `Split-OrchestrationCommandLine` and leaves the helpers file line count unchanged, for the #713 planner. Acceptance: both counts present and equal.
- [ ] [P4-T3] Scope boundary (AC-7, AC-11): run `git diff --numstat BASE_SHA HEAD` and `git status --porcelain` (substituting `BASE_SHA`). Write `docs/features/active/preimplementation-helpers-backslash-chain-operator-710/evidence/qa-gates/scope-boundary.md` (four schema fields) with both outputs and the hunk headers recorded in [P2-T2]. Acceptance: the numstat output lists exactly the five section 2 paths 1 to 5, with `5` added and `5` deleted for each of the four helper copies; the porcelain output lists no path outside the feature folder; every helper hunk lies within the `Split-OrchestrationCommandLine` region, which proves that `Test-ExemptOrchestrationOperand`, `Test-OrchestrationCommandTextUnresolvable`, and `ConvertTo-OrchestrationCommandToken` are unchanged.

### Phase 5 — Final QC Loop

Run [P5-T1] to [P5-T8] in order. If any step fails or changes a tracked file, fix the cause, re-establish the Phase 2 and Phase 3 invariants (rerun [P2-T2], and [P3-T2] to [P3-T4] when a helper copy changed), record the fix as a new commit per rule 7 (no amend), and restart from [P5-T1]. Artifacts of an abandoned pass are kept and labelled with their pass number. The gate is one pass in which every step meets its acceptance and no tracked file changes.

- [ ] [P5-T1] Pre-loop state: run `git rev-parse HEAD` and `git status --porcelain`. Write `docs/features/active/preimplementation-helpers-backslash-chain-operator-710/evidence/qa-gates/final-preloop-state.md` (four schema fields) with the pass number and both outputs. Acceptance: the porcelain output lists no path outside the feature folder.
- [ ] [P5-T2] Format: record `git status --porcelain`; run R-FORMAT; record `git status --porcelain` again. Write `docs/features/active/preimplementation-helpers-backslash-chain-operator-710/evidence/qa-gates/final-poshqc-format.md` (four schema fields) with the pass number, the counts of lines beginning `Formatted: ` and `Already formatted: `, and a `Tree Delta:` section. Acceptance: `Formatted: ` count 0, `Already formatted: ` count greater than 0, and the two porcelain outputs identical.
- [ ] [P5-T3] Analyze: run R-ANALYZE. Write `docs/features/active/preimplementation-helpers-backslash-chain-operator-710/evidence/qa-gates/final-poshqc-analyze.md` (four schema fields). Acceptance: `EXIT_CODE: 0` and the output contains `PSScriptAnalyzer passed: no findings under`.
- [ ] [P5-T4] Scoped coverage run (coverage-mode test): R-COV over the 10 HRS files plus `tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-helpers.ChainEscape.Tests.ps1`. Write `docs/features/active/preimplementation-helpers-backslash-chain-operator-710/evidence/qa-gates/final-scoped-coverage.md` (four schema fields) with the four count lines, every `FAILED:` line (or `none`), both `LINE_COVERAGE:` lines, both `MISSED_LINES:` lines, and every `CHANGED_LINE:` line. Acceptance: `FailedBlocksCount: 0`; `FailedContainersCount: 0`; every `FAILED:` path is in `B_SCOPED` and none belongs to the ChainEscape, Parity, or legacy-codex suites (rule 9); 38 `PASSED:` lines contain `preimplementation gate helpers chain escapes`; both `percent=` values are at least 85; exactly four `CHANGED_LINE:` lines are printed, two per canonical copy, each reading `executed`.
- [ ] [P5-T5] Coverage delta: from [P0-T6] and [P5-T4], write `docs/features/active/preimplementation-helpers-backslash-chain-operator-710/evidence/qa-gates/final-coverage-delta.md` (`Timestamp:`, `Command:` naming both source artifacts, `EXIT_CODE: 0`, `Output Summary:`) with, for each canonical copy, the baseline percent and counters, the post percent and counters, and the changed-line coverage (executed `CHANGED_LINE` entries divided by all `CHANGED_LINE` entries, times 100). Acceptance: each post percent is at least 85 and at least its baseline percent; each changed-line coverage is 100 (two of two lines). PowerShell has no branch-coverage gate (`.claude/rules/powershell.md`). If a required value is unavailable, the task is remediation-required and is not checked.
- [ ] [P5-T6] Full Pester: run R-FULL script A, then script B. Write `docs/features/active/preimplementation-helpers-backslash-chain-operator-710/evidence/qa-gates/final-pester-full.md` (four schema fields) with the pass number, any console line beginning `Tests Passed:`, script B's root counts, every `JUNIT_FAILED:` line (or `none`), and the `JUNIT_SUITE:` lines for `tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-helpers.ChainEscape.Tests.ps1`, the 10 HRS files, and `tests/scripts/claude-runtime/test-name-uniqueness.Tests.ps1`. Acceptance: `JUNIT_LAST_WRITE_UTC:` at or after `Timestamp:`; every `JUNIT_FAILED:` entry is in `B_FULL` (rule 9); the ChainEscape suite row reads `tests=38 failures=0 errors=0`; the Parity, legacy-codex, and test-name-uniqueness rows read `failures=0 errors=0`.
- [ ] [P5-T7] Push-down contract suite: record `git status --porcelain --ignored -- .claude/state`, then run R-PYTEST. Write `docs/features/active/preimplementation-helpers-backslash-chain-operator-710/evidence/qa-gates/final-pytest-push-down.md` (four schema fields) with the status output, the summary line, and every failed node ID (or `none`). Acceptance: `EXIT_CODE: 0`, or the only failed node is `tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py::test_bundled_claude_payload_contains_all_repo_runtime_contracts`, it also failed in [P0-T10], and the artifact records `KNOWN_ISSUE_510`.
- [ ] [P5-T8] Seven-stage record: write `docs/features/active/preimplementation-helpers-backslash-chain-operator-710/evidence/qa-gates/final-seven-stage-loop.md` (`Timestamp:` required) mapping the stages: formatting [P5-T2]; linting [P5-T3]; type checking not applicable for PowerShell (`.claude/rules/powershell.md`); architecture-boundary tests not applicable (no dependency-cruiser or NetArchTest configuration governs PowerShell hooks); unit tests [P5-T4] and [P5-T6]; contract checks the Parity and legacy-codex testsuites inside [P5-T6] and [P5-T7]; integration tests the gate-level HRS suites inside [P5-T6]. Add a `Single-Pass Statement:` naming the pass number in which [P5-T1] to [P5-T7] met their acceptance with no tracked file changed. This task text authorizes the two not-applicable entries and no other. Acceptance: seven stage rows, each naming its task or its reason, and the `Single-Pass Statement:` section.

### Phase 6 — Acceptance-Criteria Check-Off and Close-Out

Each check-off task changes only the leading `- [ ]` to `- [x]` on the named line of `docs/features/active/preimplementation-helpers-backslash-chain-operator-710/spec.md` after confirming the named evidence, and appends one row (AC identifier, line, evidence paths, outcome) to `docs/features/active/preimplementation-helpers-backslash-chain-operator-710/evidence/other/ac-checkoff.md`. Acceptance for each: the named line begins `- [x] ` and its remaining text is identical to the [P0-T2] record; when any named evidence condition is not met, the line stays `- [ ]` and the row records the unmet condition.

- [ ] [P6-T1] AC-1 (spec line 206): in `qa-gates/pass-after-chain-escape.md` the names `treats a mid-line escaped semicolon as literal`, `treats an escaped ampersand as literal`, and `treats an escaped pipe as literal` are on `PASSED:` lines for both surfaces, and in `regression-testing/fail-before-chain-escape.md` the same names are on `FAILED:` lines for both surfaces. The row cites the `evidence/regression/` override record in the plan header.
- [ ] [P6-T2] AC-2 (spec line 207): `exempts a commit whose message contains an escaped semicolon` is on `PASSED:` lines for both surfaces in `qa-gates/pass-after-chain-escape.md` and on `FAILED:` lines in `regression-testing/fail-before-chain-escape.md`.
- [ ] [P6-T3] AC-3 (spec line 208): the five `still splits on unescaped` expansions are on `PASSED:` lines for both surfaces in `qa-gates/pass-after-chain-escape.md`, and the ChainEscape row in `qa-gates/final-pester-full.md` reads `failures=0 errors=0`.
- [ ] [P6-T4] AC-4 (spec line 209): `still splits after an escaped backslash`, `splits on the unescaped ampersand after an escaped one`, `keeps backslash literal inside single quotes`, and `does not exempt a chained command after an escaped backslash` are on `PASSED:` lines for both surfaces in `qa-gates/pass-after-chain-escape.md`.
- [ ] [P6-T5] AC-5 (spec line 210): `does not split after an odd run of backslashes`, `consumes an escaped double quote inside double quotes`, `does not open a quote on an unquoted escaped double quote`, `treats a trailing lone backslash as balanced`, and `treats backslash-newline as a line continuation` are on `PASSED:` lines for both surfaces in `qa-gates/pass-after-chain-escape.md`.
- [ ] [P6-T6] AC-6 (spec line 211): `qa-gates/mirror-parity-sha256.md` records `BYTE_IDENTICAL: True` with four equal SHA256 values; `qa-gates/parity-and-legacy-contracts.md` meets its acceptance; the Parity and legacy-codex rows in `qa-gates/final-pester-full.md` read `failures=0 errors=0`.
- [ ] [P6-T7] AC-7 (spec line 212): `qa-gates/canonical-edit-checks.md` records equal `PRE_EDIT_LINE_COUNT` and `POST_EDIT_LINE_COUNT` at most 500 and every hunk inside the `Split-OrchestrationCommandLine` region; `qa-gates/scope-boundary.md` meets its acceptance.
- [ ] [P6-T8] AC-8 (spec line 213): confirm the local clauses: the ChainEscape row in `qa-gates/final-pester-full.md` reads `tests=38 failures=0 errors=0` and `qa-gates/test-portability-inspection.md` meets its acceptance. The CI clause (the `.github/workflows/_poshqc.yml` job on `windows-latest`, D6) is outside this plan's execution scope, so this task leaves the AC-8 line as `- [ ]` and records `LOCAL_CLAUSES: MET` or `NOT MET` and `CI_CLAUSE: PENDING - the orchestrator checks off AC-8 after the ci.yml PoshQC job passes on the pull-request head`. Acceptance: the row carries both lines, and the AC-8 line is unchanged.
- [ ] [P6-T9] AC-9 (spec line 214): in `qa-gates/final-pester-full.md` the rows for `tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.CommandExemption.Tests.ps1`, `tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-command-exemption.Tests.ps1`, `tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.EpicScope.Tests.ps1`, `tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.TriggerScoping.Tests.ps1`, `tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-trigger-scoping.Tests.ps1`, `tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-mode-resolution.Tests.ps1`, and `tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-mode-routing.Tests.ps1` each read `failures=0 errors=0`. When a row carries a pre-existing failure (rule 9), the line stays `- [ ]` and the row lists the `B_FULL` names.
- [ ] [P6-T10] AC-10 (spec line 215): `qa-gates/final-poshqc-format.md`, `qa-gates/final-poshqc-analyze.md`, `qa-gates/final-scoped-coverage.md`, `qa-gates/final-coverage-delta.md`, and `qa-gates/final-pester-full.md` meet their acceptance in the single pass named by `qa-gates/final-seven-stage-loop.md`, and `qa-gates/final-pester-full.md` records `JUNIT_FAILURES: 0` and `JUNIT_ERRORS: 0`. The row cites the `evidence/coverage/` override record in the plan header. When the full run carries pre-existing failures, the line stays `- [ ]` and the row lists them.
- [ ] [P6-T11] AC-11 (spec line 216): `other/follow-up-d7-operand-gap.md` meets [P4-T1] acceptance and `qa-gates/scope-boundary.md` shows `Test-ExemptOrchestrationOperand` unchanged.
- [ ] [P6-T12] Write `docs/features/active/preimplementation-helpers-backslash-chain-operator-710/evidence/other/ac-status-summary.md` with `Source:`, `Total AC items:`, `Checked off (delivered):`, `Remaining (unchecked):`, and `Items remaining:` (each unchecked AC with its reason). Acceptance: `Total AC items: 11`, and the checked and remaining counts equal the counts of `- [x]` and `- [ ]` lines below `## Acceptance Criteria` in `spec.md`.
- [ ] [P6-T13] Final commit per rule 7: list the paths with `git status --porcelain -- docs/features/active/preimplementation-helpers-backslash-chain-operator-710/`, then `git add --` and `git commit -F <SCRATCHPAD>/commit-710-evidence.txt --` with exactly those paths (spec, plan with checklist state through [P6-T12], issue, research, and evidence). Append the SHA and a `Porcelain (post-commit):` observation to `docs/features/active/preimplementation-helpers-backslash-chain-operator-710/evidence/other/commits.md`, then commit that single path the same way. Acceptance: after the second commit, `git show --name-only --format= HEAD` lists exactly `docs/features/active/preimplementation-helpers-backslash-chain-operator-710/evidence/other/commits.md` and `git status --porcelain` lists no path. The [P6-T13] check-off is made after this verification and is the only change this plan leaves uncommitted.

---

## AC Traceability

| AC | Implementation | Tests | Evidence |
| --- | --- | --- | --- |
| AC-1 | [P2-T1] E1-E3, [P2-T3] | three escaped-operator names | `regression-testing/fail-before-chain-escape.md`, `qa-gates/pass-after-chain-escape.md` |
| AC-2 | [P2-T1], [P2-T3] | `exempts a commit whose message contains an escaped semicolon` | `regression-testing/fail-before-chain-escape.md`, `qa-gates/pass-after-chain-escape.md` |
| AC-3 | [P2-T1] (operator branch untouched) | five `still splits on unescaped` expansions | `qa-gates/pass-after-chain-escape.md`, `qa-gates/final-pester-full.md` |
| AC-4 | [P2-T1] pairwise consumption | four no-bypass names | `qa-gates/pass-after-chain-escape.md` |
| AC-5 | [P2-T1] | five quote-state and boundary names | `qa-gates/pass-after-chain-escape.md` |
| AC-6 | [P2-T3], [P3-T2] | Parity suite, legacy-codex contracts | `qa-gates/mirror-parity-sha256.md`, `qa-gates/parity-and-legacy-contracts.md`, `qa-gates/final-pester-full.md` |
| AC-7 | [P2-T1] (E1 offsets E3) | R-DETECT line and anchor checks | `qa-gates/canonical-edit-checks.md`, `qa-gates/scope-boundary.md` |
| AC-8 | [P1-T2] | ChainEscape suite, portability inspection | `qa-gates/final-pester-full.md`, `qa-gates/test-portability-inspection.md` (CI clause pending) |
| AC-9 | none (non-regression) | seven existing gate suites | `qa-gates/final-pester-full.md`, `qa-gates/batch1-command-exemption.md` |
| AC-10 | Phase 5 | full toolchain, R-COV | `qa-gates/final-poshqc-format.md`, `qa-gates/final-poshqc-analyze.md`, `qa-gates/final-scoped-coverage.md`, `qa-gates/final-coverage-delta.md`, `qa-gates/final-pester-full.md` |
| AC-11 | [P4-T1] record; no operand edit | scope-boundary hunk check | `other/follow-up-d7-operand-gap.md`, `qa-gates/scope-boundary.md` |
