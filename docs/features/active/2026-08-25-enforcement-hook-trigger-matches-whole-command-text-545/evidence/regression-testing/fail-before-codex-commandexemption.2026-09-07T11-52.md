# Fail-Before — Codex Command-Exemption Suite After the Intended Reversal (issue #545)

Timestamp: 2026-09-07T11-52

Task: [P1-T11] `[expect-fail]`

Mandated command (attempted first, refused by the runtime worktree-isolation guard):
`pwsh -NoProfile -Command "Invoke-Pester -Path tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-command-exemption.Tests.ps1 -Output Detailed"`

Command:
`mcp__drm-copilot__run_poshqc_test` with `workspace_root=C:\Users\DanMoisan\repos\drm-copilot\.claude\worktrees\agent-a478b73e41951af31` and `scan_folders=["tests/scripts/codex-hooks"]`

EXIT_CODE: 15

ExpectedExitCode: 1

## Reading the exit code

The observed exit code is **15**, non-zero as the fail-before requirement demands. `Run.Exit = $true`
makes Pester return the failed-test count over the whole executed scope. The 15 decomposes exactly:

| Source | Failing cases |
| --- | --- |
| `enforce-orchestration-preimplementation-gate-command-exemption.Tests.ps1` (this task's suite) | 1 |
| `enforce-orchestration-preimplementation-gate-trigger-scoping.Tests.ps1` ([P1-T7], still red as designed) | 13 |
| `codex-pretooluse-integration.Tests.ps1` (pre-existing at baseline, recorded in [P0-T7]) | 1 |
| **Total** | **15** |

## Route deviation

The mandated single-suite `pwsh` invocation was refused by the runtime worktree-isolation guard, in
the same terms recorded in [P0-T7]. The folder-scoped MCP route was used instead.

## Suite result

**59 cases: 1 failed, 58 passed**, 0 errors, 0 skipped, 0.432 s.

The suite held 58 cases before the [P1-T10] edit; it now holds 59, which is exactly the one `It`
added and no more. The Codex suite's case count matches the Claude suite's exactly, before and after.

## The reversed `It` is the only newly failing pre-existing assertion

- Suite: `tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-command-exemption.Tests.ps1`
- Describe: `Codex enforce-orchestration-preimplementation-gate command exemption (issue #539)`
- Context: `issue #539 residual whole-command-text behaviour (D3 and D8)`
- It: `denies a message-body payload that merely contains the staging literal`
- Expected after the reversal: `allow`
- Observed against the unfixed hook: `deny`
- Failure message: `Expected strings to be the same, because issue #545 masks a heredoc body attached to a non-wrapper segment, so the prose is data, but they were different. Expected length: 5, Actual length: 4`

This is the single intended assertion reversal on the Codex side. It is the **only** failing case in
the suite.

## The new wrapper sibling `It` passes against the unfixed hook

- It: `denies the same heredoc body when it feeds a shell wrapper instead of a file`
- Result: **PASS**

Identical outcome to the Claude side. The two cases carry the same heredoc body and differ only in
destination: `cat > file` is a non-wrapper segment and must allow; `bash <<'NOTE'` feeds a shell and
must deny. The wrapper case denies today and must keep denying.

## Every other pre-existing `It` in the file passed

58 of 59 cases pass. The 57 pre-existing cases other than the reversed one all pass, in the same
three groups as the Claude sibling:

- `issue #539 orchestration-tree staging exemption allow cases` — all PASS.
- `issue #539 mixed pathspec deny cases` — all PASS.
- `issue #539 fail-closed rule table deny cases` — D4 rows 1 through 19, all PASS, including rows
  **14a through 14d**, the chained relocating denials the spec's acceptance criteria name as
  assertions that must pass unmodified, and rows 15a through 19.

## Diff scope

`git diff origin/epic/cleanup-merged-worktrees-hardening-integration -- tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-command-exemption.Tests.ps1`
reports 37 insertions and 6 deletions in one file. Filtering that diff to lines containing `It '` or
`Should -Be` yields exactly three changed assertion lines and no others:

```
-                Should -Be 'deny' -Because 'prose containing the literal never parses as a well-formed invocation'
+                Should -Be 'allow' -Because 'issue #545 masks a heredoc body attached to a non-wrapper segment, so the prose is data'
+        It 'denies the same heredoc body when it feeds a shell wrapper instead of a file' {
+                Should -Be 'deny' -Because 'a heredoc feeding a wrapper is executed, so the carve-out keeps it on raw text'
```

One existing `It` changed its expected decision; one new `It` was added; no other assertion was
modified. The remaining insertions are the rewritten rationale comment and the new case's body. The
file is 302 lines, up from 271, and remains under the 500-line cap.

## Cross-runtime symmetry

Identical to the Claude result recorded in [P1-T9]: 59 tests, 1 failed, 58 passed, with the failure
being the reversed `It` and the new wrapper sibling passing. Both sides reverse exactly one
assertion, which is what [P1-T12] records.

Output Summary: **Fail-before recorded as required.** Non-zero exit code **15**, decomposing as 1
failure in this suite, 13 in the Codex trigger-scoping suite, and 1 pre-existing baseline failure.
This suite reports **59 tests, 1 failed, 58 passed**. The single failure is the intended reversal,
`denies a message-body payload that merely contains the staging literal`, observed as `deny` where
`allow` is now expected — **the only newly failing pre-existing assertion**. The new wrapper sibling
**passes** against the unfixed hook, and every other pre-existing `It` in the file passed, including
D4 rows 14a through 14d.
