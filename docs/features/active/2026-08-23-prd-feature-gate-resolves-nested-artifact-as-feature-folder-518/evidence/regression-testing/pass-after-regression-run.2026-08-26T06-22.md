# Pass-After Regression Run — [P3-T1]

Timestamp: 2026-08-26T06-22

Task: [P3-T1]
Workspace root: `C:\Users\DanMoisan\repos\drm-copilot\.claude\worktrees\agent-a931fa47c98f755c3`
Tree state: all Phase 1 and Phase 2 edits applied, including the bundled mirror from [P2-T7].

Command:

```text
mcp__drm-copilot__run_poshqc_test  workspace_root="C:\Users\DanMoisan\repos\drm-copilot\.claude\worktrees\agent-a931fa47c98f755c3"
```

EXIT_CODE: 0

MCP result:

```json
{"ok":true,"tool":"run_poshqc_test","workspace_root":"C:\\Users\\DanMoisan\\repos\\drm-copilot\\.claude\\worktrees\\agent-a931fa47c98f755c3","summary":"Ran bundled PoshQC test against 'C:\\Users\\DanMoisan\\repos\\drm-copilot\\.claude\\worktrees\\agent-a931fa47c98f755c3'."}
```

This is the pass-after half of the pair whose fail-before half is
`evidence/regression-testing/fail-before-regression-run.2026-08-26T06-08.md` (EXIT_CODE 21).

## Numeric Test Counts

Read from `artifacts/pester/pester-junit.xml`. `artifacts/` is gitignored in this checkout, so the
XML is not committed and its numeric contents are transcribed here.

| Metric | Fail-before ([P1-T11]) | Pass-after (this run) |
| --- | --- | --- |
| Total tests | 3617 | 3617 |
| Passed | 3587 | **3608** |
| **Failed** | 21 | **0** |
| Errors | 0 | 0 |
| Skipped | 9 | 9 |
| Test suites (files) | 149 | 149 |

Zero failures across all 149 test files. The 21 failures recorded at the fail-before point are all
resolved, and no test outside the two files in scope changed state.

## Per-File Passed Count Against the [P0-T5] Baseline

| Test file | Baseline passed ([P0-T5]) | Post-change passed | Verdict |
| --- | --- | --- | --- |
| `tests/scripts/claude-hooks/enforce-prd-feature-before-planner.Tests.ps1` | 47 | **47** | not lower than baseline |
| `tests/scripts/claude-hooks/enforce-prd-feature-before-planner.FolderResolution.Tests.ps1` | n/a (new file) | 25 | 25 of 25 passing |

The pre-existing file's passed count is **47**, exactly equal to its [P0-T5] baseline of 47 and
therefore not lower than it, which is the condition [P3-T1] states. Its total is also 47, so no `It`
block was added to or removed from that file: [P1-T9] changed three assertions in place and [P1-T10]
added a mock line to seven blocks, and neither task altered the block count.

## All 25 New `It` Names Pass

### Folder resolution by four-segment truncation (6 of 6)

| `It` name | Status |
| --- | --- |
| `resolves the same folder when the prompt cites the feature folder alone` | passed |
| `resolves the same folder when the prompt cites a research artifact path` | passed |
| `resolves the same folder when the prompt cites an evidence artifact path` | passed |
| `resolves the folder from a nested artifact path with no folder citation` | passed |
| `rejects a token that truncates to fewer than four segments` | passed |
| `yields one distinct candidate when one folder is cited at three depths` | passed |

### Deterministic selection among two feature folders (3 of 3)

| `It` name | Status |
| --- | --- |
| `prefers the checkpoint folder when it occurs later in the prompt` | passed |
| `uses the earliest candidate when the checkpoint folder is absent` | passed |
| `uses the earliest candidate when the checkpoint folder is not a candidate` | passed |

### Decision equivalence and the reproduction differential (3 of 3)

| `It` name | Status |
| --- | --- |
| `returns the same decision for all four prompt forms` | passed |
| `returns the same decision for folder-relative and repo-relative research paths` | passed |
| `allows full-bug with spec present and user-story absent citing a nested research artifact` | passed |

The last of these is the reproduction from issue #518: it could not pass before this change.

### Preserved gate behavior (5 of 5)

| `It` name | Status |
| --- | --- |
| `denies full-feature when spec.md is missing` | passed |
| `denies full-bug when spec.md is missing` | passed |
| `denies full-feature when user-story.md is missing and names it` | passed |
| `allows minor-audit when neither prerequisite file is present` | passed |
| `normalizes the legacy full marker to the full-feature prerequisite set` | passed |

These five passed at the fail-before point as well. That is their purpose: they pin denials the fix
must not relax, so a resolution fix that also weakened the gate would have turned them red.

### Indeterminate work-mode marker (6 of 6)

| `It` name | Status |
| --- | --- |
| `denies with the indeterminate-marker reason when the marker line is absent` | passed |
| `denies with the indeterminate-marker reason when issue.md is unreadable` | passed |
| `denies with the indeterminate-marker reason when the marker value is unrecognized` | passed |
| `names the resolved folder and the issue.md path in the indeterminate reason` | passed |
| `omits spec.md and user-story.md from the indeterminate reason` | passed |
| `does not invoke the file-existence probe in the indeterminate branch` | passed |

### Block message (2 of 2)

| `It` name | Status |
| --- | --- |
| `names the resolved folder ahead of the prd-feature remedy phrase` | passed |
| `retains the PRD_FEATURE_BLOCKED prefix on every deny reason` | passed |

## The Three Updated `It` Blocks From [P1-T9] Pass

| `It` name | Status |
| --- | --- |
| `fails closed to the strictest set when the mode is $null` | passed |
| `fails closed to the strictest set for an unrecognized mode string` | passed |
| `fails closed when the work-mode marker line is absent from issue.md` | passed |

## The Seven Repaired `It` Blocks From [P1-T10] Pass

| `It` name | Status |
| --- | --- |
| `allows when both spec.md and user-story.md exist in the target folder (prompt path)` | passed |
| `blocks when spec.md is missing` | passed |
| `blocks when user-story.md is missing` | passed |
| `falls back to orchestrator-state.json when prompt has no folder reference` | passed |
| `prefers the prompt-derived folder over the checkpoint folder` | passed |
| `treats a path ending in .md as a file and uses its parent directory` | passed |
| `accepts backslash separators inside the prompt path` | passed |

`treats a path ending in .md as a file and uses its parent directory` passing is the backward-compat
check `spec.md` calls for at its line 211: truncation reproduces the `.md`-parent result for a file
directly inside the feature folder, so the case passes unchanged even though the branch it was named
after has been deleted.

## Two Prompt Corrections Made During Phase 2, and Their Fail-Before Property

Two of the 25 cases were authored in Phase 1 with a prompt whose feature-folder token was immediately
followed by prose punctuation — a comma in `yields one distinct candidate when one folder is cited at
three depths`, and a period in `returns the same decision for folder-relative and repo-relative
research paths`. The matching regex captures an adjacent comma or period into the token, which is a
separate known limitation that `spec.md` records at its lines 79 and 295 and explicitly leaves
unchanged. Those two prompts were therefore exercising the punctuation limitation rather than the
truncation behavior their names describe, and both prompts were corrected to place a space before the
following punctuation.

The correction does not weaken either assertion, and the fail-before property was re-measured rather
than assumed. The pre-fix resolver was extracted from the Phase 1 commit `22c702cf` and the corrected
prompts were evaluated against it directly:

```text
PREFIX_DEDUPE_RESULT=docs/features/active/2026-08-23-dedupe-1/evidence/baseline
PREFIX_DIFF_FOLDERREL=docs/features/active/2026-08-23-differential-1
PREFIX_DIFF_REPOREL=docs/features/active/2026-08-23-differential-1/research
```

The dedupe case expects `docs/features/active/2026-08-23-dedupe-1`; the pre-fix resolver returns the
`evidence/baseline` subdirectory, so the corrected case still fails against the unfixed hook. The
differential case expects the two prompts to produce the same decision; the pre-fix resolver returns
the feature folder for the folder-relative prompt and the `research` subdirectory for the
repo-relative one, so the two decisions differ and the corrected case still fails against the unfixed
hook. Both corrected cases therefore retain the fail-before property claimed for them.

## Coverage on This Run

| Metric | Baseline ([P0-T5]) | This run |
| --- | --- | --- |
| Overall line coverage | 96.14 % (6656 / 6923) | 96.15 % (6667 / 6934) |
| Per-file, `.claude/hooks/enforce-prd-feature-before-planner.ps1` | 90.32 % (84 / 93, 9 missed) | 91.35 % (95 / 104, 9 missed) |

Both figures rose. The per-file analyzable-line denominator grew from 93 to 104 as the fix added
executable lines, and the missed count stayed at 9, so every added line is covered. The formal
coverage comparison is recorded by [P4-T5].

Output Summary: The PoshQC Pester run exited 0 with zero failures: 3608 passed, 0 failed, 9 skipped,
0 errors, out of 3617 total across 149 test files. All 25 new `It` names pass, all three `It` blocks
updated by [P1-T9] pass, and all seven `It` blocks repaired by [P1-T10] pass; each is listed by name
above with its status. The per-file passed count for
`tests/scripts/claude-hooks/enforce-prd-feature-before-planner.Tests.ps1` is 47, exactly equal to and
therefore not lower than its [P0-T5] baseline of 47, and its total remains 47 so no block was added
or removed. The companion file contributes 25 of 25 passing. Zero failures occurred among the named
cases and zero occurred anywhere in the suite. Two Phase 1 prompts that inadvertently exercised the
out-of-scope trailing-punctuation limitation were corrected during Phase 2, and their fail-before
property was re-measured against the pre-fix resolver extracted from commit 22c702cf rather than
assumed. Overall line coverage is 96.15 percent and per-file coverage for the changed hook is 91.35
percent, both above the 85 percent threshold and both above their baselines.
