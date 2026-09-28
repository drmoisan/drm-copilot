# Push-Down Resource Contracts — State-File Exemption (Final Pass)

Timestamp: 2026-09-08T08-47

Task: [P8-T7]

Command:
`poetry run pytest tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py -q --no-header -p no:cacheprovider`

EXIT_CODE: 1

ExpectedExitCode: 1

This artifact path is `evidence/qa-gates/push-down-resource-contracts-state-exempt-final.2026-09-06T23-09.md`.
It differs from `evidence/qa-gates/push-down-resource-contracts-state-exempt.2026-09-06T23-09.md`,
which [P6-T6] wrote, so the Phase 6 record survives this pass unmodified.

## Result

Console summary transcribed verbatim:

```
1 failed, 10 passed in 0.15s
```

| Field | Value |
| --- | --- |
| Passed | 10 |
| Failed | 1 |
| Exit status | 1 |
| Failing node | `test_bundled_claude_payload_contains_all_repo_runtime_contracts` |

`ExpectedExitCode: 1` is declared because the success case of this gate is a non-zero exit, provided
every reported path sits under `.claude/state/`. The declaration is not a blanket waiver: it holds
only for the path list enumerated below, and any tracked `.claude` path appearing in that list would
fail this gate and restart the toolchain loop at [P8-T1].

## Complete reported-path list

The assertion in the test raises on the first path it finds missing from the bundle, so the pytest
output alone surfaces one path and cannot demonstrate that it is the only one. The plan requires the
list to be recorded as a **complete** list, so the same enumeration the test performs was re-run
exhaustively, importing the test module's own `list_scoped_files`, `BUNDLED_ROOT`, `REPO_ROOT` and
`_is_agent_memory_path` helpers so the filter is identical to the one under test rather than a
reimplementation of it.

Command: `poetry run python <enumeration script importing test_push_down_claude_resource_contracts>`,
exit status 0. Output transcribed verbatim:

```
REPO_SCOPED_COUNT: 193
BUNDLED_SCOPED_COUNT: 205
MISSING_COUNT: 1
MISSING: .claude/state/powershell-batch-budget.worktree-agent-a5a6952a0a1e65c6e-eefb09b2.json
```

The complete list of repo `.claude` files missing from the bundled payload is therefore exactly one
entry:

1. `.claude/state/powershell-batch-budget.worktree-agent-a5a6952a0a1e65c6e-eefb09b2.json`

## Exemption check, path by path

| Reported path | Under `.claude/state/` | Matches a permitted shape |
| --- | --- | --- |
| `.claude/state/powershell-batch-budget.worktree-agent-a5a6952a0a1e65c6e-eefb09b2.json` | **yes** | the batch-budget state file under that directory whose name embeds the resolved session id |

The plan permits each reported path to be either `.claude/state/current-session-id` or the
batch-budget state file under that directory whose name embeds the resolved session id. The single
reported path is the second of those two shapes: its name is
`powershell-batch-budget.` followed by the resolved session id
`worktree-agent-a5a6952a0a1e65c6e-eefb09b2` and the `.json` suffix. A directory listing confirms it
is the only file present under `.claude/state/`:

```
-rw-r--r-- 1 DanMoisan 197121 399 Sep  8 04:02 powershell-batch-budget.worktree-agent-a5a6952a0a1e65c6e-eefb09b2.json
```

`.claude/state/current-session-id` does not exist in this worktree on this pass, which is consistent
with the list above rather than in tension with it: the plan's permitted set is a set of allowed
shapes, not a required set of entries.

Every reported path sits under `.claude/state/`, so the exempt condition holds and the gate passes
under its declared expectation.

## Why the exemption is structural

Command: `git check-ignore -v .claude/state/powershell-batch-budget.worktree-agent-a5a6952a0a1e65c6e-eefb09b2.json`,
exit status 0, output transcribed verbatim:

```
.gitignore:68:.claude/state/	.claude/state/powershell-batch-budget.worktree-agent-a5a6952a0a1e65c6e-eefb09b2.json
```

`.claude/state/` is gitignored at `.gitignore:68`. The directory holds per-session runtime state
written by `.claude/hooks/enforce-powershell-batch-budget.ps1` during this very execution; it is
untracked, machine-local, and by construction never part of the bundled `claude-customizations`
payload. Its absence from the bundle is therefore a structural property of the ignore rule rather
than a missed push-down mirror.

The baseline set [P0-T8] recorded is empty. This pass reports one entry. The plan states explicitly
that this list is not required to equal the baseline set, and the difference is accounted for: the
batch-budget state file did not exist when [P0-T8] ran and was created later by the batch-budget
hook as this plan's PowerShell edits proceeded.

## What this result does not indicate

The failure branch the plan describes — in which the [P8-T1] format pass rewrote a source file
without its Phase 5 or Phase 6 mirror — would surface a **tracked** `.claude` path in the list
above. No tracked path appears. No mirror task therefore required re-running, no PowerShell
batch-budget reset was needed, and the toolchain loop does not restart at [P8-T1].

Output Summary: `test_push_down_claude_resource_contracts.py` exited **1** with 10 passed and 1
failed, which is the declared expected outcome (`ExpectedExitCode: 1`). The complete missing-path
list, derived by re-running the test's own enumeration exhaustively rather than reading the
first-failure message, contains exactly **one** entry:
`.claude/state/powershell-batch-budget.worktree-agent-a5a6952a0a1e65c6e-eefb09b2.json`. It sits
under `.claude/state/` and is the batch-budget state file whose name embeds the resolved session id,
which is a permitted shape. `.claude/state/` is gitignored at `.gitignore:68`, so the file is
untracked per-session runtime state and its absence from the bundle is structural. No tracked
`.claude` path was reported, so no mirror re-run and no batch-budget reset were required and the
gate passes.
