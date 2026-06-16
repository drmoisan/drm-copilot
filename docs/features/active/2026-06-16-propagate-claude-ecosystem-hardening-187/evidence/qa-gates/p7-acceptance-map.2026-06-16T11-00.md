# Phase 7 — Acceptance Criteria Mapping

- Timestamp: 2026-06-16T11-00
- Issue: #187
- Task: [P7-T5]

AC source (full-feature mode): `spec.md` and `user-story.md`.

## Item 1 — Test-HumanInteractionShape

- Function added to `validate-orchestrator-output.ps1` (canonical + both
  mirrors) and wired into `Invoke-OrchestratorOutputValidation`.
  - Code: `.claude/hooks/validate-orchestrator-output.ps1`; mirrors verified
    [P1-T5/T6], [P6-T1/T2].
- Passes absent-key; blocks missing-requirements, missing-response, out-of-enum,
  halt, exception-without-runbook (empty or non-existent).
  - Tests: `tests/scripts/claude-hooks/validate-orchestrator-output.Tests.ps1`
    (Context `Test-HumanInteractionShape`, 7 It blocks). Evidence: [P1-T4].
- Pester coverage via injectable `$FileExistsCheck` seam: present.

## Item 2 — Test-AutomationFeasibilitySection

- Function added to `validate-task-researcher-output.ps1` (canonical + both
  mirrors) and wired into `Invoke-TaskResearcherOutputValidation`.
  - Code: `.claude/hooks/validate-task-researcher-output.ps1`; mirrors verified
    [P2-T5/T6], [P6-T1/T2].
- Passes non-matching artifacts; requires `## Automation Feasibility` for
  artifacts matching `autonomous-execution|human-interaction`.
  - Tests: Context `Test-AutomationFeasibilitySection` + `feasibility gate
    wiring`. Evidence: [P2-T4].
- Pester coverage via injectable `$ReadFileContent` seam: present.

## Item 3 — Autonomous-Execution Mandate

- `## Autonomous-Execution Mandate` present in `orchestrate/SKILL.md` (canonical
  + both mirrors) with detection points, three permitted responses, exception-
  runbook requirement, and three named enforcement points.
  - Code: `.claude/skills/orchestrate/SKILL.md`. Section content matches SOURCE
    (verified [P3-T1]); mirrors [P3-T2], [P6-T1/T2].

## Item 4 — Human-Exception Runbook skill

- `skills/human-exception-runbook/SKILL.md` and `example.runbook.md` exist
  (canonical + both mirrors): canonical path, five required sections, MCP-first
  / web-second sourcing rule.
  - Code: `.claude/skills/human-exception-runbook/`. Created [P3-T3/T4];
    mirrors [P3-T5], [P6-T1/T2].

## Item 5 — human_interaction validator invariants

- `validate_orchestrator_state.py` enforces the three invariants in existing
  error-string style; schema not copied verbatim.
  - Code: `scripts/dev_tools/validate_orchestrator_state.py`
    (`_validate_human_interaction`). Evidence: [P4-T4].
- pytest covers the invariants + backward-compatibility case.
  - Tests: `tests/scripts/dev_tools/test_validate_orchestrator_state_human_interaction.py`
    (8 tests). Evidence: [P4-T4].
- `rules/orchestrator-state.md` documents the invariants additively without
  regressing existing prose.
  - Code: `.claude/rules/orchestrator-state.md`. Mirrors [P4-T5], [P6-T1/T2].

## Item 6 — general-unit-test.md sections

- `## Coverage Exclusion Policy` and `## Test File Location` present (canonical +
  both mirrors).
  - Code: `.claude/rules/general-unit-test.md`. Section bodies match SOURCE
    (verified [P5-T1/T2/T3]); mirrors [P6-T1/T2].

## Item 7 — Remediation handoff skill

- `remediation-handoff-atomic-planner/SKILL.md` matches the expanded SOURCE
  version (Full Handoff Chain, Required Artifacts entry-vs-exit timestamps, Plan
  Shape, Preflight Sub-Loop, Exit Gate) (canonical + both mirrors).
  - Code: `.claude/skills/remediation-handoff-atomic-planner/SKILL.md`.
    Byte-identical to SOURCE (verified [P5-T4]); mirrors [P5-T5], [P6-T1/T2].

## Mirror parity and toolchain

- Every canonical `.claude/` file changed/created is byte-identical in both
  mirrors: [P6-T1] (extensions, automated), [P6-T2] (mcp-server, manual).
- `settings.local.json` and `agent-memory/**` NOT propagated: [P6-T3].
- Bundle-sync contract tests pass: [P6-T1], [P7-T3].
- PowerShell toolchain (format/lint/Pester) passes: [P7-T1].
- Python toolchain (Black/Ruff/Pyright/Pytest) passes: [P7-T2].

## Conclusion

All spec and user-story acceptance criteria are satisfied with mapped code/test
locations and evidence artifacts.
