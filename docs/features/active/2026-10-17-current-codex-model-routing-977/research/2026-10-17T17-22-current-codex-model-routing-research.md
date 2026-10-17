<!-- markdownlint-disable-file -->

# Task Research Notes: Current Codex model routing (#977)

## Research Executed

### File Analysis

- `config/orchestration-routing.json`, section `codex_model_policy`
  - Canonical policy defines four complexity bands, five profile suffixes, three execution contexts, the C3 overlay, monotonic ceiling transitions, two forced epic personas, and twelve generated agent families.
- `scripts/dev_tools/resolve_codex_deployment.py`
  - Python resolver duplicates the policy tables in `BASE_PROFILES`, `C3_ELEVATED_PROFILE`, and `FORCED_PERSONA_PROFILES`. It rejects unavailable exact models and validates bands, context, ceiling, and logical family.
- `scripts/dev_tools/generate_codex_agent_variants.py`
  - Imports the Python profile tables. Generates five variants for each family, normalizes twelve base compatibility aliases to C3/high, writes source and bundled agents, and synchronizes six pack manifests. Forced epic personas are outside its generated families and need explicit updates. Its alias docstring and error message still name Terra/high.
- `extensions/drm-copilot/src/lib/validate/orchestrator-state-codex-model-routing.ts`
  - TypeScript resolver duplicates the same profile tables. Validation re-resolves every receipt against current tables; extra metadata does not change the required exact model comparison.
- `.claude/lib/codex-routing/CodexDeployment.psm1` and `.claude/lib/orchestrator-state/OrchestratorStateCodexModelReceipts.psm1`
  - Portable PowerShell resolver has the same model defaults; receipt validator calls that resolver and compares all resolved keys.
- `.codex/hooks/record-subagent-routing-attestation.ps1`, `.codex/hooks/codex-agent-profile-attestation.ps1`, `.codex/hooks/enforce-codex-model-routing.ps1`
  - Epic provenance branch pins the former flagship model explicitly. Attestation binds actual model, reasoning, profile identity, and profile SHA; migration must preserve these checks.
- `tests/scripts/dev_tools/test_push_down_codex_and_agents_resource_contracts.py`
  - Routing configuration is a shared extension resource, deliberately absent from the Codex customization bundle. Tests require equality with the canonical policy.
- `artifacts/orchestration/orchestrator-state.json`
  - Current bootstrap receipts retain requested former models and profile hashes, alongside actual current model/default-persona metadata and migration authorization. This is live operational state, not a source fixture to replace mechanically.

### Code Search Results

- `gpt-5\.6-(luna|terra|sol)`
  - Matches policy, Python/PowerShell/TypeScript routing tables, generated agents, forced epic agents, the epic attestation hook, relevant test expectations, and bundled copies.
- `Terra|Sol/|Sol\b|Luna`
  - Current workflow prose also needs review in `.agents/skills/codex-model-routing/SKILL.md`, `epic-plan/SKILL.md`, `epic-orchestrate/SKILL.md`, `orchestrate/SKILL.md`, and `orchestrator-workflow/SKILL.md`; forced epic agent instruction bodies also describe Sol/High or Sol/Max.
- `bootstrap|migration_authorization|profile_sha256`
  - Receipt validators do not implement a bootstrap or historical-policy exception. Profile SHA enforcement is in launch/mutation hooks rather than the three model-receipt comparison functions.

### External Research

- #githubRepo:"drmoisan/drm-copilot Codex model deployment routing"
  - Repository implementation inspected through local file reads and searches; no external repository-search result is claimed.
- #fetch:https://developers.openai.com/api/docs/guides/latest-model
  - Fetched on 2026-10-17. Names Astra, GPT-6.1 Sol, and Luna; migration guidance says to preserve supported reasoning effort. The guide explicitly mentions ultra mode in Codex.
- #fetch:https://developers.openai.com/api/docs/models
  - Fetched on 2026-10-17. Catalog lists exact IDs `gpt-6-astra`, `gpt-6.1-sol`, and `gpt-6-luna`. API effort lists include the low, medium, high, and max values needed here. API effort listings do not establish Codex ultra support; the parent-supplied host capability and issue constraint establish that separately.

### Project Conventions

- Standards referenced: repository `AGENTS.md`; `research-issue`, `execution-environment`, and `evidence-and-timestamp-conventions` skills; OpenAI Docs migration guidance.
- Instructions followed: research only; write in the parent-supplied feature research folder; retain unrelated providers and historical artifacts; no dependencies or delegation. Canonical source researcher instructions authorize the tracked research location despite obsolete embedded persona text naming `artifacts/research/`.

## Key Discoveries

### Project Structure

The canonical policy and three language resolvers must change together. The generator derives agent model settings from Python constants, rather than reading JSON dynamically. Consequently editing policy JSON alone leaves all deployments unchanged.

| Surface | Source and required mirror |
| --- | --- |
| Routing policy | `config/orchestration-routing.json`; `extensions/drm-copilot/resources/config/orchestration-routing.json`; `extensions/drm-copilot/resources/claude-customizations/config/orchestration-routing.json` |
| Generated agents | `.codex/agents/`; same relative paths under `extensions/drm-copilot/resources/codex-and-agents-customizations/` |
| Portable resolver | `.claude/lib/codex-routing/CodexDeployment.psm1`; `extensions/drm-copilot/resources/lib/codex-routing/CodexDeployment.psm1` |
| Codex hook | `.codex/hooks/record-subagent-routing-attestation.ps1`; same relative path under the Codex customization bundle |
| Current Codex skills | Five `.agents/skills/` files named above; matching files under the Codex customization bundle |

Do not create a Codex-bundle routing-policy copy. Do not change Claude/Copilot provider model settings merely because their agent files are migration sources. Historical feature plans, checkpoint evidence, and fixtures recording historical behavior are outside replacement scope.

### Implementation Patterns

Preserve suffixes, logical aliases, family inventory, file-count routing, overlay conditions/reasons, and ceiling monotonicity. C3 elevates when either epic-child context or C4 ceiling applies; forced epic personas retain their names and ultra effort. Exact model availability and attestation failures remain fail-closed.

### Complete Examples

```text
poetry run python -m scripts.dev_tools.resolve_codex_deployment --logical-agent atomic-executor --complexity-band C3 --execution-context standalone --orchestration-complexity-ceiling C3
poetry run python -m scripts.dev_tools.generate_codex_agent_variants
poetry run python -m scripts.dev_tools.generate_codex_agent_variants --check
```

The first command should resolve `atomic-executor-c3`, `gpt-6.1-sol`, high effort after migration. Generator commands are existing CLI entry points, not proposed new APIs.

### API and Schema Documentation

Receipt keys remain `logical_agent`, `deployment_agent`, `complexity_band`, `execution_context`, `orchestration_complexity_ceiling`, `c3_overlay_applied`, `c3_overlay_reason`, `model`, and `model_reasoning_effort`; checkpoint records additionally require a non-empty `phase`. Ceiling increases require existing `ceiling_transition` evidence. No new schema is necessary for the model-table migration.

### Configuration Examples

```text
C1                  gpt-6-luna    low
C2                  gpt-6.1-sol   medium
C3 standalone/C3    gpt-6.1-sol   high
C3 elevated         gpt-6-astra   high
C4                  gpt-6-astra   max
epic personas       gpt-6-astra   ultra
```

### Technical Requirements

**The final current-policy receipt gate cannot accept unchanged former-model receipts in its live validated list.** Python, TypeScript, and PowerShell re-resolve every present record against their current model tables. Fields such as `actual_model`, `migration_authorization`, and `bootstrap_exception` do not override comparison. Earlier profile SHA values also cannot attest regenerated files.

Preserve historical launch receipts verbatim in canonical feature evidence and distinguish them from newly resolved current-policy authorization. Do not relabel a past launch as a new generated-profile launch, overwrite historical hashes, invent a successful attestation, or introduce a general exception schema solely for this run. Parent orchestration must resolve the final live-checkpoint transition truthfully; this research does not authorize changing its state.

**Installed MCP validation can remain a completion blocker after source migration.** Execution-environment documents that MCP invokes the installed extension. An installed old TypeScript resolver expects former models, whereas the migrated branch expects current models. A final current-policy receipt list therefore needs a matching current extension validator before its MCP result can establish completion. Branch-current CLI validation is additional evidence and does not prove that the installed validator changed. This incompatibility is inferred from the verified resolver code and documented installed-extension execution route; an installed-version probe remains parent-owned.

## Recommended Approach

Apply the explicit three-model substitution to the canonical policy, all three resolver implementations, forced epic agents, epic hook expectation, current workflow prose, and affected tests. Run the existing generator to update the twelve aliases and sixty variants in both source and bundle. Synchronize remaining mirrors explicitly and run parity contracts. Keep existing routing algorithms and receipt schema unchanged.

Rejected alternatives: editing generated TOML files independently is viable but drifts from their generator; updating only policy JSON is insufficient because resolvers embed tables; replacing every tier with Astra violates the approved tier roles. A historical-policy validation framework would enlarge this bounded migration and weaken assurance if introduced only to satisfy bootstrap receipts.

## Implementation Guidance

- **Objectives**: acceptance criterion 1 maps to policy/resolver/profile/document/mirror updates; criterion 2 maps to unchanged topology, overlay, reasoning, unavailable-model, and attestation contracts; criterion 3 maps to complete ordered language gates and exact PR-head CI.
- **Key Tasks**: change canonical constants and current labels; explicitly update two epic personas; regenerate agents; synchronize policy, resolver, hook, and skill mirrors; update expectations that describe current behavior; preserve historical fixtures and evidence; document installed-validator limitations.
- **Dependencies**: none added. Existing Poetry, Node/Jest, and self-hosted PoshQC toolchains apply.
- **Success Criteria**: new exact slugs appear in all current routes; current C3 base alias and elevated route differ as specified; epic ultra remains; unavailable/mismatched model rejects; generation check and bundle contracts pass; no unrelated provider or historical evidence change.

Validation inventory, to be incorporated into the plan:

1. Python: `test_resolve_codex_deployment.py`, `test_generate_codex_agent_variants.py`, `test_validate_orchestrator_state_codex_model_routing.py`, `test_validate_orchestrator_state_codex_topology.py`, `test_validate_epic_planner_state.py`, `test_codex_full_migration_inventory.py`, Codex wrapper/handoff contracts, both Claude and Codex push-down resource/manifest contracts. Run through `poetry run pytest`; use module-form generator `--check`. Apply Black, Ruff, Pyright, then tests in the required order, restarting after repairs.
2. TypeScript: `test/lib/validate/codex-deployment.test.ts`, orchestrator/epic model-routing and topology tests, epic planner launch-evidence/readiness/core/feature-receipt/launch-binding suites and their support module, plus `test/lib/push-down/codex-bundle-publish.integration.test.ts`. These currently include former-model expectations or consume the shared routing resolver. In `extensions/drm-copilot/`, use `npm run format`, `npm run lint`, `npm run typecheck`, then `node run-jest.cjs` with the selected suites; run the required full suite/coverage gate for final QA.
3. PowerShell: `tests/scripts/claude-lib/codex-routing/CodexDeployment.Parity.Tests.ps1`, `tests/scripts/claude-lib/orchestrator-state/OrchestratorStateCodexModelReceipts.Tests.ps1`, and touched suites under `tests/scripts/codex-hooks/`. Current-model literals occur in profile-attestation, legacy hook-contract, epic wave/provenance/child-launch, worktree-binding, pretooluse transport/integration, and bundle-probe suites. Use the self-hosted PoshQC formatter, analyzer, and tests; read actual JUnit/coverage output because MCP invocation success does not prove test success.
4. Regression controls: reversed changed-Python module order, seeded shuffled Jest, at least three Pester file-order seeds, and the fresh single-process `tests/scripts` run. Per changed production file maintain 85% line coverage and Python/TypeScript 75% branch coverage; do not create temporary files in unit tests.
5. Scope and mirror controls: search current surfaces for both old slugs and stale Terra/Sol role prose; inspect results individually. Run resource parity, pack-manifest completeness, generator freshness, and frozen-surface tests. CI full-run checks remain necessary because configuration/code/customization paths are outside the docs-only allowlist.

## Pre-Mortem

- Review checklists: a slug-only edit can leave old role descriptions or alter the C3 overlay; map all acceptance criteria to named tests and inspect current prose separately.
- Coverage: changed resolvers or attestation hooks can lose measured negative paths; retain unavailable-model, exact-mismatch, all-band/context/ceiling tests and collect required per-file coverage.
- Mirror parity: regeneration covers agents and manifests, but not policy, portable resolver, hook, or skill mirrors; name explicit synchronization tasks and run both customization contract sets.
- File size: production and test files may already approach 500 physical lines; count touched files and avoid expanding existing large modules for this constant migration.
- Test isolation: profile/receipt tests can retain mocks, module state, or environment values; use in-memory seams and the required shuffled/reversed/single-process runs.
- CI-only behavior: Linux hook suites, path case, LF normalization, and generated freshness can differ from this Windows checkout; preserve portable paths and verify full exact-head CI.
- Evidence: old receipts and hashes cannot be rewritten as new launches, and installed MCP may still enforce old models; preserve historical records verbatim, record actual launches separately, and report the installed-validator blocker explicitly until resolved.
