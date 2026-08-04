# mixed-promotion-agent-delegation-receipts (Issue #435)

- Date captured: 2026-08-04
- Author: Dan Moisan
- Status: Promoted -> docs/features/active/mixed-promotion-agent-delegation-receipts/ (Issue #435)

> Automation note: Keep the section headings below unchanged; the promotion tooling maps each of them into the GitHub bug issue template.

- Issue: #435
- Issue URL: https://github.com/drmoisan/drm-copilot/issues/435
- Last Updated: 2026-08-04
- Work Mode: full-bug

## Summary

The canonical orchestrator checkpoint cannot retain raw lifecycle promotion
receipts and strict-completion agent delegation receipts at the same time.
Both receipt classes are assigned incompatible shapes under
`delegation_receipts`. The canonical representation must be a namespaced
object with an `agents` list for strict delegation receipts and a `promotion`
object for opaque lifecycle payloads, while preserving the currently accepted
legacy representations.

## Environment

- OS/version: Windows 11
- Python version: Repository-supported Poetry environment
- Command/flags used: `validate_orchestration_artifacts` with orchestrator-state completion, Codex topology, and model-routing gates
- Data source or fixture: A large-route checkpoint containing lifecycle promotion receipts and required agent receipts

## Steps to Reproduce

1. Store the policy-required raw promotion receipts under
   `delegation_receipts.promotion.*`.
2. Add the large-route agent delegation receipts required by strict completion.
3. Run strict completion, Codex topology, legacy model-routing, and Codex
   model-routing validation.

## Expected Behavior

The checkpoint accepts this canonical mixed representation and every strict
reader consumes the named agents:

```json
{
  "delegation_receipts": {
    "agents": [
      {
        "step": "S4_atomic_planning",
        "agent_name": "atomic-planner",
        "agent_id": "agent-1",
        "skill_source": "orchestrator-workflow",
        "started_at": "2026-08-04T10:00:00Z",
        "completed_at": "2026-08-04T10:01:00Z",
        "result_signal": "PREFLIGHT: ALL CLEAR",
        "artifact_paths": ["docs/features/active/example/plan.md"]
      }
    ],
    "promotion": {
      "potential_entry": "<opaque raw payload>",
      "issue": "<opaque raw payload>",
      "feature_folder": "<opaque raw payload>"
    }
  }
}
```

The legacy top-level receipt-list and promotion-only object forms remain
accepted.

## Actual Behavior

Object-form `delegation_receipts` permits only `promotion`, while list form is
required for agent receipt collection. Object form therefore reports all
required agent receipts missing, and replacing it with list form discards the
canonical promotion-receipt namespace.

## Logs / Screenshots

- [x] Attached minimal logs or screenshot
- Snippet: `delegation_receipts: object key 'agents' is not allowed`; strict completion then reports missing required agent receipts when only `promotion` is present.

## Impact / Severity

- [x] Blocker
- [ ] High
- [ ] Medium
- [ ] Low

## Suspected Cause / Notes

`validate_orchestrator_state.py` validates list-form agents or object-form
promotion receipts, while routing, topology, and model-routing collectors read
agents only from list form. A compatible object form should allow exactly
`agents` and `promotion`, while retaining legacy list acceptance. The
TypeScript MCP validation and reader surfaces mirror this split and must follow
the same contract to keep `validate_orchestration_artifacts` consistent with
the Python completion path.

## Proposed Fix / Validation Ideas

- [x] Unit coverage areas: state shape, routing completion, Codex topology, and Codex model-routing validators
- [x] Integration scenario to retest: a complete large-route checkpoint containing both receipt classes
- [x] Manual verification notes: retain legacy list-form and promotion-only object-form compatibility

The implementation must validate `agents` as a list through the existing
strict receipt validator; promotion child values remain opaque raw payloads.
Unknown top-level namespaces, unknown promotion child keys, malformed agent
receipts, non-list `agents`, and non-object `promotion` must continue to fail
with explicit validation errors.

## Next Step

- [ ] Promote to GitHub issue (bug-report template)
- [ ] Move to active fix folder / branch
