# Post-Change Regression Evidence — One-Unmerged Fixture [P5-T2] [expect-fail]

Timestamp: 2026-08-24T23-05

Task: [P5-T2]
Working directory: `C:\Users\DanMoisan\repos\drm-copilot\.claude\worktrees\agent-ad5151536d95b2586` (repository root of the worktree)
Fixture: `docs/features/active/2026-08-23-epic-require-complete-demands-launch-binding-no-agent-ever-writes-524/evidence/regression-testing/fixture-four-features-one-unmerged.json`

Command: `poetry run python -m scripts.dev_tools.validate_orchestration_artifacts epic-orchestrator-state docs/features/active/2026-08-23-epic-require-complete-demands-launch-binding-no-agent-ever-writes-524/evidence/regression-testing/fixture-four-features-one-unmerged.json --require-complete`

EXIT_CODE: 1
ExpectedExitCode: 1

Output Summary:

- Total errors: **1**.
- Launch-binding errors (lines containing `launch binding`): **0**.
- Errors containing the phrase `merge_status is not merged/worktree_removed`: **1**.

Full output, verbatim:

```
Epic checkpoint completion validation failed: feature 'child-d' merge_status is not merged/worktree_removed.
```

Comparison against the pre-change run recorded in
`docs/features/active/2026-08-23-epic-require-complete-demands-launch-binding-no-agent-ever-writes-524/evidence/regression-testing/before-one-unmerged.2026-08-24T22-32.md`:

| Measure | Before (P1-T4) | After (P5-T2) |
| --- | --- | --- |
| EXIT_CODE | 1 | 1 |
| Total errors | 21 | 1 |
| Launch-binding errors | 20 | 0 |
| `merge_status is not merged/worktree_removed` errors | 1 | 1 |

Discrimination guarantee: the completion gate still fails on a genuinely incomplete epic. The 20
launch-binding errors that the Claude runtime could never satisfy are gone; the single genuine
completion error for the unmerged `child-d` feature is preserved unchanged, and the run still exits
non-zero.

Expect-fail rationale: a non-zero exit is the correct and required outcome for this task. The
non-zero exit proves that removing the Codex-only launch-binding requirement did not disable the
completion gate itself.
