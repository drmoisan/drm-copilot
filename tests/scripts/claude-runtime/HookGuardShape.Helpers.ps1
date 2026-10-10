<#
.SYNOPSIS
    Guard-shape and stdout-write detectors for the hook dependency guard tests (issues #786 and #792).

.DESCRIPTION
    Test support only (operator decision D5): not mirrored, not in a pack manifest, not a coverage
    target. Both detectors take script text and a label and read no file (FR-11.5), so every fixture
    is an in-memory here-string. Get-HookGuardShapeFinding reports the S1, S2, S3, and S6 shape
    findings of one registered hook; Get-HookStdoutWriteFinding reports success- and warning-stream
    writes (FR-11.2) and ignores [Console]::Error, Write-Error, Write-Verbose, Write-Debug, comments,
    and string literals (FR-11.3). Requires HookDependencyGraph.Helpers.ps1 to be dot-sourced first.
#>

function Get-HookGuardTopStatement {
    # The statements of the script's end block, after the param block.
    param([System.Management.Automation.Language.ScriptBlockAst] $Ast)
    if ($null -eq $Ast.EndBlock) { return @() }
    return @($Ast.EndBlock.Statements)
}

function Test-HookGuardBootstrap {
    # S1 bootstrap: the first statement assigns $false to the flag and the second is the single-statement
    # try that dot-sources hook-dependency-guard.ps1 with a catch that assigns $true to the flag.
    param([object[]] $Statement)
    if ($Statement.Count -lt 2) { return $false }
    $first = $Statement[0]
    if ($first -isnot [System.Management.Automation.Language.AssignmentStatementAst] -or $first.Left.Extent.Text -ne '$script:HookDependencyGuardLoadFailed' -or $first.Right.Extent.Text -ne '$false') { return $false }
    $try = $Statement[1]
    if ($try -isnot [System.Management.Automation.Language.TryStatementAst] -or $try.Body.Statements.Count -ne 1) { return $false }
    if ($try.Body.Statements[0].Extent.Text -ne ". (Join-Path `$PSScriptRoot 'hook-dependency-guard.ps1')") { return $false }
    $flag = @($try.CatchClauses | ForEach-Object { $_.Body.FindAll({ param($n) $n -is [System.Management.Automation.Language.AssignmentStatementAst] -and $n.Left.Extent.Text -eq '$script:HookDependencyGuardLoadFailed' -and $n.Right.Extent.Text -eq '$true' }, $true) })
    return ($flag.Count -ge 1 -and @($try.CatchClauses | ForEach-Object { $_.Body.FindAll({ param($n) $n -is [System.Management.Automation.Language.CommandAst] }, $true) }).Count -eq 0)
}

function Get-HookGuardTailFinding {
    # S1 tail: the three statements that directly follow the dot-source early return.
    param([object[]] $Statement, [string] $HookEvent)
    $index = -1
    for ($i = 0; $i -lt $Statement.Count; $i++) {
        if ($Statement[$i] -is [System.Management.Automation.Language.IfStatementAst] -and $Statement[$i].Clauses[0].Item1.Extent.Text -eq '$MyInvocation.InvocationName -eq ''.''') { $index = $i; break }
    }
    if ($index -lt 0) { return 'S1: no dot-source early return' }
    if ($Statement.Count -lt $index + 4) { return 'S1: tail check missing after the dot-source early return' }
    $flagCheck = $Statement[$index + 1]
    if ($flagCheck -isnot [System.Management.Automation.Language.IfStatementAst] -or $flagCheck.Clauses[0].Item1.Extent.Text -ne '$script:HookDependencyGuardLoadFailed') { return 'S1: bootstrap flag check does not directly follow the dot-source early return' }
    $flagBody = $flagCheck.Clauses[0].Item2.Extent.Text
    if (-not $flagBody.Contains('[Console]::Error.WriteLine(') -or $flagBody -notmatch '\bexit 2\b' -or -not $flagBody.Contains('hook-dependency-guard.ps1 failed to load; the gate fails closed.')) { return 'S1: bootstrap flag check does not write the reason to stderr and exit 2' }
    $assign = $Statement[$index + 2]
    $call = if ($assign -is [System.Management.Automation.Language.AssignmentStatementAst]) { $assign.Right.Find({ param($n) $n -is [System.Management.Automation.Language.CommandAst] }, $true) } else { $null }
    if ($null -eq $call -or $assign.Left.Extent.Text -ne '$dependencyDecision' -or $call.GetCommandName() -ne 'Get-HookDependencyFailureDecision' -or $call.Extent.Text -notmatch ('-HookEvent\s+' + $HookEvent + '\b')) { return 'S1: dependency decision assignment missing from the tail' }
    $emit = $Statement[$index + 3]
    if ($emit -isnot [System.Management.Automation.Language.IfStatementAst] -or $emit.Clauses[0].Item1.Extent.Text -ne '$null -ne $dependencyDecision') { return 'S1: dependency decision check missing from the tail' }
    $emitBody = $emit.Clauses[0].Item2.Extent.Text
    if ($HookEvent -eq 'PreToolUse' -and ($emitBody -notmatch 'ConvertTo-Json' -or $emitBody -notmatch '\bexit 0\b')) { return 'S1: PreToolUse tail does not emit the deny JSON at exit 0' }
    if ($HookEvent -eq 'SubagentStop' -and ($emitBody -notmatch '\[Console\]::Error\.WriteLine' -or $emitBody -notmatch 'exit \$dependencyDecision\.ExitCode')) { return 'S1: SubagentStop tail does not write the reason to stderr and exit with the result code' }
    return $null
}

function Test-HookGuardExemptEdge {
    # An exemption-listed edge: single-statement try whose catch assigns the entry's variable.
    param($Edge, [object[]] $Entry)
    foreach ($e in $Entry) {
        if (@($e.Leaf) -notcontains $Edge.Leaf) { continue }
        $try = $Edge.Command.Parent
        while ($null -ne $try -and $try -isnot [System.Management.Automation.Language.TryStatementAst]) { $try = $try.Parent }
        if ($null -eq $try -or -not $Edge.SingleStatementTry) { continue }
        $assign = @($try.CatchClauses | ForEach-Object { $_.Body.FindAll({ param($n) $n -is [System.Management.Automation.Language.AssignmentStatementAst] -and $n.Left.Extent.Text -eq ('$script:' + $e.Variable) }, $true) })
        if ($assign.Count -gt 0) { return $true }
    }
    return $false
}

function Get-HookGuardShapeFinding {
    <#
    .SYNOPSIS
        Returns the S1, S2, S3, and S6 shape findings of one registered hook, or nothing.
    .PARAMETER Exemption
        Entries of Get-HookImportFailureExemption; a direct edge listed by a Handler entry whose
        HandlerFile equals HookPath is judged by the exemption rule.
    #>
    [CmdletBinding()]
    [OutputType([string])]
    param(
        [Parameter(Mandatory)] [AllowEmptyString()] [string] $ScriptText,
        [Parameter(Mandatory)] [string] $HookPath,
        [Parameter(Mandatory)] [ValidateSet('PreToolUse', 'SubagentStop')] [string] $HookEvent,
        [object[]] $Exemption = @()
    )

    $tokens = $null
    $parseErrors = $null
    $ast = [System.Management.Automation.Language.Parser]::ParseInput($ScriptText, [ref]$tokens, [ref]$parseErrors)
    $statements = Get-HookGuardTopStatement -Ast $ast
    if (-not (Test-HookGuardBootstrap -Statement $statements)) { 'S1: bootstrap try is not the first statement after param()' }
    $tail = Get-HookGuardTailFinding -Statement $statements -HookEvent $HookEvent
    if ($tail) { $tail }

    $entries = @($Exemption | Where-Object { $_.Kind -eq 'Handler' -and ($_.HandlerFile -replace '\\', '/') -eq ($HookPath -replace '\\', '/') })
    foreach ($edge in @(Get-HookScriptEdge -ScriptText $ScriptText -SourcePath $HookPath | Where-Object { -not $_.Runtime -and $_.Leaf -ne 'hook-dependency-guard.ps1' })) {
        if (Test-HookGuardExemptEdge -Edge $edge -Entry $entries) { continue }
        if (-not $edge.Guarded -or -not $edge.SingleStatementTry) { "S2: $($edge.Leaf) (line $($edge.Line)) is not in its own single-statement try"; continue }
        $try = $edge.Command.Parent
        while ($try -isnot [System.Management.Automation.Language.TryStatementAst]) { $try = $try.Parent }
        $records = @($try.CatchClauses | ForEach-Object { $_.Body.FindAll({ param($n) $n -is [System.Management.Automation.Language.CommandAst] -and $n.GetCommandName() -eq 'Add-HookDependencyFailure' }, $true) } | Where-Object { $_.Extent.Text -match ("-Name\s+'" + [regex]::Escape($edge.Leaf) + "'") })
        if ($records.Count -eq 0) { "S2: the catch of $($edge.Leaf) (line $($edge.Line)) does not record it through Add-HookDependencyFailure" }
        if ($edge.Kind -eq 'Module' -and -not $edge.ErrorActionStop) { "S3: guarded Import-Module of $($edge.Leaf) (line $($edge.Line)) lacks -ErrorAction Stop" }
    }

    $decisionName = Get-HookDecisionFunctionName -ScriptText $ScriptText
    if ($decisionName -ne 'NONE') {
        $function = $ast.Find({ param($n) $n -is [System.Management.Automation.Language.FunctionDefinitionAst] -and $n.Name -eq $decisionName }, $true)
        $body = @($function.Body.EndBlock.Statements)
        $okAssign = $body.Count -ge 2 -and $body[0] -is [System.Management.Automation.Language.AssignmentStatementAst] -and $body[0].Left.Extent.Text -eq '$dependencyDecision' -and
        $body[0].Right.Extent.Text -match ('^Get-HookDependencyFailureDecision -HookEvent ' + $HookEvent + ' -ReasonPrefix ')
        $okReturn = $body.Count -ge 2 -and $body[1].Extent.Text -eq 'if ($null -ne $dependencyDecision) { return $dependencyDecision }'
        if (-not ($okAssign -and $okReturn)) { "S6: $decisionName does not return the dependency decision first" }
    }
}

function Get-HookStdoutWriteFinding {
    <#
    .SYNOPSIS
        Returns one finding per success- or warning-stream write in the script text (FR-11.2).
    .OUTPUTS
        Objects with SourceLabel, Line, and Form.
    #>
    [CmdletBinding()]
    [OutputType([pscustomobject])]
    param(
        [Parameter(Mandatory)] [AllowEmptyString()] [string] $ScriptText,
        [Parameter(Mandatory)] [string] $SourceLabel
    )

    $tokens = $null
    $parseErrors = $null
    $ast = [System.Management.Automation.Language.Parser]::ParseInput($ScriptText, [ref]$tokens, [ref]$parseErrors)
    $commandNames = @('Write-Output', 'write', 'echo', 'Write-Host', 'Write-Information', 'Write-Warning', 'Out-Host')
    foreach ($command in $ast.FindAll({ param($n) $n -is [System.Management.Automation.Language.CommandAst] }, $true)) {
        $name = $command.GetCommandName()
        if ($null -ne $name -and @($commandNames | Where-Object { $_ -ieq $name }).Count -gt 0) {
            [pscustomobject]@{ SourceLabel = $SourceLabel; Line = $command.Extent.StartLineNumber; Form = $name }
        }
    }
    foreach ($invoke in $ast.FindAll({ param($n) $n -is [System.Management.Automation.Language.InvokeMemberExpressionAst] }, $true)) {
        $member = $invoke.Member.Extent.Text
        $target = $invoke.Expression
        if ($invoke.Static -and $target -is [System.Management.Automation.Language.TypeExpressionAst] -and $target.TypeName.FullName -match '^(System\.)?Console$' -and $member -match '^(Write|WriteLine)$') {
            [pscustomobject]@{ SourceLabel = $SourceLabel; Line = $invoke.Extent.StartLineNumber; Form = "[Console]::$member" }
        }
        elseif ($target -is [System.Management.Automation.Language.MemberExpressionAst] -and $target.Static -and $target.Expression -is [System.Management.Automation.Language.TypeExpressionAst] -and
            $target.Expression.TypeName.FullName -match '^(System\.)?Console$' -and $target.Member.Extent.Text -eq 'Out' -and $member -like 'Write*') {
            [pscustomobject]@{ SourceLabel = $SourceLabel; Line = $invoke.Extent.StartLineNumber; Form = "[Console]::Out.$member" }
        }
    }
}
