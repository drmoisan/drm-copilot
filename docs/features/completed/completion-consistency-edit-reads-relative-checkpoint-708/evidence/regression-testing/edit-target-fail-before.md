# Fail-Before Evidence — Issue #708

## P1-T2

Timestamp: 2026-09-27T08-40
Command: pwsh -NoProfile -Command '$r = Invoke-Pester -Path tests/scripts/claude-hooks/enforce-completion-consistency.EditTarget.Tests.ps1 -PassThru -Output None; "PASSED=$($r.PassedCount)"; "FAILED=$($r.FailedCount)"; "FAILED_BLOCKS=$($r.FailedBlocksCount)"; "FAILED_CONTAINERS=$($r.FailedContainersCount)"; $r.Failed | ForEach-Object { "FAILED_TEST=$($_.Name)" }; exit ($r.FailedCount + $r.FailedBlocksCount + $r.FailedContainersCount)'
EXIT_CODE: 8
ExpectedExitCode: 8
Output Summary:
PASSED=4
FAILED=8
FAILED_BLOCKS=0
FAILED_CONTAINERS=0
FAILED_TEST=denies a completion-asserting Edit when the checkpoint exists only at the absolute targeted file_path
FAILED_TEST=derives a deny from the targeted file_path content when the relative literal holds different content
FAILED_TEST=derives an allow from the targeted file_path content when the relative literal holds a completion-asserting checkpoint
FAILED_TEST=passes an absolute POSIX file_path to the reader unchanged
FAILED_TEST=passes a backslash-spelled file_path to the reader unchanged
FAILED_TEST=allows an Edit whose old_string is absent from the targeted file_path content
FAILED_TEST=allows an Edit when the targeted file_path content is empty
FAILED_TEST=declares CheckpointPath as a mandatory parameter of Resolve-EditedCheckpointContent

The failed set equals {T-A, T-B, T-C, T-D, T-F, T-I, T-K, T-L}; T-E, T-G, T-H, and T-J passed. Zero failed blocks and containers show the failures are assertion failures, not load or parameter-binding errors (spec D5). The run was made against the unmodified hook (see the section below).

## P1-T2 hook-unmodified

Timestamp: 2026-09-27T08-40
Command: git diff --exit-code 74b2ca0a2bdf8a0bf9a032433fef20831707b574 -- .claude/hooks/enforce-completion-consistency.ps1
EXIT_CODE: 0
Output Summary: empty diff; the hook is unmodified relative to MergeBase 74b2ca0a2bdf8a0bf9a032433fef20831707b574.
