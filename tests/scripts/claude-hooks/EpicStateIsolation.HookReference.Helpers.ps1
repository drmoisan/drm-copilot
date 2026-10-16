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

function Get-EpicStateIsolationHookDotSource {
    <#
        Pure: the dot-source command that loads the hook. Order: (i) the dot-source whose argument
        holds a hooks/<name>.ps1 literal; (ii) otherwise the dot-source whose argument references a
        variable that the suite binds to such a literal. The first in source order wins within a
        step. $null when no dot-source identifies the hook (issue #903, #737 F-2).
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
    return $null
}
