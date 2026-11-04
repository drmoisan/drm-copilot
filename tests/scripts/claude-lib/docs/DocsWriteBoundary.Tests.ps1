#Requires -Version 7.0
#Requires -Modules @{ ModuleName = 'Pester'; ModuleVersion = '5.0.0' }

<#
.SYNOPSIS
    Write-boundary proof for .claude/lib/docs: the single filesystem write primitive and the
    single caller of the WriteText scriptblock.

.DESCRIPTION
    Parses every .ps1 and .psm1 under .claude/lib/docs with the PowerShell parser (the files are
    read once into memory) and asserts, through the pure AST helper Find-DocsWritePrimitive:
    no filesystem write primitive outside Write-DocsFileText in Invoke-DocsCommand.ps1; a
    scriptblock named WriteText is invoked only inside Invoke-DocsArtifactWrite; among the 1023
    modules only DocsLedgerCommands.psm1 accesses the WriteText member; and
    Invoke-DocsArtifactWrite is referenced only from DocsLedgerCommands.psm1. A positive control
    proves the helper over an in-memory source string. No file is written.
#>

BeforeAll {
    $script:LibraryRoot = [System.IO.Path]::GetFullPath((Join-Path -Path $PSScriptRoot -ChildPath '../../../../.claude/lib/docs'))
    # Allowlist: the only write primitive of the library and the reason it is permitted.
    $script:Allowlist = @{ 'Invoke-DocsCommand.ps1/Write-DocsFileText' = 'init create-only and explicit overwrite' }
    $script:WriteCommand = @('Set-Content', 'Add-Content', 'Out-File', 'New-Item', 'Copy-Item', 'Move-Item', 'Remove-Item', 'Tee-Object', 'Export-Csv', 'Export-Clixml')
    $script:WriteType = @('System.IO.File', 'IO.File', 'System.IO.FileStream', 'IO.FileStream', 'System.IO.StreamWriter', 'IO.StreamWriter', 'System.IO.Directory', 'IO.Directory')
    $script:WriteMember = @('WriteAllText', 'WriteAllBytes', 'WriteAllLines', 'AppendAllText', 'AppendAllLines', 'AppendText', 'Create', 'CreateText', 'CreateDirectory', 'OpenWrite', 'Delete', 'Copy', 'Move', 'Replace', 'new')
    $script:Module1023 = @('DocsLedger.psm1', 'DocsLedgerRules.psm1', 'DocsParity.psm1', 'DocsEvidencePins.psm1', 'DocsStaleness.psm1', 'DocsReceipt.psm1', 'DocsValidation.psm1', 'DocsLedgerMutation.psm1', 'DocsCoverageReport.psm1', 'DocsLedgerCommands.psm1')

    [string[]] $names = @(Get-ChildItem -LiteralPath $script:LibraryRoot -File | Where-Object { $_.Extension -ceq '.ps1' -or $_.Extension -ceq '.psm1' } | ForEach-Object { $_.Name })
    [Array]::Sort($names, [System.StringComparer]::Ordinal)
    $script:Source = [ordered]@{}
    foreach ($name in $names) { $script:Source[$name] = [System.IO.File]::ReadAllText((Join-Path -Path $script:LibraryRoot -ChildPath $name)) }

    function Get-DocsBoundaryFunctionName {
        # The name of the innermost function definition containing the node, or '' at script scope.
        param([System.Management.Automation.Language.Ast] $Node)
        $current = $Node
        while ($null -ne $current) {
            if ($current -is [System.Management.Automation.Language.FunctionDefinitionAst]) { return [string] $current.Name }
            $current = $current.Parent
        }
        ''
    }

    function Get-DocsBoundaryAst {
        param([string] $SourceText, [string] $Path)
        $tokens = $null
        $errors = $null
        $ast = [System.Management.Automation.Language.Parser]::ParseInput($SourceText, $Path, [ref] $tokens, [ref] $errors)
        if (@($errors).Count -gt 0) { throw "The source '$Path' does not parse: $($errors[0].Message)" }
        $ast
    }

    function Find-DocsWritePrimitive {
        # Pure: returns one record {Path, Line, Kind, Name, Function} per filesystem write primitive in SourceText.
        # The helpers emit their records to the pipeline (no comma) so foreach collection over many files flattens them.
        param([string] $SourceText, [string] $Path)
        $ast = Get-DocsBoundaryAst -SourceText $SourceText -Path $Path
        $records = [System.Collections.Generic.List[object]]::new()
        foreach ($node in $ast.FindAll({ param($item) $item -is [System.Management.Automation.Language.CommandAst] }, $true)) {
            $name = [string] $node.GetCommandName()
            if ($script:WriteCommand -ccontains $name) { $records.Add([pscustomobject]@{ Path = $Path; Line = $node.Extent.StartLineNumber; Kind = 'command'; Name = $name; Function = (Get-DocsBoundaryFunctionName -Node $node) }) }
        }
        foreach ($node in $ast.FindAll({ param($item) $item -is [System.Management.Automation.Language.MemberExpressionAst] }, $true)) {
            $target = $node.Expression
            if ($target -isnot [System.Management.Automation.Language.TypeExpressionAst]) { continue }
            $typeName = [string] $target.TypeName.FullName
            $member = [string] $node.Member.Extent.Text
            if ($script:WriteType -ccontains $typeName -and $script:WriteMember -ccontains $member) {
                $records.Add([pscustomobject]@{ Path = $Path; Line = $node.Extent.StartLineNumber; Kind = 'member'; Name = "[$typeName]::$member"; Function = (Get-DocsBoundaryFunctionName -Node $node) })
            }
        }
        foreach ($node in $ast.FindAll({ param($item) $item -is [System.Management.Automation.Language.FileRedirectionAst] }, $true)) {
            $records.Add([pscustomobject]@{ Path = $Path; Line = $node.Extent.StartLineNumber; Kind = 'redirection'; Name = $node.Extent.Text; Function = (Get-DocsBoundaryFunctionName -Node $node) })
        }
        $records.ToArray()
    }

    function Find-DocsVariableInvocation {
        # Pure: every '& $<Name>' invocation (the command element is the named variable) with its enclosing function.
        param([string] $SourceText, [string] $Path, [string] $VariableName)
        $ast = Get-DocsBoundaryAst -SourceText $SourceText -Path $Path
        $records = [System.Collections.Generic.List[object]]::new()
        foreach ($node in $ast.FindAll({ param($item) $item -is [System.Management.Automation.Language.CommandAst] }, $true)) {
            $first = $node.CommandElements[0]
            if ($first -is [System.Management.Automation.Language.VariableExpressionAst] -and [string] $first.VariablePath.UserPath -ceq $VariableName) {
                $records.Add([pscustomobject]@{ Path = $Path; Line = $node.Extent.StartLineNumber; Function = (Get-DocsBoundaryFunctionName -Node $node) })
            }
        }
        $records.ToArray()
    }

    function Find-DocsMemberAccess {
        # Pure: every '<expression>.<MemberName>' member access with its enclosing function.
        param([string] $SourceText, [string] $Path, [string] $MemberName)
        $ast = Get-DocsBoundaryAst -SourceText $SourceText -Path $Path
        $records = [System.Collections.Generic.List[object]]::new()
        foreach ($node in $ast.FindAll({ param($item) $item -is [System.Management.Automation.Language.MemberExpressionAst] }, $true)) {
            if ([string] $node.Member.Extent.Text -ceq $MemberName) { $records.Add([pscustomobject]@{ Path = $Path; Line = $node.Extent.StartLineNumber; Function = (Get-DocsBoundaryFunctionName -Node $node) }) }
        }
        $records.ToArray()
    }

    function Find-DocsCommandReference {
        # Pure: every command invocation of CommandName with its enclosing function.
        param([string] $SourceText, [string] $Path, [string] $CommandName)
        $ast = Get-DocsBoundaryAst -SourceText $SourceText -Path $Path
        $records = [System.Collections.Generic.List[object]]::new()
        foreach ($node in $ast.FindAll({ param($item) $item -is [System.Management.Automation.Language.CommandAst] }, $true)) {
            if ([string] $node.GetCommandName() -ceq $CommandName) { $records.Add([pscustomobject]@{ Path = $Path; Line = $node.Extent.StartLineNumber; Function = (Get-DocsBoundaryFunctionName -Node $node) }) }
        }
        $records.ToArray()
    }
}

AfterAll {
    Remove-Module -Name 'Docs*', 'DiscoveryEncoding' -Force -ErrorAction SilentlyContinue
}

Describe 'Write boundary of .claude/lib/docs' {
    It 'reads every library file once' {
        $script:Source.Count | Should -BeGreaterOrEqual 18
        @($script:Source.Keys) | Should -Contain 'Invoke-DocsCommand.ps1'
        foreach ($name in $script:Module1023) { @($script:Source.Keys) | Should -Contain $name }
    }

    It 'finds no filesystem write primitive outside Write-DocsFileText' {
        # Act
        $primitives = @(foreach ($name in $script:Source.Keys) { Find-DocsWritePrimitive -SourceText $script:Source[$name] -Path $name })

        # Assert
        $outside = @($primitives | Where-Object { -not $script:Allowlist.ContainsKey($_.Path + '/' + $_.Function) })
        @($outside | ForEach-Object { "$($_.Path):$($_.Line) $($_.Kind) $($_.Name) in '$($_.Function)'" }) | Should -Be @()
        $allowed = @($primitives | Where-Object { $script:Allowlist.ContainsKey($_.Path + '/' + $_.Function) })
        $allowed.Count | Should -BeGreaterThan 0 -Because 'Write-DocsFileText holds the FileStream write'
        @($allowed | ForEach-Object { $_.Path } | Sort-Object -Unique) | Should -Be @('Invoke-DocsCommand.ps1')
        @($allowed | ForEach-Object { $_.Function } | Sort-Object -Unique) | Should -Be @('Write-DocsFileText')
        $script:Allowlist['Invoke-DocsCommand.ps1/Write-DocsFileText'] | Should -BeExactly 'init create-only and explicit overwrite'
    }

    It 'invokes a WriteText scriptblock only inside Invoke-DocsArtifactWrite' {
        # Act
        $invocations = @(foreach ($name in $script:Source.Keys) { Find-DocsVariableInvocation -SourceText $script:Source[$name] -Path $name -VariableName 'WriteText' })

        # Assert
        $invocations.Count | Should -BeGreaterThan 0 -Because 'Invoke-DocsArtifactWrite invokes the scriptblock'
        @($invocations | ForEach-Object { "$($_.Path)/$($_.Function)" } | Sort-Object -Unique) | Should -Be @('DocsLedgerMutation.psm1/Invoke-DocsArtifactWrite')
    }

    It 'accesses the WriteText member only in DocsLedgerCommands.psm1 among 1023 modules' {
        # Act
        $accesses = @(foreach ($name in $script:Module1023) { Find-DocsMemberAccess -SourceText $script:Source[$name] -Path $name -MemberName 'WriteText' })

        # Assert
        $accesses.Count | Should -BeGreaterThan 0 -Because 'the update-ledger and validate commands pass the member to the boundary'
        @($accesses | ForEach-Object { $_.Path } | Sort-Object -Unique) | Should -Be @('DocsLedgerCommands.psm1')
        @($accesses | ForEach-Object { $_.Function } | Sort-Object -Unique) | Should -Be @('Invoke-DocsUpdateLedgerCommand', 'Invoke-DocsValidateCommand')
        @(Find-DocsVariableInvocation -SourceText $script:Source['DocsLedgerCommands.psm1'] -Path 'DocsLedgerCommands.psm1' -VariableName 'WriteText').Count | Should -Be 0 -Because 'the command module passes the member on and never invokes it'
    }

    It 'references Invoke-DocsArtifactWrite only from DocsLedgerCommands.psm1' {
        # Act
        $references = @(foreach ($name in $script:Source.Keys) { Find-DocsCommandReference -SourceText $script:Source[$name] -Path $name -CommandName 'Invoke-DocsArtifactWrite' })

        # Assert
        $references.Count | Should -BeGreaterThan 0
        @($references | ForEach-Object { $_.Path } | Sort-Object -Unique) | Should -Be @('DocsLedgerCommands.psm1')
        @($references | ForEach-Object { $_.Function } | Sort-Object -Unique) | Should -Be @('Invoke-DocsUpdateLedgerCommand', 'Invoke-DocsValidateCommand')
    }

    It 'reports a write call in an in-memory source string' {
        # Arrange
        $text = @'
function Save-Thing {
    param($Path)
    Set-Content -LiteralPath $Path -Value 'x'
    [System.IO.File]::WriteAllText($Path, 'y')
    'z' > $Path
    $stream = [System.IO.FileStream]::new($Path, 'Create')
    $stream.Dispose()
}
function Read-Thing { param($Path) [System.IO.File]::ReadAllText($Path); Get-Content -LiteralPath $Path }
function Use-Writer { param([scriptblock] $WriteText, $Context) & $WriteText 'a' 'b' 'create'; $member = $Context.WriteText; Invoke-DocsArtifactWrite -Plan @() }
'@

        # Act
        $primitives = @(Find-DocsWritePrimitive -SourceText $text -Path 'memory.ps1')
        $invocations = @(Find-DocsVariableInvocation -SourceText $text -Path 'memory.ps1' -VariableName 'WriteText')
        $accesses = @(Find-DocsMemberAccess -SourceText $text -Path 'memory.ps1' -MemberName 'WriteText')
        $references = @(Find-DocsCommandReference -SourceText $text -Path 'memory.ps1' -CommandName 'Invoke-DocsArtifactWrite')

        # Assert
        @($primitives | ForEach-Object { $_.Kind + ' ' + $_.Name }) | Should -Be @('command Set-Content', 'member [System.IO.File]::WriteAllText', 'member [System.IO.FileStream]::new', 'redirection > $Path')
        @($primitives | ForEach-Object { $_.Function } | Sort-Object -Unique) | Should -Be @('Save-Thing')
        @($primitives | Where-Object { $_.Function -ceq 'Read-Thing' }).Count | Should -Be 0 -Because 'reads are not write primitives'
        $invocations.Count | Should -Be 1
        $invocations[0].Function | Should -BeExactly 'Use-Writer'
        $accesses.Count | Should -Be 1
        $references.Count | Should -Be 1
        { Find-DocsWritePrimitive -SourceText 'function {' -Path 'broken.ps1' } | Should -Throw
    }
}
