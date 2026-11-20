# PowerShell Static Baseline — Issue #1030 ([P0-T2])

Scope folders: `.codex/hooks`, `scripts/harness`, `tests/scripts/codex-hooks`, `tests/scripts/harness`, `tests/scripts/claude-runtime`, `tests/scripts/claude-hooks` (549 `.ps1`/`.psm1`/`.psd1` files).
Runner: `sh SCRATCH/issue-1030-static-base.sh`, which runs `pwsh -NoProfile -File SCRATCH/issue-1030-static.ps1 -Label baseline` against the worktree root with the branch-current `scripts/powershell/PoshQC/PoshQC.psd1`.

## Step 1 — Format check (non-writing)

Timestamp: 2026-11-18T07-57
Command: `Invoke-PoshQCFormat -Root <worktree> -ScanFolders <scope folders> -WriteFile { param($Path, $Content) } -Logger <collector>`, with the SHA256 list of every scanned file taken before and after the run
EXIT_CODE: 0
Output Summary:
- 549 files; `Formatted:` lines 0 (drift count 0); `Already formatted:` lines 549.
- Hash-list digest before `9596325FAE06C55DA4CF08FD0B9FC768DA786320479BB4676D642EC3E5475453`, after the same value; identical (no file rewritten).

## Step 2 — PSScriptAnalyzer

Timestamp: 2026-11-18T07-58
Command: `Invoke-ScriptAnalyzer -Path <each scanned file> -Settings scripts/powershell/PoshQC/settings/pssa.settings.psd1`
EXIT_CODE: 0
Output Summary:
- Findings by severity: Error 0, Warning 0, Information 0, ParseError 0 (total 0).

## Step 3 — Leak scan

Timestamp: 2026-11-18T07-59
Command: `Invoke-PoshQCLeakScan -Root <worktree>`
EXIT_CODE: 0
Output Summary:
- `Leak scan: 891 files, 79 findings, 77 exempt, 2 allowlisted, 0 failures.`
- The run printed the PoshQC warning that the `config/poshqc-scan.json` folder `tests/powershell` does not exist and is skipped (pre-existing configuration state).
