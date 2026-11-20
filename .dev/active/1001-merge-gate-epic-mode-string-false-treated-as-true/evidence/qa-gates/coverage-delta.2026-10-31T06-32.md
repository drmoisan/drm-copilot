# Coverage Delta (issue #1001)

Timestamp: 2026-10-31T06-32
Command: comparison of evidence/baseline/pester-coverage.2026-10-31T06-19.md with evidence/qa-gates/pester-coverage.2026-10-31T06-32.md; changed-predicate hits read by sh SCRATCH/issue-1001-run.sh SCRATCH/issue-1001-linehits.ps1 -Coverage SCRATCH/issue-1001-final-coverage.xml
EXIT_CODE: 0

Threshold: line coverage of at least 85% per changed PowerShell production file (default in `.claude/rules/general-unit-test.md`; root `CLAUDE.md` states no threshold). No branch gate applies to PowerShell.

| File | Baseline | Post-change | Delta | >= 85 | Not below baseline |
|---|---|---|---|---|---|
| `.claude/hooks/enforce-epic-merge-gate.ps1` | 100.00 (132/132) | 100.00 (132/132) | 0.00 | yes | yes |
| `.claude/hooks/enforce-pr-author-skill.epic-base-branch.ps1` | 93.55 (29/31) | 93.55 (29/31) | 0.00 | yes | yes |
| `.claude/hooks/enforce-model-routing-receipt.ps1` | 96.43 (81/84) | 96.43 (81/84) | 0.00 | yes | yes |

Changed predicate statements (from the post-change coverage report):

| File | Function | Statement | Result |
|---|---|---|---|
| `enforce-epic-merge-gate.ps1` | `Test-ChildCheckpointAllowsEpicMerge` | strict `epic_mode` test (`-is [bool]`) | hit (ci=3, mi=0) |
| `enforce-pr-author-skill.epic-base-branch.ps1` | `Test-EpicBaseBranchOverride` | strict `epic_mode` test (`-is [bool]`) | hit (ci=3, mi=0) |
| `enforce-model-routing-receipt.ps1` | `Get-ModelRoutingAuthorAssertedReason` | strict `epic_mode` test (`-is [bool]`) | hit (ci=3, mi=0) |

The help-text edits add no executable lines, so the covered and missed counts are unchanged. The missed lines are the same statements as at baseline (base-branch: the file-absent return in `Get-PrAuthorCheckpointContent` and the `ConvertFrom-Json` catch return; model-routing: lines in `Invoke-ModelRoutingReceiptDecision` and the script entry point), shifted by the added help lines.

Output Summary: all three hooks at or above 85% and not below baseline (100.00, 93.55, 96.43; delta 0.00 each); each changed predicate statement is hit. Result: PASS.
