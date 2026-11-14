#Requires -Version 7.0
#Requires -Modules @{ ModuleName = 'Pester'; ModuleVersion = '5.0.0' }

<#
.SYNOPSIS
    Module-boundary tests for the DocsReference*.psm1 modules of the reference generator.

.DESCRIPTION
    Parses every reference module with the PowerShell parser (read-only) and asserts: no
    filesystem, clock, randomness or Invoke-Expression command, no [System.IO.File] or
    [System.IO.Directory] type expression, no $Context reference outside DocsReferenceWriter.psm1,
    no DocsLedger, DocsAnalyzer or DocsInventory import, and no reference to InvokeProcess or
    Invoke-DocsProcess; no string constant equal to a pattern that the committed page-metadata
    schema reaches from owner, audience, last_reviewed or surface_refs through the docs common
    $defs; no -Code argument that is a DOCS_PAGE_ string constant; and a seeded property test for
    every exported pure function. Each scanner also has a positive control over an in-memory
    script, so a scan that cannot fail is detected.
#>

BeforeAll {
    $script:RepositoryRoot = [System.IO.Path]::GetFullPath((Join-Path -Path $PSScriptRoot -ChildPath '../../../..'))
    $script:LibRoot = Join-Path -Path $script:RepositoryRoot -ChildPath '.claude/lib/docs'
    Import-Module -Name (Join-Path -Path $script:LibRoot -ChildPath 'DocsJson.psm1') -Force -ErrorAction Stop

    $script:ModuleName = [string[]]@('DocsReferenceFrontMatter.psm1', 'DocsReferenceMarkers.psm1', 'DocsReferencePlan.psm1', 'DocsReferenceRender.psm1', 'DocsReferenceReport.psm1', 'DocsReferenceSplit.psm1', 'DocsReferenceWriter.psm1')
    $script:CommandModule = 'DocsReferenceWriter.psm1'
    $script:CommandFunction = [string[]]@('Invoke-DocsGenerateReferenceCommand')
    $script:ForbiddenCommand = [string[]]@('Set-Content', 'Add-Content', 'Out-File', 'New-Item', 'Remove-Item', 'Copy-Item', 'Move-Item', 'Get-Content', 'Test-Path', 'Get-Date', 'Get-Random', 'Invoke-Expression')

    function Get-TestModuleAst {
        # Parses one reference module file; throws on a parse error.
        param([string] $Name)
        $tokens = $null
        $errors = $null
        $ast = [System.Management.Automation.Language.Parser]::ParseFile((Join-Path -Path $script:LibRoot -ChildPath $Name), [ref] $tokens, [ref] $errors)
        if (@($errors).Count -gt 0) { throw "Parse error in ${Name}: $($errors[0].Message)" }
        return $ast
    }

    function Get-TestScriptAst {
        # Parses an in-memory script text for a positive control.
        param([string] $Text)
        $tokens = $null
        $errors = $null
        return [System.Management.Automation.Language.Parser]::ParseInput($Text, [ref] $tokens, [ref] $errors)
    }

    function Get-TestBoundaryViolation {
        # Returns one text per boundary violation in Ast; AllowContext permits $Context references.
        param([System.Management.Automation.Language.Ast] $Ast, [switch] $AllowContext)
        $violation = [System.Collections.Generic.List[string]]::new()
        foreach ($node in $Ast.FindAll({ $true }, $true)) {
            if ($node -is [System.Management.Automation.Language.CommandAst]) {
                $name = [string] $node.GetCommandName()
                if ($script:ForbiddenCommand -contains $name) { $violation.Add("command $name") }
                if ($name -ieq 'Invoke-DocsProcess') { $violation.Add('command Invoke-DocsProcess') }
                if ($name -ieq 'Import-Module' -and $node.Extent.Text -match 'Docs(?:Ledger|Analyzer|Inventory)') { $violation.Add("import $($node.Extent.Text)") }
            } elseif ($node -is [System.Management.Automation.Language.TypeExpressionAst] -or $node -is [System.Management.Automation.Language.TypeConstraintAst]) {
                $typeName = ([string] $node.TypeName.FullName) -replace '^System\.', ''
                if ($typeName -ieq 'IO.File' -or $typeName -ieq 'IO.Directory') { $violation.Add("type $($node.TypeName.FullName)") }
            } elseif ($node -is [System.Management.Automation.Language.VariableExpressionAst]) {
                if (-not $AllowContext -and $node.VariablePath.UserPath -ieq 'Context') { $violation.Add('variable $Context') }
            } elseif ($node -is [System.Management.Automation.Language.MemberExpressionAst]) {
                if ($node.Member -is [System.Management.Automation.Language.StringConstantExpressionAst] -and $node.Member.Value -ieq 'InvokeProcess') { $violation.Add('member InvokeProcess') }
            }
        }
        return [string[]] $violation.ToArray()
    }

    function Get-TestStringConstant {
        # Returns the values of every string constant in Ast.
        param([System.Management.Automation.Language.Ast] $Ast)
        return [string[]] @($Ast.FindAll({ param($Node) $Node -is [System.Management.Automation.Language.StringConstantExpressionAst] }, $true) | ForEach-Object { [string] $_.Value })
    }

    function Get-TestPageCodeArgument {
        # Returns every string-constant -Code argument beginning DOCS_PAGE_ in Ast.
        param([System.Management.Automation.Language.Ast] $Ast)
        $found = [System.Collections.Generic.List[string]]::new()
        foreach ($command in $Ast.FindAll({ param($Node) $Node -is [System.Management.Automation.Language.CommandAst] }, $true)) {
            $elements = @($command.CommandElements)
            for ($index = 0; $index -lt $elements.Count; $index++) {
                $element = $elements[$index]
                if ($element -isnot [System.Management.Automation.Language.CommandParameterAst] -or $element.ParameterName -ine 'Code') { continue }
                $argument = if ($null -ne $element.Argument) { $element.Argument } elseif ($index + 1 -lt $elements.Count) { $elements[$index + 1] } else { $null }
                if ($argument -is [System.Management.Automation.Language.StringConstantExpressionAst] -and $argument.Value.StartsWith('DOCS_PAGE_', [System.StringComparison]::Ordinal)) { $found.Add($argument.Value) }
            }
        }
        return [string[]] $found.ToArray()
    }

    function Get-TestSchemaPattern {
        # Collects every pattern string reachable from Node, resolving docs common $defs references.
        param([AllowNull()] [object] $Node, [System.Collections.IDictionary] $CommonDefs, [System.Collections.Generic.HashSet[string]] $Visited, [System.Collections.Generic.List[string]] $Pattern)
        if ($Node -is [System.Collections.IDictionary]) {
            foreach ($key in @($Node.Keys)) {
                $value = $Node[$key]
                if ([string] $key -ceq 'pattern' -and $value -is [string]) { $Pattern.Add($value); continue }
                if ([string] $key -ceq '$ref' -and $value -is [string]) {
                    $match = [regex]::Match($value, '(?:\Aurn:drm-copilot:docs:1\.0\.0:common)?#/\$defs/(?<name>[^/]+)\z')
                    if ($match.Success -and $Visited.Add($match.Groups['name'].Value)) {
                        Get-TestSchemaPattern -Node $CommonDefs[$match.Groups['name'].Value] -CommonDefs $CommonDefs -Visited $Visited -Pattern $Pattern
                    }
                    continue
                }
                Get-TestSchemaPattern -Node $value -CommonDefs $CommonDefs -Visited $Visited -Pattern $Pattern
            }
        } elseif ($Node -is [System.Collections.IEnumerable] -and $Node -isnot [string]) {
            foreach ($item in $Node) { Get-TestSchemaPattern -Node $item -CommonDefs $CommonDefs -Visited $Visited -Pattern $Pattern }
        }
    }

    function Get-TestSeededDescribe {
        # Returns the names of Describe blocks that contain an It named with '(seed <Seed>)' and a -ForEach.
        param([string] $Path)
        $tokens = $null
        $errors = $null
        $ast = [System.Management.Automation.Language.Parser]::ParseFile($Path, [ref] $tokens, [ref] $errors)
        $names = [System.Collections.Generic.List[string]]::new()
        foreach ($describe in $ast.FindAll({ param($Node) $Node -is [System.Management.Automation.Language.CommandAst] -and $Node.GetCommandName() -ceq 'Describe' }, $true)) {
            $title = @($describe.CommandElements)[1]
            if ($title -isnot [System.Management.Automation.Language.StringConstantExpressionAst]) { continue }
            $seeded = $describe.FindAll({
                    param($Node)
                    $Node -is [System.Management.Automation.Language.CommandAst] -and $Node.GetCommandName() -ceq 'It' -and $Node.Extent.Text.Contains('(seed <Seed>)') -and $Node.Extent.Text.Contains('-ForEach')
                }, $true)
            if (@($seeded).Count -gt 0) { $names.Add($title.Value) }
        }
        return [string[]] $names.ToArray()
    }
}

AfterAll {
    Get-Module -Name 'Docs*', 'DiscoveryEncoding' | Remove-Module -Force -ErrorAction SilentlyContinue
}

Describe 'reference module set' {
    It 'scans every DocsReference module present in the docs library' {
        # Act
        [string[]] $onDisk = @(Get-ChildItem -LiteralPath $script:LibRoot -Filter 'DocsReference*.psm1' -File | ForEach-Object { $_.Name })
        [Array]::Sort($onDisk, [System.StringComparer]::Ordinal)

        # Assert
        $onDisk | Should -Be $script:ModuleName
    }
}

Describe 'reference module boundary' {
    It 'finds no filesystem, clock, randomness, process or excluded-import use in <Name>' -ForEach @(
        @{ Name = 'DocsReferenceFrontMatter.psm1' }
        @{ Name = 'DocsReferenceMarkers.psm1' }
        @{ Name = 'DocsReferencePlan.psm1' }
        @{ Name = 'DocsReferenceRender.psm1' }
        @{ Name = 'DocsReferenceReport.psm1' }
        @{ Name = 'DocsReferenceSplit.psm1' }
        @{ Name = 'DocsReferenceWriter.psm1' }
    ) {
        # Act
        $violation = Get-TestBoundaryViolation -Ast (Get-TestModuleAst -Name $Name) -AllowContext:($Name -ceq $script:CommandModule)

        # Assert
        $violation | Should -BeNullOrEmpty
    }

    It 'detects every violation class in an in-memory positive control' {
        # Arrange
        $text = @(
            'Set-Content -Path x -Value y'
            'Get-Date'
            '[System.IO.File]::Exists("x")'
            '[IO.Directory]::GetFiles("x")'
            '$Context.ReadText'
            'Import-Module -Name (Join-Path -Path $PSScriptRoot -ChildPath "DocsLedgerStore.psm1")'
            '$item.InvokeProcess'
            'Invoke-DocsProcess -FilePath x'
        ) -join "`n"

        # Act
        $violation = Get-TestBoundaryViolation -Ast (Get-TestScriptAst -Text $text)

        # Assert
        $violation | Should -Contain 'command Set-Content'
        $violation | Should -Contain 'command Get-Date'
        $violation | Should -Contain 'type System.IO.File'
        $violation | Should -Contain 'type IO.Directory'
        $violation | Should -Contain 'variable $Context'
        @($violation | Where-Object { $_.StartsWith('import ') }).Count | Should -Be 1
        $violation | Should -Contain 'member InvokeProcess'
        $violation | Should -Contain 'command Invoke-DocsProcess'
    }
}

Describe 'reference module front-matter constants' {
    BeforeAll {
        $schemaRoot = Join-Path -Path $script:RepositoryRoot -ChildPath 'schemas/docs/v1'
        $pageSchema = (ConvertFrom-DocsJsonText -Text (Get-Content -LiteralPath (Join-Path -Path $schemaRoot -ChildPath 'page-metadata.schema.json') -Raw)).Value
        $commonSchema = (ConvertFrom-DocsJsonText -Text (Get-Content -LiteralPath (Join-Path -Path $schemaRoot -ChildPath 'common.schema.json') -Raw)).Value
        $pattern = [System.Collections.Generic.List[string]]::new()
        $visited = [System.Collections.Generic.HashSet[string]]::new([System.StringComparer]::Ordinal)
        foreach ($field in @('owner', 'audience', 'last_reviewed', 'surface_refs')) {
            Get-TestSchemaPattern -Node $pageSchema['properties'][$field] -CommonDefs $commonSchema['$defs'] -Visited $visited -Pattern $pattern
        }
        $script:FieldPattern = [string[]] @($pattern | Select-Object -Unique)
    }

    It 'collects at least one pattern from the page-metadata field definitions' {
        $script:FieldPattern.Count | Should -BeGreaterThan 0
    }

    It 'defines no string constant equal to a page-metadata field pattern in <Name>' -ForEach @(
        @{ Name = 'DocsReferenceFrontMatter.psm1' }
        @{ Name = 'DocsReferenceMarkers.psm1' }
        @{ Name = 'DocsReferencePlan.psm1' }
        @{ Name = 'DocsReferenceRender.psm1' }
        @{ Name = 'DocsReferenceReport.psm1' }
        @{ Name = 'DocsReferenceSplit.psm1' }
        @{ Name = 'DocsReferenceWriter.psm1' }
    ) {
        # Act
        [string[]] $constant = Get-TestStringConstant -Ast (Get-TestModuleAst -Name $Name)

        # Assert
        @($constant | Where-Object { $script:FieldPattern -ccontains $_ }) | Should -BeNullOrEmpty
    }

    It 'detects a field pattern defined as a string constant in an in-memory positive control' {
        # Arrange
        $text = '$p = ' + "'" + $script:FieldPattern[0].Replace("'", "''") + "'"

        # Act
        [string[]] $constant = Get-TestStringConstant -Ast (Get-TestScriptAst -Text $text)

        # Assert
        @($constant | Where-Object { $script:FieldPattern -ccontains $_ }).Count | Should -Be 1
    }
}

Describe 'reference module finding codes' {
    It 'passes no DOCS_PAGE_ string constant as a -Code argument in <Name>' -ForEach @(
        @{ Name = 'DocsReferenceFrontMatter.psm1' }
        @{ Name = 'DocsReferenceMarkers.psm1' }
        @{ Name = 'DocsReferencePlan.psm1' }
        @{ Name = 'DocsReferenceRender.psm1' }
        @{ Name = 'DocsReferenceReport.psm1' }
        @{ Name = 'DocsReferenceSplit.psm1' }
        @{ Name = 'DocsReferenceWriter.psm1' }
    ) {
        Get-TestPageCodeArgument -Ast (Get-TestModuleAst -Name $Name) | Should -BeNullOrEmpty
    }

    It 'detects a DOCS_PAGE_ code passed to New-DocsFinding in an in-memory positive control' {
        # Arrange
        $text = "New-DocsFinding -Code 'DOCS_PAGE_ORPHAN' -Severity 'error' -Message 'm' -NextAction 'n'`nNew-DocsFinding -Code:'DOCS_PAGE_TOO_LARGE' -Severity 'error' -Message 'm' -NextAction 'n'"

        # Act
        [string[]] $found = Get-TestPageCodeArgument -Ast (Get-TestScriptAst -Text $text)

        # Assert
        $found | Should -Be @('DOCS_PAGE_ORPHAN', 'DOCS_PAGE_TOO_LARGE')
    }
}

Describe 'reference property-test inventory' {
    It 'has a seeded property test for every exported pure function of the reference modules' {
        # Arrange
        $pure = [System.Collections.Generic.List[string]]::new()
        foreach ($name in $script:ModuleName) {
            $module = Import-Module -Name (Join-Path -Path $script:LibRoot -ChildPath $name) -Force -PassThru -ErrorAction Stop
            foreach ($function in @($module.ExportedFunctions.Keys)) { if ($script:CommandFunction -cnotcontains $function) { $pure.Add([string] $function) } }
        }
        $suite = @(Get-ChildItem -LiteralPath $PSScriptRoot -Filter 'DocsReference*.Properties.Tests.ps1' -File) + @(Get-Item -LiteralPath (Join-Path -Path $PSScriptRoot -ChildPath 'DocsReferenceRender.Tests.ps1'))

        # Act
        [string[]] $seeded = @($suite | ForEach-Object { Get-TestSeededDescribe -Path $_.FullName })
        [string[]] $missing = @($pure | Where-Object { $seeded -cnotcontains $_ })

        # Assert
        $pure.Count | Should -Be 24
        $missing | Should -BeNullOrEmpty
    }
}
