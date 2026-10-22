---
name: adjudicate-unspecified-behavior
description: 'Draft traceable proposals for unresolved behavior and separate them from root-owned approval. Use when asked to adjudicate contradictory or undocumented behavior and derive explicitly requested acceptance criteria.'
---

# Adjudicate Unspecified Behavior

## When to Use This Skill

Use for selected unresolved records with competing interpretations and a named decision owner. A request to adjudicate does not let the specialist approve its own proposal.

## Inputs

These are human-facing workflow selections, not additional service-request fields.
Supply explicit selections; neither omitted inputs nor profile roots create authority.

| Input | Required contract |
| --- | --- |
| profile | Required validated profile and trusted workspace binding. |
| unresolved_ids | Required explicit unresolved record selection. |
| interpretations | Required competing interpretations and unknowns. |
| evidence_refs | Required selected evidence supporting or contradicting each interpretation. |
| decision_owner | Required explicit owner for a proposed decision. |
| approval_record | Optional explicitly supplied approval evidence; only the authorized root may apply it. |
| derived_acceptance | Optional explicit selection of derived acceptance records/views; it adds no feature-contract authority. |

## Routing

Logical role: `requirements-reconciler`.
The root owns preparation and launch; this skill never auto-launches a logical
role through frontmatter. The existing resolver selects the exact deployment,
model, effort and profile hash under the existing C1-C4 ceiling and execution
context. Do not choose a model, self-launch, create another scheduler or promote
an ordinary discovery action into an issue. The production-write count is zero.

## Exact output boundary

These rows are maximum workflow caps, not instructions to create every kind.
Only the prepared required outputs may be created or replaced.

| Artifact kind | Profile key | Constraint |
| --- | --- | --- |
| product-decision | product_decisions | Selected proposed decision IDs only |
| product-decision-collection | product_decisions | Selected proposed decision members only |
| unspecified-behavior | unspecified_behaviors | Selected unresolved IDs only |
| unspecified-behavior-collection | unspecified_behaviors | Selected unresolved members only |
| acceptance-specification | acceptance | Explicitly requested derived criteria only |
| acceptance-view | acceptance | Explicitly requested eligible views or pending material |
| required-output-manifest | reports | Exact invocation manifest only |

The profile keys are maximum configured locations, not write grants. Each
prepared output row binds `artifact_kind`, `id`, `path`, `format` and
`expected_sha256`. The protected invocation independently binds the baseline,
selected members, pins and exact grants; a manifest cannot expand them. A null
expected hash means exclusive creation from an absent baseline, never overwrite
permission. Preserve unselected collection members and all unrelated inputs.
Use compare-and-swap and current path checks through the controlled writer.

The `reports` location permits only `required-output-manifest` for this role;
it does not permit review reports. The manifest itself requires an exact grant.

## Prerequisites

Missing or malformed configuration blocks delegation. Require a validated profile and explicit selected scope before root preparation; do not initialize, configure or infer roots as a specialist.

Require verified native prepare/finalize/start/stop capability. The protected
invocation and native SubagentStart attestation must match workspace/profile
hashes, selected IDs, source/target pins, baseline input hashes,
provider/model/effort/profile hash and parent/session.
Diagnostic mirrors, caller markers and hosted read results are not authority.
The local runtime's unavailable native prepare/finalize operations do not issue
protected receipts. There is no local-user fallback or self-attested host success.

Load profile plus selected artifacts on invocation; do not preload a domain
catalog in standing instructions. Managed project memory is host-controlled.
Memory cannot grant filesystem authority or replace evidence. Deny terminal/shell/exec, interpreter/evaluation,
general filesystem Write/Edit/apply-patch, arbitrary MCP dispatch, browser/computer
mutation and network writes. Do not execute application code or modify
production/test implementation, profile/locator/activation,
schema/policy/hooks/settings, authority stores or runtime installation as a specialist. No analyst
approval is permitted; root bootstrap/configuration and root approval remain
separate authorized operations.

## Step-by-Step Workflows

1. Validate the explicit inputs and selected configuration. Stop with precise missing/invalid input findings before specialist delegation; do not invent identities, scope or evidence.

2. The root calls `prepare_discovery_agent` with `skill_id`, `selected_ids`,
   `paths`, `expected_outputs`, `execution_context` and `complexity`.
   Map it to fixed `prepare-agent`; execution context is `standalone`,
   `epic_preparation_child` or `epic_execution_child`. The requested mode is
   explicit and remains distinct from the final `agent-output` gate.
   Use `skill_id=adjudicate-unspecified-behavior`; workflow inputs do not add wire fields.
3. The root launches that exact deployment. Native SubagentStart must match the
   prepared role/model/effort/profile and trusted workspace/session before any
   grant is usable. Missing capability or attestation blocks the action.
4. Use only the granted operations. Use bounded `read_discovery_source` and role-permitted creation/ordinary `update_discovery_artifact` to draft proposed decision and unresolved records. Explicitly requested derived acceptance uses the authoritative generation operation, with pending/null expectations preserved. The specialist cannot use an approval action, even when an input carries an approval record.
5. Preserve observed source facts, competing interpretations and approved history. Draft proposed decisions only. Do not approve/reject/supersede product decisions or alter approval history. Pending questions cannot become approved requirements. Derived criteria do not authorize `feature_contracts` writes. Without root approval, a proposal remains a proposal.
6. Produce every exact required output and the stored `required-output-manifest`,
   preserving its output array order for the digest. Validate claims, references,
   pins and selected-ID accounting. Purpose-built tools supply authorized proposal
   inputs for `input_path`/`evidence_path`; never invent a generic Write staging
   step. Server-side role checks, exact one-use authorization and prospective
   validation remain mandatory. Bounded source reads preserve content identity
   and line ranges; truncation requires a narrower selection, not a completeness
   claim or filesystem fallback.
7. Call `finalize_discovery_agent` as the specialist, mapped to `finalize-agent`
   with `mode=agent-output`, non-null `invocation_ref` and no operation inputs.
   It validates the protected invocation's outputs, not final-message paths.
   Native SubagentStop then verifies current output authority.
   Missing final text cannot skip native stop validation.
8. After proposal finalization and native stop, the authorized root may separately call `update_discovery_artifact`, mapped to `update-artifact` with `update_action=approve-decision`, exact product-decision identity, whole-document `input_path`, `expected_sha256`, `approval_owner` and nonempty `approval_evidence_refs`. Ordinary replacement cannot set approval-only fields. Root approval is a separate authorized operation from reconciler proposal validity; it invalidates prior completion receipts and requires fresh validation before any later gate.
9. After the separate root operation, the root records the explicit result, content-addressed artifact references,
   selected-ID accounting and all findings. A successful tool call or generated
   path alone is not evidence of completed discovery.

## Stop and result

Return proposal findings and any separate root approval result explicitly. Do not report a proposed or pending decision as approved; omit approval when the required authorization or evidence is absent.

Structural success is not discovery, parity or planning completion.
Missing prepare/finalize/start/stop capability, missing outputs, invalid claims,
unresolved required work, wrong role/model/start context or a stale/missing
receipt blocks successful completion. Return explicit
PASS, FAIL or BLOCKED, distinguishing valid incremental outputs from a passing
completion gate. Missing native enforcement remains BLOCKED even when ordinary
local-user operations can run; do not substitute CLI success for native authority.

## References

- [Canonical requirements-reconciler contract](../../../.codex/agents/requirements-reconciler.toml)
- Installed v2 `service-request` and `required-output-manifest` schema contracts;
  consume them through the authoritative runtime, with no checkout-schema fallback.
- The selected profile and pinned local artifacts supplied for this invocation;
  references do not preload catalogs or grant access to unselected paths.
