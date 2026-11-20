# Baseline Analyzer Check (P0-T7)

Timestamp: 2026-10-02T07-45
Command: CI-evidence deviation DEV-P0-T7 (replaces the local `Invoke-PoshQCAnalyze -GetFileList { ... }` child over four files). Source: CI run https://github.com/drmoisan/drm-copilot/actions/runs/36978425380, job `poshqc / PowerShell QC` https://github.com/drmoisan/drm-copilot/actions/runs/36978425380/job/110747263219, step running `Invoke-PoshQCAnalyze -Root "<CI_ROOT>"` over the whole repository (a superset of the four files). Job log searched with `git grep --no-index -n 'PSScriptAnalyzer passed' -- artifacts/ci/run-36978425380/job.log`.
EXIT_CODE: 0
Output Summary: PSScriptAnalyzer passed: no findings under <CI_ROOT>
- job.log line 823, emitted by the Analyze step (job.log lines 818-823). `Invoke-PoshQCAnalyze` prints this literal only on success and throws `PSScriptAnalyzer reported <n> issue(s).` otherwise.
- The analyzed tree is 71f8dcb4; the four files (scripts/powershell/PoshQC/PoshQC.Testing.psm1, scripts/powershell/PoshQC/PoshQC.psm1, tests/scripts/powershell/PoshQC/PoshQC.TestingInvokeSummary.Tests.ps1, tests/scripts/powershell/PoshQC/PoshQC.Comprehensive.Tests.ps1) have identical blobs on the branch (see `evidence/baseline/pwsh-format.2026-10-02T07-45.md`).
- Two further `PSScriptAnalyzer passed: no findings under /repo` lines (job.log 1238, 1239) are Pester test output, not the Analyze step.
- Acceptance: the literal `PSScriptAnalyzer passed: no findings under` is recorded. Met.
