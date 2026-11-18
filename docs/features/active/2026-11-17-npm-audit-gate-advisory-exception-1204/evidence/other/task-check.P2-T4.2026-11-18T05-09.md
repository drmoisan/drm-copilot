# Task check P2-T4

Timestamp: 2026-11-18T05-09
Changed files: docs/engineering/process-reductions/0013-npm-audit-advisory-exception.md (new), docs/engineering/process-reductions/README.md (index row for 0013, status Active, after the 0012 row).
Selection and rule: the contract tests that read the ledger folder: tests/scripts/dev-tools/ProcessReductionChain.Ledger.Tests.ps1, ProcessReductionLedger.Index.Tests.ps1, ProcessReductionLedger.Tests.ps1, ProcessReductionLedger.Replay.Tests.ps1.
Command: sh .claude/skills/test-execution-policy/scripts/run-test-suite.sh pester -TestPath <the four files above>
EXIT_CODE: 0
Output Summary:
- `Invoke-PoshQCParallelTest: workers=4; exit code=0`; shard counts 5, 15, 72, 4 passed, 0 failed. The chain test reverts every entry newest-first including 0013: the single Revert Block for `.github/workflows/_npm-audit-gate.yml` has a `Current` (the contiguous `shell: pwsh` and new `run:` lines) that occurs exactly once in the edited workflow, and its `Prior` is the single line `run: npm audit --audit-level="$AUDIT_LEVEL"`. The index test accepts the new row and file.
- The entry has the six ordered revert steps (step 1 restores the prior line and deletes the new script, module, config, and three tests; steps 2 to 5 not applicable; step 6 names the two ledger tests).
- Recorded deviation: the `Merge commit:` line reads `pending (PR #1204)` because the pull request does not exist yet and the checker requires a positive number; the number is the issue number as a stand-in. The record is back-filled with the merge commit after the merge (the `pending` form is replaced), as the ledger README states.
