# Batch-Budget Resets (constraint C9) — issue #643

Every C9 batch-budget reset performed during execution of
`plan.2026-09-07T08-13.md` is appended to this single artifact, one section per
reset, in execution order.

---

## Reset 1 — PowerShell, scheduled at [P3-T8]

Timestamp: 2026-09-07T16-05

Command: `pwsh -NoProfile -Command 'Get-ChildItem -Path .claude/state -Filter "powershell-batch-budget.*.json" -ErrorAction SilentlyContinue | ForEach-Object { Write-Output ("PRE-RESET " + $_.FullName + " " + (Get-Content -Raw $_.FullName)); Remove-Item -LiteralPath $_.FullName -Force }'`

EXIT_CODE: 0

Output Summary:

One state file was enumerated and removed.

`PRE-RESET C:\Users\DanMoisan\repos\drm-copilot-wt\2026-09-07T08-09\.claude\state\powershell-batch-budget.8af424ea-e8c4-4c97-b2f3-a930ca145a35.json`

Pre-reset `prodFiles` (3 of 3, at cap):

1. `C:/Users/DanMoisan/repos/drm-copilot-wt/2026-09-07T08-09/.claude/lib/blast-radius/BlastRadiusConflict.psm1`
2. `C:/Users/DanMoisan/repos/drm-copilot-wt/2026-09-07T08-09/.claude/lib/blast-radius/BlastRadius.psm1`
3. `C:/Users/DanMoisan/repos/drm-copilot-wt/2026-09-07T08-09/scripts/powershell/PoshQC/settings/pester.runsettings.psd1`

Pre-reset `testFiles` (2 of 3):

1. `C:/Users/DanMoisan/repos/drm-copilot-wt/2026-09-07T08-09/tests/scripts/claude-lib/blast-radius/BlastRadius.KeyPartition.Tests.ps1`
2. `C:/Users/DanMoisan/repos/drm-copilot-wt/2026-09-07T08-09/tests/scripts/claude-lib/blast-radius/BlastRadiusConflict.Tests.ps1`

Pre-reset `prodCap`: 3. Pre-reset `testCap`: 3.

DEVIATION FROM STATED ACCEPTANCE: [P3-T8] states that the pre-reset `testFiles`
array contains three paths, naming `BlastRadius.TruthTable.Tests.ps1` as the
third. The observed array holds two paths and does not name
`BlastRadius.TruthTable.Tests.ps1`. The state file is keyed on the session id
`8af424ea-e8c4-4c97-b2f3-a930ca145a35`, so the earlier `TruthTable` edit was
recorded against a different session id and no longer occupies a slot in this
session's file. The reset was nonetheless required at this point: the
`prodFiles` array was already at its cap of 3, so the next distinct production
PowerShell file would have been denied, and the `testFiles` array had one slot
left, which the [P3-T8] edit to `BlastRadius.Conflict.Tests.ps1` would have
consumed as the third entry.

Post-reset observation command: `pwsh -NoProfile -Command "(Get-ChildItem -Path .claude/state -Filter 'powershell-batch-budget.*.json' -ErrorAction SilentlyContinue | Measure-Object).Count"`

Post-reset state-file count: `0`

Post-reset command exit code: 0 (recorded; C9 attaches no acceptance condition
to this exit code because `Get-ChildItem` on a missing directory returns a
non-zero code through `pwsh -Command` even when the enumeration is empty).

---

## Reset 2 — PowerShell, before [P5-T10]

Timestamp: 2026-09-07T17-20

Command: `pwsh -NoProfile -Command 'Get-ChildItem -Path .claude/state -Filter "powershell-batch-budget.*.json" -ErrorAction SilentlyContinue | ForEach-Object { Write-Output ("PRE-RESET " + $_.FullName + " " + (Get-Content -Raw $_.FullName)); Remove-Item -LiteralPath $_.FullName -Force }'`

EXIT_CODE: 0

Output Summary: One state file was enumerated and removed. Both lists were at
their cap of 3 before the reset, so the next distinct production PowerShell file
(the `pester.runsettings.psd1` edit of [P5-T12]) and the next distinct test file
(`Resolve-MergeableConflict.Tests.ps1`, created by [P5-T10]) would both have been
denied. The observed arrays match the [P5-T10] prediction.

`PRE-RESET C:\Users\DanMoisan\repos\drm-copilot-wt\2026-09-07T08-09\.claude\state\powershell-batch-budget.8af424ea-e8c4-4c97-b2f3-a930ca145a35.json`

Pre-reset `prodFiles` (3 of 3):

1. `C:/Users/DanMoisan/repos/drm-copilot-wt/2026-09-07T08-09/.claude/lib/project-file-merge/ProjectFileMergeGrammar.psm1`
2. `C:/Users/DanMoisan/repos/drm-copilot-wt/2026-09-07T08-09/.claude/lib/project-file-merge/ProjectFileMerge.psm1`
3. `C:/Users/DanMoisan/repos/drm-copilot-wt/2026-09-07T08-09/.claude/lib/project-file-merge/Resolve-MergeableConflict.ps1`

Pre-reset `testFiles` (3 of 3):

1. `C:/Users/DanMoisan/repos/drm-copilot-wt/2026-09-07T08-09/tests/scripts/claude-lib/blast-radius/BlastRadius.Conflict.Tests.ps1`
2. `C:/Users/DanMoisan/repos/drm-copilot-wt/2026-09-07T08-09/tests/scripts/claude-lib/project-file-merge/ProjectFileMergeGrammar.Tests.ps1`
3. `C:/Users/DanMoisan/repos/drm-copilot-wt/2026-09-07T08-09/tests/scripts/claude-lib/project-file-merge/ProjectFileMerge.Tests.ps1`

Pre-reset `prodCap` and `testCap`: 3 and 3.

Post-reset observation command: `pwsh -NoProfile -Command "(Get-ChildItem -Path .claude/state -Filter 'powershell-batch-budget.*.json' -ErrorAction SilentlyContinue | Measure-Object).Count"`

Post-reset state-file count: `0`

Post-reset command exit code: 0 (recorded; C9 attaches no acceptance condition
to this exit code).

No deviation from the [P5-T10] stated acceptance: the pre-reset `prodFiles` and
`testFiles` arrays and the post-reset count of `0` are all as the task states.

---

## Reset 3 — Python runtime, scheduled reset point [P7-T2]

Timestamp: 2026-09-07T18-05

Command: `pwsh -NoProfile -Command 'Get-ChildItem -Path .claude/state -Filter "python-batch-budget.*.json" -ErrorAction SilentlyContinue | ForEach-Object { Write-Output ("PRE-RESET " + $_.FullName + " " + (Get-Content -Raw $_.FullName)); Remove-Item -LiteralPath $_.FullName -Force }'`

EXIT_CODE: 0

## Output Summary

Exactly one state file was enumerated:

`PRE-RESET C:\Users\DanMoisan\repos\drm-copilot-wt\2026-09-07T08-09\.claude\state\python-batch-budget.8af424ea-e8c4-4c97-b2f3-a930ca145a35.json`

Pre-reset `prodFiles` (1 of 3), recorded verbatim:

1. `C:/Users/DanMoisan/repos/drm-copilot-wt/2026-09-07T08-09/scripts/dev_tools/_blast_radius_mergeable.py`

Pre-reset `testFiles` (2 of 3), recorded verbatim:

1. `C:/Users/DanMoisan/repos/drm-copilot-wt/2026-09-07T08-09/tests/scripts/dev_tools/blast_radius_parity_test_support.py`
2. `C:/Users/DanMoisan/repos/drm-copilot-wt/2026-09-07T08-09/tests/scripts/dev_tools/test_blast_radius_mergeable_paths.py`

Pre-reset `prodCap` and `testCap`: 3 and 3.

Post-reset observation command: `pwsh -NoProfile -Command "(Get-ChildItem -Path .claude/state -Filter 'python-batch-budget.*.json' -ErrorAction SilentlyContinue | Measure-Object).Count"`

Post-reset state-file count: `0`

Post-reset command exit code: 0 (recorded; C9 attaches no acceptance condition
to this exit code).

## Deviation from the [P7-T2] stated pre-reset arrays

The task predicted a `testFiles` array of three paths, the third being
`tests/scripts/dev_tools/test_parallel_drift_detection_conflicts.py`. The observed array carries two
paths and does not carry that one. The cause is mechanical rather than a missing edit: the hooks
count a distinct path only when the Write or Edit tool touches it, and the Phase 2 case added to
`test_parallel_drift_detection_conflicts.py` was applied through a Bash-driven in-place edit, which
the `Write|Edit` PreToolUse matcher does not observe. The file itself carries the added case; only
its budget slot was never consumed.

Consequently no list was at its cap at this point (`prodFiles` 1 of 3, `testFiles` 2 of 3). The reset
was run regardless, exactly as the task schedules it, so that the subsequent Python test-module
creations of Phase 7 begin from an empty budget. The observed arrays above are the record of what was
actually enumerated.
