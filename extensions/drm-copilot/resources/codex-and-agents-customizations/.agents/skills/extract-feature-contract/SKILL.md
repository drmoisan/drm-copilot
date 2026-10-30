---
name: extract-feature-contract
description: 'Extract evidence-backed feature contracts for selected legacy components and record unresolved behavior. Use when asked to document a feature contract from source, tests, documentation and supplied evidence.'
---

# Extract Feature Contract

## When to Use This Skill

Use for selected component or feature extraction after scope and source references are supplied. This workflow records source behavior without approving a target design.

## Inputs

These are human-facing workflow selections, not additional service-request fields.
Supply explicit selections; neither omitted inputs nor profile roots create authority.

| Input | Required contract |
| --- | --- |
| profile | Required validated profile and trusted workspace binding. |
| component_ids | Required explicit selected components; preserve unrelated coverage members. |
| feature_ids | Required explicit feature IDs, including IDs for proposed new contracts. |
| source_refs | Required selected source references with revision/content identity. |
| test_refs | Required explicit selection or honest empty set of relevant test references. |
| documentation_refs | Required explicit selection or honest empty set of documentation references. |
| evidence_refs | Required explicit selection or honest empty set of supplied evidence references. |

## Routing

Logical role: `legacy-parity-analyst`.
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
| feature-contract | feature_contracts | Selected feature IDs only |
| coverage-ledger | coverage_ledger | Selected component dispositions only |
| evidence-reference | evidence | Explicitly granted supporting evidence only |
| unspecified-behavior | unspecified_behaviors | Selected unresolved IDs only |
| unspecified-behavior-collection | unspecified_behaviors | Selected unresolved members only |
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
   Use `skill_id=extract-feature-contract`; workflow inputs do not add wire fields.
3. The root launches that exact deployment. Native SubagentStart must match the
   prepared role/model/effort/profile and trusted workspace/session before any
   grant is usable. Missing capability or attestation blocks the action.
4. Use only the granted operations. Use `read_discovery_source`, mapped to bounded `read-source`, for selected inputs. Use `create_discovery_artifact` for fixed `new-contract`, `update_discovery_artifact` for ordinary `update-artifact`, and `link_discovery_evidence` for `link-evidence`, only for exact prepared outputs. Do not infer source truth from a filename or a desired target behavior.
5. Account for every selected component/feature ID. Distinguish verified observations, inference and unknown facts; preserve precise source/evidence references and unresolved questions. Record unknown or contradictory behavior as unresolved. Never convert source facts into approved target requirements. Update only the selected coverage dispositions justified by inspection. Do not invent product decisions, target implementation evidence or successful runtime results.
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
8. After native stop, the root records the explicit result, content-addressed artifact references,
   selected-ID accounting and all findings. A successful tool call or generated
   path alone is not evidence of completed discovery.

## Stop and result

Return selected contract IDs and evidence digests with unresolved work. A structurally valid draft may be useful incremental output without satisfying discovery or planning completion.

Structural success is not discovery, parity or planning completion.
Missing prepare/finalize/start/stop capability, missing outputs, invalid claims,
unresolved required work, wrong role/model/start context or a stale/missing
receipt blocks successful completion. Return explicit
PASS, FAIL or BLOCKED, distinguishing valid incremental outputs from a passing
completion gate. Missing native enforcement remains BLOCKED even when ordinary
local-user operations can run; do not substitute CLI success for native authority.

## References

- [Canonical legacy-parity-analyst contract](../../../.codex/agents/legacy-parity-analyst.toml)
- Installed v2 `service-request` and `required-output-manifest` schema contracts;
  consume them through the authoritative runtime, with no checkout-schema fallback.
- The selected profile and pinned local artifacts supplied for this invocation;
  references do not preload catalogs or grant access to unselected paths.
