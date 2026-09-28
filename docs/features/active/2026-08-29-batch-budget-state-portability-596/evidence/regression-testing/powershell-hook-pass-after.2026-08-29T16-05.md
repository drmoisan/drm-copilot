# [P2-T6] enforce-powershell-batch-budget.Tests.ps1 — pass-after evidence

Timestamp: 2026-08-29T16-05

Command: two commands, run in this order from the repository root of the executing worktree. The
Form A command is character-for-character the same one [P2-T3] ran.

1. Form A, scoped:
   `pwsh -NoProfile -Command "Import-Module ./scripts/powershell/PoshQC/PoshQC.psd1 -Force; Invoke-PoshQCTest -Root (Get-Location).Path -SettingsPath 'scripts/powershell/PoshQC/settings/pester.runsettings.psd1' -ScanFolders 'tests/scripts/claude-hooks/enforce-powershell-batch-budget.Tests.ps1'"`
2. Form B:
   `pwsh -NoProfile -Command '[xml]$junit = Get-Content -LiteralPath "artifacts/pester/pester-junit.xml" -Raw; $root = $junit.SelectSingleNode("/*"); "root={0} tests={1} failures={2}" -f $root.Name, $root.GetAttribute("tests"), $root.GetAttribute("failures"); $junit.SelectNodes("//testcase[failure]") | ForEach-Object { $_.name }'`

EXIT_CODE: 0

Both commands exited 0. The Form A run returned normally rather than through Pester's failure exit,
so no blocked branch applies and the JUnit result file was written before the replayed summary.

Output Summary: All **33 of 33** tests in the suite pass, with a failed count of 0. The Form B
`failures` attribute is **0**. All ten `It` titles from [P2-T2] are present among the Form B
`testcase` names, alongside all 19 pre-existing Describe-level tests and all 4 pre-existing
entry-point tests. Per-file LINE coverage for `.claude/hooks/enforce-powershell-batch-budget.ps1` is
**93.8 percent**, above the 85 percent floor and 1.8 points below its 95.6 percent baseline.

## Verbatim Form A console output

```
Starting discovery in 1 files.
Discovery found 33 tests in 151ms.
Starting code coverage.
Running tests.
[+] C:\Users\DanMoisan\repos\drm-copilot\.claude\worktrees\agent-add102e7ba6e997d5\tests\scripts\claude-hooks\enforce-powershell-batch-budget.Tests.ps1 879ms (414ms|336ms)
Tests completed in 890ms
Tests Passed: 33, Failed: 0, Skipped: 0, Inconclusive: 0, NotRun: 0
Processing code coverage result.
Covered 2.61% / 0%. 10,632 analyzed Commands in 88 Files.
Wrote Koverage coverage copy: C:\Users\DanMoisan\repos\drm-copilot\.claude\worktrees\agent-add102e7ba6e997d5\artifacts\pester\powershell-coverage.koverage.xml
```

ANSI colour escape sequences present in the raw console stream have been removed from the block
above; no other character was altered.

## The replayed summary line and its five counts

Quoted verbatim: `Tests Passed: 33, Failed: 0, Skipped: 0, Inconclusive: 0, NotRun: 0`

| Count | Value |
| --- | --- |
| Passed | 33 |
| **Failed** | **0** |
| Skipped | 0 |
| Inconclusive | 0 |
| NotRun | 0 |

The failed count is 0, as this task requires.

## Verbatim Form B output

```
root=Pester tests=33 failures=0
```

The `//testcase[failure]` node set is empty, so the command emitted no test names after the summary
line. Form B `failures` count: **0**.

## The ten `It` titles from [P2-T2], confirmed present

All ten appear in the complete `//testcase` name enumeration of the same result file, each under the
`session identity, containment, and rehydrate filter` Context segment. Because the
`//testcase[failure]` node set is empty, none carries a `failure` child.

```
enforce-powershell-batch-budget.ps1.session identity, containment, and rehydrate filter.composes the state-file name from CLAUDE_SESSION_ID when the environment supplies it
enforce-powershell-batch-budget.ps1.session identity, containment, and rehydrate filter.composes the state-file name from the session-id state file when the environment is empty
enforce-powershell-batch-budget.ps1.session identity, containment, and rehydrate filter.composes a worktree-derived state-file name when both sources are empty
enforce-powershell-batch-budget.ps1.session identity, containment, and rehydrate filter.composes pairwise different state-file names across the three session sources
enforce-powershell-batch-budget.ps1.session identity, containment, and rehydrate filter.sanitizes a hostile session id into the state-file name pattern
enforce-powershell-batch-budget.ps1.session identity, containment, and rehydrate filter.records a relative candidate path
enforce-powershell-batch-budget.ps1.session identity, containment, and rehydrate filter.records an absolute candidate path under the resolved root
enforce-powershell-batch-budget.ps1.session identity, containment, and rehydrate filter.discards an absolute candidate path outside the resolved root
enforce-powershell-batch-budget.ps1.session identity, containment, and rehydrate filter.records an in-root absolute path that differs from the root only in letter case
enforce-powershell-batch-budget.ps1.session identity, containment, and rehydrate filter.admits three in-root production files when the persisted state already holds an out-of-root entry
```

## The pre-existing tests of the same suite, confirmed present and green

The 23 tests that existed before [P2-T2] are all present and all pass. This is what establishes that
the [P2-T4] edit preserved the four scriptblock seams, the `-SessionId` and `-Root` parameter names
and positions, the deny-envelope shape, and exit code 0 on every path.

```
enforce-powershell-batch-budget.ps1.allows a new production file under the production cap and records it
enforce-powershell-batch-budget.ps1.allows PowerShell module and data files as production files
enforce-powershell-batch-budget.ps1.allows a new Pester test file under the test cap and records it
enforce-powershell-batch-budget.ps1.allows repeated file edits without consuming another slot
enforce-powershell-batch-budget.ps1.denies a new production file when the production cap is full
enforce-powershell-batch-budget.ps1.denies a new test file when the test cap is full
enforce-powershell-batch-budget.ps1.serializes the deny decision into the PreToolUse hookSpecificOutput envelope
enforce-powershell-batch-budget.ps1.ignores non-PowerShell file paths
enforce-powershell-batch-budget.ps1.uses loaded state when evaluating session budget
enforce-powershell-batch-budget.ps1.denies an empty payload as an envelope anomaly (fail closed)
enforce-powershell-batch-budget.ps1.denies the legacy flat root shape as a missing-tool_input anomaly
enforce-powershell-batch-budget.ps1.allows a well-formed tool_input carrying no file_path (scope filter)
enforce-powershell-batch-budget.ps1.denies malformed tool-input JSON with a diagnostic before touching state
enforce-powershell-batch-budget.ps1.allows valid non-PowerShell tool input without touching state
enforce-powershell-batch-budget.ps1.writes state for valid PowerShell tool input through injected state operations
enforce-powershell-batch-budget.ps1.loads existing state through injected state operations
enforce-powershell-batch-budget.ps1.continues when injected state read and write operations fail
enforce-powershell-batch-budget.ps1.denies a nested envelope naming a PowerShell file once the production cap is full (AC-7)
enforce-powershell-batch-budget.ps1.reads the payload through the shared reader at the entry point
enforce-powershell-batch-budget.ps1.entry-point dispatch.returns exit code 0 and emits nothing for an allowed non-PowerShell path (deny-only convention)
enforce-powershell-batch-budget.ps1.entry-point dispatch.returns exit code 0 and emits a deny decision with no state property for an empty payload
enforce-powershell-batch-budget.ps1.entry-point dispatch.returns exit code 0 and emits a deny decision when ToolInputRaw is omitted and the ReadPayload seam is empty
enforce-powershell-batch-budget.ps1.entry-point dispatch.returns exit code 0 for malformed JSON with non-default session and cap environment variables set
```

Of particular note, `writes state for valid PowerShell tool input through injected state operations`
still asserts `$script:writtenStateFile | Should -BeLike '*powershell-batch-budget.session-a.json'`
and still passes. That confirms an explicit `-SessionId` argument continues to win over every other
session source, which is the property that keeps the pre-existing suite green after the resolution
order was introduced.

## Coverage observation for the [P2-T4] edit

Form C, run against `artifacts/pester/powershell-coverage.xml` produced by this scoped run:

```
REPO LINE covered=191 missed=7491
.claude/hooks/enforce-powershell-batch-budget.ps1 LINE covered=121 missed=8
.claude/hooks/enforce-python-batch-budget.ps1 LINE covered=0 missed=90
.claude/hooks/persist-session-id.ps1 LINE covered=0 missed=42
```

| File | Covered | Missed | LINE percent | Baseline | Delta |
| --- | --- | --- | --- | --- | --- |
| `.claude/hooks/enforce-powershell-batch-budget.ps1` | 121 | 8 | **93.8** | 95.6 | **-1.8** |

Derivation: `100 * 121 / (121 + 8) = 93.798…`, recorded to one decimal place as 93.8.

The file remains **8.8 points above the 85 percent floor**, so no coverage gate is breached. The
decline is nonetheless recorded here rather than left for [P7-T12] to discover.

The measurable line count rose from 90 at baseline to 129, because [P2-T4] added the containment
helper, the sanitizer, and the session-id resolver. The 8 uncovered lines are:

| Line | Source | Origin |
| --- | --- | --- |
| 79 | `return $false` — the empty-or-whitespace candidate guard in `Test-PowerShellBatchBudgetPathInRoot` | new |
| 89 | `return $true` — the empty-root guard in `Test-PowerShellBatchBudgetPathInRoot` | new |
| 154 | `Write-Verbose "Ignoring unreadable session-id file ..."` | new |
| 155 | `$fromFile = ''` in the same catch block | new |
| 452 | `$entryPointResult = @(Invoke-PowerShellBatchBudgetEntryPoint)` | pre-existing |
| 453 | `if ($entryPointResult.Count -gt 1) {` | pre-existing |
| 454 | `$entryPointResult[0..($entryPointResult.Count - 2)] \| Write-Output` | pre-existing |
| 457 | `exit ([int]$entryPointResult[-1])` | pre-existing |

Four of the eight are the pre-existing thin entry-point wiring, which the suite cannot reach because
the file is dot-sourced and the `$MyInvocation.InvocationName -eq '.'` guard returns before it. Those
four account for the whole of the baseline's 4-line shortfall. The four new uncovered lines are
defensive guards on the two degenerate inputs and the unreadable-file path; none of the ten tests
[P2-T2] fixes exercises them, and this plan authorizes no eleventh test, so they are reported rather
than covered.

The Python hook and `persist-session-id.ps1` read 0 covered above because this run was **scoped** to
the PowerShell batch-budget suite and their own suites did not execute. Those zeros are an artefact
of the scan scope, not a coverage regression; `persist-session-id.ps1` measured 88.1 percent in its
own scoped run at [P1-T6]. The repository-wide figures come from the unscoped run at [P7-T12].
