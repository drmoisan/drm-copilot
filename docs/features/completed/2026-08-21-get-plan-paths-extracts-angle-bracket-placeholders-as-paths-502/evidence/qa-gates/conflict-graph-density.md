# QA Gate — Conflict-Graph Density, After State — [P7-T1] through [P7-T7]

Timestamp: 2026-08-23T03-30

Feature: 2026-08-21-get-plan-paths-extracts-angle-bracket-placeholders-as-paths-502 (issue #502)
Tasks: [P7-T1], [P7-T2], [P7-T3], [P7-T4], [P7-T5], [P7-T6], [P7-T7]
State captured: POST-FIX

Command: `poetry run python <corpus measurement script>` re-run over the item list stored by [P0-T14], followed by `poetry run python <phase 7 analysis script>` over the before and after measurements.

EXIT_CODE: 0

## [P7-T1] Item-set identity and the five headline quantities

The after-measurement enumerated the corpus with the same sorted glob, the same constant derivation timestamp, and the same sibling-spec rule as [P0-T14]. The resulting item list is **byte-identical** to the list [P0-T14] stored: the equality of the two ordered plan-path lists was asserted programmatically and reports `True`.

| Quantity | Before | After | Change |
| --- | --- | --- | --- |
| item count | **58** | **58** | 0 |
| edge count | **1282** | **1267** | **-15** |
| density | **77.6%** | **76.6%** | -1.0 pp |
| cohort count | **32** | **32** | 0 |
| maximum cohort width | **4** | **4** | 0 |

The item count is 58, which is non-zero, and it is identical in both states. All five quantities are recorded for both states.

The cohort count and maximum cohort width are unchanged. That is not a null result and it is worth stating plainly: at a density of 76.6% the conflict graph remains dense enough that greedy Welsh-Powell coloring needs the same number of cohorts, so removing 15 edges does not yet buy additional parallel lanes on this corpus. The measurable gain is in the edge set and in the total entry count, not yet in the schedule.

## [P7-T2] Total-entry accounting and the exact set difference

| Quantity | Value |
| --- | --- |
| total radius path entries, before | **3729** |
| total radius path entries, after | **2472** |
| dropped entry occurrences (summed over items) | **1257** |
| distinct dropped entry strings | **1198** |
| entries ADDED by the change | **0** |

The arithmetic closes exactly: 3729 - 1257 = 2472, and the added-entry set is empty, so every difference in the total is a drop and no entry was introduced.

### Zero marker-free entries were dropped

**Every one of the 1198 distinct dropped entries contains a marker character.** The marker-free subset of the dropped set was computed by applying the shipped predicate to each dropped string and has size **0**.

This is the entry-level positive control. A marker-free drop would mean the guard removed a real path, which the plan classifies as a Blocking defect that halts the phase. None occurred, so the phase proceeds.

Distinct dropped entries by marker (an entry may carry several):

| Marker | Distinct dropped entries carrying it |
| --- | --- |
| `` < `` | 1180 |
| `` > `` | 1180 |
| `` ${ `` | 73 |
| `` $( `` | 0 |
| `` % `` | 0 |

The angle brackets dominate, which matches the [P0-T12] and [P0-T13] baselines: the mandated evidence-path and feature-document shapes are angle-bracketed, and those are the shapes every well-formed plan quotes.

### The full set difference, enumerated per item

Every dropped entry is listed below under the item whose radius carried it. The list is the exact set difference `before_paths - after_paths` per item, and the union of these lists is the 1198-string distinct set counted above.

```text
item  1  issue 334                              2026-07-09-subagent-tree-mcp-and-dropdown-334
    - <FEATURE>/evidence/baseline/phase0-instructions-read.md
    - <FEATURE>/evidence/baseline/ps-analyze.<TS>.md
    - <FEATURE>/evidence/baseline/ps-pester-coverage.<TS>.md
    - <FEATURE>/evidence/baseline/ts-format-check.<TS>.md
    - <FEATURE>/evidence/baseline/ts-jest-coverage.<TS>.md
    - <FEATURE>/evidence/baseline/ts-lint.<TS>.md
    - <FEATURE>/evidence/baseline/ts-typecheck.<TS>.md
    - <FEATURE>/evidence/qa-gates/acceptance-criteria.<TS>.md
    - <FEATURE>/evidence/qa-gates/bundle-extension.<TS>.md
    - <FEATURE>/evidence/qa-gates/bundle-mcp-server.<TS>.md
    - <FEATURE>/evidence/qa-gates/coverage-delta.<TS>.md
    - <FEATURE>/evidence/qa-gates/dependency-check.<TS>.md
    - <FEATURE>/evidence/qa-gates/file-size-check.<TS>.md
    - <FEATURE>/evidence/qa-gates/final-ps-analyze.<TS>.md
    - <FEATURE>/evidence/qa-gates/final-ps-format.<TS>.md
    - <FEATURE>/evidence/qa-gates/final-ps-test.<TS>.md
    - <FEATURE>/evidence/qa-gates/final-ts-format.<TS>.md
    - <FEATURE>/evidence/qa-gates/final-ts-jest-coverage.<TS>.md
    - <FEATURE>/evidence/qa-gates/final-ts-lint.<TS>.md
    - <FEATURE>/evidence/qa-gates/final-ts-typecheck.<TS>.md
    - <FEATURE>/evidence/qa-gates/host-neutrality-check.<TS>.md
    - <FEATURE>/evidence/qa-gates/phase1-ts-loop.<TS>.md
    - <FEATURE>/evidence/qa-gates/phase2-ts-loop.<TS>.md
    - <FEATURE>/evidence/qa-gates/phase3-ts-loop.<TS>.md
    - <FEATURE>/evidence/qa-gates/phase4-ts-loop.<TS>.md
    - <FEATURE>/evidence/qa-gates/phase6-ps-analyze.<TS>.md
    - <FEATURE>/evidence/qa-gates/phase6-ps-format.<TS>.md
    - <FEATURE>/evidence/qa-gates/phase6-ps-test.<TS>.md
    - <FEATURE>/evidence/qa-gates/tool-advertised.<TS>.md
    - <FEATURE>/spec.md
item  3  issue 344                              2026-07-10-poshqc-test-terminal-output-scan-config-344
    - <FEATURE>/evidence/baseline/baseline-ps-analyze.md
    - <FEATURE>/evidence/baseline/baseline-ps-test-coverage.md
    - <FEATURE>/evidence/baseline/baseline-py-parity.md
    - <FEATURE>/evidence/baseline/baseline-ts-lint.md
    - <FEATURE>/evidence/baseline/baseline-ts-test-coverage.md
    - <FEATURE>/evidence/baseline/baseline-ts-typecheck.md
    - <FEATURE>/evidence/baseline/junit-command.xml
    - <FEATURE>/evidence/baseline/junit-diff-task-vs-command.md
    - <FEATURE>/evidence/baseline/junit-task.xml
    - <FEATURE>/evidence/baseline/pester-excludedpath-empirical.md
    - <FEATURE>/evidence/baseline/phase0-instructions-read.md
    - <FEATURE>/evidence/baseline/pssa-settings-diff.md
    - <FEATURE>/evidence/qa-gates/acceptance-criteria-status.md
    - <FEATURE>/evidence/qa-gates/coverage-comparison.md
    - <FEATURE>/evidence/qa-gates/file-size-check.md
    - <FEATURE>/evidence/qa-gates/final-ps-analyze.md
    - <FEATURE>/evidence/qa-gates/final-ps-format.md
    - <FEATURE>/evidence/qa-gates/final-ps-test-coverage.md
    - <FEATURE>/evidence/qa-gates/final-py-format.md
    - <FEATURE>/evidence/qa-gates/final-py-lint.md
    - <FEATURE>/evidence/qa-gates/final-py-parity.md
    - <FEATURE>/evidence/qa-gates/final-py-typecheck.md
    - <FEATURE>/evidence/qa-gates/final-ts-format.md
    - <FEATURE>/evidence/qa-gates/final-ts-lint.md
    - <FEATURE>/evidence/qa-gates/final-ts-test-coverage.md
    - <FEATURE>/evidence/qa-gates/final-ts-typecheck.md
    - <FEATURE>/evidence/qa-gates/parity-gate-extended.md
    - <FEATURE>/evidence/regression-testing/junit-command-post.xml
    - <FEATURE>/evidence/regression-testing/junit-diff-post-change.md
    - <FEATURE>/evidence/regression-testing/junit-task-post.xml
item  4  issue 364                              2026-07-17-legacy-discovery-acceptance-scenarios-364
    - schemas/vN/<schema_name>.schema.json
item  5  issue 365                              2026-07-17-legacy-discovery-agent-roles-365
    - .claude/agents/<slug>.md
item  6  issue 363                              2026-07-17-legacy-discovery-analyzer-framework-363
    - docs/features/active/2026-07-17-legacy-discovery-analyzer-framework-363/evidence/baseline/baseline-black.<yyyy-MM-ddTHH-mm>.md
    - docs/features/active/2026-07-17-legacy-discovery-analyzer-framework-363/evidence/baseline/baseline-pyright.<yyyy-MM-ddTHH-mm>.md
    - docs/features/active/2026-07-17-legacy-discovery-analyzer-framework-363/evidence/baseline/baseline-pytest-coverage.<yyyy-MM-ddTHH-mm>.md
    - docs/features/active/2026-07-17-legacy-discovery-analyzer-framework-363/evidence/baseline/baseline-ruff.<yyyy-MM-ddTHH-mm>.md
    - docs/features/active/2026-07-17-legacy-discovery-analyzer-framework-363/evidence/other/emission-shape-assumption.<yyyy-MM-ddTHH-mm>.md
    - docs/features/active/2026-07-17-legacy-discovery-analyzer-framework-363/evidence/other/upstream-dependency-status.<yyyy-MM-ddTHH-mm>.md
    - docs/features/active/2026-07-17-legacy-discovery-analyzer-framework-363/evidence/qa-gates/acceptance-traceability.<yyyy-MM-ddTHH-mm>.md
    - docs/features/active/2026-07-17-legacy-discovery-analyzer-framework-363/evidence/qa-gates/coverage-delta.<yyyy-MM-ddTHH-mm>.md
    - docs/features/active/2026-07-17-legacy-discovery-analyzer-framework-363/evidence/qa-gates/finalqc-black.<yyyy-MM-ddTHH-mm>.md
    - docs/features/active/2026-07-17-legacy-discovery-analyzer-framework-363/evidence/qa-gates/finalqc-pyright.<yyyy-MM-ddTHH-mm>.md
    - docs/features/active/2026-07-17-legacy-discovery-analyzer-framework-363/evidence/qa-gates/finalqc-pytest-coverage.<yyyy-MM-ddTHH-mm>.md
    - docs/features/active/2026-07-17-legacy-discovery-analyzer-framework-363/evidence/qa-gates/finalqc-ruff.<yyyy-MM-ddTHH-mm>.md
    - evidence/baseline/baseline-pytest-coverage.<yyyy-MM-ddTHH-mm>.md
    - evidence/qa-gates/coverage-delta.<yyyy-MM-ddTHH-mm>.md
    - evidence/qa-gates/finalqc-pytest-coverage.<yyyy-MM-ddTHH-mm>.md
item  8  issue 371                              2026-07-17-legacy-discovery-documentation-371
    - docs/features/active/2026-07-17-legacy-discovery-documentation-371/evidence/baseline/phase0-docs-tree-baseline.<yyyy-MM-ddTHH-mm>.md
    - docs/features/active/2026-07-17-legacy-discovery-documentation-371/evidence/other/integration-reconciliation.<yyyy-MM-ddTHH-mm>.md
    - docs/features/active/2026-07-17-legacy-discovery-documentation-371/evidence/other/optional-contract-test-decision.<yyyy-MM-ddTHH-mm>.md
    - docs/features/active/2026-07-17-legacy-discovery-documentation-371/evidence/qa-gates/domain-neutrality.<yyyy-MM-ddTHH-mm>.md
    - docs/features/active/2026-07-17-legacy-discovery-documentation-371/evidence/qa-gates/end-state.<yyyy-MM-ddTHH-mm>.md
    - docs/features/active/2026-07-17-legacy-discovery-documentation-371/evidence/qa-gates/link-resolution.<yyyy-MM-ddTHH-mm>.md
    - docs/features/active/2026-07-17-legacy-discovery-documentation-371/evidence/qa-gates/naming-collision.<yyyy-MM-ddTHH-mm>.md
    - docs/features/active/2026-07-17-legacy-discovery-documentation-371/evidence/qa-gates/structural-completeness.<yyyy-MM-ddTHH-mm>.md
item  9  issue 369                              2026-07-17-legacy-discovery-dotnet-vsto-analyzers-369
    - <FEATURE>/evidence/baseline/phase0-black.<ts>.md
    - <FEATURE>/evidence/baseline/phase0-instructions-read.md
    - <FEATURE>/evidence/baseline/phase0-pyright.<ts>.md
    - <FEATURE>/evidence/baseline/phase0-pytest.<ts>.md
    - <FEATURE>/evidence/baseline/phase0-ruff.<ts>.md
    - <FEATURE>/evidence/other/ac-test-mapping.<ts>.md
    - <FEATURE>/evidence/other/dependency-and-coverage-config-verification.<ts>.md
    - <FEATURE>/evidence/other/file-size-verification.<ts>.md
    - <FEATURE>/evidence/other/phase0-sequencing-assumptions.<ts>.md
    - <FEATURE>/evidence/qa-gates/coverage-delta.<ts>.md
    - <FEATURE>/evidence/qa-gates/final-qc-black.<ts>.md
    - <FEATURE>/evidence/qa-gates/final-qc-pyright.<ts>.md
    - <FEATURE>/evidence/qa-gates/final-qc-pytest.<ts>.md
    - <FEATURE>/evidence/qa-gates/final-qc-ruff.<ts>.md
    - <FEATURE>/spec.md
item 10  issue 366                              2026-07-17-legacy-discovery-hooks-366
    - .claude/state/*.<session_id>.json
    - docs/features/active/2026-07-17-legacy-discovery-hooks-366/evidence/baseline/pester-baseline.<timestamp>.md
    - docs/features/active/2026-07-17-legacy-discovery-hooks-366/evidence/baseline/poshqc-analyze-baseline.<timestamp>.md
    - docs/features/active/2026-07-17-legacy-discovery-hooks-366/evidence/baseline/poshqc-format-baseline.<timestamp>.md
    - docs/features/active/2026-07-17-legacy-discovery-hooks-366/evidence/other/ac-verification.<timestamp>.md
    - docs/features/active/2026-07-17-legacy-discovery-hooks-366/evidence/qa-gates/coverage-delta.<timestamp>.md
    - docs/features/active/2026-07-17-legacy-discovery-hooks-366/evidence/qa-gates/pester-final.<timestamp>.md
    - docs/features/active/2026-07-17-legacy-discovery-hooks-366/evidence/qa-gates/poshqc-analyze-final.<timestamp>.md
    - docs/features/active/2026-07-17-legacy-discovery-hooks-366/evidence/qa-gates/poshqc-format-final.<timestamp>.md
    - tests/scripts/claude-hooks/<name>.Tests.ps1
item 12  issue 370                              2026-07-17-legacy-discovery-mcp-vscode-370
    - docs/features/active/2026-07-17-legacy-discovery-mcp-vscode-370/evidence/baseline/baseline-format.<TS>.md
    - docs/features/active/2026-07-17-legacy-discovery-mcp-vscode-370/evidence/baseline/baseline-lint.<TS>.md
    - docs/features/active/2026-07-17-legacy-discovery-mcp-vscode-370/evidence/baseline/baseline-test-coverage.<TS>.md
    - docs/features/active/2026-07-17-legacy-discovery-mcp-vscode-370/evidence/baseline/baseline-typecheck.<TS>.md
    - docs/features/active/2026-07-17-legacy-discovery-mcp-vscode-370/evidence/qa-gates/coverage-delta.<TS>.md
    - docs/features/active/2026-07-17-legacy-discovery-mcp-vscode-370/evidence/qa-gates/domain-neutrality.<TS>.md
    - docs/features/active/2026-07-17-legacy-discovery-mcp-vscode-370/evidence/qa-gates/file-size-audit.<TS>.md
    - docs/features/active/2026-07-17-legacy-discovery-mcp-vscode-370/evidence/qa-gates/final-qc-format.<TS>.md
    - docs/features/active/2026-07-17-legacy-discovery-mcp-vscode-370/evidence/qa-gates/final-qc-lint.<TS>.md
    - docs/features/active/2026-07-17-legacy-discovery-mcp-vscode-370/evidence/qa-gates/final-qc-loop.<TS>.md
    - docs/features/active/2026-07-17-legacy-discovery-mcp-vscode-370/evidence/qa-gates/final-qc-test-coverage.<TS>.md
    - docs/features/active/2026-07-17-legacy-discovery-mcp-vscode-370/evidence/qa-gates/final-qc-typecheck.<TS>.md
    - evidence/baseline/baseline-test-coverage.<TS>.md
    - evidence/qa-gates/coverage-delta.<TS>.md
    - evidence/qa-gates/final-qc-test-coverage.<TS>.md
item 13  issue 372                              2026-07-17-legacy-discovery-publishing-372
    - .agents/skills/<name>/**
    - .claude/agents/<name>.md
    - .claude/agents/<persona-name>.md
    - .claude/hooks/<hook-name>.ps1
    - .claude/hooks/<name>.ps1
    - .claude/skills/<name>/**
    - .claude/skills/<name>/SKILL.md
    - .claude/skills/<skill-name>/SKILL.md
    - .codex/agents/<name>.toml
    - .codex/hooks/<name>.ps1
    - .github/skills/<name>/SKILL.md
    - docs/features/active/2026-07-17-legacy-discovery-publishing-372/evidence/baseline/python-claude-resource-contracts-baseline.<timestamp>.md
    - docs/features/active/2026-07-17-legacy-discovery-publishing-372/evidence/baseline/python-codex-resource-contracts-baseline.<timestamp>.md
    - docs/features/active/2026-07-17-legacy-discovery-publishing-372/evidence/baseline/python-format-baseline.<timestamp>.md
    - docs/features/active/2026-07-17-legacy-discovery-publishing-372/evidence/baseline/python-lint-baseline.<timestamp>.md
    - docs/features/active/2026-07-17-legacy-discovery-publishing-372/evidence/baseline/python-push-down-suite-baseline.<timestamp>.md
    - docs/features/active/2026-07-17-legacy-discovery-publishing-372/evidence/baseline/python-typecheck-baseline.<timestamp>.md
    - docs/features/active/2026-07-17-legacy-discovery-publishing-372/evidence/baseline/typescript-format-baseline.<timestamp>.md
    - docs/features/active/2026-07-17-legacy-discovery-publishing-372/evidence/baseline/typescript-lint-baseline.<timestamp>.md
    - docs/features/active/2026-07-17-legacy-discovery-publishing-372/evidence/baseline/typescript-push-down-suite-baseline.<timestamp>.md
    - docs/features/active/2026-07-17-legacy-discovery-publishing-372/evidence/baseline/typescript-typecheck-baseline.<timestamp>.md
    - docs/features/active/2026-07-17-legacy-discovery-publishing-372/evidence/other/claude-mirror-gap-inventory.<timestamp>.md
    - docs/features/active/2026-07-17-legacy-discovery-publishing-372/evidence/other/codex-mirror-gap-inventory.<timestamp>.md
    - docs/features/active/2026-07-17-legacy-discovery-publishing-372/evidence/other/converter-registration-verification.<timestamp>.md
    - docs/features/active/2026-07-17-legacy-discovery-publishing-372/evidence/other/domain-neutrality-check.<timestamp>.md
    - docs/features/active/2026-07-17-legacy-discovery-publishing-372/evidence/other/schema-init-template-placement-decision.<timestamp>.md
    - docs/features/active/2026-07-17-legacy-discovery-publishing-372/evidence/qa-gates/final-qc-rerun-confirmation.<timestamp>.md
    - docs/features/active/2026-07-17-legacy-discovery-publishing-372/evidence/qa-gates/python-format-final.<timestamp>.md
    - docs/features/active/2026-07-17-legacy-discovery-publishing-372/evidence/qa-gates/python-lint-final.<timestamp>.md
    - docs/features/active/2026-07-17-legacy-discovery-publishing-372/evidence/qa-gates/python-test-final.<timestamp>.md
    - docs/features/active/2026-07-17-legacy-discovery-publishing-372/evidence/qa-gates/python-typecheck-final.<timestamp>.md
    - docs/features/active/2026-07-17-legacy-discovery-publishing-372/evidence/qa-gates/typescript-format-final.<timestamp>.md
    - docs/features/active/2026-07-17-legacy-discovery-publishing-372/evidence/qa-gates/typescript-lint-final.<timestamp>.md
    - docs/features/active/2026-07-17-legacy-discovery-publishing-372/evidence/qa-gates/typescript-test-final.<timestamp>.md
    - docs/features/active/2026-07-17-legacy-discovery-publishing-372/evidence/qa-gates/typescript-typecheck-final.<timestamp>.md
    - docs/features/active/2026-07-17-legacy-discovery-publishing-372/evidence/regression-testing/coverage-delta-final.<timestamp>.md
    - docs/features/active/2026-07-17-legacy-discovery-publishing-372/evidence/regression-testing/python-claude-resource-contracts-post-mirror.<timestamp>.md
    - docs/features/active/2026-07-17-legacy-discovery-publishing-372/evidence/regression-testing/python-codex-resource-contracts-post-mirror.<timestamp>.md
    - docs/features/active/2026-07-17-legacy-discovery-publishing-372/evidence/regression-testing/python-core-pack-always-union.<timestamp>.md
    - docs/features/active/2026-07-17-legacy-discovery-publishing-372/evidence/regression-testing/python-full-contract-suite.<timestamp>.md
    - docs/features/active/2026-07-17-legacy-discovery-publishing-372/evidence/regression-testing/typescript-full-push-down-suite.<timestamp>.md
    - extensions/drm-copilot/resources/claude-customizations/.claude/agents/<name>.md
    - extensions/drm-copilot/resources/claude-customizations/.claude/hooks/<name>.ps1
    - extensions/drm-copilot/resources/claude-customizations/.claude/skills/<name>/**
    - extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/<name>/**
    - extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/agents/<name>.toml
    - extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/<name>.ps1
    - scripts/dev_tools/<legacy-discovery-package>/schemas/vN/*.schema.json
item 14  issue 368                              2026-07-17-legacy-discovery-reports-368
    - .../evidence/baseline/py-format.<ts>.md
    - .../evidence/baseline/py-lint.<ts>.md
    - .../evidence/baseline/py-test.<ts>.md
    - .../evidence/baseline/py-typecheck.<ts>.md
    - .../evidence/qa-gates/ac-mapping.<ts>.md
    - .../evidence/qa-gates/coverage-delta.<ts>.md
    - .../evidence/qa-gates/domain-neutrality-check.<ts>.md
    - .../evidence/qa-gates/final-py-format.<ts>.md
    - .../evidence/qa-gates/final-py-lint.<ts>.md
    - .../evidence/qa-gates/final-py-test.<ts>.md
    - .../evidence/qa-gates/final-py-typecheck.<ts>.md
    - evidence/baseline/py-test.<ts>.md
    - evidence/qa-gates/coverage-delta.<ts>.md
    - evidence/qa-gates/final-py-test.<ts>.md
item 15  issue 359                              2026-07-17-legacy-discovery-schemas-359
    - .cache/schemas/<sha256>.json
    - docs/features/active/2026-07-17-legacy-discovery-schemas-359/evidence/baseline/baseline-black.<ts>.md
    - docs/features/active/2026-07-17-legacy-discovery-schemas-359/evidence/baseline/baseline-pyright.<ts>.md
    - docs/features/active/2026-07-17-legacy-discovery-schemas-359/evidence/baseline/baseline-pytest-coverage.<ts>.md
    - docs/features/active/2026-07-17-legacy-discovery-schemas-359/evidence/baseline/baseline-ruff.<ts>.md
    - docs/features/active/2026-07-17-legacy-discovery-schemas-359/evidence/baseline/baseline-validate-json.<ts>.md
    - docs/features/active/2026-07-17-legacy-discovery-schemas-359/evidence/other/phase0-instructions-read.<ts>.md
    - docs/features/active/2026-07-17-legacy-discovery-schemas-359/evidence/qa-gates/coverage-delta.<ts>.md
    - docs/features/active/2026-07-17-legacy-discovery-schemas-359/evidence/qa-gates/qa-black.<ts>.md
    - docs/features/active/2026-07-17-legacy-discovery-schemas-359/evidence/qa-gates/qa-pyright.<ts>.md
    - docs/features/active/2026-07-17-legacy-discovery-schemas-359/evidence/qa-gates/qa-pytest-coverage.<ts>.md
    - docs/features/active/2026-07-17-legacy-discovery-schemas-359/evidence/qa-gates/qa-ruff.<ts>.md
    - docs/features/active/2026-07-17-legacy-discovery-schemas-359/evidence/qa-gates/qa-validate-json.<ts>.md
    - docs/features/active/2026-07-17-legacy-discovery-schemas-359/evidence/qa-gates/schema-neutrality-check.<ts>.md
    - examples/discovery/v1/<artifact>.example.json
    - schemas/<family>/v<N>/<artifact>.schema.json
    - schemas/discovery/v1/<artifact>.schema.json
    - tests/fixtures/discovery_schemas/v1/<artifact>.invalid.json
    - tests/fixtures/discovery_schemas/v1/<name>.invalid.json
item 16  issue 367                              2026-07-17-legacy-discovery-skills-367
    - .claude/skills/<name>/SKILL.md
    - docs/features/active/2026-07-17-legacy-discovery-skills-367/evidence/baseline/baseline-black-check.<yyyy-MM-ddTHH-mm>.md
    - docs/features/active/2026-07-17-legacy-discovery-skills-367/evidence/baseline/baseline-push-down-parity.<yyyy-MM-ddTHH-mm>.md
    - docs/features/active/2026-07-17-legacy-discovery-skills-367/evidence/baseline/baseline-pyright.<yyyy-MM-ddTHH-mm>.md
    - docs/features/active/2026-07-17-legacy-discovery-skills-367/evidence/baseline/baseline-pytest-cov.<yyyy-MM-ddTHH-mm>.md
    - docs/features/active/2026-07-17-legacy-discovery-skills-367/evidence/baseline/baseline-ruff.<yyyy-MM-ddTHH-mm>.md
    - docs/features/active/2026-07-17-legacy-discovery-skills-367/evidence/other/push-down-parity-postcopy.<yyyy-MM-ddTHH-mm>.md
    - docs/features/active/2026-07-17-legacy-discovery-skills-367/evidence/qa-gates/final-qc-ac-traceability.<yyyy-MM-ddTHH-mm>.md
    - docs/features/active/2026-07-17-legacy-discovery-skills-367/evidence/qa-gates/final-qc-black.<yyyy-MM-ddTHH-mm>.md
    - docs/features/active/2026-07-17-legacy-discovery-skills-367/evidence/qa-gates/final-qc-contract-gates.<yyyy-MM-ddTHH-mm>.md
    - docs/features/active/2026-07-17-legacy-discovery-skills-367/evidence/qa-gates/final-qc-coverage-delta.<yyyy-MM-ddTHH-mm>.md
    - docs/features/active/2026-07-17-legacy-discovery-skills-367/evidence/qa-gates/final-qc-pyright.<yyyy-MM-ddTHH-mm>.md
    - docs/features/active/2026-07-17-legacy-discovery-skills-367/evidence/qa-gates/final-qc-pytest-cov.<yyyy-MM-ddTHH-mm>.md
    - docs/features/active/2026-07-17-legacy-discovery-skills-367/evidence/qa-gates/final-qc-ruff.<yyyy-MM-ddTHH-mm>.md
    - evidence/baseline/baseline-pytest-cov.<yyyy-MM-ddTHH-mm>.md
    - evidence/qa-gates/final-qc-coverage-delta.<yyyy-MM-ddTHH-mm>.md
    - evidence/qa-gates/final-qc-pytest-cov.<yyyy-MM-ddTHH-mm>.md
    - extensions/drm-copilot/resources/claude-customizations/.claude/skills/<name>/SKILL.md
item 17  issue 361                              2026-07-17-legacy-discovery-validators-361
    - docs/features/active/2026-07-17-legacy-discovery-validators-361/evidence/baseline/baseline-black.<TS>.md
    - docs/features/active/2026-07-17-legacy-discovery-validators-361/evidence/baseline/baseline-pyright.<TS>.md
    - docs/features/active/2026-07-17-legacy-discovery-validators-361/evidence/baseline/baseline-pytest.<TS>.md
    - docs/features/active/2026-07-17-legacy-discovery-validators-361/evidence/baseline/baseline-ruff.<TS>.md
    - docs/features/active/2026-07-17-legacy-discovery-validators-361/evidence/other/pyproject-toml-syntax-check.<TS>.md
    - docs/features/active/2026-07-17-legacy-discovery-validators-361/evidence/qa-gates/coverage-delta-verification.<TS>.md
    - docs/features/active/2026-07-17-legacy-discovery-validators-361/evidence/qa-gates/domain-neutrality-grep.<TS>.md
    - docs/features/active/2026-07-17-legacy-discovery-validators-361/evidence/qa-gates/final-qc-black.<TS>.md
    - docs/features/active/2026-07-17-legacy-discovery-validators-361/evidence/qa-gates/final-qc-pyright.<TS>.md
    - docs/features/active/2026-07-17-legacy-discovery-validators-361/evidence/qa-gates/final-qc-pytest-new-code.<TS>.md
    - docs/features/active/2026-07-17-legacy-discovery-validators-361/evidence/qa-gates/final-qc-pytest.<TS>.md
    - docs/features/active/2026-07-17-legacy-discovery-validators-361/evidence/qa-gates/final-qc-rerun-log.<TS>.md
    - docs/features/active/2026-07-17-legacy-discovery-validators-361/evidence/qa-gates/final-qc-ruff.<TS>.md
    - docs/features/active/2026-07-17-legacy-discovery-validators-361/evidence/regression-testing/validate-json-regression.<TS>.md
    - evidence/baseline/baseline-pytest.<TS>.md
    - evidence/qa-gates/coverage-delta-verification.<TS>.md
    - evidence/qa-gates/final-qc-pytest-new-code.<TS>.md
    - evidence/qa-gates/final-qc-pytest.<TS>.md
item 18  issue 393                              2026-07-21-native-bash-toolchain-no-poetry-393
    - <FEATURE>/evidence/baseline/phase0-instructions-read.<ts>.md
    - <FEATURE>/evidence/baseline/python-format.<ts>.md
    - <FEATURE>/evidence/baseline/python-lint.<ts>.md
    - <FEATURE>/evidence/baseline/python-test.<ts>.md
    - <FEATURE>/evidence/baseline/python-typecheck.<ts>.md
    - <FEATURE>/evidence/baseline/reference-inventory.<ts>.md
    - <FEATURE>/evidence/baseline/shell-check.<ts>.md
    - <FEATURE>/evidence/baseline/shell-coverage.<ts>.md
    - <FEATURE>/evidence/baseline/shell-qc-help.<ts>.md
    - <FEATURE>/evidence/baseline/shell-test.<ts>.md
    - <FEATURE>/evidence/baseline/skip-marker-contract.<ts>.md
    - <FEATURE>/evidence/other/poetry-lock-resolution.<ts>.md
    - <FEATURE>/evidence/qa-gates/ac-verification.<ts>.md
    - <FEATURE>/evidence/qa-gates/ci-green-run.<ts>.md
    - <FEATURE>/evidence/qa-gates/coverage-delta.<ts>.md
    - <FEATURE>/evidence/qa-gates/final-python-format.<ts>.md
    - <FEATURE>/evidence/qa-gates/final-python-lint.<ts>.md
    - <FEATURE>/evidence/qa-gates/final-python-test.<ts>.md
    - <FEATURE>/evidence/qa-gates/final-python-typecheck.<ts>.md
    - <FEATURE>/evidence/qa-gates/final-shell-check.<ts>.md
    - <FEATURE>/evidence/qa-gates/final-shell-coverage.<ts>.md
    - <FEATURE>/evidence/qa-gates/final-shell-format.<ts>.md
    - <FEATURE>/evidence/qa-gates/final-shell-test.<ts>.md
    - <FEATURE>/evidence/qa-gates/python-fixall-tests.<ts>.md
    - <FEATURE>/evidence/qa-gates/python-postremoval.<ts>.md
    - <FEATURE>/evidence/qa-gates/reference-sweep.<ts>.md
    - <FEATURE>/evidence/qa-gates/shell-selfhost-check.<ts>.md
    - <FEATURE>/evidence/qa-gates/shell-test-phase2.<ts>.md
    - <FEATURE>/evidence/qa-gates/workflow-review.<ts>.md
item 19  issue 392                              2026-07-21-poshqc-bundled-mock-scope-failure-392
    - <EV>/baseline/e1-decision.<ts>.md
    - <EV>/baseline/e1a-global-hosted-preimport.<ts>.md
    - <EV>/baseline/e1b-module-hosted-narrowed.<ts>.md
    - <EV>/baseline/e2-throw-site.<ts>.md
    - <EV>/baseline/e3-module-topology.<ts>.md
    - <EV>/baseline/git-baseline.<ts>.md
    - <EV>/baseline/phase0-instructions-read.md
    - <EV>/baseline/poshqc-analyze-baseline.<ts>.md
    - <EV>/baseline/poshqc-format-baseline.<ts>.md
    - <EV>/baseline/poshqc-test-baseline.<ts>.md
    - <EV>/baseline/python-parity-baseline.<ts>.md
    - <EV>/issue-updates/issue-392.<ts>.md
    - <EV>/other/change-set-audit.<ts>.md
    - <EV>/other/parity-hash-runsettings.<ts>.md
    - <EV>/other/parity-hash.<ts>.md
    - <EV>/qa-gates/coverage-delta.<ts>.md
    - <EV>/qa-gates/final-analyze.<ts>.md
    - <EV>/qa-gates/final-change-audit.<ts>.md
    - <EV>/qa-gates/final-format.<ts>.md
    - <EV>/qa-gates/final-python-parity.<ts>.md
    - <EV>/qa-gates/final-test-coverage.<ts>.md
    - <EV>/qa-gates/interim-batch1-format-analyze.<ts>.md
    - <EV>/regression-testing/fail-before.e4-bundled.<ts>.md
    - <EV>/regression-testing/p3-t4-seam-injection.<ts>.md
    - <EV>/regression-testing/pass-after.bundled-full.<ts>.md
    - <EV>/regression-testing/pass-after.bundled-narrowed.<ts>.md
    - <EV>/regression-testing/pass-after.direct.<ts>.md
    - <EV>/regression-testing/pass-after.python-parity.<ts>.md
item 20  issue 396                              2026-07-22-cleanup-merged-worktrees-396
    - <FEATURE>/evidence/baseline/phase0-instructions-read.md
    - <FEATURE>/evidence/baseline/shell-coverage-ci.<timestamp>.md
    - <FEATURE>/evidence/baseline/shell-qc-check.<timestamp>.md
    - <FEATURE>/evidence/qa-gates/coverage-delta.<timestamp>.md
    - <FEATURE>/evidence/qa-gates/file-size-caps.<timestamp>.md
    - <FEATURE>/evidence/qa-gates/final-qa-summary.<timestamp>.md
    - <FEATURE>/evidence/qa-gates/final-shell-check.<timestamp>.md
    - <FEATURE>/evidence/qa-gates/final-shell-coverage-ci.<timestamp>.md
    - <FEATURE>/evidence/qa-gates/final-shell-format.<timestamp>.md
item 21  issue 399                              2026-07-22-large-route-matrix-promotion-type-gap-399
    - docs/features/active/2026-07-22-large-route-matrix-promotion-type-gap-399/evidence/baseline/baseline-black.<timestamp>.md
    - docs/features/active/2026-07-22-large-route-matrix-promotion-type-gap-399/evidence/baseline/baseline-pyright.<timestamp>.md
    - docs/features/active/2026-07-22-large-route-matrix-promotion-type-gap-399/evidence/baseline/baseline-pytest.<timestamp>.md
    - docs/features/active/2026-07-22-large-route-matrix-promotion-type-gap-399/evidence/baseline/baseline-ruff.<timestamp>.md
    - docs/features/active/2026-07-22-large-route-matrix-promotion-type-gap-399/evidence/qa-gates/coverage-comparison.<timestamp>.md
    - docs/features/active/2026-07-22-large-route-matrix-promotion-type-gap-399/evidence/qa-gates/final-black.<timestamp>.md
    - docs/features/active/2026-07-22-large-route-matrix-promotion-type-gap-399/evidence/qa-gates/final-pyright.<timestamp>.md
    - docs/features/active/2026-07-22-large-route-matrix-promotion-type-gap-399/evidence/qa-gates/final-pytest.<timestamp>.md
    - docs/features/active/2026-07-22-large-route-matrix-promotion-type-gap-399/evidence/qa-gates/final-ruff.<timestamp>.md
item 23  issue 397                              2026-07-22-npm-audit-vulnerabilities-ci-gate-397
    - docs/features/active/2026-07-22-npm-audit-vulnerabilities-ci-gate-397/evidence/baseline/build-baseline-mcp-server.<timestamp>.md
    - docs/features/active/2026-07-22-npm-audit-vulnerabilities-ci-gate-397/evidence/baseline/compile-baseline-extensions.<timestamp>.md
    - docs/features/active/2026-07-22-npm-audit-vulnerabilities-ci-gate-397/evidence/baseline/compile-baseline-root.<timestamp>.md
    - docs/features/active/2026-07-22-npm-audit-vulnerabilities-ci-gate-397/evidence/baseline/git-status-baseline.<timestamp>.md
    - docs/features/active/2026-07-22-npm-audit-vulnerabilities-ci-gate-397/evidence/baseline/npm-audit-baseline-extensions.<timestamp>.md
    - docs/features/active/2026-07-22-npm-audit-vulnerabilities-ci-gate-397/evidence/baseline/npm-audit-baseline-mcp-server.<timestamp>.md
    - docs/features/active/2026-07-22-npm-audit-vulnerabilities-ci-gate-397/evidence/baseline/npm-audit-baseline-root.<timestamp>.md
    - docs/features/active/2026-07-22-npm-audit-vulnerabilities-ci-gate-397/evidence/baseline/stdio-smoke-baseline-mcp-server.<timestamp>.md
    - docs/features/active/2026-07-22-npm-audit-vulnerabilities-ci-gate-397/evidence/baseline/test-coverage-baseline-extensions.<timestamp>.md
    - docs/features/active/2026-07-22-npm-audit-vulnerabilities-ci-gate-397/evidence/baseline/test-coverage-baseline-root.<timestamp>.md
    - docs/features/active/2026-07-22-npm-audit-vulnerabilities-ci-gate-397/evidence/baseline/test-unit-baseline-extensions.<timestamp>.md
    - docs/features/active/2026-07-22-npm-audit-vulnerabilities-ci-gate-397/evidence/baseline/test-unit-baseline-root.<timestamp>.md
    - docs/features/active/2026-07-22-npm-audit-vulnerabilities-ci-gate-397/evidence/issue-updates/issue-397.<timestamp>.md
    - docs/features/active/2026-07-22-npm-audit-vulnerabilities-ci-gate-397/evidence/other/lock-regeneration-<manifest>.<timestamp>.md
    - docs/features/active/2026-07-22-npm-audit-vulnerabilities-ci-gate-397/evidence/qa-gates/build-final-mcp-server.<timestamp>.md
    - docs/features/active/2026-07-22-npm-audit-vulnerabilities-ci-gate-397/evidence/qa-gates/compile-final-extensions.<timestamp>.md
    - docs/features/active/2026-07-22-npm-audit-vulnerabilities-ci-gate-397/evidence/qa-gates/compile-final-root.<timestamp>.md
    - docs/features/active/2026-07-22-npm-audit-vulnerabilities-ci-gate-397/evidence/qa-gates/final-qa-loop-integrity.<timestamp>.md
    - docs/features/active/2026-07-22-npm-audit-vulnerabilities-ci-gate-397/evidence/qa-gates/npm-audit-gate-ci-confirmation.<timestamp>.md
    - docs/features/active/2026-07-22-npm-audit-vulnerabilities-ci-gate-397/evidence/qa-gates/npm-audit-postfix-extensions.<timestamp>.md
    - docs/features/active/2026-07-22-npm-audit-vulnerabilities-ci-gate-397/evidence/qa-gates/npm-audit-postfix-mcp-server.<timestamp>.md
    - docs/features/active/2026-07-22-npm-audit-vulnerabilities-ci-gate-397/evidence/qa-gates/npm-audit-postfix-root.<timestamp>.md
    - docs/features/active/2026-07-22-npm-audit-vulnerabilities-ci-gate-397/evidence/qa-gates/scope-confirmation.<timestamp>.md
    - docs/features/active/2026-07-22-npm-audit-vulnerabilities-ci-gate-397/evidence/qa-gates/stdio-smoke-final-mcp-server.<timestamp>.md
    - docs/features/active/2026-07-22-npm-audit-vulnerabilities-ci-gate-397/evidence/qa-gates/test-coverage-final-extensions.<timestamp>.md
    - docs/features/active/2026-07-22-npm-audit-vulnerabilities-ci-gate-397/evidence/qa-gates/test-coverage-final-root.<timestamp>.md
    - docs/features/active/2026-07-22-npm-audit-vulnerabilities-ci-gate-397/evidence/qa-gates/test-unit-final-extensions.<timestamp>.md
    - docs/features/active/2026-07-22-npm-audit-vulnerabilities-ci-gate-397/evidence/qa-gates/test-unit-final-root.<timestamp>.md
item 24  issue 409                              2026-07-25-bundled-coverage-path-portability-409
    - docs/features/active/2026-07-25-bundled-coverage-path-portability-409/evidence/baseline/baseline-poshqc-analyze.<ts>.md
    - docs/features/active/2026-07-25-bundled-coverage-path-portability-409/evidence/baseline/baseline-poshqc-format.<ts>.md
    - docs/features/active/2026-07-25-bundled-coverage-path-portability-409/evidence/baseline/baseline-poshqc-test.<ts>.md
    - docs/features/active/2026-07-25-bundled-coverage-path-portability-409/evidence/baseline/baseline-python-black.<ts>.md
    - docs/features/active/2026-07-25-bundled-coverage-path-portability-409/evidence/baseline/baseline-python-pyright.<ts>.md
    - docs/features/active/2026-07-25-bundled-coverage-path-portability-409/evidence/baseline/baseline-python-pytest.<ts>.md
    - docs/features/active/2026-07-25-bundled-coverage-path-portability-409/evidence/baseline/baseline-python-ruff.<ts>.md
    - docs/features/active/2026-07-25-bundled-coverage-path-portability-409/evidence/baseline/coverage-file-set.baseline.<ts>.md
    - docs/features/active/2026-07-25-bundled-coverage-path-portability-409/evidence/other/ac-status-summary.<ts>.md
    - docs/features/active/2026-07-25-bundled-coverage-path-portability-409/evidence/other/consumer-scenario-cleanup.<ts>.md
    - docs/features/active/2026-07-25-bundled-coverage-path-portability-409/evidence/other/file-size-check.<ts>.md
    - docs/features/active/2026-07-25-bundled-coverage-path-portability-409/evidence/other/mirror-hash.<ts>.md
    - docs/features/active/2026-07-25-bundled-coverage-path-portability-409/evidence/qa-gates/coverage-delta.<ts>.md
    - docs/features/active/2026-07-25-bundled-coverage-path-portability-409/evidence/qa-gates/coverage-file-set-delta.<ts>.md
    - docs/features/active/2026-07-25-bundled-coverage-path-portability-409/evidence/qa-gates/direct-module-post-change-run.<ts>.md
    - docs/features/active/2026-07-25-bundled-coverage-path-portability-409/evidence/qa-gates/final-poshqc-analyze.<ts>.md
    - docs/features/active/2026-07-25-bundled-coverage-path-portability-409/evidence/qa-gates/final-poshqc-format.<ts>.md
    - docs/features/active/2026-07-25-bundled-coverage-path-portability-409/evidence/qa-gates/final-poshqc-test.<ts>.md
    - docs/features/active/2026-07-25-bundled-coverage-path-portability-409/evidence/qa-gates/final-python-black.<ts>.md
    - docs/features/active/2026-07-25-bundled-coverage-path-portability-409/evidence/qa-gates/final-python-pyright.<ts>.md
    - docs/features/active/2026-07-25-bundled-coverage-path-portability-409/evidence/qa-gates/final-python-pytest.<ts>.md
    - docs/features/active/2026-07-25-bundled-coverage-path-portability-409/evidence/qa-gates/final-python-ruff.<ts>.md
    - docs/features/active/2026-07-25-bundled-coverage-path-portability-409/evidence/qa-gates/parity-pytest.<ts>.md
    - docs/features/active/2026-07-25-bundled-coverage-path-portability-409/evidence/regression-testing/consumer-scenario.<ts>.md
    - docs/features/active/2026-07-25-bundled-coverage-path-portability-409/evidence/regression-testing/fail-before.<ts>.md
    - docs/features/active/2026-07-25-bundled-coverage-path-portability-409/evidence/regression-testing/pass-after.<ts>.md
    - evidence/regression-testing/fail-before.<ts>.md
    - evidence/regression-testing/pass-after.<ts>.md
item 25  issue 422                              2026-07-25-claude-rules-vitest-jest-divergence-422
    - docs/features/active/2026-07-25-claude-rules-vitest-jest-divergence-422/evidence/baseline/baseline-git-state.<yyyy-MM-ddTHH-mm>.md
    - docs/features/active/2026-07-25-claude-rules-vitest-jest-divergence-422/evidence/baseline/baseline-parity-claude.<yyyy-MM-ddTHH-mm>.md
    - docs/features/active/2026-07-25-claude-rules-vitest-jest-divergence-422/evidence/baseline/baseline-parity-codex-agents.<yyyy-MM-ddTHH-mm>.md
    - docs/features/active/2026-07-25-claude-rules-vitest-jest-divergence-422/evidence/baseline/baseline-python-black.<yyyy-MM-ddTHH-mm>.md
    - docs/features/active/2026-07-25-claude-rules-vitest-jest-divergence-422/evidence/baseline/baseline-python-pyright.<yyyy-MM-ddTHH-mm>.md
    - docs/features/active/2026-07-25-claude-rules-vitest-jest-divergence-422/evidence/baseline/baseline-python-pytest-coverage.<yyyy-MM-ddTHH-mm>.md
    - docs/features/active/2026-07-25-claude-rules-vitest-jest-divergence-422/evidence/baseline/baseline-python-ruff.<yyyy-MM-ddTHH-mm>.md
    - docs/features/active/2026-07-25-claude-rules-vitest-jest-divergence-422/evidence/other/adjacent-finding-dependency-cruiser.<yyyy-MM-ddTHH-mm>.md
    - docs/features/active/2026-07-25-claude-rules-vitest-jest-divergence-422/evidence/other/non-goal-verification.<yyyy-MM-ddTHH-mm>.md
    - docs/features/active/2026-07-25-claude-rules-vitest-jest-divergence-422/evidence/other/npx-jest-resolution.<yyyy-MM-ddTHH-mm>.md
    - docs/features/active/2026-07-25-claude-rules-vitest-jest-divergence-422/evidence/other/parity-after-p2-t1.<yyyy-MM-ddTHH-mm>.md
    - docs/features/active/2026-07-25-claude-rules-vitest-jest-divergence-422/evidence/other/parity-after-p2-t2.<yyyy-MM-ddTHH-mm>.md
    - docs/features/active/2026-07-25-claude-rules-vitest-jest-divergence-422/evidence/other/parity-after-p2-t3.<yyyy-MM-ddTHH-mm>.md
    - docs/features/active/2026-07-25-claude-rules-vitest-jest-divergence-422/evidence/other/parity-after-p2-t4.<yyyy-MM-ddTHH-mm>.md
    - docs/features/active/2026-07-25-claude-rules-vitest-jest-divergence-422/evidence/other/parity-after-p2-t5.<yyyy-MM-ddTHH-mm>.md
    - docs/features/active/2026-07-25-claude-rules-vitest-jest-divergence-422/evidence/other/parity-after-p2-t6.<yyyy-MM-ddTHH-mm>.md
    - docs/features/active/2026-07-25-claude-rules-vitest-jest-divergence-422/evidence/qa-gates/coverage-delta.<yyyy-MM-ddTHH-mm>.md
    - docs/features/active/2026-07-25-claude-rules-vitest-jest-divergence-422/evidence/qa-gates/end-state-changed-files.<yyyy-MM-ddTHH-mm>.md
    - docs/features/active/2026-07-25-claude-rules-vitest-jest-divergence-422/evidence/qa-gates/final-parity-and-regression.<yyyy-MM-ddTHH-mm>.md
    - docs/features/active/2026-07-25-claude-rules-vitest-jest-divergence-422/evidence/qa-gates/final-python-black.<yyyy-MM-ddTHH-mm>.md
    - docs/features/active/2026-07-25-claude-rules-vitest-jest-divergence-422/evidence/qa-gates/final-python-pyright.<yyyy-MM-ddTHH-mm>.md
    - docs/features/active/2026-07-25-claude-rules-vitest-jest-divergence-422/evidence/qa-gates/final-python-pytest-coverage.<yyyy-MM-ddTHH-mm>.md
    - docs/features/active/2026-07-25-claude-rules-vitest-jest-divergence-422/evidence/qa-gates/final-python-ruff.<yyyy-MM-ddTHH-mm>.md
    - docs/features/active/2026-07-25-claude-rules-vitest-jest-divergence-422/evidence/regression-testing/fail-before.<yyyy-MM-ddTHH-mm>.md
    - docs/features/active/2026-07-25-claude-rules-vitest-jest-divergence-422/evidence/regression-testing/pass-after.<yyyy-MM-ddTHH-mm>.md
item 26  issue 415                              2026-07-25-codex-pretooluse-hook-transport-415
    - .codex/hooks/<handler>.ps1
    - FEATURE/evidence/baseline/phase0-black.<ts>.md
    - FEATURE/evidence/baseline/phase0-git-baseline.<ts>.md
    - FEATURE/evidence/baseline/phase0-poshqc-analyze.<ts>.md
    - FEATURE/evidence/baseline/phase0-poshqc-format.<ts>.md
    - FEATURE/evidence/baseline/phase0-poshqc-test.<ts>.md
    - FEATURE/evidence/baseline/phase0-pyright.<ts>.md
    - FEATURE/evidence/baseline/phase0-pytest-parity.<ts>.md
    - FEATURE/evidence/baseline/phase0-ruff.<ts>.md
    - FEATURE/evidence/other/ac-verification.<ts>.md
    - FEATURE/evidence/other/phase1-poshqc-loop.<ts>.md
    - FEATURE/evidence/other/phase1-python-qc.<ts>.md
    - FEATURE/evidence/other/phase2-poshqc-loop.<ts>.md
    - FEATURE/evidence/other/phase3-poshqc-loop.<ts>.md
    - FEATURE/evidence/other/phase4-poshqc-loop.<ts>.md
    - FEATURE/evidence/other/phase5-poshqc-loop.<ts>.md
    - FEATURE/evidence/other/phase6-poshqc-loop.<ts>.md
    - FEATURE/evidence/other/phase7-poshqc-loop.<ts>.md
    - FEATURE/evidence/other/scope-verification.<ts>.md
    - FEATURE/evidence/qa-gates/coverage-comparison.<ts>.md
    - FEATURE/evidence/qa-gates/final-black.<ts>.md
    - FEATURE/evidence/qa-gates/final-poshqc-analyze.<ts>.md
    - FEATURE/evidence/qa-gates/final-poshqc-format.<ts>.md
    - FEATURE/evidence/qa-gates/final-poshqc-test.<ts>.md
    - FEATURE/evidence/qa-gates/final-pyright.<ts>.md
    - FEATURE/evidence/qa-gates/final-pytest-parity.<ts>.md
    - FEATURE/evidence/qa-gates/final-ruff.<ts>.md
    - FEATURE/evidence/regression-testing/fail-before.<ts>.md
    - FEATURE/evidence/regression-testing/issue-335-bundle-orphan-removal.<ts>.md
    - FEATURE/evidence/regression-testing/pass-after.<ts>.md
item 27  issue 423                              2026-07-25-jest-rootdir-testmatch-dot-directory-423
    - <FEATURE>/evidence/baseline/baseline-extension-coverage.<ts>.md
    - <FEATURE>/evidence/baseline/baseline-extension-format.<ts>.md
    - <FEATURE>/evidence/baseline/baseline-extension-lint.<ts>.md
    - <FEATURE>/evidence/baseline/baseline-extension-typecheck.<ts>.md
    - <FEATURE>/evidence/baseline/baseline-git.<ts>.md
    - <FEATURE>/evidence/baseline/baseline-root-format.<ts>.md
    - <FEATURE>/evidence/baseline/baseline-root-lint.<ts>.md
    - <FEATURE>/evidence/baseline/baseline-root-typecheck.<ts>.md
    - <FEATURE>/evidence/baseline/phase0-instructions-read.md
    - <FEATURE>/evidence/other/ac-verification.<ts>.md
    - <FEATURE>/evidence/other/config-diff.<ts>.md
    - <FEATURE>/evidence/other/regression-test-review.<ts>.md
    - <FEATURE>/evidence/other/run-jest-diff.<ts>.md
    - <FEATURE>/evidence/qa-gates/coverage-delta.<ts>.md
    - <FEATURE>/evidence/qa-gates/final-extension-coverage.<ts>.md
    - <FEATURE>/evidence/qa-gates/final-extension-format.<ts>.md
    - <FEATURE>/evidence/qa-gates/final-extension-lint.<ts>.md
    - <FEATURE>/evidence/qa-gates/final-extension-test.<ts>.md
    - <FEATURE>/evidence/qa-gates/final-extension-typecheck.<ts>.md
    - <FEATURE>/evidence/qa-gates/final-loop-summary.<ts>.md
    - <FEATURE>/evidence/qa-gates/final-root-format.<ts>.md
    - <FEATURE>/evidence/qa-gates/final-root-lint.<ts>.md
    - <FEATURE>/evidence/qa-gates/final-root-test.<ts>.md
    - <FEATURE>/evidence/qa-gates/final-root-typecheck.<ts>.md
    - <FEATURE>/evidence/qa-gates/scope-check.<ts>.md
    - <FEATURE>/evidence/regression-testing/fail-before-extension-jest.<ts>.md
    - <FEATURE>/evidence/regression-testing/fail-before-root-jest.<ts>.md
    - <FEATURE>/evidence/regression-testing/guard-extension.<ts>.md
    - <FEATURE>/evidence/regression-testing/guard-root.<ts>.md
    - <FEATURE>/evidence/regression-testing/pass-after-extension-jest.<ts>.md
    - <FEATURE>/evidence/regression-testing/pass-after-root-jest.<ts>.md
    - <FEATURE>/evidence/regression-testing/spot-check-readconfig.<ts>.md
    - <FEATURE>/spec.md
item 28  issue 414                              2026-07-25-npm-audit-brace-expansion-dos-414
    - <EVID>/baseline/compile-extension-baseline.<ts>.md
    - <EVID>/baseline/format-check-root-baseline.<ts>.md
    - <EVID>/baseline/git-baseline.<ts>.md
    - <EVID>/baseline/lint-extension-baseline.<ts>.md
    - <EVID>/baseline/lint-root-baseline.<ts>.md
    - <EVID>/baseline/npm-audit-baseline-mcp-server.<ts>.md
    - <EVID>/baseline/npm-audit-fail-before-extension.<ts>.md
    - <EVID>/baseline/npm-audit-fail-before-root.<ts>.md
    - <EVID>/baseline/npm-ci-extension.<ts>.md
    - <EVID>/baseline/npm-ci-root.<ts>.md
    - <EVID>/baseline/test-coverage-extension.<ts>.md
    - <EVID>/baseline/test-integration-root-baseline.<ts>.md
    - <EVID>/baseline/test-unit-coverage-root.<ts>.md
    - <EVID>/baseline/typecheck-extension-baseline.<ts>.md
    - <EVID>/baseline/typecheck-root-baseline.<ts>.md
    - <EVID>/other/ac-status-summary.<ts>.md
    - <EVID>/other/branch-head.<ts>.md
    - <EVID>/other/change-set-assertion.<ts>.md
    - <EVID>/other/committed-change-set-assertion.<ts>.md
    - <EVID>/other/lockfile-assertions.<ts>.md
    - <EVID>/other/manifest-assertions.<ts>.md
    - <EVID>/other/phase0-instructions-read.md
    - <EVID>/other/preexisting-defects-for-filing.<ts>.md
    - <EVID>/qa-gates/coverage-comparison-extension.<ts>.md
    - <EVID>/qa-gates/coverage-comparison-root.<ts>.md
    - <EVID>/qa-gates/final-compile-extension.<ts>.md
    - <EVID>/qa-gates/final-format-check-root.<ts>.md
    - <EVID>/qa-gates/final-lint-extension.<ts>.md
    - <EVID>/qa-gates/final-lint-root.<ts>.md
    - <EVID>/qa-gates/final-npm-ci-extension.<ts>.md
    - <EVID>/qa-gates/final-npm-ci-root.<ts>.md
    - <EVID>/qa-gates/final-test-coverage-extension.<ts>.md
    - <EVID>/qa-gates/final-test-integration-root.<ts>.md
    - <EVID>/qa-gates/final-test-unit-coverage-root.<ts>.md
    - <EVID>/qa-gates/final-typecheck-extension.<ts>.md
    - <EVID>/qa-gates/final-typecheck-root.<ts>.md
    - <EVID>/qa-gates/mcp-server-install-build.<ts>.md
    - <EVID>/qa-gates/npm-audit-gate-ci.<ts>.md
    - <EVID>/qa-gates/npm-install-extension.<ts>.md
    - <EVID>/qa-gates/npm-install-root.<ts>.md
    - <EVID>/regression-testing/mocha-minimatch-brace-path.<ts>.md
    - <EVID>/regression-testing/npm-audit-pass-after-extension.<ts>.md
    - <EVID>/regression-testing/npm-audit-pass-after-root.<ts>.md
    - <EVID>/regression-testing/npm-audit-post-change-mcp-server.<ts>.md
item 30  issue 413                              2026-07-25-orchestrator-completion-hook-false-block-413
    - <FEATURE>/evidence/baseline/branch-baseline.<ts>.md
    - <FEATURE>/evidence/baseline/parity-pytest.<ts>.md
    - <FEATURE>/evidence/baseline/phase0-instructions-read.md
    - <FEATURE>/evidence/baseline/portable-fallback-verification.<ts>.md
    - <FEATURE>/evidence/baseline/poshqc-analyze.<ts>.md
    - <FEATURE>/evidence/baseline/poshqc-format.<ts>.md
    - <FEATURE>/evidence/baseline/poshqc-test.<ts>.md
    - <FEATURE>/evidence/baseline/test-file-line-budget.<ts>.md
    - <FEATURE>/evidence/issue-updates/issue-413.<ts>.md
    - <FEATURE>/evidence/other/completion-passing-checkpoint.<ts>.json
    - <FEATURE>/evidence/qa-gates/ac-status-summary.<ts>.md
    - <FEATURE>/evidence/qa-gates/bundle-byte-parity.<ts>.md
    - <FEATURE>/evidence/qa-gates/coverage-delta.<ts>.md
    - <FEATURE>/evidence/qa-gates/diff-scope-audit.<ts>.md
    - <FEATURE>/evidence/qa-gates/final-parity-pytest.<ts>.md
    - <FEATURE>/evidence/qa-gates/final-poshqc-analyze.<ts>.md
    - <FEATURE>/evidence/qa-gates/final-poshqc-format.<ts>.md
    - <FEATURE>/evidence/qa-gates/final-poshqc-test.<ts>.md
    - <FEATURE>/evidence/qa-gates/hook-e2e-allow.<ts>.md
    - <FEATURE>/evidence/qa-gates/hook-e2e-live-checkpoint.<ts>.md
    - <FEATURE>/evidence/qa-gates/live-checkpoint-precheck.<ts>.md
    - <FEATURE>/evidence/qa-gates/parity-pytest.<ts>.md
    - <FEATURE>/evidence/regression-testing/fail-before.<ts>.md
    - <FEATURE>/evidence/regression-testing/model-routing-discrimination.<ts>.md
    - <FEATURE>/evidence/regression-testing/pass-after.<ts>.md
    - <FEATURE>/evidence/regression-testing/portable-fallback-tests.<ts>.md
    - <FEATURE>/spec.md
item 31  issue 421                              2026-07-25-root-vscode-test-entrypoint-unrunnable-421
    - docs/features/active/2026-07-25-root-vscode-test-entrypoint-unrunnable-421/evidence/baseline/baseline-ci-inventory.<timestamp>.md
    - docs/features/active/2026-07-25-root-vscode-test-entrypoint-unrunnable-421/evidence/baseline/baseline-format-check-root.<timestamp>.md
    - docs/features/active/2026-07-25-root-vscode-test-entrypoint-unrunnable-421/evidence/baseline/baseline-lint-root.<timestamp>.md
    - docs/features/active/2026-07-25-root-vscode-test-entrypoint-unrunnable-421/evidence/baseline/baseline-npm-ci-root.<timestamp>.md
    - docs/features/active/2026-07-25-root-vscode-test-entrypoint-unrunnable-421/evidence/baseline/baseline-test-coverage-root.<timestamp>.md
    - docs/features/active/2026-07-25-root-vscode-test-entrypoint-unrunnable-421/evidence/baseline/baseline-typecheck-root.<timestamp>.md
    - docs/features/active/2026-07-25-root-vscode-test-entrypoint-unrunnable-421/evidence/baseline/phase0-branch-baseline.<timestamp>.md
    - docs/features/active/2026-07-25-root-vscode-test-entrypoint-unrunnable-421/evidence/other/ac-status-summary.<timestamp>.md
    - docs/features/active/2026-07-25-root-vscode-test-entrypoint-unrunnable-421/evidence/other/ac-verification.<timestamp>.md
    - docs/features/active/2026-07-25-root-vscode-test-entrypoint-unrunnable-421/evidence/other/prior-art-vscode-test-removal-2f67b888.<timestamp>.md
    - docs/features/active/2026-07-25-root-vscode-test-entrypoint-unrunnable-421/evidence/qa-gates/boundary-inventory.<timestamp>.md
    - docs/features/active/2026-07-25-root-vscode-test-entrypoint-unrunnable-421/evidence/qa-gates/ci-green-run-root-typescript-tests.<timestamp>.md
    - docs/features/active/2026-07-25-root-vscode-test-entrypoint-unrunnable-421/evidence/qa-gates/ci-orchestrator-run.<timestamp>.md
    - docs/features/active/2026-07-25-root-vscode-test-entrypoint-unrunnable-421/evidence/qa-gates/coverage-comparison-root.<timestamp>.md
    - docs/features/active/2026-07-25-root-vscode-test-entrypoint-unrunnable-421/evidence/qa-gates/final-format-check-root.<timestamp>.md
    - docs/features/active/2026-07-25-root-vscode-test-entrypoint-unrunnable-421/evidence/qa-gates/final-lint-root.<timestamp>.md
    - docs/features/active/2026-07-25-root-vscode-test-entrypoint-unrunnable-421/evidence/qa-gates/final-qa-clean-pass.<timestamp>.md
    - docs/features/active/2026-07-25-root-vscode-test-entrypoint-unrunnable-421/evidence/qa-gates/final-stages-4-6-7-na-root.<timestamp>.md
    - docs/features/active/2026-07-25-root-vscode-test-entrypoint-unrunnable-421/evidence/qa-gates/final-test-coverage-root.<timestamp>.md
    - docs/features/active/2026-07-25-root-vscode-test-entrypoint-unrunnable-421/evidence/qa-gates/final-typecheck-root.<timestamp>.md
    - docs/features/active/2026-07-25-root-vscode-test-entrypoint-unrunnable-421/evidence/qa-gates/guard-test-local-run.<timestamp>.md
    - docs/features/active/2026-07-25-root-vscode-test-entrypoint-unrunnable-421/evidence/qa-gates/scripts-block-verification.<timestamp>.md
    - docs/features/active/2026-07-25-root-vscode-test-entrypoint-unrunnable-421/evidence/regression-testing/fail-before-npm-test-integration.<timestamp>.md
    - docs/features/active/2026-07-25-root-vscode-test-entrypoint-unrunnable-421/evidence/regression-testing/fail-before-npm-test.<timestamp>.md
item 33  issue 435                              2026-08-04-mixed-promotion-agent-delegation-receipts-435
    - docs/features/active/2026-08-04-mixed-promotion-agent-delegation-receipts-435/evidence/baseline/python-format.<timestamp>.md
    - docs/features/active/2026-08-04-mixed-promotion-agent-delegation-receipts-435/evidence/baseline/python-lint.<timestamp>.md
    - docs/features/active/2026-08-04-mixed-promotion-agent-delegation-receipts-435/evidence/baseline/python-tests-coverage.<timestamp>.md
    - docs/features/active/2026-08-04-mixed-promotion-agent-delegation-receipts-435/evidence/baseline/python-typecheck.<timestamp>.md
    - docs/features/active/2026-08-04-mixed-promotion-agent-delegation-receipts-435/evidence/baseline/typescript-format.<timestamp>.md
    - docs/features/active/2026-08-04-mixed-promotion-agent-delegation-receipts-435/evidence/baseline/typescript-lint.<timestamp>.md
    - docs/features/active/2026-08-04-mixed-promotion-agent-delegation-receipts-435/evidence/baseline/typescript-tests-coverage.<timestamp>.md
    - docs/features/active/2026-08-04-mixed-promotion-agent-delegation-receipts-435/evidence/baseline/typescript-typecheck.<timestamp>.md
    - docs/features/active/2026-08-04-mixed-promotion-agent-delegation-receipts-435/evidence/other/acceptance-criteria-status.<timestamp>.md
    - docs/features/active/2026-08-04-mixed-promotion-agent-delegation-receipts-435/evidence/other/mixed-complete-checkpoint.<timestamp>.json
    - docs/features/active/2026-08-04-mixed-promotion-agent-delegation-receipts-435/evidence/other/runtime-generator-parity.<timestamp>.md
    - docs/features/active/2026-08-04-mixed-promotion-agent-delegation-receipts-435/evidence/qa-gates/coverage-comparison.<timestamp>.md
    - docs/features/active/2026-08-04-mixed-promotion-agent-delegation-receipts-435/evidence/qa-gates/mcp-complete-mixed-checkpoint.<timestamp>.md
    - docs/features/active/2026-08-04-mixed-promotion-agent-delegation-receipts-435/evidence/qa-gates/python-complete-mixed-checkpoint.<timestamp>.md
    - docs/features/active/2026-08-04-mixed-promotion-agent-delegation-receipts-435/evidence/qa-gates/python-format.<timestamp>.md
    - docs/features/active/2026-08-04-mixed-promotion-agent-delegation-receipts-435/evidence/qa-gates/python-lint.<timestamp>.md
    - docs/features/active/2026-08-04-mixed-promotion-agent-delegation-receipts-435/evidence/qa-gates/python-tests-coverage.<timestamp>.md
    - docs/features/active/2026-08-04-mixed-promotion-agent-delegation-receipts-435/evidence/qa-gates/python-typecheck.<timestamp>.md
    - docs/features/active/2026-08-04-mixed-promotion-agent-delegation-receipts-435/evidence/qa-gates/typescript-format.<timestamp>.md
    - docs/features/active/2026-08-04-mixed-promotion-agent-delegation-receipts-435/evidence/qa-gates/typescript-lint.<timestamp>.md
    - docs/features/active/2026-08-04-mixed-promotion-agent-delegation-receipts-435/evidence/qa-gates/typescript-tests-coverage.<timestamp>.md
    - docs/features/active/2026-08-04-mixed-promotion-agent-delegation-receipts-435/evidence/qa-gates/typescript-typecheck.<timestamp>.md
    - docs/features/active/2026-08-04-mixed-promotion-agent-delegation-receipts-435/evidence/regression-testing/python-batch-a-fail-before.<timestamp>.md
    - docs/features/active/2026-08-04-mixed-promotion-agent-delegation-receipts-435/evidence/regression-testing/python-batch-a-pass-after.<timestamp>.md
    - docs/features/active/2026-08-04-mixed-promotion-agent-delegation-receipts-435/evidence/regression-testing/python-batch-b-fail-before.<timestamp>.md
    - docs/features/active/2026-08-04-mixed-promotion-agent-delegation-receipts-435/evidence/regression-testing/python-batch-b-pass-after.<timestamp>.md
    - docs/features/active/2026-08-04-mixed-promotion-agent-delegation-receipts-435/evidence/regression-testing/typescript-batch-a-fail-before.<timestamp>.md
    - docs/features/active/2026-08-04-mixed-promotion-agent-delegation-receipts-435/evidence/regression-testing/typescript-batch-a-pass-after.<timestamp>.md
    - docs/features/active/2026-08-04-mixed-promotion-agent-delegation-receipts-435/evidence/regression-testing/typescript-batch-b-fail-before.<timestamp>.md
    - docs/features/active/2026-08-04-mixed-promotion-agent-delegation-receipts-435/evidence/regression-testing/typescript-batch-b-pass-after.<timestamp>.md
    - evidence/baseline/python-tests-coverage.<timestamp>.md
    - evidence/baseline/typescript-tests-coverage.<timestamp>.md
    - evidence/qa-gates/python-tests-coverage.<timestamp>.md
    - evidence/qa-gates/typescript-tests-coverage.<timestamp>.md
item 34  issue 452                              2026-08-07-blast-radius-under-reporting-gaps-452
    - docs/features/active/2026-08-07-blast-radius-under-reporting-gaps-452/evidence/baseline/phase0-file-sizes.<ts>.md
    - docs/features/active/2026-08-07-blast-radius-under-reporting-gaps-452/evidence/baseline/phase0-fixture-corpus.<ts>.md
    - docs/features/active/2026-08-07-blast-radius-under-reporting-gaps-452/evidence/baseline/phase0-git-baseline.<ts>.md
    - docs/features/active/2026-08-07-blast-radius-under-reporting-gaps-452/evidence/baseline/phase0-monotonicity-truth-table.<ts>.md
    - docs/features/active/2026-08-07-blast-radius-under-reporting-gaps-452/evidence/baseline/phase0-powershell-analyze.<ts>.md
    - docs/features/active/2026-08-07-blast-radius-under-reporting-gaps-452/evidence/baseline/phase0-powershell-format.<ts>.md
    - docs/features/active/2026-08-07-blast-radius-under-reporting-gaps-452/evidence/baseline/phase0-powershell-pester-coverage.<ts>.md
    - docs/features/active/2026-08-07-blast-radius-under-reporting-gaps-452/evidence/baseline/phase0-python-black.<ts>.md
    - docs/features/active/2026-08-07-blast-radius-under-reporting-gaps-452/evidence/baseline/phase0-python-pyright.<ts>.md
    - docs/features/active/2026-08-07-blast-radius-under-reporting-gaps-452/evidence/baseline/phase0-python-pytest-coverage.<ts>.md
    - docs/features/active/2026-08-07-blast-radius-under-reporting-gaps-452/evidence/baseline/phase0-python-ruff.<ts>.md
    - docs/features/active/2026-08-07-blast-radius-under-reporting-gaps-452/evidence/qa-gates/final-acceptance-criteria-status.<ts>.md
    - docs/features/active/2026-08-07-blast-radius-under-reporting-gaps-452/evidence/qa-gates/final-clean-pass-after-relief.<ts>.md
    - docs/features/active/2026-08-07-blast-radius-under-reporting-gaps-452/evidence/qa-gates/final-clean-pass.<ts>.md
    - docs/features/active/2026-08-07-blast-radius-under-reporting-gaps-452/evidence/qa-gates/final-config-unmodified.<ts>.md
    - docs/features/active/2026-08-07-blast-radius-under-reporting-gaps-452/evidence/qa-gates/final-coverage-delta-after-relief.<ts>.md
    - docs/features/active/2026-08-07-blast-radius-under-reporting-gaps-452/evidence/qa-gates/final-coverage-delta.<ts>.md
    - docs/features/active/2026-08-07-blast-radius-under-reporting-gaps-452/evidence/qa-gates/final-file-sizes.<ts>.md
    - docs/features/active/2026-08-07-blast-radius-under-reporting-gaps-452/evidence/qa-gates/final-import-graph-after-relief.<ts>.md
    - docs/features/active/2026-08-07-blast-radius-under-reporting-gaps-452/evidence/qa-gates/final-mirror-contract.<ts>.md
    - docs/features/active/2026-08-07-blast-radius-under-reporting-gaps-452/evidence/qa-gates/final-non-goals-untouched.<ts>.md
    - docs/features/active/2026-08-07-blast-radius-under-reporting-gaps-452/evidence/qa-gates/final-powershell-analyze.<ts>.md
    - docs/features/active/2026-08-07-blast-radius-under-reporting-gaps-452/evidence/qa-gates/final-powershell-format.<ts>.md
    - docs/features/active/2026-08-07-blast-radius-under-reporting-gaps-452/evidence/qa-gates/final-powershell-pester-coverage.<ts>.md
    - docs/features/active/2026-08-07-blast-radius-under-reporting-gaps-452/evidence/qa-gates/final-powershell-untouched-by-relief.<ts>.md
    - docs/features/active/2026-08-07-blast-radius-under-reporting-gaps-452/evidence/qa-gates/final-python-black-after-relief.<ts>.md
    - docs/features/active/2026-08-07-blast-radius-under-reporting-gaps-452/evidence/qa-gates/final-python-black.<ts>.md
    - docs/features/active/2026-08-07-blast-radius-under-reporting-gaps-452/evidence/qa-gates/final-python-pyright-after-relief.<ts>.md
    - docs/features/active/2026-08-07-blast-radius-under-reporting-gaps-452/evidence/qa-gates/final-python-pyright.<ts>.md
    - docs/features/active/2026-08-07-blast-radius-under-reporting-gaps-452/evidence/qa-gates/final-python-pytest-coverage-after-relief.<ts>.md
    - docs/features/active/2026-08-07-blast-radius-under-reporting-gaps-452/evidence/qa-gates/final-python-pytest-coverage.<ts>.md
    - docs/features/active/2026-08-07-blast-radius-under-reporting-gaps-452/evidence/qa-gates/final-python-ruff-after-relief.<ts>.md
    - docs/features/active/2026-08-07-blast-radius-under-reporting-gaps-452/evidence/qa-gates/final-python-ruff.<ts>.md
    - docs/features/active/2026-08-07-blast-radius-under-reporting-gaps-452/evidence/regression-testing/phase0-failbefore-gap1.<ts>.md
    - docs/features/active/2026-08-07-blast-radius-under-reporting-gaps-452/evidence/regression-testing/phase0-failbefore-gap2.<ts>.md
    - docs/features/active/2026-08-07-blast-radius-under-reporting-gaps-452/evidence/regression-testing/phase1-file-sizes.<ts>.md
    - docs/features/active/2026-08-07-blast-radius-under-reporting-gaps-452/evidence/regression-testing/phase1-import-graph.<ts>.md
    - docs/features/active/2026-08-07-blast-radius-under-reporting-gaps-452/evidence/regression-testing/phase1-pure-move-verification.<ts>.md
    - docs/features/active/2026-08-07-blast-radius-under-reporting-gaps-452/evidence/regression-testing/phase10-f1-spec-attribution.<ts>.md
    - docs/features/active/2026-08-07-blast-radius-under-reporting-gaps-452/evidence/regression-testing/phase2-file-sizes.<ts>.md
    - docs/features/active/2026-08-07-blast-radius-under-reporting-gaps-452/evidence/regression-testing/phase2-mirror-contract.<ts>.md
    - docs/features/active/2026-08-07-blast-radius-under-reporting-gaps-452/evidence/regression-testing/phase2-pure-move-verification.<ts>.md
    - docs/features/active/2026-08-07-blast-radius-under-reporting-gaps-452/evidence/regression-testing/phase3-gap1-python-failbefore.<ts>.md
    - docs/features/active/2026-08-07-blast-radius-under-reporting-gaps-452/evidence/regression-testing/phase3-gap1-python-passafter.<ts>.md
    - docs/features/active/2026-08-07-blast-radius-under-reporting-gaps-452/evidence/regression-testing/phase3-single-source-check.<ts>.md
    - docs/features/active/2026-08-07-blast-radius-under-reporting-gaps-452/evidence/regression-testing/phase4-gap1-powershell-failbefore.<ts>.md
    - docs/features/active/2026-08-07-blast-radius-under-reporting-gaps-452/evidence/regression-testing/phase4-gap1-powershell-passafter.<ts>.md
    - docs/features/active/2026-08-07-blast-radius-under-reporting-gaps-452/evidence/regression-testing/phase4-single-source-check.<ts>.md
    - docs/features/active/2026-08-07-blast-radius-under-reporting-gaps-452/evidence/regression-testing/phase5-gap1-powershell-batchb.<ts>.md
    - docs/features/active/2026-08-07-blast-radius-under-reporting-gaps-452/evidence/regression-testing/phase5-gap1-repro-corrected.<ts>.md
    - docs/features/active/2026-08-07-blast-radius-under-reporting-gaps-452/evidence/regression-testing/phase5-gap1-second-defect-test.<ts>.md
    - docs/features/active/2026-08-07-blast-radius-under-reporting-gaps-452/evidence/regression-testing/phase5-gap1-two-language-equivalence.<ts>.md
    - docs/features/active/2026-08-07-blast-radius-under-reporting-gaps-452/evidence/regression-testing/phase6-gap2-python-failbefore.<ts>.md
    - docs/features/active/2026-08-07-blast-radius-under-reporting-gaps-452/evidence/regression-testing/phase6-gap2-python-passafter.<ts>.md
    - docs/features/active/2026-08-07-blast-radius-under-reporting-gaps-452/evidence/regression-testing/phase6-globglob-byte-identity.<ts>.md
    - docs/features/active/2026-08-07-blast-radius-under-reporting-gaps-452/evidence/regression-testing/phase7-gap2-powershell-failbefore.<ts>.md
    - docs/features/active/2026-08-07-blast-radius-under-reporting-gaps-452/evidence/regression-testing/phase7-gap2-powershell-passafter.<ts>.md
    - docs/features/active/2026-08-07-blast-radius-under-reporting-gaps-452/evidence/regression-testing/phase7-gap2-repro-corrected.<ts>.md
    - docs/features/active/2026-08-07-blast-radius-under-reporting-gaps-452/evidence/regression-testing/phase7-mirror-contract.<ts>.md
    - docs/features/active/2026-08-07-blast-radius-under-reporting-gaps-452/evidence/regression-testing/phase7-powershell-unchanged-branches.<ts>.md
    - docs/features/active/2026-08-07-blast-radius-under-reporting-gaps-452/evidence/regression-testing/phase8-fixture-add-only.<ts>.md
    - docs/features/active/2026-08-07-blast-radius-under-reporting-gaps-452/evidence/regression-testing/phase8-parity-drivers.<ts>.md
    - docs/features/active/2026-08-07-blast-radius-under-reporting-gaps-452/evidence/regression-testing/phase9-monotonicity-verification.<ts>.md
    - docs/features/active/2026-08-07-blast-radius-under-reporting-gaps-452/evidence/regression-testing/phase9-regression-guards.<ts>.md
item 35  issue 447                              2026-08-07-parallel-blast-radius-447
    - docs/features/active/2026-08-07-parallel-blast-radius-447/evidence/baseline/baseline-powershell-analyze.<yyyy-MM-ddTHH-mm>.md
    - docs/features/active/2026-08-07-parallel-blast-radius-447/evidence/baseline/baseline-powershell-format.<yyyy-MM-ddTHH-mm>.md
    - docs/features/active/2026-08-07-parallel-blast-radius-447/evidence/baseline/baseline-powershell-test-coverage.<yyyy-MM-ddTHH-mm>.md
    - docs/features/active/2026-08-07-parallel-blast-radius-447/evidence/baseline/baseline-python-format.<yyyy-MM-ddTHH-mm>.md
    - docs/features/active/2026-08-07-parallel-blast-radius-447/evidence/baseline/baseline-python-lint.<yyyy-MM-ddTHH-mm>.md
    - docs/features/active/2026-08-07-parallel-blast-radius-447/evidence/baseline/baseline-python-test-coverage.<ts>.md
    - docs/features/active/2026-08-07-parallel-blast-radius-447/evidence/baseline/baseline-python-test-coverage.<yyyy-MM-ddTHH-mm>.md
    - docs/features/active/2026-08-07-parallel-blast-radius-447/evidence/baseline/baseline-python-typecheck.<yyyy-MM-ddTHH-mm>.md
    - docs/features/active/2026-08-07-parallel-blast-radius-447/evidence/qa-gates/coverage-delta-verification.<yyyy-MM-ddTHH-mm>.md
    - docs/features/active/2026-08-07-parallel-blast-radius-447/evidence/qa-gates/final-powershell-analyze.<yyyy-MM-ddTHH-mm>.md
    - docs/features/active/2026-08-07-parallel-blast-radius-447/evidence/qa-gates/final-powershell-format.<yyyy-MM-ddTHH-mm>.md
    - docs/features/active/2026-08-07-parallel-blast-radius-447/evidence/qa-gates/final-powershell-test-coverage.<yyyy-MM-ddTHH-mm>.md
    - docs/features/active/2026-08-07-parallel-blast-radius-447/evidence/qa-gates/final-python-format.<yyyy-MM-ddTHH-mm>.md
    - docs/features/active/2026-08-07-parallel-blast-radius-447/evidence/qa-gates/final-python-lint.<yyyy-MM-ddTHH-mm>.md
    - docs/features/active/2026-08-07-parallel-blast-radius-447/evidence/qa-gates/final-python-test-coverage.<yyyy-MM-ddTHH-mm>.md
    - docs/features/active/2026-08-07-parallel-blast-radius-447/evidence/qa-gates/final-python-typecheck.<yyyy-MM-ddTHH-mm>.md
    - docs/features/active/2026-08-07-parallel-blast-radius-447/evidence/qa-gates/guardrail-verification.<yyyy-MM-ddTHH-mm>.md
    - docs/features/active/<feature-folder>/**
    - evidence/qa-gates/coverage-delta-verification.<ts>.md
    - evidence/qa-gates/final-python-test-coverage.<ts>.md
item 36  issue 445                              2026-08-07-parallel-cohort-scheduler-445
    - docs/features/active/2026-08-07-parallel-cohort-scheduler-445/evidence/baseline/baseline-black.<yyyy-MM-ddTHH-mm>.md
    - docs/features/active/2026-08-07-parallel-cohort-scheduler-445/evidence/baseline/baseline-pyright.<yyyy-MM-ddTHH-mm>.md
    - docs/features/active/2026-08-07-parallel-cohort-scheduler-445/evidence/baseline/baseline-pytest.<yyyy-MM-ddTHH-mm>.md
    - docs/features/active/2026-08-07-parallel-cohort-scheduler-445/evidence/baseline/baseline-ruff.<yyyy-MM-ddTHH-mm>.md
    - docs/features/active/2026-08-07-parallel-cohort-scheduler-445/evidence/other/acceptance-criteria-map.<yyyy-MM-ddTHH-mm>.md
    - docs/features/active/2026-08-07-parallel-cohort-scheduler-445/evidence/other/additive-only-check.<yyyy-MM-ddTHH-mm>.md
    - docs/features/active/2026-08-07-parallel-cohort-scheduler-445/evidence/other/file-size-check.<yyyy-MM-ddTHH-mm>.md
    - docs/features/active/2026-08-07-parallel-cohort-scheduler-445/evidence/qa-gates/coverage-delta.<yyyy-MM-ddTHH-mm>.md
    - docs/features/active/2026-08-07-parallel-cohort-scheduler-445/evidence/qa-gates/final-qc-black.<yyyy-MM-ddTHH-mm>.md
    - docs/features/active/2026-08-07-parallel-cohort-scheduler-445/evidence/qa-gates/final-qc-pyright.<yyyy-MM-ddTHH-mm>.md
    - docs/features/active/2026-08-07-parallel-cohort-scheduler-445/evidence/qa-gates/final-qc-pytest.<yyyy-MM-ddTHH-mm>.md
    - docs/features/active/2026-08-07-parallel-cohort-scheduler-445/evidence/qa-gates/final-qc-ruff.<yyyy-MM-ddTHH-mm>.md
    - docs/features/active/2026-08-07-parallel-cohort-scheduler-445/evidence/regression-testing/new-module-tests.<yyyy-MM-ddTHH-mm>.md
item 37  issue 446                              2026-08-07-parallel-drift-detection-446
    - docs/features/active/2026-08-07-parallel-drift-detection-446/evidence/baseline/powershell-analyze-baseline.<timestamp>.md
    - docs/features/active/2026-08-07-parallel-drift-detection-446/evidence/baseline/powershell-format-baseline.<timestamp>.md
    - docs/features/active/2026-08-07-parallel-drift-detection-446/evidence/baseline/powershell-test-baseline.<timestamp>.md
    - docs/features/active/2026-08-07-parallel-drift-detection-446/evidence/baseline/python-format-baseline.<timestamp>.md
    - docs/features/active/2026-08-07-parallel-drift-detection-446/evidence/baseline/python-lint-baseline.<timestamp>.md
    - docs/features/active/2026-08-07-parallel-drift-detection-446/evidence/baseline/python-test-baseline.<timestamp>.md
    - docs/features/active/2026-08-07-parallel-drift-detection-446/evidence/baseline/python-typecheck-baseline.<timestamp>.md
    - docs/features/active/2026-08-07-parallel-drift-detection-446/evidence/other/shared-file-edit-confinement.<timestamp>.md
    - docs/features/active/2026-08-07-parallel-drift-detection-446/evidence/other/upstream-contract-reconciliation.<timestamp>.md
    - docs/features/active/2026-08-07-parallel-drift-detection-446/evidence/qa-gates/acceptance-criteria-checkoff.<timestamp>.md
    - docs/features/active/2026-08-07-parallel-drift-detection-446/evidence/qa-gates/coverage-delta.<timestamp>.md
    - docs/features/active/2026-08-07-parallel-drift-detection-446/evidence/qa-gates/powershell-analyze-final.<timestamp>.md
    - docs/features/active/2026-08-07-parallel-drift-detection-446/evidence/qa-gates/powershell-format-final.<timestamp>.md
    - docs/features/active/2026-08-07-parallel-drift-detection-446/evidence/qa-gates/powershell-test-final.<timestamp>.md
    - docs/features/active/2026-08-07-parallel-drift-detection-446/evidence/qa-gates/python-format-final.<timestamp>.md
    - docs/features/active/2026-08-07-parallel-drift-detection-446/evidence/qa-gates/python-lint-final.<timestamp>.md
    - docs/features/active/2026-08-07-parallel-drift-detection-446/evidence/qa-gates/python-test-final.<timestamp>.md
    - docs/features/active/2026-08-07-parallel-drift-detection-446/evidence/qa-gates/python-typecheck-final.<timestamp>.md
    - docs/features/active/<child-slug>/remediation-inputs.<yyyy-MM-ddTHH-mm>.md
    - evidence/baseline/powershell-test-baseline.<timestamp>.md
    - evidence/baseline/python-test-baseline.<timestamp>.md
    - evidence/qa-gates/coverage-delta.<timestamp>.md
    - evidence/qa-gates/powershell-test-final.<timestamp>.md
    - evidence/qa-gates/python-test-final.<timestamp>.md
item 38  issue 440                              2026-08-07-parallel-enforcement-hooks-440
    - .claude/state/powershell-batch-budget.<session_id>.json
    - docs/features/active/2026-08-07-parallel-enforcement-hooks-440/evidence/baseline/powershell-analyze.<timestamp>.md
    - docs/features/active/2026-08-07-parallel-enforcement-hooks-440/evidence/baseline/powershell-format.<timestamp>.md
    - docs/features/active/2026-08-07-parallel-enforcement-hooks-440/evidence/baseline/powershell-tests-coverage.<timestamp>.md
    - docs/features/active/2026-08-07-parallel-enforcement-hooks-440/evidence/baseline/python-format.<timestamp>.md
    - docs/features/active/2026-08-07-parallel-enforcement-hooks-440/evidence/baseline/python-lint.<timestamp>.md
    - docs/features/active/2026-08-07-parallel-enforcement-hooks-440/evidence/baseline/python-tests-coverage.<timestamp>.md
    - docs/features/active/2026-08-07-parallel-enforcement-hooks-440/evidence/baseline/python-typecheck.<timestamp>.md
    - docs/features/active/2026-08-07-parallel-enforcement-hooks-440/evidence/other/acceptance-criteria-status.<timestamp>.md
    - docs/features/active/2026-08-07-parallel-enforcement-hooks-440/evidence/other/frozen-constants.<timestamp>.md
    - docs/features/active/2026-08-07-parallel-enforcement-hooks-440/evidence/other/powershell-batch-reset.<timestamp>.md
    - docs/features/active/2026-08-07-parallel-enforcement-hooks-440/evidence/other/settings-json-validity.<timestamp>.md
    - docs/features/active/2026-08-07-parallel-enforcement-hooks-440/evidence/other/subagentstop-registration-decision.<timestamp>.md
    - docs/features/active/2026-08-07-parallel-enforcement-hooks-440/evidence/other/upstream-contract-halt.<timestamp>.md
    - docs/features/active/2026-08-07-parallel-enforcement-hooks-440/evidence/other/upstream-contract-verification.<timestamp>.md
    - docs/features/active/2026-08-07-parallel-enforcement-hooks-440/evidence/qa-gates/coverage-comparison.<timestamp>.md
    - docs/features/active/2026-08-07-parallel-enforcement-hooks-440/evidence/qa-gates/powershell-analyze.<timestamp>.md
    - docs/features/active/2026-08-07-parallel-enforcement-hooks-440/evidence/qa-gates/powershell-format.<timestamp>.md
    - docs/features/active/2026-08-07-parallel-enforcement-hooks-440/evidence/qa-gates/powershell-tests-coverage.<timestamp>.md
    - docs/features/active/2026-08-07-parallel-enforcement-hooks-440/evidence/qa-gates/python-format.<timestamp>.md
    - docs/features/active/2026-08-07-parallel-enforcement-hooks-440/evidence/qa-gates/python-lint.<timestamp>.md
    - docs/features/active/2026-08-07-parallel-enforcement-hooks-440/evidence/qa-gates/python-tests-coverage.<timestamp>.md
    - docs/features/active/2026-08-07-parallel-enforcement-hooks-440/evidence/qa-gates/python-typecheck.<timestamp>.md
    - docs/features/active/2026-08-07-parallel-enforcement-hooks-440/evidence/regression-testing/phase1-powershell-analyze.<timestamp>.md
    - docs/features/active/2026-08-07-parallel-enforcement-hooks-440/evidence/regression-testing/phase1-powershell-format.<timestamp>.md
    - docs/features/active/2026-08-07-parallel-enforcement-hooks-440/evidence/regression-testing/phase1-powershell-tests.<timestamp>.md
    - docs/features/active/2026-08-07-parallel-enforcement-hooks-440/evidence/regression-testing/phase2-powershell-analyze.<timestamp>.md
    - docs/features/active/2026-08-07-parallel-enforcement-hooks-440/evidence/regression-testing/phase2-powershell-format.<timestamp>.md
    - docs/features/active/2026-08-07-parallel-enforcement-hooks-440/evidence/regression-testing/phase2-powershell-tests.<timestamp>.md
    - docs/features/active/2026-08-07-parallel-enforcement-hooks-440/evidence/regression-testing/phase3-python-format.<timestamp>.md
    - docs/features/active/2026-08-07-parallel-enforcement-hooks-440/evidence/regression-testing/phase3-python-lint.<timestamp>.md
    - docs/features/active/2026-08-07-parallel-enforcement-hooks-440/evidence/regression-testing/phase3-python-tests.<timestamp>.md
    - docs/features/active/2026-08-07-parallel-enforcement-hooks-440/evidence/regression-testing/phase3-python-typecheck.<timestamp>.md
    - evidence/baseline/powershell-tests-coverage.<timestamp>.md
    - evidence/baseline/python-tests-coverage.<timestamp>.md
    - evidence/qa-gates/coverage-comparison.<timestamp>.md
    - evidence/qa-gates/powershell-tests-coverage.<timestamp>.md
    - evidence/qa-gates/python-tests-coverage.<timestamp>.md
item 39  issue 442                              2026-08-07-parallel-mutation-protocol-442
    - <FEATURE>/evidence/baseline/baseline-ps-analyze.md
    - <FEATURE>/evidence/baseline/baseline-ps-test-coverage.md
    - <FEATURE>/evidence/baseline/baseline-py-lint.md
    - <FEATURE>/evidence/baseline/baseline-py-test-coverage.md
    - <FEATURE>/evidence/baseline/baseline-py-typecheck.md
    - <FEATURE>/evidence/baseline/phase0-instructions-read.md
    - <FEATURE>/evidence/other/property-test-tooling-decision.md
    - <FEATURE>/evidence/other/settings-insertion-point.md
    - <FEATURE>/evidence/other/upstream-branch-verification.md
    - <FEATURE>/evidence/other/upstream-f1-conflicts-signature.md
    - <FEATURE>/evidence/other/upstream-f2-coloring-signature.md
    - <FEATURE>/evidence/other/upstream-f3-mutations-schema.md
    - <FEATURE>/evidence/other/upstream-f5-skill-sections.md
    - <FEATURE>/evidence/other/upstream-reconciliation-gate.md
    - <FEATURE>/evidence/qa-gates/ac-status-summary.md
    - <FEATURE>/evidence/qa-gates/coverage-delta-verification.md
    - <FEATURE>/evidence/qa-gates/file-size-cap-verification.md
    - <FEATURE>/evidence/qa-gates/final-ps-analyze.md
    - <FEATURE>/evidence/qa-gates/final-ps-format.md
    - <FEATURE>/evidence/qa-gates/final-ps-test-coverage.md
    - <FEATURE>/evidence/qa-gates/final-py-format.md
    - <FEATURE>/evidence/qa-gates/final-py-lint.md
    - <FEATURE>/evidence/qa-gates/final-py-test-coverage.md
    - <FEATURE>/evidence/qa-gates/final-py-typecheck.md
    - <FEATURE>/evidence/qa-gates/wave4-confinement-verification.md
    - <FEATURE>/evidence/regression-testing/abandon-token-seam-binding.md
    - <FEATURE>/spec.md
    - <FEATURE>/user-story.md
item 40  issue 441                              2026-08-07-parallel-orchestrator-surface-441
    - docs/features/active/2026-08-07-parallel-orchestrator-surface-441/evidence/baseline/baseline-black.<yyyy-MM-ddTHH-mm>.md
    - docs/features/active/2026-08-07-parallel-orchestrator-surface-441/evidence/baseline/baseline-frozen-surface-hashes.<yyyy-MM-ddTHH-mm>.md
    - docs/features/active/2026-08-07-parallel-orchestrator-surface-441/evidence/baseline/baseline-pyright.<yyyy-MM-ddTHH-mm>.md
    - docs/features/active/2026-08-07-parallel-orchestrator-surface-441/evidence/baseline/baseline-pytest-coverage.<yyyy-MM-ddTHH-mm>.md
    - docs/features/active/2026-08-07-parallel-orchestrator-surface-441/evidence/baseline/baseline-ruff.<yyyy-MM-ddTHH-mm>.md
    - docs/features/active/2026-08-07-parallel-orchestrator-surface-441/evidence/baseline/baseline-upstream-contracts.<yyyy-MM-ddTHH-mm>.md
    - docs/features/active/2026-08-07-parallel-orchestrator-surface-441/evidence/other/ac-status-summary.<yyyy-MM-ddTHH-mm>.md
    - docs/features/active/2026-08-07-parallel-orchestrator-surface-441/evidence/other/bundle-parity-verification.<yyyy-MM-ddTHH-mm>.md
    - docs/features/active/2026-08-07-parallel-orchestrator-surface-441/evidence/other/f7-coordination-note.<yyyy-MM-ddTHH-mm>.md
    - docs/features/active/2026-08-07-parallel-orchestrator-surface-441/evidence/other/frozen-surface-verification.<yyyy-MM-ddTHH-mm>.md
    - docs/features/active/2026-08-07-parallel-orchestrator-surface-441/evidence/other/no-hook-or-settings-change.<yyyy-MM-ddTHH-mm>.md
    - docs/features/active/2026-08-07-parallel-orchestrator-surface-441/evidence/qa-gates/coverage-delta.<yyyy-MM-ddTHH-mm>.md
    - docs/features/active/2026-08-07-parallel-orchestrator-surface-441/evidence/qa-gates/final-qc-black.<yyyy-MM-ddTHH-mm>.md
    - docs/features/active/2026-08-07-parallel-orchestrator-surface-441/evidence/qa-gates/final-qc-pyright.<yyyy-MM-ddTHH-mm>.md
    - docs/features/active/2026-08-07-parallel-orchestrator-surface-441/evidence/qa-gates/final-qc-pytest-coverage.<yyyy-MM-ddTHH-mm>.md
    - docs/features/active/2026-08-07-parallel-orchestrator-surface-441/evidence/qa-gates/final-qc-ruff.<yyyy-MM-ddTHH-mm>.md
    - docs/features/active/2026-08-07-parallel-orchestrator-surface-441/evidence/regression-testing/bundle-parity.<yyyy-MM-ddTHH-mm>.md
    - docs/features/active/2026-08-07-parallel-orchestrator-surface-441/evidence/regression-testing/contract-tests-pass.<yyyy-MM-ddTHH-mm>.md
    - docs/features/parallel/<slug>/parallel-kickoff.md
    - docs/features/parallel/<slug>/parallel-status.md
    - docs/features/parallel/<slug>/parallel.md
    - evidence/baseline/baseline-pytest-coverage.<ts>.md
    - evidence/qa-gates/coverage-delta.<ts>.md
    - evidence/qa-gates/final-qc-pytest-coverage.<ts>.md
item 41  issue 443                              2026-08-07-parallel-planner-surface-443
    - docs/features/active/2026-08-07-parallel-planner-surface-443/evidence/baseline/black-baseline.<ts>.md
    - docs/features/active/2026-08-07-parallel-planner-surface-443/evidence/baseline/pyright-baseline.<ts>.md
    - docs/features/active/2026-08-07-parallel-planner-surface-443/evidence/baseline/pytest-coverage-baseline.<ts>.md
    - docs/features/active/2026-08-07-parallel-planner-surface-443/evidence/baseline/ruff-baseline.<ts>.md
    - docs/features/active/2026-08-07-parallel-planner-surface-443/evidence/other/ac-status-summary.<ts>.md
    - docs/features/active/2026-08-07-parallel-planner-surface-443/evidence/other/agent-persona-verification.<ts>.md
    - docs/features/active/2026-08-07-parallel-planner-surface-443/evidence/other/kickoff-module-size.<ts>.md
    - docs/features/active/2026-08-07-parallel-planner-surface-443/evidence/other/non-modification-atomic-plan-contract.<ts>.md
    - docs/features/active/2026-08-07-parallel-planner-surface-443/evidence/other/non-modification-epic-surfaces.<ts>.md
    - docs/features/active/2026-08-07-parallel-planner-surface-443/evidence/other/non-modification-f3-surfaces.<ts>.md
    - docs/features/active/2026-08-07-parallel-planner-surface-443/evidence/other/non-modification-orchestrate-route.<ts>.md
    - docs/features/active/2026-08-07-parallel-planner-surface-443/evidence/other/skill-verification.<ts>.md
    - docs/features/active/2026-08-07-parallel-planner-surface-443/evidence/other/upstream-reconciliation.<ts>.md
    - docs/features/active/2026-08-07-parallel-planner-surface-443/evidence/qa-gates/black-final.<ts>.md
    - docs/features/active/2026-08-07-parallel-planner-surface-443/evidence/qa-gates/coverage-delta.<ts>.md
    - docs/features/active/2026-08-07-parallel-planner-surface-443/evidence/qa-gates/eslint-final.<ts>.md
    - docs/features/active/2026-08-07-parallel-planner-surface-443/evidence/qa-gates/jest-coverage-final.<ts>.md
    - docs/features/active/2026-08-07-parallel-planner-surface-443/evidence/qa-gates/npm-ci-extension.<ts>.md
    - docs/features/active/2026-08-07-parallel-planner-surface-443/evidence/qa-gates/prettier-final.<ts>.md
    - docs/features/active/2026-08-07-parallel-planner-surface-443/evidence/qa-gates/pyright-final.<ts>.md
    - docs/features/active/2026-08-07-parallel-planner-surface-443/evidence/qa-gates/pytest-coverage-final.<ts>.md
    - docs/features/active/2026-08-07-parallel-planner-surface-443/evidence/qa-gates/ruff-final.<ts>.md
    - docs/features/active/2026-08-07-parallel-planner-surface-443/evidence/qa-gates/tsc-final.<ts>.md
    - docs/features/active/2026-08-07-parallel-planner-surface-443/evidence/regression-testing/contract-test-run.<ts>.md
    - docs/features/active/2026-08-07-parallel-planner-surface-443/evidence/regression-testing/kickoff-contract-test-run.<ts>.md
    - docs/features/active/2026-08-07-parallel-planner-surface-443/evidence/regression-testing/kickoff-wiring-test-run.<ts>.md
    - docs/features/active/2026-08-07-parallel-planner-surface-443/evidence/regression-testing/mirror-gate-run.<ts>.md
    - docs/features/parallel/<slug>/**
    - docs/features/parallel/<slug>/parallel-kickoff.md
    - docs/features/parallel/<slug>/parallel.md
item 42  issue 444                              2026-08-07-parallel-schema-validators-444
    - docs/features/active/2026-08-07-parallel-schema-validators-444/evidence/baseline/python-format-baseline.<ts>.md
    - docs/features/active/2026-08-07-parallel-schema-validators-444/evidence/baseline/python-lint-baseline.<ts>.md
    - docs/features/active/2026-08-07-parallel-schema-validators-444/evidence/baseline/python-test-coverage-baseline.<ts>.md
    - docs/features/active/2026-08-07-parallel-schema-validators-444/evidence/baseline/python-typecheck-baseline.<ts>.md
    - docs/features/active/2026-08-07-parallel-schema-validators-444/evidence/baseline/quality-tiers-observed.<ts>.md
    - docs/features/active/2026-08-07-parallel-schema-validators-444/evidence/baseline/ts-format-baseline.<ts>.md
    - docs/features/active/2026-08-07-parallel-schema-validators-444/evidence/baseline/ts-lint-baseline.<ts>.md
    - docs/features/active/2026-08-07-parallel-schema-validators-444/evidence/baseline/ts-test-coverage-baseline.<ts>.md
    - docs/features/active/2026-08-07-parallel-schema-validators-444/evidence/baseline/ts-typecheck-baseline.<ts>.md
    - docs/features/active/2026-08-07-parallel-schema-validators-444/evidence/other/property-test-decision.<ts>.md
    - docs/features/active/2026-08-07-parallel-schema-validators-444/evidence/other/quality-tiers-classification.<ts>.md
    - docs/features/active/2026-08-07-parallel-schema-validators-444/evidence/qa-gates/coverage-delta.<ts>.md
    - docs/features/active/2026-08-07-parallel-schema-validators-444/evidence/qa-gates/epic-unchanged.<ts>.md
    - docs/features/active/2026-08-07-parallel-schema-validators-444/evidence/qa-gates/file-size-verification.<ts>.md
    - docs/features/active/2026-08-07-parallel-schema-validators-444/evidence/qa-gates/final-qc-python-format.<ts>.md
    - docs/features/active/2026-08-07-parallel-schema-validators-444/evidence/qa-gates/final-qc-python-lint.<ts>.md
    - docs/features/active/2026-08-07-parallel-schema-validators-444/evidence/qa-gates/final-qc-python-test-coverage.<ts>.md
    - docs/features/active/2026-08-07-parallel-schema-validators-444/evidence/qa-gates/final-qc-python-typecheck.<ts>.md
    - docs/features/active/2026-08-07-parallel-schema-validators-444/evidence/qa-gates/final-qc-ts-format.<ts>.md
    - docs/features/active/2026-08-07-parallel-schema-validators-444/evidence/qa-gates/final-qc-ts-lint.<ts>.md
    - docs/features/active/2026-08-07-parallel-schema-validators-444/evidence/qa-gates/final-qc-ts-test-coverage.<ts>.md
    - docs/features/active/2026-08-07-parallel-schema-validators-444/evidence/qa-gates/final-qc-ts-typecheck.<ts>.md
    - docs/features/parallel/<slug>/parallel-status.md
    - docs/features/parallel/<slug>/parallel.md
    - evidence/baseline/ts-test-coverage-baseline.<ts>.md
    - evidence/qa-gates/coverage-delta.<ts>.md
    - evidence/qa-gates/final-qc-python-test-coverage.<ts>.md
    - evidence/qa-gates/final-qc-ts-test-coverage.<ts>.md
item 43  issue 462                              2026-08-10-parallel-surface-destination-portability-bash-462
    - <FEATURE>/evidence/baseline/environment-constraints.<ts>.md
    - <FEATURE>/evidence/baseline/phase0-instructions-read.md
    - <FEATURE>/evidence/baseline/python-baseline.<ts>.md
    - <FEATURE>/evidence/baseline/shell-baseline.<ts>.md
    - <FEATURE>/evidence/baseline/typescript-baseline.<ts>.md
    - <FEATURE>/evidence/baseline/{python,typescript,shell}-baseline.<ts>.md
    - <FEATURE>/evidence/other/permission-surface-callout.<ts>.md
    - <FEATURE>/evidence/qa-gates/acceptance-criteria-checkoff.<ts>.md
    - <FEATURE>/evidence/qa-gates/bundle-parity.<ts>.md
    - <FEATURE>/evidence/qa-gates/coverage-delta.<ts>.md
    - <FEATURE>/evidence/qa-gates/final-python-format.<ts>.md
    - <FEATURE>/evidence/qa-gates/final-python-lint.<ts>.md
    - <FEATURE>/evidence/qa-gates/final-python-test.<ts>.md
    - <FEATURE>/evidence/qa-gates/final-python-typecheck.<ts>.md
    - <FEATURE>/evidence/qa-gates/final-shell-gate-head.<ts>.md
    - <FEATURE>/evidence/qa-gates/final-shell-gate.<ts>.md
    - <FEATURE>/evidence/qa-gates/final-ts-arch.<ts>.md
    - <FEATURE>/evidence/qa-gates/final-ts-format.<ts>.md
    - <FEATURE>/evidence/qa-gates/final-ts-lint.<ts>.md
    - <FEATURE>/evidence/qa-gates/final-ts-test.<ts>.md
    - <FEATURE>/evidence/qa-gates/final-ts-typecheck.<ts>.md
    - <FEATURE>/evidence/qa-gates/final-{python,ts}-test.<ts>.md
    - <FEATURE>/evidence/qa-gates/poetry-grep.<ts>.md
    - <FEATURE>/evidence/qa-gates/schema-freeze.<ts>.md
    - <FEATURE>/evidence/qa-gates/shell-gate-phase3.<ts>.md
    - <FEATURE>/evidence/regression-testing/python-parity-suites.<ts>.md
    - <FEATURE>/spec.md
    - <FEATURE>/user-story.md
item 44  issue 469                              2026-08-13-csharp-legacy-gate-command-correctness-469
    - docs/features/active/2026-08-13-csharp-legacy-gate-command-correctness-469/evidence/issue-updates/issue-469.<TS>.md
    - docs/features/active/2026-08-13-csharp-legacy-gate-command-correctness-469/evidence/other/scope-verification.<TS>.md
    - docs/features/active/2026-08-13-csharp-legacy-gate-command-correctness-469/evidence/other/traceability.<TS>.md
    - docs/features/active/2026-08-13-csharp-legacy-gate-command-correctness-469/evidence/qa-gates/coverage-comparison.<TS>.md
    - docs/features/active/2026-08-13-csharp-legacy-gate-command-correctness-469/evidence/qa-gates/final-python-format.<TS>.md
    - docs/features/active/2026-08-13-csharp-legacy-gate-command-correctness-469/evidence/qa-gates/final-python-lint.<TS>.md
    - docs/features/active/2026-08-13-csharp-legacy-gate-command-correctness-469/evidence/qa-gates/final-python-tests-coverage.<TS>.md
    - docs/features/active/2026-08-13-csharp-legacy-gate-command-correctness-469/evidence/qa-gates/final-python-typecheck.<TS>.md
    - docs/features/active/2026-08-13-csharp-legacy-gate-command-correctness-469/evidence/qa-gates/final-typescript-format.<TS>.md
    - docs/features/active/2026-08-13-csharp-legacy-gate-command-correctness-469/evidence/qa-gates/final-typescript-lint.<TS>.md
    - docs/features/active/2026-08-13-csharp-legacy-gate-command-correctness-469/evidence/qa-gates/final-typescript-tests-coverage.<TS>.md
    - docs/features/active/2026-08-13-csharp-legacy-gate-command-correctness-469/evidence/qa-gates/final-typescript-typecheck.<TS>.md
    - docs/features/active/2026-08-13-csharp-legacy-gate-command-correctness-469/evidence/regression-testing/fail-before-contract-tests.<TS>.md
    - docs/features/active/2026-08-13-csharp-legacy-gate-command-correctness-469/evidence/regression-testing/modern-invariant-baseline.<TS>.md
    - docs/features/active/2026-08-13-csharp-legacy-gate-command-correctness-469/evidence/regression-testing/pass-after-contract-tests.<TS>.md
    - docs/features/active/2026-08-13-csharp-legacy-gate-command-correctness-469/evidence/regression-testing/push-down-suite.<TS>.md
item 45  issue 472                              2026-08-15-blast-radius-module-map-forces-serial-runs-472
    - .../evidence/qa-gates/final-ts-test-coverage.<ISO-8601>.md
    - .../final-py-pytest-coverage.<ISO-8601>.md
    - docs/features/active/2026-08-15-blast-radius-module-map-forces-serial-runs-472/evidence/qa-gates/ac15-python-surface-unchanged.<ISO-8601>.md
    - docs/features/active/2026-08-15-blast-radius-module-map-forces-serial-runs-472/evidence/qa-gates/coverage-comparison.<ISO-8601>.md
    - docs/features/active/2026-08-15-blast-radius-module-map-forces-serial-runs-472/evidence/qa-gates/final-ps-analyze.<ISO-8601>.md
    - docs/features/active/2026-08-15-blast-radius-module-map-forces-serial-runs-472/evidence/qa-gates/final-ps-format.<ISO-8601>.md
    - docs/features/active/2026-08-15-blast-radius-module-map-forces-serial-runs-472/evidence/qa-gates/final-ps-pester.<ISO-8601>.md
    - docs/features/active/2026-08-15-blast-radius-module-map-forces-serial-runs-472/evidence/qa-gates/final-py-black.<ISO-8601>.md
    - docs/features/active/2026-08-15-blast-radius-module-map-forces-serial-runs-472/evidence/qa-gates/final-py-pyright.<ISO-8601>.md
    - docs/features/active/2026-08-15-blast-radius-module-map-forces-serial-runs-472/evidence/qa-gates/final-py-pytest-coverage.<ISO-8601>.md
    - docs/features/active/2026-08-15-blast-radius-module-map-forces-serial-runs-472/evidence/qa-gates/final-py-ruff.<ISO-8601>.md
    - docs/features/active/2026-08-15-blast-radius-module-map-forces-serial-runs-472/evidence/qa-gates/final-qa-summary.<ISO-8601>.md
    - docs/features/active/2026-08-15-blast-radius-module-map-forces-serial-runs-472/evidence/qa-gates/final-ts-format.<ISO-8601>.md
    - docs/features/active/2026-08-15-blast-radius-module-map-forces-serial-runs-472/evidence/qa-gates/final-ts-lint.<ISO-8601>.md
    - docs/features/active/2026-08-15-blast-radius-module-map-forces-serial-runs-472/evidence/qa-gates/final-ts-test-coverage.<ISO-8601>.md
    - docs/features/active/2026-08-15-blast-radius-module-map-forces-serial-runs-472/evidence/qa-gates/final-ts-typecheck.<ISO-8601>.md
    - docs/features/active/2026-08-15-blast-radius-module-map-forces-serial-runs-472/evidence/regression-testing/expected-red-ts-phase3.<ISO-8601>.md
    - docs/features/active/2026-08-15-blast-radius-module-map-forces-serial-runs-472/evidence/regression-testing/expected-red-ts-phase4.<ISO-8601>.md
    - docs/features/active/2026-08-15-blast-radius-module-map-forces-serial-runs-472/evidence/regression-testing/fail-before-pester.<ISO-8601>.md
    - docs/features/active/2026-08-15-blast-radius-module-map-forces-serial-runs-472/evidence/regression-testing/fail-before-pytest.<ISO-8601>.md
    - docs/features/active/2026-08-15-blast-radius-module-map-forces-serial-runs-472/evidence/regression-testing/pass-after-config-keys.<ISO-8601>.md
    - docs/features/active/2026-08-15-blast-radius-module-map-forces-serial-runs-472/evidence/regression-testing/pass-after-pester.<ISO-8601>.md
    - docs/features/active/2026-08-15-blast-radius-module-map-forces-serial-runs-472/evidence/regression-testing/pass-after-pytest.<ISO-8601>.md
item 46  issue 475                              2026-08-15-enforcement-hooks-must-not-invoke-python-475
    - .claude/state/powershell-batch-budget.<session_id>.json
    - docs/features/active/2026-08-15-enforcement-hooks-must-not-invoke-python-475/evidence/baseline/baseline-black-check.<TS>.md
    - docs/features/active/2026-08-15-enforcement-hooks-must-not-invoke-python-475/evidence/baseline/baseline-poshqc-analyze.<TS>.md
    - docs/features/active/2026-08-15-enforcement-hooks-must-not-invoke-python-475/evidence/baseline/baseline-poshqc-format.<TS>.md
    - docs/features/active/2026-08-15-enforcement-hooks-must-not-invoke-python-475/evidence/baseline/baseline-poshqc-test.<TS>.md
    - docs/features/active/2026-08-15-enforcement-hooks-must-not-invoke-python-475/evidence/baseline/baseline-pyright.<TS>.md
    - docs/features/active/2026-08-15-enforcement-hooks-must-not-invoke-python-475/evidence/baseline/baseline-pytest.<TS>.md
    - docs/features/active/2026-08-15-enforcement-hooks-must-not-invoke-python-475/evidence/baseline/baseline-ruff.<TS>.md
    - docs/features/active/2026-08-15-enforcement-hooks-must-not-invoke-python-475/evidence/other/final-constraint-sweep.<TS>.md
    - docs/features/active/2026-08-15-enforcement-hooks-must-not-invoke-python-475/evidence/other/parity-coverage.<TS>.md
    - docs/features/active/2026-08-15-enforcement-hooks-must-not-invoke-python-475/evidence/other/phase16-mirror-disposition.<TS>.md
    - docs/features/active/2026-08-15-enforcement-hooks-must-not-invoke-python-475/evidence/qa-gates/bundle-mirror-pytest.<TS>.md
    - docs/features/active/2026-08-15-enforcement-hooks-must-not-invoke-python-475/evidence/qa-gates/codex-receipts-verify.<TS>.md
    - docs/features/active/2026-08-15-enforcement-hooks-must-not-invoke-python-475/evidence/qa-gates/codex-resolvers-verify.<TS>.md
    - docs/features/active/2026-08-15-enforcement-hooks-must-not-invoke-python-475/evidence/qa-gates/completion-checks-verify.<TS>.md
    - docs/features/active/2026-08-15-enforcement-hooks-must-not-invoke-python-475/evidence/qa-gates/completion-hook-verify.<TS>.md
    - docs/features/active/2026-08-15-enforcement-hooks-must-not-invoke-python-475/evidence/qa-gates/completion-wiring-verify.<TS>.md
    - docs/features/active/2026-08-15-enforcement-hooks-must-not-invoke-python-475/evidence/qa-gates/coverage-delta.<TS>.md
    - docs/features/active/2026-08-15-enforcement-hooks-must-not-invoke-python-475/evidence/qa-gates/discovery-hook-coverage-remediation.<TS>.md
    - docs/features/active/2026-08-15-enforcement-hooks-must-not-invoke-python-475/evidence/qa-gates/discovery-hooks-verify.<TS>.md
    - docs/features/active/2026-08-15-enforcement-hooks-must-not-invoke-python-475/evidence/qa-gates/discovery-module-verify.<TS>.md
    - docs/features/active/2026-08-15-enforcement-hooks-must-not-invoke-python-475/evidence/qa-gates/final-black.<TS>.md
    - docs/features/active/2026-08-15-enforcement-hooks-must-not-invoke-python-475/evidence/qa-gates/final-poshqc-analyze.<TS>.md
    - docs/features/active/2026-08-15-enforcement-hooks-must-not-invoke-python-475/evidence/qa-gates/final-poshqc-format.<TS>.md
    - docs/features/active/2026-08-15-enforcement-hooks-must-not-invoke-python-475/evidence/qa-gates/final-poshqc-test.<TS>.md
    - docs/features/active/2026-08-15-enforcement-hooks-must-not-invoke-python-475/evidence/qa-gates/final-pyright.<TS>.md
    - docs/features/active/2026-08-15-enforcement-hooks-must-not-invoke-python-475/evidence/qa-gates/final-pytest.<TS>.md
    - docs/features/active/2026-08-15-enforcement-hooks-must-not-invoke-python-475/evidence/qa-gates/final-ruff.<TS>.md
    - docs/features/active/2026-08-15-enforcement-hooks-must-not-invoke-python-475/evidence/qa-gates/parity-receipts-verify.<TS>.md
    - docs/features/active/2026-08-15-enforcement-hooks-must-not-invoke-python-475/evidence/qa-gates/phase16-final-black.<TS>.md
    - docs/features/active/2026-08-15-enforcement-hooks-must-not-invoke-python-475/evidence/qa-gates/phase16-final-poshqc-analyze.<TS>.md
    - docs/features/active/2026-08-15-enforcement-hooks-must-not-invoke-python-475/evidence/qa-gates/phase16-final-poshqc-format.<TS>.md
    - docs/features/active/2026-08-15-enforcement-hooks-must-not-invoke-python-475/evidence/qa-gates/phase16-final-poshqc-test.<TS>.md
    - docs/features/active/2026-08-15-enforcement-hooks-must-not-invoke-python-475/evidence/qa-gates/phase16-final-pyright.<TS>.md
    - docs/features/active/2026-08-15-enforcement-hooks-must-not-invoke-python-475/evidence/qa-gates/phase16-final-pytest.<TS>.md
    - docs/features/active/2026-08-15-enforcement-hooks-must-not-invoke-python-475/evidence/qa-gates/phase16-final-ruff.<TS>.md
    - docs/features/active/2026-08-15-enforcement-hooks-must-not-invoke-python-475/evidence/qa-gates/preflight-orchestratorstate-verify.<TS>.md
    - docs/features/active/2026-08-15-enforcement-hooks-must-not-invoke-python-475/evidence/qa-gates/routing-contract-verify.<TS>.md
    - docs/features/active/2026-08-15-enforcement-hooks-must-not-invoke-python-475/evidence/qa-gates/self-gating-audit.<TS>.md
    - docs/features/active/2026-08-15-enforcement-hooks-must-not-invoke-python-475/evidence/regression-testing/guard-fixtures.<TS>.md
    - docs/features/active/2026-08-15-enforcement-hooks-must-not-invoke-python-475/evidence/regression-testing/guard-scan-fail-before.<TS>.md
    - docs/features/active/2026-08-15-enforcement-hooks-must-not-invoke-python-475/evidence/regression-testing/guard-scan-mirror-tree.<TS>.md
    - docs/features/active/2026-08-15-enforcement-hooks-must-not-invoke-python-475/evidence/regression-testing/guard-scan-zero-findings.<TS>.md
item 47  issue 479                              2026-08-16-parallel-lane-scale-and-barrier-semantics-479
    - <FEATURE>/evidence/baseline/git-baseline.<ts>.md
    - <FEATURE>/evidence/baseline/phase0-instructions-read.md
    - <FEATURE>/evidence/baseline/powershell-test-baseline.<ts>.md
    - <FEATURE>/evidence/baseline/python-format-baseline.<ts>.md
    - <FEATURE>/evidence/baseline/python-lint-baseline.<ts>.md
    - <FEATURE>/evidence/baseline/python-test-baseline.<ts>.md
    - <FEATURE>/evidence/baseline/python-typecheck-baseline.<ts>.md
    - <FEATURE>/evidence/baseline/shell-baseline.<ts>.md
    - <FEATURE>/evidence/baseline/ts-format-baseline.<ts>.md
    - <FEATURE>/evidence/baseline/ts-lint-baseline.<ts>.md
    - <FEATURE>/evidence/baseline/ts-test-baseline.<ts>.md
    - <FEATURE>/evidence/baseline/ts-typecheck-baseline.<ts>.md
    - <FEATURE>/evidence/other/ac-checkoff.<ts>.md
    - <FEATURE>/evidence/other/ac-evidence-index.<ts>.md
    - <FEATURE>/evidence/other/backward-compat-corpus.<ts>.md
    - <FEATURE>/evidence/other/cross-cutting-gates.<ts>.md
    - <FEATURE>/evidence/other/d1-anchor-verification.<ts>.md
    - <FEATURE>/evidence/other/d1-grep-gates.<ts>.md
    - <FEATURE>/evidence/other/d2-anchor-verification.<ts>.md
    - <FEATURE>/evidence/other/d3-scope-gates.<ts>.md
    - <FEATURE>/evidence/qa-gates/final-coverage-delta.<ts>.md
    - <FEATURE>/evidence/qa-gates/final-powershell-analyze.<ts>.md
    - <FEATURE>/evidence/qa-gates/final-powershell-format.<ts>.md
    - <FEATURE>/evidence/qa-gates/final-powershell-test.<ts>.md
    - <FEATURE>/evidence/qa-gates/final-python-format.<ts>.md
    - <FEATURE>/evidence/qa-gates/final-python-lint.<ts>.md
    - <FEATURE>/evidence/qa-gates/final-python-test.<ts>.md
    - <FEATURE>/evidence/qa-gates/final-python-typecheck.<ts>.md
    - <FEATURE>/evidence/qa-gates/final-shell-qc.<ts>.md
    - <FEATURE>/evidence/qa-gates/final-toolchain-summary.<ts>.md
    - <FEATURE>/evidence/qa-gates/final-ts-format.<ts>.md
    - <FEATURE>/evidence/qa-gates/final-ts-lint.<ts>.md
    - <FEATURE>/evidence/qa-gates/final-ts-test.<ts>.md
    - <FEATURE>/evidence/qa-gates/final-ts-typecheck.<ts>.md
    - <FEATURE>/evidence/qa-gates/p1-pytest.<ts>.md
    - <FEATURE>/evidence/qa-gates/p2-jest.<ts>.md
    - <FEATURE>/evidence/qa-gates/p2-pytest.<ts>.md
    - <FEATURE>/evidence/qa-gates/p3-lane-assertion-coverage.<ts>.md
    - <FEATURE>/evidence/qa-gates/p3-pytest.<ts>.md
    - <FEATURE>/evidence/qa-gates/p4-pytest.<ts>.md
    - <FEATURE>/issue.md
    - <FEATURE>/research/2026-08-16T23-00-lane-scale-and-barrier-semantics-research.md
    - <FEATURE>/spec.md
item 48  issue 476                              2026-08-16-powershell-branch-coverage-gate-unsatisfiable-476
    - docs/features/active/2026-08-16-powershell-branch-coverage-gate-unsatisfiable-476/evidence/baseline/branch-coverage-grep-baseline.<ts>.md
    - docs/features/active/2026-08-16-powershell-branch-coverage-gate-unsatisfiable-476/evidence/baseline/git-baseline.<ts>.md
    - docs/features/active/2026-08-16-powershell-branch-coverage-gate-unsatisfiable-476/evidence/baseline/jest-coverage-baseline.<ts>.md
    - docs/features/active/2026-08-16-powershell-branch-coverage-gate-unsatisfiable-476/evidence/baseline/pytest-full-baseline.<ts>.md
    - docs/features/active/2026-08-16-powershell-branch-coverage-gate-unsatisfiable-476/evidence/baseline/pytest-parity-baseline.<ts>.md
    - docs/features/active/2026-08-16-powershell-branch-coverage-gate-unsatisfiable-476/evidence/qa-gates/ac1-carveout-structure.<ts>.md
    - docs/features/active/2026-08-16-powershell-branch-coverage-gate-unsatisfiable-476/evidence/qa-gates/ac10-ac11-untouched-surfaces.<ts>.md
    - docs/features/active/2026-08-16-powershell-branch-coverage-gate-unsatisfiable-476/evidence/qa-gates/ac13-no-command-gate.<ts>.md
    - docs/features/active/2026-08-16-powershell-branch-coverage-gate-unsatisfiable-476/evidence/qa-gates/ac14-edit-surface.<ts>.md
    - docs/features/active/2026-08-16-powershell-branch-coverage-gate-unsatisfiable-476/evidence/qa-gates/ac16-inventory-sweep.<ts>.md
    - docs/features/active/2026-08-16-powershell-branch-coverage-gate-unsatisfiable-476/evidence/qa-gates/ac2-ac4-line-threshold-guard.<ts>.md
    - docs/features/active/2026-08-16-powershell-branch-coverage-gate-unsatisfiable-476/evidence/qa-gates/ac3-measurement-obligation.<ts>.md
    - docs/features/active/2026-08-16-powershell-branch-coverage-gate-unsatisfiable-476/evidence/qa-gates/ac5-branch-capable-unweakened.<ts>.md
    - docs/features/active/2026-08-16-powershell-branch-coverage-gate-unsatisfiable-476/evidence/qa-gates/ac8-byte-parity.<ts>.md
    - docs/features/active/2026-08-16-powershell-branch-coverage-gate-unsatisfiable-476/evidence/qa-gates/coverage-delta.<ts>.md
    - docs/features/active/2026-08-16-powershell-branch-coverage-gate-unsatisfiable-476/evidence/qa-gates/final-jest-coverage.<ts>.md
    - docs/features/active/2026-08-16-powershell-branch-coverage-gate-unsatisfiable-476/evidence/qa-gates/final-pytest-full.<ts>.md
    - docs/features/active/2026-08-16-powershell-branch-coverage-gate-unsatisfiable-476/evidence/qa-gates/final-pytest-parity.<ts>.md
    - docs/features/active/2026-08-16-powershell-branch-coverage-gate-unsatisfiable-476/evidence/qa-gates/final-qa-clean-pass.<ts>.md
    - docs/features/active/2026-08-16-powershell-branch-coverage-gate-unsatisfiable-476/evidence/regression-testing/fail-before-exception.<ts>.md
    - evidence/baseline/jest-coverage-baseline.<ts>.md
    - evidence/baseline/pytest-full-baseline.<ts>.md
    - evidence/qa-gates/final-jest-coverage.<ts>.md
    - evidence/qa-gates/final-pytest-full.<ts>.md
item 49  issue 489                              2026-08-17-blast-radius-false-conflict-edges-489
    - docs/features/active/2026-08-17-blast-radius-false-conflict-edges-489/evidence/other/phase0-instructions-read.<ts>.md
    - docs/features/active/2026-08-17-blast-radius-false-conflict-edges-489/evidence/regression-testing/before-state-pin.<ts>.md
    - docs/features/active/2026-08-17-blast-radius-false-conflict-edges-489/evidence/regression-testing/verification-integrity-before-after.<ts>.md
item 50  issue 485                              2026-08-17-pr-context-verification-cannot-express-expected-nonzero-exit-485
    - ${EXT}/package-lock.json
    - ${EXT}/package.json
    - ${EXT}/package.json:212
    - ${EXT}/resources/claude-customizations/.claude/skills/evidence-and-timestamp-conventions/SKILL.md
    - ${EXT}/resources/codex-and-agents-customizations/.agents/skills/evidence-and-timestamp-conventions/SKILL.md
    - ${EXT}/resources/customizations/.github/skills/evidence-and-timestamp-conventions/SKILL.md
    - ${EXT}/src/lib/pr-context/collector-output.ts
    - ${EXT}/src/lib/pr-context/verification-evidence.ts
    - ${EXT}/test/lib/pr-context/collector-output.test.ts
    - ${EXT}/test/lib/pr-context/collector-output.test.ts:268
    - ${EXT}/test/lib/pr-context/corpus-differential.tmp.test.ts
    - ${EXT}/test/lib/pr-context/tree-file-system.ts
    - ${EXT}/test/lib/pr-context/verification-evidence.test.ts
    - ${FEATURE}/evidence/baseline/ac-inventory.<TS>.md
    - ${FEATURE}/evidence/baseline/file-size-census.<TS>.md
    - ${FEATURE}/evidence/baseline/git-baseline-ref.<TS>.md
    - ${FEATURE}/evidence/baseline/namespace-clean-grep.<TS>.md
    - ${FEATURE}/evidence/baseline/phase0-instructions-read.md
    - ${FEATURE}/evidence/baseline/py-black.<TS>.md
    - ${FEATURE}/evidence/baseline/py-pyright.<TS>.md
    - ${FEATURE}/evidence/baseline/py-pytest-coverage.<TS>.md
    - ${FEATURE}/evidence/baseline/py-ruff.<TS>.md
    - ${FEATURE}/evidence/baseline/record-construction-sites.<TS>.md
    - ${FEATURE}/evidence/baseline/ts-format.<TS>.md
    - ${FEATURE}/evidence/baseline/ts-lint.<TS>.md
    - ${FEATURE}/evidence/baseline/ts-test-coverage.<TS>.md
    - ${FEATURE}/evidence/baseline/ts-test-unit.<TS>.md
    - ${FEATURE}/evidence/baseline/ts-typecheck.<TS>.md
    - ${FEATURE}/evidence/issue-updates/issue-485.<TS>.md
    - ${FEATURE}/evidence/other/ac-status-summary.<TS>.md
    - ${FEATURE}/evidence/other/additive-corpus-parity.<TS>.md
    - ${FEATURE}/evidence/other/evidence-authoring-constraint.<TS>.md
    - ${FEATURE}/evidence/qa-gates/atomic-plan-contract-untouched.<TS>.md
    - ${FEATURE}/evidence/qa-gates/coverage-config-unchanged-gate.<TS>.md
    - ${FEATURE}/evidence/qa-gates/coverage-delta.<TS>.md
    - ${FEATURE}/evidence/qa-gates/docs-six-copy-gate.<TS>.md
    - ${FEATURE}/evidence/qa-gates/evidence-key-prohibition-gate.<TS>.md
    - ${FEATURE}/evidence/qa-gates/evidence-location-gate.<TS>.md
    - ${FEATURE}/evidence/qa-gates/existing-tests-unmodified-final.<TS>.md
    - ${FEATURE}/evidence/qa-gates/file-growth-and-existing-tests-gate.<TS>.md
    - ${FEATURE}/evidence/qa-gates/file-size-census-post-change.<TS>.md
    - ${FEATURE}/evidence/qa-gates/final-py-black.<TS>.md
    - ${FEATURE}/evidence/qa-gates/final-py-pyright.<TS>.md
    - ${FEATURE}/evidence/qa-gates/final-py-pytest-coverage.<TS>.md
    - ${FEATURE}/evidence/qa-gates/final-py-ruff.<TS>.md
    - ${FEATURE}/evidence/qa-gates/final-qc-single-clean-pass.<TS>.md
    - ${FEATURE}/evidence/qa-gates/final-ts-format.<TS>.md
    - ${FEATURE}/evidence/qa-gates/final-ts-lint.<TS>.md
    - ${FEATURE}/evidence/qa-gates/final-ts-test-coverage.<TS>.md
    - ${FEATURE}/evidence/qa-gates/final-ts-test-unit.<TS>.md
    - ${FEATURE}/evidence/qa-gates/final-ts-typecheck.<TS>.md
    - ${FEATURE}/evidence/qa-gates/no-executor-import-edge-gate.<TS>.md
    - ${FEATURE}/evidence/qa-gates/push-down-contract-tests-all.<TS>.md
    - ${FEATURE}/evidence/qa-gates/push-down-contract-tests.<TS>.md
    - ${FEATURE}/evidence/qa-gates/py-no-logging-gate.<TS>.md
    - ${FEATURE}/evidence/qa-gates/py-parser-module-coverage.<TS>.md
    - ${FEATURE}/evidence/qa-gates/renderer-boundary-gate.<TS>.md
    - ${FEATURE}/evidence/qa-gates/required-fields-unchanged-gate.<TS>.md
    - ${FEATURE}/evidence/qa-gates/result-vocabulary-closed-gate.<TS>.md
    - ${FEATURE}/evidence/qa-gates/spec-shape6-correction-confinement.<TS>.md
    - ${FEATURE}/evidence/qa-gates/throwaway-script-removed.<TS>.md
    - ${FEATURE}/evidence/qa-gates/ts-parser-module-check.<TS>.md
    - ${FEATURE}/evidence/regression-testing/parser-parity-pass-after.<TS>.md
    - ${FEATURE}/evidence/regression-testing/py-parser-fail-before.<TS>.md
    - ${FEATURE}/evidence/regression-testing/py-parser-pass-after.<TS>.md
    - ${FEATURE}/evidence/regression-testing/py-renderer-fail-before.<TS>.md
    - ${FEATURE}/evidence/regression-testing/renderer-pass-after.<TS>.md
    - ${FEATURE}/evidence/regression-testing/ts-parser-fail-before.<TS>.md
    - ${FEATURE}/evidence/regression-testing/ts-renderer-fail-before.<TS>.md
    - ${FEATURE}/issue.md
    - ${FEATURE}/research/2026-08-17T16-10-expected-nonzero-exit-research.md
    - ${FEATURE}/spec.md
    - <FEATURE>/evidence/other/additive-corpus-parity.<timestamp>.md
    - <scratchpad>/corpus_differential.py
    - <scratchpad>/spec.before-p9t6.md
    - docs/features/active/<feature>/evidence/{qa-gates,regression-testing,other}/**/*.md
item 51  issue 487                              2026-08-17-promotion-lifecycle-loses-promoted-record-487
    - ${WORKSPACE}/docs/features/potential/promoted-notes-feature.md
    - <active-folder>/issue.md
    - <active>/issue.md
    - <target>/issue.md
    - <targetDir>/issue.md
    - docs/features/active/2026-08-17-promotion-lifecycle-loses-promoted-record-487/evidence/baseline/baseline-depcruise-config-absence.<ISO>.md
    - docs/features/active/2026-08-17-promotion-lifecycle-loses-promoted-record-487/evidence/baseline/baseline-flow-ts-linecount.<ISO>.md
    - docs/features/active/2026-08-17-promotion-lifecycle-loses-promoted-record-487/evidence/baseline/baseline-git-state.<ISO>.md
    - docs/features/active/2026-08-17-promotion-lifecycle-loses-promoted-record-487/evidence/baseline/baseline-py-black.<ISO>.md
    - docs/features/active/2026-08-17-promotion-lifecycle-loses-promoted-record-487/evidence/baseline/baseline-py-pyright.<ISO>.md
    - docs/features/active/2026-08-17-promotion-lifecycle-loses-promoted-record-487/evidence/baseline/baseline-py-pytest-coverage.<ISO>.md
    - docs/features/active/2026-08-17-promotion-lifecycle-loses-promoted-record-487/evidence/baseline/baseline-py-ruff.<ISO>.md
    - docs/features/active/2026-08-17-promotion-lifecycle-loses-promoted-record-487/evidence/baseline/baseline-quality-tiers-absence.<ISO>.md
    - docs/features/active/2026-08-17-promotion-lifecycle-loses-promoted-record-487/evidence/baseline/baseline-ts-eslint.<ISO>.md
    - docs/features/active/2026-08-17-promotion-lifecycle-loses-promoted-record-487/evidence/baseline/baseline-ts-jest-coverage.<ISO>.md
    - docs/features/active/2026-08-17-promotion-lifecycle-loses-promoted-record-487/evidence/baseline/baseline-ts-prettier.<ISO>.md
    - docs/features/active/2026-08-17-promotion-lifecycle-loses-promoted-record-487/evidence/baseline/baseline-ts-tsc.<ISO>.md
    - docs/features/active/2026-08-17-promotion-lifecycle-loses-promoted-record-487/evidence/other/documentation-corrections.<ISO>.md
    - docs/features/active/2026-08-17-promotion-lifecycle-loses-promoted-record-487/evidence/other/file-size-invariant.<ISO>.md
    - docs/features/active/2026-08-17-promotion-lifecycle-loses-promoted-record-487/evidence/other/flow-ts-linecount-postchange.<ISO>.md
    - docs/features/active/2026-08-17-promotion-lifecycle-loses-promoted-record-487/evidence/other/invariant-verification.<ISO>.md
    - docs/features/active/2026-08-17-promotion-lifecycle-loses-promoted-record-487/evidence/other/ts-python-parity-inspection.<ISO>.md
    - docs/features/active/2026-08-17-promotion-lifecycle-loses-promoted-record-487/evidence/other/worktree-state-report.<ISO>.md
    - docs/features/active/2026-08-17-promotion-lifecycle-loses-promoted-record-487/evidence/qa-gates/ac-traceability.<ISO>.md
    - docs/features/active/2026-08-17-promotion-lifecycle-loses-promoted-record-487/evidence/qa-gates/coverage-delta.<ISO>.md
    - docs/features/active/2026-08-17-promotion-lifecycle-loses-promoted-record-487/evidence/qa-gates/evidence-location-audit.<ISO>.md
    - docs/features/active/2026-08-17-promotion-lifecycle-loses-promoted-record-487/evidence/qa-gates/final-py-black.<ISO>.md
    - docs/features/active/2026-08-17-promotion-lifecycle-loses-promoted-record-487/evidence/qa-gates/final-py-pyright.<ISO>.md
    - docs/features/active/2026-08-17-promotion-lifecycle-loses-promoted-record-487/evidence/qa-gates/final-py-pytest-coverage.<ISO>.md
    - docs/features/active/2026-08-17-promotion-lifecycle-loses-promoted-record-487/evidence/qa-gates/final-py-ruff.<ISO>.md
    - docs/features/active/2026-08-17-promotion-lifecycle-loses-promoted-record-487/evidence/qa-gates/final-qc-loop-ledger.<ISO>.md
    - docs/features/active/2026-08-17-promotion-lifecycle-loses-promoted-record-487/evidence/qa-gates/final-ts-architecture.<ISO>.md
    - docs/features/active/2026-08-17-promotion-lifecycle-loses-promoted-record-487/evidence/qa-gates/final-ts-eslint.<ISO>.md
    - docs/features/active/2026-08-17-promotion-lifecycle-loses-promoted-record-487/evidence/qa-gates/final-ts-jest-coverage.<ISO>.md
    - docs/features/active/2026-08-17-promotion-lifecycle-loses-promoted-record-487/evidence/qa-gates/final-ts-prettier.<ISO>.md
    - docs/features/active/2026-08-17-promotion-lifecycle-loses-promoted-record-487/evidence/qa-gates/final-ts-tsc.<ISO>.md
    - docs/features/active/2026-08-17-promotion-lifecycle-loses-promoted-record-487/evidence/regression-testing/fail-before-exception.<ISO>.md
    - docs/features/active/2026-08-17-promotion-lifecycle-loses-promoted-record-487/evidence/regression-testing/fail-before-py-pytest.<ISO>.md
    - docs/features/active/2026-08-17-promotion-lifecycle-loses-promoted-record-487/evidence/regression-testing/fail-before-ts-jest.<ISO>.md
    - docs/features/active/2026-08-17-promotion-lifecycle-loses-promoted-record-487/evidence/regression-testing/post-fix-py-new-active-feature-folder.<ISO>.md
    - docs/features/active/2026-08-17-promotion-lifecycle-loses-promoted-record-487/evidence/regression-testing/post-fix-ts-flow.<ISO>.md
    - docs/features/active/2026-08-17-promotion-lifecycle-loses-promoted-record-487/evidence/regression-testing/post-fix-ts-service-calls.<ISO>.md
    - docs/features/potential/<name>.md
    - docs/features/potential/promoted/<name>.md
    - evidence/other/invariant-verification.<ISO>.md
item 52  issue 486                              2026-08-17-reject-unfalsifiable-acceptance-gates-in-atomic-plans-486
    - .../evidence/baseline/typescript-test.<ts>.md
    - .../evidence/qa-gates/typescript-test.<ts>.md
    - docs/features/active/2026-08-17-reject-unfalsifiable-acceptance-gates-in-atomic-plans-486/evidence/baseline/existing-plan-error-strings.<ts>.md
    - docs/features/active/2026-08-17-reject-unfalsifiable-acceptance-gates-in-atomic-plans-486/evidence/baseline/phase0-instructions-read.<ts>.md
    - docs/features/active/2026-08-17-reject-unfalsifiable-acceptance-gates-in-atomic-plans-486/evidence/baseline/python-format.<ts>.md
    - docs/features/active/2026-08-17-reject-unfalsifiable-acceptance-gates-in-atomic-plans-486/evidence/baseline/python-lint.<ts>.md
    - docs/features/active/2026-08-17-reject-unfalsifiable-acceptance-gates-in-atomic-plans-486/evidence/baseline/python-test.<ts>.md
    - docs/features/active/2026-08-17-reject-unfalsifiable-acceptance-gates-in-atomic-plans-486/evidence/baseline/python-typecheck.<ts>.md
    - docs/features/active/2026-08-17-reject-unfalsifiable-acceptance-gates-in-atomic-plans-486/evidence/baseline/typescript-format.<ts>.md
    - docs/features/active/2026-08-17-reject-unfalsifiable-acceptance-gates-in-atomic-plans-486/evidence/baseline/typescript-lint.<ts>.md
    - docs/features/active/2026-08-17-reject-unfalsifiable-acceptance-gates-in-atomic-plans-486/evidence/baseline/typescript-test.<ts>.md
    - docs/features/active/2026-08-17-reject-unfalsifiable-acceptance-gates-in-atomic-plans-486/evidence/baseline/typescript-typecheck.<ts>.md
    - docs/features/active/2026-08-17-reject-unfalsifiable-acceptance-gates-in-atomic-plans-486/evidence/qa-gates/branch-diff-file-list.<ts>.md
    - docs/features/active/2026-08-17-reject-unfalsifiable-acceptance-gates-in-atomic-plans-486/evidence/qa-gates/coverage-delta.<ts>.md
    - docs/features/active/2026-08-17-reject-unfalsifiable-acceptance-gates-in-atomic-plans-486/evidence/qa-gates/g5-corpus-measurement.<ts>.md
    - docs/features/active/2026-08-17-reject-unfalsifiable-acceptance-gates-in-atomic-plans-486/evidence/qa-gates/parity-fixture-run.<ts>.md
    - docs/features/active/2026-08-17-reject-unfalsifiable-acceptance-gates-in-atomic-plans-486/evidence/qa-gates/plan-self-validation.<ts>.md
    - docs/features/active/2026-08-17-reject-unfalsifiable-acceptance-gates-in-atomic-plans-486/evidence/qa-gates/python-format.<ts>.md
    - docs/features/active/2026-08-17-reject-unfalsifiable-acceptance-gates-in-atomic-plans-486/evidence/qa-gates/python-lint.<ts>.md
    - docs/features/active/2026-08-17-reject-unfalsifiable-acceptance-gates-in-atomic-plans-486/evidence/qa-gates/python-test.<ts>.md
    - docs/features/active/2026-08-17-reject-unfalsifiable-acceptance-gates-in-atomic-plans-486/evidence/qa-gates/python-typecheck.<ts>.md
    - docs/features/active/2026-08-17-reject-unfalsifiable-acceptance-gates-in-atomic-plans-486/evidence/qa-gates/self-gate-run.<ts>.md
    - docs/features/active/2026-08-17-reject-unfalsifiable-acceptance-gates-in-atomic-plans-486/evidence/qa-gates/typescript-format.<ts>.md
    - docs/features/active/2026-08-17-reject-unfalsifiable-acceptance-gates-in-atomic-plans-486/evidence/qa-gates/typescript-lint.<ts>.md
    - docs/features/active/2026-08-17-reject-unfalsifiable-acceptance-gates-in-atomic-plans-486/evidence/qa-gates/typescript-test.<ts>.md
    - docs/features/active/2026-08-17-reject-unfalsifiable-acceptance-gates-in-atomic-plans-486/evidence/qa-gates/typescript-typecheck.<ts>.md
    - docs/features/active/2026-08-17-reject-unfalsifiable-acceptance-gates-in-atomic-plans-486/evidence/regression-testing/post-change-gate-detection.<ts>.md
    - docs/features/active/2026-08-17-reject-unfalsifiable-acceptance-gates-in-atomic-plans-486/evidence/regression-testing/pre-change-no-gate-detection.<ts>.md
    - docs/features/active/2026-08-17-reject-unfalsifiable-acceptance-gates-in-atomic-plans-486/evidence/regression-testing/python-existing-plan-validator.<ts>.md
    - docs/features/active/2026-08-17-reject-unfalsifiable-acceptance-gates-in-atomic-plans-486/evidence/regression-testing/typescript-existing-validator.<ts>.md
item 53  issue 491                              2026-08-19-mermaid-diagram-claude-runtime-491
    - .claude/state/powershell-batch-budget.<session_id>.json
    - <FEATURE>/evidence/baseline/jest-manifest-completeness.<TS>.md
    - <FEATURE>/evidence/baseline/no-python-invocation.<TS>.md
    - <FEATURE>/evidence/baseline/poshqc-analyze.<TS>.md
    - <FEATURE>/evidence/baseline/poshqc-test.<TS>.md
    - <FEATURE>/evidence/baseline/powershell-coverage.baseline.<TS>.xml
    - <FEATURE>/evidence/baseline/pytest-manifest-completeness.<TS>.md
    - <FEATURE>/evidence/baseline/pytest-poshqc-bundled-parity.<TS>.md
    - <FEATURE>/evidence/baseline/pytest-resource-contracts.<TS>.md
    - <FEATURE>/evidence/other/ac-summary.<TS>.md
    - <FEATURE>/evidence/other/accept-matrix-crosscheck.<TS>.md
    - <FEATURE>/evidence/other/capability-completeness.<TS>.md
    - <FEATURE>/evidence/other/core-json-references-verification.<TS>.md
    - <FEATURE>/evidence/other/phase0-instructions-read.md
    - <FEATURE>/evidence/other/potential-entries.md
    - <FEATURE>/evidence/qa-gates/coverage-delta.<TS>.md
    - <FEATURE>/evidence/qa-gates/dependency-manifest-check.<TS>.md
    - <FEATURE>/evidence/qa-gates/file-size-check.<TS>.md
    - <FEATURE>/evidence/qa-gates/final-jest-manifest-completeness.<TS>.md
    - <FEATURE>/evidence/qa-gates/final-no-python-invocation.<TS>.md
    - <FEATURE>/evidence/qa-gates/final-poshqc-analyze.<TS>.md
    - <FEATURE>/evidence/qa-gates/final-poshqc-format.<TS>.md
    - <FEATURE>/evidence/qa-gates/final-poshqc-test.<TS>.md
    - <FEATURE>/evidence/qa-gates/final-pytest-manifest-completeness.<TS>.md
    - <FEATURE>/evidence/qa-gates/final-pytest-poshqc-bundled-parity.<TS>.md
    - <FEATURE>/evidence/qa-gates/final-pytest-resource-contracts.<TS>.md
    - <FEATURE>/evidence/qa-gates/phase1-toolchain-pass.<TS>.md
    - <FEATURE>/evidence/qa-gates/phase2-toolchain-pass.<TS>.md
    - <FEATURE>/evidence/qa-gates/test-purity-check.<TS>.md
    - <FEATURE>/evidence/regression-testing/distribution-after.<TS>.md
    - <FEATURE>/evidence/regression-testing/distribution-negative-control-manifest.<TS>.md
    - <FEATURE>/evidence/regression-testing/distribution-negative-control-parity.<TS>.md
    - <FEATURE>/evidence/regression-testing/hook-negative-control.<TS>.md
    - <FEATURE>/evidence/regression-testing/hook-positive-control.<TS>.md
    - <FEATURE>/issue.md
    - <FEATURE>/research/claude-runtime-integration-mechanics.2026-08-19T08-39.md
    - <FEATURE>/research/mermaid-validation-technology.2026-08-19T08-39.md
    - <FEATURE>/spec.md
    - <FEATURE>/user-story.md
    - skills/<name>/SKILL.md
item 56  issue 501                              2026-08-21-pretooluse-hooks-parse-flat-payload-and-always-allow-501
    - .claude/state/powershell-batch-budget.<session_id>.json
    - FEATURE/evidence/baseline/<ISO-8601>-merge-gate-differential-prefix.md
    - FEATURE/evidence/baseline/<ISO-8601>-mirror-parity-baseline.md
    - FEATURE/evidence/baseline/<ISO-8601>-poshqc-analyze-baseline.md
    - FEATURE/evidence/baseline/<ISO-8601>-poshqc-format-baseline.md
    - FEATURE/evidence/baseline/<ISO-8601>-poshqc-test-baseline.md
    - FEATURE/evidence/baseline/<ISO-8601>-preimplementation-gate-readiness.md
    - FEATURE/evidence/qa-gates/<ISO-8601>-coverage-comparison.md
    - FEATURE/evidence/qa-gates/<ISO-8601>-file-size-ceiling.md
    - FEATURE/evidence/qa-gates/<ISO-8601>-merge-gate-live-probe-postfix.md
    - FEATURE/evidence/qa-gates/<ISO-8601>-mirror-parity-final.md
    - FEATURE/evidence/qa-gates/<ISO-8601>-poshqc-analyze-final.md
    - FEATURE/evidence/qa-gates/<ISO-8601>-poshqc-format-final.md
    - FEATURE/evidence/qa-gates/<ISO-8601>-poshqc-test-final.md
    - FEATURE/evidence/qa-gates/<ISO-8601>-runsettings-bundled-parity.md
    - FEATURE/evidence/qa-gates/<ISO-8601>-scope-boundary-diff.md
    - FEATURE/evidence/regression-testing/<ISO-8601>-merge-gate-differential-postfix.md
    - FEATURE/evidence/regression-testing/<ISO-8601>-payload-contract-falsifiability.md
item 58  issue repo-housekeeping-audit          repo-housekeeping-audit
    - .claude/agents/<name>.md
    - .claude/skills/<name>/SKILL.md
    - docs/features/active/repo-housekeeping-audit/evidence/baseline/p3-t1.git-state.<timestamp>.md
    - docs/features/active/repo-housekeeping-audit/evidence/other/p3-t2.active-folder-listing.<timestamp>.md
    - docs/features/active/repo-housekeeping-audit/evidence/other/p3-t3.relocation-confirmation.<timestamp>.md
    - docs/features/active/repo-housekeeping-audit/evidence/other/p3-t4.claude-md-path-resolution.<timestamp>.md
    - docs/features/active/repo-housekeeping-audit/evidence/other/p3-t5.readme-inventory-verification.<timestamp>.md
    - docs/features/active/repo-housekeeping-audit/evidence/other/p3-t6.issue-state-verification.<timestamp>.md
    - docs/features/active/repo-housekeeping-audit/evidence/other/p3-verification-summary.<timestamp>.md
```

## [P7-T3] Named-survivor assertion, five probes fixed before execution

The probe list was fixed in the plan of record rather than chosen at execution time, because a survivor list the executor selects can be selected to pass. Each probe exercises one acceptance rule of the classifier and each carries a pre-registered carrier count measured over the 58 derived radii.

| Acceptance rule | Probe | Pre-registered carriers | Observed carriers | Present |
| --- | --- | --- | --- | --- |
| recognized-extension | scripts/dev_tools/compute_blast_radius.py | 8 | **8** | **yes** |
| known-segment-subtree-glob | .claude/** | 16 | **16** | **yes** |
| configured-root-surface | package-lock.json | 7 | **7** | **yes** |
| own-folder-doc-glob | docs/features/active/2026-08-21-get-plan-paths-extracts-angle-bracket-placeholders-as-paths-502/** | existence claim | **1** | **yes** |
| line-suffixed-citation | (existence claim) | existence claim | **67** | **yes** |

**All five probes resolve as stated.** The three probes carrying a pre-registered numeric count match it exactly: the recognized-extension rule at 8 carriers, the known-segment subtree-glob rule at 16, and the configured-root-surface rule at 7. The own-folder documentation-glob probe is present, as it must be for every item since derivation adds it automatically. The line-suffixed-citation probe is an existence claim and is satisfied with 67 distinct line-suffixed tokens surviving; its expected instance is present, recorded as `True`.

An absence in any probe would be a Blocking defect that halts the phase. None is absent. Taken together the five probes show the guard removed marker-bearing tokens without disturbing any of the five paths by which a real citation is accepted.

The two probes the plan rejected on measurement were not reinstated: a tests-subtree glob has zero carriers because no plan in the corpus cites it, and the tier map is structurally unreachable because it appears in both the shared-surface list and the mandate-read list, so mandate-read exclusion strips it from every harvest.

### Carrier detail for the three counted probes

- **recognized-extension** — carriers by issue: 452, 447, 446, 442, 443, 472, 489, 502
- **known-segment-subtree-glob** — carriers by issue: 372, 367, 422, 412, 452, 447, 441, 443, 462, 472, 475, 476, 489, 491, 492, 501
- **configured-root-surface** — carriers by issue: 397, 414, 421, 452, 462, 472, 491
- **own-folder-doc-glob** — carriers by issue: 502

## [P7-T4] Surviving-edge identity on the pre-fixed pair

The pair was fixed in the plan rather than selected at execution time: the items for issues 486 and 487 must still conflict after the fix, with reason kind `path_overlap` and a detail naming the shared MCP tools source file. That is the known-genuine edge captured by the earlier false-conflict-edge work, so its survival is the edge-level positive control.

Pair: issue 487 (key 51) and issue 486 (key 52).

Before state, recorded verbatim from the [P0-T14] edge set:

```text
path_overlap = extensions/drm-copilot/src/mcp-tools.ts ~ extensions/drm-copilot/src/mcp-tools.ts
```

After state, recorded verbatim:

```text
path_overlap = extensions/drm-copilot/src/mcp-tools.ts ~ extensions/drm-copilot/src/mcp-tools.ts
```

**The edge is present in the after-state edge set.** Its reason kind and detail match the before-state recording exactly: the two reason lists compare equal (True).

The detail names a genuine shared source file that both items write, so this edge is a true contention signal and must survive. Its absence would be a Blocking defect that halts the phase.

## [P7-T5] Prediction against actual, and the conservation identity

### The three quantities

| Quantity | Value |
| --- | --- |
| pre-registered pair count, fixed at [P0-T15] before implementation | **53** |
| measured pair count, |P| | **63** |
| actual edge-count delta | **15** |
| pairs of P that still conflict, |S| | **50** |
| edges removed in total | **15** |
| edges added | **0** |

### The one-sided upper bound holds

The actual delta is **15**, which is at or below the pre-registered upper bound of 53. A delta above 53 would mean the fix removed an edge that no shared placeholder token accounts for, that is, that a real path was dropped. The bound is satisfied with a margin of 38.

The margin is not absorbed as success. Every unit of shortfall below 53 is attributed below, and the attribution is exact rather than approximate.

### The conservation identity as stated does not balance, and here is why

The identity the plan fixed is `delta_actual + |S| = |P_measured|`. Substituting the measured values gives `15 + 50 = 65` against `|P| = 63`. It is off by 2.

The identity presumes that **every** removed edge is a member of the pair set, and the pair set is defined as pairs sharing an *identical* placeholder path token. The measurement shows that 2 of the 15 removed edges are placeholder-induced by a mechanism the pair set's definition does not capture. Both are itemized in full below, and once they are separated out, both halves of the accounting balance **exactly**:

```text
|P|   = 63
      = 13 (members of P whose edge was removed)
      + 50 (members of P whose edge survived)   <- exact

delta = 15
      = 13 (removed edges that are members of P)
      + 2 (removed edges placeholder-induced but outside P)          <- exact

edges added = 0, so no removal is masked by an addition.
```

The corrected identity is therefore `delta_actual = |P_removed| + |R_outside|` together with `|P| = |P_removed| + |S|`. Both hold with no residual. The plan's single-equation form was written on the assumption that a placeholder-induced edge can only arise from two items citing the identical token; that assumption is what the measurement corrects, and the correction is recorded here rather than reconciled away.

### The two removed edges outside the pair set, itemized

**Pair 364 and 372** (keys 4 and 13). Before-state reason: `module_overlap = schemas`.

**Pair 365 and repo-housekeeping-audit** (keys 5 and 58). Before-state reason: `path_overlap = .claude/agents/*.md ~ .claude/agents/<name>.md`.

1. **The module-level mechanism.** The edge between the items for issues 364 and 372 rested on `module_overlap = schemas`, not on a path overlap. Item 364's only contributor to the `schemas` module was the marker-bearing token `schemas/vN/<schema_name>.schema.json`; the after-state radius for that item contains no path with `schema` in it at all, so the module resolved empty and the overlap disappeared. Item 372 retains eight real schema paths. The edge is therefore placeholder-induced, but at the module level rather than the path level, so the pair never entered a pair set defined on shared path tokens.

2. **The glob-versus-placeholder mechanism.** The edge between the item for issue 365 and the repository-housekeeping-audit item rested on `path_overlap = .claude/agents/*.md ~ .claude/agents/<name>.md`. The two entries are **different strings**: one item cited a real glob and the other cited a marker-bearing token, and the glob matched the placeholder. Because the pair set requires an identical shared token, this pair is not a member, yet dropping the placeholder is exactly what removed the edge. This is the residual class the plan's own enumeration method flagged as not exhaustively enumerated.

Neither mechanism is a real-path drop. In both cases the entry that disappeared was marker-bearing, which the [P7-T2] accounting independently confirms for the whole corpus: zero marker-free entries were dropped.

### The measured pair set exceeds 53, and the excess is itemized

`|P_measured|` is 63, which exceeds the pre-registered 53 by 10. The plan requires each additional pair to be itemized and shown to be induced by a shared placeholder token.

Every member of the measured pair set is induced by a shared placeholder token **by construction**: the set was computed as the pairs whose before-state radii share at least one path entry for which the shipped marker predicate returns true. The grouping below lists each distinct shared-token signature with the number of pairs it accounts for, which localizes the excess to the token families the plan's hand enumeration did not reach — chiefly per-feature timestamped evidence-artifact shapes, which the plan explicitly identified as its one un-enumerated residual class.

| Pairs | Shared placeholder token signature |
| --- | --- |
| 14 | <FEATURE>/evidence/baseline/phase0-instructions-read.md |
| 13 | <FEATURE>/evidence/baseline/phase0-instructions-read.md + <FEATURE>/spec.md |
| 6 | <FEATURE>/evidence/baseline/phase0-instructions-read.md + <FEATURE>/evidence/qa-gates/coverage-delta.<ts>.md + <FEATURE>/spec.md |
| 6 | .claude/state/powershell-batch-budget.<session_id>.json |
| 3 | <FEATURE>/evidence/qa-gates/coverage-delta.<ts>.md |
| 3 | <FEATURE>/spec.md |
| 2 | .claude/skills/<name>/SKILL.md |
| 2 | evidence/qa-gates/coverage-delta.<ts>.md |
| 2 | <FEATURE>/spec.md + <FEATURE>/user-story.md |
| 1 | <FEATURE>/evidence/qa-gates/coverage-delta.<TS>.md + <FEATURE>/evidence/qa-gates/file-size-check.<TS>.md + <FEATURE>/spec.md |
| 1 | <FEATURE>/evidence/baseline/baseline-ps-analyze.md + <FEATURE>/evidence/baseline/baseline-ps-test-coverage.md + <FEATURE>/evidence/baseline/phase0-instructions-read.md + <FEATURE>/evidence/qa-gates/final-ps-analyze.md + <FEATURE>/evidence/qa-gates/final-ps-format.md + <FEATURE>/evidence/qa-gates/final-ps-test-coverage.md + <FEATURE>/evidence/qa-gates/final-py-format.md + <FEATURE>/evidence/qa-gates/final-py-lint.md + <FEATURE>/evidence/qa-gates/final-py-typecheck.md |
| 1 | .claude/agents/<name>.md + .claude/skills/<name>/SKILL.md |
| 1 | <FEATURE>/evidence/qa-gates/coverage-delta.<ts>.md + <FEATURE>/evidence/qa-gates/final-python-format.<ts>.md + <FEATURE>/evidence/qa-gates/final-python-lint.<ts>.md + <FEATURE>/evidence/qa-gates/final-python-test.<ts>.md + <FEATURE>/evidence/qa-gates/final-python-typecheck.<ts>.md |
| 1 | <FEATURE>/evidence/qa-gates/final-python-format.<ts>.md + <FEATURE>/evidence/qa-gates/final-python-lint.<ts>.md + <FEATURE>/evidence/qa-gates/final-python-test.<ts>.md + <FEATURE>/evidence/qa-gates/final-python-typecheck.<ts>.md |
| 1 | evidence/baseline/python-tests-coverage.<timestamp>.md + evidence/qa-gates/python-tests-coverage.<timestamp>.md |
| 1 | <FEATURE>/evidence/baseline/phase0-instructions-read.md + <FEATURE>/spec.md + <FEATURE>/user-story.md |
| 1 | docs/features/parallel/<slug>/parallel-kickoff.md + docs/features/parallel/<slug>/parallel.md |
| 1 | docs/features/parallel/<slug>/parallel-status.md + docs/features/parallel/<slug>/parallel.md + evidence/qa-gates/coverage-delta.<ts>.md |
| 1 | docs/features/parallel/<slug>/parallel.md |
| 1 | <FEATURE>/evidence/baseline/phase0-instructions-read.md + <FEATURE>/evidence/baseline/shell-baseline.<ts>.md + <FEATURE>/evidence/qa-gates/final-python-format.<ts>.md + <FEATURE>/evidence/qa-gates/final-python-lint.<ts>.md + <FEATURE>/evidence/qa-gates/final-python-test.<ts>.md + <FEATURE>/evidence/qa-gates/final-python-typecheck.<ts>.md + <FEATURE>/evidence/qa-gates/final-ts-format.<ts>.md + <FEATURE>/evidence/qa-gates/final-ts-lint.<ts>.md + <FEATURE>/evidence/qa-gates/final-ts-test.<ts>.md + <FEATURE>/evidence/qa-gates/final-ts-typecheck.<ts>.md + <FEATURE>/spec.md |
| 1 | <FEATURE>/issue.md + <FEATURE>/spec.md |

The three families the plan enumerated by hand — the phase0 evidence artifact, the feature spec document, and the PowerShell batch-budget state file — remain the largest contributors. The 10 additional pairs come from timestamped per-feature evidence shapes and from parallel-surface document shapes that two plans happen to quote identically. Each is a shared marker-bearing token, so the deviation is localized to the enumeration's coverage and not to the fix.

### The 50 pairs of P that still conflict, with their surviving reasons

Every unit of shortfall below the pre-registered 53 is attributed to a named surviving pair. None is absorbed as success.

```text
                         334 - 344                           path_overlap=extensions/drm-copilot/package.json ~ extensions/drm-copilot/package.json
                         334 - 423                           path_overlap=extensions/drm-copilot/test/** ~ extensions/drm-copilot/test/**
                         334 - 442                           path_overlap=.claude/settings.json ~ .claude/settings.json; shared_surface_overlap=.claude/settings.json
                         334 - 462                           path_overlap=**/*.sh ~ .claude/hooks/persist-session-id.ps1; shared_surface_overlap=.claude/settings.json
                         334 - 479                           path_overlap=extensions/drm-copilot/src/lib/** ~ extensions/drm-copilot/src/lib/validate/parallel-orchestrator-state-core.ts
                         334 - 491                           path_overlap=**/*.md ~ .claude/hooks/persist-session-id.ps1; shared_surface_overlap=.claude/settings.json
                         344 - 423                           path_overlap=extensions/drm-copilot/test/** ~ extensions/drm-copilot/test/*.test.ts
                         344 - 413                           path_overlap=scripts/powershell/PoshQC/settings/pester.runsettings.psd1 ~ scripts/powershell/PoshQC/settings/pester.runsettings.psd1; module_overlap=poshqc; shared_surface_overlap=scripts/powershell/PoshQC/settings/pester.runsettings.psd1
                         344 - 442                           module_overlap=config
                         344 - 462                           path_overlap=**/*.sh ~ config/poshqc-scan.json; module_overlap=config
                         344 - 479                           path_overlap=extensions/drm-copilot/test/*.test.ts ~ extensions/drm-copilot/test/lib/validate/parallel-orchestrator-state-core.test.ts
                         369 - 393                           path_overlap=**/*.sh ~ .github/copilot-instructions.md
                         369 - 396                           path_overlap=.github/copilot-instructions.md ~ .github/copilot-instructions.md
                         369 - 462                           path_overlap=**/*.sh ~ .github/copilot-instructions.md
                         369 - 479                           path_overlap=.github/copilot-instructions.md ~ .github/copilot-instructions.md
                         369 - 491                           path_overlap=**/*.md ~ .github/copilot-instructions.md; contract_dependency=description
                         372 - 367                           path_overlap=.claude/** ~ .claude/**
                         372 - repo-housekeeping-audit       path_overlap=.claude/** ~ .claude/rules/*.md
                         368 - 444                           path_overlap=scripts/dev_tools/*parallel* ~ scripts/dev_tools/discovery/**; contract_dependency=int
                         367 - repo-housekeeping-audit       path_overlap=.claude/** ~ .claude/rules/*.md
                         393 - 423                           path_overlap=**/*.sh ~ .agents/skills/**
                         393 - 413                           path_overlap=**/*.sh ~ .claude/hooks/validate-orchestrator-output.ps1
                         393 - 462                           path_overlap=**/*.sh ~ **/*.sh; shared_surface_overlap=poetry.lock; contract_dependency=bash
                         393 - 479                           path_overlap=**/*.sh ~ .claude/agents/parallel-orchestrator.md
                         396 - 462                           path_overlap=**/*.sh ~ .claude/skills/cleanup-merged-worktrees/SKILL.md; contract_dependency=bash
                         396 - 479                           path_overlap=.github/copilot-instructions.md ~ .github/copilot-instructions.md
                         423 - 413                           path_overlap=extensions/drm-copilot/resources/claude-customizations/** ~ extensions/drm-copilot/resources/claude-customizations/.claude/hooks/validate-orchestrator-output.ps1
                         423 - 462                           path_overlap=**/*.sh ~ .agents/skills/**
                         423 - 479                           path_overlap=extensions/drm-copilot/resources/claude-customizations/** ~ extensions/drm-copilot/resources/claude-customizations/pack-manifests/core.json
                         423 - 491                           path_overlap=**/*.md ~ .agents/skills/**
                         413 - 442                           path_overlap=.claude/skills/acceptance-criteria-tracking/SKILL.md ~ .claude/skills/acceptance-criteria-tracking/SKILL.md
                         413 - 462                           path_overlap=**/*.sh ~ .claude/hooks/validate-orchestrator-output.ps1; shared_surface_overlap=scripts/dev_tools/validate_orchestrator_state.py
                         413 - 479                           path_overlap=tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py ~ tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py
                         413 - 491                           path_overlap=**/*.md ~ .claude/hooks/validate-orchestrator-output.ps1; module_overlap=poshqc; shared_surface_overlap=scripts/powershell/PoshQC/settings/pester.runsettings.psd1
                         435 - 440                           path_overlap=tests/scripts/dev_tools/test_*.py ~ tests/scripts/dev_tools/test_validate_orchestration_artifacts_state_shape.py; contract_dependency=validate_orchestration_artifacts
                         440 - 475                           path_overlap=.claude/** ~ .claude/agents/parallel-orchestrator.md; module_overlap=poshqc; shared_surface_overlap=.claude/settings.json; contract_dependency=parallel-orchestrator-state
                         440 - 491                           path_overlap=**/*.md ~ .claude/agents/parallel-orchestrator.md; module_overlap=poshqc; shared_surface_overlap=.claude/settings.json; contract_dependency=-ToolInputRaw
                         440 - 501                           path_overlap=.claude/** ~ .claude/agents/parallel-orchestrator.md; module_overlap=poshqc; shared_surface_overlap=.claude/settings.json
                         442 - 462                           path_overlap=**/*.sh ~ .claude/agents/parallel-orchestrator.md; module_overlap=config; shared_surface_overlap=.claude/settings.json
                         442 - 479                           path_overlap=.claude/agents/parallel-orchestrator.md ~ .claude/agents/parallel-orchestrator.md; shared_surface_overlap=scripts/dev_tools/validate_parallel_orchestrator_state.py; contract_dependency=max_concurrency
                         442 - 491                           path_overlap=**/*.md ~ .claude/agents/parallel-orchestrator.md; shared_surface_overlap=.claude/settings.json
                         441 - 443                           path_overlap=**/extensions/drm-copilot/test/**/*.test.ts ~ .../.claude/skills/parallel-orchestrate/SKILL.md; module_overlap=config; shared_surface_overlap=config/orchestration-routing.json
                         441 - 444                           path_overlap=.claude/** ~ .claude/skills/acceptance-criteria-tracking/SKILL.md; module_overlap=config; shared_surface_overlap=config/orchestration-routing.json
                         443 - 444                           path_overlap=**/extensions/drm-copilot/test/**/*.test.ts ~ ./src/lib/validate/parallel-orchestrator-state-core.ts; module_overlap=config; shared_surface_overlap=config/orchestration-routing.json
                         462 - 479                           path_overlap=**/*.sh ~ .claude/agents/parallel-orchestrator.md
                         462 - 491                           path_overlap=**/*.md ~ **/*.sh; shared_surface_overlap=.claude/settings.json
                         475 - 491                           path_overlap=**/*.md ~ .claude/**; module_overlap=poshqc; shared_surface_overlap=.claude/settings.json
                         475 - 501                           path_overlap=.claude/** ~ .claude/**; module_overlap=poshqc; shared_surface_overlap=.claude/settings.json
                         479 - 491                           path_overlap=**/*.md ~ .claude/agents/parallel-orchestrator.md
                         491 - 501                           path_overlap=**/*.md ~ .claude/**; module_overlap=poshqc; shared_surface_overlap=.claude/settings.json
```

Each surviving pair lost its placeholder-derived reason and remained in the edge set on a different, non-placeholder reason. That is the expected outcome: the guard removes a false reason, it does not remove a pair that also contends for a real cause.

## [P7-T6] The nine-item clique induced by the mandated evidence-path token

The clique is the set of items whose before-state radius carried the mandated phase0 evidence-artifact shape. It was identified by membership rather than by reading the plan's table, so the measurement is independent of the pre-registration.

**Members: 9 items** — issues 334, 344, 369, 396, 423, 413, 442, 462, 479.

This matches the pre-registered nine-item set exactly (334, 344, 369, 396, 413, 423, 442, 462, 479), so the component the plan predicted is the component that was measured.

| Quantity | Value |
| --- | --- |
| pairs in the clique, C(9,2) | **36** |
| pairs whose edge was removed | **12** |
| pairs whose edge survived on another reason | **24** |
| surviving pairs retaining a marker-bearing reason | **0** |

### Disposition of the component

**The clique as a clique is gone.** Every one of the 36 pairs lost the placeholder-derived `path_overlap` reason that the mandated evidence-path shape supplied, which is the plan's sub-prediction, and it holds without exception: **zero** surviving pairs retain a marker-bearing reason detail. The nine items no longer form a complete graph *on that token*.

Of the 36 pairs, 12 had no other reason and left the edge set entirely. The remaining 24 still contend, each on a reason that has nothing to do with the placeholder — a genuinely shared file, a shared module, a shared surface, or a shared contract. Those pairs were always genuine contenders; the placeholder was simply an additional, false reason layered on top.

### All 36 pairs, accounted for individually

```text
 334 - 344                          SURVIVES  path_overlap=extensions/drm-copilot/package.json ~ extensions/drm-copilot/package.json
 334 - 369                          REMOVED   no reason remains
 334 - 396                          REMOVED   no reason remains
 334 - 423                          SURVIVES  path_overlap=extensions/drm-copilot/test/** ~ extensions/drm-copilot/test/**
 334 - 413                          REMOVED   no reason remains
 334 - 442                          SURVIVES  path_overlap=.claude/settings.json ~ .claude/settings.json; shared_surface_overlap=.claude/settings.json
 334 - 462                          SURVIVES  path_overlap=**/*.sh ~ .claude/hooks/persist-session-id.ps1; shared_surface_overlap=.claude/settings.json
 334 - 479                          SURVIVES  path_overlap=extensions/drm-copilot/src/lib/** ~ extensions/drm-copilot/src/lib/validate/parallel-orchestrator-state-core.ts
 344 - 369                          REMOVED   no reason remains
 344 - 396                          REMOVED   no reason remains
 344 - 423                          SURVIVES  path_overlap=extensions/drm-copilot/test/** ~ extensions/drm-copilot/test/*.test.ts
 344 - 413                          SURVIVES  path_overlap=scripts/powershell/PoshQC/settings/pester.runsettings.psd1 ~ scripts/powershell/PoshQC/settings/pester.runsettings.psd1; module_overlap=poshqc; shared_surface_overlap=scripts/powershell/PoshQC/settings/pester.runsettings.psd1
 344 - 442                          SURVIVES  module_overlap=config
 344 - 462                          SURVIVES  path_overlap=**/*.sh ~ config/poshqc-scan.json; module_overlap=config
 344 - 479                          SURVIVES  path_overlap=extensions/drm-copilot/test/*.test.ts ~ extensions/drm-copilot/test/lib/validate/parallel-orchestrator-state-core.test.ts
 369 - 396                          SURVIVES  path_overlap=.github/copilot-instructions.md ~ .github/copilot-instructions.md
 369 - 423                          REMOVED   no reason remains
 369 - 413                          REMOVED   no reason remains
 369 - 442                          REMOVED   no reason remains
 369 - 462                          SURVIVES  path_overlap=**/*.sh ~ .github/copilot-instructions.md
 369 - 479                          SURVIVES  path_overlap=.github/copilot-instructions.md ~ .github/copilot-instructions.md
 396 - 423                          REMOVED   no reason remains
 396 - 413                          REMOVED   no reason remains
 396 - 442                          REMOVED   no reason remains
 396 - 462                          SURVIVES  path_overlap=**/*.sh ~ .claude/skills/cleanup-merged-worktrees/SKILL.md; contract_dependency=bash
 396 - 479                          SURVIVES  path_overlap=.github/copilot-instructions.md ~ .github/copilot-instructions.md
 423 - 413                          SURVIVES  path_overlap=extensions/drm-copilot/resources/claude-customizations/** ~ extensions/drm-copilot/resources/claude-customizations/.claude/hooks/validate-orchestrator-output.ps1
 423 - 442                          REMOVED   no reason remains
 423 - 462                          SURVIVES  path_overlap=**/*.sh ~ .agents/skills/**
 423 - 479                          SURVIVES  path_overlap=extensions/drm-copilot/resources/claude-customizations/** ~ extensions/drm-copilot/resources/claude-customizations/pack-manifests/core.json
 413 - 442                          SURVIVES  path_overlap=.claude/skills/acceptance-criteria-tracking/SKILL.md ~ .claude/skills/acceptance-criteria-tracking/SKILL.md
 413 - 462                          SURVIVES  path_overlap=**/*.sh ~ .claude/hooks/validate-orchestrator-output.ps1; shared_surface_overlap=scripts/dev_tools/validate_orchestrator_state.py
 413 - 479                          SURVIVES  path_overlap=tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py ~ tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py
 442 - 462                          SURVIVES  path_overlap=**/*.sh ~ .claude/agents/parallel-orchestrator.md; module_overlap=config; shared_surface_overlap=.claude/settings.json
 442 - 479                          SURVIVES  path_overlap=.claude/agents/parallel-orchestrator.md ~ .claude/agents/parallel-orchestrator.md; shared_surface_overlap=scripts/dev_tools/validate_parallel_orchestrator_state.py; contract_dependency=max_concurrency
 462 - 479                          SURVIVES  path_overlap=**/*.sh ~ .claude/agents/parallel-orchestrator.md
```

## [P7-T7] Post-fix reproduction in both runtimes

The [P0-T16] construction was re-run unchanged: two plans whose only shared inline-code token is a placeholder feature-document shape, with disjoint real files and disjoint feature folders, plus the negative control with the placeholder citation removed.

### Python runtime

```text
placeholder token under test: <FEATURE>/spec.md
--- PLACEHOLDER-ONLY OVERLAP ---
  a.paths: ['docs/features/active/2026-08-23-alpha-item-9001/**', 'scripts/dev_tools/alpha_only_module.py']
  b.paths: ['docs/features/active/2026-08-23-beta-item-9002/**', 'scripts/dev_tools/beta_only_module.py']
  conflict: False
--- NEGATIVE CONTROL (placeholder removed) ---
  a.paths: ['docs/features/active/2026-08-23-alpha-item-9001/**', 'scripts/dev_tools/alpha_only_module.py']
  b.paths: ['docs/features/active/2026-08-23-beta-item-9002/**', 'scripts/dev_tools/beta_only_module.py']
  conflict: False
```

### PowerShell runtime

```text
placeholder token under test: <FEATURE>/spec.md
--- PLACEHOLDER-ONLY OVERLAP ---
  a.paths: docs/features/active/2026-08-23-alpha-item-9001/** | scripts/dev_tools/alpha_only_module.py
  b.paths: docs/features/active/2026-08-23-beta-item-9002/** | scripts/dev_tools/beta_only_module.py
  conflict: False
--- NEGATIVE CONTROL (placeholder removed) ---
  a.paths: docs/features/active/2026-08-23-alpha-item-9001/** | scripts/dev_tools/alpha_only_module.py
  b.paths: docs/features/active/2026-08-23-beta-item-9002/** | scripts/dev_tools/beta_only_module.py
  conflict: False
```

| Case | Before ([P0-T16]) | After ([P7-T7]) |
| --- | --- | --- |
| placeholder-only overlap, Python | conflict **true** | conflict **false** |
| placeholder-only overlap, PowerShell | conflict **true** | conflict **false** |
| negative control, Python | conflict false | conflict false |
| negative control, PowerShell | conflict false | conflict false |

The placeholder-only overlap now reports conflict false in both runtimes and the negative control still reports conflict false in both. The two runtimes' path lists are now identical to each other and identical to the control's, which is the direct statement of the fix: the placeholder citation no longer contributes a radius entry, so a plan that cites it is indistinguishable from one that does not.

This pair of measurements is also the discriminating pair-level observation that [P5-T3] was reaching for, taken through the derivation seam the guard actually governs. See `evidence/other/p5-t3-blocker-conflict-fixture-seam.md`.

## Output Summary

Item set identical to the before-measurement across all 58 items. Edge count fell from 1282 to 1267, a delta of 15, comfortably at or below the pre-registered upper bound of 53. Density fell from 77.6% to 76.6%; cohort count and maximum cohort width are unchanged at 32 and 4. Total radius path entries fell from 3729 to 2472, and **every one of the 1198 distinct dropped entries carries a marker character** with zero marker-free drops and zero entries added. All five named survivor probes resolve, three of them matching their pre-registered carrier counts exactly at 8, 16, and 7. The pre-fixed 486-487 edge survives with its reason kind and detail byte-identical to the before state. The measured pair set is 63, of which 50 pairs still conflict on non-placeholder reasons and 13 were removed; the two remaining removed edges are placeholder-induced through the module level and through a glob-versus-placeholder match, and both halves of the corrected accounting balance exactly. The nine-item mandated evidence-path clique is gone as a clique: all 36 pairs lost the placeholder reason, 12 edges were removed outright, 24 survive on unrelated reasons, and none retains a marker-bearing reason. The post-fix reproduction reports conflict false in both runtimes for the placeholder-only overlap and for the control.
