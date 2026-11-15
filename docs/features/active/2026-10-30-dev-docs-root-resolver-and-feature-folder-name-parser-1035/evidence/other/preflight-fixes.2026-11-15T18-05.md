# Preflight Fixes

Timestamp: 2026-11-15T18-05
Plan: docs/features/active/2026-10-30-dev-docs-root-resolver-and-feature-folder-name-parser-1035/plan.2026-10-30T17-11.md
Head: branch feature/dev-docs-root-resolver-phase1-1035 at the preflight head named in the delegation prompt.

Classification note: each fix adds a missing test row for behavior that the same task already owns (same file, same cited spec decision OD-P4). On the #1016 round 1 precedent this class is trivial and fixed in place; it is recorded here so the orchestrator can review the classification. No task was added, removed, or reordered, and no assertion of an existing row changed.

## Fixes

1. P8-T3 | missing test row for owned behavior | Added `BR-FEATURE-PREFIX-PASSES-DEV-QUALIFIED-FOLDER`. The task widens `$script:FeatureFolderPrefix` to the union, but no named case failed when the prefix stayed at `docs/features/`; an already-qualified `.dev/active/f` would then yield a doubled `docs/features/active/.dev/active/f/**` entry with every existing and new case still passing.
2. P8-T3 | missing test row for owned behavior | Added `BR-DERIVATION-CALLS-NO-RESOLVER` (module AST names no `Resolve-DevelopmentDocsRoot`). Spec OD-P4 states the derivation does not call the resolver; the existing rows pass an explicit root or none and would still pass if the derivation called the resolver.
3. P8-T4 | missing test row for owned behavior | Added `test_derivation_passes_through_a_dev_qualified_feature_folder`, the Python twin of fix 1 for `FEATURE_FOLDER_PREFIX`.
4. P8-T4 | missing test row for owned behavior | Added `test_compute_blast_radius_calls_no_resolver` (AST: no `resolve_development_docs_root`), the Python twin of fix 2.
5. `## Spec Rule Traceability`, OD-P4 row | traceability update for fixes 1 to 4 | Named the four added tests in the failing-test column.

## Verification

- Installed MCP validator (`artifact_type: plan`): ok before the fixes.
- Branch-current Python CLI `scripts.dev_tools.validate_orchestration_artifacts plan`: exit 0 before the fixes; re-run after the fixes.
