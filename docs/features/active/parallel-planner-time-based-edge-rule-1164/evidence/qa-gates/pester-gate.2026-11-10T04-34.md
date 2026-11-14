# Pester Gate, Post-Merge (P6-T5 re-run after merge commit 25dcbcdc2)

Timestamp: 2026-11-10T04-06
Command: sh SCRATCH/issue-1164-pester-gate.sh (pwsh: Import-Module scripts/powershell/PoshQC/PoshQC.psd1 from the branch; Invoke-PoshQCParallelTest -Root <worktree>; exit with the returned ExitCode)
EXIT_CODE: 0
Output Summary:
- Run started at 2026-11-10T04-06 UTC and ended at 2026-11-10T04-32. The run printed "Invoke-PoshQCParallelTest: workers=8; wall-clock=1559.96s; exit code=0". Shards 1 to 8 each exited 0, and the returned ExitCode was 0. The merged reports were written at 2026-11-10T04-32, after this run started, so they belong to this run. The wall clock was longer than the pre-merge final run (508 s) because the host ran under concurrent load. The run had no failures.
- Counts from artifacts/pester/pester-junit.xml: 21581 tests, 0 failures, 0 errors, 10 disabled (skipped), so 21571 passed. Phase 0 baseline (evidence/baseline/pester-gate.2026-11-09T23-35.md): 21216 tests, 21206 passed, 0 failed, 10 skipped. Pre-merge final: 21486 tests. The 95 additional tests come from the main-side suites of PR #1166. No new failing test.
- Repo-wide line coverage (artifacts/pester/powershell-coverage.xml): 37690 / 39337 = 95.81% (Phase 0 95.79%, pre-merge final 95.81%). No drop.
- Per-file line coverage, post-merge against Phase 0 (no drop; new files are judged against the thresholds):
  - .claude/lib/blast-radius/BlastRadiusAccess.psm1 (new): 53 / 53 = 100.00%
  - .claude/lib/blast-radius/BlastRadiusScheduling.psm1: 136 / 136 = 100.00% (baseline 100.00%)
  - .claude/lib/parallel-admission/Invoke-ParallelAdmission.ps1: 241 / 249 = 96.79% (baseline 96.48%)
  - .claude/lib/parallel-admission/ParallelAdmissionPrecedence.psm1: 179 / 179 = 100.00% (baseline 100.00%)
  - .claude/lib/parallel-admission/ParallelAdmissionPrecedenceGate.psm1 (new): 41 / 42 = 97.62%
  - .claude/lib/parallel-drift/ParallelDrift.psm1: 128 / 128 = 100.00% (baseline 100.00%)
  - .claude/lib/parallel-drift/ParallelDriftAccess.psm1 (new): 14 / 14 = 100.00%
- Named suites (JUnit tests, failures):
  - FileSizePolicy.RepoGate.Tests.ps1: 5, 0
  - parallel-scheduling-rule-wording.Tests.ps1 (P5-T4, covering the merged parallel-orchestrate SKILL.md and its mirror): 228, 0
  - BlastRadius.KeyPartition.Tests.ps1: 6, 0
- Main-side suites merged from PR #1166 (JUnit tests, failures):
  - bash-command-shape-guidance.Tests.ps1: 22, 0
  - validate-bash.CdChainGuidance.Tests.ps1: 68, 0
  - enforce-worktree-poetry-venv.Tests.ps1 (Claude and Codex): 152, 0
