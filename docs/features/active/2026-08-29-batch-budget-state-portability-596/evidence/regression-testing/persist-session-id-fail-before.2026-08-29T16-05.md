# [P1-T3] persist-session-id.Tests.ps1 — fail-before evidence

Timestamp: 2026-08-29T16-05

Command: two commands, run in this order from the repository root of the executing worktree.

1. Form A, scoped:
   `pwsh -NoProfile -Command "Import-Module ./scripts/powershell/PoshQC/PoshQC.psd1 -Force; Invoke-PoshQCTest -Root (Get-Location).Path -SettingsPath 'scripts/powershell/PoshQC/settings/pester.runsettings.psd1' -ScanFolders 'tests/scripts/claude-hooks/persist-session-id.Tests.ps1'"`
2. Form B:
   `pwsh -NoProfile -Command '[xml]$junit = Get-Content -LiteralPath "artifacts/pester/pester-junit.xml" -Raw; $root = $junit.SelectSingleNode("/*"); "root={0} tests={1} failures={2}" -f $root.Name, $root.GetAttribute("tests"), $root.GetAttribute("failures"); $junit.SelectNodes("//testcase[failure]") | ForEach-Object { $_.name }'`

EXIT_CODE: 3

ExpectedExitCode: 3

The Form A process exit code is 3, which is non-zero as this `[expect-fail]` task requires.
`Run.Exit = $true` in `scripts/powershell/PoshQC/settings/pester.runsettings.psd1:4` makes Pester
terminate the process with a non-zero code when the run has failures, so this exit code is a real
pass/fail signal rather than an infrastructure error. The Form B command exited 0.

Output Summary: The scoped run discovered 16 tests in 1 file and recorded exactly **3 failures** and
13 passes. The three failing test names match, entry for entry, the three the plan predicted in
[P1-T3]. The second new `It`, titled `still appends the session line through the AppendLine seam when
CLAUDE_ENV_FILE is set`, passed as the plan predicted and is correctly absent from the failing set.
`artifacts/pester/pester-junit.xml` **was** produced by this failing run, so the blocked branch that
[P1-T3] carries for an absent result file was not taken.

## Verbatim Form A console output

```
Starting discovery in 1 files.
Discovery found 16 tests in 144ms.
Starting code coverage.
Running tests.
[-] persist-session-id.ps1.Invoke-PersistSessionIdHook.appends CLAUDE_SESSION_ID= to the env file when CLAUDE_ENV_FILE is set 21ms (20ms|1ms)
 at $script:stateCalls.Count | Should -Be 1, C:\Users\DanMoisan\repos\drm-copilot\.claude\worktrees\agent-add102e7ba6e997d5\tests\scripts\claude-hooks\persist-session-id.Tests.ps1:99
 at <ScriptBlock>, C:\Users\DanMoisan\repos\drm-copilot\.claude\worktrees\agent-add102e7ba6e997d5\tests\scripts\claude-hooks\persist-session-id.Tests.ps1:99
 Expected 1, but got 0.
[-] persist-session-id.ps1.Invoke-PersistSessionIdHook.writes the session id through the WriteStateFile seam when CLAUDE_ENV_FILE is set 4ms (4ms|1ms)
 at $script:stateCalls.Count | Should -Be 1, C:\Users\DanMoisan\repos\drm-copilot\.claude\worktrees\agent-add102e7ba6e997d5\tests\scripts\claude-hooks\persist-session-id.Tests.ps1:118
 at <ScriptBlock>, C:\Users\DanMoisan\repos\drm-copilot\.claude\worktrees\agent-add102e7ba6e997d5\tests\scripts\claude-hooks\persist-session-id.Tests.ps1:118
 Expected 1, but got 0.
[-] persist-session-id.ps1.default writers (mocked cmdlets, no disk access).appends the session line via Add-Content by default when CLAUDE_ENV_FILE is set 183ms (183ms|0ms)
 at Should -Invoke Set-Content -Times 1 -Exactly, C:\Users\DanMoisan\repos\drm-copilot\.claude\worktrees\agent-add102e7ba6e997d5\tests\scripts\claude-hooks\persist-session-id.Tests.ps1:223
 at <ScriptBlock>, C:\Users\DanMoisan\repos\drm-copilot\.claude\worktrees\agent-add102e7ba6e997d5\tests\scripts\claude-hooks\persist-session-id.Tests.ps1:223
 Expected Set-Content in module PoshQC to be called 1 times exactly, but was called 0 times
Tests completed in 843ms
Tests Passed: 13, Failed: 3, Skipped: 0, Inconclusive: 0, NotRun: 0
Processing code coverage result.
Covered 0.44% / 0%. 10,563 analyzed Commands in 88 Files.
```

ANSI colour escape sequences present in the raw console stream have been removed from the block
above; no other character was altered.

## Verbatim Form B output

```
root=Pester tests=16 failures=3
persist-session-id.ps1.Invoke-PersistSessionIdHook.appends CLAUDE_SESSION_ID= to the env file when CLAUDE_ENV_FILE is set
persist-session-id.ps1.Invoke-PersistSessionIdHook.writes the session id through the WriteStateFile seam when CLAUDE_ENV_FILE is set
persist-session-id.ps1.default writers (mocked cmdlets, no disk access).appends the session line via Add-Content by default when CLAUDE_ENV_FILE is set
```

## Failure count

Form B `failures` attribute: **3**. This equals the count of exactly 3 that [P1-T3] requires. The
recorded expectation was not adjusted to match an observed result; the observed result matched the
recorded expectation on the first run.

## The three failing test names, matched against the plan's enumeration

| # | Plan's predicted failing test | Observed | Failing assertion and cause |
| --- | --- | --- | --- |
| i | the new `It` titled `writes the session id through the WriteStateFile seam when CLAUDE_ENV_FILE is set` | **Failed** | `$script:stateCalls.Count \| Should -Be 1` at line 118; `Expected 1, but got 0`. The `env-file` branch of `Invoke-PersistSessionIdHook` performs no `WriteStateFile` invocation before [P1-T4]. |
| ii | the pre-existing `It` titled `appends CLAUDE_SESSION_ID=<id> to the env file when CLAUDE_ENV_FILE is set` | **Failed** | `$script:stateCalls.Count \| Should -Be 1` at line 99; `Expected 1, but got 0`. This is the assertion [P1-T2] inverted at line 99, which previously read `Should -Be 0`. |
| iii | the pre-existing `It` titled `appends the session line via Add-Content by default when CLAUDE_ENV_FILE is set` | **Failed** | `Should -Invoke Set-Content -Times 1 -Exactly` at line 223; `Expected Set-Content in module PoshQC to be called 1 times exactly, but was called 0 times`. This is the assertion [P1-T2] inverted at line 182 of the pre-edit file. |

### Test-name rendering note

The JUnit `name` attribute for failing test (ii) renders as
`appends CLAUDE_SESSION_ID= to the env file when CLAUDE_ENV_FILE is set`, without the `<id>` token
that the `It` title carries in the source file at `tests/scripts/claude-hooks/persist-session-id.Tests.ps1`.
The angle-bracketed token is elided by the reporter in both the Form A console stream and the Form B
JUnit attribute. The source `It` title is unchanged and still reads
`appends CLAUDE_SESSION_ID=<id> to the env file when CLAUDE_ENV_FILE is set`; the two names denote
the same test. This is a reporter rendering difference, not a title mismatch.

## The non-witness, confirmed absent from the failing set

The `It` titled `still appends the session line through the AppendLine seam when CLAUDE_ENV_FILE is
set` does **not** appear among the three failing names. This is the outcome [P1-T3] requires: the
`env-file` branch already invokes the `AppendLine` seam before [P1-T4], and the pre-existing
assertion `$script:appendCalls.Count | Should -Be 1` already holds for that case, so the new `It`
passes before the fix by construction. It becomes load-bearing at [P1-T6], where it is what proves
the added state-file write did not displace the env-file append.

## Ordering deviation from the plan's Form B preamble, recorded for audit

The plan's "Form B" paragraph states that on a failing run "Pester exits inside the run, so that
replayed line is not printed", and for that reason attaches a blocked branch to every Form B use
after an expected-failing run. Neither consequence was observed here: the summary line
`Tests Passed: 13, Failed: 3, Skipped: 0, Inconclusive: 0, NotRun: 0` **was** printed by this failing
run, and `artifacts/pester/pester-junit.xml` **was** written before the process exited 3. The
conservative blocked branch was therefore unnecessary in this instance. It is recorded here rather
than acted on, because the plan's caution is a guard against an unobserved ordering and this single
observation does not establish that the ordering holds in every failure mode.
