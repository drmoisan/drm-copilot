# Preflight fixes (issue #1022, plan version 1.2)

Timestamp: 2026-11-03T22-36
Plan: docs/features/active/2026-10-30-docs-surface-analyzers-python-config-1022/plan.2026-10-30T16-46.md

Single-pass preflight of plan version 1.2 against the branch tree. Three trivial defects were fixed in place in task text and preamble. No task was added, removed or reordered, and no assertion changed.

## Fixes

1. `## Execution Context` (first bullet) | stale anchor | The branch name `feature/docs-surface-analyzers-python-config-1022` was replaced with the current item branch `feature/docs-surface-analyzers-python-config-1022-r2`.
2. [P1-T1] | citation correction | `Get-DocsElementId` throws `DOCS_IDENTITY_INPUT_INVALID` (`.claude/lib/docs/DocsSurface.psm1`, `Get-DocsElementId`); `DECLARATION_INVALID` is the 1022 diagnostic code emitted for the dropped candidate (spec `### Inventory level`). The task text now states both, so it no longer reads as if `Get-DocsElementId` itself produced `DECLARATION_INVALID`.
3. [P4-T2] | stale anchor | The alternative labels `900004` or `1033` and `900011` or `1031` were replaced with the values [P0-T2] recorded from the executed 1020 (`1033` and `1031`, `dependency-1020` artifact, `ANCHOR_LABEL` row).

## Validation

- `mcp__drm-copilot__validate_orchestration_artifacts` (`artifact_type: plan`) after the fixes: ok.
- `poetry run python -m scripts.dev_tools.validate_orchestration_artifacts plan <plan>` after the fixes: plan validation passed.
