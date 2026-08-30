# [P0-T12] PowerShell test and coverage baseline (self-hosted Form A + Form C)

Timestamp: 2026-08-29T20-45

Command: two commands, run in this order.

1. Form A, unscoped:
   `pwsh -NoProfile -Command "Import-Module ./scripts/powershell/PoshQC/PoshQC.psd1 -Force; Invoke-PoshQCTest -Root (Get-Location).Path -SettingsPath 'scripts/powershell/PoshQC/settings/pester.runsettings.psd1'"`
2. Form C, exactly as written in the plan's "Form C" paragraph:
   `pwsh -NoProfile -Command '[xml]$report = Get-Content -LiteralPath "artifacts/pester/powershell-coverage.xml" -Raw; $rootLine = @($report.report.counter) | Where-Object { $_.type -eq "LINE" }; "REPO LINE covered={0} missed={1}" -f $rootLine.covered, $rootLine.missed; foreach ($leaf in @(".claude/hooks/enforce-powershell-batch-budget.ps1", ".claude/hooks/enforce-python-batch-budget.ps1", ".claude/hooks/persist-session-id.ps1")) { foreach ($pkg in @($report.report.package)) { foreach ($sf in @($pkg.sourcefile)) { $full = ($pkg.name + "/" + $sf.name).Replace("\", "/"); if ($full.EndsWith("/" + $leaf)) { $c = @($sf.counter) | Where-Object { $_.type -eq "LINE" }; "{0} LINE covered={1} missed={2}" -f $leaf, $c.covered, $c.missed } } } }'`

EXIT_CODE: 2

ExpectedExitCode: 2

Output Summary: The Form A run discovered 3851 tests across 158 files and exited with process code 2
because 2 tests failed. This is a baseline capture of the tree as found rather than a gate, so
`ExpectedExitCode: 2` is recorded to match the observed integer and the artifact normalizes to pass.
The two failures are pre-existing and unrelated to this feature; they precede every edit this plan
makes. Form C printed the repository-wide LINE counter and **all three** required per-file LINE
counters, so the BLOCKED branch was not taken and [P7-T12] has the four numbers it needs. Baseline
repository-wide LINE coverage is **94.7 percent**; the three in-scope hooks are at **95.6**, **95.6**,
and **86.8 percent** respectively, all already at or above the 85 percent threshold.

## Form A run — observed process exit code

Observed process exit code: **2**. `ExpectedExitCode: 2` is recorded to match, per this task's
instruction to treat a non-zero baseline as the observed state.

Because the run exited non-zero, Pester terminated inside the run (`Run.Exit = $true` in
`scripts/powershell/PoshQC/settings/pester.runsettings.psd1:4`) and the replayed line beginning
`Tests Passed: ` was **not printed**. The plan's acceptance for that line is conditional on a
zero-exit Form A run, so no `Tests Passed: ` line is quoted here. The counts are instead read from
the JUnit result file, which the run did produce.

### Counts read from the Pester JUnit result file

Supporting command:
`pwsh -NoProfile -Command '[xml]$junit = Get-Content -LiteralPath "artifacts/pester/pester-junit.xml" -Raw; $root = $junit.SelectSingleNode("/*"); "root={0} tests={1} failures={2}" -f $root.Name, $root.GetAttribute("tests"), $root.GetAttribute("failures"); $junit.SelectNodes("//testcase[failure]") | ForEach-Object { $_.name }'`

Verbatim output:

```
root=Pester tests=3851 failures=2
enforce-pr-author-skill.ps1.allowed commands.allows gh pr create --body-file artifacts/pr_body_12.md when context exists
Every registered Codex PreToolUse handler accepts every tool name its matcher admits.allows every registered handler for every tool name its own matcher admits
```

- Total tests: 3851
- Failures: 2
- Failing test names, verbatim:
  1. `enforce-pr-author-skill.ps1.allowed commands.allows gh pr create --body-file artifacts/pr_body_12.md when context exists`
  2. `Every registered Codex PreToolUse handler accepts every tool name its matcher admits.allows every registered handler for every tool name its own matcher admits`

### Pre-existing condition statement

Both failures are **pre-existing**. Neither test belongs to the three Pester suites this plan edits
(`persist-session-id.Tests.ps1`, `enforce-powershell-batch-budget.Tests.ps1`,
`enforce-python-batch-budget.Tests.ps1`), and neither exercises any of the three hooks this feature
changes. The first concerns the PR-author skill hook's allowed-command list; the second concerns the
Codex PreToolUse handler matcher coverage. The [P0-T5] git capture confirms no tracked file outside
this feature folder had been modified when this run was taken. No repair was attempted, consistent
with the plan's instruction not to repair a pre-existing failure during Phase 0.

This exit code 2 is the same underlying condition that [P0-T11] recorded through the MCP runner; the
`stderr_excerpt` publish-verification lines observed there appear in this run's console output as
stderr emitted by a **passing** suite (`Invoke-ReleaseTagPush.Tests.ps1`, marked `[+]`), so they are
not themselves failures.

### Form A console output

The Form A console output exceeded the tool's capture limit and was truncated in the middle by the
harness. The portions captured verbatim are: the leading configuration warning, the discovery
banner, the per-file `[+]` result lines, and the trailing region. The essential leading lines are:

```
WARNING: Scan configuration 'config/poshqc-scan.json' folder 'tests/powershell' does not exist under root 'C:\Users\DanMoisan\repos\drm-copilot\.claude\worktrees\agent-add102e7ba6e997d5'; skipping.

Starting discovery in 158 files.
Discovery found 3851 tests in 4.66s.
Starting code coverage.
Running tests.
```

The discovery count of 3851 matches the JUnit `tests` attribute exactly, which confirms the JUnit
file corresponds to this run.

## Form C — coverage extraction

Verbatim output:

```
REPO LINE covered=7236 missed=403
.claude/hooks/enforce-powershell-batch-budget.ps1 LINE covered=86 missed=4
.claude/hooks/enforce-python-batch-budget.ps1 LINE covered=86 missed=4
.claude/hooks/persist-session-id.ps1 LINE covered=33 missed=5
```

Form C printed **three** per-file lines, one for each required hook. The BLOCKED branch
(`BLOCKED: baseline coverage numbers unavailable`) was **not** taken:
`artifacts/pester/powershell-coverage.xml` is present and all three files matched.

### Derived percentages

`LINE percent = 100 * covered / (covered + missed)`, recorded to one decimal place. Each value was
computed independently from the covered and missed counts above, not copied from any summary line.

| Scope | LINE covered | LINE missed | Total | LINE percent |
| --- | --- | --- | --- | --- |
| Repository-wide (report root) | 7236 | 403 | 7639 | **94.7** |
| `.claude/hooks/enforce-powershell-batch-budget.ps1` | 86 | 4 | 90 | **95.6** |
| `.claude/hooks/enforce-python-batch-budget.ps1` | 86 | 4 | 90 | **95.6** |
| `.claude/hooks/persist-session-id.ps1` | 33 | 5 | 38 | **86.8** |

All four percentages are real derived values. None is a placeholder.

### Baseline threshold position

All three in-scope hooks are already at or above the uniform 85 percent line threshold at baseline.
`persist-session-id.ps1` at 86.8 percent has the least headroom, 1.8 percentage points, which is the
figure [P7-T5] and [P7-T12] compare against for a regression on changed lines.

No branch figure is recorded. Pester emits no branch counter for PowerShell and no PowerShell
branch-coverage gate applies.
