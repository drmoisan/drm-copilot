# Phase 0 — Restore of the Tracked `coverage.xml` after the Defective Run (P0-T7)

Timestamp: 2026-08-25T22-00

Task: [P0-T7]
Class: command task — this artifact records the restore command and the status confirmation.
It carries **no** `ExpectedExitCode:` row.
Working directory: the resolved repository root `C:/Users/DanMoisan/repos/drm-copilot/.claude/worktrees/agent-ad22fbcf94d2d5359` (resolved by P0-T2)

The pytest command this restore follows is recorded in the sibling artifact
`docs/features/active/2026-08-22-ci-coverage-targets-nonexistent-package-506/evidence/baseline/defective-coverage-command-repro.md`.
The split is mandatory and must not be recombined.

## Precondition — `coverage.xml` is a tracked file

Confirmed before the defective run:

```text
git ls-files --error-unmatch coverage.xml   ->   coverage.xml   (exit 0)
git status --porcelain -- coverage.xml      ->   no output      (exit 0)
```

The file is tracked, is not ignored, and was clean before the run.

## Command 1 of 2 — restore

Timestamp: 2026-08-25T22-00
Command: `git checkout -- coverage.xml`
EXIT_CODE: 0
Output Summary: The command produced no output and exited 0. It was run from the resolved repository root immediately after the P0-T7 pytest command.

## Command 2 of 2 — confirm the restore

Timestamp: 2026-08-25T22-00
Command: `git status --porcelain -- coverage.xml`
EXIT_CODE: 0
Output Summary: **The command produced no output.** The tracked `coverage.xml` therefore matches its committed content, appears in no working-tree status a later gate reads, and will appear in no committed diff.

Both exit codes were captured directly from their commands, not through a pipe consumer.

## Observation

The defective pytest command's XML report generation failed before writing
(`Failed to generate report: No data to report.`), so on this run the tracked file was never
overwritten in the first place — `git status --porcelain -- coverage.xml` already produced no
output immediately after the pytest run. The restore was executed unconditionally regardless,
because the plan's mandated sequence must not be made conditional on an observation of whether
the write occurred.

## Acceptance

| Condition | Result |
| --- | --- |
| Restore artifact records that the restore command exits 0 | PASS — `EXIT_CODE: 0` |
| `git status --porcelain -- coverage.xml` produces no output | PASS — no output |
| Artifact carries no `ExpectedExitCode:` row | PASS |

Verdict: PASS. `coverage.xml` is clean.
