# F4 and F5 Hook Process Run - Issue 1034 Remediation Cycle 3 (P3-T7)

Timestamp: 2026-11-07T05-21
Command: sh SCRATCH/issue-1034-c3-process.sh, which runs pwsh SCRATCH/issue-1034-c3-process.ps1 against a fresh consumer copy of .claude/hooks and .claude/lib under SCRATCH/consumer/, with the envelope on standard input of each hook process
EXIT_CODE: 0
Output Summary: PASS. 117 hook processes, 0 failures. All 38 commands of Groups F4, W and F5 print deny with PR_UNRESOLVED and the clause "does not name one pull request" at exit 0 with an enabled profile, and print allow at exit 0 with a disabled and with an absent profile. The three controls print allow at exit 0 with an enabled profile. Host paths are replaced by the token SCRATCH.

| Command | Profile | Decision | Exit | Reason code | Result |
|---|---|---|---|---|---|
| `gh pr merge 34 # x\<NL>gh pr merge 12` | enabled | deny | 0 | PR_UNRESOLVED | pass |
| `gh pr merge 34 # first line \<NL>gh pr merge 12 # second` | enabled | deny | 0 | PR_UNRESOLVED | pass |
| `gh pr merge 34 \<NL># x\<NL>gh pr merge 12` | enabled | deny | 0 | PR_UNRESOLVED | pass |
| `gh pr view 34 # x\<NL>gh pr merge 12` | enabled | deny | 0 | PR_UNRESOLVED | pass |
| `gh pr merge --disable-auto # x\<NL>gh pr merge 12` | enabled | deny | 0 | PR_UNRESOLVED | pass |
| `gh pr view 34 --json title # x\<NL>gh api -X PUT repos/o/r/pulls/12/merge` | enabled | deny | 0 | PR_UNRESOLVED | pass |
| `gh pr merge 34 # x\<CR><NL>gh pr merge 12` | enabled | deny | 0 | PR_UNRESOLVED | pass |
| `gh pr merge \<NL>12 # note` | enabled | deny | 0 | PR_UNRESOLVED | pass |
| `gh pr mer\<NL>ge 12` | enabled | deny | 0 | PR_UNRESOLVED | pass |
| `g\<NL>h pr merge 12` | enabled | deny | 0 | PR_UNRESOLVED | pass |
| `gh p\<NL>r merge 12` | enabled | deny | 0 | PR_UNRESOLVED | pass |
| `gh pr mer\<CR><NL>ge 12` | enabled | deny | 0 | PR_UNRESOLVED | pass |
| `true; gh pr mer\<NL>ge 12` | enabled | deny | 0 | PR_UNRESOLVED | pass |
| `if true; then sh -c 'gh pr merge 12'; fi` | enabled | deny | 0 | PR_UNRESOLVED | pass |
| `if true; then bash -c "gh pr merge 12"; fi` | enabled | deny | 0 | PR_UNRESOLVED | pass |
| `! sh -c 'gh pr merge 12'` | enabled | deny | 0 | PR_UNRESOLVED | pass |
| `exec sh -c 'gh pr merge 12'` | enabled | deny | 0 | PR_UNRESOLVED | pass |
| `for n in 12; do sh -c "gh pr merge $n"; done` | enabled | deny | 0 | PR_UNRESOLVED | pass |
| `if true; then eval 'gh pr merge 12'; fi` | enabled | deny | 0 | PR_UNRESOLVED | pass |
| `! eval 'gh pr merge 12'` | enabled | deny | 0 | PR_UNRESOLVED | pass |
| `nice sh -c 'gh pr merge 12'` | enabled | deny | 0 | PR_UNRESOLVED | pass |
| `find . -maxdepth 0 -exec sh -c 'gh pr merge 12' \;` | enabled | deny | 0 | PR_UNRESOLVED | pass |
| `sudo sh -c 'gh pr merge 12'` | enabled | deny | 0 | PR_UNRESOLVED | pass |
| `if true; then bash <<EOF<NL>gh pr merge 12<NL>EOF<NL>fi` | enabled | deny | 0 | PR_UNRESOLVED | pass |
| `echo 'gh pr merge 12' \| sh` | enabled | deny | 0 | PR_UNRESOLVED | pass |
| `printf 'gh pr merge 12' \| bash` | enabled | deny | 0 | PR_UNRESOLVED | pass |
| `g\h pr merge 12` | enabled | deny | 0 | PR_UNRESOLVED | pass |
| `gh pr mer\ge 12` | enabled | deny | 0 | PR_UNRESOLVED | pass |
| `gh p\r merge 12` | enabled | deny | 0 | PR_UNRESOLVED | pass |
| `true; g\h pr merge 12` | enabled | deny | 0 | PR_UNRESOLVED | pass |
| `g\h api -X PUT repos/o/r/pulls/12/merge` | enabled | deny | 0 | PR_UNRESOLVED | pass |
| `if true; then sh -c 'gh api -X PUT repos/o/r/pulls/12/merge'; fi` | enabled | deny | 0 | PR_UNRESOLVED | pass |
| `echo 'gh api -X PUT repos/o/r/pulls/12/merge' \| bash` | enabled | deny | 0 | PR_UNRESOLVED | pass |
| `if true; then ksh -c 'gh pr merge 12'; fi` | enabled | deny | 0 | PR_UNRESOLVED | pass |
| `if true; then pwsh -Command 'gh pr merge 12'; fi` | enabled | deny | 0 | PR_UNRESOLVED | pass |
| `source <(echo 'gh pr merge 12')` | enabled | deny | 0 | PR_UNRESOLVED | pass |
| `echo bash 'gh pr merge 12'` | enabled | deny | 0 | PR_UNRESOLVED | pass |
| `./run.sh 'gh pr merge 12'` | enabled | deny | 0 | PR_UNRESOLVED | pass |
| `gh pr merge 34 # x\<NL>gh pr merge 12` | disabled | allow | 0 |  | pass |
| `gh pr merge 34 # first line \<NL>gh pr merge 12 # second` | disabled | allow | 0 |  | pass |
| `gh pr merge 34 \<NL># x\<NL>gh pr merge 12` | disabled | allow | 0 |  | pass |
| `gh pr view 34 # x\<NL>gh pr merge 12` | disabled | allow | 0 |  | pass |
| `gh pr merge --disable-auto # x\<NL>gh pr merge 12` | disabled | allow | 0 |  | pass |
| `gh pr view 34 --json title # x\<NL>gh api -X PUT repos/o/r/pulls/12/merge` | disabled | allow | 0 |  | pass |
| `gh pr merge 34 # x\<CR><NL>gh pr merge 12` | disabled | allow | 0 |  | pass |
| `gh pr merge \<NL>12 # note` | disabled | allow | 0 |  | pass |
| `gh pr mer\<NL>ge 12` | disabled | allow | 0 |  | pass |
| `g\<NL>h pr merge 12` | disabled | allow | 0 |  | pass |
| `gh p\<NL>r merge 12` | disabled | allow | 0 |  | pass |
| `gh pr mer\<CR><NL>ge 12` | disabled | allow | 0 |  | pass |
| `true; gh pr mer\<NL>ge 12` | disabled | allow | 0 |  | pass |
| `if true; then sh -c 'gh pr merge 12'; fi` | disabled | allow | 0 |  | pass |
| `if true; then bash -c "gh pr merge 12"; fi` | disabled | allow | 0 |  | pass |
| `! sh -c 'gh pr merge 12'` | disabled | allow | 0 |  | pass |
| `exec sh -c 'gh pr merge 12'` | disabled | allow | 0 |  | pass |
| `for n in 12; do sh -c "gh pr merge $n"; done` | disabled | allow | 0 |  | pass |
| `if true; then eval 'gh pr merge 12'; fi` | disabled | allow | 0 |  | pass |
| `! eval 'gh pr merge 12'` | disabled | allow | 0 |  | pass |
| `nice sh -c 'gh pr merge 12'` | disabled | allow | 0 |  | pass |
| `find . -maxdepth 0 -exec sh -c 'gh pr merge 12' \;` | disabled | allow | 0 |  | pass |
| `sudo sh -c 'gh pr merge 12'` | disabled | allow | 0 |  | pass |
| `if true; then bash <<EOF<NL>gh pr merge 12<NL>EOF<NL>fi` | disabled | allow | 0 |  | pass |
| `echo 'gh pr merge 12' \| sh` | disabled | allow | 0 |  | pass |
| `printf 'gh pr merge 12' \| bash` | disabled | allow | 0 |  | pass |
| `g\h pr merge 12` | disabled | allow | 0 |  | pass |
| `gh pr mer\ge 12` | disabled | allow | 0 |  | pass |
| `gh p\r merge 12` | disabled | allow | 0 |  | pass |
| `true; g\h pr merge 12` | disabled | allow | 0 |  | pass |
| `g\h api -X PUT repos/o/r/pulls/12/merge` | disabled | allow | 0 |  | pass |
| `if true; then sh -c 'gh api -X PUT repos/o/r/pulls/12/merge'; fi` | disabled | allow | 0 |  | pass |
| `echo 'gh api -X PUT repos/o/r/pulls/12/merge' \| bash` | disabled | allow | 0 |  | pass |
| `if true; then ksh -c 'gh pr merge 12'; fi` | disabled | allow | 0 |  | pass |
| `if true; then pwsh -Command 'gh pr merge 12'; fi` | disabled | allow | 0 |  | pass |
| `source <(echo 'gh pr merge 12')` | disabled | allow | 0 |  | pass |
| `echo bash 'gh pr merge 12'` | disabled | allow | 0 |  | pass |
| `./run.sh 'gh pr merge 12'` | disabled | allow | 0 |  | pass |
| `gh pr merge 34 # x\<NL>gh pr merge 12` | absent | allow | 0 |  | pass |
| `gh pr merge 34 # first line \<NL>gh pr merge 12 # second` | absent | allow | 0 |  | pass |
| `gh pr merge 34 \<NL># x\<NL>gh pr merge 12` | absent | allow | 0 |  | pass |
| `gh pr view 34 # x\<NL>gh pr merge 12` | absent | allow | 0 |  | pass |
| `gh pr merge --disable-auto # x\<NL>gh pr merge 12` | absent | allow | 0 |  | pass |
| `gh pr view 34 --json title # x\<NL>gh api -X PUT repos/o/r/pulls/12/merge` | absent | allow | 0 |  | pass |
| `gh pr merge 34 # x\<CR><NL>gh pr merge 12` | absent | allow | 0 |  | pass |
| `gh pr merge \<NL>12 # note` | absent | allow | 0 |  | pass |
| `gh pr mer\<NL>ge 12` | absent | allow | 0 |  | pass |
| `g\<NL>h pr merge 12` | absent | allow | 0 |  | pass |
| `gh p\<NL>r merge 12` | absent | allow | 0 |  | pass |
| `gh pr mer\<CR><NL>ge 12` | absent | allow | 0 |  | pass |
| `true; gh pr mer\<NL>ge 12` | absent | allow | 0 |  | pass |
| `if true; then sh -c 'gh pr merge 12'; fi` | absent | allow | 0 |  | pass |
| `if true; then bash -c "gh pr merge 12"; fi` | absent | allow | 0 |  | pass |
| `! sh -c 'gh pr merge 12'` | absent | allow | 0 |  | pass |
| `exec sh -c 'gh pr merge 12'` | absent | allow | 0 |  | pass |
| `for n in 12; do sh -c "gh pr merge $n"; done` | absent | allow | 0 |  | pass |
| `if true; then eval 'gh pr merge 12'; fi` | absent | allow | 0 |  | pass |
| `! eval 'gh pr merge 12'` | absent | allow | 0 |  | pass |
| `nice sh -c 'gh pr merge 12'` | absent | allow | 0 |  | pass |
| `find . -maxdepth 0 -exec sh -c 'gh pr merge 12' \;` | absent | allow | 0 |  | pass |
| `sudo sh -c 'gh pr merge 12'` | absent | allow | 0 |  | pass |
| `if true; then bash <<EOF<NL>gh pr merge 12<NL>EOF<NL>fi` | absent | allow | 0 |  | pass |
| `echo 'gh pr merge 12' \| sh` | absent | allow | 0 |  | pass |
| `printf 'gh pr merge 12' \| bash` | absent | allow | 0 |  | pass |
| `g\h pr merge 12` | absent | allow | 0 |  | pass |
| `gh pr mer\ge 12` | absent | allow | 0 |  | pass |
| `gh p\r merge 12` | absent | allow | 0 |  | pass |
| `true; g\h pr merge 12` | absent | allow | 0 |  | pass |
| `g\h api -X PUT repos/o/r/pulls/12/merge` | absent | allow | 0 |  | pass |
| `if true; then sh -c 'gh api -X PUT repos/o/r/pulls/12/merge'; fi` | absent | allow | 0 |  | pass |
| `echo 'gh api -X PUT repos/o/r/pulls/12/merge' \| bash` | absent | allow | 0 |  | pass |
| `if true; then ksh -c 'gh pr merge 12'; fi` | absent | allow | 0 |  | pass |
| `if true; then pwsh -Command 'gh pr merge 12'; fi` | absent | allow | 0 |  | pass |
| `source <(echo 'gh pr merge 12')` | absent | allow | 0 |  | pass |
| `echo bash 'gh pr merge 12'` | absent | allow | 0 |  | pass |
| `./run.sh 'gh pr merge 12'` | absent | allow | 0 |  | pass |
| `git commit -m 'gh pr merge 12'` | enabled | allow | 0 |  | pass |
| `echo "gh pr merge 12"` | enabled | allow | 0 |  | pass |
| `git log --grep='gh pr merge'` | enabled | allow | 0 |  | pass |
