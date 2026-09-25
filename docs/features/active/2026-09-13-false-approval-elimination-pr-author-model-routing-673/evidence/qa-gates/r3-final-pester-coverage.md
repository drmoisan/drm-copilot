# Final Full Pester Run with Coverage (issue #673)

Timestamp: 2026-09-19T19-19

Command: `pwsh -NoProfile -File <SCRATCHPAD>/r3-test-full.ps1` in a fresh `pwsh -NoProfile -File` process (route `a`, established by `[P0-T7]`), running `Invoke-PoshQCTest -Root $root -SettingsPath scripts/powershell/PoshQC/settings/pester.runsettings.psd1` over the whole configured `Run.Path`; then `<SCRATCHPAD>/r3-report.ps1` and `<SCRATCHPAD>/r3-name-status.ps1` to read the reports.

EXIT_CODE: 0

Pass number: **2**. Pass 1 ended at `[P11-T2]` with 15 analyzer warnings in files this plan authored; those were fixed at their cause and the loop restarted from `[P11-T1]`. This is the clean pass.

## Report freshness

- JUnit report last write (UTC): `2026-09-19T19:23:43Z`
- Coverage report last write (UTC): `2026-09-19T19:22:12Z`

Both are later than this artifact's `Timestamp:` of `2026-09-19T19-19`.

## Root results

| Attribute | Value |
| --- | --- |
| `tests` | 4963 |
| `failures` | **0** |
| `errors` | **0** |
| `disabled` | 9 |

Console summary: `Tests Passed: 4954, Failed: 0, Skipped: 9, Inconclusive: 0, NotRun: 0`.

Testcases carrying a `failure` child: none. **No exclusion is applied.** The `[P0-T10]` baseline recorded zero failing tests, so there is no exclusion set to apply, and this task would have applied none regardless. The nine skipped cases are the same nine the baseline recorded, all in an unrelated parallel-manifest parity suite that skips fixtures declaring no accessor expectation.

The suite grew from 4862 passed at baseline to 4954, a net of 92 added rows.

## Named testsuites

| Testsuite | tests | failures | passed |
| --- | --- | --- | --- |
| `enforcement-hooks-no-python-invocation.Tests.ps1` | 27 | 0 | 27 |
| `WorktreeResolution.Manifest.Tests.ps1` | 10 | 0 | 10 |
| `WorktreeTargetResolution.Tests.ps1` | 51 | 0 | 51 |
| `OrchestratorState.Tests.ps1` | 46 | 0 | 46 |
| `test-name-uniqueness.Tests.ps1` | 5 | 0 | 5 |
| `ClaudeLibModuleConvention.Tests.ps1` | 6 | 0 | 6 |
| `enforce-prd-feature-before-planner.Tests.ps1` | 47 | 0 | 47 |
| `enforce-prd-feature-before-planner.FolderResolution.Tests.ps1` | 25 | 0 | 25 |
| `enforce-prd-feature-before-planner.TargetResolution.Tests.ps1` | 24 | 0 | 24 |
| `enforce-prd-feature-before-planner.IdentityResolution.Tests.ps1` | 13 | 0 | 13 |

All ten named testsuites have `failures` 0. Two are worth calling out: `enforcement-hooks-no-python-invocation.Tests.ps1` is the #475 guard whose pass result `[P10-T4]` deferred to this task, and `test-name-uniqueness.Tests.ps1` confirms that every name this plan added, including the four `-ForEach` expansions, is distinct within its parent scope.

## Every §7 name and every AC-19 name

117 distinct expected names were checked: every `It` name in the six suites this plan authored, read from the files themselves rather than restated, with the two `-ForEach` rows expanded to both of their values; the three renamed pr-author target-resolution rows; the six renamed and added prd target-resolution rows; and the fifteen AC-19 `It` names `[P0-T6]` recorded.

**Result: every one appears exactly once with status Passed.**

Four of the 117 required scoping to their owning testsuite before that could be asserted, and the reason is recorded rather than glossed: `denies an empty payload as an envelope anomaly (fail closed)` occurs in 17 testcases across the repository and `denies the legacy flat root shape as a missing-tool_input anomaly` in 17, because many hook suites use the same row name for their own gate's envelope-anomaly case. Every occurrence is Passed. Scoped to `enforce-model-routing-receipt.Tests.ps1`, which is the suite AC-19 protects, each of the four occurs exactly once and is Passed. A global uniqueness reading would have been the wrong test: `test-name-uniqueness.Tests.ps1` requires distinctness per parent scope, not per repository.

## Line coverage

Overall: **95.77%** (9603 covered, 424 missed). Baseline was 95.72% (9487 covered, 424 missed); the missed count is unchanged and the ratio rose as covered lines were added.

| File | Line coverage | `covered` | `missed` | `line` elements |
| --- | --- | --- | --- | --- |
| `.claude/hooks/enforce-pr-author-skill.ps1` | 92% | 46 | 4 | 50 |
| `.claude/hooks/enforce-pr-author-skill-helpers.ps1` | 96.67% | 87 | 3 | 90 |
| `.claude/hooks/enforce-pr-author-skill.epic-base-branch.ps1` | 92.31% | 24 | 2 | 26 |
| `.claude/hooks/enforce-model-routing-receipt.ps1` | 94.74% | 54 | 3 | 57 |
| `.claude/lib/worktree-resolution/WorktreeItemResolution.psm1` | 99.06% | 105 | 1 | 106 |
| `.claude/hooks/enforce-prd-feature-before-planner.ps1` | 90.32% | 84 | 9 | 93 |
| `.claude/hooks/enforce-prd-feature-before-planner-helpers.ps1` | 96.61% | 57 | 2 | 59 |

Each of the seven files has line coverage of at least 85%; the lowest is 90.32%.

Output Summary: The clean pass completed with `EXIT_CODE: 0`, 4954 passed, 0 failed, 0 errored, and 9 pre-existing skips, with no exclusion applied. Both reports post-date this artifact's timestamp. All ten named testsuites have `failures` 0, including the #475 Python-free guard and the test-name-uniqueness guard. All 117 expected names appear exactly once with status Passed, four of them after scoping to their owning testsuite for a reason recorded above. Every one of the seven measured files exceeds the 85% line-coverage floor, and the new identity module reaches 99.06%.
