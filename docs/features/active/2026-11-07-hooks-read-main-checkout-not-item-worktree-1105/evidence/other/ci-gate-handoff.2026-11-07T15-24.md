# CI-dependent criterion handoff (issue 1105)

Timestamp: 2026-11-07T15-24
Task: [P4-T5]
Command: none (handoff record; no command is run by the executor for this task)
EXIT_CODE: 0
Output Summary: AC-16 is pending CI and is handed to the orchestrator.

- Criterion (AC-16, `spec.md` `## Acceptance Criteria`): "CI-dependent: the CI Required Gate is green on the PR head SHA."
- Owner: the item's orchestrator run, after the pull request for branch `bug/hooks-read-main-checkout-1105` is opened. The executor cannot observe it, because no pull request exists during plan execution.
- Check observed: `CI Required Gate` on the pull-request head commit.
- Pester jobs relied on:
  - `poshqc / PowerShell QC` (aggregator of the Windows shard jobs `poshqc / PowerShell QC shard 1`, `shard 2`, and `shard 3` on `windows-latest`, with coverage).
  - `poshqc / PowerShell hook suites (Linux)` (runs `tests/scripts/claude-hooks`, which holds the eight new suites, on `ubuntu-latest`, with coverage disabled).
- The AC-16 checkbox in `spec.md` stays unchecked until the orchestrator observes `CI Required Gate` green on the final PR head.
