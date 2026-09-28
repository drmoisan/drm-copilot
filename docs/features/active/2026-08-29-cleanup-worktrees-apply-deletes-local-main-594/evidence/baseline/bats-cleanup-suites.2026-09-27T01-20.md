# P0-T10 — Baseline local bats run (cleanup-worktrees suites)

Timestamp: 2026-09-27T01-20
Task: [P0-T10]
Working directory: repository worktree root
Tool: bats-core 1.13.0 via `npx --yes bats`
Run window (UTC): 2026-09-27T01-10-51 to 2026-09-27T01-19-57 (about 9 minutes)

## Step 1 — per-file `@test` counts

Command: `grep -c -e '^@test ' tests/shell/test_cleanup_worktrees_enumeration.bats tests/shell/test_cleanup_worktrees_classification.bats tests/shell/test_cleanup_worktrees_deletion.bats`
EXIT_CODE: 0
Output:

```
tests/shell/test_cleanup_worktrees_enumeration.bats:12
tests/shell/test_cleanup_worktrees_classification.bats:19
tests/shell/test_cleanup_worktrees_deletion.bats:11
```

Per-file `@test` counts: enumeration 12, classification 19, deletion 11 (total 42; matches the plan's authoring values).

## Step 2 — full bats run (19 suite files)

Suite files matched by the glob (19): classification, cli, consolidation, deletion, detached, dirt_classify, dirt_clear, dirt_content_locations, dirt_failclosed, dirt_guard_registry, dirt_regression, enumeration, hard_failures, preserve, preserve_eol, preserve_failures, report_records, scan_helper, scan_seam (each `tests/shell/test_cleanup_worktrees_<name>.bats`).

Non-result output (verbatim, host path segments replaced with `<worktree>` and `<npx-cache>`):

```
The following warnings were encountered during tests:
BW01: `run`'s command `env CLEANUP_WT_JQ_BIN=<worktree>/tests/fixtures/cleanup_worktrees/preserve/no-jq/jq PATH=<worktree>/tests/fixtures/cleanup_worktrees/preserve/no-jq /bin/bash -c source '<worktree>/scripts/bash/cleanup_worktrees_preserve_lib.sh' && preserve_resolve_jq` exited with code 127, indicating 'Command not found'. Use run's return code checks, e.g. `run -127`, to fix this message.
      (from function `run' in file <npx-cache>/bats/lib/bats-core/test_functions.bash, line 420,
       in test file tests/shell/test_cleanup_worktrees_preserve.bats, line 133)
```

The BW01 line is a bats advisory warning from a pre-existing test in `test_cleanup_worktrees_preserve.bats` (outside this plan's scope); it does not change any test result.

Command: `npx --yes bats tests/shell/test_cleanup_worktrees_*.bats`
EXIT_CODE: 0

Output Summary:
- TAP plan: `1..231`.
- `ok` count: 231; `not ok` count: 0; skipped: 0.
- Baseline failure set: empty.
- Per-file `@test` counts: enumeration 12, classification 19, deletion 11.
- One pre-existing BW01 advisory warning (preserve suite, line 133); not a failure.
