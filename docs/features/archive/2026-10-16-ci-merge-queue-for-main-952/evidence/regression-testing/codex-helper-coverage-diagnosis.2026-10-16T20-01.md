# Codex helper coverage-attribution diagnosis (issue #952 R1, remediation cycle 2, P1-T6)

Timestamp: 2026-10-16T20-01
Command: git grep -l -E -e "Get-CodexMergeCommandPrNumber|Invoke-CodexEpicMergeDecision|HookRoot/enforce-epic-merge-gate.ps1|codex/hooks/enforce-epic-merge-gate" -- '*.Tests.ps1'; git grep -n -E -e "Get-CodexMergeCommandPrNumber|HookRoot/enforce-epic-merge-gate.ps1" -- tests/scripts/claude-hooks; Read of .codex/hooks/enforce-epic-merge-gate-command.ps1:23-32,45-47,64-72,86-93,107-111,131-137,158-189; .codex/hooks/enforce-epic-merge-gate.ps1:35,84; tests/scripts/codex-hooks/enforce-epic-merge-gate-command.Tests.ps1:56-59,66,72-80,88; tests/scripts/codex-hooks/enforce-epic-merge-gate-merge-queue.Tests.ps1:127,151-152,166,168; tests/scripts/codex-hooks/enforce-epic-merge-gate-trigger-scoping.Tests.ps1:75-76; tests/scripts/claude-hooks/hook-command-consumers.Issue824.Tests.ps1:22-25,36-39,87-108; scripts/powershell/PoshQC/settings/pester.runsettings.psd1:3,17-27; FEATURE/evidence/qa-gates/coverage-comparison.2026-10-16T17-08.md:17,19,26-29,37; FEATURE/evidence/qa-gates/ci-rows-windows.2026-10-16T17-08.md:8,31,39,40,61,63,65; FEATURE/evidence/qa-gates/ci-rows-linux.2026-10-16T17-08.md:22,24,25; FEATURE/remediation-inputs.2026-10-16T17-18.md:37,41-48; docs/features/active/2026-10-15-hook-coverage-attribution-gaps-936/research/2026-10-15T18-30-hook-coverage-attribution-research.md:21,24-25,57-61,63-96,97-134,173; docs/features/active/2026-10-15-hook-coverage-attribution-gaps-936/evidence/qa-gates/isolated-coverage-attribution.2026-10-16T01-28.md:6-17; docs/features/active/2026-10-15-hook-coverage-attribution-gaps-936/evidence/qa-gates/ci-coverage-attribution.2026-10-16T02-26.md:7-8; FEATURE/evidence/remediation-baseline/c2-shared-file-hashes.2026-10-16T19-37.md; FEATURE/evidence/regression-testing/c2-attribution-note-codex-after.2026-10-16T20-00.md
EXIT_CODE: 0
Gating: NONE
Output Summary:
R1_DISPOSITION=DOCUMENTED-ATTRIBUTION-LIMIT (issue #936 precedent; orchestrator decision D1)
CODEX_HELPER_LINE_R_FINAL_2=74.07
CLAUDE_HELPER_LINE_R_FINAL_2=100.00
HELPERS_BYTE_IDENTICAL=true
UNCOVERED_LINES=67,68,72,165,166,171,172,179,182,183,184,185,186,189
MAPPED_LINES=14/14
EARLIER_IN_PROCESS_CODEX_GATE_LOADERS=1
FIRST_COMPILING_SUITE=tests/scripts/claude-hooks/hook-command-consumers.Issue824.Tests.ps1 (codex row of the epic merge gate Describe, CN-09)
CN09_EXECUTED_HELPER_LINES=24 (all credited)
UNINVOKED_BY_CN09_FUNCTION_LINES=16 (all credited)
COVERAGE_MODE=BREAKPOINTS (no UseBreakpoints key in pester.runsettings.psd1; Pester 5.x default)
LOCAL_COVERAGE_RUN=NOT-PERFORMED (D1)
MECHANISM=LIKELY-NOT-VERIFIED (issue #936)
ATTRIBUTION_NOTE_CODEX_LOCAL=PASS

Both derivation commands exited 0 (outputs in section 4). This artifact gates nothing; it is the R1 documentation input to ORCH-R3 and the re-audit (ORCH-R4).

## 1. R1 disposition (D1) and remediation-inputs steps not applied

Under orchestrator decision D1 (`FEATURE/remediation-plan.2026-10-16T17-18.md`, Decisions Recorded by the Planner), this cycle follows the issue #936 precedent: the non-attribution is documented and the existing executing Codex rows are attached to it. Remediation-inputs R1 (`FEATURE/remediation-inputs.2026-10-16T17-18.md:41-48`) steps 1 to 3 are not applied:

- Step 1 (`:41`), the local `Invoke-Pester` discriminating run, cannot run in this session: the worktree-isolation guard refuses every PowerShell launcher invocation and no PowerShell tool is available. No scoped coverage run is recorded for this item.
- Step 2 (`:42-45`), the helper text differentiation or load-form change, is not applied; the helpers stay byte-identical.
- Step 3 (`:46`), the local >= 85% confirmation, depends on step 1 and is not performed.
- Step 4 (`:47`) remains satisfied: no coverage exclusion, threshold, function rename, `pester.runsettings.psd1`, `config/poshqc-coverage.json`, PoshQC module or `.github/workflows/_poshqc.yml` change.
- Step 5 (`:48`) is the orchestrator's CI dispatch and ORCH-R1 to ORCH-R3.

Quoted (`FEATURE/remediation-inputs.2026-10-16T17-18.md:37`, excerpt): "The ORCH-R3 hypothesis (hits credited to the first-loaded byte-identical Claude copy) is contradicted in its general form by the same report: `hook-docs-only-diff.ps1`, byte-identical in both runtimes (blob `7e429ae6c` at `fd1913a0d`), has Claude missed {189, 314, 358} and Codex missed {189, 217, 314}." ... "The mechanism is not established."

## 2. Line-to-row map (Appendix C.9)

Row keys: `CMD` = `tests/scripts/codex-hooks/enforce-epic-merge-gate-command.Tests.ps1` (post-P1-T3 line numbers; converter rows assert at `:66`, reader rows at `:88`); `MQ` = `tests/scripts/codex-hooks/enforce-epic-merge-gate-merge-queue.Tests.ps1` (post-P1-T2 line numbers); `TS` = `tests/scripts/codex-hooks/enforce-epic-merge-gate-trigger-scoping.Tests.ps1`.

### Codex helper lines (quoted from `.codex/hooks/enforce-epic-merge-gate-command.ps1`)

```powershell
67:    } elseif ($Selector -match '/pull/(\d+)/?(?:[?#].*)?$') {
68:        $digits = $Matches[1]
72:    return $null
165:                if ($index + 1 -lt $tokens.Count) { return ConvertFrom-EpicMergeGateSelector -Selector $tokens[$index + 1] }
166:                return $null
171:                    $equalsNumber = ConvertFrom-EpicMergeGateSelector -Selector $token.Substring($name.Length + 1)
172:                    if ($null -ne $equalsNumber) { return $equalsNumber }
179:        return $null
182:    foreach ($apiMatch in @(Get-CommandLineInvocation -CommandText $CommandText -CommandWord 'gh' -SubcommandPath @('api'))) {
183:        foreach ($token in @($apiMatch.Segment.Tokens)) {
184:            $rest = [regex]::Match([string]$token, $script:EpicMergeGateRestMergePattern)
185:            $number = 0
186:            if ($rest.Success -and [int]::TryParse($rest.Groups[1].Value, [ref] $number)) { return $number }
189:    return $null
```

### Executing row lines (quoted)

```powershell
CMD:56   @{ Selector = 'https://github.com/o/r/pull/5'; Expected = 5; Label = '5' }
CMD:57   @{ Selector = 'https://github.com/o/r/pull/5/?tab=checks'; Expected = 5; Label = '5' }
CMD:58   @{ Selector = 'feature-branch'; Expected = $null; Label = 'no number' }
CMD:59   @{ Selector = '99999999999'; Expected = $null; Label = 'no number' }
CMD:66   $number | Should -Be $Expected -Because "the selector $Selector resolves to $Label"
CMD:72   @{ Command = 'gh pr merge -- 5'; Expected = 5; Label = '5' }
CMD:73   @{ Command = 'gh pr merge --merge --'; Expected = $null; Label = 'no number' }
CMD:74   @{ Command = 'gh pr merge --merge=5'; Expected = 5; Label = '5' }
CMD:75   @{ Command = 'gh pr merge --merge=true 5'; Expected = 5; Label = '5' }
CMD:76   @{ Command = 'gh pr merge --merge'; Expected = $null; Label = 'no number' }
CMD:77   @{ Command = 'gh pr merge feature-branch --merge'; Expected = $null; Label = 'no number' }
CMD:78   @{ Command = 'gh api -X PUT repos/o/r/pulls/5/merge'; Expected = 5; Label = '5' }
CMD:79   @{ Command = 'gh api repos/o/r/pulls/5'; Expected = $null; Label = 'no number' }
CMD:80   @{ Command = 'git status'; Expected = $null; Label = 'no number' }
CMD:88   $prNumber | Should -Be $Expected -Because "the selector of $Command resolves to $Label"
MQ:127   @{ Name = 'a REST PUT to the pulls merge endpoint'; Expected = 'deny'; Command = 'gh api -X PUT repos/drmoisan/drm-copilot/pulls/5/merge' }
MQ:151   @{ Command = 'gh pr merge https://github.com/o/r/pull/5 --merge' }
MQ:152   @{ Command = 'gh api -X PUT repos/o/r/pulls/5/merge' }
MQ:166   @{ Command = 'gh pr merge https://github.com/drmoisan/drm-copilot/pull/5 --merge'; Expected = 'allow'; Token = '' }
MQ:168   @{ Command = 'gh api -X PUT repos/drmoisan/drm-copilot/pulls/5/merge'; Expected = 'allow'; Token = '' }
TS:75    It 'returns null for a bare gh pr merge --merge that names no PR number' {
TS:76        Get-CodexMergeCommandPrNumber -Command 'gh pr merge --merge' | Should -BeNullOrEmpty
```

Every cited row line carries the row data stated in Appendix C.9.

### Map

| Codex helper line | Executing rows (suite:line, row data) | Assertion that requires the line |
|---|---|---|
| 67 | CMD:56 `https://github.com/o/r/pull/5`; CMD:57 `https://github.com/o/r/pull/5/?tab=checks`; MQ:151 reader `gh pr merge https://github.com/o/r/pull/5 --merge`; MQ:166 decision with record, URL selector; condition evaluated, no match: CMD:58 `feature-branch`, CMD:75 `gh pr merge --merge=true 5`, CMD:77 `gh pr merge feature-branch --merge` | CMD:56-57 expect 5; a URL selector yields digits only through the `elseif` at 67 and the assignment at 68 |
| 68 | CMD:56; CMD:57; MQ:151; MQ:166 | same as 67 |
| 72 | CMD:58 `feature-branch`; CMD:59 `99999999999`; CMD:77 `gh pr merge feature-branch --merge`; CMD:75 `gh pr merge --merge=true 5` (row (h); the `--merge=true` value returns no number through 72 and the row's 5 comes from the next token) | CMD:58, CMD:59 and CMD:77 each expect no number; for those inputs 72 is the only return statement reached |
| 165 | CMD:72 `gh pr merge -- 5`; CMD:73 `gh pr merge --merge --` (condition evaluated, false) | expects 5; after a bare `--` the selector is returned only by 165 |
| 166 | CMD:73 `gh pr merge --merge --` | expects no number; a trailing bare `--` returns only through 166 |
| 171 | CMD:74 `gh pr merge --merge=5`; CMD:75 `gh pr merge --merge=true 5` (row (h)) | 171 runs for every equals-joined `--merge=` value |
| 172 | CMD:74 `gh pr merge --merge=5`; CMD:75 `gh pr merge --merge=true 5` (row (h); condition evaluated, no return) | expects 5; an equals-joined number is returned only by 172 |
| 179 | CMD:76 `gh pr merge --merge`; TS:75-76 `gh pr merge --merge` through the Codex gate reader | each expects no number; the token loop ends without a selector only at 179 |
| 182 | CMD:78 `gh api -X PUT repos/o/r/pulls/5/merge`; CMD:79 `gh api repos/o/r/pulls/5`; CMD:80 `git status`; MQ:152 REST reader; MQ:127 REST decision; MQ:168 REST decision with record | every non-`gh pr merge` command reaches the `gh api` loop header at 182 |
| 183-186 | CMD:78; CMD:79; MQ:152; MQ:127; MQ:168 | CMD:78 and MQ:152 expect 5, returned only by 186 after 183-185 match the REST token |
| 189 | CMD:79 `gh api repos/o/r/pulls/5`; CMD:80 `git status` | each expects no number; with no `gh pr merge` match and no REST merge token the reader returns only at 189 |

All 14 uncovered lines are mapped (`MAPPED_LINES=14/14`).

### R_final_2 38933561015 results for the executing suites

- Windows (`FEATURE/evidence/qa-gates/ci-rows-windows.2026-10-16T17-08.md`):
  - `:8` "R_final_2=38933561015 event=workflow_dispatch headSha=fd1913a0d1d555959edca41289fc38ace1c5d439 conclusion=success; jobs 17 of 17 success"
  - `:40` CMD "tests/scripts/codex-hooks/enforce-epic-merge-gate-command.Tests.ps1 | 15 | 0 | 15 | PASS" (15 passed, 0 failed)
  - `:39` MQ "tests/scripts/codex-hooks/enforce-epic-merge-gate-merge-queue.Tests.ps1 | 35 | 0 | 35 | PASS" (35, 0)
  - `:31` TS "tests/scripts/codex-hooks/enforce-epic-merge-gate-trigger-scoping.Tests.ps1 | 8 | 0 | 8 | PASS" (8, 0)
  - `:61` row (g) "resolves the selector helper functions from the Codex helper file" PASS
  - `:63` row (h) "returns 5 for gh pr merge --merge=true 5" (command suite) PASS
  - `:65` row (j) "converts https://github.com/o/r/pull/5 to 5" PASS
- Linux (`FEATURE/evidence/qa-gates/ci-rows-linux.2026-10-16T17-08.md`): `:25` CMD 15, 0; `:24` MQ 35, 0; `:22` TS 8, 0.

## 3. Claude helper result on the same run and byte identity

- `coverage-comparison.2026-10-16T17-08.md:17`: ".claude/hooks/enforce-epic-merge-gate-command.ps1 | NEW | 100.00 | 54 | 54 | 100.00 | PASS".
- `:28` `CLAUDE_HELPER_COVERED_LINES` lists all 54 measured lines, including all 14 Codex-uncovered lines; `:29` `CLAUDE_HELPER_UNCOVERED_LINES=` (empty).
- `:19` ".codex/hooks/enforce-epic-merge-gate-command.ps1 | NEW | 74.07 | 54 | 40 | 74.07 | FAIL"; `:26` covered set (40 lines); `:27` `CODEX_HELPER_UNCOVERED_LINES=67,68,72,165,166,171,172,179,182,183,184,185,186,189`.
- Byte identity: `c2-shared-file-hashes.2026-10-16T19-37.md` records `HELPER_COPIES_EQUAL=4/4 HELPER_BASE_HASH=94d2145cddf4f2a2ea00133216df715e52be38d5` for the Claude helper, the Codex helper and both bundle mirrors.

## 4. Derivation of the earlier compiling suite (D2)

Command 1 (EXIT_CODE 0), output verbatim:

```text
tests/scripts/claude-hooks/hook-command-consumers.Issue824.Tests.ps1
tests/scripts/codex-hooks/codex-epic-runtime-contracts.Tests.ps1
tests/scripts/codex-hooks/enforce-epic-merge-gate-authorization.Tests.ps1
tests/scripts/codex-hooks/enforce-epic-merge-gate-command.Tests.ps1
tests/scripts/codex-hooks/enforce-epic-merge-gate-decision-surface.Tests.ps1
tests/scripts/codex-hooks/enforce-epic-merge-gate-docs-only.Tests.ps1
tests/scripts/codex-hooks/enforce-epic-merge-gate-merge-queue.Tests.ps1
tests/scripts/codex-hooks/enforce-epic-merge-gate-trigger-scoping.Tests.ps1
tests/scripts/codex-hooks/epic-execution-gates.Tests.ps1
tests/scripts/codex-hooks/hook-dependency-failure.Codex.Tests.ps1
```

Command 2 (EXIT_CODE 0), output verbatim:

```text
tests/scripts/claude-hooks/hook-command-consumers.Issue824.Tests.ps1:90:        . (Join-Path $script:RepoRoot "$HookRoot/enforce-epic-merge-gate.ps1")
tests/scripts/claude-hooks/hook-command-consumers.Issue824.Tests.ps1:104:            Get-CodexMergeCommandPrNumber -Command $Command
```

Exactly one test file outside `tests/scripts/codex-hooks` loads the Codex gate in-process (`EARLIER_IN_PROCESS_CODEX_GATE_LOADERS=1`). Quoted lines of that file:

```powershell
22:    $script:Runtimes = @(
23:        @{ Runtime = 'claude'; HookRoot = '.claude/hooks' }
24:        @{ Runtime = 'codex'; HookRoot = '.codex/hooks' }
25:    )
36:    $script:MergeRows = @(
37:        @{ Command = 'gh pr merge --merge 688' }
38:        @{ Command = 'bash -c "gh pr merge --merge 688"' }
39:    )
87: Describe 'epic merge gate consumer rows, <Runtime> copy (issue #824)' -ForEach $script:Runtimes {
90:        . (Join-Path $script:RepoRoot "$HookRoot/enforce-epic-merge-gate.ps1")
100:    It 'CN-09 reads pull request 688 from <Command>' -Tag 'Issue824' -ForEach $script:MergeRows {
104:            Get-CodexMergeCommandPrNumber -Command $Command
106:        $number | Should -Be 688
```

The Codex gate dot-sources the helper from its own directory and its reader delegates to the helper:

```powershell
.codex/hooks/enforce-epic-merge-gate.ps1:35  try { . (Join-Path $PSScriptRoot 'enforce-epic-merge-gate-command.ps1') } catch { Add-HookDependencyFailure -Name 'enforce-epic-merge-gate-command.ps1' -ErrorRecord $_ }
.codex/hooks/enforce-epic-merge-gate.ps1:84      return Get-EpicMergeGateSelectorPrNumber -CommandText $Command
```

Run order: `scripts/powershell/PoshQC/settings/pester.runsettings.psd1:3` reads `        Path = @('scripts', 'tests/powershell', 'tests/scripts')`; within `tests/scripts` the `claude-hooks` folder runs before the `codex-hooks` folder, with the `claude-lib` tree in between (issue #936 research `:57-61`, which records the job-log order: a `claude-hooks` suite at 15:41:28, the `claude-lib` tree at log lines 1173-1237, and the `codex-hooks` suites about eight minutes later). The first compilation of the Codex helper in a CI run is therefore the codex row of the CN-09 Describe (`FIRST_COMPILING_SUITE`).

## 5. Line partition against CN-09 (D2; planner inference)

The Codex helper has 54 measured lines (`coverage-comparison.2026-10-16T17-08.md:26-27`). Quoted helper lines used by the partition:

```powershell
23: $script:EpicMergeGateActionFlags = @('--merge', '-m', '--squash', '-s', '--rebase', '-r', '--auto', '--admin')
26: $script:EpicMergeGateValueFlags = @('-b', '--body', '-F', '--body-file', '-t', '--subject', '-A', '--author-email', '--match-head-commit', '-R', '--repo')
29: $script:EpicMergeGateMutationNames = @('enqueuePullRequest', 'enablePullRequestAutoMerge', 'mergePullRequest')
32: $script:EpicMergeGateRestMergePattern = '(?:^|/)pulls/(\d+)/merge(?:$|[^\w-])'
45:     $split = $Token.IndexOf('=')
46:     if ($split -gt 0) { return $Token.Substring(0, $split) }
47:     return $Token
64:     $digits = $null
65:     if ($Selector -match '^\d+$') {
66:         $digits = $Selector
70:     $number = 0
71:     if ($null -ne $digits -and [int]::TryParse($digits, [ref] $number)) { return $number }
86:     $tokens = [string[]]@($Match.Segment.Tokens)
87:     $hasDisableAuto = $false
88:     for ($index = $Match.OperandIndex; $index -lt $tokens.Count; $index++) {
89:         $name = Get-EpicMergeGateFlagName -Token $tokens[$index]
90:         if ($script:EpicMergeGateActionFlags -ccontains $name) { return $false }
91:         if ($name -ceq '--disable-auto') { $hasDisableAuto = $true }
93:     return $hasDisableAuto
107:     if ([string]::IsNullOrEmpty($Text)) { return $false }
108:     foreach ($name in $script:EpicMergeGateMutationNames) {
109:         if ($Text.IndexOf($name, [System.StringComparison]::OrdinalIgnoreCase) -ge 0) { return $true }
111:     return [regex]::IsMatch($Text, $script:EpicMergeGateRestMergePattern)
131:     foreach ($match in @(Get-CommandLineInvocation -CommandText $CommandText -CommandWord 'gh' -SubcommandPath @('pr', 'merge'))) {
132:         if ($match.Status -ne 'Structural' -or -not (Test-EpicMergeGateDisableAutoOnly -Match $match)) { return $true }
134:     foreach ($match in @(Get-CommandLineInvocation -CommandText $CommandText -CommandWord 'gh' -SubcommandPath @('api'))) {
135:         if (Test-EpicMergeGateApiMutationText -Text (@($match.Segment.Tokens) -join ' ')) { return $true }
137:     return $false
158:     $match = Get-CommandLineStructuralMatch -CommandText $CommandText -CommandWord 'gh' -SubcommandPath @('pr', 'merge')
159:     if ($null -ne $match) {
160:         $tokens = [string[]]@($match.Segment.Tokens)
161:         $index = $match.OperandIndex
162:         while ($index -lt $tokens.Count) {
163:             $token = $tokens[$index]
164:             if ($token -ceq '--') {
168:             if ($token.StartsWith('-') -and $token.Length -gt 1) {
169:                 $name = Get-EpicMergeGateFlagName -Token $token
170:                 if ($name -ceq '--merge' -and $token.Length -gt $name.Length) {
174:                 $index += if ($script:EpicMergeGateValueFlags -ccontains $token) { 2 } else { 1 }
175:                 continue
177:             return ConvertFrom-EpicMergeGateSelector -Selector $token
```

Partition (each set derived by the planner and confirmed here against the quoted text and the R_final_2 covered and uncovered sets):

1. 24 lines executed by CN-09 (`gh pr merge --merge 688`, both rows), all credited (`CN09_EXECUTED_HELPER_LINES=24`): script-level 23, 26, 29, 32; `Get-EpicMergeGateFlagName` 45, 46, 47; `ConvertFrom-EpicMergeGateSelector` 64, 65, 66, 70, 71; `Get-EpicMergeGateSelectorPrNumber` 158, 159, 160, 161, 162, 163, 164, 168, 169, 170, 174, 177. CN-09 skips `--merge` (168-170, 174) and returns 688 through 177 and the all-digit converter path (64-66, 70-71); line 175 is not in the measured set.
2. 14 lines not executed by CN-09 inside the two functions it invokes (`ConvertFrom-EpicMergeGateSelector`, `.codex/hooks/enforce-epic-merge-gate-command.ps1:50-73`; `Get-EpicMergeGateSelectorPrNumber`, `:140-190`), all uncredited: 67, 68, 72, 165, 166, 171, 172, 179, 182, 183, 184, 185, 186, 189. This set equals `CODEX_HELPER_UNCOVERED_LINES`.
3. 16 lines in the three functions CN-09 never invokes, all credited (`UNINVOKED_BY_CN09_FUNCTION_LINES=16`): `Test-EpicMergeGateDisableAutoOnly` (`:75-94`) 86-91, 93; `Test-EpicMergeGateApiMutationText` (`:96-112`) 107, 108, 109, 111; `Test-EpicMergeGateCommandInScope` (`:114-138`) 131, 132, 134, 135, 137. Only `tests/scripts/codex-hooks` suites invoke these functions on the Codex copy.

24 + 14 + 16 = 54. The partition is consistent with issue #936 research step 5 (`:71`: "Nested scriptblock bodies, such as epic-scope line 201, compile lazily and stay pending until they first run, so they bind correctly even in a later instance") if function bodies also compile at first invocation: the functions first invoked by the later Codex suites are fully credited, while the lines of the functions first compiled by CN-09 are credited only where CN-09 executed them. That extension from nested scriptblocks to function bodies is a planner inference and is not verified.

## 6. The issue #936 mechanism and its status

Mechanism (issue #936 research `:63-96`, quoted in part):

- `:65` "### Mechanism (shared by all three gaps); status: likely, not experimentally verified"
- `:67` "CI uses breakpoint-based coverage. `UseBreakpoints` is unset and defaults to `$true` in Pester 5.x. `SingleHitBreakpoints` defaults to `$true`. Breakpoints are set once, before the tests run (log line 1006)."
- `:68` "PowerShell binds a pending line breakpoint to the sequence points of the first compiled instance of the file that is entered and contains that line. It then removes the breakpoint from the pending set ..."
- `:70` "... The whole cache is cleared once it holds more than 1024 entries ... After a clear, the next dot-source parses and compiles a new instance with no breakpoints bound to it."
- `:71` "Consequence: a line that the first compiled instance never executes keeps an orphaned breakpoint. A later suite that executes it in a new instance produces no hit. ..."
- `:75` "No experiment has shown that a cache clear (or another recompilation) actually happens between 15:41:28 and 15:49:39 in the CI run. That link is the unverified part of the chain."

Coverage mode in this repository: `scripts/powershell/PoshQC/settings/pester.runsettings.psd1:17-27` (quoted in full in `FEATURE/policy-followups.md` Record 4) sets `Enabled`, `OutputFormat`, `OutputPath` and `CoveragePercentTarget` and no `UseBreakpoints` key. Issue #936 research `:21` records "It has no `Path` and no `UseBreakpoints` key (a repository-wide Grep for `UseBreakpoints` outside `docs/` returned no match)"; `:24-25` record the Pester 5.x default (`UseBreakpoints` true) and that both pinned and observed Pester versions are 5.x, "so breakpoint mode is the default either way" (`COVERAGE_MODE=BREAKPOINTS`).

Issue #936 supporting evidence:

- `isolated-coverage-attribution.2026-10-16T01-28.md:6-17`: in a coverage run scoped to `tests/scripts/codex-hooks`, modes line 41 and epic-scope lines 183, 190, 191, 201, 206, 207 and 209 were `ci=1 ATTRIBUTED` (`REQUIRED-ATTRIBUTED=True`).
- `ci-coverage-attribution.2026-10-16T02-26.md:7-8`: "KNOWN-EXCEPTION: full-run breakpoint attribution (issue #936)" ... "The `.codex/hooks` package `<line>` elements for the three AC-5 lines read ci=0 in the full CI run, which is the documented breakpoint-binding exception."

No scoped coverage run was performed for this item (`LOCAL_COVERAGE_RUN=NOT-PERFORMED (D1)`), so the mechanism is not verified for the Codex helper (`MECHANISM=LIKELY-NOT-VERIFIED`). Issue #936 research `:173` notes that such non-attribution "depends on run order and cache occupancy", so a future `ci` value on these lines is not by itself a regression signal.

## 7. D3 observations

(a) Identity counterexample (CR-14). `hook-docs-only-diff.ps1` is byte-identical in both runtimes (`DOCS_ONLY_BASE_HASH=7e429ae6cc216ee91968ab921572d78638f9b976`, four copies), yet on R_final_2 the Claude copy missed {189, 314, 358} and the Codex copy missed {189, 217, 314} (`FEATURE/remediation-inputs.2026-10-16T17-18.md:37`). Byte identity alone therefore does not explain the Codex helper result.

(b) Load form. The trigger-scoping suite loads the Codex gate in the `Join-Path` form, and its case at `TS:75-76` (quoted in section 2) reaches helper line 179, which is uncredited on R_final_2. The load form therefore does not explain the result either; under D2 neither (a) nor (b) is expected to.

(c) Correction of the cycle-1 cause statement. `coverage-comparison.2026-10-16T17-08.md:37` states: "Pester's tracer keys hits by the executing statement's extent file (`Pester.psm1` `Start-TraceScript` and `Get-CoverageReport`), so if PowerShell reuses compiled statement data across two files with identical text, every hit lands on the first-compiled copy. This is a hypothesis; it has not been verified directly." CI does not use the profiler tracer: it runs in breakpoint mode because `pester.runsettings.psd1:17-27` sets no `UseBreakpoints` key (issue #936 research `:21`, `:24-25`). That statement is superseded by the issue #936 mechanism.

## 8. Rejected alternatives and the operator question

Issue #936 research `:122-133` rejected: setting `CodeCoverage.UseBreakpoints = $false` as the minimal fix (it changes measurement for every file in the population and for extension consumers, Pester 5.x labels it experimental, and it may affect the PoshQC coverage suites; retained as an operator question, `:130`); adding another full-run test (`:131`); reordering suites or making the first-compiling suite execute the lines (`:132`); and manipulating Pester breakpoints from a test (`:133`). The same alternatives are not applied here. The operator question is recorded as Record 4 of `FEATURE/policy-followups.md`.

## 9. Scope statement

For R1, this cycle makes no coverage exclusion, threshold change, workflow change, production edit, or edit to the PoshQC settings (`scripts/powershell/PoshQC/settings/pester.runsettings.psd1` and its mirror) or `config/poshqc-coverage.json`. The only R1 edits are the `.DESCRIPTION` notes in `tests/scripts/codex-hooks/enforce-epic-merge-gate-command.Tests.ps1` and `tests/scripts/codex-hooks/enforce-epic-merge-gate-merge-queue.Tests.ps1`, the row (g) comment rewording (CR-13), this artifact, and Record 4. Local test result after the edits: `ATTRIBUTION_NOTE_CODEX_LOCAL=PASS` (`c2-attribution-note-codex-after.2026-10-16T20-00.md`). ORCH-R3 records the R_final_3 value and disposition; the R1 disposition is decided by the re-audit (ORCH-R4).
