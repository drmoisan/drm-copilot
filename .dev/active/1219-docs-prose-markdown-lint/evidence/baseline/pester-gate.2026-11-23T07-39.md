# Phase 0 Baseline Pester Gate (P0-T2)

Timestamp: 2026-11-23T07-39
Command: sh .claude/skills/test-execution-policy/scripts/run-test-suite.sh pester (one Invoke-PoshQCParallelTest run through the launcher, invoked from SCRATCH/issue-1219-suite-retry.sh, which re-runs after a launcher exit 75); counts read from artifacts/pester/pester-junit.xml and line coverage from artifacts/pester/powershell-coverage.xml by SCRATCH/issue-1219-summarize.ps1
EXIT_CODE: 0
Output Summary:
- Queue timeouts (launcher exit 75, machine test-suite lock held by another worktree), recorded as queue timeouts and not failures: attempts 1-4 (2026-11-23T07-16 to 2026-11-23T07-24). The first exit-75 attempt was a direct launcher call before the retry script.
- Gate run: attempt 5, 2026-11-23T07-24 to 2026-11-23T07-37; Invoke-PoshQCParallelTest workers=8, wall-clock 699.67 s, exit code 0; all 8 shards exited 0.
- JUnit: 29153 test cases; 29135 passed; 0 failed; 18 skipped.
- Repo-wide line coverage: 96.84% (47286 covered, 1541 missed; 482 files in the coverage population).
- .claude/lib/docs/DocsLedgerCommands.psm1: 99.69% (325 covered, 1 missed).
- .claude/lib/docs/DocsProfileCommands.psm1: 97.75% (87 covered, 2 missed).
- .claude/lib/docs/DocsPagePlaceholder.psm1: not present before the change (new file; judged against the 85% threshold at the final gate).
- Pre-change state: the run measured the tree before any production or test edit of this feature (the in-progress new module was kept under SCRATCH until the run finished).
