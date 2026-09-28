# [P1-T6] persist-session-id.Tests.ps1 — pass-after evidence

Timestamp: 2026-08-29T16-05

Command: two commands, run in this order from the repository root of the executing worktree. The
Form A command is character-for-character the same one [P1-T3] ran.

1. Form A, scoped:
   `pwsh -NoProfile -Command "Import-Module ./scripts/powershell/PoshQC/PoshQC.psd1 -Force; Invoke-PoshQCTest -Root (Get-Location).Path -SettingsPath 'scripts/powershell/PoshQC/settings/pester.runsettings.psd1' -ScanFolders 'tests/scripts/claude-hooks/persist-session-id.Tests.ps1'"`
2. Form B:
   `pwsh -NoProfile -Command '[xml]$junit = Get-Content -LiteralPath "artifacts/pester/pester-junit.xml" -Raw; $root = $junit.SelectSingleNode("/*"); "root={0} tests={1} failures={2}" -f $root.Name, $root.GetAttribute("tests"), $root.GetAttribute("failures"); $junit.SelectNodes("//testcase[failure]") | ForEach-Object { $_.name }'`

EXIT_CODE: 0

Both commands exited 0. The Form A run returned normally rather than through Pester's failure exit,
so no blocked branch applies and the JUnit result file was written before the replayed summary.

Output Summary: All **16 of 16** tests in the suite pass, with a failed count of 0. The Form B
`failures` attribute is **0**. Both `It` blocks added by [P1-T2] are present among the Form B
`testcase` names with no `failure` child. The three tests that failed at [P1-T3] now pass, and no
pre-existing test in the suite regressed. Per-file LINE coverage for `.claude/hooks/persist-session-id.ps1`
is **88.1 percent**, above both the 85 percent floor and the 86.8 percent baseline.

## Verbatim Form A console output

```
Starting discovery in 1 files.
Discovery found 16 tests in 140ms.
Starting code coverage.
Running tests.
[+] C:\Users\DanMoisan\repos\drm-copilot\.claude\worktrees\agent-add102e7ba6e997d5\tests\scripts\claude-hooks\persist-session-id.Tests.ps1 845ms (414ms|308ms)
Tests completed in 855ms
Tests Passed: 16, Failed: 0, Skipped: 0, Inconclusive: 0, NotRun: 0
Processing code coverage result.
Covered 0.48% / 0%. 10,567 analyzed Commands in 88 Files.
Wrote Koverage coverage copy: C:\Users\DanMoisan\repos\drm-copilot\.claude\worktrees\agent-add102e7ba6e997d5\artifacts\pester\powershell-coverage.koverage.xml
```

ANSI colour escape sequences present in the raw console stream have been removed from the block
above; no other character was altered.

## The replayed summary line and its five counts

Quoted verbatim: `Tests Passed: 16, Failed: 0, Skipped: 0, Inconclusive: 0, NotRun: 0`

| Count | Value |
| --- | --- |
| Passed | 16 |
| **Failed** | **0** |
| Skipped | 0 |
| Inconclusive | 0 |
| NotRun | 0 |

The failed count is 0, as this task requires.

## Verbatim Form B output

```
root=Pester tests=16 failures=0
```

The `//testcase[failure]` node set is empty, so the command emitted no test names after the summary
line. Form B `failures` count: **0**.

## The two `It` titles added by [P1-T2], confirmed present with no failure child

Both appear in the complete `//testcase` name enumeration of the same result file:

- `persist-session-id.ps1.Invoke-PersistSessionIdHook.writes the session id through the WriteStateFile seam when CLAUDE_ENV_FILE is set`
- `persist-session-id.ps1.Invoke-PersistSessionIdHook.still appends the session line through the AppendLine seam when CLAUDE_ENV_FILE is set`

Because the `//testcase[failure]` node set is empty, neither carries a `failure` child.

The second of the two is what proves the added state-file write did not displace the env-file append:
it asserts one recorded `AppendLine` call to `/env/file` carrying
`CLAUDE_SESSION_ID=ef8e8029-7c73-4346-80c7-5b0ad94b33fe`, and it passes after [P1-T4] as well as
before it.

## Complete testcase enumeration, 16 names

```
persist-session-id.ps1.Get-PersistSessionIdDecision.chooses the env-file channel when CLAUDE_ENV_FILE is set
persist-session-id.ps1.Get-PersistSessionIdDecision.chooses the state-file channel when CLAUDE_ENV_FILE is unset
persist-session-id.ps1.Get-PersistSessionIdDecision.returns action none for malformed JSON
persist-session-id.ps1.Get-PersistSessionIdDecision.returns action none for empty input
persist-session-id.ps1.Get-PersistSessionIdDecision.returns action none when session_id is absent from the payload
persist-session-id.ps1.Invoke-PersistSessionIdHook.appends CLAUDE_SESSION_ID= to the env file when CLAUDE_ENV_FILE is set
persist-session-id.ps1.Invoke-PersistSessionIdHook.writes the session id through the WriteStateFile seam when CLAUDE_ENV_FILE is set
persist-session-id.ps1.Invoke-PersistSessionIdHook.still appends the session line through the AppendLine seam when CLAUDE_ENV_FILE is set
persist-session-id.ps1.Invoke-PersistSessionIdHook.writes the id to the state file (ensuring its directory) when CLAUDE_ENV_FILE is unset
persist-session-id.ps1.Invoke-PersistSessionIdHook.performs no write on malformed JSON
persist-session-id.ps1.Invoke-PersistSessionIdHook.performs no write on empty input
persist-session-id.ps1.Read-HookPayload.returns the standard-input payload when present
persist-session-id.ps1.Read-HookPayload.falls back to CLAUDE_HOOK_INPUT when standard input is empty
persist-session-id.ps1.Read-HookPayload.falls back to CLAUDE_HOOK_INPUT when reading standard input throws
persist-session-id.ps1.default writers (mocked cmdlets, no disk access).appends the session line via Add-Content by default when CLAUDE_ENV_FILE is set
persist-session-id.ps1.default writers (mocked cmdlets, no disk access).writes via Set-Content and creates the directory via New-Item by default when CLAUDE_ENV_FILE is unset
```

The five `Get-PersistSessionIdDecision` tests, which correspond to source lines 42, 52, 62, 68, and
74 of the pre-edit suite, all pass. That is the evidence for the plan's design constraint that
`Get-PersistSessionIdDecision` keeps its return contract exactly and that the change lives only in
`Invoke-PersistSessionIdHook`.

## Coverage observation for the [P1-T4] edit

Form C, run against `artifacts/pester/powershell-coverage.xml` produced by this scoped run:

```
REPO LINE covered=37 missed=7606
.claude/hooks/enforce-powershell-batch-budget.ps1 LINE covered=0 missed=90
.claude/hooks/enforce-python-batch-budget.ps1 LINE covered=0 missed=90
.claude/hooks/persist-session-id.ps1 LINE covered=37 missed=5
```

| File | Covered | Missed | LINE percent |
| --- | --- | --- | --- |
| `.claude/hooks/persist-session-id.ps1` | 37 | 5 | **88.1** |

Derivation: `100 * 37 / (37 + 5) = 88.095…`, recorded to one decimal place as 88.1.

Baseline for this file, from
`evidence/baseline/powershell-test-coverage.2026-08-29T16-05.md`, was **86.8 percent**. The file
moved from 86.8 to 88.1, a rise of 1.3 points, and sits 3.1 points above the 85 percent floor. The
lines [P1-T4] added to the `env-file` branch are covered by the two `It` blocks [P1-T2] added, so the
edit did not dilute the file's coverage. Pester emits no branch counter for PowerShell, so no branch
figure is recorded and no branch gate applies.

The two batch-budget hooks read 0 covered in the table above because this run was **scoped** to the
persist-session-id suite alone and their own suites did not execute. Those zeros are an artefact of
the scan scope, not a coverage regression; the repository-wide figures come from the unscoped run at
[P7-T12].
