# Prior-Run Corpus Coverage (amended AC-11, DC-23) ([P9-T2])

Timestamp: 2026-10-08T22-48
Command: git grep -n -E "\b(X5|X6|X9|Y4)\b" bug/promotion-hook-raw-containment-false-positive-deny-824 -- docs/features/active/2026-10-03-promotion-hook-raw-containment-false-positive-deny-824
EXIT_CODE: 0
Output Summary:
One match. The only occurrence of X5, X6, X9, or Y4 in the prior-run feature folder on the prior-run branch is a remediation-plan sentence stating that the base-versus-head probe for those four forms is not repeated. No line in that folder records the command text of X5, X6, X9, or Y4.
SearchScope: bug/promotion-hook-raw-containment-false-positive-deny-824:docs/features/active/2026-10-03-promotion-hook-raw-containment-false-positive-deny-824/
SearchPatterns: \b(X5|X6|X9|Y4)\b
SearchResult:

```
bug/promotion-hook-raw-containment-false-positive-deny-824:docs/features/active/2026-10-03-promotion-hook-raw-containment-false-positive-deny-824/remediation-plan.2026-10-03T13-56.md:102:  - The remediation-inputs base-versus-head probe for X5, X6, X9, and Y4 is not repeated; those forms are not in AC-14, and the fail-before (P1-T10) and pass-after (P7-T1) runs cover every AC-14 and AC-43 form named in spec v0.3.
```

Execution note: the command was issued as `git -C <WORKSPACE_ROOT> grep ...` because the Bash tool's working directory is reset between calls; the arguments are otherwise identical.

Conclusion: X5, X6, X9, and Y4 have no recorded command text in the searched source; the match is a reference to the IDs, not a command. No test row is derived for them (amended AC-11).

## Mapping of recorded corpus IDs to section-5 test rows

Row IDs were confirmed present in the test files by a search of `tests/scripts/claude-hooks` and `tests/scripts/codex-hooks` for each ID token. Pass state is checked at [P10-T30] against the [P10-T9] artifact.

| Corpus ID | Command (plan section 4) | Test rows |
|---|---|---|
| B1 | `bash -c 'cmd="issue create"; gh $cmd'` | PM-20 (claude, codex) |
| B2 | `pwsh -c '$a = "issue","create"; gh @a'` | PM-21 (claude, codex) |
| B3 | `bash -c 'args=(issue create); gh "${args[@]}"'` | PM-22 (claude, codex) |
| B4 | `bash -c "gh issue \` + line feed + `create"` | PM-23 (claude, codex) |
| B5 | `bash -c 'a="worktree remove"; git $a ../x'` | EW-36, PW-36, CW-36, OP-16 (claude, codex) |
| X1 | `bash -c 'echo P \| xargs git worktree remove'` | EW-29, PW-29, CW-29, OP-14 |
| X2 | `echo P \| xargs git worktree remove` | EW-30, PW-30, CW-30, OP-09, OP-14 |
| X3 | `pwsh -c 'git worktree remove (Join-Path /repo/worktrees item-a-101)'` | EW-31, PW-31, CW-31, OP-09, OP-14 |
| X4 | `bash -c 'git worktree remove >/dev/null P'` | EW-32, PW-32, CW-32, OP-09, OP-14 |
| X7 | `pwsh -c 'git worktree remove --force (Get-Item P)'` | EW-33, PW-33, CW-33, OP-14 |
| X8 | `bash -c 'printf "%s" P \| xargs git worktree remove --force'` | EW-34, PW-34, CW-34, OP-14 |
| X10 | `bash -c 'git worktree remove </dev/null P'` | EW-35, PW-35, CW-35, OP-14 |
| Y1 | `bash -c 'gh "$@"' _ issue create` | PM-24 (claude, codex), PY-06 |
| Y2 | `bash -c 'gh $*' _ issue create` | PM-25 (claude, codex) |
| Y3 | `bash -c 'echo issue create \| xargs gh'` | PM-26 (claude, codex) |
| Y5 | `bash -c 'gh $1 $2' _ issue create` | PM-27 (claude, codex) |
| W1 | `bash -c 'git worktree remove Q; git worktree remove >/dev/null P'` | EW-14, PW-14, CW-14, OP-15 |
| W2 | `bash -c 'git worktree remove Q; echo P \| xargs git worktree remove'` | EW-15, PW-15, CW-15, OP-15 |
| W3 | `pwsh -c 'git worktree remove Q; git worktree remove (Join-Path /repo/worktrees item-a-101)'` | EW-16, PW-16, CW-16, OP-15 |
| W4 | `bash -c 'git worktree remove Q && git worktree remove </dev/null P'` | EW-17, PW-17, CW-17, OP-15 |
| W5 | `bash -c "git worktree remove Q"; bash -c "git worktree remove P"` | EW-18, PW-18, CW-18, OP-15 |
| W6 | `bash -c "git worktree remove Q" && git worktree remove P` | EW-19, PW-19, CW-19, OP-15 |
| Fixture AC-4 | matcher true and false rows (plan section 4) | IV-14 (true rows), IV-15 (false rows) (claude, codex) |
| Fixture AC-5 | `R-824-MAIN` (promotion allow) | PM-01 (claude, codex), REG-01 (claude, codex) |
| Fixture AC-6 | `pwsh -NoProfile -Command 'Write-Output "through"; "issue"; New-Object Text.StringBuilder'` | PM-28 (claude, codex) |
| Fixture AC-18 | AC-4 `Select-String ... "high priority"` row (pr-author allow) | PA-05 |
| Fixture AC-19 | list command allowed; `bash -c "git worktree remove ../x"` denied | EW-37, PW-37, CW-37 (allow); EW-38, PW-38, CW-38 (deny) |
| Fixture AC-21 | `Test-ImplementationCommand` false for the `digit address` command; merge gates read `688` | CN-08 (claude, codex), CN-09 (claude, codex), OP-12 |

Every recorded corpus ID maps to at least one row ID defined in plan section 5.
