# Bash-Exact Comparison at Head - Issue 1034 Remediation Cycle 2 (P1-T3)

Timestamp: 2026-11-07T03-34
Command: sh SCRATCH/issue-1034-c2-bx.sh Before (real bash runs each command in SCRATCH/bash-exact/work with standard input from /dev/null and a stand-in gh first on PATH; a SCRATCH driver dot-sources the hook of the consumer copy under SCRATCH/bash-exact/consumer, which holds an enabled profile and no receipt, and replaces only Invoke-DocsOnlyGhExe)
EXIT_CODE: 1
ExpectedExitCode: 1
Output Summary: Expected failure. 19 commands, 8 disagree: the eight commands the task names and no others. The stand-in gh records each argument on its own line, so a command that redirects its standard output is still observed. A row agrees when the hook looks up the selector and repository that bash passed, or denies PR_UNRESOLVED with no lookup. The step script exits 1 only when the disagreeing set equals the named set and 255 otherwise. This is evidence, not a test: nothing under tests/ uses the stand-in.

| Command | Bash passed to gh | Hook lookup | Decision | Result |
|---|---|---|---|---|
| `gh pr merge 2>&1 12` | `pr merge 12` | `pr view` | allow | DISAGREE |
| `gh pr merge --merge 2>&1 epic/x-integration` | `pr merge --merge epic/x-integration` | `pr view` | allow | DISAGREE |
| `gh pr merge >log 2>&1 12` | `pr merge 12` | `pr view` | allow | DISAGREE |
| `gh pr merge &>log 12` | `pr merge 12` | `pr view` | allow | DISAGREE |
| `gh pr merge {12..12}` | `pr merge 12` | `pr view` | allow | DISAGREE |
| `gh pr merge >&2 12` | `pr merge 12` | `pr view` | allow | DISAGREE |
| `gh pr merge 1{2..2}` | `pr merge 12` | `pr view 1` | allow | DISAGREE |
| `gh pr merge 2>/dev/null 12` | `pr merge 12` | `pr view 12` | RECEIPT_ABSENT | agree |
| `gh pr merge > 99 12` | `pr merge 12` | `pr view 12` | RECEIPT_ABSENT | agree |
| `gh pr merge --merge` | `pr merge --merge` | `pr view` | allow | agree |
| `gh pr merge #99` | `pr merge` | `pr view #99` | allow | DISAGREE |
| `gh pr merge 12 --merge 2>&1` | `pr merge 12 --merge` | `pr view 12` | RECEIPT_ABSENT | agree |
| `gh pr merge 12 >/dev/null 2>&1` | `pr merge 12` | `pr view 12` | RECEIPT_ABSENT | agree |
| `gh pr merge --squash 2>&1` | `pr merge --squash` | `pr view` | allow | agree |
| `gh pr merge 12>x` | `pr merge` | `pr view` | allow | agree |
| `gh pr merge "#12"` | `pr merge #12` | `pr view #12` | RECEIPT_ABSENT | agree |
| `gh pr merge 12 #99` | `pr merge 12` | `none` | PR_UNRESOLVED | agree |
| `gh pr merge --subject 'a b' 12` | `pr merge --subject a b 12` | `pr view 12` | RECEIPT_ABSENT | agree |
| `gh --repo o/r pr merge 12` | `--repo o/r pr merge 12` | `pr view 12 --repo o/r` | PR_UNRESOLVED | agree |
