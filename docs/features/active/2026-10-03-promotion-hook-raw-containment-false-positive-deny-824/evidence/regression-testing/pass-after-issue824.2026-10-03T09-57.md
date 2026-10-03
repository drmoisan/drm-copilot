# P4-T1 Pass-after: every Issue824 test in S1-S14, U1, U2

Timestamp: 2026-10-03T09-57
Command: pwsh -NoProfile -Command "& 'SCRATCH/issue824-pester.ps1' -Path @(S1..S14, 'tests/scripts/claude-hooks/hook-command-raw-invocation.Tests.ps1', 'tests/scripts/codex-hooks/hook-command-raw-invocation.Tests.ps1') -JUnitPath 'docs/features/active/2026-10-03-promotion-hook-raw-containment-false-positive-deny-824/evidence/regression-testing/pass-after-issue824.junit.xml' -Tag 'Issue824'; exit `$LASTEXITCODE"; $LASTEXITCODE
EXIT_CODE: 0
Output Summary:
- TOTALS passed=97 failed=0 skipped=0 notrun=219 total=316; exit 0
- No CONTAINER-ERROR or FAILED lines
- Every D6 failing-set name appears as PASSED (14 lines: two P824-A1, two P824-A2, two N824-1, one A824-PR1, three A824-WT1, two A824-VB1, two A824-PI1)
- Result: PASS

```text
TOTALS passed=97 failed=0 skipped=0 notrun=219 total=316
PASSED: P824-A1 allows the issue 824 reproduction command
PASSED: P824-A2 allows a wrapped payload carrying through, issue, and New-Object with no gh issue sequence
PASSED: P824-A3 allows gh --repo o/r issue list
PASSED: P824-D1 denies gh issue create --title x
PASSED: P824-D2 denies gh issue new --title x
PASSED: P824-D3 denies GH  Issue  Create
PASSED: P824-D4 denies pwsh -NoProfile -Command 'gh issue create --title x'
PASSED: P824-D5 denies pwsh -c "& gh issue new"
PASSED: P824-D6 denies bash -c "gh issue create"
PASSED: P824-D7 denies gh api repos/o/r/issues -X POST
PASSED: P824-D8 denies bash -c "gh -R o/r issue create"
PASSED: P824-D9 denies bash -c 'x=create; gh issue $x'
PASSED: P824-D10 denies bash -c 'c=gh; $c issue create'
PASSED: P824-D11 denies the unbalanced segment echo unterminated
PASSED: P824-A1 allows the issue 824 reproduction command
PASSED: P824-A2 allows a wrapped payload carrying through, issue, and New-Object with no gh issue sequence
PASSED: P824-A3 allows gh --repo o/r issue list
PASSED: P824-D1 denies gh issue create --title x
PASSED: P824-D2 denies gh issue new --title x
PASSED: P824-D3 denies GH  Issue  Create
PASSED: P824-D4 denies pwsh -NoProfile -Command 'gh issue create --title x'
PASSED: P824-D5 denies pwsh -c "& gh issue new"
PASSED: P824-D6 denies bash -c "gh issue create"
PASSED: P824-D7 denies gh api repos/o/r/issues -X POST
PASSED: P824-D8 denies bash -c "gh -R o/r issue create"
PASSED: P824-D9 denies bash -c 'x=create; gh issue $x'
PASSED: P824-D10 denies bash -c 'c=gh; $c issue create'
PASSED: P824-D11 denies the unbalanced segment echo unterminated
PASSED: N824-1 negative control: raw containment matches the reproduction but Test-CommandLineInvocation does not
PASSED: N824-1 negative control: raw containment matches the reproduction but Test-CommandLineInvocation does not
PASSED: A824-PR1 allows a wrapped Select-String whose text carries high, priority, and create
PASSED: A824-WT1 allows a wrapped git worktree list whose filter text carries removed
PASSED: A824-WT2 still denies git worktree remove carried inside a bash -c argument
PASSED: A824-WT1 allows a wrapped git worktree list whose filter text carries removed
PASSED: A824-WT2 still denies git worktree remove carried inside a bash -c argument
PASSED: A824-WT1 allows a wrapped git worktree list whose filter text carries removed
PASSED: A824-WT2 still denies git worktree remove carried inside a bash -c argument
PASSED: A824-VB1 returns no blocked pattern for pwsh -f running legit-push.ps1
PASSED: A824-VB1 returns no blocked pattern for pwsh -f running legit-push.ps1
PASSED: A824-PI1 does not classify a wrapped Write-Output carrying digit and address as implementation
PASSED: A824-PI1 does not classify a wrapped Write-Output carrying digit and address as implementation
PASSED: A824-MG1 still routes gh pr merge --merge inside a bash -c argument to the checkpoint check
PASSED: A824-MG1 still routes gh pr merge --merge inside a bash -c argument to the checkpoint check
PASSED: R824-P1 classifies adjacent words
PASSED: R824-P2 classifies extra whitespace
PASSED: R824-P3 classifies mixed case
PASSED: R824-P4 classifies a leading ampersand
PASSED: R824-P5 classifies a leading semicolon
PASSED: R824-P6 classifies a leading pipe
PASSED: R824-P7 classifies a leading parenthesis
PASSED: R824-P8 classifies a leading double quote
PASSED: R824-P9 classifies a leading single quote
PASSED: R824-P10 classifies a leading newline
PASSED: R824-P11 classifies a /usr/bin path
PASSED: R824-P12 classifies a Windows exe path
PASSED: R824-P13 classifies a quoted exe path
PASSED: R824-P14 classifies escaped quotes
PASSED: R824-P15 classifies a short repo option
PASSED: R824-P16 classifies a repo option in equals form
PASSED: R824-P17 classifies a quoted directory option
PASSED: R824-P18 classifies an unmodeled dash option
PASSED: R824-P19 classifies an expansion in the command position
PASSED: R824-P20 classifies an expansion in a subcommand position
PASSED: R824-N1 rejects through issue New-Object
PASSED: R824-N2 rejects legit push
PASSED: R824-N3 rejects a worktree list filtered on removed
PASSED: R824-N4 rejects high priority create
PASSED: R824-N5 rejects gh issue newline
PASSED: R824-N6 rejects gh issue list
PASSED: R824-N7 rejects an all-expansion sequence
PASSED: R824-P1 classifies adjacent words
PASSED: R824-P2 classifies extra whitespace
PASSED: R824-P3 classifies mixed case
PASSED: R824-P4 classifies a leading ampersand
PASSED: R824-P5 classifies a leading semicolon
PASSED: R824-P6 classifies a leading pipe
PASSED: R824-P7 classifies a leading parenthesis
PASSED: R824-P8 classifies a leading double quote
PASSED: R824-P9 classifies a leading single quote
PASSED: R824-P10 classifies a leading newline
PASSED: R824-P11 classifies a /usr/bin path
PASSED: R824-P12 classifies a Windows exe path
PASSED: R824-P13 classifies a quoted exe path
PASSED: R824-P14 classifies escaped quotes
PASSED: R824-P15 classifies a short repo option
PASSED: R824-P16 classifies a repo option in equals form
PASSED: R824-P17 classifies a quoted directory option
PASSED: R824-P18 classifies an unmodeled dash option
PASSED: R824-P19 classifies an expansion in the command position
PASSED: R824-P20 classifies an expansion in a subcommand position
PASSED: R824-N1 rejects through issue New-Object
PASSED: R824-N2 rejects legit push
PASSED: R824-N3 rejects a worktree list filtered on removed
PASSED: R824-N4 rejects high priority create
PASSED: R824-N5 rejects gh issue newline
PASSED: R824-N6 rejects gh issue list
PASSED: R824-N7 rejects an all-expansion sequence
```
