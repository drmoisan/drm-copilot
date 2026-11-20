# R1 Merge-Delta Inventory ([P0-T2])

Plan: remediation-plan.2026-11-19T12-09.md
Timestamp: 2026-11-19T12-25
Command: git log --merges --format="%H %P | %s" -n 3; git fetch origin epic/shared-agent-harness-layer-integration; git merge-base --is-ancestor SYNC-MERGE^2 origin/epic/shared-agent-harness-layer-integration; git diff --name-status --diff-filter=AM SYNC-MERGE^1 SYNC-MERGE; Grep tool searches for `RETIRED-PATH` named below
EXIT_CODE: 0
Output Summary: SYNC-MERGE located (second parent is an ancestor of the integration branch); MERGE-DELTA 168 files; EngineRetiredRoot: absent; SyncRetiredRoot: absent; no MERGE-DELTA test holds RETIRED-PATH; no brief or contract copy in MERGE-DELTA.

## SYNC-MERGE

Subject: `Merge remote-tracking branch 'origin/epic/shared-agent-harness-layer-integration' into feature/retire-github-skills-and-thin-copilot-layer-1032`
Second parent reachable from `origin/epic/shared-agent-harness-layer-integration`: yes (`git merge-base --is-ancestor` exit 0).

## MERGE-DELTA (added or modified between the first parent of SYNC-MERGE and SYNC-MERGE)

Count: 168

| Group | Status | Count |
| --- | --- | --- |
| `docs/features/active/2026-10-30-push-down-consolidation-and-ecosystem-packs-1029/` (evidence, reviews, plans, spec, user story) | A 98, M 3 | 101 |
| `extensions/drm-copilot/CHANGELOG.md`, `README.md`, `jest.config.cjs` | M | 3 |
| `extensions/drm-copilot/jest.push-down-coverage.json` | A | 1 |
| `extensions/drm-copilot/resources/claude-customizations/pack-manifests/core.json` | M | 1 |
| `extensions/drm-copilot/resources/codex-and-agents-customizations/pack-manifests/` `core.json`, `csharp-legacy.json`, `csharp-modern.json`, `powershell.json`, `python.json` | M | 5 |
| `extensions/drm-copilot/resources/codex-and-agents-customizations/pack-manifests/shared.json` | A | 1 |
| `extensions/drm-copilot/resources/customizations/pack-manifests/` `core.json`, `csharp.json`, `powershell.json`, `python.json`, `typescript.json` | A | 5 |
| `extensions/drm-copilot/src/lib/push-down/` modified: `claude-customizations.ts`, `codex-agents-customizations.ts`, `copilot-customizations-engine.ts`, `copilot-customizations.ts`, `push-down-service-call.ts` | M | 5 |
| `extensions/drm-copilot/src/lib/push-down/` added: `claude-layer.ts`, `push-down-apply.ts`, `push-down-destination-manifest.ts`, `push-down-ecosystem-registry.ts`, `push-down-harness.ts`, `push-down-layer.ts`, `push-down-pack-resolver.ts`, `push-down-pipeline.ts`, `push-down-plan-comparator.ts`, `push-down-report.ts`, `push-down-shared-layer.ts`, `push-down-write-if-changed.ts` | A | 12 |
| `extensions/drm-copilot/src/` modified: `mcp-push-down-schema-properties.ts`, `mcp-tool-inputs-push-down.ts`, `mcp-tool-inputs.ts`, `mcp-tools.ts`, `repo-automation-command-registration-admin.ts`, `repo-automation-service-contract.ts`, `repo-automation-service-push-down.ts`, `repo-automation-service.ts` | M | 8 |
| `extensions/drm-copilot/src/push-down-command-support.ts` | A | 1 |
| `extensions/drm-copilot/test/` modified: `extension.push-down-claude-customizations.test.ts`, `lib/push-down/copilot-customizations-engine.test.ts`, `lib/push-down/push-down-service-call.test.ts`, `mcp-repo-automation-tool-definitions.test.ts`, `repo-automation-service.push-down-claude.test.ts`, `repo-automation-service.push-down-codex.test.ts` | M | 6 |
| `extensions/drm-copilot/test/` added: `lib/push-down/` `claude-layer.test.ts`, `push-down-apply.test.ts`, `push-down-bundle-manifest-completeness.test.ts`, `push-down-destination-manifest.test.ts`, `push-down-ecosystem-registry.test.ts`, `push-down-harness.real-bundle.test.ts`, `push-down-harness.test.ts`, `push-down-pack-resolver.test.ts`, `push-down-pipeline.test-helpers.ts`, `push-down-pipeline.test.ts`, `push-down-plan-comparator.test.ts`, `push-down-report.test.ts`, `push-down-shared-layer.test.ts`, `push-down-write-if-changed.test.ts`; `mcp-tool-inputs.push-down-planning.test.ts`, `push-down-command-support.test.ts`, `push-down-wrapper-compatibility.test.ts`, `repo-automation-command-registration-admin.push-down.test.ts` | A | 18 |
| `tests/scripts/dev_tools/test_push_down_codex_and_agents_pack_manifest_completeness.py` | M | 1 |

The full list is reproducible with the command above.

## Retired root in merged production roots

EngineRetiredRoot: absent (`COPILOT_ROOT_FOLDERS` in `copilot-customizations-engine.ts` lists `.github/agents`, `.github/hooks`, `.github/instructions`, `.github/prompts`; no module under `extensions/drm-copilot/src/lib/push-down/` matches `RETIRED-PATH` or a `skills` path segment literal)
SyncRetiredRoot: absent (`ROOT_FOLDERS` in `scripts/dev_tools/agentic_sync.py` lists the same four roots)

## MERGE-DELTA tests holding RETIRED-PATH

None. The `RETIRED-PATH` hits under `extensions/drm-copilot/test/` are all in `lib/codex-native-converter/*.test.ts` and `repo-automation-service.codex-native-converter.test.ts`, none of which is in MERGE-DELTA; `test_push_down_codex_and_agents_pack_manifest_completeness.py` has no match. Dispositions required: none.

## Brief and contract copies in MERGE-DELTA

none (no `execution-environment/SKILL.md` of `REMAINING-BRIEF-COPIES` and no `atomic-plan-contract/SKILL.md` of `REMAINING-CONTRACT-COPIES` is in MERGE-DELTA).
