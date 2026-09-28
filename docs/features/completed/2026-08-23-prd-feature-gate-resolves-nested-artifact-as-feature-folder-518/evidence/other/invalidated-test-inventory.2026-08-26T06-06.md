# Invalidated Pre-Existing Test Inventory — [P1-T10]

Timestamp: 2026-08-26T06-06

Task: [P1-T10]
Workspace root: `C:\Users\DanMoisan\repos\drm-copilot\.claude\worktrees\agent-a931fa47c98f755c3`
File repaired: `tests/scripts/claude-hooks/enforce-prd-feature-before-planner.Tests.ps1`

Command:

```text
mcp__drm-copilot__run_poshqc_test  workspace_root="C:\Users\DanMoisan\repos\drm-copilot\.claude\worktrees\agent-a931fa47c98f755c3"
```

EXIT_CODE: 21

The MCP runner reports the total failing-test count as its exit code. 21 is the expected count at
this point in the plan: 18 of the 25 new companion-file cases fail against the unfixed hook by
design, plus the 3 assertions intentionally updated by [P1-T9]. None of the 21 is one of the seven
blocks this task repairs.

## Why These Seven Blocks Were Invalidated

Each of the seven mocks the file-existence seam `Get-PrdFeatureFileExistence` but not the
issue-content seam `Get-PrdFeatureIssueContent`, and each drives a prompt naming a feature folder
that does not exist on disk. The real `Get-PrdFeatureIssueContent` therefore returns a null value,
`Resolve-PrdFeatureWorkMode` returns a null value, and every one of the seven reaches the
indeterminate-work-mode path today. They pass today only because the current fail-closed set
`{spec.md, user-story.md}` is satisfied by the `$true` existence mock, or is reported as missing in
the way the case happens to assert.

Once [P2-T4] gives the indeterminate mode its own decision path — which denies without running the
required-file probe at all — none of the seven can reach the prerequisite logic its assertions were
written to exercise. The repair is to supply the work-mode marker each case was written against, so
the case reaches the determined-mode path.

## The Seven Repaired `It` Blocks and the Marker Added to Each

Every one of the seven keeps its existing `It` name and its existing assertion intent. The added
`Get-PrdFeatureIssueContent` mock is the only change to each block.

| `It` name | Pre-change lines | Work-mode marker added |
| --- | --- | --- |
| `allows when both spec.md and user-story.md exist in the target folder (prompt path)` | 48-55 | `- Work Mode: full-feature` |
| `blocks when spec.md is missing` | 57-70 | `- Work Mode: full-feature` |
| `blocks when user-story.md is missing` | 72-84 | `- Work Mode: full-feature` |
| `falls back to orchestrator-state.json when prompt has no folder reference` | 98-106 | `- Work Mode: full-feature` |
| `prefers the prompt-derived folder over the checkpoint folder` | 108-123 | `- Work Mode: full-feature` |
| `treats a path ending in .md as a file and uses its parent directory` | 125-142 | `- Work Mode: full-feature` |
| `accepts backslash separators inside the prompt path` | 144-151 | `- Work Mode: full-feature` |

The exact mock statement added to each block is:

```powershell
Mock -CommandName Get-PrdFeatureIssueContent -MockWith { "- Work Mode: full-feature`n## Overview" }
```

## Why `full-feature` for All Seven

`full-feature` is the mode whose prerequisite set is the `spec.md` plus `user-story.md` pair that the
seven were originally written against, so it is the mode that preserves every existing assertion
without altering its intent. Two of the seven require that mode specifically rather than merely
tolerating it:

- `blocks when user-story.md is missing` asserts the reason text matches `user-story\.md`. Only
  `full-feature` puts `user-story.md` in the required set, so only `full-feature` can produce that
  file name in the missing list.
- `treats a path ending in .md as a file and uses its parent directory` asserts that BOTH
  `<folder>/spec.md` and `<folder>/user-story.md` were probed. Only `full-feature` probes both paths.

The remaining five are satisfied by `full-feature` as well, so a single uniform marker is used across
all seven rather than a per-case choice.

## Verified Status After the Repair

Extracted from `artifacts/pester/pester-junit.xml` written by the MCP run recorded above.

| `It` name | Status |
| --- | --- |
| `allows when both spec.md and user-story.md exist in the target folder (prompt path)` | passed |
| `blocks when spec.md is missing` | passed |
| `blocks when user-story.md is missing` | passed |
| `falls back to orchestrator-state.json when prompt has no folder reference` | passed |
| `prefers the prompt-derived folder over the checkpoint folder` | passed |
| `treats a path ending in .md as a file and uses its parent directory` | passed |
| `accepts backslash separators inside the prompt path` | passed |

Per-suite totals from the same run:

| Test file | Tests | Passed | Failed | Skipped |
| --- | --- | --- | --- | --- |
| `tests/scripts/claude-hooks/enforce-prd-feature-before-planner.Tests.ps1` | 47 | 44 | 3 | 0 |
| `tests/scripts/claude-hooks/enforce-prd-feature-before-planner.FolderResolution.Tests.ps1` | 25 | 7 | 18 | 0 |

The 47-test total for the pre-existing file is unchanged from the [P0-T5] baseline, confirming that
this task added and removed no `It` block. Its 3 failures are exactly the three assertions [P1-T9]
updated, none of which is among the seven repaired here.

Output Summary: All seven pre-existing `It` blocks that the [P2-T4] indeterminate-marker branch would
otherwise invalidate were repaired in `tests/scripts/claude-hooks/enforce-prd-feature-before-planner.Tests.ps1`
by adding a `Get-PrdFeatureIssueContent` mock supplying the `- Work Mode: full-feature` marker to
each. `full-feature` was chosen for all seven because it is the mode whose prerequisite set is the
`spec.md` plus `user-story.md` pair the cases were written against; two of the seven
(`blocks when user-story.md is missing` and
`treats a path ending in .md as a file and uses its parent directory`) require that mode specifically.
No `It` name and no assertion was changed. All seven names are present in the run output and all
seven report `passed`. The file's total remains 47 tests, matching the [P0-T5] baseline.
