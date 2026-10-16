# r2 full Pester baseline with coverage (P0-T18)

Timestamp: 2026-10-16T15-56
Command: sh "SCRATCH/issue-953-r2-p0-t18.sh" (FULL_RUN(baseline) task text verbatim: New-Item -ItemType Directory -Force -Path artifacts/pester | Out-Null; $start = [datetime]::UtcNow; pwsh -NoProfile -Command "Import-Module ./scripts/powershell/PoshQC/PoshQC.psd1 -Force; Invoke-PoshQCTest -Root (Get-Location).Path" *> (Join-Path $S 'issue-953-r2-baseline-poshqc.log'); ...; Copy-Item to SCRATCH/issue-953-r2-baseline-coverage.xml and SCRATCH/issue-953-r2-baseline-junit.xml; exit $exit), then sh "SCRATCH/issue-953-r2-p0-t18-2.sh" (validity checks, JRP, CRP)
EXIT_CODE: 0
Output Summary:
  FULL_RUN output: EXIT_CODE=0 SECONDS=1008 START_UTC=2026-10-16T15:38:48.9689685Z
  Validity: (a) coverage and JUnit LastWriteTimeUtc later than START_UTC (True, True); (b) "Code coverage population: source=config" lines = 1; (c) no -ScanFolders and no -SettingsPath argument. FULL_RUN valid.
  JRP: JUNIT_TESTS=10772 JUNIT_FAILURES=0 JUNIT_ERRORS=0; FULL_RUN wall seconds 1008.
  CRP: LINE_COVERED=17091 LINE_MISSED=1472 LINE_TOTAL=18563 LINE_PERCENT=92.07 SOURCEFILE_COUNT=208; one aggregate LINE counter; one anchor package; zero prefix or duplicate problems; per-file sums match the aggregate; threshold (>= 85%) PASS.
  MOD_KEYS per file:
    scripts/powershell/poshqc/poshqc.shard.psm1 covered=49 missed=0
    scripts/powershell/poshqc/poshqc.coveragemerge.psm1 covered=70 missed=0
    scripts/powershell/poshqc/poshqc.testing.psm1 covered=193 missed=14
  L('scripts/powershell/poshqc/poshqc.testing.psm1', 174) = ci=0 mi=1 (the default WriteShardFileList seam body is not executed before this cycle; CR-12).

R2_BASELINE_JUNIT_TESTS: 10772
