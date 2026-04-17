---
paths:
  - "**/*.ps1"
  - "**/*.psm1"
  - "**/*.psd1"
description: PowerShell-specific toolchain and coding standards.
---

# PowerShell Code Standards

This rule file summarizes the PowerShell-specific policies for this repository.

## Toolchain

1. **Formatting — Invoke-Formatter**: Format all PowerShell files via PoshQC. MCP command: `mcp__drmCopilotExtension__run_poshqc_format`
2. **Linting — PSScriptAnalyzer**: Run PoshQC analyzer with repo settings. MCP command: `mcp__drmCopilotExtension__run_poshqc_analyze`. Optional autofix: `mcp__drmCopilotExtension__run_poshqc_analyze_autofix`
3. **Type checking**: Not applicable for PowerShell; skip to testing.
4. **Testing — Pester (v5.x)**: Run tests via MCP. MCP command: `mcp__drmCopilotExtension__run_poshqc_test`. Use repo config at `scripts/powershell/PoshQC/settings/pester.runsettings.psd1`.

Run the toolchain in order: format → analyze → test. Restart from step 1 if any step fails or changes files. Use the MCP server functions; do not substitute VS Code task wrappers.

## Compatibility

- All scripts must be compatible with **PowerShell 7+** (enforced via PSScriptAnalyzer settings).

## Coding Standards

- Prefer **advanced functions** with `CmdletBinding()` and named parameters.
- Add `[Parameter(Mandatory = $true)]` and validation attributes where appropriate.
- Implement **ShouldProcess/SupportsShouldProcess** for state-changing actions.
- Avoid global state and mutable script-scoped variables; pass data explicitly.
- Avoid `Invoke-Expression`, plaintext secrets, and hard-coded credentials/paths.
- Use `Write-Error`/`throw` for failures; avoid silent catch-alls.
- Use approved verbs and descriptive nouns for function names (PSScriptAnalyzer enforces this).
- Keep scripts cohesive and under 500 lines.

## Testing Standards

- Use **Pester** (v5.x) as the test framework.
- Organize tests to mirror code structure (e.g., `tests/scripts/dev-tools/ScriptName.Tests.ps1`).
- Name test files `*.Tests.ps1`.
- Use `Describe`/`Context`/`It` blocks; one behavior per `It`.
- Write focused tests exercising a single function or behavior.
- Mock sparingly; prefer real code paths.
- No external dependencies in unit tests.
- Repository-wide line coverage must remain >= 80%.
- Any new module, class, or method must reach >= 90% coverage.
- Coverage regression on changed lines is a blocking finding.
