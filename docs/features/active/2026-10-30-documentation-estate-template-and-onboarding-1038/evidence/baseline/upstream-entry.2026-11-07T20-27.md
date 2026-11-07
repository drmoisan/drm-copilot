# Upstream entry seam and context (1020)

Timestamp: 2026-11-07T20-27
Command: Read .claude/lib/docs/Invoke-DocsCommand.ps1, tests/scripts/claude-lib/docs/Docs.TestSupport.psm1, schemas/docs/v1/docs-command-envelope.schema.json, .claude/lib/docs/DocsSchema.psm1 (Get-DocsRuntimeVersionError), .claude/lib/docs/DocsJson.psm1 (ConvertFrom-DocsJsonText)
EXIT_CODE: 0
Output Summary: Every 1020 entry-seam item matches the plan. The command context carries the eight planned members plus two additive members from 1034 (ResolveRevision, ReadRevisionText), which the in-memory builder also provides. D-2 resolves to wrap.

CONTRACT: dot-source guard (`if ($MyInvocation.InvocationName -ne '.')` around the top-level body) | match
CONTRACT: Invoke-DocsCommandCli parameters -Command, -Json, -CommandArgument, -Context (also -Help, -RepositoryRoot, -CommandFunction, -PowerShellVersion) | match
CONTRACT: Invoke-DocsCommandCli return members ExitCode, Stdout, Stderr (hashtable) | match
CONTRACT: Get-DocsCommandTable returns object[] of pscustomobject rows; row name read from `.Name`; options from `.Option` (hashtable of option name to value, multi or switch) | match
CONTRACT: command context members RepositoryRoot, ReadText, ReadBytes, TestFile, ListFile, WriteText, UtcNow, InvokeProcess (superset: ResolveRevision, ReadRevisionText added by 1034) | match
CONTRACT: Write-DocsFileText is the only filesystem write primitive (-FullPath, -Text, -Mode create|overwrite, SupportsShouldProcess) | match
CONTRACT: ConvertFrom-DocsJsonText -Text returns @{ Value; Findings } with ordinal hashtables | match
CONTRACT: Docs.TestSupport.psm1 exports Get-DocsTestRepositoryRoot, Get-DocsTestSchemaText, Get-DocsTestExampleText, New-DocsTestContext | match
CONTRACT: New-DocsTestContext WriteText updates the path-to-text map (`$files[$path] = $value`), so later ReadText, TestFile and ListFile see the write | match
CONTRACT: New-DocsTestContext InvokeProcess fake records calls in ProcessCallLog (returned as @{ Context; Files; WriteLog; ProcessCallLog }) | match
CONTRACT: exit codes 0 success, 1 error findings, 2 DOCS_CLI_ARGUMENTS, 3 DOCS_CLI_RUNTIME or DOCS_RUNTIME_UNSUPPORTED | match
CONTRACT: PowerShell floor 7.4 (`$script:DocsSchemaMinimumPowerShellVersion = [version] '7.4'`) | match
CONTRACT: envelope schema top-level required set [command, exit_code, findings, ok, result] | match

D-2: wrap
