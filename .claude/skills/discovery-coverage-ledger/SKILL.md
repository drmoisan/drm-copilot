---
name: discovery-coverage-ledger
description: 'Dispatch explicit inventory, extraction or review without mixing coverage ownership. Use when invoking the existing coverage-ledger alias with action=inventory, extract or review.'
---

# Discovery Coverage Ledger Alias

## When to Use This Skill

Use this compatibility name only to dispatch to its canonical workflow.

## Inputs

| Input | Required contract |
| --- | --- |
| action | Required inventory, extract or review; reject missing, mixed or unknown actions with no fallback. |

Forward all other supplied canonical inputs to the selected target. These
alias selectors are not service-request fields. A fixed mapping requires no
additional selector; it does not add fields to `prepare-agent`.

## Dispatch

| Selector | Canonical skill |
| --- | --- |
| inventory | inventory-legacy-system |
| extract | extract-feature-contract |
| review | review-discovery-coverage |

`action=inventory|extract|review` selects the corresponding canonical workflow. Inventory and extraction use `legacy-parity-analyst`; review uses `migration-coverage-reviewer` with no reviewer ledger writes. These names describe the target's mapping and never authorize an unprepared logical-role launch.

This alias has no independent output or write authority. Do not duplicate
business validation, call tools independently, create a receipt, change a model
or auto-launch a role. Use only the linked canonical workflow's lifecycle and
exact grants; no alias chain or filesystem fallback is permitted.

## Stop and result

Return the selected canonical workflow's explicit result and references without
changing failed, blocked, pending or incremental outcomes into completion.
An unknown selector fails with no fallback. Missing configuration or native
capability is handled by the canonical workflow, including initialization's
explicit root bootstrap exception. The alias cannot bypass prepare/finalize or
native start/stop requirements.

## References

- [inventory-legacy-system](../inventory-legacy-system/SKILL.md)
- [extract-feature-contract](../extract-feature-contract/SKILL.md)
- [review-discovery-coverage](../review-discovery-coverage/SKILL.md)
