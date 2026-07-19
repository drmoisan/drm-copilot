# Legacy Discovery and Parity

The `legacy-discovery-and-parity` capability is a reusable, domain-neutral framework for
agentic discovery of legacy-system behavior and source-to-target parity definition. A
repository migrating a legacy application to a modern architecture uses this capability
to inventory its current behavior, characterize runtime behavior, define source-to-target
parity, reconcile unspecified or contradictory behavior into product decisions, and
generate executable acceptance scenarios — all through validated, versioned artifacts.

This directory is the capability-level documentation index. Each topic page below covers
one area of the capability end to end and links to the owning functional feature's own
reference documentation instead of restating it.

## Domain-Neutrality Invariant

**Invariant: the framework contains no domain-specific behavior.** No
TaskMaster/TMW/Outlook/VSTO/email/task-management behavior is framework behavior anywhere
in this capability. All domain specificity — the legacy source location, the target
location, the technology stack, and artifact conventions — is supplied at runtime through
the domain profile (see [`domain-profile.md`](domain-profile.md)). TaskMaster and TMW
appear in this documentation set only as worked onboarding examples in
[`consumer-onboarding.md`](consumer-onboarding.md); they are never described as framework
behavior.

## Audience

- **Consumer-repository engineer** — an engineer in a repository migrating a legacy
  application to a modern architecture. Start with [`workflow.md`](workflow.md) for the
  end-to-end sequence, then [`domain-profile.md`](domain-profile.md) to author your
  repository's configuration, then [`running-the-workflow.md`](running-the-workflow.md) to
  invoke the workflow, and [`artifacts-and-schemas.md`](artifacts-and-schemas.md) to
  understand what gets produced and validated.
- **`drm-copilot` maintainer onboarding a consumer repository** — start with
  [`consumer-onboarding.md`](consumer-onboarding.md) for how the capability is delivered
  to a consumer repository through the push-down tooling.

## Topic Pages

| Page | Covers |
|---|---|
| [`workflow.md`](workflow.md) | The end-to-end discovery/parity workflow: the activity sequence from workspace initialization through validated artifacts to rendered reports and generated acceptance scenarios. |
| [`domain-profile.md`](domain-profile.md) | Domain-neutral authoring of the domain-profile configuration contract: legacy source location, target location, technology stack, and artifact conventions. |
| [`artifacts-and-schemas.md`](artifacts-and-schemas.md) | The seven versioned discovery artifact schemas, the schema-versioning convention, validation, and completion-gate enforcement. |
| [`running-the-workflow.md`](running-the-workflow.md) | The three invocation surfaces — CLI, MCP tools, and VS Code commands — documented in that order. |
| [`consumer-onboarding.md`](consumer-onboarding.md) | How a consumer repository receives the capability through the push-down tooling, with TaskMaster and TMW as worked examples. |

## Capability Provenance

This capability is delivered by the `legacy-discovery-and-parity` epic as a set of
functional features, each with its own per-feature reference documentation inside its own
pull request. This documentation set is the capability-level layer that ties those
features together; it links to, and does not duplicate, each feature's own reference docs.
