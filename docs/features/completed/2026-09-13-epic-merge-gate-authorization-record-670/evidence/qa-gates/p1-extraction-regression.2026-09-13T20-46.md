# Phase 1 Extraction Regression — Issue #670

Timestamp: 2026-09-17T08-02
Task: [P1-T3]
Command: $r = Invoke-Pester -Path 'tests/scripts/claude-hooks/enforce-epic-merge-gate.Tests.ps1','tests/scripts/claude-hooks/enforce-epic-merge-gate.TriggerScoping.Tests.ps1','tests/scripts/codex-hooks/enforce-epic-merge-gate-decision-surface.Tests.ps1','tests/scripts/codex-hooks/enforce-epic-merge-gate-trigger-scoping.Tests.ps1' -PassThru; $r.FailedCount
EXIT_CODE: 0

Output Summary:
- `$r.FailedCount` = 0
- `$r.PassedCount` = 88 (reference value re-asserted by [P4-T5])
- TotalCount = 88; Skipped = 0; NotRun = 0.
- The factory extraction to `.claude/hooks/enforce-epic-merge-gate-authorization.ps1` plus the new dot-source in the parent is a pure move: all four existing suites stay green.
