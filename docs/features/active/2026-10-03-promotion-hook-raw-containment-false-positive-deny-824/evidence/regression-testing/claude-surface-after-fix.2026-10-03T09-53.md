# P2-T5 Claude-surface behaviour after the fix

Timestamp: 2026-10-03T09-53
Command: (1) pwsh -NoProfile -Command "& 'SCRATCH/issue824-pester.ps1' -Path @('tests/scripts/claude-hooks/hook-command-invocation.Tests.ps1') -JUnitPath 'SCRATCH/s3-full.junit.xml'; exit `$LASTEXITCODE"; $LASTEXITCODE (2) pwsh -NoProfile -Command "& 'SCRATCH/issue824-pester.ps1' -Path @(S1, S3, S5, S6, S7, S9, S11, S13) -JUnitPath 'SCRATCH/claude-issue824.junit.xml' -Tag 'Issue824'; exit `$LASTEXITCODE"; $LASTEXITCODE
EXIT_CODE: 0
Output Summary:
- Run 1 (S3, every test, no tag filter): TOTALS passed=45 failed=0 skipped=0 notrun=0 total=45; exit 0
- Run 2 (Claude Issue824 subset): TOTALS passed=23 failed=0 skipped=0 notrun=129 total=152; exit 0 (expected passed=23: S1 14, S3 1, S5 1, S6 2, S7 2, S9 1, S11 1, S13 1)
- No FAILED or CONTAINER-ERROR lines
- Result: PASS

```text
TOTALS passed=45 failed=0 skipped=0 notrun=0 total=45
PASSED: N824-1 negative control: raw containment matches the reproduction but Test-CommandLineInvocation does not
TOTALS passed=23 failed=0 skipped=0 notrun=129 total=152
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
PASSED: A824-PR1 allows a wrapped Select-String whose text carries high, priority, and create
PASSED: A824-WT1 allows a wrapped git worktree list whose filter text carries removed
PASSED: A824-WT2 still denies git worktree remove carried inside a bash -c argument
PASSED: A824-WT1 allows a wrapped git worktree list whose filter text carries removed
PASSED: A824-WT2 still denies git worktree remove carried inside a bash -c argument
PASSED: A824-VB1 returns no blocked pattern for pwsh -f running legit-push.ps1
PASSED: A824-PI1 does not classify a wrapped Write-Output carrying digit and address as implementation
PASSED: A824-MG1 still routes gh pr merge --merge inside a bash -c argument to the checkpoint check
```
