# [P1-T6] B-1 and B-3 PowerShell — pass-after evidence

Timestamp: 2026-08-30T00-30

Task: [P1-T6] of the cycle-1 remediation plan.

## Execution context

The plan states its commands worktree-relative. Each command was executed with the absolute prefix
`cd "C:/Users/DanMoisan/repos/drm-copilot/.claude/worktrees/agent-add102e7ba6e997d5" && ` prepended
to the plan's command text. The plan's command text is recorded verbatim below.

## Form A — scoped Pester run

Command: `pwsh -NoProfile -Command "Import-Module ./scripts/powershell/PoshQC/PoshQC.psd1 -Force; Invoke-PoshQCTest -Root (Get-Location).Path -SettingsPath 'scripts/powershell/PoshQC/settings/pester.runsettings.psd1' -ScanFolders 'tests/scripts/claude-hooks/enforce-powershell-batch-budget.Tests.ps1'"`

EXIT_CODE: 0

Console output, verbatim (ANSI colour escapes removed; no other alteration):

```
Starting discovery in 1 files.
Discovery found 36 tests in 170ms.
Starting code coverage.
Running tests.
[+] C:\Users\DanMoisan\repos\drm-copilot\.claude\worktrees\agent-add102e7ba6e997d5\tests\scripts\claude-hooks\enforce-powershell-batch-budget.Tests.ps1 1.19s (577ms|462ms)
Tests completed in 1.2s
Tests Passed: 36, Failed: 0, Skipped: 0, Inconclusive: 0, NotRun: 0
Processing code coverage result.
Covered 2.6% / 0%. 10,850 analyzed Commands in 88 Files.
Wrote Koverage coverage copy: C:\Users\DanMoisan\repos\drm-copilot\.claude\worktrees\agent-add102e7ba6e997d5\artifacts\pester\powershell-coverage.koverage.xml
```

The replayed line, quoted verbatim:

```
Tests Passed: 36, Failed: 0, Skipped: 0, Inconclusive: 0, NotRun: 0
```

| Count | Value |
| --- | --- |
| Passed | 36 |
| Failed | 0 |
| Skipped | 0 |
| Inconclusive | 0 |
| NotRun | 0 |

The [P0-T10] baseline passed count was `33`. The observed passed count of `36` is exactly 3 greater,
the increment being the three tests added by [P1-T2]. The failed count is 0.

## Form B — Pester result-file extraction

Command: `pwsh -NoProfile -Command '[xml]$junit = Get-Content -LiteralPath "artifacts/pester/pester-junit.xml" -Raw; $root = $junit.SelectSingleNode("/*"); "root={0} tests={1} failures={2}" -f $root.Name, $root.GetAttribute("tests"), $root.GetAttribute("failures"); $junit.SelectNodes("//testcase[failure]") | ForEach-Object { $_.name }'`

EXIT_CODE: 0

Output, verbatim:

```
root=Pester tests=36 failures=0
```

The `failures` count is 0 and the failing-name list is empty.

All three `It` titles from the phase preamble are present among the `testcase` names, each with no
`failure` child:

```
enforce-powershell-batch-budget.ps1.session identity, containment, and rehydrate filter.discards an absolute candidate path in a sibling directory whose name extends the root | failureChild=False
enforce-powershell-batch-budget.ps1.session identity, containment, and rehydrate filter.admits a candidate path that is exactly the resolved root | failureChild=False
enforce-powershell-batch-budget.ps1.session identity, containment, and rehydrate filter.falls through to the worktree-derived id when the session-id file is unreadable | failureChild=False
```

The `discards an absolute candidate path in a sibling directory whose name extends the root` case
carried a `failure` child in the [P1-T3] fail-before run and carries none here, which is the
fail-before / pass-after pair for B-1 in the PowerShell hook.

## Form C — per-file line coverage

Command: `pwsh -NoProfile -Command '[xml]$report = Get-Content -LiteralPath "artifacts/pester/powershell-coverage.xml" -Raw; foreach ($leaf in @(".claude/hooks/enforce-powershell-batch-budget.ps1", ".claude/hooks/enforce-python-batch-budget.ps1")) { foreach ($pkg in @($report.report.package)) { foreach ($sf in @($pkg.sourcefile)) { $full = ($pkg.name + "/" + $sf.name).Replace("\", "/"); if ($full.EndsWith("/" + $leaf)) { $c = @($sf.counter) | Where-Object { $_.type -eq "LINE" }; "{0} LINE covered={1} missed={2}" -f $leaf, $c.covered, $c.missed } } } }'`

EXIT_CODE: 0

Output, verbatim:

```
.claude/hooks/enforce-powershell-batch-budget.ps1 LINE covered=123 missed=6
.claude/hooks/enforce-python-batch-budget.ps1 LINE covered=0 missed=129
```

Derivation for the asserted file, `100 * covered / (covered + missed)`:

`100 * 123 / (123 + 6) = 100 * 123 / 129 = 95.3` percent, recorded to one decimal place.

| Capture | covered | missed | LINE percent |
| --- | --- | --- | --- |
| [P0-T10] baseline | 121 | 8 | 93.8 |
| [P1-T6] this run | 123 | 6 | 95.3 |

95.3 is a real derived number at or above the 85 floor. The rise of two covered lines is the two
catch-body statements the B-3 test now drives.

The `.claude/hooks/enforce-python-batch-budget.ps1` row reports `covered=0 missed=129` and is
recorded but not asserted: this was a scoped run of the PowerShell suite only, so that row describes
a file no executing test touched. The Python file's own numbers are asserted by [P2-T6].

## Form D — per-line coverage for the B-3 catch body

Command: `pwsh -NoProfile -Command '[xml]$report = Get-Content -LiteralPath "artifacts/pester/powershell-coverage.xml" -Raw; $targets = @{ ".claude/hooks/enforce-powershell-batch-budget.ps1" = @(154, 155); ".claude/hooks/enforce-python-batch-budget.ps1" = @(151, 152) }; foreach ($leaf in $targets.Keys) { foreach ($pkg in @($report.report.package)) { foreach ($sf in @($pkg.sourcefile)) { $full = ($pkg.name + "/" + $sf.name).Replace("\", "/"); if ($full.EndsWith("/" + $leaf)) { foreach ($nr in $targets[$leaf]) { $ln = @($sf.line) | Where-Object { [int]$_.nr -eq $nr }; if ($ln) { "{0} line={1} mi={2} ci={3}" -f $leaf, $nr, $ln.mi, $ln.ci } else { "{0} line={1} ABSENT" -f $leaf, $nr } } } } } }'`

EXIT_CODE: 0

Output, verbatim:

```
.claude/hooks/enforce-python-batch-budget.ps1 line=151 mi=2 ci=0
.claude/hooks/enforce-python-batch-budget.ps1 line=152 mi=1 ci=0
.claude/hooks/enforce-powershell-batch-budget.ps1 line=154 mi=0 ci=2
.claude/hooks/enforce-powershell-batch-budget.ps1 line=155 mi=0 ci=1
```

The two asserted rows are the PowerShell ones, per the plan's rule that each Form D task asserts only
the rows belonging to the hook whose suite that task just ran:

| File | Line | Statement | [P0-T10] before | [P1-T6] after |
| --- | --- | --- | --- | --- |
| `.claude/hooks/enforce-powershell-batch-budget.ps1` | 154 | `Write-Verbose "Ignoring unreadable session-id file ..."` | `mi=2 ci=0` | `mi=0 ci=2` |
| `.claude/hooks/enforce-powershell-batch-budget.ps1` | 155 | `$fromFile = ''` | `mi=1 ci=0` | `mi=0 ci=1` |

Both rows report `mi=0` with `ci` greater than 0, which is the pass-after half of the B-3 evidence
pair for the PowerShell hook. The line numbers remain valid because [P1-T4] preserved the file at 457
lines.

The two Python rows still report `ci=0` and are not asserted here, for the same
scoped-run reason recorded under Form C. They are asserted by [P2-T6].

## Verdict

PASS. Form A exit 0; passed count exactly 3 above baseline with 0 failures; Form B failures 0 with all
three new titles present and unfailed; Form C 95.3 percent, above the 85 floor and above the 93.8
percent baseline; Form D both target lines covered. No BLOCKED branch taken.
