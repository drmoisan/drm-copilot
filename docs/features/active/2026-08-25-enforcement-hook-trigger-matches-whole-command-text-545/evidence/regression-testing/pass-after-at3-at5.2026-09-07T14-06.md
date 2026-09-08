# Pass-after: AT-3 and AT-5, with their paired negatives (issue #545)

Timestamp: 2026-09-07T14-06

Task: [P6-T9]

TOOLCHAIN_SUBSTITUTION: the folder-scoped `mcp__drm-copilot__run_poshqc_test` route was used in place
of the plan's `Invoke-Pester -Path <suite>` form, which is not invocable in this session; per-test
results were read out of `artifacts/pester/pester-junit.xml`.

Command: `mcp__drm-copilot__run_poshqc_test` with
`workspace_root=C:/Users/DanMoisan/repos/drm-copilot/.claude/worktrees/agent-a478b73e41951af31` and
`scan_folders=["tests/scripts/claude-hooks"]`

EXIT_CODE: 5 (folder-wide failed-test count; the suite this task names contributes 4 of the 5)

## Suite result — `tests/scripts/claude-hooks/hook-command-parser.AcceptanceCases.Tests.ps1`

| Measure | Value |
| --- | --- |
| tests | 11 |
| failures | 4 |
| errors | 0 |
| skipped | 0 |
| passed (derived) | 7 |

Per-case outcome, all eleven cases:

| Case | Result |
| --- | --- |
| AT-1 denies a relocating git worktree remove against an epic checkpoint with no authorizing record | FAIL |
| AT-2 returns 688 for a cd-prefixed gh pr merge whose PR number follows the merge flag | FAIL |
| **AT-3 allows a heredoc whose JSON body names promotion tools as receipt values** | **PASS** |
| AT-4 allows a printf whose double-quoted text mentions the gated merge phrase | FAIL |
| **AT-5 blocks a relocating gh issue create spelling that carries a repo global option** | **PASS** |
| AT-6 still classifies a pwsh -Command wrapper carrying a test invocation | PASS |
| AT-7 resolves the worktree path when the force flag precedes it, in both removal gates | FAIL |
| **paired negative for AT-3: a genuine promotion-script invocation still returns its blocked reason** | **PASS** |
| **paired negative for AT-5: a relocating gh issue list spelling still returns $null** | **PASS** |
| paired negative for AT-2: a bare gh pr merge --merge with no number still returns $null | PASS |
| paired negative for AT-2: the number-before-flag form gh pr merge 410 --merge still returns 410 | PASS |

## The two acceptance conditions of this task

**AT-3 passes.** The assertion is
`Get-PromotionBypassReason -CommandText <heredoc checkpoint write> | Should -BeNullOrEmpty`. The
fixture is a `cat > artifacts/orchestration/orchestrator-state.json <<'JSON' ... JSON` heredoc whose
body names `new_potential_bug_entry`, `potential_to_issue`, and `new_active_feature_folder` as values
of `required_mcp_tools`. `cat` is not a member of the wrapper carve-out set, so the attached heredoc
body is masked and the segment's `ScanText` is its `MaskedText`. The four byte-unchanged token
literals therefore find no match, and the reason is `$null`. This is the over-match direction.

**AT-5 passes.** The assertion is
`Get-PromotionBypassReason -CommandText 'gh --repo drmoisan/drm-copilot issue create --title "x" --body "y"' | Should -Be (Get-PromotionMcpOnlyGhIssueBlockedReason)`.
The `--repo` global option separates `gh` from its `issue` subcommand, so the byte-unchanged
adjacency expression `'(?i)\bgh\s+issue\s+(?:create|new)\b'` still does not match. The new structural
leg, `Test-CommandLineInvocation -CommandWord 'gh' -SubcommandPath @('issue','create')`, absorbs
`--repo` through the gh `WithArgument` table and reads `issue create` positionally, so the command
classifies and the gh-issue reason is returned rather than the legacy promotion-script reason. This is
the under-match direction.

**Both AT-5 paired negatives pass.**

- `paired negative for AT-3: a genuine promotion-script invocation still returns its blocked reason` —
  `pwsh ./scripts/new-potential-entry.ps1 -ShortName foo` still returns
  `Get-PromotionMcpOnlyBlockedReason`. `pwsh` is in the wrapper carve-out set, so that segment scans
  raw and the script name stays visible. The over-match removal did not weaken a real denial.
- `paired negative for AT-5: a relocating gh issue list spelling still returns $null` —
  `gh --repo drmoisan/drm-copilot issue list` is still allowed. The structural classifier matches the
  issue-creation subcommands only; `list` is neither `create` nor `new`, so that segment's scan
  terminates without a match.

Recorded for accuracy: the plan text names "the two AT-5 paired negatives". The suite carries two
paired negatives that bear on the promotion hook — the AT-3 one and the AT-5 one — and both pass, as
recorded above. The two remaining paired negatives in the suite belong to AT-2 and also pass, so all
four paired negatives in the file are green.

## Remaining failing names, checked against the [P1-T13] known-red inventory

| Failing `It` name | Inventory row | Closed by phase |
| --- | --- | --- |
| AT-1 denies a relocating git worktree remove against an epic checkpoint with no authorizing record | 1 | 8 ([P8-T14]) |
| AT-2 returns 688 for a cd-prefixed gh pr merge whose PR number follows the merge flag | 2 | 9 ([P9-T11]) |
| AT-4 allows a printf whose double-quoted text mentions the gated merge phrase | 4 | 9 ([P9-T11]) |
| AT-7 resolves the worktree path when the force flag precedes it, in both removal gates | 6 | 8 ([P8-T14]) |

All four failing names are members of the known-red inventory, and none is a row that Phase 6 closes.
The remaining failing set is therefore a subset of the [P1-T13] inventory minus the rows closed by
this phase and by Phase 5.

The fifth folder-wide failure, `allows gh pr create --body-file artifacts/pr_body_12.md when context
exists` in `enforce-pr-author-skill.Tests.ps1`, is the pre-existing baseline failure recorded in the
inventory appendix. It is outside the inventory union by design and outside this task's suite.

Output Summary: **AT-3 and AT-5 both pass**, closing known-red inventory rows 3 and 5. Both paired
negatives that guard them pass, so neither the over-match removal nor the new structural leg weakened
an existing decision. The suite is at 11 tests, 7 passed, 4 failed; the four failing names are exactly
inventory rows 1, 2, 4, and 6, none of which Phase 6 closes. The known-red inventory now stands at 4
open rows out of 34.
