# Expect-Fail Regression Run (P1-T5)

Timestamp: 2026-10-28T13-12
Command: sh SCRATCH/issue-989-pt.sh (PowerShell 7: Import-Module scripts/powershell/PoshQC/PoshQC.psd1; Invoke-PoshQCTest -ScanFolders tests/scripts/claude-hooks/enforce-model-routing-receipt.AuthorAsserted.Tests.ps1, tests/scripts/claude-hooks/enforce-pr-author-skill.CurrentBranch.Tests.ps1, tests/scripts/claude-hooks/enforce-pr-author-command-allowlist.Tests.ps1, tests/scripts/claude-runtime/pr-author-issue-link-contract.Tests.ps1, one process; counts from artifacts/pester/pester-junit.xml)
EXIT_CODE: 32
ExpectedExitCode: 32

Run state: production hooks and prose are unchanged (before P2). Pester `Run.Exit` reports the failed-test count as the process exit code.

## Counts (artifacts/pester/pester-junit.xml)

- Total 88, passed 56, failed 32, skipped 0.

## Failing rows (expected to fail) and failure messages

| Row | Failure message (abridged) |
|---|---|
| AA-02 | Expected 'deny' but was 'allow' |
| AA-03 | Expected 'deny' but was 'allow' |
| AA-04 | Expected 'deny' but was 'allow' |
| AA-05 | Expected 'deny' but was 'allow' |
| AA-08 | Expected 'deny' but was 'allow' |
| AA-09 | Expected 'deny' but was 'allow' |
| AL-39 | Expected 'allow' but was 'deny' |
| AL-49 | Expected $true: the deny reason's allowed-forms sentence does not name `gh pr view <N> --json closingIssuesReferences,body` |
| CB-01, CB-02 | CommandNotFoundException: `Invoke-PrAuthorCurrentBranchGitExe` is not recognized |
| CB-03, CB-04, CB-05, CB-06 | CommandNotFoundException: `Get-PrAuthorCurrentBranch` is not recognized |
| CB-07 to CB-13, CB-15 | CommandNotFoundException: Could not find Command Get-PrAuthorCurrentBranch (row-level mock of a function that does not yet exist) |
| CB-14 | Expected $true: the TARGET_WORKTREE_NOT_DERIVABLE reason does not contain the new create/edit guidance |
| PC-01 | Expected $true (delegation line absent from `## PR Authoring (pr-author Handoff)`) |
| PC-02 | Expected $true (delegation line absent from `## PR Creation Delegation`) |
| PC-03 | Expected $true (`delegation prompt` absent from `## Issue/PR Reference Rules`) |
| PC-04 | Expected $false (`only from verified autoclose lists` still present) |
| PC-05 (skill), PC-05 (agent) | Expected a value: `## Closing-Reference Verification` section absent |
| PC-06 (skill), PC-06 (agent) | Expected $true (`--head is not valid for gh pr edit` absent) |
| PC-07 | `"Bash(gh pr view *)"` not found in the frontmatter `tools:` list |

Failing total: 6 AA + 2 AL + 15 CB + 9 PC instances (PC-05 and PC-06 run once per file) = 32.

## Passing rows (pin preserved behavior)

- AA-01, AA-06, AA-07, AA-10, AA-11, AA-12.
- AL-01 to AL-38 (unchanged rows) and AL-40 to AL-48 (deny rows for other `gh pr view` forms).
- CB-16 (the skill gate already allows `gh pr view 5 --json closingIssuesReferences,body`).
- The two `baseline mock interception probe` rows (AuthorAsserted and CurrentBranch suites).

Output Summary: 56 passed, 32 failed; the failing and passing sets match the P1-T5 expected split exactly, with no deviation. Exit code 32 equals the failed-test count.
