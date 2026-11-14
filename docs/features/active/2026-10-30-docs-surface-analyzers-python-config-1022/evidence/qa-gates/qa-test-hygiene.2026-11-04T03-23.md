# [P6-T10] Test hygiene (issue #1022)

Timestamp: 2026-11-04T03-23
Command: (1) pwsh -NoProfile -File SCRATCH/issue-1022-p6t10-hygiene.ps1 -WorktreeRoot <item worktree>, which dot-sources `.claude/hooks/check-powershell-test-purity.ps1`, evaluates `Invoke-PowerShellTestPurityDecision -ToolInputRaw <payload>` over a PreToolUse Write payload (`tool_name` `Write`, `tool_input.file_path` the repository-relative path, `tool_input.content` the file text) for each new test file plus one control payload containing `New-TemporaryFile`, counts case-insensitive `TestDrive` matches with `Select-String -SimpleMatch`, and byte-scans both corpus files for byte 13; (2) `grep -il TestDrive` over the nineteen new test files (plain search, independent of the git index)
EXIT_CODE: 0
Output Summary: Control payload: decision `deny` (the gate can fail). Nineteen new test files: no decision returned for any file (decisions=0). `TestDrive` search: 0 matches in `Select-String` and `grep -il` printed nothing (exit 1, no match). CR byte scan: `python-surface-corpus.json` 109212 bytes, 0 CR; `config-surface-corpus.json` 34485 bytes, 0 CR.

## Purity decisions

| Test file | Decision | `TestDrive` matches |
|---|---|---|
| `tests/scripts/claude-lib/docs/DocsSourceText.Tests.ps1` | none | 0 |
| `tests/scripts/claude-lib/docs/DocsPythonTokens.Tests.ps1` | none | 0 |
| `tests/scripts/claude-lib/docs/DocsPythonSyntax.Tests.ps1` | none | 0 |
| `tests/scripts/claude-lib/docs/DocsPythonBindings.Tests.ps1` | none | 0 |
| `tests/scripts/claude-lib/docs/DocsTomlKeys.Tests.ps1` | none | 0 |
| `tests/scripts/claude-lib/docs/DocsYamlKeys.Tests.ps1` | none | 0 |
| `tests/scripts/claude-lib/docs/DocsJsonSchemaKeys.Tests.ps1` | none | 0 |
| `tests/scripts/claude-lib/docs/DocsPythonCliArgparse.Tests.ps1` | none | 0 |
| `tests/scripts/claude-lib/docs/DocsPythonCliClick.Tests.ps1` | none | 0 |
| `tests/scripts/claude-lib/docs/DocsPythonCliTyper.Tests.ps1` | none | 0 |
| `tests/scripts/claude-lib/docs/DocsAnalyzerPythonCli.Tests.ps1` | none | 0 |
| `tests/scripts/claude-lib/docs/DocsPythonHttpSites.Tests.ps1` | none | 0 |
| `tests/scripts/claude-lib/docs/DocsAnalyzerPythonHttp.Tests.ps1` | none | 0 |
| `tests/scripts/claude-lib/docs/DocsAnalyzerPythonApi.Tests.ps1` | none | 0 |
| `tests/scripts/claude-lib/docs/DocsAnalyzerArchitecture.Tests.ps1` | none | 0 |
| `tests/scripts/claude-lib/docs/DocsAnalyzerConfigFiles.Tests.ps1` | none | 0 |
| `tests/scripts/claude-lib/docs/DocsInventorySnapshot.Tests.ps1` | none | 0 |
| `tests/scripts/claude-lib/docs/DocsInventory.Tests.ps1` | none | 0 |
| `tests/scripts/claude-lib/docs/DocsInventoryProperties.Tests.ps1` | none | 0 |

## CR byte scan

| Corpus file | Bytes | CR bytes |
|---|---|---|
| `tests/scripts/claude-lib/docs/fixtures/python-surface-corpus.json` | 109212 | 0 |
| `tests/scripts/claude-lib/docs/fixtures/config-surface-corpus.json` | 34485 | 0 |
