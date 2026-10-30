# Preflight Fixes - Issue 1024

Timestamp: 2026-10-30T23-39
Plan: docs/features/active/2026-10-30-docs-reference-generator-1024/plan.2026-10-30T16-54.md
Directive: PREFLIGHT VALIDATION ONLY (single pass; task text and preamble only; no task added, removed or reordered)

## Fix 1

- Location: `## Existing Tests Asserting Changed Behavior (dispositions)`
- Defect class: validator-blind changed-existing-behavior search (execution-environment `## Preflight Defect Classes the Validator Cannot See`); the meaning of the plan's assertions is unchanged.
- Finding: a search of `tests/` for `core.json` on this branch returned test files that the dispositions section did not name: the Codex-manifest readers `test_push_down_codex_and_agents_customizations.py`, `test_push_down_codex_and_agents_pack_manifest_completeness.py`, `test_push_down_codex_and_agents_resource_contracts.py`, `test_generate_codex_agent_variants.py` (its `PACK_ROOT` resolves under `codex-and-agents-customizations`), and the three `tests/scripts/codex-hooks` suites; plus `test_blast_radius_config_tolerance_keys.py` (path constant `PACK_MANIFEST_REGISTRY` only), `tests/shell/parallel_bash_manifest_membership.bats` (`.claude/lib/bash` membership only) and `EnforcementHooksNoPythonInvocation.Helpers.ps1` (comment only).
- Change: added two bullets naming each of these files with disposition `unchanged` and the reason. No search for `Get-DocsCommandTable`, `Test-DocsCommandTable`, `generate-reference` or `Invoke-DocsCommand` matched any test on this branch; [P0-T4] repeats the search on the merged tree.

## Fix 2

- Location: [P8-T2]
- Defect class: unsatisfiable-as-worded literal (validator-blind); the correction keeps the assertion "only added lines, one per NEW-MODULES file".
- Finding: the `paths` array of `extensions/drm-copilot/resources/claude-customizations/pack-manifests/core.json` ends with an element followed by `]`; appending after that element adds a comma to its line, so the anchored diff would show a removed line and the acceptance condition could not pass.
- Change: "append" replaced with "insert ... directly after the last existing `.claude/lib/docs/` entry (not after the final array element, whose line would gain a comma)".

## Fix 3

- Location: [P9-T9]
- Defect class: citation correction (required-context names).
- Finding: the required contexts of the Python quality job carry a version suffix (`quality-checks7 / Code Quality & Tests (3.10)` to `(3.13)`) per the execution-environment brief `## CI Shape and Required Checks`; the task named the unsuffixed form.
- Change: the four suffixed contexts are named.

## Fix 4

- Location: [P7-T1]
- Defect class: task text aligned to the acceptance criterion it cites (AC-6); no task, file or design change.
- Finding: AC-6 also asserts that on exit 0 the `result`, page and `summary` key sets equal those of `spec.md` `### -Json envelope and result`, and names `DocsReferenceIntegration.Tests.ps1` for it; the task text omitted that clause.
- Change: the clause is added to the AC-6 portion of the task.

## Fix 5

- Location: [P6-T4]
- Defect class: task text aligned to the acceptance criterion it cites (AC-11); no task, file or design change.
- Finding: AC-11 requires every trigger of `### Finding-code catalog` to produce its code and severity in an example-based test; the pass-through row (`DOCS_JSON_*`, `DOCS_SCHEMA_*`, `DOCS_PROFILE_*`) was not named by any task.
- Change: [P6-T4] now names a passed-through `DOCS_JSON_*`, `DOCS_SCHEMA_*` and `DOCS_PROFILE_*` finding with its severity under AC-11.

## Re-validation

- `mcp__drm-copilot__validate_orchestration_artifacts` (artifact_type plan) and the branch-current Python CLI `plan` subcommand were run after the fixes; results are recorded in the preflight return.
