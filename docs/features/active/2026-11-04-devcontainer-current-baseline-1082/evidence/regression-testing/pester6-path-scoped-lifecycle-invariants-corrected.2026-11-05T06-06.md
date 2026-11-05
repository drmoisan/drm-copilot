Timestamp: 2026-11-05T06-06
Started: 2026-11-05T06:06:37.7907955Z
Command: C:/Program Files/Git/bin/sh.exe C:\Users\DANMOI~1\AppData\Local\Temp/codex-container-baseline/issue-1082/issue-1082-prove-module-lifecycle.sh
EXIT_CODE: 0
Output Summary:

```text
What if: Performing the operation "Remove stale fixture module binding" on target "REPO\.claude\lib\worktree-resolution\EpicScopeResolution.psm1".
Retired module instance: REPO\.claude\lib\worktree-resolution\EpicScopeResolution.psm1
Retired module instance: REPO\.claude\lib\worktree-resolution\WorktreeItemResolution.psm1
Retired module instance: REPO\.claude\lib\worktree-resolution\WorktreeResolution.psm1
Retired module instance: REPO\.claude\lib\worktree-resolution\WorktreeRunRecordPath.psm1
Retired module instance: REPO\.claude\lib\worktree-resolution\WorktreeTargetResolution.psm1
Verified stale-instance reproduction, WhatIf preservation, removal of only the owned stale scope instance, replacement-dependency preservation, coherent receiving import, and coherent-instance no-op.
```

Raw output: SCRATCH/issue-1082-pester6-path-scoped-lifecycle-invariants-corrected.log
