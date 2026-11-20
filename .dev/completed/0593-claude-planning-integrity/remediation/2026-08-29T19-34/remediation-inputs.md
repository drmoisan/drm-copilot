# Remediation Inputs: Claude Planning Integrity (#593)

**Timestamp:** 2026-08-29T19-34  
**Source review:** `docs/features/active/2026-08-29-claude-planning-integrity-593/audit/2026-08-29T19-34/`  
**Authoritative requirements source:** This document.

## Required fixes

1. Format `tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py` with Black so `poetry run black --check tests/scripts/dev_tools/test_claude_planning_integrity_contracts.py tests/scripts/dev_tools/test_parallel_planner_surface_contracts.py tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py` exits 0.
2. Remove only the extra final blank line reported by `git diff --check main...HEAD` from these committed evidence files:
   - `docs/features/active/2026-08-29-claude-planning-integrity-593/evidence/remediation-baseline/planner-review-python-focused-baseline.2026-08-29T14-41.md`
   - `docs/features/active/2026-08-29-claude-planning-integrity-593/evidence/remediation-baseline/planner-review-python-format-baseline.2026-08-29T14-41.md`
   - `docs/features/active/2026-08-29-claude-planning-integrity-593/evidence/remediation-baseline/planner-review-python-full-coverage-baseline.2026-08-29T14-41.md`
   - `docs/features/active/2026-08-29-claude-planning-integrity-593/evidence/remediation-baseline/planner-review-python-lint-baseline.2026-08-29T14-41.md`
   - `docs/features/active/2026-08-29-claude-planning-integrity-593/evidence/remediation-baseline/planner-review-python-type-baseline.2026-08-29T14-41.md`
3. Run the complete applicable toolchain after the corrections: Black, Ruff, Pyright, focused pytest, `poetry run pytest --cov`, full-root PoshQC format/analyze/test, and `git diff --check main...HEAD`. Record new command evidence under `evidence/qa-gates/` using the canonical schema.
4. Preserve all verified #593 planner-review, numeric-provenance, counter, parallel-intake, canonical/bundle parity, and acceptance-criteria behavior. Do not alter production or test behavior except the required format-only edit.

## Do not do

- Do not weaken, delete, skip, or reclassify any quality gate.
- Do not modify policy documents, runtime contracts, source behavior, or acceptance-criterion text.
- Do not use temporary test files, manual-only verification, or external services.
- Do not push, create a PR, merge, or execute remediation until the orchestrator provides execution authorization.

## Required verification

```powershell
git diff --check main...HEAD
poetry run black --check tests/scripts/dev_tools/test_claude_planning_integrity_contracts.py tests/scripts/dev_tools/test_parallel_planner_surface_contracts.py tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py
poetry run ruff check tests/scripts/dev_tools/test_claude_planning_integrity_contracts.py tests/scripts/dev_tools/test_parallel_planner_surface_contracts.py tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py
poetry run pyright tests/scripts/dev_tools/test_claude_planning_integrity_contracts.py tests/scripts/dev_tools/test_parallel_planner_surface_contracts.py tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py
poetry run pytest --cov
```

Use the DRM Copilot MCP surface for full-root PoshQC format, analysis, and Pester coverage verification.
