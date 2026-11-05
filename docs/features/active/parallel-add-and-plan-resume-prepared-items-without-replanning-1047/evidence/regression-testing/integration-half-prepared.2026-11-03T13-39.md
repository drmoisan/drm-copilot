# Integration Scenario: Add a Half-Prepared Item

Timestamp: 2026-11-03T13-39
Task: [P7-T2]
Command: sh-launched PowerShell 7 Invoke-PoshQCTest -ScanFolders tests/scripts/claude-lib/parallel-admission/Invoke-ParallelAdmission.Integration.Tests.ps1 (counts from artifacts/pester/pester-junit.xml)
EXIT_CODE: 0
Output Summary: Describe `Add a half-prepared item`: 1 test, 1 passed, 0 failed. The asserted output for a branch holding research and a spec only is `preparation_status` `spec`, `resume_stage` `plan`, and `next_action` `resume_preparation`, with `research_path` and `spec_path` reported and band source `caller`.

Evidence scope: local evidence only (mocked git seam, in-memory branch tree); no network call, no GitHub mutation, no file written.
