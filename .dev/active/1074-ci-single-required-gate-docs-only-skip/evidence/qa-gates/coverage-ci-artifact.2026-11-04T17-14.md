# CI Coverage Artifact Reading (Issue #1074)

Timestamp: 2026-11-04T17-14
Command: gh run download 41871788989 -n poshqc-test-results -D SCRATCH/dl-poshqc ; per-file LINE counters read from SCRATCH/dl-poshqc/powershell-coverage.xml (package scripts/ci)
EXIT_CODE: 0
Output Summary:
- Source run: ci.yml pull_request run 41871788989 on head 23dd72202a594c0e829072b7c6aee72b47be8140 (proof C, full run, `poshqc / PowerShell QC` success). The artifact `poshqc-test-results` holds the coverage merged across shards 1 to 3 on windows-latest.
- scripts/ci/CiRequiredGate.psm1: LINE covered 90, missed 0 (100.0%).
- scripts/ci/Invoke-CiRequiredGate.ps1: LINE covered 27, missed 3 (90.0%); the three missed lines are the run-guard statements executed only when the script runs as an entry point.
- Repository PowerShell total: LINE covered 22572, missed 1484 (93.8%).
- Both new production files meet the 85% line threshold. Commits after 23dd72202 change only files under the active feature folder, so the measured production files are identical at the branch head.
- This reading closes review finding F2 and spec AC-28. Python coverage (finding F3): the `quality-checks7 / Code Quality & Tests (3.13)` job, which runs the coverage-threshold check, concluded success in the same run; the branch changes no Python production file.
