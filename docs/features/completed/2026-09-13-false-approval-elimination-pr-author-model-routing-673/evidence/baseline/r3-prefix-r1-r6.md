# AC-18 Pre-Fix Record: R1 and R6 Observed Passing Against the Unmodified Hooks (issue #673)

Timestamp: 2026-09-19T18-23

Command: `pwsh -NoProfile -File <SCRATCHPAD>/r3-test-scoped.ps1` (route `a`) with the scan-folder list supplied as `tests/scripts/claude-hooks`, running `Invoke-PoshQCTest -Root $root -ScanFolders tests/scripts/claude-hooks -SettingsPath scripts/powershell/PoshQC/settings/pester.runsettings.psd1`. This is the same command and the same run `[P4-T5]` records; this artifact quotes four of its testcase entries.

EXIT_CODE: 27

The run's non-zero exit is the expected-failure outcome of `[P4-T5]` and is unrelated to the four entries below, each of which passed.

## What AC-18 requires

A named Pester test covering matrix rows R1 and R6 — cwd equal to the item worktree, or the target resolved to the item worktree, with the own checkpoint present and satisfactory — must assert `allow` and be **observed passing against the unmodified hooks before the fix**, with that pre-fix run archived under `evidence/baseline/`. This artifact is that archive.

## The four quoted testcase entries

| Testsuite | Testcase | Status |
| --- | --- | --- |
| `enforce-pr-author-skill.WorktreeResolution.Tests.ps1` | `pr-author R1 allows when the resolved own checkpoint is ready and the working directory is the sibling session root` | Passed |
| `enforce-pr-author-skill.WorktreeResolution.Tests.ps1` | `pr-author R6 allows when the working directory is the item worktree and its own checkpoint is ready` | Passed |
| `enforce-model-routing-receipt.WorktreeResolution.Tests.ps1` | `model-routing R1 allows when the resolved own checkpoint records the receipt` | Passed |
| `enforce-model-routing-receipt.WorktreeResolution.Tests.ps1` | `model-routing R6 allows when the working directory is the item worktree and its own receipt is present` | Passed |

Four Passed entries, two per gate family.

## Why these four pass before the fix, stated rather than assumed

Each row describes a topology in which the pre-change reading and the post-change reading select the **same** checkpoint, so the row is a regression guard rather than a new behaviour:

- Both R6 rows put the working directory and the resolved target in the same worktree. The pre-change gates read a process-directory-relative path, which is that worktree's own checkpoint; the post-change gates compose an absolute path under the resolved root, which is the same file.
- The pr-author R1 row exercises an `OtherWorktree` result through the hook's resolution seam. #687 already composes the resolved worktree's checkpoint path for that state, so this row guards behaviour that is on `main` today.
- The model-routing R1 row places the receipt in both the session root and the resolved target, so the two readings agree on the verdict even though they read different files.

That is the point of AC-18: a change that moved these to deny, or that made them pass only by accident of the process directory, would be a regression in the standalone and epic topologies the spec requires to behave exactly as they do now. `[P7-T6]` and `[P11-T4]` re-observe all four after the fix.

Output Summary: Four Passed testcase entries are archived, covering matrix rows R1 and R6 for both gate families, observed against the unmodified hooks. The mechanism that makes each pass before the fix is recorded, so a later reader can distinguish a genuine regression guard from a row that happened to pass.
