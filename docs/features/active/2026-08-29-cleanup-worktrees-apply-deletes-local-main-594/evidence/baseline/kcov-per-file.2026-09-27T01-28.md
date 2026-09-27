# P0-T12 — Baseline per-file kcov line-rate

Timestamp: 2026-09-27T01-28
Task: [P0-T12]
RUN_ID: 36285238036 (from P0-T11; headSha `b5f98be268c8c9e0752027486f6500f0a6fa26ce`, conclusion success)

Command: `gh run download 36285238036 --name shell-coverage --dir <session-scratchpad>/kcov-baseline-594`
EXIT_CODE: 0

Source file read: `cov.xml` at the root of the downloaded directory (the root copy is present, so `kcov-merged/cov.xml` was not used). The download location is the executor session scratchpad, outside the repository; no kcov output is copied into the repository.

Extraction method: for each basename, the `line-rate` attribute of the single `<class>` element whose `filename` attribute ends with `/<basename>`. Each basename matched exactly one element.

| File | `<class>` filename attribute | line-rate |
|---|---|---|
| `scripts/bash/cleanup_worktrees_enumerate_lib.sh` | `scripts/bash/cleanup_worktrees_enumerate_lib.sh` | 0.921 |
| `scripts/bash/cleanup_worktrees_actions_lib.sh` | `scripts/bash/cleanup_worktrees_actions_lib.sh` | 0.953 |
| `scripts/bash/cleanup_worktrees_lib.sh` | `scripts/bash/cleanup_worktrees_lib.sh` | 0.954 |
| `scripts/bash/cleanup_worktrees_report_records_lib.sh` | `scripts/bash/cleanup_worktrees_report_records_lib.sh` | 0.890 |
| `scripts/bash/cleanup-worktrees.sh` | `scripts/bash/cleanup-worktrees.sh` | 0.976 |

Output Summary:
- Five numeric baseline line-rates: enumerate_lib 0.921, actions_lib 0.953, lib 0.954, report_records_lib 0.890, cleanup-worktrees.sh 0.976.
- All five files are at or above the 0.85 line threshold.
- Run-wide headline for the same run (P0-T11): `Bash coverage (lines): 93.3%`.
