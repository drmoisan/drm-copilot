# Fail-Before — Claude CommandExemption Suite After the Intended Reversal (issue #545)

Timestamp: 2026-09-07T11-48

Task: [P1-T9] `[expect-fail]`

Mandated command (attempted first, refused by the runtime worktree-isolation guard):
`pwsh -NoProfile -Command "Invoke-Pester -Path tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.CommandExemption.Tests.ps1 -Output Detailed"`

Command:
`mcp__drm-copilot__run_poshqc_test` with `workspace_root=C:\Users\DanMoisan\repos\drm-copilot\.claude\worktrees\agent-a478b73e41951af31` and `scan_folders=["tests/scripts/claude-hooks"]`

EXIT_CODE: 21

ExpectedExitCode: 1

## Reading the exit code

The observed exit code is **21**, non-zero as the fail-before requirement demands. `Run.Exit = $true`
makes Pester return the failed-test count over the whole executed scope. The 21 decomposes exactly:

| Source | Failing cases |
| --- | --- |
| `enforce-orchestration-preimplementation-gate.CommandExemption.Tests.ps1` (this task's suite) | 1 |
| `enforce-orchestration-preimplementation-gate.TriggerScoping.Tests.ps1` ([P1-T5], still red as designed) | 13 |
| `hook-command-parser.AcceptanceCases.Tests.ps1` ([P1-T3], still red as designed) | 6 |
| `enforce-pr-author-skill.Tests.ps1` (pre-existing at baseline, recorded in [P0-T7]) | 1 |
| **Total** | **21** |

## Route deviation

The mandated single-suite `pwsh` invocation was refused by the runtime worktree-isolation guard, in
the same terms recorded in [P0-T7]. The folder-scoped MCP route was used instead.

## Suite result

**59 cases: 1 failed, 58 passed**, 0 errors, 0 skipped, 0.486 s.

The baseline count for this suite recorded in [P0-T10] was **58** cases. It is now 59, which is
exactly the one `It` added by [P1-T8] and no more.

## The reversed `It` is the only newly failing pre-existing assertion

- Suite: `tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.CommandExemption.Tests.ps1`
- Describe: `enforce-orchestration-preimplementation-gate.ps1 command exemption (issue #539)`
- Context: `issue #539 residual whole-command-text behaviour (D3 and D8)`
- It: `denies a message-body payload that merely contains the staging literal`
- Expected after the reversal: `allow`
- Observed against the unfixed hook: `deny`
- Failure message: `Expected strings to be the same, because issue #545 masks a heredoc body attached to a non-wrapper segment, so the prose is data, but they were different. Expected length: 5, Actual length: 4`

This is the single intended assertion reversal on the Claude side. It is the **only** failing case in
the suite, so no other pre-existing assertion was disturbed by the edit.

## The new wrapper sibling `It` passes against the unfixed hook

- It: `denies the same heredoc body when it feeds a shell wrapper instead of a file`
- Result: **PASS**

This is the expected and required outcome, and it is the substantive reason the reversal is not a
fail-open change. The two cases carry the **identical** heredoc body; only the destination differs.
`cat > file` is a non-wrapper segment, so the body is data and must allow. `bash <<'NOTE'` feeds a
shell, so the body is executed and must deny. The wrapper case denies today and must keep denying
after the fix, which makes it a deny-preservation pin rather than a fail-before case.

## Every other pre-existing `It` in the file passed

58 of 59 cases pass. The 57 pre-existing cases other than the reversed one all pass, grouped as the
suite structures them:

- `issue #539 orchestration-tree staging exemption allow cases` — 8 cases, all PASS.
- `issue #539 mixed pathspec deny cases` — 4 cases, all PASS.
- `issue #539 fail-closed rule table deny cases` — 45 cases spanning D4 rows 1 through 19, all PASS.
  This includes rows **14a, 14b, 14c, and 14d**, the chained relocating denials that the spec's
  acceptance criteria name explicitly as assertions that must pass unmodified.

8 + 4 + 45 = 57 pre-existing passing cases, plus the 1 new wrapper sibling = 58 passing; plus the 1
reversed case = 59 total.

## Diff scope

`git diff origin/epic/cleanup-merged-worktrees-hardening-integration -- tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.CommandExemption.Tests.ps1`
shows three changes and no others:

1. The rationale comment of the reversed `It`, rewritten to cite issue #545 as [P1-T8] requires.
2. `Should -Be 'deny'` changed to `Should -Be 'allow'` on that one `It`, together with the removal of
   its companion `Should -Match 'PREIMPLEMENTATION_GATE_BLOCKED'` line. The companion removal is part
   of reversing the expected decision, not a separate assertion change: an allow decision carries no
   `permissionDecisionReason`, so retaining that line would assert against a property that does not
   exist on the expected outcome.
3. The new sibling `It` added immediately after it.

No other assertion in the file is modified. The file is 296 lines, up from 267, and remains under the
500-line cap.

Output Summary: **Fail-before recorded as required.** Non-zero exit code **21**, decomposing as 1
failure in this suite, 13 in the Claude trigger-scoping suite, 6 in the acceptance-cases suite, and 1
pre-existing baseline failure. This suite reports **59 tests, 1 failed, 58 passed**. The single
failure is the intended reversal, `denies a message-body payload that merely contains the staging
literal`, observed as `deny` where `allow` is now expected — **the only newly failing pre-existing
assertion**. The new wrapper sibling `denies the same heredoc body when it feeds a shell wrapper
instead of a file` **passes** against the unfixed hook. Every other pre-existing `It` in the file
passed, including D4 rows 14a through 14d.
