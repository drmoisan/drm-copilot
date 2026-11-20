# Final QC Static — PowerShell, Remediation Cycle 2 (Issue 1025, [P2-T1])

Timestamp: 2026-11-17T06-16
Command: `pwsh -NoProfile -File SCRATCH/issue-1025-static2.ps1 -FolderList 'scripts,tests/scripts'` (through `sh SCRATCH/issue-1025-c2-phasegate.sh c2f3`, from the worktree root)
EXIT_CODE: 0
Output Summary: clean pass on the third loop pass. Format check-only: 939 files checked, 0 would change, `git status --porcelain` identical before and after. PSSA over `scripts` and `tests/scripts`: 935 files, 0 findings (`pssa-baseline-b`: 0), 0 child-process retries. Type check: N/A (PowerShell).

## Steps

| Step | Command | EXIT_CODE | Finding count |
| --- | --- | --- | --- |
| Format (check-only) | `Invoke-PoshQCFormat -Root <worktree> -ScanFolders scripts, tests/scripts -SettingsPath scripts/powershell/PoshQC/settings/pssa.settings.psd1` with a capturing `-WriteFile` seam that writes nothing | 0 | 0 would change of 939; `PorcelainIdentical=True` |
| Lint (PSSA) | `Invoke-ScriptAnalyzer -Path <each of 935 .ps1/.psm1 files> -Settings scripts/powershell/PoshQC/settings/pssa.settings.psd1 -Severity Error, Warning, Information` | 0 | 0 |
| Type check | N/A (PowerShell) | N/A | N/A |

## Loop Restarts (fixed and restarted at [P2-T1])

- Pass 1 (`c2f`, started 2026-11-17T05-59): the in-process PSSA run raised `You cannot have more than one dynamic module in each dynamic assembly in this version of the runtime.` and then stalled at constant CPU. This is an analyzer host fault, not a finding. The stalled processes (all started by this run) were stopped by PID, and the pass was discarded.
- Fix: the scratch static runner (`SCRATCH/issue-1025-static.ps1` revised as `SCRATCH/issue-1025-static2.ps1`) no longer re-imports PSScriptAnalyzer in-process after an error; it re-runs the failing file in a fresh child process and counts each such retry (`ChildRetries`).
- Pass 2 (`c2f2`, started 2026-11-17T06-09): an in-process NullReferenceException on `scripts/ci/CiRequiredGate.psm1` led to a child retry, which stalled. A standalone probe of the same file then completed in 860 ms with 0 findings, so the stall was transient. The pass was stopped by PID and discarded.
- Pass 3 (`c2f3`, started 2026-11-17T06-16): clean, 0 child retries; [P2-T2] and [P2-T3] ran in this same pass.

Acceptance: `git status --porcelain` identical before and after the format step; PSSA reports no finding beyond `pssa-baseline` (0). PASS.
