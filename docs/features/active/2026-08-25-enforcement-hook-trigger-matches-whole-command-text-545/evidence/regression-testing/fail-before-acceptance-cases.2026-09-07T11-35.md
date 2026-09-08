# Fail-Before — Acceptance Cases AT-1 through AT-7 (issue #545)

Timestamp: 2026-09-07T11-35

Task: [P1-T3] `[expect-fail]`

Mandated command (attempted first, refused by the runtime worktree-isolation guard):
`pwsh -NoProfile -Command "Invoke-Pester -Path tests/scripts/claude-hooks/hook-command-parser.AcceptanceCases.Tests.ps1 -Output Detailed"`

Command:
`mcp__drm-copilot__run_poshqc_test` with `workspace_root=C:\Users\DanMoisan\repos\drm-copilot\.claude\worktrees\agent-a478b73e41951af31` and `scan_folders=["tests/scripts/claude-hooks"]`

EXIT_CODE: 7

ExpectedExitCode: 1

## Reading the exit code

The observed exit code is **7**, which is non-zero as the fail-before requirement demands. It is not
1 because the settings file sets `Run.Exit = $true`, under which Pester returns the **failed-test
count** as the process exit code, and the executed command ran the whole
`tests/scripts/claude-hooks` folder rather than the single suite. The 7 decomposes exactly:

| Source | Failing cases |
| --- | --- |
| `hook-command-parser.AcceptanceCases.Tests.ps1` (this task's suite) | 6 |
| `enforce-pr-author-skill.Tests.ps1` (pre-existing at baseline, recorded in [P0-T7]) | 1 |
| **Total** | **7** |

`ExpectedExitCode: 1` is carried as the plan's declared expectation field. The substantive
expectation — a non-zero exit produced by exactly the six named cases — is satisfied and is
demonstrated by the decomposition above rather than by the numeral.

## Route deviation

The mandated single-suite `pwsh` invocation was refused by the runtime worktree-isolation guard, in
the same terms recorded in [P0-T7]; no process started and no exit code was produced. The folder-
scoped MCP route was used instead. The substitution widens the run beyond the one suite, which is why
the exit-code decomposition above is stated explicitly; the per-case results below are read from this
suite's own `<testsuite>` element and are unaffected by the wider scope.

## Suite result

Verbatim `<testsuite>` record:

```
<testsuite name="C:\Users\DanMoisan\repos\drm-copilot\.claude\worktrees\agent-a478b73e41951af31\tests\scripts\claude-hooks\hook-command-parser.AcceptanceCases.Tests.ps1" tests="11" errors="0" failures="6" hostname="MEGALODON4" id="36" skipped="0" disabled="0" package="C:\Users\DanMoisan\repos\drm-copilot\.claude\worktrees\agent-a478b73e41951af31\tests\scripts\claude-hooks\hook-command-parser.AcceptanceCases.Tests.ps1" time="0.216">
```

11 cases: **6 failed, 5 passed**, 0 errors, 0 skipped.

The suite parsed and executed, so the file is syntactically valid and every hook dot-source
succeeded. A parse failure would have produced an error rather than six assertion failures.

## FAILING cases (6) — each with the observed value

Every observed value below matches the "Today" column of the spec's Test Strategy table exactly.
That correspondence is the substance of this fail-before record: the cases fail for the reason the
specification predicts, not for an unrelated reason.

### AT-1 — the mandatory latent-bypass case

- `It`: `AT-1 denies a relocating git worktree remove against an epic checkpoint with no authorizing record`
- Command text: `git -C /repo/main worktree remove /repo/worktrees/item-a-101`
- Required: `deny` with a reason beginning `EPIC_WORKTREE_REMOVAL_BLOCKED`
- Observed: `Expected: 'deny' But was: 'allow'`
- Significance: this is the one case demonstrating an **unauthorized destructive command proceeding
  today**. The `-C /repo/main` global option breaks adjacency, the scope filter does not match, and
  the removal runs with no checkpoint authorization at all.

### AT-2 — the issue #591 operand mis-parse

- `It`: `AT-2 returns 688 for a cd-prefixed gh pr merge whose PR number follows the merge flag`
- Command text: `cd C:\Users\DanMoisan\repos\TaskMaster-wt\2026-08-29T00-11 && gh pr merge --merge 688`
- Required: `688`
- Observed: `Expected 688, but got 2026.`
- Significance: the year token from the directory operand is returned as the pull-request number, so
  a correct, CI-green merge is denied.

### AT-3 — the promotion-hook over-match on receipt values

- `It`: `AT-3 allows a heredoc whose JSON body names promotion tools as receipt values`
- Required: `$null`
- Observed: `Expected $null or empty, but got 'PROMOTION_MCP_ONLY_BLOCKED: Direct Bash promotion-script execution is not allowed in agent sessions. Use the drm-copilot MCP promotion tools instead.'`
- Significance: this is the checkpoint-bootstrap blocker. The orchestrator-state schema requires the
  promotion tool names as values of `required_mcp_tools`, so writing a complete checkpoint through a
  heredoc is denied. No promotion tool executes on that line.

### AT-4 — the merge-gate over-match on quoted prose

- `It`: `AT-4 allows a printf whose double-quoted text mentions the gated merge phrase`
- Required: `allow`
- Observed: `Expected: 'allow' But was: 'deny'`
- Significance: this is the epic gap-8 instance recorded from the 2026-09-06 cleanup run, in which a
  `printf` writing a memory note was denied with `EPIC_MERGE_GATE_BLOCKED`. All three checkpoint
  seams were mocked to `$null` in this case, so the deny is attributable to the scope filter alone.

### AT-5 — the promotion-hook gh relocation bypass

- `It`: `AT-5 blocks a relocating gh issue create spelling that carries a repo global option`
- Command text: `gh --repo drmoisan/drm-copilot issue create --title "x" --body "y"`
- Required: the gh-issue blocked reason
- Observed: `Expected a value, but got $null or empty.`
- Significance: a raw issue creation proceeds ungated, bypassing the MCP promotion route entirely.

### AT-7 — the cross-runtime operand divergence

- `It`: `AT-7 resolves the worktree path when the force flag precedes it, in both removal gates`
- Command text: `git worktree remove --force /repo/worktrees/item-a-101`
- Required: `/repo/worktrees/item-a-101` from both `Get-ParallelWorktreeRemovalCommandPath` and `Get-EpicWorktreeRemovalCommandPath`
- Observed: `Expected: '/repo/worktrees/item-a-101' But was: '--force'`
- Significance: the literal `--force` is captured as the worktree path, matching no checkpoint record
  and falsely denying a legitimate removal. The Codex copy of the epic gate already handles this
  spelling, so the two runtimes have diverged.

## PASSING cases (5)

| `It` | Why it must pass today |
| --- | --- |
| `AT-6 still classifies a pwsh -Command wrapper carrying a test invocation` | The deny-preservation pin. It passes today and must keep passing; it is the assertion that breaks if the issue #539 D8 fail-open objection is answered wrongly. |
| `paired negative for AT-2: a bare gh pr merge --merge with no number still returns $null` | Issue #591 constraint 1. |
| `paired negative for AT-2: the number-before-flag form gh pr merge 410 --merge still returns 410` | Issue #591 constraint 2. |
| `paired negative for AT-3: a genuine promotion-script invocation still returns its blocked reason` | The over-match removal must not weaken a real denial. |
| `paired negative for AT-5: a relocating gh issue list spelling still returns $null` | The structural gh classifier must match issue-creation subcommands only. |

6 failing + 5 passing = 11, which is the full case count of the suite.

Output Summary: **Fail-before recorded as required.** Non-zero exit code **7**, decomposing as 6
failures in this suite plus the 1 pre-existing baseline failure in
`enforce-pr-author-skill.Tests.ps1`. The suite reports 11 tests, **6 failed, 5 passed**. The six
failing cases are exactly **AT-1, AT-2, AT-3, AT-4, AT-5, and AT-7**, each failing with the value the
specification predicts for the unfixed hooks (`allow` instead of `deny`; `2026` instead of `688`; the
`PROMOTION_MCP_ONLY_BLOCKED` reason instead of `$null`; `deny` instead of `allow`; `$null` instead of
the gh-issue reason; `--force` instead of the worktree path). **AT-6 passes**, as do all four paired
negatives. This is the contracted fail-before state for both regression directions.
