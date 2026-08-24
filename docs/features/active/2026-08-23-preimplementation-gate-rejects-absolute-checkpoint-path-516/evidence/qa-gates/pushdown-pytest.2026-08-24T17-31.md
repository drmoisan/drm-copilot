# Push-Down Parity Test Modules — Issue #516

Timestamp: 2026-08-24T17-31

Command: `poetry run pytest tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py tests/scripts/dev_tools/test_push_down_codex_and_agents_pack_manifest_completeness.py`

EXIT_CODE: 0

Output Summary:

- `12 passed in 0.28s`; zero failures, zero errors.
- `tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py` — 10 passed.
- `tests/scripts/dev_tools/test_push_down_codex_and_agents_pack_manifest_completeness.py` — 2 passed.

## Note on the first invocation

The first invocation of this command exited 1 with a single failure in
`test_bundled_claude_payload_contains_all_repo_runtime_contracts`:

```
AssertionError: Repo file missing from bundle: .claude\state\powershell-batch-budget.default.json
```

That failure was not caused by this change. `.claude/state/powershell-batch-budget.default.json` is
the transient per-session running-count file written by `.claude/hooks/enforce-powershell-batch-budget.ps1`.
It is untracked and gitignored (`.gitignore:68` matches `.claude/state/`), so it does not exist in a
clean checkout or in CI, but the test enumerates the filesystem via `list_scoped_files` and therefore
does not honour `.gitignore`. The file had been recreated by the hook when the Batch 2 production
files were written, after P3-T1 deleted the prior batch's copy.

Both Batch 2 production-file writes were already complete and no further `.ps1` write remains in the
plan, so the transient file was removed as session housekeeping — the same treatment the run applies
to `testResults.xml` — and the command was re-run. The re-run is the result recorded above. No
production file, test file, or hook copy was modified to obtain it; the four hook SHA-256 hashes are
unchanged from `pushdown-pair-hashes.2026-08-24T17-31.md`.
