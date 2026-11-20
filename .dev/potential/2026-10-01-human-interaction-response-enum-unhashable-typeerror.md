# human-interaction-response-enum-unhashable-typeerror (Potential Bug)

- Date captured: 2026-10-01
- Author: Dan Moisan
- Status: Draft
- Source: follow-up 6 of issue #484 (`docs/features/active/2026-09-29-orchestrator-remediation-loop-control-484/spec.md`, `## Rollout & Follow-up`)

> Automation note: Keep the section headings below unchanged; the promotion tooling maps each of them into the GitHub bug issue template.

## Summary

The Python human-interaction validator checks `response not in HUMAN_INTERACTION_RESPONSE_ENUM` in `scripts/dev_tools/_orchestrator_state_human_interaction.py`. If the enum is a set and `response` is a list or dict, the membership test raises `TypeError: unhashable type` instead of reporting a validation error. This is an inference from set semantics and has not been executed.

## Environment

- OS/version: any
- Python version: repository Poetry environment
- Command/flags used: `poetry run python -m scripts.dev_tools.validate_orchestration_artifacts orchestrator-state <checkpoint>`
- Data source or fixture: a checkpoint whose `human_interaction.requirements[]` entry has `"response": ["halt"]` or `"response": {}`

## Steps to Reproduce

1. Create a checkpoint with a `human_interaction.requirements[]` entry whose `response` is a list or an object.
2. Run the orchestrator-state validator on it.

## Expected Behavior

The validator reports a validation error naming the invalid `response` value and exits non-zero without a traceback.

## Actual Behavior

Unverified. The expected failure mode is an uncaught `TypeError`. This is the same defect class that #523 fixed for `blocked_reason`.

## Logs / Screenshots

- [ ] Attached minimal logs or screenshot
- Snippet: none; the behavior has not been executed.

## Impact / Severity

- [ ] Blocker
- [ ] High
- [ ] Medium
- [x] Low

## Suspected Cause / Notes

Membership tests against a `frozenset` hash the operand. Guard with an `isinstance(response, str)` check before the membership test, as #523 did for `blocked_reason`. Check the TypeScript and PowerShell twins for parity.

## Proposed Fix / Validation Ideas

- [ ] Unit coverage areas: list, dict, int, and None `response` values in all three runtimes
- [ ] Integration scenario to retest: the CLI exit code and message for a malformed checkpoint
- [ ] Manual verification notes: first execute the reproduction to confirm or falsify the inference

## Next Step

- [ ] Promote to GitHub issue (bug-report template)
- [ ] Move to active fix folder / branch
