# Review Rerun: Pester Coverage Gate (feature review)

Timestamp: 2026-11-14T17-58
Command: sh SCRATCH/fr1173-pester2.sh (from the item worktree root: sh .claude/skills/test-execution-policy/scripts/run-test-suite.sh pester, retried while the machine test-suite lock returned exit 75); per-file line coverage parsed from artifacts/pester/powershell-coverage.xml and totals from artifacts/pester/pester-junit.xml
EXIT_CODE: 0
Output Summary:
- Reason: the merge of origin/main (commit ec00c5389f10) is newer than the executor's PowerShell coverage report, so the feature-review coverage Stop hook reported it stale.
- First launch at 2026-11-14T17:44:56Z exited 75 (TEST_EXECUTION_QUEUE_TIMEOUT; lock held by another worktree's Pester suite). The retry started 2026-11-14T17:46:35Z and ended 2026-11-14T17:58:17Z at head ec00c5389f10be134de8390cf839365fea5c5687, clean tree.
- One Invoke-PoshQCParallelTest run: workers=8, wall-clock 701.47 s, exit 0. JUnit tests=26688, failures=0, errors=0, disabled=22 (the count includes suites added by the origin/main merge).
- Repo-wide line coverage 96.00% (44138 covered, 1840 missed); final QC figure before the merge 95.99%; Phase 0 baseline 95.94%.
- Changed PowerShell files: every file has the same per-file figure as the final QC run. Lowest: Invoke-DocsCommand.ps1 90.91%, DocsSurfaceDeltaCommands.psm1 97.33%, DocsProfileCommands.psm1 97.75%, DocsProfileSourceRoot.psm1 (new) 97.83%, DocsLedgerMutation.psm1 98.39%, DocsValidation.psm1 98.72%, DocsLedgerCommands.psm1 99.69%; all others 100.00%, including DocsLedgerBatch.psm1, DocsLedgerBindRefs.psm1 and DocsReferenceSplit.psm1 (new) and both docs-role hooks.
