# P1-T7 Expect-Fail Run (issue #927, fail-before against unchanged hooks)

Timestamp: 2026-10-16T01-21
Command: grep -c -E 'status="Failed" classname="[^"]*enforce-pr-author-skill' artifacts/pester/pester-junit.xml (R-JUNIT J5)
EXIT_CODE: 0
MCP_CALL: error Command exited with code 39.
Output Summary: Fail-before run against the unchanged hooks. The JUnit file was rewritten (tests=7065 failures=39 errors=0). Exactly 39 rows fail: the 18 create-side expect-fail rows of Appendix R (13 DocsOnly, 4 Exemption, 1 Decision) and the 21 merge-side rows of Appendix R2 (13 in suite C, 8 in suite E). No other row fails. Pass-through rows R2, R3, A1-A4 and both probe rows pass.

## R-JUNIT reads

- J0: JUNIT_MTIME_BEFORE: 1792111467
- MCP: `mcp__drm-copilot__run_poshqc_test` workspace_root=<WORKSPACE_ROOT> scan_folders=SCAN_TEST -> ok=false, "Command exited with code 39." (either disposition accepted for this task)
- J1: JUNIT_MTIME_AFTER: 1792113651 (greater than before; rewritten)
- J2: tests=7065 failures=39 errors=0 (FAIL_BASE 0 + 39 = 39)
- J4: 236
- J5: 18
- J6: 34, 15, 8
- J8: 13, 4, 1
- J10: 0, 0, 1, 0, 1 (suites A, B, C, D, E)
- J11: 0, 0, 13, 0, 8 (suites A, B, C, D, E)
- B_FAILED lines from [P0-T9]: none, so nothing to carry forward.

## J9 (each token prints 1)

Method: J3 lists every `status="Failed"` testcase; each J9 count equals the number of J3 lines that end with the token. Each token below appears in exactly one J3 line.

Appendix R expect-fail tokens (18):
- R1 override B cluster -dB: 1
- R4 override R separate -R: 1
- R5 override R attached -Ro/r: 1
- R6 override R cluster -dR: 1
- R7 override long --repo: 1
- R8 override long --repo=: 1
- R9 override global -R before pr create: 1
- R10 override global --repo before pr create: 1
- R11 override inline GH_REPO prefix: 1
- S1 returns exit code 0 and NUL-terminated output with -C, the root, and the arguments in order: 1
- S2 joins multi-line output with a line feed: 1
- S3 returns the non-zero exit code of the injected command: 1
- S4 returns the failure object when the injected command throws: 1
- X1 denies diff output that is not NUL-terminated (issue #927): 1
- X2 denies a -R repository override before any git call (issue #927): 1
- X3 denies a -dB shorthand cluster before any git call (issue #927): 1
- X4 names every rejected override form in the E3 reason (issue #927): 1
- D1 denies a --repo override before the diff (issue #927): 1

Appendix R2 tokens (21):
- C1 to C13: 1 each (allow row, three deny-composition rows, three resolved-target rows, bare-merge row, five Test-EpicMergeGateNoRecordingTarget rows)
- E1 to E8: 1 each (allow row, NON_DOCS_PATH row, child and epic checkpoint rows, blank root, -R override, failed gh lookup, bare merge)

## J3 failed lines (verbatim test names, classname omitted)

- enforce-epic-merge-gate docs-only branch (issue #927).no checkpoint records the pull request.allows a docs-only merge with no checkpoint record (issue #927)
- enforce-epic-merge-gate docs-only branch (issue #927).no checkpoint records the pull request.denies a non-docs diff with the docs-only reason after the standalone reasons (issue #927)
- enforce-epic-merge-gate docs-only branch (issue #927).no checkpoint records the pull request.denies a failed gh lookup with the PR_UNRESOLVED docs-only reason (issue #927)
- enforce-epic-merge-gate docs-only branch (issue #927).no checkpoint records the pull request.denies a -R override with the PR_UNRESOLVED docs-only reason and no process call (issue #927)
- enforce-epic-merge-gate docs-only branch (issue #927).a checkpoint target resolves or the command is bare.makes no docs-only call when the item target is SessionRoot (issue #927)
- enforce-epic-merge-gate docs-only branch (issue #927).a checkpoint target resolves or the command is bare.makes no docs-only call when the item target is OtherWorktree (issue #927)
- enforce-epic-merge-gate docs-only branch (issue #927).a checkpoint target resolves or the command is bare.makes no docs-only call when the epic target is Ambiguous (issue #927)
- enforce-epic-merge-gate docs-only branch (issue #927).a checkpoint target resolves or the command is bare.makes no docs-only call for a bare merge and keeps its exact deny text (issue #927)
- enforce-epic-merge-gate docs-only branch (issue #927).Test-EpicMergeGateNoRecordingTarget.reports true for item NoTarget, epic NoTarget, parallel NoTarget (issue #927)
- enforce-epic-merge-gate docs-only branch (issue #927).Test-EpicMergeGateNoRecordingTarget.reports false for item Ambiguous, epic NoTarget, parallel NoTarget (issue #927)
- enforce-epic-merge-gate docs-only branch (issue #927).Test-EpicMergeGateNoRecordingTarget.reports false for item NoTarget, epic SessionRoot, parallel NoTarget (issue #927)
- enforce-epic-merge-gate docs-only branch (issue #927).Test-EpicMergeGateNoRecordingTarget.reports false for item NoTarget, epic NoTarget, parallel OtherWorktree (issue #927)
- enforce-epic-merge-gate docs-only branch (issue #927).Test-EpicMergeGateNoRecordingTarget.reports false for a bare command with no targets (issue #927)
- enforce-pr-author-skill.ps1 docs-only exemption decision (issue #901).non-epic preflight failure.denies a --repo override before the diff (issue #927)
- Get-PrAuthorDocsOnlyExemption (issue #901).predicate rows.denies diff output that is not NUL-terminated (issue #927)
- Get-PrAuthorDocsOnlyExemption (issue #901).predicate rows.denies a -R repository override before any git call (issue #927)
- Get-PrAuthorDocsOnlyExemption (issue #901).predicate rows.denies a -dB shorthand cluster before any git call (issue #927)
- Get-PrAuthorDocsOnlyExemption (issue #901).predicate rows.names every rejected override form in the E3 reason (issue #927)
- enforce-pr-author-skill docs-only helpers (issue #901).Get-PrAuthorDocsOnlyBaseName.denies the base or repository override B cluster -dB
- enforce-pr-author-skill docs-only helpers (issue #901).Get-PrAuthorDocsOnlyBaseName.denies the base or repository override R separate -R
- enforce-pr-author-skill docs-only helpers (issue #901).Get-PrAuthorDocsOnlyBaseName.denies the base or repository override R attached -Ro/r
- enforce-pr-author-skill docs-only helpers (issue #901).Get-PrAuthorDocsOnlyBaseName.denies the base or repository override R cluster -dR
- enforce-pr-author-skill docs-only helpers (issue #901).Get-PrAuthorDocsOnlyBaseName.denies the base or repository override long --repo
- enforce-pr-author-skill docs-only helpers (issue #901).Get-PrAuthorDocsOnlyBaseName.denies the base or repository override long --repo=
- enforce-pr-author-skill docs-only helpers (issue #901).Get-PrAuthorDocsOnlyBaseName.denies the base or repository override global -R before pr create
- enforce-pr-author-skill docs-only helpers (issue #901).Get-PrAuthorDocsOnlyBaseName.denies the base or repository override global --repo before pr create
- enforce-pr-author-skill docs-only helpers (issue #901).Get-PrAuthorDocsOnlyBaseName.denies the base or repository override inline GH_REPO prefix
- enforce-pr-author-skill docs-only helpers (issue #901).Invoke-PrAuthorDocsOnlyGitExe command injection (issue #927).returns exit code 0 and NUL-terminated output with -C, the root, and the arguments in order
- enforce-pr-author-skill docs-only helpers (issue #901).Invoke-PrAuthorDocsOnlyGitExe command injection (issue #927).joins multi-line output with a line feed
- enforce-pr-author-skill docs-only helpers (issue #901).Invoke-PrAuthorDocsOnlyGitExe command injection (issue #927).returns the non-zero exit code of the injected command
- enforce-pr-author-skill docs-only helpers (issue #901).Invoke-PrAuthorDocsOnlyGitExe command injection (issue #927).returns the failure object when the injected command throws
- Codex enforce-epic-merge-gate docs-only branch (issue #927).allows a docs-only merge when no checkpoint is present (codex, issue #927)
- Codex enforce-epic-merge-gate docs-only branch (issue #927).appends the NON_DOCS_PATH docs-only reason to the standalone deny (codex, issue #927)
- Codex enforce-epic-merge-gate docs-only branch (issue #927).makes no docs-only call when the child checkpoint is present (codex, issue #927)
- Codex enforce-epic-merge-gate docs-only branch (issue #927).makes no docs-only call when the epic checkpoint is present (codex, issue #927)
- Codex enforce-epic-merge-gate docs-only branch (issue #927).denies a blank repository root with PR_UNRESOLVED and no process call (codex, issue #927)
- Codex enforce-epic-merge-gate docs-only branch (issue #927).denies a -R override with PR_UNRESOLVED and no process call (codex, issue #927)
- Codex enforce-epic-merge-gate docs-only branch (issue #927).denies a failed gh lookup with PR_UNRESOLVED (codex, issue #927)
- Codex enforce-epic-merge-gate docs-only branch (issue #927).keeps the bare-merge deny text unchanged (codex, issue #927)
