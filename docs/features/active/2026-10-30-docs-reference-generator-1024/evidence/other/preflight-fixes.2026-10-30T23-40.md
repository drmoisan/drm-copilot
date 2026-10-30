# Preflight Fixes - Issue 1024 (D1 planning cycle)

Timestamp: 2026-10-30T23-40
Plan: docs/features/active/2026-10-30-docs-reference-generator-1024/plan.2026-10-30T16-54.md
Mode: single-pass preflight; trivial defects fixed in task text and preamble only; no task added, removed or reordered.

## Fixes

1. `## Terms` (tool-route bullet) | Pester runner and job not named for task-level Pester acceptances | Added one sentence stating that task-level Pester acceptances are local branch-current runs and that in CI the suites run in `poshqc / PowerShell QC shard 1`, `shard 2` and `shard 3` on `windows-latest`, aggregated by `poshqc / PowerShell QC` ([P7-T14]); no acceptance relies on the Linux hook-suite job.
2. `## Pre-Mortem` (Test isolation bullet) | Jest and Python isolation runs neither named nor marked not applicable | Added a sentence stating that no Jest or Python test is created or changed, so neither run applies.
3. `## Acceptance Criteria Traceability` (AC-12 row) | Row omitted tasks that test AC-12 finding codes | Added [P2-T2], [P5-T7] and their suites to the row.
4. [P1-T1] | Task-ordering: the only acceptance condition was a test created later in [P2-T3], so the task could not be verified when it runs | Added an immediately checkable condition (module imports and exports exactly the seven functions) and stated that the harness properties are proven when [P2-T3] runs; the asserted harness properties are unchanged.
5. [P5-T7] | AC-12 requires every trigger in `### Finding codes` to be tested; `DOCS_REFERENCE_SNAPSHOT_MISSING` was named by no task | Added the absent-snapshot case (`DOCS_REFERENCE_SNAPSHOT_MISSING`, severity `error`) to the existing AC-08 exit-1 cases of the same suite.
6. [P6-T3] | Unsatisfiable literal: appending after the final `paths` element of `CORE` edits that element's line to add a comma, so `git diff --numstat` cannot report `0` deleted | Replaced "Append" with insertion before an existing entry, never after the final element; the asserted values (`0` deleted, each path exactly once) are unchanged.
7. [P7-T1] | Mirror re-copy stated only for formatter changes; a `LIB` fix made under [P7-T2] or [P7-T3] would leave `BUNDLE` copies stale | Extended the restart clause to re-copy mirrors after such fixes.
8. [P7-T2] | `DTESTS/DocsReference.TestSupport.psm1` (created by [P1-T1]) was outside the analyzed file set although CI static analysis covers it | Added it to the analyzed file list.
9. [P7-T11] | `git status --porcelain` collapses a new untracked directory (for example a new `<FEATURE>/evidence/<kind>/` folder) into one directory entry | Added `--untracked-files=all` so every untracked file is listed individually.
10. [P7-T12] | Same collapsed-directory defect as fix 9 | Added `--untracked-files=all`.

## Re-validation

- Branch-current CLI plan validation: passed after fixes.
- MCP plan validation: passed after fixes.
