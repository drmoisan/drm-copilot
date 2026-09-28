# Marker pass is behaviour-neutral and survives the formatter — [P2-T2]

Timestamp: 2026-09-08T08-30
Task: [P2-T2]
WorkingDirectory: C:\Users\DanMoisan\repos\drm-copilot\.claude\worktrees\agent-ac72d35e7980bc69d

## Command 1 — the four dirt suites

Command: npx --yes bats --formatter tap tests/shell/test_cleanup_worktrees_dirt_classify.bats tests/shell/test_cleanup_worktrees_dirt_failclosed.bats tests/shell/test_cleanup_worktrees_dirt_clear.bats tests/shell/test_cleanup_worktrees_dirt_regression.bats
EXIT_CODE: 0

TAP plan line: 1..59
OkCount: 59
NotOkCount: 0

## Command 2 — the shell QC check stage

Command: bash scripts/bash/shell-qc.sh check
EXIT_CODE: 0

Combined stdout and stderr, reproduced verbatim between the fences. The block is empty
because `run_check` prints nothing on a clean run: `shfmt -d` emits no diff and
`shellcheck` emits no findings, and `run_check` prints no summary of its own.

```
```

Byte length of the captured combined output: 0.

## Library line count

LineCountBeforeMarkerPass: 481
LineCountAfterMarkerPass: 481

The marker pass appended trailing comments only. No line was added or removed.

## Marker re-count after the check run

Command: grep -cE '# guard:[a-z0-9-]+$' scripts/bash/cleanup_worktrees_dirt_lib.sh
Result: 37

Command: grep -cE '\(\([A-Za-z_][A-Za-z0-9_]* (==|!=|>=|<=|>|<) [0-9]+\)\)' scripts/bash/cleanup_worktrees_dirt_lib.sh
Result: 31

Every marker is still the last text on its own line, so every `$`-anchored `sed` address
the registry composes still resolves.

## Formatter intervention, recorded rather than elided

The first `bash scripts/bash/shell-qc.sh check` run after the marker pass exited 1. `shfmt -d`
reported a two-hunk diff: shfmt aligns the `#` column across a run of consecutive lines that
each carry an inline comment, and two such runs existed after the marker pass — lines 405/406
and lines 432/433. The reported diff was whitespace before the `#` only; no code text and no
marker id was altered.

`bash scripts/bash/shell-qc.sh format` was then run (EXIT_CODE: 0), which applied that
alignment, and the toolchain loop was restarted from the top: the four bats suites were re-run
(EXIT_CODE: 0, 59 ok, 0 not ok) and `check` was re-run (EXIT_CODE: 0, empty output). The
figures recorded above are from that clean pass. The alignment inserts additional spaces
before the `#` on lines 405 and 433; the marker text remains at end of line, which is why the
re-count still reports 37.
