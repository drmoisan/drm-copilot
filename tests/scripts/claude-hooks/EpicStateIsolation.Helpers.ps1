<#
.SYNOPSIS
    Structural helpers for the epic-state isolation guard (issues #709 and #690).

.DESCRIPTION
    Dot-sourced by enforce-gate-suites.EpicStateIsolation.Tests.ps1. The functions parse a
    suite's AST and report whether its outermost BeforeAll isolates both run-checkpoint
    reads: after the hook dot-source, an Import-Module of EpicScopeResolution.psm1 without
    -Force followed by a $null Mock of Get-EpicScopeCheckpointText in module scope
    EpicScopeResolution, and an Import-Module of WorktreeRunResolution.psm1 without -Force
    followed by a $null Mock of Get-WorktreeRunCheckpointText in module scope
    WorktreeRunResolution.

    Every function is pure except Get-EpicStateIsolationSuiteFinding, which reads one
    committed suite file located from the supplied repository root. No function creates a
    file, runs a process, or reads gitignored state.
#>

function Get-EpicStateIsolationCommandDepth {
    # Pure: the number of CommandAst ancestors of an AST node.
    [OutputType([int])]
    param([Parameter(Mandatory)] [System.Management.Automation.Language.Ast] $Node)
    $depth = 0
    $parent = $Node.Parent
    while ($null -ne $parent) {
        if ($parent -is [System.Management.Automation.Language.CommandAst]) { $depth++ }
        $parent = $parent.Parent
    }
    return $depth
}

function Get-EpicStateIsolationElementText {
    # Pure: the literal value of a command element, or its source text.
    [OutputType([string])]
    param([AllowNull()] [System.Management.Automation.Language.Ast] $Element)
    if ($null -eq $Element) { return $null }
    if ($Element -is [System.Management.Automation.Language.StringConstantExpressionAst]) { return $Element.Value }
    return $Element.Extent.Text
}

function Get-EpicStateIsolationMockBinding {
    # Pure: the CommandName, ModuleName, and MockWith elements of a Mock command,
    # bound by name or by position (CommandName is position 0, MockWith position 1).
    [OutputType([hashtable])]
    param([Parameter(Mandatory)] [System.Management.Automation.Language.CommandAst] $Command)
    $valueParameters = @('CommandName', 'ModuleName', 'MockWith', 'ParameterFilter', 'RemoveParameterType', 'RemoveParameterValidation')
    $named = @{}
    $positional = [System.Collections.Generic.List[System.Management.Automation.Language.Ast]]::new()
    $elements = $Command.CommandElements
    $index = 1
    while ($index -lt $elements.Count) {
        $element = $elements[$index]
        if ($element -is [System.Management.Automation.Language.CommandParameterAst]) {
            if ($null -ne $element.Argument) {
                $named[$element.ParameterName] = $element.Argument
            } elseif ($valueParameters -contains $element.ParameterName -and ($index + 1) -lt $elements.Count) {
                $index++
                $named[$element.ParameterName] = $elements[$index]
            } else {
                $named[$element.ParameterName] = $null
            }
        } else {
            $positional.Add($element)
        }
        $index++
    }
    $nextPosition = 0
    $target = $named['CommandName']
    if (-not $named.ContainsKey('CommandName') -and $positional.Count -gt $nextPosition) {
        $target = $positional[$nextPosition]
        $nextPosition++
    }
    $body = $named['MockWith']
    if (-not $named.ContainsKey('MockWith') -and $positional.Count -gt $nextPosition) {
        $body = $positional[$nextPosition]
    }
    return @{
        CommandName   = Get-EpicStateIsolationElementText -Element $target
        HasModuleName = $named.ContainsKey('ModuleName')
        ModuleName    = Get-EpicStateIsolationElementText -Element $named['ModuleName']
        MockWith      = $body
    }
}

function Test-EpicStateIsolationNullBody {
    # Pure: true when a Mock body is a script block holding exactly one $null statement.
    [OutputType([bool])]
    param([AllowNull()] [System.Management.Automation.Language.Ast] $Body)
    if ($Body -isnot [System.Management.Automation.Language.ScriptBlockExpressionAst]) { return $false }
    $block = $Body.ScriptBlock
    if ($null -ne $block.ParamBlock -or $null -ne $block.BeginBlock -or $null -ne $block.ProcessBlock -or $null -eq $block.EndBlock) { return $false }
    $statements = @($block.EndBlock.Statements)
    return ($statements.Count -eq 1 -and $statements[0].Extent.Text.Trim() -ceq '$null')
}

function Get-EpicStateIsolationPairFinding {
    <#
        Pure: the findings for one import-and-mock pair among the commands of an outermost
        BeforeAll: the $null Mock of MockCommand in module scope ModuleName, preceded by an
        Import-Module of ModuleFile without -Force, both after the hook dot-source.
    #>
    [OutputType([string])]
    param(
        [Parameter(Mandatory)] [AllowEmptyCollection()] [object[]] $Commands,
        [AllowNull()] [System.Management.Automation.Language.CommandAst] $DotSource,
        [Parameter(Mandatory)] [string] $MockCommand,
        [Parameter(Mandatory)] [string] $ModuleName,
        [Parameter(Mandatory)] [string] $ModuleFile
    )

    $mock = $null
    $binding = $null
    foreach ($command in $Commands) {
        if ($command.GetCommandName() -ne 'Mock') { continue }
        $candidate = Get-EpicStateIsolationMockBinding -Command $command
        if ($candidate.CommandName -eq $MockCommand) {
            $mock = $command
            $binding = $candidate
            break
        }
    }
    $filePattern = [regex]::Escape($ModuleFile)
    $import = $Commands | Where-Object {
        $_.GetCommandName() -eq 'Import-Module' -and
        (@($_.CommandElements | Select-Object -Skip 1 | ForEach-Object { $_.Extent.Text }) -join ' ') -match $filePattern
    } | Select-Object -First 1

    if ($null -eq $mock) {
        "Mock of $MockCommand missing from outermost BeforeAll"
    } else {
        if (-not $binding.HasModuleName -or $binding.ModuleName -ne $ModuleName) { "Mock lacks -ModuleName $ModuleName" }
        if (-not (Test-EpicStateIsolationNullBody -Body $binding.MockWith)) { 'Mock body is not exactly $null' }
    }
    if ($null -eq $import) {
        "Import-Module of $ModuleFile missing from outermost BeforeAll"
    } elseif (@($import.CommandElements | Where-Object { $_ -is [System.Management.Automation.Language.CommandParameterAst] -and $_.ParameterName -eq 'Force' }).Count -gt 0) {
        "Import-Module of $ModuleFile uses -Force"
    }
    if ($null -ne $mock -and $null -ne $import) {
        $ordered = $null -ne $DotSource -and
        $DotSource.Extent.StartOffset -lt $import.Extent.StartOffset -and
        $import.Extent.StartOffset -lt $mock.Extent.StartOffset
        if (-not $ordered) { 'hook dot-source, Import-Module, Mock order violated' }
    }
}

function Get-EpicStateIsolationFinding {
    <#
        Pure: the epic-state isolation findings for one parsed suite, empty when the
        suite's outermost BeforeAll dot-sources the hook, then carries both the
        EpicScopeResolution pair and the WorktreeRunResolution pair (issue #690).
    #>
    [OutputType([string])]
    param([Parameter(Mandatory)] [System.Management.Automation.Language.ScriptBlockAst] $Ast)

    $isCommand = { param($node) $node -is [System.Management.Automation.Language.CommandAst] }
    $outermost = @($Ast.FindAll({ param($node) $node -is [System.Management.Automation.Language.CommandAst] -and $node.GetCommandName() -eq 'BeforeAll' }, $true) |
            Sort-Object -Property @{ Expression = { Get-EpicStateIsolationCommandDepth -Node $_ } }, @{ Expression = { $_.Extent.StartOffset } } |
                Select-Object -First 1)
    $blockExpression = if ($outermost.Count -eq 1) {
        @($outermost[0].CommandElements | Where-Object { $_ -is [System.Management.Automation.Language.ScriptBlockExpressionAst] }) | Select-Object -First 1
    }
    if ($null -eq $blockExpression) {
        'no outermost BeforeAll'
        return
    }

    $commands = @($blockExpression.ScriptBlock.FindAll($isCommand, $true) | Sort-Object -Property { $_.Extent.StartOffset })
    $dotSource = $commands | Where-Object { $_.InvocationOperator -eq [System.Management.Automation.Language.TokenKind]::Dot } | Select-Object -First 1

    Get-EpicStateIsolationPairFinding -Commands $commands -DotSource $dotSource -MockCommand 'Get-EpicScopeCheckpointText' -ModuleName 'EpicScopeResolution' -ModuleFile 'EpicScopeResolution.psm1'
    Get-EpicStateIsolationPairFinding -Commands $commands -DotSource $dotSource -MockCommand 'Get-WorktreeRunCheckpointText' -ModuleName 'WorktreeRunResolution' -ModuleFile 'WorktreeRunResolution.psm1'
}

function Get-EpicStateIsolationSuiteFinding {
    # Parse one committed suite, located from the repository root, and return its
    # findings prefixed by the repository-relative path.
    [OutputType([string])]
    param(
        [Parameter(Mandatory)] [string] $RepoRoot,
        [Parameter(Mandatory)] [string] $RelativePath
    )
    $fullPath = Join-Path $RepoRoot $RelativePath
    if (-not (Test-Path -LiteralPath $fullPath -PathType Leaf)) {
        "suite file not found: $RelativePath"
        return
    }
    $tokens = $null
    $errors = $null
    $ast = [System.Management.Automation.Language.Parser]::ParseFile($fullPath, [ref] $tokens, [ref] $errors)
    if (@($errors).Count -gt 0) {
        "${RelativePath}: parse error: $($errors[0].Message)"
        return
    }
    foreach ($finding in @(Get-EpicStateIsolationFinding -Ast $ast)) {
        "${RelativePath}: $finding"
    }
}
