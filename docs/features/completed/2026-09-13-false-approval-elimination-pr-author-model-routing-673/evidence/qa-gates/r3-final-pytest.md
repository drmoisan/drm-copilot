# Final Full Python Suite (issue #673)

Timestamp: 2026-09-19T19-24

Command: `rm -f .claude/state/*` to clear the untracked, gitignored state directory; then `poetry run pytest -q`.

EXIT_CODE: 0

Final summary line, verbatim:

```
4419 passed, 5 skipped in 8.78s
```

The summary carries no `failed` count and no `error` count, which is the acceptance condition. The five skips are the same five the `[P0-T11]` baseline recorded, all in an unrelated parallel-manifest parity suite that skips fixtures declaring no accessor expectation. The passed count rose from 4418 to 4419.

## The state-directory clearance, and why it was necessary

The `[P0-T11]` baseline recorded this suite failing on one node ID:

```
tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py::test_bundled_claude_payload_contains_all_repo_runtime_contracts
```

`[P8-T8]` established the cause. That test enumerates repository `.claude` files through a filesystem walk at `tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py:130-134`, filtering out only `.claude/settings.local.json` and the `.claude/agent-memory/**` subtree, and applying **no gitignore filter**. `.gitignore:68` ignores the whole `.claude/state/` directory, so any file present there enters the required set and is demanded of the bundled payload, where it correctly does not exist.

Two independent writers populate that directory: a SessionStart hook writes a session identifier, and the PowerShell batch-budget gate writes a per-session slot file. This plan's own batch resets delete the latter and the gate recreates it at every phase boundary, so one slot file was present when this task began. `[P8-T8]` demonstrated the point by removing the first offender and exposing the second, which established that the defect is the directory being enumerated rather than any particular file in it.

Clearing the directory changed no tracked file and produced no entry in `git status --porcelain`, because nothing in it is tracked. A clean checkout and any CI runner has no such directory, which is why this test passes there and why the condition is invisible outside a development worktree. The clearance is the same operation the plan already mandates at every batch reset, applied to the same directory.

The underlying defect is pre-existing and out of this plan's scope. It is recorded here and in `[P0-T11]` and `[P8-T8]` so that this pass is attributable to a stated action rather than appearing to contradict the baseline.

Output Summary: The full Python suite passes with 4419 passed, 5 skipped, and no failure or error count, after clearing one untracked gitignored file from `.claude/state/`. The single failure the baseline recorded is a bundle-parity test that enumerates that gitignored directory; its cause, its two writers, and the reason a clean checkout never sees it are all recorded rather than left implicit.
