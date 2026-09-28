# [P2-T3] enforce-powershell-batch-budget.Tests.ps1 — fail-before evidence

Timestamp: 2026-08-29T16-05

Command: two commands, run in this order from the repository root of the executing worktree.

1. Form A, scoped:
   `pwsh -NoProfile -Command "Import-Module ./scripts/powershell/PoshQC/PoshQC.psd1 -Force; Invoke-PoshQCTest -Root (Get-Location).Path -SettingsPath 'scripts/powershell/PoshQC/settings/pester.runsettings.psd1' -ScanFolders 'tests/scripts/claude-hooks/enforce-powershell-batch-budget.Tests.ps1'"`
2. Form B:
   `pwsh -NoProfile -Command '[xml]$junit = Get-Content -LiteralPath "artifacts/pester/pester-junit.xml" -Raw; $root = $junit.SelectSingleNode("/*"); "root={0} tests={1} failures={2}" -f $root.Name, $root.GetAttribute("tests"), $root.GetAttribute("failures"); $junit.SelectNodes("//testcase[failure]") | ForEach-Object { $_.name }'`

EXIT_CODE: 10

ExpectedExitCode: 10

The Form A process exit code is 10, which is non-zero as this `[expect-fail]` task requires. Pester's
exit code equals its failed-test count under `Run.Exit = $true`
(`scripts/powershell/PoshQC/settings/pester.runsettings.psd1:4`), so the process exit code and the
Form B `failures` attribute independently agree on 10. The Form B command exited 0.

Output Summary: The scoped run discovered 33 tests and recorded exactly **10 failures** and 23
passes. The ten failing test names are, entry for entry, the ten `It` titles enumerated in [P2-T2].
No pre-existing test in the suite failed, so the count is not inflated by collateral breakage. The
recorded expectation of 10 was not adjusted; the observed result matched it on the first run.
`artifacts/pester/pester-junit.xml` **was** produced by this failing run, so the blocked branch
[P2-T3] carries for an absent result file was not taken.

## Verbatim Form B output

```
root=Pester tests=33 failures=10
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

The ten new `It` blocks were authored inside a new
`Context 'session identity, containment, and rehydrate filter'`, so each JUnit `name` carries that
Context segment between the Describe name and the `It` title. The `It` titles themselves are verbatim
the ten [P2-T2] fixes, and appear as the trailing segment of each name above.

## Verbatim Form A console output

```
Starting discovery in 1 files.
Discovery found 33 tests in 146ms.
Starting code coverage.
Running tests.
[-] enforce-powershell-batch-budget.ps1.session identity, containment, and rehydrate filter.composes the state-file name from CLAUDE_SESSION_ID when the environment supplies it 34ms (33ms|1ms)
 at (Split-Path -Path $script:writtenStateFile -Leaf) | Should -Be 'powershell-batch-budget.env-session-42.json', C:\Users\DanMoisan\repos\drm-copilot\.claude\worktrees\agent-add102e7ba6e997d5\tests\scripts\claude-hooks\enforce-powershell-batch-budget.Tests.ps1:268
 at <ScriptBlock>, C:\Users\DanMoisan\repos\drm-copilot\.claude\worktrees\agent-add102e7ba6e997d5\tests\scripts\claude-hooks\enforce-powershell-batch-budget.Tests.ps1:268
 Expected strings to be the same, but they were different.
 Expected length: 43
 Actual length:   36
 Strings differ at index 24.
 Expected: 'powershell-batch-budget.env-session-42.json'
 But was:  'powershell-batch-budget.default.json'
            ------------------------^
[-] enforce-powershell-batch-budget.ps1.session identity, containment, and rehydrate filter.composes the state-file name from the session-id state file when the environment is empty 3ms (3ms|1ms)
 at <ScriptBlock>, C:\Users\DanMoisan\repos\drm-copilot\.claude\worktrees\agent-add102e7ba6e997d5\tests\scripts\claude-hooks\enforce-powershell-batch-budget.Tests.ps1:276
 ParameterBindingException: A parameter cannot be found that matches parameter name 'ReadSessionIdFile'.
[-] enforce-powershell-batch-budget.ps1.session identity, containment, and rehydrate filter.composes a worktree-derived state-file name when both sources are empty 10ms (9ms|0ms)
 at (Split-Path -Path $script:writtenStateFile -Leaf) | Should -Match '^powershell-batch-budget\.worktree-repo-[0-9a-f]{8}\.json$', C:\Users\DanMoisan\repos\drm-copilot\.claude\worktrees\agent-add102e7ba6e997d5\tests\scripts\claude-hooks\enforce-powershell-batch-budget.Tests.ps1:301
 at <ScriptBlock>, C:\Users\DanMoisan\repos\drm-copilot\.claude\worktrees\agent-add102e7ba6e997d5\tests\scripts\claude-hooks\enforce-powershell-batch-budget.Tests.ps1:301
 Expected regular expression '^powershell-batch-budget\.worktree-repo-[0-9a-f]{8}\.json$' to match 'powershell-batch-budget.default.json', but it did not match.
[-] enforce-powershell-batch-budget.ps1.session identity, containment, and rehydrate filter.composes pairwise different state-file names across the three session sources 4ms (3ms|0ms)
 at <ScriptBlock>, C:\Users\DanMoisan\repos\drm-copilot\.claude\worktrees\agent-add102e7ba6e997d5\tests\scripts\claude-hooks\enforce-powershell-batch-budget.Tests.ps1:309
 ParameterBindingException: A parameter cannot be found that matches parameter name 'ReadSessionIdFile'.
[-] enforce-powershell-batch-budget.ps1.session identity, containment, and rehydrate filter.sanitizes a hostile session id into the state-file name pattern 8ms (8ms|0ms)
 at $leaf | Should -Match '^powershell-batch-budget\.[A-Za-z0-9._-]+\.json$', C:\Users\DanMoisan\repos\drm-copilot\.claude\worktrees\agent-add102e7ba6e997d5\tests\scripts\claude-hooks\enforce-powershell-batch-budget.Tests.ps1:358
 at <ScriptBlock>, C:\Users\DanMoisan\repos\drm-copilot\.claude\worktrees\agent-add102e7ba6e997d5\tests\scripts\claude-hooks\enforce-powershell-batch-budget.Tests.ps1:358
 Expected regular expression '^powershell-batch-budget\.[A-Za-z0-9._-]+\.json$' to match 'passwd.json', but it did not match.
[-] enforce-powershell-batch-budget.ps1.session identity, containment, and rehydrate filter.records a relative candidate path 3ms (2ms|0ms)
 at <ScriptBlock>, C:\Users\DanMoisan\repos\drm-copilot\.claude\worktrees\agent-add102e7ba6e997d5\tests\scripts\claude-hooks\enforce-powershell-batch-budget.Tests.ps1:365
 ParameterBindingException: A parameter cannot be found that matches parameter name 'Root'.
[-] enforce-powershell-batch-budget.ps1.session identity, containment, and rehydrate filter.records an absolute candidate path under the resolved root 11ms (11ms|0ms)
 at <ScriptBlock>, C:\Users\DanMoisan\repos\drm-copilot\.claude\worktrees\agent-add102e7ba6e997d5\tests\scripts\claude-hooks\enforce-powershell-batch-budget.Tests.ps1:375
 ParameterBindingException: A parameter cannot be found that matches parameter name 'Root'.
[-] enforce-powershell-batch-budget.ps1.session identity, containment, and rehydrate filter.discards an absolute candidate path outside the resolved root 3ms (2ms|0ms)
 at <ScriptBlock>, C:\Users\DanMoisan\repos\drm-copilot\.claude\worktrees\agent-add102e7ba6e997d5\tests\scripts\claude-hooks\enforce-powershell-batch-budget.Tests.ps1:385
 ParameterBindingException: A parameter cannot be found that matches parameter name 'Root'.
[-] enforce-powershell-batch-budget.ps1.session identity, containment, and rehydrate filter.records an in-root absolute path that differs from the root only in letter case 2ms (2ms|0ms)
 at <ScriptBlock>, C:\Users\DanMoisan\repos\drm-copilot\.claude\worktrees\agent-add102e7ba6e997d5\tests\scripts\claude-hooks\enforce-powershell-batch-budget.Tests.ps1:396
 ParameterBindingException: A parameter cannot be found that matches parameter name 'Root'.
[-] enforce-powershell-batch-budget.ps1.session identity, containment, and rehydrate filter.admits three in-root production files when the persisted state already holds an out-of-root entry 14ms (14ms|0ms)
 at $script:budgetDecisions[2].hookSpecificOutput.permissionDecision | Should -Be 'allow', C:\Users\DanMoisan\repos\drm-copilot\.claude\worktrees\agent-add102e7ba6e997d5\tests\scripts\claude-hooks\enforce-powershell-batch-budget.Tests.ps1:426
 at <ScriptBlock>, C:\Users\DanMoisan\repos\drm-copilot\.claude\worktrees\agent-add102e7ba6e997d5\tests\scripts\claude-hooks\enforce-powershell-batch-budget.Tests.ps1:426
 Expected strings to be the same, but they were different.
 Expected length: 5
 Actual length:   4
 Strings differ at index 0.
 Expected: 'allow'
 But was:  'deny'
            ^
Tests completed in 1.04s
Tests Passed: 23, Failed: 10, Skipped: 0, Inconclusive: 0, NotRun: 0
Processing code coverage result.
Covered 2.06% / 0%. 10,567 analyzed Commands in 88 Files.
```

ANSI colour escape sequences present in the raw console stream have been removed from the block
above; no other character was altered.

## Failure count

Form B `failures` attribute: **10**. Form A process exit code: **10**. Both equal the count of
exactly 10 that [P2-T3] requires.

The suite holds 33 tests, of which 23 passed. The pre-edit suite held 23 tests, so every pre-existing
test still passes and the failing set is exactly the ten added by [P2-T2]. This is what rules out the
"more than 10" branch of [P2-T3], under which a pre-existing test broken by the edit would have to be
repaired before the phase continues.

## Observed failure mechanism against the plan's derivation

Numbering the titles in the order [P2-T2] lists them:

| # | Title | Plan's predicted mechanism | Observed mechanism | Match |
| --- | --- | --- | --- | --- |
| 1 | `composes the state-file name from CLAUDE_SESSION_ID when the environment supplies it` | binds; fails on asserted value carrying the literal `default` | value: `Expected 'powershell-batch-budget.env-session-42.json' But was 'powershell-batch-budget.default.json'` | **yes** |
| 2 | `composes the state-file name from the session-id state file when the environment is empty` | terminating parameter-binding error on the session-id-file read seam | `ParameterBindingException: A parameter cannot be found that matches parameter name 'ReadSessionIdFile'.` | **yes** |
| 3 | `composes a worktree-derived state-file name when both sources are empty` | binds; fails on asserted value carrying the literal `default` | value: the regex `^powershell-batch-budget\.worktree-repo-[0-9a-f]{8}\.json$` did not match `powershell-batch-budget.default.json` | **yes** |
| 4 | `composes pairwise different state-file names across the three session sources` | binds; fails on asserted value | `ParameterBindingException: ... 'ReadSessionIdFile'.` | **no — see below** |
| 5 | `sanitizes a hostile session id into the state-file name pattern` | binds; fails on an unsanitized session id | value: the name pattern did not match `passwd.json`, the unsanitized id having split the composed path | **yes** |
| 6 | `records a relative candidate path` | terminating parameter-binding error on the explicit `-Root '/repo'` | `ParameterBindingException: ... 'Root'.` | **yes** |
| 7 | `records an absolute candidate path under the resolved root` | terminating parameter-binding error on the explicit `-Root '/repo'` | `ParameterBindingException: ... 'Root'.` | **yes** |
| 8 | `discards an absolute candidate path outside the resolved root` | terminating parameter-binding error on the explicit `-Root '/repo'` | `ParameterBindingException: ... 'Root'.` | **yes** |
| 9 | `records an in-root absolute path that differs from the root only in letter case` | terminating parameter-binding error on the explicit `-Root '/repo'` | `ParameterBindingException: ... 'Root'.` | **yes** |
| 10 | `admits three in-root production files when the persisted state already holds an out-of-root entry` | the persisted out-of-root entry is rehydrated unfiltered and occupies a production slot, so the third in-root file is denied | value: third decision `Expected 'allow' But was 'deny'` | **yes** |

Nine of the ten mechanisms match the plan's derivation exactly. The binding errors confirm the
plan's supporting citation that `Invoke-PowerShellBatchBudgetDecision` carries `[CmdletBinding()]`
(`.claude/hooks/enforce-powershell-batch-budget.ps1:109`), under which an undeclared parameter is a
terminating error Pester records as a failure; `Invoke-PowerShellBatchBudgetHook` carries the same
attribute at line 153, which is what makes the `ReadSessionIdFile` case terminate identically.

### Deviation on test 4, recorded rather than adjusted

The plan's derivation paragraph places test 4 in the group that "bind successfully and fail on the
asserted value instead". It failed on a `ReadSessionIdFile` parameter-binding error instead. The
cause is a constraint the derivation did not account for: test 4 compares names composed across all
**three** session sources, and the second of those sources is the `current-session-id` state file,
which the plan's own design constraints make reachable only "through a new optional scriptblock seam
so the Pester suite stays filesystem-free". Driving source 2 therefore requires passing that seam,
and passing it before [P2-T4] declares it is a binding error. The alternative — reaching source 2
through the default seam by placing a real `current-session-id` file on disk — is barred by the
filesystem prohibition in `.claude/rules/general-unit-test.md`.

Neither the count nor any name changed as a result: test 4 still fails before the fix, the count is
still exactly 10, and the ten names are still exactly the ten [P2-T2] enumerates, which is what
[P2-T3] asserts. Only the explanatory attribution of test 4 to the value-failure group rather than
the binding-failure group is inaccurate. The expectation was not lowered or otherwise adjusted to
match an observed result.

### Note on the out-of-root fixture constants

[P2-T2] fixes the out-of-root fixture value as the synthetic constant
`C:/synthetic-out-of-root/scratchpad/out_of_root_fixture.py`. That constant is used verbatim for
test 10, whose persisted state entry is filtered on containment alone and is therefore
extension-agnostic.

Test 8 cannot use it. `Invoke-PowerShellBatchBudgetDecision` returns `allow` with
`shouldWriteState = $false` for any path not matching `\.(ps1|psm1|psd1)$`
(`.claude/hooks/enforce-powershell-batch-budget.ps1:122-125`), and that extension guard precedes the
containment test. A `.py` candidate would therefore satisfy every assertion of test 8 both before and
after [P2-T4], by way of the extension filter rather than containment, making the test unable to
fail — the defect class the plan contract's wrap-tolerant authoring rules exist to prevent. Test 8
accordingly uses a PowerShell-extension sibling under the same fixed synthetic root,
`C:/synthetic-out-of-root/scratchpad/out_of_root_fixture.ps1`, declared as a suite constant next to
the first. Both constants are synthetic, fixed by the suite, never created on disk, and carry no
dependence on transient local state, which is the property [P2-T2] requires of the fixture.
