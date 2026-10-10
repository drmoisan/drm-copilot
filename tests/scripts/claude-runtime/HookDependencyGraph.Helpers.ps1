<#
.SYNOPSIS
    Hook registration discovery and AST dependency-graph helpers for the hook dependency guard
    tests (issues #786 and #792).

.DESCRIPTION
    Test support only: not mirrored under extensions/drm-copilot/resources/, not listed in a pack
    manifest, and not a coverage target (operator decision D5). Consumed by the structural
    completeness test, the #792 stdout guard, the behaviour suites, and the exemption guard.

    Every reader is an injectable script block, so fixtures are in-memory here-strings:
      - ReadText: repository-relative or rooted path in, file text (or $null) out.
      - TestPath: path in, $true when the file exists.
    Paths are composed and normalized textually (no host path resolution), so synthetic roots such as
    /synthetic-root/... resolve the same way on every host. No function writes a file.
#>

$script:HookGraphDefaultReadText = { param([string] $Path) if (Test-Path -LiteralPath $Path -PathType Leaf) { Get-Content -LiteralPath $Path -Raw } else { $null } }
$script:HookGraphDefaultTestPath = { param([string] $Path) Test-Path -LiteralPath $Path -PathType Leaf }

function ConvertTo-HookGraphNormalPath {
    <#
    .SYNOPSIS
        Normalizes a path textually: forward slashes, '.' segments dropped, '..' segments folded.
    #>
    [CmdletBinding()]
    [OutputType([string])]
    param([Parameter(Mandatory)] [AllowEmptyString()] [string] $Path)

    $text = $Path -replace '\\', '/'
    $rooted = $text.StartsWith('/')
    $drive = ''
    if ($text -match '^([A-Za-z]:)(/.*)?$') { $drive = $Matches[1]; $text = $text.Substring(2); $rooted = $true }
    $parts = [System.Collections.Generic.List[string]]::new()
    foreach ($segment in ($text -split '/')) {
        if ($segment -eq '' -or $segment -eq '.') { continue }
        if ($segment -eq '..' -and $parts.Count -gt 0 -and $parts[$parts.Count - 1] -ne '..') { $parts.RemoveAt($parts.Count - 1); continue }
        $parts.Add($segment)
    }
    $joined = $parts -join '/'
    if ($rooted) { return "$drive/$joined" }
    return $joined
}

function Join-HookGraphPath {
    # Joins two path fragments with a forward slash and normalizes the result textually.
    [CmdletBinding()]
    [OutputType([string])]
    param([AllowEmptyString()] [string] $Left, [AllowEmptyString()] [string] $Right)
    if ([string]::IsNullOrEmpty($Left)) { return (ConvertTo-HookGraphNormalPath -Path $Right) }
    if (($Right -replace '\\', '/').StartsWith('/') -or $Right -match '^[A-Za-z]:') { return (ConvertTo-HookGraphNormalPath -Path $Right) }
    return (ConvertTo-HookGraphNormalPath -Path ("$Left/$Right"))
}

function Get-HookRegistration {
    <#
    .SYNOPSIS
        Returns the PreToolUse and SubagentStop hook registrations of both surfaces.
    .DESCRIPTION
        Reads .claude/settings.json under ClaudeRoot and .codex/config.toml under CodexRoot through
        ReadText, with the same matching as the research Q3 enumeration (Get-RegisteredHook). A
        registration whose command names no hook file yields one INLINE entry. Each entry carries
        Surface, Event, Root, Hook (root-relative, forward slashes, or INLINE) and Path (Root joined
        with Hook, or INLINE). Entries are unique by Surface, Event, and Hook.
    #>
    [CmdletBinding()]
    [OutputType([pscustomobject])]
    param(
        [Parameter(Mandatory)] [string] $ClaudeRoot,
        [Parameter(Mandatory)] [string] $CodexRoot,
        [scriptblock] $ReadText = $script:HookGraphDefaultReadText
    )

    $seen = @{}
    $settingsText = & $ReadText (Join-HookGraphPath -Left $ClaudeRoot -Right '.claude/settings.json')
    if ($settingsText) {
        $settings = $settingsText | ConvertFrom-Json
        foreach ($hookEvent in 'PreToolUse', 'SubagentStop') {
            $groups = @()
            if ($null -ne $settings.hooks -and $settings.hooks.PSObject.Properties.Name -contains $hookEvent) { $groups = @($settings.hooks.$hookEvent) }
            foreach ($group in $groups) {
                foreach ($hook in @($group.hooks)) {
                    $found = [regex]::Matches([string]$hook.command, '\.claude/hooks/[\w.-]+\.ps1')
                    $names = @(if ($found.Count -eq 0) { 'INLINE' } else { $found | ForEach-Object { $_.Value } })
                    foreach ($name in $names) {
                        $key = "claude|$hookEvent|$name"
                        if ($seen.ContainsKey($key)) { continue }
                        $seen[$key] = $true
                        [pscustomobject]@{ Surface = 'claude'; Event = $hookEvent; Root = $ClaudeRoot; Hook = $name; Path = $(if ($name -eq 'INLINE') { 'INLINE' } else { Join-HookGraphPath -Left $ClaudeRoot -Right $name }) }
                    }
                }
            }
        }
    }
    $configText = & $ReadText (Join-HookGraphPath -Left $CodexRoot -Right '.codex/config.toml')
    if ($configText) {
        $hookEvent = ''
        foreach ($line in ($configText -split "`r?`n")) {
            if ($line -match '^\[\[hooks\.(\w+)') { $hookEvent = $Matches[1]; continue }
            if ($line -notmatch '^command\s*=' -or $hookEvent -notin 'PreToolUse', 'SubagentStop') { continue }
            foreach ($m in [regex]::Matches($line, '\.codex/hooks/[\w.-]+\.ps1')) {
                $key = "codex|$hookEvent|$($m.Value)"
                if ($seen.ContainsKey($key)) { continue }
                $seen[$key] = $true
                [pscustomobject]@{ Surface = 'codex'; Event = $hookEvent; Root = $CodexRoot; Hook = $m.Value; Path = (Join-HookGraphPath -Left $CodexRoot -Right $m.Value) }
            }
        }
    }
}

function Resolve-HookGraphStaticPath {
    # Static resolution of an import or dot-source target expression (research Q3 Resolve-StaticPath),
    # with textual path composition. Returns zero or more strings.
    param($Node, [string] $Directory, [hashtable] $Variables)
    if ($Node -is [System.Management.Automation.Language.ParenExpressionAst]) { $Node = $Node.Pipeline }
    if ($Node -is [System.Management.Automation.Language.PipelineAst] -and $Node.PipelineElements.Count -eq 1) { $Node = $Node.PipelineElements[0] }
    if ($Node -is [System.Management.Automation.Language.CommandExpressionAst]) { $Node = $Node.Expression }
    if ($Node -is [System.Management.Automation.Language.MemberExpressionAst] -and $Node.Member.Extent.Text -eq 'Path') { return (Resolve-HookGraphStaticPath $Node.Expression $Directory $Variables) }
    if ($Node -is [System.Management.Automation.Language.StringConstantExpressionAst]) { return $Node.Value }
    if ($Node -is [System.Management.Automation.Language.VariableExpressionAst]) {
        $name = $Node.VariablePath.UserPath -replace '^script:', ''
        if ($name -eq 'PSScriptRoot') { return $Directory }
        if ($Variables.ContainsKey($name)) { return $Variables[$name] }
        return
    }
    if ($Node -is [System.Management.Automation.Language.ExpandableStringExpressionAst]) {
        $loop = $Node.Parent
        while ($null -ne $loop -and $loop -isnot [System.Management.Automation.Language.ForEachStatementAst]) { $loop = $loop.Parent }
        if ($null -eq $loop) {
            if ($Node.Value -match '^\$PSScriptRoot(/.*)$') { return ($Directory + $Matches[1]) }
            return
        }
        $token = '$' + $loop.Variable.VariablePath.UserPath
        foreach ($item in $loop.Condition.FindAll({ param($n) $n -is [System.Management.Automation.Language.StringConstantExpressionAst] }, $true)) { $Node.Value.Replace($token, $item.Value) }
        return
    }
    if ($Node -is [System.Management.Automation.Language.InvokeMemberExpressionAst] -and $Node.Member.Extent.Text -eq 'Combine' -and $Node.Arguments.Count -ge 2) {
        foreach ($left in @(Resolve-HookGraphStaticPath $Node.Arguments[0] $Directory $Variables)) {
            foreach ($right in @(Resolve-HookGraphStaticPath $Node.Arguments[1] $Directory $Variables)) { Join-HookGraphPath -Left $left -Right $right }
        }
        return
    }
    if ($Node -is [System.Management.Automation.Language.CommandAst]) {
        $operands = @($Node.CommandElements | Select-Object -Skip 1 | Where-Object { $_ -isnot [System.Management.Automation.Language.CommandParameterAst] })
        $commandName = $Node.GetCommandName()
        if (($commandName -eq 'Join-Path' -or $commandName -eq 'Resolve-Path') -and $operands.Count -ge 1) {
            if ($commandName -eq 'Resolve-Path') { return (Resolve-HookGraphStaticPath $operands[0] $Directory $Variables) }
            if ($operands.Count -lt 2) { return }
            foreach ($left in @(Resolve-HookGraphStaticPath $operands[0] $Directory $Variables)) {
                foreach ($right in @(Resolve-HookGraphStaticPath $operands[1] $Directory $Variables)) { Join-HookGraphPath -Left $left -Right $right }
            }
        }
        elseif ($commandName -eq 'Split-Path' -and $operands.Count -ge 1) {
            foreach ($p in @(Resolve-HookGraphStaticPath $operands[0] $Directory $Variables)) { ConvertTo-HookGraphNormalPath -Path ($p -replace '/[^/]*$', '') }
        }
    }
}

function Get-HookScriptEdge {
    <#
    .SYNOPSIS
        Returns every Import-Module and dot-source edge of one script text.
    .DESCRIPTION
        One object per resolved target with Kind (Module or DotSource), Target (normalized, or
        'UNRESOLVED: <text>'), Leaf, ChildPathLiteral (the string-literal second Join-Path operand of a
        dot-source, VARIABLE when the target expression is a variable, otherwise $null), Line,
        Guarded (inside a try body), SingleStatementTry (the enclosing try body holds this one
        statement only), Runtime (inside a function or a script-block expression), Conditional
        (inside an if), ErrorActionStop, and LazyFunction (the first non-parameter element after
        Get-Command in the condition of the nearest enclosing if, or NONE).
    #>
    [CmdletBinding()]
    [OutputType([pscustomobject])]
    param(
        [Parameter(Mandatory)] [AllowEmptyString()] [string] $ScriptText,
        [Parameter(Mandatory)] [string] $SourcePath
    )

    $tokens = $null
    $parseErrors = $null
    $ast = [System.Management.Automation.Language.Parser]::ParseInput($ScriptText, [ref]$tokens, [ref]$parseErrors)
    $directory = ConvertTo-HookGraphNormalPath -Path (($SourcePath -replace '\\', '/') -replace '/[^/]*$', '')
    $variables = @{}
    foreach ($assignment in $ast.FindAll({ param($n) $n -is [System.Management.Automation.Language.AssignmentStatementAst] -and $n.Left -is [System.Management.Automation.Language.VariableExpressionAst] }, $true)) {
        $values = @(Resolve-HookGraphStaticPath $assignment.Right $directory $variables)
        if ($values.Count -eq 1) { $variables[($assignment.Left.VariablePath.UserPath -replace '^script:', '')] = [string]$values[0] }
    }
    foreach ($command in $ast.FindAll({ param($n) $n -is [System.Management.Automation.Language.CommandAst] }, $true)) {
        $childLiteral = $null
        if ($command.InvocationOperator -eq [System.Management.Automation.Language.TokenKind]::Dot) {
            $kind = 'DotSource'
            $targetNode = $command.CommandElements[0]
            $join = $targetNode.Find({ param($n) $n -is [System.Management.Automation.Language.CommandAst] -and $n.GetCommandName() -eq 'Join-Path' }, $true)
            $joinOperands = @(if ($null -ne $join) { $join.CommandElements | Select-Object -Skip 1 | Where-Object { $_ -isnot [System.Management.Automation.Language.CommandParameterAst] } })
            if ($joinOperands.Count -ge 2 -and $joinOperands[1] -is [System.Management.Automation.Language.StringConstantExpressionAst]) { $childLiteral = $joinOperands[1].Value }
            elseif ($targetNode -is [System.Management.Automation.Language.VariableExpressionAst]) { $childLiteral = 'VARIABLE' }
        }
        elseif ($command.GetCommandName() -eq 'Import-Module') {
            $kind = 'Module'
            $targetNode = @($command.CommandElements | Select-Object -Skip 1 | Where-Object { $_ -isnot [System.Management.Automation.Language.CommandParameterAst] }) | Select-Object -First 1
        }
        else { continue }
        $guarded = $false; $single = $false; $runtime = $false; $conditional = $false; $lazy = 'NONE'; $nearestIf = $null
        $child = $command; $parent = $command.Parent
        while ($null -ne $parent) {
            if ($parent -is [System.Management.Automation.Language.TryStatementAst] -and [object]::ReferenceEquals($parent.Body, $child)) {
                if (-not $guarded) { $single = ($parent.Body.Statements.Count -eq 1) }
                $guarded = $true
            }
            if ($parent -is [System.Management.Automation.Language.FunctionDefinitionAst] -or $parent -is [System.Management.Automation.Language.ScriptBlockExpressionAst]) { $runtime = $true }
            if ($parent -is [System.Management.Automation.Language.IfStatementAst]) { $conditional = $true; if ($null -eq $nearestIf) { $nearestIf = $parent } }
            $child = $parent; $parent = $parent.Parent
        }
        if ($null -ne $nearestIf) {
            $getCommand = $nearestIf.Clauses[0].Item1.Find({ param($n) $n -is [System.Management.Automation.Language.CommandAst] -and $n.GetCommandName() -eq 'Get-Command' }, $true)
            if ($null -ne $getCommand) {
                $element = @($getCommand.CommandElements | Select-Object -Skip 1 | Where-Object { $_ -isnot [System.Management.Automation.Language.CommandParameterAst] }) | Select-Object -First 1
                if ($null -ne $element) { $lazy = $element.Extent.Text.Trim("'", '"') }
            }
        }
        $targets = @(if ($null -ne $targetNode) { Resolve-HookGraphStaticPath $targetNode $directory $variables })
        if ($targets.Count -eq 0) { $targets = @('UNRESOLVED: ' + $command.Extent.Text) }
        foreach ($target in $targets) {
            [pscustomobject]@{
                Kind = $kind; Target = $target; Leaf = $(if ($target -like 'UNRESOLVED*') { $target } else { ($target -split '/')[-1] }); ChildPathLiteral = $childLiteral
                Line = $command.Extent.StartLineNumber; Guarded = $guarded; SingleStatementTry = $single; Runtime = $runtime; Conditional = $conditional
                ErrorActionStop = ($command.Extent.Text -match '-ErrorAction\s+Stop'); LazyFunction = $lazy; Command = $command
            }
        }
    }
}

function Test-HookGraphStopPreference {
    # True when a script-scope $ErrorActionPreference = 'Stop' line precedes the given line.
    param([string] $ScriptText, [int] $Line)
    $lines = $ScriptText -split "`r?`n"
    for ($i = 0; $i -lt [Math]::Min($Line - 1, $lines.Count); $i++) { if ($lines[$i] -match '^\s*\$ErrorActionPreference\s*=\s*''Stop''') { return $true } }
    return $false
}

function Get-HookDependencyClosure {
    <#
    .SYNOPSIS
        Breadth-first transitive closure of one registered hook.
    .DESCRIPTION
        Returns one record per edge with Hook, Via, the Get-HookScriptEdge fields, Covered (guarded
        here or under a guarded shallower edge), and Terminating (a dot-source, an Import-Module with
        -ErrorAction Stop, or an Import-Module after a script-scope $ErrorActionPreference = 'Stop'
        line; RS-7). The target of an edge whose Runtime is True is not expanded: a runtime target
        enters the closure only through its hook-level pre-load edge. IncludeRuntimeTargets expands
        runtime targets as well (the #792 guard scans every module a hook can load).
    #>
    [CmdletBinding()]
    [OutputType([pscustomobject])]
    param(
        [Parameter(Mandatory)] [pscustomobject] $Registration,
        [scriptblock] $ReadText = $script:HookGraphDefaultReadText,
        [scriptblock] $TestPath = $script:HookGraphDefaultTestPath,
        [switch] $IncludeRuntimeTargets
    )

    if ($Registration.Hook -eq 'INLINE') { return }
    $root = $Registration.Root
    $queue = [System.Collections.Generic.Queue[object]]::new()
    $queue.Enqueue(@($Registration.Hook, $false))
    $seen = @{}
    while ($queue.Count -gt 0) {
        $item = $queue.Dequeue()
        $relative = [string]$item[0]; $inherited = [bool]$item[1]
        if ($seen.ContainsKey("$relative|$inherited")) { continue }
        $seen["$relative|$inherited"] = $true
        $text = & $ReadText (Join-HookGraphPath -Left $root -Right $relative)
        if ($null -eq $text) { continue }
        foreach ($edge in @(Get-HookScriptEdge -ScriptText $text -SourcePath $relative)) {
            $covered = $inherited -or $edge.Guarded
            $terminating = ($edge.Kind -eq 'DotSource') -or $edge.ErrorActionStop -or (Test-HookGraphStopPreference -ScriptText $text -Line $edge.Line)
            [pscustomobject]@{
                Surface = $Registration.Surface; Event = $Registration.Event; Hook = $Registration.Hook; Via = $relative
                Kind = $edge.Kind; Target = $edge.Target; Leaf = $edge.Leaf; ChildPathLiteral = $edge.ChildPathLiteral; Line = $edge.Line
                Guarded = $edge.Guarded; SingleStatementTry = $edge.SingleStatementTry; Covered = $covered; Terminating = $terminating
                Runtime = $edge.Runtime; Conditional = $edge.Conditional; ErrorActionStop = $edge.ErrorActionStop; LazyFunction = $edge.LazyFunction
            }
            if (($edge.Runtime -and -not $IncludeRuntimeTargets) -or $edge.Target -like 'UNRESOLVED*') { continue }
            if (& $TestPath (Join-HookGraphPath -Left $root -Right $edge.Target)) { $queue.Enqueue(@($edge.Target, $covered)) }
        }
    }
}

function Get-HookDecisionFunctionName {
    <#
    .SYNOPSIS
        Returns the hook's decision function by rule R-DECISION (plan section 3), or NONE.
    .DESCRIPTION
        (a) the first function named Invoke-<Name>Decision; else (b) the first function named
        Invoke-<Name>Validation that a command outside every function definition calls; else (c) the
        first function named Get-<Name>Decision whose name contains none of Block, Deny, Allow;
        else (d) NONE. Source order is ascending start offset.
    #>
    [CmdletBinding()]
    [OutputType([string])]
    param([Parameter(Mandatory)] [AllowEmptyString()] [string] $ScriptText)

    $tokens = $null
    $parseErrors = $null
    $ast = [System.Management.Automation.Language.Parser]::ParseInput($ScriptText, [ref]$tokens, [ref]$parseErrors)
    $functions = @($ast.FindAll({ param($n) $n -is [System.Management.Automation.Language.FunctionDefinitionAst] }, $true) | Sort-Object { $_.Extent.StartOffset })
    $outside = @($ast.FindAll({ param($n) $n -is [System.Management.Automation.Language.CommandAst] }, $true) | Where-Object {
            $p = $_.Parent
            while ($null -ne $p -and $p -isnot [System.Management.Automation.Language.FunctionDefinitionAst]) { $p = $p.Parent }
            $null -eq $p
        } | ForEach-Object { $_.GetCommandName() })
    $pick = @($functions | Where-Object { $_.Name -cmatch '^Invoke-[A-Za-z]+Decision$' }) | Select-Object -First 1
    if ($pick) { return $pick.Name }
    $pick = @($functions | Where-Object { $_.Name -cmatch '^Invoke-[A-Za-z]+Validation$' -and $outside -contains $_.Name }) | Select-Object -First 1
    if ($pick) { return $pick.Name }
    $pick = @($functions | Where-Object { $_.Name -cmatch '^Get-[A-Za-z]+Decision$' -and $_.Name -notmatch 'Block|Deny|Allow' }) | Select-Object -First 1
    if ($pick) { return $pick.Name }
    return 'NONE'
}
