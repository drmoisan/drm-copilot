# Fail-before evidence: CHILD-CI-NO-CI-GATE (P1-T1, expect-fail)

Timestamp: 2026-11-08T13-55
Command: sh SCRATCH/issue-1130-focused.sh tests/scripts/claude-hooks/enforce-epic-merge-gate.ChildCi.Tests.ps1 (pwsh 7, Pester 6.2.0, Invoke-Pester on this one file; debug-only focused run, not a gate)
EXIT_CODE: 1
ExpectedExitCode: 1
Output Summary:
- RESULT passed=0 failed=1 skipped=0 total=1.
- Failed: CHILD-CI-NO-CI-GATE denies gh pr merge 42 --merge for an epic child with step9_status passed and no ci_gate.
- Observed decision: allow (reason empty). Expected 'deny' containing EPIC_CHILD_CI_NOT_VERIFIED; the unmodified branch 1 of Invoke-EpicMergeGateDecision allows the merge on checkpoint state alone (epic_mode true, step9_status passed, pr_gate.pr_number 42, no ci_gate).
- This reproduces the defect of issue #1130 before the fix.
