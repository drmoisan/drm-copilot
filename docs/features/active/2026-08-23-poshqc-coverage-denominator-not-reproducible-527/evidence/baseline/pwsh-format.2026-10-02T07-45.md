# Baseline Non-Writing Format Check (P0-T6)

Timestamp: 2026-10-02T07-45
Command: CI-evidence deviation DEV-P0-T6 (replaces the local `Invoke-PoshQCFormat -GetFileList ... -WriteFile { }` child). Source: CI run https://github.com/drmoisan/drm-copilot/actions/runs/36978425380, job `poshqc / PowerShell QC` https://github.com/drmoisan/drm-copilot/actions/runs/36978425380/job/110747263219, step running `Invoke-PoshQCFormat -Root "<CI_ROOT>"` followed by `git status --porcelain` and `Write-Error` on any rewrite. Job log saved by the orchestrator to artifacts/ci/run-36978425380/job.log and searched with `git grep --no-index -n -E 'Already formatted: .*(PoshQC[\\/]PoshQC\.Testing\.psm1|PoshQC[\\/]PoshQC\.psm1|settings[\\/]pester\.runsettings\.psd1|PoshQC\.TestingInvokeSummary\.Tests\.ps1|PoshQC\.Comprehensive\.Tests\.ps1)' -- artifacts/ci/run-36978425380/job.log` and `sed -n '202,817p' artifacts/ci/run-36978425380/job.log | grep -c ' Formatted: '`; hash snapshot with `git hash-object <five files>` and `git ls-tree 71f8dcb4 <five files>`.
EXIT_CODE: 0
Output Summary: WOULD_FORMAT=0
- The format step (job.log lines 202-817) printed 607 `Already formatted:` lines and 0 `Formatted:` lines; the step succeeded (its `git status --porcelain` check found no rewrite).
- The orchestrator's count of 609 `Already formatted:` lines covers the whole log; the 2 extra lines (job.log lines 1235 and 1237, `Already formatted: /repo/test.ps1`) are Pester test output from the test step, not repository files. The only `Formatted:` line in the log (line 1236, `/repo/test.ps1`) is also test output.
- No local formatter ran, so no file in this worktree could change; the hash snapshot below equals the blobs of 71f8dcb4 that CI formatted.

## `Already formatted:` lines for the five files (CI root written <CI_ROOT>)

```text
543: Already formatted: <CI_ROOT>\scripts\powershell\PoshQC\PoshQC.Testing.psm1
541: Already formatted: <CI_ROOT>\scripts\powershell\PoshQC\PoshQC.psm1
544: Already formatted: <CI_ROOT>\scripts\powershell\PoshQC\settings\pester.runsettings.psd1
810: Already formatted: <CI_ROOT>\tests\scripts\powershell\PoshQC\PoshQC.TestingInvokeSummary.Tests.ps1
804: Already formatted: <CI_ROOT>\tests\scripts\powershell\PoshQC\PoshQC.Comprehensive.Tests.ps1
```

`Formatted:` lines for the five files: none (WOULD_FORMAT=0).

## Hash snapshot (git hash-object; replaces rule HS, deviation DEV-P0-T6)

| Worktree blob (before = after; no local write) | Blob at 71f8dcb4 | Path |
| --- | --- | --- |
| e8d9a396aae9ed36645239f98ea08b62fd0bee93 | e8d9a396aae9ed36645239f98ea08b62fd0bee93 | scripts/powershell/PoshQC/PoshQC.Testing.psm1 |
| e2db9c8491d8d969c7541034ea26c7b599ca8cf3 | e2db9c8491d8d969c7541034ea26c7b599ca8cf3 | scripts/powershell/PoshQC/PoshQC.psm1 |
| 5300d4b19282a65923623019be370f77793745ad | 5300d4b19282a65923623019be370f77793745ad | scripts/powershell/PoshQC/settings/pester.runsettings.psd1 |
| 596641df7c9c3d2e0516c5ed58e2c60bcd5a614f | 596641df7c9c3d2e0516c5ed58e2c60bcd5a614f | tests/scripts/powershell/PoshQC/PoshQC.TestingInvokeSummary.Tests.ps1 |
| a54ebdffe732df7825e3f25fba523c64776b3973 | a54ebdffe732df7825e3f25fba523c64776b3973 | tests/scripts/powershell/PoshQC/PoshQC.Comprehensive.Tests.ps1 |
