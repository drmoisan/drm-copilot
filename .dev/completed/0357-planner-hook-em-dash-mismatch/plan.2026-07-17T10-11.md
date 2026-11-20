# planner-hook-em-dash-mismatch-357 (Plan)

- **Issue:** #357
- **Parent (optional):** none
- **Owner:** drmoisan
- **Last Updated:** 2026-07-17T10-11
- **Status:** Draft
- **Version:** 0.2

**Work Mode:** minor-audit (per `docs/features/active/planner-hook-em-dash-mismatch-357/issue.md` metadata). `issue.md` is the sole requirements source; its `## Acceptance Criteria` section is the sole acceptance-criteria source. `spec.md` and `user-story.md` are not required and must not be treated as blockers if absent.

**Change budget:** exactly 2 files in scope — `.claude/hooks/validate-planner-output.ps1` (production) and `tests/scripts/claude-hooks/validate-planner-output.Tests.ps1` (test). No other file may be modified under this plan.

**Fail-closed evidence rule:** Include explicit baseline artifact tasks, final-QA artifact tasks, and coverage-comparison tasks for each in-scope language when policy requires coverage. If any required baseline artifact, QA artifact, or coverage-comparison artifact is missing, the audit verdict must be BLOCKED or INCOMPLETE, never PASS.

**Evidence accounting rule:** Record the expected artifact path or location in each evidence-producing task. Do not mark evidence-backed work complete without the artifact. All evidence is written under `docs/features/active/planner-hook-em-dash-mismatch-357/evidence/<kind>/`.

### Phase 0 — Baseline
- [x] [P0-T1] Read CLAUDE.md, .claude/rules/general-code-change.md, .claude/rules/general-unit-test.md, and .claude/rules/powershell.md in that order and record docs/features/active/planner-hook-em-dash-mismatch-357/evidence/baseline/phase0-instructions-read.md with `Timestamp:`, `Policy Order:`, and the explicit list of files read
- [x] [P0-T2] Run mcp__drm-copilot__run_poshqc_format scoped to .claude/hooks/validate-planner-output.ps1 and tests/scripts/claude-hooks/validate-planner-output.Tests.ps1 to capture pre-change format state and write docs/features/active/planner-hook-em-dash-mismatch-357/evidence/baseline/poshqc-format-baseline.md with `Timestamp:`, `Command:`, `EXIT_CODE:`, and `Output Summary:`
- [x] [P0-T3] Run mcp__drm-copilot__run_poshqc_analyze scoped to .claude/hooks/validate-planner-output.ps1 and tests/scripts/claude-hooks/validate-planner-output.Tests.ps1 to capture pre-change analyzer findings and write docs/features/active/planner-hook-em-dash-mismatch-357/evidence/baseline/poshqc-analyze-baseline.md with `Timestamp:`, `Command:`, `EXIT_CODE:`, and `Output Summary:`
- [x] [P0-T4] Run mcp__drm-copilot__run_poshqc_test scoped to tests/scripts/claude-hooks/validate-planner-output.Tests.ps1 using scripts/powershell/PoshQC/settings/pester.runsettings.psd1 to capture pre-change pass/fail state and numeric line/branch coverage, and write docs/features/active/planner-hook-em-dash-mismatch-357/evidence/baseline/poshqc-test-baseline.md with `Timestamp:`, `Command:`, `EXIT_CODE:`, and `Output Summary:` including the baseline line-coverage and branch-coverage percentages

### Phase 1 — Regression Test (Fail-Before)
- [x] [P1-T1] Add a new `It` case to tests/scripts/claude-hooks/validate-planner-output.Tests.ps1 named to assert that a plan whose fixture lines use `### Phase 0 — Baseline` (em dash, U+2014) phase headings passes `Invoke-PlannerOutputValidation`/`Get-PlanStructureValidationReport`
- [x] [P1-T2] [expect-fail] Run mcp__drm-copilot__run_poshqc_test scoped to the single new em-dash `It` case added in tests/scripts/claude-hooks/validate-planner-output.Tests.ps1 against the current unmodified .claude/hooks/validate-planner-output.ps1 regex, confirm the test fails, and write docs/features/active/planner-hook-em-dash-mismatch-357/evidence/regression-testing/em-dash-fail-before.md with `Timestamp:`, `Command:`, `EXIT_CODE:`, and `Output Summary:` describing the observed failure

### Phase 2 — Minimal Fix
- [x] [P2-T1] Update the `$phasePattern` regex at .claude/hooks/validate-planner-output.ps1 line 121 to match `### Phase N — <Title>` using an em dash (U+2014) in place of the ASCII hyphen, matching the pattern shape used by PLAN_PHASE_RE in scripts/dev_tools/validate_orchestration_artifacts.py
- [x] [P2-T2] Update the phase-heading error message text at .claude/hooks/validate-planner-output.ps1 line 137 so it references the em-dash heading form `### Phase N — <Title>` instead of the ASCII-hyphen form
- [x] [P2-T3] Update the `.DESCRIPTION` comment-based-help line at .claude/hooks/validate-planner-output.ps1 line 17 referencing `### Phase N - <Title>` so it documents the em-dash heading form `### Phase N — <Title>` for consistency with the corrected regex
- [x] [P2-T4] Update every ASCII-hyphen `### Phase N - <Title>` fixture heading in tests/scripts/claude-hooks/validate-planner-output.Tests.ps1 (the fixtures in the "blocks when Phase 0 baseline and policy-read tasks are missing", "blocks when a task omits an explicit path", and "allows termination when the plan satisfies the structural contract" cases) to use the em-dash form `### Phase N — <Title>`
- [x] [P2-T5] Run mcp__drm-copilot__run_poshqc_test scoped to the em-dash `It` case added in tests/scripts/claude-hooks/validate-planner-output.Tests.ps1 in Phase 1 against the corrected .claude/hooks/validate-planner-output.ps1 and confirm it now passes, writing docs/features/active/planner-hook-em-dash-mismatch-357/evidence/regression-testing/em-dash-pass-after.md with `Timestamp:`, `Command:`, `EXIT_CODE:`, and `Output Summary:`

### Phase 3 — Final QA
- [x] [P3-T1] Run mcp__drm-copilot__run_poshqc_format scoped to .claude/hooks/validate-planner-output.ps1 and tests/scripts/claude-hooks/validate-planner-output.Tests.ps1 and write docs/features/active/planner-hook-em-dash-mismatch-357/evidence/qa-gates/poshqc-format-final.md with `Timestamp:`, `Command:`, `EXIT_CODE:`, and `Output Summary:`; if this step reformats either file, restart the loop from this task
- [x] [P3-T2] Run mcp__drm-copilot__run_poshqc_analyze scoped to .claude/hooks/validate-planner-output.ps1 and tests/scripts/claude-hooks/validate-planner-output.Tests.ps1 and write docs/features/active/planner-hook-em-dash-mismatch-357/evidence/qa-gates/poshqc-analyze-final.md with `Timestamp:`, `Command:`, `EXIT_CODE:`, and `Output Summary:`; if this step reports findings, remediate and restart the loop from P3-T1
- [x] [P3-T3] Run mcp__drm-copilot__run_poshqc_test scoped to tests/scripts/claude-hooks/validate-planner-output.Tests.ps1 using scripts/powershell/PoshQC/settings/pester.runsettings.psd1 with coverage enabled, confirm every test (including the em-dash regression test) passes, and write docs/features/active/planner-hook-em-dash-mismatch-357/evidence/qa-gates/poshqc-test-final.md with `Timestamp:`, `Command:`, `EXIT_CODE:`, and `Output Summary:` including the post-change line-coverage and branch-coverage percentages; if this step fails, remediate and restart the loop from P3-T1
- [x] [P3-T4] Compare the post-change coverage recorded in docs/features/active/planner-hook-em-dash-mismatch-357/evidence/qa-gates/poshqc-test-final.md against the baseline coverage recorded in docs/features/active/planner-hook-em-dash-mismatch-357/evidence/baseline/poshqc-test-baseline.md and write docs/features/active/planner-hook-em-dash-mismatch-357/evidence/qa-gates/coverage-delta.md with `Timestamp:`, baseline line/branch coverage, post-change line/branch coverage, coverage of the changed lines in .claude/hooks/validate-planner-output.ps1 (the two edited regex/message lines and the docstring line), and confirmation of no regression on either changed file
