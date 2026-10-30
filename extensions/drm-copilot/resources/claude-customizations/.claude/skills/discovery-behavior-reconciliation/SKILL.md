---
name: discovery-behavior-reconciliation
description: 'Dispatch unresolved behavior to canonical proposal and root-approval handling. Use when invoking the existing behavior-reconciliation alias.'
---

# Discovery Behavior Reconciliation Alias

## When to Use This Skill

Use this compatibility name only to dispatch to its canonical workflow.

## Inputs

| Input | Required contract |
| --- | --- |
| inputs | Required inputs of the linked canonical workflow, forwarded unchanged. |

Forward all other supplied canonical inputs to the selected target. These
alias selectors are not service-request fields. A fixed mapping requires no
additional selector; it does not add fields to `prepare-agent`.

## Dispatch

| Selector | Canonical skill |
| --- | --- |
| fixed | adjudicate-unspecified-behavior |

Dispatch directly to `adjudicate-unspecified-behavior`. The target separates specialist proposals from authorized root approval; this alias does not approve decisions.

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

- [adjudicate-unspecified-behavior](../adjudicate-unspecified-behavior/SKILL.md)
