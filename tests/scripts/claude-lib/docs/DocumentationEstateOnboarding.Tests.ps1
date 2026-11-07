#Requires -Version 7.0
#Requires -Modules @{ ModuleName = 'Pester'; ModuleVersion = '5.0.0' }

<#
.SYNOPSIS
    Documentation contract tests for the documentation-estate onboarding pages (issue #1038).

.DESCRIPTION
    Reads the five pages under docs/engineering/documentation-estate/ once. The expected subcommand
    set comes from Get-DocsCommandTable of the dot-sourced entry script and the expected docs MCP
    tool set from extensions/drm-copilot/src/mcp-docs-tool-definitions.ts read as text, so a new
    subcommand or tool without a heading and a fenced example fails the suite. Statement checks
    replace CR LF with LF and collapse whitespace before a containment check, so a reflowed sentence
    still matches. A neutrality context hashes the tokens of the template pair and the pages against
    the consumer-identifier digest list of DocsNeutrality.Tests.ps1. Positive controls run the same
    checks over in-memory text. The suite writes no file and starts no process.
#>

BeforeAll {
    $script:RepositoryRootPath = [System.IO.Path]::GetFullPath((Join-Path -Path $PSScriptRoot -ChildPath '../../../..'))
    . (Join-Path -Path $script:RepositoryRootPath -ChildPath '.claude/lib/docs/Invoke-DocsCommand.ps1')

    $script:PageRoot = 'docs/engineering/documentation-estate'
    $script:PageName = @('README.md', 'architecture.md', 'consumer-onboarding.md', 'command-reference.md', 'workflow.md')
    $script:PageText = @{}
    foreach ($name in $script:PageName) {
        $path = Join-Path -Path $script:RepositoryRootPath -ChildPath "$script:PageRoot/$name"
        if (Test-Path -LiteralPath $path) { $script:PageText[$name] = (Get-Content -LiteralPath $path -Raw) -replace "`r`n", "`n" }
    }
    $script:DefinitionText = Get-Content -LiteralPath (Join-Path -Path $script:RepositoryRootPath -ChildPath 'extensions/drm-copilot/src/mcp-docs-tool-definitions.ts') -Raw
    $script:SubcommandName = @('init', 'validate-profile', 'check', 'inventory', 'coverage', 'update-ledger', 'validate', 'generate-reference', 'surface-delta')
    $script:ToolName = @('run_docs_check', 'run_docs_inventory', 'run_docs_coverage', 'update_docs_ledger', 'generate_docs_reference', 'validate_docs_artifacts')

    function Get-NormalizedText {
        # Pure: LF line endings and every whitespace run collapsed to one space (D-7).
        param([Parameter(Mandatory = $true)] [AllowEmptyString()] [string] $Text)
        return (($Text -replace "`r`n", "`n") -replace '\s+', ' ')
    }

    function Get-MissingReferenceSection {
        # Pure: returns the names that have no '### `<name>`' heading under SectionHeading, or whose
        # subsection holds no fenced block containing ExampleToken (formatted with the name).
        param(
            [Parameter(Mandatory = $true)] [AllowEmptyString()] [string] $PageText,
            [Parameter(Mandatory = $true)] [string[]] $Names,
            [Parameter(Mandatory = $true)] [string] $SectionHeading,
            [Parameter(Mandatory = $true)] [string] $ExampleToken
        )
        $subsection = [System.Collections.Generic.Dictionary[string, System.Text.StringBuilder]]::new([System.StringComparer]::Ordinal)
        $inside = $false
        $current = $null
        foreach ($line in (($PageText -replace "`r`n", "`n") -split "`n")) {
            if ($line -cmatch '^## ') { $inside = $line.TrimEnd() -ceq $SectionHeading; $current = $null; continue }
            if (-not $inside) { continue }
            if ($line -cmatch '^### `([^`]+)`\s*$') { $current = $Matches[1]; $subsection[$current] = [System.Text.StringBuilder]::new(); continue }
            if ($null -ne $current) { [void]$subsection[$current].Append($line).Append("`n") }
        }
        $missing = foreach ($name in $Names) {
            if (-not $subsection.ContainsKey($name)) { $name; continue }
            $token = [regex]::Escape(($ExampleToken -f $name)) + '(?![A-Za-z0-9_-])'
            $blocks = [regex]::Matches($subsection[$name].ToString(), '(?ms)^```[A-Za-z]*\n(.*?)^```')
            if (@($blocks | Where-Object { $_.Groups[1].Value -cmatch $token }).Count -eq 0) { $name }
        }
        return [string[]]@($missing | Sort-Object -Unique)
    }

    function Find-EstateIdentifierDigest {
        # Pure: returns one (path, digest) pair per configured digest found in a file text, with the
        # tokenization of DocsNeutrality.Tests.ps1.
        param(
            [Parameter(Mandatory = $true)] [System.Collections.IDictionary] $FileText,
            [Parameter(Mandatory = $true)] [string[]] $Digest
        )
        $wanted = [System.Collections.Generic.HashSet[string]]::new([string[]] $Digest, [System.StringComparer]::Ordinal)
        $found = [System.Collections.Generic.List[object]]::new()
        foreach ($path in @($FileText.Keys | Sort-Object)) {
            $text = ([string] $FileText[$path]).ToLowerInvariant()
            $candidates = [System.Collections.Generic.HashSet[string]]::new([System.StringComparer]::Ordinal)
            foreach ($pattern in '[a-z0-9]+', '[a-z0-9]+(?:[-_.][a-z0-9]+)+') {
                foreach ($match in [regex]::Matches($text, $pattern)) { [void]$candidates.Add($match.Value) }
            }
            foreach ($candidate in $candidates) {
                $hash = Get-DocsSha256Hex -Text $candidate
                if ($wanted.Contains($hash)) { $found.Add([pscustomobject]@{ Path = [string] $path; Digest = $hash }) }
            }
        }
        return , $found.ToArray()
    }
}

AfterAll {
    Remove-Module -Name 'Docs*', 'DiscoveryEncoding' -Force -ErrorAction SilentlyContinue
}

Describe 'documentation-estate onboarding pages' {
    It 'has the five onboarding pages' {
        # Assert
        foreach ($name in $script:PageName) { $script:PageText.ContainsKey($name) | Should -BeTrue -Because "$script:PageRoot/$name exists" }
    }

    It 'documents every Get-DocsCommandTable row with a heading and an example' {
        # Arrange
        $table = Get-DocsCommandTable
        $rows = [string[]]@($table | ForEach-Object { [string] $_.Name })

        # Act
        $missing = Get-MissingReferenceSection -PageText $script:PageText['command-reference.md'] -Names $rows -SectionHeading '## Subcommands' -ExampleToken '-Command {0}'

        # Assert
        $rows.Count | Should -BeGreaterOrEqual 9
        $missing | Should -BeNullOrEmpty -Because 'every dispatch row has a heading and a powershell example'
    }

    It 'documents the nine named subcommands' {
        # Arrange
        $table = Get-DocsCommandTable
        $rows = [string[]]@($table | ForEach-Object { [string] $_.Name })

        # Act
        $missing = Get-MissingReferenceSection -PageText $script:PageText['command-reference.md'] -Names $script:SubcommandName -SectionHeading '## Subcommands' -ExampleToken '-Command {0}'

        # Assert
        foreach ($name in $script:SubcommandName) { $rows | Should -Contain $name }
        $missing | Should -BeNullOrEmpty
    }

    It 'documents every docs MCP tool defined in mcp-docs-tool-definitions.ts with a heading and an example' {
        # Arrange: each tool is declared as the first, double-quoted argument of a definition( call.
        $defined = @([regex]::Matches($script:DefinitionText, 'definition\(\s*"([a-z_]+)"') | ForEach-Object { $_.Groups[1].Value } | Sort-Object -Unique)

        # Act
        $missing = Get-MissingReferenceSection -PageText $script:PageText['command-reference.md'] -Names $defined -SectionHeading '## MCP Tools' -ExampleToken '"workspace_root"'

        # Assert
        $defined.Count | Should -BeGreaterThan 0
        foreach ($name in $script:ToolName) { $defined | Should -Contain $name }
        $missing | Should -BeNullOrEmpty -Because 'every defined tool has a heading and a json example'
    }

    It 'documents exit codes, envelope keys and the envelope schema path' {
        # Arrange
        $text = Get-NormalizedText -Text $script:PageText['command-reference.md']

        # Assert
        foreach ($statement in @('| 0 |', '| 1 |', '| 2 |', '| 3 |', 'DOCS_CLI_ARGUMENTS', 'DOCS_CLI_RUNTIME', 'DOCS_RUNTIME_UNSUPPORTED', '`command`, `exit_code`, `findings`, `ok` and `result`', 'schemas/docs/v1/docs-command-envelope.schema.json')) {
            $text.Contains($statement) | Should -BeTrue -Because "command-reference.md states '$statement'"
        }
    }

    It 'states the MCP tool boundaries' {
        # Arrange
        $text = Get-NormalizedText -Text $script:PageText['command-reference.md']

        # Assert
        foreach ($statement in @('`init`, `validate-profile` and `surface-delta` have no MCP tool', '`update_docs_ledger` is the only mutating tool', 'writes only with `write: true`', '`validate_docs_artifacts` never persists a receipt')) {
            $text.Contains($statement) | Should -BeTrue -Because "command-reference.md states '$statement'"
        }
    }

    It 'states the PowerShell 7.4 prerequisite' {
        # Assert
        (Get-NormalizedText -Text $script:PageText['consumer-onboarding.md']).Contains('PowerShell 7.4 or later is required on PATH as `pwsh`') | Should -BeTrue
    }

    It 'states that the optional python pack enables the native Python analyzer' {
        # Arrange
        $text = Get-NormalizedText -Text $script:PageText['consumer-onboarding.md']

        # Assert
        $text.Contains('The optional python pack enables the native Python analyzer') | Should -BeTrue
        $text.Contains('records `analysis_method: scanner`') | Should -BeTrue
    }

    It 'states that linting is optional and check is the required page gate' {
        # Arrange
        $text = Get-NormalizedText -Text $script:PageText['consumer-onboarding.md']

        # Assert
        $text.Contains('Linting is optional') | Should -BeTrue
        $text.Contains('`check` is the required page gate') | Should -BeTrue
    }

    It 'names the workflow roles, skills and the integration gate key' {
        # Arrange
        $text = Get-NormalizedText -Text $script:PageText['workflow.md']
        $names = @('docs-architect', 'docs-author', 'docs-reconciler', 'docs-coverage-reviewer', 'documentation-workflow', 'docs-init', 'docs-inventory-surface', 'docs-plan-ia', 'docs-author-page', 'docs-reconcile-behavior', 'docs-review-coverage', 'docs-validate')

        # Assert
        foreach ($name in $names) { $text.Contains("``$name``") | Should -BeTrue -Because "workflow.md names $name" }
        $text.Contains('completion_gates.integration_pr_gate.enabled') | Should -BeTrue
        $text.Contains('DOCS_COMPLETE_GATE_BLOCKED:') | Should -BeTrue
    }

    It 'fails naming the subcommand that an in-memory command reference omits' {
        # Arrange: drop the inventory subsection from an in-memory copy of the page.
        $page = $script:PageText['command-reference.md']
        $start = $page.IndexOf('### `inventory`', [System.StringComparison]::Ordinal)
        $end = $page.IndexOf('### `coverage`', [System.StringComparison]::Ordinal)
        $start | Should -BeGreaterThan 0
        $trimmed = $page.Substring(0, $start) + $page.Substring($end)

        # Act
        $missing = Get-MissingReferenceSection -PageText $trimmed -Names $script:SubcommandName -SectionHeading '## Subcommands' -ExampleToken '-Command {0}'

        # Assert
        $missing | Should -Be @('inventory')
    }
}

Describe 'documentation-estate onboarding neutrality' {
    Context 'neutrality' {
        BeforeAll {
            # The digest list exists only inside DocsNeutrality.Tests.ps1 (D-8): read that file once
            # and take the lowercase 64-hex tokens of the $script:ConsumerIdentifierSha256 assignment.
            $source = Get-Content -LiteralPath (Join-Path -Path $PSScriptRoot -ChildPath 'DocsNeutrality.Tests.ps1') -Raw
            $assignment = [regex]::Match($source, '\$script:ConsumerIdentifierSha256\s*=\s*@\(([^)]*)\)')
            $script:Digest = [string[]]@([regex]::Matches($assignment.Groups[1].Value, '[0-9a-f]{64}') | ForEach-Object { $_.Value })
            $script:ScannedText = @{}
            foreach ($name in 'epic.md', 'README.md') {
                $relative = "extensions/drm-copilot/resources/feature-templates/epic/documentation-estate/$name"
                $script:ScannedText[$relative] = Get-Content -LiteralPath (Join-Path -Path $script:RepositoryRootPath -ChildPath $relative) -Raw
            }
            foreach ($name in $script:PageText.Keys) { $script:ScannedText["$script:PageRoot/$name"] = $script:PageText[$name] }
        }

        It 'finds no consumer-identifier digest in the template pair or the onboarding pages' {
            # Act
            $found = Find-EstateIdentifierDigest -FileText $script:ScannedText -Digest $script:Digest

            # Assert
            $script:Digest.Count | Should -BeGreaterThan 0 -Because 'the digest list was read'
            $script:ScannedText.Count | Should -Be 7
            $found.Count | Should -Be 0
        }

        It 'detects a synthetic identifier injected into an in-memory page' {
            # Arrange
            $synthetic = 'zqxsyntheticconsumer'
            $digest = [string[]]@($script:Digest) + @(Get-DocsSha256Hex -Text $synthetic)
            $page = "$script:PageRoot/README.md"
            $map = @{ $page = $script:ScannedText[$page] + "`nAdopted by ZQXSyntheticConsumer.`n" }

            # Act
            $found = Find-EstateIdentifierDigest -FileText $map -Digest $digest

            # Assert
            @($found | ForEach-Object { $_.Path } | Select-Object -Unique) | Should -Be @($page)
            @($found | ForEach-Object { $_.Digest }) | Should -Contain (Get-DocsSha256Hex -Text $synthetic)
        }
    }
}
