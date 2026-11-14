# Fail-Before - Issue 1034 Remediation Cycle 3 (P2-T2)

Timestamp: 2026-11-07T04-56
Command: sh SCRATCH/issue-1034-c3-suite.sh p2t2 over COMPOUND_SUITE and HELPER_SUITE, then pwsh SCRATCH/issue-1034-c3-failbefore.ps1, which derives the expected set from the groups of the plan and exits 1 only on an exact match
EXIT_CODE: 1
ExpectedExitCode: 1
Output Summary: EXPECTED FAIL. 347 tests, 295 passed, 52 failed at the merged head with the rows of P2-T1. The 52 failing rows equal the derived set exactly (0 missing, 0 extra): 38 enabled rows of Groups F4, W and F5, and 14 rows of Group H. Every disabled, absent and control row passes.

- Code under test: `HELPER` and `HOOK` unchanged since `MERGE_COMMIT`; the suites are at the P2-T1 commit.

## Counts by Context

| Suite | Context | Total | Passed | Failed |
|---|---|---|---|---|
| `COMPOUND_SUITE` | compound merge scope (F3) | 180 | 142 | 38 |
| `COMPOUND_SUITE` | merge mentions | 12 | 12 | 0 |
| `COMPOUND_SUITE` | residual limits | 17 | 17 | 0 |
| `HELPER_SUITE` | Read-DocsCompleteGatePlainCommand | 60 | 55 | 5 |
| `HELPER_SUITE` | Get-DocsCompleteGateUnquotedView | 4 | 3 | 1 |
| `HELPER_SUITE` | Test-DocsCompleteGateMergeText | 4 | 0 | 4 |
| `HELPER_SUITE` | Test-DocsCompleteGateMergeCandidate | 26 | 22 | 4 |
| `HELPER_SUITE` | Read-DocsCompleteGateMergeOperand | 28 | 28 | 0 |
| `HELPER_SUITE` | Get-DocsCompleteGateMergeTarget | 16 | 16 | 0 |

## Rows Handled Under the Predicted-Row Rule

- Predicted rows listed to fail that pass at head: none. Every predicted row of Groups F4, W and F5 failed.
- Group R rows that fail at head: none. All 17 pass, so no row moves and no form leaves the limit statement.
- Group D passes at head as the plan states: `gh api -X GET repos/o/r/pulls/12/merge` denies in the enabled state and allows in the disabled and absent states.
- The F4 rows that look up a selector at head fail on the zero-call assertion, as `## Row Groups` predicts.

## Failing Rows

`COMPOUND` rows are 'denies PR_UNRESOLVED with no gh call for <Command>' in Context `compound merge scope (F3)`; `<NL>` and `<CR>` mark the characters in the row.

```text
COMPOUND gh pr merge 34 # x\<NL>gh pr merge 12
COMPOUND gh pr merge 34 # first line \<NL>gh pr merge 12 # second
COMPOUND gh pr merge 34 \<NL># x\<NL>gh pr merge 12
COMPOUND gh pr view 34 # x\<NL>gh pr merge 12
COMPOUND gh pr merge --disable-auto # x\<NL>gh pr merge 12
COMPOUND gh pr view 34 --json title # x\<NL>gh api -X PUT repos/o/r/pulls/12/merge
COMPOUND gh pr merge 34 # x\<CR><NL>gh pr merge 12
COMPOUND gh pr merge \<NL>12 # note
COMPOUND gh pr mer\<NL>ge 12
COMPOUND g\<NL>h pr merge 12
COMPOUND gh p\<NL>r merge 12
COMPOUND gh pr mer\<CR><NL>ge 12
COMPOUND true; gh pr mer\<NL>ge 12
COMPOUND if true; then sh -c 'gh pr merge 12'; fi
COMPOUND if true; then bash -c "gh pr merge 12"; fi
COMPOUND ! sh -c 'gh pr merge 12'
COMPOUND exec sh -c 'gh pr merge 12'
COMPOUND for n in 12; do sh -c "gh pr merge $n"; done
COMPOUND if true; then eval 'gh pr merge 12'; fi
COMPOUND ! eval 'gh pr merge 12'
COMPOUND nice sh -c 'gh pr merge 12'
COMPOUND find . -maxdepth 0 -exec sh -c 'gh pr merge 12' \;
COMPOUND sudo sh -c 'gh pr merge 12'
COMPOUND if true; then bash <<EOF<NL>gh pr merge 12<NL>EOF<NL>fi
COMPOUND echo 'gh pr merge 12' | sh
COMPOUND printf 'gh pr merge 12' | bash
COMPOUND g\h pr merge 12
COMPOUND gh pr mer\ge 12
COMPOUND gh p\r merge 12
COMPOUND true; g\h pr merge 12
COMPOUND g\h api -X PUT repos/o/r/pulls/12/merge
COMPOUND if true; then sh -c 'gh api -X PUT repos/o/r/pulls/12/merge'; fi
COMPOUND echo 'gh api -X PUT repos/o/r/pulls/12/merge' | bash
COMPOUND if true; then ksh -c 'gh pr merge 12'; fi
COMPOUND if true; then pwsh -Command 'gh pr merge 12'; fi
COMPOUND source <(echo 'gh pr merge 12')
COMPOUND echo bash 'gh pr merge 12'
COMPOUND ./run.sh 'gh pr merge 12'
HELPER Read-DocsCompleteGatePlainCommand.reads a comment ending in a backslash-newline as not plain
HELPER Read-DocsCompleteGatePlainCommand.reads a backslash-newline before a comment as not plain
HELPER Read-DocsCompleteGatePlainCommand.reads a comment with a CRLF continuation as not plain
HELPER Read-DocsCompleteGatePlainCommand.reads a word split by a backslash-newline as not plain
HELPER Read-DocsCompleteGatePlainCommand.reads a word split by a CRLF continuation as not plain
HELPER Get-DocsCompleteGateUnquotedView.removes a backslash from an unquoted word
HELPER Test-DocsCompleteGateMergeText.returns $true for the gh pr merge words
HELPER Test-DocsCompleteGateMergeText.returns $true for gh api with a mutation
HELPER Test-DocsCompleteGateMergeText.returns $false for gh api with no mutation
HELPER Test-DocsCompleteGateMergeText.returns $false for no words
HELPER Test-DocsCompleteGateMergeCandidate.returns $true for step 3, a backslash in a word
HELPER Test-DocsCompleteGateMergeCandidate.returns $true for step 3, a word split by a backslash-newline
HELPER Test-DocsCompleteGateMergeCandidate.returns $true for step 3, a quoted merge beside an evaluator word
HELPER Test-DocsCompleteGateMergeCandidate.returns $true for step 3, a quoted gh api merge beside an evaluator word
```
