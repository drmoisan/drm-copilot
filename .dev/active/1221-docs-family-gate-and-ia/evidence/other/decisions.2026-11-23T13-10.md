# Executor Decisions - Issue #1221

Timestamp: 2026-11-23T13-10
Command: autonomous-mode decision record (no command)
EXIT_CODE: 0
Output Summary: Decisions taken by the executor under autonomous mode, each with the recommended option applied.

## Decisions

1. Planner Decision P-2 (coverage summary counts): `required=<n>` counts entries with `required: true`; `present`, `missing`, and `not_applicable` count entries by `status` across every entry, including `required: false` entries. Applied in `ConvertTo-DocsCoverageFamilyLine` and asserted by `It 'counts a mixed families section in the summary line'`.
2. Return shape of `Get-DocsFamilyStatus`: it returns an ordered dictionary `{ entries, legacy_exclusions }` (the status entries in profile order and the sorted legacy list), because the spec gives the function both outputs. `Get-DocsCoverageFamilySection` returns the same two keys built from it.
3. Status entry `directory` keeps the profile value unchanged; only the evidence key, the page prefix, and the `related_paths` value of `DOCS_FAMILY_PAGE_MISSING` use the directory with trailing `/` removed, so a trailing slash never produces a finding that fails the relative-path grammar of `New-DocsFinding`.
4. `missing_root_files` follows spec `### Family status` (filled for the non-excluded `security` entry whatever its `required` value), while `DOCS_FAMILY_ROOT_FILE_MISSING` follows the findings table (only for `required: true`). A `required: false` security family therefore shows missing root files in the coverage section but produces no finding.
5. `Get-DocsFamilyFinding` emits `artifact_path` `$null` when the profile path is not a relative POSIX path, matching the existing pattern in `Read-DocsValidationArtifact`; the commands always pass a relative path.
6. Environment: `extensions/drm-copilot/node_modules` was absent in this worktree; it was installed with `npm --prefix extensions/drm-copilot ci` before the TypeScript baselines. No tracked file changed.
7. docs-plan-ia: the family-planning step is appended as step 7 after the existing steps, so every existing step keeps its number and text.
