# Task check: P2-T2

Timestamp: 2026-11-24T08-09
Command: see the command list below (each run from the item worktree root)
EXIT_CODE: 0
Output Summary: Invoke-Formatter reports no drift and PSScriptAnalyzer 0 findings on both gates and the new suite; the new Claude suite passed alone (50 tests) and inside the selection (Set H with the new suite, and Set L: 2037 tests, 0 failures, including hook-dependency-failure.SpecialCases.Tests.ps1); both bundle copies match their sources; the 0014 revert restores the merge-base bytes of all eight recorded files. Line coverage in this selection: .claude/hooks/enforce-epic-merge-gate-child-ci.ps1 100% (158/158), .claude/hooks/enforce-epic-merge-gate.ps1 98.64%, .codex/hooks/enforce-epic-merge-gate-child-ci.ps1 98.73%, .codex/hooks/enforce-epic-merge-gate.ps1 99.45%.

Changed files:
- .claude/hooks/enforce-epic-merge-gate.ps1: branch 1 of `Invoke-EpicMergeGateDecision` passes `-GitRoot $childRoot`; header condition 1 names the opt-out and EPIC_CHILD_LOCAL_QC_NOT_VERIFIED (501 lines).
- .codex/hooks/enforce-epic-merge-gate.ps1: header comment paragraph only; the call is unchanged (450 lines).
- extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-epic-merge-gate.ps1 and extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/enforce-epic-merge-gate.ps1: byte-identical copies (cmp).
- tests/scripts/claude-hooks/enforce-epic-merge-gate.ChildCiOptOut.Tests.ps1 (created): every allow, deny, fallback, and default case of table T through `Invoke-EpicMergeGateDecision` (the review-head letter-case L2 row stubs `Get-EpicMergeGateReviewDecision`, because the review guard rejects an uppercase head before branch 1); default rows compare the deny text with the same checkpoint without the opt-out keys and assert zero opt-out seam calls; call-count rows filtered by argument (allow: one `headRefOid,baseRefName` pr view and one cat-file; L2 mismatch: no cat-file; base-mismatch allow: one opt-out pr view, one run list, and only the review guard's headRefOid pr view); a root row asserting cat-file runs with WorktreeRoot equal to the item root and gh at the session root.
- .dev/engineering/process-reductions/0014-epic-child-ci-opt-out.md: blocks for both gates appended (they differ); Files Changed and Revert Steps extended.

Correction to task-check.P2-T1.2026-11-24T07-51.md: the Codex suite holds 31 deny rows, not 32 (counted from the JUnit of SCRATCH run p2t1-new); that file is left unedited under the append-only rule.

Selection and rule: Set H plus the new suite and Set L, per the task text and the task-check rule (every suite that names an edited hook file).

Commands and exit codes:
- sh SCRATCH/issue-1233-copy.sh <gate> <bundle copy> (twice) -> 0
- sh SCRATCH/issue-1233-ps-files.sh write <both gates>,<new suite> -> 0 (format drift=0 pssa findings=0)
- sh .claude/skills/test-execution-policy/scripts/run-test-suite.sh pester -TestPath tests/scripts/claude-hooks/enforce-epic-merge-gate.ChildCiOptOut.Tests.ps1 -> 0 (50 passed)
- sh .claude/skills/test-execution-policy/scripts/run-test-suite.sh pester -TestPath <Set H, 36 files> <Set L> -> 0 (2037 passed)
- sh SCRATCH/issue-1233-ledger-verify.sh -> 0 (blocks=24 files=8 problems=0)
