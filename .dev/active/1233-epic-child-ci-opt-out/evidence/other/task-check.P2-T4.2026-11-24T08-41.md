# Task check: P2-T4

Timestamp: 2026-11-24T08-41
Command: see the command list below (each run from the item worktree root)
EXIT_CODE: 0
Output Summary: Invoke-Formatter reports no drift and PSScriptAnalyzer 0 findings on both hooks and both extended suites; every completion suite in tests/scripts/claude-hooks and tests/scripts/codex-hooks (17 files) plus Set L passed (411 tests, 0 failures); both bundle copies match their sources; the Claude hook has 517 lines and the Codex hook 508 (both below 700); the 0014 revert restores the merge-base bytes of all fourteen recorded files.

Changed files:
- .claude/hooks/enforce-completion-consistency.ps1 and .codex/hooks/enforce-completion-consistency.ps1: in `Get-MissingCompletionEvidence`, under `Test-CompletionChildCiIntegrationOnly` the ci_gate evidence check is replaced by `Get-CompletionLocalQcGateMissing` and the ci_gate/pr_gate head_sha comparison is skipped; the deny reason names the local_qc_gate alternative only in that branch, and every text without the key is unchanged (the existing reason line is not edited; the opt-out reason is assigned after it under the predicate).
- Both bundle copies: byte-identical copies.
- tests/scripts/claude-hooks/enforce-completion-consistency.Tests.ps1 and tests/scripts/codex-hooks/codex-completion-consistency-hook.Tests.ps1: per runtime, DONE allowed with a valid local_qc_gate, no ci_gate, and a pr_gate head that differs from the local head; four deny rows (absent object, failure conclusion, empty head_sha, absent or empty evidence_path); a row asserting the opt-out reason names the local_qc_gate alternative; a row asserting the full COMPLETION_CONSISTENCY_BLOCKED reason of a keyless checkpoint equals the pre-change string. The other completion-consistency suites are unchanged and in the selection.
- .dev/engineering/process-reductions/0014-epic-child-ci-opt-out.md: blocks for both hooks and both extended suites appended; Files Changed and Revert Steps step 2 extended.

Selection and rule: every *completion* suite in tests/scripts/claude-hooks and tests/scripts/codex-hooks (the task text) and Set L.

Commands and exit codes:
- sh SCRATCH/issue-1233-ps-files.sh write <two hooks>,<two suites> -> 0 (format drift=0 pssa findings=0)
- sh SCRATCH/issue-1233-copy.sh <hook> <bundle copy> (twice) -> 0
- sh .claude/skills/test-execution-policy/scripts/run-test-suite.sh pester -TestPath <17 completion suites> <Set L> -> 0 (411 passed)
- sh SCRATCH/issue-1233-ledger-verify.sh -> 0 (blocks=35 files=14 problems=0)
