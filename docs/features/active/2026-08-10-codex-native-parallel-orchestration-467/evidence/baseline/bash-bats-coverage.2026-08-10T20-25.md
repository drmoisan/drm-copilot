# Bash Bats Coverage Baseline

Timestamp: `2026-08-10T23-19`

STATUS: `PASS — exact-head CI evidence` (the local environment failure remains recorded below)

Exact command: `bash -lc "SHELL_QC_KCOV_OUT_DIR='docs/features/active/2026-08-10-codex-native-parallel-orchestration-467/evidence/baseline/bash-kcov.2026-08-10T20-25' bash scripts/bash/shell-qc.sh test --coverage"`

Exact command exit code: `1`

Exact command error: `WSL ... execvpe(/bin/bash) failed: No such file or directory`. The Windows `bash.exe` command targets the default `docker-desktop` WSL distribution, which does not provide `/bin/bash`.

Host Git Bash tool probe:

- Bash: available at `/usr/bin/bash`.
- Bats: missing.
- kcov: missing.

Bounded repository-harness verification: an ephemeral `kcov/kcov:latest` Debian container was mounted read/write only to this worktree, used kcov `v44-pre-test3-2-gf65e`, installed Bats `1.10.0`, and invoked `bash scripts/bash/shell-qc.sh test --coverage` with the plan's feature-scoped `SHELL_QC_KCOV_OUT_DIR`.

Container/harness exit code: `1`

Assertions: `245 passed / 245 total`; the TAP stream began `1..245`, contained only `ok` results, and ended with `ok 245`.

Local coverage output: unavailable. The requested `bash-kcov.2026-08-10T20-25/` directory exists but is empty; `cov.xml` was not produced. The local repository harness returned 1 after the passing Bats suite, so the local environment could not supply a numeric line rate.

Bash line coverage: `92.3%` from the successful exact-head CI execution below.

Protected-source verification: `git diff --name-only -- .claude` returned 0 paths after both container attempts.

## Authoritative exact-head CI verification

Read-only commands:

- `gh run view 31442215102 --json databaseId,headSha,conclusion,status,url,workflowName,createdAt,updatedAt,jobs`
- `gh run view 31442215102 --job 93629098903 --log`

Both commands exited `0`. No run was dispatched and no external state was changed.

- Baseline HEAD: `fe0413d4aca1e76b2d02d05701fba79a887d5405`.
- CI head SHA: `fe0413d4aca1e76b2d02d05701fba79a887d5405`.
- HEAD equality: `true`.
- Run: `31442215102`, workflow `CI`, status `completed`, conclusion `success`.
- Run URL: `https://github.com/drmoisan/drm-copilot/actions/runs/31442215102`.
- Job: `93629098903`, `shell-coverage / Shell Coverage (Bats + kcov)`, status `completed`, conclusion `success`.
- Job URL: `https://github.com/drmoisan/drm-copilot/actions/runs/31442215102/job/93629098903`.
- Coverage step: `Run shell-qc test with coverage`, conclusion `success`; verified command `bash scripts/bash/shell-qc.sh test --coverage`.
- TAP plan: `1..245`.
- Assertions: `245 passed / 245 total`; 245 `ok` lines and 0 `not ok` lines.
- Numeric coverage headline: `Bash coverage (lines): 92.3%`.

The exact-head successful CI job resolves the local environment limitation without substituting a different repository state. The [P0-T20] numeric-coverage acceptance criterion is satisfied by the repository's configured Bats/kcov harness.
