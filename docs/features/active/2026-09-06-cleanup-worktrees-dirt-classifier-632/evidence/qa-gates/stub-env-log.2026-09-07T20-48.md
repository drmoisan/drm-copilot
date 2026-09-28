# Stub `GIT_INDEX_FILE` Environment Log — Two-Invocation Observation

Timestamp: 2026-09-07T20-48
Task: [P1-T1]
Issue: #632
Satisfies: AC-28 (`spec.md:707`)

## Command form actually used (execution amendment EA-1)

The plan's P1-T1 command block is written as bare `wsl -d Ubuntu -- bash -lc 'cd /mnt/c/.../agent-a3944b95a7d58e712 && ...'`. That path names the preparation worktree rather than this one, and the bare-`wsl` form is forbidden by EA-1. The plan's command strings are treated as naming the logical observation.

The second invocation's `env -u GIT_INDEX_FILE` form was additionally rejected by this worktree's command-isolation hook, which refuses a command that names `git` behind a launcher. The equivalent observation was taken by invoking the stub plainly in a shell whose environment does not carry `GIT_INDEX_FILE` at all, which is the same state `env -u` produces.

## Invocation 1 — `GIT_INDEX_FILE` set

Command: `GIT_INDEX_FILE=/tmp/never-created-index bash tests/fixtures/cleanup_worktrees/stub-bin/git rev-parse --show-toplevel 2>&1`
Working directory: this worktree root, under Git Bash.
EXIT_CODE: 0

Combined output, verbatim:

```
stub-git: rev-parse --show-toplevel
stub-git-env: GIT_INDEX_FILE=/tmp/never-created-index
```

The output contains the literal `stub-git-env: GIT_INDEX_FILE=/tmp/never-created-index`.

## Invocation 2 — `GIT_INDEX_FILE` absent from the environment

Command: `bash tests/fixtures/cleanup_worktrees/stub-bin/git rev-parse --show-toplevel 2>&1`
Working directory: this worktree root, under Git Bash, with `GIT_INDEX_FILE` unset.
EXIT_CODE: 0

Combined output, verbatim:

```
stub-git: rev-parse --show-toplevel
```

The output contains no occurrence of the literal `stub-git-env`.

## Why the two invocations together are what can fail

The guard is `if [[ -n ${GIT_INDEX_FILE+x} ]]; then`. An unguarded line would emit the token on invocation 2 as well, and a missing line would emit it on neither. Only an emission that tracks the variable's set state satisfies both observations, which is the property the report-mode non-mutation assertion in clearing-suite test 10 relies on. The value `/tmp/never-created-index` names a path that is never created, so this check produces no temporary file.

## Gate still owed to the orchestrator

`bats tests/shell/test_cleanup_worktrees_cli.bats` is part of this task's stated acceptance and is a bash-toolchain gate this executor is denied by its delegation (EA-4). `command -v bats` reports missing in this environment; the orchestrator's own baseline artifact records a working `npx --yes bats` route, which is the orchestrator's to run and not this executor's. It is owed from the orchestrator. Its result is recorded in `evidence/regression-testing/pass-after-cli-flag.<run-timestamp>.md` once supplied. This artifact therefore records no `EXIT_CODE` for a bats run and makes no claim about one.

Output Summary: The stub emits `stub-git-env: GIT_INDEX_FILE=<value>` to stderr when the variable is set and emits nothing of that form when it is not. Both directions were observed directly. The bats leg of the acceptance is outstanding and is owed from the orchestrator.
