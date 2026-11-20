# R1 Manifest and Test Inventory ([P0-T1])

Plan: remediation-plan.2026-11-19T12-09.md
Timestamp: 2026-11-19T12-24
Command: sh SCRATCH/issue-1032-r1-manifests.sh (PowerShell 7 helper SCRATCH/issue-1032-r1-manifests.ps1: parses every `extensions/drm-copilot/resources/*/pack-manifests/*.json`, counts `paths`, entries under `RETIRED-PATH`, entries under `REMAINING-COPILOT-ROOTS`, and listed paths absent from the bundle); Grep tool searches named below
EXIT_CODE: 0
Output Summary: 18 pack manifests parsed as JSON; 52 retired-path entries, all in `COPILOT-MANIFESTS` (core 48, csharp 2, powershell 2); Generated: no; no test records `update`; LedgerRegion: none.

## (a) Retired-path entries per manifest

| Manifest | Retired-path entries |
| --- | --- |
| `customizations/pack-manifests/core.json` | 48 |
| `customizations/pack-manifests/csharp.json` | 2 (`csharp-change-budget-router/SKILL.md`, `csharp-orchestration-state-machine/SKILL.md`) |
| `customizations/pack-manifests/powershell.json` | 2 (`powershell-change-budget-router/SKILL.md`, `powershell-orchestration-state-machine/SKILL.md`) |
| `customizations/pack-manifests/python.json` | 0 |
| `customizations/pack-manifests/typescript.json` | 0 |
| every `claude-customizations/pack-manifests/*.json` (6 files) | 0 |
| every `codex-and-agents-customizations/pack-manifests/*.json` (7 files) | 0 |

core.json retired entries (48, all under the retired tree, each listed but absent from the bundle): `README.md`, `acceptance-criteria-tracking`, `adjudicate-unspecified-behavior`, `atomic-plan-contract`, `characterize-runtime-behavior`, `discovery-behavior-reconciliation`, `discovery-coverage-ledger`, `discovery-parity-matrix`, `discovery-repo-inventory`, `discovery-runtime-characterization`, `discovery-validate-artifacts`, `discovery-workflow`, `docs-author-page` (`SKILL.md` and 8 templates: `api-reference`, `architecture-overview`, `cli-reference`, `config-reference`, `explanation`, `how-to`, `http-reference`, `tutorial`), `docs-init`, `docs-inventory-surface`, `docs-plan-ia`, `docs-reconcile-behavior`, `docs-review-coverage`, `docs-validate`, `documentation-workflow`, `evidence-and-timestamp-conventions`, `execution-environment`, `extract-feature-contract`, `feature-promotion-lifecycle`, `feature-review-workflow`, `generate-acceptance-scenarios`, `initialize-discovery-workspace`, `inventory-legacy-system`, `make-skill-template`, `owner-directives`, `policy-audit-template-usage`, `policy-compliance-order`, `pr-base-branch-merge-base`, `pr-context-artifacts`, `reconcile-parity-matrix`, `remediation-handoff-atomic-planner`, `review-discovery-coverage`, `skill-canonical-location-audit`, `test-execution-policy`, `validate-discovery-artifacts` (each `<name>/SKILL.md` unless stated).

## (b) COPILOT-MANIFESTS parse and counts

| Manifest | Parses | `paths` | Entries under `REMAINING-COPILOT-ROOTS` | Listed but absent |
| --- | --- | --- | --- | --- |
| `core.json` | yes | 129 | 81 | 48 (= the retired entries) |
| `csharp.json` | yes | 8 | 6 | 2 (= the retired entries) |
| `powershell.json` | yes | 8 | 6 | 2 (= the retired entries) |
| `python.json` | yes | 8 | 8 | 0 |
| `typescript.json` | yes | 4 | 4 | 0 |

## (c) Generator decision

Generated: no
Evidence: no file under `scripts/` names `customizations/pack-manifests`; the only `scripts/` reference to the Copilot bundle root is `HarnessGeneration.psm1` (bundle path mapping of `.github/` files, not a manifest writer); `PACK_ROOT` in `scripts/dev_tools/generate_codex_agent_variants.py` is the Codex bundle manifest folder; `extensions/drm-copilot/src/lib/push-down/` reads `pack-manifests` (`push-down-pack-resolver.ts` `PACK_MANIFEST_DIRECTORY`, `copilot-customizations.ts`) and writes none. Matches `## Planning-Time Observations`.

## (d) Tests and dispositions

Searches over `tests/` and `extensions/drm-copilot/test/` for the Copilot manifest folder `resources/customizations/pack-manifests`, `COPILOT_BUNDLE`, `COPILOT_PACK_NAMES`, `RETIRED-PATH` with a manifest context, and the four pack-scoped skill names:

| Test | Match | Disposition |
| --- | --- | --- |
| `tests/scripts/claude-runtime/copilot-layer-retirement.Tests.ps1` `CLR-PACK-MANIFESTS finds no retired path in any pack manifest` | scans all three bundles' `pack-manifests` | unchanged (fails before, passes after) |
| `extensions/drm-copilot/test/lib/push-down/push-down-bundle-manifest-completeness.test.ts` `lists every Copilot bundle file`, `enumerates a non-empty bundle tree` | `COPILOT_BUNDLE`; asserts every bundle file is listed, not that every listed path exists | unchanged (unaffected) |
| `extensions/drm-copilot/test/lib/push-down/push-down-pipeline.test-helpers.ts`, `push-down-service-call.test.ts` | in-memory manifests under `customizations/pack-manifests` | unchanged (unaffected) |
| `extensions/drm-copilot/test/lib/push-down/push-down-pack-resolver.test.ts` | in-memory manifests | unchanged (unaffected) |
| `tests/scripts/dev_tools/test_discovery_publication_contracts.py` (`COPILOT_BUNDLE`, `_manifest_paths`) | reads only the Claude and Codex `core.json` | unchanged (unaffected) |
| `tests/scripts/dev_tools/test_codex_handoff_contract_parity.py`, `test_csharp_orchestration_contracts.py`, `test_orchestration_guardrail_contracts.py`, `test_push_down_claude_resource_contracts.py` | pack-scoped skill names under `.agents`/`.claude` | unchanged (unaffected) |
| Claude/Codex manifest tests (`*.Manifest.Tests.ps1`, `test_push_down_*_pack_selection.py`, blast-radius fixtures and tests) | Claude or Codex `core.json` only | unchanged (unaffected) |

No test asserts a Copilot manifest entry count. TestUpdates required: none.

## (e) Ledger region

`REGION-MAP` (`ledger-region-map.2026-11-19T07-46.md`) holds no `pack-manifests` path; `docs/engineering/process-reductions/` names only the Claude and Codex `core.json` (entry 0010 and its patch), no `COPILOT-MANIFESTS` path.
LedgerRegion: none
