# Preflight Fixes - Issue 1024

Timestamp: 2026-10-30T21-32
Plan: docs/features/active/2026-10-30-docs-reference-generator-1024/plan.2026-10-30T16-54.md

## Fixes

1. [P0-T4] | literal-formatting (validator-blind search pattern) | The search for `dev.docs.`, `drm_copilot_docs.cli`, and `[tool.poetry.scripts]` used plain `grep`, under which `[tool.poetry.scripts]` is a bracket class matching any line containing one of those characters, and `.` is a wildcard. Changed to fixed-string `grep -F`. The searched tokens and the decision rule are unchanged.
2. Plan preamble `Inputs` | stale heading anchor | `### 900006 - docs-reference-generator` corrected to the full heading `### 900006 - docs-reference-generator (wave 1, C3)` in `docs/features/epics/documentation-estate-tooling/epic.md`.
3. [P7-T8] | unsatisfiable precondition wording | The parenthetical "(after the branch changes are committed)" required a commit that no plan task performs. `scripts/dev_tools/check_quality_tiers.py` classifies the projects of tracked files (`git ls-files`), and this plan adds no project manifest, so the result does not depend on a commit. The parenthetical now states this. The asserted outcome (`EXIT_CODE: 0`) is unchanged.

Validation after fixes: branch-current CLI `poetry run python -m scripts.dev_tools.validate_orchestration_artifacts plan <plan>` and the installed MCP validator, both re-run after the edits.
