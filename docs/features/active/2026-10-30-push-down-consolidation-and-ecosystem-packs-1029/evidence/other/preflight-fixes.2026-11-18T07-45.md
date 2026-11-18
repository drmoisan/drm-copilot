# Preflight Fixes (confirming preflight after plan revision 2.1)

Timestamp: 2026-11-18T07-45
Plan: docs/features/active/2026-10-30-push-down-consolidation-and-ecosystem-packs-1029/plan.2026-10-30T18-37.md
Command: env -u VIRTUAL_ENV poetry run python -m scripts.dev_tools.validate_orchestration_artifacts plan <plan path>; mcp__drm-copilot__validate_orchestration_artifacts (artifact_type plan)
EXIT_CODE: 0
Output Summary: Single-pass preflight found two trivial defects, fixed in task and preamble text, and no substantive defect. Both validators pass before and after the fixes, with no warnings.

## Fixes

1. `## Existing Test Dispositions`, row X5 | missing test disposition (citation completeness) | Added `PDT/claude-customizations-release-allowance.test.ts` with disposition "Unchanged". The file arrived with #1201 and calls the Claude `pushDownCustomizations` that P2-T3 rewrites. Its only seeded destination file is `.claude/release-commit-allowance.json`, an `EXCLUDED_RELATIVE_PATHS` path, so it matches none of R1 to R4 and is not edited. No task, file set or assertion changes.
2. `[P0-T1]` acceptance | search-scope citation correction | Named the bundle location `RES/claude-dir-customizations/`, which `Get-HarnessBundlePath` in `scripts/harness-generation/HarnessGeneration.psm1` assigns to `.mcp.json`. The location holds a tracked `.mcp.json`. The earlier P0-T1 record (`evidence/qa-gates/phase0-upstream-recheck.2026-11-18T07-25.md`) searched only the three named bundles and recorded `.mcp.json` as `absent`. The assertion is unchanged: P0-T1 still records the source or `absent`. P1-T4 and P4-T2 already handle a present `.mcp.json` source through a resources-relative root-file pair and a Claude manifest entry. No Claude manifest test checks that a listed path exists in `claude-customizations/`.

## Re-derivation notes (no fix needed)

- Shared set: 65 matrix entries (`kind` `skill`, `ecosystem` `codex`, `disposition` `shared`), each with a bundle folder. The 142 files in those folders are byte-identical to their repository copies, and no repository file is unbundled. Only three are not Markdown, and they are exactly the D16 paths (`.ps1` 2, `.sh` 1); there is no `.py`, `.ts` or `.psm1` file. S has 143 paths: 139 skill files plus the four fixed paths. Each D16 path exists in the Codex bundle and is listed in Codex `core.json`. The D16 reasons match the file text.
- X13: `_load_surface` loads `shared.json` as pack `shared`, and `powershell_sources` yields an empty list for it. `union_of_manifest_paths` in the Codex completeness test only gains coverage. `generate_codex_agent_variants.py` iterates `PACK_FAMILIES` only, and `codex-pack-selection.ts` loads manifests by selected name.
- D8 and D9: the `0010` stored hunks are matched by context (`ProcessReductionChain.psm1`). The `core.json` hunks are mid-array and the `jest.config.cjs` hunk sits inside `coverageThreshold`, away from the `require` and spread region.
- Line counts at HEAD: `jest.config.cjs` 624, `claude-customizations.ts` 497, `repo-automation-service.ts` 495, `mcp-tool-inputs.ts` 483, `mcp-tools.ts` 473, `repo-automation-command-registration-admin.ts` 420.
