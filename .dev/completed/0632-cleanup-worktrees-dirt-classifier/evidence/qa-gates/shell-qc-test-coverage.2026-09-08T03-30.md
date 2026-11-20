# P7-T4 — bash coverage stage: INCOMPLETE, not a pass

Timestamp: 2026-09-08T03-30
HostClockAtWrite: 2026-09-08T03-20Z (nominal run-timestamp scheme).
Run by: atomic-executor, directly.

Command: `env SHELL_QC_BATS_BIN=<npx bats 1.13.0> bash scripts/bash/shell-qc.sh test --coverage`
EXIT_CODE: 127

```
kcov not installed; cannot run shell tests with coverage.
Missing required tool: kcov
Devcontainer install (apt-get): apt-get update && apt-get install -y kcov
macOS (Homebrew): brew install kcov
Ubuntu/Debian: sudo apt-get update && sudo apt-get install -y kcov
On Windows, use WSL for best results.
```

Output Summary: **INCOMPLETE**. No `Bash coverage (lines):` line was printed, so no numeric
percentage exists to record. This is recorded as INCOMPLETE rather than as a pass or a skip, per
the plan's own acceptance text and the No-SKIPPED rule in `atomic-plan-contract`.

## Why it cannot be completed from this session

Two independent obstacles, both environmental:

1. `kcov` is not installed on this Windows host and has no Windows build. `command -v kcov`
   returns non-zero.
2. The WSL route the plan's command form uses is denied to this delegated executor. Every
   `wsl.exe` invocation attempted from this session is refused by the worktree-isolation guard,
   including a bare `command -v` probe.

`shfmt`, `shellcheck` and `bats` were all available natively here, which is why P7-T1, P7-T2 and
P7-T3 were run first-hand. `kcov` is the one tool of the four with no local route.

## The route that exists, and why it is not this task's to take

The P0-T5 baseline (`evidence/baseline/shell-qc-test-coverage.2026-09-08T00-55.md`, 93.5% line
coverage) was captured by dispatching `.github/workflows/_shell-coverage.yml` against the branch,
for the same reason. That route measures the **pushed** branch state. The Phase 4 through Phase 7
work is uncommitted in this worktree — `git status --porcelain` reports the new library, the four
new and modified suites, and the wrapper edit as working-tree changes against `9b8e2266`. A
workflow dispatch now would therefore measure a tree that contains neither
`scripts/bash/cleanup_worktrees_dirt_lib.sh` nor any of the new tests, and would report a number
that says nothing about this change.

Committing and pushing is not a task in this plan and is not a micro-action within P7-T4.

## Handback

P7-T4 and the P7-T5 delta comparison that consumes it require, in order: the Phase 4 through
Phase 7 work committed and pushed, then either a `_shell-coverage.yml` workflow dispatch or a
`bash scripts/bash/shell-qc.sh test --coverage` run under WSL with kcov present. Both are outside
this session's capability. P7-T4, P7-T5 and P7-T8 remain unchecked in the plan.

Baseline for the eventual comparison: **93.5** line coverage, threshold **85.0**.
