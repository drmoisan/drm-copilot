# Task Check P2-T1

Timestamp: 2026-11-24T07-13
Command: sh SCRATCH/issue-1234-taskcheck.sh "tests/scripts/claude-hooks/enforce-epic-merge-gate.Release.Tests.ps1" "tests/scripts/claude-hooks/enforce-epic-merge-gate.Release.Tests.ps1" "" (static; launcher `pester -TestPath` selection)
EXIT_CODE: 0
Output Summary:
- Changed files: new `tests/scripts/claude-hooks/enforce-epic-merge-gate.Release.Tests.ps1` (115 lines). `.claude/hooks/enforce-epic-merge-gate.ps1` is unchanged at this point (`git diff --stat` empty), so the rows ran against the pre-change gate.
- Selection rule: the new suite itself.
- Static: formatter 0 `Formatted: ` lines; analyzer 0 findings.
- Pester: exit 0 after 1 queue timeout (exit 75, re-run); 3 tests (interception probe and the two AC-21 rows), 0 failures. The rows assert with `-ceq` the full deny string (TARGET_WORKTREE_NOT_DERIVABLE prefix, STANDALONE_MERGE_AUTHORIZATION_ABSENT reason, DOCS_ONLY_EXEMPTION_NON_DOCS_PATH suffix), exactly one Invoke-DocsOnlyGhExe call (`pr view 5 --json baseRefName,headRefOid`), zero calls starting with `run` or carrying `headRefName`, and exactly three Invoke-DocsOnlyGitExe calls.
