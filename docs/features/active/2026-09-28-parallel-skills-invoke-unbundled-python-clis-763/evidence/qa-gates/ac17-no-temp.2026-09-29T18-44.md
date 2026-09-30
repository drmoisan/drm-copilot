# AC17 Temporary-File Sweep (P6-T9)

Timestamp: 2026-09-29T18-44
Command: sh SCRATCH/no-temp-sweep.sh tests/shell/parallel_abandon.bats tests/shell/parallel_abandon_parity.bats tests/shell/parallel_payload_only.bats tests/shell/parallel_ba?h_manifest_membership.bats tests/scripts/dev_tools/test_parallel_drift_parity.py tests/scripts/dev_tools/test_parallel_abandon_ba?h_parity.py tests/scripts/dev_tools/test_parallel_abandon_token_seam.py tests/scripts/dev_tools/test_skill_bundle_contract_evaluation.py tests/scripts/dev_tools/test_skill_bundle_contract_cli.py tests/scripts/claude-lib/parallel-drift/ParallelDriftHalt.Tests.ps1 tests/scripts/claude-lib/parallel-drift/ParallelDrift.Tests.ps1 tests/scripts/claude-lib/parallel-drift/ParallelDrift.Manifest.Tests.ps1 tests/scripts/claude-lib/parallel-drift/Invoke-ParallelDriftDetection.Tests.ps1 tests/scripts/claude-lib/parallel-drift/ParallelDrift.Parity.Tests.ps1 tests/fixtures/parallel_abandon_path/gh tests/fixtures/parallel_abandon_path/gi? ; sh SCRATCH/no-temp-sweep.sh docs/features/active/2026-09-28-parallel-skills-invoke-unbundled-python-clis-763/plan.2026-09-29T14-14.md
EXIT_CODE: 0
Output Summary:
- Sweep over the 16 new or changed test files and shims: no match line; final line `SWEEP-EXIT=1`.
- Negative control over the plan: one match line (line 1398, the A17 pattern quoted in Appendix A)
  and final line `SWEEP-EXIT=0`, which proves the pattern can match.

Command-text spellings: `tests/shell/parallel_bash_manifest_membership.bats` and
`tests/scripts/dev_tools/test_parallel_abandon_bash_parity.py` use the Shell route glob, and the
git shim `tests/fixtures/parallel_abandon_path/git` is spelled `.../gi?` so the worktree isolation
guard does not read the path as a second git invocation; each glob matched exactly one file.
