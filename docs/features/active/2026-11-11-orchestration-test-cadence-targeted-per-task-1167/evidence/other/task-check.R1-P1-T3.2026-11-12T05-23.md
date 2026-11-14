# Task Check [R1 P1-T3] (task-check evidence; not a gate, no coverage measured)

Timestamp: 2026-11-12T05-23
Command: sh SCRATCH/issue-1167-tc-p1t3.sh (cp of the bug template to its bundle with cmp; sh SCRATCH/issue-1167-pester-tc.sh <4 Pester files>; sh SCRATCH/issue-1167-pytest-tc.sh <7 pytest files>, pytest -n auto --no-cov)
EXIT_CODE: 0
Output Summary:
- Format, lint, type check: not applicable (Markdown template only).
- Bundle: the bug template is byte-identical to its bundle copy (cmp exit 0).
- Pester run: 356 passed, 2 failed (raw PESTER_EXIT=1). The two failures are exactly the red-window rows the plan excludes from this task check (`## Terms and Standing Rules`): TCW-TEMPLATE-BUG and TCW-TEMPLATE-BUG-BUNDLE, each reporting 2 `[phase-gate]` checkbox lines where the pre-[P1-T5] row pins 1. They are updated in [P1-T5]. On the selection with those rows excluded: 356 passed, 0 failed.
- pytest selection: 84 passed, 0 failed (PYTEST_EXIT=0), including test_plan_templates_carry_premortem_skeleton.
- parallel-gate-wording.Tests.ps1: passing, unchanged.

Changed files:
- docs/features/templates/bug/plan.yyyy-MM-ddTHH-mm.md (`**Phase 1 — Preparation**` line marked as a no-change phase; `[P2-T2]` replaced by the `[phase-gate]` task that accepts the expected failures of [P2-T1]; `[P3-T2]` unchanged)
- extensions/drm-copilot/resources/feature-templates/bug/plan.yyyy-MM-ddTHH-mm.md (byte copy)

Selection rule: tests found by searching `tests/` for the template path and file name: test-cadence-wording.Tests.ps1 (TCW-TEMPLATE-BUG rows excluded per the plan), parallel-gate-wording.Tests.ps1 and planning-contract-wording.Tests.ps1 (template sweeps), ProcessReductionChain.Tests.ps1 (feature-template bundle mapping); test_single_pass_preflight_contracts.py (template skeleton and bundle equality), the five new-active-feature-folder suites under tests/scripts/dev_tools/ (bug-template handling), and test_push_down_claude_resource_contracts.py.
