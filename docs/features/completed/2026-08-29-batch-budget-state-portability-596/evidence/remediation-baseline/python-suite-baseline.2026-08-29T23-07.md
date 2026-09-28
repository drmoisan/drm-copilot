# Python batch-budget suite baseline (remediation cycle 1)

Timestamp: 2026-08-30T00-56

Task: [P0-T11]
Plan: `docs/features/active/2026-08-29-batch-budget-state-portability-596/remediation/2026-08-29T23-07/remediation-plan.md`

All four commands were executed with the working directory set to the absolute worktree path `C:/Users/DanMoisan/repos/drm-copilot/.claude/worktrees/agent-add102e7ba6e997d5`. The plan states the commands worktree-relative; that working directory is what resolves them.

**Ordering.** This task ran after [P0-T10], as the plan requires. Each Form A invocation overwrites `artifacts/pester/powershell-coverage.xml` and `artifacts/pester/pester-junit.xml`, so [P0-T10] recorded its numbers into its own artifact before this task ran.

EXIT_CODE: 0 (Form A; Forms B, C, and D each also exited 0)

---

## Form A — self-hosted scoped Pester run

Command (plan Form A, with `<suite>` replaced by the Python suite):

```
pwsh -NoProfile -Command "Import-Module ./scripts/powershell/PoshQC/PoshQC.psd1 -Force; Invoke-PoshQCTest -Root (Get-Location).Path -SettingsPath 'scripts/powershell/PoshQC/settings/pester.runsettings.psd1' -ScanFolders 'tests/scripts/claude-hooks/enforce-python-batch-budget.Tests.ps1'"
```

EXIT_CODE: 0

Console output (ANSI colour codes stripped):

```
Starting discovery in 1 files.
Discovery found 32 tests in 145ms.
Starting code coverage.
Running tests.
[+] C:\Users\DanMoisan\repos\drm-copilot\.claude\worktrees\agent-add102e7ba6e997d5\tests\scripts\claude-hooks\enforce-python-batch-budget.Tests.ps1 796ms (369ms|302ms)
Tests completed in 807ms
Tests Passed: 32, Failed: 0, Skipped: 0, Inconclusive: 0, NotRun: 0
Processing code coverage result.
Covered 2.56% / 0%. 10,849 analyzed Commands in 88 Files.
Wrote Koverage coverage copy: C:\Users\DanMoisan\repos\drm-copilot\.claude\worktrees\agent-add102e7ba6e997d5\artifacts\pester\powershell-coverage.koverage.xml
```

Replayed line beginning `Tests Passed: `, quoted verbatim:

```
Tests Passed: 32, Failed: 0, Skipped: 0, Inconclusive: 0, NotRun: 0
```

| Count | Value |
| --- | --- |
| Passed | 32 |
| Failed | **0** |
| Skipped | 0 |
| Inconclusive | 0 |
| NotRun | 0 |

The failed count is 0, as the acceptance condition requires. `Run.Exit = $true` in the runsettings makes a failing run terminate the process with a non-zero exit code, so `EXIT_CODE: 0` is a real pass signal.

The `Covered 2.56% / 0%` line is the run-wide aggregate across all 88 instrumented files, not the per-file figure this task asserts. The per-file figure comes from Form C below.

**The passed count of 32 is the baseline that [P2-T6] compares against**, on the same +3 pattern [P1-T6] applies to the PowerShell suite.

---

## Form B — Pester result-file extraction

Command (plan Form B, verbatim):

```
pwsh -NoProfile -Command '[xml]$junit = Get-Content -LiteralPath "artifacts/pester/pester-junit.xml" -Raw; $root = $junit.SelectSingleNode("/*"); "root={0} tests={1} failures={2}" -f $root.Name, $root.GetAttribute("tests"), $root.GetAttribute("failures"); $junit.SelectNodes("//testcase[failure]") | ForEach-Object { $_.name }'
```

EXIT_CODE: 0

Output, verbatim:

```
root=Pester tests=32 failures=0
```

- `tests`: 32, agreeing with the Form A passed count
- **`failures`: 0**, as the acceptance condition requires
- No `testcase` carrying a `failure` child was emitted, so the failing-name list is empty

`artifacts/pester/pester-junit.xml` was present and parsed.

---

## Form C — per-file coverage extraction

Command (plan Form C, verbatim):

```
pwsh -NoProfile -Command '[xml]$report = Get-Content -LiteralPath "artifacts/pester/powershell-coverage.xml" -Raw; foreach ($leaf in @(".claude/hooks/enforce-powershell-batch-budget.ps1", ".claude/hooks/enforce-python-batch-budget.ps1")) { foreach ($pkg in @($report.report.package)) { foreach ($sf in @($pkg.sourcefile)) { $full = ($pkg.name + "/" + $sf.name).Replace("\", "/"); if ($full.EndsWith("/" + $leaf)) { $c = @($sf.counter) | Where-Object { $_.type -eq "LINE" }; "{0} LINE covered={1} missed={2}" -f $leaf, $c.covered, $c.missed } } } }'
```

EXIT_CODE: 0

Output, verbatim:

```
.claude/hooks/enforce-powershell-batch-budget.ps1 LINE covered=0 missed=129
.claude/hooks/enforce-python-batch-budget.ps1 LINE covered=121 missed=8
```

Exactly one row per leaf, confirming the three-segment suffix match discriminated the `.claude/hooks` package from the `.codex/hooks` package carrying a `sourcefile` element of the same bare name.

### Asserted row — `.claude/hooks/enforce-python-batch-budget.ps1`

- `covered` = **121**
- `missed` = **8**
- LINE percent = 100 * 121 / (121 + 8) = 100 * 121 / 129 = **93.8** percent, to one decimal place

**93.8 is at or above the 85 floor**, so the acceptance condition holds and the `BLOCKED: scoped baseline coverage below the 85 floor` branch is not taken. The scan was not widened, and the whole `tests/scripts/claude-hooks` directory was not scanned, which the plan prohibits because the pre-existing failing pr-author suite lives in that directory.

The scoped-measurement caveat recorded in [P0-T10] applies here unchanged: `Invoke-PoshQCTest` narrows `Run.Path` to the supplied `-ScanFolders` while leaving `CodeCoverage.Path` at its full allow-list, so this percentage is a scoped measurement and the 93.8 percent figure from the completed plan's unscoped run is an upper bound on it rather than a prediction of it. The number recorded here is derived from this run's own covered and missed counts.

### Not asserted — `.claude/hooks/enforce-powershell-batch-budget.ps1`

- `covered` = 0
- `missed` = 129

Recorded and **not asserted**, because the PowerShell suite did not run in this invocation. Its real figure is the 93.8 percent recorded by [P0-T10] under its own scoped run. The complementary zero rows in the two artifacts are what confirm that each scoped run executed exactly the suite it named.

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

### Asserted rows — `.claude/hooks/enforce-python-batch-budget.ps1`

| Line | `mi` | `ci` | Condition (`ci=0` and `mi` > 0) |
| --- | --- | --- | --- |
| 151 | 2 | **0** | holds |
| 152 | 1 | **0** | holds |

Both rows report `ci=0` with `mi` greater than 0. The acceptance condition holds.

**These two rows are the fail-before evidence for B-3 in the Python hook.** Neither reports `ci` greater than 0, so the `BLOCKED: B-3 baseline shows the catch body already covered` branch is **not** taken and the B-3 premise holds for this hook as well.

The two lines were confirmed against the source. `.claude/hooks/enforce-python-batch-budget.ps1:148-153` reads:

```powershell
    try {
        $fromFile = [string](& $ReadSessionIdFile $SessionIdFilePath)
    } catch {
        Write-Verbose "Ignoring unreadable session-id file '$SessionIdFilePath': $($_.Exception.Message)"
        $fromFile = ''
    }
```

Line 151 is the `Write-Verbose` call and line 152 is `$fromFile = ''`, exactly as the plan states. Decision D-1 holds this file at 454 lines precisely so these two absolute line numbers do not move between this baseline capture and the [P2-T6] final capture.

### Not asserted — `.claude/hooks/enforce-powershell-batch-budget.ps1` lines 154 and 155

Present in the output above but not asserted by this task, because a scoped run leaves the other hook's rows describing a suite that did not execute. [P0-T10] asserted them under its own scoped run.

---

## Output Summary

Form A exited 0 with `Tests Passed: 32, Failed: 0, Skipped: 0, Inconclusive: 0, NotRun: 0`; the failed count is 0 and the passed count of 32 is the baseline [P2-T6] compares against. Form B reports `root=Pester tests=32 failures=0` with an empty failing-name list. Form C gives `.claude/hooks/enforce-python-batch-budget.ps1` LINE covered=121, missed=8, a derived **93.8 percent**, at or above the 85 floor. Form D gives lines 151 and 152 of that file as `mi=2 ci=0` and `mi=1 ci=0` respectively, both uncovered, which is the B-3 fail-before evidence for the Python hook. Neither BLOCKED branch taken.
