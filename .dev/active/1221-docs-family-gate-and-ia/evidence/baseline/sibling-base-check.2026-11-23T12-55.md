# Sibling Base Check - Issue #1221 (P0-T1)

Timestamp: 2026-11-23T12-55
Command: git fetch origin epic/documentation-estate-families-integration; git merge-base origin/epic/documentation-estate-families-integration HEAD; grep over .claude/lib/docs/DocsProfileFamilies.psm1, .claude/lib/docs/schemas/v1/docs-profile.schema.json, .claude/lib/docs/DocsProfile.psm1; grep route_id artifacts/orchestration/orchestrator-state.json
EXIT_CODE: 0
Output Summary: All checks PASS. The branch base contains #1218 (merge of PR #1229). Execution continues to Phase 1.

## Merge-Base Derivation

- Derivation: `git merge-base origin/epic/documentation-estate-families-integration HEAD`.
- Result: the merge base equals both `HEAD` and the fetched tip of `origin/epic/documentation-estate-families-integration` (the branch has no commits of its own yet). The tip is the merge commit of PR #1229 (`feature/docs-family-profile-model-1218`).

## Checks

| Check | Result | Observation |
|---|---|---|
| `.claude/lib/docs/DocsProfileFamilies.psm1` exists | PASS | file present, 202 lines |
| `DocsProfileFamilies.psm1` exports `Get-DocsDefaultFamilySet` | PASS | `Export-ModuleMember -Function Get-DocsDefaultFamilySet, Test-DocsProfileFamilySemantic` |
| `docs-profile.schema.json` declares top-level `required_families` | PASS | array of `#/$defs/documentation-family` |
| `docs-profile.schema.json` declares top-level `legacy_exclusions` | PASS | array of `#/$defs/legacy-exclusion` |
| `New-DocsStarterProfile` seeds `required_families` with `required: true` entries | PASS | `required_families = Get-DocsDefaultFamilySet -DocumentationRoot $DocumentationRoot`; every record sets `required = $true`; `legacy_exclusions = @()` |
| Legacy-entry member names | PASS | `legacy-exclusion` requires exactly `path` and `reason` (`additionalProperties: false`), matching Decision 12 |
| Family exclusion member names | PASS | `family-exclusion` requires `reason` and `recorded_at` |
| Item worktree route value | PASS | `artifacts/orchestration/orchestrator-state.json` `route_id` is `large` (non-terminal) |

## Seeded Family Ids and Directories

Order and directories from `Get-DocsDefaultFamilySet` (directory is `<DocumentationRoot>/<id>`):

1. `product-overview` -> `<root>/product-overview`
2. `getting-started` -> `<root>/getting-started`
3. `user-guides` -> `<root>/user-guides`
4. `administration` -> `<root>/administration`
5. `security` -> `<root>/security`
6. `operations` -> `<root>/operations`
7. `service-management` -> `<root>/service-management`
8. `architecture` -> `<root>/architecture`
9. `adr` -> `<root>/adr`
10. `reference` -> `<root>/reference`

The family `directory` uses the common `relative-path` schema definition.
