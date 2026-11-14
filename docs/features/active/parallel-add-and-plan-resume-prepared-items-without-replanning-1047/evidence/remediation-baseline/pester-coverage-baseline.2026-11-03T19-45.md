# PowerShell Coverage Baseline (remediation cycle 1)

Timestamp: 2026-11-03T19-45
Task: [P0-T3]
Command: sh-launched PowerShell 7 script SCRATCH/issue-1047-run-pester.ps1: one fresh pwsh process importing scripts/powershell/PoshQC/PoshQC.psd1 and calling Invoke-PoshQCTest -ScanFolders tests/scripts with the module-default settings scripts/powershell/PoshQC/settings/pester.runsettings.psd1 (coverage population from config/poshqc-coverage.json), at branch head 5000b6455 before any edit; coverage from artifacts/pester/powershell-coverage.xml read by SCRATCH/issue-1047-read-results.ps1
EXIT_CODE: 255
Output Summary: Discovery 13912 tests; console summary "Tests Passed: 13493, Failed: 409, Skipped: 10, Inconclusive: 0, NotRun: 0" in 1119.77 s. Repo-wide LINE counter 92.59% (21572 covered, 1726 missed). ParallelAdmission.psm1 100.00% (141/0), ParallelAdmissionPrecedence.psm1 100.00% (179/0), Invoke-ParallelAdmission.ps1 96.15% (250 covered, 10 missed), enforce-parallel-cohort-barrier-helpers.ps1 100.00% (97/0). Invoke-ParallelAdmission.ps1 logical line count: 699.

## Deviation: JUnit file unreadable on this host

Pester's JUnit export failed during the run with "hexadecimal value 0x1B, is an invalid character" (an ANSI escape character in a failure message), so artifacts/pester/pester-junit.xml was left truncated and the process exited 255. The test, failure, and error counts above therefore come from Pester's console summary in the same run, not from the JUnit file. The coverage XML was written completely by the same run. Error count: the console summary reports no separate error figure; block-level (BeforeAll) failures are included in Failed.

## Failure attribution (pre-existing, outside this item)

None of the 409 failures is in a suite this item adds or changes. The parallel-admission suites, the cohort-barrier suite, ClaudeLibModuleConvention.Tests.ps1, and FileSizePolicy.RepoGate.Tests.ps1 all passed. The failures fall in two groups:

- Windows-host fixtures under tests/scripts/dev-tools and tests/scripts/powershell (for example publish-sideloaded-extension, Invoke-BootstrapHost, Invoke-SideloadedExtensionPublish, Get-VenvAwarePrompt, Resolve-RepoRoot, DrmCopilotPromptSupport), which need a C: drive, backslash paths, or Windows prompt strings.
- A PATH leak cascade: tests/scripts/dev-tools/run-actionlint.Tests.ps1 assigns $env:PATH = '/existing' in a test outside the AfterEach block that restores it, so later suites in the same process cannot resolve pwsh or python (for example "The term 'pwsh' is not recognized" in the codex-hooks Describe blocks, and the Python interpreter assertion in enforce-parallel-drift-gate-helpers.Tests.ps1).

The launcher's own pwsh resolves pwsh, python, and python3 on PATH, and run-actionlint.Tests.ps1 is not in the merge-base diff of this branch.

## Per-file line coverage

| File | Covered | Missed | Line % |
| --- | --- | --- | --- |
| .claude/lib/parallel-admission/ParallelAdmission.psm1 | 141 | 0 | 100.00 |
| .claude/lib/parallel-admission/ParallelAdmissionPrecedence.psm1 | 179 | 0 | 100.00 |
| .claude/lib/parallel-admission/Invoke-ParallelAdmission.ps1 | 250 | 10 | 96.15 |
| .claude/hooks/enforce-parallel-cohort-barrier-helpers.ps1 | 97 | 0 | 100.00 |
| Repo-wide (report-level LINE counter) | 21572 | 1726 | 92.59 |

Missed lines of Invoke-ParallelAdmission.ps1 by function: Invoke-ParallelAdmissionGit (2), Read-ParallelAdmissionJsonText (1), ConvertFrom-ParallelAdmissionJsonElement (1), Write-ParallelAdmissionJsonValue (1), Get-ParallelAdmissionPlannerItem (1), guarded entry body (4).
