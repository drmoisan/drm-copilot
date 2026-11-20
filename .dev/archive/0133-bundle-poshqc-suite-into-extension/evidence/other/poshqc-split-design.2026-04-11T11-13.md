Timestamp: 2026-04-11T11-13
Command: PoshQC split design
EXIT_CODE: 0
Output Summary: Planned the deterministic PoshQC split into `PoshQC.FileDiscovery.psm1` for `ConvertTo-PoshQCPath`, `Get-PoshQCFileList`, and `Resolve-PoshQCScanFolder`; `PoshQC.Analyzer.psm1` for `Invoke-PoshQCFormat`, `Invoke-PoshQCAnalyze`, and `Invoke-PoshQCAnalyzeAutofix`; and `PoshQC.Testing.psm1` for `Convert-PoshQCCoverageToRelative`, `Invoke-PoshQCTest`, and `Invoke-PoshQCSuite` while preserving the existing exported function list from `PoshQC.psm1`.
