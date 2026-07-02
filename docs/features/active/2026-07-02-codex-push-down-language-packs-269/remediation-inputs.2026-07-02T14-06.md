# Remediation Inputs: Codex Push-Down Language Packs (#269)

Timestamp: 2026-07-02T14-06
Primary requirements source: `docs/features/active/2026-07-02-codex-push-down-language-packs-269/remediation-inputs.2026-07-02T14-06.md`
Feature folder: `docs/features/active/2026-07-02-codex-push-down-language-packs-269`
Base branch: `main`
Merge base: `51867789325248793a241886033c3ce86681f9ad`
Head: `4fd8353e7997b51f20942d4de11bc2ec28d24537`

## Remediation Required Findings

### R1 - Evidence Location Violation

- Severity: Blocker
- Finding: `python scripts/dev_tools/validate_evidence_locations.py --root .` exits 1 because `docs/features/active/2026-07-02-codex-push-down-language-packs-269/research/2026-07-02T13-23-codex-push-down-language-packs-269-research.md` exists outside canonical locations.
- Expected behavior: Research/evidence for issue #269 is stored under `docs/features/active/2026-07-02-codex-push-down-language-packs-269/research/` or `docs/research/`, and validator exits 0.
- Files to update:
  - `docs/features/active/2026-07-02-codex-push-down-language-packs-269/research/2026-07-02T13-23-codex-push-down-language-packs-269-research.md`
  - `docs/features/active/2026-07-02-codex-push-down-language-packs-269/plan.2026-07-02T13-20.md`
- Verification command: `python scripts/dev_tools/validate_evidence_locations.py --root .`

### R2 - Modified Production Files Exceed 500 Lines

- Severity: Blocker
- Finding: `extensions/drm-copilot/src/mcp-repo-automation-tool-definitions.ts` is 501 lines and `extensions/drm-copilot/src/workflow-command-arguments.ts` is 662 lines.
- Expected behavior: Every modified production file is at or below 500 lines.
- Files to update:
  - `extensions/drm-copilot/src/mcp-repo-automation-tool-definitions.ts`
  - `extensions/drm-copilot/src/workflow-command-arguments.ts`
  - New extracted helper files if needed, each at or below 500 lines
- Verification command: measure changed production file line counts and confirm all are `<= 500`.

### R3 - C# Public Pack Selector Contract Mismatch

- Severity: Major
- Finding: Requirements document `--packs core,csharp --csharp-variant legacy`, but Python and TypeScript selectors accept `csharp-modern` and `csharp-legacy` as pack names.
- Expected behavior: Public CLI, service, MCP, and VS Code surfaces agree on selecting the C# pack with `csharp` and selecting the variant through `csharp_variant` / `csharpVariant`, or the requirement sources are explicitly revised and tests cover the revised contract.
- Files to update:
  - `scripts/dev_tools/push_down_codex_pack_selection.py`
  - `scripts/dev_tools/push_down_codex_and_agents_customizations.py`
  - `extensions/drm-copilot/src/lib/push-down/codex-pack-selection.ts`
  - `extensions/drm-copilot/src/repo-automation-command-registration-admin.ts`
  - `extensions/drm-copilot/src/mcp-tool-inputs-push-down.ts`
  - Relevant Python and TypeScript tests
- Verification commands:
  - `poetry run pytest tests/scripts/dev_tools/test_push_down_codex_pack_selection.py tests/scripts/dev_tools/test_push_down_codex_and_agents_customizations.py`
  - `npm run test:unit -- --coverage`

### R4 - Copilot MCP Schema Includes Codex-Only Fields

- Severity: Major
- Finding: `push_down_copilot_customizations` in both MCP definition files now exposes Codex-specific `packs`, `csharp_variant`, and `memory_mode` fields.
- Expected behavior: Only `push_down_codex_and_agents_customizations` exposes Codex selection fields unless a separate Copilot feature implements them.
- Files to update:
  - `extensions/drm-copilot/src/mcp-tool-definitions.ts`
  - `extensions/drm-copilot/src/mcp-repo-automation-tool-definitions.ts`
  - `extensions/drm-copilot/test/mcp-repo-automation-tool-definitions.test.ts`
- Verification command: `npm run test:unit -- --coverage`

### R5 - TypeScript New-File Coverage Below 90%

- Severity: Major
- Finding: `extensions/drm-copilot/src/lib/push-down/codex-pack-selection.ts` has 170/199 covered lines, 85.43%, in `extensions/drm-copilot/coverage/lcov.info`.
- Expected behavior: New TypeScript files have at least 90% line coverage.
- Files to update:
  - `extensions/drm-copilot/test/lib/push-down/codex-pack-selection.test.ts`
  - Implementation only if uncovered branches reveal incorrect behavior
- Verification command: `npm run test:unit -- --coverage` from `extensions/drm-copilot`

## Do Not Do

- Do not weaken repository policy, validator behavior, coverage thresholds, or file-size limits.
- Do not move evidence into `artifacts/baselines/`, `artifacts/qa/`, `artifacts/evidence/`, `artifacts/coverage/`, or `artifacts/research/`.
- Do not mark acceptance criteria as passing unless the public CLI/service/MCP behavior matches the documented contract or the requirements are formally updated.
- Do not remove meaningful tests to improve coverage percentages.
- Do not expand Copilot push-down behavior unless a separate requirement explicitly authorizes it.

## Required Final Verification

- `python scripts/dev_tools/validate_evidence_locations.py --root .`
- Python QA loop: `poetry run black .`; `poetry run ruff check .`; `poetry run pyright`; `poetry run pytest --cov=src/lexile_corpus_tuner --cov=scripts/dev_tools --cov-report=term-missing`
- TypeScript QA loop from `extensions/drm-copilot`: `npm run format`; `npm run lint`; `npm run typecheck`; `npm run test:unit -- --coverage`
- Coverage comparison artifacts under `docs/features/active/2026-07-02-codex-push-down-language-packs-269/evidence/qa-gates/`
- Updated feature audit after remediation
