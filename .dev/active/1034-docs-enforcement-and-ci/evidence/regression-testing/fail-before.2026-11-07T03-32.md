# Fail-Before Rows - Issue 1034 Remediation Cycle 2 (P1-T2)

Timestamp: 2026-11-07T03-32
Command: sh SCRATCH/issue-1034-c2-rows.sh FailBefore (Invoke-Pester over enforce-docs-complete-gate.Tests.ps1 and enforce-docs-complete-gate-compound.Tests.ps1 against the unchanged hook)
EXIT_CODE: 1
ExpectedExitCode: 1
Output Summary: Expected failure. 220 rows: 149 in the hook suite (111 plus 38 new) and 71 in the compound suite. 162 passed and 58 failed. The 58 failures are exactly the listed set: 35 hook-suite rows (Group A 16, Group B 10, Group U 9) and 23 compound-suite rows (21 enabled Group D rows and the 2 enabled unquoted Group E rows). No listed row passed and no other row failed; failed blocks 0, failed containers 0. The step script exits 1 only in that state and 255 otherwise.

## Per-block counts

- COMPOUND, compound merge scope (F3) | total=63 passed=42 failed=21
- COMPOUND, merge mentions | total=8 passed=6 failed=2
- HOOK, enforce-docs-complete-gate seams (issue #1034) | total=5 passed=5 failed=0
- HOOK, entry point | total=2 passed=2 failed=0
- HOOK, gate disabled | total=14 passed=14 failed=0
- HOOK, gate enabled | total=20 passed=20 failed=0
- HOOK, integration checkout (F1) | total=3 passed=1 failed=2
- HOOK, merge target binding (F1) | total=86 passed=53 failed=33
- HOOK, merge target controls | total=13 passed=13 failed=0
- HOOK, payload anomaly | total=2 passed=2 failed=0
- HOOK, read failures (F2) | total=4 passed=4 failed=0

## Failing rows

- HOOK, merge target binding (F1): `looks up 12 and denies RECEIPT_ABSENT for gh pr merge 12 #99`
- HOOK, merge target binding (F1): `looks up 12 and denies RECEIPT_ABSENT for gh pr merge 12 # note; echo done`
- HOOK, merge target binding (F1): `looks up 12 and denies RECEIPT_ABSENT for gh pr merge 12 # --disable-auto`
- HOOK, merge target binding (F1): `looks up 12 and denies RECEIPT_ABSENT for gh pr merge 12 --subject --disable-auto`
- HOOK, merge target binding (F1): `looks up 12 and denies RECEIPT_ABSENT for gh pr merge 12 --disable-auto=false`
- HOOK, merge target binding (F1): `looks up 12 and denies RECEIPT_ABSENT for gh pr merge 12 --disable-auto=true`
- HOOK, merge target binding (F1): `looks up 12 and denies RECEIPT_ABSENT for gh pr merge 12 --disable-auto --disable-auto=false`
- HOOK, merge target binding (F1): `looks up 12 and denies RECEIPT_ABSENT for gh pr merge --merge=1 12`
- HOOK, merge target binding (F1): `denies PR_UNRESOLVED with no gh call for gh pr merge 2>&1 12`
- HOOK, merge target binding (F1): `denies PR_UNRESOLVED with no gh call for gh pr merge --merge 2>&1 epic/x-integration`
- HOOK, merge target binding (F1): `denies PR_UNRESOLVED with no gh call for gh pr merge >log 2>&1 12`
- HOOK, merge target binding (F1): `denies PR_UNRESOLVED with no gh call for gh pr merge &>log 12`
- HOOK, merge target binding (F1): `denies PR_UNRESOLVED with no gh call for gh pr merge >&2 12`
- HOOK, merge target binding (F1): `denies PR_UNRESOLVED with no gh call for gh pr merge {12..12}`
- HOOK, merge target binding (F1): `denies PR_UNRESOLVED with no gh call for gh pr merge 1{2..2}`
- HOOK, merge target binding (F1): `denies PR_UNRESOLVED with no gh call for gh pr merge 2>/dev/null 12`
- HOOK, merge target binding (F1): `denies PR_UNRESOLVED with no gh call for gh pr merge > 99 12`
- HOOK, merge target binding (F1): `denies PR_UNRESOLVED with no gh call for gh pr merge 12 &`
- HOOK, merge target binding (F1): `denies PR_UNRESOLVED with no gh call for gh pr merge 12;`
- HOOK, merge target binding (F1): `denies PR_UNRESOLVED with no gh call for env --chdir=../other gh pr merge 12`
- HOOK, merge target binding (F1): `denies PR_UNRESOLVED with no gh call for builtin cd ../other; gh pr merge 12`
- HOOK, merge target binding (F1): `denies PR_UNRESOLVED with no gh call for GIT_DIR=../other gh pr merge 12`
- HOOK, merge target binding (F1): `denies PR_UNRESOLVED with no gh call for read GH_REPO; gh pr merge 12`
- HOOK, merge target binding (F1): `denies PR_UNRESOLVED with no gh call for export GH_REPO; gh pr merge 12`
- HOOK, merge target binding (F1): `denies PR_UNRESOLVED with no gh call for gh api -X PUT repos/other/repo/pulls/12/merge`
- HOOK, merge target binding (F1): `denies PR_UNRESOLVED with no gh call for gh api -X PUT /repos/other/repo/pulls/12/merge`
- HOOK, merge target binding (F1): `denies PR_UNRESOLVED with no gh call for timeout 30 gh pr merge epic/x-integration`
- HOOK, merge target binding (F1): `denies PR_UNRESOLVED with no gh call for sh -c 'gh pr merge epic/x-integration'`
- HOOK, merge target binding (F1): `denies PR_UNRESOLVED with no gh call for gh pr merge 99 --disable-auto; gh pr merge epic/x-integration --merge`
- HOOK, merge target binding (F1): `denies PR_UNRESOLVED with no gh call for cd ../other && gh pr merge https://github.com/o/r/pull/12 --merge`
- HOOK, merge target binding (F1): `denies PR_UNRESOLVED with no gh call for gh pr merge 12 --merge; echo done`
- HOOK, merge target binding (F1): `denies PR_UNRESOLVED with no gh call for gh pr view 12; gh pr merge 12 --merge`
- HOOK, merge target binding (F1): `denies PR_UNRESOLVED with no gh call for gh api -X PUT 'repos/{owner}/{repo}/pulls/12/merge'`
- HOOK, integration checkout (F1): `looks up the current branch and denies RECEIPT_ABSENT for gh pr merge #99`
- HOOK, integration checkout (F1): `looks up the current branch and denies RECEIPT_ABSENT for gh pr merge --merge=1`
- COMPOUND, compound merge scope (F3): `denies PR_UNRESOLVED with no gh call for if gh pr checks 12; then gh pr merge 12 --merge; fi`
- COMPOUND, compound merge scope (F3): `denies PR_UNRESOLVED with no gh call for for n in 12; do gh pr merge "$n" --merge; done`
- COMPOUND, compound merge scope (F3): `denies PR_UNRESOLVED with no gh call for ! gh pr merge 12`
- COMPOUND, compound merge scope (F3): `denies PR_UNRESOLVED with no gh call for exec gh pr merge 12`
- COMPOUND, compound merge scope (F3): `denies PR_UNRESOLVED with no gh call for while true; do gh pr merge 12 --merge; break; done`
- COMPOUND, compound merge scope (F3): `denies PR_UNRESOLVED with no gh call for if false; then echo x; else gh pr merge 12; fi`
- COMPOUND, compound merge scope (F3): `denies PR_UNRESOLVED with no gh call for until gh pr merge 12; do sleep 1; done`
- COMPOUND, compound merge scope (F3): `denies PR_UNRESOLVED with no gh call for sudo gh pr merge 12`
- COMPOUND, compound merge scope (F3): `denies PR_UNRESOLVED with no gh call for nice gh pr merge 12`
- COMPOUND, compound merge scope (F3): `denies PR_UNRESOLVED with no gh call for coproc gh pr merge 12`
- COMPOUND, compound merge scope (F3): `denies PR_UNRESOLVED with no gh call for find . -maxdepth 0 -exec gh pr merge 12 \;`
- COMPOUND, compound merge scope (F3): `denies PR_UNRESOLVED with no gh call for gh pr checks 12 && gh pr merge 12 --merge`
- COMPOUND, compound merge scope (F3): `denies PR_UNRESOLVED with no gh call for case x in x) gh pr merge 12;; esac`
- COMPOUND, compound merge scope (F3): `denies PR_UNRESOLVED with no gh call for f() { gh pr merge 12; }; f`
- COMPOUND, compound merge scope (F3): `denies PR_UNRESOLVED with no gh call for time gh pr merge 12`
- COMPOUND, compound merge scope (F3): `denies PR_UNRESOLVED with no gh call for nohup gh pr merge 12`
- COMPOUND, compound merge scope (F3): `denies PR_UNRESOLVED with no gh call for (gh pr merge 12)`
- COMPOUND, compound merge scope (F3): `denies PR_UNRESOLVED with no gh call for { gh pr merge 12; }`
- COMPOUND, compound merge scope (F3): `denies PR_UNRESOLVED with no gh call for if true; then gh api -X PUT repos/o/r/pulls/12/merge; fi`
- COMPOUND, compound merge scope (F3): `denies PR_UNRESOLVED with no gh call for ! gh api graphql -f query='mutation{mergePullRequest(x)}'`
- COMPOUND, compound merge scope (F3): `denies PR_UNRESOLVED with no gh call for gh api -X PUT repos/{owner}/{repo}/pulls/12/merge`
- COMPOUND, merge mentions: `denies PR_UNRESOLVED with no gh call for the unquoted mention echo gh pr merge 12 when the gate is enabled`
- COMPOUND, merge mentions: `denies PR_UNRESOLVED with no gh call for the unquoted mention gh pr view 12 && git merge main when the gate is enabled`
