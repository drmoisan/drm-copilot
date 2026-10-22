---
name: initialize-discovery-workspace
description: 'Initialize or explicitly configure a discovery workspace through root-owned operations before constrained review. Use when asked to bootstrap a discovery workspace or preview its initial structure.'
---

# Initialize Discovery Workspace

## When to Use This Skill

Use when a workspace needs explicit bootstrap inputs or controlled configuration. Missing initial configuration is allowed only for the root bootstrap stage.

## Inputs

These are human-facing workflow selections, not additional service-request fields.
Supply explicit selections; neither omitted inputs nor profile roots create authority.

| Input | Required contract |
| --- | --- |
| system_id | Required explicit system identity, independently of system_name. |
| system_name | Required explicit display name; do not infer it from repository paths. |
| repository_id | Required explicit repository identity. |
| repository_role | Required explicit supported repository role. |
| roots | Required explicit source/test/documentation and other applicable roots, or honest draft choices. |
| draft_inputs | Optional explicit draft/unknown inputs when completeness is not established. |
| dry_run | Required explicit preview intent; dry-run creates no configuration or authority. |
| profile_selection | Optional explicit profile selection for root configure; no ancestor or checkout inference. |

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
| validation-report | reports | Exact projected/resulting structural review |
| coverage-report | reports | Exact projected/resulting structural review |
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

Missing or malformed configuration blocks delegation. This is the sole missing-profile bootstrap exception: only the root may call `run_discovery_init`/`configure_discovery_workspace` with explicit inputs. Validate any existing configuration; do not bypass malformed state. Root configuration outputs are outside the reviewer's output table and grants. A missing valid projected/resulting context blocks reviewer preparation.

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

1. The root validates explicit bootstrap inputs, calls `run_discovery_init` mapped to `init`, and uses `configure_discovery_workspace` mapped to `configure` only for explicit profile selection/activation. Preserve no-overwrite conflict/skip behavior and dry-run no-effects semantics. Do not inspect ancestors or read arbitrary templates. Obtain a valid projected/resulting configuration before preparing the reviewer; a dry-run projection is not an activated workspace or host authority.

2. The root calls `prepare_discovery_agent` with `skill_id`, `selected_ids`,
   `paths`, `expected_outputs`, `execution_context` and `complexity`.
   Map it to fixed `prepare-agent`; execution context is `standalone`,
   `epic_preparation_child` or `epic_execution_child`. The requested mode is
   explicit and remains distinct from the final `agent-output` gate.
   Use `skill_id=initialize-discovery-workspace`; workflow inputs do not add wire fields.
3. The root launches that exact deployment. Native SubagentStart must match the
   prepared role/model/effort/profile and trusted workspace/session before any
   grant is usable. Missing capability or attestation blocks the action.
4. Use only the granted operations. After root bootstrap, the reviewer uses `validate_discovery_artifacts` for the exact projected/resulting structural review and its selected report pair. The reviewer writes exact reports, never configuration, and never receives profile, locator, activation, authority or installation writes. If the native provider cannot prepare a review for the valid projected context, return BLOCKED instead of inventing a persisted profile.
5. A truthful initialized draft may pass structural validation while discovery-complete, parity-complete and planning remain blocked. Review only root-supplied projected/resulting inputs and exact reports; preserve draft/unknown markers and empty-scope distinctions. Root local-user CLI success cannot serve as a native reviewer invocation or protected receipt.
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

Return root initialization/configuration results and the separately authorized reviewer result. If a preview leaves required stored outputs absent, finalization remains blocked; never fabricate writes or receipts. A dry-run or draft structure is not completed discovery; unavailable reviewer capability remains an explicit block even if root bootstrap succeeded.

Structural success is not discovery, parity or planning completion.
Missing prepare/finalize/start/stop capability, missing outputs, invalid claims,
unresolved required work, wrong role/model/start context or a stale/missing
receipt blocks successful completion. Return explicit
PASS, FAIL or BLOCKED, distinguishing valid incremental outputs from a passing
completion gate. Missing native enforcement remains BLOCKED even when ordinary
local-user operations can run; do not substitute CLI success for native authority.

## References

- [Canonical migration-coverage-reviewer contract](../../../.claude/agents/migration-coverage-reviewer.md)
- Installed v2 `service-request` and `required-output-manifest` schema contracts;
  consume them through the authoritative runtime, with no checkout-schema fallback.
- The selected profile and pinned local artifacts supplied for this invocation;
  references do not preload catalogs or grant access to unselected paths.
