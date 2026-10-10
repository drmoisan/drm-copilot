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

function Test-EpicStateIsolationHookLiteral {
    # Pure: true when an AST holds a string literal that names a hook script, hooks/<name>.ps1,
    # other than the EpicStateIsolation helper files and other than a test file path.
    [OutputType([bool])]
    param([AllowNull()] [System.Management.Automation.Language.Ast] $Node)
    if ($null -eq $Node) { return $false }
    $isLiteral = {
        param($candidate)
        $candidate -is [System.Management.Automation.Language.StringConstantExpressionAst] -or
        $candidate -is [System.Management.Automation.Language.ExpandableStringExpressionAst]
    }
    foreach ($literal in $Node.FindAll($isLiteral, $true)) {
        foreach ($match in [regex]::Matches([string]$literal.Value, '(?<![A-Za-z0-9_-])hooks/(?<name>[A-Za-z0-9._-]+\.ps1)')) {
            $name = $match.Groups['name'].Value
            if ($name.StartsWith('EpicStateIsolation.', [System.StringComparison]::Ordinal)) { continue }
            if ($name.EndsWith('.Tests.ps1', [System.StringComparison]::Ordinal)) { continue }
            return $true
        }
    }
    return $false
}

function Get-EpicStateIsolationVariableKey {
    # Pure: a variable name without its scope qualifier, lower-cased, for binding comparison.
    [OutputType([string])]
    param([Parameter(Mandatory)] [string] $UserPath)
    $separator = $UserPath.IndexOf(':')
    $name = if ($separator -ge 0) { $UserPath.Substring($separator + 1) } else { $UserPath }
    return $name.ToLowerInvariant()
}

function Test-EpicStateIsolationVariableBoundToHook {
    # Pure: true when the suite binds the named variable, by assignment or by a hashtable entry
    # with the same key name (the -ForEach data shape), to an expression holding a hook literal.
    [OutputType([bool])]
    param(
        [Parameter(Mandatory)] [System.Management.Automation.Language.Ast] $SuiteAst,
        [Parameter(Mandatory)] [string] $Key
    )
    $isAssignment = { param($candidate) $candidate -is [System.Management.Automation.Language.AssignmentStatementAst] }
    foreach ($assignment in $SuiteAst.FindAll($isAssignment, $true)) {
        $left = $assignment.Left
        if ($left -is [System.Management.Automation.Language.ConvertExpressionAst]) { $left = $left.Child }
        if ($left -isnot [System.Management.Automation.Language.VariableExpressionAst]) { continue }
        if ((Get-EpicStateIsolationVariableKey -UserPath $left.VariablePath.UserPath) -ne $Key) { continue }
        if (Test-EpicStateIsolationHookLiteral -Node $assignment.Right) { return $true }
    }
    $isHashtable = { param($candidate) $candidate -is [System.Management.Automation.Language.HashtableAst] }
    foreach ($table in $SuiteAst.FindAll($isHashtable, $true)) {
        foreach ($pair in $table.KeyValuePairs) {
            $keyText = Get-EpicStateIsolationElementText -Element $pair.Item1
            if ($null -eq $keyText -or $keyText.ToLowerInvariant() -ne $Key) { continue }
            if (Test-EpicStateIsolationHookLiteral -Node $pair.Item2) { return $true }
        }
    }
    return $false
}

function Get-EpicStateIsolationHookDotSource {
    <#
        Pure: the dot-source command that loads the hook. Order: (i) the dot-source whose argument
        holds a hooks/<name>.ps1 literal; (ii) otherwise the dot-source whose argument references a
        variable that the suite binds to such a literal; (iii) otherwise the first dot-source. The
        first in source order wins within a step. $null when there is no dot-source.
    #>
    [OutputType([System.Management.Automation.Language.CommandAst])]
    param(
        [AllowEmptyCollection()] [object[]] $DotSource,
        [Parameter(Mandatory)] [System.Management.Automation.Language.Ast] $SuiteAst
    )
    $candidates = @($DotSource)
    if ($candidates.Count -eq 0) { return $null }
    foreach ($candidate in $candidates) {
        if (Test-EpicStateIsolationHookLiteral -Node $candidate) { return $candidate }
    }
    $isVariable = { param($node) $node -is [System.Management.Automation.Language.VariableExpressionAst] }
    foreach ($candidate in $candidates) {
        foreach ($variable in $candidate.FindAll($isVariable, $true)) {
            $key = Get-EpicStateIsolationVariableKey -UserPath $variable.VariablePath.UserPath
            if (Test-EpicStateIsolationVariableBoundToHook -SuiteAst $SuiteAst -Key $key) { return $candidate }
        }
    }
    return $candidates[0]
}

function Get-EpicStateIsolationDirectCommand {
    # Pure: the commands of a script block that are neither inside a nested script block nor inside
    # a function body, so a Mock or Import-Module that never runs does not count as isolation.
    [OutputType([System.Management.Automation.Language.CommandAst])]
    param([Parameter(Mandatory)] [System.Management.Automation.Language.ScriptBlockAst] $Block)
    $isCommand = { param($node) $node -is [System.Management.Automation.Language.CommandAst] }
    foreach ($command in $Block.FindAll($isCommand, $true)) {
        $nested = $false
        $parent = $command.Parent
        while ($null -ne $parent -and -not [object]::ReferenceEquals($parent, $Block)) {
            if ($parent -is [System.Management.Automation.Language.ScriptBlockAst] -or
                $parent -is [System.Management.Automation.Language.ScriptBlockExpressionAst] -or
                $parent -is [System.Management.Automation.Language.FunctionDefinitionAst]) {
                $nested = $true
                break
            }
            $parent = $parent.Parent
        }
        if (-not $nested) { $command }
    }
}

function Test-EpicStateIsolationModulePathNode {
    # Pure: true when the node is, or contains, a string-constant or expandable-string element whose
    # value ends with the module file name after a separator (or is exactly that name). A string that
    # only contains the file name does not qualify.
    [OutputType([bool])]
    param(
        [AllowNull()] [System.Management.Automation.Language.Ast] $Node,
        [Parameter(Mandatory)] [string] $ModuleFile
    )
    if ($null -eq $Node) { return $false }
    $isLiteral = {
        param($candidate)
        $candidate -is [System.Management.Automation.Language.StringConstantExpressionAst] -or
        $candidate -is [System.Management.Automation.Language.ExpandableStringExpressionAst]
    }
    $pattern = '(^|[\\/])' + [regex]::Escape($ModuleFile) + '$'
    foreach ($literal in $Node.FindAll($isLiteral, $true)) {
        if ([regex]::IsMatch([string]$literal.Value, $pattern)) { return $true }
    }
    return $false
}

function Test-EpicStateIsolationModuleImport {
    # Pure: true when an Import-Module command names the module file in a positional or -Name/-Path
    # argument. Other value parameters (-Prefix, -ArgumentList, and similar) are skipped.
    [OutputType([bool])]
    param(
        [Parameter(Mandatory)] [System.Management.Automation.Language.CommandAst] $Command,
        [Parameter(Mandatory)] [string] $ModuleFile
    )
    $switchParameters = @('Force', 'Global', 'PassThru', 'DisableNameChecking', 'NoClobber', 'SkipEditionCheck', 'UseWindowsPowerShell', 'Verbose', 'Debug')
    $pathParameters = @('Name', 'Path')
    $elements = $Command.CommandElements
    $index = 1
    while ($index -lt $elements.Count) {
        $element = $elements[$index]
        if ($element -is [System.Management.Automation.Language.CommandParameterAst]) {
            if ($null -ne $element.Argument) {
                if ($pathParameters -contains $element.ParameterName -and (Test-EpicStateIsolationModulePathNode -Node $element.Argument -ModuleFile $ModuleFile)) { return $true }
            } elseif ($switchParameters -notcontains $element.ParameterName -and ($index + 1) -lt $elements.Count) {
                $index++
                if ($pathParameters -contains $element.ParameterName -and (Test-EpicStateIsolationModulePathNode -Node $elements[$index] -ModuleFile $ModuleFile)) { return $true }
            }
        } elseif (Test-EpicStateIsolationModulePathNode -Node $element -ModuleFile $ModuleFile) {
            return $true
        }
        $index++
    }
    return $false
}

function Get-EpicStateIsolationPairFinding {
    <#
        Pure: the findings for one import-and-mock pair among the commands of an outermost
        BeforeAll: the $null Mock of MockCommand in module scope ModuleName, preceded by an
        Import-Module of ModuleFile without -Force, both after the hook dot-source. A $null
        ModuleName marks a script-scope seam: the Mock carries no -ModuleName, no import is
        required, and the Mock follows the hook dot-source.
    #>
    [OutputType([string])]
    param(
        [Parameter(Mandatory)] [AllowEmptyCollection()] [object[]] $Commands,
        [AllowNull()] [System.Management.Automation.Language.CommandAst] $DotSource,
        [Parameter(Mandatory)] [string] $MockCommand,
        [AllowNull()] [string] $ModuleName,
        [AllowNull()] [string] $ModuleFile
    )

    $scriptScope = [string]::IsNullOrEmpty($ModuleName)
    $mocks = [System.Collections.Generic.List[object]]::new()
    foreach ($command in $Commands) {
        if ($command.GetCommandName() -ne 'Mock') { continue }
        $candidate = Get-EpicStateIsolationMockBinding -Command $command
        if ($candidate.CommandName -eq $MockCommand) { $mocks.Add([pscustomobject]@{ Command = $command; Binding = $candidate }) }
    }
    $import = $null
    if (-not $scriptScope) {
        $import = $Commands | Where-Object {
            $_.GetCommandName() -eq 'Import-Module' -and (Test-EpicStateIsolationModuleImport -Command $_ -ModuleFile $ModuleFile)
        } | Select-Object -First 1
    }

    $findings = [System.Collections.Generic.List[string]]::new()
    if ($mocks.Count -eq 0) {
        $findings.Add("Mock of $MockCommand missing from outermost BeforeAll")
    } else {
        # Every Mock of the seam is evaluated, so a later non-null Mock cannot hide behind an earlier null one.
        foreach ($mock in $mocks) {
            if ($scriptScope) {
                if ($mock.Binding.HasModuleName) { $findings.Add("Mock of $MockCommand carries -ModuleName for a script-scope seam") }
            } elseif (-not $mock.Binding.HasModuleName -or $mock.Binding.ModuleName -ne $ModuleName) {
                $findings.Add("Mock lacks -ModuleName $ModuleName")
            }
            if (-not (Test-EpicStateIsolationNullBody -Body $mock.Binding.MockWith)) { $findings.Add('Mock body is not exactly $null') }
        }
    }
    if (-not $scriptScope) {
        if ($null -eq $import) {
            $findings.Add("Import-Module of $ModuleFile missing from outermost BeforeAll")
        } elseif (@($import.CommandElements | Where-Object { $_ -is [System.Management.Automation.Language.CommandParameterAst] -and $_.ParameterName -eq 'Force' }).Count -gt 0) {
            $findings.Add("Import-Module of $ModuleFile uses -Force")
        }
    }
    if ($mocks.Count -gt 0 -and ($scriptScope -or $null -ne $import)) {
        $firstMock = ($mocks | Sort-Object -Property { $_.Command.Extent.StartOffset } | Select-Object -First 1).Command
        $ordered = $null -ne $DotSource -and $DotSource.Extent.StartOffset -lt $firstMock.Extent.StartOffset
        if ($ordered -and -not $scriptScope) {
            $ordered = $DotSource.Extent.StartOffset -lt $import.Extent.StartOffset -and $import.Extent.StartOffset -lt $firstMock.Extent.StartOffset
        }
        if (-not $ordered) { $findings.Add('hook dot-source, Import-Module, Mock order violated') }
    }
    $findings | Select-Object -Unique
}

function Get-EpicStateIsolationStringConstant {
    # Pure: every string-constant value inside an AST node (a bareword counts), in source order.
    [OutputType([string])]
    param([AllowNull()] [System.Management.Automation.Language.Ast] $Node)
    if ($null -eq $Node) { return }
    $isConstant = { param($candidate) $candidate -is [System.Management.Automation.Language.StringConstantExpressionAst] }
    foreach ($constant in $Node.FindAll($isConstant, $true)) { [string]$constant.Value }
}

function Get-EpicStateIsolationBoundConstant {
    # Pure: the string constants bound to a variable name anywhere in the suite, by assignment or by
    # a hashtable entry with the same key name. A binding to an empty array literal contributes nothing.
    [OutputType([string])]
    param(
        [Parameter(Mandatory)] [System.Management.Automation.Language.Ast] $SuiteAst,
        [Parameter(Mandatory)] [string] $Key
    )
    $isAssignment = { param($candidate) $candidate -is [System.Management.Automation.Language.AssignmentStatementAst] }
    foreach ($assignment in $SuiteAst.FindAll($isAssignment, $true)) {
        $left = $assignment.Left
        if ($left -is [System.Management.Automation.Language.ConvertExpressionAst]) { $left = $left.Child }
        if ($left -isnot [System.Management.Automation.Language.VariableExpressionAst]) { continue }
        if ((Get-EpicStateIsolationVariableKey -UserPath $left.VariablePath.UserPath) -ne $Key) { continue }
        Get-EpicStateIsolationStringConstant -Node $assignment.Right
    }
    $isHashtable = { param($candidate) $candidate -is [System.Management.Automation.Language.HashtableAst] }
    foreach ($table in $SuiteAst.FindAll($isHashtable, $true)) {
        foreach ($pair in $table.KeyValuePairs) {
            $keyText = Get-EpicStateIsolationElementText -Element $pair.Item1
            if ($null -eq $keyText -or $keyText.ToLowerInvariant() -ne $Key) { continue }
            Get-EpicStateIsolationStringConstant -Node $pair.Item2
        }
    }
}

function Get-EpicStateIsolationHelperSeam {
    <#
        Pure: the seam names that Register-EpicStateBaselineMock statements contribute through their
        -Seam argument, among the direct statements placed after the hook dot-source. A variable
        argument resolves by the binding rule: an assignment or a hashtable entry of the same key
        name anywhere in the suite, scope qualifier ignored, names compared case-insensitively.
    #>
    [OutputType([string])]
    param(
        [Parameter(Mandatory)] [AllowEmptyCollection()] [object[]] $Commands,
        [AllowNull()] [System.Management.Automation.Language.CommandAst] $DotSource,
        [Parameter(Mandatory)] [System.Management.Automation.Language.Ast] $SuiteAst
    )
    if ($null -eq $DotSource) { return }
    foreach ($command in $Commands) {
        if ($command.GetCommandName() -ne 'Register-EpicStateBaselineMock') { continue }
        if ($command.Extent.StartOffset -le $DotSource.Extent.StartOffset) { continue }
        $elements = $command.CommandElements
        for ($index = 1; $index -lt $elements.Count; $index++) {
            $element = $elements[$index]
            if ($element -isnot [System.Management.Automation.Language.CommandParameterAst] -or $element.ParameterName -ne 'Seam') { continue }
            $argument = if ($null -ne $element.Argument) { $element.Argument } elseif (($index + 1) -lt $elements.Count) { $elements[$index + 1] } else { $null }
            if ($null -eq $argument) { continue }
            if ($argument -is [System.Management.Automation.Language.VariableExpressionAst]) {
                Get-EpicStateIsolationBoundConstant -SuiteAst $SuiteAst -Key (Get-EpicStateIsolationVariableKey -UserPath $argument.VariablePath.UserPath)
            } else {
                Get-EpicStateIsolationStringConstant -Node $argument
            }
        }
    }
}

function Get-EpicStateIsolationDefaultRequirement {
    # Pure: the two pairs of the original guard, used when a caller supplies no requirement.
    [OutputType([hashtable])]
    param()
    return @(
        @{ Seam = 'Get-EpicScopeCheckpointText'; ModuleName = 'EpicScopeResolution'; ModuleFile = 'EpicScopeResolution.psm1' }
        @{ Seam = 'Get-WorktreeRunCheckpointText'; ModuleName = 'WorktreeRunResolution'; ModuleFile = 'WorktreeRunResolution.psm1' }
    )
}

function Get-EpicStateIsolationOutermostBlock {
    # Pure: the script block of every BeforeAll at the minimum command depth (the outermost
    # BeforeAll blocks), in source order. Empty when the suite holds none.
    [OutputType([System.Management.Automation.Language.ScriptBlockAst])]
    param([Parameter(Mandatory)] [System.Management.Automation.Language.ScriptBlockAst] $Ast)
    $beforeAll = @($Ast.FindAll({ param($node) $node -is [System.Management.Automation.Language.CommandAst] -and $node.GetCommandName() -eq 'BeforeAll' }, $true))
    if ($beforeAll.Count -eq 0) { return }
    $minimum = ($beforeAll | ForEach-Object { Get-EpicStateIsolationCommandDepth -Node $_ } | Measure-Object -Minimum).Minimum
    $outermost = @($beforeAll | Where-Object { (Get-EpicStateIsolationCommandDepth -Node $_) -eq $minimum } | Sort-Object -Property { $_.Extent.StartOffset })
    foreach ($command in $outermost) {
        $expression = @($command.CommandElements | Where-Object { $_ -is [System.Management.Automation.Language.ScriptBlockExpressionAst] }) | Select-Object -First 1
        if ($null -ne $expression) { $expression.ScriptBlock }
    }
}

function Get-EpicStateIsolationFinding {
    <#
        Pure: the epic-state isolation findings for one parsed suite, empty when the
        suite's outermost BeforeAll dot-sources the hook, then carries both the
        EpicScopeResolution pair and the WorktreeRunResolution pair (issue #690).
    #>
    [OutputType([string])]
    param(
        [Parameter(Mandatory)] [System.Management.Automation.Language.ScriptBlockAst] $Ast,
        [hashtable[]] $Requirement = (Get-EpicStateIsolationDefaultRequirement)
    )

    $blocks = @(Get-EpicStateIsolationOutermostBlock -Ast $Ast)
    if ($blocks.Count -eq 0) {
        'no outermost BeforeAll'
        return
    }

    foreach ($block in $blocks) {
        $commands = @(Get-EpicStateIsolationDirectCommand -Block $block | Sort-Object -Property { $_.Extent.StartOffset })
        $dotSources = @($commands | Where-Object { $_.InvocationOperator -eq [System.Management.Automation.Language.TokenKind]::Dot })
        $dotSource = Get-EpicStateIsolationHookDotSource -DotSource $dotSources -SuiteAst $Ast

        $helperSeam = @(Get-EpicStateIsolationHelperSeam -Commands $commands -DotSource $dotSource -SuiteAst $Ast)
        foreach ($item in $Requirement) {
            if ($helperSeam -contains $item.Seam) { continue }
            Get-EpicStateIsolationPairFinding -Commands $commands -DotSource $dotSource -MockCommand $item.Seam -ModuleName $item.ModuleName -ModuleFile $item.ModuleFile
        }
    }
}

function Get-EpicStateIsolationTextFinding {
    # Pure: parse in-memory suite text and return its findings prefixed by the repository-relative
    # path; a parse error is returned as one finding, so that branch is testable without a file.
    [OutputType([string])]
    param(
        [Parameter(Mandatory)] [AllowEmptyString()] [string] $Text,
        [Parameter(Mandatory)] [string] $RelativePath
    )
    $tokens = $null
    $errors = $null
    $ast = [System.Management.Automation.Language.Parser]::ParseInput($Text, [ref] $tokens, [ref] $errors)
    if (@($errors).Count -gt 0) {
        "${RelativePath}: parse error: $($errors[0].Message)"
        return
    }
    foreach ($finding in @(Get-EpicStateIsolationFinding -Ast $ast)) {
        "${RelativePath}: $finding"
    }
}

function Get-EpicStateIsolationSuiteFinding {
    # Read one committed suite, located from the repository root, and return its
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
    Get-EpicStateIsolationTextFinding -Text (Get-Content -Raw -LiteralPath $fullPath) -RelativePath $RelativePath
}
