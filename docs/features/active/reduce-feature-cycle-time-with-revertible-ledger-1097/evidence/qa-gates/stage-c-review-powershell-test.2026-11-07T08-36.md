# Stage C Review Remediation: PowerShell Test Gate

Timestamp: 2026-11-07T08-36
Command: Invoke-PoshQCParallelTest -Root <worktree root>, one run, from a `sh` launcher under SCRATCH that imports `scripts/powershell/PoshQC/PoshQC.psd1`
EXIT_CODE: 0
Output Summary: returned `ExitCode` 0 with 8 workers, wall-clock 304.11 seconds. `artifacts/pester/pester-junit.xml`: 15392 tests, 0 failures, 0 errors, 10 disabled. All 204 shared rows of `Get-EpicMergeGateReviewCaseRow`, which hold every row of the decisions section with its `pending-` and `nokey-` forms, pass under both `RG-` and `RGC-` names, with none missing. Names added by Phase 1: `RG-SHAPE-*` 12 of 12 passing (the five of the plan, the best-effort rows, and the session-key row); `RGC-SHAPE-*` 4 of 4; `OCR-READINESS-BLOCKS-KEY-NAME-CASE-VARIANT` and `OCR-COMPLETION-UNCHANGED-FOR-KEY-NAME-CASE-VARIANT` 1 of 1 each; `CRS-RULE-DISCLOSES-UNREAD-MERGE-FORMS` 2 of 2; `CRS-SKILL-COMMITS-ENTRY-NUMBER-BEFORE-HEAD-READ` 4 of 4; `CRS-SKILL-STATES-OWN-CALL-MERGE` 4 of 4; `CRS-AGENTS-STATE-SKILL-DOCUMENTS-KEY` 2 of 2. Repo-wide line coverage from `Get-PoshQCCoverageLineSummary`: 93.99% (23994 of 25528), against the 85% threshold.

`LINE` counters from `artifacts/pester/powershell-coverage.xml`, each against the 85% threshold, from this run alone:

- `.claude/hooks/enforce-epic-merge-gate.ps1`: 141 covered, 2 missed, 98.60%.
- `.codex/hooks/enforce-epic-merge-gate.ps1`: 167 covered, 1 missed, 99.40%.
- `.claude/hooks/enforce-epic-merge-gate-review.ps1`: 160 covered, 2 missed, 98.77%.
- `.codex/hooks/enforce-epic-merge-gate-review.ps1`: 149 covered, 13 missed, 91.98%.
- `OrchestratorState.psm1`: 112 covered, 1 missed, 99.12%.
- `OrchestratorStateCompletionChecks.psm1`: 115 covered, 2 missed, 98.29%.

Missed lines of the guard: the no-number deny of `Get-EpicMergeGateReviewDecision`, which the shape rule now reaches first and which stays as written, in both copies; the catch of the injected reader in the Claude copy, which the Codex copy covers, because the Claude reader catches its own failures; and, in the Codex copy, the two Claude-only functions. Figures were read from those files and not from MCP output.
