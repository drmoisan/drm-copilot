# Phase 0 Python Suite Baseline (issue #673)

Timestamp: 2026-09-19T17-32

Command: `poetry run pytest -q`

EXIT_CODE: 1

Final summary line, verbatim:

```
1 failed, 4418 passed, 5 skipped in 11.89s
```

Node ID of every failed or errored test:

- `tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py::test_bundled_claude_payload_contains_all_repo_runtime_contracts`

## Diagnosis of the single failure (recorded, not waived)

The failing assertion is `Repo file missing from bundle: .claude/state/current-session-id`.

Established facts, verified against this tree rather than assumed:

- `git ls-files --error-unmatch .claude/state/current-session-id` reports the path is not known to git, so the file is **untracked**.
- `git check-ignore -v .claude/state/current-session-id` reports `.gitignore:68:.claude/state/`, so the whole `.claude/state/` directory is **gitignored**.
- The file exists in this worktree's filesystem and holds a session identifier written by the runtime.
- `tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py:130-134` enumerates repository `.claude` files through `list_scoped_files(REPO_ROOT)`, which walks the filesystem. It filters out only `.claude/settings.local.json` and the `.claude/agent-memory/**` subtree; it applies no gitignore filter. The untracked, ignored state file therefore enters the required set and is demanded of the bundle, where it correctly does not exist.

The failure is consequently a property of the local working environment and not of the repository contents: a clean checkout, and any CI runner, has no `.claude/state/` directory, so the same test passes there. It is pre-existing on this branch, is unrelated to issue #673, and no commit of this change set has touched anything it reads.

Consequence for later tasks, stated now rather than discovered later: `[P11-T6]` requires `EXIT_CODE: 0` with no `failed` count and `[P11-T7]` requires this same test to report `1 passed`. Neither is satisfiable while an untracked file exists under the gitignored `.claude/state/` directory. The condition is recorded here so that its handling at `[P11-T6]` is auditable against this baseline rather than silent. It is not waived at baseline, because capturing the baseline after removing the file would have concealed a pre-existing condition.

Output Summary: The Python suite records 4418 passed, 1 failed, 5 skipped. The passed count is numeric as the acceptance condition requires. The one failure is `test_bundled_claude_payload_contains_all_repo_runtime_contracts`, caused by an untracked file under the gitignored `.claude/state/` directory being enumerated from the filesystem by a bundle-parity test that applies no gitignore filter. The failure predates this change set and does not reproduce on a clean checkout.
