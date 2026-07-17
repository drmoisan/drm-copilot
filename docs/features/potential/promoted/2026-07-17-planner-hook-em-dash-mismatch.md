# planner-hook-em-dash-mismatch (Issue #357)

- Date captured: 2026-07-17
- Author: Dan Moisan
- Status: Promoted -> docs/features/active/planner-hook-em-dash-mismatch/ (Issue #357)

> Automation note: Keep the section headings below unchanged; the promotion tooling maps each of them into the GitHub bug issue template.

- Issue: #357
- Issue URL: https://github.com/drmoisan/drm-copilot/issues/357
- Last Updated: 2026-07-17
## Summary

The `atomic-planner` `SubagentStop` hook (`.claude/hooks/validate-planner-output.ps1`) requires an ASCII hyphen in phase headings (`### Phase N - <Title>`), but the atomic-plan-contract, the `atomic-planner` agent instructions, and both canonical structural validators (Python and TypeScript) all specify and accept an em dash (`### Phase N — <Title>`). The hook therefore rejects every correctly-formatted plan.

## Environment

- OS/version: Windows 11 (repo also runs on GitHub Actions `windows-latest`/`ubuntu-latest` runners)
- Python version: n/a (PowerShell hook)
- Command/flags used: any `atomic-planner` subagent invocation; hook runs on `SubagentStop`
- Data source or fixture: `tests/scripts/claude-hooks/validate-planner-output.Tests.ps1` (uses ASCII-hyphen fixtures that match the buggy regex, so it does not catch the mismatch)

## Steps to Reproduce

1. Have `atomic-planner` produce a plan using the canonical `### Phase N — <Title>` heading format specified in `.claude/skills/atomic-plan-contract/SKILL.md` and `.claude/agents/atomic-planner.md`.
2. Let the `SubagentStop` hook `.claude/hooks/validate-planner-output.ps1` run against the plan.
3. Observe the hook reports `Line N: phase heading must match `### Phase N - <Title>`.` and blocks termination, even though the plan matches the documented contract.

Reproduces identically against the already-merged `folder-probability-plumbing-324` plan from the prior epic, confirming this is systemic (every plan produced under the current contract uses the em dash) rather than specific to any one plan.

## Expected Behavior

The hook should accept the em-dash (`U+2014`) phase-heading format that the atomic-plan-contract, the atomic-planner agent, and the canonical Python/TypeScript structural validators all specify and accept.

## Actual Behavior

The hook's `$phasePattern` regex (`.claude/hooks/validate-planner-output.ps1` line 121) is `'^### Phase (?<Phase>\d+)\s+-\s+(?<Title>.+)$'`, which requires a plain ASCII hyphen. Every plan produced per the actual contract uses an em dash and fails this check, producing a false-positive block on plan approval.

## Logs / Screenshots

- [x] Attached minimal logs or screenshot
- Snippet: `atomic-planner hook: plan '<path>' violates the atomic plan contract:\n  - Line N: phase heading must match \`### Phase N - <Title>\`.`

## Impact / Severity

- [ ] Blocker
- [x] High
- [ ] Medium
- [ ] Low

## Suspected Cause / Notes

Introduced at commit `8a5ce696` (`fix(orchestration): enforce delegated plan preflight validation`), which authored the current hook with the ASCII-hyphen regex. At that same commit, `.claude/skills/atomic-plan-contract/SKILL.md` already specified the em-dash format — the hook was never aligned to the contract. Related files:

- `.claude/hooks/validate-planner-output.ps1` (line 121: `$phasePattern`; line 137: error message string)
- `tests/scripts/claude-hooks/validate-planner-output.Tests.ps1` (fixtures use ASCII hyphen throughout, masking the bug)
- `.claude/skills/atomic-plan-contract/SKILL.md` (line 19: canonical em-dash spec)
- `.claude/agents/atomic-planner.md` (line 44: em-dash spec given to the planning agent)
- `scripts/dev_tools/validate_orchestration_artifacts.py` (line 33: `PLAN_PHASE_RE`, correctly uses em dash)
- `extensions/drm-copilot/src/lib/validate/orchestration-artifacts.ts` (line 47: `PLAN_PHASE_RE`, correctly uses em dash)

## Proposed Fix / Validation Ideas

- [x] Unit coverage areas: add an em-dash regression test to `validate-planner-output.Tests.ps1` asserting a plan with `### Phase 0 — Baseline` passes; update the existing ASCII-hyphen fixtures to em dash so the suite matches the real contract instead of masking the bug.
- [ ] Integration scenario to retest: re-run `atomic-planner` against a plan and confirm the hook allows termination.
- [x] Manual verification notes: change `$phasePattern` on line 121 to `'^### Phase (?<Phase>\d+) — (?<Title>.+)$'` and update the line-137 error message to reference the em dash.

## Next Step

- [x] Promote to GitHub issue (bug-report template)
- [x] Move to active fix folder / branch
