# Scope Check Against the Complete Write Set (P6-T30)

Timestamp: 2026-10-02T08-45
Command: git -C <ROOT> diff --name-only 589b51a30d856dca973a2ed9988f9443c35339cf; git -C <ROOT> status --porcelain --untracked-files=all (BASE_SHA substituted literally per DEV-P5-T7; run after commit ab266ca9, before the P6-T31 to P6-T48 check-off edits)
EXIT_CODE: 0
Output Summary: union = 21 non-feature-folder paths, each a Complete Write Set row (rows 1-21), plus 57 feature-folder paths (the plan, row 23, and 56 evidence files, row 24). No path outside the write set. `spec.md` (row 22) is changed after this listing by the AC check-off tasks.

## Non-feature-folder paths (from `git diff --name-only`; all committed)

| Path | Write-set row |
| --- | --- |
| tests/fixtures/poshqc-consumer/scripts/Sample.psm1 | 1 |
| tests/fixtures/poshqc-consumer/tests/scripts/Sample.Tests.ps1 | 2 |
| tests/fixtures/poshqc-consumer/.claude/hooks/validate-bash.ps1 | 3 |
| .gitignore | 4 |
| tests/scripts/powershell/PoshQC/PoshQC.Coverage.Tests.ps1 | 5 |
| tests/scripts/powershell/PoshQC/PoshQC.CoverageConfig.Tests.ps1 | 6 |
| scripts/powershell/PoshQC/PoshQC.Coverage.psm1 | 7 |
| scripts/powershell/PoshQC/PoshQC.psm1 | 8 |
| scripts/powershell/PoshQC/PoshQC.Testing.psm1 | 9 |
| scripts/powershell/PoshQC/settings/pester.runsettings.psd1 | 10 |
| config/poshqc-coverage.json | 11 |
| tests/scripts/powershell/PoshQC/PoshQC.TestingInvokeSummary.Tests.ps1 | 12 |
| tests/scripts/powershell/PoshQC/PoshQC.Comprehensive.Tests.ps1 | 13 |
| scripts/powershell/PoshQC/README.md | 14 |
| extensions/drm-copilot/resources/powershell/PoshQC/PoshQC.Coverage.psm1 | 15 |
| extensions/drm-copilot/resources/powershell/PoshQC/PoshQC.Testing.psm1 | 16 |
| extensions/drm-copilot/resources/powershell/PoshQC/PoshQC.psm1 | 17 |
| extensions/drm-copilot/resources/powershell/PoshQC/settings/pester.runsettings.psd1 | 18 |
| extensions/drm-copilot/resources/powershell/PoshQC/README.md | 19 |
| tests/scripts/dev_tools/test_poshqc_bundled_parity.py | 20 |
| docs/features/potential/2026-08-19-mcp-poshqc-test-ignores-repo-runsettings-coverage.md | 21 |

## Feature-folder paths

- `docs/features/active/2026-08-23-poshqc-coverage-denominator-not-reproducible-527/plan.2026-09-29T15-32.md` (committed; checkbox state only) — row 23.
- Committed evidence files under `<FEATURE>/evidence/` (34 paths in the `git diff --name-only` output: 12 under `baseline/`, 13 under `other/` including `plan-deviations.2026-10-02T07-45.md`, 9 under `regression-testing/`) — row 24. The classification artifact `evidence/other/pwsh-task-classification.2026-10-02T07-50.md` and the preflight-round files predate BASE_SHA, so they do not appear in the diff; they are row-24 evidence as well.
- Untracked evidence files listed by `git status --porcelain --untracked-files=all` (22 paths: 21 under `evidence/qa-gates/` and `evidence/regression-testing/pass-after-named-tests.2026-10-02T08-45.md`) — row 24. This scope-check artifact is a further row-24 file created after the listing.
- `issue.md`, `spec.md`, `research/` pre-existed per P0-T2 and do not appear in the listing.

- Acceptance: every listed path is a Complete Write Set row. Met.
