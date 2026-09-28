# Pass-after — AT-1 and AT-7 close (`hook-command-parser.AcceptanceCases.Tests.ps1`)

Timestamp: 2026-09-07T14-31

Task: [P8-T14]

TOOLCHAIN_SUBSTITUTION: the plan's targeted form
`pwsh -NoProfile -Command "Invoke-Pester -Path tests/scripts/claude-hooks/hook-command-parser.AcceptanceCases.Tests.ps1 -Output Detailed"`
is not invocable in this session — `pwsh`, `powershell`, and `cmd` are all refused by the runtime
worktree-isolation guard, so no process starts and no exit code is produced. The folder-scoped MCP
runner was used instead. Per-case results were read from the `<testcase>` elements inside the
`<testsuite>` element whose `name` ends with that suite's file name; a `<testcase>` with no
`<failure>` and no `<error>` child is how Pester's JUnit writer records a passing case.

Command: `mcp__drm-copilot__run_poshqc_test` with
`workspace_root=C:/Users/DanMoisan/repos/drm-copilot/.claude/worktrees/agent-a478b73e41951af31` and
`scan_folders=["tests/scripts/claude-hooks"]`

EXIT_CODE: 3 (folder-wide failed-test count)

## Suite result

```
<testsuite ...hook-command-parser.AcceptanceCases.Tests.ps1 tests="11" failures="2" errors="0" skipped="0" time="0.275">
```

Derived passed count: `11 - 2 - 0 - 0` = **9**.

## Per-case results, all eleven

| Case | Result |
| --- | --- |
| `AT-1 denies a relocating git worktree remove against an epic checkpoint with no authorizing record` | **PASS** |
| `AT-2 returns 688 for a cd-prefixed gh pr merge whose PR number follows the merge flag` | FAIL |
| `AT-3 allows a heredoc whose JSON body names promotion tools as receipt values` | PASS |
| `AT-4 allows a printf whose double-quoted text mentions the gated merge phrase` | FAIL |
| `AT-5 blocks a relocating gh issue create spelling that carries a repo global option` | PASS |
| `AT-6 still classifies a pwsh -Command wrapper carrying a test invocation` | PASS |
| `AT-7 resolves the worktree path when the force flag precedes it, in both removal gates` | **PASS** |
| `paired negative for AT-2: a bare gh pr merge --merge with no number still returns $null` | PASS |
| `paired negative for AT-2: the number-before-flag form gh pr merge 410 --merge still returns 410` | PASS |
| `paired negative for AT-3: a genuine promotion-script invocation still returns its blocked reason` | PASS |
| `paired negative for AT-5: a relocating gh issue list spelling still returns $null` | PASS |

## The two cases this task closes

**AT-1** (inventory row 1). The fixture is
`git -C /repo/main worktree remove /repo/worktrees/item-a-101` against an epic checkpoint whose only
`features[]` record names `/repo/worktrees/item-b-102`, with the parallel seam mocked absent. Before
[P8-T1] the gate's scope filter required `git` and `worktree remove` to be adjacent, so the `-C`
global option took the command out of scope entirely and the gate returned `allow`: an unauthorized
destructive removal proceeded with no checkpoint check. After [P8-T1] the filter is
`Test-CommandLineInvocation -CommandWord 'git' -SubcommandPath @('worktree','remove')`, which skips
the modeled `-C <arg>` pair, so the command is in scope, the checkpoint authorizes nothing, and the
gate denies with a reason beginning `EPIC_WORKTREE_REMOVAL_BLOCKED`.

**AT-7** (inventory row 6). The fixture is `git worktree remove --force /repo/worktrees/item-a-101`
and the case asserts both extractors resolve `/repo/worktrees/item-a-101`. The `It` asserts
`Get-ParallelWorktreeRemovalCommandPath` first and `Get-EpicWorktreeRemovalCommandPath` second, so it
could not pass until both were fixed: [P8-T1] supplied the second and [P8-T10] supplied the first.
Both now resolve the operand through `Get-CommandLineOperand`, which skips `--force` as a known
zero-argument flag rather than returning it as the path. This also closes the cross-runtime
divergence the case records, because the Codex copy already handled the spelling and [P8-T6] moved it
onto the same parser.

## Remaining known-red inventory

| Row | `It` | Suite | Closed by |
| --- | --- | --- | --- |
| 2 | `AT-2 returns 688 for a cd-prefixed gh pr merge whose PR number follows the merge flag` | `hook-command-parser.AcceptanceCases.Tests.ps1` | [P9-T11] |
| 4 | `AT-4 allows a printf whose double-quoted text mentions the gated merge phrase` | `hook-command-parser.AcceptanceCases.Tests.ps1` | [P9-T11] |

Both are Phase 9 rows and both are members of the [P1-T13] inventory, so the remaining failing names
in this suite are a subset of that inventory. Inventory remainder after this task: **2 of 34 rows**.

Output Summary: `hook-command-parser.AcceptanceCases.Tests.ps1` reports **11 tests, 2 failures, 0
errors, 0 skipped**, a derived passed count of **9**. **AT-1 and AT-7 both PASS**, closing known-red
inventory rows 1 and 6. The two remaining failures, AT-2 and AT-4, are inventory rows 2 and 4, which
[P9-T11] closes; the failing set is therefore a strict subset of the [P1-T13] inventory and contains
no name outside it. All four paired negatives and AT-3, AT-5, and the AT-6 deny pin continue to pass,
so nothing was weakened to reach this state.
