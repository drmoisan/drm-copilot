Timestamp: 2026-10-17T17:59:29.357796+00:00
Command: Import-Module ./scripts/powershell/PoshQC/PoshQC.psd1 -Force; Invoke-PoshQCAnalyze -Root . -ScanFolders @(".codex/hooks", "tests/scripts/codex-hooks", "tests/scripts/claude-lib/codex-routing", "tests/scripts/claude-lib/orchestrator-state")
EXIT_CODE: 1
Output Summary:

PSReviewUnusedParameter       Warning     subagent-attestation-command.Tests.ps1     34   The parameter 'Root' has
                                                                                          been declared but not used.
PSReviewUnusedParameter       Warning     subagent-attestation-persistence.Tests.ps1 119  The parameter 'Path' has
                                                                                          been declared but not used.
PSReviewUnusedParameter       Warning     subagent-attestation-persistence.Tests.ps1 121  The parameter 'Path' has
                                                                                          been declared but not used.
PSReviewUnusedParameter       Warning     subagent-attestation-persistence.Tests.ps1 122  The parameter 'Path' has
                                                                                          been declared but not used.
PSReviewUnusedParameter       Warning     subagent-attestation-persistence.Tests.ps1 122  The parameter 'Mode' has
                                                                                          been declared but not used.
PSReviewUnusedParameter       Warning     subagent-attestation-persistence.Tests.ps1 122  The parameter 'Access' has
                                                                                          been declared but not used.
PSReviewUnusedParameter       Warning     subagent-attestation-persistence.Tests.ps1 122  The parameter 'Share' has
                                                                                          been declared but not used.
PSReviewUnusedParameter       Warning     subagent-attestation-persistence.Tests.ps1 172  The parameter 'Path' has
                                                                                          been declared but not used.
PSReviewUnusedParameter       Warning     subagent-attestation-persistence.Tests.ps1 172  The parameter 'Mode' has
                                                                                          been declared but not used.
PSReviewUnusedParameter       Warning     subagent-attestation-persistence.Tests.ps1 172  The parameter 'Access' has
                                                                                          been declared but not used.
PSReviewUnusedParameter       Warning     subagent-attestation-persistence.Tests.ps1 172  The parameter 'Share' has
                                                                                          been declared but not used.
PSUseBOMForUnicodeEncodedFile Warning     subagent-attestation-persistence.Tests.ps1      Missing BOM encoding for
                                                                                          non-ASCII encoded file 'subag
                                                                                          ent-attestation-persistence.T
                                                                                          ests.ps1'

Exception: PSScriptAnalyzer reported 14 issue(s).

Full sanitized output: SCRATCH/issue-977-regression-testing-attestation-lint.log
