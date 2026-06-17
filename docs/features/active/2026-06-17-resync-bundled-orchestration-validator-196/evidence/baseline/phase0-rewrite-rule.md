# Phase 0 — Bundle Rewrite Rule and File Mappings (Issue #196)

Timestamp: 2026-06-17T19-05

## Rewrite Rule (Single Source of Truth)

Statement-anchored prefix substitution applied ONLY to import statements:

- `from scripts.dev_tools.` -> `from dev_tools.`
- `import scripts.dev_tools.` -> `import dev_tools.`

Anchored to the leading `from ` / `import ` keyword tokens. Docstring prose and
comments that contain the substring `scripts.dev_tools.` are NOT import statements
and remain unchanged in the bundle.

## Five Source-to-Bundle File Mappings

| # | Source (`scripts/dev_tools/`) | Bundle (`extensions/drm-copilot/resources/scripts/dev_tools/`) | Import rewrites |
|---|---|---|---|
| 1 | `validate_orchestration_artifacts.py` | `validate_orchestration_artifacts.py` | 3 (lines 16, 20, 23) |
| 2 | `validate_orchestrator_state.py` | `validate_orchestrator_state.py` | 1 (line 34); docstring lines 10, 14 unchanged |
| 3 | `_orchestrator_state_human_interaction.py` | `_orchestrator_state_human_interaction.py` | 0 (byte-identical); docstring lines 6, 14 unchanged |
| 4 | `validate_orchestration_review_artifacts.py` | `validate_orchestration_review_artifacts.py` | 1 (line 29); docstring line 9 unchanged |
| 5 | `validate_policy_audit_artifact.py` | `validate_policy_audit_artifact.py` | 0 (byte-identical); docstring line 11 unchanged |
