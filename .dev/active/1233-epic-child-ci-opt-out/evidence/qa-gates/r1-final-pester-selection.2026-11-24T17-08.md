# R1 final QC: Pester selection Set P (P1-T8)

Timestamp: 2026-11-24T17-08
Command: sh .claude/skills/test-execution-policy/scripts/run-test-suite.sh pester -TestPath <Set P, 80 files listed in SCRATCH/issue-1233-r1-setp.txt: the 79 files of P0-T2 plus tests/scripts/codex-hooks/enforce-completion-helpers.OrdinalKeys.Tests.ps1, which the Set P glob now matches> (through SCRATCH/issue-1233-r1-final.sh; JUnit and coverage copied to SCRATCH/issue-1233-r1-final-pester.junit.xml and SCRATCH/issue-1233-r1-final-pester.coverage.xml)
EXIT_CODE: 0
Output Summary:
- Run window 2026-11-24T16-59 to 2026-11-24T17-08; attempts 1 to 3 exited 75 (queue timeout), recorded as queue timeouts, not failures.
- Invoke-PoshQCParallelTest: workers=8; wall-clock=467.77s; exit code=0.
- Merged JUnit: tests=3589, failures=0, errors=0, skipped=0 (P0-T2: 3549; +40 from the new rows and the new suite).
- Line coverage (selection-scoped, compared like for like with r1-pester-selection.2026-11-24T15-07.md):
  - .claude/lib/orchestrator-state/OrchestratorStateCompletionChecks.psm1: 151/153, 98.69% (baseline 145/147, 98.64%)
  - .claude/hooks/enforce-epic-merge-gate-child-ci.ps1: 166/166, 100% (baseline 158/158, 100%)
  - .codex/hooks/enforce-epic-merge-gate-child-ci.ps1: 164/166, 98.8% (baseline 156/158, 98.73%)
  Each is at least 85% and none is below its P0-T2 figure.
- Added functions fully covered: Get-MissingOrdinalGateKey and the changed lines of Get-OrchestratorStateCompletionLocalQcGateError (module lines 153 to 245) have no missed line; Get-EpicMergeGateChildCiOrdinalProperty and Get-EpicMergeGateChildLocalQcReviewedHead (helper lines 252 to 298) and the switched call sites have no missed line in either copy. The remaining missed lines are pre-existing and only shifted by the insertions: module lines 472 and 473 (baseline 435 and 436, Get-OrchestratorStatePhaseCompletenessError) and Codex helper lines 242 and 543 (baseline 241 and 495: the unreadable createdAt return in Select-EpicMergeGateChildCiRun and the catch of Get-EpicMergeGateChildCiDecision).
- Other files from the same report: .codex/hooks/enforce-epic-merge-gate.ps1 182/183 (99.45%, unchanged), .codex/hooks/enforce-completion-helpers.ps1 90/90 (100%).
- Repo-wide reference remains final-qc-pester.2026-11-24T13-00.md (O1); this selection figure (8329/49447, 16.84%) is not gate evidence.
