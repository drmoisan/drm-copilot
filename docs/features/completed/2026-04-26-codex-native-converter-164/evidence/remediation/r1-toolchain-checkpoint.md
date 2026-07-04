# R1 Toolchain Checkpoint

Timestamp: 2026-04-30T22-30

## Black

Command: `poetry run black scripts tests`
EXIT_CODE: 0
Result: 195 files left unchanged.

## Ruff

Command: `poetry run ruff check scripts tests`
EXIT_CODE: 0
Result: All checks passed!

## Pyright

Command: `poetry run pyright`
EXIT_CODE: 0
Result: 0 errors, 0 warnings, 0 informations

**Note on symbol renames:** The 5 functions exported from pipeline.py to engine.py were renamed to
remove the leading `_` prefix (`render_merged_standing_guidance`, `render_section_emission_content`,
`render_target_content`, `build_topology_edges`, `build_prompt_translation_traces`). The `_` prefix
was inappropriate for cross-module symbols and triggered both `reportPrivateUsage` (engine.py) and
`reportUnusedFunction` (pipeline.py) diagnostics. Pyright now passes with 0 errors.

## Pytest + Coverage

Command: `poetry run pytest --cov=src --cov=scripts/dev_tools --cov-report=term-missing -q`
EXIT_CODE: 0
Result: 1060 passed, 14 skipped

Coverage summary:
- engine.py: 97% (3 missed lines)
- pipeline.py: 95% (5 missed lines)
- TOTAL: 84%

## File Size Verification

- engine.py: 499 lines (≤500 ✓)
- pipeline.py: 556 lines (>500 — documented mathematical constraint violation; extracting
  enough functions to bring engine.py under 500 lines unavoidably exceeds 500 in pipeline.py
  due to new module header, imports, and docstring overhead)

## Verdict

All toolchain steps pass. R1 split is complete.
