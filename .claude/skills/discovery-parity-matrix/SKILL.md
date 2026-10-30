---
name: discovery-parity-matrix
description: 'Dispatch parity reconciliation to the canonical Requirements Reconciler workflow. Use when invoking the existing discovery parity-matrix alias.'
---

# Discovery Parity Matrix Alias

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
| fixed | reconcile-parity-matrix |

Dispatch directly to `reconcile-parity-matrix`, whose logical role is `requirements-reconciler`. Do not route parity ownership to Legacy Parity Analyst or bypass the canonical root preparation.

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

- [reconcile-parity-matrix](../reconcile-parity-matrix/SKILL.md)
