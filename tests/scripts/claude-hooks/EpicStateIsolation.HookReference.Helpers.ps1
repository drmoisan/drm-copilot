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

function Get-EpicStateIsolationHookRoot {
    # Pure: '.claude/hooks' or '.codex/hooks' when the text names that root, otherwise $null.
    [OutputType([string])]
    param([AllowNull()] [string] $Text)
    if ([string]::IsNullOrEmpty($Text)) { return $null }
    $normal = $Text.Replace([string][char]92, '/')
    foreach ($root in '.claude/hooks', '.codex/hooks') {
        if ([regex]::IsMatch($normal, '(^|/)' + [regex]::Escape($root) + '(/|$)')) { return $root }
    }
    return $null
}

function Get-EpicStateIsolationReferenceRecord {
    <#
        Pure (issue #935, F-3): the hook-reference records of one expression found in a load position.
        Nested script blocks are not searched. Each record carries Name (the leaf, or * when the leaf is
        not a literal), Form (Literal, RootVariable, Segment, Dynamic) and Root (.claude/hooks,
        .codex/hooks, or $null).
    #>
    [OutputType([pscustomobject])]
    param(
        [AllowNull()] [System.Management.Automation.Language.Ast] $Node,
        [Parameter(Mandatory)] [System.Management.Automation.Language.Ast] $SuiteAst
    )
    if ($null -eq $Node -or $Node -is [System.Management.Automation.Language.ScriptBlockExpressionAst]) { return }
    $leafPattern = '^(?!.*\.Tests\.ps1$)[A-Za-z0-9._-]+\.ps1$'
    $hooksPattern = '(^|[\\/])hooks[\\/]?$'
    $isLiteral = {
        param($candidate)
        $candidate -is [System.Management.Automation.Language.StringConstantExpressionAst] -or
        $candidate -is [System.Management.Automation.Language.ExpandableStringExpressionAst]
    }
    $isVariable = { param($candidate) $candidate -is [System.Management.Automation.Language.VariableExpressionAst] }
    $rootOf = {
        param([string] $Key)
        foreach ($bound in @(Get-EpicStateIsolationVariableBinding -SuiteAst $SuiteAst -Key $Key)) {
            foreach ($text in @($bound.FindAll($isLiteral, $true) | ForEach-Object { [string]$_.Value })) {
                if ([regex]::IsMatch($text, $hooksPattern)) { return (Get-EpicStateIsolationHookRoot -Text $text) }
            }
        }
        return $null
    }
    foreach ($literal in $Node.FindAll($isLiteral, $false)) {
        $value = [string]$literal.Value
        foreach ($match in [regex]::Matches($value, '(?<![A-Za-z0-9_-])hooks/(?<name>[A-Za-z0-9._-]+\.ps1)')) {
            $name = $match.Groups['name'].Value
            if ($name.StartsWith('EpicStateIsolation.', [System.StringComparison]::Ordinal) -or $name.EndsWith('.Tests.ps1', [System.StringComparison]::Ordinal)) { continue }
            [pscustomobject]@{ Name = $name; Form = 'Literal'; Root = (Get-EpicStateIsolationHookRoot -Text $value.Substring(0, $match.Index + 5)) }
        }
        if ($literal -isnot [System.Management.Automation.Language.ExpandableStringExpressionAst]) { continue }
        $match = [regex]::Match($value, '^\$\{?(?<var>[A-Za-z_][A-Za-z0-9_]*(:[A-Za-z_][A-Za-z0-9_]*)?)\}?[\\/](?<leaf>[^\\/]+)$')
        if (-not $match.Success) { continue }
        $key = Get-EpicStateIsolationVariableKey -UserPath $match.Groups['var'].Value
        if (-not (Test-EpicStateIsolationHooksRootBinding -SuiteAst $SuiteAst -Key $key)) { continue }
        $leaf = $match.Groups['leaf'].Value
        if ($leaf -match $leafPattern) { [pscustomobject]@{ Name = $leaf; Form = 'RootVariable'; Root = (& $rootOf $key) } }
        elseif ($leaf.StartsWith('$', [System.StringComparison]::Ordinal)) { [pscustomobject]@{ Name = '*'; Form = 'Dynamic'; Root = (& $rootOf $key) } }
    }
    $isJoinPath = { param($candidate) $candidate -is [System.Management.Automation.Language.CommandAst] -and $candidate.GetCommandName() -eq 'Join-Path' }
    foreach ($command in $Node.FindAll($isJoinPath, $false)) {
        $part = Get-EpicStateIsolationJoinPathPart -Command $command
        $segment = @(Get-EpicStateIsolationJoinPathSegment -Part $part)
        $count = $segment.Count
        if ($count -ge 2 -and [string]$segment[$count - 1] -match $leafPattern -and [regex]::IsMatch([string]$segment[$count - 2], $hooksPattern)) {
            [pscustomobject]@{ Name = [string]$segment[$count - 1]; Form = 'Segment'; Root = (Get-EpicStateIsolationHookRoot -Text (@($segment[0..($count - 2)]) -join '/')) }
            continue
        }
        if ($null -eq $part.Path -or $null -eq $part.ChildPath -or $part.Additional.Count -gt 0) { continue }
        $rootKey = @($part.Path.FindAll($isVariable, $true) | ForEach-Object { Get-EpicStateIsolationVariableKey -UserPath $_.VariablePath.UserPath } |
                Where-Object { Test-EpicStateIsolationHooksRootBinding -SuiteAst $SuiteAst -Key $_ }) | Select-Object -First 1
        if ($null -eq $rootKey) { continue }
        if ($part.ChildPath -is [System.Management.Automation.Language.StringConstantExpressionAst]) {
            if ([string]$part.ChildPath.Value -match $leafPattern) { [pscustomobject]@{ Name = [string]$part.ChildPath.Value; Form = 'RootVariable'; Root = (& $rootOf $rootKey) } }
        } else {
            [pscustomobject]@{ Name = '*'; Form = 'Dynamic'; Root = (& $rootOf $rootKey) }
        }
    }
}

function Get-EpicStateIsolationHookReference {
    <#
        Pure (issue #935, #737 F-3): one record per hook reference in a load position, deduplicated.
        Load positions: the argument of a . or & invocation; Import-Module path arguments; ProcessStartInfo
        FileName assignments and ArgumentList.Add arguments; process-start cmdlet -FilePath and
        -ArgumentList arguments (and its positional arguments); and the expressions bound to a variable
        used in one of those positions. A Join-Path read only by Get-FileHash, Get-Content or ParseFile is
        in no load position and is not reported. The cmdlet name is composed from fragments.
    #>
    [OutputType([pscustomobject])]
    param([Parameter(Mandatory)] [System.Management.Automation.Language.Ast] $Ast)
    $cmdlet = 'Start' + '-' + 'Process'
    $loads = [System.Collections.Generic.List[object]]::new()
    foreach ($command in $Ast.FindAll({ param($node) $node -is [System.Management.Automation.Language.CommandAst] }, $true)) {
        $elements = $command.CommandElements
        $operator = $command.InvocationOperator
        if ($operator -eq [System.Management.Automation.Language.TokenKind]::Dot -or $operator -eq [System.Management.Automation.Language.TokenKind]::Ampersand) { $loads.Add($elements[0]); continue }
        $pathParameter = $null
        if ($command.GetCommandName() -eq 'Import-Module') { $pathParameter = @('Name', 'Path') }
        elseif ($command.GetCommandName() -eq $cmdlet) { $pathParameter = @('FilePath', 'ArgumentList') }
        if ($null -eq $pathParameter) { continue }
        for ($index = 1; $index -lt $elements.Count; $index++) {
            $element = $elements[$index]
            if ($element -isnot [System.Management.Automation.Language.CommandParameterAst]) { $loads.Add($element); continue }
            if ($pathParameter -notcontains $element.ParameterName) { continue }
            $value = $element.Argument
            if ($null -eq $value -and ($index + 1) -lt $elements.Count) { $index++; $value = $elements[$index] }
            if ($null -ne $value) { $loads.Add($value) }
        }
    }
    foreach ($assignment in $Ast.FindAll({ param($node) $node -is [System.Management.Automation.Language.AssignmentStatementAst] }, $true)) {
        if ($assignment.Left -is [System.Management.Automation.Language.MemberExpressionAst] -and (Get-EpicStateIsolationElementText -Element $assignment.Left.Member) -eq 'FileName') { $loads.Add($assignment.Right) }
    }
    foreach ($invoke in $Ast.FindAll({ param($node) $node -is [System.Management.Automation.Language.InvokeMemberExpressionAst] }, $true)) {
        if ((Get-EpicStateIsolationElementText -Element $invoke.Member) -ne 'Add' -or $invoke.Expression -isnot [System.Management.Automation.Language.MemberExpressionAst]) { continue }
        if ((Get-EpicStateIsolationElementText -Element $invoke.Expression.Member) -eq 'ArgumentList') { foreach ($argument in @($invoke.Arguments)) { $loads.Add($argument) } }
    }
    $isVariable = { param($node) $node -is [System.Management.Automation.Language.VariableExpressionAst] }
    $seen = [System.Collections.Generic.HashSet[string]]::new([System.StringComparer]::Ordinal)
    foreach ($node in $loads) {
        if ($null -eq $node -or $node -is [System.Management.Automation.Language.ScriptBlockExpressionAst]) { continue }
        $records = [System.Collections.Generic.List[object]]::new()
        foreach ($record in @(Get-EpicStateIsolationReferenceRecord -Node $node -SuiteAst $Ast)) { $records.Add($record) }
        foreach ($variable in $node.FindAll($isVariable, $false)) {
            foreach ($bound in @(Get-EpicStateIsolationVariableBinding -SuiteAst $Ast -Key (Get-EpicStateIsolationVariableKey -UserPath $variable.VariablePath.UserPath))) {
                foreach ($record in @(Get-EpicStateIsolationReferenceRecord -Node $bound -SuiteAst $Ast)) { $records.Add($record) }
            }
        }
        foreach ($record in $records) {
            if ($seen.Add("$($record.Form)|$($record.Name)|$($record.Root)")) { $record }
        }
    }
}
