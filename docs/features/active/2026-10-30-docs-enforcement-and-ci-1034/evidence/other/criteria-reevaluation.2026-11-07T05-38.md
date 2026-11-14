# Criteria Re-Evaluation - Issue 1034 Remediation Cycle 3 (P4-T11)

Timestamp: 2026-11-07T05-38
Command: read of FEATURE/spec.md, FEATURE/user-story.md and the cycle 3 evidence named in each row
EXIT_CODE: 0
Output Summary: PASS. spec:516, story:65 and story:73 evaluate PASS against the cycle 3 evidence, read with the limit statement of the HOOK header and `### Hook` of FEATURE/spec.md. Each row states the forms that allow under that statement. Checkboxes are not edited; the next review owns them. Two readings are stated for the reviewer to confirm.

Evidence files, all under `regression-testing/`: `fail-before.2026-11-07T04-56.md`, `gate-rows.2026-11-07T04-58.md`, `bash-comparison.2026-11-07T05-18.md`, `f4-f5-hook-process.2026-11-07T05-21.md`.

| Criterion | Result | Evidence | Basis |
|---|---|---|---|
| spec:516, gate disabled allows every call; enabled denies an absent, failing or other-revision receipt and names the reason | PASS | `fail-before`, `gate-rows`, `bash-comparison`, `f4-f5-hook-process` | Fail-before: 52 rows failed at the merged head and all pass now. In real hook processes each of the 38 commands of Groups F4, W and F5 allows with a disabled and with an absent profile, and denies `PR_UNRESOLVED` with an enabled profile and no receipt. Of 320 real-bash rows, each of the 35 rows that reached a lookup looked up the selector bash passed and denied `RECEIPT_ABSENT`, so no row looked up a different selector. Every row of Groups F4, W and F5 is `agree`, except `if true; then ksh -c 'gh pr merge 12'; fi`, which is `not observed` because `ksh` is absent on this host; `gate-rows` and `f4-f5-hook-process` show the hook denies it. |
| story:65, same text as spec:516 | PASS | as spec:516 | As spec:516. |
| story:73, with the gate enabled an integration-to-main merge is denied with a receipt reason, and allowed when the receipt passes and its revision equals headRefOid | PASS | `gate-rows`, `bash-comparison`, `f4-f5-hook-process` | One plain `gh pr merge` of an integration pull request denies `RECEIPT_ABSENT` in the 35 lookup rows of `bash-comparison`, and allows with a passing receipt in row 'allows a passing receipt whose revision equals headRefOid and looks up the named pull request' of `HOOK_SUITE` (`gate-rows`). |

## Forms That Allow Under the Limit Statement

These 29 rows of `bash-comparison` merged under real bash and allowed with no lookup. Each is named in the third item of the limit statement, and Group R pins it.

| Form | Rows | Example |
|---|---|---|
| `python -c` | 4 | `python -c "import os; os.system('gh pr merge 12')"` |
| `node -e` | 4 | `node -e "require('child_process').execSync('gh pr merge 12')"` |
| `curl` | 1 | `curl -X PUT https://api.github.com/repos/o/r/pulls/12/merge` |
| scripts on disk | 6 | `sh merge.sh`, `./merge.sh`, `. ./merge.sh`, `source merge.sh` |
| computed command words | 6 | `a=g; b=h; $a$b pr merge 12`, `$(echo 'gh pr merge 12')`, `gh pr me${x}rge 12` |
| quoted command word | 3 | `if true; then "gh" pr merge 12; fi`, `! gh pr 'merge' 12`, `exec gh 'pr' merge 12` |
| evaluators outside the named words | 4 | `trap 'gh pr merge 12' EXIT` |
| a direct `git push` to `main` | 1 | `git push origin HEAD:main` |

Four further forms allow and could not be shown merging by a stand-in: a `gh` alias, a mutation supplied from a file (two rows), and a merge endpoint whose number is a variable. The limit statement names them, and it states that its list is not complete.

## Readings to Confirm

1. spec:516 and story:65 carry no qualifier for forms the hook does not read. These rows are PASS on the reading that the review adopted in F5: each form either denies or is named in the residual limits. A merge through a named form allows with no receipt, and the hook does not observe it.
2. story:73: a merge the hook reads in any form other than one plain `gh pr merge` is denied with `PR_UNRESOLVED` before any receipt read, and it stays denied with a passing receipt. The denial holds for those forms; the receipt reason and the allow clause apply to the plain form.
