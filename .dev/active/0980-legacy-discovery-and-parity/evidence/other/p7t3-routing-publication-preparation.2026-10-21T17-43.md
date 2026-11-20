# P7-T3 routing and publication preparation

Timestamp (UTC): 2026-10-21T17:43:48Z

Status: PREPARATION_READY; accepted as preparation only. Authority: inventory_p7t3_preparation_20261021T173300. P7-T3 mutations remain gated on accepted P7-T1/T2 commits and coordinator release.

This artifact preserves the already returned read-only handoff. Preparation performed source/contract inspection only: no source, test, generated, policy, checkpoint, or Git changes; no tests, converter/generator execution, publication, or native capability probe. This Markdown preservation is the only write authorized by the follow-up. No additional research or validation was performed to save it.

## Retained inputs

- `plan.2026-10-17T22-38.md`, P7-T1/T2/T3, Set K/L, P8-T9 and P10-T1.
- `spec.md:509-515` for direct routing and protected invocation; `spec.md:581-587` for canonical/native publication.
- `evidence/other/p7-service-interface-delta.2026-10-20T17-14.md` for the nine workflow rows, exact P6 service fields, root/specialist separation, aliases, and unavailable-native stop conditions.
- `research/2026-10-18T02-40-runtime-publishing-research.md` for existing converter/publisher mechanisms. No duplicate research inventory was created.

## Proposed interface

Extend the existing topology resolver with `invocation_kind="ordinary" | "discovery"` and optional `skill_id`. Ordinary calls retain their existing receipt shape and behavior. Discovery requires zero production writes, rejects root-persona overrides, selects only the canonical skill mapping, and then uses the existing deployment resolver's C1-C4/context/ceiling/model-availability rules. Complexity remains independent of file count.

| Canonical skills | Logical role |
| --- | --- |
| inventory-legacy-system; extract-feature-contract | legacy-parity-analyst |
| characterize-runtime-behavior | runtime-characterization-analyst |
| reconcile-parity-matrix; adjudicate-unspecified-behavior; generate-acceptance-scenarios | requirements-reconciler |
| review-discovery-coverage; initialize-discovery-workspace; validate-discovery-artifacts | migration-coverage-reviewer |

Freeze each `discovery_operations` row as `logical_agent`, `output_contract_version`, `permissible_artifact_kinds`, and `gate_mode`. Use the retained v2 output contract and `agent-output` finalization gate. Requested structural/discovery/parity/planning review mode remains separate. Artifact kinds must be closed subsets of `packages/discovery-runtime/src/drm_copilot_discovery/agent_output.py:21-48`; a configured `reports` location does not grant every report kind. Initialization remains root bootstrap followed by a reviewer. Exact grants, selected members, source pins and output rows remain service/native responsibilities.

The discovery topology receipt explicitly identifies invocation kind, skill, selected role, contract version, kinds and gate. Its subsequent model receipt retains existing deployment fields. Neither receipt grants writes or replaces ordinary orchestration state. Protected `discovery-invocation` authority remains P8/P9 work; P7 does not claim implemented prepare/finalize/start/stop capability.

## Isolated ownership proposal

| Owner | Scope |
| --- | --- |
| Serialized contract owner | Canonical routing configuration, shared topology/deployment fixtures, exact mapping and receipt vocabulary |
| Python | Existing topology/deployment resolvers, variant-generator family inventory, Python parity tests |
| PowerShell | Existing routing modules, published topology CLI forwarding, direct and CLI parity tests |
| TypeScript | Existing topology/deployment resolvers and corresponding tests |
| Serialized conversion/publication owner | Accepted canonical roles/skills to native bases, variants, bundles/core manifests and exact profile-hash comparison |

Shared configuration and corpora have one writer. Conversion/publication follows frozen language implementations and accepted P7-T1/T2 canonical sources. No independent scheduler, issue promotion, alternate authority, or ordinary checkpoint replacement is introduced.

## Existing mechanisms and finite prerequisites

- Python topology/deployment: `scripts/dev_tools/resolve_codex_topology.py:167` and `resolve_codex_deployment.py:194`. PowerShell: `.claude/lib/codex-routing/CodexTopology.psm1:230` and `CodexDeployment.psm1`. TypeScript: `extensions/drm-copilot/src/lib/validate/codex-topology-resolver.ts:168` and `orchestrator-state-codex-model-routing.ts`. Discovery must branch before ordinary zero-count escalation and epic-child topology selection while retaining existing default behavior.
- Published CLI: `.codex/scripts/Resolve-CodexTopology.ps1:42-85` needs selector/skill argument parsing and forwarding, with its bundled mirror updated through existing publication. The CLI uses published `.codex/lib/codex-routing` or the existing repository `.claude/lib` fallback, without invoking Python.
- Shared corpus: `tests/fixtures/codex_routing/{topology,deployment}.json` is consumed by `tests/scripts/dev_tools/test_codex_routing_cli_corpus.py` and `tests/scripts/codex-scripts/Resolve-CodexRouting.Parity.Tests.ps1`. Preserve original cases; update the Python test's fixed 23-case assertion. Pester exercises every row through both process and in-process wrappers. Existing TypeScript resolver tests use inline cases; bind discovery expectations to the same frozen contract. Retain direct PowerShell resolver parity suites and Set L policy/family/wrapper/handoff checks.
- Conversion: `scripts/dev_tools/codex_native_converter/{mapping,pipeline,rewrites,validation}.py` and the TypeScript mirrors are the existing mechanism. `pipeline.py:90-140` embeds rewritten agent instructions; embedded YAML is not native tool authorization. Explicit tool/hook references require conversion validation. P8-T9 already owns broader native helper/hook classification; P7-T3 should not absorb that scope. The native Claude translation source is `.claude/skills/translate-copilot-to-claude/SKILL.md`; its Codex-migrated counterpart has rewritten target surfaces and must not be mistaken for Claude target paths.
- Variants: `scripts/dev_tools/generate_codex_agent_variants.py:33-44,123-221` uses existing deployment profiles and core manifests. Add the four families to the existing inventories and core membership; existing exact model slugs and C1/C2/C3/elevated-C3/C4 combinations need no redesign. Family recognition must not bypass unavailable native authority.
- Publication: existing Copilot/Claude/Codex publishers and core packs remain authoritative. `scripts/dev_tools/push_down_codex_and_agents_customizations.py:72-90` and its TypeScript counterpart explicitly enumerate virtual shared resources. Any necessary new PowerShell resolver helper needs an explicit resource pair and manifest membership; do not assume sibling files publish automatically.

Current measured size constraints: Python topology 291 lines, deployment 255, generator 295; PowerShell topology 394, deployment 315, CLI 96; TypeScript topology 270 and model-routing 487; Python converter rewrites 489 and pipeline 462; Set K role Pester test 485 and skill-contract Python test 415. Use cohesive helpers beside existing resolvers only where necessary to remain at or below 500 lines. Do not enlarge near-limit files without the concrete split prerequisite.

## Exact proposed P10 merge prerequisite

This is a consumer-publication prerequisite proposal, not authorization to change publishers during P7-T3. P7-T3 can retain its stated canonical configuration, resolver/generator, CLI and initial bundle-generation scope. P10 publishing must reconcile consumer configuration without erasing local policy.

Existing merge tests intentionally preserve destination top-level settings, local routes, order and idempotence. Replacing `codex_model_policy` wholesale would violate that contract. The smallest proposed rule is:

1. Append `discovery_operations` when absent; retain it when structurally identical; refuse the policy-file write when the fixed map conflicts. Do not merge caller-defined role/kind/gate overrides.
2. Within a compatible existing `codex_model_policy`, append only the four missing `generated_agent_families` in canonical order, preserving existing families and unrelated fields. Incompatible profile/context/ceiling semantics block discovery delivery rather than being overwritten.
3. Preserve all unrelated destination fields and existing ordinary/epic routing behavior. Refusal leaves the destination policy bytes unchanged and reports the incompatibility.

Concrete boundaries: `scripts/dev_tools/push_down_claude_routing_merge.py:9-23,121-155`, its TypeScript mirror `extensions/drm-copilot/src/lib/push-down/claude-routing-merge.ts`, and the applicable Codex publishing adapter. Claude already has the destination merge decorator; Codex currently exposes the mapped config through its passthrough adapter (`codex-agents-customizations.ts:321-356`). Any correction belongs to a separately recorded finite P10-T1 publishing prerequisite, with both language implementations and applicable adapter tests kept in parity.

Retain `tests/scripts/dev_tools/test_push_down_claude_routing_merge.py:54-115`, `test_push_down_claude_parity.py`, `extensions/drm-copilot/test/lib/push-down/claude-routing-merge-parity.test.ts`, and their shared `tests/fixtures/push_down/routing-merge-parity.json`. Existing Codex virtual-resource tests preserve mapping/byte-identity boundaries. No generic merge rewrite or unrelated destination-policy replacement is proposed.

## Active-profile preservation

`generate_codex_agent_variants.py::_synchronize` at line 221 writes every existing family/base and bundled copy, including active orchestrator, engineer and reviewer profiles. Adding four discovery families requires no intended change to existing profile bodies or model tables, but unchanged bytes cannot be assumed before authorized generation.

Record exact active-profile hashes before and after generation/publication. Existing native authority may be reused only when those profile bytes are identical. Any changed profile requires a fresh native launch and authority verification; coordinate an orchestrator-profile transition with root. No generator or prospective rendering was executed during this preparation.

Preparation is complete. Implementation and execution remain subject to the accepted predecessor commits and the coordinator's separate release.
