# [P3-T3] Python batch-budget hook — fail-before evidence

Timestamp: 2026-08-29T16-05

Command: `pwsh -NoProfile -Command "Import-Module ./scripts/powershell/PoshQC/PoshQC.psd1 -Force; Invoke-PoshQCTest -Root (Get-Location).Path -SettingsPath 'scripts/powershell/PoshQC/settings/pester.runsettings.psd1' -ScanFolders 'tests/scripts/claude-hooks/enforce-python-batch-budget.Tests.ps1'"`

EXIT_CODE: 10

ExpectedExitCode: 10

Output Summary: The Form A run exited 10. Pester reported `Tests Passed: 22, Failed: 10, Skipped: 0, Inconclusive: 0, NotRun: 0`. The Form B extraction of `artifacts/pester/pester-junit.xml` reported `root=Pester tests=32 failures=10`, and the ten failing `testcase` names are exactly the ten `It` titles added by [P3-T2]. This is the expected fail-before state for [P3-T4].

## Form A console output (verbatim)

```

Starting discovery in 1 files.
Discovery found 32 tests in 281ms.
Starting code coverage.
Running tests.
[-] enforce-python-batch-budget.ps1.session identity, containment, and rehydrate filter.composes the state-file name from CLAUDE_SESSION_ID when the environment supplies it 36ms (35ms|1ms)
 at (Split-Path -Path $script:writtenStateFile -Leaf) | Should -Be 'python-batch-budget.env-session-42.json', C:\Users\DanMoisan\repos\drm-copilot\.claude\worktrees\agent-add102e7ba6e997d5\tests\scripts\claude-hooks\enforce-python-batch-budget.Tests.ps1:258
 at <ScriptBlock>, C:\Users\DanMoisan\repos\drm-copilot\.claude\worktrees\agent-add102e7ba6e997d5\tests\scripts\claude-hooks\enforce-python-batch-budget.Tests.ps1:258
 Expected strings to be the same, but they were different.
 Expected length: 39
 Actual length:   32
 Strings differ at index 20.
 Expected: 'python-batch-budget.env-session-42.json'
 But was:  'python-batch-budget.default.json'
            --------------------^
[-] enforce-python-batch-budget.ps1.session identity, containment, and rehydrate filter.composes the state-file name from the session-id state file when the environment is empty 4ms (3ms|1ms)
 at <ScriptBlock>, C:\Users\DanMoisan\repos\drm-copilot\.claude\worktrees\agent-add102e7ba6e997d5\tests\scripts\claude-hooks\enforce-python-batch-budget.Tests.ps1:266
 ParameterBindingException: A parameter cannot be found that matches parameter name 'ReadSessionIdFile'.
[-] enforce-python-batch-budget.ps1.session identity, containment, and rehydrate filter.composes a worktree-derived state-file name when both sources are empty 10ms (9ms|1ms)
 at (Split-Path -Path $script:writtenStateFile -Leaf) | Should -Match '^python-batch-budget\.worktree-repo-[0-9a-f]{8}\.json$', C:\Users\DanMoisan\repos\drm-copilot\.claude\worktrees\agent-add102e7ba6e997d5\tests\scripts\claude-hooks\enforce-python-batch-budget.Tests.ps1:291
 at <ScriptBlock>, C:\Users\DanMoisan\repos\drm-copilot\.claude\worktrees\agent-add102e7ba6e997d5\tests\scripts\claude-hooks\enforce-python-batch-budget.Tests.ps1:291
 Expected regular expression '^python-batch-budget\.worktree-repo-[0-9a-f]{8}\.json$' to match 'python-batch-budget.default.json', but it did not match.
[-] enforce-python-batch-budget.ps1.session identity, containment, and rehydrate filter.composes pairwise different state-file names across the three session sources 3ms (3ms|0ms)
 at <ScriptBlock>, C:\Users\DanMoisan\repos\drm-copilot\.claude\worktrees\agent-add102e7ba6e997d5\tests\scripts\claude-hooks\enforce-python-batch-budget.Tests.ps1:299
 ParameterBindingException: A parameter cannot be found that matches parameter name 'ReadSessionIdFile'.
[-] enforce-python-batch-budget.ps1.session identity, containment, and rehydrate filter.sanitizes a hostile session id into the state-file name pattern 8ms (7ms|0ms)
 at $leaf | Should -Match '^python-batch-budget\.[A-Za-z0-9._-]+\.json$', C:\Users\DanMoisan\repos\drm-copilot\.claude\worktrees\agent-add102e7ba6e997d5\tests\scripts\claude-hooks\enforce-python-batch-budget.Tests.ps1:348
 at <ScriptBlock>, C:\Users\DanMoisan\repos\drm-copilot\.claude\worktrees\agent-add102e7ba6e997d5\tests\scripts\claude-hooks\enforce-python-batch-budget.Tests.ps1:348
 Expected regular expression '^python-batch-budget\.[A-Za-z0-9._-]+\.json$' to match 'passwd.json', but it did not match.
[-] enforce-python-batch-budget.ps1.session identity, containment, and rehydrate filter.records a relative candidate path 2ms (2ms|0ms)
 at <ScriptBlock>, C:\Users\DanMoisan\repos\drm-copilot\.claude\worktrees\agent-add102e7ba6e997d5\tests\scripts\claude-hooks\enforce-python-batch-budget.Tests.ps1:355
 ParameterBindingException: A parameter cannot be found that matches parameter name 'Root'.
[-] enforce-python-batch-budget.ps1.session identity, containment, and rehydrate filter.records an absolute candidate path under the resolved root 2ms (2ms|0ms)
 at <ScriptBlock>, C:\Users\DanMoisan\repos\drm-copilot\.claude\worktrees\agent-add102e7ba6e997d5\tests\scripts\claude-hooks\enforce-python-batch-budget.Tests.ps1:365
 ParameterBindingException: A parameter cannot be found that matches parameter name 'Root'.
[-] enforce-python-batch-budget.ps1.session identity, containment, and rehydrate filter.discards an absolute candidate path outside the resolved root 2ms (2ms|0ms)
 at <ScriptBlock>, C:\Users\DanMoisan\repos\drm-copilot\.claude\worktrees\agent-add102e7ba6e997d5\tests\scripts\claude-hooks\enforce-python-batch-budget.Tests.ps1:375
 ParameterBindingException: A parameter cannot be found that matches parameter name 'Root'.
[-] enforce-python-batch-budget.ps1.session identity, containment, and rehydrate filter.records an in-root absolute path that differs from the root only in letter case 2ms (2ms|0ms)
 at <ScriptBlock>, C:\Users\DanMoisan\repos\drm-copilot\.claude\worktrees\agent-add102e7ba6e997d5\tests\scripts\claude-hooks\enforce-python-batch-budget.Tests.ps1:386
 ParameterBindingException: A parameter cannot be found that matches parameter name 'Root'.
[-] enforce-python-batch-budget.ps1.session identity, containment, and rehydrate filter.admits three in-root production files when the persisted state already holds an out-of-root entry 15ms (15ms|1ms)
 at $script:budgetDecisions[2].hookSpecificOutput.permissionDecision | Should -Be 'allow', C:\Users\DanMoisan\repos\drm-copilot\.claude\worktrees\agent-add102e7ba6e997d5\tests\scripts\claude-hooks\enforce-python-batch-budget.Tests.ps1:416
 at <ScriptBlock>, C:\Users\DanMoisan\repos\drm-copilot\.claude\worktrees\agent-add102e7ba6e997d5\tests\scripts\claude-hooks\enforce-python-batch-budget.Tests.ps1:416
 Expected strings to be the same, but they were different.
 Expected length: 5
 Actual length:   4
 Strings differ at index 0.
 Expected: 'allow'
 But was:  'deny'
            ^
Tests completed in 961ms
Tests Passed: 22, Failed: 10, Skipped: 0, Inconclusive: 0, NotRun: 0
Processing code coverage result.
Covered 2.05% / 0%. 10,632 analyzed Commands in 88 Files.
```

Note on the replayed summary line: the plan's Form B paragraph cautions that a failing run may exit inside Pester before the `Tests Passed: ` line is replayed and before `artifacts/pester/pester-junit.xml` is written. Neither happened here. The summary line was printed and the JUnit file was written, matching what was observed in the Phase 1 and Phase 2 expect-fail runs. The blocked branch was therefore not taken.

## Form B extraction

Command: `pwsh -NoProfile -Command '[xml]$junit = Get-Content -LiteralPath "artifacts/pester/pester-junit.xml" -Raw; $root = $junit.SelectSingleNode("/*"); "root={0} tests={1} failures={2}" -f $root.Name, $root.GetAttribute("tests"), $root.GetAttribute("failures"); $junit.SelectNodes("//testcase[failure]") | ForEach-Object { $_.name }'`

EXIT_CODE: 0

Output:

```
root=Pester tests=32 failures=10
enforce-python-batch-budget.ps1.session identity, containment, and rehydrate filter.composes the state-file name from CLAUDE_SESSION_ID when the environment supplies it
enforce-python-batch-budget.ps1.session identity, containment, and rehydrate filter.composes the state-file name from the session-id state file when the environment is empty
enforce-python-batch-budget.ps1.session identity, containment, and rehydrate filter.composes a worktree-derived state-file name when both sources are empty
enforce-python-batch-budget.ps1.session identity, containment, and rehydrate filter.composes pairwise different state-file names across the three session sources
enforce-python-batch-budget.ps1.session identity, containment, and rehydrate filter.sanitizes a hostile session id into the state-file name pattern
enforce-python-batch-budget.ps1.session identity, containment, and rehydrate filter.records a relative candidate path
enforce-python-batch-budget.ps1.session identity, containment, and rehydrate filter.records an absolute candidate path under the resolved root
enforce-python-batch-budget.ps1.session identity, containment, and rehydrate filter.discards an absolute candidate path outside the resolved root
enforce-python-batch-budget.ps1.session identity, containment, and rehydrate filter.records an in-root absolute path that differs from the root only in letter case
enforce-python-batch-budget.ps1.session identity, containment, and rehydrate filter.admits three in-root production files when the persisted state already holds an out-of-root entry
```

## Failing-name set versus the [P2-T2] title list

The Form B `failures` count is **exactly 10**, matching the plan's prediction. The ten failing names are exactly the ten `It` titles enumerated in [P2-T2] and re-authored under the Python naming by [P3-T2], in the order [P2-T2] lists them:

| # | Title | Observed failure mechanism | Mechanism predicted by [P2-T3] |
| --- | --- | --- | --- |
| 1 | composes the state-file name from CLAUDE_SESSION_ID when the environment supplies it | Asserted value: composed leaf was `python-batch-budget.default.json` | Asserted value | matches |
| 2 | composes the state-file name from the session-id state file when the environment is empty | ParameterBindingException on `ReadSessionIdFile` | Parameter binding | matches |
| 3 | composes a worktree-derived state-file name when both sources are empty | Asserted value: composed leaf was `python-batch-budget.default.json` | Asserted value | matches |
| 4 | composes pairwise different state-file names across the three session sources | ParameterBindingException on `ReadSessionIdFile` | Asserted value | **mismatch, see below** |
| 5 | sanitizes a hostile session id into the state-file name pattern | Asserted value: composed leaf was `passwd.json` | Asserted value | matches |
| 6 | records a relative candidate path | ParameterBindingException on `Root` | Parameter binding | matches |
| 7 | records an absolute candidate path under the resolved root | ParameterBindingException on `Root` | Parameter binding | matches |
| 8 | discards an absolute candidate path outside the resolved root | ParameterBindingException on `Root` | Parameter binding | matches |
| 9 | records an in-root absolute path that differs from the root only in letter case | ParameterBindingException on `Root` | Parameter binding | matches |
| 10 | admits three in-root production files when the persisted state already holds an out-of-root entry | Third candidate denied: the persisted out-of-root entry is rehydrated unfiltered and occupies a production slot | Rehydrate filter absent | matches |

**Mechanism mismatch on test 4, recorded and not treated as a failure of this task.** [P2-T3] derives the count of 10 by predicting that "Tests 1, 3, 4, and 5 bind successfully and fail on the asserted value instead". Test 4 in fact fails on a terminating `ParameterBindingException` for `ReadSessionIdFile`, because the test drives all three session sources and therefore passes the `-ReadSessionIdFile` seam that the unmodified hook does not declare. The plan's acceptance for this task is stated over the failing **count** and the failing **name set**, both of which match exactly; the per-test mechanism table in [P2-T3] is a derivation of the count, not an acceptance condition. This is the same class of mismatch recorded in Phase 2 and is reported rather than adjusted. The recorded expectation was not altered to match the observed result.

## Containment fixture falsifiability

The plan's Phase 3 preamble carries forward the Phase 2 concern that a containment fixture must be able to fail. The `.py` fixture is extension-appropriate for the Python hook and the fixture is therefore falsifiable. Verified at `.claude/hooks/enforce-python-batch-budget.ps1:119-122`: `Invoke-PythonBatchBudgetDecision` normalizes the candidate on line 119 and applies its extension filter `if ($normalized -notmatch '\.py$')` on line 120, returning early on a non-`.py` path. The fixture `C:/synthetic-out-of-root/scratchpad/out_of_root_fixture.py` matches `\.py$`, so it passes that filter and reaches the position where [P3-T4] inserts the containment check. Test 8 is observed above to fail before the fix, which is direct proof of falsifiability rather than an argument for it. No synthetic sibling fixture with a second extension is required for the Python suite.
