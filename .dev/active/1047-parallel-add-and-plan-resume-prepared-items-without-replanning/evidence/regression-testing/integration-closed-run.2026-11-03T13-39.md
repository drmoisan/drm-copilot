# Integration Scenario: Add to a Closed Run

Timestamp: 2026-11-03T13-39
Task: [P7-T3]
Command: sh-launched PowerShell 7 Invoke-PoshQCTest -ScanFolders tests/scripts/claude-lib/parallel-admission/Invoke-ParallelAdmission.Integration.Tests.ps1 (counts from artifacts/pester/pester-junit.xml)
EXIT_CODE: 0
Output Summary: Describe `Add to a closed run`: 2 tests, 2 passed, 0 failed. `guard-run` on tests/fixtures/parallel_admission/closed-orchestrator-state.json with -ManifestMode closed exits 1 with stderr prefix `PARALLEL_ADMISSION_REJECTED: run_closed:` and no `PARALLEL_MUTATION_REJECTED` text; the same guard on the open seeded checkpoint with -ManifestMode open exits 0.

Evidence scope: local evidence only (committed fixtures read as text through the mocked read seam); no network call, no GitHub mutation, no file written.
