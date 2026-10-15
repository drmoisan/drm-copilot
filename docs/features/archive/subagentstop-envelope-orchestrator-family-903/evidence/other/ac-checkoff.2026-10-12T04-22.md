# AC Check-Off ([P7-T9])

Timestamp: 2026-10-12T04-22
Source: docs/features/active/subagentstop-envelope-orchestrator-family-903/spec.md, section `## Acceptance Criteria` (25 checkbox lines)
Basis: the Acceptance Criteria Map, the [P7-T8] static re-run (evidence/qa-gates/static-rerun.2026-10-12T04-21.md), and final clean pass 1 (evidence/qa-gates/final-qc-loop.2026-10-12T04-19.md).

CHECKED: AC-1, AC-2, AC-3, AC-4, AC-5, AC-6, AC-7, AC-8, AC-9, AC-10, AC-11, AC-12, AC-13, AC-14, AC-15, AC-16, AC-17, AC-18, AC-19, AC-20, AC-21, AC-22, AC-23, AC-24, AC-25
UNCHECKED: none

Already checked before this task (earlier phases): AC-1, AC-11, AC-15. Checked by this task: the other 22.

Evidence per AC:
- AC-2: evidence/regression-testing/orchestrator-pass-after.2026-10-12T03-49.md (E-ORC-1, E-ORC-2, E-ORC-3).
- AC-3: evidence/regression-testing/family-pass-after.2026-10-12T04-00.md (E-EXE-1, E-EXE-2).
- AC-4: family-pass-after (E-PLN-1, E-PLN-2, E-PLN-3).
- AC-5: family-pass-after (E-RA-1 to E-RA-4, E-RA-10).
- AC-6: orchestrator and family pass-after (E-ORC-4/5/8, E-EXE-3/4/7, E-PLN-4/5/7, E-RA-5/6/9).
- AC-7, AC-8, AC-9: evidence/qa-gates/ac7-claude-hook-input.2026-10-12T04-21.md, ac8-output-reads.2026-10-12T04-21.md, ac9-exit1-write-error.2026-10-12T04-21.md (each EXIT_CODE 1, no match).
- AC-10: evidence/qa-gates/named-rows.2026-10-12T04-19.md (E-ORC-7, E-EXE-5, E-RA-7, E-PLN-6 with stop_hook_active true; B1 rows for orchestrator and planner).
- AC-12: orchestrator-pass-after (S2-14, E-ORC-6).
- AC-13: evidence/qa-gates/ac13-cr7-comment.2026-10-12T04-21.md.
- AC-14: evidence/qa-gates/ac14-double-import.2026-10-12T04-21.md; hook-dependency-failure.Claude.Tests.ps1 passed in named-rows (359/359) and pester-full (5033/5033).
- AC-16: evidence/qa-gates/ac16-split.2026-10-12T04-21.md; artifact-type-dispatch suite and the AST no-Python row passed in named-rows.
- AC-17: evidence/qa-gates/line-counts.2026-10-12T04-21.md (OverLimitCount=0).
- AC-18: evidence/qa-gates/pester-coverage.2026-10-12T04-14.md and coverage-delta.2026-10-12T04-20.md (98.32 to 100 per file).
- AC-19: evidence/qa-gates/mirror-hashes.2026-10-12T04-03.md (MismatchCount=0), pytest-regression.2026-10-12T04-04.md (58 passed), jest-manifest.2026-10-12T04-04.md (16 passed), agent-mirror-hashes.2026-10-12T04-06.md, pytest-regression-agents.2026-10-12T04-07.md; core.json lists the routing sibling between the resolution and main entries (ordinal sorted position). The bundled-copy parity test (issue #510) passed locally in both runs, so no local-failure exception was needed.
- AC-20: evidence/regression-testing/registration-after-agent-edit.2026-10-12T04-07.md ([P5-T12] PassedCount=11, REG5_STATUS: KEPT); evidence/qa-gates/scope-boundary.2026-10-12T04-21.md (AGENTS_DIFF_COUNT: 1, .claude/agents/prd-feature.md, LANDED); evidence/other/prd-feature-registration.2026-10-12T04-06.md (LINE18_REQUIRED_ARTIFACT_COUNT: 1).
- AC-21: evidence/qa-gates/ac21-no-python.2026-10-12T04-21.md; enforcement-hooks-no-python-invocation.Tests.ps1 and the AST no-Python row passed in named-rows.
- AC-22: named-rows (39 REENTRY-ROW PASS; O-AST, X-AST, P-AST, R-AST, O-STR passed); evidence/qa-gates/ac22-stop-hook-active.2026-10-12T04-21.md.
- AC-23: evidence/qa-gates/scope-boundary.2026-10-12T04-21.md (OUT_OF_ALLOWLIST_COUNT: 0, FORBIDDEN_PATHS_FOUND: none).
- AC-24: final clean pass 1: format-check.2026-10-12T04-14.md (ChangedCount=0), pssa.2026-10-12T04-14.md (DiagnosticCount=0), pester-full.2026-10-12T04-15.md (5033/5033).
- AC-25: named-rows (four REG-3 rows and four REG-4 rows passed).

Count check: checked checkbox lines under `## Acceptance Criteria` = 25 (equals the CHECKED list length); unchecked = 0 (equals the UNCHECKED list length); total 25.
