# P6-T12 — Post-change per-file kcov line-rate

Timestamp: 2026-09-27T02-12
Task: [P6-T12]
RUN_ID: 36287146354 (from P6-T10; headSha `e29ad95d70cce6641c1817f3ac36f319d2a10b59`, conclusion success)
Overall headline (P6-T11): `Bash coverage (lines): 93.3%`

Command: `gh run download 36287146354 --name shell-coverage --dir <session-scratchpad>/kcov-final`
EXIT_CODE: 0

Source file read: `cov.xml` at the root of the downloaded directory (the root copy is present, so `kcov-merged/cov.xml` was not used). The download location is the executor session scratchpad, outside the repository; no kcov output is copied into the repository.

Extraction method (P0-T12 rule): for each basename, the `line-rate` attribute of the single `<class>` element whose `filename` attribute ends with `/<basename>`. Each basename matched exactly one element.

| File | `<class>` filename attribute | line-rate |
|---|---|---|
| `scripts/bash/cleanup_worktrees_enumerate_lib.sh` | `scripts/bash/cleanup_worktrees_enumerate_lib.sh` | 0.924 |
| `scripts/bash/cleanup_worktrees_actions_lib.sh` | `scripts/bash/cleanup_worktrees_actions_lib.sh` | 0.953 |
| `scripts/bash/cleanup_worktrees_lib.sh` | `scripts/bash/cleanup_worktrees_lib.sh` | 0.954 |
| `scripts/bash/cleanup_worktrees_report_records_lib.sh` | `scripts/bash/cleanup_worktrees_report_records_lib.sh` | 0.890 |
| `scripts/bash/cleanup-worktrees.sh` | `scripts/bash/cleanup-worktrees.sh` | 0.976 |

Output Summary:
- Five numeric post-change line-rates: enumerate_lib 0.924, actions_lib 0.953, lib 0.954, report_records_lib 0.890, cleanup-worktrees.sh 0.976.
- `scripts/bash/cleanup_worktrees_enumerate_lib.sh` 0.924 >= 0.85; `scripts/bash/cleanup_worktrees_actions_lib.sh` 0.953 >= 0.85.
- Result: PASS.
