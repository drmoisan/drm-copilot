#Requires -Version 7.0
#Requires -Modules @{ ModuleName = 'Pester'; ModuleVersion = '5.0.0' }

<#
.SYNOPSIS
    Static import-isolation test for the DocsPage*.psm1 modules of the documentation page checker.

.DESCRIPTION
    Reads the committed module texts read-only, parses each with
    [System.Management.Automation.Language.Parser]::ParseInput, follows every Import-Module whose
    argument is a literal Join-Path -Path $PSScriptRoot -ChildPath join, and computes the
    transitive closure of each page module. Asserts that direct imports stay within the allowed
    set, that no denied module is in the closure, and that no page module uses using module,
    dot-sourcing or Invoke-Expression. A positive control asserts that an in-memory module text
    importing DocsLedger.psm1 is reported. A static graph is used instead of Get-Module because
    loaded-module state leaks between suites in shuffled and single-process runs. No module is
    imported and no file is written.
#>

BeforeDiscovery {
    $libraryDocs = [System.IO.Path]::GetFullPath((Join-Path -Path $PSScriptRoot -ChildPath '../../../../.claude/lib/docs'))
    $script:PageModuleName = @(Get-ChildItem -LiteralPath $libraryDocs -Filter 'DocsPage*.psm1' -File | ForEach-Object { $_.Name } | Sort-Object)
}

BeforeAll {
    $script:LibraryRoot = [System.IO.Path]::GetFullPath((Join-Path -Path $PSScriptRoot -ChildPath '../../../../.claude/lib'))
    $script:DocsRoot = Join-Path -Path $script:LibraryRoot -ChildPath 'docs'
    $script:JoinPattern = "Join-Path\s+-Path\s+\`$PSScriptRoot\s+-ChildPath\s+'(?<child>[^']+)'"
    $script:AllowedDirect = @('DocsJson.psm1', 'DocsFinding.psm1', 'DocsSchema.psm1', 'DocsSchemaWalk.psm1', 'DocsSurface.psm1', 'DocsProfile.psm1')
    $script:DeniedPattern = @('DocsLedger*', 'DocsParity*', 'DocsEvidencePins*', 'DocsStaleness*', 'DocsReceipt*', 'DocsValidation*', 'DocsInventory*', 'DocsReference*', 'DocsSurfaceDelta*', 'DocsExtensionImport*', 'Docs*Tokens*')

    function Get-TestModuleShape {
        # Parses one module text; returns @{ Imports (relative children of literal joins); UsingModule; DotSource; InvokeExpression }.
        param([string] $Text)
        $ast = [System.Management.Automation.Language.Parser]::ParseInput($Text, [ref] $null, [ref] $null)
        $commands = @($ast.FindAll({ param($node) $node -is [System.Management.Automation.Language.CommandAst] }, $true))
        $imports = [System.Collections.Generic.List[string]]::new()
        foreach ($command in $commands) {
            if ([string] $command.GetCommandName() -ne 'Import-Module') { continue }
            foreach ($match in [regex]::Matches($command.Extent.Text, $script:JoinPattern)) { $imports.Add($match.Groups['child'].Value) }
        }
        $using = @($ast.FindAll({ param($node) $node -is [System.Management.Automation.Language.UsingStatementAst] -and $node.UsingStatementKind -eq 'Module' }, $true)).Count
        $dot = @($commands | Where-Object { $_.InvocationOperator -eq [System.Management.Automation.Language.TokenKind]::Dot }).Count
        $iex = @($commands | Where-Object { @('Invoke-Expression', 'iex') -contains [string] $_.GetCommandName() }).Count
        return @{ Imports = $imports.ToArray(); UsingModule = $using; DotSource = $dot; InvokeExpression = $iex }
    }

    function Test-TestDenied {
        # Returns $true when a module file name is denied anywhere in a page-module closure.
        param([string] $RelativePath)
        $name = [System.IO.Path]::GetFileName($RelativePath)
        if ($RelativePath.StartsWith('docs/python/', [System.StringComparison]::Ordinal)) { return $true }
        if ($name -like 'DocsAnalyzer*.psm1' -and $name -cne 'DocsAnalyzerRegistry.psm1') { return $true }
        return @($script:DeniedPattern | Where-Object { $name -like $_ }).Count -gt 0
    }

    function Get-TestClosure {
        # Returns the sorted closure (paths relative to .claude/lib) reached from one module text located in .claude/lib/docs.
        param([string] $Text)
        $seen = [System.Collections.Generic.SortedSet[string]]::new([System.StringComparer]::Ordinal)
        $queue = [System.Collections.Generic.Queue[object]]::new()
        $queue.Enqueue(@{ Directory = $script:DocsRoot; Text = $Text })
        while ($queue.Count -gt 0) {
            $item = $queue.Dequeue()
            foreach ($child in (Get-TestModuleShape -Text $item.Text).Imports) {
                $full = [System.IO.Path]::GetFullPath((Join-Path -Path $item.Directory -ChildPath $child))
                $relative = [System.IO.Path]::GetRelativePath($script:LibraryRoot, $full).Replace('\', '/')
                if (-not $seen.Add($relative)) { continue }
                if ([System.IO.File]::Exists($full)) { $queue.Enqueue(@{ Directory = [System.IO.Path]::GetDirectoryName($full); Text = [System.IO.File]::ReadAllText($full) }) }
            }
        }
        return , [string[]] @($seen)
    }
}

Describe 'DocsPage module import isolation' {
    It 'covers the seven page modules named by the plan' {
        # Arrange (BeforeDiscovery variables are not visible at run time, so the folder is listed again)
        $names = @(Get-ChildItem -LiteralPath $script:DocsRoot -Filter 'DocsPage*.psm1' -File | ForEach-Object { $_.Name })

        # Assert
        foreach ($name in @('DocsPageMarkdown.psm1', 'DocsPageFrontMatter.psm1', 'DocsPageMetadata.psm1', 'DocsPageLinks.psm1', 'DocsPageDiataxis.psm1', 'DocsPageOrphans.psm1', 'DocsPageCheck.psm1')) {
            $names | Should -Contain $name
        }
    }

    It 'keeps the direct imports and the transitive closure of <_> within the allowed set' -ForEach $script:PageModuleName {
        # Arrange
        $text = [System.IO.File]::ReadAllText((Join-Path -Path $script:DocsRoot -ChildPath $_))
        $shape = Get-TestModuleShape -Text $text

        # Act
        $closure = Get-TestClosure -Text $text
        Write-Information -MessageData "closure of ${_}: $($closure -join ', ')" -InformationAction Continue

        # Assert
        foreach ($child in $shape.Imports) {
            ($script:AllowedDirect -ccontains $child -or $child -clike 'DocsPage*.psm1') | Should -BeTrue -Because "$_ imports $child"
        }
        foreach ($path in $closure) {
            Test-TestDenied -RelativePath $path | Should -BeFalse -Because "$_ reaches $path"
            [System.IO.File]::Exists((Join-Path -Path $script:LibraryRoot -ChildPath $path)) | Should -BeTrue -Because "$_ reaches $path"
        }
        $shape.UsingModule | Should -Be 0
        $shape.DotSource | Should -Be 0
        $shape.InvokeExpression | Should -Be 0
    }

    It 'reaches the analyzer registry only through DocsProfile.psm1 from the check module' {
        # Act
        $closure = Get-TestClosure -Text ([System.IO.File]::ReadAllText((Join-Path -Path $script:DocsRoot -ChildPath 'DocsPageCheck.psm1')))
        $direct = (Get-TestModuleShape -Text ([System.IO.File]::ReadAllText((Join-Path -Path $script:DocsRoot -ChildPath 'DocsPageCheck.psm1')))).Imports

        # Assert
        $closure | Should -Contain 'docs/DocsProfile.psm1'
        $closure | Should -Contain 'docs/DocsAnalyzerRegistry.psm1'
        $direct | Should -Not -Contain 'DocsAnalyzerRegistry.psm1'
    }
}

Describe 'DocsPage import isolation positive controls' {
    It 'reports an in-memory module text that imports DocsLedger.psm1' {
        # Arrange
        $text = "Import-Module -Name (Join-Path -Path `$PSScriptRoot -ChildPath 'DocsLedger.psm1') -ErrorAction Stop"

        # Act
        $shape = Get-TestModuleShape -Text $text
        $closure = Get-TestClosure -Text $text

        # Assert
        $shape.Imports | Should -Be @('DocsLedger.psm1')
        ($script:AllowedDirect -ccontains 'DocsLedger.psm1') | Should -BeFalse
        @($closure | Where-Object { Test-TestDenied -RelativePath $_ }) | Should -Be @('docs/DocsLedger.psm1')
    }

    It 'reports an analyzer implementation and a python-subtree module and allows the registry' {
        Test-TestDenied -RelativePath 'docs/DocsAnalyzerPythonNative.psm1' | Should -BeTrue
        Test-TestDenied -RelativePath 'docs/python/helper.psm1' | Should -BeTrue
        Test-TestDenied -RelativePath 'docs/DocsReferenceRender.psm1' | Should -BeTrue
        Test-TestDenied -RelativePath 'docs/DocsAnalyzerRegistry.psm1' | Should -BeFalse
        Test-TestDenied -RelativePath 'docs/DocsSurface.psm1' | Should -BeFalse
    }

    It 'detects using module, dot-sourcing and Invoke-Expression in an in-memory text' {
        # Act
        $shape = Get-TestModuleShape -Text "using module ./x.psm1`n. (Join-Path -Path `$PSScriptRoot -ChildPath 'y.ps1')`nInvoke-Expression 'z'"

        # Assert
        $shape.UsingModule | Should -Be 1
        $shape.DotSource | Should -Be 1
        $shape.InvokeExpression | Should -Be 1
    }
}
