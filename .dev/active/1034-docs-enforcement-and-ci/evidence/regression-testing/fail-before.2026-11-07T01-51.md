# Fail-Before - Issue 1034 Remediation Cycle 1 (P1-T3)

Timestamp: 2026-11-07T01-51
Command: sh SCRATCH/issue-1034-r-rows.sh FailBefore (Pester 6.2.0 over tests/scripts/claude-hooks/enforce-docs-complete-gate.Tests.ps1; exits 1 only when every row of merge target binding (F1), every row of read failures (F2) and the seam row 'throws for an existing path that cannot be read as a file' fail and every other row passes, and 255 otherwise)
EXIT_CODE: 1
ExpectedExitCode: 1
Output Summary: As expected. 111 tests: 58 failed and 53 passed. All 58 must-fail rows failed, 0 passed unexpectedly, and 0 other rows failed. The controls, including the N6 uppercase headRefOid row, passed against the unmodified hook.

## Failing Rows

- BLOCK | enforce-docs-complete-gate seams (issue #1034) | total=5 passed=4 failed=1
- BLOCK | entry point | total=2 passed=2 failed=0
- BLOCK | gate disabled | total=14 passed=14 failed=0
- BLOCK | gate enabled | total=20 passed=20 failed=0
- BLOCK | merge target binding (F1) | total=53 passed=0 failed=53
- BLOCK | merge target controls | total=11 passed=11 failed=0
- BLOCK | payload anomaly | total=2 passed=2 failed=0
- BLOCK | read failures (F2) | total=4 passed=0 failed=4
- FAILED | merge target binding (F1) | looks up https://github.com/o/r/pull/12 and denies RECEIPT_ABSENT for gh pr merge https://github.com/o/r/pull/12 --merge
- FAILED | merge target binding (F1) | looks up epic/x-integration and denies RECEIPT_ABSENT for gh pr merge epic/x-integration --merge
- FAILED | merge target binding (F1) | looks up epic/x-integration and denies RECEIPT_ABSENT for gh pr merge --merge -- epic/x-integration
- FAILED | merge target binding (F1) | looks up epic/x-integration and denies RECEIPT_ABSENT for gh pr merge --subject title epic/x-integration
- FAILED | merge target binding (F1) | looks up epic/x-integration and denies RECEIPT_ABSENT for gh pr merge -sd epic/x-integration
- FAILED | merge target binding (F1) | looks up epic/x-integration and denies RECEIPT_ABSENT for gh pr merge -sb 99 epic/x-integration
- FAILED | merge target binding (F1) | looks up 12 --repo other/repo and denies RECEIPT_ABSENT for gh pr merge 12 -R other/repo
- FAILED | merge target binding (F1) | looks up 12 --repo other/repo and denies RECEIPT_ABSENT for gh pr merge 12 --repo other/repo
- FAILED | merge target binding (F1) | looks up 12 --repo other/repo and denies RECEIPT_ABSENT for gh pr merge 12 --repo=other/repo
- FAILED | merge target binding (F1) | looks up 12 --repo other/repo and denies RECEIPT_ABSENT for gh pr merge 12 -Rother/repo
- FAILED | merge target binding (F1) | looks up 12 --repo other/repo and denies RECEIPT_ABSENT for gh pr merge 12 -R=other/repo
- FAILED | merge target binding (F1) | looks up 12 --repo other/repo and denies RECEIPT_ABSENT for gh --repo other/repo pr merge 12
- FAILED | merge target binding (F1) | looks up 12 --repo other/repo and denies RECEIPT_ABSENT for gh pr -R other/repo merge 12
- FAILED | merge target binding (F1) | looks up 12 --repo other/repo and denies RECEIPT_ABSENT for gh --repo other/repo pr merge 12 -R other/repo
- FAILED | merge target binding (F1) | looks up 12 --repo other/repo and denies RECEIPT_ABSENT for gh api -X PUT repos/other/repo/pulls/12/merge
- FAILED | merge target binding (F1) | looks up 12 --repo other/repo and denies RECEIPT_ABSENT for gh api -X PUT /repos/other/repo/pulls/12/merge
- FAILED | merge target binding (F1) | looks up epic/x-integration and denies RECEIPT_ABSENT for timeout 30 gh pr merge epic/x-integration
- FAILED | merge target binding (F1) | looks up epic/x-integration and denies RECEIPT_ABSENT for sh -c 'gh pr merge epic/x-integration'
- FAILED | merge target binding (F1) | looks up epic/x-integration and denies RECEIPT_ABSENT for gh pr merge epic/x-integration > log
- FAILED | merge target binding (F1) | looks up epic/x-integration and denies RECEIPT_ABSENT for gh pr merge epic/x-integration >log
- FAILED | merge target binding (F1) | looks up epic/x-integration and denies RECEIPT_ABSENT for gh pr merge 99 --disable-auto; gh pr merge epic/x-integration --merge
- FAILED | merge target binding (F1) | looks up https://github.com/o/r/pull/12 and denies RECEIPT_ABSENT for cd ../other && gh pr merge https://github.com/o/r/pull/12 --merge
- FAILED | merge target binding (F1) | denies PR_UNRESOLVED with no gh call for gh api graphql -f query='mutation{mergePullRequest(input:{pullRequestId:"PR_kw"}){clientMutationId}}'
- FAILED | merge target binding (F1) | denies PR_UNRESOLVED with no gh call for gh api graphql -f query='mutation{enqueuePullRequest(input:{pullRequestId:"PR_kw"}){clientMutationId}}'
- FAILED | merge target binding (F1) | denies PR_UNRESOLVED with no gh call for gh api graphql -f query='mutation{enablePullRequestAutoMerge(input:{pullRequestId:"PR_kw"}){clientMutationId}}'
- FAILED | merge target binding (F1) | denies PR_UNRESOLVED with no gh call for gh api graphql -f query='mutation{mergePullRequest(x)}' repos/o/r/pulls/12/merge
- FAILED | merge target binding (F1) | denies PR_UNRESOLVED with no gh call for gh pr merge 99 --merge; gh pr merge 12 --merge
- FAILED | merge target binding (F1) | denies PR_UNRESOLVED with no gh call for gh pr merge 99 --merge; gh api -X PUT repos/o/r/pulls/12/merge
- FAILED | merge target binding (F1) | denies PR_UNRESOLVED with no gh call for gh --unknown pr merge 12
- FAILED | merge target binding (F1) | denies PR_UNRESOLVED with no gh call for gh pr merge 12 'unbalanced
- FAILED | merge target binding (F1) | denies PR_UNRESOLVED with no gh call for echo 12 | xargs gh pr merge --merge
- FAILED | merge target binding (F1) | denies PR_UNRESOLVED with no gh call for gh pr merge $PR
- FAILED | merge target binding (F1) | denies PR_UNRESOLVED with no gh call for gh pr merge 12 -R $REPO
- FAILED | merge target binding (F1) | denies PR_UNRESOLVED with no gh call for gh pr merge 12 --unknown
- FAILED | merge target binding (F1) | denies PR_UNRESOLVED with no gh call for gh pr merge 12 -z
- FAILED | merge target binding (F1) | denies PR_UNRESOLVED with no gh call for gh pr merge 12 13
- FAILED | merge target binding (F1) | denies PR_UNRESOLVED with no gh call for gh pr merge -- -x
- FAILED | merge target binding (F1) | denies PR_UNRESOLVED with no gh call for gh pr merge 12 --repo bad
- FAILED | merge target binding (F1) | denies PR_UNRESOLVED with no gh call for gh pr merge 12 --repo
- FAILED | merge target binding (F1) | denies PR_UNRESOLVED with no gh call for gh --repo a/b pr merge 12 -R c/d
- FAILED | merge target binding (F1) | denies PR_UNRESOLVED with no gh call for gh api -X PUT https://api.github.com/repos/o/r/pulls/12/merge
- FAILED | merge target binding (F1) | denies PR_UNRESOLVED with no gh call for gh api --hostname ghe.example.com -X PUT repos/o/r/pulls/12/merge
- FAILED | merge target binding (F1) | denies PR_UNRESOLVED with no gh call for gh api -X PUT repos/o/r/pulls/12/merge repos/o/r/pulls/13/merge
- FAILED | merge target binding (F1) | denies PR_UNRESOLVED with no gh call for gh api -X PUT repos/$OWNER/r/pulls/12/merge
- FAILED | merge target binding (F1) | denies PR_UNRESOLVED with no gh call for cd ../other && gh pr merge 12 --merge
- FAILED | merge target binding (F1) | denies PR_UNRESOLVED with no gh call for pushd ../other; gh pr merge 12
- FAILED | merge target binding (F1) | denies PR_UNRESOLVED with no gh call for chdir ../other; gh pr merge 12
- FAILED | merge target binding (F1) | denies PR_UNRESOLVED with no gh call for Set-Location ../other; gh pr merge 12
- FAILED | merge target binding (F1) | denies PR_UNRESOLVED with no gh call for Push-Location ../other; gh pr merge 12
- FAILED | merge target binding (F1) | denies PR_UNRESOLVED with no gh call for sl ../other; gh pr merge 12
- FAILED | merge target binding (F1) | denies PR_UNRESOLVED with no gh call for GH_REPO=other/repo gh pr merge 12
- FAILED | merge target binding (F1) | denies PR_UNRESOLVED with no gh call for GH_HOST=ghe.example.com gh pr merge 12
- FAILED | merge target binding (F1) | denies PR_UNRESOLVED with no gh call for export GH_REPO=other/repo; gh pr merge 12
- FAILED | read failures (F2) | denies PROFILE_UNREADABLE with no gh call when the profile read throws
- FAILED | read failures (F2) | denies RECEIPT_UNREADABLE without claiming an absent file when the receipt read throws
- FAILED | read failures (F2) | denies PR_UNRESOLVED when Invoke-DocsOnlyGhExe throws
- FAILED | read failures (F2) | returns 0 and emits a PAYLOAD_ANOMALY deny when ReadPayload throws
- FAILED | enforce-docs-complete-gate seams (issue #1034) | throws for an existing path that cannot be read as a file
