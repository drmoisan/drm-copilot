# AC-10 Inventory, Closed (P7-T21)

Timestamp: 2026-10-01T17-57
RUN_ID (first run): 36894194578; CI_SHA (first run): 90b6bd4a8646f0a510509c839e9daec77dff69d1
RUN_ID (final run, P7-T18): 36901896617; CI_SHA (final): ecba8829604f6265dc491c74cf42546f9d5aab57

New timestamped copy of `linux-first-run-failures.2026-10-01T16-56.md` with a `Final status` column.

| # | File | Testcase | Class | Planned disposition | Fix | Final status |
| --- | --- | --- | --- | --- | --- | --- |
| 1 | tests/scripts/claude-hooks/enforce-parallel-drift-gate.Tests.ps1 | denies when the only finding file predates the latest drift event | NEW | REMEDIATION-REQUIRED | none (outside plan file list) | REMEDIATION-REQUIRED |
| 2 | tests/scripts/claude-hooks/enforce-parallel-drift-gate.Tests.ps1 | allows when the finding file timestamp equals the latest drift event at | NEW | REMEDIATION-REQUIRED | none | REMEDIATION-REQUIRED |
| 3 | tests/scripts/claude-hooks/enforce-parallel-drift-gate.Tests.ps1 | allows when the finding file timestamp follows the latest drift event at | NEW | REMEDIATION-REQUIRED | none | REMEDIATION-REQUIRED |
| 4 | tests/scripts/claude-hooks/enforce-parallel-drift-gate.Tests.ps1 | denies when the finding file name carries a non-conforming embedded substring | NEW | REMEDIATION-REQUIRED | none | REMEDIATION-REQUIRED |
| 5 | tests/scripts/claude-hooks/enforce-parallel-drift-gate.Tests.ps1 | names the current-event requirement in the deny reason for a stale finding file | NEW | REMEDIATION-REQUIRED | none | REMEDIATION-REQUIRED |
| 6 | tests/scripts/claude-hooks/enforce-parallel-drift-gate.Tests.ps1 | Test-ParallelDriftFindingPresent reports absence when the feature folder does not exist | NEW | REMEDIATION-REQUIRED | none | REMEDIATION-REQUIRED |
| 7 | tests/scripts/claude-hooks/enforce-parallel-drift-gate.Tests.ps1 | Test-ParallelDriftFindingPresent reports absence when no remediation-inputs file is present | NEW | REMEDIATION-REQUIRED | none | REMEDIATION-REQUIRED |
| 8 | tests/scripts/claude-hooks/enforce-parallel-drift-gate.Tests.ps1 | Test-ParallelDriftFindingPresent reports presence for a remediation-inputs markdown file | NEW | REMEDIATION-REQUIRED | none | REMEDIATION-REQUIRED |
| 9 | tests/scripts/claude-hooks/enforce-powershell-batch-budget-routing.Tests.ps1 | the default reader yields direct mode when the checkpoint file is absent | NEW | REMEDIATION-REQUIRED | none | REMEDIATION-REQUIRED |
| 10 | tests/scripts/claude-hooks/enforce-python-batch-budget-routing.Tests.ps1 | the default reader yields direct mode when the checkpoint file is absent | NEW | REMEDIATION-REQUIRED | none | REMEDIATION-REQUIRED |
| 11 | tests/scripts/codex-hooks/codex-powershell-batch-budget-routing.Tests.ps1 | the default reader yields direct mode when the checkpoint file is absent | NEW | REMEDIATION-REQUIRED | none | REMEDIATION-REQUIRED |
| 12 | tests/scripts/codex-hooks/codex-python-batch-budget-routing.Tests.ps1 | the default reader yields direct mode when the checkpoint file is absent | NEW | REMEDIATION-REQUIRED | none | REMEDIATION-REQUIRED |
| 13 | tests/scripts/codex-hooks/enforce-epic-worktree-removal-gate-decision-surface.Tests.ps1 | resolves a relative path against the supplied working directory | S2 | P5-T3 | R10 (a), (c): OS-derived `$script:SyntheticRoot` | PASSING IN P7-T18 (fixed by P5-T3) |
| 14 | tests/scripts/codex-hooks/enforce-epic-worktree-removal-gate-decision-surface.Tests.ps1 | keeps a rooted path and trims a trailing separator | S2 | P5-T3 | R10 (c): `$script:SyntheticRoot` and `$script:SyntheticElsewhere` | PASSING IN P7-T18 (fixed by P5-T3) |
| 15 | tests/scripts/codex-hooks/enforce-epic-worktree-removal-gate-decision-surface.Tests.ps1 | skips a feature record whose worktree_path is blank and reports no match | NEW | P5-T6 | covered by the R10 (c) replacements of P5-T3; no further edit | PASSING IN P7-T18 (fixed by P5-T3, recorded under P5-T6) |
| 16 | tests/scripts/codex-hooks/enforce-epic-worktree-removal-gate-decision-surface.Tests.ps1 | returns the matching feature record when the normalized paths agree | S3 | P5-T3 | R10 (c) | PASSING IN P7-T18 (fixed by P5-T3) |
| 17 | tests/scripts/codex-hooks/enforce-epic-worktree-removal-gate-decision-surface.Tests.ps1 | allows a removal whose feature record reports worktree_removed | S3 | P5-T3 | R10 (c): checkpoint and command built with `-f $script:SyntheticRoot` | PASSING IN P7-T18 (fixed by P5-T3) |
| 18 | tests/scripts/codex-hooks/epic-child-launch-hardening.Tests.ps1 | uses inline project trust, ignores user config, and denies Codex install paths | S1b | P5-T1 | R9 at line 245 | PASSING IN P7-T18 (fixed by P5-T1) |
| 19 | tests/scripts/codex-hooks/epic-child-launch-hardening.Tests.ps1 | preflights the elevated Windows sandbox from an isolated CODEX_HOME | S1 | P5-T1 | R9 at line 346 | PASSING IN P7-T18 (fixed by P5-T1) |
| 20 | tests/scripts/codex-hooks/epic-child-launch-hardening.Tests.ps1 | repeats the exact terminal receipt timestamp under the matching status key | S5 | P5-T4 | line 427: OS-derived `worktree_path` (`C:\worktree` on Windows, `/worktree` elsewhere) | PASSING IN P7-T18 (fixed by P5-T4) |
| 21 | tests/scripts/codex-hooks/epic-child-worktree-launcher.Tests.ps1 | builds codex exec with exact model, reasoning, instructions, skills, permissions, and worktree | S1c | P5-T2 | R9 at line 315 | PASSING IN P7-T18 (fixed by P5-T2) |

Every row's Final status is `PASSING IN P7-T18` (with its fix and fixing task) or `REMEDIATION-REQUIRED`. Unconditional-skip check: `no-unconditional-skip.2026-10-01T17-57.md`.
