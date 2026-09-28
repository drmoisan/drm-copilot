# PowerShell hook suite — final QA gate ([P5-T5])

Timestamp: 2026-08-30T01-39
Task: [P5-T5]
Loop iteration: 1

All four commands were executed with the working directory set to the absolute worktree path
`C:/Users/DanMoisan/repos/drm-copilot/.claude/worktrees/agent-add102e7ba6e997d5`. The plan's command
text is worktree-relative and is reproduced verbatim below; the absolute prefix used was a `cd` into
that path ahead of each command.

## Form A — scoped Pester run

Command (plan text, verbatim, with `<suite>` substituted as the task directs):

```
pwsh -NoProfile -Command "Import-Module ./scripts/powershell/PoshQC/PoshQC.psd1 -Force; Invoke-PoshQCTest -Root (Get-Location).Path -SettingsPath 'scripts/powershell/PoshQC/settings/pester.runsettings.psd1' -ScanFolders 'tests/scripts/claude-hooks/enforce-powershell-batch-budget.Tests.ps1'"
```

EXIT_CODE: 0
ExpectedExitCode: 0

Console output (ANSI colour escapes stripped):

```
Starting discovery in 1 files.
Discovery found 36 tests in 152ms.
Starting code coverage.
Running tests.
[+] C:\Users\DanMoisan\repos\drm-copilot\.claude\worktrees\agent-add102e7ba6e997d5\tests\scripts\claude-hooks\enforce-powershell-batch-budget.Tests.ps1 839ms (402ms|304ms)
Tests completed in 849ms
Tests Passed: 36, Failed: 0, Skipped: 0, Inconclusive: 0, NotRun: 0
Processing code coverage result.
Covered 2.6% / 0%. 10,851 analyzed Commands in 88 Files.
Wrote Koverage coverage copy: C:\Users\DanMoisan\repos\drm-copilot\.claude\worktrees\agent-add102e7ba6e997d5\artifacts\pester\powershell-coverage.koverage.xml
```

Replayed line beginning `Tests Passed: `, quoted verbatim:

```
Tests Passed: 36, Failed: 0, Skipped: 0, Inconclusive: 0, NotRun: 0
```

The five counts it carries:

| Count | Value |
| --- | --- |
| Passed | 36 |
| Failed | **0** |
| Skipped | 0 |
| Inconclusive | 0 |
| NotRun | 0 |

### Passed-count comparison against the [P0-T10] baseline

| | Passed |
| --- | --- |
| Baseline [P0-T10] | 33 |
| Final [P5-T5] | 36 |
| **Difference** | **exactly 3** |

The difference of exactly 3 is the three `It` blocks added by [P1-T2]: the B-1 sibling-prefix discard
test, the exact-root admission guard, and the B-3 unreadable-session-id test.

Note on the `Covered 2.6% / 0%` line: this is Pester's whole-run aggregate across the full
`CodeCoverage.Path` allow-list of 88 files, of which only the one scanned suite executed. It is not
the per-file figure this task asserts; the per-file figure comes from Form C below.

## Form B — Pester result-file extraction

Command (plan text, verbatim):

```
pwsh -NoProfile -Command '[xml]$junit = Get-Content -LiteralPath "artifacts/pester/pester-junit.xml" -Raw; $root = $junit.SelectSingleNode("/*"); "root={0} tests={1} failures={2}" -f $root.Name, $root.GetAttribute("tests"), $root.GetAttribute("failures"); $junit.SelectNodes("//testcase[failure]") | ForEach-Object { $_.name }'
```

EXIT_CODE: 0
ExpectedExitCode: 0

Output, verbatim:

```
root=Pester tests=36 failures=0
```

`failures` count: **0**. The failing-name list is empty — no line follows the summary line, because
the `//testcase[failure]` node set is empty.

The blocked branch `BLOCKED: Pester result file not produced by the failing run` is **not** taken:
`artifacts/pester/pester-junit.xml` was present and parsed.

## Form C — per-file coverage extraction

Command (plan text, verbatim):

```
pwsh -NoProfile -Command '[xml]$report = Get-Content -LiteralPath "artifacts/pester/powershell-coverage.xml" -Raw; foreach ($leaf in @(".claude/hooks/enforce-powershell-batch-budget.ps1", ".claude/hooks/enforce-python-batch-budget.ps1")) { foreach ($pkg in @($report.report.package)) { foreach ($sf in @($pkg.sourcefile)) { $full = ($pkg.name + "/" + $sf.name).Replace("\", "/"); if ($full.EndsWith("/" + $leaf)) { $c = @($sf.counter) | Where-Object { $_.type -eq "LINE" }; "{0} LINE covered={1} missed={2}" -f $leaf, $c.covered, $c.missed } } } }'
```

EXIT_CODE: 0
ExpectedExitCode: 0

Output, verbatim:

```
.claude/hooks/enforce-powershell-batch-budget.ps1 LINE covered=123 missed=6
.claude/hooks/enforce-python-batch-budget.ps1 LINE covered=0 missed=129
```

### Asserted row — `.claude/hooks/enforce-powershell-batch-budget.ps1`

- `covered` = **123**
- `missed` = **6**
- LINE percent = 100 * 123 / (123 + 6) = 100 * 123 / 129 = **95.3** percent, to one decimal place

The percentage was recomputed independently from the covered and missed counts above rather than
read from any aggregate line.

Beside the [P0-T10] baseline:

| | covered | missed | LINE percent |
| --- | --- | --- | --- |
| Baseline [P0-T10] | 121 | 8 | 93.8 |
| Final [P5-T5] | 123 | 6 | **95.3** |
| Delta | +2 | -2 | **+1.5 points** |

95.3 is at or above the 85 floor. The two newly covered lines are the two B-3 catch-body lines, 154
and 155, confirmed by Form D below. No previously covered line became uncovered: the covered count
rose by exactly 2 while the total (129) is unchanged, which is only consistent with two lines moving
from missed to covered and none moving the other way.

### Recorded but not asserted — `.claude/hooks/enforce-python-batch-budget.ps1`

`covered=0 missed=129`. This is recorded per the plan and **not asserted**, because the Python suite
did not run in this scoped invocation. A zero covered count for a file whose suite did not execute
carries no signal about that file's real coverage; [P5-T6] measures it under its own scoped run.

### Scoped-measurement caveat

`Invoke-PoshQCTest` narrows `Run.Path` to the supplied `-ScanFolders` but leaves `CodeCoverage.Path`
at its full allow-list, so this file is instrumented while
`tests/scripts/claude-hooks/PreToolUseSchema.Contract.Tests.ps1` does not run and contributes nothing
to the covered count. The figure above is therefore a scoped measurement, the same quantity the
[P0-T10] baseline measured, and the two are directly comparable to each other. Neither is the same
quantity as the unscoped figure recorded by the completed plan. The scan was not widened.

## Form D — per-line coverage extraction

Command (plan text, verbatim):

```
pwsh -NoProfile -Command '[xml]$report = Get-Content -LiteralPath "artifacts/pester/powershell-coverage.xml" -Raw; $targets = @{ ".claude/hooks/enforce-powershell-batch-budget.ps1" = @(154, 155); ".claude/hooks/enforce-python-batch-budget.ps1" = @(151, 152) }; foreach ($leaf in $targets.Keys) { foreach ($pkg in @($report.report.package)) { foreach ($sf in @($pkg.sourcefile)) { $full = ($pkg.name + "/" + $sf.name).Replace("\", "/"); if ($full.EndsWith("/" + $leaf)) { foreach ($nr in $targets[$leaf]) { $ln = @($sf.line) | Where-Object { [int]$_.nr -eq $nr }; if ($ln) { "{0} line={1} mi={2} ci={3}" -f $leaf, $nr, $ln.mi, $ln.ci } else { "{0} line={1} ABSENT" -f $leaf, $nr } } } } } }'
```

EXIT_CODE: 0
ExpectedExitCode: 0

Output, verbatim:

```
.claude/hooks/enforce-python-batch-budget.ps1 line=151 mi=2 ci=0
.claude/hooks/enforce-python-batch-budget.ps1 line=152 mi=1 ci=0
.claude/hooks/enforce-powershell-batch-budget.ps1 line=154 mi=0 ci=2
.claude/hooks/enforce-powershell-batch-budget.ps1 line=155 mi=0 ci=1
```

### Asserted rows — the PowerShell hook only

| Line | `mi` | `ci` | Condition (`mi=0`) |
| --- | --- | --- | --- |
| 154 (`Write-Verbose "Ignoring unreadable session-id file ..."`) | **0** | 2 | met |
| 155 (`$fromFile = ''`) | **0** | 1 | met |

Both asserted rows report `mi=0`. Against the [P0-T10] baseline, which recorded `mi=2 ci=0` and
`mi=1 ci=0` respectively, both lines moved from uncovered to covered. This is the pass-after half of
the B-3 evidence pair for the PowerShell hook.

The two Python-hook rows in the same output describe a suite that did not execute in this
invocation and are **not** asserted here, exactly as the plan directs. [P5-T6] asserts them.

Output Summary: Form A exited 0 with `Tests Passed: 36, Failed: 0, Skipped: 0, Inconclusive: 0,
NotRun: 0`; the passed count is exactly 3 greater than the [P0-T10] baseline of 33. Form B reports
`root=Pester tests=36 failures=0` with an empty failing-name list. Form C gives
`.claude/hooks/enforce-powershell-batch-budget.ps1` LINE covered=123, missed=6, a derived **95.3
percent**, up 1.5 points from the 93.8 baseline and above the 85 floor, with no previously covered
line becoming uncovered. Form D gives lines 154 and 155 of that file as `mi=0 ci=2` and `mi=0 ci=1`,
both now covered. No blocked branch taken. Acceptance met on every condition.
