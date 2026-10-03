# P1-T15 [expect-fail] Issue824 tests against the unfixed helper

Timestamp: 2026-10-03T09-51
Command: pwsh -NoProfile -Command "& 'SCRATCH/issue824-pester.ps1' -Path @(S1..S14) -JUnitPath 'docs/features/active/2026-10-03-promotion-hook-raw-containment-false-positive-deny-824/evidence/regression-testing/expect-fail-issue824.junit.xml' -Tag 'Issue824'; exit `$LASTEXITCODE"; $LASTEXITCODE (full -Path list as in plan P1-T15)
EXIT_CODE: 14
ExpectedExitCode: 14
Output Summary:
- Exit code 14 (the A2 child exit code, propagated by 'exit `$LASTEXITCODE')
- TOTALS passed=29 failed=14 skipped=0 notrun=219 total=262
- CONTAINER-ERROR lines: none
- FAILED set equals the D6 failing set: two P824-A1, two P824-A2, two N824-1, one A824-PR1, three A824-WT1, two A824-VB1, two A824-PI1
- PASSED set equals the D6 passing set: two P824-A3, P824-D1..D11 twice, three A824-WT2, two A824-MG1
- Result: PASS (expected failure reproduced; defect confirmed against the unfixed R2 containment test)

Full PASSED/FAILED listing:

```text
TOTALS passed=29 failed=14 skipped=0 notrun=219 total=262
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
PASSED: A824-WT2 still denies git worktree remove carried inside a bash -c argument
PASSED: A824-WT2 still denies git worktree remove carried inside a bash -c argument
PASSED: A824-WT2 still denies git worktree remove carried inside a bash -c argument
PASSED: A824-MG1 still routes gh pr merge --merge inside a bash -c argument to the checkpoint check
PASSED: A824-MG1 still routes gh pr merge --merge inside a bash -c argument to the checkpoint check
FAILED: P824-A1 allows the issue 824 reproduction command
FAILED: P824-A2 allows a wrapped payload carrying through, issue, and New-Object with no gh issue sequence
FAILED: P824-A1 allows the issue 824 reproduction command
FAILED: P824-A2 allows a wrapped payload carrying through, issue, and New-Object with no gh issue sequence
FAILED: N824-1 negative control: raw containment matches the reproduction but Test-CommandLineInvocation does not
FAILED: N824-1 negative control: raw containment matches the reproduction but Test-CommandLineInvocation does not
FAILED: A824-PR1 allows a wrapped Select-String whose text carries high, priority, and create
FAILED: A824-WT1 allows a wrapped git worktree list whose filter text carries removed
FAILED: A824-WT1 allows a wrapped git worktree list whose filter text carries removed
FAILED: A824-WT1 allows a wrapped git worktree list whose filter text carries removed
FAILED: A824-VB1 returns no blocked pattern for pwsh -f running legit-push.ps1
FAILED: A824-VB1 returns no blocked pattern for pwsh -f running legit-push.ps1
FAILED: A824-PI1 does not classify a wrapped Write-Output carrying digit and address as implementation
FAILED: A824-PI1 does not classify a wrapped Write-Output carrying digit and address as implementation
```
