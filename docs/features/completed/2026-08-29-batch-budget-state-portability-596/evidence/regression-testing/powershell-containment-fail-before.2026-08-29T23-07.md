# [P1-T3] B-1 PowerShell — fail-before evidence

Timestamp: 2026-08-30T00-22

Output Summary: Expect-fail run of the scoped PowerShell hook suite. Form A exited 1 against a
declared `ExpectedExitCode: 1`; Form B reported exactly one failing testcase,
`discards an absolute candidate path in a sibling directory whose name extends the root`, aborting
at `$result.shouldWriteState | Should -BeFalse` with `Expected $false, but got $true`. Failure
count, failing-name set, and aborting assertion all match the plan's prediction. The other two
added tests were absent from the failing set. No test was corrected and no recorded expectation was
adjusted to match an observation.

Task: [P1-T3] `[expect-fail]` of the cycle-1 remediation plan.

## Execution context

The plan states its commands worktree-relative. Each command was executed with the absolute prefix
`cd "C:/Users/DanMoisan/repos/drm-copilot/.claude/worktrees/agent-add102e7ba6e997d5" && ` prepended
to the plan's command text. The plan's command text is recorded verbatim below.

## Form A — scoped Pester run

Command: `pwsh -NoProfile -Command "Import-Module ./scripts/powershell/PoshQC/PoshQC.psd1 -Force; Invoke-PoshQCTest -Root (Get-Location).Path -SettingsPath 'scripts/powershell/PoshQC/settings/pester.runsettings.psd1' -ScanFolders 'tests/scripts/claude-hooks/enforce-powershell-batch-budget.Tests.ps1'"`

EXIT_CODE: 1

ExpectedExitCode: 1

Complete Form A console output, verbatim (ANSI colour escapes removed for legibility; no other
alteration):

```
Starting discovery in 1 files.
Discovery found 36 tests in 154ms.
Starting code coverage.
Running tests.
[-] enforce-powershell-batch-budget.ps1.session identity, containment, and rehydrate filter.discards an absolute candidate path in a sibling directory whose name extends the root 14ms (14ms|1ms)
 at $result.shouldWriteState | Should -BeFalse, C:\Users\DanMoisan\repos\drm-copilot\.claude\worktrees\agent-add102e7ba6e997d5\tests\scripts\claude-hooks\enforce-powershell-batch-budget.Tests.ps1:437
 at <ScriptBlock>, C:\Users\DanMoisan\repos\drm-copilot\.claude\worktrees\agent-add102e7ba6e997d5\tests\scripts\claude-hooks\enforce-powershell-batch-budget.Tests.ps1:437
 Expected $false, but got $true.
Tests completed in 920ms
Tests Passed: 35, Failed: 1, Skipped: 0, Inconclusive: 0, NotRun: 0
Processing code coverage result.
Covered 2.59% / 0%. 10,849 analyzed Commands in 88 Files.
```

## Form B — Pester result-file extraction

Command: `pwsh -NoProfile -Command '[xml]$junit = Get-Content -LiteralPath "artifacts/pester/pester-junit.xml" -Raw; $root = $junit.SelectSingleNode("/*"); "root={0} tests={1} failures={2}" -f $root.Name, $root.GetAttribute("tests"), $root.GetAttribute("failures"); $junit.SelectNodes("//testcase[failure]") | ForEach-Object { $_.name }'`

EXIT_CODE: 0

Output, verbatim:

```
root=Pester tests=36 failures=1
enforce-powershell-batch-budget.ps1.session identity, containment, and rehydrate filter.discards an absolute candidate path in a sibling directory whose name extends the root
```

## Observed versus predicted

| Property | Predicted by the plan | Observed | Match |
| --- | --- | --- | --- |
| Form A exit code | non-zero | `1` | yes |
| Form B `failures` | exactly `1` | `1` | yes |
| Failing `testcase` leaf name | `discards an absolute candidate path in a sibling directory whose name extends the root` | same leaf, carried on the fully qualified name `enforce-powershell-batch-budget.ps1.session identity, containment, and rehydrate filter.discards an absolute candidate path in a sibling directory whose name extends the root` | yes |
| Aborting assertion | the `shouldWriteState` assertion, first of the two discriminating assertions | `$result.shouldWriteState | Should -BeFalse` at suite line 437, `Expected $false, but got $true.` | yes |
| The other two added tests | pass before the fix, absent from the failing set | absent from the failing set | yes |

The count of exactly 1 is the plan's derivation confirmed: against the unmodified helper,
`/repo-sibling/scripts/tool.ps1` normalizes to a path that satisfies `StartsWith('/repo')`, so it is
classified in-root, appended to `prodFiles`, and `shouldWriteState` is set true. Two of the test's
four assertions are discriminating, but `Should.ErrorAction = 'Stop'` in
`scripts/powershell/PoshQC/settings/pester.runsettings.psd1` aborts the `It` at the first failing
assertion, so exactly one failing `testcase` is contributed and the `prodFiles` assertion is never
reached. The `permissionDecision` and `testFiles` assertions pass either way and are retained as
shape guards.

Total test count rose from the [P0-T10] baseline of 33 to 36, the increment being the three tests
added by [P1-T2].

## One observation that diverges from the plan's prose, in the non-blocking direction

The plan states that on a failing run the replayed line beginning `Tests Passed: ` is not printed,
and that failing-run counts come from Form B instead. This run printed that line
(`Tests Passed: 35, Failed: 1, Skipped: 0, Inconclusive: 0, NotRun: 0`) despite exiting non-zero. The
divergence supplies more evidence than the plan predicted rather than less, and Form B was still run
and is still the recorded source of the failure count and name, so no acceptance condition is
affected. It is recorded here so a later reader does not treat the printed line as anomalous.

## Blocked branch

Not taken. `artifacts/pester/pester-junit.xml` was present and parsed after the failing run, which is
the second of the two grounds the plan records for that expectation.

## Verdict

PASS as an `[expect-fail]` task. The failure is the predicted one, in the predicted count, with the
predicted name and the predicted aborting assertion. No test was corrected and no recorded
expectation was adjusted to match an observation.
