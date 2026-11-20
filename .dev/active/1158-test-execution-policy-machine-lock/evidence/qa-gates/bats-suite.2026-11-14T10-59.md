# Final QC: bats Suite (P7-T7, loop restart after the #1159 and #1179 merges)

Timestamp: 2026-11-14T10-59
Command: sh .claude/skills/test-execution-policy/scripts/run-test-suite.sh bats --coverage, run from a `git archive HEAD` copy of the branch head after the P7-T6 re-record commit, staged under SCRATCH with a WSL-initialized `.git` directory (SCRATCH/issue-1158-bats-copy.sh, then SCRATCH/issue-1158-launch-copy.sh)
EXIT_CODE: 0
Output Summary: 803 tests, 0 failures, launcher exit 0. kcov merged report: `Bash coverage (lines): 95.0%` (3460 of 3643 lines). `.claude/skills/test-execution-policy/scripts/run-test-suite.sh` has a line-rate of 1.000 (100%).

The copy is used because a linked Windows worktree cannot be read by WSL git. That failure mode is recorded in `evidence/other/bats-worktree-host-deviation.2026-11-14T10-03.md`. After the gated commit, the branch changes only these files:

- PowerShell test files under `tests/scripts/`;
- evidence files under `docs/`.

Neither path is in the bats test directories `tests/shell` and `tests/bash` or in the shell discovery roots.

| Run | Tree | Tests | Failures | Launcher exit | Coverage |
|---|---|---|---|---|---|
| 1 | `git archive` copy of the branch head after the P7-T6 re-record | 803 | 0 | 0 | 95.0% repo bash lines; `run-test-suite.sh` 100% |
