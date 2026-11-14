# PoshQC.LeakScan.psm1 - static detection of Pester test state that can leak between test files (issue #1096).
#
# Get-PoshQCLeakFinding parses script text and reports each state write that no restore pairs with,
# under rules R1 (finally of an enclosing try), R2 (finally of a later try), R3 (later restore in the
# same block), R4 (AfterEach or AfterAll of an ancestor block), and R5 (cleanup helper functions).
# Writes inside cleanup are restores; a restore that pairs an earlier write under R3 is consumed.

$script:LeakCleanupCommands = @('aftereach', 'afterall')
$script:LeakSetLocationCommands = @('set-location', 'cd', 'chdir', 'sl')
$script:LeakPushLocationCommands = @('push-location', 'pushd')
$script:LeakPopLocationCommands = @('pop-location', 'popd')
$script:LeakItemCommands = @('set-item', 'new-item', 'remove-item', 'clear-item')
$script:LeakVariableCommands = @('set-variable', 'new-variable', 'remove-variable')
$script:LeakValueParameters = @(
    'name', 'value', 'scope', 'path', 'literalpath', 'erroraction', 'warningaction', 'informationaction',
    'option', 'description', 'visibility', 'itemtype', 'type', 'stackname', 'filter', 'include', 'exclude',
    'errorvariable', 'outvariable'
)

function Get-PoshQCLeakCommandBinding {
    # Splits a command's elements into named arguments (lower-case parameter name) and positional arguments.
    [CmdletBinding()]
    [OutputType([hashtable])]
    param([Parameter(Mandatory = $true)][System.Management.Automation.Language.CommandAst] $CommandAst)

    $named = @{}
    $positional = [System.Collections.Generic.List[object]]::new()
    $elements = $CommandAst.CommandElements
    $index = 1
    while ($index -lt $elements.Count) {
        $element = $elements[$index]
        if ($element -is [System.Management.Automation.Language.CommandParameterAst]) {
            $parameterName = $element.ParameterName.ToLowerInvariant()
            if ($null -ne $element.Argument) {
                $named[$parameterName] = $element.Argument
            } elseif ($script:LeakValueParameters -contains $parameterName -and ($index + 1) -lt $elements.Count) {
                $index++
                $named[$parameterName] = $elements[$index]
            } else {
                $named[$parameterName] = $null
            }
        } else {
            $positional.Add($element)
        }
        $index++
    }
    @{ Named = $named; Positional = $positional }
}

function Get-PoshQCLeakBoundArgument {
    # Returns the named argument when present, otherwise the positional argument at the given index.
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)][hashtable] $Binding,
        [Parameter(Mandatory = $true)][string[]] $Names,
        [int] $Position = -1
    )

    foreach ($name in $Names) {
        if ($Binding.Named.ContainsKey($name)) { return $Binding.Named[$name] }
    }
    if ($Position -ge 0 -and $Position -lt $Binding.Positional.Count) { return $Binding.Positional[$Position] }
    $null
}

function Get-PoshQCLeakArgumentText {
    # Returns the literal value of a string argument, the raw text inside an expandable string, or the
    # expression text of any other argument, so that a dynamic name keys on its expression text.
    [CmdletBinding()]
    [OutputType([string])]
    param([System.Management.Automation.Language.Ast] $Ast)

    if ($null -eq $Ast) { return '' }
    if ($Ast -is [System.Management.Automation.Language.StringConstantExpressionAst]) { return $Ast.Value }
    if ($Ast -is [System.Management.Automation.Language.ExpandableStringExpressionAst]) { return $Ast.Value }
    $Ast.Extent.Text
}

function Test-PoshQCLeakRestoreValue {
    # True when a value is a variable (including $null), a member, or an index expression, the forms
    # that rule R3 accepts as a restore. A literal or a computed value is not a restore.
    [CmdletBinding()]
    [OutputType([bool])]
    param([System.Management.Automation.Language.Ast] $Ast)

    $current = $Ast
    while ($current -is [System.Management.Automation.Language.PipelineAst] -and $current.PipelineElements.Count -eq 1) {
        $current = $current.PipelineElements[0]
    }
    if ($current -is [System.Management.Automation.Language.CommandExpressionAst]) { $current = $current.Expression }
    if ($current -is [System.Management.Automation.Language.ParenExpressionAst]) { return (Test-PoshQCLeakRestoreValue -Ast $current.Pipeline) }
    ($current -is [System.Management.Automation.Language.VariableExpressionAst]) -or
    ($current -is [System.Management.Automation.Language.MemberExpressionAst] -and $current -isnot [System.Management.Automation.Language.InvokeMemberExpressionAst]) -or
    ($current -is [System.Management.Automation.Language.IndexExpressionAst])
}

function Get-PoshQCLeakOperationRecord {
    # Builds one state operation record. Key is the kind plus the case-folded name.
    [CmdletBinding()]
    [OutputType([pscustomobject])]
    param(
        [Parameter(Mandatory = $true)][System.Management.Automation.Language.Ast] $Ast,
        [Parameter(Mandatory = $true)][string] $Kind,
        [Parameter(Mandatory = $true)][string] $Name,
        [bool] $IsWrite,
        [bool] $IsRestore,
        [bool] $Qualifies
    )

    [pscustomobject]@{
        Ast       = $Ast
        Kind      = $Kind
        Name      = $Name
        Key       = '{0}|{1}' -f $Kind, $Name.ToLowerInvariant()
        Line      = $Ast.Extent.StartLineNumber
        IsWrite   = $IsWrite
        IsRestore = $IsRestore
        Qualifies = $Qualifies
    }
}

function Test-PoshQCLeakTypeName {
    # True when a type expression names one of the given types, with or without the System. prefix.
    [CmdletBinding()]
    [OutputType([bool])]
    param(
        [System.Management.Automation.Language.Ast] $Ast,
        [Parameter(Mandatory = $true)][string] $TypeName
    )

    if ($Ast -isnot [System.Management.Automation.Language.TypeExpressionAst]) { return $false }
    $fullName = $Ast.TypeName.FullName -replace '^(?i)System\.', ''
    [string]::Equals($fullName, $TypeName, [StringComparison]::OrdinalIgnoreCase)
}

function Get-PoshQCLeakAssignmentOperation {
    # Detects assignments to $env:X, ${env:X}, $global:X, and [Environment]::CurrentDirectory.
    [CmdletBinding()]
    param([Parameter(Mandatory = $true)][System.Management.Automation.Language.AssignmentStatementAst] $AssignmentAst)

    $isPlain = $AssignmentAst.Operator -eq [System.Management.Automation.Language.TokenKind]::Equals
    $qualifies = $isPlain -and (Test-PoshQCLeakRestoreValue -Ast $AssignmentAst.Right)
    $targets = @($AssignmentAst.Left)
    if ($AssignmentAst.Left -is [System.Management.Automation.Language.ArrayLiteralAst]) { $targets = @($AssignmentAst.Left.Elements) }
    foreach ($target in $targets) {
        while ($target -is [System.Management.Automation.Language.AttributedExpressionAst]) { $target = $target.Child }
        if ($target -is [System.Management.Automation.Language.VariableExpressionAst]) {
            $userPath = $target.VariablePath.UserPath
            if ($userPath -match '^(?i)env:(.+)$') {
                Get-PoshQCLeakOperationRecord -Ast $AssignmentAst -Kind 'env' -Name $Matches[1] -IsWrite $true -IsRestore $true -Qualifies $qualifies
            } elseif ($userPath -match '^(?i)global:(.+)$') {
                Get-PoshQCLeakOperationRecord -Ast $AssignmentAst -Kind 'global-variable' -Name $Matches[1] -IsWrite $true -IsRestore $true -Qualifies $qualifies
            }
        } elseif ($target -is [System.Management.Automation.Language.MemberExpressionAst] -and $target.Static -and
            (Test-PoshQCLeakTypeName -Ast $target.Expression -TypeName 'Environment') -and
            [string]::Equals((Get-PoshQCLeakArgumentText -Ast $target.Member), 'CurrentDirectory', [StringComparison]::OrdinalIgnoreCase)) {
            Get-PoshQCLeakOperationRecord -Ast $AssignmentAst -Kind 'process-directory' -Name 'process-directory' -IsWrite $true -IsRestore $true -Qualifies $qualifies
        }
    }
}

function Get-PoshQCLeakItemOperation {
    # Detects Set-Item, New-Item, Remove-Item, and Clear-Item on Env: and Function: paths.
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)][System.Management.Automation.Language.CommandAst] $CommandAst,
        [Parameter(Mandatory = $true)][string] $CommandName,
        [Parameter(Mandatory = $true)][hashtable] $Binding
    )

    $pathText = Get-PoshQCLeakArgumentText -Ast (Get-PoshQCLeakBoundArgument -Binding $Binding -Names @('path', 'literalpath') -Position 0)
    $isRemove = $CommandName -eq 'remove-item'
    $isSet = $CommandName -eq 'set-item'
    $valuePosition = if ($Binding.Named.ContainsKey('path') -or $Binding.Named.ContainsKey('literalpath')) { 0 } else { 1 }
    $qualifies = $isRemove -or ($isSet -and (Test-PoshQCLeakRestoreValue -Ast (Get-PoshQCLeakBoundArgument -Binding $Binding -Names @('value') -Position $valuePosition)))
    if ($pathText -match '^(?i)env:[\\/]?(.*)$') {
        $name = $Matches[1]
        if (-not $name) { $name = Get-PoshQCLeakArgumentText -Ast (Get-PoshQCLeakBoundArgument -Binding $Binding -Names @('name')) }
        if (-not $name) { return }
        Get-PoshQCLeakOperationRecord -Ast $CommandAst -Kind 'env' -Name $name -IsWrite $true -IsRestore ($isRemove -or $isSet) -Qualifies $qualifies
    } elseif ($pathText -match '^(?i)function:[\\/]?(global:)?(.+)$') {
        $isGlobal = [bool] $Matches[1]
        Get-PoshQCLeakOperationRecord -Ast $CommandAst -Kind 'global-function' -Name $Matches[2] -IsWrite ($isGlobal -and $CommandName -in @('new-item', 'set-item')) -IsRestore ($isRemove -or $isSet) -Qualifies $qualifies
    }
}

function Get-PoshQCLeakVariableOperation {
    # Detects Set-Variable, New-Variable, and Remove-Variable with -Scope Global.
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)][System.Management.Automation.Language.CommandAst] $CommandAst,
        [Parameter(Mandatory = $true)][string] $CommandName,
        [Parameter(Mandatory = $true)][hashtable] $Binding
    )

    $scopeText = Get-PoshQCLeakArgumentText -Ast (Get-PoshQCLeakBoundArgument -Binding $Binding -Names @('scope'))
    if (-not [string]::Equals($scopeText, 'Global', [StringComparison]::OrdinalIgnoreCase)) { return }
    $name = Get-PoshQCLeakArgumentText -Ast (Get-PoshQCLeakBoundArgument -Binding $Binding -Names @('name') -Position 0)
    if (-not $name) { return }
    $isRemove = $CommandName -eq 'remove-variable'
    $isSet = $CommandName -eq 'set-variable'
    $valuePosition = if ($Binding.Named.ContainsKey('name')) { 0 } else { 1 }
    $qualifies = $isRemove -or ($isSet -and (Test-PoshQCLeakRestoreValue -Ast (Get-PoshQCLeakBoundArgument -Binding $Binding -Names @('value') -Position $valuePosition)))
    Get-PoshQCLeakOperationRecord -Ast $CommandAst -Kind 'global-variable' -Name $name -IsWrite $true -IsRestore ($isRemove -or $isSet) -Qualifies $qualifies
}

function Get-PoshQCLeakCommandOperation {
    # Detects state operations expressed as commands. A command whose name is dynamic is skipped, and
    # a command named as an argument (for example of Mock) is not the invoked command.
    [CmdletBinding()]
    param([Parameter(Mandatory = $true)][System.Management.Automation.Language.CommandAst] $CommandAst)

    $rawName = $CommandAst.GetCommandName()
    if (-not $rawName) { return }
    $commandName = $rawName.ToLowerInvariant()
    $binding = Get-PoshQCLeakCommandBinding -CommandAst $CommandAst
    if ($script:LeakItemCommands -contains $commandName) {
        Get-PoshQCLeakItemOperation -CommandAst $CommandAst -CommandName $commandName -Binding $binding
    } elseif ($script:LeakVariableCommands -contains $commandName) {
        Get-PoshQCLeakVariableOperation -CommandAst $CommandAst -CommandName $commandName -Binding $binding
    } elseif ($script:LeakSetLocationCommands -contains $commandName) {
        $target = Get-PoshQCLeakBoundArgument -Binding $binding -Names @('path', 'literalpath') -Position 0
        Get-PoshQCLeakOperationRecord -Ast $CommandAst -Kind 'location' -Name 'location' -IsWrite $true -IsRestore $true -Qualifies (Test-PoshQCLeakRestoreValue -Ast $target)
    } elseif ($script:LeakPushLocationCommands -contains $commandName) {
        Get-PoshQCLeakOperationRecord -Ast $CommandAst -Kind 'location' -Name 'location' -IsWrite $true -IsRestore $false -Qualifies $false
    } elseif ($script:LeakPopLocationCommands -contains $commandName) {
        Get-PoshQCLeakOperationRecord -Ast $CommandAst -Kind 'location' -Name 'location' -IsWrite $false -IsRestore $true -Qualifies $true
    }
}

function Get-PoshQCLeakMemberOperation {
    # Detects [Environment]::SetEnvironmentVariable and [IO.Directory]::SetCurrentDirectory calls.
    [CmdletBinding()]
    param([Parameter(Mandatory = $true)][System.Management.Automation.Language.InvokeMemberExpressionAst] $InvokeAst)

    if (-not $InvokeAst.Static) { return }
    $member = Get-PoshQCLeakArgumentText -Ast $InvokeAst.Member
    $arguments = @($InvokeAst.Arguments)
    if ((Test-PoshQCLeakTypeName -Ast $InvokeAst.Expression -TypeName 'Environment') -and
        [string]::Equals($member, 'SetEnvironmentVariable', [StringComparison]::OrdinalIgnoreCase) -and $arguments.Count -ge 2) {
        $name = Get-PoshQCLeakArgumentText -Ast $arguments[0]
        Get-PoshQCLeakOperationRecord -Ast $InvokeAst -Kind 'env' -Name $name -IsWrite $true -IsRestore $true -Qualifies (Test-PoshQCLeakRestoreValue -Ast $arguments[1])
    } elseif ((Test-PoshQCLeakTypeName -Ast $InvokeAst.Expression -TypeName 'IO.Directory') -and
        [string]::Equals($member, 'SetCurrentDirectory', [StringComparison]::OrdinalIgnoreCase) -and $arguments.Count -ge 1) {
        Get-PoshQCLeakOperationRecord -Ast $InvokeAst -Kind 'process-directory' -Name 'process-directory' -IsWrite $true -IsRestore $true -Qualifies (Test-PoshQCLeakRestoreValue -Ast $arguments[0])
    }
}

function Get-PoshQCLeakOperation {
    # Collects every state operation in a parsed script, in source order.
    [CmdletBinding()]
    param([Parameter(Mandatory = $true)][System.Management.Automation.Language.Ast] $Ast)

    $nodes = $Ast.FindAll({
            param($node)
            $node -is [System.Management.Automation.Language.AssignmentStatementAst] -or
            $node -is [System.Management.Automation.Language.CommandAst] -or
            $node -is [System.Management.Automation.Language.InvokeMemberExpressionAst] -or
            $node -is [System.Management.Automation.Language.FunctionDefinitionAst]
        }, $true)
    foreach ($node in $nodes) {
        if ($node -is [System.Management.Automation.Language.AssignmentStatementAst]) {
            Get-PoshQCLeakAssignmentOperation -AssignmentAst $node
        } elseif ($node -is [System.Management.Automation.Language.CommandAst]) {
            Get-PoshQCLeakCommandOperation -CommandAst $node
        } elseif ($node -is [System.Management.Automation.Language.InvokeMemberExpressionAst]) {
            Get-PoshQCLeakMemberOperation -InvokeAst $node
        } elseif ($node.Name -match '^(?i)global:(.+)$') {
            Get-PoshQCLeakOperationRecord -Ast $node -Kind 'global-function' -Name $Matches[1] -IsWrite $true -IsRestore $false -Qualifies $false
        }
    }
}

function Test-PoshQCLeakContain {
    # True when Inner lies within Outer, judged by source offsets of the same parse.
    [CmdletBinding()]
    [OutputType([bool])]
    param(
        [Parameter(Mandatory = $true)][System.Management.Automation.Language.Ast] $Outer,
        [Parameter(Mandatory = $true)][System.Management.Automation.Language.Ast] $Inner
    )

    $Inner.Extent.StartOffset -ge $Outer.Extent.StartOffset -and $Inner.Extent.EndOffset -le $Outer.Extent.EndOffset
}

function Get-PoshQCLeakCleanupBlock {
    # Returns the scriptblock argument of an AfterEach or AfterAll command, or nothing.
    [CmdletBinding()]
    param([System.Management.Automation.Language.Ast] $Ast)

    if ($Ast -isnot [System.Management.Automation.Language.CommandAst]) { return }
    $name = $Ast.GetCommandName()
    if (-not $name -or $script:LeakCleanupCommands -notcontains $name.ToLowerInvariant()) { return }
    foreach ($element in $Ast.CommandElements) {
        if ($element -is [System.Management.Automation.Language.ScriptBlockExpressionAst]) { return $element }
    }
}

function Get-PoshQCLeakStatementSlot {
    # Returns the statement list holding the operation and the index of the statement that contains it.
    [CmdletBinding()]
    param([Parameter(Mandatory = $true)][System.Management.Automation.Language.Ast] $Ast)

    $node = $Ast
    while ($null -ne $node.Parent) {
        $parent = $node.Parent
        if ($parent -is [System.Management.Automation.Language.StatementBlockAst] -or $parent -is [System.Management.Automation.Language.NamedBlockAst]) {
            $statements = $parent.Statements
            for ($index = 0; $index -lt $statements.Count; $index++) {
                if ([object]::ReferenceEquals($statements[$index], $node)) { return [pscustomobject]@{ Block = $parent; Index = $index } }
            }
        }
        $node = $parent
    }
    $null
}

function Test-PoshQCLeakRegionRestore {
    # True when a cleanup region holds a restore of the key, directly or through a cleanup helper (R5).
    [CmdletBinding()]
    [OutputType([bool])]
    param(
        [Parameter(Mandatory = $true)][System.Management.Automation.Language.Ast] $Region,
        [Parameter(Mandatory = $true)][string] $Key,
        [Parameter(Mandatory = $true)][AllowEmptyCollection()][object[]] $Operations,
        [Parameter(Mandatory = $true)][hashtable] $HelperRestoreKeys
    )

    foreach ($operation in $Operations) {
        if ($operation.IsRestore -and $operation.Key -eq $Key -and (Test-PoshQCLeakContain -Outer $Region -Inner $operation.Ast)) { return $true }
    }
    foreach ($command in $Region.FindAll({ param($node) $node -is [System.Management.Automation.Language.CommandAst] }, $true)) {
        $name = $command.GetCommandName()
        if ($name -and $HelperRestoreKeys.ContainsKey($name.ToLowerInvariant()) -and $HelperRestoreKeys[$name.ToLowerInvariant()].Contains($Key)) { return $true }
    }
    $false
}

function Get-PoshQCLeakCleanupContext {
    # Finds the cleanup regions (finally blocks, AfterEach and AfterAll bodies) and the file functions
    # called from them (R5), with the restore keys each such helper holds.
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)][System.Management.Automation.Language.Ast] $Ast,
        [Parameter(Mandatory = $true)][AllowEmptyCollection()][object[]] $Operations
    )

    $regions = [System.Collections.Generic.List[object]]::new()
    foreach ($try in $Ast.FindAll({ param($node) $node -is [System.Management.Automation.Language.TryStatementAst] }, $true)) {
        if ($null -ne $try.Finally) { $regions.Add($try.Finally) }
    }
    foreach ($command in $Ast.FindAll({ param($node) $node -is [System.Management.Automation.Language.CommandAst] }, $true)) {
        $block = Get-PoshQCLeakCleanupBlock -Ast $command
        if ($null -ne $block) { $regions.Add($block) }
    }
    $definitions = @{}
    foreach ($definition in $Ast.FindAll({ param($node) $node -is [System.Management.Automation.Language.FunctionDefinitionAst] }, $true)) {
        $definitions[($definition.Name -replace '^(?i)global:', '').ToLowerInvariant()] = $definition
    }
    $helperBodies = [System.Collections.Generic.List[object]]::new()
    $helperRestoreKeys = @{}
    foreach ($region in $regions) {
        foreach ($command in $region.FindAll({ param($node) $node -is [System.Management.Automation.Language.CommandAst] }, $true)) {
            $name = $command.GetCommandName()
            if (-not $name -or -not $definitions.ContainsKey($name.ToLowerInvariant()) -or $helperRestoreKeys.ContainsKey($name.ToLowerInvariant())) { continue }
            $body = $definitions[$name.ToLowerInvariant()].Body
            $keys = [System.Collections.Generic.HashSet[string]]::new()
            foreach ($operation in $Operations) {
                if ($operation.IsRestore -and (Test-PoshQCLeakContain -Outer $body -Inner $operation.Ast)) { [void] $keys.Add($operation.Key) }
            }
            $helperRestoreKeys[$name.ToLowerInvariant()] = $keys
            $helperBodies.Add($body)
        }
    }
    [pscustomobject]@{ Regions = $regions; HelperBodies = $helperBodies; HelperRestoreKeys = $helperRestoreKeys }
}

function Test-PoshQCLeakAncestorCleanup {
    # Rule R4: a lexical ancestor scriptblock directly holds AfterEach or AfterAll that restores the key.
    [CmdletBinding()]
    [OutputType([bool])]
    param(
        [Parameter(Mandatory = $true)][pscustomobject] $Operation,
        [Parameter(Mandatory = $true)][AllowEmptyCollection()][object[]] $Operations,
        [Parameter(Mandatory = $true)][hashtable] $HelperRestoreKeys
    )

    $node = $Operation.Ast.Parent
    while ($null -ne $node) {
        if ($node -is [System.Management.Automation.Language.ScriptBlockAst]) {
            foreach ($named in @($node.BeginBlock, $node.ProcessBlock, $node.EndBlock)) {
                if ($null -eq $named) { continue }
                foreach ($statement in $named.Statements) {
                    if ($statement -isnot [System.Management.Automation.Language.PipelineAst] -or $statement.PipelineElements.Count -ne 1) { continue }
                    $block = Get-PoshQCLeakCleanupBlock -Ast $statement.PipelineElements[0]
                    if ($null -ne $block -and (Test-PoshQCLeakRegionRestore -Region $block -Key $Operation.Key -Operations $Operations -HelperRestoreKeys $HelperRestoreKeys)) { return $true }
                }
            }
        }
        $node = $node.Parent
    }
    $false
}

function Get-PoshQCLeakPairing {
    # Applies rules R1 to R4 to one write. Returns a record whose IsPaired states the outcome and whose
    # Restore holds the R3 restore operation that the write consumes, when R3 decided it.
    [CmdletBinding()]
    [OutputType([pscustomobject])]
    param(
        [Parameter(Mandatory = $true)][pscustomobject] $Operation,
        [Parameter(Mandatory = $true)][AllowEmptyCollection()][object[]] $Operations,
        [Parameter(Mandatory = $true)][hashtable] $HelperRestoreKeys
    )

    $node = $Operation.Ast.Parent
    $child = $Operation.Ast
    while ($null -ne $node) {
        if ($node -is [System.Management.Automation.Language.TryStatementAst] -and $null -ne $node.Finally -and
            [object]::ReferenceEquals($node.Body, $child) -and
            (Test-PoshQCLeakRegionRestore -Region $node.Finally -Key $Operation.Key -Operations $Operations -HelperRestoreKeys $HelperRestoreKeys)) {
            return [pscustomobject]@{ IsPaired = $true; Restore = $null }
        }
        $child = $node
        $node = $node.Parent
    }
    $slot = Get-PoshQCLeakStatementSlot -Ast $Operation.Ast
    if ($null -ne $slot) {
        $statements = $slot.Block.Statements
        for ($index = $slot.Index + 1; $index -lt $statements.Count; $index++) {
            $statement = $statements[$index]
            if ($statement -is [System.Management.Automation.Language.TryStatementAst] -and $null -ne $statement.Finally -and
                (Test-PoshQCLeakRegionRestore -Region $statement.Finally -Key $Operation.Key -Operations $Operations -HelperRestoreKeys $HelperRestoreKeys)) {
                return [pscustomobject]@{ IsPaired = $true; Restore = $null }
            }
        }
        foreach ($candidate in $Operations) {
            if (-not $candidate.IsRestore -or -not $candidate.Qualifies -or $candidate.Key -ne $Operation.Key) { continue }
            $candidateSlot = Get-PoshQCLeakStatementSlot -Ast $candidate.Ast
            if ($null -ne $candidateSlot -and [object]::ReferenceEquals($candidateSlot.Block, $slot.Block) -and $candidateSlot.Index -gt $slot.Index) {
                return [pscustomobject]@{ IsPaired = $true; Restore = $candidate }
            }
        }
    }
    if (Test-PoshQCLeakAncestorCleanup -Operation $Operation -Operations $Operations -HelperRestoreKeys $HelperRestoreKeys) { return [pscustomobject]@{ IsPaired = $true; Restore = $null } }
    [pscustomobject]@{ IsPaired = $false; Restore = $null }
}

<#
.SYNOPSIS
Reports test state writes with no matching restore in one script.
.DESCRIPTION
Parses Content with the PowerShell parser (never from disk) and returns one finding per unpaired write
of an environment variable, global variable, global function, location, or process directory, sorted
by line. Throws, naming Path, when the content does not parse.
.PARAMETER Content
The script text to scan.
.PARAMETER Path
The repository-relative path reported in each finding; backslashes become forward slashes.
#>
function Get-PoshQCLeakFinding {
    [CmdletBinding()]
    [OutputType([pscustomobject])]
    param(
        [Parameter(Mandatory = $true)][AllowEmptyString()][string] $Content,
        [Parameter(Mandatory = $true)][string] $Path
    )

    $normalizedPath = $Path -replace '\\', '/'
    $tokens = $null
    $parseErrors = $null
    $ast = [System.Management.Automation.Language.Parser]::ParseInput($Content, [ref] $tokens, [ref] $parseErrors)
    if ($parseErrors -and $parseErrors.Count -gt 0) {
        $first = $parseErrors[0]
        throw "Parse error in ${normalizedPath} at line $($first.Extent.StartLineNumber): $($first.Message)"
    }
    $operations = @(Get-PoshQCLeakOperation -Ast $ast)
    if ($operations.Count -eq 0) { return }
    $context = Get-PoshQCLeakCleanupContext -Ast $ast -Operations $operations
    $consumed = [System.Collections.Generic.HashSet[object]]::new()
    $findings = [System.Collections.Generic.List[object]]::new()
    foreach ($operation in $operations) {
        if (-not $operation.IsWrite) { continue }
        $inCleanup = $false
        foreach ($region in @($context.Regions) + @($context.HelperBodies)) {
            if (Test-PoshQCLeakContain -Outer $region -Inner $operation.Ast) { $inCleanup = $true; break }
        }
        if ($inCleanup) { continue }
        $pairing = Get-PoshQCLeakPairing -Operation $operation -Operations $operations -HelperRestoreKeys $context.HelperRestoreKeys
        # The consumed set holds AST nodes, which compare by reference; record objects would not.
        if ($null -ne $pairing.Restore) { [void] $consumed.Add($pairing.Restore.Ast) }
        if (-not $pairing.IsPaired -and -not $consumed.Contains($operation.Ast)) {
            $findings.Add([pscustomobject]@{ Path = $normalizedPath; Line = $operation.Line; Kind = $operation.Kind; Name = $operation.Name })
        }
    }
    $findings | Sort-Object -Property Line, Kind, Name
}
