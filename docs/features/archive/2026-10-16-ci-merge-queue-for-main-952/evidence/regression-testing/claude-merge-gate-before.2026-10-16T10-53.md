# Claude Merge Gate Before (P2-T4, expect-fail)

Timestamp: 2026-10-16T10-53
Command: mcp__drm-copilot__run_poshqc_test workspace_root=WORKTREE_ROOT scan_folders=[tests/scripts/claude-hooks]
EXIT_CODE: 1
ExpectedExitCode: 1
Disposition: RAISED
Output Summary: Command exited with code 29.
Baseline (P0-T10 t-claude-hooks): GREEN

Error text (verbatim): {"ok": false, "tool": "run_poshqc_test", "workspace_root": "WORKTREE_ROOT", "summary": "Command exited with code 29."}

Informational note (not an acceptance input): the child exit code 29 equals the number of rows below expected to fail pre-change (27 Appendix B cases plus 2 changed pinned rows). Per the MCP observation rule, no count is asserted from the MCP result.

Supporting check: `git grep -n -F -e "function Test-EpicMergeGateCommandInScope" -- .claude/hooks` exited 1 with no output (the scope predicate does not exist pre-change).

RowAttribution:

Reasons referenced below:
- R-SCOPE: the scope filter `.claude/hooks/enforce-epic-merge-gate.ps1:343-356` brings a command into scope only when it invokes gh pr merge AND carries `--merge`; every other spelling, and every gh api call, is allowed.
- R-READER: the reader `.claude/hooks/enforce-epic-merge-gate.ps1:131-142` reads only an all-digit operand of the gh pr merge segment or a `--merge` flag value; a value flag such as `--subject x` or `--body-file f` makes its value the first operand, a URL is not all-digit, and gh api paths are not read.
- R-TEXT: the deny text at `.claude/hooks/enforce-epic-merge-gate.ps1:415` still begins "gh pr merge --merge requires".
- R-ABSENT: `Test-EpicMergeGateCommandInScope` is absent (git grep above exited 1).

Appendix B cases (tests/scripts/claude-hooks/enforce-epic-merge-gate.MergeQueue.Tests.ps1):

| Row | Case | Expected pre-change | Reason |
|---|---|---|---|
| probe | baseline mock interception probe | pass | unchanged probe |
| D1 | denies gh pr merge 5 --merge without an authorization record | pass | in scope today; standalone branch denies |
| D2 | denies gh pr merge 5 -m without an authorization record | fail | R-SCOPE (`-m` is not `--merge`) |
| D3 | denies gh pr merge 5 --squash without an authorization record | fail | R-SCOPE |
| D4 | denies gh pr merge 5 -s without an authorization record | fail | R-SCOPE |
| D5 | denies gh pr merge 5 --rebase without an authorization record | fail | R-SCOPE |
| D6 | denies gh pr merge 5 -r without an authorization record | fail | R-SCOPE |
| D7 | denies gh pr merge 5 --auto without an authorization record | fail | R-SCOPE |
| D8 | denies gh pr merge 5 --admin without an authorization record | fail | R-SCOPE |
| D9 | denies gh pr merge 5 without an authorization record | fail | R-SCOPE |
| D10 | denies bash -c "gh pr merge 5 --squash" without an authorization record | fail | R-SCOPE (raw-scan fallback looks only for `--merge`) |
| A1 | allows gh pr merge 5 --disable-auto | pass | out of scope today |
| A2 | allows git commit -m "gh pr merge 5 --squash" | pass | not an invocation |
| A3 | allows printf ... "gh api graphql enqueuePullRequest" >> notes.md | pass | not an invocation |
| G1 | decides deny for an enqueuePullRequest mutation | fail | R-SCOPE (gh api never in scope) |
| G2 | decides deny for an enablePullRequestAutoMerge mutation | fail | R-SCOPE |
| G3 | decides deny for a mergePullRequest mutation | fail | R-SCOPE |
| G4 | decides deny for a REST PUT to the pulls merge endpoint | fail | R-SCOPE |
| G5 | decides allow for the procedure merge-state read query | pass | out of scope today |
| S1 | resolves 5 for gh pr merge --merge --auto 5 | fail | R-READER (`--merge` value read as `--auto`; operand scan yields none) |
| S2 | resolves 5 for gh pr merge --subject x 5 --merge | fail | R-READER (first operand is `x`) |
| S3 | resolves 5 for gh pr merge -R o/r 5 --squash | pass | `-R` value skipped by the shared parser; 5 is the first all-digit operand |
| S4 | resolves 5 for gh pr merge --body-file f 5 -m | fail | R-READER |
| S5 | resolves 5 for gh pr merge https://github.com/o/r/pull/5 --merge | fail | R-READER (URL operand) |
| S6 | resolves 5 for gh api -X PUT repos/o/r/pulls/5/merge | fail | R-READER (gh api not read) |
| R1 | decides allow for gh pr merge --merge --auto 5 with a pull request 5 record | fail | R-READER yields no number, so the standalone branch is skipped and the bare deny is returned |
| R2 | decides allow for gh pr merge 5 --squash with a pull request 5 record | pass | out of scope today, allowed |
| R3 | decides allow for gh pr merge https://github.com/drmoisan/drm-copilot/pull/5 --merge with a pull request 5 record | fail | R-READER |
| R4 | decides allow for gh pr merge --subject x 5 --merge with a pull request 5 record | fail | R-READER |
| R5 | decides allow for gh api -X PUT repos/drmoisan/drm-copilot/pulls/5/merge with a pull request 5 record | pass | out of scope today, allowed |
| R6 | decides deny for gh pr merge 6 --auto with a pull request 5 record | fail | R-SCOPE (allowed today) |
| B-6 | denies a bare gh pr merge --squash with the method-agnostic message | fail | R-SCOPE and R-TEXT |
| P1 | returns False for gh pr merge 5 --disable-auto | fail | R-ABSENT |
| P2 | returns True for gh pr merge 5 --squash | fail | R-ABSENT |
| P3 | returns False for gh api graphql -f query='query { viewer { login } }' | fail | R-ABSENT |
| P4 | returns True for bash -c "gh pr merge 5 --squash" | fail | R-ABSENT |

Totals: 36 cases; 9 expected pass (probe, D1, A1, A2, A3, G5, S3, R2, R5); 27 expected fail.

Changed pinned rows:

| Suite | Row | Expected pre-change | Reason |
|---|---|---|---|
| tests/scripts/claude-hooks/enforce-epic-merge-gate.Tests.ps1 | denies gh pr merge --squash without a checkpoint (issue #952 method-agnostic scope) | fail | R-SCOPE: `:343-356` allows `--squash` |
| tests/scripts/claude-hooks/enforce-epic-merge-gate.Authorization.Tests.ps1 (:142) | keeps the existing fall-through text for a bare merge even with a valid record present | fail | R-TEXT: `:415` still carries the old text |

CI jobs relied on later: poshqc / PowerShell QC and poshqc / PowerShell hook suites (Linux).
