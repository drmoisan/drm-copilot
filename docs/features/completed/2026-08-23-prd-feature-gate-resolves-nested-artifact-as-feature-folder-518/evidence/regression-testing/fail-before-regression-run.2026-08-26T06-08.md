# Fail-Before Regression Run — [P1-T11]

Timestamp: 2026-08-26T06-08

Task: [P1-T11]
Workspace root: `C:\Users\DanMoisan\repos\drm-copilot\.claude\worktrees\agent-a931fa47c98f755c3`
Tree state: all Phase 1 test edits applied. **No production file has been edited.** Both copies of
`enforce-prd-feature-before-planner.ps1` are still at their Phase 0 state, so every failure below is
a failure of the UNFIXED hook against the newly stated expectations.

Command:

```text
mcp__drm-copilot__run_poshqc_test  workspace_root="C:\Users\DanMoisan\repos\drm-copilot\.claude\worktrees\agent-a931fa47c98f755c3"
```

EXIT_CODE: 21

ExpectedExitCode: 21

The MCP PoshQC test runner reports the failing-test count as its process exit code. A non-zero exit
is the expected and required outcome of this task: it is the fail-before half of the fail-before /
pass-after pair. [P3-T1] records the corresponding pass-after run with EXIT_CODE 0.

## Numeric Failed Count

**Failed count: 21.**

Extracted from `artifacts/pester/pester-junit.xml` written by the run recorded above. `artifacts/` is
gitignored in this checkout, so the XML is not committed and its numeric contents are transcribed
here.

| Metric | Value |
| --- | --- |
| Total tests | 3617 |
| Passed | 3587 |
| **Failed** | **21** |
| Errors | 0 |
| Skipped | 9 |
| Test suites (files) | 149 |

Baseline comparison against [P0-T5]: total rose from 3592 to 3617, an increase of 25, matching the 25
new `It` blocks added by [P1-T2] through [P1-T8]. Suite count rose from 148 to 149, matching the one
new companion test file. No pre-existing test was deleted.

Per-suite totals for the two files in scope:

| Test file | Tests | Passed | Failed | Skipped |
| --- | --- | --- | --- | --- |
| `tests/scripts/claude-hooks/enforce-prd-feature-before-planner.FolderResolution.Tests.ps1` | 25 | 7 | 18 | 0 |
| `tests/scripts/claude-hooks/enforce-prd-feature-before-planner.Tests.ps1` | 47 | 44 | 3 | 0 |

18 plus 3 equals the 21 failures, so every failure in the whole 149-file suite belongs to one of the
two files this plan touches. No unrelated test regressed.

## Exact `It` Names That Failed

### Companion file, folder resolution by four-segment truncation (4 of 6 failing)

1. `resolves the same folder when the prompt cites a research artifact path`
2. `resolves the same folder when the prompt cites an evidence artifact path`
3. `resolves the folder from a nested artifact path with no folder citation`
4. `rejects a token that truncates to fewer than four segments`
5. `yields one distinct candidate when one folder is cited at three depths`

`resolves the same folder when the prompt cites the feature folder alone` PASSES against the unfixed
hook, which is expected: truncation is the identity for a prompt citing the folder alone, so that
form resolves correctly today and must continue to.

### Companion file, deterministic selection among two feature folders (3 of 3 failing)

6. `prefers the checkpoint folder when it occurs later in the prompt`
7. `uses the earliest candidate when the checkpoint folder is absent`
8. `uses the earliest candidate when the checkpoint folder is not a candidate`

### Companion file, decision equivalence and the reproduction differential (3 of 3 failing)

9. `returns the same decision for all four prompt forms`
10. `returns the same decision for folder-relative and repo-relative research paths`
11. `allows full-bug with spec present and user-story absent citing a nested research artifact`

Item 11 is the reproduction from issue #518 stated as a test: it is the case that cannot pass today.

### Companion file, indeterminate work-mode marker (6 of 6 failing)

12. `denies with the indeterminate-marker reason when the marker line is absent`
13. `denies with the indeterminate-marker reason when issue.md is unreadable`
14. `denies with the indeterminate-marker reason when the marker value is unrecognized`
15. `names the resolved folder and the issue.md path in the indeterminate reason`
16. `omits spec.md and user-story.md from the indeterminate reason`
17. `does not invoke the file-existence probe in the indeterminate branch`

### Companion file, block message (1 of 2 failing)

18. `names the resolved folder ahead of the prd-feature remedy phrase`

`retains the PRD_FEATURE_BLOCKED prefix on every deny reason` PASSES against the unfixed hook. That
is the intended outcome for a case whose purpose is to pin an invariant the fix must not break.

### Pre-existing file, assertions updated by [P1-T9] (3 of 3 failing)

19. `fails closed to the strictest set when the mode is $null`
20. `fails closed to the strictest set for an unrecognized mode string`
21. `fails closed when the work-mode marker line is absent from issue.md`

## [P1-T6] Preserved-Behavior Status by Name

[P1-T6] requires this run to record the pass or fail status of each of its five cases by name. All
five pass against the unfixed hook, which is their purpose: they pin behavior the fix must preserve,
so a fix that relaxed the gate would turn them red.

| `It` name | Status |
| --- | --- |
| `denies full-feature when spec.md is missing` | passed |
| `denies full-bug when spec.md is missing` | passed |
| `denies full-feature when user-story.md is missing and names it` | passed |
| `allows minor-audit when neither prerequisite file is present` | passed |
| `normalizes the legacy full marker to the full-feature prerequisite set` | passed |

## Coverage at the Fail-Before Point

Recorded for continuity only; the coverage gate is applied in Phase 4.

| Metric | Value |
| --- | --- |
| Overall line coverage | 96.14 % (6656 of 6923) |
| Per-file line coverage, `.claude/hooks/enforce-prd-feature-before-planner.ps1` | 90.32 % (84 of 93, 9 missed) |

Both figures are unchanged from the [P0-T5] baseline, as expected: no production line has been
edited, and the new tests exercise the same hook lines the existing tests already reached.

Output Summary: The PoshQC Pester run exited 21, matching its declared ExpectedExitCode of 21, with
21 failed tests out of 3617 total (3587 passed, 9 skipped, 0 errors, 149 suites). All 21 failures are
confined to the two files in this plan's declared write set: 18 in the new companion file
`tests/scripts/claude-hooks/enforce-prd-feature-before-planner.FolderResolution.Tests.ps1` (25 tests,
7 passed) and 3 in `tests/scripts/claude-hooks/enforce-prd-feature-before-planner.Tests.ps1` (47
tests, 44 passed). The 21 failing `It` names are enumerated above. Seven of the 25 new cases pass
against the unfixed hook by design: the folder-alone resolution case, the
PRD_FEATURE_BLOCKED-prefix case, and the five [P1-T6] preserved-behavior cases, each of which pins
behavior the fix must not change. No test outside the two files in scope failed, so no unrelated
regression was introduced. This artifact is the fail-before half of the fail-before / pass-after
pair; the pass-after run is recorded by [P3-T1].
