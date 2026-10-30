---
name: characterize-runtime-behavior
description: 'Describe selected runtime scenarios from supplied captures or honest manual plans. Use when asked to characterize legacy behavior, record runtime evidence or prepare not-run and blocked scenarios.'
---

# Characterize Runtime Behavior

## When to Use This Skill

Use for explicit runtime scenarios with supplied environment and capability information. The specialist documents observations or manual plans; it does not execute applications.

## Inputs

These are human-facing workflow selections, not additional service-request fields.
Supply explicit selections; neither omitted inputs nor profile roots create authority.

| Input | Required contract |
| --- | --- |
| profile | Required validated profile and trusted workspace binding. |
| feature_ids | Required selected features and relevant contracts. |
| environment | Required recorded environment identity or explicit unavailable state. |
| fixtures | Required supplied fixture references or explicit absent/manual requirements. |
| preconditions | Required stated scenario preconditions; unknown facts remain unresolved. |
| actions | Required ordered manual actions or supplied action descriptions. |
| capability_mode | Required declared runtime capability and whether observations are supplied, manual, unavailable or blocked. |
| supplied_captures | Optional supplied captures and provenance; absence cannot become a passed result. |

## Routing

Logical role: `runtime-characterization-analyst`.
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
| runtime-characterization-scenario | characterization | Selected feature/scenario IDs only |
| evidence-reference | evidence | Explicitly supplied and granted evidence only |
| evidence-payload | evidence | Explicitly supplied and granted payloads only |
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
   Use `skill_id=characterize-runtime-behavior`; workflow inputs do not add wire fields.
3. The root launches that exact deployment. Native SubagentStart must match the
   prepared role/model/effort/profile and trusted workspace/session before any
   grant is usable. Missing capability or attestation blocks the action.
4. Use only the granted operations. Use bounded `read_discovery_source` for selected contracts, documentation, fixtures and supplied captures. Use `create_discovery_artifact` for fixed `new-scenario`, ordinary `update_discovery_artifact` and `link_discovery_evidence` for exact granted records. Register supplied metadata/payloads through controlled tools; never manufacture or collect new runtime captures by launching an application.
5. Every requested scenario needs a plan/result state. Known expectations stay separate from unknown expectations; unknown expectations stay null with unresolved references. A passed runtime result needs qualifying runtime evidence. Source inspection, static inference and a scenario plan are not runtime execution evidence. Valid manual/no-runtime tasks may end in not-run or blocked plans when those are the prepared outputs, without claiming behavior passed.
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

Account for each selected feature/scenario, supplied capture and missing capability. Output-valid manual plans do not prove runtime success or completion readiness.

Structural success is not discovery, parity or planning completion.
Missing prepare/finalize/start/stop capability, missing outputs, invalid claims,
unresolved required work, wrong role/model/start context or a stale/missing
receipt blocks successful completion. Return explicit
PASS, FAIL or BLOCKED, distinguishing valid incremental outputs from a passing
completion gate. Missing native enforcement remains BLOCKED even when ordinary
local-user operations can run; do not substitute CLI success for native authority.

## References

- [Canonical runtime-characterization-analyst contract](../../../.claude/agents/runtime-characterization-analyst.md)
- Installed v2 `service-request` and `required-output-manifest` schema contracts;
  consume them through the authoritative runtime, with no checkout-schema fallback.
- The selected profile and pinned local artifacts supplied for this invocation;
  references do not preload catalogs or grant access to unselected paths.
