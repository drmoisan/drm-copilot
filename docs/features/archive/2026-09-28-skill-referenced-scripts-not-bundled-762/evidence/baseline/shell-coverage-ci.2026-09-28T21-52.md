# Bash Coverage Baseline from CI on main (P0-T19)

Timestamp: 2026-09-28T21-52
Command: gh run list --workflow ci.yml --commit 5d0b93a0b0a15633b42559827fd7459d65c0b671 --json databaseId,event,status,conclusion,headSha ; gh run view 36494352285 --json jobs ; sh SCRATCH/ci-shell-coverage-log.sh 36494352285 ; gh run download 36494352285 -n shell-coverage -D SCRATCH/shell-cov-baseline ; poetry run python SCRATCH/cobertura-files.py SCRATCH/shell-cov-baseline/cov.xml scripts/ba?h/shell_qc_lib.sh <ten moved-script basenames>
EXIT_CODE: 0
Output Summary:
- BASE_SHA 5d0b93a0b0a15633b42559827fd7459d65c0b671; push run id 36494352285 (event `push`, status `completed`).
- Run overall conclusion: `failure`. Failing/cancelled jobs, all unrelated to this bash baseline:
  - `quality-checks7 / Code Quality & Tests (3.12)` failure (Python job; unrelated)
  - `quality-checks7 / Code Quality & Tests (3.10)`, `(3.11)`, `(3.13)` cancelled (fail-fast after 3.12; unrelated)
- Job `shell-coverage / Shell Coverage (Bats + kcov)` conclusion: `success`.
- Bash coverage (lines): 93.3%
- COBERTURA-TOTAL line-rate=0.933

## Coverage log line (A20)

```text
shell-coverage / Shell Coverage (Bats + kcov)	UNKNOWN STEP	2026-09-28T22:54:21.0097862Z Bash coverage (lines): 93.3%
```

## Per-file baseline (A17)

```text
COBERTURA-TOTAL line-rate=0.933
COBERTURA file=scripts/bash/shell_qc_lib.sh line-rate=0.865
COBERTURA file=scripts/bash/cleanup-worktrees.sh line-rate=0.976
COBERTURA file=scripts/bash/cleanup_worktrees_actions_lib.sh line-rate=0.953
COBERTURA file=scripts/bash/cleanup_worktrees_detached_lib.sh line-rate=1.000
COBERTURA file=scripts/bash/cleanup_worktrees_dirt_lib.sh line-rate=0.942
COBERTURA file=scripts/bash/cleanup_worktrees_enumerate_lib.sh line-rate=0.924
COBERTURA file=scripts/bash/cleanup_worktrees_lib.sh line-rate=0.954
COBERTURA file=scripts/bash/cleanup_worktrees_preserve_eol_lib.sh line-rate=0.870
COBERTURA file=scripts/bash/cleanup_worktrees_preserve_lib.sh line-rate=0.906
COBERTURA file=scripts/bash/cleanup_worktrees_report_records_lib.sh line-rate=0.890
COBERTURA file=scripts/bash/cleanup_worktrees_scan_helper.sh line-rate=0.875
```

## Execution note

The first `gh run download` into SCRATCH/shell-cov-baseline failed ("The file exists") because the directory
already held the same artifact from preflight. Removing it with `rm -rf` was denied by a PreToolUse hook
("Blocked dangerous command pattern detected: 'rm -rf'"). The artifact was downloaded fresh into
SCRATCH/shell-cov-baseline-fresh (exit 0), and `cmp` showed its cov.xml byte-identical to
SCRATCH/shell-cov-baseline/cov.xml (CMP=0), so the values above come from run 36494352285.
