# Phase 0 Full Pester Baseline with Coverage (issue #673)

Timestamp: 2026-09-19T17-27

Command: `pwsh -NoProfile -File <SCRATCHPAD>/r3-test-full.ps1` (route `a`), whose body is `$ErrorActionPreference = 'Stop'` / `$root = (Get-Location).Path` / `Import-Module ./scripts/powershell/PoshQC/PoshQC.psd1 -Force` / `Invoke-PoshQCTest -Root $root -SettingsPath scripts/powershell/PoshQC/settings/pester.runsettings.psd1`; then `pwsh -NoProfile -File <SCRATCHPAD>/r3-report.ps1` to read the two reports.

EXIT_CODE: 0

## Report freshness

- JUnit report `artifacts/pester/pester-junit.xml` last write (UTC): `2026-09-19T17:31:32Z`
- Coverage report `artifacts/pester/powershell-coverage.xml` last write (UTC): `2026-09-19T17:30:04Z`

Both are later than this artifact's `Timestamp:` of `2026-09-19T17-27`, so both reports are products of this run and not of an earlier one.

## Root results

| Attribute | Value |
| --- | --- |
| `tests` | 4871 |
| `failures` | 0 |
| `errors` | 0 |
| `disabled` | 9 |

Console summary line for cross-reference: `Tests Passed: 4862, Failed: 0, Skipped: 9, Inconclusive: 0, NotRun: 0`. The JUnit `tests` attribute of 4871 is the passed count plus the nine skipped cases, which the JUnit writer records under `disabled`.

Testcases carrying a `failure` child: **none**

Consequence for later tasks: the baseline has zero failing tests, so the exclusion set the plan's §5 provides for (`If [P0-T10] records failing testcases, every root failures 0 condition before Phase 11 excludes exactly those names`) is **empty**. Every later `failures 0` condition in this plan is therefore unconditional, and the phrase "apart from `[P0-T10]` exclusions" resolves to no exclusion at all.

## Named testsuites (all ten present)

| Testsuite (name ends with) | tests | failures | skipped | disabled | passed |
| --- | --- | --- | --- | --- | --- |
| `WorktreeResolution.Manifest.Tests.ps1` | 7 | 0 | 0 | 0 | 7 |
| `WorktreeTargetResolution.Tests.ps1` | 51 | 0 | 0 | 0 | 51 |
| `enforcement-hooks-no-python-invocation.Tests.ps1` | 27 | 0 | 0 | 0 | 27 |
| `OrchestratorState.Tests.ps1` | 48 | 0 | 0 | 0 | 48 |
| `enforce-model-routing-receipt.Tests.ps1` | 15 | 0 | 0 | 0 | 15 |
| `enforce-pr-author-skill.OrchestratorStatePreflight.Tests.ps1` | 3 | 0 | 0 | 0 | 3 |
| `enforce-pr-author-skill.epic-base-branch.Tests.ps1` | 9 | 0 | 0 | 0 | 9 |
| `enforce-prd-feature-before-planner.Tests.ps1` | 47 | 0 | 0 | 0 | 47 |
| `enforce-prd-feature-before-planner.FolderResolution.Tests.ps1` | 25 | 0 | 0 | 0 | 25 |
| `enforce-prd-feature-before-planner.TargetResolution.Tests.ps1` | 28 | 0 | 0 | 0 | 28 |

Passed counts are computed as `tests - failures - skipped - disabled`, per the plan's §5 rule.

## Overall line coverage

| Metric | Value |
| --- | --- |
| Line coverage | 95.72% |
| `covered` | 9487 |
| `missed` | 424 |

Read from the `report`-level `counter type="LINE"` element of `artifacts/pester/powershell-coverage.xml`.

## Per-file line coverage (six in-scope hook files)

All six resolve inside the package whose name ends with `.claude/hooks`; that package's name attribute carries the executing worktree root, recorded here as `<WORKSPACE_ROOT>/.claude/hooks`.

| File | Line coverage | `covered` | `missed` | `line` elements |
| --- | --- | --- | --- | --- |
| `enforce-pr-author-skill.ps1` | 92% | 46 | 4 | 50 |
| `enforce-pr-author-skill-helpers.ps1` | 95.51% | 85 | 4 | 89 |
| `enforce-pr-author-skill.epic-base-branch.ps1` | 92.31% | 24 | 2 | 26 |
| `enforce-model-routing-receipt.ps1` | 92.68% | 38 | 3 | 41 |
| `enforce-prd-feature-before-planner.ps1` | 90.72% | 88 | 9 | 97 |
| `enforce-prd-feature-before-planner-helpers.ps1` | 96.77% | 60 | 2 | 62 |

Twelve raw counters are recorded (a `covered` and a `missed` per file), six percentages, six `line`-element counts, and one overall percentage.

Output Summary: The full Pester suite passes at baseline with 4862 passed, 0 failed, 0 errored, and 9 skipped; the JUnit root records `failures 0` and `errors 0`. All ten named testsuites are present and each has `failures 0`. Overall line coverage is 95.72% (9487 covered, 424 missed). All six in-scope hook files are above the 85% line-coverage floor at baseline, the lowest being `.claude/hooks/enforce-prd-feature-before-planner.ps1` at 90.72%; that file is the one Phase 9 changes most, and `[P11-T5]` requires its post-change percentage to be at or above this 90.72% baseline, not merely above 85%. Each of the six files carries a non-zero `line`-element count, so the changed-line coverage computation `[P11-T5]` depends on has data to read. The zero-failure baseline means no exclusion set is carried forward.
