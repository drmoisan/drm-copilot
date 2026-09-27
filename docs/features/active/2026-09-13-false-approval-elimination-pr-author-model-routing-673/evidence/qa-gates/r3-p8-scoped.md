# Phase 8 Scoped Verification (issue #673)

Timestamp: 2026-09-19T18-44

Command: `pwsh -NoProfile -File <SCRATCHPAD>/r3-test-scoped.ps1` (route `a`) with the scan-folder list supplied as `tests/scripts/claude-runtime`, running `Invoke-PoshQCTest -Root $root -ScanFolders tests/scripts/claude-runtime -SettingsPath scripts/powershell/PoshQC/settings/pester.runsettings.psd1`; then `poetry run pytest tests/scripts/dev_tools/test_parallel_orchestrator_surface_contracts.py tests/scripts/dev_tools/test_epic_bounded_child_return_contract.py tests/scripts/dev_tools/test_claude_rules_frontmatter.py tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py -q`.

EXIT_CODE: 0

## Pester

- JUnit report last write (UTC): `2026-09-19T18:45:18Z`, later than this artifact's `Timestamp:` of `2026-09-19T18-44`.
- Root: `tests` 78, `failures` 0, `errors` 0. Testcases carrying a `failure` child: none.

| Testsuite | tests | failures | skipped | disabled | passed |
| --- | --- | --- | --- | --- | --- |
| `checkpoint-hygiene-skill-contract.Tests.ps1` | 7 | 0 | 0 | 0 | 7 |

Seven passed and `failures` 0, as required.

## pytest

Final summary line, verbatim:

```
65 passed in 0.28s
```

The summary carries no `failed` and no `error` count.

## The two failing runs that preceded it, and the cause

The first two invocations of the pytest command failed, each on the same node ID:

```
tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py::test_bundled_claude_payload_contains_all_repo_runtime_contracts
```

Both are recorded here rather than discarded, because the cause governs two later tasks.

| Run | Summary | Offending path in the assertion |
| --- | --- | --- |
| 1 | `1 failed, 64 passed` | `.claude/state/current-session-id` |
| 2 | `1 failed, 64 passed` | `.claude/state/powershell-batch-budget.<session>.json` |
| 3 | `65 passed` | none |

The failure is not caused by this change set. `tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py:130-134` enumerates repository `.claude` files through a filesystem walk and filters out only `.claude/settings.local.json` and the `.claude/agent-memory/**` subtree. It applies **no gitignore filter**, while `.gitignore:68` ignores the whole `.claude/state/` directory. Any file present in that directory is therefore demanded of the bundled payload, where it correctly does not exist. The `[P0-T11]` baseline recorded this same failure before any task of this plan edited a file.

Run 2 is the informative one: removing the first offender exposed a second, which establishes that the defect is the *directory* being enumerated rather than any particular file in it. Two independent writers populate it — a SessionStart hook writes the session id, and the PowerShell batch-budget gate writes a per-session slot file — and this plan's own batch-resets delete and let the gate recreate the latter at every phase boundary.

Both files are untracked and gitignored, so removing them changed no tracked file and produced no entry in `git status --porcelain`. A clean checkout and any CI runner has no `.claude/state/` directory at all, which is why this test passes there and why the condition is invisible outside a development worktree.

Consequence for later tasks, recorded now rather than discovered at the gate: `[P11-T6]` requires the full Python suite to exit 0 and `[P11-T7]` requires this same test to report `1 passed`. Neither can hold while `.claude/state/` holds a file. Phase 9 writes PowerShell files through the tools the batch-budget gate observes, so a slot file will exist again by then, and the directory must be cleared immediately before those two tasks run. That clearing is the same operation the plan already mandates at every batch reset, applied to the same directory.

Output Summary: All three acceptance conditions hold on the recorded run. The Pester report post-dates this artifact's timestamp, `checkpoint-hygiene-skill-contract.Tests.ps1` has 7 passed and `failures` 0, and the pytest summary reads `65 passed` with no failure or error count. Two earlier failing runs are recorded with their node ID and their distinct offending paths; both stem from a pre-existing bundle-parity test that enumerates the gitignored `.claude/state/` directory, a condition the `[P0-T11]` baseline already captured and that does not reproduce on a clean checkout.
