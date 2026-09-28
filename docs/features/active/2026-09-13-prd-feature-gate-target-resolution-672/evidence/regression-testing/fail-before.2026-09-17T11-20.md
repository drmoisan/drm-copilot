# Fail-Before Evidence for the Target-Resolution Behaviour Change

Timestamp: 2026-09-17T11-20

Command: `Import-Module Pester -MinimumVersion 5.0.0 -Force; $cfg = New-PesterConfiguration; $cfg.Run.Path = @('tests/scripts/claude-hooks/enforce-prd-feature-before-planner.Tests.ps1','tests/scripts/claude-hooks/enforce-prd-feature-before-planner.FolderResolution.Tests.ps1','tests/scripts/claude-hooks/enforce-prd-feature-before-planner.TargetResolution.Tests.ps1'); $cfg.Should.ErrorAction = 'Stop'; Invoke-Pester -Configuration $cfg`, run from the worktree root through the scratchpad wrapper `sh runps.sh threesuites.ps1`.

EXIT_CODE: 1

ExpectedExitCode: 1

Output Summary: 84 total, 74 passed, 10 failed. All ten failures are in the new companion suite; every case in both existing suites still passes after the Phase 1 extraction.

## The ten `It` blocks added by `[P3-T2]` through `[P3-T8]`, with observed outcomes

| # | task | `It` name | observed outcome | failure mode |
| --- | --- | --- | --- | --- |
| 1 | `[P3-T2]` | `allows when the target root holds the required document` | **FAILED** | parameter-binding error |
| 2 | `[P3-T3]` | `allows when the modelled cwd is the item worktree` | **PASSED** (its required outcome) | n/a |
| 3 | `[P3-T4]` | `allows an absolute path to the target feature folder` (two `-ForEach` rows, both observed) | **FAILED** on both rows | parameter-binding error |
| 4 | `[P3-T5]` | `denies rather than validating against a sibling session checkpoint` | **FAILED** | composition-path assertion failure |
| 5 | `[P3-T5]` | `denies rather than selecting the earliest candidate on an unresolved tie` | **FAILED** | composition-path assertion failure |
| 6 | `[P3-T5]` | `denies with the ambiguity reason when the folder is absent from the target root` | **FAILED** | parameter-binding error |
| 7 | `[P3-T6]` | `runs no existence probe on the ambiguity branch` | **FAILED** | parameter-binding error |
| 8 | `[P3-T7]` | `denies with the ambiguity code when the target cannot be resolved` | **FAILED** | parameter-binding error |
| 9 | `[P3-T7]` | `emits an ambiguity code distinct from the missing-document and marker reasons` | **FAILED** | parameter-binding error |
| 10 | `[P3-T8]` | `denies with the missing-document reason when the document is absent under the target root` | **FAILED** | parameter-binding error |

Ten `It` blocks are named. **Nine** fail. Exactly **eight** of the rows required to fail do fail: every row except `allows when the modelled cwd is the item worktree` (`[P3-T3]`, excluded and observed passing) and `allows an absolute path to the target feature folder` (`[P3-T4]`, excluded and observed failing). Eight recorded failures establish fail-before for the behaviour change.

## Failure-mode detail

Two rows fail with a composition-path assertion failure, which is a direct behavioural observation of the pre-change hook:

- `denies rather than validating against a sibling session checkpoint`: `Expected: 'deny' But was: 'allow'`. The pre-change hook lets the session's own checkpoint decide a two-candidate tie and then allows.
- `denies rather than selecting the earliest candidate on an unresolved tie`: `Expected: 'deny' But was: 'allow'`. The pre-change hook returns the earliest-occurring candidate and then allows.

The remaining seven rows bind the injection parameter `-ResolvedTarget`, which `[P4-T3]` adds, so against the Phase 3 hook they fail with `A parameter cannot be found that matches parameter name 'ResolvedTarget'.` rather than with a composition-path assertion failure. `[P3-T3]`'s row is excluded from this accounting as well as from the fail count, because it deliberately omits the parameter.

## Behavioural observation of the pre-change composition path, per binding-error row

Each of the seven rows was additionally run against the pre-change hook with the parameter omitted and its own seam values in place (`sh runps.sh p3t9probe.ps1`, which dot-sources both hook files and redefines the three seams). Every one of them produced:

- Decision: `deny`
- Reason: `PRD_FEATURE_BLOCKED: resolved feature folder 'docs/features/active/2026-09-13-synthetic-target-672', but its work mode could not be determined from 'docs/features/active/2026-09-13-synthetic-target-672/issue.md' (the '- Work Mode:' marker is absent, unreadable, or unrecognized). Confirm that is the intended feature folder, then add or correct the '- Work Mode:' marker in that file so the prerequisite set can be derived.`

That single observation is the defect stated behaviourally: the pre-change hook discards the absolute prefix, composes `docs/features/active/...` against the session root, finds no `issue.md` there, and emits the marker-is-broken reason for a folder it probed at the wrong root. The two rows that assert an ambiguity reason and the row that asserts a missing-document reason under the target root are each distinguishable from this observed reason, so none of them can pass vacuously after the fix.
