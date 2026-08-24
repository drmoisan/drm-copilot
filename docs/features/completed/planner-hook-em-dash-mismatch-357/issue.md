# planner-hook-em-dash-mismatch-357

- Work Mode: minor-audit
## Problem / Why
The `atomic-planner` `SubagentStop` hook (`.claude/hooks/validate-planner-output.ps1`, line 121) requires an ASCII hyphen in phase headings (`### Phase N - <Title>`), but the atomic-plan-contract (`.claude/skills/atomic-plan-contract/SKILL.md`), the `atomic-planner` agent instructions (`.claude/agents/atomic-planner.md`), and both canonical structural validators (`scripts/dev_tools/validate_orchestration_artifacts.py`, `extensions/drm-copilot/src/lib/validate/orchestration-artifacts.ts`) specify and accept an em dash (`### Phase N — <Title>`). The hook therefore rejects every correctly-formatted plan the planner produces, blocking the handoff from `epic-planner`/`atomic-planner` to `epic-orchestrator`/orchestrator on every invocation.

## Implementation Intent
Change the hook's `$phasePattern` regex and its associated error message to accept the canonical em-dash heading format, matching the contract and the other two validators. Update the existing Pester fixtures (which currently use ASCII hyphen and therefore mask the bug) to use the em dash, and add an explicit regression test asserting an em-dash heading passes validation.

## Acceptance Criteria
- [x] `Get-PlanStructureValidationReport` in `.claude/hooks/validate-planner-output.ps1` accepts `### Phase N — <Title>` (em dash) phase headings.
- [x] A new/updated Pester test in `tests/scripts/claude-hooks/validate-planner-output.Tests.ps1` proves a plan using the em-dash heading format passes validation (regression test, written to fail against the pre-fix regex).
- [x] Existing fixtures are updated to use the em dash so the suite reflects the real contract rather than masking the mismatch.
- [x] PoshQC format, analyze, and Pester toolchain all pass with no regressions.

## Dependencies / Risks
- Risk: an ASCII-hyphen plan (if any exist) would now be rejected; no such plans are known to exist post-`8a5ce696`, and the contract/agent instructions have specified the em dash since that commit.
- No dependency on other in-flight work.

## Verification Steps
1. Add a failing regression test using an em-dash fixture; confirm it fails against the current (unfixed) regex.
2. Apply the minimal regex/message fix.
3. Re-run the regression test and confirm it passes.
4. Run the full PowerShell toolchain (format → analyze → test) and confirm a clean pass.

## Evidence Checklist
- [x] baseline
- [x] targeted verification
- [x] end-state