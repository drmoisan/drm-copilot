# Preflight Fixes — Remediation Plan Cycle 1, Issue #1093

Timestamp: 2026-11-07T01-57
Plan: docs/features/active/2026-11-06-epic-progress-report-skill-1093/remediation-plan.2026-11-07T01-41.md
Command: single-pass preflight review of every phase, task and prose region; installed MCP plan validator and branch-current `poetry run python -m scripts.dev_tools.validate_orchestration_artifacts plan <plan>`
EXIT_CODE: 0
Output Summary: one trivial fix applied in task text; no substantive defect; both validators pass.

## Fixes

1. [P2-T2] | literal-formatting (task text vs acceptance) | The acceptance requires the `Entry suite additions` bullet to name the test `pairs and writes the stored samples with -PairSamples within 90 seconds of the last sample`, while the task text described the case only in prose. The task text now quotes that test name as the text to add. The asserted value is unchanged.

## Citations re-derived against the tree

- `tests/scripts/claude-skills/epic-progress-report/Get-EpicProgressReport.Tests.ps1`: 563 physical lines; 35 `It` cases; `Describe 'Invoke-EpicProgressReport'`; `rewrites the stored samples in pairs with -PairSamples`; `$script:statePath`, `$script:existingPaths`, `$script:fileText`, `$script:stateWrites`, `$script:fixedNowUnix`, `$script:reportParameter` present; `$PSScriptRoot`-relative `../../../../.claude/...` paths support the SCRATCH mirror layout of P1-T2.
- `.claude/skills/epic-progress-report/scripts/Get-EpicProgressReport.ps1` `Invoke-EpicProgressReport`: write condition `$selection.Changed -or $ResetBaseline -or $PairSamples`.
- `.claude/skills/epic-progress-report/scripts/Get-EpicProgressReport.State.ps1`: `Select-EpicProgressSample` (90-second rule), `Merge-EpicProgressSamplePair` (keeps indices n-1, n-3, ...; five samples give now minus 1230, 630, 30), `Resolve-EpicProgressBaseline` (passed, else reset now, else stored).
- `spec.md` `## Script Additions` `-StartUtc` row and `## Test Inventory` `Entry suite additions` bullet present; 28 checked and 3 unchecked AC lines in `spec.md`.
- Six suites under `tests/scripts/claude-skills/epic-progress-report/`, five `CANON` files and five `BUNDLE` copies present.
