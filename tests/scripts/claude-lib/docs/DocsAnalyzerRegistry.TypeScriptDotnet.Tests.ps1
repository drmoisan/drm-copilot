#Requires -Version 7.0
#Requires -Modules @{ ModuleName = 'Pester'; ModuleVersion = '5.0.0' }

<#
.SYNOPSIS
    Membership tests for the 1033 rows of .claude/lib/docs/DocsAnalyzerRegistry.psm1.

.DESCRIPTION
    Asserts membership only: the registry source text carries the anchor line
    "# --- 1033: TypeScript and .NET analyzers ---" inside the scanner table $script:DocsAnalyzerRow
    and no placeholder-numbered anchor; Get-DocsAnalyzerRegistration contains a scanner row for
    each of the seven 1033 identifiers with version 1.0.0, the specified module leaf, function
    and element kinds; none of the seven is a 1022 identifier; Test-DocsAnalyzerRegistration
    reports no finding; and each row lies after the 1033 anchor and before the next anchor or
    the end of the scanner table. No row count and no exclusivity of the committed tables is
    asserted. The module text is read from disk; no file is written and no process is started.
#>

BeforeAll {
    $script:LibraryRoot = Join-Path -Path $PSScriptRoot -ChildPath '../../../../.claude/lib'
    $script:ModulePath = [System.IO.Path]::GetFullPath((Join-Path -Path $script:LibraryRoot -ChildPath 'docs/DocsAnalyzerRegistry.psm1'))
    Import-Module -Name $script:ModulePath -Force -ErrorAction Stop
    $script:ModuleText = Get-Content -LiteralPath $script:ModulePath -Raw
    $script:Anchor = '# --- 1033: TypeScript and .NET analyzers ---'
    $script:Rows = @(
        @{ Id = 'typescript-cli'; Leaf = 'DocsAnalyzerTypeScriptCli.psm1'; Function = 'Invoke-DocsAnalyzerTypeScriptCli'; Kinds = @('cli-command', 'cli-option') }
        @{ Id = 'typescript-http'; Leaf = 'DocsAnalyzerTypeScriptHttp.psm1'; Function = 'Invoke-DocsAnalyzerTypeScriptHttp'; Kinds = @('http-route') }
        @{ Id = 'typescript-exports'; Leaf = 'DocsAnalyzerTypeScriptExports.psm1'; Function = 'Invoke-DocsAnalyzerTypeScriptExports'; Kinds = @('public-symbol') }
        @{ Id = 'dotnet-http'; Leaf = 'DocsAnalyzerDotnetHttp.psm1'; Function = 'Invoke-DocsAnalyzerDotnetHttp'; Kinds = @('http-route') }
        @{ Id = 'dotnet-config'; Leaf = 'DocsAnalyzerDotnetConfig.psm1'; Function = 'Invoke-DocsAnalyzerDotnetConfig'; Kinds = @('config-key') }
        @{ Id = 'dotnet-public-api'; Leaf = 'DocsAnalyzerDotnetApi.psm1'; Function = 'Invoke-DocsAnalyzerDotnetApi'; Kinds = @('public-symbol') }
        @{ Id = 'extension-import'; Leaf = 'DocsAnalyzerExtensionImport.psm1'; Function = 'Invoke-DocsAnalyzerExtensionImport'; Kinds = @('cli-command', 'cli-option', 'http-route', 'config-key', 'public-symbol', 'architecture-component') }
    )

    function Get-TestScannerRow {
        # Returns the committed rows whose Id and AnalysisMethod match (membership lookup).
        param([string] $Id, [string] $AnalysisMethod = 'scanner')
        [object[]] $rows = Get-DocsAnalyzerRegistration
        @($rows | Where-Object { [string] $_.Id -ceq $Id -and [string] $_.AnalysisMethod -ceq $AnalysisMethod })
    }
}

AfterAll {
    Remove-Module -Name DocsAnalyzerRegistry, DocsSurface, DocsFinding, DocsJson, DiscoveryEncoding -Force -ErrorAction SilentlyContinue
}

Describe 'DocsAnalyzerRegistry 1033 rows (membership only)' {
    It 'carries the 1033 anchor line inside the scanner table' {
        # Arrange
        $scannerAt = $script:ModuleText.IndexOf('$script:DocsAnalyzerRow = @(', [System.StringComparison]::Ordinal)
        $anchorAt = $script:ModuleText.IndexOf($script:Anchor, [System.StringComparison]::Ordinal)
        $nativeAt = $script:ModuleText.IndexOf('$script:DocsAnalyzerNativeRow = @(', [System.StringComparison]::Ordinal)

        # Assert
        $scannerAt | Should -BeGreaterThan 0
        $anchorAt | Should -BeGreaterThan $scannerAt
        $nativeAt | Should -BeGreaterThan $anchorAt
    }

    It 'carries no placeholder-numbered anchor, and the guard pattern matches a positive control' {
        # Arrange
        $pattern = '# --- 900[0-9]{3}:'

        # Assert
        @($script:ModuleText -split "`n" | Where-Object { $_ -match $pattern }).Count | Should -Be 0
        '# --- 900011: placeholder ---' | Should -Match $pattern
    }

    It 'registers <Id> as a scanner row with version 1.0.0, module leaf <Leaf> and function <Function>' -ForEach @(
        # Discovery-time copy of the BeforeAll table (a -ForEach value is read before BeforeAll runs).
        @{ Id = 'typescript-cli'; Leaf = 'DocsAnalyzerTypeScriptCli.psm1'; Function = 'Invoke-DocsAnalyzerTypeScriptCli'; Kinds = @('cli-command', 'cli-option') }
        @{ Id = 'typescript-http'; Leaf = 'DocsAnalyzerTypeScriptHttp.psm1'; Function = 'Invoke-DocsAnalyzerTypeScriptHttp'; Kinds = @('http-route') }
        @{ Id = 'typescript-exports'; Leaf = 'DocsAnalyzerTypeScriptExports.psm1'; Function = 'Invoke-DocsAnalyzerTypeScriptExports'; Kinds = @('public-symbol') }
        @{ Id = 'dotnet-http'; Leaf = 'DocsAnalyzerDotnetHttp.psm1'; Function = 'Invoke-DocsAnalyzerDotnetHttp'; Kinds = @('http-route') }
        @{ Id = 'dotnet-config'; Leaf = 'DocsAnalyzerDotnetConfig.psm1'; Function = 'Invoke-DocsAnalyzerDotnetConfig'; Kinds = @('config-key') }
        @{ Id = 'dotnet-public-api'; Leaf = 'DocsAnalyzerDotnetApi.psm1'; Function = 'Invoke-DocsAnalyzerDotnetApi'; Kinds = @('public-symbol') }
        @{ Id = 'extension-import'; Leaf = 'DocsAnalyzerExtensionImport.psm1'; Function = 'Invoke-DocsAnalyzerExtensionImport'; Kinds = @('cli-command', 'cli-option', 'http-route', 'config-key', 'public-symbol', 'architecture-component') }
    ) {
        # Act
        $found = @(Get-TestScannerRow -Id $Id)

        # Assert: found by Id and AnalysisMethod; no row count over the table.
        $found.Count | Should -Be 1
        $found[0].Version | Should -Be '1.0.0'
        [System.IO.Path]::GetFileName([string] $found[0].Module) | Should -Be $Leaf
        $found[0].Function | Should -Be $Function
        @($found[0].ElementKinds) | Should -Be $Kinds
    }

    It 'uses none of the 1022 identifiers' {
        # Arrange
        $python = @('python-cli', 'python-http', 'python-public-api', 'config-files', 'python-architecture')

        # Assert
        foreach ($row in $script:Rows) { $python | Should -Not -Contain $row.Id }
    }

    It 'reports no finding for the committed registry' {
        (Test-DocsAnalyzerRegistration -Registration (Get-DocsAnalyzerRegistration)).Count | Should -Be 0
    }

    It 'places each of the seven rows after the 1033 anchor and before the next anchor or the end of the scanner table' {
        # Arrange
        $anchorAt = $script:ModuleText.IndexOf($script:Anchor, [System.StringComparison]::Ordinal)
        $tableEnd = $script:ModuleText.IndexOf("`n)", $anchorAt, [System.StringComparison]::Ordinal)
        $nextAnchor = [regex]::Match($script:ModuleText.Substring($anchorAt + $script:Anchor.Length), '# --- [0-9]+:')
        $regionEnd = if ($nextAnchor.Success -and ($anchorAt + $script:Anchor.Length + $nextAnchor.Index) -lt $tableEnd) { $anchorAt + $script:Anchor.Length + $nextAnchor.Index } else { $tableEnd }

        # Assert
        $anchorAt | Should -BeGreaterThan 0
        $tableEnd | Should -BeGreaterThan $anchorAt
        foreach ($row in $script:Rows) {
            $token = "Id = '" + $row.Id + "'"
            $rowAt = $script:ModuleText.IndexOf($token, [System.StringComparison]::Ordinal)
            $rowAt | Should -BeGreaterThan $anchorAt -Because "$($row.Id) must follow the 1033 anchor"
            $rowAt | Should -BeLessThan $regionEnd -Because "$($row.Id) must precede the next anchor or the end of the scanner table"
            $script:ModuleText.IndexOf($token, $rowAt + 1, [System.StringComparison]::Ordinal) | Should -Be -1 -Because "$($row.Id) is registered once"
        }
    }
}
