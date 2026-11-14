# PowerShell Final QC (static), QA loop re-run — [P6-T1]

Timestamp: 2026-11-14T03-55
Command: sh SCRATCH/issue-1156-ps-static.sh (pwsh 7: per file, Invoke-Formatter -ScriptDefinition <content> -Settings scripts/powershell/PoshQC/settings/pssa.settings.psd1 compared with the file content; Invoke-ScriptAnalyzer -Path <file> -Settings scripts/powershell/PoshQC/settings/pssa.settings.psd1, direct run) over the 39 .ps1/.psm1/.psd1 files added or modified since the merge base of origin/main and HEAD, bundle copies included
EXIT_CODE: 0
Output Summary: one pass: 39 files, 0 files with format drift, 0 analyzer findings. The formatter is compared, not written, so no file changed (git status --porcelain empty before and after).

## Why the loop was re-run

[P6-T8] found the policy-audit row "New Code Coverage ≥90%" would fail per file, and tests were added (`evidence/other/task-check.P6-T8.2026-11-14T03-53.md`). Before the re-run, `origin/main` had advanced by one merged PR (#1174, issue #1160), which was merged into the branch without conflicts (merge commit "Merge origin/main into feature/regenerate-after-integration-merge-1156 (#1156)"). After the merge, the six execution-environment brief copies hash identically, and both `pack-manifests/core.json` files parse as JSON. Per [P6-T8], the QA loop restarts at [P6-T1].

| Step | Command | Exit | Findings |
|---|---|---|---|
| format (compare) | Invoke-Formatter vs file text, 39 files | 0 | 0 files with drift |
| analyze | Invoke-ScriptAnalyzer, 39 files | 0 | 0 |
| type check | not applicable for PowerShell | - | - |
