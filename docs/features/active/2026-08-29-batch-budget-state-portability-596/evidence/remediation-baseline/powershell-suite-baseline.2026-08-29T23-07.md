# PowerShell batch-budget suite baseline (remediation cycle 1)

Timestamp: 2026-08-30T00-54

Task: [P0-T10]
Plan: `docs/features/active/2026-08-29-batch-budget-state-portability-596/remediation/2026-08-29T23-07/remediation-plan.md`

All four commands were executed with the working directory set to the absolute worktree path `C:/Users/DanMoisan/repos/drm-copilot/.claude/worktrees/agent-add102e7ba6e997d5`. The plan states the commands worktree-relative; that working directory is what resolves them.

EXIT_CODE: 0 (Form A; Forms B, C, and D each also exited 0)

---

## Form A — self-hosted scoped Pester run

Command (plan Form A, with `<suite>` replaced by the PowerShell suite):

```
pwsh -NoProfile -Command "Import-Module ./scripts/powershell/PoshQC/PoshQC.psd1 -Force; Invoke-PoshQCTest -Root (Get-Location).Path -SettingsPath 'scripts/powershell/PoshQC/settings/pester.runsettings.psd1' -ScanFolders 'tests/scripts/claude-hooks/enforce-powershell-batch-budget.Tests.ps1'"
```

EXIT_CODE: 0

Console output (ANSI colour codes stripped):

```
Starting discovery in 1 files.
Discovery found 33 tests in 170ms.
Starting code coverage.
Running tests.
[+] C:\Users\DanMoisan\repos\drm-copilot\.claude\worktrees\agent-add102e7ba6e997d5\tests\scripts\claude-hooks\enforce-powershell-batch-budget.Tests.ps1 922ms (430ms|347ms)
Tests completed in 943ms
Tests Passed: 33, Failed: 0, Skipped: 0, Inconclusive: 0, NotRun: 0
Processing code coverage result.
Covered 2.56% / 0%. 10,849 analyzed Commands in 88 Files.
Wrote Koverage coverage copy: C:\Users\DanMoisan\repos\drm-copilot\.claude\worktrees\agent-add102e7ba6e997d5\artifacts\pester\powershell-coverage.koverage.xml
```

Replayed line beginning `Tests Passed: `, quoted verbatim:

```
Tests Passed: 33, Failed: 0, Skipped: 0, Inconclusive: 0, NotRun: 0
```

The five counts it carries:

| Count | Value |
| --- | --- |
| Passed | 33 |
| Failed | **0** |
| Skipped | 0 |
| Inconclusive | 0 |
| NotRun | 0 |

The failed count is 0, as the acceptance condition requires. `Run.Exit = $true` in `scripts/powershell/PoshQC/settings/pester.runsettings.psd1` makes Pester terminate the process with a non-zero exit code when the run has failures, so the observed `EXIT_CODE: 0` is a real pass signal rather than an absence of signal.

The `Covered 2.56% / 0%` line is the run-wide aggregate across all 88 instrumented files and is **not** the per-file figure this task asserts. It is low because a scoped run instruments the full `CodeCoverage.Path` allow-list while executing only one suite. The per-file figure comes from Form C below.

**The passed count of 33 is the baseline that [P1-T6] compares against**, which asserts a passed count exactly 3 greater, that is 36.

---

## Form B — Pester result-file extraction

Command (plan Form B, verbatim):

```
pwsh -NoProfile -Command '[xml]$junit = Get-Content -LiteralPath "artifacts/pester/pester-junit.xml" -Raw; $root = $junit.SelectSingleNode("/*"); "root={0} tests={1} failures={2}" -f $root.Name, $root.GetAttribute("tests"), $root.GetAttribute("failures"); $junit.SelectNodes("//testcase[failure]") | ForEach-Object { $_.name }'
```

EXIT_CODE: 0

Output, verbatim:

```
root=Pester tests=33 failures=0
```

- `tests`: 33, agreeing with the Form A passed count
- **`failures`: 0**, as the acceptance condition requires
- No `testcase` carrying a `failure` child was emitted, so the failing-name list is empty

`artifacts/pester/pester-junit.xml` was present and parsed. The `BLOCKED: Pester result file not produced by the failing run` branch does not apply to this task, which is a passing run.

---

## Form C — per-file coverage extraction

Command (plan Form C, verbatim):

```
pwsh -NoProfile -Command '[xml]$report = Get-Content -LiteralPath "artifacts/pester/powershell-coverage.xml" -Raw; foreach ($leaf in @(".claude/hooks/enforce-powershell-batch-budget.ps1", ".claude/hooks/enforce-python-batch-budget.ps1")) { foreach ($pkg in @($report.report.package)) { foreach ($sf in @($pkg.sourcefile)) { $full = ($pkg.name + "/" + $sf.name).Replace("\", "/"); if ($full.EndsWith("/" + $leaf)) { $c = @($sf.counter) | Where-Object { $_.type -eq "LINE" }; "{0} LINE covered={1} missed={2}" -f $leaf, $c.covered, $c.missed } } } }'
```

EXIT_CODE: 0

Output, verbatim:

```
.claude/hooks/enforce-powershell-batch-budget.ps1 LINE covered=121 missed=8
.claude/hooks/enforce-python-batch-budget.ps1 LINE covered=0 missed=129
```

Exactly one row was emitted per leaf, confirming that the three-segment suffix match discriminated the `.claude/hooks` package from the `.codex/hooks` package that carries a `sourcefile` element of the same bare name.

### Asserted row — `.claude/hooks/enforce-powershell-batch-budget.ps1`

- `covered` = **121**
- `missed` = **8**
- LINE percent = 100 * 121 / (121 + 8) = 100 * 121 / 129 = **93.8** percent, to one decimal place

**93.8 is at or above the 85 floor**, so the acceptance condition holds and the `BLOCKED: scoped baseline coverage below the 85 floor` branch is not taken. The scan was not widened, and the whole `tests/scripts/claude-hooks` directory was not scanned.

**Note on the relationship to the 93.8 percent figure recorded by the completed plan.** The plan states that figure as an upper bound on what a scoped run can observe, not as a prediction of it, because `Invoke-PoshQCTest` narrows `Run.Path` to the supplied `-ScanFolders` while leaving `CodeCoverage.Path` at its full allow-list. `tests/scripts/claude-hooks/PreToolUseSchema.Contract.Tests.ps1` therefore did not run and contributed nothing to the covered count in this measurement. The scoped figure derived here happens to coincide with that bound at one decimal place, which is consistent with the bound but is not evidence that the two quantities are the same measurement. The number recorded here is the one derived from this run's own covered and missed counts.

### Recorded but not asserted — `.claude/hooks/enforce-python-batch-budget.ps1`

- `covered` = 0
- `missed` = 129

Recorded per the plan and **not asserted**, because the Python suite did not run in this invocation. A zero covered count for a file whose suite did not execute is the expected result and carries no signal about that file's real coverage. [P0-T11] measures it under its own scoped run.

---

## Form D — per-line coverage for the B-3 catch bodies

Command (plan Form D, verbatim):

```
pwsh -NoProfile -Command '[xml]$report = Get-Content -LiteralPath "artifacts/pester/powershell-coverage.xml" -Raw; $targets = @{ ".claude/hooks/enforce-powershell-batch-budget.ps1" = @(154, 155); ".claude/hooks/enforce-python-batch-budget.ps1" = @(151, 152) }; foreach ($leaf in $targets.Keys) { foreach ($pkg in @($report.report.package)) { foreach ($sf in @($pkg.sourcefile)) { $full = ($pkg.name + "/" + $sf.name).Replace("\", "/"); if ($full.EndsWith("/" + $leaf)) { foreach ($nr in $targets[$leaf]) { $ln = @($sf.line) | Where-Object { [int]$_.nr -eq $nr }; if ($ln) { "{0} line={1} mi={2} ci={3}" -f $leaf, $nr, $ln.mi, $ln.ci } else { "{0} line={1} ABSENT" -f $leaf, $nr } } } } } }'
```

EXIT_CODE: 0

Output, verbatim:

```
.claude/hooks/enforce-python-batch-budget.ps1 line=151 mi=2 ci=0
.claude/hooks/enforce-python-batch-budget.ps1 line=152 mi=1 ci=0
.claude/hooks/enforce-powershell-batch-budget.ps1 line=154 mi=2 ci=0
.claude/hooks/enforce-powershell-batch-budget.ps1 line=155 mi=1 ci=0
```

### Asserted rows — `.claude/hooks/enforce-powershell-batch-budget.ps1`

| Line | `mi` | `ci` | Condition (`ci=0` and `mi` > 0) |
| --- | --- | --- | --- |
| 154 | 2 | **0** | holds |
| 155 | 1 | **0** | holds |

Both rows report `ci=0` with `mi` greater than 0. The acceptance condition holds.

**These two rows are the fail-before evidence for B-3 in the PowerShell hook.** Neither row reports `ci` greater than 0, so the `BLOCKED: B-3 baseline shows the catch body already covered` branch is **not** taken and the B-3 premise holds: the unreadable-session-id catch body is currently untested.

The two lines were confirmed against the source to be the catch bodies the plan names. `.claude/hooks/enforce-powershell-batch-budget.ps1:151-156` reads:

```powershell
    try {
        $fromFile = [string](& $ReadSessionIdFile $SessionIdFilePath)
    } catch {
        Write-Verbose "Ignoring unreadable session-id file '$SessionIdFilePath': $($_.Exception.Message)"
        $fromFile = ''
    }
```

Line 154 is the `Write-Verbose` call and line 155 is `$fromFile = ''`, exactly as the plan states. Decision D-1 holds this file at 457 lines precisely so these two absolute line numbers do not move between this baseline capture and the [P1-T6] final capture.

### Not asserted — `.claude/hooks/enforce-python-batch-budget.ps1` lines 151 and 152

The two Python rows are present in the output above but are **not asserted by this task**, because a scoped run leaves the other hook's rows describing a suite that did not execute. [P0-T11] asserts them under its own scoped run.

---

## Output Summary

Form A exited 0 with `Tests Passed: 33, Failed: 0, Skipped: 0, Inconclusive: 0, NotRun: 0`; the failed count is 0 and the passed count of 33 is the baseline [P1-T6] compares against. Form B reports `root=Pester tests=33 failures=0` with an empty failing-name list. Form C gives `.claude/hooks/enforce-powershell-batch-budget.ps1` LINE covered=121, missed=8, a derived **93.8 percent**, at or above the 85 floor. Form D gives lines 154 and 155 of that file as `mi=2 ci=0` and `mi=1 ci=0` respectively, both uncovered, which is the B-3 fail-before evidence for the PowerShell hook. No BLOCKED branch taken: coverage is above the floor and the catch body is not already covered.
