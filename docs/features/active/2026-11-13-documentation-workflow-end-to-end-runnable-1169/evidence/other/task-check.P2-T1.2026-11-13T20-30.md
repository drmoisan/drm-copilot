# Task Check P2-T1

Timestamp: 2026-11-13T20-30
Command: sh SCRATCH/issue-1169-tc.sh P2-T1 <files> <tests> (pwsh 7: Invoke-Formatter and Invoke-ScriptAnalyzer with scripts/powershell/PoshQC/settings/pssa.settings.psd1; Invoke-Pester with Run.Path = the selection); sh SCRATCH/issue-1169-pyc.sh <contract tests>
EXIT_CODE: 0
Output Summary:
- Changed files: new .claude/lib/docs/DocsValidateCommands.psm1 (Test-DocsValidateArgument and Invoke-DocsValidateCommand moved unchanged; cmp of the moved function text against the HEAD text of DocsLedgerCommands.psm1 reports identical); .claude/lib/docs/DocsLedgerCommands.psm1 (the two functions removed, header updated, eight private helpers exported for the new module; 785 to 705 lines); .claude/lib/docs/Invoke-DocsCommand.ps1 (the validate row binds DocsValidateCommands.psm1); bundle copies of all three; Claude core.json entry.
- Tests: DocsLedgerCommands.Validate.Tests.ps1 renamed (git mv) to tests/scripts/claude-lib/docs/DocsValidateCommands.Tests.ps1 with the new module in its import list and the Test-DocsValidateArgument cases of DocsLedgerCommands.Tests.ps1 moved into it with bodies unchanged; DocsLedgerCommands.Tests.ps1 dispatch-row case expects DocsValidateCommands.psm1 for validate; DocsLedgerCommands.Properties.Tests.ps1 import list gains the new module; DocsWriteBoundary.Tests.ps1 Module1023 gains the new module and the WriteText and Invoke-DocsArtifactWrite cases expect the validate function in DocsValidateCommands.psm1.
- Format and lint (three library files and four suites): 0 formatter differences, 0 analyzer findings.
- Selection rule: every test file that names DocsLedgerCommands, DocsValidateCommands, Invoke-DocsCommand, Invoke-DocsValidateCommand, or Test-DocsValidateArgument (git grep over tests/, 21 suites), plus tests/scripts/claude-lib/ClaudeLibModuleConvention.Tests.ps1; contract tests reading the Claude pack manifest.
- Pester: 490 passed, 0 failed, 0 skipped; exit 0.
- pytest: test_push_down_claude_resource_contracts.py, test_push_down_claude_pack_manifest_completeness.py, test_push_down_pack_manifest_dependency_closure.py: 34 passed; exit 0.
