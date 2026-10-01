# AC-10 Inventory: First Linux Run Failures (P4-T4)

Timestamp: 2026-10-01T16-56
RUN_ID: 36894194578
CI_SHA: 90b6bd4a8646f0a510509c839e9daec77dff69d1

Source: the 21 `FAIL:` lines of P4-T3 (`linux-first-run.2026-10-01T16-44.md`). One row per `FAIL:` line. Row count: 21.

Root cause shared by every row except the three `windows.sandbox` rows: the Linux runner reported `DriveNotFoundException: Cannot find drive. A drive with the name 'C' does not exist.` when a `C:` path literal reached `Join-Path` or a provider path call. The three S1/S1b/S1c rows fail because `.codex/scripts/epic-child-sandbox-preflight.ps1` and `.codex/scripts/launch-epic-child-wave.ps1` add `windows.sandbox="elevated"` only when `$IsWindows` is true.

| # | File | Testcase | Class | Planned disposition | Fix |
| --- | --- | --- | --- | --- | --- |
| 1 | tests/scripts/claude-hooks/enforce-parallel-drift-gate.Tests.ps1 | denies when the only finding file predates the latest drift event | NEW | REMEDIATION-REQUIRED | not in this plan's file list; failure raised at `.claude/hooks/enforce-parallel-drift-gate.ps1:179` (DriveNotFoundException) |
| 2 | tests/scripts/claude-hooks/enforce-parallel-drift-gate.Tests.ps1 | allows when the finding file timestamp equals the latest drift event at | NEW | REMEDIATION-REQUIRED | as row 1 |
| 3 | tests/scripts/claude-hooks/enforce-parallel-drift-gate.Tests.ps1 | allows when the finding file timestamp follows the latest drift event at | NEW | REMEDIATION-REQUIRED | as row 1 |
| 4 | tests/scripts/claude-hooks/enforce-parallel-drift-gate.Tests.ps1 | denies when the finding file name carries a non-conforming embedded substring | NEW | REMEDIATION-REQUIRED | as row 1 |
| 5 | tests/scripts/claude-hooks/enforce-parallel-drift-gate.Tests.ps1 | names the current-event requirement in the deny reason for a stale finding file | NEW | REMEDIATION-REQUIRED | as row 1 |
| 6 | tests/scripts/claude-hooks/enforce-parallel-drift-gate.Tests.ps1 | Test-ParallelDriftFindingPresent reports absence when the feature folder does not exist | NEW | REMEDIATION-REQUIRED | as row 1 |
| 7 | tests/scripts/claude-hooks/enforce-parallel-drift-gate.Tests.ps1 | Test-ParallelDriftFindingPresent reports absence when no remediation-inputs file is present | NEW | REMEDIATION-REQUIRED | as row 1 |
| 8 | tests/scripts/claude-hooks/enforce-parallel-drift-gate.Tests.ps1 | Test-ParallelDriftFindingPresent reports presence for a remediation-inputs markdown file | NEW | REMEDIATION-REQUIRED | as row 1 |
| 9 | tests/scripts/claude-hooks/enforce-powershell-batch-budget-routing.Tests.ps1 | the default reader yields direct mode when the checkpoint file is absent | NEW | REMEDIATION-REQUIRED | not in this plan's file list; raised at `.claude/hooks/enforce-powershell-batch-budget.ps1:372` (DriveNotFoundException) |
| 10 | tests/scripts/claude-hooks/enforce-python-batch-budget-routing.Tests.ps1 | the default reader yields direct mode when the checkpoint file is absent | NEW | REMEDIATION-REQUIRED | not in this plan's file list; raised at `.claude/hooks/enforce-python-batch-budget.ps1:375` (DriveNotFoundException) |
| 11 | tests/scripts/codex-hooks/codex-powershell-batch-budget-routing.Tests.ps1 | the default reader yields direct mode when the checkpoint file is absent | NEW | REMEDIATION-REQUIRED | not in this plan's file list; raised at `.codex/hooks/enforce-powershell-batch-budget.ps1:217` (DriveNotFoundException) |
| 12 | tests/scripts/codex-hooks/codex-python-batch-budget-routing.Tests.ps1 | the default reader yields direct mode when the checkpoint file is absent | NEW | REMEDIATION-REQUIRED | not in this plan's file list; raised at `.codex/hooks/enforce-python-batch-budget.ps1:220` (DriveNotFoundException) |
| 13 | tests/scripts/codex-hooks/enforce-epic-worktree-removal-gate-decision-surface.Tests.ps1 | resolves a relative path against the supplied working directory | S2 | P5-T3 | R10 (a) and (c): `-WorkingDirectory 'C:/repo'` becomes `-WorkingDirectory $script:SyntheticRoot`; `Should -Be 'C:/repo/worktrees/child-a'` becomes `Should -Be "$script:SyntheticRoot/worktrees/child-a"` |
| 14 | tests/scripts/codex-hooks/enforce-epic-worktree-removal-gate-decision-surface.Tests.ps1 | keeps a rooted path and trims a trailing separator | S2 | P5-T3 | R10 (c): `-Path 'C:/repo/worktrees/child-a/' -WorkingDirectory 'C:/elsewhere'` becomes `-Path "$script:SyntheticRoot/worktrees/child-a/" -WorkingDirectory $script:SyntheticElsewhere`; expected value as row 13 |
| 15 | tests/scripts/codex-hooks/enforce-epic-worktree-removal-gate-decision-surface.Tests.ps1 | skips a feature record whose worktree_path is blank and reports no match | NEW | P5-T6 | lines 157-162 were outside the research S2/S3 ranges; the R10 (c) replacements applied by P5-T3 (`-TargetPath 'C:/repo/wt'` and `-WorkingDirectory 'C:/repo'`) cover this case, so P5-T6 adds no further edit |
| 16 | tests/scripts/codex-hooks/enforce-epic-worktree-removal-gate-decision-surface.Tests.ps1 | returns the matching feature record when the normalized paths agree | S3 | P5-T3 | R10 (c): `-TargetPath 'C:/repo/worktrees/child-a'` becomes `-TargetPath "$script:SyntheticRoot/worktrees/child-a"`; `-WorkingDirectory 'C:/repo'` becomes `$script:SyntheticRoot` |
| 17 | tests/scripts/codex-hooks/enforce-epic-worktree-removal-gate-decision-surface.Tests.ps1 | allows a removal whose feature record reports worktree_removed | S3 | P5-T3 | R10 (c): checkpoint JSON and `git worktree remove` command built with `-f $script:SyntheticRoot`; `-WorkingDirectory $script:SyntheticRoot` |
| 18 | tests/scripts/codex-hooks/epic-child-launch-hardening.Tests.ps1 | uses inline project trust, ignores user config, and denies Codex install paths | S1b | P5-T1 | R9 at line 245: `$arguments \| Should -Contain 'windows.sandbox="elevated"'` becomes `($arguments -contains 'windows.sandbox="elevated"') \| Should -Be $IsWindows -Because '...'` |
| 19 | tests/scripts/codex-hooks/epic-child-launch-hardening.Tests.ps1 | preflights the elevated Windows sandbox from an isolated CODEX_HOME | S1 | P5-T1 | R9 at line 346 (same replacement) |
| 20 | tests/scripts/codex-hooks/epic-child-launch-hardening.Tests.ps1 | repeats the exact terminal receipt timestamp under the matching status key | S5 | P5-T4 | raised at `.codex/scripts/launch-epic-child-wave.ps1:218` (`Join-Path` on `worktree_path = 'C:\worktree'`); fix recorded in the P5-T4 section below |
| 21 | tests/scripts/codex-hooks/epic-child-worktree-launcher.Tests.ps1 | builds codex exec with exact model, reasoning, instructions, skills, permissions, and worktree | S1c | P5-T2 | R9 at line 315 (same replacement) |

Row count (21) equals the number of P4-T3 `FAIL:` lines (21). Every row has File, Testcase, Class, and Planned disposition filled.

P5-T5: NO ROWS (no row was assigned to P5-T5).
