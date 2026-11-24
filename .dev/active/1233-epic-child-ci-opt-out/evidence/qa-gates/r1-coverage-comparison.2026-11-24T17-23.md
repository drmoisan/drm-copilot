# R1 coverage comparison (P1-T12)

Timestamp: 2026-11-24T17-23
Command: pwsh -NoProfile -File SCRATCH/issue-1233-pester-summary.ps1 and SCRATCH/issue-1233-r1-range.ps1 over SCRATCH/issue-1233-r1-p0-pester.coverage.xml (P0-T2) and SCRATCH/issue-1233-r1-final-pester.coverage.xml (P1-T8)
EXIT_CODE: 0
Output Summary:
- Scope: both figures are selection-scoped under owner rule O1 (Set P, the same selection in P0-T2 and P1-T8 plus the one new suite), compared like for like. They are not repo-wide gate evidence; the repo-wide reference stays final-qc-pester.2026-11-24T13-00.md.

| Changed PowerShell file | Baseline (P0-T2) | Final (P1-T8) | Changed-line coverage | Result |
| --- | --- | --- | --- | --- |
| .claude/lib/orchestrator-state/OrchestratorStateCompletionChecks.psm1 | 145/147, 98.64% | 151/153, 98.69% | lines 153 to 245 (Get-MissingOrdinalGateKey and Get-OrchestratorStateCompletionLocalQcGateError): 30/30, 100% | at least 85%, no drop |
| .claude/hooks/enforce-epic-merge-gate-child-ci.ps1 | 158/158, 100% | 166/166, 100% | lines 252 to 358 (the two new accessors, Test-EpicMergeGateChildCiOptOut, Get-EpicMergeGateChildCiLivePullRequest): 25/25; lines 474 to 512 (Get-EpicMergeGateChildLocalQcResult record and binding stages): 26/26; 100% | at least 85%, no drop |
| .codex/hooks/enforce-epic-merge-gate-child-ci.ps1 | 156/158, 98.73% | 164/166, 98.8% | same ranges: 25/25 and 26/26, 100% | at least 85%, no drop |
| .codex/hooks/enforce-epic-merge-gate.ps1 (comment-only change) | 182/183, 99.45% | 182/183, 99.45% | no executable line changed | at least 85%, no drop |

- Bundle copies are byte-identical to their sources and are not measured separately.
- The two missed lines of the module (472, 473) and of the Codex helper (242, 543) are pre-existing lines shifted by the insertions (baseline 435, 436 and 241, 495); no added or changed line is uncovered.
- Python and TypeScript production files are unchanged in this cycle (O2); their selection counts rose by the four new corpus rows only (r1-final-pytest-selection, r1-final-jest-selection).
- No shortfall; no re-run of P1-T7 to P1-T12 was needed.
