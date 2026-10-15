# plan-validator-accepts-bare-scratch-paths (Issue #932)

- Date captured: 2026-10-15
- Author: Dan Moisan
- Status: Promoted -> docs/features/active/plan-validator-accepts-bare-scratch-paths/ (Issue #932)

> Automation note: Keep the section headings below unchanged; the promotion tooling maps each of them into the GitHub bug issue template.

- Issue: #932
- Issue URL: https://github.com/drmoisan/drm-copilot/issues/932
- Last Updated: 2026-10-15
- Work Mode: full-bug

## Summary

The scratch-location rule added by #900 (PR #922) has no preflight enforcement: a plan that defines SCRATCH as the bare scratchpad root still passes plan validation. The test guard is a fixed denylist.

## Environment

- OS/version: any
- Python version: n/a
- Command/flags used: see Steps
- Data source or fixture: main at f6915d42

## Steps to Reproduce

1. Write a plan that sets SCRATCH to the bare scratchpad root and run the plan validator; it passes.
2. `tests/scripts/dev_tools/test_scratch_location_contracts.py` `FORBIDDEN_SCRATCH_PATHS` (lines 93-100) lists six literals only.

## Expected Behavior

Plan preflight rejects a SCRATCH definition that is not namespaced by issue number.

## Actual Behavior

Only the executor-side mechanism and a literal denylist apply.

## Logs / Screenshots

- [x] Attached minimal logs or screenshot
- Snippet: #900 code-review.2026-10-12T17-38.md (Low advisory and Info rows); feature-audit.2026-10-12T17-38.md:56.

## Impact / Severity

- [ ] Blocker
- [ ] High
- [ ] Medium
- [x] Low

## Suspected Cause / Notes

The fix requires editing .claude/rules/plan-acceptance-gates.md, a policy file that needs operator approval. The .codex/agents TOML update was also noted as out of scope.

## Proposed Fix / Validation Ideas

- [ ] With operator approval, add a plan-acceptance gate rejecting bare SCRATCH definitions and implement it in the plan validator.
- [ ] Replace the literal denylist with a pattern check; update the .codex/agents TOML.

## Next Step

- [ ] Promote to GitHub issue (bug-report template)
- [ ] Move to active fix folder / branch