# Follow-Ups Recorded by Remediation Cycle 1

Timestamp: 2026-10-08T20-35
Command: none (record only)
EXIT_CODE: 0
Output Summary: Five items are recorded and none is filed as a GitHub issue by this cycle.

1. CR-2 (recorded, not filed): extend the R1 trim set to `)`, `]`, `>`, `*`, and `_` so that `(docs/features/active/x)` and `**docs/features/active/x**` resolve to `x`. This requires a spec R1 amendment and new S06 rows.
2. CR-3 (recorded, not filed): `Find-OrchestrationModeRecord` was not converted to a delegate of `Find-FeatureFolderRecord`; see `evidence/other/cr3-mode-record-deviation.2026-10-08T20-35.md`. Candidate for C1b (#732).
3. PA-1 (recorded, not filed): repo-wide PowerShell line coverage is below 85% (pre-existing; non-blocking under the 2026-09-30 operator decision). Every changed production file is above 85%.
4. PA-2 (recorded, not filed): keep `evidence/other/timestamp-correction.2026-10-08T18-46.md` referenced in the PR description. All remediation cycle 1 artifacts use clock-read timestamps.
5. AC item 30 (recorded, not filed): the seven contract suites must pass in CI on the pull request. The item stays unchecked until CI evidence exists; an epic-child PR may need a manual `workflow_dispatch` of `ci.yml`.
