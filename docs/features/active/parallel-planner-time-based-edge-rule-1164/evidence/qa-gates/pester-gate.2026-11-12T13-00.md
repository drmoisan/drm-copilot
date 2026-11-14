# Pester Gate (remediation cycle 1, P2-T4, post-main-merge head)

Timestamp: 2026-11-12T12-35
Command: sh SCRATCH/issue-1164-pester-gate.sh (pwsh 7: Import-Module scripts/powershell/PoshQC/PoshQC.psd1 from the branch; Invoke-PoshQCParallelTest -Root <item worktree>; exit with the returned ExitCode); figures read by pwsh -File SCRATCH/issue-1164-pester-extract.ps1
EXIT_CODE: 0
Output Summary:
- Run on the post-main-merge head 01547c4c7 (plain merge of origin/main, PR #1168, after the remediation commit e2d42d831); final QA loop gate, run in full.
- Run 2026-11-12T12-35 to 13-00 UTC; "Invoke-PoshQCParallelTest: workers=8; wall-clock=1478.15s; exit code=0"; returned ExitCode 0; shards 1 to 8 exited 0. Merged reports written 2026-11-12T13-00, so they belong to this run.
- artifacts/pester/pester-junit.xml: 21734 tests, 0 failures, 0 errors, 10 disabled, so 21724 passed, 0 failed (P0-T4: 21571 passed, 0 failed; the increase comes from the P1-T5 and P1-T6 cases and the suites the main merge brought in, including test-cadence-wording.Tests.ps1).
- Repo-wide line coverage (artifacts/pester/powershell-coverage.xml): 37702 / 39348 = 95.82% (P0-T4: 95.81%). No drop.
- Per-file line coverage:
  - .claude/lib/blast-radius/BlastRadiusAccess.psm1: 64 / 64 = 100.00% (P0-T4: 53 / 53 = 100.00%). No drop; at least 85%.
  - .claude/lib/parallel-admission/ParallelAdmissionPrecedenceGate.psm1: 42 / 42 = 100.00% (P0-T4: 41 / 42 = 97.62%). No drop; the R4 case covers the former missed line.
- Named suites (tests, failures): BlastRadiusAccess.Tests.ps1 35, 0 (P0-T4 19); ParallelAdmissionPrecedenceGate.Tests.ps1 10, 0 (P0-T4 9); parallel-scheduling-rule-wording.Tests.ps1 228, 0; FileSizePolicy.RepoGate.Tests.ps1 5, 0.
- New cases: "rejects a path whose read title carries the write form <Form>" 15 of 15 passed; "keeps a read path whose title word only begins like a write verb" 1 passed; "rejects a cost entry naming an item absent from items with the default-band gain" 1 passed.
- No failing test, so no failure is classified under the Execution Terms.
