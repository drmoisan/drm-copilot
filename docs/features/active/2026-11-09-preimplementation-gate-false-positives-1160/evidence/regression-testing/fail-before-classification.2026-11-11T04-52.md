# Fail-Before Classification Run on the Unfixed Gates (P1-T4, expect-fail)

Timestamp: 2026-11-11T04-22
Command: sh SCRATCH/issue-1160-pester-gate.sh (PowerShell 7: Import-Module scripts/powershell/PoshQC/PoshQC.psd1 -Force; Invoke-PoshQCParallelTest -Root <worktree root>; exit with the returned ExitCode; then SCRATCH/issue-1160-summary.ps1 reads the shard JUnit files under artifacts/pester/parallel/ because the run is red)
EXIT_CODE: 1
ExpectedExitCode: 1
Output Summary:
- One parallel run, 8 shard processes, started 2026-11-11T04-22 UTC and ended 2026-11-11T04-51 UTC. Shards 3 and 7 exited 34; the other six exited 0. The merged reports are not written for a red run, so the counts come from the shard JUnit files.
- Shard JUnit totals: 21571 tests, 21493 passed, 68 failed, 10 skipped. The Phase 0 baseline (`evidence/baseline/pester-gate.2026-11-10T04-19.md`) recorded no failure, so no pre-existing failure is carried into this run.
- The 68 failures are exactly the false-positive rows of both new runners, two tests per row per surface (17 rows x 2 tests x 2 surfaces):
  - `tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.Classification.Tests.ps1`: `does not classify false-positive row FP-01` to `FP-17` and `allows false-positive row FP-01 with a not-ready checkpoint` to `FP-17` (34 failures).
  - `tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-classification.Tests.ps1`: the same 34 test names (34 failures).
- Every existing-denial row (ED-01 to ED-42, classification and byte-equal generic deny text) and every non-goal row (NG-01 to NG-09) passes on both surfaces; no test outside the two runners fails.
- The rows FP-01 to FP-17 are the spec AC-1 and research section 6.3 rows, so this run is the fail-before evidence for AC-1.
