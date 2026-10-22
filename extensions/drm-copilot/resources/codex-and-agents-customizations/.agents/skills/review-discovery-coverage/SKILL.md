---
name: review-discovery-coverage
description: 'Review selected discovery coverage and parity with authoritative reports and explicit findings. Use when asked for a structural, discovery-complete or parity-complete review.'
---

# Review Discovery Coverage

## When to Use This Skill

Use for a requested review of configured scope or a pinned snapshot. The reviewer reports readiness without editing underlying facts.

## Inputs

These are human-facing workflow selections, not additional service-request fields.
Supply explicit selections; neither omitted inputs nor profile roots create authority.

| Input | Required contract |
| --- | --- |
| profile | Required validated profile and trusted workspace binding. |
| scope | Required exact requested scope or explicit whole configured graph. |
| snapshot | Required selected current/pinned snapshot identity for the review. |
| mode | Required explicit structural, discovery-complete or parity-complete review mode. |

## Routing

Logical role: `migration-coverage-reviewer`.
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
| coverage-report | reports | Exact requested scope and mode |
| parity-report | reports | Exact requested scope and mode |
| completion-report | reports | Exact requested scope and mode |
| validation-report | reports | Exact requested selection and mode |
| required-output-manifest | reports | Exact invocation manifest only |

The profile keys are maximum configured locations, not write grants. Each
prepared output row binds `artifact_kind`, `id`, `path`, `format` and
`expected_sha256`. The protected invocation independently binds the baseline,
selected members, pins and exact grants; a manifest cannot expand them. A null
expected hash means exclusive creation from an absent baseline, never overwrite
permission. Preserve unselected collection members and all unrelated inputs.
Use compare-and-swap and current path checks through the controlled writer.

Only exact selected reports and the invocation manifest may be written. A profile
report root and a validation report pair never grant report-root-wide writes.

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
   Use `skill_id=review-discovery-coverage`; workflow inputs do not add wire fields.
3. The root launches that exact deployment. Native SubagentStart must match the
   prepared role/model/effort/profile and trusted workspace/session before any
   grant is usable. Missing capability or attestation blocks the action.
4. Use only the granted operations. Use `validate_discovery_artifacts` and `run_discovery_report` through the authoritative fixed validation/report operations in the requested mode. Use bounded `read_discovery_source` for selected supporting inputs only. Do not guess artifact types by first-success validation. Do not create a second graph/schema engine or infer readiness from report existence.
5. At least one required report must be recomputable structured JSON in the invocation's requested review mode. Preserve all findings for the requested scope and explicit PASS/FAIL. Do not update inventory, coverage ledger, contracts, parity entries, evidence, decisions or configuration to force a pass. The validate-all canonical report pair does not grant report-root-wide writes.
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

A valid FAIL report may finish as `output-valid/result-fail`; it never authorizes discovery, parity or planning completion. Missing required reports still block output validity. Review status and completion authority remain separate.

Structural success is not discovery, parity or planning completion.
Missing prepare/finalize/start/stop capability, missing outputs, invalid claims,
unresolved required work, wrong role/model/start context or a stale/missing
receipt blocks successful completion. Return explicit
PASS, FAIL or BLOCKED, distinguishing valid incremental outputs from a passing
completion gate. Missing native enforcement remains BLOCKED even when ordinary
local-user operations can run; do not substitute CLI success for native authority.

## References

- [Canonical migration-coverage-reviewer contract](../../../.codex/agents/migration-coverage-reviewer.toml)
- Installed v2 `service-request` and `required-output-manifest` schema contracts;
  consume them through the authoritative runtime, with no checkout-schema fallback.
- The selected profile and pinned local artifacts supplied for this invocation;
  references do not preload catalogs or grant access to unselected paths.
