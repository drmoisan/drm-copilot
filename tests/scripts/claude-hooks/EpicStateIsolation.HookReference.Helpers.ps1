<#
.SYNOPSIS
    Hook-reference helpers for the epic-state isolation guard (issue #935).

.DESCRIPTION
    Holds the functions that decide whether a suite's dot-source or other command loads a
    hook script. This file is dot-sourced from the top of EpicStateIsolation.Helpers.ps1 and
    calls helpers defined there (Get-EpicStateIsolationElementText and
    Get-EpicStateIsolationStringConstant) at run time.

    Every function is pure. No function creates a file, runs a process, or reads gitignored
    state. This file is not mirrored under extensions/drm-copilot/resources/.
#>

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

function Get-EpicStateIsolationVariableBinding {
    # Pure: the expressions the suite binds to the named variable, by assignment or by a hashtable
    # entry with the same key name (the -ForEach data shape), in source order (issue #935).
    [OutputType([System.Management.Automation.Language.Ast])]
    param(
        [Parameter(Mandatory)] [System.Management.Automation.Language.Ast] $SuiteAst,
        [Parameter(Mandatory)] [string] $Key
    )
    $isAssignment = { param($candidate) $candidate -is [System.Management.Automation.Language.AssignmentStatementAst] }
    foreach ($assignment in $SuiteAst.FindAll($isAssignment, $true)) {
        $left = $assignment.Left
        if ($left -is [System.Management.Automation.Language.ConvertExpressionAst]) { $left = $left.Child }
        if ($left -isnot [System.Management.Automation.Language.VariableExpressionAst]) { continue }
        if ((Get-EpicStateIsolationVariableKey -UserPath $left.VariablePath.UserPath) -eq $Key) { $assignment.Right }
    }
    $isHashtable = { param($candidate) $candidate -is [System.Management.Automation.Language.HashtableAst] }
    foreach ($table in $SuiteAst.FindAll($isHashtable, $true)) {
        foreach ($pair in $table.KeyValuePairs) {
            $keyText = Get-EpicStateIsolationElementText -Element $pair.Item1
            if ($null -ne $keyText -and $keyText.ToLowerInvariant() -eq $Key) { $pair.Item2 }
        }
    }
}

function Test-EpicStateIsolationHooksRootBinding {
    # Pure (issue #935, R1): true when the suite binds the variable (assignment or hashtable entry) to an
    # expression holding a string literal whose value ends with a hooks path segment. One level of indirection.
    [OutputType([bool])]
    param(
        [Parameter(Mandatory)] [System.Management.Automation.Language.Ast] $SuiteAst,
        [Parameter(Mandatory)] [string] $Key
    )
    $isLiteral = {
        param($candidate)
        $candidate -is [System.Management.Automation.Language.StringConstantExpressionAst] -or
        $candidate -is [System.Management.Automation.Language.ExpandableStringExpressionAst]
    }
    foreach ($bound in @(Get-EpicStateIsolationVariableBinding -SuiteAst $SuiteAst -Key $Key)) {
        foreach ($literal in $bound.FindAll($isLiteral, $true)) {
            if ([regex]::IsMatch([string]$literal.Value, '(^|[\\/])hooks[\\/]?$')) { return $true }
        }
    }
    return $false
}

function Get-EpicStateIsolationJoinPathPart {
    # Pure: the Path, ChildPath, and AdditionalChildPath arguments of a Join-Path command, bound by name
    # or by position (Path, then ChildPath, then the remaining arguments as AdditionalChildPath).
    [OutputType([hashtable])]
    param([Parameter(Mandatory)] [System.Management.Automation.Language.CommandAst] $Command)
    $part = @{ Path = $null; ChildPath = $null; Additional = [System.Collections.Generic.List[object]]::new() }
    $positional = [System.Collections.Generic.List[object]]::new()
    $elements = $Command.CommandElements
    for ($index = 1; $index -lt $elements.Count; $index++) {
        $element = $elements[$index]
        if ($element -isnot [System.Management.Automation.Language.CommandParameterAst]) { $positional.Add($element); continue }
        if (@('Path', 'ChildPath', 'AdditionalChildPath') -notcontains $element.ParameterName) { continue }
        $value = $element.Argument
        if ($null -eq $value -and ($index + 1) -lt $elements.Count) { $index++; $value = $elements[$index] }
        if ($null -eq $value) { continue }
        if ($element.ParameterName -eq 'AdditionalChildPath') { $part.Additional.Add($value) } else { $part[$element.ParameterName] = $value }
    }
    foreach ($node in $positional) {
        if ($null -eq $part.Path) { $part.Path = $node } elseif ($null -eq $part.ChildPath) { $part.ChildPath = $node } else { $part.Additional.Add($node) }
    }
    return $part
}

function Get-EpicStateIsolationJoinPathSegment {
    # Pure: the literal value of each Join-Path segment in order (Path, ChildPath, then each
    # AdditionalChildPath element), $null for a segment that is not a string constant.
    [OutputType([string])]
    param([Parameter(Mandatory)] [hashtable] $Part)
    $nodes = [System.Collections.Generic.List[object]]::new()
    foreach ($node in @($Part.Path, $Part.ChildPath) + @($Part.Additional)) {
        if ($node -is [System.Management.Automation.Language.ArrayLiteralAst]) { foreach ($item in $node.Elements) { $nodes.Add($item) } }
        elseif ($null -ne $node) { $nodes.Add($node) }
    }
    foreach ($node in $nodes) {
        if ($node -is [System.Management.Automation.Language.StringConstantExpressionAst]) { [string]$node.Value } else { [string]$null }
    }
}

function Test-EpicStateIsolationHookReference {
    <#
        Pure (issue #935, R1): true when the node holds (a) a hooks/<name>.ps1 literal; (b) an expandable
        string "$<var>/<name>.ps1" or "$<var>\<name>.ps1"; (c) Join-Path <expr> '<name>.ps1' (positional
        or -ChildPath); or (d) a Join-Path segment list ending in 'hooks', '<name>.ps1'. For (b) and (c)
        <var>, or a variable inside <expr>, must satisfy Test-EpicStateIsolationHooksRootBinding.
    #>
    [OutputType([bool])]
    param(
        [AllowNull()] [System.Management.Automation.Language.Ast] $Node,
        [Parameter(Mandatory)] [System.Management.Automation.Language.Ast] $SuiteAst
    )
    if ($null -eq $Node) { return $false }
    if (Test-EpicStateIsolationHookLiteral -Node $Node) { return $true }
    $leafPattern = '^(?!.*\.Tests\.ps1$)[A-Za-z0-9._-]+\.ps1$'
    $isExpandable = { param($candidate) $candidate -is [System.Management.Automation.Language.ExpandableStringExpressionAst] }
    foreach ($string in $Node.FindAll($isExpandable, $true)) {
        $match = [regex]::Match([string]$string.Value, '^\$\{?(?<var>[A-Za-z_][A-Za-z0-9_]*(:[A-Za-z_][A-Za-z0-9_]*)?)\}?[\\/](?<leaf>[^\\/]+)$')
        if (-not $match.Success -or $match.Groups['leaf'].Value -notmatch $leafPattern) { continue }
        if (Test-EpicStateIsolationHooksRootBinding -SuiteAst $SuiteAst -Key (Get-EpicStateIsolationVariableKey -UserPath $match.Groups['var'].Value)) { return $true }
    }
    $isJoinPath = { param($candidate) $candidate -is [System.Management.Automation.Language.CommandAst] -and $candidate.GetCommandName() -eq 'Join-Path' }
    $isVariable = { param($candidate) $candidate -is [System.Management.Automation.Language.VariableExpressionAst] }
    foreach ($command in $Node.FindAll($isJoinPath, $true)) {
        $part = Get-EpicStateIsolationJoinPathPart -Command $command
        $segment = @(Get-EpicStateIsolationJoinPathSegment -Part $part)
        $count = $segment.Count
        if ($count -ge 2 -and [string]$segment[$count - 1] -match $leafPattern -and [regex]::IsMatch([string]$segment[$count - 2], '(^|[\\/])hooks[\\/]?$')) { return $true }
        $childIsLeaf = $part.ChildPath -is [System.Management.Automation.Language.StringConstantExpressionAst] -and [string]$part.ChildPath.Value -match $leafPattern
        if (-not $childIsLeaf -or $null -eq $part.Path -or $part.Additional.Count -gt 0) { continue }
        foreach ($variable in $part.Path.FindAll($isVariable, $true)) {
            if (Test-EpicStateIsolationHooksRootBinding -SuiteAst $SuiteAst -Key (Get-EpicStateIsolationVariableKey -UserPath $variable.VariablePath.UserPath)) { return $true }
        }
    }
    return $false
}

function Get-EpicStateIsolationHookDotSource {
    <#
        Pure: the dot-source command that loads the hook. Order: (i) the dot-source that
        Test-EpicStateIsolationHookReference identifies (issue #935, R1); (ii) otherwise the dot-source
        whose argument references a variable that the suite binds to a hooks/<name>.ps1 literal or to
        an expression that Test-EpicStateIsolationHookReference identifies. The first in source order
        wins within a step. $null when no dot-source identifies the hook (issue #903, #737 F-2).
    #>
    [OutputType([System.Management.Automation.Language.CommandAst])]
    param(
        [AllowEmptyCollection()] [object[]] $DotSource,
        [Parameter(Mandatory)] [System.Management.Automation.Language.Ast] $SuiteAst
    )
    $candidates = @($DotSource)
    if ($candidates.Count -eq 0) { return $null }
    foreach ($candidate in $candidates) {
        if (Test-EpicStateIsolationHookReference -Node $candidate -SuiteAst $SuiteAst) { return $candidate }
    }
    $isVariable = { param($node) $node -is [System.Management.Automation.Language.VariableExpressionAst] }
    foreach ($candidate in $candidates) {
        foreach ($variable in $candidate.FindAll($isVariable, $true)) {
            $key = Get-EpicStateIsolationVariableKey -UserPath $variable.VariablePath.UserPath
            if (Test-EpicStateIsolationVariableBoundToHook -SuiteAst $SuiteAst -Key $key) { return $candidate }
            foreach ($bound in @(Get-EpicStateIsolationVariableBinding -SuiteAst $SuiteAst -Key $key)) {
                if (Test-EpicStateIsolationHookReference -Node $bound -SuiteAst $SuiteAst) { return $candidate }
            }
        }
    }
    return $null
}

function Test-EpicStateIsolationHelperDotSource {
    # Pure (issue #935, R2): true when a dot-source is a test-helper load: its argument holds a string
    # literal whose leaf matches \.Helpers\.ps1$ and Test-EpicStateIsolationHookReference is false for it.
    [OutputType([bool])]
    param(
        [Parameter(Mandatory)] [System.Management.Automation.Language.CommandAst] $Command,
        [Parameter(Mandatory)] [System.Management.Automation.Language.Ast] $SuiteAst
    )
    if (Test-EpicStateIsolationHookReference -Node $Command -SuiteAst $SuiteAst) { return $false }
    $isLiteral = {
        param($candidate)
        $candidate -is [System.Management.Automation.Language.StringConstantExpressionAst] -or
        $candidate -is [System.Management.Automation.Language.ExpandableStringExpressionAst]
    }
    foreach ($literal in $Command.FindAll($isLiteral, $true)) {
        $leaf = @([string]$literal.Value -split '[\\/]')[-1]
        if ($leaf -cmatch '\.Helpers\.ps1$') { return $true }
    }
    return $false
}
