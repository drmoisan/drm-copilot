# Preflight Fixes - Issue #1218 (round two)

Timestamp: 2026-11-23T06-25
Plan: .dev/active/1218-docs-family-profile-model/plan.2026-11-23T00-38.md
Signal: PREFLIGHT: ALL CLEAR (trivial fixes below applied in task text only; no task added, removed, or reordered; the round-one record preflight-fixes.2026-11-23T06-14.md is not edited)

## Round-One Defects Verified Resolved

1. P1-T2 `DOCS_SCHEMA_REQUIRED_MISSING` pointer: task text states `/required_families/0/<field>` and the exclusion `reason`/`recorded_at` pointers; spec D16 and the `### Schema-layer error codes` row agree with `Get-DocsSchemaWalkFinding` (`Get-DocsChildPointer -Pointer $Pointer -Part $name`) in `.claude/lib/docs/DocsSchemaWalk.psm1`.
2. P1-T2 `DOCS_SCHEMA_INVALID` cases: one case each for uppercase id, template with a space, directory with a backslash, legacy glob path, whitespace-only reason, duplicate audience entry, and negative interval. Each keyword (`pattern`, `uniqueItems`, `minimum`) is outside the structural walk subset, so the code is `DOCS_SCHEMA_INVALID` from Test-Json.
3. P2-T2 ordinal key-order assertion for every `Get-DocsDefaultFamilySet` record: present.
4. P2-T4 starter audience descriptions asserted against the spec `### Starter audiences` text in order: present, text equal to spec.
5. P3-T1 four-copy placement and token It over `Get-DocsAuthoringSkillRoot` (`Claude`, `ClaudeBundle`, `Codex`, `CodexBundle`), tagged `[expect-fail]`, expected failures named with an evidence artifact under `evidence/regression-testing/`; P3-T2 asserts every row passes; the Phase 3 gate (P3-T3) runs after P3-T2, so no gate or acceptance condition is unsatisfiable.

## Fixes

1. [P3-T1] | changed-behavior test disposition (validator-blind class) | Named the contract tests that read the edited `.agents/skills/docs-init` files and fail transiently between P3-T1 and P3-T2 (`docs-authoring-roles.Mirrors.Tests.ps1` docs-init row, `HarnessGeneration.RepoGate.Tests.ps1`, `test_push_down_codex_and_agents_resource_contracts.py`), with disposition: unchanged, outside the P3-T1 task-check selection, asserted passing in P3-T2. The P3-T1 assertion and expect-fail set are unchanged.
2. [Pre-Mortem / File size] | citation correction | Corrected the line count of `tests/scripts/claude-runtime/docs-authoring-roles.WorkflowText.Tests.ps1` from 146 to 145 (measured with `wc -l`).

## Validation

- Installed MCP validator (`validate_orchestration_artifacts`, artifact_type plan): ok.
- Branch-current CLI (`scripts.dev_tools.validate_orchestration_artifacts plan`): re-run after the fixes.
- Size: 18 canonical tasks, 80 physical lines (within 20 and 250).
- Correction appended after re-validation: the canonical task count is 20 (P0 4, P1 3, P2 6, P3 3, P4 4), at the 20-task limit; 80 physical lines. Branch-current CLI re-run after the fixes: `plan validation passed`, exit 0; installed MCP validator: ok.
