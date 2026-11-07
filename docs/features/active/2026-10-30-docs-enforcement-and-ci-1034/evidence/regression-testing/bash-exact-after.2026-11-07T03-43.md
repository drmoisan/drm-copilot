# Bash-Exact Comparison After the Fix - Issue 1034 Remediation Cycle 2 (P2-T5)

Timestamp: 2026-11-07T03-43
Command: sh SCRATCH/issue-1034-c2-bx.sh After (the P1-T3 comparison against a refreshed consumer copy under SCRATCH/bash-exact/consumer holding the corrected hook and helper; the command set is the P1-T3 set extended with every Group A, B and C row outside the integration-checkout stand-in)
EXIT_CODE: 0
Output Summary: PASS. 40 commands, 0 disagree. Each command either looks up the selector and repository that bash passed to gh, or denies PR_UNRESOLVED with no lookup, except the three no-merge controls of Group C, which allow with no lookup as the P1-T3 definition permits. env --chdir=../other shows no gh arguments because the directory does not exist in the scratch working directory, so env exits before running gh; the hook denies that command with no lookup.

| Command | Bash passed to gh | Hook lookup | Decision | Result |
|---|---|---|---|---|
| `gh pr merge 2>&1 12` | `pr merge 12` | `none` | PR_UNRESOLVED | agree |
| `gh pr merge --merge 2>&1 epic/x-integration` | `pr merge --merge epic/x-integration` | `none` | PR_UNRESOLVED | agree |
| `gh pr merge >log 2>&1 12` | `pr merge 12` | `none` | PR_UNRESOLVED | agree |
| `gh pr merge &>log 12` | `pr merge 12` | `none` | PR_UNRESOLVED | agree |
| `gh pr merge {12..12}` | `pr merge 12` | `none` | PR_UNRESOLVED | agree |
| `gh pr merge >&2 12` | `pr merge 12` | `none` | PR_UNRESOLVED | agree |
| `gh pr merge 1{2..2}` | `pr merge 12` | `none` | PR_UNRESOLVED | agree |
| `gh pr merge 2>/dev/null 12` | `pr merge 12` | `none` | PR_UNRESOLVED | agree |
| `gh pr merge > 99 12` | `pr merge 12` | `none` | PR_UNRESOLVED | agree |
| `gh pr merge --merge` | `pr merge --merge` | `pr view` | allow | agree |
| `gh pr merge #99` | `pr merge` | `pr view` | allow | agree |
| `gh pr merge 12 --merge 2>&1` | `pr merge 12 --merge` | `pr view 12` | RECEIPT_ABSENT | agree |
| `gh pr merge 12 >/dev/null 2>&1` | `pr merge 12` | `pr view 12` | RECEIPT_ABSENT | agree |
| `gh pr merge --squash 2>&1` | `pr merge --squash` | `pr view` | allow | agree |
| `gh pr merge 12>x` | `pr merge` | `pr view` | allow | agree |
| `gh pr merge "#12"` | `pr merge #12` | `pr view #12` | RECEIPT_ABSENT | agree |
| `gh pr merge 12 #99` | `pr merge 12` | `pr view 12` | RECEIPT_ABSENT | agree |
| `gh pr merge --subject 'a b' 12` | `pr merge --subject a b 12` | `pr view 12` | RECEIPT_ABSENT | agree |
| `gh --repo o/r pr merge 12` | `--repo o/r pr merge 12` | `pr view 12 --repo o/r` | PR_UNRESOLVED | agree |
| `gh pr merge 12 &` | `pr merge 12` | `none` | PR_UNRESOLVED | agree |
| `gh pr merge 12;` | `pr merge 12` | `none` | PR_UNRESOLVED | agree |
| `env --chdir=../other gh pr merge 12` | `none` | `none` | PR_UNRESOLVED | agree |
| `builtin cd ../other; gh pr merge 12` | `pr merge 12` | `none` | PR_UNRESOLVED | agree |
| `GIT_DIR=../other gh pr merge 12` | `pr merge 12` | `none` | PR_UNRESOLVED | agree |
| `read GH_REPO; gh pr merge 12` | `pr merge 12` | `none` | PR_UNRESOLVED | agree |
| `export GH_REPO; gh pr merge 12` | `pr merge 12` | `none` | PR_UNRESOLVED | agree |
| `gh pr merge 12 # note; echo done` | `pr merge 12` | `pr view 12` | RECEIPT_ABSENT | agree |
| `gh pr merge 12 # --disable-auto` | `pr merge 12` | `pr view 12` | RECEIPT_ABSENT | agree |
| `gh pr merge 12 --subject --disable-auto` | `pr merge 12 --subject --disable-auto` | `pr view 12` | RECEIPT_ABSENT | agree |
| `gh pr merge 12 --disable-auto=false` | `pr merge 12 --disable-auto=false` | `pr view 12` | RECEIPT_ABSENT | agree |
| `gh pr merge 12 --disable-auto=true` | `pr merge 12 --disable-auto=true` | `pr view 12` | RECEIPT_ABSENT | agree |
| `gh pr merge 12 --disable-auto --disable-auto=false` | `pr merge 12 --disable-auto --disable-auto=false` | `pr view 12` | RECEIPT_ABSENT | agree |
| `gh pr merge --merge=1 12` | `pr merge --merge=1 12` | `pr view 12` | RECEIPT_ABSENT | agree |
| `gh pr merge "12"` | `pr merge 12` | `pr view 12` | RECEIPT_ABSENT | agree |
| `gh pr merge --subject 'a; b' 12` | `pr merge --subject a; b 12` | `pr view 12` | RECEIPT_ABSENT | agree |
| `gh pr merge 12 --disable-auto --auto=false` | `pr merge 12 --disable-auto --auto=false` | `pr view 12` | RECEIPT_ABSENT | agree |
| `gh pr merge 12 --disable-auto # note` | `pr merge 12 --disable-auto` | `none` | allow | agree |
| `gh pr view feature/merge` | `pr view feature/merge` | `none` | allow | agree |
| `gh --help pr merge` | `--help pr merge` | `none` | allow | agree |
| `gh pr merge 12 --unknown x` | `pr merge 12 --unknown x` | `none` | PR_UNRESOLVED | agree |
