# Full-Suite Pester Coverage Read (P10-T5)

Timestamp: 2026-10-01T23-02
Task: P10-T5
Loop iteration: 2
Route: sh-wrapped invocation (scratchpad script outside the repository); the child `pwsh` process is the one the plan names.

## Step 1 — Self-hosted PoshQC test run (child process)

Command: pwsh -NoProfile -Command "Import-Module ./scripts/powershell/PoshQC/PoshQC.psd1 -Force; Invoke-PoshQCTest -Root (Get-Location).Path"
Child exit code: 2
Console summary: `Tests Passed: 6476, Failed: 2, Skipped: 10, Inconclusive: 0, NotRun: 0`; `Covered 95.72% / 0%. 16,632 analyzed Commands in 127 Files.`

## Step 2 — P0-T32 JUnit read against this run's file

JUnit file last written 2026-10-01T23:02:13Z (this run, after P10-T4).
Output:

```
Tests=6488 Failures=2 Errors=0
enforce-pr-author-skill.ps1.allowed commands.allows gh pr create --body-file artifacts/pr_body_12.md when context exists
Every registered Codex PreToolUse handler accepts every tool name its matcher admits.allows every registered handler for every tool name its own matcher admits
```

- Root `failures`: 2. Root `errors`: 0. Failing test-case names printed: 2.
- Condition (a): root `errors` is 0 — holds.
- Condition (b): both failing names are in the P0-T32 failing set — holds.
- Condition (c): exit code 2 equals root `failures` 2, which equals the 2 names printed — holds.

## Step 3 — Coverage read

Coverage file: `artifacts/pester/powershell-coverage.xml`, last written 2026-10-01T23:00:35Z (during this run).
Command: [xml]$x=Get-Content -Raw -LiteralPath artifacts/pester/powershell-coverage.xml; foreach ($n in @('OrchestratorStateRemediationAccounting.psm1','OrchestratorStateReceipts.psm1')) { $s=@($x.SelectNodes('//sourcefile') | Where-Object { $nm=$_.GetAttribute('name').Replace([string][char]92,'/'); $nm -eq $n -or $nm.EndsWith('/' + $n) }); $cv=0; $ms=0; foreach ($f in $s) { $l=$f.SelectSingleNode("counter[@type='LINE']"); if ($l) { $cv+=[int]$l.GetAttribute('covered'); $ms+=[int]$l.GetAttribute('missed') } }; "$n Files=$($s.Count) Covered=$cv Missed=$ms" }
Output:

```
OrchestratorStateRemediationAccounting.psm1 Files=1 Covered=100 Missed=0
OrchestratorStateReceipts.psm1 Files=1 Covered=117 Missed=0
```

EXIT_CODE: 2
ExpectedExitCode: 2

## Output Summary:

- All three conditions hold, so ExpectedExitCode is the observed exit code 2; EXIT_CODE equals ExpectedExitCode.
- Recorded counts: failures 2, errors 0, failing names 2.
- `OrchestratorStateRemediationAccounting.psm1`: Files=1, 100/(100+0) = 1.0000 (100.00%).
- `OrchestratorStateReceipts.psm1`: Files=1, 117/(117+0) = 1.0000 (100.00%).
- Both modules are in the coverage denominator and meet 0.85. Result: PASS.
