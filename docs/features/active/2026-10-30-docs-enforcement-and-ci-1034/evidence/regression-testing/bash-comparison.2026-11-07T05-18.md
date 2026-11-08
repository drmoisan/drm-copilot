# Real-Bash Comparison - Issue 1034 Remediation Cycle 3 (P3-T6)

Timestamp: 2026-11-07T05-18
Command: sh SCRATCH/issue-1034-c3-cmp.sh, then pwsh SCRATCH/issue-1034-c3-cmp-artifact.ps1
EXIT_CODE: 0
Output Summary: PASS. 320 rows, equal to the derivation of ## Comparison Set. agree 290, of which false deny 24; escape 29; not observed 1. Every escape carries a Class value naming a form of the limit statement, and each form is present in the HOOK header and FEATURE/spec.md after whitespace collapse. Every row of Groups F4, W and F5 is agree or not observed. No row was added and no form was added to the limit statement.

## Row Derivation

| Source | Rows |
|---|---|
| F4 | 8 |
| W | 5 |
| F5 | 25 |
| C | 4 |
| D | 1 |
| R | 17 |
| TOP | 9 |
| ML | 110 |
| POS | 56 |
| PL | 81 |
| FILE | 4 |
| Added by this task | 0 |
| Total | 320 |

`TOP` is the `Top-level controls` of `### F5 results` with its elisions expanded. `C` holds the two new controls and the two existing controls that `## Row Groups` names. `ML`, `POS`, `PL` and `FILE` are the Multi-line, Positional, Payload and Files derivations.

## Method

- Stand-ins for `gh`, `git` and `curl`, each with a `.cmd` form, are first on `PATH` under SCRATCH/compare/bin/, and `sudo` runs its arguments. The directories holding the real `gh`, `git` and `curl` are off `PATH`. A read-only probe showed Python and PowerShell resolving the `gh` stand-in, and the Windows search path holding no other `gh`, before any merge-shaped row ran.
- Each row ran through `bash -c` in a scratch working directory holding `merge.sh`, with standard input from `/dev/null`. Each stand-in appends one whole record per call, so concurrent pipeline stages do not interleave.
- The driver dot-sources the HOOK of a consumer copy with an enabled profile and no receipt, and replaces only `Invoke-DocsOnlyGhExe` with a recorder. Selector 12 is the integration pull request.
- 35 rows are plain and reached the lookup; each looked up the selector bash passed.
- Group D: a `GET` on the merge endpoint does not merge, so that row is `agree` and a `false deny`, as the limit statement accepts.
- On this host Git Bash treats a backslash followed by a carriage return and line feed as a continuation; the `\<CR><NL>` rows record that behavior as observed.

## Rows the Stand-ins Cannot Show Merging

- `gh alias set m 'pr merge 12'; gh m`: `agree`. A stand-in does not resolve an alias, read a mutation from a file, or see a number in an unset variable. The form stays in the limit statement.
- `gh api graphql -F query=@f.graphql`: `agree`. A stand-in does not resolve an alias, read a mutation from a file, or see a number in an unset variable. The form stays in the limit statement.
- `gh api graphql --input f`: `agree`. A stand-in does not resolve an alias, read a mutation from a file, or see a number in an unset variable. The form stays in the limit statement.
- `gh api -X PUT repos/o/r/pulls/$n/merge`: `agree`. A stand-in does not resolve an alias, read a mutation from a file, or see a number in an unset variable. The form stays in the limit statement.

## Not Observed

- `if true; then ksh -c 'gh pr merge 12'; fi`: interpreter ksh missing on this host. P3-T2 and P3-T7 assert the deny of the hook for this row.

## Escapes by Class

| Class | Rows |
|---|---|
| a direct git push to main | 1 |
| computed command words | 6 |
| curl | 1 |
| evaluators outside the named words | 4 |
| node -e | 4 |
| python -c | 4 |
| quoted command word | 3 |
| scripts on disk | 6 |

Every class is a form already named in the third item of the limit statement, so no form was denied or listed in this task.

## Rows

| Group | Command | Arguments bash passed | Lookup | Decision | Result | Class |
|---|---|---|---|---|---|---|
| F4 | `gh pr merge 34 # x\<NL>gh pr merge 12` | `gh pr merge 34 ; gh pr merge 12` | `none` | deny PR_UNRESOLVED | agree |  |
| F4 | `gh pr merge 34 # first line \<NL>gh pr merge 12 # second` | `gh pr merge 34 ; gh pr merge 12` | `none` | deny PR_UNRESOLVED | agree |  |
| F4 | `gh pr merge 34 \<NL># x\<NL>gh pr merge 12` | `gh pr merge 34 ; gh pr merge 12` | `none` | deny PR_UNRESOLVED | agree |  |
| F4 | `gh pr view 34 # x\<NL>gh pr merge 12` | `gh pr view 34 ; gh pr merge 12` | `none` | deny PR_UNRESOLVED | agree |  |
| F4 | `gh pr merge --disable-auto # x\<NL>gh pr merge 12` | `gh pr merge --disable-auto ; gh pr merge 12` | `none` | deny PR_UNRESOLVED | agree |  |
| F4 | `gh pr view 34 --json title # x\<NL>gh api -X PUT repos/o/r/pulls/12/merge` | `gh pr view 34 --json title ; gh api -X PUT repos/o/r/pulls/12/merge` | `none` | deny PR_UNRESOLVED | agree |  |
| F4 | `gh pr merge 34 # x\<CR><NL>gh pr merge 12` | `gh pr merge 34 ; gh pr merge 12` | `none` | deny PR_UNRESOLVED | agree |  |
| F4 | `gh pr merge \<NL>12 # note` | `gh pr merge 12` | `none` | deny PR_UNRESOLVED | agree |  |
| W | `gh pr mer\<NL>ge 12` | `gh pr merge 12` | `none` | deny PR_UNRESOLVED | agree |  |
| W | `g\<NL>h pr merge 12` | `gh pr merge 12` | `none` | deny PR_UNRESOLVED | agree |  |
| W | `gh p\<NL>r merge 12` | `gh pr merge 12` | `none` | deny PR_UNRESOLVED | agree |  |
| W | `gh pr mer\<CR><NL>ge 12` | `gh pr merge 12` | `none` | deny PR_UNRESOLVED | agree |  |
| W | `true; gh pr mer\<NL>ge 12` | `gh pr merge 12` | `none` | deny PR_UNRESOLVED | agree |  |
| F5 | `if true; then sh -c 'gh pr merge 12'; fi` | `gh pr merge 12` | `none` | deny PR_UNRESOLVED | agree |  |
| F5 | `if true; then bash -c "gh pr merge 12"; fi` | `gh pr merge 12` | `none` | deny PR_UNRESOLVED | agree |  |
| F5 | `! sh -c 'gh pr merge 12'` | `gh pr merge 12` | `none` | deny PR_UNRESOLVED | agree |  |
| F5 | `exec sh -c 'gh pr merge 12'` | `gh pr merge 12` | `none` | deny PR_UNRESOLVED | agree |  |
| F5 | `for n in 12; do sh -c "gh pr merge $n"; done` | `gh pr merge 12` | `none` | deny PR_UNRESOLVED | agree |  |
| F5 | `if true; then eval 'gh pr merge 12'; fi` | `gh pr merge 12` | `none` | deny PR_UNRESOLVED | agree |  |
| F5 | `! eval 'gh pr merge 12'` | `gh pr merge 12` | `none` | deny PR_UNRESOLVED | agree |  |
| F5 | `nice sh -c 'gh pr merge 12'` | `gh pr merge 12` | `none` | deny PR_UNRESOLVED | agree |  |
| F5 | `find . -maxdepth 0 -exec sh -c 'gh pr merge 12' \;` | `gh pr merge 12` | `none` | deny PR_UNRESOLVED | agree |  |
| F5 | `sudo sh -c 'gh pr merge 12'` | `gh pr merge 12` | `none` | deny PR_UNRESOLVED | agree |  |
| F5 | `if true; then bash <<EOF<NL>gh pr merge 12<NL>EOF<NL>fi` | `gh pr merge 12` | `none` | deny PR_UNRESOLVED | agree |  |
| F5 | `echo 'gh pr merge 12' \| sh` | `gh pr merge 12` | `none` | deny PR_UNRESOLVED | agree |  |
| F5 | `printf 'gh pr merge 12' \| bash` | `gh pr merge 12` | `none` | deny PR_UNRESOLVED | agree |  |
| F5 | `g\h pr merge 12` | `gh pr merge 12` | `none` | deny PR_UNRESOLVED | agree |  |
| F5 | `gh pr mer\ge 12` | `gh pr merge 12` | `none` | deny PR_UNRESOLVED | agree |  |
| F5 | `gh p\r merge 12` | `gh pr merge 12` | `none` | deny PR_UNRESOLVED | agree |  |
| F5 | `true; g\h pr merge 12` | `gh pr merge 12` | `none` | deny PR_UNRESOLVED | agree |  |
| F5 | `g\h api -X PUT repos/o/r/pulls/12/merge` | `gh api -X PUT repos/o/r/pulls/12/merge` | `none` | deny PR_UNRESOLVED | agree |  |
| F5 | `if true; then sh -c 'gh api -X PUT repos/o/r/pulls/12/merge'; fi` | `gh api -X PUT repos/o/r/pulls/12/merge` | `none` | deny PR_UNRESOLVED | agree |  |
| F5 | `echo 'gh api -X PUT repos/o/r/pulls/12/merge' \| bash` | `gh api -X PUT repos/o/r/pulls/12/merge` | `none` | deny PR_UNRESOLVED | agree |  |
| F5 | `if true; then ksh -c 'gh pr merge 12'; fi` | `none` | `none` | deny PR_UNRESOLVED | not observed |  |
| F5 | `if true; then pwsh -Command 'gh pr merge 12'; fi` | `gh pr merge 12` | `none` | deny PR_UNRESOLVED | agree |  |
| F5 | `source <(echo 'gh pr merge 12')` | `gh pr merge 12` | `none` | deny PR_UNRESOLVED | agree |  |
| F5 | `echo bash 'gh pr merge 12'` | `none` | `none` | deny PR_UNRESOLVED | agree, false deny |  |
| F5 | `./run.sh 'gh pr merge 12'` | `none` | `none` | deny PR_UNRESOLVED | agree, false deny |  |
| C | `git log --grep='gh pr merge'` | `git log --grep=gh pr merge` | `none` | allow | agree |  |
| C | `git commit -m 'gh api -X PUT repos/o/r/pulls/12/merge'` | `git commit -m gh api -X PUT repos/o/r/pulls/12/merge` | `none` | allow | agree |  |
| C | `git commit -m 'gh pr merge 12'` | `git commit -m gh pr merge 12` | `none` | allow | agree |  |
| C | `echo "gh pr merge 12"` | `none` | `none` | allow | agree |  |
| D | `gh api -X GET repos/o/r/pulls/12/merge` | `gh api -X GET repos/o/r/pulls/12/merge` | `none` | deny PR_UNRESOLVED | agree, false deny |  |
| R | `python -c "import os; os.system('gh pr merge 12')"` | `gh pr merge 12` | `none` | allow | escape | Class: python -c |
| R | `node -e "require('child_process').execSync('gh pr merge 12')"` | `gh pr merge 12` | `none` | allow | escape | Class: node -e |
| R | `curl -X PUT https://api.github.com/repos/o/r/pulls/12/merge` | `curl -X PUT https://api.github.com/repos/o/r/pulls/12/merge` | `none` | allow | escape | Class: curl |
| R | `./merge.sh` | `gh pr merge 12` | `none` | allow | escape | Class: scripts on disk |
| R | `sh merge.sh` | `gh pr merge 12` | `none` | allow | escape | Class: scripts on disk |
| R | `a=g; b=h; $a$b pr merge 12` | `gh pr merge 12` | `none` | allow | escape | Class: computed command words |
| R | `$(echo 'gh pr merge 12')` | `gh pr merge 12` | `none` | allow | escape | Class: computed command words |
| R | `if true; then "gh" pr merge 12; fi` | `gh pr merge 12` | `none` | allow | escape | Class: quoted command word |
| R | `! gh pr 'merge' 12` | `gh pr merge 12` | `none` | allow | escape | Class: quoted command word |
| R | `exec gh 'pr' merge 12` | `gh pr merge 12` | `none` | allow | escape | Class: quoted command word |
| R | `gh pr me${x}rge 12` | `gh pr merge 12` | `none` | allow | escape | Class: computed command words |
| R | `trap 'gh pr merge 12' EXIT` | `gh pr merge 12` | `none` | allow | escape | Class: evaluators outside the named words |
| R | `gh alias set m 'pr merge 12'; gh m` | `gh alias set m pr merge 12 ; gh m` | `none` | allow | agree |  |
| R | `gh api graphql -F query=@f.graphql` | `gh api graphql -F query=@f.graphql` | `none` | allow | agree |  |
| R | `gh api graphql --input f` | `gh api graphql --input f` | `none` | allow | agree |  |
| R | `gh api -X PUT repos/o/r/pulls/$n/merge` | `gh api -X PUT repos/o/r/pulls//merge` | `none` | allow | agree |  |
| R | `git push origin HEAD:main` | `git push origin HEAD:main` | `none` | allow | escape | Class: a direct git push to main |
| TOP | `sh -c 'gh pr merge 12'` | `gh pr merge 12` | `none` | deny PR_UNRESOLVED | agree |  |
| TOP | `bash -c "gh pr merge 12"` | `gh pr merge 12` | `none` | deny PR_UNRESOLVED | agree |  |
| TOP | `eval 'gh pr merge 12'` | `gh pr merge 12` | `none` | deny PR_UNRESOLVED | agree |  |
| TOP | `env sh -c 'gh pr merge 12'` | `gh pr merge 12` | `none` | deny PR_UNRESOLVED | agree |  |
| TOP | `sh <<< 'gh pr merge 12'` | `gh pr merge 12` | `none` | deny PR_UNRESOLVED | agree |  |
| TOP | `bash <<EOF<NL>gh pr merge 12<NL>EOF` | `gh pr merge 12` | `none` | deny PR_UNRESOLVED | agree |  |
| TOP | `pwsh -NoProfile -Command 'gh pr merge 12'` | `gh pr merge 12` | `none` | deny PR_UNRESOLVED | agree |  |
| TOP | `\gh pr merge 12` | `gh pr merge 12` | `none` | deny PR_UNRESOLVED | agree |  |
| TOP | `gh pr \merge 12` | `gh pr merge 12` | `none` | deny PR_UNRESOLVED | agree |  |
| ML | `gh pr view 34<NL>gh pr merge 12` | `gh pr view 34 ; gh pr merge 12` | `none` | deny PR_UNRESOLVED | agree |  |
| ML | `gh pr view 34<NL>gh api -X PUT repos/o/r/pulls/12/merge` | `gh pr view 34 ; gh api -X PUT repos/o/r/pulls/12/merge` | `none` | deny PR_UNRESOLVED | agree |  |
| ML | `gh pr view 34 # x<NL>gh pr merge 12` | `gh pr view 34 ; gh pr merge 12` | `none` | deny PR_UNRESOLVED | agree |  |
| ML | `gh pr view 34 # x<NL>gh api -X PUT repos/o/r/pulls/12/merge` | `gh pr view 34 ; gh api -X PUT repos/o/r/pulls/12/merge` | `none` | deny PR_UNRESOLVED | agree |  |
| ML | `gh pr view 34 # x\<NL>gh pr merge 12` | `gh pr view 34 ; gh pr merge 12` | `none` | deny PR_UNRESOLVED | agree |  |
| ML | `gh pr view 34 # x\<NL>gh api -X PUT repos/o/r/pulls/12/merge` | `gh pr view 34 ; gh api -X PUT repos/o/r/pulls/12/merge` | `none` | deny PR_UNRESOLVED | agree |  |
| ML | `gh pr view 34 # x \<NL>gh pr merge 12` | `gh pr view 34 ; gh pr merge 12` | `none` | deny PR_UNRESOLVED | agree |  |
| ML | `gh pr view 34 # x \<NL>gh api -X PUT repos/o/r/pulls/12/merge` | `gh pr view 34 ; gh api -X PUT repos/o/r/pulls/12/merge` | `none` | deny PR_UNRESOLVED | agree |  |
| ML | `gh pr view 34 \<NL>gh pr merge 12` | `gh pr view 34 gh pr merge 12` | `none` | allow | agree |  |
| ML | `gh pr view 34 \<NL>gh api -X PUT repos/o/r/pulls/12/merge` | `gh pr view 34 gh api -X PUT repos/o/r/pulls/12/merge` | `none` | allow | agree |  |
| ML | `gh pr view 34\<NL>gh pr merge 12` | `gh pr view 34gh pr merge 12` | `none` | deny PR_UNRESOLVED | agree, false deny |  |
| ML | `gh pr view 34\<NL>gh api -X PUT repos/o/r/pulls/12/merge` | `gh pr view 34gh api -X PUT repos/o/r/pulls/12/merge` | `none` | deny PR_UNRESOLVED | agree, false deny |  |
| ML | `gh pr view 34\<CR><NL>gh pr merge 12` | `gh pr view 34gh pr merge 12` | `none` | deny PR_UNRESOLVED | agree, false deny |  |
| ML | `gh pr view 34\<CR><NL>gh api -X PUT repos/o/r/pulls/12/merge` | `gh pr view 34gh api -X PUT repos/o/r/pulls/12/merge` | `none` | deny PR_UNRESOLVED | agree, false deny |  |
| ML | `gh pr view 34;<NL>gh pr merge 12` | `gh pr view 34 ; gh pr merge 12` | `none` | deny PR_UNRESOLVED | agree |  |
| ML | `gh pr view 34;<NL>gh api -X PUT repos/o/r/pulls/12/merge` | `gh pr view 34 ; gh api -X PUT repos/o/r/pulls/12/merge` | `none` | deny PR_UNRESOLVED | agree |  |
| ML | `gh pr view 34 &&<NL>gh pr merge 12` | `gh pr view 34 ; gh pr merge 12` | `none` | deny PR_UNRESOLVED | agree |  |
| ML | `gh pr view 34 &&<NL>gh api -X PUT repos/o/r/pulls/12/merge` | `gh pr view 34 ; gh api -X PUT repos/o/r/pulls/12/merge` | `none` | deny PR_UNRESOLVED | agree |  |
| ML | `gh pr view 34 && \<NL>gh pr merge 12` | `gh pr view 34 ; gh pr merge 12` | `none` | deny PR_UNRESOLVED | agree |  |
| ML | `gh pr view 34 && \<NL>gh api -X PUT repos/o/r/pulls/12/merge` | `gh pr view 34 ; gh api -X PUT repos/o/r/pulls/12/merge` | `none` | deny PR_UNRESOLVED | agree |  |
| ML | `gh pr view 34 \|<NL>gh pr merge 12` | `gh pr view 34 ; gh pr merge 12` | `none` | deny PR_UNRESOLVED | agree |  |
| ML | `gh pr view 34 \|<NL>gh api -X PUT repos/o/r/pulls/12/merge` | `gh pr view 34 ; gh api -X PUT repos/o/r/pulls/12/merge` | `none` | deny PR_UNRESOLVED | agree |  |
| ML | `gh pr merge 34<NL>gh pr merge 12` | `gh pr merge 34 ; gh pr merge 12` | `none` | deny PR_UNRESOLVED | agree |  |
| ML | `gh pr merge 34<NL>gh api -X PUT repos/o/r/pulls/12/merge` | `gh pr merge 34 ; gh api -X PUT repos/o/r/pulls/12/merge` | `none` | deny PR_UNRESOLVED | agree |  |
| ML | `gh pr merge 34 # x<NL>gh pr merge 12` | `gh pr merge 34 ; gh pr merge 12` | `none` | deny PR_UNRESOLVED | agree |  |
| ML | `gh pr merge 34 # x<NL>gh api -X PUT repos/o/r/pulls/12/merge` | `gh pr merge 34 ; gh api -X PUT repos/o/r/pulls/12/merge` | `none` | deny PR_UNRESOLVED | agree |  |
| ML | `gh pr merge 34 # x\<NL>gh pr merge 12` | `gh pr merge 34 ; gh pr merge 12` | `none` | deny PR_UNRESOLVED | agree |  |
| ML | `gh pr merge 34 # x\<NL>gh api -X PUT repos/o/r/pulls/12/merge` | `gh pr merge 34 ; gh api -X PUT repos/o/r/pulls/12/merge` | `none` | deny PR_UNRESOLVED | agree |  |
| ML | `gh pr merge 34 # x \<NL>gh pr merge 12` | `gh pr merge 34 ; gh pr merge 12` | `none` | deny PR_UNRESOLVED | agree |  |
| ML | `gh pr merge 34 # x \<NL>gh api -X PUT repos/o/r/pulls/12/merge` | `gh pr merge 34 ; gh api -X PUT repos/o/r/pulls/12/merge` | `none` | deny PR_UNRESOLVED | agree |  |
| ML | `gh pr merge 34 \<NL>gh pr merge 12` | `gh pr merge 34 gh pr merge 12` | `none` | deny PR_UNRESOLVED | agree |  |
| ML | `gh pr merge 34 \<NL>gh api -X PUT repos/o/r/pulls/12/merge` | `gh pr merge 34 gh api -X PUT repos/o/r/pulls/12/merge` | `none` | deny PR_UNRESOLVED | agree |  |
| ML | `gh pr merge 34\<NL>gh pr merge 12` | `gh pr merge 34gh pr merge 12` | `none` | deny PR_UNRESOLVED | agree |  |
| ML | `gh pr merge 34\<NL>gh api -X PUT repos/o/r/pulls/12/merge` | `gh pr merge 34gh api -X PUT repos/o/r/pulls/12/merge` | `none` | deny PR_UNRESOLVED | agree |  |
| ML | `gh pr merge 34\<CR><NL>gh pr merge 12` | `gh pr merge 34gh pr merge 12` | `none` | deny PR_UNRESOLVED | agree |  |
| ML | `gh pr merge 34\<CR><NL>gh api -X PUT repos/o/r/pulls/12/merge` | `gh pr merge 34gh api -X PUT repos/o/r/pulls/12/merge` | `none` | deny PR_UNRESOLVED | agree |  |
| ML | `gh pr merge 34;<NL>gh pr merge 12` | `gh pr merge 34 ; gh pr merge 12` | `none` | deny PR_UNRESOLVED | agree |  |
| ML | `gh pr merge 34;<NL>gh api -X PUT repos/o/r/pulls/12/merge` | `gh pr merge 34 ; gh api -X PUT repos/o/r/pulls/12/merge` | `none` | deny PR_UNRESOLVED | agree |  |
| ML | `gh pr merge 34 &&<NL>gh pr merge 12` | `gh pr merge 34 ; gh pr merge 12` | `none` | deny PR_UNRESOLVED | agree |  |
| ML | `gh pr merge 34 &&<NL>gh api -X PUT repos/o/r/pulls/12/merge` | `gh pr merge 34 ; gh api -X PUT repos/o/r/pulls/12/merge` | `none` | deny PR_UNRESOLVED | agree |  |
| ML | `gh pr merge 34 && \<NL>gh pr merge 12` | `gh pr merge 34 ; gh pr merge 12` | `none` | deny PR_UNRESOLVED | agree |  |
| ML | `gh pr merge 34 && \<NL>gh api -X PUT repos/o/r/pulls/12/merge` | `gh pr merge 34 ; gh api -X PUT repos/o/r/pulls/12/merge` | `none` | deny PR_UNRESOLVED | agree |  |
| ML | `gh pr merge 34 \|<NL>gh pr merge 12` | `gh pr merge 34 ; gh pr merge 12` | `none` | deny PR_UNRESOLVED | agree |  |
| ML | `gh pr merge 34 \|<NL>gh api -X PUT repos/o/r/pulls/12/merge` | `gh pr merge 34 ; gh api -X PUT repos/o/r/pulls/12/merge` | `none` | deny PR_UNRESOLVED | agree |  |
| ML | `gh pr merge --disable-auto<NL>gh pr merge 12` | `gh pr merge --disable-auto ; gh pr merge 12` | `none` | deny PR_UNRESOLVED | agree |  |
| ML | `gh pr merge --disable-auto<NL>gh api -X PUT repos/o/r/pulls/12/merge` | `gh pr merge --disable-auto ; gh api -X PUT repos/o/r/pulls/12/merge` | `none` | deny PR_UNRESOLVED | agree |  |
| ML | `gh pr merge --disable-auto # x<NL>gh pr merge 12` | `gh pr merge --disable-auto ; gh pr merge 12` | `none` | deny PR_UNRESOLVED | agree |  |
| ML | `gh pr merge --disable-auto # x<NL>gh api -X PUT repos/o/r/pulls/12/merge` | `gh pr merge --disable-auto ; gh api -X PUT repos/o/r/pulls/12/merge` | `none` | deny PR_UNRESOLVED | agree |  |
| ML | `gh pr merge --disable-auto # x\<NL>gh pr merge 12` | `gh pr merge --disable-auto ; gh pr merge 12` | `none` | deny PR_UNRESOLVED | agree |  |
| ML | `gh pr merge --disable-auto # x\<NL>gh api -X PUT repos/o/r/pulls/12/merge` | `gh pr merge --disable-auto ; gh api -X PUT repos/o/r/pulls/12/merge` | `none` | deny PR_UNRESOLVED | agree |  |
| ML | `gh pr merge --disable-auto # x \<NL>gh pr merge 12` | `gh pr merge --disable-auto ; gh pr merge 12` | `none` | deny PR_UNRESOLVED | agree |  |
| ML | `gh pr merge --disable-auto # x \<NL>gh api -X PUT repos/o/r/pulls/12/merge` | `gh pr merge --disable-auto ; gh api -X PUT repos/o/r/pulls/12/merge` | `none` | deny PR_UNRESOLVED | agree |  |
| ML | `gh pr merge --disable-auto \<NL>gh pr merge 12` | `gh pr merge --disable-auto gh pr merge 12` | `none` | deny PR_UNRESOLVED | agree, false deny |  |
| ML | `gh pr merge --disable-auto \<NL>gh api -X PUT repos/o/r/pulls/12/merge` | `gh pr merge --disable-auto gh api -X PUT repos/o/r/pulls/12/merge` | `none` | deny PR_UNRESOLVED | agree, false deny |  |
| ML | `gh pr merge --disable-auto\<NL>gh pr merge 12` | `gh pr merge --disable-autogh pr merge 12` | `none` | deny PR_UNRESOLVED | agree |  |
| ML | `gh pr merge --disable-auto\<NL>gh api -X PUT repos/o/r/pulls/12/merge` | `gh pr merge --disable-autogh api -X PUT repos/o/r/pulls/12/merge` | `none` | deny PR_UNRESOLVED | agree |  |
| ML | `gh pr merge --disable-auto\<CR><NL>gh pr merge 12` | `gh pr merge --disable-autogh pr merge 12` | `none` | deny PR_UNRESOLVED | agree |  |
| ML | `gh pr merge --disable-auto\<CR><NL>gh api -X PUT repos/o/r/pulls/12/merge` | `gh pr merge --disable-autogh api -X PUT repos/o/r/pulls/12/merge` | `none` | deny PR_UNRESOLVED | agree |  |
| ML | `gh pr merge --disable-auto;<NL>gh pr merge 12` | `gh pr merge --disable-auto ; gh pr merge 12` | `none` | deny PR_UNRESOLVED | agree |  |
| ML | `gh pr merge --disable-auto;<NL>gh api -X PUT repos/o/r/pulls/12/merge` | `gh pr merge --disable-auto ; gh api -X PUT repos/o/r/pulls/12/merge` | `none` | deny PR_UNRESOLVED | agree |  |
| ML | `gh pr merge --disable-auto &&<NL>gh pr merge 12` | `gh pr merge --disable-auto ; gh pr merge 12` | `none` | deny PR_UNRESOLVED | agree |  |
| ML | `gh pr merge --disable-auto &&<NL>gh api -X PUT repos/o/r/pulls/12/merge` | `gh pr merge --disable-auto ; gh api -X PUT repos/o/r/pulls/12/merge` | `none` | deny PR_UNRESOLVED | agree |  |
| ML | `gh pr merge --disable-auto && \<NL>gh pr merge 12` | `gh pr merge --disable-auto ; gh pr merge 12` | `none` | deny PR_UNRESOLVED | agree |  |
| ML | `gh pr merge --disable-auto && \<NL>gh api -X PUT repos/o/r/pulls/12/merge` | `gh pr merge --disable-auto ; gh api -X PUT repos/o/r/pulls/12/merge` | `none` | deny PR_UNRESOLVED | agree |  |
| ML | `gh pr merge --disable-auto \|<NL>gh pr merge 12` | `gh pr merge --disable-auto ; gh pr merge 12` | `none` | deny PR_UNRESOLVED | agree |  |
| ML | `gh pr merge --disable-auto \|<NL>gh api -X PUT repos/o/r/pulls/12/merge` | `gh pr merge --disable-auto ; gh api -X PUT repos/o/r/pulls/12/merge` | `none` | deny PR_UNRESOLVED | agree |  |
| ML | `ls<NL>gh pr merge 12` | `gh pr merge 12` | `none` | deny PR_UNRESOLVED | agree |  |
| ML | `ls<NL>gh api -X PUT repos/o/r/pulls/12/merge` | `gh api -X PUT repos/o/r/pulls/12/merge` | `none` | deny PR_UNRESOLVED | agree |  |
| ML | `ls # x<NL>gh pr merge 12` | `gh pr merge 12` | `none` | deny PR_UNRESOLVED | agree |  |
| ML | `ls # x<NL>gh api -X PUT repos/o/r/pulls/12/merge` | `gh api -X PUT repos/o/r/pulls/12/merge` | `none` | deny PR_UNRESOLVED | agree |  |
| ML | `ls # x\<NL>gh pr merge 12` | `gh pr merge 12` | `none` | deny PR_UNRESOLVED | agree |  |
| ML | `ls # x\<NL>gh api -X PUT repos/o/r/pulls/12/merge` | `gh api -X PUT repos/o/r/pulls/12/merge` | `none` | deny PR_UNRESOLVED | agree |  |
| ML | `ls # x \<NL>gh pr merge 12` | `gh pr merge 12` | `none` | deny PR_UNRESOLVED | agree |  |
| ML | `ls # x \<NL>gh api -X PUT repos/o/r/pulls/12/merge` | `gh api -X PUT repos/o/r/pulls/12/merge` | `none` | deny PR_UNRESOLVED | agree |  |
| ML | `ls \<NL>gh pr merge 12` | `none` | `none` | deny PR_UNRESOLVED | agree, false deny |  |
| ML | `ls \<NL>gh api -X PUT repos/o/r/pulls/12/merge` | `none` | `none` | deny PR_UNRESOLVED | agree, false deny |  |
| ML | `ls\<NL>gh pr merge 12` | `none` | `none` | deny PR_UNRESOLVED | agree, false deny |  |
| ML | `ls\<NL>gh api -X PUT repos/o/r/pulls/12/merge` | `none` | `none` | deny PR_UNRESOLVED | agree, false deny |  |
| ML | `ls\<CR><NL>gh pr merge 12` | `none` | `none` | deny PR_UNRESOLVED | agree, false deny |  |
| ML | `ls\<CR><NL>gh api -X PUT repos/o/r/pulls/12/merge` | `none` | `none` | deny PR_UNRESOLVED | agree, false deny |  |
| ML | `ls;<NL>gh pr merge 12` | `gh pr merge 12` | `none` | deny PR_UNRESOLVED | agree |  |
| ML | `ls;<NL>gh api -X PUT repos/o/r/pulls/12/merge` | `gh api -X PUT repos/o/r/pulls/12/merge` | `none` | deny PR_UNRESOLVED | agree |  |
| ML | `ls &&<NL>gh pr merge 12` | `gh pr merge 12` | `none` | deny PR_UNRESOLVED | agree |  |
| ML | `ls &&<NL>gh api -X PUT repos/o/r/pulls/12/merge` | `gh api -X PUT repos/o/r/pulls/12/merge` | `none` | deny PR_UNRESOLVED | agree |  |
| ML | `ls && \<NL>gh pr merge 12` | `gh pr merge 12` | `none` | deny PR_UNRESOLVED | agree |  |
| ML | `ls && \<NL>gh api -X PUT repos/o/r/pulls/12/merge` | `gh api -X PUT repos/o/r/pulls/12/merge` | `none` | deny PR_UNRESOLVED | agree |  |
| ML | `ls \|<NL>gh pr merge 12` | `gh pr merge 12` | `none` | deny PR_UNRESOLVED | agree |  |
| ML | `ls \|<NL>gh api -X PUT repos/o/r/pulls/12/merge` | `gh api -X PUT repos/o/r/pulls/12/merge` | `none` | deny PR_UNRESOLVED | agree |  |
| ML | `true<NL>gh pr merge 12` | `gh pr merge 12` | `none` | deny PR_UNRESOLVED | agree |  |
| ML | `true<NL>gh api -X PUT repos/o/r/pulls/12/merge` | `gh api -X PUT repos/o/r/pulls/12/merge` | `none` | deny PR_UNRESOLVED | agree |  |
| ML | `true # x<NL>gh pr merge 12` | `gh pr merge 12` | `none` | deny PR_UNRESOLVED | agree |  |
| ML | `true # x<NL>gh api -X PUT repos/o/r/pulls/12/merge` | `gh api -X PUT repos/o/r/pulls/12/merge` | `none` | deny PR_UNRESOLVED | agree |  |
| ML | `true # x\<NL>gh pr merge 12` | `gh pr merge 12` | `none` | deny PR_UNRESOLVED | agree |  |
| ML | `true # x\<NL>gh api -X PUT repos/o/r/pulls/12/merge` | `gh api -X PUT repos/o/r/pulls/12/merge` | `none` | deny PR_UNRESOLVED | agree |  |
| ML | `true # x \<NL>gh pr merge 12` | `gh pr merge 12` | `none` | deny PR_UNRESOLVED | agree |  |
| ML | `true # x \<NL>gh api -X PUT repos/o/r/pulls/12/merge` | `gh api -X PUT repos/o/r/pulls/12/merge` | `none` | deny PR_UNRESOLVED | agree |  |
| ML | `true \<NL>gh pr merge 12` | `none` | `none` | deny PR_UNRESOLVED | agree, false deny |  |
| ML | `true \<NL>gh api -X PUT repos/o/r/pulls/12/merge` | `none` | `none` | deny PR_UNRESOLVED | agree, false deny |  |
| ML | `true\<NL>gh pr merge 12` | `none` | `none` | deny PR_UNRESOLVED | agree, false deny |  |
| ML | `true\<NL>gh api -X PUT repos/o/r/pulls/12/merge` | `none` | `none` | deny PR_UNRESOLVED | agree, false deny |  |
| ML | `true\<CR><NL>gh pr merge 12` | `none` | `none` | deny PR_UNRESOLVED | agree, false deny |  |
| ML | `true\<CR><NL>gh api -X PUT repos/o/r/pulls/12/merge` | `none` | `none` | deny PR_UNRESOLVED | agree, false deny |  |
| ML | `true;<NL>gh pr merge 12` | `gh pr merge 12` | `none` | deny PR_UNRESOLVED | agree |  |
| ML | `true;<NL>gh api -X PUT repos/o/r/pulls/12/merge` | `gh api -X PUT repos/o/r/pulls/12/merge` | `none` | deny PR_UNRESOLVED | agree |  |
| ML | `true &&<NL>gh pr merge 12` | `gh pr merge 12` | `none` | deny PR_UNRESOLVED | agree |  |
| ML | `true &&<NL>gh api -X PUT repos/o/r/pulls/12/merge` | `gh api -X PUT repos/o/r/pulls/12/merge` | `none` | deny PR_UNRESOLVED | agree |  |
| ML | `true && \<NL>gh pr merge 12` | `gh pr merge 12` | `none` | deny PR_UNRESOLVED | agree |  |
| ML | `true && \<NL>gh api -X PUT repos/o/r/pulls/12/merge` | `gh api -X PUT repos/o/r/pulls/12/merge` | `none` | deny PR_UNRESOLVED | agree |  |
| ML | `true \|<NL>gh pr merge 12` | `gh pr merge 12` | `none` | deny PR_UNRESOLVED | agree |  |
| ML | `true \|<NL>gh api -X PUT repos/o/r/pulls/12/merge` | `gh api -X PUT repos/o/r/pulls/12/merge` | `none` | deny PR_UNRESOLVED | agree |  |
| POS | `g\<NL>h pr merge 12` | `gh pr merge 12` | `none` | deny PR_UNRESOLVED | agree |  |
| POS | `g\h pr merge 12` | `gh pr merge 12` | `none` | deny PR_UNRESOLVED | agree |  |
| POS | `g''h pr merge 12` | `gh pr merge 12` | `pr view 12` | deny RECEIPT_ABSENT | agree |  |
| POS | `g""h pr merge 12` | `gh pr merge 12` | `pr view 12` | deny RECEIPT_ABSENT | agree |  |
| POS | `gh\<NL> pr merge 12` | `gh pr merge 12` | `pr view 12` | deny RECEIPT_ABSENT | agree |  |
| POS | `gh\ pr merge 12` | `none` | `none` | deny PR_UNRESOLVED | agree, false deny |  |
| POS | `gh'' pr merge 12` | `gh pr merge 12` | `pr view 12` | deny RECEIPT_ABSENT | agree |  |
| POS | `gh"" pr merge 12` | `gh pr merge 12` | `pr view 12` | deny RECEIPT_ABSENT | agree |  |
| POS | `gh \<NL>pr merge 12` | `gh pr merge 12` | `pr view 12` | deny RECEIPT_ABSENT | agree |  |
| POS | `gh \pr merge 12` | `gh pr merge 12` | `none` | deny PR_UNRESOLVED | agree |  |
| POS | `gh ''pr merge 12` | `gh pr merge 12` | `pr view 12` | deny RECEIPT_ABSENT | agree |  |
| POS | `gh ""pr merge 12` | `gh pr merge 12` | `pr view 12` | deny RECEIPT_ABSENT | agree |  |
| POS | `gh p\<NL>r merge 12` | `gh pr merge 12` | `none` | deny PR_UNRESOLVED | agree |  |
| POS | `gh p\r merge 12` | `gh pr merge 12` | `none` | deny PR_UNRESOLVED | agree |  |
| POS | `gh p''r merge 12` | `gh pr merge 12` | `pr view 12` | deny RECEIPT_ABSENT | agree |  |
| POS | `gh p""r merge 12` | `gh pr merge 12` | `pr view 12` | deny RECEIPT_ABSENT | agree |  |
| POS | `gh pr\<NL> merge 12` | `gh pr merge 12` | `pr view 12` | deny RECEIPT_ABSENT | agree |  |
| POS | `gh pr\ merge 12` | `gh pr merge 12` | `none` | deny PR_UNRESOLVED | agree, false deny |  |
| POS | `gh pr'' merge 12` | `gh pr merge 12` | `pr view 12` | deny RECEIPT_ABSENT | agree |  |
| POS | `gh pr"" merge 12` | `gh pr merge 12` | `pr view 12` | deny RECEIPT_ABSENT | agree |  |
| POS | `gh pr \<NL>merge 12` | `gh pr merge 12` | `pr view 12` | deny RECEIPT_ABSENT | agree |  |
| POS | `gh pr \merge 12` | `gh pr merge 12` | `none` | deny PR_UNRESOLVED | agree |  |
| POS | `gh pr ''merge 12` | `gh pr merge 12` | `pr view 12` | deny RECEIPT_ABSENT | agree |  |
| POS | `gh pr ""merge 12` | `gh pr merge 12` | `pr view 12` | deny RECEIPT_ABSENT | agree |  |
| POS | `gh pr m\<NL>erge 12` | `gh pr merge 12` | `none` | deny PR_UNRESOLVED | agree |  |
| POS | `gh pr m\erge 12` | `gh pr merge 12` | `none` | deny PR_UNRESOLVED | agree |  |
| POS | `gh pr m''erge 12` | `gh pr merge 12` | `pr view 12` | deny RECEIPT_ABSENT | agree |  |
| POS | `gh pr m""erge 12` | `gh pr merge 12` | `pr view 12` | deny RECEIPT_ABSENT | agree |  |
| POS | `gh pr me\<NL>rge 12` | `gh pr merge 12` | `none` | deny PR_UNRESOLVED | agree |  |
| POS | `gh pr me\rge 12` | `gh pr merge 12` | `none` | deny PR_UNRESOLVED | agree |  |
| POS | `gh pr me''rge 12` | `gh pr merge 12` | `pr view 12` | deny RECEIPT_ABSENT | agree |  |
| POS | `gh pr me""rge 12` | `gh pr merge 12` | `pr view 12` | deny RECEIPT_ABSENT | agree |  |
| POS | `gh pr mer\<NL>ge 12` | `gh pr merge 12` | `none` | deny PR_UNRESOLVED | agree |  |
| POS | `gh pr mer\ge 12` | `gh pr merge 12` | `none` | deny PR_UNRESOLVED | agree |  |
| POS | `gh pr mer''ge 12` | `gh pr merge 12` | `pr view 12` | deny RECEIPT_ABSENT | agree |  |
| POS | `gh pr mer""ge 12` | `gh pr merge 12` | `pr view 12` | deny RECEIPT_ABSENT | agree |  |
| POS | `gh pr merg\<NL>e 12` | `gh pr merge 12` | `none` | deny PR_UNRESOLVED | agree |  |
| POS | `gh pr merg\e 12` | `gh pr merge 12` | `none` | deny PR_UNRESOLVED | agree |  |
| POS | `gh pr merg''e 12` | `gh pr merge 12` | `pr view 12` | deny RECEIPT_ABSENT | agree |  |
| POS | `gh pr merg""e 12` | `gh pr merge 12` | `pr view 12` | deny RECEIPT_ABSENT | agree |  |
| POS | `gh pr merge\<NL> 12` | `gh pr merge 12` | `pr view 12` | deny RECEIPT_ABSENT | agree |  |
| POS | `gh pr merge\ 12` | `gh pr merge 12` | `none` | deny PR_UNRESOLVED | agree, false deny |  |
| POS | `gh pr merge'' 12` | `gh pr merge 12` | `pr view 12` | deny RECEIPT_ABSENT | agree |  |
| POS | `gh pr merge"" 12` | `gh pr merge 12` | `pr view 12` | deny RECEIPT_ABSENT | agree |  |
| POS | `gh pr merge \<NL>12` | `gh pr merge 12` | `pr view 12` | deny RECEIPT_ABSENT | agree |  |
| POS | `gh pr merge \12` | `gh pr merge 12` | `none` | deny PR_UNRESOLVED | agree |  |
| POS | `gh pr merge ''12` | `gh pr merge 12` | `pr view 12` | deny RECEIPT_ABSENT | agree |  |
| POS | `gh pr merge ""12` | `gh pr merge 12` | `pr view 12` | deny RECEIPT_ABSENT | agree |  |
| POS | `gh pr merge 1\<NL>2` | `gh pr merge 12` | `none` | deny PR_UNRESOLVED | agree |  |
| POS | `gh pr merge 1\2` | `gh pr merge 12` | `none` | deny PR_UNRESOLVED | agree |  |
| POS | `gh pr merge 1''2` | `gh pr merge 12` | `pr view 12` | deny RECEIPT_ABSENT | agree |  |
| POS | `gh pr merge 1""2` | `gh pr merge 12` | `pr view 12` | deny RECEIPT_ABSENT | agree |  |
| POS | `gh pr merge 12\<NL>` | `gh pr merge 12` | `pr view 12` | deny RECEIPT_ABSENT | agree |  |
| POS | `gh pr merge 12\` | `gh pr merge 12\` | `none` | deny PR_UNRESOLVED | agree |  |
| POS | `gh pr merge 12''` | `gh pr merge 12` | `pr view 12` | deny RECEIPT_ABSENT | agree |  |
| POS | `gh pr merge 12""` | `gh pr merge 12` | `pr view 12` | deny RECEIPT_ABSENT | agree |  |
| PL | `sh -c 'gh pr merge 12'` | `gh pr merge 12` | `none` | deny PR_UNRESOLVED | agree |  |
| PL | `bash -c "gh pr merge 12"` | `gh pr merge 12` | `none` | deny PR_UNRESOLVED | agree |  |
| PL | `eval 'gh pr merge 12'` | `gh pr merge 12` | `none` | deny PR_UNRESOLVED | agree |  |
| PL | `eval "gh pr merge 12"` | `gh pr merge 12` | `none` | deny PR_UNRESOLVED | agree |  |
| PL | `if true; then sh -c 'gh pr merge 12'; fi` | `gh pr merge 12` | `none` | deny PR_UNRESOLVED | agree |  |
| PL | `! sh -c 'gh pr merge 12'` | `gh pr merge 12` | `none` | deny PR_UNRESOLVED | agree |  |
| PL | `exec sh -c 'gh pr merge 12'` | `gh pr merge 12` | `none` | deny PR_UNRESOLVED | agree |  |
| PL | `nice sh -c 'gh pr merge 12'` | `gh pr merge 12` | `none` | deny PR_UNRESOLVED | agree |  |
| PL | `for i in 1; do bash -c 'gh pr merge 12'; done` | `gh pr merge 12` | `none` | deny PR_UNRESOLVED | agree |  |
| PL | `while true; do sh -c 'gh pr merge 12'; break; done` | `gh pr merge 12` | `none` | deny PR_UNRESOLVED | agree |  |
| PL | `case x in x) sh -c 'gh pr merge 12';; esac` | `gh pr merge 12` | `none` | deny PR_UNRESOLVED | agree |  |
| PL | `f() { sh -c 'gh pr merge 12'; }; f` | `gh pr merge 12` | `none` | deny PR_UNRESOLVED | agree |  |
| PL | `( sh -c 'gh pr merge 12' )` | `gh pr merge 12` | `none` | deny PR_UNRESOLVED | agree |  |
| PL | `{ sh -c 'gh pr merge 12'; }` | `gh pr merge 12` | `none` | deny PR_UNRESOLVED | agree |  |
| PL | `echo 'gh pr merge 12' \| sh` | `gh pr merge 12` | `none` | deny PR_UNRESOLVED | agree |  |
| PL | `printf 'gh pr merge 12' \| bash` | `gh pr merge 12` | `none` | deny PR_UNRESOLVED | agree |  |
| PL | `sh <<< 'gh pr merge 12'` | `gh pr merge 12` | `none` | deny PR_UNRESOLVED | agree |  |
| PL | `bash <(echo 'gh pr merge 12')` | `gh pr merge 12` | `none` | deny PR_UNRESOLVED | agree |  |
| PL | `source <(echo 'gh pr merge 12')` | `gh pr merge 12` | `none` | deny PR_UNRESOLVED | agree |  |
| PL | `eval "$(echo 'gh pr merge 12')"` | `gh pr merge 12` | `none` | deny PR_UNRESOLVED | agree |  |
| PL | `$(echo 'gh pr merge 12')` | `gh pr merge 12` | `none` | allow | escape | Class: computed command words |
| PL | `trap 'gh pr merge 12' EXIT` | `gh pr merge 12` | `none` | allow | escape | Class: evaluators outside the named words |
| PL | `cat <<EOF \| sh<NL>gh pr merge 12<NL>EOF` | `gh pr merge 12` | `none` | deny PR_UNRESOLVED | agree |  |
| PL | `if true; then bash <<EOF<NL>gh pr merge 12<NL>EOF<NL>fi` | `gh pr merge 12` | `none` | deny PR_UNRESOLVED | agree |  |
| PL | `sh -c 'echo first<NL>gh pr merge 12'` | `gh pr merge 12` | `none` | deny PR_UNRESOLVED | agree |  |
| PL | `python -c "import os; os.system('gh pr merge 12')"` | `gh pr merge 12` | `none` | allow | escape | Class: python -c |
| PL | `node -e "require('child_process').execSync('gh pr merge 12')"` | `gh pr merge 12` | `none` | allow | escape | Class: node -e |
| PL | `sh -c 'gh pr merge 12 --merge'` | `gh pr merge 12 --merge` | `none` | deny PR_UNRESOLVED | agree |  |
| PL | `bash -c "gh pr merge 12 --merge"` | `gh pr merge 12 --merge` | `none` | deny PR_UNRESOLVED | agree |  |
| PL | `eval 'gh pr merge 12 --merge'` | `gh pr merge 12 --merge` | `none` | deny PR_UNRESOLVED | agree |  |
| PL | `eval "gh pr merge 12 --merge"` | `gh pr merge 12 --merge` | `none` | deny PR_UNRESOLVED | agree |  |
| PL | `if true; then sh -c 'gh pr merge 12 --merge'; fi` | `gh pr merge 12 --merge` | `none` | deny PR_UNRESOLVED | agree |  |
| PL | `! sh -c 'gh pr merge 12 --merge'` | `gh pr merge 12 --merge` | `none` | deny PR_UNRESOLVED | agree |  |
| PL | `exec sh -c 'gh pr merge 12 --merge'` | `gh pr merge 12 --merge` | `none` | deny PR_UNRESOLVED | agree |  |
| PL | `nice sh -c 'gh pr merge 12 --merge'` | `gh pr merge 12 --merge` | `none` | deny PR_UNRESOLVED | agree |  |
| PL | `for i in 1; do bash -c 'gh pr merge 12 --merge'; done` | `gh pr merge 12 --merge` | `none` | deny PR_UNRESOLVED | agree |  |
| PL | `while true; do sh -c 'gh pr merge 12 --merge'; break; done` | `gh pr merge 12 --merge` | `none` | deny PR_UNRESOLVED | agree |  |
| PL | `case x in x) sh -c 'gh pr merge 12 --merge';; esac` | `gh pr merge 12 --merge` | `none` | deny PR_UNRESOLVED | agree |  |
| PL | `f() { sh -c 'gh pr merge 12 --merge'; }; f` | `gh pr merge 12 --merge` | `none` | deny PR_UNRESOLVED | agree |  |
| PL | `( sh -c 'gh pr merge 12 --merge' )` | `gh pr merge 12 --merge` | `none` | deny PR_UNRESOLVED | agree |  |
| PL | `{ sh -c 'gh pr merge 12 --merge'; }` | `gh pr merge 12 --merge` | `none` | deny PR_UNRESOLVED | agree |  |
| PL | `echo 'gh pr merge 12 --merge' \| sh` | `gh pr merge 12 --merge` | `none` | deny PR_UNRESOLVED | agree |  |
| PL | `printf 'gh pr merge 12 --merge' \| bash` | `gh pr merge 12 --merge` | `none` | deny PR_UNRESOLVED | agree |  |
| PL | `sh <<< 'gh pr merge 12 --merge'` | `gh pr merge 12 --merge` | `none` | deny PR_UNRESOLVED | agree |  |
| PL | `bash <(echo 'gh pr merge 12 --merge')` | `gh pr merge 12 --merge` | `none` | deny PR_UNRESOLVED | agree |  |
| PL | `source <(echo 'gh pr merge 12 --merge')` | `gh pr merge 12 --merge` | `none` | deny PR_UNRESOLVED | agree |  |
| PL | `eval "$(echo 'gh pr merge 12 --merge')"` | `gh pr merge 12 --merge` | `none` | deny PR_UNRESOLVED | agree |  |
| PL | `$(echo 'gh pr merge 12 --merge')` | `gh pr merge 12 --merge` | `none` | allow | escape | Class: computed command words |
| PL | `trap 'gh pr merge 12 --merge' EXIT` | `gh pr merge 12 --merge` | `none` | allow | escape | Class: evaluators outside the named words |
| PL | `cat <<EOF \| sh<NL>gh pr merge 12 --merge<NL>EOF` | `gh pr merge 12 --merge` | `none` | deny PR_UNRESOLVED | agree |  |
| PL | `if true; then bash <<EOF<NL>gh pr merge 12 --merge<NL>EOF<NL>fi` | `gh pr merge 12 --merge` | `none` | deny PR_UNRESOLVED | agree |  |
| PL | `sh -c 'echo first<NL>gh pr merge 12 --merge'` | `gh pr merge 12 --merge` | `none` | deny PR_UNRESOLVED | agree |  |
| PL | `python -c "import os; os.system('gh pr merge 12 --merge')"` | `gh pr merge 12 --merge` | `none` | allow | escape | Class: python -c |
| PL | `node -e "require('child_process').execSync('gh pr merge 12 --merge')"` | `gh pr merge 12 --merge` | `none` | allow | escape | Class: node -e |
| PL | `sh -c 'gh api -X PUT repos/o/r/pulls/12/merge'` | `gh api -X PUT repos/o/r/pulls/12/merge` | `none` | deny PR_UNRESOLVED | agree |  |
| PL | `bash -c "gh api -X PUT repos/o/r/pulls/12/merge"` | `gh api -X PUT repos/o/r/pulls/12/merge` | `none` | deny PR_UNRESOLVED | agree |  |
| PL | `eval 'gh api -X PUT repos/o/r/pulls/12/merge'` | `gh api -X PUT repos/o/r/pulls/12/merge` | `none` | deny PR_UNRESOLVED | agree |  |
| PL | `eval "gh api -X PUT repos/o/r/pulls/12/merge"` | `gh api -X PUT repos/o/r/pulls/12/merge` | `none` | deny PR_UNRESOLVED | agree |  |
| PL | `if true; then sh -c 'gh api -X PUT repos/o/r/pulls/12/merge'; fi` | `gh api -X PUT repos/o/r/pulls/12/merge` | `none` | deny PR_UNRESOLVED | agree |  |
| PL | `! sh -c 'gh api -X PUT repos/o/r/pulls/12/merge'` | `gh api -X PUT repos/o/r/pulls/12/merge` | `none` | deny PR_UNRESOLVED | agree |  |
| PL | `exec sh -c 'gh api -X PUT repos/o/r/pulls/12/merge'` | `gh api -X PUT repos/o/r/pulls/12/merge` | `none` | deny PR_UNRESOLVED | agree |  |
| PL | `nice sh -c 'gh api -X PUT repos/o/r/pulls/12/merge'` | `gh api -X PUT repos/o/r/pulls/12/merge` | `none` | deny PR_UNRESOLVED | agree |  |
| PL | `for i in 1; do bash -c 'gh api -X PUT repos/o/r/pulls/12/merge'; done` | `gh api -X PUT repos/o/r/pulls/12/merge` | `none` | deny PR_UNRESOLVED | agree |  |
| PL | `while true; do sh -c 'gh api -X PUT repos/o/r/pulls/12/merge'; break; done` | `gh api -X PUT repos/o/r/pulls/12/merge` | `none` | deny PR_UNRESOLVED | agree |  |
| PL | `case x in x) sh -c 'gh api -X PUT repos/o/r/pulls/12/merge';; esac` | `gh api -X PUT repos/o/r/pulls/12/merge` | `none` | deny PR_UNRESOLVED | agree |  |
| PL | `f() { sh -c 'gh api -X PUT repos/o/r/pulls/12/merge'; }; f` | `gh api -X PUT repos/o/r/pulls/12/merge` | `none` | deny PR_UNRESOLVED | agree |  |
| PL | `( sh -c 'gh api -X PUT repos/o/r/pulls/12/merge' )` | `gh api -X PUT repos/o/r/pulls/12/merge` | `none` | deny PR_UNRESOLVED | agree |  |
| PL | `{ sh -c 'gh api -X PUT repos/o/r/pulls/12/merge'; }` | `gh api -X PUT repos/o/r/pulls/12/merge` | `none` | deny PR_UNRESOLVED | agree |  |
| PL | `echo 'gh api -X PUT repos/o/r/pulls/12/merge' \| sh` | `gh api -X PUT repos/o/r/pulls/12/merge` | `none` | deny PR_UNRESOLVED | agree |  |
| PL | `printf 'gh api -X PUT repos/o/r/pulls/12/merge' \| bash` | `gh api -X PUT repos/o/r/pulls/12/merge` | `none` | deny PR_UNRESOLVED | agree |  |
| PL | `sh <<< 'gh api -X PUT repos/o/r/pulls/12/merge'` | `gh api -X PUT repos/o/r/pulls/12/merge` | `none` | deny PR_UNRESOLVED | agree |  |
| PL | `bash <(echo 'gh api -X PUT repos/o/r/pulls/12/merge')` | `gh api -X PUT repos/o/r/pulls/12/merge` | `none` | deny PR_UNRESOLVED | agree |  |
| PL | `source <(echo 'gh api -X PUT repos/o/r/pulls/12/merge')` | `gh api -X PUT repos/o/r/pulls/12/merge` | `none` | deny PR_UNRESOLVED | agree |  |
| PL | `eval "$(echo 'gh api -X PUT repos/o/r/pulls/12/merge')"` | `gh api -X PUT repos/o/r/pulls/12/merge` | `none` | deny PR_UNRESOLVED | agree |  |
| PL | `$(echo 'gh api -X PUT repos/o/r/pulls/12/merge')` | `gh api -X PUT repos/o/r/pulls/12/merge` | `none` | allow | escape | Class: computed command words |
| PL | `trap 'gh api -X PUT repos/o/r/pulls/12/merge' EXIT` | `gh api -X PUT repos/o/r/pulls/12/merge` | `none` | allow | escape | Class: evaluators outside the named words |
| PL | `cat <<EOF \| sh<NL>gh api -X PUT repos/o/r/pulls/12/merge<NL>EOF` | `gh api -X PUT repos/o/r/pulls/12/merge` | `none` | deny PR_UNRESOLVED | agree |  |
| PL | `if true; then bash <<EOF<NL>gh api -X PUT repos/o/r/pulls/12/merge<NL>EOF<NL>fi` | `gh api -X PUT repos/o/r/pulls/12/merge` | `none` | deny PR_UNRESOLVED | agree |  |
| PL | `sh -c 'echo first<NL>gh api -X PUT repos/o/r/pulls/12/merge'` | `gh api -X PUT repos/o/r/pulls/12/merge` | `none` | deny PR_UNRESOLVED | agree |  |
| PL | `python -c "import os; os.system('gh api -X PUT repos/o/r/pulls/12/merge')"` | `gh api -X PUT repos/o/r/pulls/12/merge` | `none` | allow | escape | Class: python -c |
| PL | `node -e "require('child_process').execSync('gh api -X PUT repos/o/r/pulls/12/merge')"` | `gh api -X PUT repos/o/r/pulls/12/merge` | `none` | allow | escape | Class: node -e |
| FILE | `sh merge.sh` | `gh pr merge 12` | `none` | allow | escape | Class: scripts on disk |
| FILE | `. ./merge.sh` | `gh pr merge 12` | `none` | allow | escape | Class: scripts on disk |
| FILE | `source merge.sh` | `gh pr merge 12` | `none` | allow | escape | Class: scripts on disk |
| FILE | `./merge.sh` | `gh pr merge 12` | `none` | allow | escape | Class: scripts on disk |
