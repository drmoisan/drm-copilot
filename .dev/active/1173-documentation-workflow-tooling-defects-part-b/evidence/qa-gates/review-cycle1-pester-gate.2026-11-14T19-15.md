# Review Rerun: Pester Coverage Gate (feature review, cycle 1 re-audit)

Timestamp: 2026-11-14T19-15
Command: sh .claude/skills/test-execution-policy/scripts/run-test-suite.sh pester (from the item worktree root, through a scratch runner); per-file line coverage parsed from artifacts/pester/powershell-coverage.xml and totals from artifacts/pester/pester-junit.xml
EXIT_CODE: 0
Output Summary:
- Reason: the feature-review coverage Stop hook compares artifacts/pester/powershell-coverage.xml with the newest commit touching PowerShell files (the merge commit aea5742dc, 2026-11-14T18:44:43Z); the existing report was written at 2026-11-14T17:58Z, before it.
- Run window (UTC, clock-read): 2026-11-14T19:00:20Z to 2026-11-14T19:12:31Z at head aea5742dc2b628f2c095ce9cf71aa53f18a538de, clean tree.
- One Invoke-PoshQCParallelTest run: workers=8, wall-clock 730.16 s, exit 0. JUnit tests=26790, failures=0, errors=0, disabled=22 (the count includes suites added by the origin/main merge).
- Repo-wide line coverage 96.01% (44264 covered of 46104); prior review rerun 96.00%; Phase 0 baseline 95.94%.
- Changed PowerShell production files (24 root files): every file has the same per-file figure as the prior review rerun. Lowest: Invoke-DocsCommand.ps1 90.91% (190/209), DocsSurfaceDeltaCommands.psm1 97.33%, DocsProfileCommands.psm1 97.75%, DocsProfileSourceRoot.psm1 (new) 97.83%, DocsLedgerMutation.psm1 98.39%, DocsValidation.psm1 98.72%, DocsLedgerCommands.psm1 99.69%; the other 17 files are at 100.00%, including DocsLedgerBatch.psm1, DocsLedgerBindRefs.psm1 and DocsReferenceSplit.psm1 (new) and both docs-role hooks.
