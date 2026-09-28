# Python hook suite — final QA gate ([P5-T6])

Timestamp: 2026-08-30T01-41
Task: [P5-T6]
Loop iteration: 1

All four commands were executed with the working directory set to the absolute worktree path
`C:/Users/DanMoisan/repos/drm-copilot/.claude/worktrees/agent-add102e7ba6e997d5`. The plan's command
text is worktree-relative and is reproduced verbatim below; the absolute prefix used was a `cd` into
that path ahead of each command.

This task runs after [P5-T5] because each Form A invocation overwrites
`artifacts/pester/powershell-coverage.xml` and `artifacts/pester/pester-junit.xml`. [P5-T5] recorded
its numbers into its own artifact before this task ran.

## Form A — scoped Pester run

Command (plan text, verbatim, with `<suite>` substituted as the task directs):

```
pwsh -NoProfile -Command "Import-Module ./scripts/powershell/PoshQC/PoshQC.psd1 -Force; Invoke-PoshQCTest -Root (Get-Location).Path -SettingsPath 'scripts/powershell/PoshQC/settings/pester.runsettings.psd1' -ScanFolders 'tests/scripts/claude-hooks/enforce-python-batch-budget.Tests.ps1'"
```

EXIT_CODE: 0
ExpectedExitCode: 0

Console output (ANSI colour escapes stripped):

```
Starting discovery in 1 files.
Discovery found 35 tests in 152ms.
Starting code coverage.
Running tests.
[+] C:\Users\DanMoisan\repos\drm-copilot\.claude\worktrees\agent-add102e7ba6e997d5\tests\scripts\claude-hooks\enforce-python-batch-budget.Tests.ps1 844ms (398ms|313ms)
Tests completed in 855ms
Tests Passed: 35, Failed: 0, Skipped: 0, Inconclusive: 0, NotRun: 0
Processing code coverage result.
Covered 2.6% / 0%. 10,851 analyzed Commands in 88 Files.
Wrote Koverage coverage copy: C:\Users\DanMoisan\repos\drm-copilot\.claude\worktrees\agent-add102e7ba6e997d5\artifacts\pester\powershell-coverage.koverage.xml
```

Replayed line beginning `Tests Passed: `, quoted verbatim:

```
Tests Passed: 35, Failed: 0, Skipped: 0, Inconclusive: 0, NotRun: 0
```

| Count | Value |
| --- | --- |
| Passed | 35 |
| Failed | **0** |
| Skipped | 0 |
| Inconclusive | 0 |
| NotRun | 0 |

### Passed-count comparison against the [P0-T11] baseline

| | Passed |
| --- | --- |
| Baseline [P0-T11] | 32 |
| Final [P5-T6] | 35 |
| **Difference** | **exactly 3** |

The difference of exactly 3 is the three `It` blocks added by [P2-T2] under the Python naming.

## Form B — Pester result-file extraction

Command (plan text, verbatim):

```
pwsh -NoProfile -Command '[xml]$junit = Get-Content -LiteralPath "artifacts/pester/pester-junit.xml" -Raw; $root = $junit.SelectSingleNode("/*"); "root={0} tests={1} failures={2}" -f $root.Name, $root.GetAttribute("tests"), $root.GetAttribute("failures"); $junit.SelectNodes("//testcase[failure]") | ForEach-Object { $_.name }'
```

EXIT_CODE: 0
ExpectedExitCode: 0

Output, verbatim:

```
root=Pester tests=35 failures=0
```

`failures` count: **0**, with an empty failing-name list. The absent-result-file blocked branch is
not taken.

## Form C — per-file coverage extraction

Command (plan text, verbatim):

```
pwsh -NoProfile -Command '[xml]$report = Get-Content -LiteralPath "artifacts/pester/powershell-coverage.xml" -Raw; foreach ($leaf in @(".claude/hooks/enforce-powershell-batch-budget.ps1", ".claude/hooks/enforce-python-batch-budget.ps1")) { foreach ($pkg in @($report.report.package)) { foreach ($sf in @($pkg.sourcefile)) { $full = ($pkg.name + "/" + $sf.name).Replace("\", "/"); if ($full.EndsWith("/" + $leaf)) { $c = @($sf.counter) | Where-Object { $_.type -eq "LINE" }; "{0} LINE covered={1} missed={2}" -f $leaf, $c.covered, $c.missed } } } }'
```

EXIT_CODE: 0
ExpectedExitCode: 0

Output, verbatim:

```
.claude/hooks/enforce-powershell-batch-budget.ps1 LINE covered=0 missed=129
.claude/hooks/enforce-python-batch-budget.ps1 LINE covered=123 missed=6
```

### Asserted row — `.claude/hooks/enforce-python-batch-budget.ps1`

- `covered` = **123**
- `missed` = **6**
- LINE percent = 100 * 123 / (123 + 6) = 100 * 123 / 129 = **95.3** percent, to one decimal place

Recomputed independently from the covered and missed counts above.

Beside the [P0-T11] baseline:

| | covered | missed | LINE percent |
| --- | --- | --- | --- |
| Baseline [P0-T11] | 121 | 8 | 93.8 |
| Final [P5-T6] | 123 | 6 | **95.3** |
| Delta | +2 | -2 | **+1.5 points** |

95.3 is at or above the 85 floor. The covered count rose by exactly 2 against an unchanged total of
129, which is only consistent with two lines moving from missed to covered and none moving the other
way; no previously covered line became uncovered.

### Recorded but not asserted — `.claude/hooks/enforce-powershell-batch-budget.ps1`

`covered=0 missed=129`. The PowerShell suite did not run in this scoped invocation, so this row
carries no signal about that file's real coverage. [P5-T5] measured it under its own scoped run and
recorded 123 / 6.

### Scoped-measurement caveat

The caveat recorded in [P5-T5] applies here unchanged: `Invoke-PoshQCTest` narrows `Run.Path` but
leaves `CodeCoverage.Path` at its full allow-list, so this is a scoped measurement directly
comparable to the [P0-T11] scoped baseline and not to any unscoped figure. The scan was not widened.

## Form D — per-line coverage extraction

Command (plan text, verbatim):

```
pwsh -NoProfile -Command '[xml]$report = Get-Content -LiteralPath "artifacts/pester/powershell-coverage.xml" -Raw; $targets = @{ ".claude/hooks/enforce-powershell-batch-budget.ps1" = @(154, 155); ".claude/hooks/enforce-python-batch-budget.ps1" = @(151, 152) }; foreach ($leaf in $targets.Keys) { foreach ($pkg in @($report.report.package)) { foreach ($sf in @($pkg.sourcefile)) { $full = ($pkg.name + "/" + $sf.name).Replace("\", "/"); if ($full.EndsWith("/" + $leaf)) { foreach ($nr in $targets[$leaf]) { $ln = @($sf.line) | Where-Object { [int]$_.nr -eq $nr }; if ($ln) { "{0} line={1} mi={2} ci={3}" -f $leaf, $nr, $ln.mi, $ln.ci } else { "{0} line={1} ABSENT" -f $leaf, $nr } } } } } }'
```

EXIT_CODE: 0
ExpectedExitCode: 0

Output, verbatim:

```
.claude/hooks/enforce-python-batch-budget.ps1 line=151 mi=0 ci=2
.claude/hooks/enforce-python-batch-budget.ps1 line=152 mi=0 ci=1
.claude/hooks/enforce-powershell-batch-budget.ps1 line=154 mi=2 ci=0
.claude/hooks/enforce-powershell-batch-budget.ps1 line=155 mi=1 ci=0
```

### Asserted rows — the Python hook only

| Line | `mi` | `ci` | Condition (`mi=0`) |
| --- | --- | --- | --- |
| 151 (`Write-Verbose "Ignoring unreadable session-id file ..."`) | **0** | 2 | met |
| 152 (`$fromFile = ''`) | **0** | 1 | met |

Both asserted rows report `mi=0`. Against the [P0-T11] baseline, which recorded `mi=2 ci=0` and
`mi=1 ci=0`, both lines moved from uncovered to covered. This is the pass-after half of the B-3
evidence pair for the Python hook.

The two PowerShell-hook rows in the same output describe a suite that did not execute in this
invocation and are not asserted here; [P5-T5] asserts them.

Output Summary: Form A exited 0 with `Tests Passed: 35, Failed: 0, Skipped: 0, Inconclusive: 0,
NotRun: 0`; the passed count is exactly 3 greater than the [P0-T11] baseline of 32. Form B reports
`root=Pester tests=35 failures=0` with an empty failing-name list. Form C gives
`.claude/hooks/enforce-python-batch-budget.ps1` LINE covered=123, missed=6, a derived **95.3
percent**, up 1.5 points from the 93.8 baseline and above the 85 floor, with no previously covered
line becoming uncovered. Form D gives lines 151 and 152 of that file as `mi=0 ci=2` and `mi=0 ci=1`,
both now covered. No blocked branch taken. Acceptance met on every condition.
