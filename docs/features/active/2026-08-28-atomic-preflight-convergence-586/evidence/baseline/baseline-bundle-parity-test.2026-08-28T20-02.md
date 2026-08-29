# Baseline — Bundle Parity Test (Issue #586)

Timestamp: 2026-08-28T22-02

Task: [P0-T6]
Feature: docs/features/active/2026-08-28-atomic-preflight-convergence-586
Test file: `tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py`
Revision context: worktree state at HEAD `56dcad93cc3767de1191e89807fa31c248c4c87d`, before any Phase 1 edit.

Command: poetry run pytest tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py -p no:cacheprovider -q

EXIT_CODE: 0

Output Summary:

```
..........                                                               [100%]
10 passed in 0.12s
```

The summary line the command printed is `10 passed in 0.12s`, which records `10 passed`. That equals the passed count the plan states for the pre-change tree, and the command exited 0. No discrepancy, so Phase 1 is not blocked by this task.

This is the repository test that gates `.claude/**`-to-bundle byte parity. Its case `test_bundled_claude_payload_contains_all_repo_runtime_contracts` enumerates every repository `.claude/**` file except `.claude/settings.local.json` and the `.claude/agent-memory/**` subtree and asserts that the bundled copy is byte-equal to it. It is the automated form of the mirror-parity invariant that [P0-T5] recorded by blob hash, and [P2-T11] re-runs this same command as a final-QC gate expecting the same `10 passed` at exit 0.

No coverage argument is passed, and none is required: no language with a mandatory coverage policy is in scope for this plan, and this run executes an existing test as a payload-parity gate rather than measuring new code.
