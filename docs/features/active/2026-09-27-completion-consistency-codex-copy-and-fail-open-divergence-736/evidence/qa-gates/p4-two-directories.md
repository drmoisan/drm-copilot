# Ten test files from two working directories ([P4-T2])

Timestamp: 2026-10-08T18-23
Command: pwsh -NoProfile -Command '$root = (Get-Location).Path; $files = @(<ten test paths>) | ForEach-Object { Join-Path $root $_ }; "LIVE_CHECKPOINT_AT_ROOT=..."; foreach ($wd in @(".", "tests/fixtures/worktree-resolution")) { Set-Location (Join-Path $root $wd); $tag = "CWD=$wd"; $r = Invoke-Pester -Path $files -PassThru -Output None; "$tag PASSED=... FAILED=... FAILED_BLOCKS=... FAILED_CONTAINERS=..." }; Set-Location $root'
EXIT_CODE: 0
Output Summary: two CWD lines identical except for the directory label, each FAILED=0 FAILED_BLOCKS=0 FAILED_CONTAINERS=0 and PASSED=240. Arithmetic: 37 (P3-T1) + 13 (P3-T2) + 7 (P3-T3) + 59 (P3-T4, two files) + 16 (P3-T5) + 37 (P3-T6) + 13 (P3-T7) + 7 (P3-T8) + 51 (P3-T9, transport) = 240. This is the re-run after the [P5-T7] remediation added one EditSemantics row to each surface; the first run before that remediation printed PASSED=238 on both lines.

LIVE_CHECKPOINT_AT_ROOT=True
CWD=. PASSED=240 FAILED=0 FAILED_BLOCKS=0 FAILED_CONTAINERS=0
CWD=tests/fixtures/worktree-resolution PASSED=240 FAILED=0 FAILED_BLOCKS=0 FAILED_CONTAINERS=0
