# Baseline Push-Down And No-Python Guard State

Timestamp: 2026-09-08T00-24

Task: [P0-T8]

Command (Python suites):
`poetry run pytest tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py tests/scripts/dev_tools/test_push_down_claude_pack_manifest_completeness.py -q --no-header -p no:cacheprovider`

EXIT_CODE: 0

The command was run without a pipe so the reported exit status is pytest's own and not a downstream
filter's.

## Python suites

```
.............                                                            [100%]
13 passed in 0.19s
```

| Suite | Verdict | Test count |
| --- | --- | --- |
| `tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py` | **pass** | combined 13 across both files |
| `tests/scripts/dev_tools/test_push_down_claude_pack_manifest_completeness.py` | **pass** | combined 13 across both files |

`test_push_down_claude_resource_contracts.py` did **not** fail, so the conditional branch this task
defines — recording every reported missing path and deciding whether all of them sit under
`.claude/state/` — has no subject at baseline. The reported-path list a later task would compare
against is therefore **empty**.

## `.claude/state/` existence at baseline

Command: `ls -la .claude/state`

EXIT_CODE: 2

Output: `ls: cannot access '.claude/state': No such file or directory`

**`.claude/state/` does not exist at baseline.** This is why
`test_push_down_claude_resource_contracts.py` passes here: the enumeration at that module's lines
39-48 walks the `.claude` tree and finds nothing under a directory that is absent. The directory is
gitignored and is created during execution by `persist-session-id.ps1` and
`enforce-powershell-batch-budget.ps1`, so the condition is expected to appear once this plan's first
PowerShell write or its first batch-budget reset runs. [P6-T6] and [P8-T7] are written against the
set recorded here, which at baseline is the empty set.

## PowerShell no-Python guard suite

Command: the suite ran as part of the [P0-T7] full-suite run
(`mcp__drm-copilot__run_poshqc_test`, `workspace_root=C:/Users/DanMoisan/repos/drm-copilot/.claude/worktrees/agent-a5a6952a0a1e65c6e`).
Its per-suite result was read from the `testsuite` element in `artifacts/pester/pester-junit.xml`
written by that run.

Route note: a standalone `pwsh -NoProfile -Command "Invoke-Pester -Path
tests/scripts/claude-runtime/enforcement-hooks-no-python-invocation.Tests.ps1"` invocation is refused
by the runtime worktree-isolation guard, as recorded in the [P0-T2] artifact in this folder. Reading
the element from the full run avoids overwriting the [P0-T7] baseline output files with a targeted
rerun, and observes the same suite executing on the same tree.

Start tag, transcribed verbatim:

```
<testsuite name="C:\Users\DanMoisan\repos\drm-copilot\.claude\worktrees\agent-a5a6952a0a1e65c6e\tests\scripts\claude-runtime\enforcement-hooks-no-python-invocation.Tests.ps1" tests="27" errors="0" failures="0" hostname="MEGALODON4" id="111" skipped="0" disabled="0" package="C:\Users\DanMoisan\repos\drm-copilot\.claude\worktrees\agent-a5a6952a0a1e65c6e\tests\scripts\claude-runtime\enforcement-hooks-no-python-invocation.Tests.ps1" time="1.715">
```

Derived passed = 27 - 0 (`failures`) - 0 (`errors`) - 0 (`skipped`) - 0 (`disabled`) = **27**.

| Suite | Verdict | Test count |
| --- | --- | --- |
| `tests/scripts/claude-runtime/enforcement-hooks-no-python-invocation.Tests.ps1` | **pass** | 27 |

The named test is present with a passing status:

```
<testcase name="enforcement hooks must not invoke Python.allowlist policy.ships an empty allowlist" status="Passed" ...
```

Output Summary: All three suites pass at baseline. Python:
`test_push_down_claude_resource_contracts.py` and
`test_push_down_claude_pack_manifest_completeness.py` together report **13 passed**, exit code 0, and
neither failed, so the reported-missing-path list is empty. PowerShell:
`enforcement-hooks-no-python-invocation.Tests.ps1` reports **27 tests, 0 failures, 0 errors**, derived
27 passed, and its named test `ships an empty allowlist` is present with status `Passed`.
`.claude/state/` **does not exist** at baseline. The blocking precondition this task defines — a
`test_push_down_claude_resource_contracts.py` failure reporting a path outside `.claude/state/` — was
**not** triggered, because that suite did not fail.
