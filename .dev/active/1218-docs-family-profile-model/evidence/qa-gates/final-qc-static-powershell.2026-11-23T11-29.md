# Final-QC Static Steps, PowerShell (Issue #1218, P4-T1)

Timestamp: 2026-11-23T11-29
Command: (1) sh SCRATCH/issue-1218-qc.sh format-check <12 changed PowerShell files>; (2) sh SCRATCH/issue-1218-qc.sh analyze <same 12 files> (direct Invoke-ScriptAnalyzer with scripts/powershell/PoshQC/settings/pssa.settings.psd1); (3) type check N/A for PowerShell; (4) sh SCRATCH/issue-1218-leakscan.sh (branch-current PoshQC.psd1, Invoke-PoshQCLeakScan -Root <worktree>); (5) sh SCRATCH/issue-1218-gen.sh check (scripts/harness-generation/Invoke-HarnessGeneration.ps1 -Check)
EXIT_CODE: 0
Output Summary:
- Files: .claude/lib/docs/DocsProfile.psm1, .claude/lib/docs/DocsProfileFamilies.psm1, both Claude bundle copies, tests/scripts/claude-lib/docs/DocsProfile.Tests.ps1, DocsProfileCommands.Tests.ps1, DocsValidateCommands.Tests.ps1, DocsValidation.Properties.Tests.ps1, DocsValidation.Tests.ps1, DocsProfileFamilies.Schema.Tests.ps1, DocsProfileFamilies.Tests.ps1, tests/scripts/claude-runtime/docs-authoring-roles.WorkflowText.Tests.ps1.
- Loop history: the first pass (2026-11-23T11-18) had format exit 0 with 0 changes, then the analyzer step raised `Object reference not set to an instance of an object.` from inside Invoke-ScriptAnalyzer and its process stalled; that process (own PID only) was stopped and the loop restarted from format.
- Clean pass (2026-11-23T11-28 to 11-29):
  - Format check: EXIT_CODE 0, 0 files needing format (TOTAL: 0); no file rewritten.
  - PSScriptAnalyzer: EXIT_CODE 0, 0 findings on each of the 12 files.
  - Leak scan: EXIT_CODE 0, `Leak scan: 904 files, 80 findings, 78 exempt, 2 allowlisted, 0 failures.` (one warning: scan folder tests/powershell does not exist and is skipped). No new leak finding.
  - Invoke-HarnessGeneration.ps1 -Check: EXIT_CODE 0, `harness-generation: no drift`.
