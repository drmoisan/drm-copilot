# Phase 0 Pester Coverage Baseline — Issue #673 ([P0-T7])

Timestamp: 2026-09-17T10-33

Command: sh "C:/Users/DanMoisan/AppData/Local/Temp/claude/C--Users-DanMoisan-repos-drm-copilot-wt-2026-09-13T08-30/edea1a9d-6671-4ea6-8e13-6405d6284a83/scratchpad/f673-exec/p0t7.sh"
(route a-prime per `execution-route.md`; working directory set to the workspace root, then
`"/c/Program Files/PowerShell/7/pwsh.exe" -NoProfile -File .../f673-exec/p0t7.ps1`). The PowerShell body:
```
Set-Location -LiteralPath 'C:/Users/DanMoisan/repos/drm-copilot/.claude/worktrees/agent-a4da10d770a658efe'
Import-Module ./scripts/powershell/PoshQC/PoshQC.psd1 -Force
Invoke-PoshQCTest -Root 'C:/Users/DanMoisan/repos/drm-copilot/.claude/worktrees/agent-a4da10d770a658efe' -SettingsPath 'scripts/powershell/PoshQC/settings/pester.runsettings.psd1'
```

EXIT_CODE: 2 (the runsettings sets `Run.Exit = $true`, so the child exits with the failed-test count; two
pre-existing failures are recorded below)

## Resolved settings file

- Resolved path: `C:\Users\DanMoisan\repos\drm-copilot\.claude\worktrees\agent-a4da10d770a658efe\scripts\powershell\PoshQC\settings\pester.runsettings.psd1`
- Resolved settings file line count: **302** (`(Get-Content -LiteralPath ...).Count`)

The plan's [P0-T7] acceptance condition requires this count to be 293. The measured value is 302, and the
difference is explained rather than waived:

- At the plan's own authoring commit `203011a5` the same file was 293 lines
  (`git show 203011a5:scripts/powershell/PoshQC/settings/pester.runsettings.psd1 | awk 'END{print NR}'` -> 293).
- Between that commit and the base commit `d039e89b`, `git diff --stat 203011a5 d039e89b -- scripts/powershell/PoshQC/settings/pester.runsettings.psd1`
  reports `1 file changed, 9 insertions(+)` and no deletions. The nine added lines are the F3 (#670) entry
  `.claude/hooks/enforce-epic-merge-gate-authorization.ps1` and the F1 (#669) entries
  `.claude/lib/worktree-resolution/WorktreeResolution.psm1` and
  `.claude/lib/worktree-resolution/WorktreeTargetResolution.psm1`, with their comments.
- The guard's purpose — distinguishing the repository copy from the stale 59-line installed copy — is
  satisfied: 302 is the repository copy, and all four in-scope hooks appear in its coverage path, as the
  per-file coverage figures below demonstrate.

Because the literal value 293 is not observed, [P0-T7] is left unchecked in the plan and the discrepancy is
reported to the caller.

Output Summary:
- Test counts, read from `artifacts/pester/pester-junit.xml` (last write 2026-09-17T10:37:27, at or after this
  artifact's Timestamp), root `testsuites` element: total **4733**, failed **2**, skipped (root `disabled`
  attribute, which is `NotRunCount + SkippedCount`) **9**, passed (derived as `tests` minus `failures` minus
  `disabled`) **4722**. `testsuite` element count: 198.
- Coverage, read from `artifacts/pester/powershell-coverage.xml` (last write 2026-09-17T10:36:32), each
  percentage derived as `covered / (covered + missed) * 100` from the `<counter type="LINE">` element:
  - Overall (report root counter): covered 9333, missed 424 -> **95.65%**
  - `.claude/hooks/enforce-pr-author-skill.ps1`: covered 46, missed 4 -> **92.00%**
  - `.claude/hooks/enforce-pr-author-skill-helpers.ps1`: covered 72, missed 3 -> **96.00%**
  - `.claude/hooks/enforce-pr-author-skill.epic-base-branch.ps1`: covered 24, missed 2 -> **92.31%**
  - `.claude/hooks/enforce-model-routing-receipt.ps1`: covered 38, missed 3 -> **92.68%**
  The four `sourcefile` elements were matched by base filename inside the single `package` element whose
  `name` attribute ends with `.claude/hooks`
  (`C:/Users/DanMoisan/repos/drm-copilot/.claude/worktrees/agent-a4da10d770a658efe/.claude/hooks`).

## Pre-existing failures at baseline (2)

1. `tests/scripts/claude-hooks/enforce-pr-author-skill.Tests.ps1` — `testcase`
   `enforce-pr-author-skill.ps1.allowed commands.allows gh pr create --body-file artifacts/pr_body_12.md when context exists`,
   status `Failed`. This failure is itself an observation of the defect class under repair: the live checkpoint
   at the workspace root (`artifacts/orchestration/orchestrator-state.json`) carries `epic_mode: true`, and the
   test's command carries no `--base`, so check 6 (`Test-EpicBaseBranchOverride` via the cwd-relative binding at
   `enforce-pr-author-skill.epic-base-branch.ps1:35`) reads that ambient checkpoint and denies.
2. `tests/scripts/codex-hooks/codex-pretooluse-integration.Tests.ps1` — `testcase`
   `Every registered Codex PreToolUse handler accepts every tool name its matcher admits.allows every registered
   handler for every tool name its own matcher admits`, status `Failed`. Out of F5's scope; recorded as
   pre-existing baseline state.

Both failures are present before any file in this feature's change set is edited.
