---
name: discovery-workflow
description: 'Dispatch an explicit canonical discovery workflow without adding authority. Use when invoking the legacy discovery umbrella with a selected skill_id.'
---

# Discovery Workflow Alias

## When to Use This Skill

Use this compatibility name only to dispatch to its canonical workflow.

## Inputs

| Input | Required contract |
| --- | --- |
| skill_id | Required exact one of the nine canonical skill IDs listed below; unknown or missing values fail with no fallback. |

Forward all other supplied canonical inputs to the selected target. These
alias selectors are not service-request fields. A fixed mapping requires no
additional selector; it does not add fields to `prepare-agent`.

## Dispatch

| Selector | Canonical skill |
| --- | --- |
| inventory-legacy-system | inventory-legacy-system |
| extract-feature-contract | extract-feature-contract |
| characterize-runtime-behavior | characterize-runtime-behavior |
| reconcile-parity-matrix | reconcile-parity-matrix |
| review-discovery-coverage | review-discovery-coverage |
| adjudicate-unspecified-behavior | adjudicate-unspecified-behavior |
| generate-acceptance-scenarios | generate-acceptance-scenarios |
| initialize-discovery-workspace | initialize-discovery-workspace |
| validate-discovery-artifacts | validate-discovery-artifacts |

Select exactly one canonical workflow using `skill_id`. Forward its supplied inputs without inventing defaults or reinterpreting source identity. Each target owns its root prepare, exact launch, granted operations, finalize, native stop and root result; this umbrella adds no scheduler.

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
- [characterize-runtime-behavior](../characterize-runtime-behavior/SKILL.md)
- [reconcile-parity-matrix](../reconcile-parity-matrix/SKILL.md)
- [review-discovery-coverage](../review-discovery-coverage/SKILL.md)
- [adjudicate-unspecified-behavior](../adjudicate-unspecified-behavior/SKILL.md)
- [generate-acceptance-scenarios](../generate-acceptance-scenarios/SKILL.md)
- [initialize-discovery-workspace](../initialize-discovery-workspace/SKILL.md)
- [validate-discovery-artifacts](../validate-discovery-artifacts/SKILL.md)
