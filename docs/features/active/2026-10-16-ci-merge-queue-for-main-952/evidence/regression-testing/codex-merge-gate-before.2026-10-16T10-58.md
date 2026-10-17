# Codex Merge Gate Before (P2-T7, expect-fail)

Timestamp: 2026-10-16T10-58
Command: mcp__drm-copilot__run_poshqc_test workspace_root=WORKTREE_ROOT scan_folders=[tests/scripts/codex-hooks]
EXIT_CODE: 1
ExpectedExitCode: 1
Disposition: RAISED
Output Summary: Command exited with code 26.
Baseline (P0-T10 t-codex-hooks): GREEN

Error text (verbatim): {"ok": false, "tool": "run_poshqc_test", "workspace_root": "WORKTREE_ROOT", "summary": "Command exited with code 26."}

Informational note (not an acceptance input): the child exit code 26 equals the number of rows below expected to fail pre-change (25 Appendix C cases plus 1 changed pinned row). Per the MCP observation rule, no count is asserted from the MCP result.

RowAttribution:

Reasons referenced below:
- R-SCOPE: the scope filter `.codex/hooks/enforce-epic-merge-gate.ps1:144-157` brings a command into scope only when it invokes gh pr merge AND carries `--merge`; every other spelling, and every gh api call, returns $null (allow).
- R-READER: the reader `.codex/hooks/enforce-epic-merge-gate.ps1:64-75` reads only an all-digit operand of the gh pr merge segment or a `--merge` flag value.
- R-TEXT: the deny text at `.codex/hooks/enforce-epic-merge-gate.ps1:191` still begins "gh pr merge --merge requires".
- R-ABSENT: `Test-EpicMergeGateCommandInScope` is not loaded by the Codex hook (no helper file exists; P2-T4 recorded `git grep -n -F -e "function Test-EpicMergeGateCommandInScope" -- .claude/hooks` exiting 1, and `.codex/hooks` has no such function either).

Appendix C cases (tests/scripts/codex-hooks/enforce-epic-merge-gate-merge-queue.Tests.ps1):

| Row | Case | Expected pre-change | Reason |
|---|---|---|---|
| probe | baseline mock interception probe | pass | unchanged probe |
| C-1 D1 | denies gh pr merge 5 --merge without an authorization record | pass | in scope today; standalone branch denies |
| C-1 D2 to D10 | denies gh pr merge 5 -m / --squash / -s / --rebase / -r / --auto / --admin / (bare) / bash -c "gh pr merge 5 --squash" | fail (9 cases) | R-SCOPE |
| C-2 A1 to A3 | allows gh pr merge 5 --disable-auto; git commit -m "..."; printf ... >> notes.md | pass (3 cases) | out of scope today |
| C-3 G1 to G4 | decides deny for the three GraphQL mutations and the REST PUT | fail (4 cases) | R-SCOPE |
| C-3 G5 | decides allow for the procedure merge-state read query | pass | out of scope today |
| C-4 S1, S2, S4, S5, S6 | resolves 5 for the five spellings other than -R | fail (5 cases) | R-READER |
| C-4 S3 | resolves 5 for gh pr merge -R o/r 5 --squash | pass | 5 is the first all-digit operand |
| C-5 R1, R3, R4 | decides allow with a pull request 5 record for --merge --auto 5, the /pull/5 URL, --subject x 5 --merge | fail (3 cases) | R-READER yields no number, so the standalone branch is skipped and the bare deny is returned |
| C-5 R2, R5 | decides allow for gh pr merge 5 --squash and gh api -X PUT .../pulls/5/merge | pass (2 cases) | out of scope today, allowed |
| C-5 R6 | decides deny for gh pr merge 6 --auto with a pull request 5 record | fail | R-SCOPE (allowed today) |
| C-6 | denies a bare gh pr merge --squash with the method-agnostic message | fail | R-SCOPE and R-TEXT |
| C-7 P1 | returns False for gh pr merge 5 --disable-auto | fail | R-ABSENT |
| C-7 P4 | returns True for bash -c "gh pr merge 5 --squash" | fail | R-ABSENT |

Totals: 34 cases; 9 expected pass (probe, D1, A1, A2, A3, G5, S3, R2, R5); 25 expected fail.

Changed pinned row:

| Suite | Row | Expected pre-change | Reason |
|---|---|---|---|
| tests/scripts/codex-hooks/enforce-epic-merge-gate-authorization.Tests.ps1 (:123) | keeps the existing deny text for a bare merge even with a valid record present | fail | R-TEXT: `:191` still carries the old text |

CI jobs relied on later: poshqc / PowerShell QC and poshqc / PowerShell hook suites (Linux).
