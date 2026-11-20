Timestamp: 2026-10-17T17:35:12.076324+00:00
Command: Import-Module ./scripts/powershell/PoshQC/PoshQC.psd1 -Force; Invoke-PoshQCFormat -Root .; if ((git diff --name-only -- "*.ps1" "*.psm1" "*.psd1")) { exit 1 }
EXIT_CODE: 0
Output Summary:

Already formatted: .\tests\scripts\dev-tools\tree.Tests.ps1
Already formatted: .\tests\scripts\dev-tools\verify-host.Tests.ps1
Already formatted: .\tests\scripts\host-tools.manifest.Tests.ps1
Already formatted: .\tests\scripts\powershell\PoshQC\Get-PoshQCFileList.Excludes.Tests.ps1
Already formatted: .\tests\scripts\powershell\PoshQC\PoshQC.Comprehensive.Tests.ps1
Already formatted: .\tests\scripts\powershell\PoshQC\PoshQC.Coverage.Tests.ps1
Already formatted: .\tests\scripts\powershell\PoshQC\PoshQC.CoverageConfig.Tests.ps1
Already formatted: .\tests\scripts\powershell\PoshQC\PoshQC.CoverageMerge.Tests.ps1
Already formatted: .\tests\scripts\powershell\PoshQC\PoshQC.EntryPoints.Tests.ps1
Already formatted: .\tests\scripts\powershell\PoshQC\PoshQC.ModuleCoverage.Tests.ps1
Already formatted: .\tests\scripts\powershell\PoshQC\PoshQC.RunSettings.Tests.ps1
Already formatted: .\tests\scripts\powershell\PoshQC\PoshQC.ScanConfig.Tests.ps1
Already formatted: .\tests\scripts\powershell\PoshQC\PoshQC.ScanFolders.Tests.ps1
Already formatted: .\tests\scripts\powershell\PoshQC\PoshQC.Shard.Tests.ps1
Already formatted: .\tests\scripts\powershell\PoshQC\PoshQC.TestingCommands.Tests.ps1
Already formatted: .\tests\scripts\powershell\PoshQC\PoshQC.TestingCoveragePruning.Tests.ps1
Already formatted: .\tests\scripts\powershell\PoshQC\PoshQC.TestingInvokeConfigPaths.Tests.ps1
Already formatted: .\tests\scripts\powershell\PoshQC\PoshQC.TestingInvokeSummary.Tests.ps1
Already formatted: .\tests\scripts\powershell\PoshQC\PoshQC.TestingSeamDefaults.Tests.ps1
Already formatted: .\tests\scripts\powershell\PoshQC\PoshQC.TestingShard.Tests.ps1
Already formatted: .\tests\scripts\powershell\PoshQC\PoshQC.Tests.ps1
Already formatted: .\tests\scripts\powershell\Publish-DrmCopilotExtension.Tests.ps1
Already formatted: .\tests\scripts\powershell\Support\TestHelpers.ps1
Already formatted: .\tests\scripts\workflows\CiChangeScopeWorkflow.Tests.ps1
Already formatted: .\tests\scripts\workflows\CiWorkflow.Tests.ps1
Already formatted: .\tests\scripts\workflows\PoshQcWorkflow.Tests.ps1
Already formatted: .\tests\scripts\workflows\PublishMcpNpmWorkflow.Tests.ps1
Already formatted: .\tests\scripts\workflows\VerifyPublishedReleasesWorkflow.Tests.ps1

Full sanitized output: SCRATCH/issue-977-baseline-powershell-format.log
